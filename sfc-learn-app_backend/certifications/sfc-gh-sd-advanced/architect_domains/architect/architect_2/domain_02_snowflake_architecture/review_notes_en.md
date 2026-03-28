# Domain 2: Data Architecture

> **ARA-C01 Syllabus Coverage:** Data Modeling, Object Hierarchy, Data Recovery

---

## 2.1 DATA MODELING

**Data Vault**

- Three core entity types: **Hubs** (business keys), **Links** (relationships), **Satellites** (descriptive attributes + history)
- Designed for auditability, flexibility, and parallel loading
- Hash keys enable parallel, insert-only loading
- Best for: enterprise data warehouses with many source systems, evolving schemas, audit requirements
- Downside: more complex queries, requires experienced modelers

**Exam trap:** IF YOU SEE "star schema is best for audit trails" → WRONG because Data Vault is designed for auditability.

**Star Schema**

- Central **fact table** (measures/metrics) surrounded by **dimension tables** (descriptive context)
- Denormalized dimensions = fast reads, simple joins
- Best for: BI/analytics, dashboards, known query patterns
- Downside: ETL is harder (must maintain denormalized dims), less flexible to schema changes

**Snowflake Schema**

- Like star schema but dimensions are normalized (broken into sub-dimensions)
- e.g., `product_dim` → `category_dim` → `department_dim`
- Best for: saving storage, reducing redundancy in large dimensions
- Downside: more joins = slower queries, more complex for analysts

**Exam trap:** IF YOU SEE "snowflake schema is the default recommendation for Snowflake the product" → WRONG because the naming is coincidental. Star schema is more common for analytics.

**Data Vault 2.0 in Snowflake**

- Multi-table INSERT enables **parallel loading** of hubs and satellites from a single source in one pass
- **HASH_DIFF** (not "HASH_DELTA") is used for satellite change detection -- compares hash of current payload vs. incoming payload to detect changes
- **SHA2-512 for hash keys:** minimizes collision risk in hash-based business keys compared to MD5. Preferred for enterprise-scale Data Vault implementations
- Snowflake's separation of storage and compute makes Data Vault's insert-only, parallel-load pattern highly efficient

**Exam trap:** IF YOU SEE "Data Vault replaces dimensional modeling" → WRONG because Data Vault is for the integration layer; you still build star schemas on top for consumption.

**Supported Models on the Exam**

- **Dimensional / Kimball:** star schema with conformed dimensions across business processes. Bottom-up approach -- build one business process at a time
- **Inmon / 3NF (Corporate Information Factory):** top-down enterprise data warehouse in third normal form, then build data marts. Emphasizes single source of truth
- **Data Vault:** integration layer designed for agility and auditability. Complements both Kimball and Inmon as the staging/raw layer
- Know the differences and when each applies -- the exam tests your ability to select the right model for a given scenario

**When to Use Each**

| Model | Use When... |
|---|---|
| Data Vault | Many sources, need audit trail, schema changes frequently |
| Star | Stable schema, BI-heavy, query performance is priority |
| Snowflake | Large dimensions with high redundancy, storage matters |
| Flat/OBT | Simple analytics, single source, minimal joins needed |

### Why This Matters
A media company ingests data from 20+ ad platforms. Schemas change monthly. Data Vault absorbs the changes in satellites without breaking hubs/links. The BI layer uses star schemas built on top.

### Best Practices
- Use Data Vault for the raw/integration layer, star schema for the presentation layer
- Leverage Snowflake's compute elasticity — storage savings from snowflake schema rarely justify the query complexity
- Document business keys and grain for every fact table

### Real-World Examples
- **Media conglomerate (20+ ad platforms):** Data Vault integration layer. Each ad platform (Google Ads, Meta, TikTok, programmatic DSPs) feeds into shared Hubs (Campaign, Advertiser, Impression). When a new platform is onboarded, add new Satellites -- Hubs and Links stay untouched. Star schema presentation layer on top for the media buying team's Tableau dashboards.
- **Regional grocery chain (single POS system):** Star schema directly. One fact table (`sales_transactions`) with dimensions for stores, products, dates, promotions. Stable schema, one source system, 15 analysts who need simple queries. Data Vault overhead is unjustified here -- the schema hasn't changed in 3 years.
- **Insurance company (claims + underwriting + actuarial):** Inmon 3NF enterprise data warehouse for the canonical model, then Data Vault for integrating external data sources (reinsurers, weather data, fraud detection APIs). Actuarial models consume from the 3NF layer; claims dashboards use star schemas built on top. Three modeling patterns coexisting by design.
- **Startup with one Postgres DB and 8 people:** Flat/OBT (One Big Table) for their core metrics dashboard. A single wide denormalized table with all the fields analysts need. Zero joins, zero complexity. When they grow past 30 people and add more sources, migrate to star schema or Data Vault.
- **Global bank (regulatory reporting across 40 countries):** Data Vault 2.0 with SHA2-512 hash keys. Multi-table INSERT loads Hubs and Satellites in parallel from each country's source system. HASH_DIFF on Satellites detects changes without scanning full payloads. The audit trail is built into the model -- regulators can trace any number back to its source system and load timestamp.

### Common Questions (FAQ)
**Q: Can I use star schema directly on raw data?**
A: You can, but it's fragile. Changes in source systems break the model. Better to stage/integrate first.

**Q: Does Snowflake enforce any modeling standard?**
A: No. Snowflake is schema-agnostic. You choose the model that fits your needs.

### Example Scenario Questions — Data Modeling

**Scenario:** A media conglomerate acquires 5 companies, each with different source systems (SAP, Salesforce, custom APIs, flat files). Schemas change frequently due to ongoing integrations. The CFO needs a unified financial reporting layer for quarterly earnings. What data modeling approach should the architect recommend?
**Answer:** Use Data Vault for the integration/raw layer. Hubs capture core business entities (customer, account, transaction) via hash keys, Links capture relationships, and Satellites absorb schema changes without breaking existing structures. Each acquired company's data feeds into the same Hub/Link structure with separate Satellites tracking the source history. On top of the Data Vault layer, build star schemas for the presentation/consumption layer — the CFO's reporting team queries denormalized fact and dimension tables optimized for BI dashboards. This two-layer approach absorbs ongoing schema changes in the Data Vault while delivering stable, fast analytics in the star layer.

**Scenario:** A startup with a single Postgres source and 10 analysts wants fast dashboards. They have a small team with no Data Vault experience. The data schema is stable and changes rarely. What modeling approach fits best?
**Answer:** Star schema directly on the curated/presentation layer. With a single stable source, the complexity of Data Vault is unnecessary overhead. Build fact tables for core business events (orders, sessions, payments) surrounded by denormalized dimension tables (customers, products, dates). Star schema provides the simplest joins for BI tools like Tableau or Looker. Since Snowflake's elastic compute handles joins efficiently, the query performance benefits of denormalized dimensions outweigh the minimal storage savings of a normalized snowflake schema.

---

## 2.2 OBJECT HIERARCHY

**Top-Down Structure**

```
Organization
  └── Account
        └── Database
              └── Schema
                    ├── Tables (permanent, transient, temporary, external, dynamic, Iceberg)
                    ├── Views (standard, secure, materialized)
                    ├── Stages (internal, external)
                    ├── File Formats
                    ├── Sequences
                    ├── Streams
                    ├── Tasks
                    ├── Pipes
                    ├── UDFs / UDTFs
                    ├── Stored Procedures
                    ├── Tags
                    └── Policies (masking, RAP, aggregation, projection)
```

**Key Points**

- Everything lives inside a `DATABASE.SCHEMA` namespace
- **Account-level objects** (do NOT live inside a database.schema namespace): warehouses, roles, databases, users, resource monitors, network policies, integrations, shares
- Stages can be table-level (`@%my_table`), schema-level (`@my_stage`), or user-level (`@~`)
- Managed access schemas: only the schema owner (or MANAGE GRANTS) can grant privileges — prevents object owners from granting access independently

**Exam trap:** IF YOU SEE "warehouses belong to a database" → WRONG because warehouses are account-level objects.

**Exam trap:** IF YOU SEE "network policies are database-level objects" → WRONG because they are account-level.

**Exam trap:** IF YOU SEE "managed access schemas prevent the schema owner from granting" → WRONG because the schema owner CAN still grant in managed access schemas — the restriction is on object owners other than the schema owner.

**ORGADMIN Capabilities and Limits**

- Can: create accounts, view account list, enable replication, rename accounts, manage organization-level settings
- **CANNOT change an account's edition** -- only Snowflake Support can change editions (Standard to Enterprise, etc.)
- **CANNOT delete the last account** in the organization
- ORGADMIN is an organization-level role, separate from ACCOUNTADMIN

**Exam trap:** IF YOU SEE "ORGADMIN can change an account's edition" → WRONG because only Snowflake Support can change editions.

**Identifier Case Sensitivity**

- Object names are **case-insensitive by default** and stored as UPPERCASE internally
- Double-quoting makes names case-sensitive: `"MyTable"` != `MYTABLE`
- Once created with double quotes, you must ALWAYS use double quotes to reference it
- The **`identifier()`** function resolves session variables or string expressions to table/column names in dynamic SQL: `SELECT * FROM identifier($my_table_var)`

**Context Functions**

- Valid: `CURRENT_REGION()`, `CURRENT_SESSION()`, `CURRENT_CLIENT()`, `CURRENT_ROLE()`, `CURRENT_WAREHOUSE()`, `CURRENT_DATABASE()`, `CURRENT_SCHEMA()`, `CURRENT_ACCOUNT()`
- **NOT valid / do not exist:** `CURRENT_WORKSHEET()`, `CURRENT_CLOUD_INFRASTRUCTURE()` -- these are exam distractors

**Exam trap:** IF YOU SEE "CURRENT_WORKSHEET() returns the active worksheet name" → WRONG because CURRENT_WORKSHEET() does not exist as a Snowflake context function.

### Why This Matters
A data platform team needs to prevent individual table owners from granting SELECT to random roles. Managed access schemas centralize grant control.

### Best Practices
- Use managed access schemas in production
- Organize schemas by domain or data layer (raw, curated, presentation)
- Name objects consistently: `<domain>_<entity>_<suffix>` (e.g., `sales_orders_fact`)
- Keep account-level objects (warehouses, roles) well-documented

### Real-World Examples
- **Enterprise data platform (3 environments):** One database per layer: `RAW_DB`, `CURATED_DB`, `PRESENTATION_DB`. Each with schemas per domain (`SALES`, `MARKETING`, `FINANCE`). Managed access schemas on CURATED and PRESENTATION so only the platform team controls grants. RAW uses regular schemas because data engineers need flexibility during development.
- **Multi-tenant SaaS company:** One schema per customer inside a shared database: `APP_DB.TENANT_001`, `APP_DB.TENANT_002`. Row access policies for cross-tenant isolation. Warehouses are account-level, so each customer tier gets a dedicated warehouse (SMALL for free tier, LARGE for enterprise tier) without any schema changes.
- **Analytics consultancy (many clients, shared Snowflake account):** Naming convention enforced: `<client>_<layer>_<entity>` (e.g., `acme_raw_orders`). Double-quoted identifiers explicitly banned in coding standards -- a new analyst once created `"MyTable"` and nobody could query it without quotes. Account-level network policies restrict access to the consultancy's VPN IPs only.
- **Data mesh organization (domain ownership):** Each domain team owns their database (`MARKETING_DB`, `PRODUCT_DB`, `FINANCE_DB`). SYSADMIN owns all databases (inherited via role hierarchy). Domain teams get custom admin roles (`MARKETING_ADMIN`) granted to SYSADMIN. Context functions like `CURRENT_DATABASE()` and `CURRENT_SCHEMA()` used in dynamic SQL for domain-agnostic ETL frameworks.
- **Regulated healthcare platform:** `INFORMATION_SCHEMA` for real-time monitoring of active queries and locks during business hours. `ACCOUNT_USAGE.QUERY_HISTORY` for the weekly compliance report (365-day retention). Both views serve different audiences -- ops team uses real-time, compliance team uses historical.

### Common Questions (FAQ)
**Q: What's the difference between `@~` and `@%table`?**
A: `@~` is the user stage (one per user). `@%table` is the table stage (one per table). Both are internal, but scoped differently.

**Q: Can I have a schema without a database?**
A: No. Schemas always live inside a database.

### Example Scenario Questions — Object Hierarchy

**Scenario:** A production data platform has 200 tables owned by different teams (marketing, finance, engineering). The security team discovers that individual table owners have been granting SELECT on their tables to unapproved roles, bypassing the central governance model. How should the architect prevent this?
**Answer:** Convert production schemas to managed access schemas using `ALTER SCHEMA ... ENABLE MANAGED ACCESS`. In a managed access schema, only the schema owner or roles with the MANAGE GRANTS privilege can issue GRANT statements on objects within the schema. Individual table owners lose the ability to grant access independently. This centralizes privilege management without requiring any changes to the object ownership model or existing data pipelines.

**Scenario:** An architect is designing the schema layout for a new analytics platform. They need separate layers for raw ingestion, cleaned/curated data, and presentation-ready datasets. Some objects (warehouses, resource monitors, network policies) need to be shared across all layers. How should this be organized?
**Answer:** Create a single database (or one per domain) with three schemas: `RAW`, `CURATED`, and `PRESENTATION`. Each schema represents a data layer with its own access controls. Warehouses, resource monitors, network policies, users, and roles are account-level objects — they exist outside the database hierarchy and are shared across all schemas automatically. Use managed access schemas for `CURATED` and `PRESENTATION` to enforce centralized grant control. Name objects consistently with domain prefixes (e.g., `sales_orders_fact`) for discoverability.

### INFORMATION_SCHEMA vs ACCOUNT_USAGE

| | INFORMATION_SCHEMA | ACCOUNT_USAGE (SNOWFLAKE db) |
|---|---|---|
| **Latency** | Real-time | 2-3 hour delay |
| **Retention** | 7-14 days (varies by view) | Up to **365 days** |
| **Scope** | Current database only | Entire account |
| **Access** | Any role with database access | ACCOUNTADMIN (or granted) |
| **Best for** | "What's happening NOW" -- active queries, current locks | Historical analysis, auditing, compliance |

- For **recent or ongoing events** (e.g., detecting a credential stuffing attack, checking active queries): use INFORMATION_SCHEMA for real-time data
- For **historical analysis** (e.g., query cost trends over 6 months, login audit for compliance): use ACCOUNT_USAGE views
- Key ACCOUNT_USAGE views: `QUERY_HISTORY`, `LOGIN_HISTORY`, `WAREHOUSE_METERING_HISTORY`, `STORAGE_USAGE`, `ACCESS_HISTORY`

---

## 2.3 TABLE TYPES & VIEWS

**Table Types**

| Type | Time Travel | Fail-safe | Persists After Session | Cloneable |
|---|---|---|---|---|
| **Permanent** | 0-90 days (Enterprise) | 7 days | Yes | Yes |
| **Transient** | 0-1 day | None | Yes | Yes |
| **Temporary** | 0-1 day | None | No (session-scoped) | Yes (within session) |
| **External** | No | No | Yes (metadata only) | No |
| **Dynamic** | 0-90 days | 7 days | Yes | No |

- **Transient:** use for staging/ETL tables where you don't need Fail-safe (saves storage cost)

**Exam trap:** IF YOU SEE "transient tables have 7 days of Fail-safe" → WRONG because transient tables have zero Fail-safe.

- **Temporary:** use for session-scoped intermediate results

**Exam trap:** IF YOU SEE "temporary tables persist after the session ends" → WRONG because they are dropped when the session ends.

- **External:** metadata layer over files in external storage — read-only

**Exam trap:** IF YOU SEE "external tables support DML" → WRONG because external tables are read-only.

- **Dynamic:** automatically refreshed based on a query and target lag

**Transient Database Inheritance**

- Creating a **transient database** makes ALL child schemas and tables transient by default -- you cannot create permanent tables inside a transient database
- `DATA_RETENTION_TIME_IN_DAYS` on transient schemas/tables is limited to **0 or 1 day** (cannot set higher even on Enterprise edition)
- This is a common cost-optimization pattern for staging/dev environments

**Column and Type Details**

- **ALTER column to NOT NULL:** returns an error if the column already contains NULL values. You must clean (UPDATE) the data first, then ALTER
- **VARCHAR aliases:** STRING, TEXT, CHAR are all aliases for VARCHAR in Snowflake. They all become VARCHAR internally regardless of which keyword you use

**Iceberg Tables**

- **Managed (Snowflake-managed):** Snowflake manages the Iceberg metadata/catalog
  - Full DML support (INSERT, UPDATE, DELETE, MERGE)
  - Snowflake handles compaction, snapshot management
  - **Requires an external volume** — data is stored on the customer's cloud storage (S3/Azure/GCS), NOT in Snowflake-managed storage. Snowflake manages the Iceberg metadata and catalog, but the data files reside on the customer's external volume
- **Unmanaged (externally-managed / catalog-linked):** external catalog (AWS Glue, Polaris) manages metadata
  - Read-only from Snowflake (or limited write depending on catalog)
  - Snowflake reads Iceberg metadata to query data
  - Use for multi-engine access (Spark + Snowflake on same data)

**Hybrid Tables**

- Designed for transactional (OLTP) workloads within Snowflake
- Support fast single-row lookups, indexes, and referential integrity (PRIMARY KEY, FOREIGN KEY, UNIQUE enforced)
- Stored in a row-oriented format for low-latency point reads
- Use case: operational data that also needs to be joined with analytical data

**Exam trap:** IF YOU SEE "hybrid tables use columnar storage" → WRONG because they use row-oriented storage for fast point lookups.

**View Types**

| Type | Materialized? | Secure? | Notes |
|---|---|---|---|
| Standard view | No | No | Just a saved query |
| Secure view | No | Yes | Hides definition, optimizer fence |
| Materialized view | Yes | No | Pre-computed, auto-maintained |
| Secure materialized view | Yes | Yes | Both benefits |

- **Secure views:** query definition hidden from consumers, optimizer cannot push predicates past the view boundary
- **Materialized views:** best for expensive aggregations on large, infrequently-changing data
- **MV limitations (complete list):** no joins, no UDFs, no subqueries, no context functions (CURRENT_ROLE, etc.), no HAVING clause, no UNION, no window functions with ORDER BY. **Single base table only**
- **MV auto-rewrite behavior:** even when a query matches the MV definition exactly, the optimizer **may choose the base table instead** if the base table is well-clustered and can efficiently prune. MV auto-rewrite is an optimizer decision, NOT guaranteed -- it depends on cost estimation

**Exam trap:** IF YOU SEE "materialized views support joins" → WRONG because MV definitions cannot include joins.

### Why This Matters
A data marketplace shares data via secure views — consumers cannot see the underlying query logic or bypass row-level security.

### Best Practices
- Use transient tables for staging data (avoid unnecessary Fail-safe costs)
- Use dynamic tables instead of complex task/stream pipelines where possible
- Use secure views for all shared objects
- Consider Iceberg managed tables when you need open-format interoperability

### Real-World Examples
- **E-commerce platform (50 TB staging data):** All ETL staging tables are transient. The pipeline recreates them every 4 hours. Zero Fail-safe saves ~350 TB/year of storage costs (50 TB x 7 days Fail-safe). Production fact/dimension tables remain permanent with 90-day Time Travel for audit recovery.
- **ML platform (Spark + Snowflake):** Feature store uses managed Iceberg tables on S3. Data engineers write features from Snowflake (full DML). Data scientists read the same Iceberg files from Spark for model training. One copy of data, two engines. Before Iceberg, they maintained duplicate Parquet exports -- 200 TB of wasted storage.
- **Fintech app (real-time account lookups):** Hybrid tables for the `user_accounts` table -- primary key on `account_id`, foreign key to `customers`. The app does single-row lookups by account ID in <10ms (row-oriented storage). Same table is joined with analytical fact tables for monthly reporting using regular columnar queries.
- **Data marketplace provider:** All shared datasets exposed via secure materialized views for expensive aggregations (daily summary stats) and secure views for row-level filtered data. Standard views are never used in shares -- they expose the SQL definition. The provider tested consumer visibility using `SIMULATED_DATA_SHARING_CONSUMER` before publishing.
- **IoT platform (sensor data, 1B rows/day):** Search Optimization Service on the `device_id` and `sensor_type` columns for point-lookup queries. Dynamic tables replace the old stream+task pipeline for hourly rollups. External tables for historical cold data in S3 that's rarely queried but must remain accessible.

### Semi-Structured Data

**VARIANT Column Access**

- Colon notation: `col:key` or bracket notation: `col['key']`
- **Column names** are case-insensitive (standard Snowflake behavior)
- **JSON keys within VARIANT are CASE-SENSITIVE:** `col:Name` != `col:name` -- this is a frequent exam trap
- Nested access: `col:address.city` or `col:address['city']`

**Exam trap:** IF YOU SEE "JSON keys in VARIANT are case-insensitive" → WRONG because while Snowflake column names are case-insensitive, JSON keys within VARIANT are CASE-SENSITIVE.

**JSON null vs SQL NULL**

- JSON `null` string values stored in VARIANT degrade query performance because the optimizer cannot skip them during pruning
- Use **`STRIP_NULL_VALUE = TRUE`** in file format options to convert JSON null values to SQL NULLs during ingestion
- SQL NULLs are handled efficiently by Snowflake's micro-partition metadata

**OBJECT_CONSTRUCT Functions**

- `OBJECT_CONSTRUCT(*)` builds a JSON object from all columns of a table row -- useful for converting relational rows to JSON
- `OBJECT_CONSTRUCT('key1', val1, 'key2', val2)` builds from explicit key-value pairs
- **`OBJECT_CONSTRUCT_KEEP_NULL`** preserves null values in the output (by default, OBJECT_CONSTRUCT omits keys with NULL values)

**INFER_SCHEMA + USING TEMPLATE**

- Auto-create tables from staged file metadata (Parquet, Avro, ORC)
- `SELECT * FROM TABLE(INFER_SCHEMA(LOCATION => '@my_stage', FILE_FORMAT => 'my_format'))` detects column names and types
- `CREATE TABLE my_table USING TEMPLATE (SELECT ... FROM TABLE(INFER_SCHEMA(...)))` generates the DDL automatically
- Eliminates manual DDL authoring for wide tables with many columns

### Search Optimization Service (SOS)

- Improves performance of **selective point-lookup queries** (equality, IN, LIKE, geo) on large tables
- Enabled per table: `ALTER TABLE t ADD SEARCH OPTIMIZATION`
- Can target specific columns: `ALTER TABLE t ADD SEARCH OPTIMIZATION ON EQUALITY(col1), SUBSTRING(col2)`
- **ADD SEARCH OPTIMIZATION is additive:** subsequent `ALTER TABLE ADD SEARCH OPTIMIZATION ON ...` commands **extend** the existing config, they do NOT replace it
- **SOS limitations:** NOT supported on external tables, materialized views, casts on table columns (except fixed-point to string), or analytical expressions
- SOS is a **serverless** feature -- Snowflake manages the compute for building and maintaining the search access paths
- On **Standard edition** (where SOS and MV are not available), partition external tables by folder structure to improve query performance as a workaround

**Exam trap:** IF YOU SEE "ADD SEARCH OPTIMIZATION replaces existing config" → WRONG because it is additive -- each new ALTER ADD extends the search optimization, it does not replace.

### Common Questions (FAQ)
**Q: Can I convert a permanent table to transient?**
A: Not directly. You must create a new transient table and copy data (or use CTAS).

**Q: Do secure views have a performance cost?**
A: Yes. The optimizer fence prevents some optimizations, so secure views can be slower than standard views.

**Q: When would I use a managed Iceberg table vs a regular Snowflake table?**
A: When you need the data to be in open Iceberg format for multi-engine access while still having full Snowflake DML.

### Example Scenario Questions — Table Types & Views

**Scenario:** A data platform team runs multi-step ETL pipelines that produce intermediate staging tables. These tables are recreated every run and don't need historical recovery. Storage costs are a concern because the staging data is 50 TB and growing. What table types should the architect use?
**Answer:** Use transient tables for all staging/intermediate tables. Transient tables have zero Fail-safe storage (saving 7 days worth of historical data storage per table) and a maximum of 1-day Time Travel. Since these tables are recreated every run, the 7-day Fail-safe of permanent tables provides no value but adds significant storage cost at 50 TB scale. For truly session-scoped scratch work within a single ETL step, temporary tables are even lighter (dropped when the session ends).

**Scenario:** A company runs both Snowflake and Apache Spark. The data science team uses Spark for ML training on feature tables, while the analytics team queries the same tables from Snowflake. Currently, data is duplicated — a Snowflake copy and a Parquet copy in S3. How should the architect eliminate the duplication?
**Answer:** Migrate the feature tables to managed Iceberg tables with an external volume pointing to S3. Snowflake manages the table lifecycle (writes, compaction, snapshots) and produces Iceberg-formatted data files and metadata in S3. Spark reads the same Iceberg metadata and data files directly — no duplication. Snowflake retains full DML (INSERT, UPDATE, DELETE, MERGE) support, Time Travel, and clustering. The data science team accesses the same data from Spark without any data movement or copy.

**Scenario:** A data marketplace needs to share pre-aggregated sales metrics with external consumers. The underlying query logic is proprietary. Consumers should not see the SQL definition or be able to bypass row-level security through optimizer tricks. What view type should the architect use?
**Answer:** Use secure views (or secure materialized views for expensive aggregations). Secure views hide the view definition from consumers and impose an optimizer fence that prevents predicate pushdown past the view boundary — this stops consumers from inferring hidden data through clever filtering. For the data marketplace use case, all shared objects should use secure views as a baseline. Note that secure views have a minor performance cost due to the optimizer fence, but this is an acceptable trade-off for data protection in a sharing context.

---

## 2.4 DATA RECOVERY

**Time Travel**

- Query or restore data as it existed at any point within the retention period
- Methods: `AT` / `BEFORE` with `TIMESTAMP`, `OFFSET`, or `STATEMENT` (query ID)
- Retention: 0-1 day (Standard), 0-90 days (Enterprise+)
- Works on tables, schemas, and databases
- Costs storage for changed/deleted data

**Exam trap:** IF YOU SEE "Time Travel retention can be set to 90 days on Standard edition" → WRONG because Standard edition max is 1 day.

**Time Travel Retention Inheritance on DROP**

- When a **DATABASE** is dropped, its retention period overrides all child schema/table retention settings -- the database-level retention applies to everything inside
- When only a **SCHEMA** is dropped, the schema's own retention applies to its children
- When only a **TABLE** is dropped, the table's own retention applies

**Fail-safe**

- 7-day period AFTER Time Travel expires
- NOT user-accessible — only Snowflake Support can recover data
- Only for permanent tables (not transient, temporary, or external)
- Exists as a last resort for catastrophic scenarios

**Exam trap:** IF YOU SEE "Fail-safe data can be recovered by users via SQL" → WRONG because only Snowflake Support can recover Fail-safe data.

**UNDROP**

- Restores the most recently dropped object: `UNDROP TABLE`, `UNDROP SCHEMA`, `UNDROP DATABASE`
- Uses Time Travel data under the hood
- If you drop and recreate a same-named object, then drop the new one, UNDROP restores the **most recently dropped version** (the new one). To recover the original dropped table, you must first rename the current table, then UNDROP will restore the original

**Exam trap:** IF YOU SEE "UNDROP works on transient tables after Fail-safe" → WRONG because transient tables have no Fail-safe, and UNDROP only works during the Time Travel period.

**Zero-Copy Cloning for Backup**

- `CREATE TABLE backup_table CLONE source_table`
- No additional storage until data diverges
- Clones inherit Time Travel settings from source
- Supports cloning databases and schemas (recursive clone of all children)
- Clones are independent — changes to clone don't affect source

**Exam trap:** IF YOU SEE "cloning a table doubles storage immediately" → WRONG because cloning is zero-copy; storage only grows as data diverges.

**Cloning Details and Edge Cases**

- **COPY GRANTS during cloning:** `CREATE TABLE ... CLONE ... COPY GRANTS` copies grants to the clone. Without `COPY GRANTS`, the clone gets default grants only. Supported for tables and views, but NOT for all object types
- **Cloned tasks are always SUSPENDED:** after cloning a database or schema, ALL tasks in the clone start in SUSPENDED state. You must manually `ALTER TASK ... RESUME` each one
- **Cloning scope for pipes:** only pipes referencing **external stages** are cloned. Pipes referencing internal stages are NOT cloned
- **Unconsumed stream records after clone:** stream records that existed before the clone are inaccessible in the cloned copy. The clone's stream starts fresh from the clone point
- **Cloning is NOT possible cross-account:** use replication or data sharing instead. Zero-copy cloning is intra-account only

**Exam trap:** IF YOU SEE "cloned tasks resume automatically" → WRONG because all tasks in a cloned database/schema are SUSPENDED and must be manually resumed.

**Exam trap:** IF YOU SEE "zero-copy cloning works cross-account" → WRONG because cloning is intra-account only. Use replication or data sharing for cross-account copies.

**Replication for DR**

- Database replication: async copy of database to another account/region
- Account replication: replicate users, roles, warehouses, policies
- Failover groups: bundle of replicated objects that can failover together
- RPO depends on replication frequency; RTO is the time to promote secondary

### Why This Matters
An analyst accidentally runs `DELETE FROM production_table`. With 90-day Time Travel, the data team restores the table to 5 minutes before the delete. No backup tapes, no downtime.

### Best Practices
- Set 90-day Time Travel on critical production tables (Enterprise required)
- Use transient tables for staging to avoid Fail-safe storage costs
- Clone production to dev/test instead of copying data
- Set up replication for mission-critical databases to a secondary region
- Test your recovery procedures regularly

### Real-World Examples
- **Retail company (Black Friday incident):** A deploy script ran `TRUNCATE TABLE orders` on production instead of staging. Discovered 45 minutes later. Recovery: `CREATE TABLE orders_restored CLONE orders BEFORE(STATEMENT => '<truncate_query_id>')`, verify row counts, then `ALTER TABLE orders SWAP WITH orders_restored`. Zero downtime, full recovery. After this, the team set `DATA_RETENTION_TIME_IN_DAYS = 90` on all production tables and `MIN_DATA_RETENTION_TIME_IN_DAYS = 7` at account level.
- **SaaS platform (5 dev teams, 200 TB production):** Each team gets a fresh clone every morning: `CREATE DATABASE dev_team_1 CLONE production`. Zero additional storage until devs make changes. Clones are dropped and recreated daily. Before cloning, they were running CTAS into separate databases -- 1 PB of wasted storage.
- **Healthcare analytics (HIPAA audit trail):** 90-day Time Travel on all PHI tables. When a compliance officer asks "what did patient record X look like on March 15th?", the team queries `SELECT * FROM patients AT(TIMESTAMP => '2025-03-15 00:00:00'::TIMESTAMP)`. No custom audit tables needed.
- **Global fintech (multi-region DR):** Failover group with all critical databases + account objects (users, roles, network policies) replicated to a secondary in EU-West every 10 minutes. Client redirect via Connection object. During quarterly DR drills, they promote the secondary and verify that apps auto-redirect within 3 minutes. RPO = 10 min, RTO = 3 min.
- **Data engineering team (cloning gotcha):** Cloned the production database for testing. All tasks in the clone were SUSPENDED (expected). But they forgot that streams in the clone start fresh -- unconsumed records from before the clone were lost. Lesson: after cloning, always verify stream offsets and manually resume tasks.

### Common Questions (FAQ)
**Q: If I set Time Travel to 0, can I still UNDROP?**
A: No. UNDROP relies on Time Travel data. With 0 retention, the data is gone immediately.

**Q: Does cloning copy grants?**
A: When cloning databases/schemas, grants on child objects are copied. Table-level clones do not copy grants by default (unless you use `COPY GRANTS`).

**Q: Can I replicate to a different cloud provider?**
A: Yes. Cross-cloud replication is supported (e.g., AWS to Azure), but both accounts must be in the same Organization.

### Example Scenario Questions — Data Recovery

**Scenario:** A junior engineer accidentally runs `TRUNCATE TABLE customers` on the production database containing 500M rows. The team discovers the mistake 3 hours later. The account is on Enterprise edition with the default 1-day Time Travel retention. How should the architect recover the data?
**Answer:** Use Time Travel to restore the data. Since only 3 hours have passed and the table has at least 1-day Time Travel, the data is fully recoverable. Option 1: `CREATE TABLE customers_restored CLONE customers BEFORE(STATEMENT => '<truncate_query_id>')` to create a point-in-time clone, then swap the tables. Option 2: `INSERT INTO customers SELECT * FROM customers BEFORE(OFFSET => -10800)` to repopulate from the 3-hour-ago snapshot. Going forward, the architect should set `DATA_RETENTION_TIME_IN_DAYS = 90` on all critical production tables (Enterprise edition supports up to 90 days) and set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level to prevent anyone from reducing it.

**Scenario:** A data platform team needs to provide fresh copies of the 200 TB production database to 5 development teams daily for testing. Full data copies would cost 1 PB of storage. How should the architect handle this efficiently?
**Answer:** Use zero-copy cloning: `CREATE DATABASE dev_team_1 CLONE production`. Each clone initially shares all underlying micro-partitions with production — zero additional storage. Storage only grows as dev teams make changes to their cloned data. Each morning, drop the previous day's clones and create fresh ones. Clones inherit Time Travel settings from the source and are fully independent — dev team changes never affect production. This provides 5 teams with full production data at near-zero storage cost.

---

## 2.5 REPLICATION & FAILOVER

**Database Replication**

- Replicate a database from primary account to one or more secondary accounts
- Secondary is read-only until promoted (or until failover)
- Replication is asynchronous — data freshness depends on refresh schedule
- Initial replication copies all data; subsequent are incremental (only changes)

**Exam trap:** IF YOU SEE "secondary databases are read-write" → WRONG because secondary databases are read-only until promoted to primary.

**Exam trap:** IF YOU SEE "replication requires the same cloud provider" → WRONG because cross-cloud replication is supported.

**Account Replication**

- Replicate account-level objects: users, roles, grants, warehouses, network policies, parameters
- Essential for true DR — database replication alone doesn't cover access control
- Combined with database replication in failover groups

**Failover Groups**

- Named collection of objects that can fail over as a unit
- Types of objects: databases, shares, users, roles, warehouses, integrations, network policies
- `PRIMARY` → `SECONDARY` promotion via `ALTER FAILOVER GROUP ... PRIMARY`
- Only one primary at a time per failover group

**Exam trap:** IF YOU SEE "failover is automatic" → WRONG because failover must be manually initiated (Snowflake does not auto-failover).

**Cross-Region / Cross-Cloud**

- Replication works across regions AND across cloud providers
- Both accounts must be in the same Snowflake Organization
- Consider data residency regulations when replicating across regions
- Replication costs: data transfer + compute for refresh
- **DR across cloud providers requires multiple accounts** -- you cannot do DR within a single account across cloud providers

**Replication Billing and Behavior**

- The **target (secondary) account** is charged for BOTH data transfer AND compute charges during replication refresh -- not the source
- **External tables are SKIPPED** during database replication -- they are not replicated (external table metadata references external storage that may not be accessible from the target account)
- **`SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER`** is used to enable replication across accounts at the organization level
- **Time Travel on secondary databases:** only provides access to versions from hourly refresh snapshots, NOT continuous point-in-time recovery like on the primary

**Exam trap:** IF YOU SEE "the source account pays for replication compute" → WRONG because the target (secondary) account is charged for both data transfer and compute during replication refresh.

**Exam trap:** IF YOU SEE "external tables are replicated with the database" → WRONG because external tables are SKIPPED during database replication.

**Replication of Shares**

- **Shares can be included in failover groups** -- when a failover group includes shares, the share definitions and grants are replicated to the secondary account
- This enables cross-region sharing: replicate the database AND the share to the consumer's region, so the share is available from the replicated account
- For **Marketplace listings**, Cross-Cloud Auto Fulfillment handles this automatically -- but for **direct shares**, you must manually include shares in failover groups or replicate and recreate them

**Client Redirect**

- Connection URLs that automatically redirect to the active primary
- Minimizes client-side changes during failover
- Uses `CONNECTION` objects: `CREATE CONNECTION`, `ALTER CONNECTION ... PRIMARY`

**Exam trap:** IF YOU SEE "client redirect works without Connection objects" → WRONG because you must create and configure Connection objects for client redirect.

### Why This Matters
A global fintech company runs primary in AWS US-East, secondary in AWS EU-West. If US-East goes down, they promote EU-West in minutes. Client redirect means apps don't need config changes.

### Best Practices
- Use failover groups (not standalone database replication) for production DR
- Include account objects in your failover group for complete recovery
- Set up client redirect to minimize failover RTO
- Monitor replication lag via `REPLICATION_GROUP_REFRESH_HISTORY`
- Test failover quarterly with real promote/failback drills

### Real-World Examples
- **Global fintech (AWS US-East primary, AWS EU-West secondary):** Failover group includes 4 databases + users, roles, grants, warehouses, network policies, integrations. Replication every 10 minutes (RPO = 10 min). Client redirect via Connection object -- JDBC apps use the Connection URL. During the annual DR drill, they promoted EU-West in 4 minutes. Zero app config changes needed. The CFO approved the replication cost after seeing the 4-minute RTO.
- **E-commerce company (incomplete DR -- what NOT to do):** Replicated only the database, not account objects. During a failover drill, the secondary had the data but nobody could log in -- no users, no roles, no network policies existed. Lesson: always use failover groups that include account-level objects, not standalone database replication.
- **Multi-cloud enterprise (AWS primary, Azure secondary):** Cross-cloud replication from AWS US-East to Azure West-Europe. Both accounts in the same Snowflake Organization. Higher data transfer costs than same-cloud replication, but the company's risk committee requires cloud-provider redundancy. They monitor `REPLICATION_GROUP_REFRESH_HISTORY` daily for lag spikes.
- **Data provider with cross-region consumers:** Primary account in US-East shares market data. A large consumer in EU wants low-latency access. The provider replicates the database to an account in EU-West, creates a share from the replica. The consumer queries from the EU replica with local latency. For Marketplace listings, Cross-Cloud Auto Fulfillment handles this automatically.
- **Insurance company (regulatory RPO = 1 hour):** Replication refresh scheduled every 15 minutes with alerting if lag exceeds 30 minutes. The secondary account is charged for both data transfer and compute. Budget: ~$2K/month for replication -- cheap insurance against a regional outage that could cost millions in claims processing delays.

### Common Questions (FAQ)
**Q: What's the difference between database replication and failover groups?**
A: Database replication covers one database. Failover groups bundle multiple databases + account objects for coordinated failover.

**Q: Is there data loss during failover?**
A: Potentially, yes. RPO = time since last successful replication refresh. Any data written after the last refresh is not on the secondary.

**Q: Can I have multiple failover groups?**
A: Yes. You can have multiple failover groups, each containing different sets of objects. Each object can only belong to one failover group.

### Example Scenario Questions — Replication & Failover

**Scenario:** A global fintech company runs its primary Snowflake account in AWS US-East-1. Regulators require that the platform can recover from a full regional outage within 5 minutes (RTO) with no more than 15 minutes of data loss (RPO). Applications connect via JDBC using a single connection URL. How should the architect design the DR architecture?
**Answer:** Set up a failover group containing all critical databases plus account-level objects (users, roles, grants, warehouses, network policies, integrations). Replicate to a secondary account in AWS EU-West-1 (or another region) within the same Organization. Schedule replication refreshes every 10-15 minutes to meet the 15-minute RPO. Configure client redirect using a Connection object — applications connect to the Connection URL, which automatically routes to the active primary. During failover, promote the secondary via `ALTER FAILOVER GROUP ... PRIMARY` and update the Connection object. Apps automatically redirect to the new primary without configuration changes, meeting the 5-minute RTO. Test failover quarterly with real promote/failback drills.

**Scenario:** A company replicates its core database to a secondary account for DR, but during a failover drill, they discover that users cannot log in to the secondary account because roles, grants, and network policies were not replicated. What did the architect miss?
**Answer:** The architect used database replication alone instead of a failover group with account replication. Database replication only copies the database and its contents — it does not replicate account-level objects like users, roles, grants, warehouses, network policies, or integrations. The correct approach is to create a failover group that includes both the databases AND account-level objects. This ensures that when the secondary is promoted, all access controls, role hierarchies, and network policies are already in place. Always include account objects in failover groups for complete DR.

**Scenario:** An organization operates on AWS for its primary workloads but wants a secondary DR site on Azure for cloud-provider redundancy. Is this possible with Snowflake replication?
**Answer:** Yes. Snowflake supports cross-cloud replication — you can replicate from an AWS account to an Azure account (or GCP) as long as both accounts are in the same Snowflake Organization. The failover group mechanism works identically across cloud providers. However, the architect should account for cross-cloud data transfer costs, potential latency differences, and data residency regulations that may restrict which regions data can be replicated to. Monitor replication lag via `REPLICATION_GROUP_REFRESH_HISTORY` to ensure RPO targets are met despite cross-cloud overhead.

---

## 2.6 DATA SHARING & MARKETPLACE

**Core Sharing Concepts**

- A **share** is a named Snowflake object that encapsulates databases, schemas, tables, and secure views for sharing with other accounts
- Shares are **read-only** for consumers -- no DML (INSERT, UPDATE, DELETE) on shared objects
- A share can include objects from **only one database** (use secure views to join data from multiple databases into the share)
- Consumers create a database from the share: `CREATE DATABASE my_db FROM SHARE provider_account.share_name`
- **Shared databases have NO:** Time Travel, cloning, PUBLIC schema, INFORMATION_SCHEMA (unless explicitly granted)
- New tables added to the provider's schema require **explicit** `GRANT SELECT ON TABLE ... TO SHARE` -- they do NOT auto-appear in the share
- `DROP SHARE` is **permanent** -- you cannot UNDROP a share; must recreate from scratch
- Consuming a share requires both **IMPORT SHARE** and **CREATE DATABASE** privileges on the consumer account

**Exam trap:** IF YOU SEE "shares can include objects from multiple databases" → WRONG because a share is limited to one database. Use secure views to consolidate data from multiple databases.

**Exam trap:** IF YOU SEE "new tables auto-appear in a share" → WRONG because the provider must explicitly GRANT SELECT on each new table to the share.

**Exam trap:** IF YOU SEE "you can UNDROP a share" → WRONG because DROP SHARE is permanent -- no recovery possible.

**Cross-Region / Cross-Cloud Sharing**

- Direct sharing only works within the **same region on the same cloud provider**
- For cross-region or cross-cloud sharing, the provider must: (1) replicate the database to an account in the consumer's region, (2) create the share from the replicated database
- **Cross-Cloud Auto Fulfillment** (for Marketplace): automatically replicates listings to consumer regions -- the provider does not manually manage replication for Marketplace listings

**Exam trap:** IF YOU SEE "direct sharing works cross-region" → WRONG because cross-region sharing requires database replication first.

**Reader Accounts**

- For consumers who do **NOT** have a Snowflake account
- Provider creates and manages the reader account: `CREATE MANAGED ACCOUNT`
- Reader accounts are paid for by the **provider** (both compute and storage)
- Limited functionality: cannot create databases, shares, or integrations
- Best for: sharing with non-Snowflake customers, small partners, trial access
- Reader accounts can only consume data from the provider that created them

**Exam trap:** IF YOU SEE "reader accounts are free for the provider" → WRONG because the provider pays for reader account compute and storage.

**Data Exchange & Marketplace**

- **Data Exchange:** private marketplace for a curated group of accounts (e.g., within an organization). Setup requires ACCOUNTADMIN
- **Snowflake Marketplace:** public marketplace for any Snowflake account to discover and consume listings
- Listings can be **free or paid** (monetized)
- Cross-Cloud Auto Fulfillment enables listings to serve consumers in any region without manual replication
- Providers can publish **Standard** listings (free, instant access) or **Personalized** listings (requires approval)

**What Can Be Shared (Complete List)**

| Shareable | NOT Shareable |
|---|---|
| Tables (permanent, transient, dynamic, external, Iceberg) | Warehouses |
| Secure views | Stages (internal or external) |
| Secure materialized views | Pipes |
| Secure UDFs | Stored procedures |
| Secure UDTFs | Standard (non-secure) views |
| Databases, schemas (via USAGE grant) | Tasks, streams, sequences |

- **Standard views CANNOT be shared** -- only secure views/MVs are compatible with Data Sharing
- **Stored procedures CANNOT be shared** -- but secure UDFs CAN be shared
- Sharing requires: `GRANT USAGE ON DATABASE`, `GRANT USAGE ON SCHEMA`, `GRANT SELECT ON TABLE/VIEW` to the share

**Exam trap:** IF YOU SEE "stored procedures can be shared" → WRONG because only secure UDFs/UDTFs can be shared, not stored procedures.

**Billing Model**

- **Provider pays for:** storage of the shared data (data lives in provider's account)
- **Consumer pays for:** compute (warehouse costs to query shared data)
- **No data movement** -- consumers query the provider's data in place via metadata pointers
- **Reader accounts exception:** provider pays for BOTH storage AND compute (provider manages the reader account's warehouse)
- This zero-copy architecture is what makes Snowflake sharing fundamentally different from ETL-based data delivery

**Exam trap:** IF YOU SEE "provider pays for compute when consumers query shared data" → WRONG because the consumer pays for their own compute (warehouse). Provider only pays storage. Exception: reader accounts where provider pays both.

**SIMULATED_DATA_SHARING_CONSUMER Parameter**

- Session parameter to **test what consumers will see** in secure views BEFORE actually sharing
- Syntax: `ALTER SESSION SET SIMULATED_DATA_SHARING_CONSUMER = '<consumer_account_name>'`
- After setting, query the secure view -- results reflect what that consumer would see (respecting `CURRENT_ACCOUNT()` logic in the view)
- Works with: **secure views** and **secure materialized views**
- Does **NOT** work with: **secure UDFs** (cannot simulate UDF behavior for consumers)
- Essential validation step before publishing shares to ensure row-level/column-level filtering is correct

**Exam trap:** IF YOU SEE "SIMULATED_DATA_SHARING_CONSUMER works with secure UDFs" → WRONG because it only works with secure views and secure materialized views, NOT secure UDFs.

**Consumer Operations on Shared Databases**

- Consumers **CAN:** query shared objects, join shared objects with local tables/views, grant access to shared DB to local roles
- Consumers **CANNOT:** perform DML (INSERT/UPDATE/DELETE), clone shared objects, re-share to other accounts, create objects inside the shared database
- Shared databases do NOT have: Time Travel, Fail-safe, PUBLIC schema, INFORMATION_SCHEMA (unless explicitly granted by provider)
- TRANSIENT and DATA_RETENTION_TIME_IN_DAYS properties do NOT apply to shared databases

**Exam trap:** IF YOU SEE "shared databases support Time Travel" → WRONG because shared databases are read-only snapshots with no Time Travel, no cloning, and no PUBLIC/INFORMATION_SCHEMA schemas.

**Exam trap:** IF YOU SEE "consumers can clone shared databases" → WRONG because shared databases are read-only -- no cloning, no DML, no re-sharing.

**Sharing Security**

- **SHARE_RESTRICTIONS:** Business Critical accounts sharing to lower-edition accounts must set `SHARE_RESTRICTIONS = FALSE` and have `OVERRIDE SHARE RESTRICTIONS` privilege
- A user with a **share-owning role** that also has the **OVERRIDE SHARE RESTRICTIONS** privilege must set the parameter when adding the lower-edition consumer account to the share
- Always use **secure views** in shares -- standard views expose query definitions to consumers
- **Database roles** are the recommended way to manage share access (portable with the database, simplifying grant management across shares)
- **CAUTION with OR REPLACE on database roles:** `CREATE OR REPLACE` on a database role that is granted to a share **drops the role from the share**. Consumers lose access until the role is re-granted. Avoid OR REPLACE for roles used in shares
- **Dynamic Data Masking in shares:** masking policies applied to tables/columns in the provider account are **enforced on shared data**. Consumers see masked values based on the policy logic (e.g., `CURRENT_ACCOUNT()`, `CURRENT_ROLE()` conditions)

**Exam trap:** IF YOU SEE "CREATE OR REPLACE on a database role is safe for shares" → WRONG because OR REPLACE drops the role from any shares it was granted to. Consumers lose access.

**Cross-Cloud Auto Fulfillment vs Disaster Recovery**

- **Auto Fulfillment** is for **Marketplace listings ONLY** -- it automatically replicates listing data to consumer regions
- Auto Fulfillment is **NOT a DR solution** -- it does not provide failover, failback, or client redirect capabilities
- For DR, use **database replication + failover groups + client redirect** (Section 2.5)
- Common exam trap: confusing Auto Fulfillment (sharing feature) with replication-based DR (availability feature)

**Exam trap:** IF YOU SEE "Cross-Cloud Auto Fulfillment provides disaster recovery" → WRONG because Auto Fulfillment is for Marketplace listing replication only, NOT for DR. Use failover groups + replication for DR.

**Sharing Unstructured Data**

- Use **scoped URLs** via `BUILD_SCOPED_FILE_URL()` for sharing file access through secure views
- Scoped URLs have a **24-hour expiration**
- Not suitable for long-term file sharing -- use pre-signed URLs or staged files for persistent access

### Why This Matters
A healthcare analytics company wants to share de-identified patient outcome data with 50 hospital partners. Some partners have Snowflake accounts, others don't. The company uses secure views in a share for Snowflake partners (zero data copy, real-time access) and reader accounts for non-Snowflake partners (provider pays compute). All shared objects use secure views to hide proprietary SQL logic.

### Best Practices
- Always use **secure views** in shares to protect query logic and enforce row-level security
- Use **database roles** for managing share access -- they travel with the database during replication
- For cross-region consumers, replicate the database first, then create the share in the target region
- Monitor share usage via `SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY`
- Use Marketplace with Cross-Cloud Auto Fulfillment for broad distribution without manual replication

### Real-World Examples
- **Pharmaceutical company (multi-partner trial data):** Shares de-identified clinical trial results with 200+ hospital partners globally. Uses secure views with `CURRENT_ACCOUNT()` filters so each hospital sees only its own patients. Cross-Cloud Auto Fulfillment distributes Marketplace listings to partners in AWS EU, Azure US, and GCP APAC without manual replication. Reader accounts serve 30 academic institutions that lack Snowflake accounts -- provider absorbs ~$800/month compute cost but gains research collaboration value.
- **Financial data vendor (monetized Marketplace):** Publishes real-time market data feeds as paid Marketplace listings. Standard listings for free delayed data (attracts leads), Personalized listings for premium real-time feeds (requires contract approval). Revenue model: consumers pay subscription + their own compute. Provider uses database roles per listing tier to manage access granularity -- avoids the OR REPLACE trap that would silently revoke consumer access.
- **Retail conglomerate (internal Data Exchange):** 12 business units share sales, inventory, and customer data through a private Data Exchange (not public Marketplace). Each BU is both provider and consumer. Secure views enforce row-level access so the luxury brand division cannot see discount outlet customer data. All shares use a single database per BU with views that join across schemas -- working around the one-database-per-share limitation.
- **Government open data program:** Publishes census, weather, and infrastructure datasets as free Marketplace listings. Uses Cross-Cloud Auto Fulfillment so any Snowflake customer worldwide gets zero-copy access. Monitors consumption via `DATA_TRANSFER_HISTORY` to justify program funding. Key architect decision: chose Marketplace over direct shares because Auto Fulfillment eliminates cross-region replication management for 5,000+ consumers.
- **SaaS analytics platform (embedded insights):** Shares aggregated benchmarking data back to customers so they can compare their metrics against industry averages. Uses reader accounts for customers on competing cloud platforms. Architect chose reader accounts over pushing data via ETL because zero-copy sharing means benchmarks update in real-time as new data arrives -- no stale extracts. Provider pays ~$2,000/month for reader compute but saves $15,000/month in ETL infrastructure and support.
- **Insurance consortium (claims data sharing):** Five insurance companies share anonymized claims data for fraud detection. Private Data Exchange with strict access controls. Each company provides data via secure views that mask policyholder PII using dynamic data masking policies. Key decision: `SIMULATED_DATA_SHARING_CONSUMER` testing before onboarding each new member -- caught a masking policy gap that would have exposed SSN data to one partner whose `CURRENT_ROLE()` wasn't in the policy whitelist.

### Common Questions (FAQ)
**Q: Can a consumer modify shared data?**
A: No. Shared objects are read-only. Consumers can create local copies (CTAS) if they need to modify data.

**Q: How do I share data from multiple databases?**
A: Create secure views in a single database that join/union data from other databases, then share that database.

**Q: What happens when the provider revokes a share?**
A: The consumer's database created from that share becomes inaccessible immediately. The consumer must drop it.

**Q: Can reader accounts access data from multiple providers?**
A: No. A reader account can only consume data from the provider that created it.

**Q: How do I validate what a consumer will see before sharing?**
A: Use `ALTER SESSION SET SIMULATED_DATA_SHARING_CONSUMER = '<account>'` then query the secure view. This simulates the consumer's perspective without actually sharing.

**Q: Can a Business Critical account share with a Standard edition consumer?**
A: Yes, but the provider must set `SHARE_RESTRICTIONS = FALSE` and have the `OVERRIDE SHARE RESTRICTIONS` privilege on the share-owning role.

**Q: What privileges does a consumer need to import a share?**
A: Both `IMPORT SHARE` (to import the share) and `CREATE DATABASE` (to create a database from it).

**Q: Who can set up a Data Exchange?**
A: Only a user with the **ACCOUNTADMIN** role can create and manage a Data Exchange, invite members, and configure sharing settings.

### Example Scenario Questions -- Data Sharing & Marketplace

**Scenario:** A financial data provider wants to monetize their market data by making it available to any Snowflake customer globally, regardless of cloud provider or region. They update data every 15 minutes and want consumers to always see the latest data without manual distribution. What approach should the architect recommend?
**Answer:** Publish the data as a paid listing on the **Snowflake Marketplace** with **Cross-Cloud Auto Fulfillment** enabled. The provider maintains the data in their primary account and publishes secure views as the listing. Cross-Cloud Auto Fulfillment automatically replicates the listing to consumer regions on demand -- the provider does not need to manually set up replication to every region. Consumers get a live, read-only view of the data (no data copy), and updates are visible as soon as the provider writes them. Use secure views to control exactly which columns and rows each consumer tier can access.

**Scenario:** A pharmaceutical company needs to share clinical trial results with 5 research partners. Three partners have Snowflake accounts (two in the same region, one in a different region). Two partners do not have Snowflake accounts. How should the architect set up sharing?
**Answer:** For the two same-region Snowflake partners: create a share with secure views and grant access directly. For the cross-region Snowflake partner: replicate the database to an account in the partner's region, then create a share from the replica. For the two non-Snowflake partners: create **reader accounts** (`CREATE MANAGED ACCOUNT`) for each. The pharmaceutical company pays for reader account compute and storage. All shared objects use secure views to hide proprietary query logic and enforce row-level filtering per partner.

---

## CONFUSING PAIRS — Data Architecture

| They ask about... | The answer is... | NOT... |
|---|---|---|
| **Star schema** vs **snowflake schema** | **Star** = denormalized dims, fewer joins, fast queries | **Snowflake schema** = normalized dims, more joins, saves storage but slower |
| **Data Vault** vs **dimensional modeling** | **Data Vault** = integration/raw layer (Hubs, Links, Satellites) | **Dimensional** = presentation/BI layer (facts + dims). They're *complementary*, not competing |
| **Hub** vs **Link** vs **Satellite** | **Hub** = business key, **Link** = relationship, **Satellite** = descriptive history | Don't confuse Hub (entity ID) with Satellite (attributes) |
| **Managed Iceberg** vs **unmanaged Iceberg** | **Managed** = Snowflake controls metadata + full DML | **Unmanaged** = external catalog (Glue, Polaris) controls metadata, read-only from Snowflake |
| **Time Travel** vs **Fail-safe** | **Time Travel** = user-accessible, 0-90 days, query/restore via SQL | **Fail-safe** = Snowflake Support only, 7 days AFTER Time Travel expires |
| **Clone** vs **replica** | **Clone** = zero-copy snapshot *within* same account, independent object | **Replica** = async copy to *another* account/region for DR |
| **Permanent** vs **transient** table | **Permanent** = full Time Travel + 7-day Fail-safe | **Transient** = max 1-day Time Travel, **zero** Fail-safe |
| **Temporary** vs **transient** table | **Temporary** = session-scoped, gone when session ends | **Transient** = persists across sessions, just no Fail-safe |
| **Secure view** vs **standard view** | **Secure** = hides definition + optimizer fence (slower) | **Standard** = visible definition, full optimizer (faster) |
| **Materialized view** vs **dynamic table** | **MV** = auto-maintained, no joins/UDFs allowed | **Dynamic table** = more flexible (joins OK), target lag based, replaces stream+task |
| **Hybrid table** vs **regular table** | **Hybrid** = row-oriented, enforced PK/FK/UNIQUE, fast point lookups (OLTP) | **Regular** = columnar, no enforced constraints (OLAP) |
| **Database replication** vs **failover group** | **DB replication** = one database copied to secondary | **Failover group** = bundle of DBs + account objects that fail over together |
| **UNDROP** vs **Time Travel AT** | **UNDROP** = restores a *dropped* object | **AT/BEFORE** = queries/restores data at a *point in time* (object still exists) |
| **Client redirect** vs **DNS failover** | **Client redirect** = Snowflake **Connection object**, auto-routes to active primary | NOT generic DNS — requires explicit Snowflake config |
| **Share** vs **clone** vs **replica** | **Share** = read-only cross-account access, no data copy | **Clone** = intra-account copy. **Replica** = cross-account async copy for DR |
| **Reader account** vs **full account** | **Reader** = provider-managed, provider-paid, limited (no shares/DBs/integrations) | **Full account** = independent Snowflake account with all capabilities |
| **Data Exchange** vs **Marketplace** | **Exchange** = private, curated group of accounts | **Marketplace** = public, any Snowflake account can discover/consume |
| **Direct sharing** vs **cross-region sharing** | **Direct** = same region + same cloud, instant | **Cross-region** = requires database replication first, then share from replica |
| **Provider cost** vs **consumer cost** (sharing) | **Provider** pays for storage (data stays in provider account) | **Consumer** pays for compute (warehouse to query shared data). Exception: reader accounts -- provider pays both |
| **Direct Share** vs **Listing** vs **Data Exchange** | **Direct Share** = point-to-point, provider→consumer, same region | **Listing** = Marketplace (public) or personalized (approval). **Exchange** = private group of accounts |
| **Cross-Cloud Auto Fulfillment** vs **DB replication** | **Auto Fulfillment** = automatic, Marketplace listings only | **DB replication** = manual setup, works for direct shares and DR -- Auto Fulfillment is NOT for DR |
| **Secure UDF** vs **stored procedure** (sharing) | **Secure UDFs** can be shared in a share | **Stored procedures** CANNOT be shared |
| **SIMULATED_DATA_SHARING_CONSUMER** vs **reader account** | **SIMULATED** = session parameter to *test/validate* what consumer sees | **Reader account** = actual managed account for non-Snowflake consumers to *access* shared data |
| **INFORMATION_SCHEMA** vs **ACCOUNT_USAGE** | **INFORMATION_SCHEMA** = real-time, 7-14 day retention, current DB | **ACCOUNT_USAGE** = 2-3 hr latency, 365-day retention, entire account |

---

## DON'T MIX -- Architecture Concepts That Sound the Same

### Hybrid Table vs Iceberg Table vs External Table

All three access data "differently" from regular tables. The exam loves to swap them.

| | Hybrid Table | Managed Iceberg Table | External Table |
|---|---|---|---|
| Storage format | Row-oriented (OLTP) | Iceberg (open, columnar) | Raw files (CSV/Parquet/etc.) |
| Where data lives | Snowflake-managed storage | YOUR cloud storage (external volume) | YOUR cloud storage |
| DML support | Full (INSERT/UPDATE/DELETE) | Full (INSERT/UPDATE/DELETE/MERGE) | READ-ONLY |
| Constraints enforced? | YES (PK, FK, UNIQUE) | No | No |
| Time Travel | Yes | Yes | No |
| Use case | Fast point lookups + analytics | Multi-engine open format | Legacy read-only access |

**RULE:** Hybrid = OLTP (row-based, enforced keys). Iceberg = open format (multi-engine, your storage). External = read-only window into files.

**The trap:** "Use an Iceberg table for fast single-row lookups" -- WRONG. Iceberg is columnar. For point lookups you need Hybrid (row-oriented).

**The trap:** "Managed Iceberg stores data in Snowflake storage" -- WRONG. Data is on YOUR external volume. Snowflake manages the metadata/catalog.

### Dynamic Table vs Materialized View -- When to Use Which

Both "auto-refresh" data. The exam tests the boundary.

| | Dynamic Table | Materialized View |
|---|---|---|
| Joins allowed? | YES | NO (single table only) |
| UDFs allowed? | YES | NO |
| Scheduling | Target lag (declarative) | Automatic (on base table change) |
| Optimizer auto-rewrite? | No (must query the DT directly) | YES (optimizer can silently redirect) |
| Chaining | DT can reference other DTs | MV cannot reference other MVs |
| Best for | Multi-step pipelines, complex transforms | Simple single-table aggregations |

**RULE:** If the query has a JOIN or UDF -- Dynamic Table. If it's a simple aggregation on ONE table -- Materialized View.

**The trap:** "Use an MV for a join-based summary" -- WRONG. MVs cannot join. Use a Dynamic Table.

### Failover Group vs Database Replication

| | Database Replication | Failover Group |
|---|---|---|
| Scope | ONE database | Multiple databases + account objects |
| Includes roles/users? | NO | YES (if you include them) |
| Coordinated failover? | No (each DB independent) | YES (all objects fail over together) |
| Client redirect? | Not included | Works with Connection objects |

**RULE:** Database replication alone = incomplete DR. Failover group = production-ready DR.

**The trap:** "We replicated the database, so DR is ready" -- WRONG. Without account objects (users, roles, grants), nobody can log in to the secondary.

### Clone vs Replica vs Backup

| | Zero-Copy Clone | Replication | "Backup" |
|---|---|---|---|
| Where | Same account | Different account/region | Not a Snowflake concept |
| Storage cost | Zero (until divergence) | Full copy on secondary | N/A |
| Purpose | Dev/test copies | DR / cross-region | Snowflake uses Time Travel + Fail-safe instead |

**RULE:** Clone = same account, zero cost. Replica = different account, full copy. "Backup" = use Time Travel/Fail-safe, not a separate feature.

---

## SCENARIO DECISION TREES — Data Architecture

**Scenario 1: "20+ source systems, schemas change monthly, need full audit trail..."**
- **CORRECT:** **Data Vault** for the integration layer (absorbs changes in Satellites)
- TRAP: *"Star schema on raw data"* — **WRONG**, star schema is brittle with frequent schema changes

**Scenario 2: "BI team needs fast dashboards on stable, well-understood data..."**
- **CORRECT:** **Star schema** for the presentation/consumption layer
- TRAP: *"Data Vault directly for BI"* — **WRONG**, Data Vault queries are complex; build star schemas on top

**Scenario 3: "Need open-format data so Spark and Snowflake can both read/write..."**
- **CORRECT:** **Managed Iceberg table** with external volume (Snowflake writes Iceberg format, Spark reads same files)
- TRAP: *"External table"* — **WRONG**, external tables are read-only and don't produce Iceberg format

**Scenario 4: "Staging tables hold temporary ETL data — minimize storage costs..."**
- **CORRECT:** **Transient tables** (no Fail-safe = lower storage cost)
- TRAP: *"Temporary tables"* — **WRONG**, temporary tables are session-scoped and vanish when the session ends; not suitable for multi-session ETL

**Scenario 5: "Analyst accidentally deleted 1M rows from production 2 hours ago..."**
- **CORRECT:** **Time Travel** — `INSERT INTO prod SELECT * FROM prod AT(OFFSET => -7200)` or `CREATE TABLE restore CLONE prod AT(...)`
- TRAP: *"Contact Snowflake Support for Fail-safe"* — **WRONG**, Fail-safe is only after Time Travel expires; 2 hours ago is within Time Travel

**Scenario 6: "Need DR to a different cloud region with < 5 min RTO for app connections..."**
- **CORRECT:** **Failover group** (DB + account objects) + **client redirect** (Connection object)
- TRAP: *"Database replication alone"* — **WRONG**, DB replication doesn't cover roles/users/policies, and no auto-redirect without Connection objects

**Scenario 7: "Prevent individual table owners in production from granting access to their tables..."**
- **CORRECT:** **Managed access schema** — centralizes grant control to schema owner
- TRAP: *"Just use RBAC carefully"* — **WRONG**, without managed access, any object owner can grant privileges

**Scenario 8: "Data shared to external consumers — must hide query definition..."**
- **CORRECT:** **Secure views** (hides definition, prevents predicate pushdown bypass)
- TRAP: *"Standard views with row access policies"* — **WRONG**, standard views expose the SQL definition to consumers

**Scenario 9: "Need a pre-computed summary table that auto-updates, simple aggregation, no joins..."**
- **CORRECT:** **Materialized view** (auto-maintained, great for simple aggregations)
- TRAP: *"Dynamic table"* — not wrong per se, but MV is simpler and more efficient for single-table aggregations with no joins

**Scenario 10: "Application needs fast single-row lookups by primary key + joins with analytics tables..."**
- **CORRECT:** **Hybrid table** (row-oriented, enforced PK, fast point reads)
- TRAP: *"Regular Snowflake table with clustering on PK"* — **WRONG**, columnar storage is not optimized for single-row lookups

**Scenario 11: "Spark cluster owns the Iceberg catalog (AWS Glue), Snowflake needs to read it..."**
- **CORRECT:** **Unmanaged (catalog-linked) Iceberg table** with Glue catalog integration
- TRAP: *"Managed Iceberg table"* — **WRONG**, managed means Snowflake takes over catalog ownership, conflicting with Spark

**Scenario 12: "Clone production to dev for testing without doubling storage..."**
- **CORRECT:** **Zero-copy clone** (`CREATE DATABASE dev CLONE prod`)
- TRAP: *"CTAS all tables into new database"* — **WRONG**, CTAS copies all data immediately, doubling storage

**Scenario 13: "Share data with a partner who doesn't have a Snowflake account..."**
- **CORRECT:** **Reader account** (`CREATE MANAGED ACCOUNT`) — provider manages and pays
- TRAP: *"Create a share and tell them to sign up"* — **WRONG**, reader accounts exist precisely for non-Snowflake consumers

**Scenario 14: "Share data with a consumer in a different cloud region..."**
- **CORRECT:** **Replicate the database** to the consumer's region first, then create the share from the replica
- TRAP: *"Create a direct share"* — **WRONG**, direct sharing only works within the same region on the same cloud provider

**Scenario 15: "Need to share data from 3 different databases in one share..."**
- **CORRECT:** Create **secure views** in one database that join/reference the other databases, then share that single database
- TRAP: *"Add objects from all 3 databases to the share"* — **WRONG**, a share can only include objects from ONE database

**Scenario 16: "Need real-time metadata about active queries and current locks..."**
- **CORRECT:** **INFORMATION_SCHEMA** views (real-time, no latency)
- TRAP: *"ACCOUNT_USAGE views"* — **WRONG** for real-time needs; ACCOUNT_USAGE has 2-3 hour latency. Use it for historical analysis instead

**Scenario 17: "Business Critical provider needs to share data with a Standard edition consumer..."**
- **CORRECT:** Set `SHARE_RESTRICTIONS = FALSE` on the share using a role with **OVERRIDE SHARE RESTRICTIONS** privilege
- TRAP: *"Upgrade the consumer to Business Critical"* — **WRONG**, the provider controls the share restriction, not the consumer's edition

**Scenario 18: "Architect needs to validate that a secure view shows the right data per consumer before sharing..."**
- **CORRECT:** `ALTER SESSION SET SIMULATED_DATA_SHARING_CONSUMER = '<account>'` then query the secure view
- TRAP: *"Create reader accounts and log in as each consumer"* — **WRONG**, the SIMULATED parameter is specifically designed for this without creating accounts
- TRAP: *"Set SHARE_RESTRICTIONS on the share"* — **WRONG**, SHARE_RESTRICTIONS controls edition compatibility, not data validation

**Scenario 19: "Large company with 12 Snowflake accounts across divisions wants a centralized internal data sharing hub..."**
- **CORRECT:** Deploy a **Private Data Exchange** (requires ACCOUNTADMIN) and use replication for accounts in other regions
- TRAP: *"Use Snowflake Marketplace"* — **WRONG**, Marketplace is public; a Data Exchange is the private, curated option for internal sharing

**Scenario 20: "Company needs analytics to continue during regional failure. Also shares data via Marketplace to other regions..."**
- **CORRECT:** **Database replication + failover groups** for DR; **Cross-Cloud Auto Fulfillment** for Marketplace sharing. They are separate solutions
- TRAP: *"Cross-Cloud Auto Fulfillment handles both DR and sharing"* — **WRONG**, Auto Fulfillment is for Marketplace listings only, NOT for disaster recovery

---

## FLASHCARDS -- Domain 2

**Q1:** What are the three core entity types in Data Vault?
**A1:** Hubs (business keys), Links (relationships), Satellites (descriptive attributes + history).

**Q2:** What is the maximum Time Travel retention on Enterprise edition?
**A2:** 90 days.

**Q3:** Do transient tables have Fail-safe?
**A3:** No. Zero Fail-safe.

**Q4:** Can materialized views include joins?
**A4:** No. MVs cannot include joins, UDFs, or subqueries.

**Q5:** What is zero-copy cloning?
**A5:** Creating a copy of an object that shares the underlying storage until data diverges. No additional storage at clone time.

**Q6:** What is the difference between managed and unmanaged Iceberg tables?
**A6:** Managed: Snowflake controls metadata + data, full DML. Unmanaged: external catalog manages metadata, limited/read-only from Snowflake.

**Q7:** What objects can a failover group contain?
**A7:** Databases, shares, users, roles, warehouses, integrations, network policies, and other account objects.

**Q8:** How does UNDROP work if you drop and recreate a same-named table?
**A8:** UNDROP uses internal versioning — it restores the most recently dropped version, not the current one.

**Q9:** What makes hybrid tables different from regular tables?
**A9:** Row-oriented storage, enforced constraints (PK, FK, UNIQUE), fast point lookups — designed for OLTP.

**Q10:** Is replication synchronous or asynchronous?
**A10:** Asynchronous. Data freshness depends on refresh frequency.

**Q11:** What is a managed access schema?
**A11:** A schema where only the schema owner (or MANAGE GRANTS holder) can grant privileges on objects — individual object owners cannot.

**Q12:** What is the storage overhead of Fail-safe?
**A12:** Up to 7 days of historical data beyond Time Travel, for permanent tables only.

**Q13:** Can you replicate across cloud providers?
**A13:** Yes, as long as both accounts are in the same Organization.

**Q14:** What does a secure view hide?
**A14:** Its query definition and prevents optimizer from pushing predicates past the view boundary.

**Q15:** What is client redirect?
**A15:** A Connection object that automatically routes clients to the active primary account during failover.

**Q16:** Can a share include objects from multiple databases?
**A16:** No. A share is limited to one database. Use secure views to consolidate data from multiple databases into the share.

**Q17:** What is a reader account?
**A17:** A managed account created by a provider for consumers who don't have a Snowflake account. The provider pays for compute and storage.

**Q18:** Can you share data directly across regions?
**A18:** No. Direct sharing requires same region + same cloud provider. Cross-region sharing requires database replication first.

**Q19:** What happens to tasks after cloning a database?
**A19:** All cloned tasks are in SUSPENDED state. You must manually ALTER TASK ... RESUME each one.

**Q20:** Are JSON keys in VARIANT case-sensitive?
**A20:** Yes. Column names are case-insensitive, but JSON keys within VARIANT are case-sensitive. `col:Name` != `col:name`.

**Q21:** What is the difference between INFORMATION_SCHEMA and ACCOUNT_USAGE?
**A21:** INFORMATION_SCHEMA is real-time with 7-14 day retention (current DB only). ACCOUNT_USAGE has 2-3 hour latency but 365-day retention (entire account).

**Q22:** Can ORGADMIN change an account's edition?
**A22:** No. Only Snowflake Support can change account editions.

**Q23:** What does ADD SEARCH OPTIMIZATION ON do if SOS already exists on the table?
**A23:** It is additive -- it extends the existing search optimization config, it does not replace it.

**Q24:** Who pays for replication compute charges?
**A24:** The target (secondary) account pays for both data transfer and compute during replication refresh.

**Q25:** How do you test what a consumer will see in a shared secure view before sharing?
**A25:** `ALTER SESSION SET SIMULATED_DATA_SHARING_CONSUMER = '<account>'` then query the secure view. Works with secure views and secure MVs, NOT secure UDFs.

**Q26:** Can stored procedures be shared?
**A26:** No. Only secure UDFs and secure UDTFs can be shared. Stored procedures are NOT shareable.

**Q27:** Who pays for what in data sharing?
**A27:** Provider pays storage. Consumer pays compute (warehouse). Exception: reader accounts -- provider pays both.

**Q28:** What privileges does a consumer need to import a share?
**A28:** Both IMPORT SHARE and CREATE DATABASE.

**Q29:** What happens when you `CREATE OR REPLACE` a database role that is granted to a share?
**A29:** The role is dropped from the share. Consumers lose access until the role is re-granted.

**Q30:** What is SHARE_RESTRICTIONS and when is it needed?
**A30:** A parameter that must be set to FALSE (with OVERRIDE SHARE RESTRICTIONS privilege) when a Business Critical provider shares with a lower-edition consumer.

**Q31:** What is Cross-Cloud Auto Fulfillment?
**A31:** Automatic replication of Marketplace listings to consumer regions. It is NOT a DR solution -- use failover groups for DR.

**Q32:** Who can set up a Data Exchange?
**A32:** Only a user with the ACCOUNTADMIN role.

**Q33:** Can a consumer re-share data from a shared database to another account?
**A33:** No. Consumers cannot re-share, clone, or perform DML on shared objects.

---

## EXPLAIN LIKE I'M 5 -- Domain 2

**1. Data Vault**
Imagine you have a box for each friend's name (Hub), a string connecting friends who played together (Link), and sticky notes describing what happened each playdate (Satellite). You never throw anything away — you just add more sticky notes!

**2. Star Schema**
Your toy collection: the big toy chest in the middle has all your play sessions (fact table). Around it are shelves labeled "toys," "friends," "days of the week" (dimension tables). Easy to find "which toy did I play with on Tuesday?"

**3. Time Travel**
Your magic undo button. Spilled paint on your drawing? Press undo and go back to before the spill. Works for up to 90 days!

**4. Fail-safe**
Even after your undo button stops working, your parents kept a secret backup of your drawings in a locked drawer. You can't open it yourself, but they can help if something really bad happens.

**5. Zero-Copy Cloning**
Like taking a photo of your LEGO castle. The photo takes no extra LEGO pieces. But if you change the original castle, only the changed parts need extra pieces.

**6. Transient vs Permanent Tables**
Permanent tables are like your favorite toy kept forever with insurance (Fail-safe). Transient tables are like sand castles — they exist, but no insurance if the tide comes.

**7. Managed Iceberg Tables**
You build with LEGO, but you use the universal LEGO connector system so your friend with a different LEGO brand can also connect to your castle. Snowflake manages the building, but anyone can read the instructions.

**8. Secure Views**
A magic window where you can see the garden but can't see how the window was built. Different people looking through the same window might see different flowers (filtered!).

**9. Replication**
Like having a backup of your favorite game save file on a USB stick at grandma's house. If your computer breaks, grandma has the save file. Not quite up-to-the-second, but close.

**10. Client Redirect**
Like a mailbox that follows you. If you move houses, the mailbox automatically goes to your new house, and everyone's letters still arrive without them knowing you moved.

**11. Data Sharing**
You have a bookshelf with great books. Instead of giving copies to your friends (expensive!), you let them look through a special window into your room. They can read the books but can't take them, change them, or see how you organized your room. That's a share with secure views.

**12. Reader Accounts**
Your friend doesn't have a library card (Snowflake account). So you get them a guest pass that YOU pay for. They can only visit YOUR section of the library, and you control what they see.

**13. Marketplace**
Like a farmers' market where anyone can browse and buy produce (data). Some stalls are free samples, others charge money. The market organizers make sure every stall is available no matter which entrance you came through (Cross-Cloud Auto Fulfillment).

**14. SIMULATED_DATA_SHARING_CONSUMER**
Before letting your friend look through the window (share), you put on your friend's glasses to see what THEY would see. If they'd see something they shouldn't, you fix the window (secure view) before inviting them over.

**15. Data Exchange**
A private club for data. Only members you invite can browse and use the data. The public market (Marketplace) is open to everyone, but the Data Exchange is invite-only -- like a secret treehouse with a "members only" sign.
