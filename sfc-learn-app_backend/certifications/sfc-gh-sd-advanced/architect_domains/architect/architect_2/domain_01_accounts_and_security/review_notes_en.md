# Domain 1: Account & Security Strategy

> **ARA-C01 Syllabus Coverage:** Account/DB Strategy, Security/Privacy/Compliance, Security Principles

---

## 1.1 ACCOUNT STRATEGY

**Single vs Multi-Account Architecture**

- **Single account:** simplest, all environments (dev/staging/prod) share one account
  - Cheaper, less overhead
  - Risk: blast radius is the entire account (a bad GRANT affects everything)
- **Multi-account:** separate accounts per environment, business unit, or region
  - Stronger isolation, independent security policies, separate billing
  - Required for strict compliance (e.g., PCI data in its own account)
- **Snowflake Organizations:** parent container that groups multiple accounts
  - Enables cross-account replication, failover groups, and centralized billing
  - ORGADMIN role manages accounts within the org
  - Account creation via `CREATE ACCOUNT` (ORGADMIN only)

**Exam trap:** IF YOU SEE "ACCOUNTADMIN can create new accounts" → WRONG because only ORGADMIN can create accounts within an Organization.

**Exam trap:** IF YOU SEE "Organizations require Enterprise edition" → WRONG because Organizations are available on all editions.

**Segmentation Patterns**

- **By environment:** dev / staging / prod accounts
- **By region:** accounts in different cloud regions for data residency
- **By business unit:** finance, marketing, engineering each get their own
- **By compliance:** PCI-scoped account, HIPAA-scoped account

**Exam trap:** IF YOU SEE "use a single account with separate databases for PCI isolation" → WRONG because PCI requires account-level isolation, not just database-level.

### Why This Matters
A healthcare company needs HIPAA data isolated from marketing analytics. Multi-account with org-level replication lets them share non-PHI data across accounts while keeping PHI locked down.

### Best Practices
- Use Organizations to centrally manage accounts and billing
- Replicate security objects (network policies, RBAC) via account replication
- Keep production accounts on Business Critical or higher edition for compliance

### Real-World Examples
- **Startup (10 engineers, 1 product):** Single account is fine. All dev/staging/prod in one account with separate databases. Low overhead, fast iteration. Switch to multi-account when you hit compliance requirements or team size >50.
- **Mid-size SaaS company (100 people, B2B analytics):** Multi-account by environment (dev/staging/prod). Prevents a bad deploy in dev from affecting production customers. Each account has its own RBAC and network policies.
- **Global retail chain (EU + US + APAC operations):** Multi-account by region. EU account in `aws_eu_central_1` for GDPR data residency. US account for North America. Replicate aggregated (non-PII) sales data to a central analytics account for global dashboards.
- **Bank processing credit card transactions:** Multi-account by compliance. Dedicated Business Critical account for PCI-scoped data (cardholder info). Separate account for non-PCI analytics (marketing, operations). PCI auditors only need to audit the PCI account, reducing audit scope.
- **Hospital network with PHI and research data:** Separate account for PHI (Business Critical + BAA) and a separate account for de-identified research datasets shared with universities. Organization ties them together for billing and replication.
- **Consulting firm with 20 clients:** One shared account with separate schemas per client for small engagements. For enterprise clients with contractual isolation requirements, spin up dedicated accounts per client within the Organization.

**When to recommend changing from single to multi-account:** When a client says "we need separate billing per business unit," "our auditor wants PCI scope reduced," "EU law requires data stays in EU," or "a developer accidentally dropped production" -- these are your arguments for multi-account.

### Common Questions (FAQ)
**Q: Can I share data across accounts without Organizations?**
A: Yes, via Secure Data Sharing (listings), but Organizations add replication, failover, and centralized management.

**Q: Does each account in an org get separate billing?**
A: By default billing is consolidated at the org level, but you can view per-account usage.

### Example Scenario Questions — Account Strategy

**Scenario:** A global insurance company operates in the EU, US, and APAC. EU regulations require that EU customer data never leaves EU soil. The US team needs access to aggregated (non-PII) metrics from all regions for global dashboards. How should the architect design the Snowflake account topology?
**Answer:** Deploy separate Snowflake accounts per region (EU, US, APAC) within a single Snowflake Organization. Each regional account stores its own customer data in a cloud region that satisfies data residency requirements. Use database replication to replicate non-PII aggregated datasets from EU and APAC accounts to the US account for global dashboards. ORGADMIN manages account creation and centralized billing. This ensures EU data never leaves the EU account while enabling cross-region analytics on safe aggregates.

**Scenario:** A fintech startup is growing from 10 to 500 employees and currently uses a single Snowflake account for dev, staging, and production. An intern accidentally ran a `GRANT ALL ON DATABASE prod_db TO ROLE PUBLIC` in production. What architectural change prevents this class of incident?
**Answer:** Migrate to a multi-account architecture with separate accounts for dev, staging, and production within a Snowflake Organization. This provides account-level blast radius isolation — a misconfigured GRANT in dev cannot affect production. Additionally, use managed access schemas in the production account so that only the schema owner (or MANAGE GRANTS holder) can issue grants, preventing ad-hoc privilege escalation by individual object owners. Replicate security objects across accounts using account replication for consistent RBAC.

---

## 1.2 PARAMETER HIERARCHY

**Three Levels (top to bottom):**

1. **Account** — set by ACCOUNTADMIN, applies globally
2. **Object** — set on warehouse, database, schema, table, user
3. **Session** — set by user for their current session (`ALTER SESSION`)

**Precedence Rule:** Most specific wins. Session > Object > Account.

**Exam trap:** IF YOU SEE "account parameter always overrides session parameter" → WRONG because session is more specific and wins.

**Key Parameters to Know:**

| Parameter | Typical Level | Notes |
|---|---|---|
| `STATEMENT_TIMEOUT_IN_SECONDS` | Account / Session | Kills long queries |
| `DATA_RETENTION_TIME_IN_DAYS` | Account / Object | Time Travel window (0-90) |
| `MIN_DATA_RETENTION_TIME_IN_DAYS` | Account only | Floor that objects cannot go below |
| `NETWORK_POLICY` | Account / User | User-level overrides account-level |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` | Account | Security hardening |

**Exam trap:** IF YOU SEE "MIN_DATA_RETENTION_TIME_IN_DAYS can be set on a schema" → WRONG because it is account-level only.

**Exam trap:** IF YOU SEE "a user-level network policy is additive to account-level" → WRONG because user-level network policy **replaces** the account-level policy for that user.

### Why This Matters
A DBA sets account-level timeout to 1 hour. A data scientist sets session timeout to 4 hours for a big ML job. The session-level wins for that user.

### Best Practices
- Set `MIN_DATA_RETENTION_TIME_IN_DAYS` at account level to prevent users from setting Time Travel to 0
- Use `STATEMENT_TIMEOUT_IN_SECONDS` on warehouses to prevent runaway queries
- Document which parameters are set at which level

**Warehouse Session Precedence**

- Default warehouse for user (base) > overridden by driver/connector config > overridden by command line parameter
- The most explicit specification wins at session establishment time

**Schema-Level Parameter Override**

- **Schema parameters override account parameters** for objects within that schema
- Example: `DATA_RETENTION_TIME_IN_DAYS` set on a schema overrides the account-level default for all tables in that schema (unless overridden again at the table level)

### Real-World Examples
- **E-commerce company (mixed workloads):** ETL warehouse gets `STATEMENT_TIMEOUT = 21600` (6 hours) for large batch loads. BI warehouse gets `STATEMENT_TIMEOUT = 600` (10 min) to kill runaway ad-hoc queries. Account-level stays at `3600` as safety net.
- **Financial services (regulatory retention):** Account-level `MIN_DATA_RETENTION_TIME_IN_DAYS = 7` so nobody can disable Time Travel. Audit tables get `DATA_RETENTION = 90` for regulatory lookback. Staging tables inherit the 7-day minimum floor.
- **Data science team (ML training):** Scientists set session-level `STATEMENT_TIMEOUT = 43200` (12 hours) for model training. This overrides the 1-hour account default only for their session, without affecting BI analysts.
- **Multi-tenant SaaS platform:** Each customer schema gets its own `DATA_RETENTION_TIME_IN_DAYS` based on tier: Free = 1 day, Pro = 30 days, Enterprise = 90 days. The account-level MIN ensures nobody goes below 1 day.
- **Security-conscious enterprise:** `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` at account level. Forces all external access through governed storage integrations -- prevents developers from creating stages with raw AWS keys pasted in SQL.

### Common Questions (FAQ)
**Q: If I set DATA_RETENTION_TIME_IN_DAYS = 1 on a table but the account MIN is 7, which wins?**
A: The MIN wins — the table gets 7 days. MIN sets a floor.

**Q: Can a non-ACCOUNTADMIN set account parameters?**
A: No. Only ACCOUNTADMIN (or roles granted the privilege) can set account-level parameters.

### Example Scenario Questions — Parameter Hierarchy

**Scenario:** A data engineering team runs large Spark-based ETL jobs that can take up to 6 hours. The account-level `STATEMENT_TIMEOUT_IN_SECONDS` is set to 3600 (1 hour) to protect against runaway queries. The ETL jobs keep getting killed. The team asks the architect to raise the account timeout to 24 hours. What is the correct approach?
**Answer:** Do not raise the account-level timeout — that would expose all users to potential 24-hour runaway queries. Instead, set `STATEMENT_TIMEOUT_IN_SECONDS` at the object level on the dedicated ETL warehouse to 21600 (6 hours). Session-level and object-level parameters override the account default for that specific context. This way, BI users on other warehouses still get the 1-hour safety net while ETL has the headroom it needs.

**Scenario:** A compliance officer discovers that a developer set `DATA_RETENTION_TIME_IN_DAYS = 0` on several staging tables, meaning accidental deletes cannot be recovered via Time Travel. How should the architect prevent this from happening again across the entire account?
**Answer:** Set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level (e.g., to 1 or 7 days). This parameter is account-level only and establishes a floor that no individual database, schema, or table can go below. Even if a developer sets `DATA_RETENTION_TIME_IN_DAYS = 0` on a table, the MIN floor overrides it, ensuring Time Travel is always available for at least the minimum period.

---

## 1.3 ROLE-BASED ACCESS CONTROL

**Core Concepts**

- Snowflake uses **Role-Based Access Control (RBAC)** -- privileges are granted to roles, roles are granted to users
- Roles form a **tree hierarchy** (NOT a linear chain) -- child role privileges flow UP to parent roles
- **System-defined roles:**

```
    ACCOUNTADMIN          (top-level, inherits EVERYTHING below)
    ├── SECURITYADMIN     (manages grants + inherits USERADMIN)
    │   └── USERADMIN     (creates users and roles)
    └── SYSADMIN          (creates databases, schemas, warehouses)
         └── (custom roles should be granted here)
              └── PUBLIC  (auto-granted to every user, bottom of hierarchy)
```

- ORGADMIN is SEPARATE -- it manages the organization (creates/manages accounts), NOT part of the account hierarchy
- SYSADMIN and SECURITYADMIN are SIBLING branches -- SYSADMIN does NOT inherit from USERADMIN, and SECURITYADMIN does NOT inherit from SYSADMIN
- Inheritance flows UPWARD: ACCOUNTADMIN inherits from both branches

### ELI5: The Divided Company (The Y-Shape)

Your Snowflake account is a company. Picture a **Y**.

**The CEO (ACCOUNTADMIN)** sits at the top of the Y. Most powerful person in the building. Inherits everything from everyone below.

Below the CEO, the company splits into **TWO completely separate departments**:

**Left branch -- HR & Security (People):**
- **SECURITYADMIN** = the Security Director. His job: distribute access badges (GRANTS). He inherits from the guy below him.
- **USERADMIN** = the HR Recruiter. His job: create People (USERS) and create Badges/Roles (ROLES). He can create them but NOT distribute them.

**Right branch -- Engineering (Machines & Data):**
- **SYSADMIN** = the Master Builder. He builds databases, tables, warehouses. All infrastructure.
- Custom roles live under SYSADMIN (best practice).

**PUBLIC** = the lobby. Everyone automatically has access to it. Bottom of the hierarchy.

**ORGADMIN** = the Franchise Owner. He sits OUTSIDE the building -- he creates and manages other buildings (accounts). He is NOT above the CEO inside the building. They're separate.

**The exam trick:** "SYSADMIN tried to reset a user's password but got an error. Why?"
Because the Master Builder (SYSADMIN) has ZERO power over HR (USERADMIN). They're on separate branches of the Y. They're siblings who only share one boss: the CEO (ACCOUNTADMIN).

**Privilege Inheritance**

- If Role A is granted to Role B, then Role B inherits ALL privileges of Role A
- ACCOUNTADMIN should inherit from both SECURITYADMIN and SYSADMIN
- Never use ACCOUNTADMIN for daily work

**Exam trap:** IF YOU SEE "ACCOUNTADMIN should be the default role for admins" → WRONG because ACCOUNTADMIN is for break-glass only; daily work should use lower roles.

**Exam trap:** IF YOU SEE "privilege inheritance flows downward" → WRONG because it flows UPWARD in the role hierarchy.

**Database Roles**

- Scoped to a single database (portable with the database during replication/cloning)
- Granted to account-level roles or other database roles
- Ideal for sharing: consumers get database roles, not account roles

**Exam trap:** IF YOU SEE "database roles can be granted directly to users" → WRONG because database roles must be granted to account-level roles first (or other database roles).

**Functional vs Access Roles Pattern**

- **Access roles:** hold object privileges (e.g., `ANALYST_READ` has SELECT on tables)
- **Functional roles:** represent job functions, inherit from access roles (e.g., `DATA_ANALYST` inherits `ANALYST_READ` + `DASHBOARD_WRITE`)
- This two-layer model simplifies management at scale

**Primary vs Secondary Roles**

- A session has exactly **one primary role** and optionally **many secondary roles**
- `USE SECONDARY ROLES ALL` activates all granted roles -- user gets union of privileges
- **CREATE operations (CREATE TABLE, CREATE VIEW, etc.) are restricted to the PRIMARY role only.** Secondary roles cannot create objects.
- Default secondary role can be set on user object

**Exam trap:** IF YOU SEE "CREATE TABLE works with secondary roles" → WRONG because CREATE operations require the PRIMARY role.

**SECURITYADMIN Self-Grant Pattern**

- When a custom role is created outside the SYSADMIN hierarchy, SECURITYADMIN can grant it to themselves to bring it back into the hierarchy
- This is the standard pattern for "rescuing" orphaned roles

**SHOW GRANTS TO vs SHOW GRANTS ON**

- `SHOW GRANTS TO USER x` -- lists all **roles granted to** the user
- `SHOW GRANTS ON USER x` -- lists privileges granted **ON the user object itself** (like OWNERSHIP)
- These are different commands with different results -- the exam tests this distinction

**Privileges vs Securable Objects**

- **Securable objects:** users, roles, databases, tables, views, warehouses, etc.
- **Privileges** are permissions assigned to roles -- they are NOT objects you can grant ON
- You grant a privilege ON a securable object TO a role

**Global-Level Privilege Grants**

- **APPLY MASKING POLICY, APPLY ROW ACCESS POLICY, APPLY SESSION POLICY** are granted at the **Global level** (not schema or database level)
- Syntax: `GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE ...`
- **OWNERSHIP required for search optimization:** only the table OWNER (or a role with OWNERSHIP) can add search optimization to a table

**Changing Account Edition**

- Only **Snowflake Support** can change an account's edition
- Not ORGADMIN, not ACCOUNTADMIN, not `ALTER ACCOUNT`

**Exam trap:** IF YOU SEE "ACCOUNTADMIN can change the account edition" → WRONG because only Snowflake Support can change an account's edition.

### Why This Matters
A 500-person analytics team needs granular access. Functional roles (Data Analyst, Data Engineer) inherit from fine-grained access roles. New hire? Grant one functional role. Done.

### Best Practices
- Never grant privileges directly to users — always use roles
- SYSADMIN should own all databases/warehouses (or custom roles granted to SYSADMIN)
- Use database roles for objects shared via Secure Sharing
- Separate SECURITYADMIN (manages grants) from SYSADMIN (manages objects)

### Real-World Examples
- **Enterprise consulting firm (20 clients):** Each client gets a dedicated database with database roles (`CLIENT_A_READ`, `CLIENT_A_WRITE`). Consultants get functional roles (`SENIOR_CONSULTANT` inherits multiple client access roles). When a consultant leaves a project, revoke one role instead of 50 individual grants.
- **Retail chain (500 stores, regional managers):** Access roles per region (`US_WEST_READ`, `US_EAST_READ`, `EMEA_READ`). Regional managers get functional roles that inherit their region's access roles. Store-level analysts get narrower access roles filtered by store. Row access policies add another layer for row-level store filtering.
- **Startup growing to 50 people:** Start with SYSADMIN owning everything and a few custom roles. Once you hit ~20 users, implement the functional/access role pattern. Create `DATA_ENGINEER`, `DATA_ANALYST`, `PRODUCT_MANAGER` functional roles. Onboarding = 1 GRANT.
- **Data marketplace provider:** Use database roles for shared datasets. Consumers get database roles scoped to the shared database, never see your account-level role hierarchy. When you clone or replicate the database, the database roles travel with it.
- **Regulated bank (separation of duties):** SECURITYADMIN manages grants and policies. SYSADMIN manages objects and warehouses. USERADMIN handles user lifecycle. ACCOUNTADMIN is break-glass only, used by 2-3 people max, always with MFA. This satisfies SOX audit requirements for separation of duties.

### Common Questions (FAQ)
**Q: What's the difference between SECURITYADMIN and USERADMIN?**
A: USERADMIN manages users and roles. SECURITYADMIN inherits USERADMIN and can also manage grants (GRANT/REVOKE).

**Q: Can I use secondary roles with Secure Sharing?**
A: No. Shares use the share's designated database role; secondary roles don't apply in sharing context.

### Example Scenario Questions — Role-Based Access Control

**Scenario:** A 2,000-person enterprise has 15 departments, each with analysts, engineers, and managers. New hires join weekly. Currently, each new hire requires 10+ individual GRANT statements. The security team wants a scalable model. What RBAC pattern should the architect implement?
**Answer:** Implement the functional-role / access-role pattern. Create fine-grained access roles that hold object-level privileges (e.g., `SALES_READ`, `SALES_WRITE`, `MARKETING_READ`). Then create functional roles representing job functions (e.g., `SALES_ANALYST`, `SALES_ENGINEER`, `MARKETING_MANAGER`) that inherit from the appropriate access roles. When a new hire joins, grant them a single functional role. All access roles should be granted to SYSADMIN for hierarchy completeness. This reduces onboarding to one GRANT per new user and simplifies auditing.

**Scenario:** A data marketplace team shares curated datasets to external consumers via Secure Data Sharing. They need consumers to have SELECT on specific views without exposing account-level role structures. What role type should the architect use?
**Answer:** Use database roles. Database roles are scoped to a single database and are portable with the database during sharing. Grant SELECT on the secure views to database roles within the shared database, then assign those database roles to the share. Consumers receive the database roles without visibility into the provider's account-level role hierarchy. This also ensures that if the database is replicated or cloned, the database roles travel with it.

**Scenario:** Multiple analysts complain about constantly switching roles to access tables in different databases. Each analyst has 4-5 roles granted. How should the architect solve this without restructuring the entire RBAC model?
**Answer:** Enable secondary roles by having analysts run `USE SECONDARY ROLES ALL` at session start (or set a default secondary role on the user object). This gives users the union of privileges from all their granted roles simultaneously, eliminating constant `USE ROLE` switching. This is a session-level change and does not affect the underlying RBAC model or security posture.

---

## 1.4 NETWORK SECURITY

**Network Policies**

- IP allow/block lists applied at account or user level
- Use `ALLOWED_IP_LIST` and `BLOCKED_IP_LIST`
- User-level policy **replaces** (not supplements) account-level policy

**Exam trap:** IF YOU SEE "network policies support FQDN/hostname blocking" → WRONG for network policies alone; you need network rules for hostname-based controls.

**Network Rules (newer, more flexible)**

- Can reference IP ranges, VPC endpoints, host names
- Attached to network policies for modular, reusable rules
- Support `INGRESS` (inbound) and `EGRESS` (outbound) directions

**AWS PrivateLink / Azure Private Link / GCP Private Service Connect**

- Private connectivity from your VPC to Snowflake — no public internet
- Requires Business Critical edition or higher
- You get a private endpoint URL (e.g., `account.privatelink.snowflakecomputing.com`)
- Does NOT replace network policies — use both together

**Exam trap:** IF YOU SEE "PrivateLink is available on Standard edition" → WRONG because it requires Business Critical or higher.

**Exam trap:** IF YOU SEE "PrivateLink eliminates the need for network policies" → WRONG because they serve different purposes and should be used together.

**External Access Integrations**

- Allow UDFs/procedures to call external APIs (e.g., REST endpoints)
- Requires creating an External Access Integration + Network Rule (egress)
- Secrets stored in Snowflake secret objects, not in code

**PrivateLink Connectivity Troubleshooting**

- **`SYSTEM$ALLOWLIST_PRIVATELINK()`:** returns the list of endpoints your network must whitelist for PrivateLink connectivity
- Used with **SnowCD** for diagnosing and troubleshooting connectivity issues

**Security Policy Evaluation Order**

- Snowflake evaluates security policies in this order: **Network Policies > Authentication Policies > Password Policies > Session Policies**
- This is the enforcement chain -- if a network policy blocks you, authentication policies are never reached

**Exam trap:** IF YOU SEE "Authentication policies are evaluated before network policies" → WRONG because the order is Network > Authentication > Password > Session.

**Network Policy Setup Requirements**

- **SECURITYADMIN** role (or higher) is needed to create and assign network policies
- User-level policies require specifying both the policy and the user

### Why This Matters
A bank needs all Snowflake traffic to stay on their private network. PrivateLink + network policies + block public access = zero public internet exposure.

### Best Practices
- Always set an account-level network policy (even if broad) as a safety net
- Use PrivateLink for production workloads in regulated industries
- Test network policies in non-prod before applying to account level
- Use network rules instead of raw IP lists for maintainability

### Real-World Examples
- **Investment bank (zero public internet):** AWS PrivateLink from their VPCs to Snowflake + account-level network policy blocking ALL public IPs. Admin Snowsight access via PrivateLink-enabled URL only. Every connection stays on AWS backbone, never touches the internet. Business Critical edition required.
- **Remote-first tech company (200 employees, no office):** VPN with static egress IPs. Account-level network policy allows the VPN egress IPs. When employees connect to VPN, they can reach Snowflake. Without VPN, blocked. Cheaper than PrivateLink, good enough for non-regulated data.
- **Healthcare startup calling external API:** Python UDFs need to call a HIPAA-compliant transcription API. Create network rule (EGRESS, specific hostname), external access integration, and a Snowflake secret for the API key. The UDF can only call that one endpoint -- no blanket internet access.
- **Multi-cloud enterprise (AWS + Azure):** AWS PrivateLink for AWS-based apps, Azure Private Link for Azure-based apps. Each cloud's apps use their native private connectivity. Both connect to the same Snowflake account. Network policies restrict by IP/VPC endpoint per environment.
- **Managed service provider hosting 50 clients:** Each client gets a user-level network policy with their specific office IPs. Client A's IP list is completely independent from Client B's. Remember: user-level REPLACES account-level for that user.

### Common Questions (FAQ)
**Q: If I block all public IPs, can I still use Snowsight?**
A: Only via PrivateLink-enabled Snowsight URL or if you allowlist Snowflake's Snowsight IPs.

**Q: Can I have both account and user network policies?**
A: Yes, but the user-level policy fully replaces (not merges with) the account policy for that user.

### Example Scenario Questions — Network Security

**Scenario:** A large bank is migrating to Snowflake and requires zero public internet exposure. Their applications run in AWS VPCs across three regions. Some teams also need Snowsight access from corporate offices with static IPs. How should the architect design the network architecture?
**Answer:** Enable AWS PrivateLink to establish private connectivity from each VPC to Snowflake — traffic stays on the AWS backbone and never traverses the public internet. Create a network policy at the account level that blocks all public IPs by default. For Snowsight access from corporate offices, add the corporate static IPs to the `ALLOWED_IP_LIST` in the account-level network policy (or use a user-level network policy for specific admin users who need Snowsight). PrivateLink requires Business Critical edition or higher. Use network rules for modular, reusable IP and VPC endpoint definitions.

**Scenario:** A data engineering team needs their Python UDFs to call an external REST API for geocoding. The security team does not allow arbitrary outbound internet access from Snowflake. What is the correct architecture?
**Answer:** Create a network rule with `MODE = EGRESS` specifying the geocoding API's hostname. Create an external access integration referencing that network rule and a Snowflake secret object containing the API key. Grant the external access integration to the UDF. This allows controlled, auditable outbound access to only the specified endpoint — no blanket internet access. The API credentials are stored in Snowflake's secret management, never in code.

---

## 1.5 AUTHENTICATION

**SSO / SAML 2.0**

- Snowflake acts as the Service Provider (SP)
- Your IdP (Okta, Azure AD, etc.) authenticates users
- Configured via a SAML2 security integration
- Supports SCIM for automated user/group provisioning

**OAuth**

- External OAuth: token from your IdP (Okta, Azure AD, PingFederate)
- Snowflake OAuth: Snowflake issues the token (used by partner apps like Tableau)
- Both use security integrations

**Exam trap:** IF YOU SEE "Snowflake OAuth and External OAuth are the same" → WRONG because Snowflake OAuth is issued by Snowflake; External OAuth comes from your IdP.

**MFA (Multi-Factor Authentication)**

- Built-in Duo MFA, no extra cost
- Can be enforced via authentication policies (`AUTHENTICATION_POLICY`)
- `CLIENT_TYPES` in auth policy controls which clients must use MFA

**Key-Pair Authentication**

- RSA 2048-bit minimum
- Public key stored on user object, private key held by client
- Supports key rotation (two active keys: `RSA_PUBLIC_KEY` and `RSA_PUBLIC_KEY_2`)
- Required for service accounts / automation (Snowpipe, connectors)

**Authentication Policies**

- Control allowed auth methods per account or per user
- Can restrict to specific `CLIENT_TYPES` (e.g., SNOWFLAKE_UI, DRIVERS)
- Can enforce MFA for specific client types

**Authentication Best Practices Priority Order**

- Snowflake recommends (in order of preference): **OAuth (#1) > External Browser (#2) > Okta native (#3) > Key-Pair (#4) > Password (#5, last resort)**

**MFA Passcode-in-Password**

- When using `--mfa-passcode-in-password`, the format is **PASSWORD + TOKEN** concatenated
- Example: if password is `SNOW` and token is `123456`, you enter `SNOW123456` (password first, token appended)
- **`ALLOW_CLIENT_MFA_CACHING`:** account-level parameter that caches MFA tokens so users don't get repeatedly prompted. Reduces MFA friction without weakening security.

**SCIM Capabilities**

- Auto-provisions both **users AND groups** (IdP groups become Snowflake roles)
- Handles the full user lifecycle: create, update, deactivate
- Not limited to users only -- groups/roles are included

**Exam trap:** IF YOU SEE "SCIM only provisions users, not roles" → WRONG because SCIM provisions users AND groups from the IdP, and when IdP groups are pushed via SCIM, corresponding Snowflake roles ARE automatically created.

**Git Repository Integration Order**

- The correct creation sequence is:
  1. Create a **secret** with credentials
  2. Create an **API integration**
  3. Create the **Git repository stage**
- The order matters because each step depends on the previous one

**Federated Authentication**

- Combines SSO + MFA for strongest posture
- Users authenticate via IdP, then MFA challenge

### Why This Matters
An enterprise with 5,000 users needs SSO via Okta, MFA enforced for UI users, and key-pair for CI/CD pipelines. Authentication policies let you enforce different rules per use case.

### Best Practices
- Enforce MFA for all human users (at minimum ACCOUNTADMIN)
- Use key-pair auth for all service accounts / automation
- Use SCIM to sync users/groups from your IdP
- Set authentication policies to block password-only access

### Real-World Examples
- **Enterprise with Okta (5,000 employees):** SAML 2.0 SSO for all human users via Okta. SCIM auto-provisions users and groups -- when someone joins the "Data Engineering" group in Okta, they automatically get the `DATA_ENGINEER` role in Snowflake. When they leave the company, SCIM deactivates them. Zero manual user management.
- **DevOps team (CI/CD pipelines):** 50 service accounts using key-pair authentication (RSA 2048-bit). No passwords, no MFA prompts -- automated pipelines can't click "approve" on a phone. Keys rotate quarterly using the two-key slot (`RSA_PUBLIC_KEY` + `RSA_PUBLIC_KEY_2`) for zero-downtime rotation.
- **Partner analytics tool (Tableau, Looker):** Snowflake OAuth -- Snowflake issues the token. The BI tool redirects users to Snowflake's login page, users authenticate (with SSO/MFA), and Snowflake hands back an OAuth token. No passwords stored in Tableau.
- **Custom internal app (React + Python backend):** External OAuth via Azure AD. The app's backend gets an OAuth token from Azure AD and presents it to Snowflake. Snowflake validates the token against the configured security integration. Users never enter Snowflake credentials in the app.
- **Compliance-strict government agency:** Authentication policy enforcing MFA for all `SNOWFLAKE_UI` client types. Key-pair only for `DRIVERS` (programmatic access). Password auth completely blocked. `ALLOW_CLIENT_MFA_CACHING` enabled to reduce MFA friction for analysts who reconnect frequently.

### Common Questions (FAQ)
**Q: Can I use both SSO and password login?**
A: Yes, unless you set an authentication policy that blocks password auth. By default both work.

**Q: What happens if a user loses their key pair?**
A: Admin can set a new public key on the user object. The second key slot enables rotation without downtime.

### Example Scenario Questions — Authentication

**Scenario:** An enterprise has 5,000 employees using Okta for SSO, plus 200 CI/CD service accounts running nightly ETL pipelines. The CISO mandates MFA for all human users accessing Snowsight but cannot require MFA for automated pipelines (which have no human to approve a push notification). How should the architect configure authentication?
**Answer:** Configure a SAML 2.0 security integration with Okta for SSO for all human users. Create an authentication policy that enforces MFA with `CLIENT_TYPES` set to `SNOWFLAKE_UI` (Snowsight) — this requires MFA for interactive logins but not for programmatic drivers. For the 200 CI/CD service accounts, use key-pair authentication (RSA 2048-bit minimum) with the public key stored on each service user object. Set a separate authentication policy on service accounts that allows only key-pair auth and blocks password-based access entirely. Use SCIM to auto-provision and deprovision human users from Okta.

**Scenario:** A company rotates credentials quarterly. They have 50 service accounts using key-pair authentication. How can the architect enable zero-downtime key rotation?
**Answer:** Snowflake supports two concurrent public keys per user object: `RSA_PUBLIC_KEY` and `RSA_PUBLIC_KEY_2`. During rotation, generate a new key pair and set it as `RSA_PUBLIC_KEY_2` on the user object. Update the service account's client configuration to use the new private key. Once confirmed working, remove the old key from `RSA_PUBLIC_KEY`. This overlapping window allows zero-downtime rotation without any service interruption.

---

## 1.6 DATA GOVERNANCE

**Masking Policies (Dynamic Data Masking)**

- Column-level security: returns masked value based on the querying role
- Policy is a SQL function: `CREATE MASKING POLICY ... RETURNS <type> -> CASE WHEN ...`
- Applied to columns via `ALTER TABLE ... ALTER COLUMN ... SET MASKING POLICY`
- One masking policy per column
- Supports conditional masking (based on role, another column, etc.)

**Exam trap:** IF YOU SEE "you can apply two masking policies to the same column" → WRONG because only one masking policy per column is allowed.

**Context Functions in Masking Policies**

- **`CURRENT_ROLE()`:** checks the session's active role
- **`INVOKER_ROLE()`:** checks the executing role in a SQL statement (relevant for owner's rights procedures)
- **`IS_ROLE_IN_SESSION()`:** returns TRUE/FALSE checking if a specific role is in the current session's active roles

**Exam trap:** IF YOU SEE "IS_ROLE_IN_SESSION checks at account level" → WRONG because it checks at session level.

**Conditional Masking with Non-Role Columns**

- Masking policies can reference **other columns in the same table** for conditional logic (e.g., unmask if `event_timestamp` is older than 90 days)
- The policy body receives the column value AND any additional column references

**DDM Characteristics**

- One masking policy can be applied to columns across **MANY tables** (reusable)
- On external tables, masking applies to the **VALUE column**
- **Table owners are NOT exempt from masking** -- the policy applies to ALL roles including the table owner
- When combined with **object tagging (tag-based masking)**, DDM policies can be automatically applied to all columns matching a specific tag value, enabling governance at scale without per-column policy assignment

**Exam trap:** IF YOU SEE "table owners are exempt from masking policies" → WRONG because masking policies apply to ALL roles including the table owner.

**Row Access Policies (RAP)**

- Row-level security: filters rows based on querying context
- Returns `TRUE` (row visible) or `FALSE` (row hidden)
- One RAP per table/view
- Can reference mapping tables for role-to-region filtering

**Exam trap:** IF YOU SEE "row access policies are applied to columns" → WRONG because RAP is applied to tables/views, not individual columns.

**Row Access Policies on External Tables**

- RAP can be applied to the **VALUE column** of an external table (via ALTER TABLE, not at creation time)
- Cannot apply to virtual columns
- External tables are **NOT supported as mapping tables** within RAP

**Aggregation Policies**

- Prevent queries that return results below a minimum group size
- Protects against re-identification in analytics
- Entity-level privacy (e.g., must aggregate at least 5 patients)

**Exam trap:** IF YOU SEE "aggregation policies filter rows" → WRONG because they block queries that produce groups below the minimum size, not filter individual rows.

**Projection Policies**

- Prevent `SELECT column` directly — column can only be used in WHERE, JOIN, GROUP BY
- Use case: allow filtering on SSN but never displaying it

**Object Tagging**

- Key-value metadata on any object (table, column, warehouse, etc.)
- Tag lineage: tags propagate through views
- Foundation for tag-based masking policies (apply masking to all columns with tag X)
- System tags from classification (e.g., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = EMAIL`)

**Exam trap:** IF YOU SEE "object tags require Business Critical edition" → WRONG because tagging is available on Enterprise and above.

**Data Lineage (ACCESS_HISTORY)**

- `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY` — tracks reads/writes at column level
- Shows which columns were accessed, by whom, and how data flowed
- 365-day retention
- Requires Enterprise edition or higher

**Masking Data Exfiltration Risk**

- If an authorized user (who sees unmasked data) loads that data into a column **WITHOUT** a masking policy, the **unmasked data is stored permanently**
- This is a data exfiltration risk that must be mitigated with governance controls (e.g., restrict COPY INTO, limit CREATE TABLE privileges)

**Database Role OR REPLACE Behavior**

- `CREATE OR REPLACE DATABASE ROLE` drops the role from any shares it was granted to
- Consumers lose access and must be re-granted -- use with caution on shared databases

### Why This Matters
A retail company tags all PII columns, then applies a single masking policy to every column with the PII tag. When a new PII column is added and tagged, masking is automatic.

### Best Practices
- Use tag-based masking for scalable governance
- Combine RAP + masking for defense-in-depth
- Use aggregation policies for analytics datasets exposed to broad audiences
- Run data classification to auto-detect sensitive data

### Real-World Examples
- **Insurance company (1,000+ tables, PII everywhere):** Tag-based masking. Run automatic data classification to tag columns as EMAIL, SSN, PHONE. Create one masking policy per tag. When a new data source is onboarded and classified, masking auto-applies. The governance team never manually assigns policies to individual columns.
- **Pharmaceutical company sharing clinical trial data:** Aggregation policy (min group size = 20) on patient datasets shared with external researchers. Projection policy on patient_id so researchers can use it in GROUP BY but never SELECT it. Researchers can analyze cohorts but never identify individuals.
- **E-commerce platform (GDPR compliance):** Row access policy on customer table using a mapping table that maps roles to EU/US regions. EU analysts only see EU customers. US analysts only see US. Masking policy on email/phone columns: unmasked for customer service roles, masked for marketing analysts.
- **Financial services (SOX audit requirements):** `ACCESS_HISTORY` view tracks every column-level read/write for 365 days. Auditors can see exactly who accessed what PII, when, and how data flowed through views and transformations. No custom logging needed.
- **Multi-tenant SaaS (B2B):** Each tenant's data is in the same table with a `tenant_id` column. Row access policy filters by tenant based on the querying role. Masking policy on sensitive business metrics: only the tenant's own admin role sees real numbers, all other roles see aggregated averages.
- **Retail analytics shared via Snowflake Marketplace:** Database roles on the shared database grant access to curated secure views. Masking policies on the underlying tables ensure that even if someone gains access to raw tables (they shouldn't), PII is still masked. Defense-in-depth.

### Common Questions (FAQ)
**Q: Can masking policies reference other tables?**
A: Yes. You can query a mapping table inside the masking policy body (subquery).

**Q: Do row access policies work on materialized views?**
A: No. RAP is not supported on materialized views.

**Q: What's the difference between projection policy and masking policy?**
A: Masking replaces the value (e.g., `***`). Projection prevents the column from appearing in results entirely but allows its use in predicates.

### Example Scenario Questions — Data Governance

**Scenario:** A healthcare analytics platform has 500+ tables, and new columns containing PHI (emails, phone numbers, SSNs) are added regularly as new data sources are onboarded. The governance team cannot manually review every new column. How should the architect automate masking at scale?
**Answer:** Implement tag-based masking. Run Snowflake's automatic data classification to detect sensitive columns and apply system tags (e.g., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = 'EMAIL'`). Create masking policies for each sensitivity category (EMAIL, PHONE, SSN) and bind them to the corresponding tags using tag-based masking policy assignments. When new columns are added and classified, the masking policy auto-applies based on the tag — no manual intervention needed. Combine with row access policies for defense-in-depth.

**Scenario:** A pharmaceutical company needs to share a clinical trial dataset with external researchers. Researchers must be able to filter by patient demographics (age, gender, zip code) for cohort selection, but must never see individual patient records — results must aggregate at least 20 patients per group to prevent re-identification. How should the architect configure governance?
**Answer:** Apply an aggregation policy on the shared dataset with a minimum group size of 20 — any query that produces groups with fewer than 20 patients is blocked. Additionally, apply projection policies on direct patient identifiers (patient_id, SSN) so researchers can use them in WHERE/JOIN/GROUP BY for cohort selection but cannot SELECT them in results. Share the data via secure views with these policies applied. This provides layered privacy: aggregation prevents small-group re-identification, and projection prevents direct identifier exposure.

**Scenario:** An internal audit requires understanding which roles accessed which PII columns over the past year, including data flows through views and downstream tables. What Snowflake feature supports this?
**Answer:** Query `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY`, which provides column-level data lineage tracking with 365-day retention. It records which columns were read (`base_objects_accessed`) and written (`objects_modified`), by which role, including data flows through views and transformations. This supports audit requirements without requiring any custom logging infrastructure. Requires Enterprise edition or higher.

---

## 1.7 COMPLIANCE

**Edition Requirements Comparison**

| Feature | Standard | Enterprise | Business Critical |
|---|---|---|---|
| MFA | Yes | Yes | Yes |
| Time Travel (max) | 1 day | 90 days | 90 days |
| PrivateLink | No | No | Yes |
| Tri-Secret Secure | No | No | Yes |
| External Tokenization | No | Yes | Yes |
| Column-level masking | No | Yes | Yes |
| Replication | No | Yes | Yes |
| PCI DSS | No | No | Yes |

**Exam trap:** IF YOU SEE "External Tokenization works on Standard edition" → WRONG because it requires Enterprise edition minimum.

**Tri-Secret Secure Key Hierarchy**

- The customer-managed key wraps the **Account Master Key (AMK)**
- Snowflake manages the hierarchy below (table master key, file keys)
- If the customer revokes their key, **ALL data in the account** becomes inaccessible

**Exam trap:** IF YOU SEE "Tri-Secret Secure wraps the table master key" → WRONG because the customer key wraps the Account Master Key (AMK), not individual table keys.

**Key Rotation**

- Automatic key rotation every **30 days** (Snowflake-managed)
- `PERIODIC_DATA_REKEYING = TRUE` enables annual re-encryption of data with new keys (requires **Enterprise+** edition)

**Exam trap:** IF YOU SEE "key rotation happens annually by default" → WRONG because automatic rotation is every 30 days. PERIODIC_DATA_REKEYING (annual re-encryption) must be explicitly enabled.

**Storage Integration as Data Export Restriction**

- Storage integrations define **allowed and blocked storage locations**
- Combined with `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE`, this restricts where COPY INTO can export data
- Prevents unauthorized data exfiltration to uncontrolled storage buckets

**SIMULATED_DATA_SHARING_CONSUMER**

- Session parameter that lets providers **simulate** querying a secure view as a consumer account
- Validates data visibility before publishing
- Does **NOT** support secure UDFs -- only secure views

**Object Per Tenant (OPT) Multi-Tenancy**

- When row-level security isn't viable for strong legal isolation between tenants, create separate objects (schemas or databases) per tenant
- Avoids complex entitlement tables
- Use when tenants require contractual data isolation guarantees

**PrivateLink + SSO Integration**

- When adding PrivateLink to an existing SSO setup, you must update BOTH:
  1. The **Snowflake security integration** to use the PrivateLink URL
  2. The **IdP configuration** (Azure AD, Okta) to use the PrivateLink URL
- Missing either causes IP block or redirect errors

**Cloning and Time Travel Edge Cases**

- **Cloning failure with retention=0:** if `DATA_RETENTION_TIME_IN_DAYS = 0` on a table, DML operations during a long-running clone can purge data before the clone completes, causing the clone to fail
- **Time Travel clone errors:** a Time Travel clone (AT/BEFORE) fails if: (1) the offset points to before the object was created, or (2) the target is an external table (not supported)

---

## DON'T MIX -- Security Concepts the Exam Tries to Confuse

These are the pairs that look similar but the exam tests you on the EXACT difference. Read the "RULE" line for each -- that's the one sentence to anchor.

### Network Policy vs Private Link

| | Network Policy | Private Link |
|---|---|---|
| What it does | IP allow/block list (who CAN connect) | Private network path (HOW they connect) |
| Layer | Application layer (IP filtering) | Network layer (no public internet) |
| Edition | All editions | Business Critical+ |
| Replace each other? | NO -- use BOTH together | NO -- use BOTH together |

**RULE:** Network Policy = WHO can connect. Private Link = HOW they connect. You always need both.

### Network Policy at Account vs User Level

| | Account-level | User-level |
|---|---|---|
| Scope | All users by default | One specific user |
| Relationship | Base policy | REPLACES (not adds to) account policy |
| Set by | ACCOUNTADMIN | SECURITYADMIN+ |

**RULE:** User-level REPLACES account-level. It does NOT merge or add. If a user has their own policy, the account policy is IGNORED for them.

### SECURITYADMIN vs USERADMIN vs SYSADMIN

| Role | Creates... | Manages... | Does NOT... |
|---|---|---|---|
| USERADMIN | Users, Roles | User properties | Manage grants or objects |
| SECURITYADMIN | (inherits USERADMIN) | GRANTS (GRANT/REVOKE) | Own databases/warehouses |
| SYSADMIN | Databases, Warehouses, Schemas | Objects, compute | Manage users or grants |

**RULE:** SECURITY = grants. USER = people. SYS = objects. They are SEPARATE branches under ACCOUNTADMIN, not a chain.

### Masking Policy vs Row Access Policy vs Projection Policy

| | Masking | Row Access (RAP) | Projection |
|---|---|---|---|
| Applied to | Column | Table/View | Column |
| What it does | Replaces value (shows `***`) | Hides entire rows | Blocks SELECT but allows WHERE/JOIN |
| Limit | 1 per column | 1 per table | 1 per column |
| Use case | "Show me `***` instead of SSN" | "Don't show me EU rows" | "Let me filter by SSN but never see it" |

**RULE:** Masking = you see the row but value is hidden. RAP = you don't see the row at all. Projection = you can use the column but never display it.

### Aggregation Policy vs Row Access Policy

| | Aggregation | Row Access |
|---|---|---|
| Purpose | Prevent small-group re-identification | Control who sees which rows |
| How | Blocks queries with groups < minimum size | Filters rows per role/context |
| Applied to | Table | Table/View |

**RULE:** RAP = "this role can't see these rows." Aggregation = "nobody can see groups smaller than N."

### Snowflake OAuth vs External OAuth

| | Snowflake OAuth | External OAuth |
|---|---|---|
| Who issues token | Snowflake itself | Your IdP (Okta, Azure AD) |
| Used by | Partner apps (Tableau, Looker) | Custom apps, enterprise SSO |
| Token validation | Snowflake validates internally | Snowflake validates against IdP config |

**RULE:** If the exam says "partner tool" = Snowflake OAuth. If it says "enterprise IdP" = External OAuth.

### Tri-Secret Secure vs Regular Encryption

| | Regular (default) | Tri-Secret Secure |
|---|---|---|
| Keys | Snowflake manages all keys | Customer key + Snowflake key + composite key |
| Control | Snowflake controls access | Customer can revoke their key = Snowflake locked out |
| Edition | All | Business Critical+ |
| Cost | Included | Extra (customer manages KMS) |

**RULE:** Tri-Secret = customer holds a kill switch. If they revoke their CMK, Snowflake literally cannot read the data.

---

**Edition Features for Compliance**

| Requirement | Minimum Edition |
|---|---|
| HIPAA / HITRUST | Business Critical |
| PCI DSS | Business Critical |
| SOC 1/2 | All editions |
| FedRAMP Moderate | Virtual Private Snowflake (VPS) on AWS GovCloud |
| ITAR | VPS on AWS GovCloud |
| PHI support | Business Critical with BAA |

**Tri-Secret Secure**

- Customer-managed key (CMK) wraps Snowflake's key, which wraps the data key
- Requires Business Critical edition
- If customer revokes CMK, Snowflake cannot decrypt data — full customer control
- Supported on AWS (KMS), Azure (Key Vault), GCP (Cloud KMS)

**Storage Integrations**

- Secure, governed access to external cloud storage (S3, GCS, Azure Blob)
- Uses IAM roles / service principals — no raw credentials in SQL
- Required for external stages, external tables, data lake access
- `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` parameter forces their use

### Why This Matters
A healthcare company storing PHI needs Business Critical + BAA + Tri-Secret Secure + PrivateLink. Missing any one breaks HIPAA compliance.

### Best Practices
- Enable Tri-Secret Secure for data you need full control over
- Require storage integrations at account level to prevent credential leakage
- Document your compliance architecture for auditors
- Use VPS only when FedRAMP / ITAR is required (significant cost)

### Real-World Examples
- **Hospital chain (HIPAA):** Business Critical edition + signed BAA with Snowflake. Tri-Secret Secure with AWS KMS for customer-controlled encryption kill switch. PrivateLink for private connectivity. Network policies blocking all public IPs. PHI stored in dedicated account. Total cost is higher but HIPAA has no shortcut.
- **Online payment processor (PCI DSS):** Dedicated Business Critical account for cardholder data. Separate Standard account for non-PCI analytics. PCI auditors only audit the cardholder account, drastically reducing audit scope. Tri-Secret Secure on the PCI account for key control.
- **EU fintech (GDPR):** Account in `aws_eu_central_1` for EU data residency. Row access policies ensure only EU-based roles access EU customer data. Right-to-erasure implemented via masking + deletion procedures. Cross-border data transfers only for aggregated, anonymized datasets via database replication to a US analytics account.
- **US defense contractor (ITAR):** Virtual Private Snowflake (VPS) on AWS GovCloud. Fully dedicated, isolated infrastructure -- separate metadata store, compute, and storage. Non-ITAR commercial workloads on a separate Business Critical account in a commercial region. Both under the same Organization for billing. VPS is expensive but ITAR demands complete isolation.
- **Mid-size SaaS company (SOC 2):** Standard edition is fine for SOC 2 -- it's available on all editions. They document their Snowflake security controls (RBAC, encryption, network policies) in their SOC 2 Type II report. No need to upgrade to Business Critical just for SOC 2.
- **Insurance company (data exfiltration prevention):** `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` at account level. Storage integrations define allowed S3 buckets only. Even if an authorized user can see unmasked data, they cannot COPY it to an unauthorized bucket. Combined with restricted CREATE TABLE privileges to prevent copying unmasked data to new tables.

**Exam trap:** IF YOU SEE "Tri-Secret Secure is available on Enterprise edition" → WRONG because it requires Business Critical.

**Exam trap:** IF YOU SEE "SOC 2 compliance requires Business Critical" → WRONG because SOC 2 reports are available for all editions.

**Exam trap:** IF YOU SEE "Tri-Secret Secure means Snowflake cannot access your data at all" → WRONG because Snowflake still manages the middle key; the customer controls the outer key.

### Common Questions (FAQ)
**Q: What's the difference between Business Critical and VPS?**
A: Business Critical adds encryption, compliance, PrivateLink. VPS adds a dedicated, isolated Snowflake deployment (separate metadata store, compute).

**Q: Does enabling Tri-Secret Secure affect performance?**
A: Negligible. The key wrapping adds minimal overhead.

### Example Scenario Questions — Compliance

**Scenario:** A US defense contractor needs to process ITAR-controlled data in Snowflake. They also have non-ITAR commercial workloads that don't require the same isolation. What Snowflake deployment model should the architect recommend?
**Answer:** Deploy a Virtual Private Snowflake (VPS) instance on AWS GovCloud specifically for the ITAR-controlled workloads. VPS provides a fully dedicated, isolated Snowflake deployment with a separate metadata store and compute infrastructure — the strongest isolation level Snowflake offers. For non-ITAR commercial workloads, use a standard Business Critical account in a commercial region. Both accounts can be managed under the same Snowflake Organization for centralized billing, but data and compute are completely separated. Never mix ITAR data with commercial workloads in the same account.

**Scenario:** A healthcare company stores PHI in Snowflake and must comply with HIPAA. Their CISO requires the ability to immediately revoke Snowflake's access to all data in case of a security incident. What combination of features should the architect implement?
**Answer:** Deploy on Business Critical edition (minimum for HIPAA/PHI support) and sign a Business Associate Agreement (BAA) with Snowflake. Enable Tri-Secret Secure, which adds a customer-managed key (CMK) via AWS KMS, Azure Key Vault, or GCP Cloud KMS that wraps Snowflake's encryption key. If the CISO needs to revoke access, they revoke the CMK — Snowflake immediately loses the ability to decrypt any data. Complement with PrivateLink for private connectivity, network policies to block all public access, and `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` to prevent credential leakage in stages.

---

## CONFUSING PAIRS — Account & Security

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Who **creates users/roles**? | **USERADMIN** | NOT SECURITYADMIN (SECURITYADMIN *inherits* USERADMIN but its own job is grants) |
| Who **manages grants** (GRANT/REVOKE)? | **SECURITYADMIN** | NOT USERADMIN (USERADMIN only creates users/roles) |
| Who **creates accounts** in an org? | **ORGADMIN** | NOT ACCOUNTADMIN (ACCOUNTADMIN is per-account, not org-level) |
| **Functional roles** vs **access roles** | **Functional** = business function (Data Analyst), **Access** = object privileges (READ_SALES) | Don't mix — functional roles *inherit from* access roles |
| **Database roles** vs **account roles** | **Database roles** = scoped to one DB, portable with replication/cloning | **Account roles** = account-wide, NOT portable with DB |
| **Network policy** vs **network rule** | **Policy** = IP allow/block list applied to account/user | **Rule** = more granular (host, port, VPC endpoint), attached to policies |
| **Column masking** vs **row access policy** | **Masking** = hides/replaces column *values* | **RAP** = hides entire *rows* — applied to table, not column |
| **Aggregation policy** vs **projection policy** | **Aggregation** = blocks queries below min group size | **Projection** = prevents column from appearing in SELECT results |
| **External tokenization** vs **dynamic masking** | **External** = third-party service (Protegrity) replaces value | **Dynamic masking** = Snowflake built-in, role-based at query time |
| **PrivateLink** vs **VPN** | **PrivateLink** = direct cloud backbone connection, no internet | **VPN** = encrypted tunnel *over* the internet |
| **Authentication policy** vs **security integration** | **Auth policy** = rules for *how* users can log in (MFA, client types) | **Security integration** = SSO/OAuth *config* with an external IdP |
| User-level network policy + account-level | User-level **replaces** account-level for that user | NOT additive — the account policy is *ignored* for that user |
| **Snowflake OAuth** vs **External OAuth** | **Snowflake OAuth** = Snowflake issues token (partner apps) | **External OAuth** = your IdP issues the token |
| **SCIM** provisions... | **Users, groups, AND roles** automatically from IdP | SCIM DOES create Snowflake roles when IdP groups are pushed — roles are created to correspond to IdP groups |
| **MIN_DATA_RETENTION** level | **Account-level only** (sets a floor) | NOT settable on schema or table |

---

## SCENARIO DECISION TREES — Account & Security

**Scenario 1: "A company needs completely isolated data for PCI compliance..."**
- **CORRECT:** Separate Snowflake **accounts** (PCI data in its own account, Business Critical edition)
- TRAP: *"Use different databases in the same account"* — **WRONG**, same account = shared metadata, shared ACCOUNTADMIN, not true isolation

**Scenario 2: "An analyst should see masked SSNs but a manager sees real ones..."**
- **CORRECT:** **Dynamic data masking policy** with role-based CASE logic
- TRAP: *"Create two separate views"* — **WRONG**, not scalable, hard to maintain, bypasses governance

**Scenario 3: "Block all public internet access to Snowflake..."**
- **CORRECT:** **PrivateLink** + **network policy** blocking all public IPs
- TRAP: *"Just use a VPN"* — **WRONG**, VPN still traverses public internet; PrivateLink stays on cloud backbone

**Scenario 4: "A service account needs to connect to Snowflake from a CI/CD pipeline..."**
- **CORRECT:** **Key-pair authentication** (RSA 2048-bit)
- TRAP: *"Store username/password in environment variables"* — **WRONG**, passwords are less secure and can't enforce MFA

**Scenario 5: "Prevent table owners from granting SELECT to unauthorized roles..."**
- **CORRECT:** **Managed access schema** — only schema owner/MANAGE GRANTS can grant
- TRAP: *"Use row access policies"* — **WRONG**, RAP filters rows but doesn't prevent grant escalation

**Scenario 6: "Allow filtering on SSN in WHERE clause but never display the column..."**
- **CORRECT:** **Projection policy** on the SSN column
- TRAP: *"Masking policy"* — **WRONG**, masking still shows the column (with masked value). Projection hides it entirely from SELECT

**Scenario 7: "Enforce MFA for Snowsight users but not for JDBC service accounts..."**
- **CORRECT:** **Authentication policy** with `CLIENT_TYPES` set to enforce MFA only for `SNOWFLAKE_UI`
- TRAP: *"Network policy"* — **WRONG**, network policies control IP access, not authentication methods

**Scenario 8: "Ensure Time Travel can never be set below 7 days on any table..."**
- **CORRECT:** Set **`MIN_DATA_RETENTION_TIME_IN_DAYS = 7`** at account level
- TRAP: *"Set DATA_RETENTION_TIME_IN_DAYS = 7 on each schema"* — **WRONG**, individual objects can override schema settings; only MIN at account level sets a true floor

**Scenario 9: "Analytics queries must aggregate at least 10 patients before showing results..."**
- **CORRECT:** **Aggregation policy** with minimum group size of 10
- TRAP: *"Row access policy"* — **WRONG**, RAP filters rows per role; it doesn't enforce minimum group sizes

**Scenario 10: "Customer wants full control to revoke Snowflake's access to their data..."**
- **CORRECT:** **Tri-Secret Secure** (customer-managed key wraps Snowflake's key) on **Business Critical**
- TRAP: *"Just use Snowflake's built-in encryption"* — **WRONG**, default encryption doesn't give the customer a kill switch

**Scenario 11: "5,000 users need SSO, with groups auto-synced from Okta..."**
- **CORRECT:** **SAML 2.0 security integration** for SSO + **SCIM** for user/group provisioning
- TRAP: *"Manually create users with passwords"* — **WRONG**, doesn't scale, no auto-deprovisioning

**Scenario 12: "New PII column added — must be automatically masked without manual intervention..."**
- **CORRECT:** **Tag-based masking** — tag the column as PII, masking policy auto-applies to all columns with that tag
- TRAP: *"Apply a new masking policy to each column manually"* — **WRONG**, doesn't scale, easy to miss columns

---

## FLASHCARDS -- Domain 1

**Q1:** What role can create new accounts in a Snowflake Organization?
**A1:** ORGADMIN only.

**Q2:** If a session parameter and account parameter conflict, which wins?
**A2:** Session parameter (most specific wins).

**Q3:** What is the minimum edition for PrivateLink?
**A3:** Business Critical.

**Q4:** How many masking policies can be applied to a single column?
**A4:** One.

**Q5:** What's the difference between a functional role and an access role?
**A5:** Access roles hold object privileges; functional roles represent job functions and inherit from access roles.

**Q6:** What does Tri-Secret Secure provide?
**A6:** Customer-managed key wrapping Snowflake's key — customer can revoke access to their data.

**Q7:** Can database roles be granted directly to users?
**A7:** No. They must be granted to account-level roles (or other database roles within the same database).

**Q8:** What does `MIN_DATA_RETENTION_TIME_IN_DAYS` do?
**A8:** Sets a floor for Time Travel retention that individual objects cannot go below.

**Q9:** What authentication method should service accounts use?
**A9:** Key-pair authentication.

**Q10:** What is the purpose of a projection policy?
**A10:** Prevents a column from appearing in SELECT results while allowing its use in WHERE/JOIN/GROUP BY.

**Q11:** What does SCIM do in Snowflake?
**A11:** Automates user and group provisioning/deprovisioning from an external IdP.

**Q12:** When a user-level network policy is set, what happens to the account-level policy for that user?
**A12:** The user-level policy fully replaces (does not merge with) the account-level policy.

**Q13:** What edition is required for row access policies?
**A13:** Enterprise or higher.

**Q14:** What is the retention period for ACCESS_HISTORY?
**A14:** 365 days.

**Q15:** Can aggregation policies be combined with masking policies on the same table?
**A15:** Yes. They serve different purposes and can coexist.

---

## EXPLAIN LIKE I'M 5 -- Domain 1

**1. Multi-Account Strategy**
Imagine you have different toy boxes for different rooms. The bedroom box has bedtime toys, the playroom box has messy-play toys. You keep them separate so glitter doesn't get on your pillow. That's multi-account — separate boxes for separate stuff.

**2. Parameter Hierarchy**
Your parents say "bedtime at 8pm" (account rule). But for YOUR room, it's "bedtime at 8:30pm" (object rule). And tonight, since it's your birthday, it's "bedtime at 9pm" (session rule). The most specific rule wins!

**3. Role Inheritance**
You're the "cookie monitor" at school. That means you can hand out cookies. Your teacher is the "classroom boss" and she has ALL the monitor powers, including yours. Powers flow UP.

**4. Network Policies**
It's like a guest list at a birthday party. Only kids on the list can come in. If your mom makes a special list just for you, it replaces the main list — doesn't add to it.

**5. PrivateLink**
Instead of walking to your friend's house on the public sidewalk, you build a secret tunnel between your houses. Nobody else can see you walking. That's PrivateLink.

**6. Masking Policies**
You write a secret note. When your best friend reads it, they see the real words. When anyone else reads it, they see "XXXXX." Same note, different views.

**7. Row Access Policies**
A magic coloring book where you can only see pages that have YOUR name on them. Other kids have the same book but see different pages.

**8. Tri-Secret Secure**
You lock your diary with YOUR lock. Then put it in a box with SNOWFLAKE'S lock. Both locks needed to read it. You can remove your lock anytime and nobody can read it.

**9. SSO / SAML**
Instead of remembering a password for every website, you have one magic key (your school badge) that opens all the doors.

**10. Object Tagging**
Putting colored stickers on your toys: red for "fragile," blue for "share with friends." Later you can say "hide ALL red-                                        