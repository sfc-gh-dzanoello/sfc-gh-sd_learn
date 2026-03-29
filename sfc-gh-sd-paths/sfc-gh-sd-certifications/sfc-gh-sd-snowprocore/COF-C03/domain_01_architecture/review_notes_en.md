# DOMAIN 1: SNOWFLAKE AI DATA CLOUD FEATURES & ARCHITECTURE
## 31% of exam = ~31 questions. This is the BIGGEST domain.

---

## 1.1 THE THREE LAYERS

Snowflake = hybrid of shared-disk + shared-nothing.
Three independent layers that scale independently:

```
┌─────────────────────────────────┐
│      CLOUD SERVICES LAYER       │  ← "The Brain"
│  Auth, Security, Metadata,      │
│  Query Optimizer, Transactions  │
│  Runs 24/7. Billed only if >10%│
│  of daily warehouse credits     │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│        COMPUTE LAYER            │  ← "The Muscle"
│  Virtual Warehouses (VW)        │
│  Independent clusters, no       │
│  sharing between warehouses     │
│  Billed per-second (60s min)    │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│    DATABASE STORAGE LAYER       │  ← "The Memory"
│  Centralized cloud storage      │
│  Columnar micro-partitions      │
│  Compressed, encrypted, immutable│
│  Billed per TB/month            │
└─────────────────────────────────┘
```

### Cloud Services Layer handles:
- Authentication + access control (RBAC + DAC)
- Query parsing + optimization
- Metadata management
- Transaction management (ACID compliance)
- Infrastructure management
- Security + encryption

**Exam trap**: "Which layer handles query optimization?" → Cloud Services. IF YOU SEE "Compute layer optimizes" → WRONG, Compute only executes queries.
**Exam trap**: "Which layer handles ACID/transactions?" → Cloud Services. IF YOU SEE "Storage layer" or "Compute layer" with "transactions" → WRONG, only Cloud Services manages transactions.
**Exam trap**: "Which layer ensures User A cannot see uncommitted changes from User B?" → Cloud Services (Transaction Management). IF YOU SEE "isolation" + "Compute" → WRONG, transaction isolation = Cloud Services.

### Cloud Services billing:
- Only charged if Cloud Services usage > 10% of total daily warehouse credit usage
- Most accounts never hit this threshold

Exam trap: "Cloud Services is always billed separately" → WRONG. IF YOU SEE "always" + "billed" with Cloud Services → WRONG, only billed if exceeding 10% of daily warehouse credits.
Exam trap: "The 10% threshold is monthly" → WRONG. IF YOU SEE "monthly" with the 10% threshold → WRONG, it's calculated DAILY, not monthly.

### Compute Layer:
- Virtual warehouses = independent MPP clusters
- One warehouse does NOT affect another
- Loading + querying can happen simultaneously on same table (different warehouses)
- Warehouse cache lives here (lost when warehouse suspends)

Exam trap: "Warehouse cache persists after suspend" → WRONG. IF YOU SEE "persists" or "retained" with "suspend" → WRONG, SSD cache is LOST on suspend. Only result cache (Cloud Services) survives.
Exam trap: "Two warehouses share compute resources" → WRONG. IF YOU SEE "share" or "shared resources" between warehouses → WRONG, each warehouse is fully independent.

### Storage Layer:
- Data stored in cloud provider's blob storage (S3, Azure Blob, GCS)
- Columnar format, compressed, encrypted
- Customer cannot directly access the underlying files
- Billed monthly per TB (compressed)

Exam trap: "Customers can directly access underlying storage files" → WRONG. IF YOU SEE "direct access" or "browse S3 objects" → WRONG, Snowflake manages all files — no direct access.
Exam trap: "Storage is billed per TB uncompressed" → WRONG. IF YOU SEE "uncompressed" with storage billing → WRONG, billed per TB COMPRESSED.

### Example Scenario Questions — Three Layers

**Scenario:** A data engineer notices that query compilation takes unusually long, but once running, queries complete quickly. Which layer is the bottleneck, and what might cause this?
**Answer:** Cloud Services layer — it handles query parsing, optimization, and compilation. Possible causes: very complex SQL with many joins/subqueries, or high metadata overhead. This is NOT a Compute issue since execution is fast.

**Scenario:** Two teams share the same Snowflake account. Team A runs heavy ETL jobs while Team B runs real-time dashboards. Team B complains about slow performance. The admin confirms they use separate warehouses. Is it possible that Team A's workload affects Team B?
**Answer:** No. Virtual warehouses are completely independent in the Compute layer. Each warehouse has its own dedicated resources. If Team B is slow, the issue is with their own warehouse size, not Team A's workload. Check if Team B's warehouse needs scaling up.

**Scenario:** An auditor asks: "Where does Snowflake physically store our data, and can we access the raw files for compliance?" What is the correct answer?
**Answer:** Data is stored in the cloud provider's blob storage (S3/Azure Blob/GCS) in the Storage layer, in compressed, encrypted, columnar micro-partitions. You CANNOT directly access the raw files — Snowflake manages all storage. For compliance, use ACCOUNT_USAGE views, Access History, and Time Travel instead.

**Scenario:** Your Cloud Services costs suddenly spike to 15% of your daily warehouse credits. What happened and what do you pay?
**Answer:** You only pay for the amount exceeding 10%. If Cloud Services = 15% and warehouse credits = 100, you pay for 5 credits of Cloud Services (15 - 10 = 5). Common causes: excessive SHOW/DESCRIBE commands, heavy metadata operations, or complex query compilation on many small queries.

---

## 1.2 SNOWFLAKE ACCOUNT BASICS

### One account = one cloud provider + one region
- An account CANNOT span multiple cloud providers
- To use AWS + Azure = need separate accounts
- Use Organizations to link accounts across providers/regions
- Replication can sync data between accounts

### Account Identifiers (two formats):
1. **Organization + Account name**: `myorg-myaccount` (preferred)
2. **Account locator**: legacy format, region-specific (e.g., `xy12345.us-east-1`)

Exam trap: "Account locator is the preferred format" → WRONG. IF YOU SEE "locator" as "preferred" or "recommended" → WRONG, `myorg-myaccount` is preferred. Locator is legacy.
Exam trap: "One account can span AWS and Azure" → WRONG. IF YOU SEE "span" or "multiple providers" in one account → WRONG, one account = one cloud provider + one region.
Exam trap: "Replication moves the account to another region" → WRONG. IF YOU SEE "moves" with replication → WRONG, replication syncs DATA between accounts. The account stays put.

### Example Scenario Questions — Account Basics

**Scenario:** A multinational company wants to use Snowflake on AWS in us-east-1 for their US team and Azure West Europe for their EU team. How many Snowflake accounts do they need?
**Answer:** At least 2 accounts — one per cloud provider/region combination. They should use Snowflake Organizations to manage both accounts and database replication to sync shared data between them.

**Scenario:** A developer shares their account identifier as `xy12345.us-east-1`. A colleague in another region tries to connect using that identifier but it doesn't resolve. Why?
**Answer:** Account locators are region-specific and legacy format. The preferred approach is using the organization-based format `myorg-myaccount` which works globally. The locator `xy12345.us-east-1` only works for that specific region.

**Scenario:** Management wants disaster recovery across AWS regions. Can they replicate their Snowflake account from us-east-1 to us-west-2?
**Answer:** Yes, but it requires a second Snowflake account in us-west-2. Database replication syncs data objects, while account replication (Business Critical+) syncs users, roles, warehouses, and policies. Both accounts are linked via Organizations.

---

## 1.3 EDITIONS (VERY HEAVILY TESTED)

### Standard Edition — ALL of these are included:
- Virtual warehouses (single-cluster only)
- 1-day Time Travel
- 7-day Fail-safe (permanent tables only)
- Automatic encryption (AES-256)
- Network policies, MFA, SSO, OAuth
- RBAC + DAC
- UDFs (Java, JavaScript, Python, SQL)
- Stored procedures (Java, JavaScript, Python, Scala, SQL)
- Snowpark
- Dynamic tables
- External tables
- Hybrid tables
- Clustering (automatic)
- Data sharing
- Resource monitors
- Standard SQL support
- Semi-structured data (JSON, Avro, ORC, Parquet, XML)
- Unstructured data support
- Data Quality / Data Metric Functions

### Enterprise Edition = Standard + these additions:
- Multi-cluster warehouses (scale OUT)
- Extended Time Travel (up to 90 days)
- Column-level security (masking policies)
- Row-level security (row access policies)
- Aggregation policies
- Projection policies
- Data classification
- Access History (ACCOUNT_USAGE view)
- Periodic rekeying of encrypted data
- Search Optimization Service
- Query Acceleration Service
- Materialized views
- Synthetic data generation

### Business Critical = Enterprise + these additions:
- Tri-Secret Secure (customer-managed keys)
- Private connectivity (AWS PrivateLink, Azure Private Link, GCP Private Service Connect)
- PHI/HIPAA/HITRUST compliance
- PCI DSS support
- FedRAMP/ITAR support
- Account failover/failback (disaster recovery)

### VPS (Virtual Private Snowflake) = Business Critical + :
- Completely isolated environment
- Dedicated metadata store
- Dedicated compute pool
- No shared resources with other Snowflake accounts

### EDITION CHEAT SHEET — What goes where:

| Feature | Edition |
|---|---|
| Clustering | ALL (automatic) |
| Dynamic tables | ALL |
| Snowpark | ALL |
| UDFs + Stored Procs | ALL |
| Network policies | ALL |
| MFA, SSO, OAuth | ALL |
| 1-day Time Travel | ALL |
| Fail-safe (7 days) | ALL (permanent tables) |
| Resource monitors | ALL |
| Data Quality / DMFs | ALL |
| Multi-cluster warehouses | Enterprise+ |
| Extended Time Travel (90 days) | Enterprise+ |
| Column-level security (masking) | Enterprise+ |
| Row access policies | Enterprise+ |
| Search Optimization | Enterprise+ |
| Query Acceleration | Enterprise+ |
| Materialized views | Enterprise+ |
| Data classification | Enterprise+ |
| Access History | Enterprise+ |
| Periodic rekeying | Enterprise+ |
| Tri-Secret Secure | Business Critical+ |
| Private connectivity (PrivateLink) | Business Critical+ |
| PHI/HIPAA support | Business Critical+ |
| Dedicated metadata store | VPS only |

Exam trap: "Masking policies are available in Standard" → WRONG. IF YOU SEE "Standard" + "masking" or "column-level security" → WRONG, masking requires Enterprise+.
Exam trap: "Multi-cluster warehouses work on Standard" → WRONG. IF YOU SEE "Standard" + "multi-cluster" → WRONG, multi-cluster requires Enterprise+. Standard = single-cluster only.
Exam trap: "Tri-Secret Secure is Enterprise" → WRONG. IF YOU SEE "Enterprise" with "Tri-Secret" → WRONG, Tri-Secret = Business Critical+. Don't confuse with periodic rekeying (Enterprise+).

### Example Scenario Questions — Editions

**Scenario:** A healthcare company needs to store PHI (Protected Health Information) in Snowflake and must comply with HIPAA. They're currently on Enterprise edition. Is this sufficient?
**Answer:** No. HIPAA/PHI compliance requires Business Critical edition or higher. Enterprise provides masking policies and row access policies for data protection, but the compliance certifications (HIPAA, HITRUST, PCI DSS) are only available starting at Business Critical.

**Scenario:** A startup wants to use dynamic masking policies to hide PII from junior analysts. They have Standard edition. Will this work?
**Answer:** No. Masking policies (column-level security) require Enterprise edition or higher. The startup needs to upgrade to Enterprise. Standard includes network policies, MFA, SSO, and RBAC, but NOT dynamic data masking.

**Scenario:** A company's data team wants to use multi-cluster warehouses to handle 200 concurrent dashboard users during peak hours. They have Standard edition. What do they need?
**Answer:** Upgrade to Enterprise edition. Multi-cluster warehouses (horizontal scaling) require Enterprise+. On Standard, they're limited to a single cluster per warehouse, which means queries will queue during high concurrency.

**Scenario:** Your security team demands that encryption keys be managed by your organization (customer-managed keys) so you can revoke access at any time. Which edition and feature do you need?
**Answer:** Business Critical edition with Tri-Secret Secure. This creates a composite master key using both a Snowflake-managed key and a customer-managed key (via AWS KMS, Azure Key Vault, or GCP Cloud KMS). If you revoke your key, data becomes inaccessible.

---

## 1.4 VIRTUAL WAREHOUSES (VERY HEAVILY TESTED)

### What they are:
- Independent MPP compute clusters
- Required for queries AND DML (INSERT, UPDATE, DELETE, COPY INTO)
- NOT required for metadata operations (SHOW, DESCRIBE, some COUNT queries)

### Sizes (Gen1):
XS=1 credit/hr → S=2 → M=4 → L=8 → XL=16 → 2XL=32 → 3XL=64 → 4XL=128 → 5XL=256 → 6XL=512

**Pattern**: each size UP = double the credits = double the compute

Exam trap: "A Medium warehouse is 3x an XS" → WRONG. IF YOU SEE "3x" or any non-power-of-2 multiplier → WRONG, each size DOUBLES (1→2→4→8→16). M = 4x XS.
Exam trap: "SHOW and DESCRIBE require a running warehouse" → WRONG. IF YOU SEE "warehouse required" for SHOW/DESCRIBE → WRONG, metadata operations need no warehouse.

### Gen2 Warehouses (NEW for COF-C03):
- Newer generation of standard warehouses
- Not yet default, not available in all regions
- Same size names but different credit consumption (see Service Consumption Table)
- Better performance per credit for many workloads

### Snowpark-Optimized Warehouses:
- Designed for Snowpark workloads (Python, Java, Scala)
- More memory per node
- Use for: ML training, large UDFs, data-intensive Snowpark operations
- Higher credit cost than standard warehouses

Exam trap: "Snowpark-Optimized warehouses are cheaper" → WRONG. IF YOU SEE "cheaper" or "lower cost" with Snowpark-Optimized → WRONG, they cost MORE credits for the extra memory.
Exam trap: "All Snowpark code needs Snowpark-Optimized warehouses" → WRONG. IF YOU SEE "requires" or "needs" Snowpark-Optimized → WRONG, standard warehouses run Snowpark fine. Optimized = heavy ML only.

### Default Warehouse for Notebooks:
- SYSTEM$STREAMLIT_NOTEBOOK_WH (auto-provisioned)
- Multi-cluster XS, max 10 clusters, 60-second timeout
- ACCOUNTADMIN owns it
- Best practice: use this only for notebook Python workloads, use separate warehouse for SQL queries from notebooks

### Billing:
- Per-second billing
- 60-second minimum each time warehouse starts
- Credits consumed only while running
- Suspended warehouse = zero credits

Exam trap: "Billing is per-minute" → WRONG. IF YOU SEE "per-minute" → WRONG, it's per-SECOND with 60-second minimum.
Exam trap: "A suspended warehouse still costs credits" → WRONG. IF YOU SEE "suspended" + "credits" or "costs" → WRONG, suspended = zero credits. Only running = billed.

### Auto-Suspend + Auto-Resume:
- Auto-suspend: warehouse suspends after X seconds of inactivity (default varies)
- Auto-resume: warehouse auto-starts when a query arrives (enabled by default)
- Both apply to the ENTIRE warehouse, not individual clusters

Exam trap: "Auto-suspend applies per cluster in multi-cluster" → WRONG. IF YOU SEE "per cluster" with auto-suspend → WRONG, auto-suspend applies to the ENTIRE warehouse.
Exam trap: "Auto-resume is disabled by default" → WRONG. IF YOU SEE "disabled" + "auto-resume" → WRONG, auto-resume is ENABLED by default.

### Scaling UP vs Scaling OUT:

| | Scale UP | Scale OUT |
|---|---|---|
| What | Bigger warehouse size | More clusters (multi-cluster) |
| When | Complex queries, spilling | High concurrency, many users |
| How | ALTER WAREHOUSE SET SIZE | Set MAX_CLUSTER_COUNT > 1 |
| Edition | ALL | Enterprise+ |
| Solves | Slow single queries, disk spilling | Queue wait times |

### Multi-cluster Warehouses (Enterprise+):
- Min clusters = 1 to 10
- Max clusters = 1 to 10
- If MIN = MAX → **Maximized mode** (always that many clusters)
- If MIN < MAX → **Auto-scale mode**

### Scaling Policies (for auto-scale):
- **Standard**: starts new cluster immediately when a query queues. Shuts down after 2-3 minutes idle. Favors performance.
- **Economy**: starts new cluster only if estimated to be busy for 6+ minutes. Favors cost savings.

**Exam trap**: "Economy prioritizes..." → Credit savings / throughput. IF YOU SEE "Economy" + "performance" or "fast" → WRONG, Economy favors cost savings, not speed.
**Exam trap**: "Standard prioritizes..." → Performance / fast response. IF YOU SEE "Standard" + "cost savings" → WRONG, Standard favors performance, starts clusters immediately.

### Why This Matters + Use Cases

**Why separate warehouses?** Because one team's heavy query shouldn't slow down another team. Warehouses are INDEPENDENT — they don't share resources.

**Real scenario — "Our BI dashboard is slow during ETL loads"**
A company runs COPY INTO (loading) and Tableau queries on the SAME warehouse. During loading, dashboard users wait in queue. Solution: separate warehouses — one for loading (auto-suspend after 1 min), one for BI (always-on during business hours).

**Real scenario — "Our monthly report takes 3 hours on XS"**
The query is complex and spills to remote disk. Solution: scale UP to Large or XL for that specific query. The report runs in 15 minutes. Then scale back down. Per-second billing means you only pay for those 15 minutes.

**Real scenario — "50 analysts all querying at 9am"**
Queries queue because there's only 1 cluster. Solution: multi-cluster warehouse (Enterprise+) with Standard scaling policy. New clusters spin up immediately when queries queue. At 11am when traffic drops, clusters auto-shut down.

**The scaling trap the exam loves:**
- "Spilling to disk" → Scale UP (bigger warehouse, more memory)
- "Queries queuing" → Scale OUT (more clusters, multi-cluster)
- NEVER the other way around. The exam WILL try to trick you.

---

### Warehouse Best Practices:
- Separate warehouses for different workloads (loading vs querying vs BI)
- Separate warehouses for different teams
- Use auto-suspend (save credits)
- Size UP for complex queries with spilling
- Scale OUT for concurrency issues
- Start small, resize as needed

Exam trap: "One big warehouse for all workloads is best practice" → WRONG. IF YOU SEE "single warehouse" or "one warehouse for everything" → WRONG, best practice = SEPARATE warehouses per workload.
Exam trap: "Resizing a warehouse affects running queries" → WRONG. IF YOU SEE "running queries" + "resize" + "affected" → WRONG, running queries use the OLD size. Only NEW queries get the new size.

### Example Scenario Questions — Virtual Warehouses

**Scenario:** A Query Profile shows significant "Bytes spilled to remote storage" for a complex join query running on an XS warehouse. What should you do?
**Answer:** Scale UP vertically — increase the warehouse size to Medium or Large. Spilling to remote storage means the warehouse doesn't have enough local SSD memory, so data overflows to slower remote storage. A bigger warehouse = more memory = less spilling = faster query. Do NOT add more clusters (horizontal scaling) — that only helps with concurrency, not individual query performance.

**Scenario:** At 9 AM every Monday, 80 analysts run their weekly reports simultaneously. The warehouse queue shows 60+ queries waiting. The warehouse is XL. What should you do?
**Answer:** Enable multi-cluster warehouse (requires Enterprise+) with auto-scale mode. Set MIN_CLUSTER_COUNT=1, MAX_CLUSTER_COUNT=5, scaling policy=Standard. This starts new clusters immediately when queries queue. The XL size is fine for individual queries — the problem is concurrency, not query complexity.

**Scenario:** A warehouse was suspended for 4 hours. A user runs the same query they ran yesterday. The query takes much longer than yesterday. Why?
**Answer:** The warehouse's local SSD cache (warm cache) was cleared when the warehouse was suspended. Yesterday's query benefited from cached data. Today the query must re-read data from remote storage. Note: the result cache (in Cloud Services) may still have yesterday's result IF the underlying data hasn't changed — but if data changed, a full re-scan is needed.

**Scenario:** You have a multi-cluster warehouse with MIN=1, MAX=4 and Economy scaling policy. During a burst of 30 concurrent queries, users complain about wait times. What's happening?
**Answer:** Economy policy only starts a new cluster if the system estimates it will be busy for 6+ minutes. Short bursts may not trigger new clusters. Switch to Standard scaling policy, which starts new clusters immediately when queries queue. Standard favors performance; Economy favors cost savings.

**Scenario:** An admin creates a Snowpark-Optimized warehouse for a team that writes simple SELECT queries on small tables. Is this the right choice?
**Answer:** No. Snowpark-Optimized warehouses cost more credits because they have extra memory per node. They're designed for memory-intensive workloads like ML training, large UDFs, and heavy Snowpark DataFrame operations. For simple SELECT queries, a standard warehouse is more cost-effective.

---

## 1.5 MICRO-PARTITIONS & DATA CLUSTERING

### Micro-partitions:
- Snowflake automatically divides ALL table data into micro-partitions
- Size: 50-500 MB uncompressed (smaller when compressed)
- Columnar storage within each partition
- Immutable (cannot be changed, only replaced)
- Users do NOT manually define or manage them

### What metadata is stored per micro-partition:
- Min and max values for each column
- Number of distinct values
- Number of null values
- Additional optimization properties

**Exam trap**: "What metadata is stored?" → Min/max values, distinct count, null count. IF YOU SEE "query history" or "user names" as metadata → WRONG, only statistical metadata is stored.
**Exam trap**: "What is NOT stored?" → User names who queried, query history. IF YOU SEE "who queried" in micro-partition metadata → WRONG, that's in ACCOUNT_USAGE, not partition metadata.

### Query Pruning:
- Snowflake uses micro-partition metadata to skip irrelevant partitions
- Only scans partitions where data MIGHT match the filter
- Also prunes at COLUMN level within partitions (columnar = only scans needed columns)

**Exam trap**: "What prevents effective pruning?" → Using functions on filtered columns. IF YOU SEE "WHERE UPPER(col)" or "WHERE CAST(col...)" → trap! Functions on columns defeat pruning.

### Data Clustering:
- Data is naturally clustered by insertion order
- Clustering depth = how many partitions overlap for a column
- Lower depth = better clustering = faster queries
- Available in ALL editions (automatic clustering)
- Clustering KEYS = you define which columns to cluster by
- Automatic Clustering = background service maintains clustering (serverless, costs credits)

### Clustering Depth:
- SYSTEM$CLUSTERING_DEPTH(table, columns) → check depth
- SYSTEM$CLUSTERING_INFORMATION(table, columns) → detailed clustering info
- Depth of 1 = perfectly clustered (no overlap)

Exam trap: "Higher clustering depth = better" → WRONG. IF YOU SEE "higher" + "better" with clustering depth → WRONG, LOWER depth = better. Depth 1 = perfect.
Exam trap: "SYSTEM$CLUSTERING_DEPTH returns the clustering KEY" → WRONG. IF YOU SEE "returns key" or "returns column name" → WRONG, it returns a NUMBER (overlap depth).

### When to use clustering keys:
- Very large tables (multi-terabyte)
- Queries frequently filter on specific columns
- Clustering depth is high (lots of overlap)
- NOT for small tables (waste of credits)

Exam trap: "All tables benefit from clustering keys" → WRONG. IF YOU SEE "all tables" + "clustering keys" → WRONG, only very large (multi-TB) tables benefit. Small tables = wasted credits.
Exam trap: "Automatic Clustering requires Enterprise edition" → WRONG. IF YOU SEE "Enterprise" + "clustering" → WRONG, clustering = ALL editions. Don't confuse with multi-cluster warehouses (Enterprise+).

### Example Scenario Questions — Micro-partitions & Clustering

**Scenario:** A 10TB orders table is frequently queried with `WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31'`. The query scans 95% of all micro-partitions despite the date filter. What's the problem and the fix?
**Answer:** The data has poor natural clustering on `order_date` — micro-partitions have overlapping date ranges so Snowflake can't effectively prune. Fix: define a clustering key on `order_date` with `ALTER TABLE orders CLUSTER BY (order_date)`. Automatic Clustering will reorganize data in the background. Verify improvement with `SYSTEM$CLUSTERING_DEPTH('orders', '(order_date)')` — the depth should decrease over time.

**Scenario:** A developer writes `WHERE UPPER(customer_name) = 'JOHN'` on a table with a clustering key on `customer_name`. The query is still slow. Why?
**Answer:** Wrapping a column in a function (like UPPER()) prevents micro-partition pruning. Snowflake stores min/max metadata for the raw column values, not for function results. Rewrite as `WHERE customer_name = 'John'` (if data is consistent) or use a case-insensitive collation. This is a common exam trap.

**Scenario:** A team adds clustering keys to every table in their schema, including a 50MB lookup table. Is this appropriate?
**Answer:** No. Clustering keys are only beneficial for very large tables (multi-TB). A 50MB table fits into a single micro-partition — there's nothing to prune. Adding clustering keys wastes credits on Automatic Clustering maintenance with zero query benefit.

**Scenario:** You run `SYSTEM$CLUSTERING_DEPTH('sales', '(region)')` and get a depth of 15. What does this tell you?
**Answer:** The clustering depth of 15 means there are many micro-partitions with overlapping `region` values — poor clustering. Ideally you want depth close to 1 (no overlap). If `region` is a frequent filter column, this table would benefit from a clustering key on `region`. After setting the key, Automatic Clustering will reduce depth over time.

---

## 1.6 TABLE TYPES (HEAVILY TESTED)

### Permanent Tables (default):
- Full Time Travel (1 day Standard, up to 90 days Enterprise+)
- 7-day Fail-safe after Time Travel expires
- Highest storage cost (data + Time Travel + Fail-safe)

### Transient Tables:
- Time Travel: 0 or 1 day only (even on Enterprise+, max 1 day)
- NO Fail-safe
- Persist across sessions
- Visible to other users/roles with access
- Lower storage cost than permanent
- Good for: staging data, ETL intermediate tables

### Temporary Tables:
- Time Travel: 0 or 1 day
- NO Fail-safe
- Session-scoped (dropped when session ends)
- Only visible to the session that created it
- Different sessions can have temp tables with same name
- If session disconnects (network failure) → table is dropped immediately

**Exam trap**: "Temporary table + network failure?" → Table dropped immediately. IF YOU SEE "persists" or "recoverable" after disconnect → WRONG, temp table = gone instantly.
**Exam trap**: "Transient vs Temporary?" → Transient persists across sessions, Temporary is session-only. IF YOU SEE "transient" + "session-scoped" → WRONG, that's temporary.
**Exam trap**: "Can you convert Transient to Permanent?" → NO (must recreate). IF YOU SEE "ALTER" + "convert" between table types → WRONG, you must CREATE new + copy data.

### External Tables:
- Read-only
- Data stays in external stage (S3, Azure Blob, GCS)
- Metadata managed by Snowflake
- Can use with Directory Tables
- No Time Travel, no Fail-safe
- Useful for data lakes

Exam trap: "External tables support INSERT/UPDATE" → WRONG. IF YOU SEE "INSERT", "UPDATE", or "DML" with external tables → WRONG, external tables are READ-ONLY.
Exam trap: "External tables have Time Travel" → WRONG. IF YOU SEE "Time Travel" or "Fail-safe" with external tables → WRONG, data is outside Snowflake's control — no TT, no Fail-safe.

### Dynamic Tables (NEW for COF-C03):
- Defined by a SQL query (SELECT statement)
- Snowflake automatically keeps results up to date
- You set a "target lag" (freshness target)
- Can be incremental or full refresh
- Available ALL editions
- Replaces complex Streams + Tasks pipelines for many use cases
- Think of it as: "I want this table to always reflect the result of this query"

### Why Dynamic Tables Exist — The Real Problem

**The old pain:** Before Dynamic Tables, if you wanted a table that always showed "yesterday's sales aggregated by region," you had to build: 1) a Stream to capture changes, 2) a Task to run every X minutes, 3) a MERGE statement to update the target table, 4) error handling, 5) monitoring. That's 5 moving pieces for something conceptually simple.

**The solution:** Dynamic Tables are DECLARATIVE. You write ONE SQL query and set a target lag (e.g., "1 day" or "1 hour"). Snowflake handles EVERYTHING else — it figures out when to refresh, whether to do incremental or full, and maintains the pipeline automatically.

**Real scenario:** A retail company wants a dashboard showing "total sales per store, updated hourly." 
- Old way: CREATE STREAM on sales_table → CREATE TASK hourly → MERGE INTO store_totals → hope nothing breaks
- New way: `CREATE DYNAMIC TABLE store_totals TARGET_LAG = '1 hour' AS SELECT store_id, SUM(amount) FROM sales GROUP BY store_id;` Done. One line.

**What "target lag" means:** It's your freshness tolerance. If target_lag = '1 hour', Snowflake guarantees the data is never more than 1 hour stale. Shorter lag = more frequent refreshes = more compute cost.

**Exam shortcut — if the question mentions:**
- "Declarative pipeline" → Dynamic Table
- "Target lag" → Dynamic Table
- "Replace Streams + Tasks" → Dynamic Table
- "Auto-refreshing materialized results" → Dynamic Table
- Available in ALL editions (not just Enterprise)

Exam trap: "Dynamic tables require Streams and Tasks" → WRONG. IF YOU SEE "Streams" or "Tasks" as requirements for dynamic tables → WRONG, dynamic tables REPLACE Streams+Tasks.
Exam trap: "Dynamic tables require Enterprise edition" → WRONG. IF YOU SEE "Enterprise" + "dynamic tables" as a requirement → WRONG, available in ALL editions.
Exam trap: "Dynamic tables are the same as materialized views" → WRONG. IF YOU SEE them equated → WRONG. Dynamic tables support complex queries (joins, subqueries). Materialized views are limited to single-table aggregations.

### Apache Iceberg Tables (NEW for COF-C03):
- Open table format
- Data stored in YOUR external storage (S3, Azure, GCS)
- Metadata in Iceberg format (not Snowflake proprietary)
- You manage the storage
- Can be read by other engines (Spark, Flink, etc.)
- Combines Snowflake query performance with open format
- Use for data lakes / lakehouses

### Why Iceberg Tables Exist — The Real Problem

**The vendor lock-in fear:** Companies store terabytes in Snowflake's proprietary format. If they ever want to also use Spark, Flink, or Databricks to read that data, they CAN'T — the data is locked inside Snowflake's internal storage format. They'd have to COPY it out (expensive, slow, duplicated).

**The solution: Apache Iceberg.** It's an OPEN table format — a standard way to store data that ANY engine can read. Snowflake, Spark, Flink, Trino, Databricks — they all understand Iceberg. The data lives in YOUR cloud storage (S3, Azure Blob, GCS), not inside Snowflake.

**Real scenario — "Our ML team uses Spark, our BI team uses Snowflake"**
The ML team trains models in Spark reading from S3. The BI team builds dashboards in Snowflake. Without Iceberg: two copies of the data, nightly sync, always out of date. With Iceberg: ONE copy in S3, both engines read it directly. Always fresh, no duplication.

**Iceberg vs External Table — What's the difference?**
- External Table: Snowflake creates its own metadata format to query files in your storage. Only Snowflake can use that metadata.
- Iceberg Table: Uses the open Apache Iceberg metadata format. Snowflake AND Spark AND Flink can all use the same metadata. True interoperability.

### Common Questions (FAQ)

**Q: Can Spark only run in the cloud?**
A: No! Apache Spark is open-source and runs ANYWHERE — your laptop, on-premises servers, or cloud (AWS EMR, Databricks, GCP Dataproc). It was created before cloud computing. But for Iceberg tables to work with BOTH Spark and Snowflake, the data must be in cloud storage (S3/Azure/GCS) because Snowflake is 100% cloud — it cannot read your local disk.

**Q: Can Snowflake run on-premises?**
A: No. Snowflake is cloud-ONLY. You cannot install it on your company's servers. It runs exclusively on AWS, Azure, or GCP. This is fundamental — if the exam mentions "on-premises Snowflake," it's a trap answer.

**Q: If the data is in MY S3, who pays for storage?**
A: YOU pay your cloud provider (AWS) for S3 storage. Snowflake charges compute credits when you query it, but the storage cost is on your AWS bill, not Snowflake's.

**Q: Can I write to an Iceberg table from Snowflake?**
A: Yes, Snowflake supports read AND write operations on managed Iceberg tables. But the key point for the exam is that the data format is OPEN — not proprietary to Snowflake.

**Exam shortcut — if the question mentions:**
- "Open table format" → Iceberg
- "Data stays in customer's storage" → Iceberg (or External table)
- "Multiple engines read the same data" or "interoperable" → Iceberg
- "Data lakehouse" → Iceberg
- "Apache Iceberg metadata" → Iceberg (not External table)

Exam trap: "Iceberg tables store data in Snowflake storage" → WRONG. IF YOU SEE "Snowflake storage" or "internal storage" with Iceberg → WRONG, data stays in YOUR external storage (S3/Azure/GCS).
Exam trap: "External table and Iceberg table are the same" → WRONG. IF YOU SEE "same" or "identical" comparing external and Iceberg → WRONG, Iceberg = open Apache format (interoperable). External = Snowflake metadata format.
Exam trap: "You need Enterprise edition for Iceberg tables" → WRONG. Available in ALL editions.

### Hybrid Tables:
- Optimized for low-latency transactional workloads
- Row-based storage (not columnar)
- Supports row locking, unique + referential integrity constraints
- Use for Unistore (transactional + analytical together)
- Available ALL editions

### Why Hybrid Tables Exist — The Real Problem

**The divided world:** Before Hybrid Tables, companies needed TWO databases: one fast transactional DB (Postgres, MySQL) for their e-commerce app to process orders in milliseconds, and Snowflake for analytics. They had to build expensive ETL pipelines to copy data between them every night. Painful, costly, always delayed.

**The solution: Unistore.** Hybrid Tables let your e-commerce app plug DIRECTLY into Snowflake. One place for both transactions AND analytics. No more copying data back and forth.

**Why row-based?** Traditional Snowflake stores data in COLUMNS (great for "sum all sales"). But an app needs to find ONE customer record instantly — that requires ROW storage. Hybrid Tables use row-based storage so finding a single row is sub-millisecond fast.

**The BIGGEST exam trap — Enforced Constraints:**
- Regular Snowflake tables: you can write PRIMARY KEY in your DDL, but Snowflake **does NOT enforce it**. You can insert duplicate IDs and Snowflake won't stop you. Constraints are just "informational."
- Hybrid Tables: constraints are **actually enforced**! Insert a duplicate ID → ERROR. Two users buying the last concert ticket → row locking ensures only one succeeds.
- IF YOU SEE "enforced constraints" or "enforced primary key" → Hybrid Table
- IF YOU SEE "constraints are informational only" → Regular permanent table

**Exam shortcut — if the question mentions:**
- "Unistore" → Hybrid Table
- "Enforced constraints" → Hybrid Table  
- "E-commerce app" or "OLTP" plugged into Snowflake → Hybrid Table
- "Row-based storage" → Hybrid Table
- "Sub-millisecond latency for single-row lookups" → Hybrid Table

Exam trap: "Hybrid tables use columnar storage" → WRONG. IF YOU SEE "columnar" with hybrid tables → WRONG, hybrid = ROW-based storage. Only regular Snowflake tables are columnar.
Exam trap: "Hybrid tables are for analytics workloads" → WRONG. IF YOU SEE "analytics" or "analytical" with hybrid tables → WRONG, hybrid = TRANSACTIONAL (operational) workloads.
Exam trap: "Hybrid tables require Enterprise edition" → WRONG. Available in ALL editions.
Exam trap: "Regular Snowflake tables enforce PRIMARY KEY constraints" → WRONG. IF YOU SEE "enforce" + regular table → WRONG. Only Hybrid Tables enforce constraints. Regular tables = informational only.

### Table Types Summary:

| Type | Time Travel | Fail-safe | Scope | Persist |
|---|---|---|---|---|
| Permanent | 1 day (90 Enterprise+) | 7 days | Account | Yes |
| Transient | 0-1 day max | NONE | Account | Yes |
| Temporary | 0-1 day max | NONE | Session only | No |
| External | NONE | NONE | Account | Yes (read-only) |
| Dynamic | Depends on underlying type | Depends | Account | Yes |
| Iceberg | Limited | NONE | Account | Yes |
| Hybrid | Limited | Limited | Account | Yes |

### Why This Matters + Use Cases

**Why does Snowflake have so many table types?** Because storage costs money, and not all data deserves the same protection level.

**The money rule:** Permanent tables cost the MOST because they keep 7 days of Fail-safe backup that you CAN'T disable. That's extra storage you pay for whether you want it or not.

**Real scenario — "How do I stop paying for Fail-safe on test data?"**
A client has a staging table that gets recreated every day by their ETL pipeline. They're paying for 7 days of Fail-safe on data they don't care about recovering. Solution: CREATE TRANSIENT TABLE. Zero Fail-safe = ~25-30% storage savings.

**Real scenario — "My session crashed and my temp table is gone"**
A data scientist was running a 2-hour analysis using temporary tables. Their VPN dropped. ALL temporary tables = gone instantly. Lesson: if your work takes hours, use TRANSIENT (persists across sessions) not TEMPORARY.

**Real scenario — "We need Spark AND Snowflake to read the same data"**
A data engineering team uses Spark for ML training and Snowflake for BI. They don't want to maintain two copies of the data. Solution: Apache Iceberg table — open format, stored in customer's S3, readable by both engines.

**Real scenario — "We want a table that always shows yesterday's aggregated sales"**
Instead of building a complex Streams + Tasks pipeline, create a Dynamic Table with target_lag = '1 day'. Snowflake automatically refreshes it. Declarative, simple, no pipeline code.

**The Fail-safe trap the exam loves:**
- "Can you change Fail-safe from 7 days to 3 days?" → NO. It's ALWAYS 7 for permanent tables.
- "Can you disable Fail-safe?" → Only by using Transient or Temporary tables. You can't disable it on permanent.
- "Who controls Time Travel vs Fail-safe?" → YOU control Time Travel (0-90 days). SNOWFLAKE controls Fail-safe (always 7 days, always support-only recovery).

---

### Best Practices — When to Use Each Table Type
- **Permanent**: Production data, compliance/audit data, anything needing disaster recovery
- **Transient**: Staging/ETL tables, derived aggregations that can be recreated. Saves ~25-30% storage vs permanent (no Fail-safe)
- **Temporary**: Session-only work — exploratory queries, intermediate calculations. Auto-dropped when session ends (NOT on disconnect — sessions persist through network drops)
- **External**: Data lake queries where data stays in S3/Azure/GCS. Read-only. Use when you DON'T want to copy data into Snowflake
- **Dynamic**: Replace Streams+Tasks pipelines. Set target lag. Best for automatically-refreshing dashboards/aggregations
- **Iceberg**: Open format, YOUR storage. Use when multiple engines (Spark, Flink) need to read the same data
- **Hybrid**: Low-latency transactional workloads (OLTP). NOT for analytics
- NEVER use permanent tables for staging — wasteful (Fail-safe costs money for data you can recreate)
- Decision tree: Need disaster recovery? → Permanent. Can recreate? → Transient. Session-only? → Temporary. External data? → External/Iceberg

### Example Scenario Questions — Table Types

**Scenario:** Your ETL pipeline creates a staging table every morning, loads CSV files from S3, transforms data, and inserts into production tables. The staging data is deleted after each run. Currently using permanent tables for staging, and storage costs are high. What table type should you use for staging?
**Answer:** Transient tables. Staging data can be recreated (just re-run the pipeline), so there's no need for Fail-safe. Switching from permanent to transient saves ~25-30% on storage costs. Do NOT use temporary — you want the table to persist across sessions in case the pipeline spans multiple sessions.

**Scenario:** A data analyst creates a temporary table during an interactive session to hold intermediate results of a complex analysis. Their VPN drops and the session disconnects. What happens to the data?
**Answer:** The temporary table is immediately dropped — all data is lost. Temporary tables are session-scoped and cannot survive disconnection. If the work is important and takes time, use a transient table instead (persists across sessions, still no Fail-safe cost).

**Scenario:** Your company wants both Snowflake and Apache Spark to read the same dataset stored in S3. They don't want to maintain two copies. Which table type should they use?
**Answer:** Apache Iceberg tables. Iceberg is an open table format stored in the customer's own storage (S3/Azure/GCS). Both Snowflake and Spark can read/write Iceberg format natively. The data stays in one place with one format — no duplication.

**Scenario:** A team wants a summary table that always reflects the latest aggregated sales data with no more than 1 hour delay. They currently use a complex Streams + Tasks pipeline that occasionally fails. What's a simpler approach?
**Answer:** Create a Dynamic Table with `TARGET_LAG = '1 hour'`. Define the table as a SELECT query with the aggregation logic. Snowflake automatically refreshes it (incrementally when possible). No Streams, no Tasks, no pipeline code to maintain.

**Scenario:** An admin tries to run `ALTER TABLE staging_transient SET DATA_RETENTION_TIME_IN_DAYS = 45` on a transient table (Enterprise edition). Will this work?
**Answer:** No. Transient tables have a maximum Time Travel retention of 1 day, even on Enterprise edition (which allows up to 90 days for permanent tables). The ALTER will fail. If you need 45-day Time Travel, you must use a permanent table.

---

## 1.7 VIEW TYPES

### Standard View:
- Stored SQL query (no data stored)
- Re-executes query every time it's accessed
- Can see the underlying SQL definition

### Materialized View (Enterprise+):
- Stores query results physically
- Auto-refreshed by background service (costs credits)
- Faster reads (pre-computed)
- Cannot use all SQL features (limited to single table, no UDFs, no window functions in some cases)
- Best for: expensive queries on data that doesn't change frequently

### Secure View:
- Hides the view definition from non-owners
- Query optimizer may be limited (can't see definition to optimize)
- Use for: sharing data (required for shares), protecting business logic
- Can be standard secure or materialized secure

**Exam trap**: "Which view type is required for data sharing?" → Secure View. IF YOU SEE "standard view" or "materialized view" as required for sharing → WRONG, only SECURE views work in shares.
**Exam trap**: "Materialized views cost credits for..." → Background maintenance/refresh. IF YOU SEE "no additional cost" with materialized views → WRONG, auto-refresh = serverless credits.

### Example Scenario Questions — View Types

**Scenario:** A company wants to share a curated dataset with an external Snowflake account via Secure Data Sharing. They have a standard view that joins 3 tables and applies business logic. Can they share this view directly?
**Answer:** No. Data sharing requires SECURE views. The admin must recreate the view as `CREATE SECURE VIEW ...`. Secure views hide the view definition from consumers, which is required for shares. Standard views expose their SQL definition, which is not allowed in sharing.

**Scenario:** A BI team runs the same expensive aggregation query every 15 minutes on a 2TB table that only changes once per day. The query takes 3 minutes each time. What view type would help?
**Answer:** A Materialized View (Enterprise+). It pre-computes and stores the results physically. Since the underlying data changes only once per day, the materialized view auto-refreshes once (cheap). The 15-minute queries become instant reads. The tradeoff: materialized views cost credits for background maintenance, and they're limited to single-table queries.

**Scenario:** A developer creates a secure view and notices that queries against it are slower than the same query run directly on the base table. Why?
**Answer:** Secure views limit the query optimizer's ability to optimize because the view definition is hidden. The optimizer can't push predicates through the view boundary as aggressively. This is the security-performance tradeoff of secure views. Only use secure views when security requires it (sharing, protecting business logic).

---

## 1.8 OBJECT HIERARCHY

```
Organization
  └── Account(s)
        └── Database(s)
              └── Schema(s)
                    ├── Tables
                    ├── Views
                    ├── Stages (user @~, table @%t, named @s)
                    ├── File Formats
                    ├── Sequences
                    ├── Pipes
                    ├── Streams
                    ├── Tasks
                    ├── UDFs
                    ├── Stored Procedures
                    ├── ML Models
                    └── Applications (Native Apps)
```

### Fully Qualified Name: `database.schema.object`
### Namespace: database.schema

### Session Context Variables:
- CURRENT_DATABASE()
- CURRENT_SCHEMA()
- CURRENT_WAREHOUSE()
- CURRENT_ROLE()
- CURRENT_USER()
- CURRENT_SESSION()
- CURRENT_ACCOUNT()

### Parameter Hierarchy (precedence — most specific wins):
- Account → set by ACCOUNTADMIN (least specific)
- User → overrides account for that user
- Session → overrides user for that session
- Object → depends on the parameter (most specific)

**Key**: More specific settings override less specific ones. Order: Object > Session > User > Account.

Exam trap: "Account-level overrides session-level" → WRONG. IF YOU SEE "account overrides session" → WRONG, session overrides account. More specific wins (Object > Session > User > Account).
Exam trap: "Stages are account-level objects" → WRONG. IF YOU SEE "account-level" + "stages" → WRONG, stages live inside schemas. Only warehouses and roles are account-level.
Exam trap: "Fully qualified name includes the account" → WRONG. IF YOU SEE "account" in a fully qualified name → WRONG, it's `database.schema.object` — no account.

### Example Scenario Questions — Object Hierarchy

**Scenario:** A new analyst runs `SELECT * FROM customers` and gets "Object does not exist" even though the table exists. Other team members can query it fine. What's likely wrong?
**Answer:** The analyst's session context is set to a different database or schema. They need to either use the fully qualified name `database.schema.customers` or set the correct context with `USE DATABASE mydb; USE SCHEMA myschema;`. Check with `SELECT CURRENT_DATABASE(), CURRENT_SCHEMA()`.

**Scenario:** An admin sets `STATEMENT_TIMEOUT_IN_SECONDS = 3600` at the account level. A specific user needs longer timeouts for their ETL jobs. Can this be overridden?
**Answer:** Yes. Set the parameter at the user level: `ALTER USER etl_user SET STATEMENT_TIMEOUT_IN_SECONDS = 7200`. More specific settings override less specific ones: Object > Session > User > Account. The ETL user gets 7200s while all other users keep 3600s.

**Scenario:** A developer asks: "Are stages account-level objects like warehouses?" How do you answer?
**Answer:** No. Stages are schema-level objects — they live inside `database.schema`. Warehouses and roles are account-level objects (they exist outside any database). This distinction matters for RBAC — granting access to a stage requires schema-level privileges.

---

## 1.9 INTERFACES AND TOOLS

### Snowsight:
- Web-based UI
- Write + run SQL
- Dashboards + visualizations
- Manage warehouses, databases, users
- View Query Profile / Query History

### Snowflake CLI (snow):
- Command-line tool
- Manage Snowflake objects from terminal
- Execute SQL
- Deploy Snowpark applications, Streamlit apps, Native Apps

### IDE Integrations:
- VS Code extension for Snowflake
- Connect to Snowflake from your IDE
- Write and run SQL, Snowpark code

### Git Integration (NEW for COF-C03):
- Connect Git repositories to Snowflake
- Store UDFs, procedures, Streamlit apps in Git
- Version control for Snowflake code
- CREATE GIT REPOSITORY object

Exam trap: "Snowsight supports PUT/GET commands" → WRONG. IF YOU SEE "Snowsight" + "PUT" or "GET" → WRONG, only SnowSQL (CLI) and connectors support PUT/GET.
Exam trap: "Snowflake CLI and SnowSQL are the same thing" → WRONG. IF YOU SEE "same" or "identical" comparing CLI and SnowSQL → WRONG, Snowflake CLI (`snow`) is newer. SnowSQL is legacy.
Exam trap: "Git integration stores code in Snowflake storage" → WRONG. IF YOU SEE "stored in Snowflake" with Git integration → WRONG, code stays in your Git repo. Snowflake references it via CREATE GIT REPOSITORY.

### Example Scenario Questions — Interfaces & Tools

**Scenario:** A developer needs to upload a 2GB CSV file from their local laptop to a Snowflake internal stage. They try using Snowsight but can't find an upload option for files this large. What tool should they use?
**Answer:** Use SnowSQL (the CLI client) with the PUT command: `PUT file:///path/to/file.csv @my_stage`. Snowsight has a file upload limit and doesn't support the PUT/GET commands. For programmatic uploads, you can also use Snowflake connectors (Python, JDBC, etc.).

**Scenario:** A team wants to version-control their Snowflake UDFs and stored procedures in GitHub, and deploy changes automatically. How can they integrate Git with Snowflake?
**Answer:** Use Git Integration (NEW in COF-C03): `CREATE GIT REPOSITORY` to connect your GitHub repo to Snowflake. The code stays in Git (not stored in Snowflake storage). You can then reference Git-stored files when creating UDFs, procedures, or Streamlit apps. For CI/CD, use the Snowflake CLI (`snow`) to deploy from Git.

**Scenario:** An admin wants to explore query performance issues using the VS Code extension for Snowflake. Can they view Query Profiles from VS Code?
**Answer:** The VS Code extension lets you connect to Snowflake, run SQL, and browse objects. For detailed Query Profile analysis (execution plan, operator statistics, spilling details), use Snowsight — it provides the visual Query Profile with the full performance breakdown.

---

## 1.10 AI/ML AND APP DEVELOPMENT (NEW for COF-C03)

### Snowflake Notebooks:
- Interactive coding environment inside Snowflake
- Support Python + SQL cells
- Use for data exploration, ML, analysis
- Run on dedicated notebook warehouse (SYSTEM$STREAMLIT_NOTEBOOK_WH)
- Can use Snowpark, ML libraries

### Streamlit in Snowflake:
- Build data apps directly in Snowflake
- Python-based (Streamlit framework)
- Data stays in Snowflake (no data movement)
- Governed by Snowflake security (RBAC)

### Snowpark:
- Write code in Python, Java, Scala
- DataFrame API that translates to SQL
- Code executes INSIDE the warehouse (not on your laptop)
- "Lazy evaluation" = nothing executes until you call an action (collect, show, write)
- Available ALL editions
- Use Snowpark-Optimized warehouses for heavy workloads

**Exam trap**: "Where does Snowpark code execute?" → Inside the Virtual Warehouse. IF YOU SEE "client-side", "local machine", or "Cloud Services" → WRONG, Snowpark runs INSIDE the warehouse.
**Exam trap**: "What is lazy evaluation?" → Query only runs when an action is called. IF YOU SEE "immediate execution" or "runs on definition" → WRONG, nothing executes until .collect()/.show().
**Exam trap**: "Snowpark translates to..." → SQL for execution. IF YOU SEE "bytecode" or "native Python execution" → WRONG, Snowpark translates DataFrame operations to SQL.

### Snowflake Cortex (AI Functions):
- AI_COMPLETE → text generation (LLM inference)
- AI_SENTIMENT → sentiment analysis
- AI_SUMMARIZE → text summarization
- AI_TRANSLATE → language translation
- AI_EXTRACT → entity extraction
- AI_CLASSIFY → text classification
- AI_EMBED → generate embeddings
- Runs inside Snowflake, data stays in Snowflake
- No need to move data to external ML platforms

Exam trap: "Cortex AI functions require data to be exported to an external ML platform" → WRONG. IF YOU SEE "export", "external platform", or "move data" with Cortex → WRONG, Cortex runs INSIDE Snowflake.
Exam trap: "AI_COMPLETE is for sentiment analysis" → WRONG. IF YOU SEE "AI_COMPLETE" + "sentiment" → WRONG, AI_COMPLETE = text generation (LLM). AI_SENTIMENT = sentiment. Don't swap the names.

### Cortex Search:
- Semantic search over text data
- Build search applications on your Snowflake data

### Cortex Analyst:
- Natural language to SQL
- Ask questions about your data in plain English
- Uses semantic views / semantic models

### Snowflake ML:
- ML Functions: built-in forecasting, anomaly detection, classification
- Model Registry: store and version ML models
- Feature Store: manage ML features
- Framework connectors for popular ML libraries

Exam trap: "Cortex Analyst does semantic search" → WRONG. IF YOU SEE "Analyst" + "semantic search" → WRONG, Analyst = natural language to SQL. Search = semantic search. They're swapped.
Exam trap: "Cortex Search generates SQL queries" → WRONG. IF YOU SEE "Search" + "generates SQL" → WRONG, Search does text search. Analyst generates SQL. Don't swap them.

### Example Scenario Questions — AI/ML and App Development

**Scenario:** A data scientist wants to build a quick dashboard to let business users explore sales data interactively. They want the app to run inside Snowflake without moving data to an external server. What should they use?
**Answer:** Use Streamlit in Snowflake. It allows you to build interactive Python-based data apps directly inside Snowflake. Data never leaves Snowflake, and the app is governed by Snowflake RBAC. No external hosting needed.

**Scenario:** A team has a Python ML pipeline that processes large DataFrames. They currently run it on a local server, but want to run it inside Snowflake for better scalability. What technology should they use, and where does the code execute?
**Answer:** Use Snowpark with a Snowpark-optimized warehouse. The Snowpark DataFrame API translates Python operations to SQL. Code executes INSIDE the virtual warehouse (not on the client machine). For memory-intensive ML workloads, use Snowpark-optimized warehouses which provide more memory per node.

**Scenario:** A company wants to add sentiment analysis to their customer feedback table without exporting data to an external ML platform. Which Cortex function should they use?
**Answer:** Use `AI_SENTIMENT()` — e.g., `SELECT AI_SENTIMENT(feedback_text) FROM customer_feedback`. This runs inside Snowflake, no data export needed. Do NOT confuse with AI_COMPLETE (which is for text generation/LLM inference) or AI_CLASSIFY (which is for text classification into categories).

**Scenario:** A business analyst wants to ask questions about their data in plain English and get SQL results back. They heard about Cortex Search and Cortex Analyst but aren't sure which to use. What's the difference?
**Answer:** Cortex Analyst converts natural language to SQL queries — it's for asking questions about structured data (e.g., "What were total sales last quarter?"). Cortex Search performs semantic search over text data — it's for finding relevant documents or text passages. The analyst wants Cortex Analyst (natural language → SQL), not Cortex Search.

**Scenario:** A developer is using Snowflake Notebooks and notices the notebook runs on a warehouse called SYSTEM$STREAMLIT_NOTEBOOK_WH. Can they change this?
**Answer:** Snowflake Notebooks run on dedicated notebook warehouses. While they use SYSTEM$STREAMLIT_NOTEBOOK_WH by default, you can configure the warehouse. Notebooks support both Python and SQL cells, and have access to Snowpark and ML libraries for data exploration and analysis.

---

## 1.11 CLONING (Zero-Copy Clone)

- CREATE ... CLONE creates a metadata-only copy
- No additional storage until data is modified
- Works on: databases, schemas, tables
- Clone inherits data at the point-in-time of cloning
- Clone does NOT inherit Time Travel history of the original
- Changes to clone do NOT affect original (and vice versa)
- Modified micro-partitions create new storage (only the changed parts cost extra)

**Exam trap**: "Storage cost of clone?" → Zero until modifications. IF YOU SEE "doubles storage" or "full copy" with clone → WRONG, zero-copy = no extra storage until data changes.
**Exam trap**: "Does clone include Time Travel history?" → No, only data at point of creation. IF YOU SEE "inherits Time Travel" or "includes history" → WRONG, clone starts fresh.

### Example Scenario Questions — Cloning

**Scenario:** A team needs to create a copy of a production database for testing. They're concerned about storage costs since the database is 5TB. How much additional storage will the clone use initially?
**Answer:** Zero additional storage initially. `CREATE DATABASE test_db CLONE prod_db` creates a zero-copy clone — it's metadata-only. Both the original and clone point to the same micro-partitions. You only pay for additional storage when data in the clone is modified (and only for the changed micro-partitions, not the entire table).

**Scenario:** After cloning a table, a developer checks Time Travel on the clone and expects to see the original table's history. They can't find it. Why?
**Answer:** Clones do NOT inherit Time Travel history from the original. The clone starts with only the data as it existed at the point of cloning. Time Travel on the clone begins fresh from the moment of creation. This is a common exam trap — "inherits Time Travel" is always wrong for clones.

**Scenario:** A developer clones a schema containing 10 tables. They then INSERT new rows into 3 of the cloned tables. How much additional storage is used?
**Answer:** Only the new/modified micro-partitions in those 3 tables consume additional storage. The other 7 unchanged tables still share micro-partitions with the original (zero extra storage). Even for the 3 modified tables, only the affected micro-partitions are new — unchanged partitions are still shared.

**Scenario:** Can you clone a view in Snowflake?
**Answer:** You cannot directly clone individual views. However, when you clone a database or schema, the views within it are included in the clone. The cloned views will reference the cloned tables (within the cloned schema/database), not the original tables. Cloning works on: databases, schemas, and tables.

---

## 1.12 SEMI-STRUCTURED DATA

### Supported formats: JSON, Avro, ORC, Parquet, XML

### VARIANT data type:
- Stores semi-structured data
- Can hold any type (object, array, scalar)
- Max size: 16 MB per value (compressed)

### Key Functions:
- **PARSE_JSON()** → convert JSON string to VARIANT
- **FLATTEN()** → expand arrays/objects into rows
- **OBJECT_KEYS()** → get all keys from a JSON object
- **TYPEOF()** → get the data type of a VARIANT value
- **::type** notation → cast VARIANT to specific type (e.g., col:name::string)
- **TO_DATE()**, **TO_NUMBER()** → convert VARIANT to typed values
- **Dot notation**: `column:key.subkey` to navigate JSON

### Sub-columnarization:
- Cloud Services layer automatically analyzes VARIANT columns
- Extracts frequently-accessed paths into optimized columnar storage
- Happens automatically, no user action needed

**Exam trap**: "Which service sub-columnarizes VARIANT?" → Cloud Services Layer. IF YOU SEE "Compute" or "Storage" layer doing sub-columnarization → WRONG, Cloud Services analyzes and optimizes VARIANT columns.
**Exam trap**: "FLATTEN is used for?" → Expanding nested arrays into rows. IF YOU SEE "FLATTEN" + "aggregate" or "collapse" → WRONG, FLATTEN expands/explodes — the opposite of aggregation.

### Example Scenario Questions — Semi-structured Data

**Scenario:** A company receives JSON data from an API where each record contains a nested array of order items. They need to create one row per order item for analysis. Which function should they use?
**Answer:** Use `FLATTEN()` to expand the nested array into individual rows. Example: `SELECT o.value:product_name::string AS product, o.value:quantity::number AS qty FROM orders, LATERAL FLATTEN(input => order_data:items) o`. FLATTEN explodes arrays/objects into rows — it's the opposite of aggregation.

**Scenario:** A data engineer loads JSON data into a VARIANT column. Queries on this column are slow. They haven't done anything special — does Snowflake optimize VARIANT data automatically?
**Answer:** Yes. The Cloud Services layer automatically performs sub-columnarization on VARIANT columns. It analyzes access patterns and extracts frequently-queried paths into optimized internal columnar storage. This happens automatically with no user action required. The key exam point: sub-columnarization is done by Cloud Services (not Compute, not Storage).

**Scenario:** A developer needs to access a deeply nested JSON field: `{"customer": {"address": {"city": "NYC"}}}`. The data is stored in a VARIANT column called `data`. How do they extract the city?
**Answer:** Use dot notation with casting: `SELECT data:customer.address.city::string AS city FROM my_table`. The colon (`:`) accesses the first level, dots (`.`) navigate deeper levels, and `::string` casts the VARIANT value to a string type. You can also use bracket notation: `data['customer']['address']['city']::string`.

**Scenario:** A team needs to load Parquet files into Snowflake. Should they convert Parquet to CSV first, or can Snowflake handle Parquet natively?
**Answer:** Snowflake handles Parquet natively — no conversion needed. Snowflake supports JSON, Avro, ORC, Parquet, and XML as semi-structured formats. You can load Parquet directly using COPY INTO with `TYPE = PARQUET` in the file format. Snowflake can also auto-detect the schema from Parquet files using `INFER_SCHEMA()`.

---

## RAPID-FIRE REVIEW (most tested patterns)

1. Three layers: Cloud Services (brain), Compute (muscle), Storage (memory)
2. Cloud Services handles: auth, optimizer, transactions, metadata
3. Warehouses bill per-second, 60s minimum
4. Each size up = 2x credits
5. Scale UP = bigger size (complex queries). Scale OUT = more clusters (concurrency)
6. Multi-cluster = Enterprise+ only
7. Standard scaling = start clusters fast. Economy = save credits.
8. Micro-partitions: 50-500 MB, columnar, immutable, automatic
9. Pruning uses min/max metadata. Functions on columns prevent pruning.
10. Temporary table = session-only, dropped when session ends (NOT on disconnect)
11. Transient = no Fail-safe, persists across sessions
12. Permanent = Time Travel + Fail-safe
13. Cannot convert between table types (must recreate)
14. Clone = zero-copy, no storage cost until modification
15. VARIANT = semi-structured container
16. PARSE_JSON + FLATTEN = most tested functions
17. Snowpark = lazy evaluation, runs IN the warehouse
18. Dynamic tables = automatic refresh, target lag
19. Iceberg = open format, YOUR storage, interoperable
20. All editions get: clustering, Snowpark, UDFs, dynamic tables, network policies
21. Enterprise+: multi-cluster, masking, row access, search opt, query accel, 90-day TT
22. Business Critical+: Tri-Secret, PrivateLink, HIPAA
23. VPS: dedicated everything, fully isolated

---

## CONFUSING PAIRS — Architecture

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Query optimization | Cloud Services layer | Compute layer |
| ACID compliance | Cloud Services layer | Storage layer |
| Where data physically lives | Storage layer | Cloud Services |
| Where queries run | Compute layer | Cloud Services |
| Credit billing | Per-second, 60s min | Per-minute |
| Micro-partition size | 50-500 MB uncompressed | 50-500 MB compressed |
| Micro-partitions managed by | Snowflake (automatic) | Users (manual) |
| Clustering available in | ALL editions | Enterprise+ |
| Multi-cluster available in | Enterprise+ | ALL editions |
| Temp table session ends | Table is DROPPED | Table persists |
| Transient table Fail-safe | NONE | 7 days |
| Snowpark runs code | Inside warehouse | On your local machine |
| Dynamic table freshness | Target lag (you set) | Real-time always |
| Account spans providers | NO (one provider per account) | Yes |

Exam trap: "Clustering and multi-cluster are the same" → WRONG. IF YOU SEE "clustering" and "multi-cluster" used interchangeably → WRONG, clustering = data organization (ALL editions). Multi-cluster = warehouse clusters (Enterprise+).
Exam trap: "Micro-partition size is 50-500 MB compressed" → WRONG. IF YOU SEE "compressed" with 50-500 MB → trap! It's 50-500 MB UNCOMPRESSED. The word "compressed" is the trap.

---

## BRAIN-FRIENDLY SUMMARY — Domain 1

### SCENARIO DECISION TREES
When you read a question, find the pattern:

**"A company needs to handle more concurrent users..."**
→ CORRECT: Scale OUT (multi-cluster, Enterprise+)
→ TRAP OPTION: "Increase warehouse size to XL" — WRONG, that's scale UP (solves slow queries, not concurrency)
→ TRAP OPTION: "Use Economy scaling" — WRONG direction, Economy is a scaling POLICY not a scaling action

**"A complex query is slow / spilling to disk..."**
→ CORRECT: Scale UP (bigger warehouse size)
→ TRAP OPTION: "Add more clusters" — WRONG, more clusters help concurrency, not single-query speed
→ TRAP OPTION: "Enable result cache" — WRONG, caching only helps repeated identical queries

**"A client wants to know which layer handles [anything smart]..."**
→ If it's about thinking/deciding/optimizing/security → Cloud Services
→ If it's about running queries → Compute
→ If it's about where data lives → Storage
→ TRAP OPTION: "Compute layer handles optimization" — WRONG, Compute just executes. Cloud Services optimizes.

**"An organization has data in AWS and also needs Azure..."**
→ CORRECT: Separate accounts (one account = one cloud) + link with Organizations
→ TRAP OPTION: "Configure the existing account to use both providers" — WRONG, one account = one cloud provider, always
→ TRAP OPTION: "Use data sharing across providers" — WRONG, you need replication first

**"A team needs staging data that won't need recovery..."**
→ CORRECT: Transient table (no Fail-safe, persists across sessions)
→ TRAP OPTION: "Temporary table" — WRONG if they need it across sessions. Temp = session-only.
→ TRAP OPTION: "Permanent table with 0 Time Travel" — WRONG, permanent still has 7-day Fail-safe (costs money)

**"A developer needs temp data just for this session..."**
→ CORRECT: Temporary table (gone when session ends)
→ TRAP OPTION: "Transient table" — WRONG if truly session-only. Transient persists and is visible to others.

**"The network drops and session disconnects. What happens to the temp table?"**
→ CORRECT: GONE. Dropped immediately.
→ TRAP OPTION: "Table persists until Time Travel expires" — WRONG, no recovery for temp tables on disconnect
→ TRAP OPTION: "Table is available when you reconnect" — WRONG, it's gone forever

**"Client wants open format, data stays in their S3..."**
→ CORRECT: Iceberg table
→ TRAP OPTION: "External table" — CLOSE but wrong if they need interoperability (Spark/Flink). External = Snowflake metadata only.
→ TRAP OPTION: "Create a permanent table and COPY data from S3" — WRONG, data wouldn't stay in their S3

**"Client wants auto-refreshing pipeline without managing Streams+Tasks..."**
→ CORRECT: Dynamic table (set target lag, done)
→ TRAP OPTION: "Create a materialized view" — CLOSE but wrong for complex queries. MVs are limited to single-table.
→ TRAP OPTION: "Use Streams + Tasks" — WRONG, that's the complex approach they want to avoid

**"Where does Snowpark Python code actually run?"**
→ CORRECT: Inside the warehouse. Always.
→ TRAP OPTION: "On the client machine" — WRONG, Snowpark is NOT local execution
→ TRAP OPTION: "In Cloud Services layer" — WRONG, Cloud Services only optimizes. Execution = Compute.

**"A client's warehouse is XS and the monthly report takes too long. They resize to Medium. What happens to the running query?"**
→ CORRECT: Running query stays on XS. Only NEW queries use Medium.
→ TRAP OPTION: "The running query immediately gets more resources" — WRONG, resize affects NEXT query only
→ TRAP OPTION: "The query restarts on the Medium warehouse" — WRONG, no restart happens

**"A client asks: what's the difference between a secure view and a regular view?"**
→ CORRECT: Secure view hides the SQL definition from consumers. Required for sharing.
→ TRAP OPTION: "Secure views are faster" — WRONG, they can actually be slower (optimizer can't see definition)
→ TRAP OPTION: "Regular views can be used in shares" — WRONG, only SECURE views in shares

**"A data team wants to query JSON nested inside a VARIANT column..."**
→ CORRECT: Dot notation: col:key.subkey + Cast with ::type + FLATTEN for arrays
→ TRAP OPTION: "Use PARSE_JSON on every query" — WRONG, PARSE_JSON converts strings to VARIANT. If data is already VARIANT, use dot notation directly.

**"A client runs SELECT COUNT(*) FROM huge_table with no WHERE clause and it returns instantly..."**
→ CORRECT: Metadata Cache (no warehouse needed, Cloud Services handles it)
→ TRAP OPTION: "Result cache from a previous query" — CLOSE but wrong if no one ran this query before. COUNT(*) without WHERE uses metadata.
→ TRAP OPTION: "The warehouse is very large" — WRONG, no warehouse is even needed for this

**"A client wants to build a Python ML model that processes data without moving it out of Snowflake..."**
→ CORRECT: Snowpark (DataFrame API, runs inside warehouse)
→ TRAP OPTION: "Export data to CSV and use locally" — WRONG, data leaves Snowflake
→ TRAP OPTION: "Use Cortex AI functions" — WRONG if they want custom ML model training. Cortex = pre-built AI functions.

**"A client asks: which Snowflake interface supports PUT/GET commands?"**
→ CORRECT: SnowSQL (CLI) and Snowflake connectors ONLY
→ TRAP OPTION: "Snowsight" — WRONG, Snowsight web UI does NOT support PUT/GET
→ TRAP OPTION: "Any SQL interface" — WRONG, PUT/GET are CLI-specific

**"A client wants low-latency key-value lookups with ACID transactions..."**
→ CORRECT: Hybrid table (operational workloads)
→ TRAP OPTION: "Standard permanent table" — WRONG, permanent tables are columnar (optimized for analytics, slow for single-row lookups)
→ TRAP OPTION: "Dynamic table" — WRONG, dynamic tables are for pipelines, not transactional workloads
→ SnowSQL (CLI) and Snowflake connectors ONLY
→ NOT Snowsight (web UI)

**"An organization needs to see usage across all their Snowflake accounts..."**
→ ORGADMIN role + Organization usage views
→ NOT ACCOUNTADMIN (that's per-account only)

**"A client wants to run a Streamlit dashboard that queries live Snowflake data..."**
→ Streamlit in Snowflake (runs inside SF, no external hosting)
→ Data never leaves Snowflake

**"A client needs both Python and SQL in the same document, with visualizations..."**
→ Snowflake Notebooks (interactive, collaborative)
→ NOT Streamlit (that's for apps, not notebooks)

**"A client asks about Gen2 warehouses vs regular warehouses..."**
→ Gen2 = newer compute engine, better price-performance
→ Same SQL, same interface — just runs faster/cheaper under the hood

**"A client stores Parquet files in their own S3 and wants Snowflake to query them without copying..."**
→ External table (read-only, data stays in customer's storage)
→ If they also want Apache Iceberg format compatibility → Iceberg table

**"A client wants low-latency key-value lookups with ACID transactions..."**
→ Hybrid table (optimized for operational workloads)
→ NOT regular tables (those are optimized for analytics)

---

### MNEMONICS TO LOCK IN

**Layers = B-M-M** (Brain, Muscle, Memory)
- Brain = Cloud Services (thinks, optimizes, secures)
- Muscle = Compute (does the heavy lifting)
- Memory = Storage (remembers the data)

**Warehouse sizes double = "Double Down"**
- XS=1, S=2, M=4, L=8, XL=16... every step UP = 2x credits

**Table types = "PeTT-y EDI"** (Permanent, Transient, Temporary, External, Dynamic, Iceberg)
- **Pe**rmanent = full protection (TT + Fail-safe)
- **T**ransient = no safety net (no Fail-safe)
- **T**emporary = no safety net AND session-only

**Edition rule = "Security UP, Features UP"**
- Standard = basics (works fine for most things)
- Enterprise = control who sees what (masking, row access) + performance (multi-cluster, search opt)
- BC = encryption + privacy (Tri-Secret, PrivateLink, HIPAA)
- VPS = total isolation

**Scaling memory trick = "UP for Power, OUT for People"**
- UP = more power for one big query
- OUT = more room for many people querying

**Micro-partitions = "Small, Columnar, Immutable, Automatic" → SCIA**
- 50-500 MB, columnar, can't change them, Snowflake handles it

---

### TOP TRAPS — Domain 1

1. **"Clustering requires Enterprise"** → WRONG. ALL editions. (Multi-cluster is Enterprise+, clustering is not)
2. **"Snowpark requires Enterprise"** → WRONG. ALL editions.
3. **"Micro-partitions are 50-500 MB compressed"** → WRONG. That's UNCOMPRESSED size.
4. **"Users define micro-partitions"** → WRONG. Automatic, always.
5. **"Warehouse suspend keeps the cache"** → WRONG. SSD cache is LOST on suspend.
6. **"Temporary tables have no Time Travel"** → WRONG. Up to 1 day.
7. **"You can ALTER a transient table to permanent"** → WRONG. Must recreate.
8. **"Snowpark runs on your local machine"** → WRONG. Runs inside the warehouse.
9. **"Dynamic tables need manual refresh"** → WRONG. Automatic based on target lag.
10. **"One Snowflake account spans AWS + Azure"** → WRONG. One account = one cloud provider.

---

### PATTERN SHORTCUTS — "If you see ___, answer is ___"

| If the question mentions... | The answer is almost always... |
|---|---|
| "query optimization", "query parsing" | Cloud Services layer |
| "transaction management", "ACID" | Cloud Services layer |
| "spilling to local/remote disk" | Increase warehouse SIZE |
| "queries queuing", "concurrency" | Multi-cluster / scale OUT |
| "Economy scaling policy" | Saves credits, waits 6 min |
| "Standard scaling policy" | Performance, starts immediately |
| "MIN = MAX clusters" | Maximized mode |
| "no Fail-safe but persists" | Transient table |
| "session ends = gone" | Temporary table |
| "open format, external storage" | Iceberg table |
| "target lag", "auto refresh pipeline" | Dynamic table |
| "lazy evaluation" | Snowpark |
| "DataFrame API" | Snowpark |
| "AI_COMPLETE, AI_SENTIMENT" | Cortex AI functions |
| "natural language to SQL" | Cortex Analyst |
| "semantic search" | Cortex Search |
| "interactive Python + SQL" | Snowflake Notebooks |
| "data app inside Snowflake" | Streamlit in Snowflake |
| "version control code in Snowflake" | Git integration (CREATE GIT REPOSITORY) |
| "transform models, testing, lineage" | dbt (third-party, Partner Connect) |
| "ELT pipeline tool, connectors" | Fivetran, Matillion, etc. (Partner Connect) |

---

## EXAM DAY TIPS — Domain 1 (31% = ~31 questions)

**Before studying this domain:**
- Make 10-15 flashcards ONLY for the concepts you keep confusing (layers, table types, editions)
- "Explain to a 5-year-old" test: if you can't explain Cloud Services vs Compute in one sentence, study more
- Practice the scenario questions above — the exam tests scenarios, not definitions

**During the exam — Domain 1 questions:**
- Read the LAST sentence first (the actual question) — then read the scenario
- Eliminate 2 obviously wrong answers immediately
- If they mention a LAYER → ask yourself: thinking/deciding = Cloud Services, doing work = Compute, storing = Storage
- If they mention SCALING → "UP for Power, OUT for People"
- If they mention a TABLE TYPE → check: does it persist? does it have Fail-safe?
- If they mention an EDITION → think "Security UP, Features UP" (Standard → Enterprise → BC → VPS)

Exam trap: "Domain 1 is only about the three layers" → WRONG. IF YOU SEE "only layers" → WRONG, it covers layers, editions, warehouses, table types, views, cloning, semi-structured, AI/ML, AND tools. It's 31%.
Exam trap: "Read the entire scenario first" → Risky for ADHD. IF YOU SEE a long scenario → read the LAST sentence (actual question) FIRST, then skim the scenario for keywords.

---

## ONE-LINE PER TOPIC — Domain 1

| Topic | One-line summary |
|---|---|
| 3-layer architecture | Cloud Services (brain), Compute (muscle), Storage (memory) — fully independent |
| Cloud Services | Thinks: query optimization, security, metadata, transaction management |
| Compute | Does: runs queries in warehouses, each warehouse = independent cluster of nodes |
| Storage | Remembers: all data in micro-partitions, columnar, compressed, immutable |
| Editions | Standard→Enterprise (masking, multi-cluster)→BC (Tri-Secret, PrivateLink)→VPS (full isolation) |
| Virtual Warehouses | T-shirt sizing (XS=1 credit/hr, doubles each size), auto-suspend, auto-resume |
| Gen2 Warehouses | Newer engine, better performance per credit, same interface |
| Snowpark-optimized WH | Extra memory for ML/data science workloads (Snowpark, UDFs) |
| Multi-cluster | Scale OUT for concurrency, Enterprise+, Standard or Economy policy |
| Micro-partitions | 50-500MB uncompressed, columnar, immutable, automatic — you never manage them |
| Clustering keys | You choose columns, Snowflake auto-maintains, improves pruning on large tables |
| Permanent tables | Full protection: Time Travel (1-90 days) + Fail-safe (7 days) |
| Transient tables | No Fail-safe, max 1-day TT, persists across sessions |
| Temporary tables | No Fail-safe, max 1-day TT, gone when session ends |
| External tables | Read-only, data in customer's cloud storage, metadata in Snowflake |
| Dynamic tables | Declarative pipeline: SQL + target lag = auto-refreshing results |
| Iceberg tables | Open Apache Iceberg format, data in customer's storage, interoperable |
| Hybrid tables | Low-latency key-value + ACID, for operational workloads |
| Views | Standard (exposes SQL), Secure (hides SQL, required for sharing), Materialized (pre-computed, Enterprise+) |
| Snowpark | DataFrame API (Python/Java/Scala), lazy evaluation, runs inside warehouse |
| Cortex AI | AI_COMPLETE, AI_SENTIMENT, AI_EXTRACT — built-in LLM functions |
| Cortex Analyst | Natural language → SQL using semantic model |
| Cortex Search | Semantic/hybrid search over text data |
| Snowflake Notebooks | Interactive Python + SQL, collaborative, visualizations |
| Streamlit in Snowflake | Build data apps inside Snowflake, data never leaves |
| Git Integration | CREATE GIT REPOSITORY, connects GitHub/GitLab to Snowflake |
| Object hierarchy | Organization → Account → Database → Schema → Objects |
| Cloning | Zero-copy, instant, independent after creation, no TT history from source |

---

## FLASHCARDS — Domain 1

**Q:** What are the 3 layers of Snowflake and what does each do?
**A:** Cloud Services (brain — auth, optimizer, metadata, transactions), Compute (muscle — virtual warehouses execute queries), Storage (memory — centralized cloud storage, columnar micro-partitions). All scale independently.

**Q:** Which layer handles query optimization?
**A:** Cloud Services layer — NOT Compute. Common exam trap.

**Q:** Which layer handles ACID transactions?
**A:** Cloud Services layer. It ensures User A cannot see uncommitted changes from User B.

**Q:** When is Cloud Services billed?
**A:** Only if Cloud Services usage exceeds 10% of total daily warehouse credit usage. Most accounts never hit this.

**Q:** Can one Snowflake account span multiple cloud providers?
**A:** No. One account = one cloud provider + one region. Use Organizations to link accounts across providers/regions.

**Q:** What are the two account identifier formats?
**A:** 1) Organization + Account name: `myorg-myaccount` (preferred). 2) Account locator: legacy, region-specific (e.g., `xy12345.us-east-1`).

**Q:** What does Enterprise Edition add over Standard?
**A:** Multi-cluster warehouses, Time Travel up to 90 days, column-level security, row access policies, materialized views, search optimization, query acceleration, dynamic data masking, periodic rekeying.

**Q:** What does Business Critical add over Enterprise?
**A:** Tri-Secret Secure, PrivateLink, HIPAA/PCI DSS compliance, account failover/failback.

**Q:** What does VPS add over Business Critical?
**A:** Dedicated metadata store + isolated compute pool. Completely separate from other Snowflake customers.

**Q:** What is the warehouse billing model?
**A:** Per-second billing with 60-second minimum. Credits depend on size (XS=1, S=2, M=4, L=8... each size doubles).

**Q:** Scale UP vs Scale OUT — when to use each?
**A:** Scale UP (bigger warehouse) = complex queries, spilling. Scale OUT (multi-cluster) = more concurrent users, queuing.

**Q:** What are micro-partitions?
**A:** Columnar, compressed, immutable, 50-500MB. Created automatically — you CANNOT control their size or number.

**Q:** What metadata does Snowflake store per micro-partition?
**A:** Row count, min/max per column, null count, distinct count. This powers pruning.

**Q:** What is a clustering key?
**A:** A column (or expression) that tells Snowflake how to physically organize micro-partitions. Use on large tables (multi-TB) with known filter columns. Automatic Clustering reorganizes in the background (ALL editions).

**Q:** Transient vs Temporary tables — what's the difference?
**A:** Both: 0-1 day Time Travel, NO Fail-safe. Transient persists across sessions. Temporary exists only in current session and is invisible to other sessions.

**Q:** External table vs regular table?
**A:** External table: data stays in external cloud storage (S3/Azure/GCS), read-only, no Time Travel, no Fail-safe, no clustering. Regular table: data in Snowflake storage, full features.

**Q:** What is a Dynamic Table?
**A:** A table that automatically refreshes based on a query and a target lag. Declarative pipeline — no tasks/streams needed. New for COF-C03.

**Q:** Regular view vs Secure view vs Materialized view?
**A:** Regular: SQL alias, no storage. Secure: hides SQL definition, required for shares. Materialized: stores results, auto-refreshes, Enterprise+ only, costs storage + compute.

**Q:** What is the object hierarchy?
**A:** Organization → Account → Database → Schema → Objects (tables, views, stages, etc.)

**Q:** What is Snowpark?
**A:** Developer framework to write data pipelines in Python, Java, or Scala using DataFrame API. Runs in the COMPUTE layer (not Cloud Services).

**Q:** UDF vs Stored Procedure?
**A:** UDF: returns a value, used in SELECT. Stored Procedure: performs actions, called with CALL, can use SQL/Python/Java/Scala/JavaScript.

**Q:** What is VARIANT data type?
**A:** Stores semi-structured data (JSON, Avro, Parquet, XML). Max 16MB per value. Access nested fields with `:` and `[]` notation.

**Q:** What does FLATTEN do?
**A:** Converts VARIANT/ARRAY/OBJECT into rows. Usually paired with LATERAL in FROM clause.

**Q:** What does zero-copy cloning do?
**A:** Creates a new object that shares the same micro-partitions (metadata-only at creation). No data copied until either source or clone is modified. Privileges are NOT cloned.

**Q:** What can be cloned?
**A:** Databases, schemas, tables, streams, tasks, sequences, stages (without external), file formats, pipes. NOT: users, roles, shares, warehouses.

**Q:** What are Snowflake's supported cloud providers?
**A:** AWS, Microsoft Azure, Google Cloud Platform. Account lives on one provider.

---

## EXPLAIN LIKE I'M 5 — Domain 1

**Cloud Services Layer**: The boss that reads your question, figures out the best plan, and tells the workers what to do.

**Compute Layer**: The workers (virtual warehouses) that actually crunch the numbers and do the heavy lifting.

**Storage Layer**: The giant filing cabinet where all your data is kept in organized little folders (micro-partitions).

**Micro-partitions**: Snowflake automatically chops your data into small organized boxes (50-500MB each) so it can find stuff faster.

**Pruning**: When you ask for data, Snowflake checks each box's label (min/max values) and skips boxes that definitely don't have what you need — like only opening drawers labeled "A-M" when looking for "Bob."

**Clustering key**: Telling Snowflake "please keep the boxes organized by this column" so it can skip even more boxes when searching.

**Virtual Warehouse**: A group of computers that does your work. You can have many warehouses, and they don't bother each other.

**Editions**: Like phone plans — Standard is basic, Enterprise adds fancy features (multi-cluster, 90-day Time Travel), Business Critical adds security (HIPAA, encryption), VPS is your own private Snowflake.

**Transient table**: A table that sticks around but doesn't keep long-term backups. Like writing on a whiteboard that nobody photographs.

**Temporary table**: A table that disappears when you close your session. Like a sandcastle — gone when you leave the beach.

**External table**: Looking at data that lives somewhere else (like S3) without moving it into Snowflake. Read-only window.

**Dynamic table**: A table that automatically updates itself based on a recipe (SQL query) you wrote. Like a self-filling spreadsheet.

**Secure view**: A window into your data that hides HOW you built the window. Required when sharing data with others.

**Materialized view**: A saved copy of query results that Snowflake keeps fresh automatically. Faster to read but costs storage.

**Snowpark**: Writing code in Python/Java/Scala that runs inside Snowflake's workers, instead of writing SQL.

**VARIANT**: A special box that can hold messy data (JSON, nested objects). Snowflake understands what's inside.

**FLATTEN**: Unpacking a list inside a VARIANT box — turning one row with an array into many rows.

**Zero-copy clone**: Making a copy of a table instantly by sharing the same boxes — no data actually moves until someone changes something.

**Object hierarchy**: Organization is the big company, Account is one office, Database is one room, Schema is one shelf, Objects are the individual files on that shelf.

**Result cache**: When you ask the same question twice