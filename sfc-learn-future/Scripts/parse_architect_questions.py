"""
Parse SnowPro Architect (ARA-C01) Udemy questions into structured JSON.
Same format as Core Course 1: blank-line separated, "Correct answer/selection" markers.
Includes auto-tagging to 6 study domains by keyword matching.
"""
import json
import re
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_DIR = os.path.join(os.path.dirname(BASE), "Snowprocore_architect", "course_arquitec t_udemy")

CONTROL_LINES = {
    "Correct answer", "Correct selection", "Your answer is correct",
    "Your answer is incorrect", "Overall explanation", "Domain",
    "Explanation", "Skipped", "Incorrect", "Correct",
}


def is_control(line):
    s = line.strip()
    if s in CONTROL_LINES:
        return True
    if s.startswith("Your answer is") or s.startswith("Your selection is"):
        return True
    if re.match(r"^[Qq]uestion\s+\d+$", s):
        return True
    return False


def detect_multi_select(question_text):
    t = question_text.lower()
    if "select all that apply" in t or "choose all that apply" in t:
        return -1
    m = re.search(r"\((?:select|choose)\s+(\d+)\)", t, re.IGNORECASE)
    if m:
        return int(m.group(1))
    if "choose two" in t or "select two" in t:
        return 2
    if "choose three" in t or "select three" in t:
        return 3
    return 0


def parse_architect(filepath, source_label):
    """Parse Architect test files (same format as Core Course 1)."""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Fix common typo: "uestion" → "Question"
    content = re.sub(r"^uestion\s+(\d+)", r"Question \1", content, flags=re.MULTILINE)

    blocks = re.split(r"(?=^Question\s+\d+\s*$)", content, flags=re.MULTILINE)

    questions = []
    for block in blocks:
        block = block.strip()
        if not block:
            continue

        blines = block.split("\n")
        m = re.match(r"^Question\s+(\d+)$", blines[0])
        if not m:
            continue

        q_num = int(m.group(1))

        # Find markers
        correct_markers = []
        overall_idx = None

        for j, line in enumerate(blines):
            s = line.strip()
            if s in ("Correct answer", "Correct selection"):
                correct_markers.append(j)
            if s == "Overall explanation" and overall_idx is None:
                overall_idx = j

        if not correct_markers or overall_idx is None:
            continue

        # Status line
        status_idx = 1
        if status_idx < len(blines) and blines[status_idx].strip() in ("Skipped", "Incorrect", "Correct"):
            content_start = status_idx + 1
        else:
            content_start = status_idx

        # Find correct option line indices
        correct_next_indices = set()
        for cm in correct_markers:
            j = cm + 1
            while j < overall_idx:
                s = blines[j].strip()
                if s == "" or is_control(blines[j]):
                    j += 1
                    continue
                correct_next_indices.add(j)
                break

        # Walk through content
        q_text_parts = []
        all_content = []
        found_question_end = False

        for j in range(content_start, overall_idx):
            s = blines[j].strip()
            if s == "" or is_control(blines[j]):
                continue

            is_correct = j in correct_next_indices

            if not found_question_end:
                if is_correct:
                    found_question_end = True
                    all_content.append((j, s, True))
                elif q_text_parts and (
                    q_text_parts[-1].endswith("?") or
                    q_text_parts[-1].endswith(":") or
                    q_text_parts[-1].endswith(")")
                ):
                    found_question_end = True
                    all_content.append((j, s, False))
                else:
                    q_text_parts.append(s)
            else:
                all_content.append((j, s, is_correct))

        q_text = " ".join(q_text_parts).strip()

        # Build options
        options = []
        correct_indices = []
        seen = set()
        for _, text, is_corr in all_content:
            if text in seen:
                continue
            seen.add(text)
            if is_corr:
                correct_indices.append(len(options))
            options.append({"text": text, "explanation": ""})

        # Overall explanation
        overall_lines = []
        j = overall_idx + 1
        while j < len(blines):
            s = blines[j].strip()
            if re.match(r"^[Qq]uestion\s+\d+$", s):
                break
            if s:
                overall_lines.append(s)
            j += 1
        overall_exp = " ".join(overall_lines).strip()

        multi_count = detect_multi_select(q_text)
        is_multi = multi_count != 0 or len(correct_indices) > 1

        if q_text and options:
            questions.append({
                "id": f"{source_label}_q{q_num}",
                "source": source_label,
                "question_num": q_num,
                "question": q_text,
                "options": options,
                "correct_indices": correct_indices,
                "multi_select": is_multi,
                "multi_select_count": multi_count if multi_count > 0 else len(correct_indices),
                "overall_explanation": overall_exp,
                "domain_raw": "",
                "domain": "Untagged",
            })

    return questions


# ── Auto-tagging by keyword for Architect domains ──
ARCHITECT_DOMAIN_KEYWORDS = {
    "Domain 1: Account & Security": [
        "account strategy", "account parameter", "session parameter", "object parameter",
        "parameter hierarchy", "multi-account", "account isolation", "segmentation",
        "RBAC", "DAC", "privilege", "GRANT", "REVOKE", "role hierarchy",
        "system role", "functional role", "access role", "database role", "secondary role",
        "network policy", "network rule", "private connectivity", "PrivateLink",
        "authentication", "SSO", "SAML", "OAuth", "MFA", "key-pair", "federated",
        "masking policy", "row access policy", "aggregation policy", "projection policy",
        "object tagging", "data lineage", "data governance", "compliance",
        "HIPAA", "PCI", "PHI", "PII", "encryption", "Tri-Secret",
        "secure view", "storage integration", "external access", "access control",
        "security integration", "authentication policy",
    ],
    "Domain 2: Data Architecture": [
        "data model", "data vault", "star schema", "snowflake schema",
        "dimension", "fact table", "SCD", "slowly changing",
        "object hierarchy", "database", "schema", "organization",
        "data recovery", "Time Travel", "Fail-safe", "UNDROP",
        "clone", "zero-copy", "replication", "failover", "failback",
        "disaster recovery", "data corruption",
        "table type", "permanent", "transient", "temporary",
        "view", "materialized view", "secure view",
        "dynamic table", "target lag",
    ],
    "Domain 3: Data Engineering": [
        "data loading", "data unloading", "COPY INTO", "bulk load",
        "Snowpipe", "Snowpipe Streaming", "auto-ingest", "pipe",
        "stage", "internal stage", "external stage", "PUT", "GET",
        "file format", "CSV", "JSON", "Parquet", "Avro", "ORC",
        "stream", "task", "CDC", "change data capture",
        "external table", "Iceberg", "directory table",
        "schema detection", "schema evolution",
        "incremental", "full refresh", "reload",
        "Kafka", "connector", "Spark", "Python connector",
        "JDBC", "ODBC", "SQL API",
        "ELT", "ETL", "pipeline", "data transformation",
        "FLATTEN", "UDF", "UDTF", "external function",
        "stored procedure", "secure function",
    ],
    "Domain 4: Performance": [
        "warehouse", "virtual warehouse", "warehouse size",
        "multi-cluster", "scaling policy", "economy", "standard scaling",
        "auto-suspend", "auto-resume", "query acceleration",
        "Snowpark-optimized", "Gen2",
        "query profile", "bottleneck", "spilling", "queuing",
        "cache", "result cache", "metadata cache", "local disk cache",
        "pruning", "clustering", "clustering key", "auto-clustering",
        "micro-partition", "partition",
        "resource monitor", "ACCOUNT_USAGE", "INFORMATION_SCHEMA",
        "query history", "warehouse metering",
        "performance", "optimization", "slow query",
        "concurrency", "workload",
    ],
    "Domain 5: Sharing & Collaboration": [
        "data sharing", "share", "secure data sharing",
        "provider", "consumer", "reader account",
        "Marketplace", "Data Exchange", "listing",
        "cross-region", "cross-cloud", "Auto-Fulfillment",
        "Data Clean Room", "clean room",
        "Native App", "application package",
        "Snowflake Native App Framework",
    ],
    "Domain 6: DevOps & Ecosystem": [
        "CI/CD", "DevOps", "DataOps", "deployment",
        "Git", "git integration", "version control",
        "Snowflake CLI", "SnowSQL",
        "Streamlit", "Snowpark Container Services", "SPCS",
        "Cortex", "ML function", "LLM",
        "development lifecycle", "sandbox", "production",
        "migration", "rollback",
        "storage directory", "zone", "data warehouse layer",
        "bronze", "silver", "gold", "medallion",
    ],
}


def auto_tag_architect(question_text, options_text=""):
    combined = (question_text + " " + options_text).lower()
    scores = {}
    for domain, keywords in ARCHITECT_DOMAIN_KEYWORDS.items():
        score = 0
        for kw in keywords:
            if kw.lower() in combined:
                score += len(kw.split())
        if score > 0:
            scores[domain] = score

    if not scores:
        return "Untagged"

    best = max(scores, key=scores.get)
    if scores[best] >= 2:
        return best
    return "Untagged"


def main():
    all_questions = []

    print("=== SnowPro Architect (ARA-C01) ===")
    for i in range(1, 6):
        fp = os.path.join(SOURCE_DIR, f"course_01_architect_test example_{i}.md")
        label = f"architect_test{i}"
        if not os.path.exists(fp):
            print(f"  {label}: FILE NOT FOUND at {fp}")
            continue
        qs = parse_architect(fp, label)
        print(f"  {label}: {len(qs)} questions")
        all_questions.extend(qs)

    # Auto-tag
    print("\n=== Auto-tagging ===")
    untagged_before = sum(1 for q in all_questions if q["domain"] == "Untagged")
    for q in all_questions:
        if q["domain"] == "Untagged":
            opts_text = " ".join(o["text"] for o in q["options"])
            q["domain"] = auto_tag_architect(q["question"], opts_text)
    untagged_after = sum(1 for q in all_questions if q["domain"] == "Untagged")
    print(f"  Before: {untagged_before} untagged")
    print(f"  After:  {untagged_after} untagged")
    print(f"  Tagged: {untagged_before - untagged_after}")

    # Stats
    print(f"\nTotal: {len(all_questions)}")
    from collections import Counter
    domain_counts = Counter(q["domain"] for q in all_questions)
    print("\nDomain distribution:")
    for d, c in sorted(domain_counts.items()):
        print(f"  {d}: {c}")

    multi = sum(1 for q in all_questions if q.get("multi_select"))
    few_opts = sum(1 for q in all_questions if len(q["options"]) < 2)
    no_correct = sum(1 for q in all_questions if not q["correct_indices"])
    print(f"\nMulti-select: {multi}")
    print(f"<2 options: {few_opts}")
    print(f"0 correct: {no_correct}")

    # Save
    out_path = os.path.join(BASE, "architect_questions.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(all_questions, f, indent=2, ensure_ascii=False)
    print(f"\nSaved to: {out_path}")


if __name__ == "__main__":
    main()
