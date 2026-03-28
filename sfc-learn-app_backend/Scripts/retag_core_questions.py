"""
Re-tag 188 Untagged SnowPro Core questions using keyword matching.
Maps questions to the 5 official COF-C03 domains based on question + options text.

Usage: python Scripts/retag_core_questions.py
"""
import json
import os
import re

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
QS_FILE = os.path.join(
    BASE, "certifications", "sfc-gh-sd-snowprocore", "core_questions.json"
)

DOMAINS = {
    "Domain 1: Architecture": [
        "micro-partition", "micro partition", "columnar", "column store",
        "cloud services layer", "compute layer", "storage layer",
        "virtual warehouse", "warehouse size", "multi-cluster",
        "elastic", "snowflake architecture", "three layers",
        "metadata", "global services", "query processing",
        "hybrid table", "row-oriented", "architecture",
        "snowflake edition", "standard edition", "enterprise edition",
        "business critical", "virtual private snowflake", "vps",
        "snowflake object", "stages of query", "query compilation",
        "query execution", "result cache", "persisted query result",
        "local disk cache", "remote disk", "metadata cache",
    ],
    "Domain 2: Account & Governance": [
        "role", "rbac", "grant", "privilege", "access control",
        "accountadmin", "sysadmin", "securityadmin", "useradmin",
        "public role", "orgadmin", "network policy", "ip allow",
        "ip block", "masking policy", "row access policy",
        "tag", "object tag", "data classification", "pii",
        "mfa", "multi-factor", "sso", "saml", "scim",
        "key pair", "rsa", "authentication", "password policy",
        "session policy", "account parameter", "account usage",
        "information_schema", "login_history", "access_history",
        "resource monitor", "credit quota", "organization",
        "account identifier", "region group", "data sharing governance",
        "managed access", "future grant", "ownership",
        "user", "profile", "switch role", "default role",
        "secondary role", "account_usage", "information schema",
    ],
    "Domain 3: Data Loading": [
        "copy into", "stage", "file format", "snowpipe",
        "auto_ingest", "pipe", "bulk load", "data loading",
        "put command", "get command", "csv", "json", "parquet",
        "avro", "orc", "infer_schema", "using template",
        "error_on_column", "on_error", "skip_file", "abort_statement",
        "field_optionally_enclosed", "record_delimiter",
        "strip_null", "match_by_column", "force",
        "validation_mode", "load_history", "copy_history",
        "metadata\\$", "external stage", "internal stage",
        "user stage", "table stage", "named stage",
        "storage integration", "unload", "data unloading",
        "semi-structured", "variant", "flatten", "lateral",
        "object_construct", "array_agg", "parse_json",
        "strip_outer_array", "directory table",
        "file_format", "type =", "compression",
    ],
    "Domain 4: Performance & Querying": [
        "query profile", "performance", "clustering",
        "cluster key", "pruning", "partition",
        "spill", "spillage", "cache", "caching",
        "warehouse size", "scale up", "scale out",
        "concurrency", "queuing", "suspend", "auto_suspend",
        "auto_resume", "materialized view", "search optimization",
        "query acceleration", "explain", "query_history",
        "warehouse_metering", "credit", "cost",
        "execution time", "bytes scanned", "rows produced",
        "deterministic", "result set cache",
        "sequence", "generate_series", "window function",
        "qualify", "rank", "row_number", "dense_rank",
        "lead", "lag", "first_value", "last_value",
        "pivot", "unpivot", "group by", "having",
        "lateral flatten", "recursive cte", "connect by",
        "merge", "insert", "update", "delete", "truncate",
        "create table as select", "ctas",
        "time travel", "at timestamp", "before statement",
        "undrop", "data_retention", "fail-safe", "failsafe",
        "transient", "temporary table",
        "task", "stream", "dynamic table", "target lag",
        "stored procedure", "udf", "udtf", "javascript",
        "sql scripting", "snowpark", "python udf",
    ],
    "Domain 5: Collaboration": [
        "share", "sharing", "data share", "data sharing",
        "reader account", "managed account", "listing",
        "marketplace", "data exchange", "provider", "consumer",
        "secure view", "secure function", "secure udf",
        "clone", "zero-copy", "cloning", "replication",
        "failover", "failback", "cross-region", "cross-cloud",
        "database replication", "failover group",
        "snowsight", "worksheet", "dashboard", "chart",
        "notification", "alert", "email",
        "connector", "driver", "snowsql", "snowcli",
        "partner connect", "ecosystem",
        "external function", "api integration",
        "snowpark container", "streamlit",
        "data catalog", "data clean room",
        "unstructured", "scoped url", "presigned url",
        "file url", "build_scoped_file_url",
    ],
}


def classify_question(q):
    """Return the best-matching domain for a question, or None."""
    text = (
        q.get("question", "")
        + " "
        + " ".join(o.get("text", "") for o in q.get("options", []))
        + " "
        + q.get("explanation", "")
    ).lower()

    scores = {}
    for domain, keywords in DOMAINS.items():
        score = 0
        for kw in keywords:
            if kw in text:
                score += 1
        scores[domain] = score

    best = max(scores, key=scores.get)
    if scores[best] == 0:
        return None
    return best


def main():
    with open(QS_FILE, "r", encoding="utf-8") as f:
        questions = json.load(f)

    untagged = [q for q in questions if q.get("domain") == "Untagged"]
    print(f"Total questions: {len(questions)}")
    print(f"Untagged before: {len(untagged)}")

    retagged = 0
    still_untagged = 0
    domain_counts = {}

    for q in questions:
        if q.get("domain") != "Untagged":
            continue
        new_domain = classify_question(q)
        if new_domain:
            q["domain"] = new_domain
            q["domain_raw"] = q.get("domain_raw", "Untagged") + " (auto-retagged)"
            retagged += 1
            domain_counts[new_domain] = domain_counts.get(new_domain, 0) + 1
        else:
            still_untagged += 1

    # For any still untagged, assign to domain with fewest questions overall
    if still_untagged > 0:
        overall = {}
        for q in questions:
            d = q.get("domain", "Untagged")
            if d != "Untagged":
                overall[d] = overall.get(d, 0) + 1
        smallest = min(overall, key=overall.get)
        for q in questions:
            if q.get("domain") == "Untagged":
                q["domain"] = smallest
                q["domain_raw"] = q.get("domain_raw", "Untagged") + " (auto-fallback)"
                retagged += 1
                domain_counts[smallest] = domain_counts.get(smallest, 0) + 1

    print(f"\nRetagged: {retagged}")
    print(f"Still untagged: {sum(1 for q in questions if q.get('domain') == 'Untagged')}")
    print("\nDistribution of retagged questions:")
    for d, c in sorted(domain_counts.items()):
        print(f"  {d}: +{c}")

    # Final distribution
    print("\nFinal domain distribution:")
    final = {}
    for q in questions:
        d = q.get("domain", "?")
        final[d] = final.get(d, 0) + 1
    for d, c in sorted(final.items()):
        print(f"  {d}: {c}")

    with open(QS_FILE, "w", encoding="utf-8") as f:
        json.dump(questions, f, indent=2, ensure_ascii=False)
    print(f"\nSaved to {QS_FILE}")


if __name__ == "__main__":
    main()
