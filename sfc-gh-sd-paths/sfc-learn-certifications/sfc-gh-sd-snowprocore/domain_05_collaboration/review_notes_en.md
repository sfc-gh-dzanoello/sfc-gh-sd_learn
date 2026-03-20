# DOMAIN 5: DATA COLLABORATION
## 10% of exam = ~10 questions. Smallest domain, but easy points.

---

## 5.1 DATA REPLICATION & FAILOVER

### Database Replication:
- Copy a database from one account to another
- Primary database (read-write) → Secondary database(s) (read-only)
- Can replicate across regions and cloud providers
- Secondary database refreshes to sync changes from primary
- Required for: cross-region data sharing

### Account Replication:
- Replicate account-level objects (users, roles, warehouses, databases)
- For disaster recovery

### Failover (Business Critical+):
- Promote a secondary database/account to primary
- When primary region/account is unavailable
- Business continuity and disaster recovery
- Failback: switch back to original primary after recovery

**Exam trap**: "Share data cross-region?" → Need replication FIRST, then share. IF YOU SEE "direct share" + "cross-region" or "different cloud" → WRONG because direct share = same region + same cloud only.
**Exam trap**: "Failover edition?" → Business Critical+. IF YOU SEE "Standard" or "Enterprise" + "failover" → WRONG because failover requires Business Critical or higher.
**Exam trap**: "Secondary database is..." → Read-only until promoted. IF YOU SEE "read-write" + "secondary database" → WRONG because secondary = read-only. Only primary is read-write.

### Example Scenario Questions — Data Replication & Failover

**Scenario:** A multinational retail company has its primary Snowflake account in AWS US-East-1. They need to share sales data with their analytics team in AWS EU-Frankfurt. The team tries to create a direct share but gets an error. What is the correct approach?
**Answer:** Direct shares only work within the same cloud provider AND the same region. The company must first replicate the database to an account in AWS EU-Frankfurt using database replication (CREATE DATABASE ... AS REPLICA OF ...), then create a share from the replicated database in that region. Replication works across regions and cloud providers on any Snowflake edition.

**Scenario:** A financial services firm on Snowflake Business Critical edition has accounts in two regions for disaster recovery. Their primary region experiences an outage. The DR team needs to restore operations. What Snowflake feature should they use, and what edition is required?
**Answer:** They should use Failover to promote their secondary account/database to primary. Failover is available only on Business Critical edition and above — their BC edition qualifies. Once the original region recovers, they can failback (switch back to the original primary). Standard and Enterprise editions support replication but NOT failover.

**Scenario:** A healthcare company replicates their patient analytics database to a secondary account for disaster recovery. A junior analyst connects to the secondary database and tries to INSERT new records. What happens?
**Answer:** The INSERT will fail. Secondary databases are read-only — they can only be used for querying until they are promoted to primary via failover. Only the primary database supports read-write operations. The analyst must connect to the primary account to insert data.

---

## 5.2 SECURE DATA SHARING (HEAVILY TESTED)

### How it works:
- Provider SHARES data with Consumer
- NO data is copied or moved
- Consumer accesses Provider's data in real-time
- Changes by Provider are visible to Consumer IMMEDIATELY
- Zero data movement = zero storage cost for sharing

### What can be shared:
- Tables
- Secure views (required for sharing views)
- Secure UDFs
- Secure materialized views

### What CANNOT be shared directly:
- Regular (non-secure) views
- Stages
- Pipes
- Tasks

### Share object:
- Created by ACCOUNTADMIN (only ACCOUNTADMIN can create shares)
- GRANT privileges on objects TO SHARE
- Consumer creates a database FROM SHARE

### Provider vs Consumer:
| | Provider | Consumer |
|---|---|---|
| Creates share | Yes | No |
| Owns the data | Yes | No |
| Pays for storage | Yes | No |
| Pays for compute | No (consumer queries) | Yes (own warehouse) |
| Can modify shared data | Yes | No (read-only) |

### Key rule: Consumer uses their OWN warehouse to query shared data. Provider pays nothing for consumer's queries.

### Why This Matters + Use Cases

**Real scenario — "Our partner doesn't have a Snowflake account"**
Create a Reader Account for them. YOU (provider) pay for EVERYTHING — storage + compute. The reader account is read-only and limited. Use this only when the partner has no Snowflake account.

**Real scenario — "We shared a view but the consumer sees our SQL logic"**
Regular views expose the SQL definition. Solution: use SECURE views for ALL shared objects. Secure views hide the SQL definition from consumers. This is REQUIRED for shares.

**Real scenario — "We need to share data with our Tokyo office but our account is in US-West"**
Direct cross-region sharing is NOT possible. Solution: replicate your database to the Tokyo region first (CREATE DATABASE ... AS REPLICA OF ...), then create a share in that region.

---

### Best Practices — Data Sharing
- Always use SECURE views for sharing (required, hides SQL)
- Only ACCOUNTADMIN can create shares
- For cross-region sharing: replicate database first, then create share
- Reader accounts: use ONLY when consumer has no Snowflake account (you pay everything)
- Monitor shared data usage with ACCOUNT_USAGE views

**Exam trap**: "Who pays for compute on shared data?" → Consumer (uses own warehouse). IF YOU SEE "provider pays compute" or "provider's warehouse" for shared queries → WRONG because consumer always uses their OWN warehouse.
**Exam trap**: "Provider updates data, when does consumer see it?" → Immediately. IF YOU SEE "delay", "refresh needed", or "sync required" for shared data visibility → WRONG because shared data = same underlying data, changes visible instantly.
**Exam trap**: "Who creates Share object?" → ACCOUNTADMIN only. IF YOU SEE "SYSADMIN", "SECURITYADMIN", or "USERADMIN" + "create share" → WRONG because ONLY ACCOUNTADMIN can create Share objects.
**Exam trap**: "Can you share a regular view?" → NO, must be Secure View. IF YOU SEE "regular view" + "share" or "non-secure view" + "data sharing" → WRONG because ONLY secure views/UDFs/MVs can be shared.

### Example Scenario Questions — Secure Data Sharing

**Scenario:** A logistics company (Provider) shares real-time shipment tracking data with a retail partner (Consumer). The retail partner's CFO asks: "How much are we being charged for storing the shared data?" What is the correct answer?
**Answer:** The Consumer pays zero for storage of shared data. The Provider owns and stores the data — storage costs are entirely the Provider's responsibility. The Consumer only pays for compute when they query the shared data using their own warehouse. Shared data involves zero data movement and zero storage duplication.

**Scenario:** A data engineering team creates a share containing a view that joins three internal tables. After the consumer creates a database from the share, they can see the SQL definition of the view and reverse-engineer the Provider's data model. How should this be fixed?
**Answer:** The view must be changed to a SECURE view (ALTER VIEW ... SET SECURE). Only secure views, secure UDFs, and secure materialized views can be shared. Secure views hide the SQL definition from consumers, preventing them from seeing the underlying logic or table structure. Regular (non-secure) views should never be used in shares.

**Scenario:** A Provider updates pricing data in a shared table at 2:00 PM. The Consumer runs a query at 2:01 PM. Will the Consumer see the updated prices, or is there a synchronization delay?
**Answer:** The Consumer will see the updated prices immediately. Secure Data Sharing provides real-time access to the Provider's underlying data — there is no copy, no sync process, and no delay. Changes made by the Provider are visible to the Consumer instantly because both are reading the same underlying micro-partitions.

**Scenario:** A SYSADMIN at a healthcare company tries to create a SHARE object to distribute anonymized patient statistics to research partners. The command fails. Why?
**Answer:** Only ACCOUNTADMIN can create SHARE objects in Snowflake. SYSADMIN, SECURITYADMIN, and other roles do not have the CREATE SHARE privilege. The SYSADMIN must ask the ACCOUNTADMIN to create the share, or the ACCOUNTADMIN role must be used directly.

---

## 5.3 READER ACCOUNTS

### What they are:
- Created BY the Provider FOR consumers who do NOT have a Snowflake account
- Managed account — Provider controls everything

### Key facts:
- Provider creates them (CREATE MANAGED ACCOUNT)
- **Provider pays for everything** (storage + compute)
- Reader account users can query shared data (read-only access to shared data)
- CAN create databases, tables, views, and virtual warehouses within their account
- CANNOT create shares or access the provider's warehouses
- No hard limit on number of Reader accounts per Provider

**Exam trap**: "Consumer has no Snowflake account?" → Create Reader Account. IF YOU SEE "no Snowflake account" + "direct share" or "Marketplace" → WRONG because without a SF account, only a Reader Account works.
**Exam trap**: "Who pays for Reader Account compute?" → The PROVIDER. IF YOU SEE "consumer pays" + "reader account" → WRONG because Reader Account = Provider pays EVERYTHING (storage + compute).
**Exam trap**: "How many Reader Accounts can you create?" → No hard limit. IF YOU SEE a specific number like "5", "10", "25" as a max limit → WRONG because there is no hard limit on Reader Accounts per Provider.

### Example Scenario Questions — Reader Accounts

**Scenario:** A weather data Provider wants to share forecast data with a small agricultural cooperative that does not have a Snowflake account and has no budget for one. The Provider's finance team asks who will pay for the cooperative's query compute costs. What is the answer?
**Answer:** The Provider pays for everything — both storage and compute — when using a Reader Account. Since the cooperative has no Snowflake account, a Reader Account (CREATE MANAGED ACCOUNT) is the only option. The Provider should budget for the cooperative's compute costs, as queries run on warehouses provisioned within the Reader Account but billed to the Provider.

**Scenario:** A consulting firm creates a Reader Account for a client to access shared benchmark data. The client's analyst wants to create their own tables within the Reader Account to store custom calculations. Can they do this?
**Answer:** Reader Accounts have limited functionality but CAN create databases, tables, views, and virtual warehouses within their account. However, the shared data from the Provider is read-only — the client cannot modify shared objects. If the client needs to store custom calculations, they can create their own local tables within the Reader Account. What Reader Accounts CANNOT do is create shares or access the Provider's warehouses.

**Scenario:** A SaaS company shares usage analytics with 30 different enterprise clients, each without Snowflake accounts. Their architect asks if there is a limit to how many Reader Accounts they can create. What should they be told?
**Answer:** There is no hard limit on the number of Reader Accounts a Provider can create. The SaaS company can create Reader Accounts for all 30 clients. However, they should be aware that they (the Provider) will pay all compute and storage costs for every Reader Account, so cost monitoring is important at scale.

---

## 5.4 DATA SHARING & RESHARING

### Direct Share:
- Provider → Consumer (one-to-one or one-to-many)
- Both must be on same cloud provider + region (unless using replication)
- For cross-region: replicate database first, then share

### Resharing:
- Consumer can reshare data they received (if Provider allows)
- Chain of sharing

**Exam trap**: "Direct share works across regions?" → NO. Same region + cloud only. Cross-region requires replication FIRST. IF YOU SEE "direct share" + "different region" or "cross-cloud" → WRONG because direct share = same region AND same cloud provider only.
**Exam trap**: "Can any consumer reshare data?" → Only if Provider explicitly allows it. Not automatic. IF YOU SEE "consumer reshares" + "by default" or "automatically" → WRONG because resharing requires explicit Provider permission.
**Exam trap**: "Direct share = data is copied to consumer?" → WRONG. Zero copy. Consumer reads Provider's data in place. IF YOU SEE "data copied", "data moved", or "data transferred" + "sharing" → WRONG because sharing = zero copy, zero movement.

### Example Scenario Questions — Data Sharing & Resharing

**Scenario:** A pharmaceutical company in AWS US-East-1 wants to share clinical trial results directly with a research hospital in Azure West Europe. They attempt to create a direct share. Will this work?
**Answer:** No. Direct shares require both parties to be on the same cloud provider AND the same region. AWS US-East-1 and Azure West Europe differ in both cloud provider and region. The pharmaceutical company must first replicate the database to an account in Azure West Europe, then create a share from that replicated database.

**Scenario:** Company A shares market research data with Company B via Secure Data Sharing. Company B wants to reshare this data with Company C (a mutual business partner). Can Company B do this without any special permissions?
**Answer:** No. Resharing is not automatic. Company B can only reshare the data if Company A (the original Provider) explicitly grants permission to reshare. Without that permission, Company B cannot create a share of data they received from Company A. This prevents unauthorized distribution of proprietary data.

**Scenario:** A data Provider shares inventory data with 15 different retail partners, all within the same AWS US-West-2 region. One partner asks if the Provider had to create 15 separate copies of the data to serve all partners. What is the reality?
**Answer:** Zero copies were created. A single share can serve multiple consumers (one-to-many). All 15 retail partners read from the same underlying data in the Provider's storage. There is no data duplication, no data movement, and no additional storage cost for the Provider regardless of how many consumers access the share. Each consumer uses their own warehouse for compute.

---

## 5.5 SNOWFLAKE MARKETPLACE

### What it is:
- Discovery and access platform for data products
- Third-party data providers list their data
- Consumers browse, request access, and use data
- Some listings are free, others are paid

### Types of Listings:

**Public Listings**:
- Visible to all Snowflake accounts
- Anyone can request access
- Listed on Marketplace

**Private Listings**:
- Visible only to specific invited accounts
- Direct sharing between known parties
- Not publicly discoverable

### Data Exchange (older concept):
- Private hub for controlled group of participants
- Provider controls who can join
- Members can share data within the exchange

**Exam trap**: "Marketplace vs Data Exchange?" → Marketplace = public/private listings for broad discovery. Data Exchange = private invite-only hub. IF YOU SEE "Data Exchange" + "public" or "anyone can join" → WRONG because Data Exchange = private, invite-only.
**Exam trap**: "Private Listing vs Data Exchange?" → Private Listing = on Marketplace but visible to invited accounts only. Data Exchange = separate private hub entirely. IF YOU SEE "Private Listing" confused with "Data Exchange" → WRONG because Private Listing lives ON the Marketplace; Data Exchange is a separate hub.
**Exam trap**: "Free Marketplace listing = no cost at all?" → No storage cost to consumer (Provider stores it), but consumer still pays compute to query. IF YOU SEE "free listing" + "no cost" or "completely free" → WRONG because "free" only means no data fee — consumer still pays compute.

### Example Scenario Questions — Snowflake Marketplace

**Scenario:** A global weather data company wants to make their historical climate dataset available to any Snowflake customer worldwide for discovery and purchase. Should they use a Public Listing, a Private Listing, or a Data Exchange?
**Answer:** A Public Listing on the Snowflake Marketplace. Public listings are visible to all Snowflake accounts and allow anyone to discover, request access, and use the data. This is the right choice for broad distribution to unknown potential customers. A Private Listing would limit visibility to invited accounts only, and a Data Exchange is a separate private hub — neither fits the goal of broad public discovery.

**Scenario:** A financial services consortium of five banks wants to share proprietary risk models only among themselves — no outside access. They need a controlled environment where only approved members can participate. What should they use?
**Answer:** A Data Exchange. Data Exchanges are private, invite-only hubs where the provider controls exactly who can join. This is ideal for a closed consortium where membership is restricted. A Marketplace public listing would expose the data to all Snowflake users, and a private listing still lives on the public Marketplace (just with restricted visibility). A Data Exchange is a completely separate, controlled environment.

**Scenario:** A consumer finds a "free" weather dataset on the Snowflake Marketplace and tells their manager it will cost the company nothing. Is this accurate?
**Answer:** Not entirely. "Free" on the Marketplace means there is no data licensing fee and no storage cost to the consumer (the Provider stores the data). However, the consumer still pays for compute — they must use their own warehouse to query the data. So while the data itself is free, querying it incurs standard Snowflake compute charges.

---

## 5.6 NATIVE APPS

### What they are:
- Full applications built on Snowflake data
- Provider builds the app, Consumer installs it
- App runs in Consumer's account
- Data stays in Consumer's account (privacy)
- Can include: UI (Streamlit), stored procedures, UDFs, views

### Native App Framework:
- Provider creates an Application Package
- Package includes: setup script, data content, Streamlit UI, code
- Consumer installs and runs the app
- Provider can update the app (versioning)

**Exam trap**: "Native App runs in Provider's account?" → WRONG. Runs in Consumer's account. Data stays private to consumer. IF YOU SEE "provider's account" + "Native App runs" → WRONG because Native Apps ALWAYS run in the Consumer's account.
**Exam trap**: "Native App vs Secure Data Sharing?" → Sharing = read-only data access. Native App = full application with UI + logic + code. IF YOU SEE "sharing" when the question describes UI, stored procedures, or application logic → WRONG because that's a Native App, not plain sharing.
**Exam trap**: "Who pays compute for Native App?" → Consumer (it runs in their account on their compute). IF YOU SEE "provider pays compute" + "Native App" → WRONG because app runs in Consumer's account, so Consumer pays all compute.

### Example Scenario Questions — Native Apps

**Scenario:** An analytics vendor builds a churn-prediction application with a Streamlit dashboard, stored procedures, and UDFs. They want to distribute it to customers so each customer can run it on their own data without exposing that data to the vendor. What Snowflake feature should they use?
**Answer:** A Native App. The vendor creates an Application Package containing the Streamlit UI, stored procedures, and UDFs. Each customer installs the app in their own Snowflake account. The app runs inside the customer's account on the customer's data — the vendor never sees the customer's raw data. This preserves data privacy while distributing full application functionality.

**Scenario:** A consumer installs a Native App from a Provider. The consumer's finance team wants to know: does the Provider charge us for the compute used to run this app? Where does the app actually execute?
**Answer:** The Native App runs entirely in the Consumer's account, using the Consumer's compute resources (warehouses). The Consumer pays for all compute. The Provider does not pay for the Consumer's execution costs. The Provider may charge a licensing or subscription fee for the app itself (separate from Snowflake compute costs), but Snowflake compute is always the Consumer's responsibility since the app runs in their environment.

**Scenario:** A data Provider currently shares read-only tables with consumers via Secure Data Sharing. A consumer asks for interactive dashboards and custom scoring logic on the shared data. Can this be done with Secure Data Sharing alone?
**Answer:** No. Secure Data Sharing provides read-only data access — it cannot deliver UI, stored procedures, or application logic. The Provider should build a Native App using the Native App Framework. The Application Package can include a Streamlit UI for dashboards, stored procedures for scoring logic, and UDFs for calculations. The consumer installs it and gets the full interactive experience in their own account.

---

## 5.7 CLONING (Zero-Copy)

### How it works:
- CREATE TABLE/DATABASE/SCHEMA ... CLONE source
- Metadata-only operation (instant)
- No additional storage until data is modified
- Clone is independent — changes don't affect original

### What can be cloned:
- Databases
- Schemas
- Tables (permanent, transient, temporary)
- Streams
- Tasks
- Stages (named stages only, not user/table stages)
- File formats
- Sequences

### What CANNOT be cloned:
- External tables
- Internal (user/table) stages

### Clone behavior with privileges:
- When cloning a database/schema: child objects inherit the SAME privileges from source
- When cloning a single table: privileges are NOT copied

### Clone + Time Travel:
- Clone captures data at CURRENT point in time (or specified time)
- Clone does NOT include Time Travel history of original
- Can clone using Time Travel: CREATE TABLE clone CLONE source AT(TIMESTAMP => '...')

**Exam trap**: "Storage cost of new clone?" → Zero until modifications. IF YOU SEE "doubles storage", "full copy cost", or "same storage as original" + "clone" → WRONG because clone = zero-copy, no extra storage until data is modified.
**Exam trap**: "Clone includes Time Travel history?" → NO. IF YOU SEE "Time Travel history" + "clone inherits" or "clone includes" → WRONG because clone starts fresh with NO Time Travel history from the source.
**Exam trap**: "Clone at a past point?" → Yes, using AT/BEFORE clause. IF YOU SEE "cannot clone historical data" or "clone only works on current state" → WRONG because you CAN clone at a past point via CLONE source AT(TIMESTAMP => '...').
**Exam trap**: "Clone of database includes privileges?" → YES (child objects keep privileges). IF YOU SEE "no privileges" + "database clone" or "schema clone" → WRONG because DB/schema clones DO keep child privileges. Only single TABLE clones lose privileges.

### Example Scenario Questions — Cloning

**Scenario:** A DevOps team needs to create an exact copy of their 2TB production database for QA testing. They are concerned about doubling their storage costs and the time it will take to copy all the data. How should they proceed?
**Answer:** Use zero-copy cloning: CREATE DATABASE qa_db CLONE production_db. This is a metadata-only operation that completes in seconds regardless of database size. The clone initially points to the same underlying micro-partitions, so there is zero additional storage cost at creation. Storage costs only increase as the QA team modifies data in the clone — and only for the changed micro-partitions, not the entire database.

**Scenario:** A DBA clones an entire production database for a development team. The dev team asks whether the table-level grants (SELECT, INSERT) that exist in production will also exist in the cloned database. What is the answer?
**Answer:** Yes. When cloning a database or schema, child objects inherit the same privileges from the source. So all table-level grants (SELECT, INSERT, etc.) in the production database will be present in the cloned database. This is different from cloning a single table directly — in that case, privileges are NOT copied.

**Scenario:** A data engineer clones a table and then discovers they need the data as it existed two days ago, not at the current point in time. They also wonder if the clone contains the original table's Time Travel history. What should they know?
**Answer:** Clones do NOT include the Time Travel history of the source table — the clone starts fresh with its own Time Travel timeline from the moment of creation. However, the engineer can create a new clone at a past point in time using: CREATE TABLE my_clone CLONE source_table AT(TIMESTAMP => '2024-01-15 10:00:00'). This combines cloning with Time Travel to capture the table's state at the specified timestamp.

**Scenario:** A team tries to clone an external table and a table stage as part of their development environment setup. Both operations fail. Why?
**Answer:** External tables and internal stages (user stages and table stages) cannot be cloned. These are among the few object types excluded from cloning. Named stages CAN be cloned, but user/table stages cannot. For external tables, the team would need to recreate the external table definition manually in the target environment.

---

## 5.8 TIME TRAVEL (HEAVILY TESTED)

### What it is:
- Access historical data (before changes)
- Query data as it was at a past point in time
- Recover dropped objects

### Retention periods:
| Edition | Permanent Tables | Transient/Temporary |
|---|---|---|
| Standard | 0-1 day | 0-1 day |
| Enterprise+ | 0-90 days | 0-1 day |

### Parameter: DATA_RETENTION_TIME_IN_DAYS
- Set at account, database, schema, or table level
- Setting to 0 = disables Time Travel for that object

### Time Travel queries:
- `AT(TIMESTAMP => 'timestamp')` → data at exact time
- `AT(OFFSET => -60*5)` → data 5 minutes ago (seconds)
- `AT(STATEMENT => 'query_id')` → data before a specific query
- `BEFORE(STATEMENT => 'query_id')` → data before the query executed

### Recover dropped objects:
- UNDROP TABLE table_name
- UNDROP SCHEMA schema_name
- UNDROP DATABASE database_name
- Must be within Time Travel retention period

### Best Practices — Data Protection
- Set DATA_RETENTION_TIME_IN_DAYS = 90 for critical production tables (Enterprise+)
- Set DATA_RETENTION_TIME_IN_DAYS = 0 for staging/temp data (save storage)
- Use UNDROP immediately after accidental drops — it's fastest recovery
- Clone before risky operations: CREATE TABLE backup CLONE production
- Fail-safe is Snowflake-support only — plan recovery around Time Travel, not Fail-safe

**Exam trap**: "Query data 5 minutes ago?" → AT(OFFSET => -60*5). IF YOU SEE "TIMESTAMP" when the question says "X minutes ago" → trap! Offset uses negative SECONDS, not a timestamp.
**Exam trap**: "UNDROP TABLE works within..." → Time Travel retention period. IF YOU SEE "Fail-safe" + "UNDROP" → WRONG because UNDROP only works during Time Travel. Fail-safe requires Snowflake support — you cannot UNDROP from Fail-safe.
**Exam trap**: "Set retention to 0?" → Disables Time Travel. IF YOU SEE "DATA_RETENTION_TIME_IN_DAYS = 0" + "still has Time Travel" or "still can UNDROP" → WRONG because 0 = completely disabled, no historical access at all.
**Exam trap**: "Transient table max Time Travel?" → 1 day (even on Enterprise). IF YOU SEE "90 days" + "transient" or "temporary" → WRONG because transient/temporary tables max out at 1 day regardless of edition.

### Example Scenario Questions — Time Travel

**Scenario:** An analyst on an Enterprise edition account accidentally runs a DELETE statement that removes all records from a critical sales table. They realize the mistake 30 minutes later. The table has DATA_RETENTION_TIME_IN_DAYS set to 90. How can they recover the data?
**Answer:** Since only 30 minutes have passed and the table has 90-day Time Travel retention on Enterprise edition, they have multiple recovery options: (1) Query the data before the delete using SELECT * FROM sales_table BEFORE(STATEMENT => 'delete_query_id'), (2) Use UNDROP if the table was dropped, or (3) Create a clone at the point before the delete: CREATE TABLE sales_recovered CLONE sales_table BEFORE(STATEMENT => 'delete_query_id'). The BEFORE clause captures data just before the DELETE executed.

**Scenario:** A company on Enterprise edition creates a transient staging table for ETL processing. The data architect sets DATA_RETENTION_TIME_IN_DAYS = 90 on this table. Will this work?
**Answer:** No. Transient tables have a maximum Time Travel retention of 1 day, regardless of the Snowflake edition. Even though Enterprise edition supports up to 90 days for permanent tables, transient and temporary tables are capped at 1 day. The ALTER TABLE command will either fail or be silently capped to 1 day. If 90-day Time Travel is needed, the table must be created as a permanent table.

**Scenario:** A database administrator sets DATA_RETENTION_TIME_IN_DAYS = 0 on a test database to save storage. Later, a developer accidentally drops a table in that database and tries to run UNDROP TABLE. What happens?
**Answer:** The UNDROP will fail. Setting DATA_RETENTION_TIME_IN_DAYS = 0 completely disables Time Travel for the object. With Time Travel disabled, there is no historical data retained — no AT/BEFORE queries, no UNDROP capability. The table may still be recoverable via Fail-safe (if it was a permanent table), but only by contacting Snowflake support. To prevent this, critical tables should always have a non-zero retention period.

**Scenario:** A data engineer needs to see what a table looked like exactly 10 minutes before a specific UPDATE query ran (query ID: '01a2b3c4-...'). Should they use AT or BEFORE?
**Answer:** They should use BEFORE(STATEMENT => '01a2b3c4-...'). The BEFORE clause returns data as it existed immediately before the specified statement executed. The AT clause would return data at the moment the statement ran, which would include the effects of the UPDATE. If they need data 10 minutes before the query (not just immediately before), they should use AT(OFFSET => -600) where -600 is 10 minutes in negative seconds, or AT(TIMESTAMP => 'specific_timestamp') with the exact time 10 minutes prior.

---

## 5.9 FAIL-SAFE

### What it is:
- 7-day period AFTER Time Travel expires
- Snowflake-managed disaster recovery
- YOU cannot access Fail-safe data directly
- Only Snowflake support can recover Fail-safe data

### Which tables have Fail-safe:
- Permanent tables → YES (7 days)
- Transient tables → NO
- Temporary tables → NO

### Fail-safe is NOT:
- A backup you control
- Something you can query
- Available for transient/temporary tables

### Storage cost timeline:
```
Active Data → Time Travel Data → Fail-safe Data → Purged
(current)     (1-90 days)        (7 days)          (gone forever)
```

**Exam trap**: "Fail-safe for transient tables?" → NO Fail-safe. IF YOU SEE "Fail-safe" + "transient" or "temporary" → WRONG because ONLY permanent tables have Fail-safe. Transient and temporary = zero Fail-safe.
**Exam trap**: "Can you query Fail-safe data?" → NO (Snowflake support only). IF YOU SEE "SELECT", "query", or "access directly" + "Fail-safe" → WRONG because you CANNOT query Fail-safe data. Only Snowflake support can recover it.
**Exam trap**: "Fail-safe duration?" → 7 days (always, all editions). IF YOU SEE "90 days", "varies by edition", or "configurable" + "Fail-safe" → WRONG because Fail-safe is ALWAYS exactly 7 days, not configurable.
**Exam trap**: "Data dropped 10 days ago, 1-day Time Travel?" → In Fail-safe (contact Snowflake), or if past 8 days total → permanently lost. IF YOU SEE "UNDROP" + "past Time Travel retention" → WRONG because UNDROP only works within Time Travel. After that, only Snowflake support via Fail-safe.

### Example Scenario Questions — Fail-Safe

**Scenario:** A company uses transient tables for all their staging data to save on storage costs. After a critical ETL failure corrupts staging data 3 days ago (past the 1-day Time Travel window), the team asks if Fail-safe can recover the data. What is the answer?
**Answer:** No. Transient tables do NOT have Fail-safe protection — only permanent tables do. With a 1-day Time Travel window already expired, the data is permanently lost. There is no recovery path — not through UNDROP, not through Time Travel queries, and not through Fail-safe. For critical staging data that may need recovery beyond 1 day, the team should use permanent tables instead of transient tables.

**Scenario:** A DBA accidentally drops a permanent production table. Time Travel retention was set to 1 day, and the mistake is discovered 5 days later. The DBA tries UNDROP TABLE but it fails. Is the data gone forever?
**Answer:** Not necessarily. UNDROP only works within the Time Travel retention period (1 day in this case), so it correctly failed. However, since the table is a permanent table, it has 7 days of Fail-safe protection that begins after Time Travel expires. Day 5 falls within the Fail-safe window (Time Travel day 1 + Fail-safe days 2-8). The DBA must contact Snowflake support to request data recovery from Fail-safe. Note: recovery is not guaranteed and is a best-effort process performed by Snowflake.

**Scenario:** A finance team asks their architect to explain the total storage cost timeline for a permanent table on Enterprise edition with 90-day Time Travel. How long is data retained in total before permanent deletion?
**Answer:** The total data retention timeline is: Active data (current) → Time Travel (up to 90 days after modification/deletion) → Fail-safe (7 additional days after Time Travel expires) → permanently purged. So the maximum total retention before permanent deletion is 90 + 7 = 97 days. During Time Travel, users can query historical data and use UNDROP. During Fail-safe, only Snowflake support can recover data. After both periods expire, data is gone forever.

**Scenario:** A manager asks: "Can we write a script that queries our Fail-safe data periodically as an extra backup check?" Is this possible?
**Answer:** No. Fail-safe data cannot be accessed, queried, or interacted with by users in any way. There is no SQL command, API, or interface to read Fail-safe data. It is entirely managed by Snowflake internally and can only be recovered by contacting Snowflake support in a disaster recovery scenario. For proactive backup strategies, rely on Time Travel (which you CAN query) and cloning.

---

## 5.10 DATA CLEAN ROOMS

### What they are:
- Secure environment for multi-party data analysis
- Each party keeps their data private
- Run approved queries/analyses without exposing raw data
- Use case: advertising overlap, customer matching

**Exam trap**: "Data Clean Room = data is shared between parties?" → WRONG. Raw data stays private. Only approved aggregate results are visible. IF YOU SEE "raw data shared", "parties see each other's data", or "data exchanged" + "Clean Room" → WRONG because raw data NEVER leaves each party.
**Exam trap**: "Data Clean Room vs Secure Data Sharing?" → Sharing = one party gives access to data. Clean Room = multi-party analysis where NO party sees the other's raw data. IF YOU SEE "Data Sharing" when the scenario describes multi-party private analysis → WRONG because that's a Clean Room, not regular sharing.

### Example Scenario Questions — Data Clean Rooms

**Scenario:** Two competing retail brands want to measure how many customers they share in common to evaluate a joint loyalty program. Neither brand is willing to reveal their full customer list to the other. What Snowflake feature should they use?
**Answer:** A Data Clean Room. Each brand keeps their customer data private within their own Snowflake account. The Clean Room allows them to run approved aggregate queries — such as counting overlapping customers — without either party seeing the other's raw customer records. Only the agreed-upon aggregate results (e.g., "12,450 customers overlap") are visible, not the underlying individual records.

**Scenario:** An advertising agency wants to match their campaign audience data against a media company's viewer data to measure ad effectiveness. The media company's legal team insists that no raw viewer data can leave their environment. Can this be done with regular Secure Data Sharing?
**Answer:** No. Secure Data Sharing would give the advertising agency direct read access to the media company's data, which violates their legal requirement. A Data Clean Room is the correct solution. In a Clean Room, both parties contribute their data but neither sees the other's raw records. Only pre-approved analyses (like audience overlap counts or aggregate conversion metrics) produce results — the raw viewer data never leaves the media company's control.

**Scenario:** A pharmaceutical company and a hospital network want to jointly analyze patient outcomes for a drug trial. Regulations require that individual patient records are never exposed to the pharmaceutical company. How does a Data Clean Room help compared to just sharing the data?
**Answer:** In regular Secure Data Sharing, the pharmaceutical company would gain read access to the hospital's patient data — violating privacy regulations. A Data Clean Room ensures that the hospital's raw patient records are never visible to the pharmaceutical company. Both parties load their respective data, and only approved aggregate analyses (e.g., average recovery time, outcome distributions by age group) are computed and shared. Individual patient-level data remains private to each party throughout the process.

---

## RAPID-FIRE REVIEW — Domain 5

1. Data sharing = no data copied, real-time access, zero movement cost
2. Provider pays storage. Consumer pays compute (own warehouse).
3. Only ACCOUNTADMIN creates Shares
4. Only Secure Views can be shared (not regular views)
5. Reader Account = for consumers without Snowflake. Provider pays everything.
6. Cross-region sharing requires replication first
7. Failover = Business Critical+ only
8. Marketplace: public listings (anyone) vs private listings (invited only)
9. Native Apps = full applications, run in consumer's account
10. Clone = zero-copy, instant, no storage cost until modification
11. Clone does NOT include Time Travel history
12. Time Travel: 1 day Standard, up to 90 days Enterprise+ (permanent tables)
13. Transient/Temporary tables: max 1 day Time Travel regardless of edition
14. UNDROP = recover within Time Travel period
15. Fail-safe: 7 days, permanent tables only, Snowflake-managed (can't access directly)
16. DATA_RETENTION_TIME_IN_DAYS = 0 disables Time Travel
17. Consumer sees Provider's updates immediately
18. No limit on Reader Accounts per Provider

---

## CONFUSING PAIRS — Domain 5

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Who pays for shared data queries | Consumer (own warehouse) | Provider |
| Who pays for Reader Account | Provider (everything) | Consumer |
| Share a view | Must be Secure View | Regular view works |
| Who creates Share | ACCOUNTADMIN | SYSADMIN |
| Cross-region sharing needs | Replication first | Direct share |
| Fail-safe for transient | NONE | 7 days |
| Fail-safe access | Snowflake support only | Direct query |
| Time Travel max (transient) | 1 day | 90 days |
| Time Travel max (permanent, Enterprise) | 90 days | 1 day |
| Clone storage cost | Zero until modified | Full copy cost |
| Clone Time Travel history | NOT included | Included |
| Marketplace public listing | Anyone can see | Invited only |
| Marketplace private listing | Invited accounts only | Public |
| Failover edition | Business Critical+ | Enterprise |
| UNDROP works during | Time Travel period | Fail-safe |
| Secondary database | Read-only | Read-write |

---

## BRAIN-FRIENDLY SUMMARY — Domain 5

### SCENARIO DECISION TREES
When you read a question, find the pattern:

**"A pharmaceutical company wants to share clinical trial results with a partner hospital that also uses Snowflake..."**
→ Direct Share (Provider creates SHARE, Consumer creates database FROM SHARE)
→ No data copied, real-time access, zero storage cost for sharing

**"A startup wants to share data with a small vendor who does NOT have a Snowflake account..."**
→ Reader Account (Provider creates it, Provider pays for EVERYTHING)
→ Consumer gets limited read-only access

**"Who pays when a consumer queries shared data?"**
→ CONSUMER pays (uses their own warehouse)
→ Provider pays NOTHING for consumer's queries

**"Who pays when a Reader Account user queries shared data?"**
→ PROVIDER pays (Reader Account = Provider pays everything — compute + storage)

**"A global company in AWS US-West needs to share data with their team in Azure Europe..."**
→ Step 1: Replicate the database to the other region/cloud FIRST
→ Step 2: Then create a Share in that region
→ Cannot direct-share across regions without replication

**"A company's primary region goes down. How do they keep running?"**
→ Failover: promote secondary database/account to primary (Business Critical+)
→ NOT just replication (replication copies data, failover switches the active one)

**"The provider updates a shared table. When does the consumer see the change?"**
→ IMMEDIATELY (no delay, no refresh needed — it's the same data)

**"A client wants to share a view with another account..."**
→ Must be a SECURE VIEW (regular views CANNOT be shared)
→ Also works: Secure UDFs, Secure Materialized Views

**"A data provider wants to list their weather data for any Snowflake customer to discover..."**
→ Marketplace Public Listing (visible to all Snowflake accounts)

**"Two competing banks want to find customer overlap without revealing their full customer lists..."**
→ Data Clean Room (multi-party analysis, raw data stays private)

**"A software vendor wants to distribute an analytics app that runs inside the customer's Snowflake account..."**
→ Native App (Provider builds Application Package, Consumer installs it)
→ App runs in Consumer's account, data stays private

**"A team needs to create a copy of production for testing, without doubling storage costs..."**
→ Clone (CREATE ... CLONE — zero-copy, instant, no extra storage until changes)

**"Does a clone include the original table's Time Travel history?"**
→ NO. Clone starts fresh. No historical snapshots from the source.

**"A developer accidentally dropped a table 2 hours ago..."**
→ UNDROP TABLE (within Time Travel retention period)
→ If past Time Travel → might be in Fail-safe (contact Snowflake support)

**"Can you query data from Fail-safe directly?"**
→ NO. Only Snowflake support can recover Fail-safe data. You cannot access it yourself.

**"A transient table was dropped. Can Fail-safe recover it?"**
→ NO. Transient and Temporary tables have NO Fail-safe.

**"An Enterprise account wants 90-day Time Travel on a transient table..."**
→ IMPOSSIBLE. Transient/Temporary tables max out at 1 day regardless of edition.

**"A consumer receives a share and wants to modify the data they received..."**
→ CANNOT modify shared data directly (read-only)
→ Must CREATE TABLE ... AS SELECT from the shared view/table to get a local copy they own

**"A client clones an entire database. Do the child tables keep their privileges?"**
→ YES. When cloning a DATABASE or SCHEMA, child objects inherit privileges from source.
→ But cloning a SINGLE TABLE → privileges are NOT copied.

**"A client wants to clone a table as it existed 3 days ago..."**
→ CREATE TABLE clone_name CLONE source AT(TIMESTAMP => '2024-01-01 12:00:00')
→ Combines Clone + Time Travel in one command

**"A client wants to know the total storage cost of a table including Time Travel and Fail-safe..."**
→ TABLE_STORAGE_METRICS (ACCOUNT_USAGE)
→ Shows: active bytes + time travel bytes + fail-safe bytes

**"A provider wants to share data with 50 different Snowflake accounts..."**
→ One Share can have multiple consumers (one-to-many)
→ Or use Marketplace listing for broader distribution

**"A consumer reshares data they received from a provider to a third party..."**
→ Resharing is possible IF the provider allows it
→ Creates a chain of sharing

**"A client asks: what objects CANNOT be cloned?"**
→ External tables and internal (user/table) stages CANNOT be cloned
→ Named stages CAN be cloned

**"A client's secondary database hasn't been refreshed in 48 hours. Is the data current?"**
→ NO. Secondary databases need to be refreshed to stay current.
→ Refresh can be automated with replication schedules (ALTER DATABASE ... SET REPLICATION_SCHEDULE) or done manually (ALTER DATABASE ... REFRESH)
→ They don't auto-refresh like Dynamic Tables, but scheduling automates the process

**"A provider builds a Native App that includes a Streamlit UI and stored procedures..."**
→ All packaged in an Application Package
→ Consumer installs → app runs in Consumer's account
→ Provider can push updates (versioning)

**"A client wants to query data as it was exactly before a specific DELETE statement ran..."**
→ BEFORE(STATEMENT => 'query_id')
→ NOT AT (AT gives data at the time, BEFORE gives data just before the statement)

**"A client sets DATA_RETENTION_TIME_IN_DAYS = 0 on a table. What happens?"**
→ Time Travel is DISABLED for that table
→ No UNDROP, no AT/BEFORE queries, no historical access
→ Fail-safe still applies (if permanent table)

---

### MNEMONICS TO LOCK IN

**Sharing billing = "Provider Stores, Consumer Computes"**
- Provider pays for storage (they own the data)
- Consumer pays for compute (they run the queries with their warehouse)
- EXCEPTION: Reader Account → Provider pays BOTH

**Share creation = "Only the Boss"**
- Only ACCOUNTADMIN can create Share objects
- NOT SYSADMIN, NOT SECURITYADMIN

**What can be shared = "Secure Only" → tables + secure views/UDFs/MVs**
- Regular views → NO
- Stages, Pipes, Tasks → NO

**Time Travel retention = "1-90-1" rule**
- Standard edition: max 1 day (all table types)
- Enterprise+: up to 90 days (permanent tables only)
- Transient/Temporary: max 1 day (ANY edition)

**Data lifecycle = "A-T-F-G" → "Active, Travel, Failsafe, Gone"**
- **A**ctive data → current
- **T**ime Travel → 1-90 days (you can query/UNDROP)
- **F**ail-safe → 7 days (Snowflake support only, permanent tables only)
- **G**one → permanently deleted

**Clone = "Copy the Pointer, Not the Data"**
- Instant, zero storage cost
- Independent after creation
- No Time Travel history from source

**Failover edition = "BC+" (Business Critical and above)**
- Replication = any edition
- Failover = BC+ only

**Marketplace = "Public vs Private"**
- Public listing → everyone sees it
- Private listing → invitation only

---

### TOP TRAPS — Domain 5

1. **"Consumer pays for shared data storage"** → WRONG. Provider pays storage. Consumer pays compute.
2. **"Reader Account: consumer pays"** → WRONG. Provider pays EVERYTHING for Reader Accounts.
3. **"SYSADMIN can create Shares"** → WRONG. Only ACCOUNTADMIN.
4. **"Regular views can be shared"** → WRONG. Must be Secure Views.
5. **"Direct share works cross-region"** → WRONG. Need replication first.
6. **"Provider updates are delayed for consumers"** → WRONG. Immediate visibility.
7. **"Clone doubles storage"** → WRONG. Zero cost until data is modified.
8. **"Clone includes Time Travel history"** → WRONG. Clone starts fresh.
9. **"Transient tables have Fail-safe"** → WRONG. No Fail-safe (permanent tables only).
10. **"You can query Fail-safe data"** → WRONG. Snowflake support only.
11. **"Transient table + Enterprise = 90-day Time Travel"** → WRONG. Max 1 day regardless.
12. **"Failover works on Standard edition"** → WRONG. Business Critical+ only.

---

### PATTERN SHORTCUTS — "If you see ___, answer is ___"

| If the question mentions... | The answer is almost always... |
|---|---|
| "share data, no copy" | Secure Data Sharing |
| "consumer has no SF account" | Reader Account |
| "who pays compute on shared data" | Consumer (own warehouse) |
| "who pays for Reader Account" | Provider (everything) |
| "who creates Share object" | ACCOUNTADMIN only |
| "share a view" | Must be Secure View |
| "cross-region sharing" | Replicate first, then share |
| "primary region is down" | Failover (BC+) |
| "secondary database is..." | Read-only (until promoted) |
| "provider updates, consumer sees when" | Immediately |
| "zero-copy, instant copy" | CLONE |
| "clone storage cost" | Zero until modified |
| "clone Time Travel history" | NOT included |
| "recover dropped table" | UNDROP (within Time Travel period) |
| "recover after Time Travel expires" | Fail-safe (Snowflake support, permanent only) |
| "7 days after Time Travel" | Fail-safe period |
| "DATA_RETENTION_TIME_IN_DAYS = 0" | Disables Time Travel |
| "transient table max Time Travel" | 1 day (any edition) |
| "permanent table max TT, Enterprise" | 90 days |
| "data products marketplace" | Snowflake Marketplace |
| "public listing" | Anyone can discover |
| "private listing" | Invited accounts only |
| "app runs in consumer's account" | Native App |
| "multi-party analysis, data private" | Data Clean Room |
| "Application Package" | Native App Framework |

---

## EXAM DAY TIPS — Domain 5 (10% = ~10 questions)

**Before studying this domain:**
- Smallest domain but EASY POINTS — don't skip it
- Flashcard: who pays for what in sharing (Provider stores, Consumer computes, Reader = Provider pays all)
- Flashcard: Time Travel retention rules (1-90-1: Standard=1 day, Enterprise+=90 days permanent, Transient=1 day always)
- Know Clone behavior: zero-copy, no TT history, privileges differ (database clone = yes, table clone = no)

**During the exam — Domain 5 questions:**
- Read the LAST sentence first — then read the scenario
- Eliminate 2 obviously wrong answers immediately
- If they ask WHO PAYS → Provider stores, Consumer computes. EXCEPTION: Reader Account = Provider pays all.
- If they ask about SHARING A VIEW → must be Secure View (regular views cannot be shared)
- If they ask about CROSS-REGION → replication first, then share
- If they ask about RECOVERY → Time Travel window = UNDROP. Past TT = Fail-safe (SF support only). Past both = gone.
- If they mention CLONE → zero storage, instant, independent, NO Time Travel history from source

---

## ONE-LINE PER TOPIC — Domain 5

| Topic | One-line summary |
|---|---|
| Database Replication | Primary (read-write) → Secondary (read-only). Cross-region/cloud. Any edition. |
| Account Replication | Replicate users, roles, warehouses for disaster recovery. |
| Failover | Promote secondary to primary when primary is down. BC+ only. |
| Secure Data Sharing | No copy, real-time, zero movement cost. Provider → Consumer. |
| Share object | Created by ACCOUNTADMIN only. GRANT objects TO SHARE. |
| Provider billing | Pays for storage. Does NOT pay for consumer's queries. |
| Consumer billing | Pays for compute (uses own warehouse). Does NOT pay for storage. |
| Reader Accounts | For consumers without SF account. Provider pays EVERYTHING. Limited read-only. |
| Shareable objects | Tables, Secure Views, Secure UDFs, Secure MVs. NOT: regular views, stages, pipes. |
| Cross-region sharing | Replicate database first → then create Share in that region. |
| Marketplace | Public listings (anyone) vs Private listings (invited only). |
| Data Exchange | Private hub for controlled group. Provider decides who joins. |
| Native Apps | Application Package → Consumer installs → runs in Consumer's account. Streamlit UI + code. |
| Data Clean Rooms | Multi-party analysis, each party's raw data stays private. |
| Cloning | Zero-copy, instant, independent. No TT history. DB/schema clone keeps privileges. |
| Time Travel | AT(TIMESTAMP/OFFSET/STATEMENT), BEFORE(STATEMENT). 1-90 days depending on edition+table type. |
| UNDROP | Recover dropped table/schema/database within Time Travel retention. |
| Fail-safe | 7 days after TT expires. Permanent tables only. Snowflake support only. |
| DATA_RETENTION_TIME_IN_DAYS | Set at account/database/schema/table level. 0 = disable TT. |
| AT vs BEFORE | AT = data at that moment. BEFORE = data just before a statement executed. |
| Clone + Time Travel | Can clone at past point: CLONE source AT(TIMESTAMP => '...'). |
| Clone privileges | Database/schema clone = child privileges kept. Single table clone = NO privileges. |
| Resharing | Consumer can reshare if Provider allows. Creates sharing chain. |

---

## FLASHCARDS — Domain 5

**Q:** What is Secure Data Sharing?
**A:** Sharing live data between Snowflake accounts with zero copy and zero data movement. Provider creates a SHARE object, consumer creates a database FROM SHARE. Data stays in provider's storage.

**Q:** Who pays for what in data sharing?
**A:** Provider pays for storage. Consumer pays for compute (their own warehouse). No data transfer costs within the same region.

**Q:** Who can create a SHARE object?
**A:** Only ACCOUNTADMIN can create shares and grant objects to them.

**Q:** What objects CAN be shared?
**A:** Tables, secure views, secure materialized views, secure UDFs. Must be SECURE variants for views/UDFs.

**Q:** What objects CANNOT be shared?
**A:** Regular (non-secure) views, stages, pipes, tasks, streams, sequences, file formats.

**Q:** What is a Reader Account?
**A:** A Snowflake account created BY the provider FOR consumers who don't have their own Snowflake account. Provider pays for EVERYTHING (storage + compute). Reader accounts are read-only and limited.

**Q:** How does cross-region sharing work?
**A:** You must first replicate the database to the target region, then create a share in that region. Direct cross-region sharing is not possible without replication.

**Q:** What is the difference between Marketplace and Data Exchange?
**A:** Marketplace: public or private listings visible to all Snowflake customers. Data Exchange: private hub where the provider controls exactly who can join and access data.

**Q:** What is a Native App?
**A:** An installable application built with an Application Package. Consumer installs it in their own account. Can include Streamlit UI, stored procedures, and logic. Code runs in consumer's account.

**Q:** What is a Data Clean Room?
**A:** A secure environment for multi-party data analysis where each party's raw data stays private. Only agreed-upon aggregate results are shared.

**Q:** What does zero-copy cloning mean?
**A:** CLONE creates an instant, independent copy that initially points to the same micro-partitions. No data is physically copied until one side modifies data. It's free at creation.

**Q:** Does a clone inherit Time Travel history?
**A:** No. A clone starts fresh — it has no Time Travel history from the source. TT begins from the moment of cloning.

**Q:** What privileges does a clone get?
**A:** Database/schema clone: child object privileges are copied. Single table clone: NO privileges are copied.

**Q:** What is Time Travel?
**A:** Ability to query historical data using AT or BEFORE clauses. Retention period: 0-1 day (Standard), 0-90 days (Enterprise+). Set via DATA_RETENTION_TIME_IN_DAYS.

**Q:** AT vs BEFORE — what's the difference?
**A:** AT(TIMESTAMP => X) = data as it existed at that exact moment. BEFORE(STATEMENT => 'query_id') = data just before that statement executed.

**Q:** What is UNDROP?
**A:** Recovers a dropped table, schema, or database — but only within the Time Travel retention period. After that, the object is gone to Fail-safe.

**Q:** What is Fail-safe?
**A:** 7 additional days of data protection AFTER Time Travel expires. Only for permanent tables. Only Snowflake support can recover data — you cannot access it yourself.

**Q:** Which table types have Fail-safe?
**A:** Only permanent tables. Transient and temporary tables have ZERO Fail-safe.

**Q:** Can you clone to a past point in time?
**A:** Yes. `CREATE TABLE clone_t CLONE source AT(TIMESTAMP => '2024-01-01')` creates a clone of the source as it was at that timestamp.

**Q:** What is Database Replication?
**A:** Copying a database to another Snowflake account (same or different region/cloud). Used for disaster recovery (failover) and cross-region data sharing. Primary → secondary → can promote secondary.

---

## EXPLAIN LIKE I'M 5 — Domain 5

**Secure Data Sharing**: You let your friend look at your toy through a window — they can see it and play with it, but you never hand it over. No copying, no shipping.

**Reader Account**: Your friend doesn't have a Snowflake account, so you create a mini-account for them and pay their bills too. They can only look, not build.

**SHARE object**: A special box where you put the things you want to share. Only the boss (ACCOUNTADMIN) can make the box.

**Secure view**: A window that only shows certain toys from your collection — hides the ones you don't want others to see. Must be "secure" to share.

**Marketplace**: A store where anyone can browse data listings. Some are free, some cost money. Like an app store for data.

**Data Exchange**: A private club — only people you invite can see and use the data. Not open to the public.

**Native App**: A complete app you build and give to someone else to install in THEIR house. It runs on their electricity (compute), not yours.

**Data Clean Room**: Two kids want to compare toy collections without showing each other everything. They use a magic room that only tells them "you both have 5 matching toys" without revealing which ones.

**Zero-copy clone**: Making a photocopy that's actually magic — it looks real, weighs nothing, and costs nothing. Only starts costing when someone draws on their copy.

**Time Travel**: A time machine for your data. Go back and see what your table looked like yesterday, or right before someone accidentally deleted everything.

**UNDROP**: An "undo delete" button. Dropped a table? Say UNDROP and it comes back — but only if you're still within the Time Travel window.

**Fail-safe**: After your time machine expires, Snowflake keeps a secret backup for 7 more days in a vault only they can open. Emergency use only.

**AT vs BEFORE**: AT = "show me the photo taken at 3pm." BEFORE = "show me the photo taken right before the accident happened."

**Database Replication**: Making a live backup copy of your entire database in another city. If the first city has a disaster, you switch to the copy.

**Resharing**: Your friend shares your toys with THEIR friend. Only allowed if you say it's OK. Creates a chain of sharing.
