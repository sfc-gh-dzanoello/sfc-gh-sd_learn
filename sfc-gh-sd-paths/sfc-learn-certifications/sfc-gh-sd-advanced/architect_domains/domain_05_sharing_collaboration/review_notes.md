# Domain 5: Sharing & Collaboration — Data Sharing Solutions

> **ARA-C01 Weight:** ~10-15% of the exam.
> Focus on: sharing mechanics, cross-region/cloud patterns, reader accounts, marketplace, and Native Apps.

---

## 5.1 SECURE DATA SHARING

The **zero-copy sharing** model is Snowflake's core differentiator.

### Key Concepts

- **Provider**: the account that owns the data and creates the share
- **Consumer**: the account that receives the share and creates a database from it
- Sharing is **zero-copy** — no data is duplicated; consumer reads from provider's storage
- Provider pays for **storage**; consumer pays for **compute** (their own warehouse)
- Sharing uses **shares** — named objects containing databases, schemas, tables, secure views, UDFs

**What can be shared:**

- Tables (full or filtered via secure views)
- Secure views, secure materialized views
- Secure UDFs
- Schemas (all objects in them)

**What CANNOT be shared directly:**

- Unsecured views (must be SECURE)
- Stages, pipes, tasks, streams
- Stored procedures
- Temporary/transient tables

**Share creation flow:**

```sql
CREATE SHARE my_share;
GRANT USAGE ON DATABASE mydb TO SHARE my_share;
GRANT USAGE ON SCHEMA mydb.public TO SHARE my_share;
GRANT SELECT ON TABLE mydb.public.customers TO SHARE my_share;
ALTER SHARE my_share ADD ACCOUNTS = consumer_account;
```

**Consumer side:**

```sql
CREATE DATABASE shared_db FROM SHARE provider_account.my_share;
```

### Why This Matters

A healthcare provider needs to share anonymized patient data with a research partner. They create a secure view that masks PII, add it to a share, and the partner queries it directly — no data copies, no ETL pipelines, no stale data. Real-time, always fresh.

### Best Practices

- Always use **secure views** to control what consumers see (row-level and column-level filtering)
- Grant the minimum objects needed — don't share entire databases unless necessary
- Monitor shared data access via `SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY`
- Document your shares and review them quarterly

**Exam traps:**

- Exam trap: IF YOU SEE "Consumer pays for storage of shared data" → WRONG because the **provider** pays for storage; the consumer only pays for compute
- Exam trap: IF YOU SEE "Regular views can be shared" → WRONG because only **secure views** can be included in shares; non-secure views expose internal logic
- Exam trap: IF YOU SEE "Shared data can be modified by the consumer" → WRONG because shared data is **read-only** to consumers; they cannot INSERT/UPDATE/DELETE
- Exam trap: IF YOU SEE "Shares create a copy of the data" → WRONG because shares are **zero-copy**; consumers query the provider's micro-partitions directly

### Common Questions (FAQ)

**Q: Can a consumer re-share data they received?**
A: No. Consumers cannot create shares from shared databases. Data chain-sharing is blocked by design.

**Q: Does the provider see consumer queries?**
A: No. The provider has no visibility into consumer query activity. Consumers control their own usage.

---

## 5.2 SHARING SCENARIOS

Different sharing topologies have different requirements.

### Key Concepts

| Scenario | Mechanism | Notes |
|----------|-----------|-------|
| **Same account** | Not applicable — just use RBAC | Sharing is between accounts, not within |
| **Same region, same cloud** | Direct share | Simplest — zero-copy, no replication |
| **Cross-region (same cloud)** | Database replication + share | Replicate data to target region first, then share |
| **Cross-cloud** | Database replication + share | Same as cross-region but across AWS/Azure/GCP |
| **Non-Snowflake customer** | Reader account | Provider creates a managed account for the consumer |

**Cross-region / cross-cloud flow:**

1. Provider enables replication: `ALTER DATABASE mydb ENABLE REPLICATION TO ACCOUNTS target_account`
2. Target account creates replica: `CREATE DATABASE mydb AS REPLICA OF source_account.mydb`
3. Refresh replica: `ALTER DATABASE mydb REFRESH`
4. Create share in target region using replicated database
5. OR: use **Listing + Cross-Cloud Auto-Fulfillment** (handles replication automatically)

**Key point:** Direct sharing only works within the **same region and cloud provider**. Anything cross-region or cross-cloud requires replication first (or auto-fulfillment).

### Why This Matters

A global retail company on AWS us-east-1 needs to share sales data with a partner on Azure West Europe. They must replicate the database to an Azure West Europe account first, then create the share there. Without understanding this, architects propose direct sharing and it silently fails.

### Best Practices

- For frequent cross-region sharing, use **Listings with Auto-Fulfillment** — it automates replication
- Monitor replication costs in `REPLICATION_USAGE_HISTORY`
- Cross-cloud replication has data transfer costs — factor this into your architecture
- Use database replication groups for multi-database scenarios

**Exam traps:**

- Exam trap: IF YOU SEE "Direct sharing works across regions" → WRONG because direct sharing requires **same region AND same cloud**; cross-region needs replication first
- Exam trap: IF YOU SEE "Cross-cloud sharing is not possible in Snowflake" → WRONG because it IS possible via **database replication** to the target cloud/region, then sharing
- Exam trap: IF YOU SEE "Auto-Fulfillment eliminates all replication costs" → WRONG because auto-fulfillment automates replication but the **data transfer costs still apply**

### Common Questions (FAQ)

**Q: Can I share between two accounts in the same organization but different regions?**
A: Yes, via database replication + share, or through a Marketplace listing with Auto-Fulfillment.

**Q: Is replication real-time?**
A: No. Replication is near-real-time with a configurable refresh schedule. There is always some lag.

---

## 5.3 READER ACCOUNTS

For sharing with organizations that **do NOT have a Snowflake account**.

### Key Concepts

- Created by the **provider** using `CREATE MANAGED ACCOUNT`
- Reader accounts are **managed accounts** — fully controlled by the provider
- **Provider pays for EVERYTHING**: storage and compute
- Reader account users can only query shared data — they cannot load their own data
- Limited functionality: no data loading, no shares from reader accounts, minimal administration

**Capabilities of Reader accounts:**

- Query shared data via their own warehouse (provider-funded)
- Create users within the reader account
- Use resource monitors (to control costs)

**Cannot do:**

- Load data into the account
- Create shares
- Access Snowflake Marketplace
- Use advanced features (tasks, streams, etc.)
- Replicate data

### Why This Matters

A government agency wants to share public datasets with small municipalities that can't justify a Snowflake subscription. Reader accounts let the agency share data without requiring the municipality to sign a Snowflake contract. But the agency pays all compute costs — so resource monitors are essential.

### Best Practices

- **Always** set resource monitors on reader account warehouses — you pay their compute
- Keep reader account warehouses small (X-Small or Small)
- Set aggressive auto-suspend (60 seconds)
- Periodically audit reader account usage via `RESOURCE_MONITORS` and `MANAGED_ACCOUNTS`
- Consider Marketplace listings instead if you want consumers to pay their own way

**Exam traps:**

- Exam trap: IF YOU SEE "Reader accounts can load their own data" → WRONG because reader accounts can **only query shared data**; no data loading is permitted
- Exam trap: IF YOU SEE "Consumer pays for reader account compute" → WRONG because the **provider pays everything** — storage AND compute for reader accounts
- Exam trap: IF YOU SEE "Reader accounts can create shares to other accounts" → WRONG because reader accounts cannot create shares, period

### Common Questions (FAQ)

**Q: Can a reader account be upgraded to a full Snowflake account?**
A: No. Reader accounts cannot be converted. The organization would need to sign their own Snowflake contract and you'd set up a regular share.

**Q: How many reader accounts can a provider create?**
A: There is no hard limit documented, but Snowflake may impose soft limits. Contact support for very large numbers.

---

## 5.4 MARKETPLACE & DATA EXCHANGE

Marketplace is Snowflake's public data catalog. Data Exchange is private.

### Key Concepts

**Snowflake Marketplace:**

- Public catalog where providers **list** datasets for any Snowflake customer to discover
- Free or paid listings
- **Personalized listings** — tailored to specific consumers
- **Standard listings** — available to anyone
- Consumers get data instantly — zero-copy sharing under the hood
- Providers: Snowflake, third-party data vendors, any Snowflake customer

**Data Exchange (Private):**

- **Private, invitation-only** group of accounts for sharing
- Created by a Snowflake customer or Snowflake itself
- Members can publish and discover listings within the group
- Use case: internal departments, trusted partners, industry consortiums

**Cross-Cloud Auto-Fulfillment:**

- Marketplace feature that **automatically replicates** listings to consumers in different regions/clouds
- Provider publishes once → Snowflake handles replication to wherever the consumer is
- Provider pays data transfer/replication costs
- Removes the manual replication burden from cross-region/cross-cloud sharing

### Why This Matters

A weather data company publishes daily forecasts on Snowflake Marketplace. A retail chain on Azure East US discovers it, clicks "Get," and instantly has a shared database — no negotiations, no data pipelines, no ETL. Cross-Cloud Auto-Fulfillment means the weather company doesn't need accounts in every region.

### Best Practices

- Use Marketplace for **public or semi-public** data distribution
- Use Data Exchange for **private** sharing within a trusted group
- Enable Auto-Fulfillment if your consumers span multiple regions/clouds
- Monitor listing usage to understand demand and optimize costs
- Write clear listing descriptions — consumers discover data through search

**Exam traps:**

- Exam trap: IF YOU SEE "Data Exchange is the same as Marketplace" → WRONG because Marketplace is **public**, Data Exchange is **private and invitation-only**
- Exam trap: IF YOU SEE "Auto-Fulfillment is free for providers" → WRONG because providers still pay **data replication and transfer costs**
- Exam trap: IF YOU SEE "Consumers must be in the same region to use Marketplace" → WRONG because **Auto-Fulfillment** handles cross-region/cross-cloud delivery automatically

### Common Questions (FAQ)

**Q: Can I charge for Marketplace listings?**
A: Yes. Snowflake supports paid listings with usage-based or fixed pricing, managed through the provider dashboard.

**Q: Who manages billing for paid listings?**
A: Snowflake handles billing. Consumers pay through their Snowflake bill, and Snowflake remits to the provider.

---

## 5.5 DATA CLEAN ROOMS

Secure multi-party data analysis without exposing raw data.

### Key Concepts

- **Purpose:** Two or more parties analyze overlapping data without seeing each other's raw data
- Built on Snowflake's sharing + secure views + privacy controls
- **Snowflake Data Clean Rooms** — managed product (powered by Native App Framework)
- Typical use case: advertiser + publisher measuring campaign overlap without exposing customer lists
- **Key guarantee:** no party sees the other's row-level data — only aggregated/anonymized results

**How it works (simplified):**

1. Party A shares their data into the clean room
2. Party B shares their data into the clean room
3. Pre-approved queries (templates) run on the overlap
4. Results returned are aggregated — minimum thresholds prevent individual identification
5. Neither party downloads the other's raw data

**Privacy controls:**

- **Differential privacy** — adds statistical noise to prevent re-identification
- **Minimum aggregation thresholds** — query results must represent N+ individuals
- **Column policies** — restrict which columns are joinable/visible

### Why This Matters

A bank and a retailer want to understand shared customers for a co-branded credit card. Neither can share customer lists due to regulations. A data clean room lets them compute "overlap size" and "average spend" without either party seeing individual records.

### Best Practices

- Define **analysis templates** upfront — restrict ad-hoc queries
- Set meaningful minimum aggregation thresholds (e.g., minimum 100 individuals per group)
- Use Snowflake's managed clean room product rather than building from scratch
- Audit all clean room queries and results
- Involve legal/compliance teams in clean room design

**Exam traps:**

- Exam trap: IF YOU SEE "Data clean rooms let parties see each other's data" → WRONG because clean rooms **prevent** raw data exposure; only aggregated results are returned
- Exam trap: IF YOU SEE "Clean rooms require data to be copied to a third party" → WRONG because Snowflake clean rooms use **zero-copy sharing** — data stays in each party's account
- Exam trap: IF YOU SEE "Any query can run in a clean room" → WRONG because queries are restricted to **pre-approved templates** to prevent data leakage

### Common Questions (FAQ)

**Q: Can more than two parties participate in a clean room?**
A: Yes. Multi-party clean rooms are supported, though complexity increases.

**Q: Is a clean room a separate Snowflake account?**
A: The clean room logic runs as a Native App installed in the participating accounts. Data stays in each party's account.

---

## 5.6 NATIVE APPS

The **Snowflake Native App Framework** lets providers package code + data as installable applications.

### Key Concepts

**Application Package:**

- The **provider-side** container for the app
- Contains: setup scripts, versioned code, shared data content, Streamlit UI, stored procedures, UDFs
- Created with `CREATE APPLICATION PACKAGE`
- Versioned: `ALTER APPLICATION PACKAGE ADD VERSION v1_0 USING '@stage/v1'`

**Native App (Consumer-side):**

- Installed by the consumer from a listing or directly
- Created from an Application Package
- Runs **inside the consumer's account** — provider cannot see consumer data
- Can request **privileges** from the consumer (e.g., access to specific tables)
- Consumer controls what access to grant

**What Native Apps can include:**

- Stored procedures and UDFs (SQL, Python, Java, Scala, JavaScript)
- Streamlit dashboards (UI)
- Shared data content (reference data)
- Tasks and streams (for automated processing)
- External access integrations (call external APIs)

**Setup script (`setup.sql`):**

- Runs when the consumer installs the app
- Creates all internal objects (schemas, views, procedures, etc.)
- Defines **application roles** that map to consumer-granted privileges

### Why This Matters

A data enrichment company builds a Native App that takes a consumer's customer table, enriches it with third-party demographic data, and returns results — all without the consumer's data ever leaving their account. The provider distributes through Marketplace, and each consumer gets their own isolated install.

### Best Practices

- Use **versioned patches** for app updates (consumers can upgrade at their pace)
- Minimize privilege requests — ask only for what the app truly needs
- Include a Streamlit UI for non-SQL users
- Test apps thoroughly in a dev application package before publishing
- Use `manifest.yml` to declare required privileges and configuration

**Exam traps:**

- Exam trap: IF YOU SEE "Native Apps run in the provider's account" → WRONG because Native Apps run **inside the consumer's account**; provider cannot see consumer data
- Exam trap: IF YOU SEE "Native Apps automatically have access to consumer data" → WRONG because the consumer must **explicitly grant** privileges; the app requests them, the consumer approves
- Exam trap: IF YOU SEE "Native Apps are just shared databases" → WRONG because Native Apps can include **code** (procedures, UDFs, Streamlit), not just data

### Common Questions (FAQ)

**Q: Can a Native App write data to the consumer's account?**
A: Yes, if the consumer grants the necessary privileges (e.g., CREATE TABLE in a schema).

**Q: How do consumers get updates to Native Apps?**
A: Providers publish new versions/patches. Consumers can upgrade manually or the provider can set auto-upgrade.

---

## 5.7 SECURITY PATTERNS FOR SHARING

Security is non-negotiable when sharing data.

### Key Concepts

**Secure views are required:**

- Regular views expose their definition (SQL) to anyone with `SHOW VIEWS`
- Secure views hide the definition and prevent optimizer-based data inference
- **All views in shares MUST be secure** — Snowflake enforces this
- Trade-off: secure views may have slightly different optimization (query optimizer restrictions)

**Share privileges hierarchy:**

```
SHARE
  └── USAGE on DATABASE
       └── USAGE on SCHEMA
            └── SELECT on TABLE / VIEW / MATERIALIZED VIEW
            └── USAGE on UDF
```

- Must grant at every level — granting SELECT on a table without USAGE on its schema won't work
- `GRANT REFERENCE_USAGE ON DATABASE` — allows consumer to create views that reference shared data

**Cross-region sharing requires replication first:**

- You cannot create a share and add a consumer in a different region directly
- Must replicate the database (or use Auto-Fulfillment for listings)
- Replication can be continuous (`REPLICATION_SCHEDULE`) or manual (`ALTER DATABASE REFRESH`)

**Secure UDFs in shares:**

- UDF source code is hidden from consumers (just like secure view definitions)
- Consumers can call them but cannot inspect their logic

### Why This Matters

An architect shares a view containing financial data but forgets to make it secure. The consumer runs `SHOW VIEWS` and sees the SQL definition, which reveals hidden filtering logic and table names. Now they know about tables they shouldn't. Secure views prevent this.

### Best Practices

- **Always** use secure views — never share regular views
- Grant privileges at the most granular level possible
- Use secure UDFs for business logic you don't want to expose
- For cross-region consumers, plan replication lag into your SLAs
- Audit shares regularly: `SHOW SHARES`, `DESCRIBE SHARE`

**Exam traps:**

- Exam trap: IF YOU SEE "Regular views can be added to shares" → WRONG because Snowflake **requires secure views** in shares; you'll get an error adding a non-secure view
- Exam trap: IF YOU SEE "Granting SELECT on a table is enough for sharing" → WRONG because you must also grant **USAGE on the DATABASE and SCHEMA**
- Exam trap: IF YOU SEE "Secure views have identical performance to regular views" → WRONG because secure views restrict certain **optimizer behaviors** to prevent data leakage, which can slightly impact performance

### Common Questions (FAQ)

**Q: Can I share a secure materialized view?**
A: Yes. Secure materialized views can be included in shares.

**Q: If I drop and recreate a table that's in a share, does the consumer lose access?**
A: Yes. The share references the specific object. You must re-grant after recreating.

---

## FLASHCARDS — Domain 5

**Q1: Who pays for storage in a direct share?**
A1: The **provider** pays for storage. The consumer pays only for their own compute.

**Q2: Can a consumer modify shared data?**
A2: **No.** Shared data is read-only for consumers.

**Q3: What is required to share data cross-region?**
A3: **Database replication** to the target region first, then create the share there. Or use Marketplace with Auto-Fulfillment.

**Q4: What type of view MUST be used in shares?**
A4: **Secure views** — regular views are not allowed in shares.

**Q5: Who pays for compute in a reader account?**
A5: The **provider** pays for everything — both storage and compute.

**Q6: Can reader accounts load their own data?**
A6: **No.** Reader accounts can only query shared data.

**Q7: What is Cross-Cloud Auto-Fulfillment?**
A7: A Marketplace feature that **automatically replicates** listings to consumers in different regions/clouds, so the provider only publishes once.

**Q8: Where does a Native App run?**
A8: In the **consumer's account** — the provider cannot see consumer data.

**Q9: What is a Data Exchange?**
A9: A **private, invitation-only** group for sharing listings among trusted accounts. Unlike Marketplace, which is public.

**Q10: What prevents raw data exposure in a data clean room?**
A10: **Pre-approved query templates**, minimum aggregation thresholds, and differential privacy controls.

**Q11: Can a consumer re-share data received through a share?**
A11: **No.** Chain-sharing is not allowed by design.

**Q12: What file defines Native App metadata and privileges?**
A12: The **manifest.yml** file declares required privileges, configuration, and app metadata.

**Q13: What is the `REFERENCE_USAGE` privilege used for?**
A13: It allows a consumer to **create views in their own database that reference** objects in the shared database.

**Q14: How does a clean room ensure individual privacy?**
A14: Results must meet **minimum aggregation thresholds** (e.g., 100+ individuals per group) and may use **differential privacy** noise.

**Q15: What happens if underlying shared data changes?**
A15: Consumers see the changes **immediately** (for same-region shares) because sharing is zero-copy — they read the provider's live micro-partitions.

---

## EXPLAIN LIKE I'M 5 — Domain 5

**ELI5 #1: Secure Data Sharing**
You have a coloring book. Instead of photocopying pages for your friend (which wastes paper), you let them look at your book through a window. They can see and trace it, but they can't change your book, and you don't have two copies.

**ELI5 #2: Provider vs. Consumer**
You baked cookies (provider). Your friend eats them (consumer). You bought the ingredients (storage). Your friend uses their own plate and fork (compute).

**ELI5 #3: Reader Accounts**
Your friend doesn't have a plate or fork. So you give them yours. You're paying for everything — the cookies AND the plate and fork. That's a reader account.

**ELI5 #4: Cross-Region Sharing**
Your friend lives in another city. You can't just hold up the coloring book — they're too far away. You need to make a copy and send it to their city first (replication), then they can look through the window there.

**ELI5 #5: Marketplace**
Imagine a library where anyone can borrow any book for free (or a small fee). That's Marketplace. Anyone can browse, find datasets, and "borrow" them instantly.

**ELI5 #6: Data Exchange**
Now imagine a private book club. Only invited members can share and borrow books. That's Data Exchange.

**ELI5 #7: Data Clean Rooms**
You and your friend each have a bag of marbles. You want to know how many colors you share, but neither wants to show all their marbles. So you each put your bags in a magic box that only tells you "You share 3 colors" — not which specific marbles.

**ELI5 #8: Native Apps**
Someone builds a toy robot and puts it in a box with instructions. You install it in YOUR room, and it plays with YOUR toys. The builder never comes into your room — the robot works on its own.

**ELI5 #9: Secure Views**
A secure view is like a one-way mirror. You can see the data through it, but you can't see the blueprints of how the mirror was built or what's hidden behind the wall.

**ELI5 #10: Auto-Fulfillment**
You sell lemonade. Instead of setting up a stand in every neighborhood yourself, a magic helper automatically appears in any neighborhood where someone wants lemonade. You just make the recipe once.
