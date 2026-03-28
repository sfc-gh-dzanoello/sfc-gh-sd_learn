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

**COPY INTO -- Deep Dive (Exam Details)**

- **Supported transformations during COPY:** Type casts (`col::INTEGER`), column reordering, column omitting (skip columns), loading a subset of columns. Does NOT support: subqueries, window functions, or joins during load.
- **VALIDATION_MODE values:** Three options: `RETURN_ERRORS` (return first error), `RETURN_ALL_ERRORS` (all errors), `RETURN_N_ROWS` (validate N rows). VALIDATION_MODE is **incompatible with transformations** -- you cannot use both. It does NOT load data, only validates.
- **FORCE=TRUE:** Reloads files that were already loaded (bypasses the 14-day dedup). Risk: **causes duplicate data** if the same file is loaded again.
- **LOAD_UNCERTAIN_FILES:** Reloads files whose metadata has expired (past the 14-day tracking window). Useful for recovering from missed loads.
- **Max files in discrete list:** The `FILES = (...)` parameter supports a maximum of **1000 files** per COPY INTO statement.
- **PURGE=TRUE:** Deletes staged files after successful load. Saves storage cost for large one-time migrations.
- **REMOVE from stage after load:** Removing processed files from the stage improves performance of subsequent COPY operations (fewer files for Snowflake to scan metadata for).
- **CURRENT_TIMESTAMP in COPY/Snowpipe:** Evaluated at load operation **compile time** in the cloud services layer, NOT at per-row insert time. All rows in the same COPY batch get the **same timestamp value**.
- **ON_ERROR options:** `CONTINUE` (skip bad rows, keep going), `SKIP_FILE` (skip entire file on error -- slower than CONTINUE), `ABORT_STATEMENT` (stop immediately). SKIP_FILE has performance overhead.
- **ERROR_ON_COLUMN_COUNT_MISMATCH:** When TRUE, rejects files where the number of columns doesn't match the table. Default is FALSE (extra columns ignored for CSV).
- **MATCH_BY_COLUMN_NAME with CSV:** Works with CSV files only when headers are present. Matches by column name instead of position.
- **File unloading constraints:** Only CSV, JSON, and Parquet formats supported for COPY INTO location (unloading). Only **UTF-8 encoding**. Default `MAX_FILE_SIZE` = 16MB enables parallel unload.
- **AVRO compression:** Supports GZIP, ZSTD, AUTO. Does **NOT** support BZ2.
- **ON_ERROR = SKIP_FILE_n:** A variant of SKIP_FILE that skips the file only when the number of errors reaches `n` (e.g., `SKIP_FILE_3`). Useful for tolerating a small number of bad rows per file while rejecting badly corrupted files.
- **SKIP_FILE reload behavior:** When a file is skipped via `ON_ERROR = SKIP_FILE`, Snowflake marks it as **NOT loaded**. A subsequent `COPY INTO` (without FORCE) will automatically retry that file. You can also use `FILES = ('file5.csv')` to target it explicitly.
- **S3 Glacier is NOT supported:** Snowpipe and COPY INTO cannot read files from S3 Glacier storage class. Files must be in standard S3 storage tiers.
- **Small file optimization:** Snowflake performs poorly with many tiny files. Best practice is to merge small files into **100-250 MB compressed** files before loading. If unavoidable, a multi-cluster warehouse can help parallelize the scan.
- **Loading ORDER BY for natural clustering:** When loading into reporting/analytics tables, use `ORDER BY <cluster_key_columns>` in the INSERT...SELECT or CTAS from staging. This produces naturally clustered micro-partitions, improving pruning without automatic reclustering cost.
- **Cross-database COPY requires qualified names:** When copying data across databases, use fully qualified names: `database.schema.table`. Unqualified names resolve against the current session context.
- **Pipe modification procedure:** To safely modify a Snowpipe definition: (1) Pause the pipe with `ALTER PIPE ... SET PIPE_EXECUTION_PAUSED = TRUE`, (2) Query `SYSTEM$PIPE_STATUS` and wait until `pendingFileCount` = 0, (3) Recreate the pipe with the new definition, (4) Verify cloud notification config is intact, (5) Resume the pipe.
- **Snowpipe does NOT support PURGE:** The `PURGE = TRUE` copy option is invalid in `CREATE PIPE`. To clean up staged files after Snowpipe loads them, run `REMOVE @stage` periodically as a separate task.
- **Transformations in CREATE PIPE AS COPY:** Supported: type casts (`$1::DATE`), column reordering, column omission. **NOT supported:** joins, subqueries, WHERE clause filtering, `ON_ERROR = ABORT_STATEMENT`, `FILES = (...)`, `PURGE`.
- **AWS vs GCS/Azure auto-ingest:** AWS auto-ingest requires `aws_sns_topic` in the pipe definition. GCS and Azure require an `INTEGRATION` parameter instead. The `INTEGRATION` parameter is only for GCS/Azure -- not AWS.
- **max_concurrency_level for Snowpark:** Set `ALTER WAREHOUSE ... SET MAX_CONCURRENCY_LEVEL = 1` to dedicate all warehouse resources to a single Snowpark stored procedure, maximizing memory and compute for resource-intensive operations.

**Exam trap:** IF YOU SEE "VALIDATION_MODE works with column transformations" → WRONG because VALIDATION_MODE is incompatible with COPY transformations.

**Exam trap:** IF YOU SEE "FORCE=TRUE is safe to use repeatedly" → WRONG because FORCE=TRUE bypasses dedup and will cause duplicate rows.

**Exam trap:** IF YOU SEE "CURRENT_TIMESTAMP in COPY is evaluated per-row" → WRONG because it's evaluated once at compile time -- all rows get the same value.

**Exam trap:** IF YOU SEE "COPY INTO can unload to ORC or XML" → WRONG because unloading only supports CSV, JSON, and Parquet.

**Snowpipe (Continuous Loading)**

- Serverless, auto-ingest pipeline triggered by cloud events (S3 notifications, GCS Pub/Sub, Azure Event Grid)
- Near real-time (micro-batch, typically seconds to minutes latency)
- Uses a PIPE object: `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO ...`
- Billed per-second of serverless compute + file notification overhead
- Exactly-once semantics via file load metadata (14-day dedup window)

**Snowpipe REST API & Operational Details**

- **Snowpipe REST API endpoints:**

| Endpoint | Purpose | Key Limits |
|---|---|---|
| `insertFiles` | Submit files for loading | Max 5000 files per call, 1024 bytes max path length |
| `insertReport` | Check load status for recently submitted files | Max 10K events returned, 10-minute retention window |
| `loadHistoryScan` | Query historical load status | Rate-limited, returns HTTP 429 on overuse |

- **insertReport vs loadHistoryScan best practice:** Call `insertReport` every ~8 minutes with a 10-minute time range. Use `loadHistoryScan` only for historical investigation. Frequent `loadHistoryScan` calls trigger HTTP 429 rate limiting.
- **insertFiles 200 response:** A 200 HTTP response means the files are **queued**, NOT ingested. Actual loading happens asynchronously.
- **Snowpipe minimum privileges:** OWNERSHIP on the pipe (NOT USAGE), USAGE on the stage (NOT READ for external stages), USAGE on database/schema, INSERT + SELECT on the target table.
- **CREATE PIPE allowed copy options:** `SKIP_HEADER`, `STRIP_OUTER_ARRAY`, `FILE_FORMAT`. Does NOT support: `PURGE`, `FILES=`, `ON_ERROR=ABORT_STATEMENT`.
- **Cloud-specific requirements:** AWS auto-ingest needs `aws_sns_topic` in the pipe definition. GCS and Azure need an `INTEGRATION` parameter instead.
- **Paused pipe notification retention:** When a pipe is paused, event notification messages enter a **14-day limited retention**. After 14 days, messages are lost and must be re-sent.
- **SNS topic deletion impact:** If the AWS SNS topic is deleted, the pipe stops receiving notifications. Must recreate the pipe with a new SNS topic.
- **COPY_HISTORY retention:** Both COPY INTO and Snowpipe load history is available in INFORMATION_SCHEMA for **14 days**.
- **Cross-cloud ingestion:** Snowpipe REST API endpoint can ingest from any cloud (e.g., S3 files into a GCP Snowflake account) as long as the stage is accessible.

**Exam trap:** IF YOU SEE "Snowpipe needs USAGE privilege on the pipe" → WRONG because it needs OWNERSHIP on the pipe, not USAGE.

**Exam trap:** IF YOU SEE "insertFiles 200 means data is loaded" → WRONG because 200 means files are queued for loading, not yet ingested.

**Exam trap:** IF YOU SEE "PURGE can be used in CREATE PIPE" → WRONG because PURGE is not a valid copy option in pipe definitions.

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

### Example Scenario Questions — Data Loading

**Scenario:** A retail chain has 2,000 stores, each uploading daily sales CSV files to S3 at unpredictable times throughout the day. The analytics team needs data available within 5 minutes of upload. Currently, a scheduled COPY INTO job runs hourly, causing up to 60 minutes of latency and occasionally missing late-arriving files. How should the architect redesign the ingestion?
**Answer:** Replace the scheduled COPY INTO with Snowpipe using auto-ingest. Configure S3 event notifications (SQS) on the bucket to trigger Snowpipe whenever a new file lands. Create a PIPE object with `AUTO_INGEST = TRUE` pointing to the S3 stage with the appropriate file format. Snowpipe processes files within seconds to minutes of arrival — well within the 5-minute SLA. It uses serverless compute (no dedicated warehouse), and the 14-day deduplication window prevents re-loading files. Enable schema evolution on the target table to handle any new columns stores may add over time.

**Scenario:** An IoT platform receives 50,000 sensor events per second from industrial equipment. Events must be queryable within 2 seconds for real-time monitoring dashboards. File-based ingestion cannot meet the latency requirement. What ingestion method should the architect use?
**Answer:** Use Snowpipe Streaming via the Snowflake Ingest SDK (Java). The application calls `insertRows()` to write events directly to Snowflake without creating intermediate files — achieving sub-second latency. Data lands in a staging area and is automatically migrated to table storage. No PIPE object is needed; the SDK uses CHANNEL objects. Combine Snowpipe Streaming with dynamic tables for real-time transformation — e.g., a dynamic table with a 1-minute target lag that aggregates raw sensor events into equipment health metrics for the monitoring dashboard.

**Scenario:** A data engineering team is onboarding a new data source that adds new columns to its JSON payloads every few weeks. They don't want to manually ALTER TABLE each time. How should the architect configure the pipeline to handle this automatically?
**Answer:** Enable schema evolution on the target table: `ALTER TABLE ... SET ENABLE_SCHEMA_EVOLUTION = TRUE`. Use `MATCH_BY_COLUMN_NAME = 'CASE_INSENSITIVE'` in the COPY INTO or Snowpipe definition so that columns are matched by name rather than position. When new columns appear in the source files, Snowflake automatically adds them to the table. Existing columns are never modified or removed. The role running the load must have the EVOLVE SCHEMA privilege on the table. Use `INFER_SCHEMA` for the initial table creation to detect the starting schema from a sample file.

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

**Stages -- Deep Dive (Exam Details)**

- **File format specification precedence:** When loading, the format specified in COPY INTO > stage definition > table definition. Most specific wins.
- **PREVENT_UNLOAD_TO_INTERNAL_STAGES:** User-level parameter that prevents a user from unloading data to internal stages. Minimal administrative overhead for controlling data export.
- **GET command:** Used in SnowSQL to download files from internal stages to local machine. Syntax: `GET @stage/path file:///local/path`
- **Cross-cloud external stages:** An external stage can point to storage on a different cloud than your Snowflake account (e.g., GCS stage for an Azure Snowflake account).
- **Storage integration benefits:** No raw credentials in SQL. Uses IAM roles/service principals. One integration can serve multiple stages. Defines allowed/blocked storage locations.
- **PREVENT_UNLOAD_TO_INLINE_URL:** Account-level parameter. When set to `TRUE`, blocks COPY INTO unloads to URLs that are NOT backed by a named stage with a storage integration. Prevents users from exfiltrating data to arbitrary cloud URLs.
- **PREVENT_UNLOAD_TO_INTERNAL_STAGES:** User-level parameter. When `TRUE`, prevents the user from unloading data to internal stages. Set at the user level for least administrative overhead (not session level).
- **File format specification locations:** A file format can be set in three places: (1) `COPY INTO` statement, (2) `CREATE STAGE`, (3) `CREATE TABLE`. **Precedence:** COPY INTO > stage > table. Most specific wins.
- **Cross-cloud external stages and cost:** An external stage can point to storage on a different cloud than your Snowflake account (e.g., a GCS stage from an Azure Snowflake account). This works but incurs **cross-cloud data transfer fees**. Snowflake does not block it.
- **Storage integration for cross-region ingestion:** A storage integration allows connecting to external cloud storage regardless of the Snowflake account's region. This enables multi-site companies to ingest from regional buckets into a single Snowflake account.

**Exam trap:** IF YOU SEE "PREVENT_UNLOAD_TO_INTERNAL_STAGES is a session parameter" → WRONG because it is a **user-level** parameter. Setting at user level provides least overhead.

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

### Example Scenario Questions — Stages & File Formats

**Scenario:** A data lake has 2 million Parquet files in S3 across hundreds of folders. The data engineering team needs to track which files have been processed, identify new arrivals, and build processing pipelines based on file metadata (size, last modified date). Currently, they run AWS CLI `ls` commands which take 30+ minutes. How should the architect improve this?
**Answer:** Create an external stage pointing to the S3 bucket with a storage integration (no inline credentials). Enable a directory table on the stage: `ALTER STAGE @data_lake SET DIRECTORY = (ENABLE = TRUE)`. Configure auto-refresh with S3 event notifications so the directory table updates automatically when new files land. The team can now query file metadata (name, size, MD5, last_modified) via standard SQL in seconds instead of running CLI commands. Combine the directory table with a stream to detect new file arrivals and trigger processing tasks automatically.

**Scenario:** A security audit reveals that several external stages in production were created with inline AWS access keys embedded directly in the stage definition. How should the architect remediate this and prevent recurrence?
**Answer:** Recreate all external stages using storage integrations instead of inline credentials. A storage integration uses IAM roles (on AWS) or service principals (on Azure) — no raw credentials in SQL. After migrating all stages, set the account-level parameter `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` to prevent anyone from creating stages with inline credentials in the future. Rotate the compromised AWS access keys immediately. Use named internal stages over table/user stages for any internally-staged data in production.

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
- A stream has a **staleness window** — if not consumed within the source table's `DATA_RETENTION_TIME_IN_DAYS` + 14 days, it becomes stale and must be recreated

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

**Streams & Tasks -- Deep Dive (Exam Details)**

- **TASK_HISTORY function details:** Returns max 10K rows. Shows both completed AND currently running tasks. Covers 7 days of history + next 8 days of scheduled executions.
- **Task scheduling and daylight savings:** Tasks scheduled with UTC are immune to daylight savings changes. Tasks using local time zones may skip or double-execute during DST transitions.
- **Cloned tasks are always SUSPENDED:** When cloning a database or schema, all tasks in the clone are created in SUSPENDED state. Must manually resume each task.
- **Stream staleness extension:** Snowflake automatically extends the data retention period by 14 days beyond the table's `DATA_RETENTION_TIME_IN_DAYS` for stream offset tracking. This is the "staleness window."
- **Change tracking features:** Both streams AND the `CHANGES` clause can track changes. Streams have a consumable offset; CHANGES clause is idempotent (same query always returns same results for a given time range).
- **Change tracking on views:** You can enable change tracking on views: `ALTER VIEW ... SET CHANGE_TRACKING = TRUE`. Streams can then be created on those views.
- **TASK_HISTORY two sources:** `TABLE(INFORMATION_SCHEMA.TASK_HISTORY())` for recent runs (7 days, max 10K rows). `ACCOUNT_USAGE.TASK_HISTORY` for up to **365 days** of history with 45-minute latency. Use `ERROR_ONLY => TRUE` to filter to only failed/cancelled tasks.
- **SYSTEM$STREAM_HAS_DATA evaluation:** This function runs in the **cloud services layer** (no warehouse compute). A warehouse with `AUTO_SUSPEND` will only start when the stream actually has data and the task body executes.
- **Append-only stream with TRUNCATE:** An append-only stream records ALL inserts regardless of subsequent TRUNCATE or DELETE operations. A standard stream shows the net result (TRUNCATE cancels prior inserts). This is a key behavioral difference tested on the exam.
- **Shareable objects in Data Sharing:** Tables, dynamic tables, external tables, Iceberg tables, secure views, secure materialized views, and secure UDFs can be shared. **NOT shareable:** standard views, stored procedures, streams, tasks, pipes.

**Exam trap:** IF YOU SEE "SYSTEM$STREAM_HAS_DATA requires warehouse compute" → WRONG because it evaluates in the cloud services layer at zero warehouse cost.

**Exam trap:** IF YOU SEE "Append-only streams lose data after TRUNCATE" → WRONG because append-only streams track ALL inserts regardless of subsequent TRUNCATE/DELETE.

**Cloning Impacts on Streams & Tasks**

- **Cloning pipes:** Only pipes referencing **external stages** are cloned. Internal stage pipes are NOT cloned.
- **Cloned privileges:** Child objects (tables, views) inherit their grants. The container (database, schema) does NOT inherit grants from the source.
- **Unconsumed stream records:** After cloning a database/schema, stream records that existed before the clone are **inaccessible** in the cloned version. The clone's streams start fresh.

**Exam trap:** IF YOU SEE "cloned tasks are active by default" → WRONG because cloned tasks are always SUSPENDED and must be explicitly resumed.

### Why This Matters
An e-commerce platform uses a stream on `raw_orders` and a task that runs every 5 minutes. The task checks `SYSTEM$STREAM_HAS_DATA`, and if true, merges changes into `curated_orders`. CDC without a third-party tool.

### Best Practices
- Use `SYSTEM$STREAM_HAS_DATA` in task WHEN clause to avoid empty runs
- Set appropriate `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors
- Use serverless tasks unless you need to control the warehouse size
- Prefer dynamic tables over stream+task for pure transformation pipelines
- Monitor tasks via `TASK_HISTORY` in ACCOUNT_USAGE

**Exam trap:** IF YOU SEE "streams DON'T work on views" → WRONG because streams DO work on views. `CREATE STREAM ... ON VIEW <view_name>` is valid syntax and works on both regular views and secure views.

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

### Example Scenario Questions — Streams & Tasks

**Scenario:** An e-commerce platform needs to merge incremental order updates (inserts, updates, deletes) from a raw orders table into a curated orders table every 5 minutes. The merge logic includes custom conflict resolution (e.g., latest timestamp wins for updates). What pipeline architecture should the architect use?
**Answer:** Create a standard stream on the raw orders table to capture all DML changes (inserts, updates, deletes). Create a task with a 5-minute schedule and a `WHEN SYSTEM$STREAM_HAS_DATA('orders_stream')` clause to avoid empty runs. The task body executes a MERGE statement that reads from the stream and applies custom conflict resolution logic (e.g., `WHEN MATCHED AND src.updated_at > tgt.updated_at THEN UPDATE`). Use serverless tasks unless the MERGE is complex enough to warrant a dedicated warehouse. Set `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors and monitor via `TASK_HISTORY`.

**Scenario:** A data platform has a complex ETL pipeline: raw data must be cleaned, then enriched with reference data, then aggregated into summary tables. Each step depends on the previous one completing successfully. If any step fails, a notification must be sent. How should the architect orchestrate this?
**Answer:** Build a task tree (DAG). The root task runs on a schedule and performs the cleaning step. A child task handles enrichment (triggered automatically on root success). A grandchild task handles aggregation. Add a finalizer task to the DAG — it runs after all tasks complete (whether they succeed or fail) and sends an email notification with the outcome. Only the root task has a schedule; children trigger on parent completion. Use `ALLOW_OVERLAPPING_EXECUTION = FALSE` on the root to prevent concurrent runs. Alternatively, if the pipeline is pure SQL transformations without custom merge logic, consider chaining dynamic tables instead — they handle scheduling and incremental refresh declaratively.

---

## 3.4 EXTERNAL & ICEBERG TABLES

**External Tables**

- Read-only table over files in external storage (S3, GCS, Azure)
- Snowflake stores only metadata; data stays in your cloud storage
- Supports auto-refresh of metadata via cloud notifications
- Query performance is slower than native tables (no clustering, no micro-partition optimization)
- Support for partitioning via `PARTITION BY` computed columns
- Streams on external tables: insert-only (tracks new files)

**External Tables -- Deep Dive (Exam Details)**

- **External table schema columns:** The schema includes: `VALUE` (VARIANT with row data), `METADATA$FILE_ROW_NUMBER`, `METADATA$FILENAME`. NOT valid: `METADATA$EXTERNAL_TABLE_PARTITION`, `METADATA$ROW_ID`.
- **Partition columns are virtual columns:** Defined using expressions computed from the file path (e.g., `PARTITION_DATE DATE AS TO_DATE(SPLIT_PART(METADATA$FILENAME, '/', 3))`). They are not stored in the data files -- they are derived at query time from the stage path structure.
- **Partitioning for performance:** The single most effective performance improvement for external tables is adding partition columns. This enables Snowflake to prune irrelevant files (partition pruning), processing only relevant subsets of data.
- **External table vs directory table:** External tables query file **contents** (actual data rows). Directory tables query file **metadata** (file name, size, last modified). They serve different purposes and are not interchangeable.
- **Search optimization on external tables:** Search optimization service can be applied to external tables to improve point lookup performance, especially on VARIANT columns containing semi-structured data.

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

### Example Scenario Questions — External & Iceberg Tables

**Scenario:** A company's data science team uses Apache Spark on EMR to train ML models, and the analytics team uses Snowflake for reporting. Both teams need read/write access to the same feature store tables. Currently, data is duplicated in both Parquet files and Snowflake tables, causing consistency issues. How should the architect unify the data layer?
**Answer:** Migrate the feature store to managed Iceberg tables in Snowflake. Define an external volume pointing to S3 where the Iceberg data and metadata files will be stored. Snowflake manages the table lifecycle — full DML (INSERT, UPDATE, DELETE, MERGE), compaction, and snapshot management. The Spark team reads the same Iceberg metadata and data files from S3 directly using Spark's Iceberg connector. One copy of data, two engines, full consistency. Managed Iceberg tables also support Time Travel and clustering for the Snowflake analytics team.

**Scenario:** A partner organization manages their data catalog in AWS Glue and writes Iceberg tables from their Spark pipelines. Your company needs to query this data from Snowflake without taking ownership of the catalog. How should the architect set this up?
**Answer:** Create an unmanaged (catalog-linked) Iceberg table in Snowflake. Configure a catalog integration pointing to the partner's AWS Glue catalog. Snowflake reads the Glue-managed Iceberg metadata to understand the table structure and queries the data files directly from S3. This is read-only from Snowflake — all writes continue through the partner's Spark pipelines. Enable auto-refresh on the catalog integration so Snowflake detects when the partner updates the table. Do not use a managed Iceberg table here, as that would transfer catalog ownership to Snowflake and conflict with the partner's Spark writes.

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

**External Functions & Parsing -- Deep Dive (Exam Details)**

- **External function requirements:** Must use HTTPS endpoints. Input/output is JSON format. Returns scalar values only (one output per input row).
- **External function costs:** Data transfer charges (data leaves Snowflake to the API) + warehouse compute for the calling query. The external API provider (Lambda, Azure Functions) may also charge independently.
- **External function limitations:** Cannot be stored procedures (only functions). Must return a scalar value (one per input row). Cannot return multiple values. Future grants on external functions are NOT supported.
- **External function batch processing:** Snowflake sends rows in batches to the remote service. The remote service must accept JSON arrays and return JSON arrays of the same length. Batch size is controlled by Snowflake automatically.
- **TRY_PARSE_JSON vs PARSE_JSON:** `TRY_PARSE_JSON` returns NULL on parse failure. `PARSE_JSON` throws an error. Use TRY_ variant for defensive parsing of untrusted data.
- **Stored procedure CALLER vs OWNER rights:** `CALLER` rights = procedure runs with the **invoker's** privileges (good for dynamic, user-context-dependent operations). `OWNER` rights = procedure runs with the **definer's** privileges (good for elevated-privilege admin tasks). CALLER rights cannot access objects the caller doesn't have privileges on. OWNER rights can access objects the owner has privileges on regardless of the caller.
- **Task + UDTF pattern:** For automated pipelines that require import, join, and aggregation across multiple file types (e.g., Parquet + CSV), use a scheduled task that calls a Tabular UDF (UDTF). Materialized views cannot perform joins, so a UDTF is the correct choice for producing joined/aggregated results.
- **Resource monitors for pipeline cost control:** Resource monitors can be applied to warehouses running data pipelines. They monitor credit consumption and can suspend the warehouse or send notifications when thresholds are reached. They do NOT prevent duplicate data or limit concurrent queries.

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
- Streams on dynamic tables are supported (since 2024) for change tracking on dynamic table output

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

**Exam trap:** IF YOU SEE "dynamic tables cannot be sources for streams" → WRONG because streams on dynamic tables have been supported since 2024. You CAN create streams on dynamic tables for change tracking.

**Exam trap:** IF YOU SEE "external functions run inside Snowflake compute" → WRONG because they call an external API endpoint outside Snowflake.

**Exam trap:** IF YOU SEE "FLATTEN only works with JSON" → WRONG because FLATTEN works with any semi-structured type: VARIANT, ARRAY, OBJECT.

### Common Questions (FAQ)
**Q: Can I use Python UDFs in materialized views?**
A: No. MVs only support SQL expressions (no UDFs, no external functions).

**Q: What's the difference between target lag DOWNSTREAM and a specific interval?**
A: DOWNSTREAM means "refresh whenever my upstream dynamic table refreshes." A specific interval (e.g., 5 MINUTES) means "ensure data is no older than 5 minutes."

**Q: Can dynamic tables reference other dynamic tables?**
A: Yes. This creates a dynamic table pipeline (DAG), where upstream refreshes cascade downstream.

### Example Scenario Questions — Data Transformation

**Scenario:** A data platform ingests raw JSON events with deeply nested arrays (e.g., an order contains an array of items, each item contains an array of discounts). The analytics team needs a flat, relational table with one row per discount. Some orders have no discounts and must still appear in the output. How should the architect design the transformation?
**Answer:** Use nested LATERAL FLATTEN to expand the multi-level arrays. First FLATTEN the items array, then FLATTEN the discounts array within each item. Use `OUTER => TRUE` on the discounts FLATTEN to preserve orders/items that have empty discount arrays (they appear as NULL discount rows instead of being dropped). The query pattern: `SELECT ... FROM orders, LATERAL FLATTEN(INPUT => items, OUTER => TRUE) AS i, LATERAL FLATTEN(INPUT => i.VALUE:discounts, OUTER => TRUE) AS d`. Materialize this as a dynamic table with an appropriate target lag so the flat table stays current as new events arrive.

**Scenario:** A company has a complex transformation pipeline: raw → cleaned → enriched → aggregated. Currently this is managed with 4 stream+task pairs, and the team spends significant time debugging task failures, managing stream staleness, and handling scheduling edge cases. How should the architect simplify this?
**Answer:** Replace the stream+task chain with a pipeline of dynamic tables. Define each layer as a dynamic table with a SQL query referencing the previous layer: `raw_dt → cleaned_dt → enriched_dt → aggregated_dt`. Set target lag based on business SLAs — the final aggregated table might use `TARGET_LAG = '5 MINUTES'` while intermediate tables use `TARGET_LAG = DOWNSTREAM` (refresh when downstream needs data). Snowflake handles scheduling, incremental refresh, and error management declaratively. This eliminates manual stream offset management, task scheduling, and staleness risks. Note: dynamic tables work best for pure SQL transformations; if you need custom merge logic or procedural control flow, stream+task remains appropriate.

**Scenario:** The data engineering team needs a stored procedure that loops through all databases in the account, creates a governance tag on each, and grants APPLY TAG privileges to a specific role. A junior engineer asks why they can't use a UDF for this. What should the architect explain?
**Answer:** UDFs cannot execute DML or DDL statements — they are read-only functions usable in SELECT. This task requires DDL (`CREATE TAG`) and DCL (`GRANT`) operations, which only stored procedures can perform. Create a stored procedure using Snowflake Scripting (SQL) with a RESULTSET cursor to iterate over `SHOW DATABASES`, then execute `CREATE TAG IF NOT EXISTS` and `GRANT APPLY TAG` for each database. The procedure should run with CALLER rights so it executes under the invoking role's permissions, ensuring proper authorization checks.

---

## 3.6 KAFKA CONNECTOR

**Kafka Connector for Snowflake:**
- Streams data from Apache Kafka topics into Snowflake tables
- **Auto-creates objects:** For each topic, the connector creates: a target table, an internal stage, and a pipe (one pipe per partition)
- **Table columns:** Two VARIANT columns: `RECORD_CONTENT` (the message payload) and `RECORD_METADATA` (offset, partition, topic, timestamp)
- **Supported formats:** JSON and Avro **only** (no CSV, no Parquet, no ORC)
- **Authentication:** Uses **2048-bit RSA key pair** (same as key-pair auth for service accounts). Does NOT support OAuth or basic username/password.
- **Failed file handling:** Failed files are moved to the **table stage** for the target table (not user stage, not deleted)
- **Cost optimization:** Increase `buffer.flush.time` to batch more records per flush, reducing the number of pipe ingestion operations. Higher flush time = lower cost but higher latency.
- **Required privileges:** The connector's role needs: CREATE TABLE, CREATE STAGE, CREATE PIPE on the target schema
- **Two ingestion modes:** Snowpipe-based (files to internal stage, then pipe loads them) and Snowpipe Streaming-based (direct row insert, lower latency, no intermediate files)
- **Auto-table creation from unmapped topics:** If the connector subscribes to topics not explicitly mapped to tables, it auto-creates a table using the topic name and adds the standard two VARIANT columns.
- **Dropping Kafka connector pipes:** Use standard `DROP PIPE <pipe_name>` syntax. There is no special Kafka-specific command.
- **Default Kafka topic retention:** Kafka's default is **7 days** (not 14). This is a Kafka setting, not a Snowflake setting.

**Exam trap:** IF YOU SEE "Kafka connector supports CSV format" → WRONG because only JSON and Avro are supported.

**Exam trap:** IF YOU SEE "Kafka connector creates one pipe per topic" → WRONG because it creates one pipe per PARTITION within each topic.

**Exam trap:** IF YOU SEE "RECORD_CONTENT is a VARCHAR column" → WRONG because both RECORD_CONTENT and RECORD_METADATA are VARIANT columns.

**Exam trap:** IF YOU SEE "Kafka connector uses OAuth authentication" → WRONG because it uses key pair authentication with a 2048-bit RSA minimum.

**Exam trap:** IF YOU SEE "Failed Kafka files are deleted" → WRONG because failed files are moved to the table stage associated with the target table.

---

## 3.7 ECOSYSTEM CONNECTIVITY

**SQL REST API:**
- No client installation required -- call Snowflake from any HTTP client
- Supports: read (SELECT) and write (INSERT, UPDATE, DELETE) operations
- Supports ROLLBACK and multiple SQL statements in a single API call
- Supports asynchronous execution
- Does NOT support: PUT or GET commands (file staging)

**Spark Connector transfer modes:**
- **Internal mode:** Snowflake manages a temporary storage location for data transfer between Spark and Snowflake
- **External mode:** User provides their own cloud storage location for the transfer
- Internal mode is simpler; external mode gives more control over intermediate data

**dbt with Snowflake:**
- dbt handles the **T in ELT** -- transformation and testing only
- Does NOT handle data loading or replication
- Use dbt for: testing data quality, building transformation models, documentation
- Not a replacement for Snowpipe, COPY INTO, or replication

**Data Vault 2.0 patterns in Snowflake:**
- **Multi-table INSERT:** Enables parallel loading of hubs and satellites from a single staging table in one statement
- **HASH_DIFF:** Used for satellite change detection (compare current vs new record hash). Note: it's `HASH_DIFF`, NOT "HASH_DELTA"
- SHA2-512 recommended for hash keys to minimize collision risk

**ELT vs ETL decision framework:**

| Factor | ELT (preferred in Snowflake) | ETL |
|---|---|---|
| Scalability | Higher -- uses Snowflake compute for transforms | Lower -- transform engine is a bottleneck |
| Error recovery | Easier -- raw data is in Snowflake, re-transform | Harder -- must reload from source |
| Flexibility | High -- change transforms without reloading | Low -- transform logic baked into pipeline |
| When to use | Most Snowflake workloads | When source data requires pre-processing before loading |

Note: COPY INTO DOES support some inline transformations (type cast, column subset), blurring the ELT/ETL boundary.

**Transaction behavior in Snowflake:**
- DDL statements **implicitly commit** any active transaction (auto-commit on DDL)
- `BEGIN TRANSACTION` / `BEGIN WORK` starts an explicit transaction
- `COMMIT WORK` / `ROLLBACK WORK` ends it
- AUTOCOMMIT cannot be changed inside a stored procedure
- Explicit transactions should contain only DML and query statements. DDL (CREATE, ALTER, DROP) will auto-commit the transaction prematurely.

**Connectivity decision guide:**

| Need | Use | Why NOT the others |
|---|---|---|
| No software installation on app server | **SQL REST API** | JDBC, ODBC, SnowSQL all require client installation |
| File download from internal stage | **GET command in SnowSQL** | GET is not available in Snowsight Worksheets or via SQL REST API |
| Stateless serverless functions (Lambda) | **SQL REST API** | JDBC/ODBC connection pooling is impractical in short-lived functions |
| Existing Spark infrastructure | **Spark Connector** | Snowpark requires rewriting; Spark connector integrates natively |
| All compute inside Snowflake | **Snowpark** | Python connector pulls data out; Snowpark keeps it in Snowflake |

**Continuous ELT pipeline components:** A typical continuous ELT pipeline uses Snowpipe (ingestion) + Streams (CDC) + Tasks (scheduling) + Stored Procedures/Dynamic Tables (transformation). **Data Exchange is NOT a pipeline component** -- it is for data collaboration and sharing between accounts.

**Exam trap:** IF YOU SEE "SQL REST API supports PUT/GET" → WRONG because PUT and GET (file staging commands) are not supported via the REST API.

**Exam trap:** IF YOU SEE "dbt handles data loading into Snowflake" → WRONG because dbt only handles transformation and testing, not loading.

---

## 3.8 ECOSYSTEM TOOLS

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

**Exam trap:** IF YOU SEE "the Kafka connector only supports JSON" → WRONG because it supports both JSON and Avro formats.

### Common Questions (FAQ)
**Q: When should I use the Spark connector vs Snowpark?**
A: Use Spark connector when you already have Spark infrastructure and need to integrate Snowflake into existing pipelines. Use Snowpark when you want to run all compute in Snowflake without a Spark cluster.

**Q: Can the SQL API handle large result sets?**
A: Yes, via result set pagination. Large results are returned in partitions that you fetch incrementally.

**Q: Does the Kafka connector support schema evolution?**
A: Yes. New fields in JSON payloads are loaded into the VARIANT column. If you use schema evolution on the target table, columns are auto-added.

### Example Scenario Questions — Ecosystem Tools

**Scenario:** A company has an existing Spark-based ML pipeline on Databricks that processes 500 GB of features daily. They're migrating analytics to Snowflake but don't want to rewrite the Spark pipeline. The Spark pipeline needs to read from and write to Snowflake tables. How should the architect integrate the two systems?
**Answer:** Use the Snowflake Spark connector. Configure it with the Snowflake connection parameters (`sfURL`, `sfUser`, `sfWarehouse`, etc.) and use key-pair authentication for the service account. The Spark connector supports bidirectional data movement and pushes predicates down to Snowflake when reading (minimizing data transfer). For the longer-term, evaluate migrating the ML pipeline to Snowpark — which runs the DataFrame API directly on Snowflake compute without moving data out. But for immediate integration without rewriting, the Spark connector is the correct choice.

**Scenario:** A microservices architecture on AWS Lambda needs to execute Snowflake queries. The Lambda functions are stateless, short-lived, and cannot maintain persistent database connections. What connectivity approach should the architect recommend?
**Answer:** Use the Snowflake SQL API (REST). Lambda functions submit SQL statements via HTTP POST, then poll for status and fetch results asynchronously. The SQL API supports OAuth or key-pair tokens for authentication — no persistent database connections needed. This fits the stateless, ephemeral nature of Lambda. For larger result sets, the API returns paginated results that Lambda can fetch incrementally. Avoid JDBC/ODBC in Lambda since connection pooling is impractical in short-lived serverless functions.

**Scenario:** A data science team currently extracts 100 GB of data from Snowflake to their local Python environment using the Python connector and pandas for feature engineering. The extraction takes 45 minutes and overwhelms local memory. How should the architect improve this workflow?
**Answer:** Migrate the feature engineering logic to Snowpark. Snowpark provides a pandas-like DataFrame API that executes directly on Snowflake's compute — no data extraction needed. The data stays in Snowflake, operations are lazily evaluated and pushed down to the warehouse, and results are only materialized on `.collect()` or when writing to a table. This eliminates the 45-minute extraction, local memory constraints, and data movement costs. Snowpark supports Python UDFs and stored procedures for complex ML logic that can't be expressed in SQL.

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

## DON'T MIX -- Data Engineering Concepts the Exam Swaps

### COPY INTO vs Snowpipe vs Snowpipe Streaming -- The Decision Tree

You know all three. The exam tests WHEN to pick each one. Anchor on one word per option.

| | COPY INTO | Snowpipe | Snowpipe Streaming |
|---|---|---|---|
| Trigger | YOU run it (manual/scheduled) | FILE arrives (cloud event) | APP pushes rows (SDK call) |
| Input | Files on a stage | Files on a stage | Rows (no files) |
| Latency | Minutes to hours (batch window) | Seconds to minutes | Sub-second |
| Object | None (it's a command) | PIPE | CHANNEL |
| Compute | YOUR warehouse | Serverless | Serverless |
| Dedup | No automatic dedup | 14-day file dedup | SDK handles offsets |

**RULE:** Files you control the schedule = COPY INTO. Files arrive unpredictably = Snowpipe. No files at all, raw rows = Streaming.

**The trap:** "Snowpipe Streaming uses a PIPE object" -- WRONG. Streaming uses CHANNELS via the Ingest SDK. PIPE is for regular Snowpipe only.

**The trap:** "Use Snowpipe for IoT with sub-second latency" -- WRONG. Snowpipe is file-based (seconds to minutes). For sub-second you need Streaming.

### Stream vs Change Tracking

Both track changes. The exam tests when you pick each one.

| | Stream | Change Tracking |
|---|---|---|
| Object type | Dedicated object (`CREATE STREAM`) | Property on a table (`SET CHANGE_TRACKING = TRUE`) |
| Offset | Consumable -- advances after DML reads it | No offset -- query any point in time, idempotent |
| Goes stale? | YES (Time Travel + 14 days) | No (as long as Time Travel window covers it) |
| Use case | Pipeline that processes changes ONCE (stream+task) | Ad-hoc "what changed since X?" queries |

**RULE:** Stream = "process changes exactly once, then move forward." Change Tracking = "peek at changes without consuming them."

**The trap:** "Use a stream for ad-hoc change queries" -- works but overkill. Change Tracking + CHANGES clause is simpler and doesn't risk staleness.

### Dynamic Table vs Stream+Task Pipeline

Both build transformation pipelines. The exam tests the boundary.

| | Dynamic Table | Stream + Task |
|---|---|---|
| Approach | Declarative: "here's my SQL + target lag" | Imperative: "here's my stream, here's my task, here's my MERGE" |
| Scheduling | Snowflake manages it (target lag) | You manage it (CRON/interval) |
| Custom MERGE logic? | NO (it's a SELECT, not a MERGE) | YES (full control over conflict resolution) |
| Error handling | Snowflake retries automatically | You handle it (SUSPEND_TASK_AFTER_NUM_FAILURES) |
| Staleness risk? | No (no stream to go stale) | YES (stream can go stale if task fails) |
| Chaining | DT references DT (automatic cascade) | Stream+task+stream+task (manual wiring) |

**RULE:** Pure SQL transforms with no custom merge = Dynamic Table. Custom MERGE with conflict resolution or procedural logic = Stream+Task.

**The trap:** "Dynamic tables replace stream+task in ALL cases" -- WRONG. If you need MERGE with `WHEN MATCHED AND src.ts > tgt.ts THEN UPDATE`, you need stream+task.

### Schema Detection vs Schema Evolution

| | Schema Detection | Schema Evolution |
|---|---|---|
| When | ONE TIME (at table creation) | ONGOING (every load) |
| Function | `INFER_SCHEMA()` / `USING TEMPLATE` | `ENABLE_SCHEMA_EVOLUTION = TRUE` |
| What it does | Reads files to discover columns/types | Auto-adds NEW columns to existing table |
| Removes columns? | N/A (creates fresh) | NEVER removes columns |

**RULE:** Detection = discover schema once. Evolution = adapt schema continuously. Use both together: detection for initial DDL, evolution for ongoing changes.

### UDF vs Stored Procedure -- The Side Effect Rule

| | UDF | Stored Procedure |
|---|---|---|
| Returns | A value (scalar or table) | A status/result |
| Called from | SELECT, WHERE, JOIN | CALL statement only |
| Can do DML? | NO (read-only) | YES (INSERT, UPDATE, DELETE, DDL) |
| Side effects? | NONE allowed | Yes (that's the point) |
| Use in MV? | SQL UDFs only (no Python/Java) | Cannot be used in MVs |

**RULE:** If it needs to CHANGE data or run DDL = Stored Procedure. If it COMPUTES a value = UDF.

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
**A11:** Yes (since 2024). Streams on dynamic tables are supported for change tracking on dynamic table output.

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
