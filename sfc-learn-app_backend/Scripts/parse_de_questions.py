"""
Parse Data Engineer test markdown files into the standard questions JSON format.
Handles: single-select, multi-select, scenario questions with numbered-step options.
Assigns domains based on keyword matching to the 5 official DE exam domains.

Usage: python Scripts/parse_de_questions.py
Output: certifications/sfc-gh-sd-advanced/data_engineer_domains/data_engineer_questions.json
"""

import json
import os
import re
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DE_DIR = os.path.join(
    BASE,
    "certifications",
    "sfc-gh-sd-advanced",
    "Snow_specialist_dta_engineer",
)
OUTPUT_DIR = os.path.join(
    BASE,
    "certifications",
    "sfc-gh-sd-advanced",
    "data_engineer_domains",
)

# ── Official DE exam domains ──
DOMAINS = {
    "Domain 1.0: Data Movement": {
        "weight": "28%",
        "keywords": [
            "copy into", "stage", "stages", "file format", "snowpipe",
            "auto_ingest", "auto-ingest", "pipe", "pipe_status",
            "ingest", "loading", "load", "data loading", "bulk load",
            "put command", "get command", "file_format", "csv",
            "json", "parquet", "avro", "orc", "infer_schema",
            "schema detection", "metadata$filename", "metadata$file_row_number",
            "data share", "share", "sharing", "listing", "marketplace",
            "reader account", "replication", "replicate",
            "kafka", "connector", "spark connector", "python connector",
            "stream", "streams", "task", "tasks", "dynamic table",
            "snowpipe streaming", "continuous data pipeline",
            "external table", "iceberg", "hybrid table",
            "unload", "data movement", "copy_history", "load_history",
            "validate_pipe_load", "validate", "error_on_column_count",
            "field_optionally_enclosed_by", "storage integration",
            "encryption", "auto_refresh", "notification",
            "openflow", "data pipeline", "cdc",
        ],
    },
    "Domain 2.0: Performance Optimization": {
        "weight": "19%",
        "keywords": [
            "performance", "query profile", "warehouse size", "scale up",
            "scale out", "multi-cluster", "multi_cluster", "clustering",
            "cluster key", "clustering_information", "clustering_depth",
            "micro-partition", "pruning", "partition", "spill",
            "spillage", "spilling", "cache", "caching", "result cache",
            "persisted result", "warehouse queue", "resource monitor",
            "query acceleration", "search optimization",
            "materialized view", "automatic clustering",
            "explain_plan_json", "underperforming", "slow query",
            "virtual warehouse", "warehouse", "suspend", "auto_suspend",
            "credit consumption", "account_usage", "query_history",
            "data_transfer_history", "warehouse_metering",
            "concurrency", "queuing",
        ],
    },
    "Domain 3.0: Storage and Data Protection": {
        "weight": "14%",
        "keywords": [
            "time travel", "fail-safe", "failsafe", "data_retention",
            "retention", "clone", "cloning", "zero-copy",
            "undrop", "replication", "failover", "failback",
            "cross-region", "cross-cloud", "micro-partition",
            "clustering depth", "system$clustering",
            "table_storage_metrics", "data protection",
            "offset", "before", "at timestamp", "at statement",
        ],
    },
    "Domain 4.0: Data Governance": {
        "weight": "14%",
        "keywords": [
            "masking", "masking policy", "dynamic data masking",
            "row access policy", "rbac", "role", "grant", "privilege",
            "securityadmin", "sysadmin", "accountadmin", "useradmin",
            "managed access", "future grant", "object tagging",
            "classification", "data lineage", "data quality",
            "data metric", "projection policy", "aggregation policy",
            "data clean room", "column-level security",
            "tokenization", "governance", "security",
            "network policy", "ip whitelist",
        ],
    },
    "Domain 5.0: Data Transformation": {
        "weight": "25%",
        "keywords": [
            "udf", "user-defined function", "user defined function",
            "udtf", "udaf", "stored procedure", "procedure",
            "javascript", "snowpark", "python", "java", "scala",
            "external function", "api integration",
            "transaction", "begin transaction", "commit", "rollback",
            "semi-structured", "variant", "parse_json", "try_parse_json",
            "flatten", "lateral", "object_construct", "array_agg",
            "unstructured", "directory table", "rest api",
            "snowflake scripting", "caller's rights", "owner's rights",
            "execute as caller", "execute as owner",
            "session variable", "dataframe", "snowpark",
            "transformation", "transform",
            "git integration", "notebook",
        ],
    },
}


def classify_domain(question_text, options_text, explanation_text):
    """Assign a domain based on keyword frequency in the full question context."""
    full_text = f"{question_text} {options_text} {explanation_text}".lower()
    scores = {}
    for domain, info in DOMAINS.items():
        score = 0
        for kw in info["keywords"]:
            occurrences = full_text.count(kw.lower())
            if occurrences > 0:
                score += occurrences * len(kw)  # weight by keyword length
        scores[domain] = score
    best = max(scores, key=scores.get)
    if scores[best] == 0:
        return "Untagged"
    return best


def split_into_questions(text, source_name):
    """Split markdown text into raw question blocks."""
    # Normalize line endings
    text = text.replace("\r\n", "\n")

    # Split by "Question N" pattern (handles missing Q in test 2)
    parts = re.split(r"\n(?:Q|q)?uestion\s+(\d+)\s*\n", text)

    blocks = []

    # Handle text before first "Question N" (test 3 has Q1 without header)
    preamble = parts[0].strip()
    if preamble and "Overall explanation" in preamble:
        # This is a question without a header (test 3, Q1)
        blocks.append(("1", preamble))

    # Process matched pairs
    i = 1
    while i < len(parts) - 1:
        qnum = parts[i]
        body = parts[i + 1]
        blocks.append((qnum, body.strip()))
        i += 2

    return blocks


def parse_question_block(raw_body, qnum, source_name):
    """Parse a single question block into structured data.

    Uses a marker-based segment approach:
    1. Strip status lines, split at 'Overall explanation'
    2. Find question/option boundary using first marker position
    3. Parse options by splitting on markers and blank lines
    4. Multi-line non-numbered segments get split into individual options
    """
    lines = raw_body.split("\n")

    # Remove status lines (Skipped, Incorrect, Correct)
    STATUS_LINES = {"Skipped", "Incorrect", "Correct"}
    cleaned = [l for l in lines if l.strip() not in STATUS_LINES]
    text = "\n".join(cleaned)

    # Split at "Overall explanation"
    expl_match = re.split(r"\nOverall explanation\s*\n?", text, maxsplit=1)
    qo_part = expl_match[0].strip()
    explanation = expl_match[1].strip() if len(expl_match) > 1 else ""

    # Clean explanation: remove trailing doc references
    explanation = re.sub(
        r"\s*For more detailed information,?\s*refer to the official Snowflake documentation\.?\s*$",
        "",
        explanation,
    ).strip()

    MARKER_MAP = {
        "Correct answer": "correct_single",
        "Correct selection": "correct_multi",
        "Your answer is incorrect": "wrong",
    }

    qo_lines = qo_part.split("\n")

    # ---- Find question / option boundary ----
    # Find the first marker line
    first_marker_idx = None
    for i, line in enumerate(qo_lines):
        if line.strip() in MARKER_MAP:
            first_marker_idx = i
            break

    if first_marker_idx is None:
        return None

    # Strategy: try TWO boundaries and pick the one that produces better options.
    # Boundary A: first blank line after the last "?" line (works when unmarked
    #   options are separated by blank lines -- Q7/Q11 pattern)
    # Boundary B: last blank line before the first marker (works when options
    #   are on consecutive lines or code sits between question and marker -- Q1/Q3)

    # Boundary A: find last "?" line before first marker
    q_mark_end = -1
    for i in range(first_marker_idx - 1, -1, -1):
        if qo_lines[i].strip().endswith("?"):
            # Include up to the next blank line after the "?" line
            q_mark_end = i + 1
            for j in range(i + 1, first_marker_idx):
                if qo_lines[j].strip() == "":
                    q_mark_end = j
                    break
            break

    # Boundary B: last blank line before first marker
    q_blank_end = -1
    for i in range(first_marker_idx - 1, -1, -1):
        if qo_lines[i].strip() == "":
            q_blank_end = i
            break

    # Fallback: first blank line
    q_fallback = first_marker_idx
    for i, line in enumerate(qo_lines):
        if line.strip() == "" and i > 0:
            q_fallback = i
            break

    def _parse_from_boundary(q_end):
        """Parse options starting from a given question boundary."""
        remaining = qo_lines[q_end:]
        segments = []
        cur_marker = None
        cur_lines = []

        for line in remaining:
            s = line.strip()
            if s == "":
                if cur_lines:
                    segments.append((cur_marker, cur_lines[:]))
                    cur_marker = None
                    cur_lines = []
                continue
            if s in MARKER_MAP:
                if cur_lines:
                    segments.append((cur_marker, cur_lines[:]))
                    cur_lines = []
                cur_marker = MARKER_MAP[s]
                continue
            cur_lines.append(s)

        if cur_lines:
            segments.append((cur_marker, cur_lines[:]))

        opts = []
        corr = []
        multi = False

        for marker, content_lines in segments:
            if not content_lines:
                continue
            is_numbered = (
                len(content_lines) > 1
                and all(re.match(r"^\d+[\.\)]\s", l) for l in content_lines)
            )
            if len(content_lines) > 1 and not is_numbered:
                for ci, line in enumerate(content_lines):
                    if marker in ("correct_single", "correct_multi") and ci == 0:
                        corr.append(len(opts))
                        if marker == "correct_multi":
                            multi = True
                    opts.append(line)
            else:
                opt_text = "\n".join(content_lines)
                if marker in ("correct_single", "correct_multi"):
                    corr.append(len(opts))
                    if marker == "correct_multi":
                        multi = True
                opts.append(opt_text)

        q_text = "\n".join(qo_lines[:q_end]).strip()
        q_text = re.sub(r"\n{3,}", "\n\n", q_text)
        return q_text, opts, corr, multi

    # Try boundary A (question-mark based) first
    best_q = ""
    best_opts = []
    best_corr = []
    best_multi = False

    candidates = []
    if q_mark_end > 0:
        candidates.append(q_mark_end)
    if q_blank_end > 0 and q_blank_end != q_mark_end:
        candidates.append(q_blank_end)
    if not candidates:
        candidates.append(q_fallback)

    for boundary in candidates:
        q_text, opts, corr, multi = _parse_from_boundary(boundary)
        # Prefer the result with 3-6 options and at least 1 correct
        if len(opts) >= 2 and len(corr) >= 1:
            if 3 <= len(opts) <= 8:
                best_q, best_opts, best_corr, best_multi = q_text, opts, corr, multi
                break
            elif len(opts) > len(best_opts):
                best_q, best_opts, best_corr, best_multi = q_text, opts, corr, multi

    # If nothing good found, use best available
    if len(best_opts) < 2:
        for boundary in candidates:
            q_text, opts, corr, multi = _parse_from_boundary(boundary)
            if len(opts) > len(best_opts):
                best_q, best_opts, best_corr, best_multi = q_text, opts, corr, multi

    question_text = best_q
    options = best_opts
    correct_indices = best_corr
    is_multi = best_multi

    # ---- Clean up options ----
    cleaned_options = []
    for opt in options:
        steps = re.findall(r"^\d+\.\s+.+$", opt, re.MULTILINE)
        if len(steps) >= 2 and opt.strip().startswith(("1.", "1 ")):
            cleaned_options.append(opt)
        else:
            cleaned_options.append(re.sub(r"\s+", " ", opt).strip())

    if not cleaned_options or not question_text:
        return None

    # ---- Detect multi-select from question text ----
    multi_match = re.search(
        r"\((?:Select|Choose)\s+(TWO|THREE|FOUR|two|three|four|2|3|4)\)",
        question_text,
        re.IGNORECASE,
    )
    if multi_match:
        is_multi = True
        count_map = {
            "two": 2, "three": 3, "four": 4,
            "2": 2, "3": 3, "4": 4,
        }
        multi_count = count_map.get(multi_match.group(1).lower(), 2)
    else:
        multi_count = len(correct_indices) if is_multi else 1

    # Classify domain
    opts_text = " ".join(cleaned_options)
    domain = classify_domain(question_text, opts_text, explanation)

    return {
        "id": f"de_{source_name}_q{qnum}",
        "source": f"de_{source_name}",
        "question_num": int(qnum),
        "question": question_text,
        "options": [{"text": o, "explanation": ""} for o in cleaned_options],
        "correct_indices": correct_indices,
        "multi_select": is_multi or len(correct_indices) > 1,
        "multi_select_count": max(multi_count, len(correct_indices)),
        "overall_explanation": explanation,
        "domain_raw": "",
        "domain": domain,
    }


def parse_file(filepath, source_name):
    """Parse a single test markdown file."""
    with open(filepath, "r", encoding="utf-8") as f:
        text = f.read()

    blocks = split_into_questions(text, source_name)
    questions = []
    for qnum, body in blocks:
        q = parse_question_block(body, qnum, source_name)
        if q:
            q["id"] = f"de_{source_name}_q{qnum}"
            q["source"] = f"de_{source_name}"
            questions.append(q)
        else:
            print(f"  WARN: Could not parse {source_name} Q{qnum}")

    return questions


def main():
    files = [
        ("course_01_data_engineer_test example_1.md", "test1"),
        ("course_01_data_engineer_test example_2.md", "test2"),
        ("course_01_data_enginer_test example_3.md", "test3"),
    ]

    all_questions = []
    for fname, source in files:
        fpath = os.path.join(DE_DIR, fname)
        if not os.path.exists(fpath):
            print(f"SKIP: {fname} not found")
            continue
        print(f"Parsing {fname}...")
        qs = parse_file(fpath, source)
        print(f"  Parsed {len(qs)} questions")
        all_questions.extend(qs)

    print(f"\nTotal questions: {len(all_questions)}")

    # Domain distribution
    domain_counts = {}
    for q in all_questions:
        d = q["domain"]
        domain_counts[d] = domain_counts.get(d, 0) + 1
    print("\nDomain distribution:")
    for d, c in sorted(domain_counts.items()):
        print(f"  {d}: {c}")

    # Multi-select stats
    multi = sum(1 for q in all_questions if q["multi_select"])
    print(f"\nMulti-select: {multi}")
    print(f"Single-select: {len(all_questions) - multi}")

    # Validation: check for questions with no correct indices
    bad = [q for q in all_questions if not q["correct_indices"]]
    if bad:
        print(f"\nWARNING: {len(bad)} questions with no correct answer:")
        for q in bad:
            print(f"  {q['id']}: {q['question'][:80]}...")

    # Validation: check for questions with no options
    no_opts = [q for q in all_questions if len(q["options"]) < 2]
    if no_opts:
        print(f"\nWARNING: {len(no_opts)} questions with < 2 options:")
        for q in no_opts:
            print(f"  {q['id']}: {len(q['options'])} opts - {q['question'][:60]}...")

    # Write output
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    out_path = os.path.join(OUTPUT_DIR, "data_engineer_questions.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(all_questions, f, indent=2, ensure_ascii=False)
    print(f"\nWritten to: {out_path}")


if __name__ == "__main__":
    main()
