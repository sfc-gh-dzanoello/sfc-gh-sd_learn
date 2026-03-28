# Domain 1: Data Movement

> **DEA-C01 Weight:** 28% of the exam

---

## 1.1 COPY INTO -- Bulk Loading and Unloading

### Key Concepts
- **COPY INTO <table>** loads data from a stage into a table (bulk ingestion)
- **COPY INTO <location>** unloads data from a table into a stage (bulk export)
- **Load metadata** is stored for 64 days -- Snowflake tracks which files have been loaded and skips duplicates automatically
- **PURGE = TRUE** deletes staged files after successful load
- **ON_ERROR** controls behavior on row-level errors: CONTINUE, SKIP_FILE, SKIP_FILE_<n>, ABORT_STATEMENT (default)
- **VALIDATION_MODE** allows dry-run validation without actually loading data (RETURN_ERRORS, RETURN_<n>_ROWS, RETURN_ALL_ERRORS)
- **FORCE = TRUE** bypasses the 64-day load metadata check and reloads files even if previously loaded
- **SIZE_LIMIT** caps the total bytes loaded per COPY statement (not per file)
- **MATCH_BY_COLUMN_NAME** allows loading when source columns differ in order from target (matches by name, not position)

### Why This Matters
A data engineer must reliably load terabytes of raw data into Snowflake daily. COPY INTO is the workhorse command for batch/bulk pipelines, and understanding its nuances (error handling, deduplication, file sizing) separates production-grade pipelines from fragile ones.

### Best Practices
- Split large files into 100-250 MB compressed chunks for optimal parallel loading
- Use COPY INTO with ON_ERROR = SKIP_FILE for production pipelines where partial loads are acceptable
- Leverage VALIDATION_MODE before first load of a new data source to catch schema mismatches
- Always define explicit FILE_FORMAT (do not rely on defaults)
- Use PATTERN to filter specific files from a stage rather than loading everything
- Prefer PURGE = TRUE to avoid reprocessing costs and stage clutter

**Exam trap:** IF YOU SEE "COPY INTO loads data in real-time as files arrive" -> WRONG because COPY INTO is a batch command, not a continuous ingestion mechanism. Snowpipe handles continuous loading.

**Exam trap:** IF YOU SEE "FORCE = TRUE prevents duplicate rows" -> WRONG because FORCE = TRUE does the opposite -- it reloads files regardless of load history, which CAN create duplicates.

**Exam trap:** IF YOU SEE "VALIDATION_MODE loads valid rows and skips invalid ones" -> WRONG because VALIDATION_MODE never loads any data. It only validates and returns results.

**Exam trap:** IF YOU SEE "Load metadata is stored indefinitely" -> WRONG because load metadata expires after 64 days.

### Common Questions (FAQ)
**Q: What happens if you run the same COPY INTO command twice on the same files?**
A: Snowflake automatically skips files that were already loaded within the 64-day metadata window. No duplicates are created unless you use FORCE = TRUE.

**Q: Can COPY INTO load data from an external stage directly?**
A: Yes. COPY INTO supports internal stages (@~, @%table, @named), external stages (S3, GCS, Azure), and inline URLs.

**Q: What is the difference between COPY INTO and INSERT INTO ... SELECT?**
A: COPY INTO is optimized for bulk file loading with deduplication, error handling, and parallel processing. INSERT INTO ... SELECT is a standard SQL DML that works on already-loaded data or cross-table operations.

### Example Scenario Questions
**Scenario:** A pipeline loads CSV files from an S3 external stage nightly. One night the job fails halfway. The next night the job runs again. Some files from the failed run were partially loaded. What happens?
**Answer:** Files that were fully loaded and committed will be skipped (64-day metadata). Files that failed mid-load will be retried because they were not committed. No duplicates occur for successfully loaded files.

**Scenario:** A team needs to validate a new Parquet data source before building a production pipeline. They want to check for schema issues without loading any data. What should they use?
**Answer:** Use COPY INTO with VALIDATION_MODE = RETURN_ALL_ERRORS. This parses and validates the files without inserting any rows, returning all error details for review.

---

## 1.2 Snowpipe -- Continuous Data Ingestion

### Key Concepts
- **Snowpipe** provides continuous, serverless data loading (micro-batch, not true streaming)
- **AUTO_INGEST = TRUE** uses cloud event notifications (S3 SQS, GCS Pub/Sub, Azure Event Grid) to trigger loading automatically
- **REST API** endpoint (insertFiles) allows programmatic pipe triggering without event notifications
- **Serverless compute** -- Snowpipe uses Snowflake-managed compute, not your virtual warehouse
- **Billing** is per-second based on actual compute used, billed as a fraction of a warehouse credit
- **Pipe status** is checked via SYSTEM$PIPE_STATUS() which returns executionState, pendingFileCount, etc.
- **COPY history** for Snowpipe is visible in INFORMATION_SCHEMA.COPY_HISTORY and ACCOUNT_USAGE.COPY_HISTORY
- **Load metadata** for Snowpipe is also 64 days (same as COPY INTO)

### Why This Matters
When data must be available within minutes of landing in cloud storage, Snowpipe eliminates the need for scheduled COPY INTO jobs. It is the standard approach for near-real-time ingestion in Snowflake data engineering pipelines.

### Best Practices
- Ensure cloud event notification (SQS queue, Pub/Sub subscription) is correctly configured before enabling AUTO_INGEST
- Size incoming files at 100-250 MB compressed for optimal Snowpipe throughput
- Monitor pipe health with SYSTEM$PIPE_STATUS() and COPY_HISTORY views
- Use a single pipe per target table per source location for clarity
- Do not mix Snowpipe and manual COPY INTO on the same files -- this causes unpredictable deduplication behavior
- Set ERROR_INTEGRATION for alerting on load failures

**Exam trap:** IF YOU SEE "Snowpipe uses your virtual warehouse" -> WRONG because Snowpipe is serverless. It uses Snowflake-managed compute.

**Exam trap:** IF YOU SEE "Snowpipe guarantees exactly-once delivery" -> WRONG because Snowpipe provides at-least-once semantics within the 64-day window. Duplicate file notifications can cause reloads if metadata has expired.

**Exam trap:** IF YOU SEE "AUTO_INGEST works without any cloud notification setup" -> WRONG because AUTO_INGEST requires cloud-side event notification configuration (SQS, Pub/Sub, or Event Grid).

### Common Questions (FAQ)
**Q: What is the typical latency for Snowpipe loading?**
A: Snowpipe typically loads data within 1 minute of file notification, but Snowflake does not guarantee a specific SLA. It is near-real-time, not real-time.

**Q: Can you ALTER a pipe's COPY statement?**
A: No. To change the COPY statement, you must recreate the pipe (CREATE OR REPLACE PIPE).

### Example Scenario Questions
**Scenario:** A company has IoT sensors writing JSON files to S3 every 30 seconds. They need data in Snowflake within 2 minutes. The solution must be low-maintenance. What do you recommend?
**Answer:** Create an external stage pointing to the S3 bucket. Configure S3 event notifications to an SQS queue. Create a Snowpipe with AUTO_INGEST = TRUE. This is fully serverless and meets the latency requirement.

**Scenario:** Snowpipe loads appear to have stopped. Files are landing in S3 but not appearing in the target table. How do you diagnose?
**Answer:** Run SYSTEM$PIPE_STATUS('pipe_name') to check executionState and pendingFileCount. Check COPY_HISTORY for errors. Verify the SQS queue is receiving notifications and that the pipe has not been paused with ALTER PIPE ... SET PIPE_EXECUTION_PAUSED = TRUE.

---

## 1.3 Snowpipe Streaming

### Key Concepts
- **Snowpipe Streaming** ingests rows directly via the Snowflake Ingest SDK (Java) -- no staging files required
- **Lowest latency** option: data is queryable within seconds (sub-second to a few seconds)
- **Channel** is the unit of ingestion -- each channel maintains its own offset for exactly-once semantics
- **insertRows()** API call writes rows directly into Snowflake table micro-partitions
- **No file staging** -- unlike Snowpipe, data goes directly from client memory to Snowflake
- **Offset tracking** ensures exactly-once delivery per channel (client manages offsets)
- **Kafka connector** (Snowflake Kafka Connector) can use Snowpipe Streaming as its ingestion method

### Why This Matters
For true low-latency streaming use cases (real-time dashboards, fraud detection, live monitoring), Snowpipe Streaming provides the fastest path from source system to queryable Snowflake table.

### Best Practices
- Use Snowpipe Streaming when latency requirements are under 10 seconds
- Manage channel offsets carefully to prevent data loss or duplication
- Use the Snowflake Kafka Connector with Snowpipe Streaming for Kafka-based architectures
- Monitor ingestion latency via ACCOUNT_USAGE views
- Understand that Snowpipe Streaming requires the Ingest SDK (Java-based)

**Exam trap:** IF YOU SEE "Snowpipe Streaming writes to a stage first" -> WRONG because Snowpipe Streaming bypasses staging entirely and writes directly to table storage.

**Exam trap:** IF YOU SEE "Snowpipe Streaming uses REST API like Snowpipe" -> WRONG because it uses the Snowflake Ingest SDK (Java), not the REST API.

### Common Questions (FAQ)
**Q: What is the difference between Snowpipe and Snowpipe Streaming?**
A: Snowpipe loads from staged files (micro-batch). Snowpipe Streaming writes rows directly via SDK without staging (true streaming). Snowpipe Streaming has lower latency.

**Q: Does Snowpipe Streaming use a virtual warehouse?**
A: No. Like Snowpipe, it uses Snowflake-managed serverless compute.

### Example Scenario Questions
**Scenario:** A fintech company needs transaction data available for fraud detection queries within 3 seconds of the transaction occurring. They use Apache Kafka. What Snowflake ingestion method should they use?
**Answer:** Use the Snowflake Kafka Connector configured with Snowpipe Streaming. This provides sub-second to low-second latency from Kafka topics directly into Snowflake tables without intermediate file staging.

---

## 1.4 Data Sharing, Replication, and Marketplace

### Key Concepts
- **Direct Share** (provider creates a share, consumer creates a database from it) -- read-only, same region, no data copying
- **Listing** is the modern mechanism for sharing data (replaces legacy direct shares for cross-region/cross-cloud)
- **Reader accounts** are Snowflake accounts created by a provider for consumers who do not have their own Snowflake account
- **Secure views** are required in shares to prevent data leakage through query plan exposure
- **Database replication** creates read-only replicas across regions/clouds for DR and low-latency access
- **Failover groups** enable account-level replication and failover (databases, shares, warehouses, users, roles)
- **Snowflake Marketplace** is the public data exchange where providers list free or paid data products
- **No data copying** occurs in same-region shares -- consumers query the provider's storage directly
- **SHOW SHARES** lists shares; DESCRIBE SHARE shows objects in a share

### Why This Matters
Data sharing is a core differentiator of Snowflake. Data engineers must understand how to securely share data with partners, replicate across regions for disaster recovery, and leverage Marketplace for enrichment datasets.

### Best Practices
- Always use secure views (not regular views) in shares to prevent query plan leaks
- Use listings instead of legacy direct shares for cross-region sharing
- Configure replication with appropriate REPLICATION_SCHEDULE for DR databases
- Monitor replication lag with REPLICATION_GROUP_REFRESH_HISTORY
- Use reader accounts sparingly -- the provider pays for all compute and storage
- Set up failover groups to protect entire account configurations, not just databases

**Exam trap:** IF YOU SEE "Shared data is copied to the consumer account" -> WRONG because same-region shares use zero-copy (consumer queries provider storage). Cross-region listings do replicate data.

**Exam trap:** IF YOU SEE "Regular views can be shared" -> WRONG because only secure views, secure UDFs, and secure materialized views can be included in shares.

**Exam trap:** IF YOU SEE "Reader accounts are free for the provider" -> WRONG because the provider pays for all storage and compute used by reader accounts.

### Common Questions (FAQ)
**Q: Can you share across cloud providers (e.g., AWS to Azure)?**
A: Yes, using listings with cross-cloud auto-fulfillment. Legacy direct shares only work within the same region.

**Q: What objects can be included in a share?**
A: Tables, secure views, secure materialized views, and secure UDFs. You cannot share raw stored procedures, stages, or tasks.

**Q: What is the difference between database replication and data sharing?**
A: Replication creates a full read-only copy in another region for DR/performance. Sharing provides live access to specific objects without copying (same region) or via listing replication (cross-region).

### Example Scenario Questions
**Scenario:** A healthcare company wants to share de-identified patient analytics with a research partner who does not have a Snowflake account. The research partner needs to run their own queries. What approach should they use?
**Answer:** Create a reader account for the research partner. Create a share with secure views containing de-identified data. The provider will bear compute and storage costs for the reader account.

**Scenario:** A global company needs their analytics database available in both US-East and EU-West regions for low-latency access. How should they configure this?
**Answer:** Set up database replication from the primary region to the secondary region. Configure a failover group if they also need DR capability. The secondary replica will be read-only but can be promoted to primary during failover.

---

## 1.5 Stages and File Formats

### Key Concepts
- **User stage** (@~) -- each user has one, cannot be altered or dropped, no one else can access it
- **Table stage** (@%table_name) -- each table has one, no file format can be set on it directly
- **Named internal stage** (CREATE STAGE) -- most flexible, supports file format, directory tables, encryption settings
- **External stage** -- points to S3, GCS, or Azure Blob/ADLS via URL and credentials (or storage integration)
- **Storage integration** -- account-level object that decouples cloud credentials from stage definitions
- **Directory tables** -- enable querying staged file metadata (filename, size, last_modified, etag) via SELECT on @stage
- **FILE_FORMAT** objects define parsing rules: TYPE (CSV, JSON, PARQUET, AVRO, ORC, XML), field delimiters, compression, etc.
- **INFER_SCHEMA** function detects column names and types from staged files (Parquet, Avro, ORC, CSV with headers)
- **Schema evolution** (ENABLE_SCHEMA_EVOLUTION = TRUE on target table) automatically adds new columns when source files have extra columns
- **Schema detection** uses USING TEMPLATE with INFER_SCHEMA to create tables matching source file schema

### Why This Matters
Stages are the gateway for all data entering or leaving Snowflake. A data engineer must master stage types, external stage security (storage integrations), and file format configurations to build reliable data pipelines.

### Best Practices
- Use named internal stages instead of user/table stages for production pipelines
- Use storage integrations for external stages instead of embedding credentials
- Define named FILE_FORMAT objects for reusability across multiple COPY statements
- Enable directory tables on stages when you need to programmatically list and filter files
- Use INFER_SCHEMA for initial table creation, then lock down the schema for production
- Compress files (GZIP, SNAPPY, ZSTD) before staging for cost and speed benefits

**Exam trap:** IF YOU SEE "You can set a file format on a table stage" -> WRONG because table stages do not support named file format assignment. You must specify FORMAT_NAME or format options inline in the COPY command.

**Exam trap:** IF YOU SEE "Schema evolution changes existing column types" -> WRONG because schema evolution only ADDS new columns. It never modifies or drops existing columns.

**Exam trap:** IF YOU SEE "INFER_SCHEMA works on all file types including CSV without headers" -> WRONG because for CSV, INFER_SCHEMA requires PARSE_HEADER = TRUE (headers in the file).

### Common Questions (FAQ)
**Q: What is the difference between a storage integration and putting credentials directly in the stage definition?**
A: A storage integration is an account-level object managed by ACCOUNTADMIN. It uses IAM roles (AWS) or service principals (Azure) instead of raw keys, improving security and credential rotation.

**Q: Can you query files directly on a stage without loading them?**
A: Yes. Use SELECT $1, $2 ... FROM @stage/path (pattern: SELECT columns FROM @stage). For structured formats like Parquet, you can query by column name using $1:column_name notation.

### Example Scenario Questions
**Scenario:** A team receives Parquet files from an external vendor via S3. The vendor occasionally adds new columns. The Snowflake target table should automatically accommodate these new columns. How should this be configured?
**Answer:** Create an external stage with a storage integration. Set ENABLE_SCHEMA_EVOLUTION = TRUE on the target table. Use MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE in the COPY INTO command. New columns in Parquet files will be automatically added to the table.

**Scenario:** An engineer needs to create a Snowflake table that matches the schema of Parquet files already staged. They do not want to manually define every column. What approach should they use?
**Answer:** Use CREATE TABLE ... USING TEMPLATE (SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) FROM TABLE(INFER_SCHEMA(LOCATION => '@my_stage', FILE_FORMAT => 'my_parquet_format'))). This auto-generates the table DDL from the file metadata.

---

## CONFUSING PAIRS -- Data Movement

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Continuous serverless file loading | Snowpipe (AUTO_INGEST) | COPY INTO (batch, manual) |
| Lowest latency ingestion (seconds) | Snowpipe Streaming (Ingest SDK) | Snowpipe (minutes latency) |
| Programmatic pipe trigger | Snowpipe REST API (insertFiles) | COPY INTO |
| Reloading already-loaded files | FORCE = TRUE | Running COPY INTO again (skipped by default) |
| Validating files without loading | VALIDATION_MODE | ON_ERROR = CONTINUE |
| Sharing data same region, no copy | Direct Share / Listing | Database Replication (copies data) |
| Sharing data cross-region | Listing with auto-fulfillment | Direct Share (same region only) |
| Consumer without Snowflake account | Reader Account | Regular share (requires SF account) |
| Detecting source file schema | INFER_SCHEMA | DESCRIBE TABLE |
| Auto-adding new source columns | Schema Evolution (ENABLE_SCHEMA_EVOLUTION) | INFER_SCHEMA (one-time detection) |
| Querying file metadata on stage | Directory Table | INFORMATION_SCHEMA |
| Secure credential management for stages | Storage Integration | Inline credentials in CREATE STAGE |

---

## DON'T MIX -- Data Movement

### COPY INTO vs Snowpipe
| Aspect | COPY INTO | Snowpipe |
|---|---|---|
| Trigger | Manual / scheduled | Event-driven (AUTO_INGEST) or REST API |
| Compute | Your virtual warehouse | Snowflake serverless compute |
| Latency | Minutes to hours (batch) | ~1 minute (near-real-time) |
| Billing | Warehouse credit time | Per-second serverless billing |
| Use case | Large batch loads | Continuous trickle loading |

**RULE:** If it is scheduled/batch, think COPY INTO. If it is event-driven/continuous, think Snowpipe.
**The trap:** Questions may describe "automated loading" -- this could be either (a COPY INTO in a Task or Snowpipe). Look for "serverless" or "event notification" as Snowpipe indicators.

### Snowpipe vs Snowpipe Streaming
| Aspect | Snowpipe | Snowpipe Streaming |
|---|---|---|
| Input | Files on a stage | Rows via Ingest SDK |
| Staging required | Yes | No |
| Latency | ~1 minute | Seconds |
| API | REST API / AUTO_INGEST | Java Ingest SDK (insertRows) |
| Offset management | Automatic (64-day metadata) | Client-managed per channel |

**RULE:** Files on stage = Snowpipe. Rows from application/Kafka = Snowpipe Streaming.
**The trap:** Both are serverless and continuous. The differentiator is file-based vs row-based.

### Direct Share vs Database Replication
| Aspect | Direct Share | Database Replication |
|---|---|---|
| Data copied | No (same region) | Yes (full replica) |
| Cross-region | No (use listings) | Yes |
| Consumer access | Read-only on shared objects | Read-only replica database |
| Use case | Data sharing with partners | DR, multi-region performance |

**RULE:** Sharing with external parties = Share/Listing. Replicating your own data for DR = Replication.
**The trap:** Cross-region sharing via listings does replicate data behind the scenes, but it is still sharing, not replication.

### Schema Detection vs Schema Evolution
| Aspect | Schema Detection (INFER_SCHEMA) | Schema Evolution |
|---|---|---|
| When | Table creation time | Ongoing, during COPY INTO |
| Action | Detects schema from files | Adds new columns automatically |
| Frequency | One-time | Continuous |
| Configuration | USING TEMPLATE + INFER_SCHEMA | ENABLE_SCHEMA_EVOLUTION = TRUE |

**RULE:** Detection = upfront, one-time. Evolution = ongoing, automatic.
**The trap:** Schema evolution does NOT change existing column types or remove columns. It only adds new ones.

---

## FLASHCARDS -- Domain 1

**Q1:** How long does Snowflake store COPY INTO load metadata?
**A1:** 64 days. After 64 days, the same file can be reloaded without FORCE = TRUE.

**Q2:** What does VALIDATION_MODE do in a COPY INTO statement?
**A2:** It validates the data files without loading any rows. Options: RETURN_ERRORS, RETURN_n_ROWS, RETURN_ALL_ERRORS.

**Q3:** What compute does Snowpipe use?
**A3:** Snowflake-managed serverless compute, not a user virtual warehouse.

**Q4:** What cloud services are needed for AUTO_INGEST with S3?
**A4:** An SQS queue configured with S3 event notifications pointing to the Snowpipe notification channel.

**Q5:** How does Snowpipe Streaming differ from Snowpipe in terms of staging?
**A5:** Snowpipe Streaming writes rows directly via the Ingest SDK without staging files. Snowpipe requires files on a stage.

**Q6:** Can you share a regular (non-secure) view?
**A6:** No. Only secure views, secure materialized views, and secure UDFs can be included in shares.

**Q7:** Who pays for compute in a reader account?
**A7:** The provider (the account that created the reader account) pays for all compute and storage.

**Q8:** What are the three types of internal stages?
**A8:** User stage (@~), table stage (@%table_name), and named internal stage (CREATE STAGE).

**Q9:** What does ENABLE_SCHEMA_EVOLUTION = TRUE do on a table?
**A9:** It automatically adds new columns to the table when COPY INTO encounters columns in the source file that do not exist in the target table.

**Q10:** What function detects the schema of staged files?
**A10:** INFER_SCHEMA(). It returns column names and data types from Parquet, Avro, ORC, or CSV (with PARSE_HEADER = TRUE).

**Q11:** Can you set a named FILE_FORMAT on a table stage?
**A11:** No. Table stages do not support file format assignment. Specify format options inline in the COPY command.

**Q12:** What is a storage integration used for?
**A12:** It decouples cloud credentials from stage definitions, using IAM roles or service principals instead of raw access keys.

**Q13:** What does FORCE = TRUE do in COPY INTO?
**A13:** It reloads files regardless of whether they were previously loaded (bypasses 64-day load metadata tracking), which can create duplicates.

**Q14:** What is the difference between a listing and a direct share for cross-region data sharing?
**A14:** A listing supports cross-region and cross-cloud sharing via auto-fulfillment. A direct share is limited to the same region.

**Q15:** How do you check Snowpipe status programmatically?
**A15:** Use the SYSTEM$PIPE_STATUS('pipe_name') function, which returns JSON with executionState, pendingFileCount, and other metadata.
