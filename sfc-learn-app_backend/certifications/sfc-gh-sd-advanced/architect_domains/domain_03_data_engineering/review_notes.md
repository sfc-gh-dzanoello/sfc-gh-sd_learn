# Domain 3: Data Engineering

> **ARA-C01 Syllabus Coverage:** Data Loading/Unloading, Data Transformation, Ecosystem Tools

---

## 3.1 DATA LOADING

**COPY INTO (Bulk Loading)**

- Primary command for batch/bulk loading from stages into tables
- Supports: CSV, JSON, Avro, Parquet, ORC, XML
- Key options: `ON_ERROR`, `PURGE`, `FORCE`, `MATCH_BY_COLUMN_NAME`
- `VALIDATION_MODE` — dry-run to check data without loading
- Returns metadata: rows loaded, errors, file names
- Best for: scheduled batch loads, initial data migration, large files

**Snowpipe (Continuous Loading)**

- Serverless, auto-ingest pipeline triggered by cloud events (S3 notifications, GCS Pub/Sub, Azure Event Grid)
- Near real-time (micro-batch, typically seconds to minutes latency)
- Uses a PIPE object: `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO ...`
- Billed per-second of serverless compute + file notification overhead
- Exactly-once semantics via file load metadata (14-day dedup window)

**Snowpipe Streaming**

- Lowest latency option: rows land in seconds, no files involved
- Uses the Snowflake Ingest SDK (Java) — client calls `insertRows()`
- Data is written to a staging area, then automatically migrated to table storage
- No pipe object needed — uses `CHANNEL` objects
- Best for: IoT, clickstream, real-time event data
- Combines with Dynamic Tables for real-time transformation

**Schema Detection & Evolution**

- **Schema detection** (`INFER_SCHEMA`): automatically detect column names/types from staged files
  - Works with Parquet, Avro, ORC, CSV (with headers)
  - `SELECT * FROM TABLE(INFER_SCHEMA(LOCATION => '@stage', FILE_FORMAT => 'fmt'))`
  - Use with `CREATE TABLE ... USING TEMPLATE` for auto DDL
- **Schema evolution** (`ENABLE_SCHEMA_EVOLUTION = TRUE`): new columns in source files are automatically added to the table
  - Existing columns are NOT modified or removed
  - Requires file role to have EVOLVE SCHEMA privilege

### Why This Matters
A retail company gets 500 CSV files daily from stores. Snowpipe auto-ingests them as they land in S3. Schema evolution handles new columns (e.g., "loyalty_tier") without manual ALTER TABLE.

### Best Practices
- Use Snowpipe for steady, event-driven streams; COPY INTO for large scheduled batches
- Set `ON_ERROR = CONTINUE` for non-critical loads (with error monitoring)
- Enable schema evolution on staging tables to handle source schema changes
- Use `MATCH_BY_COLUMN_NAME` when source columns don't match table order
- Monitor Snowpipe via `PIPE_USAGE_HISTORY` and `COPY_HISTORY`

**Exam trap:** IF YOU SEE "Snowpipe Streaming requires a PIPE object" → WRONG because Streaming uses CHANNELS, not pipes.

**Exam trap:** IF YOU SEE "COPY INTO automatically detects schema" → WRONG because you must explicitly use `INFER_SCHEMA` or `USING TEMPLATE`.

**Exam trap:** IF YOU SEE "schema evolution can remove columns" → WRONG because it only ADDS new columns; never removes or modifies existing ones.

**Exam trap:** IF YOU SEE "Snowpipe loads data synchronously" → WRONG because Snowpipe is asynchronous (serverless, event-driven).

### Common Questions (FAQ)
**Q: What's the dedup window for Snowpipe?**
A: 14 days. Files loaded within the past 14 days won't be re-loaded (based on file name + metadata).

**Q: Can I use Snowpipe with internal stages?**
A: Yes, but auto-ingest with cloud notifications only works with external stages. For internal stages, you call `insertFiles` REST API manually.

**Q: When should I use Snowpipe Streaming vs regular Snowpipe?**
A: Use Streaming when you need sub-second latency and are generating data programmatically (not files). Use regular Snowpipe when data arrives as files in cloud storage.

---

## 3.2 STAGES & FILE FORMATS

**Internal Stages**

- **User stage** (`@~`): one per user, cannot be altered or dropped
- **Table stage** (`@%table_name`): one per table, tied to that table
- **Named internal stage** (`@my_stage`): created explicitly, most flexible
- Data stored in Snowflake-managed storage, encrypted at rest

**External Stages**

- Point to cloud storage: S3, GCS, Azure Blob/ADLS
- Require a **storage integration** (best practice) or inline credentials (not recommended)
- Support folder paths: `@ext_stage/path/to/folder/`

**File Formats**

- Reusable format definitions: `CREATE FILE FORMAT`
- Types: CSV, JSON, AVRO, PARQUET, ORC, XML
- Key CSV options: `FIELD_DELIMITER`, `SKIP_HEADER`, `NULL_IF`, `ERROR_ON_COLUMN_COUNT_MISMATCH`
- Key JSON options: `STRIP_OUTER_ARRAY`, `STRIP_NULL_VALUES`
- Can be specified inline in COPY INTO or referenced by name

**Directory Tables**

- Metadata layer on a stage: `ALTER STAGE @my_stage SET DIRECTORY = (ENABLE = TRUE)`
- Lets you query file metadata (name, size, MD5, last_modified) via SQL
- Must be refreshed: `ALTER STAGE @my_stage REFRESH`
- Auto-refresh available for external stages with cloud notifications
- Useful for file inventory, tracking new arrivals, building processing pipelines

### Why This Matters
A data lake has 2M Parquet files in S3. A directory table provides a queryable inventory without listing objects via AWS CLI. Combined with streams, you can detect new files automatically.

### Best Practices
- Always use storage integrations for external stages (no inline credentials)
- Use named internal stages over table/user stages for production workloads
- Define file formats as reusable objects, not inline specs
- Enable directory tables with auto-refresh for file-driven pipelines

**Exam trap:** IF YOU SEE "user stages can be shared across users" → WRONG because each user's stage is private and scoped to that user.

**Exam trap:** IF YOU SEE "directory tables store the actual file data" → WRONG because they only store metadata about files.

**Exam trap:** IF YOU SEE "table stages support all stage features" → WRONG because table stages cannot have file formats, and have limited options vs named stages.

### Common Questions (FAQ)
**Q: Can I GRANT access to a user stage?**
A: No. User stages are per-user and cannot be granted to others.

**Q: Do directory tables work on internal stages?**
A: Yes, but auto-refresh is only available for external stages. Internal stages require manual `REFRESH`.

---

## 3.3 STREAMS & TASKS

**Streams (Change Data Capture)**

- Track DML changes (INSERT, UPDATE, DELETE) on a source table
- Three types:
  - **Standard:** tracks all three DML types, uses hidden columns
  - **Append-only:** only tracks INSERTs (cheaper, simpler)
  - **Insert-only (on external tables):** tracks new files/rows on external tables
- Metadata columns: `METADATA$ACTION`, `METADATA$ISUPDATE`, `METADATA$ROW_ID`
- Stream is "consumed" when used in a DML transaction (advances the offset)
- A stream has a **staleness window** — if not consumed within Time Travel retention, it becomes stale

**Change Tracking**

- Alternative to streams: `ALTER TABLE ... SET CHANGE_TRACKING = TRUE`
- Query changes via `CHANGES` clause: `SELECT * FROM table CHANGES(INFORMATION => DEFAULT) AT(...)`
- Does not have a consumable offset — idempotent queries
- Useful for point-in-time change queries without a dedicated stream object

**Tasks**

- Scheduled SQL execution (standalone or in task trees/DAGs)
- Schedule via CRON expression or `SCHEDULE = 'N MINUTE'`
- Task trees: root task triggers children in dependency order
- Tasks use serverless compute by default (or a specified warehouse)
- Must be explicitly resumed: `ALTER TASK ... RESUME`
- `WHEN` clause: conditional execution (e.g., `WHEN SYSTEM$STREAM_HAS_DATA('my_stream')`)

**Task Trees (DAGs)**

- Root task → child tasks → grandchild tasks
- Only the root task has a schedule; children trigger automatically
- Finalizer task: runs after all tasks in the graph complete (success or failure)
- Use `ALLOW_OVERLAPPING_EXECUTION` to control concurrent runs

### Why This Matters
An e-commerce platform uses a stream on `raw_orders` and a task that runs every 5 minutes. The task checks `SYSTEM$STREAM_HAS_DATA`, and if true, merges changes into `curated_orders`. CDC without a third-party tool.

### Best Practices
- Use `SYSTEM$STREAM_HAS_DATA` in task WHEN clause to avoid empty runs
- Set appropriate `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors
- Use serverless tasks unless you need to control the warehouse size
- Prefer dynamic tables over stream+task for pure transformation pipelines
- Monitor tasks via `TASK_HISTORY` in ACCOUNT_USAGE

**Exam trap:** IF YOU SEE "streams work on views" → WRONG because streams work on tables (and external tables), not views.

**Exam trap:** IF YOU SEE "child tasks can have their own schedule" → WRONG because only the root task has a schedule; children are triggered by parent completion.

**Exam trap:** IF YOU SEE "streams never become stale" → WRONG because a stream becomes stale if not consumed within the source's Time Travel retention + 14 days.

**Exam trap:** IF YOU SEE "tasks are resumed by default after creation" → WRONG because tasks are created in SUSPENDED state and must be explicitly resumed.

### Common Questions (FAQ)
**Q: Can multiple streams exist on the same table?**
A: Yes. Each stream tracks independently with its own offset.

**Q: What happens if a stream goes stale?**
A: It becomes unusable. You must recreate it. The offset is lost, and you may need to do a full reload.

**Q: Can tasks call stored procedures?**
A: Yes. A task's body can be any single SQL statement, including `CALL my_procedure()`.

---

## 3.4 EXTERNAL & ICEBERG TABLES

**External Tables**

- Read-only table over files in external storage (S3, GCS, Azure)
- Snowflake stores only metadata; data stays in your cloud storage
- Supports auto-refresh of metadata via cloud notifications
- Query performance is slower than native tables (no clustering, no micro-partition optimization)
- Support for partitioning via `PARTITION BY` computed columns
- Streams on external tables: insert-only (tracks new files)

**Managed Iceberg Tables**

- Snowflake manages the table lifecycle (write path, compaction, snapshots)
- External volume defines WHERE data is stored (your cloud storage)
- Full DML: INSERT, UPDATE, DELETE, MERGE
- Catalog integration not required (Snowflake is the catalog)
- Other engines can read the Iceberg metadata/data files
- Supports Time Travel, cloning, replication

**Unmanaged Iceberg Tables (Catalog-Linked)**

- External catalog (Glue, Polaris/OpenCatalog, Unity, REST) manages metadata
- Snowflake reads the catalog to understand table structure
- Read-only from Snowflake (writes go through the external engine)
- Requires CATALOG INTEGRATION object
- Auto-refresh detects catalog changes

**Incremental vs Full Refresh (Dynamic/Iceberg Context)**

- **Full refresh:** recompute entire dataset (expensive but simple)
- **Incremental refresh:** only process changed data (cheaper, requires change tracking)
- Dynamic tables use incremental refresh when possible (operator-dependent)
- Some operations force full refresh (e.g., non-deterministic functions, complex joins)

### Why This Matters
A company runs both Spark and Snowflake. Managed Iceberg tables let Snowflake write data in Iceberg format to S3. Spark reads the same files directly. One copy of data, two engines.

### Best Practices
- Use managed Iceberg for new "open format" requirements with Snowflake as primary engine
- Use unmanaged/catalog-linked for data owned by another engine (Spark, Trino)
- External tables are legacy for read-only access — prefer Iceberg for new projects
- Partition external tables by date/region for query pruning

**Exam trap:** IF YOU SEE "external tables support UPDATE/DELETE" → WRONG because external tables are read-only.

**Exam trap:** IF YOU SEE "unmanaged Iceberg tables support MERGE" → WRONG because writes must go through the external catalog/engine.

**Exam trap:** IF YOU SEE "managed Iceberg tables store data in Snowflake's internal storage" → WRONG because they write to an external volume (your cloud storage) in Iceberg format.

**Exam trap:** IF YOU SEE "dynamic tables always use incremental refresh" → WRONG because certain operations force full refresh.

### Common Questions (FAQ)
**Q: Can I convert an external table to a native table?**
A: Not directly. You'd CTAS from the external table into a new native (or Iceberg) table.

**Q: Do managed Iceberg tables support clustering?**
A: Yes. You can define clustering keys on managed Iceberg tables.

**Q: What's the difference between an external table and an unmanaged Iceberg table?**
A: External tables work on raw files (CSV, Parquet, etc.) with Snowflake-defined metadata. Unmanaged Iceberg tables read Iceberg-formatted tables managed by an external catalog with full Iceberg capabilities (snapshots, schema evolution).

---

## 3.5 DATA TRANSFORMATION

**FLATTEN**

- Converts semi-structured (JSON, ARRAY, VARIANT) data into rows
- Lateral join by default: `SELECT ... FROM table, LATERAL FLATTEN(input => col)`
- Key parameters: `INPUT`, `PATH`, `OUTER` (keep rows with empty arrays), `RECURSIVE`, `MODE`
- Output columns: `SEQ`, `KEY`, `PATH`, `INDEX`, `VALUE`, `THIS`

**UDFs (User-Defined Functions)**

- SQL, JavaScript, Python, Java, Scala
- Scalar UDFs: return one value per input row
- Must be deterministic for use in materialized views / clustering
- Secure UDFs: hide function body from consumers

**UDTFs (User-Defined Table Functions)**

- Return a table (multiple rows per input row)
- Must implement: `PROCESS()` (per-row logic) and optionally `END_PARTITION()` (final output)
- Called with `TABLE()` in FROM clause
- Useful for: parsing, exploding, custom aggregation

**External Functions**

- Call external API endpoints (e.g., AWS Lambda, Azure Functions) from SQL
- Requires: API integration + external function definition
- Synchronous: Snowflake calls the API per batch and waits
- Use for: ML inference, third-party enrichment, custom logic not in Snowflake
- Being replaced by container-based UDFs (SPCS) for new use cases

**Stored Procedures**

- Can contain control flow (IF, LOOP, BEGIN/END), multiple SQL statements
- Languages: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Can run with CALLER rights or OWNER rights
- Use for: admin tasks, complex ETL, multi-step operations
- Key difference from UDFs: procedures can have side effects (DML), UDFs cannot

**Dynamic Tables**

- Declarative transformation: define the target as a SQL query + target lag
- Snowflake automatically refreshes (incremental when possible)
- Replace complex stream+task chains for transformation pipelines
- Target lag: `DOWNSTREAM` (cascade from upstream DTs) or explicit interval
- Cannot be used as a direct source for streams

**Secure Functions**

- UDFs/UDTFs with `SECURE` keyword: body is hidden from consumers
- Required for functions used in Secure Data Sharing
- Same optimizer fence as secure views

### Why This Matters
A pipeline flattens raw JSON events, enriches them via an external function (ML scoring), and lands results in a dynamic table with 5-minute target lag. Zero task/stream management.

### Best Practices
- Prefer dynamic tables over stream+task for transformation-only pipelines
- Use SQL UDFs for simple calculations; Python UDFs for complex logic
- Minimize external function calls (network overhead per batch)
- Use stored procedures for administrative workflows, not data transformation
- Set dynamic table target lag based on business SLA, not as low as possible

**Exam trap:** IF YOU SEE "UDFs can execute DML statements" → WRONG because UDFs are read-only; only stored procedures can execute DML.

**Exam trap:** IF YOU SEE "dynamic tables can be sources for streams" → WRONG because you cannot create streams on dynamic tables.

**Exam trap:** IF YOU SEE "external functions run inside Snowflake compute" → WRONG because they call an external API endpoint outside Snowflake.

**Exam trap:** IF YOU SEE "FLATTEN only works with JSON" → WRONG because FLATTEN works with any semi-structured type: VARIANT, ARRAY, OBJECT.

### Common Questions (FAQ)
**Q: Can I use Python UDFs in materialized views?**
A: No. MVs only support SQL expressions (no UDFs, no external functions).

**Q: What's the difference between target lag DOWNSTREAM and a specific interval?**
A: DOWNSTREAM means "refresh whenever my upstream dynamic table refreshes." A specific interval (e.g., 5 MINUTES) means "ensure data is no older than 5 minutes."

**Q: Can dynamic tables reference other dynamic tables?**
A: Yes. This creates a dynamic table pipeline (DAG), where upstream refreshes cascade downstream.

---

## 3.6 ECOSYSTEM TOOLS

**Kafka Connector**

- Streams data from Kafka topics into Snowflake tables
- Two versions: **Snowpipe-based** (files to stage, then COPY) and **Snowpipe Streaming** (direct row insert, lower latency)
- Supports exactly-once semantics
- Handles schema evolution (new fields in JSON)
- Managed by Snowflake or self-hosted

**Spark Connector**

- Bi-directional: read from and write to Snowflake from Spark
- Pushes queries down to Snowflake when possible (predicate pushdown)
- Supports DataFrame API and SQL
- Key config: `sfURL`, `sfUser`, `sfPassword`, `sfDatabase`, `sfSchema`, `sfWarehouse`

**Python Connector**

- Native Python library (`snowflake-connector-python`)
- Supports `write_pandas()` for bulk DataFrame uploads
- Integrates with SQLAlchemy
- Async query support for long-running queries
- `snowflake-snowpark-python` — DataFrame API that runs on Snowflake compute

**JDBC / ODBC**

- Standard database connectivity for Java (JDBC) and other languages (ODBC)
- Snowflake provides its own JDBC and ODBC drivers
- Support all standard SQL operations
- Used by most BI tools (Tableau, Power BI, Looker)

**SQL API (REST)**

- HTTP REST endpoint for executing SQL
- Submit statements, check status, retrieve results via REST calls
- Uses OAuth or key-pair tokens for authentication
- Async execution: submit → poll status → fetch results
- Useful for serverless architectures, microservices

**Snowpark**

- Developer framework for Python, Java, Scala
- DataFrame API that executes on Snowflake's compute (no data movement)
- Supports UDFs, UDTFs, and stored procedures
- Ideal for ML pipelines, complex transformations
- Lazy evaluation: operations build a plan, execute on `.collect()` or action

### Why This Matters
A data platform uses Kafka connector for real-time ingestion, Snowpark for ML feature engineering, and JDBC for BI tools. The architect must know which connector fits each use case.

### Best Practices
- Use Kafka connector with Snowpipe Streaming for lowest latency
- Use Snowpark instead of extracting data to Python/Spark when possible (compute stays in Snowflake)
- Use SQL API for lightweight integrations and serverless apps
- Always use the latest Snowflake-provided drivers (updated frequently)
- Use key-pair auth for all programmatic/service connections

**Exam trap:** IF YOU SEE "the Spark connector always moves all data to Spark" → WRONG because it supports predicate pushdown, pushing filters to Snowflake.

**Exam trap:** IF YOU SEE "SQL API is synchronous only" → WRONG because it supports async execution (submit → poll → fetch).

**Exam trap:** IF YOU SEE "Snowpark requires data to be extracted from Snowflake" → WRONG because Snowpark runs on Snowflake compute; data stays in Snowflake.

**Exam trap:** IF YOU SEE "the Kafka connector only supports JSON" → WRONG because it supports JSON, Avro, and Protobuf (with schema registry).

### Common Questions (FAQ)
**Q: When should I use the Spark connector vs Snowpark?**
A: Use Spark connector when you already have Spark infrastructure and need to integrate Snowflake into existing pipelines. Use Snowpark when you want to run all compute in Snowflake without a Spark cluster.

**Q: Can the SQL API handle large result sets?**
A: Yes, via result set pagination. Large results are returned in partitions that you fetch incrementally.

**Q: Does the Kafka connector support schema evolution?**
A: Yes. New fields in JSON payloads are loaded into the VARIANT column. If you use schema evolution on the target table, columns are auto-added.

---

## CONFUSING PAIRS — Data Engineering

| They ask about... | The answer is... | NOT... |
|---|---|---|
| **Snowpipe** vs **COPY INTO** | **Snowpipe** = serverless, event-driven, continuous (files trigger load) | **COPY INTO** = manual/scheduled batch command, you run it explicitly |
| **Snowpipe** vs **Snowpipe Streaming** | **Snowpipe** = file-based (cloud notifications → micro-batch) | **Streaming** = row-based (Ingest SDK, no files, sub-second latency) |
| **PIPE object** vs **CHANNEL object** | **PIPE** = used by regular Snowpipe (`CREATE PIPE`) | **CHANNEL** = used by Snowpipe Streaming (Ingest SDK, no PIPE needed) |
| **Stream** vs **Task** | **Stream** = CDC tracker (records changes on a table) | **Task** = scheduled SQL executor (cron/interval). They're *partners*, not substitutes |
| **Standard stream** vs **append-only stream** | **Standard** = tracks INSERT + UPDATE + DELETE | **Append-only** = tracks only INSERTs (cheaper, simpler) |
| **External table** vs **Iceberg table** | **External** = raw files (CSV, Parquet), read-only, Snowflake metadata | **Iceberg** = Iceberg-format, managed = full DML, unmanaged = catalog-linked |
| **Schema detection** vs **schema evolution** | **Detection** (`INFER_SCHEMA`) = reads file to discover columns *once* | **Evolution** = auto-adds new columns to table *ongoing* as source changes |
| **UDF** vs **UDTF** | **UDF** = one value per row (scalar) | **UDTF** = multiple rows per input (table function, uses PROCESS + END_PARTITION) |
| **UDF** vs **stored procedure** | **UDF** = read-only, no side effects, usable in SELECT | **Procedure** = can do DML, control flow, side effects, called via CALL |
| **External function** vs **UDF** | **External function** = calls an API *outside* Snowflake (Lambda, Azure Func) | **UDF** = runs *inside* Snowflake compute |
| **Dynamic table** vs **stream + task** | **Dynamic table** = declarative (define SQL + target lag, Snowflake manages refresh) | **Stream + task** = imperative (you manage CDC + scheduling + error handling) |
| **Directory table** vs **external table** | **Directory table** = metadata about *files* on a stage (name, size, date) | **External table** = queryable *data inside* files on external storage |
| **User stage** vs **table stage** vs **named stage** | **User** (`@~`) = per-user, private, can't share | **Table** (`@%t`) = per-table, limited options | **Named** (`@s`) = explicit, most flexible |
| **Target lag DOWNSTREAM** vs **explicit interval** | **DOWNSTREAM** = refresh when upstream DT refreshes | **Explicit** (e.g., 5 MIN) = data no older than N minutes |
| **VALIDATION_MODE** vs **ON_ERROR** | **VALIDATION_MODE** = dry run, no data loaded | **ON_ERROR** = controls behavior *during* actual load (CONTINUE, ABORT, SKIP_FILE) |

---

## SCENARIO DECISION TREES — Data Engineering

**Scenario 1: "500 CSV files land in S3 daily from store POS systems..."**
- **CORRECT:** **Snowpipe** with auto-ingest (S3 event notification triggers load)
- TRAP: *"Scheduled COPY INTO every hour"* — **WRONG**, misses files between runs, higher latency, more warehouse cost

**Scenario 2: "IoT sensors send 10K events/second, need sub-second latency..."**
- **CORRECT:** **Snowpipe Streaming** (Ingest SDK, row-level, no files)
- TRAP: *"Regular Snowpipe"* — **WRONG**, Snowpipe is file-based with seconds-to-minutes latency; Streaming is sub-second

**Scenario 3: "Source adds new columns frequently, table should adapt automatically..."**
- **CORRECT:** **Schema evolution** (`ENABLE_SCHEMA_EVOLUTION = TRUE`) + `MATCH_BY_COLUMN_NAME`
- TRAP: *"INFER_SCHEMA before every load"* — **WRONG**, INFER_SCHEMA is one-time detection, not ongoing evolution

**Scenario 4: "Need to merge incremental changes from raw into curated every 5 minutes..."**
- **CORRECT:** **Stream on raw table** + **Task** with `SYSTEM$STREAM_HAS_DATA` + MERGE statement
- TRAP: *"Dynamic table"* — possible but dynamic tables don't support MERGE logic with custom conflict resolution; stream+task gives full control

**Scenario 5: "Build a transformation pipeline: raw → cleaned → aggregated, purely SQL..."**
- **CORRECT:** **Dynamic tables** chained (raw DT → cleaned DT → agg DT with target lag)
- TRAP: *"Three stream+task pairs"* — **WRONG**, overly complex; dynamic tables handle this declaratively

**Scenario 6: "Call an external ML scoring API from within a SQL query..."**
- **CORRECT:** **External function** (API integration + function definition)
- TRAP: *"Python UDF"* — **WRONG**, Python UDF runs inside Snowflake; it can't call external APIs without an external access integration

**Scenario 7: "Need to flatten nested JSON arrays into rows for analytics..."**
- **CORRECT:** **LATERAL FLATTEN** with `INPUT => column`, optionally `OUTER => TRUE` for empty arrays
- TRAP: *"PARSE_JSON + manual extraction"* — **WRONG**, FLATTEN is purpose-built and handles nested arrays natively

**Scenario 8: "Admin task: loop through databases, create tags, run grants..."**
- **CORRECT:** **Stored procedure** (Snowflake Scripting with IF/LOOP/BEGIN-END)
- TRAP: *"UDF"* — **WRONG**, UDFs cannot execute DML (CREATE, GRANT, ALTER)

**Scenario 9: "Need to track which files exist on a stage and when they arrived..."**
- **CORRECT:** **Directory table** on the stage (`ENABLE = TRUE`, auto-refresh for external)
- TRAP: *"External table"* — **WRONG**, external tables query file *contents*, not file *metadata*

**Scenario 10: "Kafka topics need to land in Snowflake with lowest possible latency..."**
- **CORRECT:** **Kafka connector with Snowpipe Streaming** mode (direct row insert)
- TRAP: *"Kafka connector with Snowpipe mode"* — not wrong, but higher latency (file-based); Streaming mode is lower latency

**Scenario 11: "Data validation before loading — check for bad rows without actually loading..."**
- **CORRECT:** `COPY INTO ... VALIDATION_MODE = 'RETURN_ERRORS'` (dry run)
- TRAP: *"Load with ON_ERROR = CONTINUE then check errors"* — **WRONG**, this actually loads data; VALIDATION_MODE loads nothing

**Scenario 12: "Python ML feature engineering on data already in Snowflake..."**
- **CORRECT:** **Snowpark** (DataFrame API runs on Snowflake compute, no data movement)
- TRAP: *"Python connector + pandas"* — **WRONG**, this pulls data out of Snowflake to local machine; Snowpark keeps compute in Snowflake

---

## FLASHCARDS -- Domain 3

**Q1:** What is the deduplication window for Snowpipe?
**A1:** 14 days. Files loaded in the last 14 days are tracked and won't be re-ingested.

**Q2:** What object does Snowpipe Streaming use instead of a PIPE?
**A2:** CHANNEL objects (via the Ingest SDK).

**Q3:** Can schema evolution remove columns from a table?
**A3:** No. It only adds new columns.

**Q4:** What are the three stream types?
**A4:** Standard (all DML), Append-only (inserts only), Insert-only (external tables, new files).

**Q5:** What state are tasks created in?
**A5:** SUSPENDED. They must be explicitly resumed.

**Q6:** Can UDFs execute DML?
**A6:** No. Only stored procedures can execute DML (INSERT, UPDATE, DELETE).

**Q7:** What is the key difference between an external function and a UDF?
**A7:** External functions call an API endpoint outside Snowflake; UDFs run inside Snowflake compute.

**Q8:** What does FLATTEN do?
**A8:** Converts semi-structured data (VARIANT, ARRAY, OBJECT) into relational rows.

**Q9:** What is the purpose of a storage integration?
**A9:** Provides secure, credential-free access to external cloud storage using IAM roles or service principals.

**Q10:** How does Snowpark differ from the Python connector?
**A10:** Snowpark executes a DataFrame API on Snowflake's compute (no data movement). The Python connector runs queries from a Python client.

**Q11:** Can you create a stream on a dynamic table?
**A11:** No. Streams cannot be created on dynamic tables.

**Q12:** What does `VALIDATION_MODE` do in COPY INTO?
**A12:** Performs a dry run — validates data without actually loading it.

**Q13:** What is a directory table?
**A13:** A metadata layer on a stage that lets you query file attributes (name, size, last_modified) via SQL.

**Q14:** What triggers child tasks in a task tree?
**A14:** The successful completion of the parent task. Only the root task has a schedule.

**Q15:** What is target lag DOWNSTREAM on a dynamic table?
**A15:** The dynamic table refreshes whenever its upstream dynamic table refreshes, cascading through the pipeline.

---

## EXPLAIN LIKE I'M 5 -- Domain 3

**1. COPY INTO**
Imagine you have a big box of puzzle pieces (files). COPY INTO dumps all those pieces onto your puzzle board (table) at once. You do it when you have a whole box ready.

**2. Snowpipe**
Now imagine someone slides puzzle pieces under your door one by one as they find them. That's Snowpipe — pieces arrive and get placed automatically without you doing anything.

**3. Snowpipe Streaming**
Even faster: someone is THROWING puzzle pieces through your window as fast as they pick them up. No waiting for a pile. Each piece arrives instantly.

**4. Streams (CDC)**
A magic notepad that writes down every time someone adds, changes, or removes a toy from the toy box. When you read the notepad, it clears itself and starts fresh.

**5. Tasks**
An alarm clock that goes off every N minutes and says "Time to do your chores!" Your chore is a SQL statement. You can set up a chain: "After washing dishes, sweep the floor."

**6. FLATTEN**
You have a bag of bags of candy. FLATTEN opens all the inner bags and pours everything into one big pile so you can count each candy individually.

**7. Dynamic Tables**
A magic whiteboard that automatically updates itself. You wrote the rules once ("show me total sales per store"), and every few minutes the whiteboard erases and redraws with the latest numbers.

**8. External Tables**
Looking through a window at your neighbor's garden. You can SEE the flowers (read the data) but you can't touch or rearrange them (no writes). The flowers stay in their garden.

**9. Stages**
Your locker at school. You put your backpack (files) in your locker (stage) before taking things out in class (loading into tables). Some lockers are yours (internal), some are shared storage closets (external).

**10. Kafka Connector**
A conveyor belt from a factory (Kafka) to your warehouse (Snowflake). Items keep rolling in automatically. If the belt uses the Streaming version, items arrive even faster without needing to be boxed first.
