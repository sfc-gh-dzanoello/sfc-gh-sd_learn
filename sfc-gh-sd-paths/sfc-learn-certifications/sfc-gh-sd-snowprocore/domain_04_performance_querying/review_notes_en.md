# DOMAIN 4: PERFORMANCE OPTIMIZATION, QUERYING & TRANSFORMATION
## 21% of exam = ~21 questions

---

## 4.1 CACHING (VERY HEAVILY TESTED)

Snowflake has THREE cache layers. Each works differently.

### 1. Query Result Cache
- Stores the RESULT of previously executed queries
- Duration: 24 hours (resets if same query runs again, max 31 days of renewal)
- Scope: SHARED across all users in the account
- Location: Cloud Services layer
- Cost: FREE (no warehouse needed to return cached result)
- Conditions for cache hit:
  - Exact same SQL text
  - Same role
  - Underlying data has NOT changed
  - Same session settings
- Different user, same role → STILL uses cache
- Can disable: ALTER SESSION SET USE_CACHED_RESULT = FALSE

**Exam trap**: "Different user runs same query?" → YES, uses Result Cache (same role + data unchanged). IF YOU SEE "per-user cache" or "each user has own cache" → TRAP! Result cache is SHARED across users.
**Exam trap**: "Result cache duration?" → 24 hours (renewable up to 31 days). IF YOU SEE "indefinite" or "permanent" → TRAP! Max is 31 days, resets after 24hr of no reuse.
**Exam trap**: "Result cache stored where?" → Cloud Services layer. IF YOU SEE "warehouse" or "SSD" or "local disk" → TRAP! Result cache lives in Cloud Services, not on any warehouse.
**Exam trap**: "Cost of result cache hit?" → Zero (no warehouse credits). IF YOU SEE "warehouse required" or "consumes credits" with result cache → TRAP! Result cache is FREE, served by Cloud Services.

### 2. Warehouse Cache (Local Disk / SSD Cache)
- Caches raw table data on the warehouse's local SSD
- Speeds up subsequent queries on same data
- Duration: as long as warehouse is RUNNING
- **LOST when warehouse is suspended**
- Each warehouse has its own cache (not shared)

**Exam trap**: "Warehouse suspends → cache?" → Local disk cache is LOST. IF YOU SEE "cache persists" or "survives suspend" → TRAP! SSD cache is wiped the moment you suspend.
**Exam trap**: "Which cache is lost on suspend?" → Warehouse cache / Local Disk (SSD) Cache. IF YOU SEE "result cache" as the answer → TRAP! Result cache is in Cloud Services and is never lost on suspend.

### 3. Metadata Cache
- Stores table metadata (row counts, min/max, byte sizes)
- Used for: COUNT(*), MIN, MAX on entire table (no filter)
- Cloud Services layer handles this
- No warehouse needed for pure metadata queries
- Always available, cannot be disabled

### Cache Decision Flow:
```
Query arrives →
  1. Check Result Cache (exact match?) → YES → return instantly (free)
  2. Check Metadata Cache (metadata-only query?) → YES → return from metadata (free)
  3. Run on Warehouse → uses Warehouse Cache for data reads
```

### Why This Matters + Use Cases

**Why do caches matter so much?** Because Snowflake charges per-second for compute. If a cache can answer your query for FREE, that's real money saved — especially at scale with hundreds of users.

**Real scenario — "Our dashboard costs $500/day in warehouse credits"**
The same 10 dashboard queries run every 5 minutes for 50 users. But the underlying data only changes once per hour. Solution: Result Cache handles 95% of those queries for FREE (no warehouse spin-up). Only the first run after data changes costs credits.

**Real scenario — "We suspended the warehouse overnight to save money, but morning queries are slow"**
Warehouse SSD cache was wiped on suspend. First queries of the day must re-read from remote storage. This is the "cold start" penalty. Trade-off: save credits overnight vs. slower first queries. For critical dashboards, consider a longer auto-suspend timeout.

**Real scenario — "Our query scans 500GB but only returns 100 rows"**
Classic pruning problem. The table has billions of rows but the WHERE clause can't efficiently skip partitions. Fix: add a clustering key on the filtered column. After clustering, the same query scans 2GB instead of 500GB.

**Real scenario — "One analyst's giant query is blocking everyone else"**
50 users are queuing behind one massive report. Scale OUT (multi-cluster) so the big query gets its own cluster and everyone else gets theirs. Also set STATEMENT_TIMEOUT to kill queries that run too long.

---

### Best Practices — Performance
- Don't disable result cache (USE_CACHED_RESULT = TRUE is default — keep it)
- Avoid SELECT * — only query columns you need (columnar pruning)
- Use clustering keys ONLY on multi-TB tables with known filter patterns
- Check Query Profile for TableScan: if partitions scanned ≈ total, add clustering key
- Use EXPLAIN USING TABULAR to preview query plan without running it
- Set STATEMENT_TIMEOUT at warehouse level to kill runaway queries

### Example Scenario Questions — Caching

**Scenario:** A retail company runs an executive dashboard that refreshes every 2 minutes. The same 5 SQL queries are executed by 30 different analysts throughout the day. The underlying sales data is loaded via a nightly ETL job (once every 24 hours). The team notices their warehouse is running all day and costing significant credits. How can they reduce costs without changing the dashboard?
**Answer:** Since the underlying data only changes once per day (nightly ETL), the **Result Cache** will serve all repeated queries for free after the first execution — as long as the SQL text is identical, the role is the same, and the data hasn't changed. The warehouse only needs to run for the first execution after each nightly load. The team should ensure USE_CACHED_RESULT = TRUE (the default) and that the dashboard uses parameterized queries with consistent SQL text. They can also set a short auto-suspend timeout (1-2 minutes) so the warehouse stops between the rare cache misses. This could eliminate 95%+ of warehouse credit consumption.

**Scenario:** A data engineering team suspends their XL warehouse every night at 8 PM to save credits. Every morning at 7 AM, the first batch of queries takes 3-4x longer than normal. By 8 AM, query performance is back to normal. What is causing this, and what are the trade-offs of fixing it?
**Answer:** When the warehouse is suspended, the **Warehouse Cache (SSD/Local Disk Cache)** is completely wiped. The first morning queries must re-read all data from remote storage (cold start), which is much slower. By 8 AM, the SSD cache is warm again from repeated reads. The trade-off: keeping the warehouse running overnight preserves the cache but costs credits for idle time. Options: (1) accept the cold start penalty and save overnight credits, (2) increase auto-suspend to a longer timeout so it only suspends after extended inactivity, or (3) schedule a lightweight "warm-up" query to run just before the 7 AM workload begins.

**Scenario:** An analyst runs `SELECT COUNT(*) FROM sales_fact;` on a 500 billion-row table. The query returns instantly in under 1 second without a warehouse running. Another analyst runs `SELECT COUNT(*) FROM sales_fact WHERE region = 'EMEA';` and it takes 45 seconds with a warehouse. Why the dramatic difference?
**Answer:** The first query (`COUNT(*)` with no filter) is answered by the **Metadata Cache**, which stores pre-computed statistics like row counts, min/max values, and byte sizes. This is served by the Cloud Services layer for free — no warehouse needed. The second query includes a WHERE clause, so Snowflake cannot use metadata alone; it must actually scan (and prune) micro-partitions on a running warehouse. The metadata cache only works for full-table aggregate operations without filters.

**Scenario:** User A (role: ANALYST_ROLE) runs a complex 20-table join query that takes 8 minutes. User B (role: ANALYST_ROLE) runs the exact same query 10 minutes later. User C (role: FINANCE_ROLE) runs the same query 5 minutes after User B. Which users benefit from the result cache?
**Answer:** **User B** gets a result cache hit — same SQL text, same role (ANALYST_ROLE), and data unchanged within 24 hours. The query returns instantly with zero warehouse cost. **User C** does NOT get a result cache hit, even though the SQL is identical, because User C is using a different role (FINANCE_ROLE). The result cache requires the same role, same SQL text, and unchanged underlying data. User C's query will execute fully on the warehouse.

---

## 4.2 QUERY PROFILE & QUERY INSIGHTS (HEAVILY TESTED)

### Query Profile:
- Visual execution plan in Snowsight
- Shows: operators, data flow, statistics
- Use to identify performance bottlenecks

### Key metrics in Query Profile:

**Bytes Spilled to Local Storage (Local Disk Spilling)**:
- Query needed more memory than available
- Data spilled to local SSD
- Fix: INCREASE warehouse size (scale UP)

**Bytes Spilled to Remote Storage (Remote Disk Spilling)**:
- Even worse — spilled beyond local SSD to remote storage
- Much slower
- Fix: INCREASE warehouse size significantly

**Inefficient Pruning**:
- Too many partitions scanned vs partitions needed
- Scan-to-filter ratio is high
- Fix: add clustering key, review WHERE clauses
- Common cause: using functions on filter columns (e.g., WHERE UPPER(col) = 'X')

**Exploding Joins**:
- Join produces way more rows than input
- Usually Cartesian product or missing join condition
- Fix: review join conditions, add proper predicates

**Queuing**:
- Queries waiting for warehouse resources
- Fix: scale OUT (add clusters via multi-cluster warehouse)
- Not: scale UP (bigger size doesn't help with queuing)

### Key rules:
- Spilling (local or remote) → Scale UP (bigger warehouse)
- Queuing / concurrency → Scale OUT (more clusters)
- Pruning issues → Better clustering, fix WHERE clauses

**Exam trap**: "Local Disk Spilling fix?" → Increase warehouse size (scale UP). IF YOU SEE "add clusters" or "scale out" for spilling → TRAP! Spilling = memory problem = scale UP, not OUT.
**Exam trap**: "Remote Disk Spilling fix?" → Increase warehouse size even more. IF YOU SEE "scale out" or "multi-cluster" for remote spilling → TRAP! Remote spill is a worse memory problem = scale UP significantly.
**Exam trap**: "High queuing?" → Add clusters (scale OUT). IF YOU SEE "bigger warehouse" or "scale up" for queuing → TRAP! Queuing = concurrency problem = scale OUT with more clusters.
**Exam trap**: "MONITOR privilege needed for?" → Viewing other users' query profiles. IF YOU SEE "OPERATE" or "USAGE" as the privilege → TRAP! Only MONITOR grants access to other users' Query Profiles.

### Query History:
- ACCOUNT_USAGE.QUERY_HISTORY → 365 days, up to 45 min latency
- INFORMATION_SCHEMA.QUERY_HISTORY() → 7 days, real-time
- Shows: query text, duration, warehouse, bytes scanned, rows returned

### Query Attribution:
- Track resource consumption per query
- Understand which queries use the most credits/resources

### Example Scenario Questions — Query Profile & Query Insights

**Scenario:** A financial services company has a nightly reconciliation query that normally takes 15 minutes. Last night it took 2.5 hours. The DBA opens the Query Profile and sees "Bytes Spilled to Local Storage: 85 GB" and "Bytes Spilled to Remote Storage: 210 GB." The warehouse is a Medium. What happened, and what is the correct fix?
**Answer:** The query ran out of memory on the Medium warehouse and **spilled** data first to local SSD (85 GB), then to much slower remote storage (210 GB). Remote spilling is extremely expensive in terms of performance. The fix is to **scale UP** — increase the warehouse size to Large or XL to provide more memory so the query can process in-memory without spilling. Scaling OUT (adding clusters) would NOT help here because spilling is a memory problem for a single query, not a concurrency problem. The DBA should also check if the query changed (new joins, more data) to understand why it suddenly needs more memory.

**Scenario:** A BI team reports that their morning dashboard queries are slow. The Query Profile shows that a query on the `orders` table scans 12,000 out of 12,500 total micro-partitions, but only returns 500 rows where `order_date = '2025-12-01'`. What is the issue, and how should it be fixed?
**Answer:** This is a **pruning problem**. The query is scanning nearly all micro-partitions (12,000/12,500 = 96%) but only needs a tiny fraction of the data. The `order_date` column is not well-clustered, so Snowflake cannot skip irrelevant partitions. The fix: add a **clustering key** on `order_date` with `ALTER TABLE orders CLUSTER BY (order_date)`. After automatic clustering reorganizes the data, the same query might scan only 50-100 partitions instead of 12,000. Also check that the WHERE clause doesn't wrap the column in a function (e.g., `WHERE DATE_TRUNC('day', order_date)`) — functions on filter columns prevent pruning.

**Scenario:** A SaaS company has 150 concurrent users running reports on a single Large multi-cluster warehouse (max 3 clusters, Standard scaling). Users complain that queries are "stuck" and taking much longer than usual. The Query Profile shows minimal spilling but significant time in the "Initialization" phase. What is the problem?
**Answer:** The queries are **queuing** — waiting for available compute resources. With 150 concurrent users, even 3 clusters may not be enough. The "Initialization" wait time indicates queries sitting in the queue before execution begins. The fix is to **scale OUT** — either increase the maximum cluster count beyond 3, or create separate warehouses for different user groups (e.g., finance vs. operations). Scaling UP (bigger warehouse) would NOT help because the problem is concurrency (too many queries), not memory. They should also check STATEMENT_QUEUED_TIMEOUT_IN_SECONDS to auto-cancel queries that wait too long.

**Scenario:** A developer writes a query joining `customers` (10M rows) with `addresses` (50M rows) but accidentally omits the join condition, writing `FROM customers, addresses` instead of using a proper ON clause. The Query Profile shows the output has 500 trillion rows. What happened?
**Answer:** This is an **exploding join** (Cartesian product). Without a join condition, every row in `customers` is matched with every row in `addresses`: 10M x 50M = 500 trillion rows. The Query Profile would show the join operator producing massively more rows than the input. The fix: add the proper join predicate (`ON customers.customer_id = addresses.customer_id`). Always check join conditions when the Query Profile shows output rows >> input rows. This is a common exam scenario — if a join produces way more rows than expected, the answer is almost always a missing or incorrect join condition.

---

## 4.3 PERFORMANCE OPTIMIZATION SERVICES

### Query Acceleration Service (QAS) — Enterprise+
- Offloads portions of large scan queries to serverless compute
- Best for: queries that scan lots of data (large table scans)
- Serverless (Snowflake-managed compute, billed per use)
- You enable it on a warehouse: ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE
- Can set scale factor (0-100, where 0 = no limit; default is 8) to control max serverless compute
- Does NOT help with: small queries, queries already fast

**How it works**: Query has a big scan portion → QAS farms out parts of the scan to extra serverless compute → results merge back → faster execution

### Search Optimization Service (SOS) — Enterprise+
- Persistent data structure (like a secondary index)
- Best for: point lookup queries on high-cardinality columns
- Example: searching for a specific transaction ID in billions of rows
- Background maintenance (serverless, costs credits)
- Snowflake automatically maintains search access paths
- Reduces need for manual clustering on lookup columns

**Exam trap**: "Specific ID lookup in billions of rows?" → Search Optimization Service. IF YOU SEE "Query Acceleration" for point lookups → TRAP! QAS is for large scans. SOS is for specific ID/value lookups.
**Exam trap**: "SOS is like a..." → Secondary index / access paths. IF YOU SEE "materialized view" or "cached result" → TRAP! SOS builds search access paths (like an index), not pre-computed results.
**Exam trap**: "QAS offloads to..." → Shared serverless compute resources. IF YOU SEE "dedicated warehouse" or "user-managed compute" → TRAP! QAS uses Snowflake-managed serverless compute, not your warehouse.
**Exam trap**: "Both QAS and SOS are..." → Enterprise+ edition. IF YOU SEE "Standard edition" or "all editions" → TRAP! QAS, SOS, and Materialized Views all require Enterprise+ minimum.

### Clustering Keys
- Define which columns to cluster by
- ALTER TABLE ... CLUSTER BY (col1, col2)
- Automatic Clustering: background service maintains clustering
- Serverless (costs credits for maintenance)
- Best for: very large tables where queries filter on specific columns
- Co-locates similar data in micro-partitions → better pruning

**Exam trap**: "Add clustering key to existing table?" → ALTER TABLE ... CLUSTER BY. IF YOU SEE "CREATE TABLE" or "recreate table" → TRAP! You add clustering to existing tables with ALTER TABLE, no rebuild needed.
**Exam trap**: "Automatic clustering cost?" → Serverless credits (background maintenance). IF YOU SEE "free" or "no cost" → TRAP! Defining the key is free, but automatic maintenance consumes serverless credits.

### Materialized Views — Enterprise+
- Pre-computed query results stored physically
- Auto-refreshed when underlying data changes (background service, costs credits)
- Best for: expensive queries on data that changes infrequently
- Limitations: single table only, limited SQL features
- Can use Search Optimization on materialized views

### Example Scenario Questions — Performance Optimization Services

**Scenario:** A logistics company has a 2 TB `shipments` table with 8 billion rows. Their operations team frequently searches for individual shipment tracking numbers (e.g., `WHERE tracking_id = 'TRK-2025-8847291'`). These lookup queries take 30-60 seconds each. The team is considering enabling Query Acceleration Service. Is this the right choice?
**Answer:** No — **Search Optimization Service (SOS)** is the correct choice, not QAS. This is a **point lookup** scenario: searching for a specific value in a high-cardinality column across billions of rows. SOS builds persistent search access paths (like a secondary index) optimized for equality predicates, IN lists, and LIKE patterns. QAS is designed for large table scans, not targeted lookups. Enable SOS with `ALTER TABLE shipments ADD SEARCH OPTIMIZATION ON EQUALITY(tracking_id)`. After the background service builds the access paths, these lookups should drop from 30-60 seconds to under 1 second. SOS requires Enterprise+ edition.

**Scenario:** A media company runs ad-hoc analytics queries against a 5 TB `user_events` table. Most queries are fast, but occasionally an analyst runs a query that scans the entire table and takes 20+ minutes, blocking other work. The team wants to speed up these outlier queries without permanently upsizing the warehouse. What service should they use?
**Answer:** **Query Acceleration Service (QAS)** is ideal here. QAS offloads the scan-heavy portions of eligible queries to Snowflake-managed serverless compute, letting the outlier query finish faster without affecting other queries on the warehouse. Enable it with `ALTER WAREHOUSE analytics_wh SET ENABLE_QUERY_ACCELERATION = TRUE` and set a scale factor (e.g., 8) to control the maximum serverless compute allowed. QAS is billed per-use (serverless credits) so it only costs money when those outlier queries actually trigger it. This avoids the cost of permanently running a larger warehouse just for occasional heavy queries. Enterprise+ required.

**Scenario:** A healthcare analytics team runs the same expensive aggregation — total patient visits by department, region, and month — dozens of times per day. The underlying `patient_visits` table (800 GB) is only updated once daily via a batch load. Each execution takes 4 minutes on a Large warehouse. What optimization would provide the best performance improvement?
**Answer:** A **Materialized View** is the best fit. Since the query is expensive (4 min), repeated frequently, and the underlying data changes infrequently (once daily), a materialized view will pre-compute and physically store the aggregation results. Subsequent reads of the MV will be nearly instant since Snowflake reads the pre-computed result rather than re-scanning 800 GB. Snowflake automatically refreshes the MV when the base table changes (after the daily load). The trade-off: MVs consume storage and serverless credits for auto-refresh maintenance. Limitations to remember: MVs can only reference a single base table and support limited SQL features (no joins, no UDFs). Enterprise+ required.

**Scenario:** A fintech company has a 10 TB `transactions` table. Queries always filter by `transaction_date` and the table grows by 500 million rows per day. Query performance has degraded over time — the Query Profile shows poor pruning (scanning 80% of partitions). They've already tried increasing warehouse size with no improvement. What should they do?
**Answer:** Add a **clustering key** on `transaction_date` with `ALTER TABLE transactions CLUSTER BY (transaction_date)`. As the table grows, new data is appended in ingestion order, which may not align with `transaction_date`. This causes date ranges to be scattered across many micro-partitions, resulting in poor pruning. A clustering key tells Snowflake's Automatic Clustering service to reorganize micro-partitions so rows with similar `transaction_date` values are co-located. After reclustering, queries filtering by date will skip most partitions. Note: clustering keys work on ALL editions, but the Automatic Clustering background maintenance consumes serverless credits. Scaling UP the warehouse wouldn't help here — the problem is I/O (reading too many partitions), not memory.

---

## 4.4 WORKLOAD MANAGEMENT BEST PRACTICES

### Group similar workloads:
- Separate warehouses for: ETL loading, BI reporting, ad-hoc queries, data science
- Prevents one workload from starving another

### Right-size warehouses:
- Start small, scale up if needed
- Complex queries → bigger warehouse
- Simple queries → small warehouse
- Loading → depends on number of files (not just data volume)

### Use auto-suspend:
- Save credits when warehouse is idle
- Short timeout for interactive workloads (1-5 minutes)
- Longer timeout for BI tools with frequent queries

### Timeout parameters:
- STATEMENT_TIMEOUT_IN_SECONDS → kill queries that run too long
- STATEMENT_QUEUED_TIMEOUT_IN_SECONDS → kill queries waiting too long in queue

**Exam trap**: "Economy vs Standard scaling policy?" → Economy waits ~6 min before adding clusters (saves credits). Standard adds immediately. IF YOU SEE "Economy adds clusters faster" or "immediately" with Economy → TRAP! Economy WAITS ~6 min. Standard is the fast one.
**Exam trap**: "Auto-suspend set to 0?" → Warehouse NEVER auto-suspends. IF YOU SEE "immediate suspend" or "instant shutdown" for 0 → TRAP! 0 = disabled = warehouse runs forever until manually suspended.
**Exam trap**: "STATEMENT_TIMEOUT vs STATEMENT_QUEUED_TIMEOUT?" → TIMEOUT kills running queries. QUEUED_TIMEOUT kills queries still waiting in queue. IF YOU SEE these swapped → TRAP! TIMEOUT = running. QUEUED_TIMEOUT = waiting.

### Example Scenario Questions — Workload Management Best Practices

**Scenario:** A company has a single XL warehouse shared by the ETL team (heavy nightly loads), the BI team (daytime dashboards), and the data science team (ad-hoc ML queries). The BI team complains that their dashboards are slow every morning while the ETL job is still finishing. What is the recommended architectural change?
**Answer:** Create **separate warehouses** for each workload type: one for ETL loading, one for BI reporting, and one for data science ad-hoc queries. This is Snowflake's core best practice for workload isolation — it prevents one workload from starving another. The ETL warehouse can be sized larger (XL) for heavy transforms, the BI warehouse can be a Medium multi-cluster warehouse for high concurrency, and the data science warehouse can be a Large with aggressive auto-suspend since usage is sporadic. Each team gets dedicated resources and predictable performance.

**Scenario:** An e-commerce company uses an Enterprise edition warehouse with Economy scaling policy (min 1, max 5 clusters). During Black Friday, users report that queries are queuing for several minutes before executing, even though the system is allowed up to 5 clusters. Support confirms only 2 clusters are running. What is happening?
**Answer:** The **Economy scaling policy** waits approximately 6 minutes of sustained queuing before adding a new cluster — it prioritizes cost savings over immediate performance. During a traffic spike like Black Friday, this 6-minute delay per cluster means it takes a long time to scale from 1 to 5 clusters. The fix: switch to **Standard scaling policy**, which adds clusters immediately when queries begin queuing. Standard is the right choice for performance-sensitive, user-facing workloads. Economy is better suited for cost-sensitive batch workloads where a few minutes of queuing is acceptable.

**Scenario:** A team has a warehouse that processes bursts of queries every 30 minutes (triggered by a scheduler) but sits completely idle in between. The auto-suspend is set to 10 minutes. They notice they're paying for 20 minutes of idle time per hour. What should they change?
**Answer:** Reduce the **auto-suspend timeout** to 1-2 minutes (e.g., `ALTER WAREHOUSE SET AUTO_SUSPEND = 60`). Since the workload is bursty with 30-minute gaps, a 10-minute timeout means the warehouse runs idle for 10 minutes after each burst before suspending — wasting credits. With a 1-minute timeout, it suspends almost immediately after the burst completes. Auto-resume (enabled by default) will automatically restart the warehouse when the next scheduled burst arrives. The trade-off: the first query of each burst will have a small cold-start delay (a few seconds for warehouse provisioning), but the credit savings from 28+ minutes of avoided idle time per hour far outweigh this.

**Scenario:** A data platform team discovers that a single analyst's query has been running for 14 hours, consuming an XL warehouse the entire time. It appears to be an accidental Cartesian join. How can they prevent this from happening again?
**Answer:** Set **STATEMENT_TIMEOUT_IN_SECONDS** at the warehouse level to automatically kill queries that exceed a reasonable duration. For example, `ALTER WAREHOUSE SET STATEMENT_TIMEOUT_IN_SECONDS = 3600` would kill any query running longer than 1 hour. They should also set **STATEMENT_QUEUED_TIMEOUT_IN_SECONDS** to prevent queries from waiting indefinitely in queue. These parameters can be set at the account, warehouse, or session level. For the immediate issue, the admin can manually cancel the running query. Important distinction: STATEMENT_TIMEOUT kills *running* queries, while STATEMENT_QUEUED_TIMEOUT kills queries *waiting in the queue* — don't confuse them on the exam.

---

## 4.5 DATA TYPES & TRANSFORMATION

### Structured Data:
- Standard SQL types: VARCHAR, NUMBER, DATE, TIMESTAMP, BOOLEAN, etc.
- Standard table operations

### Semi-Structured Data:
- Stored in VARIANT, OBJECT, ARRAY columns
- Navigate with dot notation: col:key.subkey
- Cast with ::type notation: col:name::string
- Key functions:
  - PARSE_JSON() → string to VARIANT
  - FLATTEN() → expand arrays/objects into rows
  - LATERAL FLATTEN → join flattened output with other columns
  - OBJECT_KEYS() → get all keys
  - ARRAY_SIZE() → count array elements
  - TYPEOF() → check VARIANT type
  - GET_PATH() / GET() → extract values

### Unstructured Data:
- Images, PDFs, audio, video
- Stored in internal/external stages
- Referenced via stage URLs (VARCHAR) — there is no FILE data type in Snowflake
- Process with UDFs, external functions, or Cortex AI

**Exam trap**: "FLATTEN vs PARSE_JSON?" → PARSE_JSON converts a string TO VARIANT. FLATTEN expands VARIANT INTO rows. IF YOU SEE these swapped or treated as the same → TRAP! PARSE_JSON = string→VARIANT. FLATTEN = VARIANT→rows. Opposite directions.
**Exam trap**: "Dot notation col:key works on VARCHAR?" → WRONG. IF YOU SEE "col:key" on a VARCHAR column → TRAP! Dot notation only works on VARIANT/OBJECT. Must PARSE_JSON first if it's a string.
**Exam trap**: "ARRAY and OBJECT are the same as VARIANT?" → WRONG. IF YOU SEE "interchangeable" or "identical" → TRAP! VARIANT is the generic container. ARRAY = ordered list, OBJECT = key-value pairs. Three distinct types.

### Example Scenario Questions — Data Types & Transformation

**Scenario:** A company ingests IoT sensor data as JSON into a `sensor_readings` table with a VARIANT column called `payload`. A typical record looks like: `{"device_id": "D-4421", "readings": [{"temp": 72.5, "humidity": 45}, {"temp": 73.1, "humidity": 44}], "timestamp": "2025-06-15T10:30:00Z"}`. An analyst needs to produce one row per individual reading with the device ID and timestamp. How should they write this query?
**Answer:** Use **LATERAL FLATTEN** to expand the nested `readings` array into individual rows, combined with dot notation and casting to extract the scalar values:
```sql
SELECT
  payload:device_id::STRING AS device_id,
  payload:timestamp::TIMESTAMP AS event_time,
  f.value:temp::FLOAT AS temperature,
  f.value:humidity::FLOAT AS humidity
FROM sensor_readings,
  LATERAL FLATTEN(input => payload:readings) f;
```
Key concepts: `payload:device_id` uses dot notation to navigate the VARIANT. `::STRING` casts the VARIANT element to a typed value. `LATERAL FLATTEN` expands the array so each element becomes its own row. `f.value` accesses the current array element. Without LATERAL, you'd lose the correlation back to the parent row's `device_id` and `timestamp`.

**Scenario:** A developer stores API response data as a VARCHAR column containing JSON strings (not VARIANT). They try to query it with `SELECT api_response:status_code FROM api_logs` and get an error. What is wrong, and how should they fix it?
**Answer:** Dot notation (`col:key`) only works on **VARIANT, OBJECT, or ARRAY** columns — not on VARCHAR. Even though the VARCHAR contains valid JSON text, Snowflake treats it as a plain string. The fix: use **PARSE_JSON()** to convert the string to VARIANT first: `SELECT PARSE_JSON(api_response):status_code::NUMBER FROM api_logs`. Alternatively, the better long-term fix is to change the column type to VARIANT during ingestion. Remember: PARSE_JSON converts string→VARIANT (parsing direction), while FLATTEN converts VARIANT→rows (expanding direction). These are opposite operations and a common exam confusion point.

**Scenario:** A data engineer is migrating a legacy system that stores customer preferences as deeply nested JSON. Some customers have preferences nested 5+ levels deep (e.g., `payload:settings:notifications:email:frequency:value`). They ask whether Snowflake's VARIANT column can handle this depth, and whether there are performance considerations for deeply nested semi-structured data.
**Answer:** Snowflake's VARIANT type can handle arbitrary nesting depth — there is no hard limit on JSON nesting levels. However, there are performance considerations. Snowflake automatically extracts and optimizes commonly accessed top-level keys in VARIANT columns into a columnar format for better pruning and performance. Deeply nested paths may not benefit from this automatic optimization. For frequently queried deep paths, consider: (1) using FLATTEN to normalize deeply nested structures into separate rows/columns at ingestion time, (2) creating a view that extracts commonly used paths with `GET_PATH()` or dot notation, or (3) materializing frequently accessed nested values into dedicated typed columns for better query performance and pruning.

---

## 4.6 SQL QUERY TECHNIQUES

### Aggregate Functions:
- COUNT, SUM, AVG, MIN, MAX, LISTAGG
- GROUP BY, HAVING
- GROUPING SETS, ROLLUP, CUBE (for subtotals)

### Window Functions:
- Perform calculations across related rows
- Syntax: function() OVER (PARTITION BY col ORDER BY col)
- Common: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM, AVG
- ROWS BETWEEN / RANGE BETWEEN for frame specification
- Running totals, moving averages, ranking

### Common Table Expressions (CTEs):
- WITH clause for readable, reusable subqueries
- Improve readability of complex queries
- Can reference earlier CTEs in same WITH block

### LATERAL:
- Used with FLATTEN to join flattened results with source row
- SELECT t.id, f.value FROM table t, LATERAL FLATTEN(input => t.array_col) f

### Query Optimization Tips:
- Filter early (WHERE clauses push down)
- Avoid SELECT * (scan unnecessary columns)
- Use clustering keys for large table filters
- Avoid functions on filtered columns (prevents pruning)
- Use LIMIT for exploration queries
- Avoid Cartesian joins (always have join conditions)

**Exam trap**: "QUALIFY vs HAVING vs WHERE?" → WHERE = before grouping. HAVING = after GROUP BY. QUALIFY = after window functions. IF YOU SEE "interchangeable" or any of these swapped → TRAP! Each filters at a different stage of query execution.
**Exam trap**: "RANK vs DENSE_RANK vs ROW_NUMBER?" → ROW_NUMBER = always unique (1,2,3). RANK = gaps on ties (1,1,3). DENSE_RANK = no gaps (1,1,2). IF YOU SEE "RANK and DENSE_RANK are the same" → TRAP! RANK skips numbers after ties, DENSE_RANK does not.
**Exam trap**: "PIVOT vs UNPIVOT?" → PIVOT = rows→columns (tall→wide). UNPIVOT = columns→rows (wide→tall). IF YOU SEE these reversed → TRAP! PIVOT makes it wider, UNPIVOT makes it taller. Exact opposites.

### Example Scenario Questions — SQL Query Techniques

**Scenario:** A sales manager needs a report showing each salesperson's monthly revenue alongside a running total for the year. The output should keep every individual monthly row visible (not collapsed). A junior analyst suggests using `GROUP BY salesperson, month` with `SUM(revenue)`. Why is this approach incomplete, and what is the correct technique?
**Answer:** GROUP BY with SUM would give the monthly total per salesperson, but it cannot produce a **running total** across months while keeping each row visible. The correct approach is a **window function**:
```sql
SELECT salesperson, month, revenue,
  SUM(revenue) OVER (PARTITION BY salesperson ORDER BY month
    ROWS UNBOUNDED PRECEDING) AS ytd_revenue
FROM monthly_sales;
```
The window function calculates the running sum across all preceding months within each salesperson's partition, without collapsing rows. GROUP BY collapses rows; window functions preserve them. This is a key exam distinction — if the question says "keep all rows" or "running total," think window functions, not GROUP BY.

**Scenario:** A data team has a `user_logins` table with duplicate entries (same user can log in multiple times per day). They need to keep only the most recent login per user per day. An analyst writes a subquery with GROUP BY and MAX(login_time), then joins back to get the full row. A senior engineer suggests a simpler approach. What is it?
**Answer:** Use **QUALIFY** with **ROW_NUMBER()** — this is the idiomatic Snowflake approach for deduplication:
```sql
SELECT *
FROM user_logins
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY user_id, DATE(login_time)
  ORDER BY login_time DESC
) = 1;
```
QUALIFY filters the results of window functions directly, eliminating the need for a subquery or CTE wrapper. It executes after window functions are computed (just like HAVING executes after GROUP BY). The execution order is: WHERE → GROUP BY/HAVING → Window Functions → QUALIFY. Remember: QUALIFY is not part of the ANSI SQL standard but is supported by Snowflake, Teradata, BigQuery, and DuckDB — this is a common exam point.

**Scenario:** A finance team has a `quarterly_results` table with columns: `company`, `Q1_revenue`, `Q2_revenue`, `Q3_revenue`, `Q4_revenue`. They need to transform this into a normalized format with columns: `company`, `quarter`, `revenue` — one row per company per quarter. What SQL technique should they use?
**Answer:** Use **UNPIVOT** to convert columns into rows (wide→tall):
```sql
SELECT company, quarter, revenue
FROM quarterly_results
  UNPIVOT(revenue FOR quarter IN (Q1_revenue, Q2_revenue, Q3_revenue, Q4_revenue));
```
UNPIVOT takes the four separate quarter columns and rotates them into rows, creating a `quarter` column (with the original column names as values) and a `revenue` column (with the corresponding values). The opposite operation — PIVOT — would convert rows back into columns (tall→wide) and requires an aggregate function. On the exam, remember: PIVOT = rows→columns (makes wider), UNPIVOT = columns→rows (makes taller).

**Scenario:** A product team needs a report showing total sales by region and product category, but they also need subtotal rows for each region and a grand total row at the bottom. Writing multiple UNION ALL queries for each subtotal level seems cumbersome. What is the efficient approach?
**Answer:** Use **ROLLUP** within GROUP BY to automatically generate hierarchical subtotals:
```sql
SELECT region, product_category, SUM(sales) AS total_sales
FROM sales_data
GROUP BY ROLLUP(region, product_category);
```
ROLLUP produces subtotals in a left-to-right hierarchy: (region, product_category), (region, NULL) for region subtotals, and (NULL, NULL) for the grand total. If they needed ALL possible combinations of subtotals (not just hierarchical), they'd use **CUBE** instead. If they only needed specific custom grouping combinations, they'd use **GROUPING SETS**. The exam tests the distinction: ROLLUP = hierarchical, CUBE = all combos, GROUPING SETS = you pick exactly which.

---

## 4.7 STORED PROCEDURES vs UDFs

### Stored Procedures:
- Execute procedural logic
- Can include DDL/DML (CREATE, INSERT, etc.)
- Called with CALL procedure_name()
- Languages: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Can return a single value or RETURNS TABLE(...) for tabular results

### UDFs (User-Defined Functions):
- Return values for use in SQL expressions
- Can be used in SELECT, WHERE, etc.
- Languages: SQL, JavaScript, Python, Java, Scala
- Can be scalar (one value) or tabular (UDTF - returns table)
- Cannot execute DDL/DML

### External Functions:
- Call external APIs (AWS Lambda, Azure Functions)
- Require API Integration
- Data leaves Snowflake → processes externally → returns

**Exam trap**: "Execute DDL inside a function?" → Use Stored Procedure (not UDF). IF YOU SEE "UDF" with CREATE/INSERT/DDL → TRAP! UDFs cannot run DDL/DML. Only Stored Procedures can.
**Exam trap**: "Use in SELECT statement?" → UDF (not Stored Procedure). IF YOU SEE "CALL" inside SELECT or Stored Procedure in SELECT → TRAP! Procedures use CALL, only UDFs work inside SELECT/WHERE.
**Exam trap**: "NOT a supported language for stored procedures?" → C++ (not supported). IF YOU SEE "C++" as a valid language → TRAP! Supported: SQL, JavaScript, Python, Java, Scala. No C++.

### Example Scenario Questions — Stored Procedures vs UDFs

**Scenario:** A data engineering team needs to automate an end-of-month process that: (1) creates a new archive table with the current month's name, (2) inserts all transactions from the current month into that archive table, (3) deletes the archived transactions from the main table, and (4) returns a count of rows archived. Should they use a stored procedure or a UDF?
**Answer:** This requires a **Stored Procedure**. The process involves DDL (CREATE TABLE), DML (INSERT, DELETE), and procedural logic — none of which are allowed in a UDF. The procedure would be called with `CALL archive_monthly_transactions()`. UDFs are restricted to returning values and cannot execute DDL or DML statements. This is one of the most common exam distinctions: if the task involves CREATE, INSERT, UPDATE, DELETE, MERGE, or any schema changes, the answer is always Stored Procedure.

**Scenario:** A marketing team needs a reusable function that takes a customer's purchase history (total spend and number of orders) and returns a loyalty tier label ('Platinum', 'Gold', 'Silver', 'Bronze'). They want to use it directly in SELECT statements like: `SELECT customer_name, calculate_loyalty_tier(total_spend, order_count) FROM customers`. Should this be a procedure or a UDF?
**Answer:** This must be a **scalar UDF** (User-Defined Function). The requirement to use it inside a SELECT statement is the key indicator — only UDFs can be embedded in SQL expressions (SELECT, WHERE, HAVING, etc.). Stored procedures are invoked with CALL and cannot be used inside queries. The UDF would accept two numeric inputs and return a VARCHAR tier label. It could be written in SQL, Python, Java, or JavaScript. Example: `CREATE FUNCTION calculate_loyalty_tier(spend FLOAT, orders INT) RETURNS VARCHAR AS $$ ... $$`.

**Scenario:** A company needs to call an external fraud detection API (hosted on AWS Lambda) from within Snowflake during query execution. For each transaction row, they want to send the transaction details to the API and get back a fraud risk score. What type of function should they create, and what additional Snowflake object is required?
**Answer:** They need an **External Function** backed by an **API Integration**. External functions allow Snowflake to call external REST APIs (like AWS Lambda or Azure Functions) during query execution. The setup requires: (1) an API Integration object that defines the trusted external endpoint and authentication, (2) the external function definition that maps Snowflake input/output to the API request/response. Once created, the external function works like a UDF in SELECT statements: `SELECT transaction_id, fraud_check(amount, merchant, location) AS risk_score FROM transactions`. Key consideration: data leaves Snowflake to the external service, so security and latency must be evaluated. External functions are slower than native UDFs because of the network round-trip.

**Scenario:** A developer needs to write a function that takes a department ID and returns a table of all employees in that department with their calculated bonus amounts. The output needs to be used in a FROM clause: `SELECT * FROM TABLE(get_department_bonuses(101))`. What type of object should they create?
**Answer:** They need a **User-Defined Table Function (UDTF)** — a UDF that `RETURNS TABLE(...)`. UDTFs return multiple rows (unlike scalar UDFs which return a single value) and are invoked with the `TABLE()` wrapper in the FROM clause. This is NOT a stored procedure — procedures use CALL and return a single value, not a result set usable in FROM. The UDTF can be written in SQL, Python, Java, or JavaScript. Example skeleton: `CREATE FUNCTION get_department_bonuses(dept_id INT) RETURNS TABLE(emp_name VARCHAR, bonus FLOAT) AS $$ ... $$`. On the exam, if you see TABLE() in FROM, think UDTF. If you see CALL, think stored procedure.

---

## RAPID-FIRE REVIEW — Domain 4

1. Three caches: Result (24hr, shared, free), Warehouse (SSD, lost on suspend), Metadata (always on)
2. Result cache shared across users (same role + same SQL + data unchanged)
3. Warehouse suspend = local cache GONE
4. Spilling (local or remote) = scale UP (bigger warehouse)
5. Queuing = scale OUT (more clusters)
6. Functions on WHERE columns = prevents pruning
7. Query Acceleration Service = serverless, large scans, Enterprise+
8. Search Optimization = point lookups, like secondary index, Enterprise+
9. Clustering keys = co-locate data, better pruning, auto-maintained
10. Materialized views = pre-computed, auto-refreshed, Enterprise+
11. STATEMENT_TIMEOUT_IN_SECONDS = kill long-running queries
12. VARIANT = semi-structured container
13. FLATTEN + LATERAL = expand nested data into rows
14. Window functions = calculations across partitions (ROW_NUMBER, RANK, etc.)
15. Stored Procedures = procedural + DDL/DML. UDFs = return values in SQL.
16. C++ is NOT supported for stored procedures or UDFs
17. MONITOR privilege = view other users' query profiles
18. Query Profile shows: operators, spilling, pruning efficiency, join explosions
19. Separate warehouses per workload type
20. Auto-suspend saves credits when idle

**Exam trap**: "Clustering keys require Enterprise edition?" → WRONG. Clustering keys work on ALL editions. IF YOU SEE "Enterprise required" for clustering keys → TRAP! Only Automatic Clustering maintenance is serverless-billed. The key itself works on any edition.
**Exam trap**: "QUALIFY is a Snowflake-only clause?" → Correct. IF YOU SEE "ANSI SQL standard" with QUALIFY → TRAP! QUALIFY is Snowflake-specific, not standard ANSI SQL. Filters window function results directly.

---

## CONFUSING PAIRS — Domain 4

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Cache lost on suspend | Warehouse cache (SSD) | Result cache |
| Cache shared across users | Result cache | Warehouse cache |
| Cache with no cost | Result cache | Warehouse cache |
| Duration of result cache | 24 hours (31 days max renewal) | Indefinite |
| Fix spilling | Scale UP (bigger warehouse) | Scale OUT (more clusters) |
| Fix queuing | Scale OUT (more clusters) | Scale UP (bigger warehouse) |
| Point lookups on billions of rows | Search Optimization | Query Acceleration |
| Large table scans | Query Acceleration | Search Optimization |
| Pre-computed results | Materialized View | Standard View |
| Prevent pruning | Functions on filter columns | Simple WHERE clauses |
| Background maintenance cost | Serverless credits | Free |
| DDL inside SQL logic | Stored Procedure | UDF |
| Use in SELECT/WHERE | UDF | Stored Procedure |
| Kill long query | STATEMENT_TIMEOUT_IN_SECONDS | Resource Monitor |
| Kill queued query | STATEMENT_QUEUED_TIMEOUT_IN_SECONDS | Auto-suspend |
| Flatten nested array | LATERAL FLATTEN | PARSE_JSON |
| Navigate JSON | Dot notation (col:key) | Array indexing |

**Exam trap**: "Materialized view vs result cache?" → MV is a physical pre-computed table (auto-refreshed, costs credits). Result cache is a stored query answer (24hr, free). IF YOU SEE these treated as equivalent → TRAP! MV = persistent physical object. Result cache = temporary cached answer. Totally different mechanisms.
**Exam trap**: "LATERAL FLATTEN vs just FLATTEN?" → LATERAL is needed to correlate flattened output back to the source row. IF YOU SEE FLATTEN without LATERAL in a joined query → TRAP! Without LATERAL you lose the join context to the parent row.

---

## BRAIN-FRIENDLY SUMMARY — Domain 4

### SCENARIO DECISION TREES
When you read a question, find the pattern:

**"A bank's end-of-month report query is spilling to local disk..."**
→ Scale UP (bigger warehouse = more memory)
→ NOT scale OUT (more clusters don't help one slow query)

**"A bank's end-of-month report is spilling to REMOTE disk..."**
→ Scale UP even MORE (remote spill = really needs more memory)
→ Same fix, just more urgent

**"An e-commerce site has 200 analysts all querying at the same time and queries are queuing..."**
→ Scale OUT (multi-cluster warehouse, Enterprise+)
→ NOT scale UP (bigger warehouse doesn't reduce queue)

**"A healthcare company runs the same patient lookup query thousands of times a day..."**
→ Result Cache handles this (24hr, free, no warehouse needed)
→ Same SQL + same role + data unchanged = cache hit

**"A different analyst runs the exact same query as another analyst..."**
→ STILL uses Result Cache (shared across users IF same role)
→ Different user doesn't matter — same role + same SQL = cache hit

**"An admin suspends a warehouse to save costs. What happens to cached data?"**
→ Warehouse (SSD) cache is LOST
→ Result cache is fine (it's in Cloud Services, not the warehouse)

**"A telecom company searches for a specific phone number in 5 billion call records..."**
→ Search Optimization Service (point lookup, high cardinality, Enterprise+)
→ NOT Query Acceleration (that's for large SCANS)

**"A retail company's dashboard scans the entire sales table every morning..."**
→ Query Acceleration Service (offloads large scan portions, Enterprise+)
→ NOT Search Optimization (that's for specific ID lookups)

**"A query's WHERE clause uses UPPER(email) = 'TEST@MAIL.COM'..."**
→ BAD — function on column prevents pruning
→ Fix: store a pre-computed column or rewrite the filter

**"A join produces 100x more rows than the input tables..."**
→ Exploding join / Cartesian product
→ Fix: check join conditions, add proper predicates

**"A data science team runs expensive ML queries on data that rarely changes..."**
→ Materialized View (pre-computed, auto-refreshed, Enterprise+)
→ Best when: expensive query + infrequent data changes

**"A client wants to run procedural logic with CREATE TABLE inside..."**
→ Stored Procedure (can run DDL/DML)
→ NOT UDF (UDFs cannot run DDL/DML)

**"A client wants a reusable function inside SELECT and WHERE clauses..."**
→ UDF (returns values usable in SQL expressions)
→ NOT Stored Procedure (called with CALL, not in SELECT)

**"A client wants to call an external AWS Lambda function from Snowflake..."**
→ External Function + API Integration
→ Data leaves Snowflake, processes externally, returns

**"A client's table has 10 billion rows. Queries always filter by date but it's slow..."**
→ Add clustering key on the date column (ALTER TABLE ... CLUSTER BY (date_col))
→ Auto-clustering maintains it (serverless credits)
→ Co-locates similar dates in same micro-partitions → better pruning

**"A client resized a warehouse from Small to Large while a query was running. Does the running query benefit?"**
→ NO. Running queries use the OLD size.
→ Only NEW queries after resize use the Large warehouse.

**"A client's Query Profile shows high 'Bytes Scanned' but low 'Rows Returned'..."**
→ Poor pruning — scanning way more data than needed
→ Fix: add/improve clustering key, check WHERE clauses

**"A client needs running totals across monthly sales data..."**
→ Window function: SUM(sales) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING)
→ NOT GROUP BY (that collapses rows, window functions keep all rows)

**"A client needs to rank employees by salary within each department..."**
→ RANK() or DENSE_RANK() OVER (PARTITION BY dept ORDER BY salary DESC)
→ RANK = gaps in ranking (ties skip), DENSE_RANK = no gaps

**"A client has nested JSON arrays in a VARIANT column and needs each array element as a separate row..."**
→ LATERAL FLATTEN(input => col:array_key)
→ Each element becomes its own row, joined back to the source

**"A client asks: what's the difference between GROUPING SETS, ROLLUP, and CUBE?"**
→ GROUPING SETS = specific combinations you choose
→ ROLLUP = hierarchical subtotals (year → month → day)
→ CUBE = ALL possible combinations of subtotals

**"An ETL warehouse and a BI reporting warehouse are competing for resources..."**
→ Use SEPARATE warehouses for each workload (best practice)
→ ETL = dedicated warehouse, BI = dedicated warehouse
→ Prevents one workload from starving the other

**"A client wants to automatically kill queries that run longer than 30 minutes..."**
→ STATEMENT_TIMEOUT_IN_SECONDS = 1800
→ Set at warehouse, session, or account level

**"A client's warehouse sits idle most of the day but gets bursts of queries every hour..."**
→ Short auto-suspend timeout (1-2 minutes) to save credits during idle
→ Auto-resume handles the bursts automatically

**"A client wants a UDTF (table function) that returns multiple rows..."**
→ User-Defined Table Function (RETURNS TABLE)
→ Languages: SQL, JavaScript, Python, Java
→ Used with TABLE() in FROM clause

---

### MNEMONICS TO LOCK IN

**Three caches = "R-W-M" → "Result, Warehouse, Metadata"**
- **R**esult Cache → 24hr, FREE, shared, Cloud Services layer
- **W**arehouse Cache → SSD, LOST on suspend, per-warehouse
- **M**etadata Cache → always on, COUNT(*)/MIN/MAX, free

**Cache flow = "R then M then W"**
- Query arrives → check Result cache first → then Metadata → then run on Warehouse

**Spilling vs Queuing = "UP for Power, OUT for People"**
- Spilling (local or remote) → scale UP (bigger warehouse = more memory)
- Queuing (too many queries) → scale OUT (more clusters = more room)

**Performance services = "QAS-SOS-CK-MV"**
- **Q**AS = Query Acceleration Service (large scans, serverless, Enterprise+)
- **S**OS = Search Optimization Service (point lookups, like an index, Enterprise+)
- **C**K = Clustering Keys (co-locate data, better pruning, ALL editions)
- **M**V = Materialized Views (pre-computed results, Enterprise+)

**Procedures vs UDFs = "Procedures DO, Functions RETURN"**
- Stored Procedures → DO things (DDL, DML, procedural logic) → CALL
- UDFs → RETURN values → use in SELECT/WHERE

**Semi-structured navigation = "Dot-Cast-Flat"**
- **Dot** notation → col:key.subkey (navigate)
- **Cast** → ::string, ::number (convert types)
- **Flat**ten → LATERAL FLATTEN (expand arrays into rows)

---

### TOP TRAPS — Domain 4

1. **"Result cache requires a running warehouse"** → WRONG. Result cache is FREE, no warehouse needed.
2. **"Result cache is per-user"** → WRONG. Shared across users (same role + same SQL + data unchanged).
3. **"Warehouse cache survives suspend"** → WRONG. SSD cache LOST on suspend.
4. **"Spilling → add more clusters"** → WRONG. Spilling → bigger warehouse (scale UP).
5. **"Queuing → bigger warehouse"** → WRONG. Queuing → more clusters (scale OUT).
6. **"Search Optimization = large table scans"** → WRONG. SOS = point lookups. QAS = large scans.
7. **"Clustering keys require Enterprise"** → WRONG. ALL editions. (Auto-clustering maintenance is serverless.)
8. **"UDFs can run CREATE TABLE"** → WRONG. Only Stored Procedures can run DDL/DML.
9. **"C++ is supported for UDFs"** → WRONG. Supported: SQL, JavaScript, Python, Java, Scala.
10. **"Materialized views can join multiple tables"** → WRONG. Single table only.

---

### PATTERN SHORTCUTS — "If you see ___, answer is ___"

| If the question mentions... | The answer is almost always... |
|---|---|
| "spilling to local disk" | Scale UP (bigger warehouse) |
| "spilling to remote disk" | Scale UP MORE (much bigger warehouse) |
| "queries queuing" | Scale OUT (multi-cluster) |
| "same query, different user, same role" | Result Cache (still works) |
| "warehouse suspended, what about cache" | SSD/warehouse cache = LOST |
| "COUNT(*) with no WHERE, instant" | Metadata Cache |
| "search one ID in billions of rows" | Search Optimization Service |
| "large scan offloaded" | Query Acceleration Service |
| "pre-computed, auto-refreshed" | Materialized View |
| "co-locate data, better pruning" | Clustering Keys |
| "function in WHERE prevents..." | Pruning (rewrite the filter) |
| "too many rows from join" | Exploding join / missing join condition |
| "CALL procedure_name()" | Stored Procedure |
| "used in SELECT/WHERE" | UDF |
| "DDL inside code logic" | Stored Procedure (not UDF) |
| "VARIANT column" | Semi-structured data |
| "FLATTEN + LATERAL" | Expand nested arrays/objects |
| "col:key::string" | Semi-structured navigation + casting |
| "STATEMENT_TIMEOUT_IN_SECONDS" | Kill long-running queries |
| "STATEMENT_QUEUED_TIMEOUT_IN_SECONDS" | Kill queries waiting too long |
| "separate warehouses per workload" | Best practice for workload isolation |
| "Economy scaling policy" | Saves credits, waits 6 min before adding cluster |
| "Standard scaling policy" | Performance first, adds cluster immediately |

**Exam trap**: "Resize warehouse while query running — does the running query benefit?" → NO. Only NEW queries use the new size. Running queries keep the old size.
**Exam trap**: "GROUPING SETS vs ROLLUP vs CUBE?" → GROUPING SETS = you pick exact combos. ROLLUP = hierarchical left-to-right. CUBE = every possible combo. WRONG: "They all produce the same output."
**Exam trap**: "Caller's rights vs owner's rights default?" → Default is OWNER's rights. WRONG: "Default is caller's rights."

---

## EXAM DAY TIPS — Domain 4 (21% = ~21 questions)

**Before studying this domain:**
- Flashcard the 3 caches (Result, Warehouse, Metadata) — what's shared, what's lost, what's free
- Flashcard "spilling = UP, queuing = OUT" — this comes up over and over
- Know QAS vs SOS: QAS = large scans, SOS = point lookups. Both Enterprise+.
- Know Stored Procedures vs UDFs: Procedures DO (DDL/DML), Functions RETURN (in SELECT)

**During the exam — Domain 4 questions:**
- Read the LAST sentence first — then read the scenario
- Eliminate 2 obviously wrong answers immediately
- If they describe a SLOW query → check: is it spilling (scale UP) or queuing (scale OUT)?
- If they mention CACHE → ask: which one? Result (24hr, free), Warehouse (SSD, lost on suspend), Metadata (always on)
- If they ask about OPTIMIZATION SERVICE → large scan = QAS, specific lookup = SOS
- If they show JSON/VARIANT → think dot notation, ::cast, LATERAL FLATTEN
- If they ask "can this run DDL?" → only Stored Procedures, never UDFs

**Exam trap**: "Query History 365 days from INFORMATION_SCHEMA?" → WRONG. INFORMATION_SCHEMA = 7 days (real-time). ACCOUNT_USAGE = 365 days (up to 3hr latency). Don't swap them.
**Exam trap**: "Materialized views can reference multiple tables?" → WRONG. MVs are single-table only. If the question describes a multi-table join, MV is not the answer.

---

## ONE-LINE PER TOPIC — Domain 4

| Topic | One-line summary |
|---|---|
| Result Cache | 24hr (31 day max), shared across users (same role+SQL+data), Cloud Services, FREE. |
| Warehouse Cache | SSD on warehouse nodes, LOST on suspend, per-warehouse, not shared. |
| Metadata Cache | Always on, COUNT(*)/MIN/MAX full table, Cloud Services, no warehouse needed. |
| Query Profile | Visual execution plan in Snowsight: operators, spilling, pruning, join issues. |
| Local Disk Spilling | Query needs more memory → spills to local SSD → scale UP warehouse. |
| Remote Disk Spilling | Even worse than local → spills to remote storage → scale UP significantly. |
| Queuing | Too many concurrent queries → waiting in line → scale OUT (multi-cluster). |
| Pruning | Snowflake skips irrelevant micro-partitions. Functions on WHERE columns prevent it. |
| QAS | Query Acceleration Service: offloads large scans to serverless compute. Enterprise+. |
| SOS | Search Optimization Service: persistent access paths for point lookups. Enterprise+. |
| Clustering Keys | ALTER TABLE CLUSTER BY (cols). Auto-maintained. Better pruning. ALL editions. |
| Materialized Views | Pre-computed results, auto-refreshed, single table only. Enterprise+. |
| Workload isolation | Separate warehouses per workload type (ETL, BI, ad-hoc, data science). |
| Auto-suspend | Save credits when idle. Short timeout (1-5 min) for interactive workloads. |
| STATEMENT_TIMEOUT | Kill long-running queries. Set at warehouse/session/account level. |
| Semi-structured data | VARIANT/OBJECT/ARRAY columns. Dot notation, ::cast, FLATTEN. |
| LATERAL FLATTEN | Expand nested arrays/objects into rows. Join back to source. |
| Window functions | ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, SUM OVER. Keep all rows. |
| GROUPING SETS/ROLLUP/CUBE | Subtotals: SETS = custom combos, ROLLUP = hierarchy, CUBE = all combos. |
| CTEs | WITH clause for readable subqueries. Can reference earlier CTEs. |
| Stored Procedures | Procedural logic + DDL/DML. CALL to execute. SQL/JS/Python/Java/Scala. |
| UDFs | Return values in SQL expressions (SELECT/WHERE). Cannot run DDL/DML. |
| UDTFs | Table functions (RETURNS TABLE). Return multiple rows. Used with TABLE(). |
| External Functions | Call external APIs (Lambda, Azure Functions). Require API Integration. |
| Scaling policies | Standard = add cluster immediately. Economy = wait 6 min, save credits. |

**Exam trap**: "Search Optimization works on any edition?" → WRONG. SOS requires Enterprise+ edition. Same for QAS and Materialized Views.
**Exam trap**: "UDTFs are called with CALL?" → WRONG. UDTFs are used with TABLE() in the FROM clause. CALL is for stored procedures only.

---

## FLASHCARDS — Domain 4

**Q:** What is the cache check order?
**A:** 1) Result cache (free, 24h, Cloud Services) → 2) Local disk cache (warehouse SSD) → 3) Remote disk cache (Storage layer).

**Q:** When does the result cache get invalidated?
**A:** When underlying data changes, when the query uses non-deterministic functions (CURRENT_TIMESTAMP, RANDOM), or after 24 hours.

**Q:** Does the result cache require a running warehouse?
**A:** No. Result cache is served by Cloud Services — no warehouse credits consumed.

**Q:** What is spilling?
**A:** When a query needs more memory than the warehouse has, it spills to local disk (SSD), then to remote storage. Fix: scale UP (bigger warehouse).

**Q:** What is queuing?
**A:** When all clusters in a warehouse are busy, new queries wait in a queue. Fix: scale OUT (add more clusters via multi-cluster warehouse).

**Q:** Economy vs Standard scaling policy?
**A:** Standard: spin up new clusters immediately when queries queue. Economy: wait ~6 minutes before adding clusters — saves credits but higher latency.

**Q:** What is the Query Profile?
**A:** Visual execution plan in Snowsight. Shows operators, data flow, pruning stats, spilling, and bottlenecks. Use it to diagnose slow queries.

**Q:** What does "TableScan" show in Query Profile?
**A:** Partitions scanned vs total partitions. If scanned is close to total, pruning is poor — consider a clustering key.

**Q:** What is Search Optimization Service?
**A:** Background service that builds search access paths for point lookups (equality, IN, LIKE). Enterprise+. Best for selective queries on large tables.

**Q:** What are Materialized Views?
**A:** Pre-computed query results stored physically. Auto-refreshed by Snowflake. Enterprise+ only. Good for repeated expensive aggregations.

**Q:** What is Query Acceleration Service (QAS)?
**A:** Offloads parts of eligible queries (large scans) to shared compute. Enterprise+. Good for ad-hoc/unpredictable workloads with outlier queries.

**Q:** What is Automatic Clustering?
**A:** Background service that reorganizes micro-partitions based on clustering key. ALL editions. Runs when data changes, billed as serverless compute.

**Q:** What does FLATTEN do?
**A:** Converts VARIANT/ARRAY/OBJECT into rows (one row per element). Usually used with LATERAL: `SELECT * FROM table, LATERAL FLATTEN(input => col)`.

**Q:** What is the QUALIFY clause?
**A:** Filters window function results — like WHERE but for window functions. Example: `QUALIFY ROW_NUMBER() OVER (...) = 1`.

**Q:** Stored Procedure vs UDF — key differences?
**A:** Procedure: called with CALL, can perform DDL/DML, doesn't return in SELECT. UDF: returns a value, used in SELECT, cannot do DDL. Both support SQL/Python/Java/Scala/JavaScript.

**Q:** What is caller's rights vs owner's rights?
**A:** Caller's rights: procedure runs with the permissions of whoever calls it. Owner's rights: runs with permissions of the procedure owner. Default is owner's rights.

**Q:** What does PIVOT do?
**A:** Rotates rows into columns. Turns unique values in one column into separate columns. Opposite of UNPIVOT.

**Q:** What window functions are commonly tested?
**A:** ROW_NUMBER (unique rank), RANK (gaps on ties), DENSE_RANK (no gaps), LAG/LEAD (previous/next row), SUM/AVG OVER (running aggregates).

**Exam trap**: "Non-deterministic functions (CURRENT_TIMESTAMP, RANDOM) use result cache?" → WRONG. Non-deterministic functions INVALIDATE the result cache. The query re-executes every time.
**Exam trap**: "Automatic Clustering is free?" → WRONG. It's a serverless background service that costs credits. Only defining the clustering key (ALTER TABLE CLUSTER BY) is free.
**Exam trap**: "PIVOT requires an aggregate function?" → Correct. PIVOT syntax needs an aggregate (SUM, COUNT, etc.). WRONG: "PIVOT just rearranges rows without aggregation."

---

## EXPLAIN LIKE I'M 5 — Domain 4

**Result cache**: When you ask the same question twice, Snowflake remembers the answer for 24 hours and gives it back instantly for free.

**Local disk cache**: The warehouse keeps recently used data on its fast SSD drive — like keeping a book on your desk instead of walking to the library.

**Spilling**: Your warehouse ran out of desk space and had to put papers on the floor (local disk), then in the hallway (remote storage). Get a bigger desk = scale UP.

**Queuing**: There's a line of people waiting to use the warehouse. Get more warehouses = scale OUT.

**Query Profile**: An X-ray of your query showing exactly what happened — where it spent time, what data it read, and where it got stuck.

**Pruning**: Snowflake skipping data it doesn't need. Good pruning = fast query. Check by looking at "partitions scanned" in Query Profile.

**Clustering key**: Organizing your bookshelf by topic so you can find books faster. Only worth it for huge bookshelves (multi-TB tables).

**Search Optimization**: A special index that helps find specific needles in a huge haystack. For lookups like "find the row where ID = 12345."

**Materialized view**: A cheat sheet that Snowflake pre-calculates and keeps updated. Faster to read, but costs money to maintain.

**Query Acceleration**: When one query is doing way more work than others, Snowflake borrows extra computers to help just that query finish faster.

**FLATTEN**: Opening a box that contains a list and spreading each item into its own row on the table.

**QUALIFY**: A filter for window functions. Like saying "give me only the first result" after numbering all the rows.

**Window function**: Doing math across rows without collapsing them. Like calculating a running total where each row shows the sum so far.

**Stored procedure**: A recipe with step-by-step instructions that you can run anytime by saying its name. Can do anything.

**UDF**: A mini calculator — you give it input, it gives you one output. Used inside queries.

**PIVOT**: Turning tall data into wide data — like converting a list of months into separate columns for each month.

**Economy scaling**: Being patient and cheap — waiting a bit before hiring extra workers. Standard scaling: hiring extra workers immediately when there's a line.

**Exam trap**: "Window functions collapse rows like GROUP BY?" → WRONG. Window functions KEEP all rows. GROUP BY collapses them. That's the key difference.
**Exam trap**: "Spilling means the query is queuing?" → WRONG. Spilling = not enough MEMORY (scale UP). Queuing = not enough CONCURRENCY (scale OUT). Completely different problems.
