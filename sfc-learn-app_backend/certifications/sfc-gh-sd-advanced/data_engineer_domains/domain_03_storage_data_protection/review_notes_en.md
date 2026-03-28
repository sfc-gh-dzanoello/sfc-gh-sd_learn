# Domain 3: Storage and Data Protection

> **DEA-C01 Weight:** 14% of the exam

---

## 3.1 Micro-partitions and Data Clustering

### Key Concepts
- **Micro-partitions** are Snowflake's fundamental storage unit: immutable, compressed, columnar files (50-500 MB uncompressed)
- Each micro-partition stores metadata: min/max values, distinct count, null count per column
- **Pruning** uses micro-partition metadata to skip irrelevant partitions during query execution
- **Natural clustering** occurs based on data insertion order (e.g., data loaded chronologically is naturally clustered by date)
- **Clustering keys** explicitly define the desired sort order across micro-partitions for improved pruning
- **Clustering depth** measures how many overlapping micro-partitions contain the same key range (lower = better)
- Snowflake tables are always stored as micro-partitions -- there is no row-store or other storage option

### Why This Matters
All Snowflake performance depends on micro-partition pruning. Understanding how data is physically stored, how pruning works, and how clustering impacts scan volume is essential for designing efficient tables and queries.

### Best Practices
- Let natural clustering work for time-series data loaded in order -- do not add a clustering key unless pruning degrades
- Monitor clustering with SYSTEM$CLUSTERING_INFORMATION() before adding keys
- Cluster on columns commonly used in WHERE clauses and join predicates
- Place lower-cardinality columns first in compound clustering keys
- Do not cluster tables smaller than ~1 TB -- the overhead outweighs the benefit

**Exam trap:** IF YOU SEE "Micro-partitions are mutable and updated in place" -> WRONG because micro-partitions are immutable. Updates create new micro-partitions and mark old ones for deletion.

**Exam trap:** IF YOU SEE "Each micro-partition stores one row" -> WRONG because each micro-partition stores 50-500 MB of columnar data, typically many thousands of rows.

**Exam trap:** IF YOU SEE "Clustering physically moves data immediately" -> WRONG because Automatic Clustering reorganizes data in the background over time.

### Common Questions (FAQ)
**Q: Does Snowflake support user-defined partitioning (like Hive partitions)?**
A: No. Snowflake manages micro-partitioning automatically. Clustering keys influence the organization but are not user-defined partition schemes.

**Q: What happens to old micro-partitions when data is updated?**
A: New micro-partitions are created with the updated data. Old micro-partitions are marked for deletion and eventually reclaimed after Time Travel and Fail-safe periods expire.

### Example Scenario Questions
**Scenario:** A 3 TB event table is loaded daily in time order. Queries always filter by event_date. Initially, queries are fast, but after months of DML operations (updates, deletes), queries slow down. What happened and how do you fix it?
**Answer:** DML operations fragment the natural clustering. Micro-partitions now have overlapping date ranges, reducing pruning efficiency. Add a clustering key on event_date and enable Automatic Clustering to restore optimal partition organization.

---

## 3.2 Time Travel

### Key Concepts
- **Time Travel** allows querying, cloning, and undropping data as it existed at a point in the past
- **DATA_RETENTION_TIME_IN_DAYS** controls how far back Time Travel reaches (0-1 day for Standard, 0-90 days for Enterprise+)
- **Default retention:** 1 day for permanent tables, 0 days for transient/temporary tables
- **AT / BEFORE** clauses enable historical queries: SELECT ... AT(TIMESTAMP => ...), AT(OFFSET => -300), AT(STATEMENT => 'query_id')
- **UNDROP TABLE / SCHEMA / DATABASE** restores dropped objects within the Time Travel retention window
- **Storage cost** is incurred for all changed micro-partitions retained during the Time Travel window
- Time Travel data is the delta (changed micro-partitions), not a full copy of the table

### Why This Matters
Time Travel is Snowflake's built-in disaster recovery for accidental data changes or drops. A data engineer must understand retention settings per table type and edition to design appropriate data protection strategies.

### Best Practices
- Set DATA_RETENTION_TIME_IN_DAYS = 90 for critical production tables (Enterprise+)
- Use minimal retention (0-1 day) for staging/temp tables to reduce storage costs
- Test UNDROP procedures in a non-production environment before you need them in an emergency
- Use AT(STATEMENT => 'query_id') to recover data from before a specific bad DML operation
- Remember that UNDROP restores to the most recently dropped version only

**Exam trap:** IF YOU SEE "Time Travel stores a full copy of the table for each day" -> WRONG because Time Travel only stores changed micro-partitions (the delta), not full copies.

**Exam trap:** IF YOU SEE "Standard edition supports 90 days of Time Travel" -> WRONG because Standard edition supports 0-1 day maximum. Enterprise+ is required for up to 90 days.

**Exam trap:** IF YOU SEE "You can UNDROP a table that was dropped 60 days ago with 1-day retention" -> WRONG because once the retention period expires, the data moves to Fail-safe and is no longer accessible via UNDROP.

### Common Questions (FAQ)
**Q: Can you Time Travel on a transient table?**
A: Transient tables support 0 or 1 day of Time Travel (default 0). They cannot have retention beyond 1 day regardless of edition.

**Q: What happens if you drop and recreate a table with the same name?**
A: The old table still exists in the Time Travel retention period. You can UNDROP it, but you must first rename or drop the current table with the same name.

**Q: Does Time Travel work on views?**
A: No. Time Travel applies to tables (and schemas/databases). Views are metadata definitions -- you can UNDROP a dropped view, but you cannot query AT/BEFORE on a view.

### Example Scenario Questions
**Scenario:** An engineer accidentally runs DELETE FROM orders WHERE 1=1, wiping the entire table. The table has DATA_RETENTION_TIME_IN_DAYS = 7. The mistake was discovered 2 hours later. How do they recover?
**Answer:** Use CREATE TABLE orders_recovered AS SELECT * FROM orders AT(OFFSET => -7200) to recover the full table as it existed 2 hours ago. Then swap or rename tables. Alternatively, use the query_id of the DELETE statement with AT(STATEMENT => 'query_id') to get the state just before the delete.

**Scenario:** A database was dropped 3 days ago. The account is Enterprise edition with 5-day retention. Can it be recovered?
**Answer:** Yes. Run UNDROP DATABASE database_name. The entire database (including all schemas and tables) is restored within the Time Travel window.

---

## 3.3 Fail-safe

### Key Concepts
- **Fail-safe** provides a 7-day recovery window AFTER Time Travel expires
- **Not user-accessible** -- only Snowflake support can recover data from Fail-safe
- Fail-safe is for catastrophic recovery scenarios, not routine data recovery
- **Storage cost** continues during the 7-day Fail-safe period for changed micro-partitions
- **Total protection window** = Time Travel period + 7 days of Fail-safe
- **Transient and temporary tables have NO Fail-safe** (0 days)
- **Permanent tables** always have 7 days of Fail-safe (cannot be changed)

### Why This Matters
Fail-safe is the last line of defense. Data engineers must understand that it is NOT self-service and that only permanent tables have it. Table type selection directly impacts data protection and storage cost.

### Best Practices
- Use permanent tables for business-critical data that needs the full protection chain (Time Travel + Fail-safe)
- Use transient tables for staging, intermediate, and reproducible data to avoid Fail-safe storage costs
- Budget for Fail-safe storage: 7 days of changed data for every permanent table
- Do not rely on Fail-safe for routine recovery -- use Time Travel (UNDROP, AT/BEFORE) instead

**Exam trap:** IF YOU SEE "Users can query Fail-safe data directly" -> WRONG because Fail-safe is only accessible by contacting Snowflake support. Users cannot query or restore from Fail-safe themselves.

**Exam trap:** IF YOU SEE "Fail-safe period is configurable" -> WRONG because Fail-safe is always 7 days for permanent tables and cannot be changed.

**Exam trap:** IF YOU SEE "Transient tables have Fail-safe" -> WRONG because transient tables have 0 days of Fail-safe.

### Common Questions (FAQ)
**Q: If Time Travel is set to 90 days, what is the total data protection window?**
A: 90 days Time Travel + 7 days Fail-safe = 97 days total. But only the Time Travel portion is self-service.

**Q: Does Fail-safe storage count toward my bill?**
A: Yes. Fail-safe storage is billed at the standard storage rate for all changed micro-partitions retained during the 7-day window.

### Example Scenario Questions
**Scenario:** A team is concerned about storage costs for a large staging table (refreshed daily). The data can always be reloaded from source. What table type should they use?
**Answer:** Create the staging table as TRANSIENT. This limits Time Travel to 0-1 day and eliminates Fail-safe storage entirely, significantly reducing storage costs for data that is reproducible.

---

## 3.4 Table Types -- Permanent, Transient, Temporary

### Key Concepts
- **Permanent tables** (default): Full Time Travel (up to 90 days Enterprise+), 7-day Fail-safe
- **Transient tables** (CREATE TRANSIENT TABLE): 0-1 day Time Travel, NO Fail-safe
- **Temporary tables** (CREATE TEMPORARY TABLE): 0-1 day Time Travel, NO Fail-safe, visible only to the creating session
- Temporary tables are automatically dropped when the session ends
- **Transient databases/schemas** make all tables within them transient by default
- You cannot convert a permanent table to transient or vice versa (must recreate)

### Why This Matters
Choosing the right table type is a cost/protection trade-off. Data engineers must match table types to data criticality: permanent for irreplaceable production data, transient for reproducible intermediate data, temporary for session-scoped scratch work.

### Best Practices
- Use permanent tables for production fact/dimension tables
- Use transient tables for staging, ETL intermediates, and data that can be reloaded
- Use temporary tables for session-scoped calculations and intermediate query results
- Create transient schemas for staging areas to automatically make all tables transient

**Exam trap:** IF YOU SEE "Temporary tables persist across sessions" -> WRONG because temporary tables are dropped when the session ends.

**Exam trap:** IF YOU SEE "You can ALTER a permanent table to transient" -> WRONG because table type cannot be changed after creation. You must recreate the table.

### Common Questions (FAQ)
**Q: Can other users see a temporary table?**
A: No. Temporary tables are scoped to the session that created them. Other sessions and users cannot see or access them.

**Q: What is the storage cost difference between table types?**
A: Permanent = data + Time Travel + Fail-safe. Transient = data + minimal Time Travel. Temporary = data + minimal Time Travel (auto-dropped on session end). The Fail-safe difference is the primary cost impact.

### Example Scenario Questions
**Scenario:** A team creates wide staging tables during ETL that are dropped and recreated every 6 hours. These tables are 500 GB each. Storage costs are high. What change reduces cost?
**Answer:** Change the staging tables from permanent to transient (CREATE TRANSIENT TABLE). This eliminates 7 days of Fail-safe storage and limits Time Travel to 0-1 day. For 500 GB tables refreshed every 6 hours, this can save substantial storage costs.

---

## 3.5 Cloning (Zero-copy Clone)

### Key Concepts
- **CREATE TABLE ... CLONE** creates an instant, metadata-only copy of a table (zero-copy: no data is duplicated)
- Cloned table shares the same micro-partitions as the source until data diverges
- **Storage cost** is only incurred for micro-partitions that differ between source and clone after creation
- Cloning works on tables, schemas, and databases (with all contained objects)
- **Time Travel clone:** You can clone an object as it existed at a past point: CLONE ... AT(TIMESTAMP => ...)
- **Cloning preserves:** data, structure, clustering keys, comments, stages (if database/schema clone)
- **Cloning does NOT preserve:** privileges (grants must be re-applied with COPY GRANTS option), future grants, pipes

### Why This Matters
Zero-copy cloning enables instant development and testing environments without doubling storage costs. It is also a powerful recovery tool when combined with Time Travel.

### Best Practices
- Clone production databases to create development/testing environments instantly
- Use Time Travel cloning to recover data to a specific point before a bad change
- Remember to re-apply necessary privileges after cloning (or use COPY GRANTS)
- Monitor clone storage divergence over time to understand actual storage costs
- Do not use clones as a substitute for proper backup/replication strategies

**Exam trap:** IF YOU SEE "Cloning duplicates all data immediately" -> WRONG because cloning is metadata-only (zero-copy). Data is shared until one side modifies it.

**Exam trap:** IF YOU SEE "Clones inherit all privileges from the source" -> WRONG because privileges are not cloned by default. Use COPY GRANTS to preserve them.

**Exam trap:** IF YOU SEE "Changes to a clone affect the source table" -> WRONG because clone and source are independent after creation. Changes to either do not affect the other.

### Common Questions (FAQ)
**Q: If I clone a 1 TB table, do I immediately pay for 2 TB of storage?**
A: No. The clone shares micro-partitions with the source. You only pay for new or modified micro-partitions. Initially, storage cost for the clone is near zero.

**Q: Can you clone a shared database (from data sharing)?**
A: No. Shared databases are read-only and cannot be cloned by the consumer.

### Example Scenario Questions
**Scenario:** A team needs an exact copy of the production database for testing a major schema migration. They need the copy within minutes and cannot afford to double their storage bill. What approach should they use?
**Answer:** Use CREATE DATABASE test_db CLONE prod_db. The entire database (all schemas, tables, views) is cloned instantly with zero-copy semantics. Storage costs only increase as the test environment diverges from production.

**Scenario:** An engineer needs to recover a table to its state from 3 hours ago after a bad UPDATE statement corrupted data. What is the fastest approach?
**Answer:** CREATE TABLE recovered_table CLONE corrupted_table AT(OFFSET => -10800). This creates a zero-copy clone of the table as it existed 3 hours ago. Then rename or swap tables as needed.

---

## CONFUSING PAIRS -- Storage and Data Protection

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Self-service data recovery | Time Travel (UNDROP, AT/BEFORE) | Fail-safe (Snowflake support only) |
| Last-resort catastrophic recovery | Fail-safe (contact Snowflake) | Time Travel (self-service) |
| 90-day retention capability | Enterprise+ edition, permanent tables | Standard edition (1 day max) |
| Staging/intermediate table type | Transient (no Fail-safe, low cost) | Permanent (unnecessary Fail-safe cost) |
| Session-scoped scratch table | Temporary table | Transient table (persists across sessions) |
| Instant copy, no storage duplication | Zero-copy clone | CTAS (full data copy) |
| Physical storage unit | Micro-partition (50-500 MB, columnar) | Row, block, or file |
| Data protected after Time Travel expires | Fail-safe (7 days, support-only) | Nothing (data is gone after Fail-safe) |
| Table with no Fail-safe at all | Transient or Temporary table | Permanent table (always 7 days) |

---

## DON'T MIX -- Storage and Data Protection

### Time Travel vs Fail-safe
| Aspect | Time Travel | Fail-safe |
|---|---|---|
| Access | Self-service (UNDROP, AT/BEFORE) | Snowflake support only |
| Duration | 0-90 days (configurable, edition-dependent) | Always 7 days (not configurable) |
| When active | Immediately after data change/drop | After Time Travel period expires |
| Table types | All tables (duration varies) | Permanent tables only |
| Use case | Routine recovery, auditing | Catastrophic disaster recovery |

**RULE:** If you can do it yourself, it is Time Travel. If you must call Snowflake, it is Fail-safe.
**The trap:** Questions mention "7-day recovery" -- check if they mean configurable (Time Travel) or the fixed 7-day Fail-safe window that only Snowflake support can access.

### Permanent vs Transient vs Temporary Tables
| Aspect | Permanent | Transient | Temporary |
|---|---|---|---|
| Time Travel (max) | 90 days (Enterprise+) | 1 day | 1 day |
| Fail-safe | 7 days | 0 days | 0 days |
| Visibility | All sessions with access | All sessions with access | Creating session only |
| Lifespan | Until dropped | Until dropped | Until session ends |
| Storage cost | Highest | Medium | Lowest (auto-dropped) |

**RULE:** Irreplaceable data = permanent. Reproducible data = transient. Scratch data = temporary.
**The trap:** Transient and temporary both lack Fail-safe. The key difference is session scope: temporary tables vanish when the session ends.

### Clone vs CTAS (CREATE TABLE AS SELECT)
| Aspect | Clone | CTAS |
|---|---|---|
| Speed | Instant (metadata-only) | Depends on data volume |
| Initial storage cost | Near zero | Full data copy |
| Data independence | Independent after creation | Independent from creation |
| Time Travel recovery | Supports AT/BEFORE in clone | Only captures current state |
| Preserves | Structure, data, clustering | Structure, data (no clustering keys) |

**RULE:** Need a fast, cheap copy = clone. Need a transformed/filtered copy = CTAS.
**The trap:** Both produce independent tables. The difference is speed, cost, and whether you need a transformation.

### Micro-partition Pruning vs Clustering
| Aspect | Pruning | Clustering |
|---|---|---|
| What it is | Skipping irrelevant partitions at query time | Organizing partitions for better pruning |
| Automatic | Always happens (built-in) | Must be configured (clustering keys) |
| Cost | Free (part of query execution) | Serverless compute for Automatic Clustering |
| Monitoring | Query Profile (partitions scanned) | SYSTEM$CLUSTERING_INFORMATION() |

**RULE:** Pruning is the benefit. Clustering is the optimization that improves pruning.
**The trap:** Every query prunes. Clustering keys only matter when natural ordering is insufficient and pruning is inefficient.

---

## FLASHCARDS -- Domain 3

**Q1:** What is the size range of a Snowflake micro-partition?
**A1:** 50-500 MB of uncompressed data. They are compressed, immutable, and stored in columnar format.

**Q2:** What is the maximum Time Travel retention for Enterprise edition?
**A2:** 90 days for permanent tables. Standard edition is limited to 0-1 day.

**Q3:** Can users query Fail-safe data?
**A3:** No. Fail-safe is only accessible by Snowflake support for catastrophic recovery. Users cannot query, UNDROP, or access Fail-safe data.

**Q4:** How long is the Fail-safe period?
**A4:** Always 7 days for permanent tables. It cannot be configured. Transient and temporary tables have 0 days.

**Q5:** What is the total data protection window for a permanent table with 90-day Time Travel?
**A5:** 97 days (90 days Time Travel + 7 days Fail-safe).

**Q6:** What does zero-copy cloning mean?
**A6:** Cloning creates a metadata-only copy that shares the same micro-partitions as the source. No data is duplicated. Storage cost increases only when data diverges.

**Q7:** Can you clone a table at a past point in time?
**A7:** Yes. Use CLONE ... AT(TIMESTAMP => ...) or AT(OFFSET => ...) to clone a table as it existed at a specific historical point within the Time Travel window.

**Q8:** What Time Travel is available for transient tables?
**A8:** 0 or 1 day (default 0). Cannot exceed 1 day regardless of edition.

**Q9:** Do temporary tables persist after the session ends?
**A9:** No. Temporary tables are automatically dropped when the creating session terminates.

**Q10:** Are grants (privileges) preserved when cloning?
**A10:** No, not by default. Use the COPY GRANTS option to preserve them during cloning.

**Q11:** What is the default DATA_RETENTION_TIME_IN_DAYS for a new permanent table?
**A11:** 1 day. It must be explicitly increased to leverage longer Time Travel.

**Q12:** Can you convert a permanent table to a transient table?
**A12:** No. Table type cannot be changed after creation. You must recreate the table (e.g., CREATE TRANSIENT TABLE ... AS SELECT * FROM ...).

**Q13:** What metadata does each micro-partition store?
**A13:** Min/max values, distinct count, and null count for each column. This metadata enables partition pruning.

**Q14:** What happens to Time Travel data when you drop a transient table?
**A14:** If retention is set to 1 day, Time Travel data is available for 1 day. If 0, it is immediately gone. No Fail-safe follows.

**Q15:** Can you UNDROP a table if another table with the same name already exists?
**A15:** No. You must first rename or drop the existing table with the same name, then run UNDROP.

**Q16:** Where does storage cost come from for a clone?
**A16:** Only from micro-partitions that have diverged (modified or new) since the clone was created. Shared micro-partitions are not double-billed.
