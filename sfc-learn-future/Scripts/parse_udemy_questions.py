"""
Parse all 12 Udemy markdown files into structured JSON for the Streamlit quiz app.
Course 1 (6 files): no domain tags, blank lines between items
Course 2 (6 files): per-option explanations, domain tags, doc URLs
Output: questions.json with all questions

v3 — block-based parsing, handles Format A (with explanations) and Format B
     (no explanations on wrong options), multi-select detection, auto-tagging.
"""
import json
import re
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Domain mapping from Course 2 raw tags to exam domains
DOMAIN_MAP = {
    "Snowflake Architecture": "Domain 1: Architecture",
    "Storage and Protection": "Domain 1: Architecture",
    "Performance and Warehouses": "Domain 4: Performance & Querying",
    "Security": "Domain 2: Account & Governance",
    "Account and Data Sharing": "Domain 5: Collaboration",
    "Data Movement": "Domain 3: Data Loading",
}

MANUAL_DOMAIN_FIXES = {
    "course2_test4_q44": "Domain 1: Architecture",
    "course2_test4_q51": "Domain 2: Account & Governance",
    "course2_test4_q61": "Domain 4: Performance & Querying",
    "course2_test4_q89": "Domain 5: Collaboration",
    "course2_test4_q98": "Domain 1: Architecture",
}

# Control lines that are NOT option text
CONTROL_LINES = {
    "Correct answer", "Correct selection", "Your answer is correct",
    "Your answer is incorrect", "Overall explanation", "Domain",
    "Explanation", "Skipped", "Incorrect", "Correct",
}


def is_control(line):
    """Check if a line is a structural marker, not content."""
    s = line.strip()
    if s in CONTROL_LINES:
        return True
    if s.startswith("Your answer is"):
        return True
    if re.match(r"^Question\s+\d+$", s):
        return True
    return False


def detect_multi_select(question_text):
    """Detect if a question requires multiple answers. Returns expected count or 0."""
    t = question_text.lower()
    if "select all that apply" in t or "choose all that apply" in t:
        return -1  # unknown count, but multi
    m = re.search(r"\(select\s+(\d+)\)", t, re.IGNORECASE)
    if m:
        return int(m.group(1))
    m = re.search(r"\(choose\s+(\d+)\)", t, re.IGNORECASE)
    if m:
        return int(m.group(1))
    if "select two" in t or "choose two" in t:
        return 2
    if "select three" in t or "choose three" in t:
        return 3
    return 0


def parse_course2(filepath, source_label):
    """
    Parse Course 2 files using block-based approach.
    Handles both Format A (with per-option Explanation) and Format B (no explanations).
    """
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Split into question blocks
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

        # Find all key marker positions
        correct_markers = []  # indices of "Correct answer" / "Correct selection"
        explanation_markers = []  # indices of "Explanation"
        overall_idx = None
        domain_idx = None

        for j, line in enumerate(blines):
            s = line.strip()
            if s in ("Correct answer", "Correct selection", "Your answer is correct"):
                correct_markers.append(j)
            if s == "Explanation":
                explanation_markers.append(j)
            if s == "Overall explanation" and overall_idx is None:
                overall_idx = j
            if s == "Domain" and domain_idx is None:
                domain_idx = j

        if overall_idx is None:
            # No overall explanation — skip malformed block
            continue

        # Determine if this is Format A (has Explanation lines) or Format B (no Explanation lines)
        # Format A: explanation_markers exist between status line and overall_idx
        has_explanations = any(e < overall_idx for e in explanation_markers)

        # Skip status line (line 1)
        status_idx = 1
        if status_idx < len(blines) and blines[status_idx].strip() in ("Skipped", "Incorrect", "Correct"):
            content_start = status_idx + 1
        else:
            content_start = status_idx

        # ── FORMAT A: options have Explanation lines ──
        if has_explanations:
            # Question text: from content_start until first option
            # First option is either a "Correct answer/selection" line or
            # a content line followed by "Explanation"
            q_text_lines = []
            i = content_start
            while i < overall_idx:
                s = blines[i].strip()
                if s == "":
                    i += 1
                    continue
                if s in ("Correct answer", "Correct selection", "Your answer is correct"):
                    break
                # Check if this line is followed by "Explanation" (= it's an option)
                if (i + 1 < len(blines) and blines[i + 1].strip() == "Explanation"
                        and s != "" and not s.startswith("Question")):
                    break
                q_text_lines.append(s)
                i += 1

            q_text = " ".join(q_text_lines).strip()

            # Parse options
            options = []
            correct_indices = []
            while i < overall_idx:
                s = blines[i].strip()
                if s == "":
                    i += 1
                    continue
                if s == "Overall explanation":
                    break

                is_correct = False
                if s in ("Correct answer", "Correct selection", "Your answer is correct"):
                    is_correct = True
                    i += 1
                    if i >= overall_idx:
                        break
                    s = blines[i].strip()

                # Skip control lines
                if is_control(blines[i]):
                    i += 1
                    continue

                # This should be option text
                opt_text = s
                i += 1

                # Read explanation if present
                opt_explanation = ""
                if i < len(blines) and blines[i].strip() == "Explanation":
                    i += 1
                    exp_lines = []
                    while i < overall_idx:
                        cs = blines[i].strip()
                        if cs in ("Correct answer", "Correct selection", "Your answer is correct"):
                            break
                        if cs == "Overall explanation":
                            break
                        # Next option: non-empty line followed by "Explanation"
                        if (cs != "" and i + 1 < len(blines)
                                and blines[i + 1].strip() == "Explanation"):
                            break
                        if cs == "":
                            i += 1
                            continue
                        exp_lines.append(cs)
                        i += 1
                    opt_explanation = " ".join(exp_lines).strip()

                if opt_text:
                    options.append({"text": opt_text, "explanation": opt_explanation})
                    if is_correct:
                        correct_indices.append(len(options) - 1)

        # ── FORMAT B: no Explanation lines on options ──
        else:
            # Same logic as Course 1: collect ALL content lines between
            # content_start and overall_idx, mark correct ones
            correct_next_indices = set()
            for cm in correct_markers:
                if cm > content_start and cm < overall_idx:
                    j = cm + 1
                    while j < overall_idx:
                        s = blines[j].strip()
                        if s == "" or is_control(blines[j]):
                            j += 1
                            continue
                        correct_next_indices.add(j)
                        break

            q_text_parts = []
            all_content = []
            found_q_end = False

            for j in range(content_start, overall_idx):
                s = blines[j].strip()
                if s == "" or is_control(blines[j]):
                    continue

                is_correct = j in correct_next_indices

                if not found_q_end:
                    if is_correct:
                        found_q_end = True
                        all_content.append((j, s, True))
                    elif q_text_parts and (
                        q_text_parts[-1].endswith("?") or
                        q_text_parts[-1].endswith(":") or
                        q_text_parts[-1].endswith(")")
                    ):
                        found_q_end = True
                        all_content.append((j, s, False))
                    else:
                        q_text_parts.append(s)
                else:
                    all_content.append((j, s, is_correct))

            q_text = " ".join(q_text_parts).strip()

            options = []
            correct_indices = []
            seen_texts = set()
            for _, text, is_corr in all_content:
                if text in seen_texts:
                    continue
                seen_texts.add(text)
                if is_corr:
                    correct_indices.append(len(options))
                options.append({"text": text, "explanation": ""})

        # ── Read overall explanation ──
        overall_lines = []
        j = overall_idx + 1
        end_idx = domain_idx if domain_idx else len(blines)
        while j < end_idx:
            s = blines[j].strip()
            if re.match(r"^Question\s+\d+$", s):
                break
            if s:
                overall_lines.append(s)
            j += 1
        overall_exp = " ".join(overall_lines).strip()

        # ── Read domain ──
        domain_raw = ""
        if domain_idx is not None and domain_idx + 1 < len(blines):
            domain_raw = blines[domain_idx + 1].strip()

        q_id = f"{source_label}_q{q_num}"
        exam_domain = MANUAL_DOMAIN_FIXES.get(q_id, DOMAIN_MAP.get(domain_raw, "Unknown"))

        # Multi-select detection
        multi_count = detect_multi_select(q_text)
        is_multi = multi_count != 0 or len(correct_indices) > 1

        if q_text and options:
            questions.append({
                "id": q_id,
                "source": source_label,
                "question_num": q_num,
                "question": q_text,
                "options": options,
                "correct_indices": correct_indices,
                "multi_select": is_multi,
                "multi_select_count": multi_count if multi_count > 0 else len(correct_indices),
                "overall_explanation": overall_exp,
                "domain_raw": domain_raw,
                "domain": exam_domain,
            })

    return questions


def parse_course1(filepath, source_label):
    """
    Parse Course 1 files (block-based).
    Handles BOTH variants:
      Variant 1: question → wrong opts → Correct answer → correct opt → Overall
      Variant 2: question → Correct answer → correct opt → wrong opts → Overall
    """
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

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

        # Find ALL key markers
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

        # Collect ALL content lines between content_start and overall_idx
        # marking which are correct (line after a correct_marker)
        correct_next_indices = set()
        for cm in correct_markers:
            # The correct option text is the next non-empty non-control line after the marker
            j = cm + 1
            while j < overall_idx:
                s = blines[j].strip()
                if s == "" or is_control(blines[j]):
                    j += 1
                    continue
                correct_next_indices.add(j)
                break

        # Now walk through and collect question + options
        # Strategy: first non-empty segment (possibly multi-line ending with ?)
        # is the question, everything else is an option
        q_text_parts = []
        all_content = []  # (line_idx, text, is_correct)
        found_question_end = False

        for j in range(content_start, overall_idx):
            s = blines[j].strip()
            if s == "" or is_control(blines[j]):
                continue

            is_correct = j in correct_next_indices

            if not found_question_end:
                # Question text continues until we see a line ending with ? : )
                # OR until we hit a correct marker or option
                if is_correct:
                    # This is an option, not question text
                    found_question_end = True
                    all_content.append((j, s, True))
                elif q_text_parts and (
                    q_text_parts[-1].endswith("?") or
                    q_text_parts[-1].endswith(":") or
                    q_text_parts[-1].endswith(")")
                ):
                    # Previous line ended the question, this is an option
                    found_question_end = True
                    all_content.append((j, s, False))
                else:
                    q_text_parts.append(s)
            else:
                all_content.append((j, s, is_correct))

        # If we never found the end, take first part as question
        if not found_question_end and q_text_parts:
            # The entire content is just the question? Check if there are options after correct marker
            pass

        q_text = " ".join(q_text_parts).strip()

        # Build options list
        options = []
        correct_indices = []
        seen_texts = set()
        for _, text, is_corr in all_content:
            if text in seen_texts:
                continue
            seen_texts.add(text)
            if is_corr:
                correct_indices.append(len(options))
            options.append({"text": text, "explanation": ""})

        # Overall explanation
        overall_lines = []
        j = overall_idx + 1
        while j < len(blines):
            s = blines[j].strip()
            if re.match(r"^Question\s+\d+$", s):
                break
            if s:
                overall_lines.append(s)
            j += 1
        overall_exp = " ".join(overall_lines).strip()

        # Multi-select
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


# ── Auto-tagging by keyword ──

DOMAIN_KEYWORDS = {
    "Domain 1: Architecture": [
        "micro-partition", "micropartition", "columnar", "three layers", "3 layers",
        "cloud services layer", "compute layer", "storage layer", "architecture",
        "snowflake edition", "standard edition", "enterprise edition",
        "business critical", "virtual private", "VPS", "snowpark",
        "hybrid table", "dynamic table", "iceberg table", "external table",
        "regular table", "permanent table", "transient table", "temporary table",
        "table type", "materialized view", "secure view", "view type",
        "object hierarchy", "database object", "schema object",
        "variant", "semi-structured", "json", "parquet", "avro", "orc", "xml",
        "data type", "metadata", "cloud provider", "AWS", "Azure", "GCP",
        "account identifier", "account locator", "organization name",
        "snowflake connector", "snowflake driver", "snowsight", "classic console",
        "snowflake releases", "release schedule",
    ],
    "Domain 2: Account & Governance": [
        "RBAC", "role-based", "access control", "ACCOUNTADMIN", "SECURITYADMIN",
        "USERADMIN", "SYSADMIN", "PUBLIC role", "system role", "custom role",
        "role hierarchy", "privilege", "GRANT", "REVOKE", "OWNERSHIP",
        "masking policy", "dynamic data masking", "row access policy",
        "column-level security", "tag", "object tagging",
        "network policy", "IP whitelist", "ALLOWED_IP_LIST", "BLOCKED_IP_LIST",
        "MFA", "multi-factor", "key pair", "SSO", "SAML", "SCIM", "federated",
        "encryption", "AES-256", "at rest", "in transit", "TLS",
        "tri-secret", "customer-managed key", "periodic rekeying",
        "resource monitor", "credit quota", "warehouse monitor",
        "ACCOUNT_USAGE", "INFORMATION_SCHEMA", "ACCESS_HISTORY",
        "LOGIN_HISTORY", "QUERY_HISTORY", "STORAGE_USAGE",
        "account parameter", "session parameter", "parameter hierarchy",
        "governance", "audit", "compliance", "HIPAA", "PCI DSS", "SOC",
    ],
    "Domain 3: Data Loading": [
        "COPY INTO", "COPY command", "data loading", "data unloading",
        "bulk load", "batch load", "continuous load",
        "stage", "internal stage", "external stage", "user stage", "table stage",
        "named stage", "@~", "@%",
        "PUT command", "GET command", "LIST command",
        "file format", "CSV", "delimiter", "SKIP_HEADER", "FIELD_OPTIONALLY_ENCLOSED",
        "Snowpipe", "auto-ingest", "pipe", "CREATE PIPE", "event notification",
        "SQS", "SNS", "Event Grid", "GCS notification",
        "VALIDATION_MODE", "ON_ERROR", "CONTINUE", "ABORT_STATEMENT",
        "MATCH_BY_COLUMN_NAME", "PURGE", "FORCE",
        "task", "CREATE TASK", "task schedule", "CRON", "task tree",
        "stream", "change tracking", "change data capture", "CDC",
        "append-only stream", "insert-only stream", "standard stream",
        "METADATA$", "SYSTEM$STREAM_HAS_DATA",
        "directory table", "Snowpipe Streaming",
    ],
    "Domain 4: Performance & Querying": [
        "warehouse", "virtual warehouse", "warehouse size", "X-Small", "4X-Large",
        "multi-cluster", "scaling policy", "economy", "standard scaling",
        "auto-suspend", "auto-resume", "MIN_CLUSTER_COUNT", "MAX_CLUSTER_COUNT",
        "query profile", "query history", "query performance",
        "result cache", "metadata cache", "local disk cache", "remote disk",
        "caching", "cache", "24 hours", "persisted query result",
        "pruning", "partition pruning", "clustering", "clustering key",
        "automatic clustering", "SYSTEM$CLUSTERING_INFORMATION",
        "search optimization", "search optimization service",
        "materialized view", "query acceleration", "QAS",
        "spilling", "spill to local", "spill to remote",
        "queuing", "queue", "concurrency",
        "EXPLAIN", "query plan", "execution plan", "operator",
        "window function", "ROW_NUMBER", "RANK", "DENSE_RANK", "LAG", "LEAD",
        "QUALIFY", "OVER", "PARTITION BY", "ORDER BY",
        "CTE", "WITH clause", "common table expression",
        "PIVOT", "UNPIVOT", "FLATTEN", "LATERAL",
        "stored procedure", "UDF", "user-defined function", "UDTF",
        "JavaScript UDF", "Python UDF", "Java UDF",
        "external function", "API integration",
        "MERGE", "INSERT", "UPDATE", "DELETE",
        "UNION", "INTERSECT", "MINUS", "EXCEPT",
        "subquery", "correlated", "scalar function",
        "STATEMENT_TIMEOUT", "query timeout",
    ],
    "Domain 5: Collaboration": [
        "data sharing", "secure data sharing", "share", "SHARE object",
        "provider", "consumer", "reader account", "managed account",
        "listing", "marketplace", "data exchange", "private listing",
        "data clean room",
        "native app", "application package", "Streamlit",
        "replication", "database replication", "failover", "failback",
        "account replication", "primary", "secondary",
        "cross-region", "cross-cloud",
        "time travel", "AT clause", "BEFORE clause", "UNDROP",
        "DATA_RETENTION_TIME_IN_DAYS", "retention",
        "fail-safe", "failsafe", "7 days",
        "clone", "cloning", "zero-copy", "CREATE.*CLONE",
        "resharing", "re-sharing",
    ],
}


def auto_tag_domain(question_text, options_text=""):
    """Assign a domain to a question based on keyword matching."""
    combined = (question_text + " " + options_text).lower()
    scores = {}
    for domain, keywords in DOMAIN_KEYWORDS.items():
        score = 0
        for kw in keywords:
            if kw.lower() in combined:
                # Longer keywords = more specific = higher weight
                score += len(kw.split())
        if score > 0:
            scores[domain] = score

    if not scores:
        return "Untagged"

    # Return domain with highest score
    best = max(scores, key=scores.get)
    # Only tag if score is meaningful (at least 2 keyword matches or one strong match)
    if scores[best] >= 2:
        return best
    return "Untagged"


def main():
    all_questions = []

    # Course 2 files (6)
    print("=== Course 2 ===")
    for i in range(1, 7):
        fp = os.path.join(BASE, "_sources", "core", "udemy_mar_update", f"course_2_snowprocore_test example_{i}.md")
        label = f"course2_test{i}"
        qs = parse_course2(fp, label)
        print(f"  {label}: {len(qs)} questions")
        all_questions.extend(qs)

    # Course 1 files (6)
    print("\n=== Course 1 ===")
    for i in range(1, 7):
        fp = os.path.join(BASE, "_sources", "core", "udemy_cof_03", f"course_01_snowprocore_test example_{i}.md")
        label = f"course1_test{i}"
        qs = parse_course1(fp, label)
        print(f"  {label}: {len(qs)} questions")
        all_questions.extend(qs)

    # Auto-tag untagged questions
    print("\n=== Auto-tagging ===")
    untagged_before = sum(1 for q in all_questions if q["domain"] == "Untagged")
    for q in all_questions:
        if q["domain"] == "Untagged":
            opts_text = " ".join(o["text"] for o in q["options"])
            q["domain"] = auto_tag_domain(q["question"], opts_text)
    untagged_after = sum(1 for q in all_questions if q["domain"] == "Untagged")
    print(f"  Before: {untagged_before} untagged")
    print(f"  After:  {untagged_after} untagged")
    print(f"  Tagged: {untagged_before - untagged_after} questions")

    # Stats
    print(f"\nTotal questions parsed: {len(all_questions)}")

    # Domain distribution
    domain_counts = {}
    for q in all_questions:
        d = q["domain"]
        domain_counts[d] = domain_counts.get(d, 0) + 1
    print("\nDomain distribution:")
    for d, c in sorted(domain_counts.items()):
        print(f"  {d}: {c}")

    # Multi-select stats
    multi = [q for q in all_questions if q.get("multi_select")]
    print(f"\nMulti-select questions: {len(multi)}")

    # Questions with <2 options
    few_opts = [q for q in all_questions if len(q["options"]) < 2]
    print(f"Questions with <2 options (malformed): {len(few_opts)}")

    # Questions with 0 correct answers
    no_correct = [q for q in all_questions if not q["correct_indices"]]
    print(f"Questions with 0 correct answers: {len(no_correct)}")

    # Source distribution
    source_counts = {}
    for q in all_questions:
        s = q["source"]
        source_counts[s] = source_counts.get(s, 0) + 1
    print("\nSource distribution:")
    for s, c in sorted(source_counts.items()):
        print(f"  {s}: {c}")

    # Save JSON
    out_path = os.path.join(BASE, "questions.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(all_questions, f, indent=2, ensure_ascii=False)
    print(f"\nSaved to: {out_path}")


if __name__ == "__main__":
    main()
