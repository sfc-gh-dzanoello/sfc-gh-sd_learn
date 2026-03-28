#!/usr/bin/env python3
"""
Classify all architect questions by sub-topic and fix image-dependent questions.

Sub-topic taxonomy (from review_notes):
  Domain 1: Account & Security
    1.1 Account Strategy
    1.2 Parameter Hierarchy
    1.3 Role-Based Access Control
    1.4 Network Security
    1.5 Authentication

  Domain 2: Data Architecture
    2.1 Data Modeling
    2.2 Object Hierarchy
    2.3 Table Types & Views
    2.4 Data Recovery
    2.5 Replication & Failover

  Domain 3: Data Engineering
    3.1 Data Loading
    3.2 Stages & File Formats
    3.3 Streams & Tasks
    3.4 External & Iceberg Tables
    3.5 Data Transformation
    3.6 Kafka Connector
    3.7 Ecosystem Connectivity
    3.8 Ecosystem Tools

  Domain 4: Performance Optimization
    4.1 Query Profile
    4.2 Warehouses
    4.3 Caching
    4.4 Clustering & Pruning
    4.5 Performance Services

  Domain 5: Sharing & Collaboration
    5.1 Secure Data Sharing
    5.2 Sharing Scenarios
    5.3 Reader Accounts
    5.4 Marketplace & Data Exchange
    5.5 Data Clean Rooms
    5.6 Native Apps

  Domain 6: DevOps & Ecosystem
    6.1 Development Lifecycle
    6.2 CI/CD & Deployment
    6.3 Snowpark Container Services
    6.4 AI/ML in Snowflake
    6.5 Streamlit & Native Apps
    6.6 Data Warehouse Layers
"""

import json
import re
import os

# --- Sub-topic classification rules ---
# Each rule: (sub_topic_id, sub_topic_name, keywords_in_question_or_explanation)
# Priority: more specific patterns first within each domain

RULES = [
    # Domain 1
    ("1.5", "Authentication", [
        "sso", "single sign", "saml", "mfa", "multi-factor", "multifactor",
        "oauth", "okta", "identity provider", "idp", "federated",
        "scim", "key pair", "authenticat", "token caching",
        "allow_client_mfa", "client_session_keep_alive", "external oauth",
        "password policy", "session token",
    ]),
    ("1.4", "Network Security", [
        "network policy", "privatelink", "private link", "private_link",
        "ip allow", "ip block", "firewall", "vpn", "vpc",
        "tri-secret", "tri_secret", "trisecret", "customer-managed key",
        "cmk", "byok", "encryption key", "network rule",
    ]),
    ("1.3", "Role-Based Access Control", [
        "rbac", "role-based", "access control", "grant", "privilege",
        "system role", "custom role", "accountadmin", "sysadmin", "securityadmin",
        "useradmin", "orgadmin", "role hierarchy", "secondary role",
        "ownership", "future grant", "managed access", "discretionary",
        "object_viewer", "object_creator", "masking policy", "row access policy",
        "tag-based", "column-level", "row-level", "dynamic data masking",
        "data governance", "object tagging",
    ]),
    ("1.2", "Parameter Hierarchy", [
        "parameter", "data_retention_time", "retention_time",
        "time travel", "session parameter", "account parameter",
        "object parameter", "parameter hierarchy", "statement_timeout",
        "abort_detached_query",
    ]),
    ("1.1", "Account Strategy", [
        "multi-tenant", "account per tenant", "organization",
        "account strategy", "account locator", "region group",
        "snowflake edition", "standard edition", "enterprise edition",
        "business critical", "vps edition", "virtual private",
        "account identifier", "orgname", "account_name",
    ]),

    # Domain 2
    ("2.5", "Replication & Failover", [
        "replication", "failover", "failback", "primary account",
        "secondary account", "replication group", "failover group",
        "client redirect", "connection url", "database replication",
        "cross-region", "cross-cloud", "disaster recovery",
        "account replication", "global account",
    ]),
    ("2.4", "Data Recovery", [
        "time travel", "undrop", "fail-safe", "failsafe",
        "data_retention", "clone", "zero-copy", "zero copy",
        "snapshot", "data recovery", "at.*offset", "before.*timestamp",
    ]),
    ("2.3", "Table Types & Views", [
        "transient table", "temporary table", "permanent table",
        "external table", "hybrid table", "dynamic table",
        "materialized view", "secure view", "view", "lateral flatten",
        "semi-structured", "variant", "array", "object",
        "flatten", "search optimization", "sos",
        "information_schema", "account_usage",
    ]),
    ("2.2", "Object Hierarchy", [
        "database", "schema", "object hierarchy", "namespace",
        "stage", "sequence", "pipe", "file format",
        "fully qualified", "dot notation",
    ]),
    ("2.1", "Data Modeling", [
        "star schema", "snowflake schema", "data vault", "3nf",
        "kimball", "inmon", "dimensional", "fact table", "dimension table",
        "hub", "satellite", "link", "data model", "normali",
        "denormali", "data mesh", "data lakehouse", "data lake",
        "medallion", "bronze", "silver", "gold", "raw.*layer",
    ]),

    # Domain 3
    ("3.6", "Kafka Connector", [
        "kafka", "record_content", "record_metadata",
        "snowflake connector for kafka", "kafka connector",
    ]),
    ("3.4", "External & Iceberg Tables", [
        "iceberg", "external table", "external_table",
        "parquet", "orc", "avro", "delta",
        "catalog integration", "external volume",
    ]),
    ("3.3", "Streams & Tasks", [
        "stream", "task", "change tracking", "cdc",
        "change data capture", "append_only", "standard stream",
        "task graph", "dag", "predecessor", "root task",
        "serverless task", "task schedule", "cron",
        "system$stream_has_data",
    ]),
    ("3.2", "Stages & File Formats", [
        "stage", "file format", "internal stage", "external stage",
        "named stage", "table stage", "user stage",
        "put command", "get command", "list @", "remove @",
        "csv", "json format", "copy option",
        "file_format", "skip_header", "strip_outer_array",
        "on_error", "purge", "pattern",
    ]),
    ("3.5", "Data Transformation", [
        "stored procedure", "udf", "udtf", "udaf",
        "user-defined", "javascript", "java udf", "python udf",
        "snowpark", "dataframe", "sproc",
        "caller.*right", "owner.*right", "execute as",
        "warehouse task", "merge", "insert overwrite",
        "multi-table insert", "conditional insert",
    ]),
    ("3.1", "Data Loading", [
        "copy into", "snowpipe", "auto_ingest", "auto-ingest",
        "bulk load", "data loading", "data ingestion", "ingest",
        "load history", "copy_history", "load_history",
        "validation_mode", "return_failed_only",
        "files =", "force = true",
    ]),
    ("3.7", "Ecosystem Connectivity", [
        "connector", "driver", "jdbc", "odbc",
        "python connector", "spark connector", "go driver",
        ".net driver",
    ]),
    ("3.8", "Ecosystem Tools", [
        "snowsql", "snowcli", "snow cli",
        "git integration", "git repository",
    ]),

    # Domain 4
    ("4.4", "Clustering & Pruning", [
        "cluster", "clustering key", "micro-partition", "micropartition",
        "pruning", "partition", "natural clustering",
        "system$clustering_information", "system$clustering_depth",
        "average_depth", "average_overlap", "recluster",
        "automatic clustering",
    ]),
    ("4.3", "Caching", [
        "cache", "result cache", "metadata cache", "warehouse cache",
        "local disk", "ssd", "remote disk", "persist_query_result",
        "use_cached_result",
    ]),
    ("4.1", "Query Profile", [
        "query profile", "query_id", "query history",
        "explain plan", "execution plan", "operator",
        "spilling", "spillage", "bytes scanned",
        "bytes sent", "rows produced", "statistics",
        "query_acceleration", "search optimization",
        "query tag", "resource monitor",
    ]),
    ("4.2", "Warehouses", [
        "warehouse", "multi-cluster", "multicluster",
        "scaling policy", "auto-suspend", "auto-resume",
        "economy scaling", "standard scaling",
        "warehouse size", "x-small", "x-large", "4-xl",
        "concurrency", "queuing", "max_cluster",
        "min_cluster", "initially_suspended",
    ]),
    ("4.5", "Performance Services", [
        "materialized view", "search optimization",
        "query acceleration", "qas",
    ]),

    # Domain 5
    ("5.5", "Data Clean Rooms", [
        "clean room", "cleanroom", "data clean room",
    ]),
    ("5.6", "Native Apps", [
        "native app", "application package", "snowflake native",
        "provider.*consumer", "installed app",
    ]),
    ("5.3", "Reader Accounts", [
        "reader account", "managed account",
    ]),
    ("5.4", "Marketplace & Data Exchange", [
        "marketplace", "data exchange", "listing",
        "data product", "provider", "consumer",
    ]),
    ("5.2", "Sharing Scenarios", [
        "cross-region.*shar", "cross-cloud.*shar",
        "share.*replicate", "replicate.*share",
        "different.*region.*share", "different.*cloud.*share",
    ]),
    ("5.1", "Secure Data Sharing", [
        "share", "sharing", "data share", "secure share",
        "simulated_data_sharing", "share_restrictions",
        "create share", "alter share", "show shares",
        "inbound share", "outbound share",
    ]),

    # Domain 6
    ("6.3", "Snowpark Container Services", [
        "spcs", "container service", "container",
        "compute pool", "image repository", "service function",
    ]),
    ("6.4", "AI/ML in Snowflake", [
        "cortex", "ml function", "machine learning",
        "forecast", "anomaly_detection", "classification",
        "snowflake ml", "model registry",
    ]),
    ("6.5", "Streamlit & Native Apps", [
        "streamlit", "sis", "streamlit in snowflake",
    ]),
    ("6.6", "Data Warehouse Layers", [
        "staging layer", "raw layer", "curated layer",
        "presentation layer", "etl", "elt",
        "landing zone", "consumption layer",
    ]),
    ("6.2", "CI/CD & Deployment", [
        "ci/cd", "cicd", "ci cd", "deployment",
        "schemachange", "flyway", "terraform",
        "snow cli", "snowcli",
    ]),
    ("6.1", "Development Lifecycle", [
        "git", "version control", "development",
        "sandbox", "dev.*prod", "environment",
    ]),
]


def classify_question(q):
    """Return (sub_topic_id, sub_topic_name) for a question."""
    domain = q.get("domain", "")
    text = (q.get("question", "") + " " + q.get("overall_explanation", "")).lower()

    # Also include option text for better classification
    for opt in q.get("options", []):
        text += " " + opt.get("text", "").lower()
        text += " " + opt.get("explanation", "").lower()

    # Determine domain number
    domain_num = None
    m = re.search(r"Domain (\d+)", domain)
    if m:
        domain_num = m.group(1)

    best_match = None
    best_score = 0

    for rule_id, rule_name, keywords in RULES:
        # Only consider rules for the correct domain
        if domain_num and not rule_id.startswith(domain_num + "."):
            continue

        score = 0
        for kw in keywords:
            if re.search(kw, text, re.IGNORECASE):
                score += 1

        if score > best_score:
            best_score = score
            best_match = (rule_id, rule_name)

    if best_match:
        return best_match

    # Fallback: first sub-topic of the domain
    fallbacks = {
        "1": ("1.1", "Account Strategy"),
        "2": ("2.1", "Data Modeling"),
        "3": ("3.1", "Data Loading"),
        "4": ("4.2", "Warehouses"),
        "5": ("5.1", "Secure Data Sharing"),
        "6": ("6.1", "Development Lifecycle"),
    }
    if domain_num and domain_num in fallbacks:
        return fallbacks[domain_num]

    return ("0.0", "Unclassified")


# --- Image question rewrites ---
IMAGE_REWRITES = {
    "architect_test1_q27": {
        "question": "A company has two Snowflake accounts: Account A (in AWS us-east-1) contains database DB1, and Account B (in AWS us-west-2) contains database DB2 with table TBL2. The accounts are in the same organization. How can the data from DB1 be copied into TBL2? (Choose two.)",
        "overall_explanation": "Database replication can be used to replicate DB1 from Account A to Account B, making the data available locally. Once replicated, standard COPY/INSERT operations can move data into TBL2. Alternatively, creating a data share from Account A and consuming it in Account B provides read access to the data, which can then be inserted into TBL2. Direct cross-account SQL queries are not supported without replication or sharing. For more detailed information, refer to the official Snowflake documentation on database replication and data sharing.",
    },
    "architect_test2_q6": {
        # Time Travel diagram reference - the explanation mentions a diagram
        # The question itself is fine, just the explanation references an image
        "overall_explanation": "When a database is dropped, the data retention period for child schemas or tables, if explicitly set to be different from the retention of the database, is not honored. The child schemas or tables are retained for the same period as the database. So even though the schema S1 has DATA_RETENTION_TIME_IN_DAYS=50, dropping the database means Time Travel access is limited to the database's retention period of 30 days. If only the schema were dropped (without dropping the database), Time Travel would use the schema's own retention period of 50 days. Key rule: the parent object's retention overrides children when the parent is dropped.",
    },
    "architect_test2_q24": {
        "overall_explanation": "Data skew refers to a non-uniform distribution of values in a dataset -- for example, if 90% of rows have the same value in a join column. In Snowflake, this means one processing node handles the majority of the data while other nodes sit idle, creating a bottleneck. Scaling up the warehouse does NOT help because the problem is concentrated on a single node. The solution involves restructuring the query or data to distribute work more evenly. Common strategies include: filtering out the skewed values first, breaking the query into parts, or using different join strategies. You can identify data skew in the Query Profile by looking at uneven partition scans across nodes.",
    },
    "architect_test2_q44": {
        "overall_explanation": "The process flow for Snowpipe auto-ingest with Amazon SNS follows three steps: (1) Data files are loaded into the S3 bucket. (2) S3 sends an event notification to an SNS topic. (3) SNS forwards the notification to a Snowflake SQS queue, which triggers Snowpipe to load the data. The key point is that S3 event notifications go to SNS first (not directly to SQS), and SNS then relays to Snowflake's SQS queue. This architecture allows multiple subscribers to receive the same S3 event notifications. The aws_sns_topic parameter in the CREATE PIPE statement configures this integration.",
    },
    "architect_test4_q4": {
        # SCIM question with "following diagram" in explanation
        "overall_explanation": "SCIM (System for Cross-domain Identity Management) integration requires configuring a SCIM security integration in Snowflake. The authentication integration (SSO/SAML) handles login but does NOT handle user provisioning or role assignment. SCIM is a separate integration that must be configured to automatically provision/deprovision users and sync group-to-role mappings from the identity provider (like Azure AD or Okta) to Snowflake. Without SCIM, users and roles must be manually created in Snowflake even if SSO is configured. The process: (1) Configure SSO for authentication, (2) Configure SCIM for provisioning, (3) Map IdP groups to Snowflake roles in the SCIM configuration.",
    },
    "architect_test3_q30": {
        # "following picture" reference about bytes scanned metric
        "overall_explanation": "The 'Bytes scanned' metric is found in the Statistics section of the Query Profile, not in the operator details. The Query Profile in the Snowflake Web UI has several sections: the visual operator tree (showing nodes like TableScan, Filter, Join, etc.), the operator details panel (showing per-operator metrics when you click a node), and the Statistics panel (showing overall query statistics like 'Bytes scanned', 'Percentage scanned from cache', 'Partitions scanned', 'Partitions total'). Understanding where to find each metric is important for troubleshooting performance issues.",
    },
}


def fix_image_questions(questions):
    """Rewrite questions that depend on missing images."""
    count = 0
    for q in questions:
        qid = q["id"]
        if qid in IMAGE_REWRITES:
            rewrite = IMAGE_REWRITES[qid]
            if "question" in rewrite:
                q["question"] = rewrite["question"]
            if "overall_explanation" in rewrite:
                q["overall_explanation"] = rewrite["overall_explanation"]
            count += 1
    return count


def main():
    qfile = os.path.join(
        os.path.dirname(os.path.dirname(__file__)),
        "certifications", "sfc-gh-sd-advanced", "architect_domains",
        "architect_questions.json",
    )

    with open(qfile, "r") as f:
        questions = json.load(f)

    print(f"Loaded {len(questions)} questions")

    # Fix image-dependent questions
    fixed = fix_image_questions(questions)
    print(f"Fixed {fixed} image-dependent questions")

    # Classify all questions
    from collections import Counter
    subtopic_counts = Counter()
    unclassified = []

    for q in questions:
        st_id, st_name = classify_question(q)
        q["sub_topic"] = st_id
        q["sub_topic_name"] = st_name
        subtopic_counts[f"{st_id} {st_name}"] += 1
        if st_id == "0.0":
            unclassified.append(q["id"])

    # Print distribution
    print("\nSub-topic distribution:")
    for st, count in sorted(subtopic_counts.items()):
        print(f"  {st}: {count}")

    if unclassified:
        print(f"\nUnclassified ({len(unclassified)}):")
        for qid in unclassified:
            print(f"  {qid}")

    # Write back
    with open(qfile, "w") as f:
        json.dump(questions, f, indent=2, ensure_ascii=False)
    print(f"\nWrote {len(questions)} questions to {qfile}")


if __name__ == "__main__":
    main()
