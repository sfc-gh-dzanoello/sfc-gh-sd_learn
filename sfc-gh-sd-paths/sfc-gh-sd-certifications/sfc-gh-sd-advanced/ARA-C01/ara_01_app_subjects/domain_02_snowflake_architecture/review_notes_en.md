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

**Exam trap:** IF YOU SEE "star schema is best for audit trails" → WRONG because Data Vault is designed for auditability.

**Exam trap:** IF YOU SEE "snowflake schema is the default recommendation for Snowflake the product" → WRONG because the naming is coincidental. Star schema is more common for analytics.

**Exam trap:** IF YOU SEE "Data Vault replaces dimensional modeling" → WRONG because Data Vault is for the integration layer; you still build star schemas on top for consumption.

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
- Some objects are account-level: warehouses, users, roles, resource monitors, network policies, integrations, shares
- Stages can be table-level (`@%my_table`), schema-level (`@my_stage`), or user-level (`@~`)
- Managed access schemas: only the schema owner (or MANAGE GRANTS) can grant privileges — prevents object owners from granting access independently

### Why This Matters
A data platform team needs to prevent individual table owners from granting SELECT to random roles. Managed access schemas centralize grant control.

### Best Practices
- Use managed access schemas in production
- Organize schemas by domain or data layer (raw, curated, presentation)
- Name objects consistently: `<domain>_<entity>_<suffix>` (e.g., `sales_orders_fact`)
- Keep account-level objects (warehouses, roles) well-documented

**Exam trap:** IF YOU SEE "warehouses belong to a database" → WRONG because warehouses are account-level objects.

**Exam trap:** IF YOU SEE "managed access schemas prevent the schema owner from granting" → WRONG because the schema owner CAN still grant in managed access schemas — the restriction is on object owners other than the schema owner.

**Exam trap:** IF YOU SEE "network policies are database-level objects" → WRONG because they are account-level.

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
- **Temporary:** use for session-scoped intermediate results
- **External:** metadata layer over files in external storage — read-only
- **Dynamic:** automatically refreshed based on a query and target lag

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

**View Types**

| Type | Materialized? | Secure? | Notes |
|---|---|---|---|
| Standard view | No | No | Just a saved query |
| Secure view | No | Yes | Hides definition, optimizer fence |
| Materialized view | Yes | No | Pre-computed, auto-maintained |
| Secure materialized view | Yes | Yes | Both benefits |

- **Secure views:** query definition hidden from consumers, optimizer cannot push predicates past the view boundary
- **Materialized views:** best for expensive aggregations on large, infrequently-changing data
- Materialized views have limitations: no joins, no UDFs, no subqueries in definition

### Why This Matters
A data marketplace shares data via secure views — consumers cannot see the underlying query logic or bypass row-level security.

### Best Practices
- Use transient tables for staging data (avoid unnecessary Fail-safe costs)
- Use dynamic tables instead of complex task/stream pipelines where possible
- Use secure views for all shared objects
- Consider Iceberg managed tables when you need open-format interoperability

**Exam trap:** IF YOU SEE "transient tables have 7 days of Fail-safe" → WRONG because transient tables have zero Fail-safe.

**Exam trap:** IF YOU SEE "temporary tables persist after the session ends" → WRONG because they are dropped when the session ends.

**Exam trap:** IF YOU SEE "materialized views support joins" → WRONG because MV definitions cannot include joins.

**Exam trap:** IF YOU SEE "hybrid tables use columnar storage" → WRONG because they use row-oriented storage for fast point lookups.

**Exam trap:** IF YOU SEE "external tables support DML" → WRONG because external tables are read-only.

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

**Fail-safe**

- 7-day period AFTER Time Travel expires
- NOT user-accessible — only Snowflake Support can recover data
- Only for permanent tables (not transient, temporary, or external)
- Exists as a last resort for catastrophic scenarios

**UNDROP**

- Restores the most recently dropped object: `UNDROP TABLE`, `UNDROP SCHEMA`, `UNDROP DATABASE`
- Uses Time Travel data under the hood
- If you drop and recreate a same-named object, then drop the new one, UNDROP restores the **most recently dropped version** (the new one). To recover the original dropped table, you must first rename the current table, then UNDROP will restore the original

**Zero-Copy Cloning for Backup**

- `CREATE TABLE backup_table CLONE source_table`
- No additional storage until data diverges
- Clones inherit Time Travel settings from source
- Supports cloning databases and schemas (recursive clone of all children)
- Clones are independent — changes to clone don't affect source

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

**Exam trap:** IF YOU SEE "Fail-safe data can be recovered by users via SQL" → WRONG because only Snowflake Support can recover Fail-safe data.

**Exam trap:** IF YOU SEE "Time Travel retention can be set to 90 days on Standard edition" → WRONG because Standard edition max is 1 day.

**Exam trap:** IF YOU SEE "cloning a table doubles storage immediately" → WRONG because cloning is zero-copy; storage only grows as data diverges.

**Exam trap:** IF YOU SEE "UNDROP works on transient tables after Fail-safe" → WRONG because transient tables have no Fail-safe, and UNDROP only works during the Time Travel period.

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

**Account Replication**

- Replicate account-level objects: users, roles, grants, warehouses, network policies, parameters
- Essential for true DR — database replication alone doesn't cover access control
- Combined with database replication in failover groups

**Failover Groups**

- Named collection of objects that can fail over as a unit
- Types of objects: databases, shares, users, roles, warehouses, integrations, network policies
- `PRIMARY` → `SECONDARY` promotion via `ALTER FAILOVER GROUP ... PRIMARY`
- Only one primary at a time per failover group

**Cross-Region / Cross-Cloud**

- Replication works across regions AND across cloud providers
- Both accounts must be in the same Snowflake Organization
- Consider data residency regulations when replicating across regions
- Replication costs: data transfer + compute for refresh

**Client Redirect**

- Connection URLs that automatically redirect to the active primary
- Minimizes client-side changes during failover
- Uses `CONNECTION` objects: `CREATE CONNECTION`, `ALTER CONNECTION ... PRIMARY`

### Why This Matters
A global fintech company runs primary in AWS US-East, secondary in AWS EU-West. If US-East goes down, they promote EU-West in minutes. Client redirect means apps don't need config changes.

### Best Practices
- Use failover groups (not standalone database replication) for production DR
- Include account objects in your failover group for complete recovery
- Set up client redirect to minimize failover RTO
- Monitor replication lag via `REPLICATION_GROUP_REFRESH_HISTORY`
- Test failover quarterly with real promote/failback drills

**Exam trap:** IF YOU SEE "secondary databases are read-write" → WRONG because secondary databases are read-only until promoted to primary.

**Exam trap:** IF YOU SEE "replication requires the same cloud provider" → WRONG because cross-cloud replication is supported.

**Exam trap:** IF YOU SEE "failover is automatic" → WRONG because failover must be manually initiated (Snowflake does not auto-failover).

**Exam trap:** IF YOU SEE "client redirect works without Connection objects" → WRONG because you must create and configure Connection objects for client redirect.

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
