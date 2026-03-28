# Domain 6: DevOps & Ecosystem — Dev Lifecycle, Workloads, CI/CD, Tools

> **ARA-C01 Weight:** ~10-15% of the exam.
> Focus on: environment patterns, CI/CD with Snowflake, SPCS, AI/ML features, and architectural layers.

---

## 6.1 DEVELOPMENT LIFECYCLE

How to structure environments and promote changes safely.

### Key Concepts

**Environment tiers:**

| Environment | Purpose | Data | Access |
|-------------|---------|------|--------|
| **Production** | Live workloads, real users | Full production data | Restricted, audited |
| **Staging/QA** | Pre-production testing | Copy or subset of prod data | Test team |
| **Development** | Feature building | Synthetic or cloned data | Developers |
| **Sandbox** | Experimentation | Any data | Individual devs |

**Snowflake approach — database-level isolation:**

- Each environment = separate database (e.g., `PROD_DB`, `STAGING_DB`, `DEV_DB`)
- Use **zero-copy clones** to create dev/staging from prod — instant, no extra storage (until data diverges)
- Clones for testing: `CREATE DATABASE staging_db CLONE prod_db;`

**Zones/layers pattern:**

- **Raw/Landing zone** — data as ingested (Snowpipe, COPY INTO)
- **Transform zone** — cleaned, joined, business logic applied
- **Consumption zone** — curated datasets for BI, ML, sharing
- Each zone = separate schema or database for access control clarity

**Object tagging and environment management:**

- Use tags to identify environment: `ALTER TABLE t SET TAG env = 'prod'`
- Use roles to enforce access boundaries between environments
- `ACCOUNTADMIN` should never be used for daily dev work

### Why This Matters

A data engineer accidentally runs a DELETE on a production table during development. With proper environment isolation (separate databases + role restrictions), this is impossible. Without it, one mistake = outage.

### Best Practices

- **Clone production weekly** for staging — keeps test data realistic
- Use separate roles per environment: `DEV_ROLE`, `STAGING_ROLE`, `PROD_ROLE`
- Never grant `DEV_ROLE` write access to production databases
- Use `EXECUTE AS CALLER` vs. `EXECUTE AS OWNER` deliberately in procedures
- Implement a promotion workflow: dev → staging → prod (never skip staging)

**Exam traps:**

- Exam trap: IF YOU SEE "Clones double your storage cost" → WRONG because clones are **zero-copy** initially; you only pay for divergent data
- Exam trap: IF YOU SEE "All environments should use the same database with schema separation" → WRONG because **database-level** isolation provides stronger security boundaries than schemas alone
- Exam trap: IF YOU SEE "Sandbox environments should use production data directly" → WRONG because sandboxes should use **cloned or synthetic** data for safety and compliance

### Common Questions (FAQ)

**Q: Can I clone a share (shared database)?**
A: No. Shared databases cannot be cloned. Clone the source database in the provider account instead.

**Q: Do clones inherit grants?**
A: No by default. Use `CREATE ... CLONE ... COPY GRANTS` to carry over permissions.

---

## 6.2 CI/CD & DEPLOYMENT

Automating Snowflake deployments with modern DevOps practices.

### Key Concepts

**Snowflake CLI (`snow`):**

- Official command-line tool for Snowflake
- Commands: `snow sql`, `snow stage`, `snow connection`, `snow app`, `snow notebook`
- Used in CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins, Azure DevOps)
- Config file: `connections.toml` (stores connection profiles)

**Git integration:**

- Snowflake supports **Git repositories** as first-class objects
- `CREATE GIT REPOSITORY` — links a remote Git repo to Snowflake
- Fetch files directly: `SELECT * FROM @my_repo/branches/main/path/to/file`
- Use for versioned SQL scripts, stored procedure code, UDF source code
- Supports: GitHub, GitLab, Bitbucket, Azure DevOps

**Deployment patterns:**

| Pattern | Description | Best For |
|---------|-------------|----------|
| **Schema migration** | Sequential numbered scripts (V1, V2, V3...) | DDL changes, schema evolution |
| **State-based** | Desired state defined, tool generates diff | Declarative approaches |
| **Blue/green** | Two production copies, switch via SWAP | Zero-downtime deployments |

**Blue/green with `ALTER DATABASE ... SWAP WITH`:**

```sql
-- Deploy new version to BLUE
-- Test BLUE
ALTER DATABASE PROD_DB SWAP WITH BLUE_DB;
-- PROD_DB now has new version, BLUE_DB has the old (for rollback)
```

**Rollback strategies:**

- `UNDROP` — recovers dropped objects within retention period
- `TIME TRAVEL` — query or clone from a point in the past
- `SWAP` — swap back to previous blue/green database
- Keep migration scripts idempotent (`CREATE OR REPLACE`, `IF NOT EXISTS`)

### Why This Matters

A team deploys a broken stored procedure to production at 3 AM. With proper CI/CD: the pipeline ran tests in staging, the deployment was blue/green, and rolling back is one SWAP command. Without CI/CD: manual hotfix, extended outage, and angry stakeholders.

### Best Practices

- Store all DDL/DML in Git — no manual changes in production
- Use `CREATE OR REPLACE` over `CREATE ... IF NOT EXISTS` + `ALTER` when possible
- Run `snow sql -f migration.sql` in CI/CD pipelines
- Test migrations against a **clone of production** before deploying
- Use key-pair authentication (not passwords) in CI/CD pipelines
- Tag deployments: `ALTER SCHEMA SET TAG deployment_version = 'v2.3.1'`

**Exam traps:**

- Exam trap: IF YOU SEE "Snowflake has no native Git integration" → WRONG because Snowflake supports `CREATE GIT REPOSITORY` for direct Git repo integration
- Exam trap: IF YOU SEE "Blue/green requires two separate accounts" → WRONG because blue/green uses two **databases** in the same account, swapped with `ALTER DATABASE SWAP WITH`
- Exam trap: IF YOU SEE "Time Travel can only be used for queries, not rollbacks" → WRONG because you can `CREATE TABLE ... CLONE ... AT(TIMESTAMP => ...)` to restore a table from a previous point

### Common Questions (FAQ)

**Q: What authentication works best for CI/CD pipelines?**
A: **Key-pair authentication** — no passwords in pipeline configs, supports rotation, and is more secure than username/password.

**Q: Can Git repositories in Snowflake trigger pipelines?**
A: Not directly. Use your Git platform's CI/CD (GitHub Actions, etc.) to trigger deployments. Snowflake Git repos are for reading files, not pipeline orchestration.

---

## 6.3 SNOWPARK CONTAINER SERVICES (SPCS)

Run **custom containers** (Docker) inside Snowflake's managed infrastructure.

### Key Concepts

**What SPCS provides:**

- Fully managed container runtime inside Snowflake
- Run any Docker image — not limited to SQL/Python UDFs
- Supports: GPUs, networking between services, persistent storage via volumes
- Data **never leaves Snowflake** — container runs in the same cloud/region

**Key objects:**

| Object | Purpose |
|--------|---------|
| **Compute Pool** | Managed cluster of nodes (CPU/GPU) for running containers |
| **Image Repository** | Snowflake-hosted Docker registry for your images |
| **Service** | Running container(s) with defined spec (YAML) |
| **Service Function** | SQL function that calls a running service |
| **Ingress** | Public endpoint for exposing a service externally |

**Workflow:**

1. Push Docker image to Snowflake's image repository
2. Create a compute pool (`CREATE COMPUTE POOL`)
3. Create a service with a YAML spec defining containers, resources, endpoints
4. Access via service functions (SQL), ingress (HTTP), or service-to-service networking

**Service specification (YAML) includes:**

- Container image reference
- Resource limits (CPU, memory, GPU)
- Endpoints (ports)
- Volume mounts
- Environment variables
- Secrets (for external API keys, etc.)

### Why This Matters

A data science team has a custom PyTorch model that can't run as a UDF (it needs GPU, custom C++ libraries, and 32 GB RAM). SPCS lets them containerize it, deploy inside Snowflake, and call it from SQL — no data egress, no external infrastructure to manage.

### Best Practices

- Use **Snowpark-optimized warehouses** for memory-intensive SPCS workloads
- Keep container images minimal — faster startup, less storage cost
- Use **service functions** to integrate containers with SQL workflows
- Monitor compute pool usage — suspend when not needed
- Use Snowflake secrets for credentials — never hardcode API keys in images

**Exam traps:**

- Exam trap: IF YOU SEE "SPCS requires you to manage Kubernetes clusters" → WRONG because SPCS is **fully managed** — you define compute pools and services, Snowflake handles orchestration
- Exam trap: IF YOU SEE "SPCS containers can only use CPU" → WRONG because SPCS supports **GPU** compute pools (for ML inference, training, etc.)
- Exam trap: IF YOU SEE "Data must be exported from Snowflake to use SPCS" → WRONG because SPCS runs **inside** Snowflake — data stays within the platform
- Exam trap: IF YOU SEE "SPCS is the same as external functions" → WRONG because external functions call **outside** APIs; SPCS runs containers **inside** Snowflake

### Common Questions (FAQ)

**Q: Can SPCS services communicate with each other?**
A: Yes. Services in the same account can communicate via service-to-service networking using DNS names.

**Q: Are SPCS compute pools always running?**
A: No. Compute pools can be suspended and resumed. You pay only when they're active.

---

## 6.4 AI/ML IN SNOWFLAKE

Snowflake's native AI and machine learning capabilities.

### Key Concepts

**Cortex LLM Functions (Serverless):**

| Function | Purpose |
|----------|---------|
| `SNOWFLAKE.CORTEX.COMPLETE()` | Text generation / completion with LLMs |
| `SNOWFLAKE.CORTEX.SUMMARIZE()` | Text summarization |
| `SNOWFLAKE.CORTEX.SENTIMENT()` | Sentiment analysis (-1 to 1) |
| `SNOWFLAKE.CORTEX.TRANSLATE()` | Language translation |
| `SNOWFLAKE.CORTEX.EXTRACT_ANSWER()` | Q&A from text |
| `SNOWFLAKE.CORTEX.EMBED_TEXT_768()` | Text embeddings (768-dim) |
| `SNOWFLAKE.CORTEX.EMBED_TEXT_1024()` | Text embeddings (1024-dim) |

- All run **serverlessly** — no warehouse needed (billed per token/call)
- Data stays in Snowflake — LLMs run on Snowflake's infrastructure
- Support various models: Llama, Mistral, others (Snowflake-hosted)

**Snowflake ML (formerly Snowpark ML):**

- **ML Functions (SQL-based):** `FORECAST()`, `ANOMALY_DETECTION()`, `CONTRIBUTION_EXPLORER()`, `CLASSIFICATION()`
- These are **automated ML** — no coding required, SQL interface
- Trained on Snowflake compute (serverless or warehouse-based)

**Snowflake ML Python API:**

- `snowflake.ml.modeling` — scikit-learn-compatible API that runs on Snowflake compute
- **Model Registry** — version, deploy, and manage models
- **Feature Store** — centralized feature engineering and sharing
- Models can be deployed as **model services** (container-based inference)

**Cortex Search:**

- Hybrid search (vector + keyword) over text data
- Create a search service: `CREATE CORTEX SEARCH SERVICE`
- Useful for RAG (Retrieval-Augmented Generation) pipelines

### Why This Matters

A retail company wants to classify customer feedback sentiment, forecast next month's sales, and build a chatbot — all without moving data out of Snowflake. Cortex functions handle sentiment and the chatbot. ML Functions handle forecasting. The model registry tracks all model versions.

### Best Practices

- Use **Cortex LLM functions** for text tasks — avoid building custom NLP pipelines
- Use **ML Functions** for time-series forecasting and anomaly detection before reaching for custom models
- Register all models in the **Model Registry** for reproducibility and governance
- Use **Feature Store** to share feature engineering across teams
- For custom models (PyTorch, TensorFlow): use SPCS with GPU compute pools

**Exam traps:**

- Exam trap: IF YOU SEE "Cortex LLM functions require a running warehouse" → WRONG because Cortex LLM functions are **serverless** — no warehouse needed
- Exam trap: IF YOU SEE "Snowflake ML only supports Python" → WRONG because ML Functions like `FORECAST()` and `ANOMALY_DETECTION()` are accessible via **SQL** — no Python required
- Exam trap: IF YOU SEE "You must export data to train ML models" → WRONG because Snowflake ML training runs **inside Snowflake** on Snowflake compute

### Common Questions (FAQ)

**Q: Can I bring my own ML model to Snowflake?**
A: Yes. Use the Model Registry to log models (scikit-learn, XGBoost, PyTorch, etc.) and deploy them as model services.

**Q: What's the difference between Cortex LLM functions and ML Functions?**
A: Cortex LLM functions are for **text/language** tasks (completion, sentiment, etc.). ML Functions are for **structured data** tasks (forecasting, anomaly detection, classification).

---

## 6.5 STREAMLIT & NATIVE APPS

Building interactive applications inside Snowflake.

### Key Concepts

**Streamlit in Snowflake (SiS):**

- Build Python-based web apps that run **inside Snowflake**
- No external infrastructure — the app runs on Snowflake compute
- Direct access to Snowflake data via the session — no connectors or credentials
- Supports: charts, tables, forms, file uploads, custom components
- Access controlled by Snowflake RBAC (roles, grants)
- Deployed via Snowsight UI or Snowflake CLI

**Key SiS patterns:**

- `st.connection("snowflake")` — get a Snowflake session
- `session.sql("SELECT ...")` — run queries and display results
- `st.dataframe()` — render DataFrames
- `st.cache_data` — cache query results for performance

**Native App Framework (for distribution):**

- Bundle Streamlit apps + procedures + data into an **Application Package**
- Distribute via Marketplace or direct share
- Consumer installs → gets a full app experience (UI + logic + data)
- Provider can include setup scripts, version management, upgrade paths

**When to use Streamlit vs. Native Apps:**

| Use Case | Tool |
|----------|------|
| Internal dashboard for your team | Streamlit in Snowflake |
| Admin tool for data ops | Streamlit in Snowflake |
| Product you sell to other Snowflake accounts | Native App (with Streamlit inside) |
| Partner integration with code + data | Native App |

### Why This Matters

The analytics team needs a self-service tool for marketing to explore campaign performance. Instead of building a React app with API layers and authentication, they write a 100-line Streamlit app inside Snowflake. It's live in hours, inherits Snowflake RBAC, and costs nothing extra beyond warehouse compute.

### Best Practices

- Use `st.cache_data` aggressively to avoid redundant queries
- Design Streamlit apps for the warehouse they'll use — keep queries efficient
- For Native Apps: version everything, use `manifest.yml` for metadata
- Test Native Apps in a dev application package before publishing
- Use Streamlit for prototyping before investing in full frontend apps

**Exam traps:**

- Exam trap: IF YOU SEE "Streamlit in Snowflake requires an external server" → WRONG because SiS runs **entirely within Snowflake** — no external hosting needed
- Exam trap: IF YOU SEE "Streamlit apps bypass Snowflake access control" → WRONG because SiS apps inherit **Snowflake RBAC** — the app runs with the user's role
- Exam trap: IF YOU SEE "Native Apps are only for data sharing" → WRONG because Native Apps can include **code, UI (Streamlit), procedures, and data** — they're full applications

### Common Questions (FAQ)

**Q: Can Streamlit apps access external APIs?**
A: Yes, via **external access integrations** that whitelist specific endpoints.

**Q: Who pays for Streamlit app compute?**
A: The account running the app pays — the app uses a Snowflake warehouse for computation.

---

## 6.6 DATA WAREHOUSE LAYERS

Architectural patterns for organizing data within Snowflake.

### Key Concepts

**Medallion Architecture (Bronze / Silver / Gold):**

| Layer | Also Called | Purpose | Data Quality |
|-------|-----------|---------|-------------|
| **Bronze** | Raw, Landing | Ingested data as-is | Low (raw) |
| **Silver** | Cleansed, Curated | Cleaned, deduped, typed | Medium |
| **Gold** | Aggregated, Consumption | Business-ready, aggregated | High |

**Bronze layer:**

- COPY INTO or Snowpipe loads raw data (JSON, CSV, Parquet, etc.)
- No transformations — preserve original data for lineage/audit
- Store as VARIANT for semi-structured, or raw columns for structured
- Append-only — never delete or modify

**Silver layer:**

- Flatten semi-structured data
- Apply data types, null handling, deduplication
- Join reference data
- Apply business rules (e.g., currency conversion, timezone normalization)
- Implemented as: dynamic tables, tasks + streams, dbt models, or procedures

**Gold layer:**

- Business-facing aggregations, KPIs, fact/dimension tables
- Optimized for BI tools (Tableau, Power BI, Sigma)
- Often materialized views or dynamic tables
- Secure views for sharing

**Directory structure in Snowflake:**

```
ANALYTICS_DB
├── RAW (bronze schemas)
│   ├── RAW.SALESFORCE
│   ├── RAW.STRIPE
│   └── RAW.WEB_EVENTS
├── CURATED (silver schemas)
│   ├── CURATED.CUSTOMERS
│   └── CURATED.TRANSACTIONS
└── CONSUMPTION (gold schemas)
    ├── CONSUMPTION.FINANCE_METRICS
    └── CONSUMPTION.MARKETING_DASHBOARD
```

Or use separate databases per layer:
```
RAW_DB → CURATED_DB → ANALYTICS_DB
```

### Why This Matters

A company loads Salesforce, Stripe, and web analytics data into one giant table. Six months later, nobody knows which column means what, transformations are scattered across 50 views, and debugging takes days. The medallion architecture prevents this chaos by enforcing clear boundaries.

### Best Practices

- **One database per major source in bronze** (or one schema per source)
- Silver should be the **single source of truth** — all downstream reads from here
- Gold should be **purpose-built** for specific consumers (BI team, ML team, sharing)
- Use **dynamic tables** for silver/gold layers — automatic incremental refresh
- Document transformations in each layer with comments or a metadata table
- Apply clustering keys at the gold layer (consumption-optimized)

**Exam traps:**

- Exam trap: IF YOU SEE "Bronze layer should clean and transform data" → WRONG because bronze is **raw ingestion only**; cleaning happens in silver
- Exam trap: IF YOU SEE "Gold layer stores all historical data" → WRONG because gold stores **aggregated, consumption-ready** data; full history lives in bronze/silver
- Exam trap: IF YOU SEE "You need exactly three layers" → WRONG because medallion is a **pattern, not a mandate**; some architectures use two layers or add a "platinum" layer
- Exam trap: IF YOU SEE "Each layer must be a separate database" → WRONG because layers can be **schemas within one database** or separate databases — both are valid

### Common Questions (FAQ)

**Q: Should I use separate databases or separate schemas for medallion layers?**
A: Separate databases provide stronger isolation and easier access control. Separate schemas are simpler for smaller projects. Choose based on your governance needs.

**Q: Where do dynamic tables fit in the medallion architecture?**
A: Dynamic tables are ideal for **silver and gold** layers — they automate incremental transformation from their upstream source.

**Q: How does dbt relate to medallion architecture?**
A: dbt models naturally map to medallion layers: `staging` models = silver, `marts` models = gold. dbt orchestrates the transformations between layers.

---

## FLASHCARDS — Domain 6

**Q1: What is the purpose of zero-copy clones in development environments?**
A1: They create **instant copies** of production data for dev/staging with **no additional storage cost** (until data diverges).

**Q2: What authentication method is recommended for CI/CD pipelines?**
A2: **Key-pair authentication** — more secure than passwords, supports rotation, no secrets in plaintext.

**Q3: How does Snowflake's Git integration work?**
A3: `CREATE GIT REPOSITORY` links a remote repo. You can then reference files directly: `@my_repo/branches/main/path/file.sql`.

**Q4: What is a compute pool in SPCS?**
A4: A **managed cluster of nodes** (CPU or GPU) that runs container services. Can be suspended when idle.

**Q5: Name three Cortex LLM functions.**
A5: `COMPLETE()`, `SUMMARIZE()`, `SENTIMENT()`. Others: `TRANSLATE()`, `EXTRACT_ANSWER()`, `EMBED_TEXT_768()`.

**Q6: Do Cortex LLM functions require a warehouse?**
A6: **No.** They run serverlessly and are billed per token/call.

**Q7: What SQL ML function forecasts time-series data?**
A7: `FORECAST()` — an automated ML function accessible via SQL.

**Q8: Where do Streamlit in Snowflake apps run?**
A8: **Inside Snowflake** — on Snowflake compute, with no external server.

**Q9: What are the three medallion architecture layers?**
A9: **Bronze** (raw), **Silver** (cleansed/curated), **Gold** (aggregated/consumption).

**Q10: What is the blue/green deployment pattern in Snowflake?**
A10: Maintain two databases (blue/green). Deploy to one, test it, then `ALTER DATABASE ... SWAP WITH` for zero-downtime switch.

**Q11: Can SPCS services use GPUs?**
A11: **Yes.** Compute pools can be configured with GPU-enabled node types.

**Q12: What is the Snowflake Model Registry?**
A12: A versioning and deployment system for ML models. Log models, track versions, deploy as inference services.

**Q13: How do Native Apps differ from Streamlit in Snowflake?**
A13: Native Apps are **distributable packages** (code + data + UI) for other accounts. SiS is for **internal apps** within your account.

**Q14: What should the bronze layer contain?**
A14: **Raw data as ingested** — no transformations. Preserves original data for lineage and audit.

**Q15: What is `ALTER DATABASE SWAP WITH` used for?**
A15: **Blue/green deployments** — atomically swaps two databases, enabling zero-downtime releases and instant rollback.

---

## EXPLAIN LIKE I'M 5 — Domain 6

**ELI5 #1: Development Environments**
You're building a sandcastle. The beach is production — people are enjoying it. You practice in a sandbox first (dev). When your design looks good, you show your parents (staging). Only then do you build it on the beach (production).

**ELI5 #2: Zero-Copy Clones**
You take a photo of the sandcastle instead of rebuilding it. The photo costs almost nothing. If someone draws on the photo, only the drawing costs extra — not the whole castle.

**ELI5 #3: CI/CD**
Imagine a conveyor belt in a toy factory. Someone designs a toy (code), it goes through a quality checker (tests), then gets packaged and shipped (deploy). The belt runs automatically — no one carries toys by hand.

**ELI5 #4: SPCS (Containers)**
You have a special LEGO room inside your house. You can build anything in that room — robots, cars, castles — using any pieces you want. The room is managed by your parents (Snowflake), so you don't worry about the walls or roof.

**ELI5 #5: Cortex LLM Functions**
You have a really smart friend who lives inside your computer. You can ask them to summarize a story, tell you if an email is happy or sad, or translate something to Spanish. They're always available and you don't need any special equipment.

**ELI5 #6: ML Functions (FORECAST)**
You track how tall a plant grows every week: 2cm, 4cm, 6cm. FORECAST looks at the pattern and says "next week it'll be about 8cm." It learns the pattern from your data.

**ELI5 #7: Streamlit in Snowflake**
You draw a control panel on paper — buttons, sliders, screens. Then magically, it becomes a real control panel that anyone at school can use. No wiring or electronics needed (no server setup).

**ELI5 #8: Medallion Architecture**
You pick apples from a tree (bronze — dirty, some bruised). You wash and sort them (silver — clean, inspected). You make apple pie slices on plates (gold — ready to eat).

**ELI5 #9: Blue/Green Deployment**
You have two identical toy train tracks. You run the old train on Track A. You build the new train on Track B and test it. When it works, you flip a switch and everyone rides Track B. If it breaks, flip back to Track A instantly.

**ELI5 #10: Git Integration**
Your recipe book (Git) is connected to your kitchen (Snowflake). Instead of retyping recipes, your kitchen can read directly from the book. When someone updates the book, the kitchen sees the new recipe next time it looks.
