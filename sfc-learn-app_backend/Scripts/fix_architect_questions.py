"""
Fix architect_questions.json:
1. Fix broken multi-select correct_indices (q1, q5)
2. Rewrite image-dependent question (q27) as text-only
3. Add difficulty levels to all 289 questions
"""
import json
import re
from pathlib import Path

QF = Path(__file__).resolve().parent.parent / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "architect_questions.json"

with open(QF) as f:
    qs = json.load(f)

# ── Fix 1: architect_test1_q1 ── expects 2 correct, only has [2]
# Explanation says multi-cluster (index 1) + dedicated warehouse (index 2)
for q in qs:
    if q["id"] == "architect_test1_q1":
        q["correct_indices"] = [1, 2]
        print(f"Fixed {q['id']}: correct_indices -> {q['correct_indices']}")

# ── Fix 2: architect_test1_q5 ── expects 3 correct, only has [4, 5]
# Dimensional/Kimball (1), Inmon/3NF (4), Data vault (5)
for q in qs:
    if q["id"] == "architect_test1_q5":
        q["correct_indices"] = [1, 4, 5]
        print(f"Fixed {q['id']}: correct_indices -> {q['correct_indices']}")

# ── Fix 3: architect_test1_q27 ── options are letters A-E referencing invisible image
# Rewrite as self-contained text question about cross-database data copy
for q in qs:
    if q["id"] == "architect_test1_q27":
        q["question"] = (
            "A Snowflake account has the following setup:\n"
            "- Database DB1 with schema S1 containing table TBL1\n"
            "- Database DB2 with schema S2 containing table TBL2\n"
            "- A user's current context is set to DB1.S1\n\n"
            "How can data from DB1.S1.TBL1 be copied into DB2.S2.TBL2? (Choose two.)"
        )
        q["options"] = [
            {"text": "INSERT INTO TBL2 SELECT * FROM TBL1", "explanation": "Fails because TBL2 resolves to DB1.S1.TBL2 which does not exist."},
            {"text": "INSERT INTO S2.TBL2 SELECT * FROM TBL1", "explanation": "Fails because S2.TBL2 resolves to DB1.S2.TBL2 which does not exist."},
            {"text": "INSERT INTO DB2.S2.TBL2 SELECT * FROM TBL1", "explanation": "Correct. Fully qualified target, source resolves from current context."},
            {"text": "INSERT INTO DB2.S2.TBL2 SELECT * FROM S1.TBL1", "explanation": "Works but S1.TBL1 resolves to DB1.S1.TBL1 via current context, which is correct."},
            {"text": "INSERT INTO DB2.S2.TBL2 SELECT * FROM DB1.S1.TBL1", "explanation": "Correct. Both source and target are fully qualified."},
        ]
        q["correct_indices"] = [2, 4]
        q["overall_explanation"] = (
            "When working across databases in Snowflake, the target table must be fully qualified "
            "(DB.SCHEMA.TABLE) because it is outside the current session context. The source table "
            "can use either a fully qualified name or rely on the current context (DB1.S1) to resolve. "
            "Options using unqualified or partially qualified target names fail because they resolve "
            "against the current database/schema context, not the intended target."
        )
        print(f"Rewrote {q['id']} as self-contained text question")

# ── Fix 4: Add difficulty levels ──
# Heuristics:
# - Questions with >= 5 options or multi_select with count >= 3 -> advanced
# - Questions about specific parameters, edge cases, or multi-step scenarios -> advanced
# - Standard conceptual questions -> intermediate
# - Basic definition/recall questions -> beginner

ADVANCED_KEYWORDS = [
    "minimum privilege", "minimum object privilege", "least amount",
    "most cost-effective", "tri-secret", "customer-managed key",
    "privatelink", "private link", "failover group", "replication group",
    "client redirect", "scim", "key pair rotation", "key rotation",
    "snowpipe streaming", "iceberg", "hybrid table", "dynamic table",
    "native app", "application package", "data clean room",
    "query profile", "compilation_time", "spilling",
    "hash_diff", "data vault 2.0", "sha2-512",
    "buffer.flush.time", "buffer.size.bytes",
    "pipe_execution_paused", "pendingfilecount",
    "insert_report", "loadhistoryscan",
    "min_data_retention", "require_storage_integration",
    "allow_client_mfa_caching", "cortex_models_allowlist",
]

BEGINNER_KEYWORDS = [
    "what is", "which of the following is true",
    "which statement is correct", "what type of",
    "what does", "which layer", "what are the three",
    "which edition", "what is the purpose",
    "which role", "which command",
]

tagged = {"beginner": 0, "intermediate": 0, "advanced": 0}

for q in qs:
    text = (q["question"] + " " + q.get("overall_explanation", "")).lower()
    num_options = len(q["options"])
    multi_count = q.get("multi_select_count", 1)

    # Advanced indicators
    is_advanced = False
    if multi_count >= 3 or num_options >= 6:
        is_advanced = True
    if any(kw in text for kw in ADVANCED_KEYWORDS):
        is_advanced = True
    if "choose three" in text or "choose four" in text:
        is_advanced = True

    # Beginner indicators
    is_beginner = False
    if not q.get("multi_select") and num_options <= 4:
        if any(kw in text for kw in BEGINNER_KEYWORDS):
            is_beginner = True

    if is_advanced:
        q["difficulty"] = "advanced"
    elif is_beginner:
        q["difficulty"] = "beginner"
    else:
        q["difficulty"] = "intermediate"

    tagged[q["difficulty"]] += 1

print(f"\nDifficulty distribution: {tagged}")

# ── Write back ──
with open(QF, "w") as f:
    json.dump(qs, f, indent=2, ensure_ascii=False)

print(f"\nWrote {len(qs)} questions to {QF}")

# ── Verify ──
with open(QF) as f:
    verify = json.load(f)

broken = [q for q in verify if q.get("multi_select") and len(q["correct_indices"]) != q.get("multi_select_count", 1)]
no_diff = [q for q in verify if not q.get("difficulty")]
print(f"Broken multi-select remaining: {len(broken)}")
print(f"Questions without difficulty: {len(no_diff)}")
