"""
Deploy all study hub content to Snowflake tables in PST.PS_APPS_DEV.
Reads local JSON/MD files and generates INSERT statements.

Tables populated:
- CERT_REGISTRY (cert metadata)
- CERT_DOMAINS (domain definitions)
- CERT_DOMAIN_TIPS (study tips per domain)
- CERT_QUESTIONS (all practice questions)
- CERT_REVIEW_NOTES (markdown review notes)

Usage: python3 Scripts/deploy_content_to_snowflake.py
  This script writes SQL files that can be executed via snow sql or Cortex.
"""
import json
import os
import re
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
OUT = BASE / "Scripts"

def escape_sql(s):
    """Escape single quotes for SQL string literals."""
    if s is None:
        return "NULL"
    return s.replace("'", "''")

def sql_str(s):
    """Wrap in single quotes or return NULL."""
    if s is None:
        return "NULL"
    return f"'{escape_sql(str(s))}'"

def sql_bool(b):
    return "TRUE" if b else "FALSE"

def sql_variant(obj):
    """Convert Python object to PARSE_JSON('...') for VARIANT columns."""
    if obj is None:
        return "NULL"
    j = json.dumps(obj, ensure_ascii=False)
    return f"PARSE_JSON('{escape_sql(j)}')"

# Load registry
with open(BASE / "registry.json") as f:
    registry = json.load(f)["certifications"]

# ═══════════════════════════════════════════════════
# 1. CERT_REGISTRY
# ═══════════════════════════════════════════════════
lines = ["-- CERT_REGISTRY data\n",
         "TRUNCATE TABLE IF EXISTS PST.PS_APPS_DEV.CERT_REGISTRY;\n"]

for ck, cert in registry.items():
    lines.append(f"""INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  {sql_str(ck)}, {sql_str(cert.get('name'))}, {sql_str(cert.get('code'))},
  {sql_str(cert.get('full_name'))}, {sql_str(cert.get('category'))}, {sql_str(cert.get('color'))},
  {sql_str(cert.get('sidebar_gradient'))}, {sql_str(cert.get('sidebar_accent'))},
  {sql_str(cert.get('sidebar_text'))}, {sql_str(cert.get('sidebar_sub'))},
  {sql_str(cert.get('difficulty'))}, {sql_bool(cert.get('available', False))},
  {sql_variant(cert.get('exam'))}, {sql_variant(cert.get('info'))},
  {sql_str(cert.get('questions_file'))}
);\n""")

with open(OUT / "deploy_01_cert_registry.sql", "w") as f:
    f.write("\n".join(lines))
print(f"Wrote {len(registry)} registry entries")

# ═══════════════════════════════════════════════════
# 2. CERT_DOMAINS + CERT_DOMAIN_TIPS
# ═══════════════════════════════════════════════════
domain_lines = ["-- CERT_DOMAINS data\n",
                "TRUNCATE TABLE IF EXISTS PST.PS_APPS_DEV.CERT_DOMAINS;\n"]
tip_lines = ["-- CERT_DOMAIN_TIPS data\n",
             "TRUNCATE TABLE IF EXISTS PST.PS_APPS_DEV.CERT_DOMAIN_TIPS;\n"]

domain_count = 0
tip_count = 0

for ck, cert in registry.items():
    for sort_order, (dname, dinfo) in enumerate(cert.get("domains", {}).items(), 1):
        domain_count += 1
        domain_lines.append(f"""INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ({sql_str(ck)}, {sql_str(dname)}, {sql_str(dinfo.get('dir'))},
  {sql_str(dinfo.get('color'))}, {sql_str(dinfo.get('css_num'))},
  {sql_str(dinfo.get('weight'))}, {sort_order});\n""")

    for dname, tips in cert.get("domain_tips", {}).items():
        for tip_order, tip_text in enumerate(tips, 1):
            tip_count += 1
            tip_lines.append(f"""INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ({sql_str(ck)}, {sql_str(dname)}, {tip_order}, {sql_str(tip_text)});\n""")

with open(OUT / "deploy_02_cert_domains.sql", "w") as f:
    f.write("\n".join(domain_lines))

with open(OUT / "deploy_03_cert_domain_tips.sql", "w") as f:
    f.write("\n".join(tip_lines))

print(f"Wrote {domain_count} domain entries, {tip_count} tips")

# ═══════════════════════════════════════════════════
# 3. CERT_QUESTIONS (architect only for now)
# ═══════════════════════════════════════════════════
q_lines = ["-- CERT_QUESTIONS data (architect)\n",
           "DELETE FROM PST.PS_APPS_DEV.CERT_QUESTIONS WHERE CERT_KEY = 'architect';\n"]

cert_key = "architect"
qfile = BASE / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "architect_questions.json"

with open(qfile) as f:
    questions = json.load(f)

for q in questions:
    opts = json.dumps(q["options"], ensure_ascii=False)
    correct = json.dumps(q["correct_indices"])
    q_lines.append(f"""INSERT INTO PST.PS_APPS_DEV.CERT_QUESTIONS
(CERT_KEY, QUESTION_ID, SOURCE, DOMAIN, QUESTION_TEXT, OPTIONS, CORRECT_INDICES, EXPLANATION, DIFFICULTY)
VALUES ({sql_str(cert_key)}, {sql_str(q['id'])}, {sql_str(q.get('source'))},
  {sql_str(q.get('domain'))}, {sql_str(q.get('question'))},
  PARSE_JSON('{escape_sql(opts)}'),
  PARSE_JSON('{escape_sql(correct)}'),
  {sql_str(q.get('overall_explanation'))}, {sql_str(q.get('difficulty'))});\n""")

with open(OUT / "deploy_04_cert_questions_architect.sql", "w") as f:
    f.write("\n".join(q_lines))

print(f"Wrote {len(questions)} architect questions")

# ═══════════════════════════════════════════════════
# 4. CERT_REVIEW_NOTES (architect)
# ═══════════════════════════════════════════════════
note_lines = ["-- CERT_REVIEW_NOTES data (architect)\n",
              "DELETE FROM PST.PS_APPS_DEV.CERT_REVIEW_NOTES WHERE CERT_KEY = 'architect';\n"]

note_count = 0
arch_domains = registry["architect"]["domains"]

for dname, dinfo in arch_domains.items():
    domain_dir = dinfo.get("dir", "")
    for lang in ["en", "pt", "es"]:
        md_path = BASE / domain_dir / f"review_notes_{lang}.md"
        if not md_path.exists():
            md_path = BASE / domain_dir / "review_notes.md"
        if md_path.exists():
            content = md_path.read_text(encoding="utf-8")
            note_count += 1
            note_lines.append(f"""INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ({sql_str('architect')}, {sql_str(dname)}, {sql_str(lang)},
  {sql_str(content)});\n""")

with open(OUT / "deploy_05_cert_review_notes_architect.sql", "w") as f:
    f.write("\n".join(note_lines))

print(f"Wrote {note_count} review note entries")

# ═══════════════════════════════════════════════════
# 5. Combined runner
# ═══════════════════════════════════════════════════
runner = """-- Deploy all study hub content to PST.PS_APPS_DEV
-- Run each file in order using: snow sql -f <file> -c VCVDCXW-YD26998
-- Or execute via Cortex Code / Snowsight

-- Step 1: Registry
-- snow sql -f Scripts/deploy_01_cert_registry.sql -c VCVDCXW-YD26998

-- Step 2: Domains
-- snow sql -f Scripts/deploy_02_cert_domains.sql -c VCVDCXW-YD26998

-- Step 3: Domain Tips
-- snow sql -f Scripts/deploy_03_cert_domain_tips.sql -c VCVDCXW-YD26998

-- Step 4: Questions (architect)
-- snow sql -f Scripts/deploy_04_cert_questions_architect.sql -c VCVDCXW-YD26998

-- Step 5: Review Notes (architect)
-- snow sql -f Scripts/deploy_05_cert_review_notes_architect.sql -c VCVDCXW-YD26998
"""

with open(OUT / "deploy_00_readme.sql", "w") as f:
    f.write(runner)

print("\nAll deploy scripts written to Scripts/deploy_*.sql")
print("Run them in order to populate Snowflake tables.")
