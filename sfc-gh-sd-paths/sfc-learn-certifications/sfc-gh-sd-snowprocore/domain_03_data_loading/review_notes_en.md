# DOMAIN 3: DATA LOADING, UNLOADING & CONNECTIVITY
## 18% of exam = ~18 questions

---

## 3.1 STAGES (VERY HEAVILY TESTED)

A stage = a location where data files sit before/after loading.

### Three types of INTERNAL stages:

| Stage | Symbol | Scope | Who uses it |
|---|---|---|---|
| User stage | @~ | One user, many tables | Personal file storage |
| Table stage | @%table_name | Many users, ONE table | Tied to a specific table |
| Named stage | @stage_name | Many users, many tables | Most flexible, recommended |

### Key rules:
- **User stage** (@~): auto-created per user. Cannot be altered or dropped. Cannot set file format.
- **Table stage** (@%table): auto-created per table. Cannot be altered or dropped. No grantable privileges. Must be table owner.
- **Named stage** (CREATE STAGE): database object. Can set file format, encryption. Can grant privileges. Most control.

### External stages:
- Point to cloud storage: S3, Azure Blob, GCS
- Created with CREATE STAGE ... URL = 's3://bucket/path'
- Need storage integration OR credentials
- Can be used regardless of which cloud hosts your Snowflake account

### Why This Matters + Use Cases

**Real scenario — "We need data available within 1 minute of landing in S3"**
COPY INTO runs on a schedule (every 15 min). Not fast enough. Solution: Snowpipe with auto-ingest. S3 event notification triggers Snowpipe, data available in ~1 minute. Serverless, no warehouse needed.

**Real scenario — "PUT command fails with 'external stage not supported'"**
PUT only works with INTERNAL stages. For external stages (S3, Azure, GCS), upload files directly to your cloud storage using AWS CLI, Azure CLI, etc. Then use COPY INTO from the external stage.

**Real scenario — "Half our CSV rows have bad data and the load fails"**
Use ON_ERROR = CONTINUE to load good rows and skip bad ones. Or use VALIDATION_MODE = RETURN_ERRORS first to preview what would fail without loading anything.

---

### Best Practices — Stages
- Named stages over table/user stages for production (more control)
- External stages for cloud storage you already manage
- Always specify FILE_FORMAT when creating a stage

### File upload/download:
- **PUT** → upload files FROM local machine TO internal stage
- **GET** → download files FROM internal stage TO local machine
- PUT/GET only work with SnowSQL or Snowflake connectors (NOT Snowsight)
- PUT automatically compresses files (gzip by default)

**Exam trap**: "Upload file from laptop to stage?" → PUT command via SnowSQL. IF YOU SEE "COPY INTO" for local-to-stage → WRONG because COPY INTO loads stage-to-table, not local-to-stage.
**Exam trap**: "Download file from stage to laptop?" → GET command. IF YOU SEE "COPY INTO" for stage-to-local → WRONG because COPY INTO unloads to a stage, not to your local machine.
**Exam trap**: "Which stage type CANNOT be altered?" → User and Table stages. IF YOU SEE "ALTER STAGE @~" or "ALTER STAGE @%table" → WRONG because user/table stages cannot be altered or dropped.
**Exam trap**: "NOT a valid stage type?" → Warehouse Stage (does not exist). IF YOU SEE "warehouse stage" → trap! Only User (@~), Table (@%t), and Named (@s) stages exist.

### Example Scenario Questions — Stages

**Scenario:** A data engineer at a retail company needs to load daily sales CSV files from their laptop into a Snowflake table. They try running `COPY INTO sales_table FROM file:///tmp/sales.csv` but it fails. What is the correct approach?
**Answer:** Files must first be uploaded to an internal stage using the PUT command via SnowSQL (e.g., `PUT file:///tmp/sales.csv @~`), and then loaded with `COPY INTO sales_table FROM @~`. COPY INTO loads from a stage to a table — it cannot read directly from a local filesystem. PUT is the only way to move files from local to an internal stage, and it only works through SnowSQL or Snowflake connectors (not Snowsight).

**Scenario:** A team has 15 analysts who each need to upload their own data files to Snowflake, but the data all ends up in the same shared table. The DBA wants to control file format and grant access to other roles. Which stage type should they use?
**Answer:** A named internal stage (CREATE STAGE) is the best choice. Named stages are database objects that support setting file format options, encryption, and grantable privileges — so the DBA can control access via RBAC. User stages (@~) are per-user and cannot have file formats set. Table stages (@%table) cannot be granted to other roles and cannot be altered. Named stages provide the most flexibility for shared, production workloads.

**Scenario:** A company hosts their Snowflake account on Azure but stores raw data files in an AWS S3 bucket. Can they create a stage in Snowflake that points to S3?
**Answer:** Yes. External stages can point to any supported cloud provider (S3, Azure Blob, GCS) regardless of which cloud hosts the Snowflake account. They would create an external stage with `CREATE STAGE ... URL = 's3://bucket/path'` and use either a storage integration or direct credentials. Cross-cloud stages are fully supported.

---

## 3.2 FILE FORMATS

### Supported formats for LOADING:
- CSV (default)
- JSON
- Avro
- ORC
- Parquet
- XML

### NOT supported: HTML, PDF, Excel

### File Format objects:
- CREATE FILE FORMAT → reusable format definition
- Can set: delimiter, compression, date format, skip headers, etc.
- Can attach to a stage or use inline in COPY INTO

### Compression:
- Default for unloading: gzip
- Supported: gzip, bz2, Brotli, Zstandard, deflate, raw_deflate, none
- Snowflake auto-detects compression on loading

**Exam trap**: "Can Snowflake load Excel files?" → NO. IF YOU SEE "Excel" + "load" or "COPY INTO" → WRONG because only CSV, JSON, Avro, ORC, Parquet, XML are supported.
**Exam trap**: "Default file format for COPY INTO?" → CSV. IF YOU SEE "JSON" or "Parquet" as default → WRONG because CSV is always the default format.
**Exam trap**: "Do you need to specify compression when loading?" → NO. IF YOU SEE "must specify compression" → WRONG because Snowflake auto-detects compression on load.

### Example Scenario Questions — File Formats

**Scenario:** A partner sends your team a batch of Excel (.xlsx) files containing inventory data. The data engineer tries to load them directly with COPY INTO but gets an error. What should they do?
**Answer:** Snowflake does not support loading Excel files. The supported file formats are CSV, JSON, Avro, ORC, Parquet, and XML only. The partner must first convert the Excel files to a supported format (typically CSV) before uploading to a stage and loading with COPY INTO. Tools like Python (pandas) or Excel's "Save As CSV" can handle the conversion.

**Scenario:** A data pipeline sends gzip-compressed JSON files to an S3 bucket. The engineer creating the COPY INTO statement is unsure whether to specify `COMPRESSION = GZIP` in the file format. Is it required?
**Answer:** No. Snowflake auto-detects compression during loading, so specifying `COMPRESSION = GZIP` is optional. Snowflake will recognize the gzip format automatically and decompress the files. You only need to explicitly set compression if you want to override the auto-detection behavior (e.g., `COMPRESSION = NONE` to skip decompression).

**Scenario:** A team frequently loads CSV files with the same format settings (pipe-delimited, UTF-8, skip 2 header rows) across many different COPY INTO statements. What is the recommended approach to avoid repeating format options every time?
**Answer:** Create a reusable file format object with `CREATE FILE FORMAT my_csv_format TYPE = CSV FIELD_DELIMITER = '|' SKIP_HEADER = 2 ENCODING = 'UTF8'`. This format can then be referenced in stage definitions or directly in COPY INTO statements with `FILE_FORMAT = my_csv_format`. File format objects are database objects that can be shared across teams via grants and ensure consistency across all load operations.

---

## 3.3 COPY INTO (HEAVILY TESTED)

### Loading: COPY INTO table FROM stage
### Unloading: COPY INTO stage FROM table/query

### Loading behavior:
- Default: if ANY error → entire load fails and rolls back
- Tracks which files were already loaded (prevents duplicates within 64 days)
- Only loads files that haven't been loaded before (unless FORCE = TRUE)

### Key parameters:

**ON_ERROR** (what to do when error occurs):
- `ABORT_STATEMENT` (default) → fail entire load
- `CONTINUE` → skip bad rows, load the rest
- `SKIP_FILE` → skip files with errors
- `SKIP_FILE_n` → skip file if n+ errors
- `SKIP_FILE_n%` → skip file if n% errors

**VALIDATION_MODE** (check without loading):
- `RETURN_ERRORS` → show all errors
- `RETURN_n_ROWS` → parse first n rows
- Does NOT actually load data

**PURGE = TRUE**: delete source files after successful load

**FORCE = TRUE**: reload files even if already loaded

**MATCH_BY_COLUMN_NAME**: match source columns to table columns by name (not position)

**ERROR_ON_COLUMN_COUNT_MISMATCH**:
- TRUE (default) → error if column count differs
- FALSE → allow mismatch (extra columns ignored, missing = NULL)

### Transformations during load:
- Column reordering
- Column omission (skip columns)
- Type casting
- Text truncation
- Use SELECT in COPY INTO: `COPY INTO table FROM (SELECT $1, $2::date FROM @stage)`

### METADATA columns available during load:
- METADATA$FILENAME → source file name
- METADATA$FILE_ROW_NUMBER → row number in source file
- METADATA$FILE_CONTENT_KEY → content hash
- METADATA$FILE_LAST_MODIFIED → file timestamp
- METADATA$START_SCAN_TIME → scan start time

### Best Practices — Data Loading
- Use Snowpipe for continuous/real-time loading, COPY INTO for batch
- File size sweet spot: 100-250 MB compressed for optimal parallelism
- Use PURGE = TRUE to auto-delete staged files after successful load
- VALIDATION_MODE before first load to catch format issues
- Separate warehouses for loading vs querying
- Use file formats objects (reusable) instead of inline format options

**Exam trap**: "Include filename in table during load?" → METADATA$FILENAME in SELECT. IF YOU SEE "after load" + "get filename" → WRONG because METADATA$ columns are only available DURING the COPY INTO, not after.
**Exam trap**: "Check for errors without loading?" → VALIDATION_MODE. IF YOU SEE "ON_ERROR" for pre-load checking → WRONG because ON_ERROR controls behavior DURING load; VALIDATION_MODE checks WITHOUT loading.
**Exam trap**: "Delete source files after load?" → PURGE = TRUE. IF YOU SEE "REMOVE" or "DROP" for post-load cleanup → WRONG because PURGE = TRUE is the COPY INTO parameter that deletes source files.
**Exam trap**: "Default unload compression?" → gzip. IF YOU SEE "none" or "uncompressed" as default → WRONG because gzip is always the default for unloading.

### Example Scenario Questions — COPY INTO

**Scenario:** A healthcare company loads patient records nightly from CSV files in S3. One night, a file contains 50,000 rows but 200 rows have malformed date fields. The team wants to load the valid rows and investigate the bad ones later. What parameters should they use?
**Answer:** Use `ON_ERROR = CONTINUE` to skip the bad rows and load the remaining valid rows. After the load completes, use the `VALIDATE(table_name, job_id => '_last')` function to retrieve details about which rows failed and why. The default `ON_ERROR = ABORT_STATEMENT` would reject the entire file, losing all 49,800 good rows.

**Scenario:** A data engineer is loading files from an external stage but notices the same files keep getting loaded every time the COPY INTO runs, creating duplicates. What is happening and how can they fix it?
**Answer:** COPY INTO tracks loaded files for 64 days to prevent re-loading. If duplicates are occurring, possible causes include: (1) FORCE = TRUE is set, which overrides duplicate detection; (2) the files were modified after the initial load (different content hash); or (3) more than 64 days passed since the last load. Remove FORCE = TRUE if set, and ensure files are not being modified after initial load. The 64-day load metadata window is automatic and cannot be extended.

**Scenario:** Before loading a large batch of 10 million rows from Parquet files for the first time, the team wants to verify the data will parse correctly without actually inserting anything into the target table. How should they proceed?
**Answer:** Use `VALIDATION_MODE = RETURN_ERRORS` in the COPY INTO statement. This parses all files and returns any errors found without loading a single row. Alternatively, `VALIDATION_MODE = RETURN_n_ROWS` (e.g., RETURN_10_ROWS) parses just the first n rows as a quick sanity check. This is distinct from ON_ERROR, which controls behavior during an actual load — VALIDATION_MODE prevents any data from being loaded at all.

**Scenario:** A logistics company loads shipment data from CSV files but the CSV columns are ordered differently than the target Snowflake table. The CSV has columns: shipment_date, tracking_id, weight — but the table expects: tracking_id, shipment_date, weight. How can they handle this without changing the source files?
**Answer:** Use a SELECT transformation in the COPY INTO statement to reorder columns: `COPY INTO shipments FROM (SELECT $2, $1, $3 FROM @my_stage) FILE_FORMAT = (TYPE = CSV)`. The $N references correspond to the positional columns in the source file. Alternatively, if the CSV has headers, use `MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE` to match source columns to target columns by name instead of position.

---

## 3.4 VALIDATE FUNCTION

- VALIDATE(table, job_id) → review errors from a previous COPY INTO
- Shows which rows failed and why
- Use after a load with ON_ERROR = CONTINUE

**Exam trap**: "VALIDATE vs VALIDATION_MODE?" → VALIDATE = after load. VALIDATION_MODE = before load. IF YOU SEE "VALIDATE" for pre-load checking → WRONG because VALIDATE reviews PAST errors; VALIDATION_MODE checks WITHOUT loading.
**Exam trap**: "VALIDATE(table, job_id) requires which ON_ERROR?" → CONTINUE. IF YOU SEE "ABORT_STATEMENT" with VALIDATE → WRONG because aborted loads have no skipped rows to review; CONTINUE skips bad rows so VALIDATE can find them.

### Example Scenario Questions — Validate Function

**Scenario:** A data engineer loaded 500 CSV files into a transactions table using `ON_ERROR = CONTINUE`. The load completed but they know some rows were skipped. How can they find out exactly which rows failed and why?
**Answer:** Use `SELECT * FROM TABLE(VALIDATE(transactions, job_id => '_last'))` to retrieve all rejected rows from the most recent COPY INTO job. The VALIDATE function returns the row data, the error message, and the file/line information for each rejected row. The `_last` shortcut references the most recent load job, or a specific job_id can be provided. This only works when ON_ERROR = CONTINUE was used because ABORT_STATEMENT stops the load entirely, leaving no skipped rows to review.

**Scenario:** A junior engineer runs `VALIDATE(orders, job_id => '_last')` but gets no results, even though they know there were errors in the source files. Their COPY INTO used the default ON_ERROR setting. What went wrong?
**Answer:** The default ON_ERROR setting is ABORT_STATEMENT, which causes the entire load to fail and roll back on the first error — no rows are loaded and no rows are "skipped." VALIDATE only returns rows that were skipped during a successful load with ON_ERROR = CONTINUE (or SKIP_FILE). Since the load was aborted, there are no skipped rows to review. The engineer should re-run the load with ON_ERROR = CONTINUE, or use VALIDATION_MODE = RETURN_ERRORS to preview errors without loading.

---

## 3.5 SNOWPIPE (HEAVILY TESTED)

### What it is:
- Continuous, automated data loading
- Serverless (Snowflake manages compute)
- Loads files as soon as they arrive in the stage
- Near real-time (within minutes)

### How it works:
1. Files land in stage (S3, Azure, GCS, or internal)
2. Notification triggers Snowpipe (cloud event notification OR REST API call)
3. Snowpipe loads the data using a COPY INTO defined in the pipe
4. Files tracked to prevent reloading

### Billing:
- Per-second compute charge (serverless)
- Based on number of files and compute used
- NOT billed by warehouse credits (no warehouse needed)

### Recommended file size: 100-250 MB compressed
- Smaller files = more overhead per file
- Larger files = slower to start loading

### Key objects/functions:
- CREATE PIPE ... AS COPY INTO table FROM @stage
- SYSTEM$PIPE_STATUS(pipe_name) → check pipe health
- COPY_HISTORY (INFORMATION_SCHEMA / ACCOUNT_USAGE) → load history
- VALIDATE_PIPE_LOAD() → returns pipe activity within last 14 days

### Snowpipe can load from:
- External stages (S3, Azure, GCS)
- Internal stages (yes, Snowpipe works with internal stages too)

### Auto-ingest:
- AUTO_INGEST = TRUE in pipe definition
- Requires cloud event notification (S3 SQS, Azure Event Grid, GCP Pub/Sub)

**Exam trap**: "Snowpipe compute model?" → Serverless (Snowflake-managed). IF YOU SEE "warehouse" with Snowpipe → trap! Snowpipe is SERVERLESS — no warehouse needed.
**Exam trap**: "Snowpipe recommended file size?" → 100-250 MB compressed. IF YOU SEE "1 GB" or "10 MB" as recommended → WRONG because 100-250 MB compressed is the sweet spot.
**Exam trap**: "Can Snowpipe load from internal stage?" → YES. IF YOU SEE "external only" for Snowpipe → WRONG because Snowpipe works with BOTH internal and external stages.
**Exam trap**: "Pipe health check?" → SYSTEM$PIPE_STATUS. IF YOU SEE "PIPE_USAGE_HISTORY" for health check → WRONG because SYSTEM$PIPE_STATUS checks pipe health; PIPE_USAGE_HISTORY shows billing/history.
**Exam trap**: "STALLED_COMPILATION status?" → SQL in pipe is invalid or schema mismatch. IF YOU SEE "network issue" or "permission error" for STALLED_COMPILATION → WRONG because it means the COPY INTO SQL inside the pipe won't compile.

### Example Scenario Questions — Snowpipe

**Scenario:** An e-commerce company receives order files in an S3 bucket throughout the day and needs them loaded into Snowflake within minutes of arrival. They currently run a scheduled COPY INTO every hour from a warehouse. How should they redesign this for near-real-time loading?
**Answer:** Replace the scheduled COPY INTO with Snowpipe. Create a pipe with `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO orders FROM @s3_stage`. Configure an S3 event notification (SQS queue) on the bucket to trigger Snowpipe whenever a new file lands. Snowpipe is serverless (no warehouse needed), loads files within minutes of arrival, and bills per-second based on actual compute used — far more efficient than keeping a warehouse running hourly.

**Scenario:** A team sets up Snowpipe and notices their loading costs are higher than expected. They are sending thousands of 1 KB files per minute. What is the likely issue?
**Answer:** The files are far too small. Snowflake recommends 100-250 MB compressed files for Snowpipe. Each file incurs overhead for scheduling and processing, so thousands of tiny files create excessive per-file overhead. The team should batch or aggregate their source files before landing them in the stage — for example, buffer records and write larger files at intervals. This reduces the number of files Snowpipe processes and significantly lowers costs.

**Scenario:** A data engineer creates a Snowpipe and checks `SYSTEM$PIPE_STATUS('my_pipe')` which returns a status of STALLED_COMPILATION. Files are landing in the stage but nothing is being loaded. What should they investigate?
**Answer:** STALLED_COMPILATION means the SQL defined inside the pipe (the COPY INTO statement) is invalid or references objects that no longer match. Common causes: the target table was dropped or renamed, a column was removed from the table, the stage was altered, or the file format changed. The engineer should check that the COPY INTO statement in the pipe definition still compiles correctly by verifying the target table schema, stage, and file format all match the pipe's SQL.

---

## 3.6 SNOWPIPE STREAMING (NEW for COF-C03)

### What it is:
- Load ROW-LEVEL data directly to Snowflake (no files needed)
- Uses Snowflake Ingest SDK (Java SDK) and Python SDK (high-performance, NOT REST API — REST API is for regular Snowpipe)
- Lowest latency option (sub-second)
- No staging files required

### Difference from regular Snowpipe:
| | Snowpipe | Snowpipe Streaming |
|---|---|---|
| Input | Files in stage | Rows via SDK/API |
| Latency | Minutes | Seconds |
| Staging | Required | Not required |
| Trigger | File notification | API call |

### Kafka Connector:
- Snowflake Connector for Kafka
- Runs in customer's Kafka environment (Confluent or self-hosted)
- Can use Snowpipe Streaming for lower latency
- Reads from Kafka topics → writes to Snowflake tables

**Exam trap**: "Snowpipe Streaming needs files in a stage?" → WRONG. IF YOU SEE "stage" + "Snowpipe Streaming" → trap! Rows are sent directly via SDK/API, NO staging required.
**Exam trap**: "Snowpipe Streaming latency?" → Sub-second (seconds). IF YOU SEE "minutes" for Streaming latency → WRONG because "minutes" is regular Snowpipe; Streaming = SECONDS.
**Exam trap**: "Kafka connector runs inside Snowflake?" → WRONG. IF YOU SEE "Snowflake-managed" + "Kafka connector" → trap! It runs in the CUSTOMER's Kafka environment.

### Example Scenario Questions — Snowpipe Streaming

**Scenario:** A manufacturing company has IoT sensors on their assembly line that emit temperature readings every 100 milliseconds. They need this data in Snowflake with sub-second latency for real-time quality monitoring dashboards. Regular Snowpipe takes minutes. What should they use?
**Answer:** Snowpipe Streaming is the correct choice. It accepts row-level data directly via the Snowflake Ingest SDK (Java) or REST API — no files or staging required. Data arrives in Snowflake within seconds (sub-second latency), compared to minutes with regular Snowpipe. The application would use the SDK to stream individual sensor readings directly into a Snowflake table without writing intermediate files.

**Scenario:** A company uses Apache Kafka for their event streaming platform and wants to sink Kafka topic data into Snowflake. They want the lowest possible latency. Where does the Kafka connector run, and which ingestion mode should they configure?
**Answer:** The Snowflake Connector for Kafka runs in the customer's own Kafka environment (e.g., Confluent Cloud, self-hosted Kafka cluster) — not inside Snowflake. To achieve the lowest latency, configure the connector to use Snowpipe Streaming mode instead of the default Snowpipe (file-based) mode. With Snowpipe Streaming, rows from Kafka topics are sent directly to Snowflake tables without staging files, achieving seconds-level latency instead of minutes.

**Scenario:** A developer is evaluating whether to use Snowpipe or Snowpipe Streaming for their data pipeline. Their source system generates one 200 MB CSV file every 5 minutes and drops it in S3. Which option is more appropriate?
**Answer:** Regular Snowpipe with auto-ingest is the better fit. Snowpipe Streaming is designed for row-level, API-based ingestion where there are no files — it excels when applications emit individual records. Since this pipeline already produces well-sized files (200 MB is within the recommended 100-250 MB range) landing in S3, Snowpipe with S3 event notifications is the natural choice. Snowpipe Streaming would require rewriting the source system to send rows via the SDK instead of writing files.

---

## 3.7 STREAMS (Change Data Capture)

### What they are:
- Track changes (INSERT, UPDATE, DELETE) on a table
- "Change Data Capture" (CDC)
- When you query a stream, you see what changed since last consumed

### Key columns in stream output:
- METADATA$ACTION → INSERT or DELETE
- METADATA$ISUPDATE → TRUE if it's an update (shows as DELETE + INSERT)
- METADATA$ROW_ID → unique row identifier

### Stream types:
- **Standard**: tracks all DML (INSERT, UPDATE, DELETE)
- **Append-only**: tracks only INSERTs
- **Insert-only**: for external tables (only new rows)

### Streams + Tasks = pipeline:
- Stream detects changes
- Task checks stream (SYSTEM$STREAM_HAS_DATA)
- If stream has data → Task runs and processes changes
- After consumption, stream advances (changes are "consumed")

**Exam trap**: "Task runs only when stream has data?" → WHEN SYSTEM$STREAM_HAS_DATA('stream_name') is an ADDITIONAL condition, but the task still needs a CRON or interval schedule to define WHEN to check. Both work together: the schedule defines how often to check, and the WHEN clause prevents the task from running if no new data exists. IF YOU SEE "CRON is not needed for stream-based tasks" → WRONG because the task still requires a schedule; the WHEN clause is an extra guard.
**Exam trap**: "Stream on external table?" → Insert-only stream. IF YOU SEE "standard" or "append-only" for external tables → WRONG because external tables only support INSERT-ONLY streams.

### Example Scenario Questions — Streams

**Scenario:** A finance team needs to build an audit trail that captures every change to the `accounts` table — inserts, updates, and deletes — so they can replicate changes to a downstream reporting table. Which stream type should they use, and how do updates appear in the stream?
**Answer:** Use a Standard stream, which tracks all DML operations (INSERT, UPDATE, DELETE). Updates appear as two rows in the stream: one DELETE row (the old values) and one INSERT row (the new values), both with `METADATA$ISUPDATE = TRUE`. The `METADATA$ACTION` column shows INSERT or DELETE, while `METADATA$ISUPDATE` distinguishes true inserts/deletes from updates. Standard streams are the default type and provide the full CDC picture needed for audit trails.

**Scenario:** A data engineering team has a stream on their `web_events` table, but nobody queried it for 3 weeks. The table's DATA_RETENTION_TIME_IN_DAYS is set to 14 days. When they query the stream, they get a stale stream error. What happened?
**Answer:** Streams rely on the table's Time Travel retention to track their offset position. Since the stream wasn't consumed within the 14-day retention window, the stream's offset fell outside the available Time Travel data and became STALE. Once stale, the stream cannot recover its change history — the CDC data is lost. To prevent this, either consume streams regularly (within the retention period) or increase the table's DATA_RETENTION_TIME_IN_DAYS to a value longer than the maximum gap between stream consumption.

**Scenario:** A company has an external table pointing to Parquet files in S3. They want to create a stream on it to detect when new files are added. Which stream type is supported?
**Answer:** Only Insert-only streams are supported on external tables. External tables do not support Standard or Append-only streams. An Insert-only stream will detect new rows that appear when new files are added to the external stage. It cannot track updates or deletes because external tables are read-only views over files in cloud storage — Snowflake has no control over file modifications or deletions at the source.

---

## 3.8 TASKS

### What they are:
- Schedule SQL execution
- Can run on a schedule (CRON or interval)
- Can depend on other tasks (DAG / task tree)
- Can be triggered by stream data

### Task tree (DAG):
- Root task → child tasks → grandchild tasks
- Root task has the schedule
- Child tasks run after parent completes
- Up to 1000 tasks in a tree

### Compute options:
- User-managed warehouse (you pay for warehouse)
- Serverless tasks (Snowflake manages compute, pay per use)

### Key: Tasks must be RESUMED to run (they start in SUSPENDED state)
- ALTER TASK task_name RESUME

**Exam trap**: "Tasks start in RUNNING state?" → WRONG. IF YOU SEE "RUNNING" as initial task state → trap! Tasks start SUSPENDED. Must ALTER TASK ... RESUME.
**Exam trap**: "Where does the schedule go in a task tree?" → Only the ROOT task. IF YOU SEE "schedule" on a child task → WRONG because child tasks fire AFTER parent completes, only the root has a schedule.
**Exam trap**: "Task compute options?" → User-managed warehouse OR serverless. IF YOU SEE "serverless only" or "warehouse only" → WRONG because BOTH options are valid for tasks.

### Example Scenario Questions — Tasks

**Scenario:** A data engineer creates a task to aggregate daily sales data every night at midnight. They run `CREATE TASK nightly_agg WAREHOUSE = analytics_wh SCHEDULE = 'USING CRON 0 0 * * * America/New_York' AS INSERT INTO daily_summary SELECT ...`. The task is created successfully, but it never runs. What did they forget?
**Answer:** Tasks are created in a SUSPENDED state by default. The engineer must run `ALTER TASK nightly_agg RESUME` to activate it. This is a common pitfall — until a task is explicitly resumed, it will never execute regardless of the schedule or warehouse configuration. This applies to all tasks, both root tasks and child tasks in a DAG.

**Scenario:** A team builds a data pipeline with a root task that runs every 10 minutes and three child tasks that perform transformations after the root completes. A new requirement comes in to add a fourth child task. Where should the schedule be defined, and what happens if they try to put a schedule on the child task?
**Answer:** The schedule belongs only on the root task. Child tasks fire automatically after their parent completes — they inherit execution timing from the dependency chain, not from their own schedule. Attempting to set a SCHEDULE on a child task that has an AFTER clause will result in an error. The new fourth child task should be created with `AFTER root_task` (or after another child if there's a dependency) and no SCHEDULE parameter. The DAG supports up to 1,000 tasks.

**Scenario:** A company wants to process CDC changes from a stream only when new data arrives, rather than running a task on a fixed schedule that wastes compute when there are no changes. How should they configure the task?
**Answer:** Use the `WHEN SYSTEM$STREAM_HAS_DATA('my_stream')` condition on the task. The task still needs a schedule (CRON or interval) that defines how often to check the condition, but the SQL body only executes when the stream actually has unconsumed data. For example: `CREATE TASK process_changes WAREHOUSE = etl_wh SCHEDULE = '5 MINUTE' WHEN SYSTEM$STREAM_HAS_DATA('orders_stream') AS MERGE INTO ...`. This avoids unnecessary warehouse spin-up when the stream is empty.

---

## 3.9 DYNAMIC TABLES (NEW for COF-C03)

### What they are:
- Declarative data pipelines
- Define a SQL query, set a "target lag" (freshness)
- Snowflake automatically keeps results up to date
- Replaces many Streams + Tasks pipelines

### Target lag:
- You set how fresh you need the data (e.g., 1 minute, 1 hour)
- Snowflake decides when to refresh
- Can be incremental or full refresh (Snowflake chooses)

### Advantages over Streams+Tasks:
- Simpler to define (just SQL + lag)
- Automatic refresh scheduling
- Can chain dynamic tables (DT reads from DT)

### Available ALL editions

**Exam trap**: "Dynamic Tables require Enterprise edition?" → WRONG. IF YOU SEE "Enterprise" or "Business Critical" as requirement → trap! Dynamic Tables are available on ALL editions.
**Exam trap**: "Dynamic Table vs Streams+Tasks?" → Dynamic Table = declarative (SQL + target lag). IF YOU SEE "Dynamic Table requires manual scheduling" → WRONG because Snowflake handles refresh automatically; Streams+Tasks is the manual/imperative approach.
**Exam trap**: "Who decides when a Dynamic Table refreshes — you or Snowflake?" → Snowflake decides. IF YOU SEE "user schedules refresh" → WRONG because you set the TARGET LAG and Snowflake decides when to refresh.

### Example Scenario Questions — Dynamic Tables

**Scenario:** A marketing team needs a summary table that joins customer data with purchase history and is never more than 10 minutes stale. They currently maintain this with a stream on the customers table, a stream on the purchases table, and a task that runs a complex MERGE every 5 minutes. The pipeline is brittle and hard to debug. What is a simpler alternative?
**Answer:** Replace the entire Streams + Tasks pipeline with a single Dynamic Table: `CREATE DYNAMIC TABLE customer_purchase_summary TARGET_LAG = '10 minutes' WAREHOUSE = analytics_wh AS SELECT c.*, p.total_spend FROM customers c JOIN purchases p ON c.id = p.customer_id`. Snowflake automatically determines when to refresh the table to meet the 10-minute target lag. This eliminates the need to manage streams, tasks, MERGE logic, and error handling — just define the SQL and the desired freshness.

**Scenario:** A data architect is building a multi-layer transformation pipeline: raw data → cleaned data → aggregated data. They want each layer to automatically stay fresh. Can Dynamic Tables be chained together?
**Answer:** Yes. Dynamic Tables can read from other Dynamic Tables, forming a chain. For example: `dt_clean` reads from a raw table, `dt_aggregated` reads from `dt_clean`. Each has its own TARGET_LAG. Snowflake coordinates refresh scheduling across the chain to ensure downstream tables stay within their lag targets. The upstream table refreshes first, then downstream tables refresh when their source changes. This creates a fully declarative, multi-layer pipeline with no manual orchestration.

**Scenario:** A colleague claims Dynamic Tables require Enterprise edition. A team on Standard edition wants to use them. Who is correct?
**Answer:** The colleague is wrong. Dynamic Tables are available on ALL Snowflake editions, including Standard. There is no edition restriction. The team on Standard edition can create and use Dynamic Tables with the same functionality — define a SQL query, set a target lag, and Snowflake handles the rest.

---

## 3.10 CONNECTORS & INTEGRATIONS

### Snowflake Connectors:
- Python Connector → Python apps connect to Snowflake
- JDBC Driver → Java apps
- ODBC Driver → General database connectivity
- Node.js Driver → JavaScript apps
- .NET Driver → C#/.NET apps
- Go Driver → Go apps

### Snowflake CLI (snow):
- Command-line tool
- Execute SQL, manage objects, deploy apps

### SnowSQL:
- Command-line client
- Execute SQL
- PUT/GET files (only way to upload/download from local)

### Storage Integration:
- Securely connect to external cloud storage
- Avoids storing credentials in stage definitions
- CREATE STORAGE INTEGRATION → define once, use in multiple stages

### API Integration:
- Connect to external APIs
- Used for external functions
- CREATE API INTEGRATION

### Git Integration (NEW for COF-C03):
- Connect Git repositories to Snowflake
- Store code (UDFs, procedures, Streamlit apps) in Git
- CREATE GIT REPOSITORY
- Version-controlled code management

**Exam trap**: "Storage Integration vs API Integration?" → Storage = cloud storage (S3/Azure/GCS). API = external REST APIs. IF YOU SEE "API Integration" for S3 access → WRONG because S3/Azure/GCS use STORAGE Integration; API Integration is for external functions.
**Exam trap**: "SnowSQL vs Snowflake CLI (snow)?" → Both are CLI tools. IF YOU SEE "SnowSQL deploys apps" or "snow CLI does PUT/GET" → WRONG because SnowSQL = older SQL client (PUT/GET); snow CLI = newer, manages objects + deploys apps.
**Exam trap**: "PUT/GET work in Snowsight web UI?" → WRONG. IF YOU SEE "Snowsight" + "PUT" or "GET" → trap! PUT/GET only work via SnowSQL or Snowflake connectors (Python, JDBC, etc.).

### Example Scenario Questions — Connectors & Integrations

**Scenario:** A company's data pipeline creates external stages pointing to multiple S3 buckets. Currently, each stage definition includes hardcoded AWS access keys and secret keys. The security team flags this as a risk. What is the recommended way to secure these connections?
**Answer:** Create a Storage Integration with `CREATE STORAGE INTEGRATION` that uses an IAM role-based trust relationship instead of embedded credentials. The integration is defined once and can be referenced by multiple stages. This eliminates hardcoded credentials from stage definitions, centralizes access management, and follows Snowflake's security best practices. The integration establishes trust between Snowflake's IAM identity and the customer's AWS IAM role.

**Scenario:** A DevOps engineer wants to store their Snowflake UDFs and stored procedures in a GitHub repository and deploy them through version-controlled workflows. Does Snowflake support native Git integration?
**Answer:** Yes. Snowflake supports Git Integration via `CREATE GIT REPOSITORY`, which connects a Git repository (GitHub, GitLab, etc.) directly to Snowflake. This allows teams to store UDFs, stored procedures, and Streamlit app code in Git with full version control. Code can be synced from the repository into Snowflake, enabling CI/CD-style deployments. This is a new feature for the COF-C03 exam and is separate from external tools like dbt.

**Scenario:** A new hire asks whether they should use SnowSQL or the Snowflake CLI (`snow`) to upload local CSV files to a Snowflake stage. Which tool supports PUT/GET?
**Answer:** SnowSQL is the correct tool for PUT/GET operations. The Snowflake CLI (`snow`) is a newer tool focused on managing Snowflake objects, deploying applications (Streamlit, Native Apps), and executing SQL — but it does not support PUT/GET file transfers. PUT and GET commands work only through SnowSQL or Snowflake language connectors (Python, JDBC, ODBC, etc.). They do not work in the Snowsight web UI either.

---

## 3.11 DIRECTORY TABLES

### What they are:
- Built-in catalog of files in a stage
- Query with SQL to see file metadata
- Available for both internal and external stages
- Provides: file name, size, MD5, last modified, etc.

### Enable on stage:
- CREATE STAGE ... DIRECTORY = (ENABLE = TRUE)
- Must refresh: ALTER STAGE ... REFRESH

**Exam trap**: "Directory tables auto-refresh?" → NO for external stages. IF YOU SEE "automatic" + "directory table refresh" on external stages → WRONG because you must run ALTER STAGE ... REFRESH (or configure auto-refresh explicitly).
**Exam trap**: "Directory table vs LIST command?" → Directory table = queryable with SQL. IF YOU SEE "LIST" for JOIN or WHERE filtering → WRONG because LIST is a simple file listing; Directory Tables support full SQL (JOIN, WHERE, etc.).

### Example Scenario Questions — Directory Tables

**Scenario:** A media company stores thousands of image files in an external stage (S3). They want to build a SQL query that joins file metadata (name, size, last modified) with a tracking table to find files that haven't been processed yet. Can they do this with the LIST command?
**Answer:** No. The LIST command returns a simple file listing that cannot be used in SQL joins, WHERE clauses, or subqueries. Instead, enable a Directory Table on the stage with `ALTER STAGE my_stage SET DIRECTORY = (ENABLE = TRUE)`, then run `ALTER STAGE my_stage REFRESH` to populate it. The directory table can then be queried with full SQL: `SELECT * FROM DIRECTORY(@my_stage) d LEFT JOIN processed_files p ON d.RELATIVE_PATH = p.file_name WHERE p.file_name IS NULL`. Directory tables provide file name, size, MD5, last modified, and other metadata as queryable columns.

**Scenario:** A data engineer enables a directory table on an external stage pointing to GCS. New files land in the bucket daily, but the directory table doesn't show them. What is missing?
**Answer:** Directory tables on external stages do not auto-refresh by default. The engineer must run `ALTER STAGE my_stage REFRESH` to update the directory table with newly arrived files. This can be automated by configuring auto-refresh with cloud event notifications (similar to Snowpipe auto-ingest), or by scheduling a task to run the refresh command periodically. Without explicit refresh, the directory table only shows files that were present at the time of the last refresh.

---

## 3.12 FILE URLs (TESTED)

### Three types of URLs for files in stages:

| URL Type | Duration | Who can use | Function |
|---|---|---|---|
| File URL | Persistent (64-bit ID) | Snowflake users with access | BUILD_STAGE_FILE_URL() |
| Scoped URL | Session duration only | Current user's session | BUILD_SCOPED_FILE_URL() |
| Pre-signed URL | Configurable expiry | Anyone (no Snowflake login) | GET_PRESIGNED_URL() |

**Exam trap**: "Share file with external partner (no Snowflake account)?" → Pre-signed URL. IF YOU SEE "File URL" or "Scoped URL" for external sharing → WRONG because those require Snowflake authentication; Pre-signed URL needs NO login.
**Exam trap**: "URL valid only for current session?" → Scoped URL. IF YOU SEE "Pre-signed URL" as session-scoped → WRONG because Pre-signed has configurable expiry; SCOPED URL dies when the session ends.
**Exam trap**: "Persistent file access for Snowflake users?" → File URL. IF YOU SEE "Pre-signed URL" for persistent access → WRONG because Pre-signed URLs expire; FILE URL is persistent (tied to a 64-bit ID).

### Example Scenario Questions — File URLs

**Scenario:** A consulting firm needs to share a PDF report stored in a Snowflake internal stage with a client who does not have a Snowflake account. The link should expire after 7 days. Which URL type should they use?
**Answer:** Use a Pre-signed URL generated with `GET_PRESIGNED_URL(@stage, 'report.pdf', 604800)` (604800 seconds = 7 days). Pre-signed URLs are the only URL type that works for users without a Snowflake account — anyone with the link can download the file. The expiry is configurable. File URLs and Scoped URLs both require Snowflake authentication, making them unsuitable for external sharing.

**Scenario:** A Streamlit app in Snowflake displays images stored in a stage. The app needs URLs that work only during the user's active session and cannot be shared or bookmarked for later use. Which URL type is appropriate?
**Answer:** Use Scoped URLs generated with `BUILD_SCOPED_FILE_URL(@stage, 'image.png')`. Scoped URLs are tied to the current user's session and expire when the session ends. They cannot be shared with other users or reused in a different session. This provides the tightest access control for session-bound use cases like in-app image rendering, where persistent or shareable access is not desired.

**Scenario:** An analytics team builds a dashboard that references report files in a stage. The file links need to work persistently across sessions for any Snowflake user who has access to the stage. Which URL type should they use?
**Answer:** Use File URLs generated with `BUILD_STAGE_FILE_URL(@stage, 'report.csv')`. File URLs are persistent (they use a 64-bit identifier) and work for any Snowflake user who has the appropriate privileges on the stage. Unlike Scoped URLs (which die with the session) or Pre-signed URLs (which expire), File URLs provide stable, long-lived access — ideal for dashboards, bookmarks, and shared references within the organization.

---

## 3.13 SERVER-SIDE ENCRYPTION

### Internal stages:
- Snowflake manages encryption (AES-256)
- Automatic, always on

### External stages:
- Can use server-side encryption on cloud storage (SSE-S3, SSE-KMS for AWS)
- Configure in stage definition or storage integration

**Exam trap**: "Do you need to enable encryption for internal stages?" → NO. IF YOU SEE "enable encryption" + "internal stage" → WRONG because internal stages are ALWAYS encrypted (AES-256) automatically — no action needed.
**Exam trap**: "Who manages encryption keys for internal stages?" → Snowflake manages them. IF YOU SEE "customer-managed keys" for internal stages → WRONG because Snowflake handles internal stage encryption; YOU only configure encryption for EXTERNAL stages.

### Example Scenario Questions — Server-Side Encryption

**Scenario:** A security auditor asks the data team to confirm that files in Snowflake's internal stages are encrypted at rest. The team hasn't configured any encryption settings. Should they be concerned?
**Answer:** No. Internal stages are always encrypted with AES-256 encryption, managed entirely by Snowflake. This encryption is automatic and always on — there is no configuration required and no way to disable it. The team does not need to take any action. Snowflake manages the encryption keys for internal stages as part of its built-in security model.

**Scenario:** A company stores sensitive financial data in an S3 bucket used as an external stage. Their compliance team requires that all data at rest in S3 is encrypted with AWS KMS customer-managed keys (SSE-KMS). How should they configure encryption for the external stage?
**Answer:** Configure server-side encryption in the external stage definition or storage integration by specifying the encryption type and KMS key. For example, in the stage definition: `CREATE STAGE my_s3_stage URL = 's3://bucket/path' ... ENCRYPTION = (TYPE = 'AWS_SSE_KMS' KMS_KEY_ID = 'aws/key')`. This ensures files written to S3 during unloading are encrypted with the specified KMS key. For loading, the files must already be encrypted at the source — Snowflake can read SSE-S3 and SSE-KMS encrypted files when proper IAM permissions are configured via a storage integration.

---

## 3.14 UNLOADING DATA

### COPY INTO @stage FROM table/query:
- Exports data to files in a stage
- Default compression: gzip
- Default format: CSV
- Can unload to: internal stages, external stages (S3, Azure, GCS)
- Supports: CSV, JSON, Parquet
- Can partition output files: PARTITION BY expression

### Key unloading options:
- SINGLE = TRUE → one output file
- MAX_FILE_SIZE → control file size
- HEADER = TRUE → include column headers
- OVERWRITE = TRUE → overwrite existing files

**Exam trap**: "Unload supports Avro/ORC/XML?" → WRONG. IF YOU SEE "Avro", "ORC", or "XML" for unloading → trap! Unloading ONLY supports CSV, JSON, Parquet. All 6 formats are for LOADING only.
**Exam trap**: "Default unloading behavior — one file or many?" → Many files (split). IF YOU SEE "single file" as default → WRONG because default splits into multiple files; use SINGLE = TRUE for one file.
**Exam trap**: "COPY INTO @stage = loading or unloading?" → UNLOADING (export). IF YOU SEE "COPY INTO @stage" described as loading → WRONG because @stage as TARGET = unloading; COPY INTO table = loading.

### Example Scenario Questions — Unloading Data

**Scenario:** A data team needs to export query results to Parquet files in an S3 bucket, partitioned by year and month, for consumption by a Spark cluster. They also want column headers included. How should they configure the COPY INTO?
**Answer:** Use `COPY INTO @s3_stage/export/ FROM (SELECT * FROM analytics_table) FILE_FORMAT = (TYPE = PARQUET) PARTITION BY ('year=' || YEAR(order_date) || '/month=' || MONTH(order_date)) HEADER = TRUE`. This exports data as Parquet files (one of three supported unload formats: CSV, JSON, Parquet), partitioned into S3 prefixes by year/month for efficient Spark reads. Default compression is gzip. Note that Avro, ORC, and XML are supported for loading only — not for unloading.

**Scenario:** A downstream system requires exactly one output file (not split across multiple files) when receiving data exports from Snowflake. The default COPY INTO unload produces many small files. How can the engineer produce a single file?
**Answer:** Set `SINGLE = TRUE` in the COPY INTO statement: `COPY INTO @my_stage/export.csv FROM my_table FILE_FORMAT = (TYPE = CSV) SINGLE = TRUE`. By default, Snowflake splits unloaded data into multiple files for parallelism. SINGLE = TRUE forces all output into one file. For large datasets, also consider setting `MAX_FILE_SIZE` to ensure the single file isn't too large for the downstream system. Note that single-file unloads may be slower since they cannot parallelize the write.

**Scenario:** A company unloads customer data to an internal stage weekly for backup purposes. Each week's export overwrites the previous one. They notice the old files still exist alongside new ones. What parameter controls this behavior?
**Answer:** Use `OVERWRITE = TRUE` in the COPY INTO statement to replace existing files in the stage. Without OVERWRITE = TRUE, Snowflake writes new files alongside existing ones (it does not automatically delete previous exports). Alternatively, the team can manually remove old files with `REMOVE @stage/path/` before each unload, but OVERWRITE = TRUE is the cleaner approach for recurring export workflows.

---

## RAPID-FIRE REVIEW — Domain 3

1. Three internal stages: User @~, Table @%t, Named @s
2. PUT = upload local→stage. GET = download stage→local. Both need SnowSQL.
3. External stages = S3, Azure, GCS
4. COPY INTO = bulk load. Default error behavior = ABORT entire load.
5. VALIDATION_MODE = check errors without loading
6. PURGE = TRUE deletes source files after load
7. METADATA$FILENAME = get source filename during load
8. Snowpipe = serverless, continuous, near-real-time (minutes)
9. Snowpipe Streaming = row-level, sub-second, no files needed
10. Recommended file size: 100-250 MB compressed
11. Streams = CDC (INSERT, UPDATE, DELETE tracking)
12. Tasks = scheduled SQL execution (CRON or interval)
13. Streams + Tasks = classic pipeline. Dynamic Tables = modern replacement.
14. Dynamic Tables = SQL query + target lag, automatic refresh
15. Storage Integration = secure connection to cloud storage (no embedded creds)
16. Git Integration = version-controlled code in Snowflake (NEW)
17. Directory Tables = file catalog for stages
18. Pre-signed URL = share with anyone (no Snowflake account needed)
19. Scoped URL = session-only access
20. File URL = persistent access for Snowflake users
21. Kafka connector runs in CUSTOMER's environment
22. Supported formats: CSV, JSON, Avro, ORC, Parquet, XML. NOT: HTML, Excel, PDF
23. Unloading default: gzip compression, CSV format
24. VALIDATE() function → review errors from previous load

---

## CONFUSING PAIRS — Domain 3

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Upload local file to stage | PUT (via SnowSQL) | COPY INTO |
| Load data from stage to table | COPY INTO | PUT |
| Download stage file to local | GET | COPY INTO |
| Unload table to stage | COPY INTO @stage FROM table | GET |
| Snowpipe compute | Serverless (Snowflake-managed) | Warehouse-based |
| Snowpipe trigger | Cloud event notification or REST API | Manual schedule |
| Snowpipe Streaming input | Rows via SDK/API | Files |
| Stream type for external table | Insert-only | Standard |
| Task starts in state | SUSPENDED (must RESUME) | RUNNING |
| Dynamic Table vs Streams+Tasks | Target lag (declarative) | Manual scheduling |
| Pre-signed URL | Anyone, temporary | Snowflake users only |
| Scoped URL | Current session only | Persistent |
| File URL | Persistent, Snowflake users | External access |
| ON_ERROR default | ABORT_STATEMENT | CONTINUE |
| FORCE = TRUE | Reload already-loaded files | Normal load behavior |
| Kafka connector runs where | Customer's environment | Snowflake cloud |
| Storage Integration | Secure cloud access, no creds in stage | Stage with embedded creds |

---

## BRAIN-FRIENDLY SUMMARY — Domain 3

### SCENARIO DECISION TREES
When you read a question, find the pattern:

**"A client's data engineer needs to upload CSV files from their laptop into Snowflake..."**
→ Step 1: PUT file to stage (via SnowSQL)
→ Step 2: COPY INTO table FROM stage
→ NOT just "COPY INTO" alone (files must be staged first)

**"A retail company wants data to load automatically whenever new sales files land in their S3 bucket..."**
→ Snowpipe with AUTO_INGEST = TRUE + S3 event notification (SQS)
→ NOT scheduled Tasks (Snowpipe is event-driven, not polling)

**"A logistics company's IoT fleet sensors send individual GPS records every second..."**
→ Snowpipe Streaming (row-level, sub-second, no files needed)
→ NOT regular Snowpipe (that needs files to land first)

**"A marketing team wants a dashboard summary table that's never more than 10 minutes stale..."**
→ Dynamic Table with TARGET_LAG = '10 minutes'
→ NOT Streams + Tasks (works, but Dynamic Table is simpler for this)

**"A finance team needs to know exactly which transactions were inserted, updated, or deleted since yesterday..."**
→ Stream (Change Data Capture) — Standard type
→ METADATA$ACTION tells you INSERT vs DELETE, METADATA$ISUPDATE tells you if it was an UPDATE

**"A data pipeline should only process new data when it actually arrives, not on a fixed schedule..."**
→ Task with WHEN SYSTEM$STREAM_HAS_DATA('stream_name')
→ Stream + Task combo

**"A consulting firm needs to share a report file with a client who doesn't have Snowflake..."**
→ Pre-signed URL (GET_PRESIGNED_URL) — anyone can use it, no login
→ NOT File URL (requires Snowflake login)
→ NOT Scoped URL (current session only)

**"Before loading 50 million rows, the team wants to preview any errors first..."**
→ VALIDATION_MODE = RETURN_ERRORS (checks without actually loading)
→ NOT ON_ERROR (that's what happens DURING the actual load)

**"After loading, the analyst wants to know which source file each row came from..."**
→ METADATA$FILENAME in the SELECT clause of COPY INTO
→ Must be done DURING load, not after

**"An e-commerce company streams events from Kafka into Snowflake..."**
→ Kafka Connector (runs in CUSTOMER's Kafka environment, not Snowflake)
→ Can use Snowpipe Streaming mode for lower latency

**"A data engineer accidentally loaded the same files twice..."**
→ COPY INTO tracks loaded files for 64 days (prevents duplicates automatically)
→ Unless FORCE = TRUE was used (that overrides the duplicate check)

**"A team wants to clean up source files from S3 after successful loading..."**
→ PURGE = TRUE in COPY INTO
→ Deletes source files only after successful load

**"A client asks: can I upload files through the Snowsight web UI?"**
→ PUT/GET do NOT work in Snowsight
→ Must use SnowSQL CLI or Snowflake connectors

**"An analytics team wants to store their dbt models and UDF code with version control..."**
→ Git Integration (CREATE GIT REPOSITORY — connects GitHub/GitLab to Snowflake)
→ This is Snowflake's native feature, separate from dbt itself

**"A client loads a CSV but the columns are in the wrong order compared to the table..."**
→ Use SELECT with column reordering in COPY INTO: COPY INTO table FROM (SELECT $3, $1, $2 FROM @stage)
→ Or use MATCH_BY_COLUMN_NAME to match by header names

**"A client loads data and some rows have more columns than the target table..."**
→ ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE (extra columns ignored, missing = NULL)
→ Default is TRUE (will error)

**"A data team wants to unload query results to Parquet files in S3..."**
→ COPY INTO @external_stage FROM (SELECT ...) FILE_FORMAT = (TYPE = PARQUET)
→ Default unload compression = gzip. Supports CSV, JSON, Parquet for unload.

**"A client wants ONE big output file when unloading..."**
→ SINGLE = TRUE in COPY INTO
→ Default behavior splits into multiple files

**"A client's Snowpipe shows STALLED_COMPILATION status..."**
→ The SQL in the pipe definition is invalid or there's a schema mismatch
→ Fix: check the COPY INTO statement in the pipe, verify table/stage still match

**"A client loads JSON data into Snowflake. What column type should they use?"**
→ VARIANT (semi-structured container)
→ Can also use OBJECT or ARRAY depending on the JSON structure

**"A client wants to see all files sitting in a stage and their metadata..."**
→ Directory Table (ENABLE on stage, then query with SQL)
→ Shows: file name, size, MD5, last modified

**"A client needs to securely connect their stage to S3 without embedding AWS keys in the stage definition..."**
→ Storage Integration (CREATE STORAGE INTEGRATION)
→ Define once, reuse across multiple stages. No credentials exposed.

**"A task tree has a root task and 3 child tasks. Where does the schedule go?"**
→ Only the ROOT task has the schedule
→ Child tasks run AFTER their parent completes (dependency-based, no independent schedule)

**"A stream was created on a table. Nobody queried it for 2 weeks. Is the data still there?"**
→ YES, as long as the stream's offset is within the table's Time Travel retention
→ If retention expires and stream wasn't consumed → stream goes STALE (data lost)

---

### MNEMONICS TO LOCK IN

**Stage types = "U-T-N" → "U Turn Now"**
- **U**ser @~ → personal locker, auto-created, can't change it
- **T**able @%t → attached to one table, auto-created, can't change it
- **N**amed @s → the flexible one, CREATE STAGE, recommended for production

**Loading flow = "P-C-V" → "Put, Copy, Validate"**
- **P**UT → laptop files to stage
- **C**OPY INTO → stage to table
- **V**ALIDATE → check what went wrong after

**ON_ERROR options = "A-C-S" → "Abort, Continue, Skip"**
- **A**BORT_STATEMENT = stop everything (DEFAULT)
- **C**ONTINUE = skip bad rows, load the rest
- **S**KIP_FILE = skip entire files with errors

**Pipeline evolution = "Old vs New"**
- OLD way: Streams + Tasks (more control, more code)
- NEW way: Dynamic Tables (just SQL + target lag)
- Both are valid. Dynamic Tables = less plumbing.

**Three URLs = "F-S-P" → "Forever, Session, Public"**
- **F**ile URL → forever access, Snowflake users only
- **S**coped URL → session-only, dies when you log out
- **P**re-signed URL → temporary, anyone can use (no Snowflake account needed)

**Snowpipe vs Streaming = "Files vs Rows"**
- Snowpipe = files land → loaded in MINUTES
- Streaming = rows sent via API → loaded in SECONDS

**File formats = "CAJ-OPX"** (CSV, Avro, JSON, ORC, Parquet, XML)
- NOT supported: HTML, Excel, PDF
- Default load format: CSV
- Default unload compression: gzip

---

### TOP TRAPS — Domain 3

1. **"PUT works in Snowsight"** → WRONG. PUT/GET only via SnowSQL or connectors.
2. **"Snowpipe uses a warehouse"** → WRONG. Serverless (Snowflake-managed compute).
3. **"Snowpipe Streaming needs staged files"** → WRONG. Row-level via SDK/API, no files.
4. **"Tasks start in RUNNING state"** → WRONG. Start SUSPENDED. Must ALTER TASK ... RESUME.
5. **"Dynamic Tables require Enterprise edition"** → WRONG. ALL editions.
6. **"ON_ERROR default is CONTINUE"** → WRONG. Default = ABORT_STATEMENT (fail everything).
7. **"Kafka connector runs inside Snowflake"** → WRONG. Runs in CUSTOMER's environment.
8. **"User stage can be altered or dropped"** → WRONG. Cannot alter or drop user/table stages.
9. **"Pre-signed URL requires Snowflake login"** → WRONG. Anyone can use it (that's the whole point).
10. **"COPY INTO always reloads files"** → WRONG. Tracks loaded files for 64 days. Use FORCE=TRUE to override.

---

### PATTERN SHORTCUTS — "If you see ___, answer is ___"

| If the question mentions... | The answer is almost always... |
|---|---|
| "upload from local machine" | PUT command (via SnowSQL) |
| "download to local machine" | GET command |
| "bulk load from stage" | COPY INTO |
| "continuous loading", "auto-ingest" | Snowpipe |
| "real-time row ingestion", "sub-second" | Snowpipe Streaming |
| "100-250 MB compressed" | Recommended Snowpipe file size |
| "track changes", "CDC" | Stream |
| "SYSTEM$STREAM_HAS_DATA" | Stream + Task pattern |
| "target lag", "declarative pipeline" | Dynamic Table |
| "schedule SQL", "CRON" | Task |
| "source filename in loaded data" | METADATA$FILENAME |
| "check errors without loading" | VALIDATION_MODE |
| "delete source files after load" | PURGE = TRUE |
| "reload already-loaded files" | FORCE = TRUE |
| "share file with non-Snowflake user" | Pre-signed URL |
| "session-only file access" | Scoped URL |
| "persistent file access, SF users" | File URL |
| "secure cloud storage connection" | Storage Integration |
| "version control in Snowflake" | Git Integration (CREATE GIT REPOSITORY) |
| "file catalog on stage" | Directory Table |
| @~ | User stage |
| @%table_name | Table stage |
| @stage_name | Named stage |
| "Kafka to Snowflake" | Kafka Connector (runs in customer env) |
| "INSERT-only stream" | External tables |
| "Append-only stream" | Only tracks INSERTs (not updates/deletes) |

---

## EXAM DAY TIPS — Domain 3 (18% = ~18 questions)

**Before studying this domain:**
- Flashcard the 3 stage types (@~, @%t, @s) and what each can/can't do
- Flashcard Snowpipe vs Snowpipe Streaming (files vs rows, minutes vs seconds)
- Know the COPY INTO parameters: ON_ERROR, VALIDATION_MODE, PURGE, FORCE
- Know the 3 URL types (File, Scoped, Pre-signed) — who can use each

**During the exam — Domain 3 questions:**
- Read the LAST sentence first — then read the scenario
- Eliminate 2 obviously wrong answers immediately
- If they say "continuous loading" → Snowpipe. If "row-level, sub-second" → Snowpipe Streaming.
- If they say "target lag" or "declarative" → Dynamic Table
- If they say "track changes" or "CDC" → Stream
- If they mention a STAGE → check the symbol: @~ = user, @% = table, @name = named
- If they ask "who can access this file?" → File URL (SF users), Scoped (session), Pre-signed (anyone)

---

## ONE-LINE PER TOPIC — Domain 3

| Topic | One-line summary |
|---|---|
| User stage @~ | Personal, auto-created, can't alter/drop, can't set file format. |
| Table stage @%t | Per-table, auto-created, can't alter/drop, must be table owner. |
| Named stage @s | CREATE STAGE, most flexible, can set file format + encryption, recommended. |
| External stages | Point to S3/Azure/GCS, need storage integration or credentials. |
| PUT command | Upload local files → internal stage. SnowSQL/connectors only. Auto-compresses. |
| GET command | Download stage files → local machine. SnowSQL/connectors only. |
| File formats | CSV (default), JSON, Avro, ORC, Parquet, XML. NOT: HTML, Excel, PDF. |
| COPY INTO (load) | Bulk load stage → table. Tracks files for 64 days. Default ON_ERROR = ABORT. |
| COPY INTO (unload) | Export table → stage. Default: gzip compression, CSV format. |
| ON_ERROR | ABORT (default), CONTINUE (skip bad rows), SKIP_FILE (skip bad files). |
| VALIDATION_MODE | Check for errors WITHOUT loading. RETURN_ERRORS or RETURN_n_ROWS. |
| PURGE = TRUE | Delete source files after successful load. |
| FORCE = TRUE | Reload files even if already loaded (overrides 64-day tracking). |
| MATCH_BY_COLUMN_NAME | Match source columns to table columns by name, not position. |
| METADATA$ columns | FILENAME, FILE_ROW_NUMBER, FILE_CONTENT_KEY, FILE_LAST_MODIFIED, START_SCAN_TIME. |
| VALIDATE function | Review errors from a previous COPY INTO (after ON_ERROR = CONTINUE). |
| Snowpipe | Continuous, serverless, auto-ingest from cloud events. Minutes latency. 100-250MB files. |
| Snowpipe Streaming | Row-level via SDK/API, sub-second latency, no files needed. |
| Kafka Connector | Runs in CUSTOMER's environment, reads topics → writes to SF tables. |
| Streams (CDC) | Track INSERT/UPDATE/DELETE. Standard, Append-only, Insert-only types. |
| Tasks | Scheduled SQL (CRON/interval). Start SUSPENDED. Task trees up to 1000. |
| Dynamic Tables | SQL + target lag = auto-refreshing pipeline. Replaces Streams+Tasks. ALL editions. |
| Storage Integration | Secure cloud storage connection without embedded credentials. |
| Git Integration | CREATE GIT REPOSITORY, version-controlled code in Snowflake. NEW topic. |
| Directory Tables | File catalog for stages. Query file metadata with SQL. |
| File URL | Persistent, Snowflake users only. BUILD_STAGE_FILE_URL(). |
| Scoped URL | Session-only, current user. BUILD_SCOPED_FILE_URL(). |
| Pre-signed URL | Configurable expiry, anyone (no SF account). GET_PRESIGNED_URL(). |

---

## FLASHCARDS — Domain 3

**Q:** What are the 4 stage types?
**A:** User stage (@~), Table stage (@%table_name), Named internal stage (@my_stage), Named external stage (@my_ext_stage pointing to S3/Azure/GCS).

**Q:** Which stages can you use PUT with?
**A:** INTERNAL stages ONLY (user, table, named internal). For external stages, upload files directly to cloud storage.

**Q:** COPY INTO vs Snowpipe?
**A:** COPY INTO = bulk batch loading, needs a warehouse. Snowpipe = continuous micro-batch, serverless (Cloud Services compute), event-driven.

**Q:** How is Snowpipe triggered?
**A:** Event notifications (SQS for AWS, Event Grid for Azure, Pub/Sub for GCP) or REST API calls. Auto-scales, billed per-file.

**Q:** What compute does Snowpipe use?
**A:** Cloud Services compute — NOT a warehouse. This is a common exam trap.

**Q:** What file formats does Snowflake support?
**A:** CSV, Avro, JSON, ORC, Parquet, XML. Mnemonic: CAJ-OPX.

**Q:** What does VALIDATION_MODE do?
**A:** Checks/validates data WITHOUT actually loading it. Options: RETURN_ERRORS, RETURN_N_ROWS, RETURN_ALL_ERRORS.

**Q:** What is the VALIDATE function?
**A:** Called AFTER a COPY INTO to retrieve errors from the last load. Uses: VALIDATE(table, job_id => '_last').

**Q:** What does ON_ERROR do in COPY INTO?
**A:** Controls error behavior: CONTINUE (skip bad rows), SKIP_FILE, SKIP_FILE_n (skip if n+ errors), ABORT_STATEMENT (default — stop on first error).

**Q:** What is a stream?
**A:** A Change Data Capture (CDC) object that tracks INSERT, UPDATE, DELETE on a table. Columns: METADATA$ACTION, METADATA$ISUPDATE, METADATA$ROW_ID.

**Q:** Standard stream vs Append-only stream?
**A:** Standard: tracks inserts, updates, deletes. Append-only: tracks ONLY inserts (for regular tables). Insert-only: for external tables (only new rows added via new files). Note: external tables use INSERT-ONLY streams, not append-only.

**Q:** What is a task?
**A:** A scheduled SQL statement. Can form DAGs (directed acyclic graphs) with predecessor tasks. Supports CRON or interval scheduling. Needs a warehouse (or serverless).

**Q:** What is a Dynamic Table?
**A:** Declarative pipeline — you define a query + target lag, and Snowflake automatically keeps it refreshed. Replaces tasks+streams for many use cases. New for COF-C03.

**Q:** What is Snowpipe Streaming?
**A:** Low-latency streaming via Snowflake Ingest SDK (Java). Rows are written directly to tables without staging files. Faster than regular Snowpipe. New for COF-C03.

**Q:** What is a directory table?
**A:** A read-only table layered on top of a stage that catalogs staged files. Shows filename, size, MD5, last modified. Enable with DIRECTORY = (ENABLE = TRUE).

**Q:** What are the 3 types of file URLs?
**A:** File URL (persistent, SF users only, BUILD_STAGE_FILE_URL), Scoped URL (session-only, current user, BUILD_SCOPED_FILE_URL), Pre-signed URL (configurable expiry, anyone, GET_PRESIGNED_URL).

**Q:** What does PURGE = TRUE do in COPY INTO?
**A:** Automatically deletes staged files after they're successfully loaded.

**Q:** How does COPY INTO track loaded files?
**A:** Maintains 64-day load metadata. Won't re-load the same file within 64 days unless you use FORCE = TRUE.

**Q:** What is the difference between COPY INTO table and COPY INTO location?
**A:** COPY INTO table = loading data IN. COPY INTO location = unloading data OUT (to a stage or external storage).

**Q:** What does the GET command do?
**A:** Downloads files FROM an internal stage to local file system. Opposite of PUT.

---

## EXPLAIN LIKE I'M 5 — Domain 3

**Stage**: A parking lot where your data files sit before being loaded into Snowflake tables.

**User stage (@~)**: Your own personal parking spot that only you can use.

**Table stage (@%table)**: A parking lot attached to a specific table — anyone with table access can use it.

**Named stage**: A shared parking lot you create and give a name, with rules about who can park there.

**PUT**: Uploading files from your computer to Snowflake's parking lot. Only works for Snowflake's own parking lots (internal stages).

**COPY INTO**: The moving truck that takes data from the parking lot and puts it into the table. You tell it which truck (warehouse) to use.

**Snowpipe**: A robot that watches the parking lot and automatically moves new files into the table as soon as they arrive. No truck needed — it uses its own tiny robot arms.

**Snowpipe Streaming**: Instead of parking files first, you hand data directly to the robot row by row. Even faster.

**File format**: Instructions for the moving truck about how files are organized — like "this is a CSV with commas" or "this is JSON."

**VALIDATION_MODE**: Checking if the data looks right without actually loading it — like inspecting boxes before moving them into the house.

**Stream**: A security camera on a table that records every change (who was added, removed, or updated).

**Task**: An alarm clock that runs a SQL command at scheduled times. You can chain them together like dominoes.

**Dynamic table**: A smart table that keeps itself updated automatically. You tell it what data you want and how fresh it should be.

**Directory table**: A list of all the files in a parking lot (stage), showing names, sizes, and when they arrived.

**ON_ERROR**: What the moving truck does when it finds a broken box — stop everything? Skip the box? Skip the whole file?

**PURGE**: Throwing away the files from the parking lot after they've been safely moved into the table.

**GET**: Taking files back out of Snowflake's parking lot and downloading them to your computer.
