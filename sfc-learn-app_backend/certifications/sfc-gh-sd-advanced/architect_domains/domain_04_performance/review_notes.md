# Domain 4: Performance — Tools, Best Practices & Troubleshooting

> **ARA-C01 Weight:** ~20-25% of the exam. This is a HIGH-PRIORITY domain.
> Focus on: Query Profile interpretation, warehouse sizing, caching layers, clustering, and performance services.

---

## 4.1 QUERY PROFILE

The Query Profile is your **single most important diagnostic tool** in Snowflake.

### Key Concepts

- Access via: **History tab → query → Query Profile** (or `GET_QUERY_OPERATOR_STATS()`)
- Shows a **DAG (directed acyclic graph)** of operators — data flows bottom to top
- Each operator node shows: **% of total time**, rows processed, bytes scanned

**Critical operators to know:**

| Operator | What It Does | Red Flag |
|----------|-------------|----------|
| TableScan | Reads micro-partitions | High partitions scanned vs. total = bad pruning |
| Filter | Applies WHERE clauses | Should appear AFTER pruning, not instead of it |
| Aggregate | GROUP BY / DISTINCT | High memory = possible spilling |
| SortWithLimit | ORDER BY + LIMIT | Expensive on large datasets |
| JoinFilter | Hash join / merge join | Exploding rows = bad join condition |
| ExternalScan | External tables / stages | Always slower than native tables |
| WindowFunction | OVER() clauses | Memory-intensive, watch for spilling |
| Flatten | VARIANT/array expansion | Row explosion risk |

**Spilling indicators:**

- **Bytes spilled to local storage** — warehouse SSD used (moderate issue)
- **Bytes spilled to remote storage** — S3/Azure Blob/GCS used (SEVERE issue)
- Fix: use a **larger warehouse** (more memory/SSD) or optimize the query

**Pruning statistics (on TableScan):**

- **Partitions scanned** vs. **Partitions total** — goal is scanned << total
- If scanned ≈ total → clustering key is missing or filter doesn't match clustering

### Why This Matters

You have a report query taking 45 minutes. Query Profile shows a JoinFilter with 50B rows output from two 10M-row tables. The join condition is missing a key column — cartesian join. Without Query Profile, you'd just upsize the warehouse and waste credits.

### Best Practices

- Check **"Most Expensive Nodes"** panel first — the top 1-2 nodes are usually the bottleneck
- Look at **Statistics → Spilling** before upsizing warehouses
- Use `SYSTEM$EXPLAIN_PLAN()` for quick checks without running the query
- Compare pruning stats before/after adding clustering keys

**Exam traps:**

- Exam trap: IF YOU SEE "Query is slow, increase warehouse size" → WRONG because you should diagnose with Query Profile first; the problem might be a bad join or missing filter, not insufficient compute
- Exam trap: IF YOU SEE "Spilling to local disk is a critical issue" → WRONG because local spilling is a moderate concern; spilling to **remote storage** is the severe one
- Exam trap: IF YOU SEE "Query Profile shows execution plan before running" → WRONG because Query Profile shows **actual execution** stats; use `EXPLAIN_PLAN` for pre-execution plans

### Common Questions (FAQ)

**Q: Can I see Query Profile for queries run by other users?**
A: Yes, if you have ACCOUNTADMIN or MONITOR privilege on the warehouse. Otherwise, you only see your own queries.

**Q: How long are Query Profiles retained?**
A: 14 days in the web UI. Use ACCOUNT_USAGE.QUERY_HISTORY for up to 365 days (but without the visual DAG).

---

## 4.2 WAREHOUSES

Warehouses are your **compute engines**. Sizing them correctly is the #1 cost lever.

### Key Concepts

**Warehouse sizes (T-shirt sizing):**

| Size | Nodes | Credits/hr | Use Case |
|------|-------|-----------|----------|
| X-Small | 1 | 1 | Dev, simple queries |
| Small | 2 | 2 | Light analytics |
| Medium | 4 | 4 | Moderate workloads |
| Large | 8 | 8 | Complex joins, transforms |
| X-Large | 16 | 16 | Heavy ETL |
| 2XL–6XL | 32–128 | 32–128 | Massive workloads |

**Doubling rule:** Each size up = **2x nodes, 2x credits, 2x memory/SSD**. Does NOT guarantee 2x speed.

**Snowpark-Optimized Warehouses:**

- 16x more memory per node than standard
- Purpose: ML training, large UDFs, Snowpark DataFrames, Java/Python UDTFs
- Cost: ~1.5x more credits per hour than standard same-size

**Multi-cluster warehouses (Enterprise+):**

- **Min clusters** and **Max clusters** settings
- **Scaling policies:**
  - **Standard (default):** Spins up new cluster when a query is queued. Conservative scale-down.
  - **Economy:** Waits until enough load to keep new cluster busy for 6 minutes. Saves credits but increases queuing.

**Auto-suspend / Auto-resume:**

- Auto-suspend: set in **seconds** (minimum 60s, or 0 for immediate)
- Auto-resume: `TRUE` by default — warehouse starts when a query hits it
- Suspended warehouses consume **zero credits**
- Each resume incurs provisioning time (~1-2 seconds typically)

### Why This Matters

Your data engineering team runs ETL at 2 AM on a 2XL warehouse that auto-suspends after 10 minutes. But 50 small queries trickle in every few minutes during the day, each resuming the warehouse. You're paying 2XL credits for X-Small workloads. Solution: separate warehouses by workload type.

### Best Practices

- **Separate warehouses by workload** (ETL vs. BI vs. data science)
- Start small, scale up only after checking Query Profile
- Auto-suspend: **60 seconds** for ETL, **300-600 seconds** for BI (avoids constant resume)
- Use **Economy** scaling policy for cost-sensitive, latency-tolerant workloads
- Use **Standard** scaling policy for user-facing, latency-sensitive workloads

**Exam traps:**

- Exam trap: IF YOU SEE "Larger warehouse always means faster queries" → WRONG because query speed depends on the bottleneck; a bad query plan won't improve with more compute
- Exam trap: IF YOU SEE "Multi-cluster warehouses run a single query across multiple clusters" → WRONG because each cluster runs separate queries; multi-cluster is for **concurrency**, not single-query parallelism
- Exam trap: IF YOU SEE "Snowpark-optimized warehouses are always better" → WRONG because they cost more and only help memory-intensive workloads (ML, large UDFs); standard is fine for SQL
- Exam trap: IF YOU SEE "Auto-suspend 0 means never suspend" → WRONG because `AUTO_SUSPEND = 0` means suspend immediately when idle; `NULL` disables auto-suspend

### Common Questions (FAQ)

**Q: Does warehouse size affect compilation time?**
A: No. Compilation happens in the cloud services layer, not the warehouse.

**Q: Can I resize a warehouse while queries are running?**
A: Yes. Running queries use the old size; new queries use the new size.

---

## 4.3 CACHING

Snowflake has **three caching layers**. Understanding them is critical for exam and real life.

### Key Concepts

**1. Result Cache (Cloud Services Layer)**

- Stores **exact query results** for 24 hours
- Reused when: same query text + same data (no underlying changes) + same role
- **Free** — no warehouse needed
- Persists even if warehouse is suspended
- Invalidated when underlying data changes (DML) or 24 hours pass
- Can be disabled: `ALTER SESSION SET USE_CACHED_RESULT = FALSE;`

**2. Metadata Cache (Cloud Services Layer)**

- Stores min/max/count/null_count per micro-partition per column
- Powers: `SELECT COUNT(*)`, `MIN()`, `MAX()` on full tables — **instant, no warehouse**
- Always active, cannot be disabled

**3. Local Disk Cache (Warehouse SSD)**

- Caches **raw micro-partition data** on warehouse SSD
- Lost when warehouse suspends (SSD cleared)
- Shared across queries on the same warehouse
- Helps repeat scans of the same data within a session
- Reason why longer auto-suspend can sometimes save money (avoid re-fetching data)

### Why This Matters

A dashboard refreshes every 5 minutes with the same 10 queries. If underlying data hasn't changed, all 10 hit the result cache — zero warehouse credits. But if someone inserts one row, all 10 caches invalidate and the warehouse spins up. Understanding this shapes your ELT scheduling.

### Best Practices

- Schedule data loads at predictable intervals so result cache stays valid between loads
- Don't disable result cache unless debugging
- Balance auto-suspend timeout: too short = lose SSD cache; too long = waste credits
- Use dedicated warehouses per workload to maximize SSD cache hits
- Metadata cache means `SELECT COUNT(*) FROM big_table` is always instant — no need to cache this yourself

**Exam traps:**

- Exam trap: IF YOU SEE "Result cache works across different roles" → WRONG because result cache is **role-specific**; same query with different roles = cache miss
- Exam trap: IF YOU SEE "Suspending a warehouse clears the result cache" → WRONG because result cache lives in **cloud services layer**, not the warehouse; SSD/local disk cache is what gets cleared
- Exam trap: IF YOU SEE "Result cache lasts 24 hours no matter what" → WRONG because any DML on the underlying tables **invalidates** the cache immediately

### Common Questions (FAQ)

**Q: Does result cache count toward cloud services billing?**
A: No. Result cache retrieval is free. Cloud services billing only kicks in if cloud services exceed 10% of total compute.

**Q: If two users run the same query with the same role, does user B benefit from user A's result cache?**
A: Yes — result cache is shared across users if the query text, role, and data are identical.

---

## 4.4 CLUSTERING & PRUNING

Micro-partition pruning is how Snowflake avoids full table scans. Clustering controls how data is organized.

### Key Concepts

**Micro-partitions:**

- Snowflake stores data in 50-100 MB compressed micro-partitions (immutable, columnar)
- Each partition has **metadata**: min/max values per column
- Queries use this metadata to **skip** irrelevant partitions = pruning

**Natural clustering:**

- Data is clustered by **ingestion order** by default
- Works great if you always filter by a timestamp column and load data chronologically
- Degrades with random inserts, updates, or merges over time

**Clustering keys:**

- Defined with `ALTER TABLE ... CLUSTER BY (col1, col2)`
- Best for: large tables (multi-TB), frequently filtered columns, low-to-medium cardinality
- Snowflake's **Automatic Clustering** service re-organizes data in the background (serverless, costs credits)
- Check clustering quality: `SYSTEM$CLUSTERING_INFORMATION('table', '(col)')`
  - `average_depth` — lower is better (1.0 = perfect)
  - `average_overlap` — lower is better (0.0 = no overlap)

**Key selection guidelines:**

- Pick columns used in WHERE, JOIN, ORDER BY
- 3-4 columns max in a clustering key
- Put **low-cardinality columns first** (e.g., `region` before `order_id`)
- Expressions allowed: `CLUSTER BY (TO_DATE(created_at), region)`

### Why This Matters

A 500 TB fact table with `WHERE event_date = '2025-01-15'` scans 500 TB without clustering. With `CLUSTER BY (event_date)`, it scans maybe 100 MB. That's the difference between a 30-minute query and a 2-second query.

### Best Practices

- Only cluster tables > 1 TB (or with poor pruning visible in Query Profile)
- Monitor auto-clustering credits in ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
- Don't cluster by high-cardinality columns alone (e.g., UUID) — ineffective
- Combine with time-based columns for event/log tables: `CLUSTER BY (TO_DATE(ts), category)`
- Re-evaluate clustering keys quarterly as query patterns evolve

**Exam traps:**

- Exam trap: IF YOU SEE "Clustering keys sort the data like a traditional index" → WRONG because Snowflake doesn't have indexes; clustering keys guide **micro-partition organization** for better pruning
- Exam trap: IF YOU SEE "You should cluster every table" → WRONG because small tables don't benefit; clustering has ongoing maintenance cost (auto-clustering credits)
- Exam trap: IF YOU SEE "Clustering keys are free to maintain" → WRONG because Automatic Clustering is a **serverless feature that consumes credits**
- Exam trap: IF YOU SEE "High-cardinality column is the best clustering key" → WRONG because low-to-medium cardinality provides better partition pruning; high cardinality means too many distinct values per partition

### Common Questions (FAQ)

**Q: Can I have multiple clustering keys on one table?**
A: No. One clustering key per table, but it can be a **compound key** with multiple columns.

**Q: Does clustering affect DML performance?**
A: Not directly. But Automatic Clustering runs in the background and consumes serverless credits when data changes.

---

## 4.5 PERFORMANCE SERVICES

Three serverless services that accelerate specific query patterns.

### Key Concepts

**1. Query Acceleration Service (QAS)**

- Offloads **portions** of a query to shared serverless compute
- Best for: queries with large scans + selective filters (ad-hoc analytics)
- Enabled per warehouse: `ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE;`
- `QUERY_ACCELERATION_MAX_SCALE_FACTOR` — limits serverless compute (0 = unlimited, default 8)
- Check eligibility: `SYSTEM$ESTIMATE_QUERY_ACCELERATION('query_id')`
- **Not helpful for:** queries limited by single-threaded operations, small scans, or CPU bottlenecks

**2. Search Optimization Service (SOS)**

- Builds a **persistent, server-maintained** search access path
- Best for: **selective point lookups** on large tables (WHERE id = X, CONTAINS, GEO)
- Supports: equality predicates, IN, SUBSTRING, GEOGRAPHY/GEOMETRY functions, VARIANT fields
- Enabled per table or per column: `ALTER TABLE t ADD SEARCH OPTIMIZATION ON EQUALITY(col)`
- Costs: serverless credits for building + storage for search structures
- **Not helpful for:** range scans, full table analytics, small tables

**3. Materialized Views (MVs)**

- Pre-computed, automatically maintained query results stored as micro-partitions
- Best for: repeated subqueries, pre-aggregations, commonly joined subsets
- Snowflake **auto-refreshes** MVs when base table changes (serverless credits)
- Query optimizer can **auto-rewrite** queries to use MVs even if not referenced directly
- Limitations: single base table only, no joins, no UDFs, no HAVING, limited window functions
- Enterprise Edition required

### Why This Matters

An analytics platform has 200 users running ad-hoc queries on a 100 TB table. Some queries scan 80 TB, some scan 100 MB. QAS helps the large-scan queries share serverless compute. SOS helps the point-lookup queries skip straight to the right partitions. MVs pre-compute the top-10 dashboard aggregations.

### Best Practices

- QAS: enable on warehouses serving **unpredictable, ad-hoc** query patterns
- SOS: use for **known high-selectivity** lookup patterns (ID lookups, search filters)
- MVs: use for **stable, repeated** aggregations or filtered views
- Monitor all three in ACCOUNT_USAGE: QAS history, SOS history, MV refresh history
- Don't enable all three blindly — each has ongoing serverless costs

**Exam traps:**

- Exam trap: IF YOU SEE "QAS replaces the warehouse entirely" → WRONG because QAS **supplements** the warehouse; the warehouse still runs the query, QAS offloads scan-intensive portions
- Exam trap: IF YOU SEE "Search Optimization is like a traditional B-tree index" → WRONG because it's a **search access path** maintained serverlessly; it's not a user-managed index
- Exam trap: IF YOU SEE "Materialized views can join multiple tables" → WRONG because MVs in Snowflake support **single base table only** — no joins
- Exam trap: IF YOU SEE "Materialized views must be referenced in the query to be used" → WRONG because the optimizer can **auto-rewrite** queries to use MVs transparently

### Common Questions (FAQ)

**Q: Can QAS and Search Optimization be used together?**
A: Yes. They solve different problems — QAS for large scans, SOS for point lookups.

**Q: Do materialized views consume storage?**
A: Yes. They are stored as micro-partitions and contribute to your storage bill.

---

## 4.6 TROUBLESHOOTING

Know where to look and what tools to use.

### Key Concepts

**INFORMATION_SCHEMA vs. ACCOUNT_USAGE:**

| Feature | INFORMATION_SCHEMA | ACCOUNT_USAGE |
|---------|-------------------|---------------|
| Latency | Real-time | 15 min – 3 hr lag |
| Retention | 7 days–6 months (varies) | **365 days** |
| Scope | Current database | Entire account |
| Dropped objects | Not included | **Included** |
| Access | Any role with DB access | ACCOUNTADMIN (or granted) |

**Key ACCOUNT_USAGE views for performance:**

- `QUERY_HISTORY` — all queries, execution time, bytes scanned, warehouse, errors
- `WAREHOUSE_METERING_HISTORY` — credit consumption per warehouse
- `AUTOMATIC_CLUSTERING_HISTORY` — auto-clustering credit usage
- `SEARCH_OPTIMIZATION_HISTORY` — SOS credit usage
- `MATERIALIZED_VIEW_REFRESH_HISTORY` — MV refresh credit usage
- `QUERY_ACCELERATION_HISTORY` — QAS credit usage
- `STORAGE_USAGE` — storage trends over time
- `LOGIN_HISTORY` — auth issues

**Resource Monitors:**

- Track **credit consumption** at account or warehouse level
- Actions at thresholds: **Notify, Notify & Suspend, Notify & Suspend Immediately**
- Set with: `CREATE RESOURCE MONITOR` + assign to warehouse or account
- Only ACCOUNTADMIN can create account-level monitors
- Can set **start time, frequency (daily/weekly/monthly), credit quota**

**Alerts & Event Tables:**

- **Alerts** (`CREATE ALERT`): scheduled SQL condition checks → trigger action (email, task, etc.)
- **Event Table**: centralized store for **logs, traces, metrics** from UDFs, procedures, Streamlit
- One event table per account: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`
- Query event data with standard SQL: `SELECT * FROM db.schema.events WHERE ...`

**Logging & Tracing:**

- Set log level: `ALTER SESSION SET LOG_LEVEL = 'INFO';` (OFF, TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
- Set trace level: `ALTER SESSION SET TRACE_LEVEL = 'ON_EVENT';` (OFF, ALWAYS, ON_EVENT)
- Logs go to the **event table** — queryable via SQL
- Available in UDFs (Python, Java, Scala, JavaScript), stored procedures, Streamlit apps

### Why This Matters

Production dashboard is slow. You check ACCOUNT_USAGE.QUERY_HISTORY and find 500 queries queued on a single warehouse. Resource monitors show you're burning 2x expected credits. Alerts you set up caught the spike and emailed the team. Without these tools, you wouldn't know until users complained.

### Best Practices

- Use ACCOUNT_USAGE for historical analysis (365-day retention)
- Use INFORMATION_SCHEMA for real-time debugging (current session/database)
- Set resource monitors on **every production warehouse** — non-negotiable
- Create alerts for: long-running queries, spilling, warehouse queue depth, login failures
- Enable logging (INFO level minimum) for all production UDFs and procedures
- Review WAREHOUSE_METERING_HISTORY weekly to catch cost anomalies early

**Exam traps:**

- Exam trap: IF YOU SEE "INFORMATION_SCHEMA has 365-day retention" → WRONG because that's **ACCOUNT_USAGE**; INFORMATION_SCHEMA varies (7 days to 6 months by view)
- Exam trap: IF YOU SEE "Resource monitors can limit storage costs" → WRONG because resource monitors only track **compute credits**, not storage
- Exam trap: IF YOU SEE "ACCOUNT_USAGE data is real-time" → WRONG because ACCOUNT_USAGE has **15 minutes to 3 hours latency**
- Exam trap: IF YOU SEE "Any role can create account-level resource monitors" → WRONG because only **ACCOUNTADMIN** can create account-level resource monitors

### Common Questions (FAQ)

**Q: Can I grant ACCOUNT_USAGE access to non-ACCOUNTADMIN roles?**
A: Yes. Grant the `IMPORTED PRIVILEGES` on the SNOWFLAKE database to any role.

**Q: Do resource monitors prevent queries from starting?**
A: With "Suspend Immediately", yes — running queries are killed and new ones blocked. With "Suspend", running queries finish but no new ones start.

**Q: What's the difference between an Alert and a Task?**
A: A Task runs on a schedule unconditionally. An Alert runs on a schedule but **only triggers its action if a SQL condition is true**.

---

## FLASHCARDS — Domain 4

**Q1: What are the three caching layers in Snowflake?**
A1: Result cache (cloud services, 24h, free), Metadata cache (cloud services, always on), Local disk cache (warehouse SSD, lost on suspend).

**Q2: A query spills to remote storage. What's the fix?**
A2: Use a **larger warehouse** (more memory/SSD). Also check if the query can be optimized to reduce data volume.

**Q3: What scaling policy should you use for a user-facing BI warehouse?**
A3: **Standard** — scales up quickly when queries queue. Economy is for cost-sensitive, latency-tolerant workloads.

**Q4: How do you check if a table would benefit from clustering?**
A4: `SYSTEM$CLUSTERING_INFORMATION('table', '(columns)')` — check `average_depth` and `average_overlap`. High values = poor clustering.

**Q5: What is the maximum retention period for ACCOUNT_USAGE views?**
A5: **365 days**.

**Q6: Can materialized views join multiple base tables?**
A6: **No.** Snowflake MVs support a single base table only.

**Q7: What does Query Acceleration Service (QAS) do?**
A7: Offloads scan-intensive portions of eligible queries to serverless compute, supplementing the warehouse.

**Q8: Result cache is invalidated when ____?**
A8: Underlying data changes (DML), 24 hours pass, or the user changes roles.

**Q9: What's the minimum auto-suspend setting?**
A9: **60 seconds** (or 0 for immediate suspend).

**Q10: Snowpark-optimized warehouses have ___x more memory.**
A10: **16x** more memory per node compared to standard warehouses.

**Q11: INFORMATION_SCHEMA shows data for which scope?**
A11: The **current database** only. For account-wide data, use ACCOUNT_USAGE.

**Q12: How does Search Optimization Service work?**
A12: Builds a persistent search access path (serverless-maintained) for selective point lookups, equality predicates, and geo functions.

**Q13: Resource monitors track what?**
A13: **Compute credits** only. They do NOT track storage costs.

**Q14: Where do UDF/procedure logs go?**
A14: The **event table** — a single account-level table set via `ALTER ACCOUNT SET EVENT_TABLE`.

**Q15: What columns should go first in a clustering key?**
A15: **Low-cardinality columns first** (e.g., region, status) for maximum pruning efficiency.

---

## EXPLAIN LIKE I'M 5 — Domain 4

**ELI5 #1: Query Profile**
Imagine you're building a LEGO castle and someone takes a photo at each step. Query Profile is those photos — it shows you exactly which step took the longest and where things got stuck.

**ELI5 #2: Warehouse Sizing**
A warehouse is like hiring workers. X-Small = 1 worker, Small = 2, Medium = 4. More workers cost more money. But if the job needs a special tool (better SQL), hiring more workers won't help.

**ELI5 #3: Result Cache**
You ask your mom "What's for dinner?" She says "Pasta." You ask again 5 minutes later — she remembers and says "Pasta" instantly without checking the kitchen. That's result cache. But if she starts cooking something else, the answer changes.

**ELI5 #4: Micro-partition Pruning**
You have 1,000 labeled toy boxes. Each label says what's inside (e.g., "cars from 2020"). When you want "cars from 2020", you only open the boxes labeled "2020" instead of all 1,000.

**ELI5 #5: Clustering Keys**
You organize your bookshelf by color first, then by size. Now when someone asks for "all blue books," you go straight to the blue section instead of checking every shelf.

**ELI5 #6: Spilling**
Your desk is too small for your puzzle. You spill pieces onto the floor (local disk) — slower but okay. If the floor fills up, you move pieces to the garage (remote storage) — much slower. Bigger desk = bigger warehouse.

**ELI5 #7: Multi-cluster Warehouses**
One ice cream shop with long lines. Multi-cluster = opening more shops when the line gets too long. Standard policy: open a new shop as soon as someone waits. Economy policy: only open if the line is really, really long.

**ELI5 #8: Search Optimization**
Your teacher made an index at the back of the textbook. Instead of reading every page to find "dinosaurs," you look at the index, get "page 42," and go straight there.

**ELI5 #9: Resource Monitors**
Your parents give you $20 for arcade games. A resource monitor is like a tracker: at $15 it warns you, at $20 it takes the money away so you can't overspend.

**ELI5 #10: Materialized Views**
Every morning your teacher writes "Today's Lunch Menu" on the board. Instead of everyone walking to the cafeteria to check, they just look at the board. When the menu changes, the teacher updates the board automatically.
