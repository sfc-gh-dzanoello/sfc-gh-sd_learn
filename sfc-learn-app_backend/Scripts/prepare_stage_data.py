"""
Prepare JSON files for Snowflake stage upload, then generate COPY INTO statements.
Creates clean NDJSON files that can be PUT to a stage and loaded into tables.
"""
import json
import os
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
OUT = BASE / "Scripts" / "stage_data"
OUT.mkdir(exist_ok=True)

# Load registry
with open(BASE / "registry.json") as f:
    registry = json.load(f)["certifications"]

# ═══════════════════════════════════════════════════
# 1. cert_registry.json
# ═══════════════════════════════════════════════════
reg_rows = []
for ck, cert in registry.items():
    reg_rows.append({
        "CERT_KEY": ck,
        "NAME": cert.get("name"),
        "CODE": cert.get("code"),
        "FULL_NAME": cert.get("full_name"),
        "CATEGORY": cert.get("category"),
        "COLOR": cert.get("color"),
        "SIDEBAR_GRADIENT": cert.get("sidebar_gradient"),
        "SIDEBAR_ACCENT": cert.get("sidebar_accent"),
        "SIDEBAR_TEXT": cert.get("sidebar_text"),
        "SIDEBAR_SUB": cert.get("sidebar_sub"),
        "DIFFICULTY": cert.get("difficulty"),
        "AVAILABLE": cert.get("available", False),
        "EXAM_INFO": cert.get("exam", {}),
        "DISPLAY_INFO": cert.get("info", {}),
        "QUESTIONS_FILE": cert.get("questions_file"),
    })
with open(OUT / "cert_registry.json", "w") as f:
    json.dump(reg_rows, f, ensure_ascii=False)
print(f"cert_registry.json: {len(reg_rows)} rows")

# ═══════════════════════════════════════════════════
# 2. cert_domains.json
# ═══════════════════════════════════════════════════
domain_rows = []
for ck, cert in registry.items():
    for sort_order, (dname, dinfo) in enumerate(cert.get("domains", {}).items(), 1):
        domain_rows.append({
            "CERT_KEY": ck,
            "DOMAIN_NAME": dname,
            "DOMAIN_DIR": dinfo.get("dir", ""),
            "COLOR": dinfo.get("color", "#6B7280"),
            "CSS_NUM": dinfo.get("css_num", "1"),
            "WEIGHT": dinfo.get("weight", ""),
            "SORT_ORDER": sort_order,
        })
with open(OUT / "cert_domains.json", "w") as f:
    json.dump(domain_rows, f, ensure_ascii=False)
print(f"cert_domains.json: {len(domain_rows)} rows")

# ═══════════════════════════════════════════════════
# 3. cert_domain_tips.json
# ═══════════════════════════════════════════════════
tip_rows = []
for ck, cert in registry.items():
    for dname, tips in cert.get("domain_tips", {}).items():
        for tip_order, tip_text in enumerate(tips, 1):
            tip_rows.append({
                "CERT_KEY": ck,
                "DOMAIN_NAME": dname,
                "TIP_ORDER": tip_order,
                "TIP_TEXT": tip_text,
            })
with open(OUT / "cert_domain_tips.json", "w") as f:
    json.dump(tip_rows, f, ensure_ascii=False)
print(f"cert_domain_tips.json: {len(tip_rows)} rows")

# ═══════════════════════════════════════════════════
# 4. cert_questions_architect.json
# ═══════════════════════════════════════════════════
qfile = BASE / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "architect_questions.json"
with open(qfile) as f:
    questions = json.load(f)

q_rows = []
for q in questions:
    q_rows.append({
        "CERT_KEY": "architect",
        "QUESTION_ID": q["id"],
        "SOURCE": q.get("source"),
        "DOMAIN": q.get("domain"),
        "QUESTION_TEXT": q.get("question"),
        "OPTIONS": q.get("options", []),
        "CORRECT_INDICES": q.get("correct_indices", []),
        "EXPLANATION": q.get("overall_explanation", ""),
        "DIFFICULTY": q.get("difficulty"),
    })
with open(OUT / "cert_questions_architect.json", "w") as f:
    json.dump(q_rows, f, ensure_ascii=False)
print(f"cert_questions_architect.json: {len(q_rows)} rows")

# ═══════════════════════════════════════════════════
# 5. cert_review_notes_architect.json
# ═══════════════════════════════════════════════════
note_rows = []
arch_domains = registry["architect"]["domains"]
for dname, dinfo in arch_domains.items():
    domain_dir = dinfo.get("dir", "")
    for lang in ["en", "pt", "es"]:
        md_path = BASE / domain_dir / f"review_notes_{lang}.md"
        if not md_path.exists():
            md_path = BASE / domain_dir / "review_notes.md"
        if md_path.exists():
            content = md_path.read_text(encoding="utf-8")
            note_rows.append({
                "CERT_KEY": "architect",
                "DOMAIN_NAME": dname,
                "LANG": lang,
                "CONTENT": content,
            })
with open(OUT / "cert_review_notes_architect.json", "w") as f:
    json.dump(note_rows, f, ensure_ascii=False)
print(f"cert_review_notes_architect.json: {len(note_rows)} rows")

print(f"\nAll files written to {OUT}/")
print("Next: PUT these to @PST.PS_APPS_DEV.STUDY_HUB_STAGE")
