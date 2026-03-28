# Domain 2: Performance Optimization

> **DEA-C01 Weight:** 19% of the exam

---

## 2.1 Virtual Warehouses -- Sizing, Scaling, and Management

### Key Concepts
- **Warehouse sizes** range from X-Small to 6X-Large, each size doubling compute resources and credits per hour from the previous
- **Multi-cluster warehouses** (Enterprise edition+) automatically scale OUT by adding clusters to handle concurrency
- **Scaling policy:** STANDARD (favors spinning up clusters quickly) vs ECONOMY (favors keeping clusters consolidated, waits ~6 min)
- **AUTO_SUSPEND** stops the warehouse after N seconds of inactivity (minimum 60 seconds; set to 0 for immediate, NULL for never)
- **AUTO_RESUME** automatically starts the warehouse when a query is submitted
- **INITIALLY_SUSPENDED** creates the warehouse in a suspended state (avoids immediate credit charges)
- **Warehouse types:** Standard (general workloads) vs Snowpark-optimized (ML, large memory operations -- 16x memory per node)
- **MIN_CLUSTER_COUNT / MAX_CLUSTER_COUNT** controls the scaling range of multi-cluster warehouses
- **Query queuing** occurs when all clusters are fully utilized; queries wait in a FIFO queue

### Why This Matters
Warehouse configuration directly controls cost and performance. Over-sizing wastes credits, under-sizing causes slow queries and queuing. A data engineer must right-size warehouses for each workload type and configure scaling policies to balance cost with concurrency.

### Best Practices
- Start with X-Small or Small and scale up only if query times are unacceptable
- Use dedicated warehouses per workload type (ETL vs BI vs ad-hoc) to isolate performance and billing
- Set AUTO_SUSPEND to 60-300 seconds for interactive warehouses, higher for batch warehouses
- Use ECONOMY scaling policy for cost-sensitive workloads with predictable concurrency
- Use STANDARD scaling policy for user-facing dashboards where latency matters
- Monitor warehouse utilization via WAREHOUSE_METERING_HISTORY and QUERY_HISTORY

**Exam trap:** IF YOU SEE "Scaling up (bigger size) handles more concurrent queries" -> WRONG because scaling up adds compute power per query (faster individual queries). Scaling out (multi-cluster) handles more concurrent queries.

**Exam trap:** IF YOU SEE "AUTO_SUSPEND = 0 means the warehouse never suspends" -> WRONG because AUTO_SUSPEND = 0 means immediate suspend. NULL means never suspend.

**Exam trap:** IF YOU SEE "Snowpark-optimized warehouses are faster for all query types" -> WRONG because they are optimized for large memory workloads (ML, Snowpark). For standard SQL queries, standard warehouses are more cost-effective.

### Common Questions (FAQ)
**Q: When should you scale up vs scale out?**
A: Scale up (larger warehouse) when individual queries are slow due to data volume. Scale out (multi-cluster) when queries queue because too many run concurrently.

**Q: Does a 2X-Large warehouse run queries twice as fast as an X-Large?**
A: Not necessarily. Doubling resources helps with large scans and joins, but small queries may not benefit. Warehouse sizing follows diminishing returns for small workloads.

**Q: What happens when AUTO_RESUME is FALSE and a query is submitted?**
A: The query fails. The warehouse must be manually started with ALTER WAREHOUSE ... RESUME.

### Example Scenario Questions
**Scenario:** A BI team reports slow dashboard load times during morning hours (9-10 AM) when 50+ analysts run reports simultaneously. Individual queries complete quickly during off-peak hours. What is the recommended fix?
**Answer:** Enable multi-cluster warehouses with STANDARD scaling policy. Set MAX_CLUSTER_COUNT high enough to handle peak concurrency. The issue is concurrency (queuing), not individual query speed, so scaling out is the correct approach.

**Scenario:** A nightly ETL pipeline processes 500 GB of data in a single complex query. The query takes 4 hours on a Medium warehouse. The team wants it done in under 1 hour. What should they do?
**Answer:** Scale up the warehouse to X-Large or larger. This is a single large query that benefits from more compute power per query. Multi-cluster scaling would not help since there is only one query.

---

## 2.2 Query Optimization -- Clustering, Search Optimization, Query Acceleration

### Key Concepts
- **Clustering keys** define the physical sort order of micro-partitions for a table to improve pruning efficiency
- **Automatic Clustering** (background service) maintains the clustering order as data changes; billed as serverless compute
- **SYSTEM$CLUSTERING_INFORMATION()** returns clustering depth and overlap metrics to evaluate clustering effectiveness
- **Search Optimization Service (SOS)** accelerates point-lookup queries (equality predicates, IN lists, LIKE, geo) on large tables
- **SOS** is a serverless, materialized data structure maintained in the background -- billed for storage and compute
- **Query Acceleration Service (QAS)** offloads portions of a query (large scans) to shared serverless compute
- **QAS eligibility** is checked via SYSTEM$ESTIMATE_QUERY_ACCELERATION(); only certain scan-heavy queries benefit
- **SCALE_FACTOR** for QAS (1-100) limits how many serverless resources can be used as a multiple of warehouse size
- **Query Profile** (in Snowsight or via GET_QUERY_OPERATOR_STATS) shows the execution plan, spilling, pruning stats, and bottlenecks
- **EXPLAIN** generates the logical execution plan without running the query

### Why This Matters
Large-scale data engineering requires tuning query performance beyond warehouse sizing. Clustering, SOS, and QAS are the three primary optimization levers for reducing scan volume, accelerating lookups, and offloading compute.

### Best Practices
- Add clustering keys only on tables larger than ~1 TB that are frequently filtered on specific columns
- Choose clustering columns that align with the most common WHERE clause filters
- Use SOS for tables with frequent point-lookups (e.g., user_id = 'X') on large tables
- Use QAS for ad-hoc analytic queries with large scan components; set SCALE_FACTOR to control cost
- Always check the Query Profile for spilling (disk/remote), partition pruning ratios, and join explosion
- Do not cluster on high-cardinality columns alone (e.g., UUID); combine with a lower-cardinality column first

**Exam trap:** IF YOU SEE "Clustering keys physically reorder the table immediately" -> WRONG because Automatic Clustering reorders in the background over time. It is not instant.

**Exam trap:** IF YOU SEE "Search Optimization Service speeds up full table scans" -> WRONG because SOS accelerates selective point-lookup queries, not full scans.

**Exam trap:** IF YOU SEE "QAS replaces the need for a larger warehouse" -> WRONG because QAS supplements the warehouse by offloading scan-heavy portions. It does not replace the warehouse.

### Common Questions (FAQ)
**Q: When should you use clustering keys vs SOS?**
A: Clustering keys improve range scans and filters on sorted columns. SOS accelerates equality lookups and selective predicates. They serve different query patterns and can be used together.

**Q: Is there a cost to Automatic Clustering even when no queries run?**
A: Yes. Automatic Clustering runs in the background whenever data changes (inserts/updates/deletes), regardless of query activity. It is billed as serverless compute.

**Q: How do you know if QAS will help a specific query?**
A: Run SYSTEM$ESTIMATE_QUERY_ACCELERATION('query_id'). It returns the estimated speedup and eligible partitions.

### Example Scenario Questions
**Scenario:** A 5 TB fact table is filtered by date_key in 90% of queries. Over time, DML operations have degraded partition pruning. Queries now scan 10x more partitions than expected. What should you do?
**Answer:** Add a clustering key on date_key (or a compound key starting with date_key). Enable Automatic Clustering. Monitor improvement with SYSTEM$CLUSTERING_INFORMATION(). The clustering service will reorganize micro-partitions in the background.

**Scenario:** An application runs thousands of queries per hour looking up individual customer records by customer_id from a 2 TB table. Each query returns 1-5 rows. Warehouse utilization is high. What optimization should be applied?
**Answer:** Enable Search Optimization Service on the table for the customer_id column. SOS builds a search access path that makes point-lookups extremely fast without scanning partitions.

---

## 2.3 Caching Layers

### Key Concepts
- **Result cache** returns identical results for repeated queries without any compute (free, persists 24 hours)
- Result cache conditions: same query text, same role, no underlying data changes, no non-deterministic functions
- **Local disk cache (SSD cache)** stores recently accessed micro-partitions on the warehouse's local SSD
- Local disk cache is lost when the warehouse suspends (nodes released, cache evicted)
- **Remote disk cache** fetches data from Snowflake's storage layer when not in local cache
- **Cache hierarchy:** Result cache -> Local disk cache -> Remote disk cache -> Cloud storage
- **Metadata cache** stores table statistics (row count, min/max per column, distinct count) for small metadata queries

### Why This Matters
Understanding caching directly impacts both performance tuning and cost optimization. Result cache avoids compute charges entirely. Local disk cache avoids slow remote reads. Misunderstanding cache behavior leads to misleading benchmark results.

### Best Practices
- Do not suspend frequently-used warehouses too aggressively if local disk cache hit rate is important
- Use result cache by keeping query text consistent (same SQL text, same bind variables)
- Do not rely on result cache for queries on frequently changing tables (DML invalidates it)
- Benchmark queries on a warm cache (second run) for realistic production performance metrics
- Queries using non-deterministic functions (CURRENT_TIMESTAMP, RANDOM) bypass result cache

**Exam trap:** IF YOU SEE "Result cache persists indefinitely" -> WRONG because result cache expires after 24 hours, or sooner if underlying data changes.

**Exam trap:** IF YOU SEE "Local disk cache survives warehouse suspension" -> WRONG because suspending a warehouse releases compute nodes and clears local disk cache.

**Exam trap:** IF YOU SEE "Result cache is per-warehouse" -> WRONG because result cache is a global cloud services layer feature, not tied to a specific warehouse.

### Common Questions (FAQ)
**Q: Why does my query run faster the second time?**
A: If results are identical and conditions are met, the result cache returns instantly (no compute). If data changed, the local disk cache may still have partitions from the first run, reducing remote reads.

**Q: Does result cache work across different warehouses?**
A: Yes. Result cache is managed at the cloud services layer and is not warehouse-specific. Same query + same role + unchanged data = cache hit, regardless of warehouse.

### Example Scenario Questions
**Scenario:** A data team runs the same aggregation report every morning at 9 AM. The underlying table is refreshed nightly at 2 AM. The first analyst to run it waits 30 seconds, but subsequent analysts get results instantly. Why?
**Answer:** The first run populates the result cache. Subsequent identical queries hit the result cache (free, instant). Since data was refreshed at 2 AM and no further changes occurred, the result cache remains valid until 24 hours after the first query or until data changes again.

---

## 2.4 Materialized Views

### Key Concepts
- **Materialized views** are precomputed result sets stored as physical micro-partitions
- **Automatic background maintenance** keeps materialized views in sync with the base table (serverless compute cost)
- Queries may be **automatically rewritten** by the optimizer to use a materialized view even if the query references the base table
- **Limitations:** No joins, no UDFs, no HAVING, no ORDER BY, no LIMIT in the MV definition; must query a single table
- **Clustering** can be applied to materialized views for further pruning optimization
- **Enterprise edition** required for materialized views

### Why This Matters
Materialized views accelerate repetitive aggregation and filter patterns. They trade storage and maintenance cost for query speed. Knowing their limitations prevents wasted effort on unsupported patterns.

### Best Practices
- Use materialized views for frequently repeated aggregations on a single table
- Monitor maintenance costs via MATERIALIZED_VIEW_REFRESH_HISTORY
- Do not create materialized views on tables with extremely high DML rates (maintenance cost may exceed benefit)
- Leverage automatic query rewrite -- no need to change existing queries

**Exam trap:** IF YOU SEE "Materialized views support joins" -> WRONG because materialized views can only query a single table. No joins are allowed.

**Exam trap:** IF YOU SEE "Materialized views must be explicitly refreshed" -> WRONG because Snowflake maintains them automatically in the background.

### Common Questions (FAQ)
**Q: What is the difference between a materialized view and a dynamic table?**
A: Materialized views are single-table, auto-maintained, and support query rewrite. Dynamic tables support complex SQL (joins, CTEs) with a configurable target lag. Dynamic tables are more flexible but do not support automatic query rewrite.

### Example Scenario Questions
**Scenario:** A dashboard queries daily revenue aggregations from a 10 TB transaction table. The same query runs hundreds of times per day. The base table is updated once per hour. How can you optimize this?
**Answer:** Create a materialized view with the aggregation (GROUP BY date). Snowflake auto-maintains it after each hourly update. All dashboard queries benefit from the precomputed result and may be automatically rewritten to use the MV.

---

## 2.5 Resource Monitors, Query Profiling, and Query Tags

### Key Concepts
- **Resource monitors** track credit consumption at account or warehouse level over a specified interval
- **Actions:** NOTIFY, SUSPEND (finish running queries, then suspend), SUSPEND_IMMEDIATELY (kill running queries)
- **Thresholds** are set as percentages (e.g., 80% = notify, 100% = suspend)
- **Query tags** (ALTER SESSION SET QUERY_TAG = 'etl_pipeline') label queries for filtering in QUERY_HISTORY
- **Query Profile** (Snowsight) visualizes the execution DAG, showing each operator's statistics
- **Key Query Profile metrics:** bytes scanned, partitions scanned vs total, spilling to local/remote disk, percentage scanned from cache
- **Spilling to remote disk** is a critical performance red flag (data overflows warehouse memory and local SSD)

### Why This Matters
Resource monitors prevent runaway cost. Query profiling is the primary diagnostic tool for performance issues. Query tags enable workload attribution and chargeback analysis.

### Best Practices
- Create resource monitors for every warehouse in production with at least a NOTIFY threshold
- Set both SUSPEND and NOTIFY thresholds (e.g., notify at 80%, suspend at 100%)
- Use query tags consistently across pipelines for cost attribution
- Investigate any query with remote disk spilling -- consider scaling up the warehouse
- Check partition pruning ratio in Query Profile: if partitions scanned >> partitions needed, add clustering keys

**Exam trap:** IF YOU SEE "Resource monitors can limit the number of queries" -> WRONG because resource monitors track credit consumption, not query count.

**Exam trap:** IF YOU SEE "Spilling to local disk is always a problem" -> WRONG because local disk spilling (SSD) is expected for large operations. Remote disk spilling is the critical issue.

### Common Questions (FAQ)
**Q: Can a resource monitor cover multiple warehouses?**
A: Yes. A resource monitor can be assigned to one or more warehouses, or to the entire account.

**Q: What happens to running queries when a resource monitor triggers SUSPEND?**
A: SUSPEND waits for running queries to finish, then suspends the warehouse. SUSPEND_IMMEDIATELY kills running queries.

### Example Scenario Questions
**Scenario:** A team discovers their monthly Snowflake bill spiked because a developer left a Large warehouse running all weekend. How can they prevent this?
**Answer:** Create a resource monitor on the warehouse with a weekly or monthly credit quota. Set NOTIFY at 80% and SUSPEND at 100%. Also set AUTO_SUSPEND = 300 on the warehouse to suspend after 5 minutes of inactivity.

---

## CONFUSING PAIRS -- Performance Optimization

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Faster individual queries (more compute) | Scale up (larger warehouse) | Scale out (multi-cluster) |
| Handle more concurrent queries | Scale out (multi-cluster) | Scale up (larger warehouse) |
| Accelerate point lookups on large tables | Search Optimization Service (SOS) | Clustering keys (range scans) |
| Improve range scan pruning | Clustering keys | Search Optimization Service |
| Offload scan-heavy query portions | Query Acceleration Service (QAS) | Larger warehouse |
| Identical query, instant result, no compute | Result cache | Local disk cache |
| Fast repeat read, same warehouse session | Local disk cache (SSD) | Result cache |
| Precomputed single-table aggregation | Materialized view | Dynamic table |
| Complex multi-table pipeline result | Dynamic table | Materialized view |
| Track credit consumption | Resource monitor | Query tag |
| Label queries for filtering/attribution | Query tag | Resource monitor |
| Kill running queries on cost limit | SUSPEND_IMMEDIATELY | SUSPEND (waits for queries) |

---

## DON'T MIX -- Performance Optimization

### Scale Up vs Scale Out
| Aspect | Scale Up | Scale Out (Multi-cluster) |
|---|---|---|
| What changes | Warehouse size (more resources per node) | Number of clusters (more parallel capacity) |
| Helps with | Large, slow individual queries | Many concurrent queries queuing |
| Cost impact | Higher per-hour rate | More clusters x base rate |
| Configuration | ALTER WAREHOUSE ... SET WAREHOUSE_SIZE | MIN/MAX_CLUSTER_COUNT |
| Edition required | All editions | Enterprise+ |

**RULE:** Slow queries = scale up. Queuing queries = scale out.
**The trap:** Questions describe "performance problems" vaguely. Check if the issue is slow individual queries (scale up) or queries waiting in queue (scale out).

### Clustering Keys vs Search Optimization Service
| Aspect | Clustering Keys | Search Optimization Service |
|---|---|---|
| Optimizes | Range scans, filters on sorted columns | Point lookups, equality, IN, LIKE, geo |
| Mechanism | Physically reorders micro-partitions | Builds search access paths (materialized) |
| Maintenance | Automatic Clustering (serverless) | Background service (serverless) |
| Best for | WHERE date BETWEEN x AND y | WHERE id = 'abc' |
| Cost type | Serverless compute | Serverless compute + storage |

**RULE:** Range filters = clustering. Equality lookups = SOS. They can coexist on the same table.
**The trap:** Both improve pruning but for different access patterns. Do not assume one replaces the other.

### Result Cache vs Local Disk Cache
| Aspect | Result Cache | Local Disk Cache |
|---|---|---|
| Scope | Cloud services layer (global) | Per-warehouse node SSD |
| Stores | Complete query results | Raw micro-partition data |
| Survives suspend | Yes (24 hours) | No (cleared on suspend) |
| Cost | Free (no compute) | Uses warehouse compute for initial read |
| Invalidation | Data change or 24-hour expiry | Warehouse suspend or LRU eviction |

**RULE:** Same exact query with unchanged data = result cache (free). Different query on recently-read data = local disk cache (fast read).
**The trap:** Result cache is not warehouse-specific. Local disk cache is. Suspending a warehouse kills local cache but NOT result cache.

### Materialized Views vs Dynamic Tables
| Aspect | Materialized View | Dynamic Table |
|---|---|---|
| SQL complexity | Single table, no joins | Any SQL (joins, CTEs, subqueries) |
| Refresh | Automatic, near-instant | Target lag (configurable interval) |
| Query rewrite | Yes (optimizer auto-rewrites) | No |
| Use case | Repeated aggregations on one table | Multi-table pipelines |
| Edition | Enterprise+ | Enterprise+ |

**RULE:** Simple single-table aggregation = materialized view. Complex pipeline = dynamic table.
**The trap:** Both are "auto-refreshed" but materialized views support query rewrite while dynamic tables do not.

### SUSPEND vs SUSPEND_IMMEDIATELY (Resource Monitors)
| Aspect | SUSPEND | SUSPEND_IMMEDIATELY |
|---|---|---|
| Running queries | Waits for them to finish | Kills them immediately |
| New queries | Blocked | Blocked |
| Use case | Graceful cost control | Emergency cost control |
| Risk | Running queries may consume extra credits | Queries fail, users see errors |

**RULE:** SUSPEND = graceful. SUSPEND_IMMEDIATELY = emergency.
**The trap:** SUSPEND does not stop credit consumption instantly because running queries complete first.

---

## FLASHCARDS -- Domain 2

**Q1:** What are the two scaling directions for warehouses?
**A1:** Scale up (increase warehouse size for faster individual queries) and scale out (add clusters via multi-cluster for more concurrent queries).

**Q2:** What is the minimum AUTO_SUSPEND value?
**A2:** 60 seconds. Setting it to 0 means immediate suspend. NULL means never suspend.

**Q3:** What edition is required for multi-cluster warehouses?
**A3:** Enterprise edition or higher.

**Q4:** What does the ECONOMY scaling policy do differently from STANDARD?
**A4:** ECONOMY conserves credits by waiting ~6 minutes before spinning up additional clusters. STANDARD spins up clusters immediately when queries queue.

**Q5:** What function checks clustering effectiveness?
**A5:** SYSTEM$CLUSTERING_INFORMATION(table_name, column_list). It returns clustering depth and overlap statistics.

**Q6:** What type of queries does Search Optimization Service accelerate?
**A6:** Selective point-lookup queries: equality predicates (=), IN lists, LIKE, SUBSTR, and geospatial functions on large tables.

**Q7:** How do you check if a query can benefit from QAS?
**A7:** Run SYSTEM$ESTIMATE_QUERY_ACCELERATION('query_id'). It returns estimated speedup and eligible scan partitions.

**Q8:** How long does the result cache persist?
**A8:** Up to 24 hours, or until the underlying data changes, whichever comes first.

**Q9:** Does the result cache require a running warehouse?
**A9:** No. Result cache is served by the cloud services layer and consumes no warehouse credits.

**Q10:** What happens to local disk cache when a warehouse is suspended?
**A10:** It is cleared. Suspending releases compute nodes and all cached micro-partition data on their SSDs.

**Q11:** Can materialized views contain joins?
**A11:** No. Materialized views can only reference a single base table. No joins, UDFs, HAVING, ORDER BY, or LIMIT.

**Q12:** What is spilling to remote disk and why is it bad?
**A12:** When a query exceeds warehouse memory and local SSD capacity, it spills data to remote cloud storage. This is the slowest tier and signals the warehouse is undersized for the workload.

**Q13:** What do resource monitors track?
**A13:** Credit consumption (not query count or data volume). They can trigger NOTIFY, SUSPEND, or SUSPEND_IMMEDIATELY at defined percentage thresholds.

**Q14:** What is a Snowpark-optimized warehouse used for?
**A14:** Workloads requiring large amounts of memory per node (16x standard), such as ML training, large Snowpark DataFrame operations, and UDFs with high memory requirements.

**Q15:** What is the difference between SUSPEND and SUSPEND_IMMEDIATELY on a resource monitor?
**A15:** SUSPEND waits for running queries to complete before suspending. SUSPEND_IMMEDIATELY kills all running queries and suspends immediately.

**Q16:** What is the Query Acceleration Service SCALE_FACTOR?
**A16:** A value from 1-100 that limits how many additional serverless compute resources QAS can use, expressed as a multiple of the warehouse size. Higher values = more resources = more cost.

**Q17:** Does Automatic Clustering incur cost even when no queries run?
**A17:** Yes. It runs as a background serverless process whenever DML operations change data, regardless of query activity.
