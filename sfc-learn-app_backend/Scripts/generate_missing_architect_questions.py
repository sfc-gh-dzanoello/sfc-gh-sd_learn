"""
Generate new architect questions for topics with zero or low coverage.
Adds them to architect_questions.json.

Topics covered:
- Domain 5: Sharing & Collaboration (new domain, ~20 questions)
- Domain 6: DevOps & Ecosystem (new domain, ~20 questions)
- Gap topics: Hybrid tables, Data Clean Rooms, Native Apps, SPCS, DAGs,
  Key rotation, Failback, Dynamic tables, Iceberg, QAS, PrivateLink,
  Resource monitors, Client redirect, SCIM
- Domain 1 reinforcement (~15 more questions)
"""
import json
from pathlib import Path

QF = Path(__file__).resolve().parent.parent / "certifications" / "sfc-gh-sd-advanced" / "architect_domains" / "architect_questions.json"

with open(QF) as f:
    existing = json.load(f)

existing_ids = {q["id"] for q in existing}
new_qs = []
qnum = 0

def add_q(domain, question, options, correct_indices, explanation,
          multi_select=False, difficulty="intermediate"):
    global qnum
    qnum += 1
    qid = f"architect_new_q{qnum}"
    assert qid not in existing_ids, f"Duplicate ID: {qid}"
    ms_count = len(correct_indices) if multi_select else 1
    new_qs.append({
        "id": qid,
        "source": "architect_new",
        "question_num": qnum,
        "question": question,
        "options": [{"text": t, "explanation": ""} for t in options],
        "correct_indices": correct_indices,
        "multi_select": multi_select,
        "multi_select_count": ms_count,
        "overall_explanation": explanation,
        "domain_raw": "",
        "domain": domain,
        "difficulty": difficulty,
    })

D1 = "Domain 1.0: Accounts and Security"
D2 = "Domain 2.0: Snowflake Architecture"
D3 = "Domain 3.0: Data Engineering"
D4 = "Domain 4.0: Performance Optimization"
D5 = "Domain 5.0: Sharing & Collaboration"
D6 = "Domain 6.0: DevOps & Ecosystem"

# ═══════════════════════════════════════════════════════════════
# DOMAIN 5: SHARING & COLLABORATION (~20 questions)
# ═══════════════════════════════════════════════════════════════

add_q(D5,
    "A provider wants to share a filtered subset of customer data with a consumer account. "
    "Only rows where region = 'EMEA' should be visible. What is the recommended approach?",
    [
        "Create a regular view with a WHERE clause and add it to the share.",
        "Create a secure view with a WHERE clause and add it to the share.",
        "Use a row access policy on the base table and share the table directly.",
        "Export the filtered data to a stage and share the stage.",
    ],
    [1],
    "Secure views are required for sharing -- regular views expose their SQL definition to consumers. "
    "A secure view with a WHERE filter is the standard approach for row-level filtering in shares. "
    "Row access policies are for controlling access within an account, not across shares.",
    difficulty="intermediate"
)

add_q(D5,
    "Which objects can be included in a Snowflake share? (Choose three.)",
    [
        "Tables",
        "Secure views",
        "Stored procedures",
        "Secure UDFs",
        "Stages",
        "Streams",
    ],
    [0, 1, 3],
    "Shares can include tables, secure views, secure materialized views, and secure UDFs. "
    "Stored procedures, stages, streams, tasks, and pipes cannot be shared directly.",
    multi_select=True, difficulty="intermediate"
)

add_q(D5,
    "A healthcare company needs to share anonymized patient data with a research university "
    "that does not have a Snowflake account. What should the Architect recommend?",
    [
        "Create a standard share and ask the university to sign up for Snowflake.",
        "Create a reader account for the university and share the data via a share.",
        "Export the data to Parquet files and send them via secure file transfer.",
        "Create a listing on the Snowflake Marketplace.",
    ],
    [1],
    "Reader accounts are designed for consumers who don't have their own Snowflake account. "
    "The provider creates the reader account and pays for both storage and compute. "
    "The consumer gets read-only access to the shared data.",
    difficulty="intermediate"
)

add_q(D5,
    "Who pays for compute when a consumer queries data from a standard Snowflake share?",
    [
        "The provider pays for both storage and compute.",
        "The consumer pays for both storage and compute.",
        "The provider pays for storage; the consumer pays for compute.",
        "Costs are split equally between provider and consumer.",
    ],
    [2],
    "In standard Snowflake sharing, the provider pays for storage (since the data lives in their account) "
    "and the consumer pays for compute (they use their own warehouses to query the shared data). "
    "This is different from reader accounts where the provider pays for everything.",
    difficulty="beginner"
)

add_q(D5,
    "A company in AWS us-east-1 wants to share data with a partner in Azure West Europe. "
    "What is required for this to work?",
    [
        "Direct cross-cloud sharing is supported natively -- no additional steps needed.",
        "The provider must replicate the database to an Azure account first, then create a share from there.",
        "The provider must export data to S3 and the consumer imports from S3 to Azure.",
        "Cross-cloud sharing is not possible in Snowflake.",
    ],
    [1],
    "Cross-region and cross-cloud sharing requires database replication first. The provider must replicate "
    "the shared database to an account in the consumer's region/cloud, then create the share from there. "
    "Auto-Fulfillment handles this automatically for Marketplace listings.",
    difficulty="advanced"
)

add_q(D5,
    "What is the primary purpose of Auto-Fulfillment in the Snowflake Marketplace?",
    [
        "Automatically generating documentation for shared datasets.",
        "Automatically replicating listing data to consumer regions across clouds.",
        "Automatically creating reader accounts for new consumers.",
        "Automatically refreshing stale shared data.",
    ],
    [1],
    "Auto-Fulfillment automatically replicates Marketplace listing data to the consumer's "
    "cloud and region, enabling cross-cloud and cross-region delivery without the provider "
    "manually setting up replication.",
    difficulty="advanced"
)

add_q(D5,
    "A Data Clean Room analysis requires two companies to compute audience overlap without "
    "either party seeing the other's raw data. What Snowflake feature enables this?",
    [
        "Standard data sharing with secure views.",
        "Snowflake Data Clean Rooms with secure multiparty computation.",
        "External functions calling a third-party MPC service.",
        "Database replication between the two accounts.",
    ],
    [1],
    "Snowflake Data Clean Rooms enable secure multiparty analysis where participants can compute "
    "aggregate results (like audience overlap) without exposing underlying raw data to each other. "
    "This goes beyond standard sharing which grants read access to actual rows.",
    difficulty="advanced"
)

add_q(D5,
    "Which statement about Snowflake Native Apps is TRUE?",
    [
        "Native Apps can only contain SQL procedures and nothing else.",
        "Native Apps are installed in the consumer's account and can include Streamlit UIs, procedures, and shared data.",
        "Native Apps require the consumer to have ACCOUNTADMIN privileges to install.",
        "Native Apps bypass Snowflake's access control model.",
    ],
    [1],
    "Native Apps (Application Packages) are full distributable packages that can include "
    "Streamlit interfaces, stored procedures, UDFs, shared data, and setup scripts. "
    "They install in the consumer's account and respect Snowflake's RBAC model.",
    difficulty="intermediate"
)

add_q(D5,
    "What happens to shared data if the provider drops the source table that is included in an active share?",
    [
        "The consumer's queries continue to work because the data was copied.",
        "The consumer's queries fail because shares are zero-copy -- no data was copied.",
        "The share is automatically deleted.",
        "The consumer's shared database is automatically dropped.",
    ],
    [1],
    "Shares are zero-copy -- the consumer reads directly from the provider's storage. "
    "If the provider drops the source object, the consumer's queries will fail because "
    "the underlying data no longer exists. The share itself remains but becomes unusable.",
    difficulty="intermediate"
)

add_q(D5,
    "An Architect needs to share data with 50 different consumer accounts. Each consumer "
    "should only see rows relevant to their organization. What is the MOST scalable approach?",
    [
        "Create 50 separate shares, each with a different secure view filtering rows for that consumer.",
        "Create one share with a single secure view that uses CURRENT_ACCOUNT() to filter rows dynamically.",
        "Create 50 separate databases, each containing only that consumer's data.",
        "Export filtered CSV files for each consumer.",
    ],
    [1],
    "Using CURRENT_ACCOUNT() inside a secure view allows a single share to serve multiple consumers "
    "with row-level filtering based on the consumer's account identifier. This is far more scalable "
    "than creating separate shares or databases for each consumer.",
    difficulty="advanced"
)

add_q(D5,
    "What is the difference between a Snowflake Marketplace listing and a direct share?",
    [
        "Marketplace listings require Enterprise Edition; direct shares work on Standard.",
        "Marketplace listings are discoverable by any Snowflake account; direct shares require the provider to know the consumer's account.",
        "Marketplace listings copy data to the consumer; direct shares are zero-copy.",
        "There is no difference -- they use the same underlying mechanism.",
    ],
    [1],
    "Marketplace listings are publicly discoverable in the Snowflake Marketplace catalog, allowing "
    "any Snowflake account to find and request access. Direct shares require the provider to explicitly "
    "add consumer accounts. Both use zero-copy sharing under the hood.",
    difficulty="intermediate"
)

add_q(D5,
    "A provider creates a share containing a secure view that references two tables. "
    "The consumer reports an error when querying the shared view. What is the MOST likely cause?",
    [
        "The consumer's warehouse is too small to execute the view.",
        "The provider only granted SELECT on one of the two underlying tables to the share.",
        "Secure views cannot reference multiple tables.",
        "The consumer must create their own view on top of the shared view.",
    ],
    [1],
    "When sharing a secure view that references multiple tables, the provider must grant "
    "SELECT on ALL underlying tables to the share. Missing grants on any referenced table "
    "will cause the consumer's queries to fail.",
    difficulty="advanced"
)

add_q(D5,
    "Which of the following CANNOT be shared using Snowflake Secure Data Sharing? (Choose two.)",
    [
        "Transient tables",
        "Secure materialized views",
        "Stages",
        "Tables",
        "Secure UDFs",
    ],
    [0, 2],
    "Transient tables and stages cannot be shared. Shares support regular tables, "
    "secure views, secure materialized views, and secure UDFs. Temporary tables also "
    "cannot be shared.",
    multi_select=True, difficulty="intermediate"
)

add_q(D5,
    "A company publishes a free dataset on the Snowflake Marketplace. A consumer in a different "
    "cloud region subscribes. How is the data delivered?",
    [
        "The consumer must manually replicate the data to their region.",
        "Auto-Fulfillment replicates the data to the consumer's region automatically.",
        "The consumer queries the data cross-region with added latency.",
        "Free listings are only available within the same region.",
    ],
    [1],
    "For Marketplace listings, Snowflake's Auto-Fulfillment automatically handles cross-region "
    "and cross-cloud data delivery by replicating the listing data to the consumer's region.",
    difficulty="intermediate"
)

add_q(D5,
    "A reader account is consuming shared data. Who is billed for the reader account's warehouse compute?",
    [
        "The reader account is billed independently.",
        "The provider account is billed for all reader account costs.",
        "Snowflake absorbs reader account costs.",
        "The provider pays for storage; the reader pays for compute.",
    ],
    [1],
    "Reader accounts are fully managed and paid for by the provider. The provider pays for "
    "everything -- storage, compute, and cloud services. This is the key difference from "
    "standard sharing where the consumer pays for their own compute.",
    difficulty="intermediate"
)

add_q(D5,
    "What is the primary advantage of using a Data Exchange over individual direct shares?",
    [
        "Data Exchanges provide encryption that direct shares lack.",
        "Data Exchanges allow a group of accounts to share data bidirectionally under a unified governance model.",
        "Data Exchanges are faster than direct shares.",
        "Data Exchanges automatically translate data between languages.",
    ],
    [1],
    "A Data Exchange creates a curated, governed hub where a group of related accounts can "
    "share data bidirectionally. Unlike individual shares, it provides centralized governance, "
    "discoverability, and request workflows for the group.",
    difficulty="advanced"
)

add_q(D5,
    "Which SQL command does a consumer use to access data from a share?",
    [
        "IMPORT DATABASE FROM SHARE provider.my_share;",
        "CREATE DATABASE shared_db FROM SHARE provider.my_share;",
        "CLONE DATABASE FROM SHARE provider.my_share;",
        "MOUNT SHARE provider.my_share AS shared_db;",
    ],
    [1],
    "The consumer creates a database from the share using CREATE DATABASE ... FROM SHARE. "
    "This creates a read-only database in the consumer's account that references the provider's data.",
    difficulty="beginner"
)

add_q(D5,
    "An Architect is designing a solution where multiple departments within the same account "
    "need access to curated data products. Should they use Snowflake shares or another approach?",
    [
        "Create internal shares between departments.",
        "Use RBAC with grants -- shares are only for cross-account data access.",
        "Create reader accounts for each department.",
        "Export data to separate databases for each department.",
    ],
    [1],
    "Snowflake shares are designed for cross-account data access. Within the same account, "
    "the standard approach is to use RBAC (role-based access control) with appropriate grants "
    "on databases, schemas, and objects.",
    difficulty="intermediate"
)

# ═══════════════════════════════════════════════════════════════
# DOMAIN 6: DEVOPS & ECOSYSTEM (~20 questions)
# ═══════════════════════════════════════════════════════════════

add_q(D6,
    "An Architect needs to deploy schema changes to production with zero downtime. "
    "Which Snowflake feature enables this?",
    [
        "CREATE DATABASE ... CLONE",
        "ALTER DATABASE ... SWAP WITH",
        "ALTER DATABASE ... RENAME TO",
        "CREATE DATABASE ... FROM SHARE",
    ],
    [1],
    "ALTER DATABASE SWAP WITH atomically swaps two databases, enabling blue/green deployments. "
    "Deploy changes to the 'blue' database, test them, then swap it with production. "
    "If issues arise, swap back for instant rollback.",
    difficulty="intermediate"
)

add_q(D6,
    "After cloning a production database for testing, an Architect notices that scheduled "
    "tasks are not running in the cloned database. Why?",
    [
        "Tasks cannot be cloned.",
        "Cloned tasks are suspended by default and must be manually resumed.",
        "The clone does not include task objects.",
        "Tasks require a separate warehouse that wasn't cloned.",
    ],
    [1],
    "When cloning a database or schema, all tasks are cloned but are automatically suspended. "
    "This is a safety measure to prevent cloned tasks from accidentally running against "
    "production resources or consuming unexpected credits.",
    difficulty="intermediate"
)

add_q(D6,
    "What authentication method is recommended for Snowflake CI/CD pipelines?",
    [
        "Username and password stored in environment variables.",
        "Single sign-on (SSO) with SAML.",
        "Key-pair authentication with an encrypted private key.",
        "OAuth with user consent flow.",
    ],
    [2],
    "Key-pair authentication is the recommended method for CI/CD pipelines. It avoids storing "
    "passwords, supports key rotation with two active keys, and doesn't require interactive login. "
    "SSO and OAuth with consent flows are interactive and unsuitable for automated pipelines.",
    difficulty="intermediate"
)

add_q(D6,
    "What is the purpose of CREATE GIT REPOSITORY in Snowflake?",
    [
        "It creates a local Git repository inside Snowflake for version control.",
        "It links an external Git repository so Snowflake can read files directly from it.",
        "It enables Snowflake to push changes back to a Git repository.",
        "It creates a backup of Snowflake objects in Git format.",
    ],
    [1],
    "CREATE GIT REPOSITORY links an external Git repository (GitHub, GitLab, etc.) to Snowflake. "
    "Files can then be referenced directly using stage notation: @my_repo/branches/main/path/file.sql. "
    "This is read-only -- Snowflake can fetch files but cannot push changes back.",
    difficulty="intermediate"
)

add_q(D6,
    "A data science team needs to run a custom PyTorch model with GPU support inside Snowflake. "
    "What should the Architect recommend?",
    [
        "Create a Python UDF with the model code.",
        "Use Snowpark Container Services (SPCS) with a GPU compute pool.",
        "Use a Snowpark-optimized warehouse.",
        "Deploy the model as an external function.",
    ],
    [1],
    "SPCS supports GPU compute pools for running containerized workloads. The team can containerize "
    "their PyTorch model as a Docker image, push it to Snowflake's image repository, create a GPU "
    "compute pool, and deploy the model as a service. Data never leaves Snowflake.",
    difficulty="advanced"
)

add_q(D6,
    "Which objects are involved in deploying a container service in SPCS? (Choose three.)",
    [
        "Compute pool",
        "Image repository",
        "Service specification (YAML)",
        "Virtual warehouse",
        "External function",
        "Network policy",
    ],
    [0, 1, 2],
    "SPCS requires: (1) an image repository to store Docker images, (2) a compute pool "
    "to provide nodes for running containers, and (3) a service specification in YAML format "
    "defining the container config. Virtual warehouses are not used by SPCS.",
    multi_select=True, difficulty="advanced"
)

add_q(D6,
    "How do Cortex LLM functions like SNOWFLAKE.CORTEX.COMPLETE() consume compute resources?",
    [
        "They run on the user's active warehouse.",
        "They run serverlessly -- no warehouse required, billed per token.",
        "They require a Snowpark-optimized warehouse.",
        "They require a dedicated SPCS compute pool.",
    ],
    [1],
    "Cortex LLM functions are serverless -- they do not require a running warehouse. "
    "They are billed per token (input + output tokens). This makes them simple to use but "
    "cost should be monitored for high-volume usage.",
    difficulty="intermediate"
)

add_q(D6,
    "What is the difference between Cortex LLM functions and Snowflake ML Functions?",
    [
        "Cortex functions are for text/language tasks; ML Functions are for structured data tasks like forecasting.",
        "They are the same thing with different names.",
        "Cortex functions require Python; ML Functions are SQL-only.",
        "ML Functions are deprecated in favor of Cortex functions.",
    ],
    [0],
    "Cortex LLM functions (COMPLETE, SUMMARIZE, SENTIMENT, etc.) handle text and language tasks. "
    "Snowflake ML Functions (FORECAST, ANOMALY_DETECTION, CLASSIFICATION) handle structured data tasks "
    "like time-series forecasting and anomaly detection. Both are accessible via SQL.",
    difficulty="intermediate"
)

add_q(D6,
    "Where do Streamlit in Snowflake (SiS) applications execute?",
    [
        "On an external server managed by Streamlit Cloud.",
        "On the user's local machine.",
        "Inside Snowflake on Snowflake-managed compute.",
        "On a customer-managed Kubernetes cluster.",
    ],
    [2],
    "Streamlit in Snowflake apps run entirely inside Snowflake's infrastructure. No external "
    "servers are needed. The app inherits Snowflake's RBAC model -- it runs with the current "
    "user's role and permissions.",
    difficulty="beginner"
)

add_q(D6,
    "What is the bronze layer in the medallion architecture?",
    [
        "Cleaned and deduplicated data ready for analysis.",
        "Raw data as ingested, with no transformations applied.",
        "Aggregated business-ready metrics and KPIs.",
        "A security layer that encrypts data at rest.",
    ],
    [1],
    "The bronze (raw/landing) layer stores data exactly as ingested -- no cleaning, no transformations. "
    "This preserves the original data for lineage and audit. Transformations happen in the silver layer.",
    difficulty="beginner"
)

add_q(D6,
    "An Architect is designing environment isolation for a Snowflake deployment. "
    "Which approach provides the STRONGEST security boundaries between dev and prod?",
    [
        "Separate schemas within the same database.",
        "Separate databases within the same account.",
        "Separate accounts within a Snowflake Organization.",
        "Separate roles with different object grants.",
    ],
    [2],
    "Separate accounts within a Snowflake Organization provide the strongest isolation. "
    "Each account has independent RBAC, network policies, and billing. A mistake in the dev "
    "account (like a bad GRANT) cannot affect production. Database-level isolation is good "
    "but still shares account-level settings.",
    difficulty="intermediate"
)

add_q(D6,
    "Which Snowflake feature allows an Application Package to be distributed to other accounts "
    "via the Marketplace?",
    [
        "Secure Data Sharing",
        "Database Replication",
        "Native App Framework",
        "Snowpipe Streaming",
    ],
    [2],
    "The Native App Framework allows providers to bundle code (procedures, UDFs, Streamlit), "
    "data, and configuration into an Application Package. This package can be published on the "
    "Marketplace for other accounts to install.",
    difficulty="intermediate"
)

add_q(D6,
    "What is the correct order for deploying a Docker container to SPCS?",
    [
        "Create service -> Push image -> Create compute pool",
        "Push image to image repository -> Create compute pool -> Create service",
        "Create compute pool -> Create service -> Push image",
        "Create service function -> Push image -> Start compute pool",
    ],
    [1],
    "The correct order is: (1) Push the Docker image to Snowflake's image repository, "
    "(2) Create a compute pool to provide infrastructure, (3) Create a service referencing "
    "the image and compute pool. The service specification (YAML) defines the configuration.",
    difficulty="intermediate"
)

add_q(D6,
    "A team uses dbt to transform data in Snowflake. In the medallion architecture, "
    "where do dbt staging models and mart models typically map?",
    [
        "Staging models = bronze, mart models = silver.",
        "Staging models = silver, mart models = gold.",
        "Staging models = gold, mart models = bronze.",
        "dbt does not follow medallion architecture patterns.",
    ],
    [1],
    "In dbt's convention: staging models clean and standardize raw data (silver/curated layer), "
    "and mart models create business-ready aggregations and fact/dimension tables (gold/consumption layer). "
    "The bronze layer is typically populated by ingestion tools (Snowpipe, COPY INTO) before dbt runs.",
    difficulty="intermediate"
)

add_q(D6,
    "What happens to privileges when you clone a database using CREATE DATABASE ... CLONE?",
    [
        "All privileges are cloned along with the objects.",
        "Privileges are NOT cloned by default; use COPY GRANTS to include them.",
        "Only OWNERSHIP privileges are cloned; other grants are dropped.",
        "Privileges are cloned but downgraded to read-only.",
    ],
    [1],
    "By default, privileges (grants) are NOT cloned. The cloned objects are owned by the role "
    "performing the clone. Use CREATE ... CLONE ... COPY GRANTS to carry over existing grants.",
    difficulty="intermediate"
)

add_q(D6,
    "A Snowflake Architect wants to enable external access from a Streamlit in Snowflake app "
    "to call a third-party REST API. What is required?",
    [
        "No special configuration -- SiS apps can access any URL.",
        "An external access integration that whitelists the API endpoint.",
        "A network policy allowing outbound traffic.",
        "An external function that proxies the API call.",
    ],
    [1],
    "Streamlit in Snowflake runs inside Snowflake's secure environment with no external access "
    "by default. To call external APIs, an external access integration must be created that "
    "explicitly whitelists the allowed endpoints.",
    difficulty="advanced"
)

add_q(D6,
    "What is the Snowflake Model Registry used for?",
    [
        "Tracking and versioning machine learning models deployed in Snowflake.",
        "Registering external data sources for ingestion.",
        "Cataloging all database objects in an account.",
        "Managing Docker images for SPCS.",
    ],
    [0],
    "The Model Registry provides versioning, metadata tracking, and deployment management for "
    "ML models. Models (scikit-learn, XGBoost, PyTorch, etc.) can be logged, versioned, and "
    "deployed as inference services within Snowflake.",
    difficulty="intermediate"
)

add_q(D6,
    "Which approach is recommended for rolling back a failed production deployment in Snowflake? "
    "(Choose two.)",
    [
        "Use ALTER DATABASE SWAP WITH to swap back to the previous version.",
        "Manually re-run the previous migration scripts.",
        "Use Time Travel to clone the database from before the deployment.",
        "Delete the account and recreate it.",
    ],
    [0, 2],
    "Two reliable rollback strategies: (1) ALTER DATABASE SWAP WITH reverses a blue/green deployment "
    "instantly. (2) Time Travel allows cloning a database from a point before the failed deployment. "
    "Both are fast and don't require re-running scripts.",
    multi_select=True, difficulty="advanced"
)

add_q(D6,
    "Are SPCS compute pools always running and incurring costs?",
    [
        "Yes, compute pools run continuously once created.",
        "No, compute pools can be suspended and resumed; costs only accrue when active.",
        "Compute pools auto-suspend after 5 minutes of inactivity.",
        "Compute pools are billed per container, not per pool.",
    ],
    [1],
    "SPCS compute pools can be explicitly suspended and resumed. You only pay when the compute "
    "pool is active. Unlike warehouses, they do not auto-suspend -- you must suspend them manually "
    "or via automation.",
    difficulty="intermediate"
)

# ═══════════════════════════════════════════════════════════════
# GAP TOPICS: Zero/Low coverage
# ═══════════════════════════════════════════════════════════════

# --- Hybrid Tables ---
add_q(D2,
    "What is the primary use case for Snowflake hybrid tables?",
    [
        "Long-running analytical queries on petabyte-scale data.",
        "Low-latency transactional (OLTP) workloads with single-row lookups.",
        "Storing semi-structured data like JSON and XML.",
        "Replacing external tables for data lake access.",
    ],
    [0],  # Actually [1] - fixing
    "Hybrid tables combine analytical and transactional capabilities. They use a row-store index "
    "for fast single-row lookups (OLTP-like performance) while still supporting analytical queries. "
    "They enforce primary keys and support row-level locking.",
    difficulty="advanced"
)
# Fix the correct index for the hybrid table question
new_qs[-1]["correct_indices"] = [1]

add_q(D2,
    "Which statements about hybrid tables are TRUE? (Choose two.)",
    [
        "Hybrid tables enforce primary keys.",
        "Hybrid tables do not support indexes.",
        "Hybrid tables support row-level locking for concurrent updates.",
        "Hybrid tables are only available on Standard edition.",
        "Hybrid tables replace regular tables for all use cases.",
    ],
    [0, 2],
    "Hybrid tables enforce primary keys (required at creation) and support row-level locking, "
    "enabling concurrent transactional workloads. They also maintain a row-store index for "
    "fast point lookups. They are not a replacement for regular tables in analytical workloads.",
    multi_select=True, difficulty="advanced"
)

# --- Data Clean Rooms ---
add_q(D2,
    "What is the primary purpose of Snowflake Data Clean Rooms?",
    [
        "Cleaning and deduplicating data before loading.",
        "Enabling secure multiparty computation where participants analyze combined data without seeing each other's raw records.",
        "Providing a sandbox environment for data exploration.",
        "Encrypting data at rest using customer-managed keys.",
    ],
    [1],
    "Data Clean Rooms enable two or more parties to run analyses on their combined datasets "
    "without either party seeing the other's raw data. Common use cases include audience overlap "
    "analysis, ad measurement, and collaborative analytics between companies.",
    difficulty="advanced"
)

# --- Native Apps ---
add_q(D5,
    "What is the relationship between an Application Package and a Native App?",
    [
        "An Application Package is the distributable artifact; a Native App is the installed instance in the consumer's account.",
        "They are the same thing -- the terms are interchangeable.",
        "A Native App contains multiple Application Packages.",
        "An Application Package is for free listings; a Native App is for paid listings.",
    ],
    [0],
    "An Application Package is the provider-side artifact that bundles code, data, and configuration. "
    "When a consumer installs it, they get a Native App (application object) in their account. "
    "The package is the blueprint; the app is the running instance.",
    difficulty="advanced"
)

# --- DAGs / Task Trees ---
add_q(D3,
    "How are task dependencies (DAGs) defined in Snowflake?",
    [
        "Using a separate DAG object: CREATE DAG.",
        "Using the AFTER clause in CREATE TASK to define parent-child relationships.",
        "Using a JSON configuration file uploaded to a stage.",
        "Tasks cannot have dependencies -- they run independently.",
    ],
    [1],
    "Task trees (DAGs) are created by defining parent-child relationships using the AFTER clause. "
    "A child task runs only after its parent task completes successfully. "
    "Example: CREATE TASK child_task ... AFTER parent_task AS ...",
    difficulty="intermediate"
)

add_q(D3,
    "In a task tree, what happens if a parent task fails?",
    [
        "Child tasks run anyway with the data available.",
        "Child tasks are skipped and marked as failed.",
        "Child tasks wait indefinitely for the parent to succeed.",
        "The entire task tree is automatically retried from the root.",
    ],
    [1],
    "When a parent task in a task tree fails, all downstream child tasks are automatically "
    "skipped. They do not execute. The task tree must be manually restarted or the root task "
    "must succeed on its next scheduled run for children to execute.",
    difficulty="intermediate"
)

# --- Key Rotation ---
add_q(D1,
    "A company uses key-pair authentication for a service account. How should they rotate "
    "the RSA key pair without downtime?",
    [
        "Generate a new key pair and immediately replace the old one using ALTER USER ... SET RSA_PUBLIC_KEY.",
        "Set the new key as RSA_PUBLIC_KEY_2, update the service to use the new private key, then remove the old RSA_PUBLIC_KEY.",
        "Temporarily switch to password authentication during rotation.",
        "Key rotation is not supported -- a new user must be created.",
    ],
    [1],
    "Snowflake supports two active RSA public keys (RSA_PUBLIC_KEY and RSA_PUBLIC_KEY_2) "
    "for zero-downtime key rotation. Set the new key as the secondary key, update the client "
    "to use the new private key, verify it works, then remove the old primary key.",
    difficulty="advanced"
)

# --- Failback ---
add_q(D2,
    "After a failover event promotes a secondary account to primary, what is the process "
    "to restore the original primary account?",
    [
        "The original primary automatically becomes secondary and can be promoted back.",
        "Failback requires recreating the replication group from scratch.",
        "The administrator must reverse the replication direction and then promote the original primary.",
        "Failback is not possible -- the failover is permanent.",
    ],
    [2],
    "Failback (restoring the original primary) requires the administrator to refresh and reverse "
    "the replication direction so the new primary replicates to the original account. Once caught up, "
    "the original account can be promoted back to primary. This is a manual, deliberate process.",
    difficulty="advanced"
)

add_q(D2,
    "What is the difference between failover groups and database replication?",
    [
        "Failover groups replicate databases only; database replication handles all object types.",
        "Failover groups bundle multiple object types (databases, shares, roles, etc.) for coordinated failover; database replication only handles individual databases.",
        "They are identical features with different names.",
        "Database replication is for cross-region; failover groups are for same-region only.",
    ],
    [1],
    "Failover groups can bundle databases, shares, network policies, parameters, and other objects "
    "into a single unit for coordinated failover. Database replication only replicates individual "
    "databases. Failover groups ensure all related objects fail over together consistently.",
    difficulty="advanced"
)

# --- Dynamic Tables ---
add_q(D3,
    "When should an Architect recommend dynamic tables over streams and tasks?",
    [
        "When the pipeline requires complex procedural logic with IF/ELSE branching.",
        "When the pipeline is a declarative SQL transformation that should auto-refresh on a schedule.",
        "When sub-second latency is required.",
        "When the pipeline needs to call external functions.",
    ],
    [1],
    "Dynamic tables are ideal for declarative SQL pipelines where you define the desired result "
    "and Snowflake handles refresh scheduling via TARGET_LAG. Streams + tasks are better for "
    "procedural logic, complex branching, or when you need fine-grained control over execution.",
    difficulty="intermediate"
)

add_q(D3,
    "What does the TARGET_LAG parameter control in a dynamic table?",
    [
        "The maximum acceptable staleness of the data in the dynamic table.",
        "The maximum execution time before the refresh is cancelled.",
        "The network latency threshold for cross-region queries.",
        "The time delay before the dynamic table is created.",
    ],
    [0],
    "TARGET_LAG defines the maximum acceptable freshness lag. For example, TARGET_LAG = '10 minutes' "
    "means Snowflake ensures the dynamic table is never more than 10 minutes behind its source data. "
    "Snowflake automatically schedules incremental refreshes to meet this target.",
    difficulty="intermediate"
)

# --- Iceberg Tables ---
add_q(D3,
    "What are the two management modes for Apache Iceberg tables in Snowflake?",
    [
        "Internal mode and external mode.",
        "Snowflake-managed and externally-managed catalog.",
        "Read-only mode and read-write mode.",
        "Shared mode and private mode.",
    ],
    [1],
    "Iceberg tables in Snowflake can be Snowflake-managed (Snowflake manages the Iceberg catalog "
    "and metadata) or externally-managed (an external catalog like AWS Glue or a REST catalog "
    "manages the metadata). Snowflake-managed gives full DML; externally-managed is read-only.",
    difficulty="advanced"
)

add_q(D3,
    "What is a key advantage of using Snowflake-managed Iceberg tables over regular Snowflake tables?",
    [
        "They are faster for analytical queries.",
        "They store data in open Apache Iceberg format, enabling interoperability with other engines.",
        "They support Time Travel for longer periods.",
        "They automatically cluster data without explicit clustering keys.",
    ],
    [1],
    "Snowflake-managed Iceberg tables store data in the open Apache Iceberg format (Parquet files). "
    "This means external engines (Spark, Trino, Presto) can also read the data, enabling "
    "interoperability. Regular Snowflake tables use a proprietary format.",
    difficulty="advanced"
)

# --- Query Acceleration Service (QAS) ---
add_q(D4,
    "What type of queries benefit MOST from the Query Acceleration Service (QAS)?",
    [
        "Simple single-table scans with tight filters.",
        "Queries with large scans that disproportionately impact overall warehouse performance (outlier queries).",
        "DDL operations like CREATE TABLE and ALTER TABLE.",
        "All queries benefit equally from QAS.",
    ],
    [1],
    "QAS targets outlier queries -- queries that scan significantly more data than typical queries "
    "in the workload. It offloads portions of these queries to shared compute resources, reducing "
    "their impact on the warehouse. It's most effective for exploratory or ad-hoc heavy queries.",
    difficulty="advanced"
)

add_q(D4,
    "How does the Query Acceleration Service differ from multi-cluster warehouses?",
    [
        "QAS adds more warehouses; multi-cluster adds more compute within a warehouse.",
        "QAS offloads portions of individual heavy queries; multi-cluster adds clusters for concurrent query capacity.",
        "There is no difference -- they solve the same problem.",
        "QAS is for small warehouses; multi-cluster is for large warehouses.",
    ],
    [1],
    "QAS helps individual heavy queries by offloading scan-intensive portions to shared compute. "
    "Multi-cluster warehouses add entire clusters to handle more concurrent queries. "
    "QAS addresses query-level outliers; multi-cluster addresses workload-level concurrency.",
    difficulty="advanced"
)

# --- PrivateLink ---
add_q(D1,
    "What is the purpose of AWS PrivateLink / Azure Private Link with Snowflake?",
    [
        "Encrypting data in transit between the client and Snowflake.",
        "Routing traffic between the client and Snowflake over a private network path, avoiding the public internet.",
        "Enabling Snowflake to access data in private S3 buckets.",
        "Creating VPN tunnels between on-premises networks and Snowflake.",
    ],
    [1],
    "PrivateLink creates a private network endpoint so traffic between the client and Snowflake "
    "never traverses the public internet. This is a network security feature required by many "
    "compliance frameworks. It requires Business Critical edition or higher.",
    difficulty="intermediate"
)

add_q(D1,
    "Which Snowflake edition is required to use PrivateLink connectivity?",
    [
        "Standard",
        "Enterprise",
        "Business Critical",
        "Virtual Private Snowflake (VPS)",
    ],
    [2],
    "Business Critical edition (or higher) is required for PrivateLink. This edition also provides "
    "Tri-Secret Secure encryption and HIPAA/PCI compliance support. Standard and Enterprise "
    "do not support PrivateLink.",
    difficulty="intermediate"
)

# --- Resource Monitors ---
add_q(D4,
    "What do Snowflake resource monitors track?",
    [
        "Query execution time and rows processed.",
        "Credit consumption by warehouses.",
        "Storage usage in bytes.",
        "Network bandwidth consumption.",
    ],
    [1],
    "Resource monitors track credit consumption. They can be set at the account level or "
    "assigned to specific warehouses. When credit usage reaches defined thresholds, they can "
    "send notifications, suspend the warehouse, or suspend immediately (killing running queries).",
    difficulty="intermediate"
)

add_q(D4,
    "At which levels can resource monitors be applied? (Choose two.)",
    [
        "Account level",
        "Database level",
        "Warehouse level",
        "Schema level",
        "User level",
    ],
    [0, 2],
    "Resource monitors can be applied at the account level (monitoring all credit usage) or "
    "at the warehouse level (monitoring specific warehouse credit usage). They cannot be applied "
    "at the database, schema, or user level.",
    multi_select=True, difficulty="intermediate"
)

# --- Client Redirect ---
add_q(D2,
    "What is the purpose of client redirect in Snowflake?",
    [
        "Redirecting HTTP API calls to a different endpoint.",
        "Automatically redirecting client connections from a failed primary to a secondary account.",
        "Redirecting query results to a different table.",
        "Routing clients to the nearest regional endpoint for lower latency.",
    ],
    [1],
    "Client redirect enables automatic failover of client connections. When configured, "
    "if the primary account becomes unavailable, client connections are automatically redirected "
    "to the promoted secondary account using a connection URL that resolves dynamically.",
    difficulty="advanced"
)

# --- SCIM ---
add_q(D1,
    "What role is required to configure SCIM integration with an identity provider?",
    [
        "ACCOUNTADMIN",
        "SYSADMIN",
        "SECURITYADMIN",
        "USERADMIN",
    ],
    [2],  # SECURITYADMIN for SCIM network policy; actually a SCIM-specific role owns the integration
    "SCIM provisioning requires the SECURITYADMIN role (or a custom role with the necessary privileges). "
    "SCIM integrations manage users and roles, which are security operations. The SCIM integration "
    "is typically owned by SECURITYADMIN or a dedicated SCIM role.",
    difficulty="intermediate"
)

add_q(D1,
    "What does SCIM automate in Snowflake? (Choose two.)",
    [
        "Warehouse scaling policies.",
        "User provisioning and deprovisioning.",
        "Group membership synchronization as Snowflake roles.",
        "Data encryption key management.",
        "Query optimization.",
    ],
    [1, 2],
    "SCIM (System for Cross-domain Identity Management) automates user lifecycle management: "
    "creating users when they join, deactivating when they leave, and synchronizing identity "
    "provider group memberships as Snowflake roles. It works with Okta, Azure AD, and other IdPs.",
    multi_select=True, difficulty="intermediate"
)

# ═══════════════════════════════════════════════════════════════
# DOMAIN 1 REINFORCEMENT (~15 more questions)
# ═══════════════════════════════════════════════════════════════

add_q(D1,
    "What is Tri-Secret Secure encryption in Snowflake?",
    [
        "A three-layer encryption using AES-128, AES-192, and AES-256.",
        "A combination of a customer-managed key, a Snowflake-managed key, and a composite master key.",
        "Three separate encryption keys for data at rest, in transit, and in use.",
        "Encryption that requires three different administrators to approve.",
    ],
    [1],
    "Tri-Secret Secure combines a customer-managed key (from the customer's cloud KMS) with "
    "a Snowflake-managed key to create a composite master key. If either key is revoked, the data "
    "becomes inaccessible. Requires Business Critical edition or higher.",
    difficulty="advanced"
)

add_q(D1,
    "A company's security team wants to ensure that if they revoke their encryption key, "
    "Snowflake can no longer access their data. Which feature provides this capability?",
    [
        "Column-level encryption.",
        "Tri-Secret Secure with a customer-managed key.",
        "Network policies with IP allowlisting.",
        "Masking policies on sensitive columns.",
    ],
    [1],
    "Tri-Secret Secure ensures that revoking the customer-managed key renders data inaccessible "
    "to both Snowflake and the customer. This is the highest level of encryption control, "
    "providing customer-controlled data sovereignty.",
    difficulty="advanced"
)

add_q(D1,
    "Which Snowflake edition is required for masking policies?",
    [
        "Standard",
        "Enterprise",
        "Business Critical",
        "All editions support masking policies.",
    ],
    [1],
    "Dynamic data masking requires Enterprise edition or higher. Standard edition does not support "
    "masking policies. Business Critical and VPS also support masking but Enterprise is the minimum.",
    difficulty="beginner"
)

add_q(D1,
    "A user-level network policy and an account-level network policy are both configured. "
    "A user has both policies applicable. Which policy takes effect?",
    [
        "The account-level policy takes precedence.",
        "The user-level policy replaces the account-level policy for that user.",
        "Both policies are combined (union of allowed IPs).",
        "Both policies are combined (intersection of allowed IPs).",
    ],
    [1],
    "A user-level network policy completely replaces the account-level network policy for that user. "
    "It is NOT additive. The user-level policy is the only one evaluated for users who have one assigned.",
    difficulty="advanced"
)

add_q(D1,
    "What is the parameter MIN_DATA_RETENTION_TIME_IN_DAYS used for?",
    [
        "Setting the maximum Time Travel retention at the account level.",
        "Setting a floor for Time Travel retention that no object in the account can go below.",
        "Setting the minimum Fail-safe retention period.",
        "Setting the minimum data retention for shares.",
    ],
    [1],
    "MIN_DATA_RETENTION_TIME_IN_DAYS is an account-level parameter that sets a floor. "
    "No database, schema, or table in the account can have a DATA_RETENTION_TIME_IN_DAYS "
    "value lower than this minimum. It prevents users from setting Time Travel to 0.",
    difficulty="advanced"
)

add_q(D1,
    "What is the precedence order for Snowflake parameters?",
    [
        "Account > Object > Session (account always wins).",
        "Session > Object > Account (most specific wins).",
        "All levels have equal precedence.",
        "Object > Session > Account.",
    ],
    [1],
    "The most specific parameter wins: Session overrides Object, which overrides Account. "
    "For example, if a user sets STATEMENT_TIMEOUT_IN_SECONDS at the session level, it overrides "
    "the account-level and warehouse-level settings for that session.",
    difficulty="intermediate"
)

add_q(D1,
    "An organization operates in the EU with strict GDPR requirements. Customer data must "
    "never leave EU soil. How should the Architect configure the Snowflake deployment?",
    [
        "Use a single US account with row access policies filtering EU data.",
        "Deploy a Snowflake account in an EU cloud region within a Snowflake Organization.",
        "Use data masking to hide location information from non-EU users.",
        "Encrypt EU data with a customer-managed key stored in Europe.",
    ],
    [1],
    "GDPR data residency requires that EU customer data physically resides in EU infrastructure. "
    "Deploying a Snowflake account in an EU cloud region (e.g., AWS eu-central-1) within a "
    "Snowflake Organization ensures data stays in Europe while allowing org-level management.",
    difficulty="intermediate"
)

add_q(D1,
    "What is the purpose of REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION?",
    [
        "Requiring encryption for all external stages.",
        "Forcing the use of storage integrations (instead of raw credentials) when creating external stages.",
        "Requiring ACCOUNTADMIN to approve all stage creation.",
        "Limiting stage creation to internal stages only.",
    ],
    [1],
    "This account-level parameter prevents users from creating external stages with embedded "
    "credentials (access keys, secret keys). It forces the use of storage integrations, which "
    "use IAM roles and centralize credential management. This is a security hardening best practice.",
    difficulty="advanced"
)

add_q(D1,
    "What authentication mechanism does Snowflake use for SAML-based federated authentication?",
    [
        "The identity provider sends a SAML assertion to Snowflake, which validates it and creates a session.",
        "Snowflake sends credentials to the identity provider for validation.",
        "Both parties exchange OAuth tokens.",
        "Snowflake stores the IdP's password hash for comparison.",
    ],
    [0],
    "In SAML-based SSO, the identity provider authenticates the user and sends a signed SAML "
    "assertion to Snowflake. Snowflake validates the assertion's signature using the IdP's "
    "certificate and creates a session. Snowflake never sees the user's password.",
    difficulty="intermediate"
)

add_q(D1,
    "What is a managed access schema?",
    [
        "A schema where only ACCOUNTADMIN can create objects.",
        "A schema where the schema owner (or MANAGE GRANTS holder) controls all grants, not individual object owners.",
        "A schema that automatically applies masking policies to all tables.",
        "A schema that restricts access to read-only.",
    ],
    [1],
    "In a managed access schema, individual object owners cannot grant access to their objects. "
    "Only the schema owner or a role with MANAGE GRANTS can issue grants. This prevents "
    "privilege escalation where individual developers grant unauthorized access.",
    difficulty="intermediate"
)

add_q(D1,
    "What happens when ALLOW_CLIENT_MFA_CACHING is enabled at the account level?",
    [
        "MFA is disabled for all client connections.",
        "MFA tokens are cached so users don't need to re-authenticate with MFA for every session.",
        "Client applications can bypass MFA entirely.",
        "MFA prompts are cached in the browser for 30 days.",
    ],
    [1],
    "ALLOW_CLIENT_MFA_CACHING allows MFA tokens to be cached on the client, reducing the "
    "frequency of MFA prompts. This is especially useful for tools like DBeaver or other JDBC "
    "clients that would otherwise prompt for MFA on every connection.",
    difficulty="advanced"
)

add_q(D1,
    "How many masking policies can be applied to a single column?",
    [
        "Unlimited -- policies are evaluated in order.",
        "Exactly one masking policy per column.",
        "Up to three masking policies per column.",
        "One per role -- each role sees a different policy.",
    ],
    [1],
    "Only ONE masking policy can be applied to a single column at any time. The policy itself "
    "can contain conditional logic (CASE statements using CURRENT_ROLE() or IS_ROLE_IN_SESSION()) "
    "to return different masked values for different roles.",
    difficulty="intermediate"
)

add_q(D1,
    "What is the difference between ACCOUNT_USAGE and INFORMATION_SCHEMA for monitoring?",
    [
        "ACCOUNT_USAGE has real-time data; INFORMATION_SCHEMA has delayed data.",
        "ACCOUNT_USAGE has 45min-3h latency with 365-day retention; INFORMATION_SCHEMA has real-time data with 7-day to 6-month retention.",
        "They contain identical data with the same latency.",
        "ACCOUNT_USAGE is for storage monitoring; INFORMATION_SCHEMA is for compute monitoring.",
    ],
    [1],
    "ACCOUNT_USAGE (in the SNOWFLAKE shared database) has a 45-minute to 3-hour latency but retains "
    "data for 365 days. INFORMATION_SCHEMA provides real-time data but with shorter retention "
    "(7 days to 6 months depending on the view). Use ACCOUNT_USAGE for historical analysis.",
    difficulty="intermediate"
)

# ═══════════════════════════════════════════════════════════════
# WRITE
# ═══════════════════════════════════════════════════════════════

print(f"Generated {len(new_qs)} new questions")
from collections import Counter
domain_dist = Counter(q["domain"] for q in new_qs)
print("New question distribution:")
for d, c in sorted(domain_dist.items()):
    print(f"  {d}: {c}")

all_qs = existing + new_qs
print(f"\nTotal questions: {len(existing)} existing + {len(new_qs)} new = {len(all_qs)}")

with open(QF, "w") as f:
    json.dump(all_qs, f, indent=2, ensure_ascii=False)

# Verify
with open(QF) as f:
    verify = json.load(f)

domain_totals = Counter(q["domain"] for q in verify)
print(f"\nFinal domain distribution:")
for d, c in sorted(domain_totals.items()):
    print(f"  {d}: {c}")
print(f"\nTotal: {len(verify)}")

# Check for broken multi-select
broken = [q for q in verify if q.get("multi_select") and len(q["correct_indices"]) != q.get("multi_select_count", 1)]
print(f"\nBroken multi-select: {len(broken)}")

# Check for duplicate IDs
ids = [q["id"] for q in verify]
dupes = [i for i in ids if ids.count(i) > 1]
print(f"Duplicate IDs: {len(set(dupes))}")
