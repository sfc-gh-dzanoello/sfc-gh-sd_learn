# Domain 5: Data Transformation

> **DEA-C01 Weight:** 25% of the exam

---

## 5.1 Streams -- Change Data Capture

### Key Concepts
- **Streams** capture DML changes (INSERT, UPDATE, DELETE) on a source table as a change log
- **Standard stream** captures all DML types (inserts, updates, deletes) -- default
- **Append-only stream** captures INSERT operations only (ignores updates and deletes)
- **Insert-only stream** designed for external tables -- captures new file inserts only
- **Stream columns:** METADATA$ACTION (INSERT/DELETE), METADATA$ISUPDATE (TRUE for update pairs), METADATA$ROW_ID
- **Updates** are represented as a DELETE + INSERT pair (old row deleted, new row inserted)
- **Stream offset** advances when the stream's data is consumed in a DML transaction (not on SELECT)
- **Stale stream:** If the stream offset falls behind the table's Time Travel retention, the stream becomes stale and unusable
- **Streams are lightweight** -- they store only an offset pointer, not a copy of changes

### Why This Matters
Streams are the foundation of incremental data pipelines in Snowflake. Instead of reprocessing entire tables, streams capture only what changed since the last consumption, enabling efficient CDC patterns.

### Best Practices
- Match stream type to the use case: standard for full CDC, append-only for insert-heavy logs
- Always consume streams within a DML transaction to advance the offset (SELECT alone does not advance it)
- Set adequate DATA_RETENTION_TIME_IN_DAYS on source tables to prevent stream staleness
- Pair streams with tasks for automated incremental processing
- Use SYSTEM$STREAM_HAS_DATA() to check if a stream has new changes before triggering processing

**Exam trap:** IF YOU SEE "Streams store a copy of all changed rows" -> WRONG because streams store an offset pointer. The actual change data is derived from the table's Time Travel metadata at query time.

**Exam trap:** IF YOU SEE "SELECT from a stream advances the offset" -> WRONG because only DML operations (INSERT, MERGE, etc.) in a transaction that read from the stream advance the offset.

**Exam trap:** IF YOU SEE "Append-only streams capture updates" -> WRONG because append-only streams capture only inserts. Updates and deletes are ignored.

**Exam trap:** IF YOU SEE "Stale streams can be refreshed" -> WRONG because a stale stream must be recreated. There is no way to recover a stale stream.

### Common Questions (FAQ)
**Q: How are UPDATEs represented in a standard stream?**
A: As a pair: one DELETE row (old values, METADATA$ISUPDATE = TRUE) and one INSERT row (new values, METADATA$ISUPDATE = TRUE).

**Q: What causes a stream to become stale?**
A: If the stream's offset falls outside the source table's Time Travel retention period (data needed to compute changes has been purged).

**Q: Can you create a stream on a view?**
A: Yes, streams can be created on views (including secure views), but the underlying tables must support Time Travel.

### Example Scenario Questions
**Scenario:** An ETL pipeline needs to incrementally load only new and changed customer records from a source table into a target table. Deletions should also be captured. What is the best approach?
**Answer:** Create a standard stream on the source table. Create a task that runs a MERGE statement reading from the stream into the target table. The MERGE handles inserts, updates, and deletes. The stream offset advances automatically after each successful task execution.

**Scenario:** A logging table receives millions of INSERT operations per day but never has updates or deletes. You want to incrementally process new rows only. Which stream type should you use?
**Answer:** Use an append-only stream. It is optimized for insert-only workloads and avoids the overhead of tracking updates and deletes that will never occur.

---

## 5.2 Tasks -- Scheduling and Orchestration

### Key Concepts
- **Tasks** execute SQL statements or stored procedures on a schedule
- **Schedule types:** CRON expression (e.g., 'USING CRON 0 9 * * * America/New_York') or interval (e.g., '60 MINUTE')
- **Task trees (DAGs):** A root task triggers child tasks. Only the root task has a schedule; children run after their parent completes
- **WHEN condition:** Tasks can have a boolean condition (e.g., SYSTEM$STREAM_HAS_DATA('my_stream')) that must be true for execution
- **ALTER TASK ... RESUME** is required to start a task (tasks are created in SUSPENDED state)
- **Task owner role** must have EXECUTE TASK privilege (granted by ACCOUNTADMIN)
- **Serverless tasks** (USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE) use Snowflake-managed compute instead of a named warehouse
- **Error handling:** SUSPEND_TASK_AFTER_NUM_FAILURES controls automatic suspension after consecutive failures
- **TASK_HISTORY** view in INFORMATION_SCHEMA and ACCOUNT_USAGE tracks execution history

### Why This Matters
Tasks are the native scheduler for Snowflake pipelines. Combined with streams, they enable fully automated incremental data pipelines without external orchestration tools.

### Best Practices
- Use task trees (DAGs) for multi-step pipelines instead of independent tasks with overlapping schedules
- Set WHEN conditions with SYSTEM$STREAM_HAS_DATA() to skip execution when there is nothing to process
- Use serverless tasks for unpredictable workloads to avoid idle warehouse costs
- Set SUSPEND_TASK_AFTER_NUM_FAILURES to a reasonable value (e.g., 3-5) to catch persistent errors
- Resume tasks from leaf to root when building a DAG; suspend from root to leaf when stopping

**Exam trap:** IF YOU SEE "Child tasks in a DAG have their own schedule" -> WRONG because only the root task has a schedule. Child tasks are triggered by parent completion.

**Exam trap:** IF YOU SEE "Tasks are created in RESUMED state" -> WRONG because tasks are always created SUSPENDED and must be explicitly resumed.

**Exam trap:** IF YOU SEE "Serverless tasks require a warehouse" -> WRONG because serverless tasks use Snowflake-managed compute. You specify an initial size hint, not a warehouse name.

### Common Questions (FAQ)
**Q: How do you build a multi-step pipeline with tasks?**
A: Create a root task with a schedule. Create child tasks with AFTER <parent_task>. Only the root task runs on schedule; each child runs after its parent succeeds.

**Q: Can a task call a stored procedure?**
A: Yes. A task's SQL can be a CALL statement that executes a stored procedure.

**Q: What happens when a task's WHEN condition returns FALSE?**
A: The task is skipped for that scheduled run. It will be re-evaluated at the next scheduled interval.

### Example Scenario Questions
**Scenario:** A pipeline has three steps: (1) load raw data from a stream, (2) transform into a staging table, (3) merge into the final table. How do you orchestrate this?
**Answer:** Create a root task for step 1 with a schedule (e.g., every 5 minutes) and a WHEN condition checking SYSTEM$STREAM_HAS_DATA(). Create a child task for step 2 with AFTER root_task. Create a grandchild task for step 3 with AFTER step_2_task. Resume all tasks from leaf to root.

---

## 5.3 Dynamic Tables

### Key Concepts
- **Dynamic tables** are declarative pipeline objects: you define the target SQL, Snowflake keeps the result fresh
- **TARGET_LAG** specifies the maximum staleness tolerance (e.g., '5 minutes', '1 hour', or DOWNSTREAM)
- **Incremental refresh** allows Snowflake to process only changed data (when the query supports it)
- **Full refresh** recomputes the entire result when incremental refresh is not possible
- **DOWNSTREAM** target lag means the dynamic table refreshes only when a downstream object needs it
- **Dynamic table pipelines:** Chain dynamic tables where each one reads from the previous, forming a declarative DAG
- **No explicit scheduling needed** -- Snowflake manages refresh timing based on the target lag
- **Supported SQL:** Joins, aggregations, CTEs, window functions, FLATTEN -- most SQL constructs
- **DYNAMIC_TABLE_REFRESH_HISTORY** tracks refresh operations, latency, and incremental vs full refresh

### Why This Matters
Dynamic tables replace the streams + tasks pattern for many use cases with a simpler, declarative approach. They are the recommended way to build transformation pipelines when you want Snowflake to manage the refresh logic.

### Best Practices
- Set TARGET_LAG based on business requirements, not arbitrary short intervals (shorter lag = higher cost)
- Use DOWNSTREAM for intermediate tables that only need to be fresh when queried
- Check DYNAMIC_TABLE_REFRESH_HISTORY to verify incremental refreshes are occurring (full refreshes are more expensive)
- Use dynamic tables for declarative pipelines; use streams + tasks when you need imperative control (error handling, conditional logic)
- Keep dynamic table SQL within the supported incremental refresh subset for best performance

**Exam trap:** IF YOU SEE "Dynamic tables must be manually refreshed" -> WRONG because Snowflake automatically manages refresh based on the target lag.

**Exam trap:** IF YOU SEE "Dynamic tables always do incremental refresh" -> WRONG because only queries that support incremental refresh get it. Complex operations may fall back to full refresh.

**Exam trap:** IF YOU SEE "TARGET_LAG = DOWNSTREAM means the table never refreshes" -> WRONG because DOWNSTREAM means it refreshes when needed by a downstream dynamic table or on-demand.

### Common Questions (FAQ)
**Q: When should you use dynamic tables vs streams + tasks?**
A: Dynamic tables for declarative, SQL-only pipelines where Snowflake manages refresh. Streams + tasks for imperative pipelines needing conditional logic, stored procedure calls, or complex error handling.

**Q: What happens if a dynamic table's source changes faster than the target lag?**
A: Snowflake batches changes and refreshes at the target lag interval. Some changes may be batched together.

### Example Scenario Questions
**Scenario:** A team builds a pipeline with three transformation stages, each reading from the previous. They currently use streams + tasks but find the orchestration complex. What is the simpler alternative?
**Answer:** Replace each stream + task pair with a dynamic table. Each dynamic table defines its SQL transformation and reads from the previous dynamic table. Set appropriate TARGET_LAG at each level. Snowflake manages the entire refresh chain automatically.

---

## 5.4 Stored Procedures

### Key Concepts
- **Stored procedures** execute procedural logic: loops, conditionals, error handling, multi-statement transactions
- **Language options:** SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- **SQL Scripting:** DECLARE, LET, IF/ELSE, FOR, WHILE, RETURN, RESULTSET, cursors
- **Caller's rights** (default): Runs with the privileges of the calling role
- **Owner's rights** (EXECUTE AS OWNER): Runs with the privileges of the owning role
- **IMPORTANT:** In SQL stored procedures, reference variables and parameters with a colon prefix (:var_name) inside SQL statements
- **Stored procedures can return a single value** (scalar) or a table (RETURNS TABLE)
- **Anonymous stored procedures** can be created and executed inline with CALL (using $$ blocks)

### Why This Matters
Stored procedures enable complex, multi-step ETL logic that pure SQL cannot express: branching, looping, dynamic SQL, and transaction control. They are the primary tool for imperative data engineering in Snowflake.

### Best Practices
- Use SQL Scripting for most data engineering tasks (native, no external runtime)
- Use Python for procedures that need external libraries or ML integration
- Use caller's rights for general utility procedures
- Use owner's rights when the procedure needs to access objects the caller cannot
- Always handle exceptions with BEGIN ... EXCEPTION ... END blocks
- Use the colon prefix (:param) for variables in SQL statements within procedure bodies

**Exam trap:** IF YOU SEE "Stored procedures can be used in SELECT statements" -> WRONG because stored procedures are invoked with CALL, not in SQL expressions. UDFs are used in SELECT.

**Exam trap:** IF YOU SEE "Stored procedures use the owner's rights by default" -> WRONG because the default is caller's rights (EXECUTE AS CALLER).

### Common Questions (FAQ)
**Q: What is the difference between a stored procedure and a UDF?**
A: Stored procedures execute procedural logic via CALL (can have side effects, DML, DDL). UDFs return values and are used in SQL expressions (SELECT, WHERE). UDFs cannot perform DML.

**Q: Can stored procedures execute DDL?**
A: Yes. Stored procedures can execute any SQL including DDL (CREATE, ALTER, DROP), DML, and queries.

### Example Scenario Questions
**Scenario:** A pipeline needs to dynamically create partitioned tables based on a date range, load data into each, and log results. This requires looping and conditional logic. What should be used?
**Answer:** Create a SQL stored procedure using Snowflake Scripting with a FOR loop over the date range. Inside the loop, use dynamic SQL (EXECUTE IMMEDIATE) to create tables and run COPY INTO commands. Log results to an audit table after each iteration.

---

## 5.5 User-Defined Functions (UDFs, UDTFs, External Functions)

### Key Concepts
- **Scalar UDFs** return a single value per input row; used in SELECT, WHERE, etc.
- **Tabular UDFs (UDTFs)** return a table (multiple rows/columns); invoked with TABLE() in FROM clause
- **Language options:** SQL, JavaScript, Python, Java, Scala
- **SQL UDFs** are expression-based: the body is a single SQL expression (no BEGIN/END blocks for scalar)
- **External functions** call external APIs (via API Gateway + Lambda/Cloud Functions) -- for logic outside Snowflake
- **Secure UDFs** hide the function definition (like secure views); required for sharing
- **UDFs cannot perform DML** (INSERT, UPDATE, DELETE) -- they are read-only transformations
- **Overloading:** Multiple UDFs with the same name but different parameter signatures are supported

### Why This Matters
UDFs encapsulate reusable transformation logic within SQL queries. Data engineers use them for custom parsing, validation, business rules, and integrations that go beyond built-in functions.

### Best Practices
- Prefer SQL UDFs for simple transformations (best performance, no language runtime overhead)
- Use Python/Java UDFs when external libraries are needed
- Use UDTFs when a single input row must produce multiple output rows (e.g., parsing JSON arrays)
- Use external functions only when logic must run outside Snowflake (external API calls, proprietary algorithms)
- Write scalar SQL UDFs as expressions without BEGIN/END to avoid compilation issues

**Exam trap:** IF YOU SEE "UDFs can insert data into tables" -> WRONG because UDFs are read-only and cannot perform DML operations.

**Exam trap:** IF YOU SEE "External functions run inside Snowflake" -> WRONG because external functions call external endpoints (API Gateway + Lambda) outside Snowflake.

**Exam trap:** IF YOU SEE "UDTFs are invoked like scalar functions in SELECT" -> WRONG because UDTFs are invoked with TABLE(function_name()) in the FROM clause.

### Common Questions (FAQ)
**Q: When should you use a UDF vs a stored procedure?**
A: Use a UDF when you need a reusable transformation in SQL queries (SELECT, WHERE). Use a stored procedure for procedural logic with side effects (DML, DDL, loops).

**Q: Can you share a UDF?**
A: Yes, but it must be a secure UDF (CREATE SECURE FUNCTION) to be included in a data share.

### Example Scenario Questions
**Scenario:** Every query in a reporting pipeline applies the same complex business logic to calculate a "risk score" from 5 input columns. The logic involves nested CASE statements. What approach keeps the SQL clean?
**Answer:** Create a scalar SQL UDF that takes 5 parameters and returns the risk score. Replace the nested CASE logic in every query with a single function call: risk_score(col1, col2, col3, col4, col5).

**Scenario:** A JSON column contains an array of tags. Each row should be expanded into multiple rows (one per tag). What function type is needed?
**Answer:** Create a UDTF (or use the built-in FLATTEN function). A UDTF with RETURNS TABLE processes each input row and outputs multiple rows. Invoke it with SELECT * FROM table, TABLE(parse_tags(json_column)).

---

## 5.6 Snowpark DataFrame API

### Key Concepts
- **Snowpark** provides a DataFrame API for Python, Java, and Scala -- transformations execute on Snowflake, not the client
- **Lazy evaluation:** DataFrame operations build a query plan; execution happens on collect(), show(), or write
- **Session** object connects to Snowflake and is the entry point for all Snowpark operations
- **session.table()** reads a table into a DataFrame; session.sql() executes raw SQL
- **Transformations:** select(), filter(), group_by(), join(), with_column(), etc.
- **Pushdown:** All transformations are translated to SQL and executed on the Snowflake warehouse
- **Snowpark-optimized warehouses** provide extra memory for large Snowpark operations
- **Stored procedures can be written in Snowpark** (Python) for complex procedural ETL

### Why This Matters
Snowpark enables Python/Java/Scala developers to build data pipelines using familiar DataFrame syntax while leveraging Snowflake's compute. It bridges the gap between SQL-first and code-first data engineering.

### Best Practices
- Use Snowpark when the team prefers Python/Java over SQL for transformations
- Leverage lazy evaluation -- chain transformations before calling an action
- Use session.sql() for operations that do not map cleanly to the DataFrame API
- Deploy Snowpark code as stored procedures for production scheduling via tasks
- Use Snowpark-optimized warehouses for memory-intensive Snowpark workloads

**Exam trap:** IF YOU SEE "Snowpark executes transformations on the client machine" -> WRONG because Snowpark uses pushdown execution -- all transformations run on the Snowflake warehouse.

**Exam trap:** IF YOU SEE "Snowpark DataFrames are evaluated eagerly" -> WRONG because Snowpark uses lazy evaluation. The query plan is built incrementally and executed only on action calls.

### Common Questions (FAQ)
**Q: What is the difference between Snowpark and a Pandas DataFrame?**
A: Pandas processes data locally in memory. Snowpark DataFrames push all computation to Snowflake's warehouse. Snowpark handles data larger than local memory.

**Q: Can Snowpark be used with existing SQL pipelines?**
A: Yes. session.sql() executes any SQL. You can mix DataFrame operations with raw SQL freely.

### Example Scenario Questions
**Scenario:** A data science team writes Python transformations using Pandas but hits memory limits on large datasets. They want to keep using Python syntax. What should they use?
**Answer:** Migrate to Snowpark DataFrames. The API is similar to Pandas but executes on Snowflake's warehouse (pushdown), handling datasets far larger than local memory. Deploy as Snowpark stored procedures for production.

---

## 5.7 SQL Transformations -- CTEs, Window Functions, MERGE, FLATTEN, PIVOT

### Key Concepts
- **CTEs (Common Table Expressions):** WITH clause defines temporary named result sets within a query; improves readability
- **Recursive CTEs:** WITH RECURSIVE enables hierarchical/graph traversals
- **Window functions:** OVER(PARTITION BY ... ORDER BY ...) for running totals, rankings, LAG/LEAD, FIRST_VALUE, etc.
- **MERGE:** Combines INSERT, UPDATE, DELETE in a single statement based on join conditions (upsert pattern)
- **FLATTEN:** Converts VARIANT/ARRAY/OBJECT semi-structured data into relational rows
- **LATERAL FLATTEN:** Correlates FLATTEN with the parent row for row-by-row expansion
- **PIVOT:** Rotates rows to columns (wide format); UNPIVOT does the reverse (columns to rows)
- **Sequences:** CREATE SEQUENCE generates unique, sequential numbers (used for surrogate keys)
- **GENERATOR / TABLE(GENERATOR(ROWCOUNT => N)):** Creates synthetic rows for testing or series generation
- **Directory tables:** Enable querying file metadata on a stage (filename, size, last_modified) for unstructured data processing

### Why This Matters
These SQL constructs are the core toolkit for data transformation in Snowflake. MERGE is essential for CDC. FLATTEN is critical for JSON/semi-structured data. Window functions enable complex analytics without self-joins.

### Best Practices
- Use CTEs to break complex queries into readable, testable steps
- Use MERGE for stream-based CDC pipelines (handles insert/update/delete in one statement)
- Use LATERAL FLATTEN for semi-structured data (JSON arrays, nested objects)
- Use window functions instead of self-joins for row comparisons (LAG, LEAD, ROW_NUMBER)
- Use PIVOT/UNPIVOT for reshaping data between wide and tall formats
- Use sequences for surrogate keys in dimension tables

**Exam trap:** IF YOU SEE "MERGE can only INSERT or UPDATE" -> WRONG because MERGE supports WHEN MATCHED THEN UPDATE, WHEN MATCHED THEN DELETE, and WHEN NOT MATCHED THEN INSERT.

**Exam trap:** IF YOU SEE "FLATTEN works on relational columns" -> WRONG because FLATTEN operates on VARIANT, ARRAY, or OBJECT data types.

**Exam trap:** IF YOU SEE "CTEs materialize intermediate results" -> WRONG because CTEs in Snowflake are inlined (not materialized). The optimizer may re-execute a CTE multiple times.

### Common Questions (FAQ)
**Q: What is the difference between FLATTEN and LATERAL FLATTEN?**
A: FLATTEN is a table function that explodes arrays/objects. LATERAL FLATTEN correlates with the outer row, allowing you to reference outer columns in the same query. In practice, LATERAL FLATTEN is the standard pattern for semi-structured data.

**Q: Can MERGE handle all three DML operations in one statement?**
A: Yes. A single MERGE can have WHEN MATCHED THEN UPDATE, WHEN MATCHED AND condition THEN DELETE, and WHEN NOT MATCHED THEN INSERT.

**Q: What are directory tables used for?**
A: They allow you to query metadata about files staged in internal or external stages (file name, size, last modified, MD5). Useful for processing unstructured data (images, PDFs) where you need to list files before processing them.

### Example Scenario Questions
**Scenario:** A CDC pipeline uses a stream on a source table. The stream captures inserts, updates, and deletes. You need to apply all changes to a target table in a single operation. What SQL pattern should you use?
**Answer:** Use a MERGE statement. Match on the primary key. Use WHEN MATCHED AND METADATA$ACTION = 'DELETE' THEN DELETE, WHEN MATCHED AND METADATA$ACTION = 'INSERT' THEN UPDATE (for updates represented as delete+insert), and WHEN NOT MATCHED THEN INSERT.

**Scenario:** A JSON column contains nested arrays of product items per order. You need one row per product item with the order information preserved. How do you transform this?
**Answer:** Use LATERAL FLATTEN: SELECT o.order_id, f.value:product_id, f.value:quantity FROM orders o, LATERAL FLATTEN(input => o.items_json) f. This produces one row per array element, correlated with the outer order row.

---

## CONFUSING PAIRS -- Data Transformation

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Captures DML changes incrementally | Stream | Dynamic table (declarative refresh) |
| Declarative pipeline with auto-refresh | Dynamic table | Stream + task (imperative) |
| Scheduled SQL execution | Task | Stream (captures changes, does not schedule) |
| Procedural logic with DML side effects | Stored procedure | UDF (read-only) |
| Reusable transformation in SELECT | UDF | Stored procedure (CALL only) |
| Returns multiple rows from a function | UDTF (table function) | Scalar UDF (single value) |
| Explode JSON array into rows | FLATTEN / LATERAL FLATTEN | UDF |
| Upsert (insert + update) pattern | MERGE | INSERT + UPDATE (two statements) |
| Auto-increment unique ID | Sequence | IDENTITY (column property) |
| Runs transformation on Snowflake compute | Snowpark (pushdown) | Pandas (local compute) |
| File metadata from stage | Directory table | INFORMATION_SCHEMA |
| Rotate rows to columns | PIVOT | UNPIVOT (columns to rows) |

---

## DON'T MIX -- Data Transformation

### Streams + Tasks vs Dynamic Tables
| Aspect | Streams + Tasks | Dynamic Tables |
|---|---|---|
| Approach | Imperative (you define when/how to process) | Declarative (you define what, SF manages when) |
| Scheduling | Task schedule or CRON | TARGET_LAG (Snowflake manages) |
| Error handling | Custom (SUSPEND_TASK_AFTER_NUM_FAILURES) | Managed by Snowflake |
| Flexibility | Full control (conditionals, procedures) | SQL-only transformations |
| Orchestration | You build the DAG with AFTER clause | Chain dynamic tables (auto-DAG) |
| Refresh model | You consume stream in DML | Incremental or full (automatic) |

**RULE:** Need control (error handling, conditionals, procedures) = streams + tasks. Need simplicity (declarative SQL) = dynamic tables.
**The trap:** Both achieve incremental pipelines. The question will hint at "simple SQL transformations" (dynamic tables) or "complex logic, error handling" (streams + tasks).

### UDFs vs Stored Procedures
| Aspect | UDF | Stored Procedure |
|---|---|---|
| Invocation | In SQL expressions (SELECT, WHERE) | CALL statement |
| Return | Value(s) used in query | Single value or table |
| DML | Cannot perform DML | Can perform DML, DDL, any SQL |
| Side effects | None (pure function) | Can modify data, create objects |
| Use case | Reusable transformation logic | Procedural ETL, admin operations |

**RULE:** If it goes in a SELECT -> UDF. If it is called standalone to do work -> stored procedure.
**The trap:** Both can be written in Python/Java/SQL. The differentiator is invocation context and side effects.

### Standard Stream vs Append-only Stream
| Aspect | Standard Stream | Append-only Stream |
|---|---|---|
| Captures | INSERT, UPDATE, DELETE | INSERT only |
| Update representation | DELETE + INSERT pair | Ignored |
| Delete capture | Yes | No |
| Best for | Full CDC (all changes) | Insert-heavy tables (logs, events) |
| Overhead | Higher (tracks all DML) | Lower (only inserts) |

**RULE:** Need full CDC (updates + deletes) = standard stream. Only inserts matter = append-only stream.
**The trap:** Both capture inserts. The difference is whether updates and deletes matter for your pipeline.

### FLATTEN vs PIVOT
| Aspect | FLATTEN | PIVOT |
|---|---|---|
| Input | Semi-structured (VARIANT/ARRAY/OBJECT) | Relational rows |
| Output | Rows from nested structures | Columns from row values |
| Direction | Nested -> flat (normalize) | Tall -> wide (denormalize) |
| Use case | JSON arrays to rows | Category values to columns |

**RULE:** JSON/array to rows = FLATTEN. Row values to column headers = PIVOT.
**The trap:** Both reshape data but in opposite directions and from different input types.

### Caller's Rights vs Owner's Rights (Stored Procedures)
| Aspect | Caller's Rights | Owner's Rights |
|---|---|---|
| Privileges used | Calling role's privileges | Owning role's privileges |
| Default | Yes (EXECUTE AS CALLER) | No (must specify EXECUTE AS OWNER) |
| Use case | General utility procedures | Controlled access to sensitive objects |
| Security model | Caller must have access | Caller does not need direct access |

**RULE:** Utility procedure for any role = caller's rights. Granting controlled access to protected data = owner's rights.
**The trap:** Owner's rights can be a security risk if the owning role has broad access. Only use it when callers should not have direct access to the underlying objects.

---

## FLASHCARDS -- Domain 5

**Q1:** What are the three stream types in Snowflake?
**A1:** Standard (all DML), append-only (inserts only), and insert-only (for external tables).

**Q2:** How does a stream represent an UPDATE?
**A2:** As a DELETE + INSERT pair. The DELETE row has the old values, the INSERT row has the new values. Both have METADATA$ISUPDATE = TRUE.

**Q3:** What advances a stream's offset?
**A3:** A DML statement (INSERT INTO, MERGE, etc.) that reads from the stream within a committed transaction. SELECT alone does not advance the offset.

**Q4:** What makes a stream stale?
**A4:** When the stream's offset falls outside the source table's Time Travel retention period.

**Q5:** What function checks if a stream has new data?
**A5:** SYSTEM$STREAM_HAS_DATA('stream_name'). Returns TRUE if there are unconsumed changes.

**Q6:** Are tasks created in RESUMED or SUSPENDED state?
**A6:** SUSPENDED. You must explicitly ALTER TASK ... RESUME to start them.

**Q7:** How do child tasks in a DAG get triggered?
**A7:** By their parent task's successful completion. Only the root task has a schedule. Children use the AFTER clause.

**Q8:** What is TARGET_LAG in dynamic tables?
**A8:** The maximum allowed staleness. Snowflake automatically refreshes the dynamic table to stay within this lag.

**Q9:** What does TARGET_LAG = DOWNSTREAM mean?
**A9:** The dynamic table only refreshes when a downstream dynamic table (or a query) needs it, rather than on a fixed schedule.

**Q10:** Can UDFs perform INSERT, UPDATE, or DELETE operations?
**A10:** No. UDFs are read-only transformations. Only stored procedures can perform DML.

**Q11:** How is a UDTF invoked in a query?
**A11:** In the FROM clause using TABLE(): SELECT * FROM TABLE(my_udtf(args)).

**Q12:** What is Snowpark pushdown?
**A12:** All Snowpark DataFrame transformations are translated to SQL and executed on the Snowflake warehouse, not on the client machine.

**Q13:** What does LATERAL FLATTEN do?
**A13:** It expands semi-structured data (ARRAY, OBJECT, VARIANT) into rows while correlating with the outer query row, allowing access to both the flattened elements and the parent row's columns.

**Q14:** What operations can a MERGE statement perform?
**A14:** INSERT, UPDATE, and DELETE in a single statement, based on WHEN MATCHED / WHEN NOT MATCHED conditions.

**Q15:** What is the default execution context for stored procedures?
**A15:** Caller's rights (EXECUTE AS CALLER). The procedure runs with the calling role's privileges.

**Q16:** What is the difference between a CTE and a temporary table?
**A16:** A CTE exists only within the scope of a single query (not materialized). A temporary table is a session-scoped physical table that persists for the session and can be referenced by multiple queries.

**Q17:** When should you use a sequence vs an IDENTITY column?
**A17:** Use IDENTITY (AUTOINCREMENT) for simple auto-increment primary keys on a single table. Use a sequence when you need to share the same counter across multiple tables or need explicit control (e.g., NEXTVAL in INSERT statements).

**Q18:** What is a serverless task?
**A18:** A task that uses Snowflake-managed compute (USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE) instead of a named warehouse. It scales automatically and bills per-second for actual usage.
