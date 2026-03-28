-- CERT_REVIEW_NOTES data (architect)

DELETE FROM PST.PS_APPS_DEV.CERT_REVIEW_NOTES WHERE CERT_KEY = 'architect';

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 'en',
  '# Domain 1: Account & Security Strategy

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

**ORGADMIN** = the Franchise Owner. He sits OUTSIDE the building -- he creates and manages other buildings (accounts). He is NOT above the CEO inside the building. They''re separate.

**The exam trick:** "SYSADMIN tried to reset a user''s password but got an error. Why?"
Because the Master Builder (SYSADMIN) has ZERO power over HR (USERADMIN). They''re on separate branches of the Y. They''re siblings who only share one boss: the CEO (ACCOUNTADMIN).

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

- Only **Snowflake Support** can change an account''s edition
- Not ORGADMIN, not ACCOUNTADMIN, not `ALTER ACCOUNT`

**Exam trap:** IF YOU SEE "ACCOUNTADMIN can change the account edition" → WRONG because only Snowflake Support can change an account''s edition.

### Why This Matters
A 500-person analytics team needs granular access. Functional roles (Data Analyst, Data Engineer) inherit from fine-grained access roles. New hire? Grant one functional role. Done.

### Best Practices
- Never grant privileges directly to users — always use roles
- SYSADMIN should own all databases/warehouses (or custom roles granted to SYSADMIN)
- Use database roles for objects shared via Secure Sharing
- Separate SECURITYADMIN (manages grants) from SYSADMIN (manages objects)

### Real-World Examples
- **Enterprise consulting firm (20 clients):** Each client gets a dedicated database with database roles (`CLIENT_A_READ`, `CLIENT_A_WRITE`). Consultants get functional roles (`SENIOR_CONSULTANT` inherits multiple client access roles). When a consultant leaves a project, revoke one role instead of 50 individual grants.
- **Retail chain (500 stores, regional managers):** Access roles per region (`US_WEST_READ`, `US_EAST_READ`, `EMEA_READ`). Regional managers get functional roles that inherit their region''s access roles. Store-level analysts get narrower access roles filtered by store. Row access policies add another layer for row-level store filtering.
- **Startup growing to 50 people:** Start with SYSADMIN owning everything and a few custom roles. Once you hit ~20 users, implement the functional/access role pattern. Create `DATA_ENGINEER`, `DATA_ANALYST`, `PRODUCT_MANAGER` functional roles. Onboarding = 1 GRANT.
- **Data marketplace provider:** Use database roles for shared datasets. Consumers get database roles scoped to the shared database, never see your account-level role hierarchy. When you clone or replicate the database, the database roles travel with it.
- **Regulated bank (separation of duties):** SECURITYADMIN manages grants and policies. SYSADMIN manages objects and warehouses. USERADMIN handles user lifecycle. ACCOUNTADMIN is break-glass only, used by 2-3 people max, always with MFA. This satisfies SOX audit requirements for separation of duties.

### Common Questions (FAQ)
**Q: What''s the difference between SECURITYADMIN and USERADMIN?**
A: USERADMIN manages users and roles. SECURITYADMIN inherits USERADMIN and can also manage grants (GRANT/REVOKE).

**Q: Can I use secondary roles with Secure Sharing?**
A: No. Shares use the share''s designated database role; secondary roles don''t apply in sharing context.

### Example Scenario Questions — Role-Based Access Control

**Scenario:** A 2,000-person enterprise has 15 departments, each with analysts, engineers, and managers. New hires join weekly. Currently, each new hire requires 10+ individual GRANT statements. The security team wants a scalable model. What RBAC pattern should the architect implement?
**Answer:** Implement the functional-role / access-role pattern. Create fine-grained access roles that hold object-level privileges (e.g., `SALES_READ`, `SALES_WRITE`, `MARKETING_READ`). Then create functional roles representing job functions (e.g., `SALES_ANALYST`, `SALES_ENGINEER`, `MARKETING_MANAGER`) that inherit from the appropriate access roles. When a new hire joins, grant them a single functional role. All access roles should be granted to SYSADMIN for hierarchy completeness. This reduces onboarding to one GRANT per new user and simplifies auditing.

**Scenario:** A data marketplace team shares curated datasets to external consumers via Secure Data Sharing. They need consumers to have SELECT on specific views without exposing account-level role structures. What role type should the architect use?
**Answer:** Use database roles. Database roles are scoped to a single database and are portable with the database during sharing. Grant SELECT on the secure views to database roles within the shared database, then assign those database roles to the share. Consumers receive the database roles without visibility into the provider''s account-level role hierarchy. This also ensures that if the database is replicated or cloned, the database roles travel with it.

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
- **Multi-cloud enterprise (AWS + Azure):** AWS PrivateLink for AWS-based apps, Azure Private Link for Azure-based apps. Each cloud''s apps use their native private connectivity. Both connect to the same Snowflake account. Network policies restrict by IP/VPC endpoint per environment.
- **Managed service provider hosting 50 clients:** Each client gets a user-level network policy with their specific office IPs. Client A''s IP list is completely independent from Client B''s. Remember: user-level REPLACES account-level for that user.

### Common Questions (FAQ)
**Q: If I block all public IPs, can I still use Snowsight?**
A: Only via PrivateLink-enabled Snowsight URL or if you allowlist Snowflake''s Snowsight IPs.

**Q: Can I have both account and user network policies?**
A: Yes, but the user-level policy fully replaces (not merges with) the account policy for that user.

### Example Scenario Questions — Network Security

**Scenario:** A large bank is migrating to Snowflake and requires zero public internet exposure. Their applications run in AWS VPCs across three regions. Some teams also need Snowsight access from corporate offices with static IPs. How should the architect design the network architecture?
**Answer:** Enable AWS PrivateLink to establish private connectivity from each VPC to Snowflake — traffic stays on the AWS backbone and never traverses the public internet. Create a network policy at the account level that blocks all public IPs by default. For Snowsight access from corporate offices, add the corporate static IPs to the `ALLOWED_IP_LIST` in the account-level network policy (or use a user-level network policy for specific admin users who need Snowsight). PrivateLink requires Business Critical edition or higher. Use network rules for modular, reusable IP and VPC endpoint definitions.

**Scenario:** A data engineering team needs their Python UDFs to call an external REST API for geocoding. The security team does not allow arbitrary outbound internet access from Snowflake. What is the correct architecture?
**Answer:** Create a network rule with `MODE = EGRESS` specifying the geocoding API''s hostname. Create an external access integration referencing that network rule and a Snowflake secret object containing the API key. Grant the external access integration to the UDF. This allows controlled, auditable outbound access to only the specified endpoint — no blanket internet access. The API credentials are stored in Snowflake''s secret management, never in code.

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
- **`ALLOW_CLIENT_MFA_CACHING`:** account-level parameter that caches MFA tokens so users don''t get repeatedly prompted. Reduces MFA friction without weakening security.

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
- **DevOps team (CI/CD pipelines):** 50 service accounts using key-pair authentication (RSA 2048-bit). No passwords, no MFA prompts -- automated pipelines can''t click "approve" on a phone. Keys rotate quarterly using the two-key slot (`RSA_PUBLIC_KEY` + `RSA_PUBLIC_KEY_2`) for zero-downtime rotation.
- **Partner analytics tool (Tableau, Looker):** Snowflake OAuth -- Snowflake issues the token. The BI tool redirects users to Snowflake''s login page, users authenticate (with SSO/MFA), and Snowflake hands back an OAuth token. No passwords stored in Tableau.
- **Custom internal app (React + Python backend):** External OAuth via Azure AD. The app''s backend gets an OAuth token from Azure AD and presents it to Snowflake. Snowflake validates the token against the configured security integration. Users never enter Snowflake credentials in the app.
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
**Answer:** Snowflake supports two concurrent public keys per user object: `RSA_PUBLIC_KEY` and `RSA_PUBLIC_KEY_2`. During rotation, generate a new key pair and set it as `RSA_PUBLIC_KEY_2` on the user object. Update the service account''s client configuration to use the new private key. Once confirmed working, remove the old key from `RSA_PUBLIC_KEY`. This overlapping window allows zero-downtime rotation without any service interruption.

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

- **`CURRENT_ROLE()`:** checks the session''s active role
- **`INVOKER_ROLE()`:** checks the executing role in a SQL statement (relevant for owner''s rights procedures)
- **`IS_ROLE_IN_SESSION()`:** returns TRUE/FALSE checking if a specific role is in the current session''s active roles

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
- **Multi-tenant SaaS (B2B):** Each tenant''s data is in the same table with a `tenant_id` column. Row access policy filters by tenant based on the querying role. Masking policy on sensitive business metrics: only the tenant''s own admin role sees real numbers, all other roles see aggregated averages.
- **Retail analytics shared via Snowflake Marketplace:** Database roles on the shared database grant access to curated secure views. Masking policies on the underlying tables ensure that even if someone gains access to raw tables (they shouldn''t), PII is still masked. Defense-in-depth.

### Common Questions (FAQ)
**Q: Can masking policies reference other tables?**
A: Yes. You can query a mapping table inside the masking policy body (subquery).

**Q: Do row access policies work on materialized views?**
A: No. RAP is not supported on materialized views.

**Q: What''s the difference between projection policy and masking policy?**
A: Masking replaces the value (e.g., `***`). Projection prevents the column from appearing in results entirely but allows its use in predicates.

### Example Scenario Questions — Data Governance

**Scenario:** A healthcare analytics platform has 500+ tables, and new columns containing PHI (emails, phone numbers, SSNs) are added regularly as new data sources are onboarded. The governance team cannot manually review every new column. How should the architect automate masking at scale?
**Answer:** Implement tag-based masking. Run Snowflake''s automatic data classification to detect sensitive columns and apply system tags (e.g., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = ''EMAIL''`). Create masking policies for each sensitivity category (EMAIL, PHONE, SSN) and bind them to the corresponding tags using tag-based masking policy assignments. When new columns are added and classified, the masking policy auto-applies based on the tag — no manual intervention needed. Combine with row access policies for defense-in-depth.

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

- When row-level security isn''t viable for strong legal isolation between tenants, create separate objects (schemas or databases) per tenant
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

## DON''T MIX -- Security Concepts the Exam Tries to Confuse

These are the pairs that look similar but the exam tests you on the EXACT difference. Read the "RULE" line for each -- that''s the one sentence to anchor.

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
| Use case | "Show me `***` instead of SSN" | "Don''t show me EU rows" | "Let me filter by SSN but never see it" |

**RULE:** Masking = you see the row but value is hidden. RAP = you don''t see the row at all. Projection = you can use the column but never display it.

### Aggregation Policy vs Row Access Policy

| | Aggregation | Row Access |
|---|---|---|
| Purpose | Prevent small-group re-identification | Control who sees which rows |
| How | Blocks queries with groups < minimum size | Filters rows per role/context |
| Applied to | Table | Table/View |

**RULE:** RAP = "this role can''t see these rows." Aggregation = "nobody can see groups smaller than N."

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

- Customer-managed key (CMK) wraps Snowflake''s key, which wraps the data key
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
- **Mid-size SaaS company (SOC 2):** Standard edition is fine for SOC 2 -- it''s available on all editions. They document their Snowflake security controls (RBAC, encryption, network policies) in their SOC 2 Type II report. No need to upgrade to Business Critical just for SOC 2.
- **Insurance company (data exfiltration prevention):** `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` at account level. Storage integrations define allowed S3 buckets only. Even if an authorized user can see unmasked data, they cannot COPY it to an unauthorized bucket. Combined with restricted CREATE TABLE privileges to prevent copying unmasked data to new tables.

**Exam trap:** IF YOU SEE "Tri-Secret Secure is available on Enterprise edition" → WRONG because it requires Business Critical.

**Exam trap:** IF YOU SEE "SOC 2 compliance requires Business Critical" → WRONG because SOC 2 reports are available for all editions.

**Exam trap:** IF YOU SEE "Tri-Secret Secure means Snowflake cannot access your data at all" → WRONG because Snowflake still manages the middle key; the customer controls the outer key.

### Common Questions (FAQ)
**Q: What''s the difference between Business Critical and VPS?**
A: Business Critical adds encryption, compliance, PrivateLink. VPS adds a dedicated, isolated Snowflake deployment (separate metadata store, compute).

**Q: Does enabling Tri-Secret Secure affect performance?**
A: Negligible. The key wrapping adds minimal overhead.

### Example Scenario Questions — Compliance

**Scenario:** A US defense contractor needs to process ITAR-controlled data in Snowflake. They also have non-ITAR commercial workloads that don''t require the same isolation. What Snowflake deployment model should the architect recommend?
**Answer:** Deploy a Virtual Private Snowflake (VPS) instance on AWS GovCloud specifically for the ITAR-controlled workloads. VPS provides a fully dedicated, isolated Snowflake deployment with a separate metadata store and compute infrastructure — the strongest isolation level Snowflake offers. For non-ITAR commercial workloads, use a standard Business Critical account in a commercial region. Both accounts can be managed under the same Snowflake Organization for centralized billing, but data and compute are completely separated. Never mix ITAR data with commercial workloads in the same account.

**Scenario:** A healthcare company stores PHI in Snowflake and must comply with HIPAA. Their CISO requires the ability to immediately revoke Snowflake''s access to all data in case of a security incident. What combination of features should the architect implement?
**Answer:** Deploy on Business Critical edition (minimum for HIPAA/PHI support) and sign a Business Associate Agreement (BAA) with Snowflake. Enable Tri-Secret Secure, which adds a customer-managed key (CMK) via AWS KMS, Azure Key Vault, or GCP Cloud KMS that wraps Snowflake''s encryption key. If the CISO needs to revoke access, they revoke the CMK — Snowflake immediately loses the ability to decrypt any data. Complement with PrivateLink for private connectivity, network policies to block all public access, and `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` to prevent credential leakage in stages.

---

## CONFUSING PAIRS — Account & Security

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Who **creates users/roles**? | **USERADMIN** | NOT SECURITYADMIN (SECURITYADMIN *inherits* USERADMIN but its own job is grants) |
| Who **manages grants** (GRANT/REVOKE)? | **SECURITYADMIN** | NOT USERADMIN (USERADMIN only creates users/roles) |
| Who **creates accounts** in an org? | **ORGADMIN** | NOT ACCOUNTADMIN (ACCOUNTADMIN is per-account, not org-level) |
| **Functional roles** vs **access roles** | **Functional** = business function (Data Analyst), **Access** = object privileges (READ_SALES) | Don''t mix — functional roles *inherit from* access roles |
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
- TRAP: *"Store username/password in environment variables"* — **WRONG**, passwords are less secure and can''t enforce MFA

**Scenario 5: "Prevent table owners from granting SELECT to unauthorized roles..."**
- **CORRECT:** **Managed access schema** — only schema owner/MANAGE GRANTS can grant
- TRAP: *"Use row access policies"* — **WRONG**, RAP filters rows but doesn''t prevent grant escalation

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
- TRAP: *"Row access policy"* — **WRONG**, RAP filters rows per role; it doesn''t enforce minimum group sizes

**Scenario 10: "Customer wants full control to revoke Snowflake''s access to their data..."**
- **CORRECT:** **Tri-Secret Secure** (customer-managed key wraps Snowflake''s key) on **Business Critical**
- TRAP: *"Just use Snowflake''s built-in encryption"* — **WRONG**, default encryption doesn''t give the customer a kill switch

**Scenario 11: "5,000 users need SSO, with groups auto-synced from Okta..."**
- **CORRECT:** **SAML 2.0 security integration** for SSO + **SCIM** for user/group provisioning
- TRAP: *"Manually create users with passwords"* — **WRONG**, doesn''t scale, no auto-deprovisioning

**Scenario 12: "New PII column added — must be automatically masked without manual intervention..."**
- **CORRECT:** **Tag-based masking** — tag the column as PII, masking policy auto-applies to all columns with that tag
- TRAP: *"Apply a new masking policy to each column manually"* — **WRONG**, doesn''t scale, easy to miss columns

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

**Q5:** What''s the difference between a functional role and an access role?
**A5:** Access roles hold object privileges; functional roles represent job functions and inherit from access roles.

**Q6:** What does Tri-Secret Secure provide?
**A6:** Customer-managed key wrapping Snowflake''s key — customer can revoke access to their data.

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

## EXPLAIN LIKE I''M 5 -- Domain 1

**1. Multi-Account Strategy**
Imagine you have different toy boxes for different rooms. The bedroom box has bedtime toys, the playroom box has messy-play toys. You keep them separate so glitter doesn''t get on your pillow. That''s multi-account — separate boxes for separate stuff.

**2. Parameter Hierarchy**
Your parents say "bedtime at 8pm" (account rule). But for YOUR room, it''s "bedtime at 8:30pm" (object rule). And tonight, since it''s your birthday, it''s "bedtime at 9pm" (session rule). The most specific rule wins!

**3. Role Inheritance**
You''re the "cookie monitor" at school. That means you can hand out cookies. Your teacher is the "classroom boss" and she has ALL the monitor powers, including yours. Powers flow UP.

**4. Network Policies**
It''s like a guest list at a birthday party. Only kids on the list can come in. If your mom makes a special list just for you, it replaces the main list — doesn''t add to it.

**5. PrivateLink**
Instead of walking to your friend''s house on the public sidewalk, you build a secret tunnel between your houses. Nobody else can see you walking. That''s PrivateLink.

**6. Masking Policies**
You write a secret note. When your best friend reads it, they see the real words. When anyone else reads it, they see "XXXXX." Same note, different views.

**7. Row Access Policies**
A magic coloring book where you can only see pages that have YOUR name on them. Other kids have the same book but see different pages.

**8. Tri-Secret Secure**
You lock your diary with YOUR lock. Then put it in a box with SNOWFLAKE''S lock. Both locks needed to read it. You can remove your lock anytime and nobody can read it.

**9. SSO / SAML**
Instead of remembering a password for every website, you have one magic key (your school badge) that opens all the doors.

**10. Object Tagging**
Putting colored stickers on your toys: red for "fragile," blue for "share with friends." Later you can say "hide ALL red-                                        ');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 'pt',
  '# Domínio 1: Estratégia de Conta e Segurança

> **Cobertura do Programa ARA-C01:** Estratégia de Conta/DB, Segurança/Privacidade/Conformidade, Princípios de Segurança

---

## 1.1 ESTRATÉGIA DE CONTA

**Arquitetura de Conta Única vs Multi-Conta**

- **Conta única:** mais simples, todos os ambientes (dev/staging/prod) compartilham uma conta
  - Mais barato, menos overhead
  - Risco: raio de explosão é a conta inteira (um GRANT ruim afeta tudo)
- **Multi-conta:** contas separadas por ambiente, unidade de negócio ou região
  - Isolamento mais forte, políticas de segurança independentes, cobrança separada
  - Necessário para conformidade estrita (ex: dados PCI em sua própria conta)
- **Snowflake Organizations:** contêiner pai que agrupa múltiplas contas
  - Habilita replicação cross-account, failover groups e cobrança centralizada
  - Role ORGADMIN gerencia contas dentro da org
  - Criação de conta via `CREATE ACCOUNT` (apenas ORGADMIN)

**Padrões de Segmentação**

- **Por ambiente:** contas dev / staging / prod
- **Por região:** contas em diferentes regiões de nuvem para residência de dados
- **Por unidade de negócio:** finanças, marketing, engenharia cada uma com a sua
- **Por conformidade:** conta com escopo PCI, conta com escopo HIPAA

### Por Que Isso Importa
Uma empresa de saúde precisa de dados HIPAA isolados de analytics de marketing. Multi-conta com replicação no nível de org permite compartilhar dados não-PHI entre contas enquanto mantém PHI protegido.

### Melhores Práticas
- Use Organizations para gerenciar centralmente contas e cobrança
- Replique objetos de segurança (network policies, RBAC) via replicação de conta
- Mantenha contas de produção em edição Business Critical ou superior para conformidade

**Armadilha do exame:** SE VOCÊ VER "use uma conta única com bancos de dados separados para isolamento PCI" → ERRADO porque PCI requer isolamento no nível de conta, não apenas no nível de banco de dados.

**Armadilha do exame:** SE VOCÊ VER "ACCOUNTADMIN pode criar novas contas" → ERRADO porque apenas ORGADMIN pode criar contas dentro de uma Organization.

**Armadilha do exame:** SE VOCÊ VER "Organizations requerem edição Enterprise" → ERRADO porque Organizations estão disponíveis em todas as edições.

### Perguntas Frequentes (FAQ)
**P: Posso compartilhar dados entre contas sem Organizations?**
R: Sim, via Secure Data Sharing (listings), mas Organizations adicionam replicação, failover e gerenciamento centralizado.

**P: Cada conta em uma org recebe cobrança separada?**
R: Por padrão a cobrança é consolidada no nível da org, mas você pode visualizar uso por conta.

### Exemplos de Perguntas de Cenário — Estratégia de Conta

**Cenário:** Uma seguradora global opera na UE, EUA e APAC. As regulamentações da UE exigem que os dados de clientes da UE nunca saiam do solo europeu. A equipe dos EUA precisa de acesso a métricas agregadas (não-PII) de todas as regiões para dashboards globais. Como o arquiteto deve projetar a topologia de contas Snowflake?
**Resposta:** Implante contas Snowflake separadas por região (UE, EUA, APAC) dentro de uma única Snowflake Organization. Cada conta regional armazena seus próprios dados de clientes em uma região de nuvem que satisfaça os requisitos de residência de dados. Use replicação de banco de dados para replicar datasets agregados não-PII das contas UE e APAC para a conta dos EUA para dashboards globais. ORGADMIN gerencia a criação de contas e cobrança centralizada. Isso garante que os dados da UE nunca saiam da conta da UE enquanto habilita analytics cross-region em agregações seguras.

**Cenário:** Uma fintech startup está crescendo de 10 para 500 funcionários e atualmente usa uma única conta Snowflake para dev, staging e produção. Um estagiário acidentalmente executou `GRANT ALL ON DATABASE prod_db TO ROLE PUBLIC` em produção. Qual mudança arquitetural previne essa classe de incidente?
**Resposta:** Migre para uma arquitetura multi-conta com contas separadas para dev, staging e produção dentro de uma Snowflake Organization. Isso fornece isolamento de raio de explosão no nível de conta — um GRANT mal configurado em dev não pode afetar produção. Adicionalmente, use managed access schemas na conta de produção para que apenas o dono do schema (ou detentor de MANAGE GRANTS) possa emitir grants, prevenindo escalação de privilégios por donos individuais de objetos. Replique objetos de segurança entre contas usando replicação de conta para RBAC consistente.

---

## 1.2 HIERARQUIA DE PARÂMETROS

**Três Níveis (de cima para baixo):**

1. **Account** — definido por ACCOUNTADMIN, aplica-se globalmente
2. **Object** — definido em warehouse, banco de dados, schema, tabela, usuário
3. **Session** — definido pelo usuário para sua sessão atual (`ALTER SESSION`)

**Regra de Precedência:** O mais específico vence. Session > Object > Account.

**Parâmetros-Chave que Você Precisa Conhecer:**

| Parâmetro | Nível Típico | Notas |
|---|---|---|
| `STATEMENT_TIMEOUT_IN_SECONDS` | Account / Session | Encerra queries longas |
| `DATA_RETENTION_TIME_IN_DAYS` | Account / Object | Janela de Time Travel (0-90) |
| `MIN_DATA_RETENTION_TIME_IN_DAYS` | Apenas Account | Piso que objetos não podem ficar abaixo |
| `NETWORK_POLICY` | Account / User | Nível de usuário sobrescreve nível de conta |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` | Account | Endurecimento de segurança |

### Por Que Isso Importa
Um DBA define timeout no nível de conta para 1 hora. Um cientista de dados define timeout de sessão para 4 horas para um job grande de ML. O nível de sessão vence para esse usuário.

### Melhores Práticas
- Defina `MIN_DATA_RETENTION_TIME_IN_DAYS` no nível de conta para impedir que usuários definam Time Travel para 0
- Use `STATEMENT_TIMEOUT_IN_SECONDS` em warehouses para prevenir queries descontroladas
- Documente quais parâmetros são definidos em qual nível

**Armadilha do exame:** SE VOCÊ VER "parâmetro de conta sempre sobrescreve parâmetro de sessão" → ERRADO porque sessão é mais específico e vence.

**Armadilha do exame:** SE VOCÊ VER "MIN_DATA_RETENTION_TIME_IN_DAYS pode ser definido em um schema" → ERRADO porque é apenas no nível de conta.

**Armadilha do exame:** SE VOCÊ VER "uma network policy no nível de usuário é aditiva à de nível de conta" → ERRADO porque a network policy no nível de usuário **substitui** a política no nível de conta para aquele usuário.

### Perguntas Frequentes (FAQ)
**P: Se eu definir DATA_RETENTION_TIME_IN_DAYS = 1 em uma tabela mas o MIN da conta é 7, qual vence?**
R: O MIN vence — a tabela recebe 7 dias. MIN define um piso.

**P: Um não-ACCOUNTADMIN pode definir parâmetros de conta?**
R: Não. Apenas ACCOUNTADMIN (ou roles com o privilégio concedido) pode definir parâmetros no nível de conta.


### Exemplos de Perguntas de Cenário — Parameter Hierarchy

**Cenário:** A data engineering team runs large Spark-based ETL jobs that can take up to 6 hours. The account-level `STATEMENT_TIMEOUT_IN_SECONDS` is set to 3600 (1 hour) to protect against runaway queries. The ETL jobs keep getting killed. The team asks the architect to raise the account timeout to 24 hours. What is the correct approach?
**Resposta:** Do not raise the account-level timeout — that would expose all users to potential 24-hour runaway queries. Instead, set `STATEMENT_TIMEOUT_IN_SECONDS` at the object level on the dedicated ETL warehouse to 21600 (6 hours). Session-level and object-level parameters override the account default for that specific context. This way, BI users on other warehouses still get the 1-hour safety net while ETL has the headroom it needs.

**Cenário:** A compliance officer discovers that a developer set `DATA_RETENTION_TIME_IN_DAYS = 0` on several staging tables, meaning accidental deletes cannot be recovered via Time Travel. How should the architect prevent this from happening again across the entire account?
**Resposta:** Set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level (e.g., to 1 or 7 days). This parameter is account-level only and establishes a floor that no individual database, schema, or table can go below. Even if a developer sets `DATA_RETENTION_TIME_IN_DAYS = 0` on a table, the MIN floor overrides it, ensuring Time Travel is always available for at least the minimum period.

---

---

## 1.3 CONTROLE DE ACESSO BASEADO EM ROLES

**Conceitos Fundamentais**

- Snowflake usa **Role-Based Access Control (RBAC)** — privilégios são concedidos a roles, roles são concedidas a usuários
- Roles formam uma hierarquia: privilégios de role filho fluem PARA CIMA para roles pai
- **Roles definidas pelo sistema:** ORGADMIN > ACCOUNTADMIN > SECURITYADMIN > SYSADMIN > USERADMIN > PUBLIC

**Herança de Privilégios**

- Se Role A é concedida a Role B, então Role B herda TODOS os privilégios da Role A
- ACCOUNTADMIN deve herdar de tanto SECURITYADMIN quanto SYSADMIN
- Nunca use ACCOUNTADMIN para trabalho diário

**Database Roles**

- Com escopo para um único banco de dados (portável com o banco de dados durante replicação/clonagem)
- Concedidas a roles no nível de conta ou outras database roles
- Ideal para compartilhamento: consumidores recebem database roles, não account roles

**Padrão de Roles Funcionais vs de Acesso**

- **Roles de acesso:** detêm privilégios de objeto (ex: `ANALYST_READ` tem SELECT em tabelas)
- **Roles funcionais:** representam funções de trabalho, herdam de roles de acesso (ex: `DATA_ANALYST` herda `ANALYST_READ` + `DASHBOARD_WRITE`)
- Este modelo de duas camadas simplifica o gerenciamento em escala

**Secondary Roles**

- `USE SECONDARY ROLES ALL` — usuário obtém união de privilégios de todas as roles concedidas
- Evita troca constante de role
- Role secundária padrão pode ser definida no objeto do usuário

### Por Que Isso Importa
Uma equipe de analytics de 500 pessoas precisa de acesso granular. Roles funcionais (Data Analyst, Data Engineer) herdam de roles de acesso refinadas. Novo contratado? Conceda uma role funcional. Pronto.

### Melhores Práticas
- Nunca conceda privilégios diretamente a usuários — sempre use roles
- SYSADMIN deve possuir todos os bancos de dados/warehouses (ou roles customizadas concedidas a SYSADMIN)
- Use database roles para objetos compartilhados via Secure Sharing
- Separe SECURITYADMIN (gerencia grants) de SYSADMIN (gerencia objetos)

**Armadilha do exame:** SE VOCÊ VER "ACCOUNTADMIN deve ser a role padrão para admins" → ERRADO porque ACCOUNTADMIN é apenas para emergências; trabalho diário deve usar roles inferiores.

**Armadilha do exame:** SE VOCÊ VER "database roles podem ser concedidas diretamente a usuários" → ERRADO porque database roles devem ser concedidas a roles no nível de conta primeiro (ou outras database roles).

**Armadilha do exame:** SE VOCÊ VER "herança de privilégios flui para baixo" → ERRADO porque flui PARA CIMA na hierarquia de roles.

### Perguntas Frequentes (FAQ)
**P: Qual é a diferença entre SECURITYADMIN e USERADMIN?**
R: USERADMIN gerencia usuários e roles. SECURITYADMIN herda USERADMIN e também pode gerenciar grants (GRANT/REVOKE).

**P: Posso usar secondary roles com Secure Sharing?**
R: Não. Shares usam a database role designada do share; secondary roles não se aplicam no contexto de compartilhamento.


### Exemplos de Perguntas de Cenário — Role-Based Access Control

**Cenário:** A 2,000-person enterprise has 15 departments, each with analysts, engineers, and managers. New hires join weekly. Currently, each new hire requires 10+ individual GRANT statements. The security team wants a scalable model. What RBAC pattern should the architect implement?
**Resposta:** Implement the functional-role / access-role pattern. Create fine-grained access roles that hold object-level privileges (e.g., `SALES_READ`, `SALES_WRITE`, `MARKETING_READ`). Then create functional roles representing job functions (e.g., `SALES_ANALYST`, `SALES_ENGINEER`, `MARKETING_MANAGER`) that inherit from the appropriate access roles. When a new hire joins, grant them a single functional role. All access roles should be granted to SYSADMIN for hierarchy completeness. This reduces onboarding to one GRANT per new user and simplifies auditing.

**Cenário:** A data marketplace team shares curated datasets to external consumers via Secure Data Sharing. They need consumers to have SELECT on specific views without exposing account-level role structures. What role type should the architect use?
**Resposta:** Use database roles. Database roles are scoped to a single database and are portable with the database during sharing. Grant SELECT on the secure views to database roles within the shared database, then assign those database roles to the share. Consumers receive the database roles without visibility into the provider''s account-level role hierarchy. This also ensures that if the database is replicated or cloned, the database roles travel with it.

**Cenário:** Multiple analysts complain about constantly switching roles to access tables in different databases. Each analyst has 4-5 roles granted. How should the architect solve this without restructuring the entire RBAC model?
**Resposta:** Enable secondary roles by having analysts run `USE SECONDARY ROLES ALL` at session start (or set a default secondary role on the user object). This gives users the union of privileges from all their granted roles simultaneously, eliminating constant `USE ROLE` switching. This is a session-level change and does not affect the underlying RBAC model or security posture.

---

---

## 1.4 SEGURANÇA DE REDE

**Network Policies**

- Listas de IP permitidos/bloqueados aplicadas no nível de conta ou usuário
- Use `ALLOWED_IP_LIST` e `BLOCKED_IP_LIST`
- Política no nível de usuário **substitui** (não complementa) a política no nível de conta

**Network Rules (mais recentes, mais flexíveis)**

- Podem referenciar faixas de IP, endpoints VPC, nomes de host
- Anexadas a network policies para regras modulares e reutilizáveis
- Suportam direções `INGRESS` (entrada) e `EGRESS` (saída)

**AWS PrivateLink / Azure Private Link / GCP Private Service Connect**

- Conectividade privada da sua VPC ao Snowflake — sem internet pública
- Requer edição Business Critical ou superior
- Você recebe uma URL de endpoint privado (ex: `account.privatelink.snowflakecomputing.com`)
- NÃO substitui network policies — use ambos juntos

**External Access Integrations**

- Permitem que UDFs/procedures chamem APIs externas (ex: endpoints REST)
- Requer criar uma External Access Integration + Network Rule (egress)
- Segredos armazenados em objetos secret do Snowflake, não no código

### Por Que Isso Importa
Um banco precisa que todo o tráfego do Snowflake fique em sua rede privada. PrivateLink + network policies + bloqueio de acesso público = zero exposição à internet pública.

### Melhores Práticas
- Sempre defina uma network policy no nível de conta (mesmo que ampla) como rede de segurança
- Use PrivateLink para workloads de produção em indústrias regulamentadas
- Teste network policies em não-produção antes de aplicar no nível de conta
- Use network rules em vez de listas de IP brutas para manutenibilidade

**Armadilha do exame:** SE VOCÊ VER "PrivateLink está disponível na edição Standard" → ERRADO porque requer Business Critical ou superior.

**Armadilha do exame:** SE VOCÊ VER "network policies suportam bloqueio por FQDN/hostname" → ERRADO para network policies sozinhas; você precisa de network rules para controles baseados em hostname.

**Armadilha do exame:** SE VOCÊ VER "PrivateLink elimina a necessidade de network policies" → ERRADO porque servem propósitos diferentes e devem ser usados juntos.

### Perguntas Frequentes (FAQ)
**P: Se eu bloquear todos os IPs públicos, ainda posso usar o Snowsight?**
R: Apenas via URL do Snowsight habilitada para PrivateLink ou se você adicionar os IPs do Snowsight do Snowflake à lista de permitidos.

**P: Posso ter tanto network policies de conta quanto de usuário?**
R: Sim, mas a política no nível de usuário substitui completamente (não mescla com) a política de conta para aquele usuário.


### Exemplos de Perguntas de Cenário — Network Security

**Cenário:** A large bank is migrating to Snowflake and requires zero public internet exposure. Their applications run in AWS VPCs across three regions. Some teams also need Snowsight access from corporate offices with static IPs. How should the architect design the network architecture?
**Resposta:** Enable AWS PrivateLink to establish private connectivity from each VPC to Snowflake — traffic stays on the AWS backbone and never traverses the public internet. Create a network policy at the account level that blocks all public IPs by default. For Snowsight access from corporate offices, add the corporate static IPs to the `ALLOWED_IP_LIST` in the account-level network policy (or use a user-level network policy for specific admin users who need Snowsight). PrivateLink requires Business Critical edition or higher. Use network rules for modular, reusable IP and VPC endpoint definitions.

**Cenário:** A data engineering team needs their Python UDFs to call an external REST API for geocoding. The security team does not allow arbitrary outbound internet access from Snowflake. What is the correct architecture?
**Resposta:** Create a network rule with `MODE = EGRESS` specifying the geocoding API''s hostname. Create an external access integration referencing that network rule and a Snowflake secret object containing the API key. Grant the external access integration to the UDF. This allows controlled, auditable outbound access to only the specified endpoint — no blanket internet access. The API credentials are stored in Snowflake''s secret management, never in code.

---

---

## 1.5 AUTENTICAÇÃO

**SSO / SAML 2.0**

- Snowflake atua como Service Provider (SP)
- Seu IdP (Okta, Azure AD, etc.) autentica usuários
- Configurado via integração de segurança SAML2
- Suporta SCIM para provisionamento automatizado de usuários/grupos

**OAuth**

- External OAuth: token do seu IdP (Okta, Azure AD, PingFederate)
- Snowflake OAuth: Snowflake emite o token (usado por apps parceiros como Tableau)
- Ambos usam integrações de segurança

**MFA (Autenticação Multi-Fator)**

- MFA Duo integrado, sem custo extra
- Pode ser aplicado via políticas de autenticação (`AUTHENTICATION_POLICY`)
- `CLIENT_TYPES` na política de auth controla quais clientes devem usar MFA

**Autenticação por Par de Chaves**

- RSA 2048-bit mínimo
- Chave pública armazenada no objeto do usuário, chave privada mantida pelo cliente
- Suporta rotação de chaves (duas chaves ativas: `RSA_PUBLIC_KEY` e `RSA_PUBLIC_KEY_2`)
- Necessário para contas de serviço / automação (Snowpipe, conectores)

**Políticas de Autenticação**

- Controlam métodos de auth permitidos por conta ou por usuário
- Podem restringir a `CLIENT_TYPES` específicos (ex: SNOWFLAKE_UI, DRIVERS)
- Podem aplicar MFA para tipos de cliente específicos

**Autenticação Federada**

- Combina SSO + MFA para postura mais forte
- Usuários autenticam via IdP, depois desafio MFA

### Por Que Isso Importa
Uma empresa com 5.000 usuários precisa de SSO via Okta, MFA aplicado para usuários de UI, e par de chaves para pipelines CI/CD. Políticas de autenticação permitem aplicar regras diferentes por caso de uso.

### Melhores Práticas
- Aplique MFA para todos os usuários humanos (no mínimo ACCOUNTADMIN)
- Use autenticação por par de chaves para todas as contas de serviço / automação
- Use SCIM para sincronizar usuários/grupos do seu IdP
- Defina políticas de autenticação para bloquear acesso apenas por senha

**Armadilha do exame:** SE VOCÊ VER "Snowflake OAuth e External OAuth são a mesma coisa" → ERRADO porque Snowflake OAuth é emitido pelo Snowflake; External OAuth vem do seu IdP.

**Armadilha do exame:** SE VOCÊ VER "autenticação por par de chaves requer edição Enterprise" → ERRADO porque está disponível em todas as edições.

**Armadilha do exame:** SE VOCÊ VER "MFA pode ser aplicado via network policy" → ERRADO porque aplicação de MFA usa políticas de autenticação, não network policies.

**Armadilha do exame:** SE VOCÊ VER "SCIM cria roles automaticamente" → ERRADO porque SCIM provisiona usuários e grupos mas NÃO cria roles do Snowflake automaticamente.

### Perguntas Frequentes (FAQ)
**P: Posso usar tanto SSO quanto login por senha?**
R: Sim, a menos que você defina uma política de autenticação que bloqueie auth por senha. Por padrão ambos funcionam.

**P: O que acontece se um usuário perder seu par de chaves?**
R: O admin pode definir uma nova chave pública no objeto do usuário. O segundo slot de chave permite rotação sem downtime.


### Exemplos de Perguntas de Cenário — Authentication

**Cenário:** An enterprise has 5,000 employees using Okta for SSO, plus 200 CI/CD service accounts running nightly ETL pipelines. The CISO mandates MFA for all human users accessing Snowsight but cannot require MFA for automated pipelines (which have no human to approve a push notification). How should the architect configure authentication?
**Resposta:** Configure a SAML 2.0 security integration with Okta for SSO for all human users. Create an authentication policy that enforces MFA with `CLIENT_TYPES` set to `SNOWFLAKE_UI` (Snowsight) — this requires MFA for interactive logins but not for programmatic drivers. For the 200 CI/CD service accounts, use key-pair authentication (RSA 2048-bit minimum) with the public key stored on each service user object. Set a separate authentication policy on service accounts that allows only key-pair auth and blocks password-based access entirely. Use SCIM to auto-provision and deprovision human users from Okta.

**Cenário:** A company rotates credentials quarterly. They have 50 service accounts using key-pair authentication. How can the architect enable zero-downtime key rotation?
**Resposta:** Snowflake supports two concurrent public keys per user object: `RSA_PUBLIC_KEY` and `RSA_PUBLIC_KEY_2`. During rotation, generate a new key pair and set it as `RSA_PUBLIC_KEY_2` on the user object. Update the service account''s client configuration to use the new private key. Once confirmed working, remove the old key from `RSA_PUBLIC_KEY`. This overlapping window allows zero-downtime rotation without any service interruption.

---

---

## 1.6 GOVERNANÇA DE DADOS

**Masking Policies (Dynamic Data Masking)**

- Segurança no nível de coluna: retorna valor mascarado com base na role que consulta
- A política é uma função SQL: `CREATE MASKING POLICY ... RETURNS <type> -> CASE WHEN ...`
- Aplicada a colunas via `ALTER TABLE ... ALTER COLUMN ... SET MASKING POLICY`
- Uma masking policy por coluna
- Suporta mascaramento condicional (baseado em role, outra coluna, etc.)

**Row Access Policies (RAP)**

- Segurança no nível de linha: filtra linhas com base no contexto de consulta
- Retorna `TRUE` (linha visível) ou `FALSE` (linha oculta)
- Uma RAP por tabela/view
- Pode referenciar tabelas de mapeamento para filtragem de role-para-região

**Aggregation Policies**

- Impedem queries que retornam resultados abaixo de um tamanho mínimo de grupo
- Protege contra re-identificação em analytics
- Privacidade no nível de entidade (ex: deve agregar pelo menos 5 pacientes)

**Projection Policies**

- Impedem `SELECT column` diretamente — coluna só pode ser usada em WHERE, JOIN, GROUP BY
- Caso de uso: permitir filtrar por SSN mas nunca exibi-lo

**Object Tagging**

- Metadados chave-valor em qualquer objeto (tabela, coluna, warehouse, etc.)
- Linhagem de tags: tags se propagam através de views
- Base para masking policies baseadas em tags (aplicar mascaramento a todas as colunas com tag X)
- Tags de sistema da classificação (ex: `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = EMAIL`)

**Linhagem de Dados (ACCESS_HISTORY)**

- `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY` — rastreia leituras/escritas no nível de coluna
- Mostra quais colunas foram acessadas, por quem, e como os dados fluíram
- Retenção de 365 dias
- Requer edição Enterprise ou superior

### Por Que Isso Importa
Uma empresa de varejo tageia todas as colunas PII, depois aplica uma única masking policy a cada coluna com a tag PII. Quando uma nova coluna PII é adicionada e tageada, o mascaramento é automático.

### Melhores Práticas
- Use mascaramento baseado em tags para governança escalável
- Combine RAP + masking para defesa em profundidade
- Use aggregation policies para datasets de analytics expostos a públicos amplos
- Execute classificação de dados para auto-detectar dados sensíveis

**Armadilha do exame:** SE VOCÊ VER "você pode aplicar duas masking policies na mesma coluna" → ERRADO porque apenas uma masking policy por coluna é permitida.

**Armadilha do exame:** SE VOCÊ VER "row access policies são aplicadas a colunas" → ERRADO porque RAP é aplicada a tabelas/views, não colunas individuais.

**Armadilha do exame:** SE VOCÊ VER "object tags requerem edição Business Critical" → ERRADO porque tagging está disponível em Enterprise e superior.

**Armadilha do exame:** SE VOCÊ VER "aggregation policies filtram linhas" → ERRADO porque elas bloqueiam queries que produzem grupos abaixo do tamanho mínimo, não filtram linhas individuais.

### Perguntas Frequentes (FAQ)
**P: Masking policies podem referenciar outras tabelas?**
R: Sim. Você pode consultar uma tabela de mapeamento dentro do corpo da masking policy (subquery).

**P: Row access policies funcionam em materialized views?**
R: Não. RAP não é suportada em materialized views.

**P: Qual é a diferença entre projection policy e masking policy?**
R: Masking substitui o valor (ex: `***`). Projection impede que a coluna apareça nos resultados completamente mas permite seu uso em predicados.


### Exemplos de Perguntas de Cenário — Data Governance

**Cenário:** A healthcare analytics platform has 500+ tables, and new columns containing PHI (emails, phone numbers, SSNs) are added regularly as new data sources are onboarded. The governance team cannot manually review every new column. How should the architect automate masking at scale?
**Resposta:** Implement tag-based masking. Run Snowflake''s automatic data classification to detect sensitive columns and apply system tags (e.g., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = ''EMAIL''`). Create masking policies for each sensitivity category (EMAIL, PHONE, SSN) and bind them to the corresponding tags using tag-based masking policy assignments. When new columns are added and classified, the masking policy auto-applies based on the tag — no manual intervention needed. Combine with row access policies for defense-in-depth.

**Cenário:** A pharmaceutical company needs to share a clinical trial dataset with external researchers. Researchers must be able to filter by patient demographics (age, gender, zip code) for cohort selection, but must never see individual patient records — results must aggregate at least 20 patients per group to prevent re-identification. How should the architect configure governance?
**Resposta:** Apply an aggregation policy on the shared dataset with a minimum group size of 20 — any query that produces groups with fewer than 20 patients is blocked. Additionally, apply projection policies on direct patient identifiers (patient_id, SSN) so researchers can use them in WHERE/JOIN/GROUP BY for cohort selection but cannot SELECT them in results. Share the data via secure views with these policies applied. This provides layered privacy: aggregation prevents small-group re-identification, and projection prevents direct identifier exposure.

**Cenário:** An internal audit requires understanding which roles accessed which PII columns over the past year, including data flows through views and downstream tables. What Snowflake feature supports this?
**Resposta:** Query `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY`, which provides column-level data lineage tracking with 365-day retention. It records which columns were read (`base_objects_accessed`) and written (`objects_modified`), by which role, including data flows through views and transformations. This supports audit requirements without requiring any custom logging infrastructure. Requires Enterprise edition or higher.

---

---

## 1.7 CONFORMIDADE

**Funcionalidades por Edição para Conformidade**

| Requisito | Edição Mínima |
|---|---|
| HIPAA / HITRUST | Business Critical |
| PCI DSS | Business Critical |
| SOC 1/2 | Todas as edições |
| FedRAMP Moderate | Virtual Private Snowflake (VPS) no AWS GovCloud |
| ITAR | VPS no AWS GovCloud |
| Suporte a PHI | Business Critical com BAA |

**Tri-Secret Secure**

- Chave gerenciada pelo cliente (CMK) envolve a chave do Snowflake, que envolve a chave de dados
- Requer edição Business Critical
- Se o cliente revogar a CMK, Snowflake não pode descriptografar dados — controle total do cliente
- Suportado em AWS (KMS), Azure (Key Vault), GCP (Cloud KMS)

**Storage Integrations**

- Acesso seguro e governado ao armazenamento de nuvem externo (S3, GCS, Azure Blob)
- Usa IAM roles / service principals — sem credenciais brutas no SQL
- Necessário para external stages, tabelas externas, acesso a data lake
- Parâmetro `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` força seu uso

### Por Que Isso Importa
Uma empresa de saúde armazenando PHI precisa de Business Critical + BAA + Tri-Secret Secure + PrivateLink. Faltar qualquer um quebra a conformidade HIPAA.

### Melhores Práticas
- Habilite Tri-Secret Secure para dados sobre os quais você precisa de controle total
- Exija storage integrations no nível de conta para prevenir vazamento de credenciais
- Documente sua arquitetura de conformidade para auditores
- Use VPS apenas quando FedRAMP / ITAR for necessário (custo significativo)

**Armadilha do exame:** SE VOCÊ VER "Tri-Secret Secure está disponível na edição Enterprise" → ERRADO porque requer Business Critical.

**Armadilha do exame:** SE VOCÊ VER "conformidade SOC 2 requer Business Critical" → ERRADO porque relatórios SOC 2 estão disponíveis para todas as edições.

**Armadilha do exame:** SE VOCÊ VER "Tri-Secret Secure significa que Snowflake não pode acessar seus dados de forma alguma" → ERRADO porque Snowflake ainda gerencia a chave intermediária; o cliente controla a chave externa.

### Perguntas Frequentes (FAQ)
**P: Qual é a diferença entre Business Critical e VPS?**
R: Business Critical adiciona criptografia, conformidade, PrivateLink. VPS adiciona um deployment Snowflake dedicado e isolado (metadata store separado, computação separada).

**P: Habilitar Tri-Secret Secure afeta a performance?**
R: Insignificantemente. O envolvimento de chaves adiciona overhead mínimo.


### Exemplos de Perguntas de Cenário — Compliance

**Cenário:** A US defense contractor needs to process ITAR-controlled data in Snowflake. They also have non-ITAR commercial workloads that don''t require the same isolation. What Snowflake deployment model should the architect recommend?
**Resposta:** Deploy a Virtual Private Snowflake (VPS) instance on AWS GovCloud specifically for the ITAR-controlled workloads. VPS provides a fully dedicated, isolated Snowflake deployment with a separate metadata store and compute infrastructure — the strongest isolation level Snowflake offers. For non-ITAR commercial workloads, use a standard Business Critical account in a commercial region. Both accounts can be managed under the same Snowflake Organization for centralized billing, but data and compute are completely separated. Never mix ITAR data with commercial workloads in the same account.

**Cenário:** A healthcare company stores PHI in Snowflake and must comply with HIPAA. Their CISO requires the ability to immediately revoke Snowflake''s access to all data in case of a security incident. What combination of features should the architect implement?
**Resposta:** Deploy on Business Critical edition (minimum for HIPAA/PHI support) and sign a Business Associate Agreement (BAA) with Snowflake. Enable Tri-Secret Secure, which adds a customer-managed key (CMK) via AWS KMS, Azure Key Vault, or GCP Cloud KMS that wraps Snowflake''s encryption key. If the CISO needs to revoke access, they revoke the CMK — Snowflake immediately loses the ability to decrypt any data. Complement with PrivateLink for private connectivity, network policies to block all public access, and `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` to prevent credential leakage in stages.

---

---

## PARES CONFUSOS — Conta e Segurança

| Perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| Quem **cria usuários/roles**? | **USERADMIN** | NÃO SECURITYADMIN (SECURITYADMIN *herda* USERADMIN mas sua função é grants) |
| Quem **gerencia grants** (GRANT/REVOKE)? | **SECURITYADMIN** | NÃO USERADMIN (USERADMIN apenas cria usuários/roles) |
| Quem **cria contas** em uma org? | **ORGADMIN** | NÃO ACCOUNTADMIN (ACCOUNTADMIN é por conta, não no nível de org) |
| **Roles funcionais** vs **roles de acesso** | **Funcional** = função de negócio (Data Analyst), **Acesso** = privilégios de objeto (READ_SALES) | Não misture — roles funcionais *herdam de* roles de acesso |
| **Database roles** vs **account roles** | **Database roles** = escopo de um DB, portáveis com replicação/clonagem | **Account roles** = escopo de conta, NÃO portáveis com DB |
| **Network policy** vs **network rule** | **Policy** = lista de IP permitidos/bloqueados aplicada a conta/usuário | **Rule** = mais granular (host, porta, endpoint VPC), anexada a policies |
| **Column masking** vs **row access policy** | **Masking** = esconde/substitui *valores* de coluna | **RAP** = esconde *linhas* inteiras — aplicada à tabela, não à coluna |
| **Aggregation policy** vs **projection policy** | **Aggregation** = bloqueia queries abaixo do tamanho mínimo de grupo | **Projection** = impede coluna de aparecer nos resultados do SELECT |
| **External tokenization** vs **dynamic masking** | **External** = serviço terceiro (Protegrity) substitui valor | **Dynamic masking** = nativo do Snowflake, baseado em role no momento da query |
| **PrivateLink** vs **VPN** | **PrivateLink** = conexão direta pelo backbone da nuvem, sem internet | **VPN** = túnel criptografado *pela* internet |
| **Authentication policy** vs **security integration** | **Auth policy** = regras de *como* usuários podem fazer login (MFA, tipos de cliente) | **Security integration** = *configuração* de SSO/OAuth com um IdP externo |
| Network policy de usuário + de conta | Nível de usuário **substitui** nível de conta para aquele usuário | NÃO é aditivo — a política de conta é *ignorada* para aquele usuário |
| **Snowflake OAuth** vs **External OAuth** | **Snowflake OAuth** = Snowflake emite token (apps parceiros) | **External OAuth** = seu IdP emite o token |
| **SCIM** provisiona... | **Usuários e grupos** automaticamente do IdP | NÃO roles — SCIM NÃO cria roles do Snowflake |
| Nível de **MIN_DATA_RETENTION** | **Apenas nível de conta** (define um piso) | NÃO pode ser definido em schema ou tabela |

---

## ÁRVORES DE DECISÃO DE CENÁRIOS — Conta e Segurança

**Cenário 1: "Uma empresa precisa de dados completamente isolados para conformidade PCI..."**
- **CORRETO:** **Contas** Snowflake separadas (dados PCI em sua própria conta, edição Business Critical)
- ARMADILHA: *"Usar bancos de dados diferentes na mesma conta"* — **ERRADO**, mesma conta = metadados compartilhados, ACCOUNTADMIN compartilhado, não é isolamento real

**Cenário 2: "Um analista deve ver SSNs mascarados mas um gerente vê os reais..."**
- **CORRETO:** **Masking policy de dados dinâmicos** com lógica CASE baseada em role
- ARMADILHA: *"Criar duas views separadas"* — **ERRADO**, não escalável, difícil de manter, contorna governança

**Cenário 3: "Bloquear todo acesso à internet pública ao Snowflake..."**
- **CORRETO:** **PrivateLink** + **network policy** bloqueando todos os IPs públicos
- ARMADILHA: *"Apenas usar uma VPN"* — **ERRADO**, VPN ainda atravessa internet pública; PrivateLink fica no backbone da nuvem

**Cenário 4: "Uma conta de serviço precisa conectar ao Snowflake de um pipeline CI/CD..."**
- **CORRETO:** **Autenticação por par de chaves** (RSA 2048-bit)
- ARMADILHA: *"Armazenar usuário/senha em variáveis de ambiente"* — **ERRADO**, senhas são menos seguras e não podem aplicar MFA

**Cenário 5: "Impedir que donos de tabelas concedam SELECT para roles não autorizadas..."**
- **CORRETO:** **Managed access schema** — apenas dono do schema/MANAGE GRANTS pode conceder
- ARMADILHA: *"Usar row access policies"* — **ERRADO**, RAP filtra linhas mas não previne escalação de grants

**Cenário 6: "Permitir filtrar por SSN na cláusula WHERE mas nunca exibir a coluna..."**
- **CORRETO:** **Projection policy** na coluna SSN
- ARMADILHA: *"Masking policy"* — **ERRADO**, masking ainda mostra a coluna (com valor mascarado). Projection esconde completamente do SELECT

**Cenário 7: "Aplicar MFA para usuários Snowsight mas não para contas de serviço JDBC..."**
- **CORRETO:** **Authentication policy** com `CLIENT_TYPES` definido para aplicar MFA apenas para `SNOWFLAKE_UI`
- ARMADILHA: *"Network policy"* — **ERRADO**, network policies controlam acesso por IP, não métodos de autenticação

**Cenário 8: "Garantir que Time Travel nunca seja definido abaixo de 7 dias em qualquer tabela..."**
- **CORRETO:** Definir **`MIN_DATA_RETENTION_TIME_IN_DAYS = 7`** no nível de conta
- ARMADILHA: *"Definir DATA_RETENTION_TIME_IN_DAYS = 7 em cada schema"* — **ERRADO**, objetos individuais podem sobrescrever configurações do schema; apenas MIN no nível de conta define um piso verdadeiro

**Cenário 9: "Queries de analytics devem agregar pelo menos 10 pacientes antes de mostrar resultados..."**
- **CORRETO:** **Aggregation policy** com tamanho mínimo de grupo de 10
- ARMADILHA: *"Row access policy"* — **ERRADO**, RAP filtra linhas por role; não aplica tamanhos mínimos de grupo

**Cenário 10: "Cliente quer controle total para revogar o acesso do Snowflake aos seus dados..."**
- **CORRETO:** **Tri-Secret Secure** (chave gerenciada pelo cliente envolve a chave do Snowflake) no **Business Critical**
- ARMADILHA: *"Apenas usar a criptografia nativa do Snowflake"* — **ERRADO**, criptografia padrão não dá ao cliente um interruptor de desligamento

**Cenário 11: "5.000 usuários precisam de SSO, com grupos auto-sincronizados do Okta..."**
- **CORRETO:** **Integração de segurança SAML 2.0** para SSO + **SCIM** para provisionamento de usuários/grupos
- ARMADILHA: *"Criar usuários manualmente com senhas"* — **ERRADO**, não escala, sem desprovisionamento automático

**Cenário 12: "Nova coluna PII adicionada — deve ser automaticamente mascarada sem intervenção manual..."**
- **CORRETO:** **Mascaramento baseado em tags** — tagear a coluna como PII, masking policy se aplica automaticamente a todas as colunas com aquela tag
- ARMADILHA: *"Aplicar nova masking policy a cada coluna manualmente"* — **ERRADO**, não escala, fácil de perder colunas

---

## FLASHCARDS -- Domínio 1

**Q1:** Qual role pode criar novas contas em uma Snowflake Organization?
**A1:** Apenas ORGADMIN.

**Q2:** Se um parâmetro de sessão e um parâmetro de conta conflitam, qual vence?
**A2:** Parâmetro de sessão (o mais específico vence).

**Q3:** Qual é a edição mínima para PrivateLink?
**A3:** Business Critical.

**Q4:** Quantas masking policies podem ser aplicadas a uma única coluna?
**A4:** Uma.

**Q5:** Qual é a diferença entre uma role funcional e uma role de acesso?
**A5:** Roles de acesso detêm privilégios de objeto; roles funcionais representam funções de trabalho e herdam de roles de acesso.

**Q6:** O que o Tri-Secret Secure fornece?
**A6:** Chave gerenciada pelo cliente envolvendo a chave do Snowflake — cliente pode revogar acesso aos seus dados.

**Q7:** Database roles podem ser concedidas diretamente a usuários?
**A7:** Não. Devem ser concedidas a roles no nível de conta (ou outras database roles dentro do mesmo banco de dados).

**Q8:** O que `MIN_DATA_RETENTION_TIME_IN_DAYS` faz?
**A8:** Define um piso para retenção de Time Travel que objetos individuais não podem ficar abaixo.

**Q9:** Qual método de autenticação contas de serviço devem usar?
**A9:** Autenticação por par de chaves.

**Q10:** Qual é o propósito de uma projection policy?
**A10:** Impede que uma coluna apareça nos resultados do SELECT enquanto permite seu uso em WHERE/JOIN/GROUP BY.

**Q11:** O que SCIM faz no Snowflake?
**A11:** Automatiza provisionamento/desprovisionamento de usuários e grupos de um IdP externo.

**Q12:** Quando uma network policy no nível de usuário é definida, o que acontece com a política no nível de conta para aquele usuário?
**A12:** A política no nível de usuário substitui completamente (não mescla com) a política no nível de conta.

**Q13:** Qual edição é necessária para row access policies?
**A13:** Enterprise ou superior.

**Q14:** Qual é o período de retenção do ACCESS_HISTORY?
**A14:** 365 dias.

**Q15:** Aggregation policies podem ser combinadas com masking policies na mesma tabela?
**A15:** Sim. Servem propósitos diferentes e podem coexistir.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS -- Domínio 1

**1. Estratégia Multi-Conta**
Imagine que você tem caixas de brinquedos diferentes para salas diferentes. A caixa do quarto tem brinquedos de dormir, a caixa da sala de jogos tem brinquedos de bagunça. Você mantém separados para que glitter não vá parar no seu travesseiro. Isso é multi-conta — caixas separadas para coisas separadas.

**2. Hierarquia de Parâmetros**
Seus pais dizem "hora de dormir às 20h" (regra de conta). Mas para O SEU quarto, é "hora de dormir às 20:30" (regra de objeto). E hoje à noite, já que é seu aniversário, é "hora de dormir às 21h" (regra de sessão). A regra mais específica vence!

**3. Herança de Roles**
Você é o "monitor de biscoitos" na escola. Isso significa que pode distribuir biscoitos. Sua professora é a "chefe da sala" e ela tem TODOS os poderes de monitor, incluindo os seus. Poderes fluem PARA CIMA.

**4. Network Policies**
É como uma lista de convidados em uma festa de aniversário. Só crianças na lista podem entrar. Se sua mãe faz uma lista especial só para você, ela substitui a lista principal — não adiciona a ela.

**5. PrivateLink**
Imagine um túnel secreto da sua casa direto para a casa do seu amigo. Você nunca precisa andar na calçada (internet pública). É mais seguro porque ninguém pode te ver indo e voltando.

**6. Masking Policies**
Seu diário tem uma tinta mágica. Quando VOCÊ lê, vê tudo. Quando seu irmão lê, as partes secretas ficam borradas. Mesma página, pessoas diferentes veem coisas diferentes.

**7. Row Access Policies**
Um buffet onde todo mundo vê pratos diferentes. Crianças veem pizza e nuggets. Adultos veem salada e sushi. Mesma mesa, porções diferentes baseadas em quem você é.

**8. Tri-Secret Secure**
Seu cofre precisa de DUAS chaves para abrir. Você tem uma, o Snowflake tem a outra. Se você tira sua chave, ninguém pode abrir o cofre — nem mesmo o Snowflake.

**9. SCIM**
Quando um novo aluno entra na escola, ele automaticamente ganha um crachá, um cubículo e um lugar no refeitório. Quando sai, tudo é retirado automaticamente. Não é preciso papelada manual!

**10. Aggregation Policies**
Uma regra que diz "você não pode contar uma história sobre menos de 5 pessoas." Isso impede que alguém adivinhe sobre quem é a história.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 'es',
  '# Dominio 1: Estrategia de Cuentas y Seguridad

> **Cobertura del Temario ARA-C01:** Estrategia de Cuentas/BD, Seguridad/Privacidad/Cumplimiento, Principios de Seguridad

---

## 1.1 ESTRATEGIA DE CUENTAS

**Arquitectura de Cuenta Única vs Multi-Cuenta**

- **Cuenta única:** la más simple, todos los entornos (dev/staging/prod) comparten una cuenta
  - Más económica, menos sobrecarga administrativa
  - Riesgo: el radio de impacto es toda la cuenta (un GRANT incorrecto afecta todo)
- **Multi-cuenta:** cuentas separadas por entorno, unidad de negocio o región
  - Mayor aislamiento, políticas de seguridad independientes, facturación separada
  - Requerido para cumplimiento estricto (ej., datos PCI en su propia cuenta)
- **Snowflake Organizations:** contenedor padre que agrupa múltiples cuentas
  - Habilita replicación entre cuentas, grupos de failover y facturación centralizada
  - El rol ORGADMIN administra las cuentas dentro de la organización
  - Creación de cuentas mediante `CREATE ACCOUNT` (solo ORGADMIN)

**Patrones de Segmentación**

- **Por entorno:** cuentas de dev / staging / prod
- **Por región:** cuentas en diferentes regiones de nube para residencia de datos
- **Por unidad de negocio:** finanzas, marketing, ingeniería, cada uno tiene la suya
- **Por cumplimiento:** cuenta con alcance PCI, cuenta con alcance HIPAA

### Por Qué Esto Importa
Una empresa de salud necesita datos HIPAA aislados de los análisis de marketing. Multi-cuenta con replicación a nivel de organización les permite compartir datos no-PHI entre cuentas mientras mantienen los PHI protegidos.

### Mejores Prácticas
- Usar Organizations para administrar centralmente las cuentas y la facturación
- Replicar objetos de seguridad (network policies, RBAC) mediante replicación de cuentas
- Mantener las cuentas de producción en edición Business Critical o superior para cumplimiento

**Trampa del examen:** SI VES "usar una sola cuenta con bases de datos separadas para aislamiento PCI" → **INCORRECTO** porque PCI requiere aislamiento a nivel de cuenta, no solo a nivel de base de datos.

**Trampa del examen:** SI VES "ACCOUNTADMIN puede crear nuevas cuentas" → **INCORRECTO** porque solo ORGADMIN puede crear cuentas dentro de una Organization.

**Trampa del examen:** SI VES "Organizations requiere edición Enterprise" → **INCORRECTO** porque Organizations está disponible en todas las ediciones.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo compartir datos entre cuentas sin Organizations?**
R: Sí, mediante Secure Data Sharing (listings), pero Organizations agrega replicación, failover y administración centralizada.

**P: ¿Cada cuenta en una organización recibe facturación separada?**
R: Por defecto la facturación se consolida a nivel de organización, pero puedes ver el uso por cuenta.


### Ejemplos de Preguntas de Escenario — Account Strategy

**Escenario:** A global insurance company operates in the EU, US, and APAC. EU regulations require that EU customer data never leaves EU soil. The US team needs access to aggregated (non-PII) metrics from all regions for global dashboards. How should the architect design the Snowflake account topology?
**Respuesta:** Deploy separate Snowflake accounts per region (EU, US, APAC) within a single Snowflake Organization. Each regional account stores its own customer data in a cloud region that satisfies data residency requirements. Use database replication to replicate non-PII aggregated datasets from EU and APAC accounts to the US account for global dashboards. ORGADMIN manages account creation and centralized billing. This ensures EU data never leaves the EU account while enabling cross-region analytics on safe aggregates.

**Escenario:** A fintech startup is growing from 10 to 500 employees and currently uses a single Snowflake account for dev, staging, and production. An intern accidentally ran a `GRANT ALL ON DATABASE prod_db TO ROLE PUBLIC` in production. What architectural change prevents this class of incident?
**Respuesta:** Migrate to a multi-account architecture with separate accounts for dev, staging, and production within a Snowflake Organization. This provides account-level blast radius isolation — a misconfigured GRANT in dev cannot affect production. Additionally, use managed access schemas in the production account so that only the schema owner (or MANAGE GRANTS holder) can issue grants, preventing ad-hoc privilege escalation by individual object owners. Replicate security objects across accounts using account replication for consistent RBAC.

---

---

## 1.2 JERARQUÍA DE PARÁMETROS

**Tres Niveles (de arriba hacia abajo):**

1. **Cuenta** — establecido por ACCOUNTADMIN, aplica globalmente
2. **Objeto** — establecido en warehouse, base de datos, esquema, tabla, usuario
3. **Sesión** — establecido por el usuario para su sesión actual (`ALTER SESSION`)

**Regla de Precedencia:** El más específico gana. Sesión > Objeto > Cuenta.

**Parámetros Clave que Debes Conocer:**

| Parámetro | Nivel Típico | Notas |
|---|---|---|
| `STATEMENT_TIMEOUT_IN_SECONDS` | Cuenta / Sesión | Cancela consultas largas |
| `DATA_RETENTION_TIME_IN_DAYS` | Cuenta / Objeto | Ventana de Time Travel (0-90) |
| `MIN_DATA_RETENTION_TIME_IN_DAYS` | Solo cuenta | Piso que los objetos no pueden reducir |
| `NETWORK_POLICY` | Cuenta / Usuario | Nivel de usuario sobreescribe nivel de cuenta |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` | Cuenta | Endurecimiento de seguridad |

### Por Qué Esto Importa
Un DBA establece el timeout a nivel de cuenta en 1 hora. Un científico de datos establece el timeout de sesión en 4 horas para un trabajo grande de ML. El nivel de sesión gana para ese usuario.

### Mejores Prácticas
- Establecer `MIN_DATA_RETENTION_TIME_IN_DAYS` a nivel de cuenta para evitar que los usuarios configuren Time Travel en 0
- Usar `STATEMENT_TIMEOUT_IN_SECONDS` en warehouses para prevenir consultas descontroladas
- Documentar qué parámetros están configurados en qué nivel

**Trampa del examen:** SI VES "el parámetro de cuenta siempre sobreescribe el parámetro de sesión" → **INCORRECTO** porque la sesión es más específica y gana.

**Trampa del examen:** SI VES "MIN_DATA_RETENTION_TIME_IN_DAYS se puede establecer en un esquema" → **INCORRECTO** porque es solo a nivel de cuenta.

**Trampa del examen:** SI VES "una network policy a nivel de usuario es aditiva a la de nivel de cuenta" → **INCORRECTO** porque la network policy a nivel de usuario **reemplaza** la política a nivel de cuenta para ese usuario.

### Preguntas Frecuentes (FAQ)
**P: Si establezco DATA_RETENTION_TIME_IN_DAYS = 1 en una tabla pero el MIN de la cuenta es 7, ¿cuál gana?**
R: El MIN gana — la tabla obtiene 7 días. MIN establece un piso.

**P: ¿Puede un usuario que no sea ACCOUNTADMIN establecer parámetros de cuenta?**
R: No. Solo ACCOUNTADMIN (o roles con el privilegio otorgado) puede establecer parámetros a nivel de cuenta.


### Ejemplos de Preguntas de Escenario — Parameter Hierarchy

**Escenario:** A data engineering team runs large Spark-based ETL jobs that can take up to 6 hours. The account-level `STATEMENT_TIMEOUT_IN_SECONDS` is set to 3600 (1 hour) to protect against runaway queries. The ETL jobs keep getting killed. The team asks the architect to raise the account timeout to 24 hours. What is the correct approach?
**Respuesta:** Do not raise the account-level timeout — that would expose all users to potential 24-hour runaway queries. Instead, set `STATEMENT_TIMEOUT_IN_SECONDS` at the object level on the dedicated ETL warehouse to 21600 (6 hours). Session-level and object-level parameters override the account default for that specific context. This way, BI users on other warehouses still get the 1-hour safety net while ETL has the headroom it needs.

**Escenario:** A compliance officer discovers that a developer set `DATA_RETENTION_TIME_IN_DAYS = 0` on several staging tables, meaning accidental deletes cannot be recovered via Time Travel. How should the architect prevent this from happening again across the entire account?
**Respuesta:** Set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level (e.g., to 1 or 7 days). This parameter is account-level only and establishes a floor that no individual database, schema, or table can go below. Even if a developer sets `DATA_RETENTION_TIME_IN_DAYS = 0` on a table, the MIN floor overrides it, ensuring Time Travel is always available for at least the minimum period.

---

---

## 1.3 CONTROL DE ACCESO BASADO EN ROLES

**Conceptos Fundamentales**

- Snowflake usa **Control de Acceso Basado en Roles (RBAC)** — los privilegios se otorgan a roles, los roles se otorgan a usuarios
- Los roles forman una jerarquía: los privilegios de roles hijos fluyen HACIA ARRIBA a los roles padres
- **Roles definidos por el sistema:** ORGADMIN > ACCOUNTADMIN > SECURITYADMIN > SYSADMIN > USERADMIN > PUBLIC

**Herencia de Privilegios**

- Si el Rol A se otorga al Rol B, entonces el Rol B hereda TODOS los privilegios del Rol A
- ACCOUNTADMIN debería heredar tanto de SECURITYADMIN como de SYSADMIN
- Nunca usar ACCOUNTADMIN para trabajo diario

**Database Roles**

- Limitados a una sola base de datos (portables con la base de datos durante replicación/clonación)
- Se otorgan a roles a nivel de cuenta u otros database roles
- Ideales para compartir: los consumidores obtienen database roles, no roles de cuenta

**Patrón de Roles Funcionales vs Roles de Acceso**

- **Roles de acceso:** contienen privilegios sobre objetos (ej., `ANALYST_READ` tiene SELECT en tablas)
- **Roles funcionales:** representan funciones laborales, heredan de roles de acceso (ej., `DATA_ANALYST` hereda `ANALYST_READ` + `DASHBOARD_WRITE`)
- Este modelo de dos capas simplifica la administración a escala

**Roles Secundarios**

- `USE SECONDARY ROLES ALL` — el usuario obtiene la unión de privilegios de todos los roles otorgados
- Evita el cambio constante de roles
- El rol secundario predeterminado se puede establecer en el objeto de usuario

### Por Qué Esto Importa
Un equipo de analítica de 500 personas necesita acceso granular. Los roles funcionales (Data Analyst, Data Engineer) heredan de roles de acceso detallados. ¿Nueva contratación? Otorga un rol funcional. Listo.

### Mejores Prácticas
- Nunca otorgar privilegios directamente a usuarios — siempre usar roles
- SYSADMIN debería ser dueño de todas las bases de datos/warehouses (o roles personalizados otorgados a SYSADMIN)
- Usar database roles para objetos compartidos mediante Secure Sharing
- Separar SECURITYADMIN (administra grants) de SYSADMIN (administra objetos)

**Trampa del examen:** SI VES "ACCOUNTADMIN debería ser el rol predeterminado para administradores" → **INCORRECTO** porque ACCOUNTADMIN es solo para emergencias; el trabajo diario debe usar roles inferiores.

**Trampa del examen:** SI VES "los database roles se pueden otorgar directamente a usuarios" → **INCORRECTO** porque los database roles deben otorgarse primero a roles a nivel de cuenta (u otros database roles).

**Trampa del examen:** SI VES "la herencia de privilegios fluye hacia abajo" → **INCORRECTO** porque fluye HACIA ARRIBA en la jerarquía de roles.

### Preguntas Frecuentes (FAQ)
**P: ¿Cuál es la diferencia entre SECURITYADMIN y USERADMIN?**
R: USERADMIN administra usuarios y roles. SECURITYADMIN hereda de USERADMIN y también puede administrar grants (GRANT/REVOKE).

**P: ¿Puedo usar roles secundarios con Secure Sharing?**
R: No. Los shares usan el database role designado del share; los roles secundarios no aplican en el contexto de sharing.


### Ejemplos de Preguntas de Escenario — Role-Based Access Control

**Escenario:** A 2,000-person enterprise has 15 departments, each with analysts, engineers, and managers. New hires join weekly. Currently, each new hire requires 10+ individual GRANT statements. The security team wants a scalable model. What RBAC pattern should the architect implement?
**Respuesta:** Implement the functional-role / access-role pattern. Create fine-grained access roles that hold object-level privileges (e.g., `SALES_READ`, `SALES_WRITE`, `MARKETING_READ`). Then create functional roles representing job functions (e.g., `SALES_ANALYST`, `SALES_ENGINEER`, `MARKETING_MANAGER`) that inherit from the appropriate access roles. When a new hire joins, grant them a single functional role. All access roles should be granted to SYSADMIN for hierarchy completeness. This reduces onboarding to one GRANT per new user and simplifies auditing.

**Escenario:** A data marketplace team shares curated datasets to external consumers via Secure Data Sharing. They need consumers to have SELECT on specific views without exposing account-level role structures. What role type should the architect use?
**Respuesta:** Use database roles. Database roles are scoped to a single database and are portable with the database during sharing. Grant SELECT on the secure views to database roles within the shared database, then assign those database roles to the share. Consumers receive the database roles without visibility into the provider''s account-level role hierarchy. This also ensures that if the database is replicated or cloned, the database roles travel with it.

**Escenario:** Multiple analysts complain about constantly switching roles to access tables in different databases. Each analyst has 4-5 roles granted. How should the architect solve this without restructuring the entire RBAC model?
**Respuesta:** Enable secondary roles by having analysts run `USE SECONDARY ROLES ALL` at session start (or set a default secondary role on the user object). This gives users the union of privileges from all their granted roles simultaneously, eliminating constant `USE ROLE` switching. This is a session-level change and does not affect the underlying RBAC model or security posture.

---

---

## 1.4 SEGURIDAD DE RED

**Network Policies**

- Listas de IPs permitidas/bloqueadas aplicadas a nivel de cuenta o usuario
- Usan `ALLOWED_IP_LIST` y `BLOCKED_IP_LIST`
- La política a nivel de usuario **reemplaza** (no complementa) la política a nivel de cuenta

**Network Rules (más nuevas, más flexibles)**

- Pueden referenciar rangos de IP, endpoints de VPC, nombres de host
- Se adjuntan a network policies para reglas modulares y reutilizables
- Soportan direcciones `INGRESS` (entrante) y `EGRESS` (saliente)

**AWS PrivateLink / Azure Private Link / GCP Private Service Connect**

- Conectividad privada desde tu VPC a Snowflake — sin internet público
- Requiere edición Business Critical o superior
- Obtienes una URL de endpoint privado (ej., `account.privatelink.snowflakecomputing.com`)
- NO reemplaza las network policies — usa ambas juntas

**External Access Integrations**

- Permiten que UDFs/procedimientos llamen APIs externas (ej., endpoints REST)
- Requiere crear una External Access Integration + Network Rule (egress)
- Los secretos se almacenan en objetos secret de Snowflake, no en el código

### Por Qué Esto Importa
Un banco necesita que todo el tráfico de Snowflake permanezca en su red privada. PrivateLink + network policies + bloquear acceso público = cero exposición a internet público.

### Mejores Prácticas
- Siempre establecer una network policy a nivel de cuenta (aunque sea amplia) como red de seguridad
- Usar PrivateLink para cargas de trabajo de producción en industrias reguladas
- Probar las network policies en entornos no productivos antes de aplicarlas a nivel de cuenta
- Usar network rules en lugar de listas de IP directas para mejor mantenibilidad

**Trampa del examen:** SI VES "PrivateLink está disponible en la edición Standard" → **INCORRECTO** porque requiere Business Critical o superior.

**Trampa del examen:** SI VES "las network policies soportan bloqueo por FQDN/hostname" → **INCORRECTO** para network policies solas; necesitas network rules para controles basados en hostname.

**Trampa del examen:** SI VES "PrivateLink elimina la necesidad de network policies" → **INCORRECTO** porque sirven para propósitos diferentes y deben usarse juntas.

### Preguntas Frecuentes (FAQ)
**P: Si bloqueo todas las IPs públicas, ¿puedo seguir usando Snowsight?**
R: Solo mediante la URL de Snowsight habilitada para PrivateLink o si agregas las IPs de Snowsight de Snowflake a la lista permitida.

**P: ¿Puedo tener network policies tanto a nivel de cuenta como de usuario?**
R: Sí, pero la política a nivel de usuario reemplaza completamente (no se fusiona con) la política de cuenta para ese usuario.


### Ejemplos de Preguntas de Escenario — Network Security

**Escenario:** A large bank is migrating to Snowflake and requires zero public internet exposure. Their applications run in AWS VPCs across three regions. Some teams also need Snowsight access from corporate offices with static IPs. How should the architect design the network architecture?
**Respuesta:** Enable AWS PrivateLink to establish private connectivity from each VPC to Snowflake — traffic stays on the AWS backbone and never traverses the public internet. Create a network policy at the account level that blocks all public IPs by default. For Snowsight access from corporate offices, add the corporate static IPs to the `ALLOWED_IP_LIST` in the account-level network policy (or use a user-level network policy for specific admin users who need Snowsight). PrivateLink requires Business Critical edition or higher. Use network rules for modular, reusable IP and VPC endpoint definitions.

**Escenario:** A data engineering team needs their Python UDFs to call an external REST API for geocoding. The security team does not allow arbitrary outbound internet access from Snowflake. What is the correct architecture?
**Respuesta:** Create a network rule with `MODE = EGRESS` specifying the geocoding API''s hostname. Create an external access integration referencing that network rule and a Snowflake secret object containing the API key. Grant the external access integration to the UDF. This allows controlled, auditable outbound access to only the specified endpoint — no blanket internet access. The API credentials are stored in Snowflake''s secret management, never in code.

---

---

## 1.5 AUTENTICACIÓN

**SSO / SAML 2.0**

- Snowflake actúa como el Proveedor de Servicios (SP)
- Tu IdP (Okta, Azure AD, etc.) autentica a los usuarios
- Se configura mediante una security integration SAML2
- Soporta SCIM para aprovisionamiento automatizado de usuarios/grupos

**OAuth**

- External OAuth: token de tu IdP (Okta, Azure AD, PingFederate)
- Snowflake OAuth: Snowflake emite el token (usado por aplicaciones asociadas como Tableau)
- Ambos usan security integrations

**MFA (Autenticación Multi-Factor)**

- MFA Duo integrado, sin costo adicional
- Se puede aplicar mediante authentication policies (`AUTHENTICATION_POLICY`)
- `CLIENT_TYPES` en la política de autenticación controla qué clientes deben usar MFA

**Autenticación por Par de Claves**

- RSA 2048-bit como mínimo
- La clave pública se almacena en el objeto de usuario, la clave privada la tiene el cliente
- Soporta rotación de claves (dos claves activas: `RSA_PUBLIC_KEY` y `RSA_PUBLIC_KEY_2`)
- Requerido para cuentas de servicio / automatización (Snowpipe, conectores)

**Authentication Policies**

- Controlan los métodos de autenticación permitidos por cuenta o por usuario
- Pueden restringir a `CLIENT_TYPES` específicos (ej., SNOWFLAKE_UI, DRIVERS)
- Pueden aplicar MFA para tipos de cliente específicos

**Autenticación Federada**

- Combina SSO + MFA para la postura más fuerte
- Los usuarios se autentican vía IdP, luego el desafío MFA

### Por Qué Esto Importa
Una empresa con 5,000 usuarios necesita SSO vía Okta, MFA obligatorio para usuarios de la interfaz, y par de claves para pipelines CI/CD. Las authentication policies permiten aplicar reglas diferentes por caso de uso.

### Mejores Prácticas
- Aplicar MFA para todos los usuarios humanos (como mínimo ACCOUNTADMIN)
- Usar autenticación por par de claves para todas las cuentas de servicio / automatización
- Usar SCIM para sincronizar usuarios/grupos desde tu IdP
- Establecer authentication policies para bloquear el acceso solo con contraseña

**Trampa del examen:** SI VES "Snowflake OAuth y External OAuth son lo mismo" → **INCORRECTO** porque Snowflake OAuth es emitido por Snowflake; External OAuth proviene de tu IdP.

**Trampa del examen:** SI VES "la autenticación por par de claves requiere edición Enterprise" → **INCORRECTO** porque está disponible en todas las ediciones.

**Trampa del examen:** SI VES "MFA se puede aplicar mediante una network policy" → **INCORRECTO** porque la aplicación de MFA usa authentication policies, no network policies.

**Trampa del examen:** SI VES "SCIM crea roles automáticamente" → **INCORRECTO** porque SCIM aprovisiona usuarios y grupos pero NO crea roles de Snowflake automáticamente.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo usar tanto SSO como inicio de sesión con contraseña?**
R: Sí, a menos que establezcas una authentication policy que bloquee la autenticación por contraseña. Por defecto ambos funcionan.

**P: ¿Qué pasa si un usuario pierde su par de claves?**
R: El administrador puede establecer una nueva clave pública en el objeto de usuario. El segundo espacio de clave permite la rotación sin tiempo de inactividad.


### Ejemplos de Preguntas de Escenario — Authentication

**Escenario:** An enterprise has 5,000 employees using Okta for SSO, plus 200 CI/CD service accounts running nightly ETL pipelines. The CISO mandates MFA for all human users accessing Snowsight but cannot require MFA for automated pipelines (which have no human to approve a push notification). How should the architect configure authentication?
**Respuesta:** Configure a SAML 2.0 security integration with Okta for SSO for all human users. Create an authentication policy that enforces MFA with `CLIENT_TYPES` set to `SNOWFLAKE_UI` (Snowsight) — this requires MFA for interactive logins but not for programmatic drivers. For the 200 CI/CD service accounts, use key-pair authentication (RSA 2048-bit minimum) with the public key stored on each service user object. Set a separate authentication policy on service accounts that allows only key-pair auth and blocks password-based access entirely. Use SCIM to auto-provision and deprovision human users from Okta.

**Escenario:** A company rotates credentials quarterly. They have 50 service accounts using key-pair authentication. How can the architect enable zero-downtime key rotation?
**Respuesta:** Snowflake supports two concurrent public keys per user object: `RSA_PUBLIC_KEY` and `RSA_PUBLIC_KEY_2`. During rotation, generate a new key pair and set it as `RSA_PUBLIC_KEY_2` on the user object. Update the service account''s client configuration to use the new private key. Once confirmed working, remove the old key from `RSA_PUBLIC_KEY`. This overlapping window allows zero-downtime rotation without any service interruption.

---

---

## 1.6 GOBERNANZA DE DATOS

**Masking Policies (Dynamic Data Masking)**

- Seguridad a nivel de columna: retorna un valor enmascarado según el rol que consulta
- La política es una función SQL: `CREATE MASKING POLICY ... RETURNS <type> -> CASE WHEN ...`
- Se aplica a columnas mediante `ALTER TABLE ... ALTER COLUMN ... SET MASKING POLICY`
- Una masking policy por columna
- Soporta enmascaramiento condicional (basado en rol, otra columna, etc.)

**Row Access Policies (RAP)**

- Seguridad a nivel de fila: filtra filas según el contexto de consulta
- Retorna `TRUE` (fila visible) o `FALSE` (fila oculta)
- Una RAP por tabla/vista
- Puede referenciar tablas de mapeo para filtrado de rol-a-región

**Aggregation Policies**

- Previenen consultas que retornan resultados por debajo de un tamaño mínimo de grupo
- Protegen contra la re-identificación en analítica
- Privacidad a nivel de entidad (ej., debe agregar al menos 5 pacientes)

**Projection Policies**

- Previenen `SELECT column` directamente — la columna solo puede usarse en WHERE, JOIN, GROUP BY
- Caso de uso: permitir filtrar por SSN pero nunca mostrarlo

**Object Tagging**

- Metadatos clave-valor en cualquier objeto (tabla, columna, warehouse, etc.)
- Linaje de tags: los tags se propagan a través de vistas
- Base para masking policies basadas en tags (aplicar enmascaramiento a todas las columnas con tag X)
- Tags del sistema desde clasificación (ej., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = EMAIL`)

**Linaje de Datos (ACCESS_HISTORY)**

- `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY` — rastrea lecturas/escrituras a nivel de columna
- Muestra qué columnas fueron accedidas, por quién, y cómo fluyeron los datos
- Retención de 365 días
- Requiere edición Enterprise o superior

### Por Qué Esto Importa
Una empresa de retail etiqueta todas las columnas PII, luego aplica una sola masking policy a cada columna con el tag PII. Cuando se agrega y etiqueta una nueva columna PII, el enmascaramiento es automático.

### Mejores Prácticas
- Usar enmascaramiento basado en tags para gobernanza escalable
- Combinar RAP + masking para defensa en profundidad
- Usar aggregation policies para datasets analíticos expuestos a audiencias amplias
- Ejecutar clasificación de datos para auto-detectar datos sensibles

**Trampa del examen:** SI VES "puedes aplicar dos masking policies a la misma columna" → **INCORRECTO** porque solo se permite una masking policy por columna.

**Trampa del examen:** SI VES "las row access policies se aplican a columnas" → **INCORRECTO** porque las RAP se aplican a tablas/vistas, no a columnas individuales.

**Trampa del examen:** SI VES "los object tags requieren edición Business Critical" → **INCORRECTO** porque el etiquetado está disponible en Enterprise y superior.

**Trampa del examen:** SI VES "las aggregation policies filtran filas" → **INCORRECTO** porque bloquean consultas que producen grupos por debajo del tamaño mínimo, no filtran filas individuales.

### Preguntas Frecuentes (FAQ)
**P: ¿Las masking policies pueden referenciar otras tablas?**
R: Sí. Puedes consultar una tabla de mapeo dentro del cuerpo de la masking policy (subconsulta).

**P: ¿Las row access policies funcionan en vistas materializadas?**
R: No. Las RAP no están soportadas en vistas materializadas.

**P: ¿Cuál es la diferencia entre projection policy y masking policy?**
R: Masking reemplaza el valor (ej., `***`). Projection evita que la columna aparezca en los resultados por completo pero permite su uso en predicados.


### Ejemplos de Preguntas de Escenario — Data Governance

**Escenario:** A healthcare analytics platform has 500+ tables, and new columns containing PHI (emails, phone numbers, SSNs) are added regularly as new data sources are onboarded. The governance team cannot manually review every new column. How should the architect automate masking at scale?
**Respuesta:** Implement tag-based masking. Run Snowflake''s automatic data classification to detect sensitive columns and apply system tags (e.g., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = ''EMAIL''`). Create masking policies for each sensitivity category (EMAIL, PHONE, SSN) and bind them to the corresponding tags using tag-based masking policy assignments. When new columns are added and classified, the masking policy auto-applies based on the tag — no manual intervention needed. Combine with row access policies for defense-in-depth.

**Escenario:** A pharmaceutical company needs to share a clinical trial dataset with external researchers. Researchers must be able to filter by patient demographics (age, gender, zip code) for cohort selection, but must never see individual patient records — results must aggregate at least 20 patients per group to prevent re-identification. How should the architect configure governance?
**Respuesta:** Apply an aggregation policy on the shared dataset with a minimum group size of 20 — any query that produces groups with fewer than 20 patients is blocked. Additionally, apply projection policies on direct patient identifiers (patient_id, SSN) so researchers can use them in WHERE/JOIN/GROUP BY for cohort selection but cannot SELECT them in results. Share the data via secure views with these policies applied. This provides layered privacy: aggregation prevents small-group re-identification, and projection prevents direct identifier exposure.

**Escenario:** An internal audit requires understanding which roles accessed which PII columns over the past year, including data flows through views and downstream tables. What Snowflake feature supports this?
**Respuesta:** Query `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY`, which provides column-level data lineage tracking with 365-day retention. It records which columns were read (`base_objects_accessed`) and written (`objects_modified`), by which role, including data flows through views and transformations. This supports audit requirements without requiring any custom logging infrastructure. Requires Enterprise edition or higher.

---

---

## 1.7 CUMPLIMIENTO

**Características de Edición para Cumplimiento**

| Requisito | Edición Mínima |
|---|---|
| HIPAA / HITRUST | Business Critical |
| PCI DSS | Business Critical |
| SOC 1/2 | Todas las ediciones |
| FedRAMP Moderate | Virtual Private Snowflake (VPS) en AWS GovCloud |
| ITAR | VPS en AWS GovCloud |
| Soporte de PHI | Business Critical con BAA |

**Tri-Secret Secure**

- La clave administrada por el cliente (CMK) envuelve la clave de Snowflake, que envuelve la clave de datos
- Requiere edición Business Critical
- Si el cliente revoca la CMK, Snowflake no puede descifrar los datos — control total del cliente
- Soportado en AWS (KMS), Azure (Key Vault), GCP (Cloud KMS)

**Storage Integrations**

- Acceso seguro y gobernado a almacenamiento en la nube externo (S3, GCS, Azure Blob)
- Usa roles IAM / service principals — sin credenciales en texto plano en SQL
- Requerido para external stages, external tables, acceso a data lake
- El parámetro `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` obliga su uso

### Por Qué Esto Importa
Una empresa de salud que almacena PHI necesita Business Critical + BAA + Tri-Secret Secure + PrivateLink. Si falta cualquiera, se rompe el cumplimiento HIPAA.

### Mejores Prácticas
- Habilitar Tri-Secret Secure para datos sobre los que necesitas control total
- Requerir storage integrations a nivel de cuenta para prevenir fuga de credenciales
- Documentar tu arquitectura de cumplimiento para los auditores
- Usar VPS solo cuando se requiera FedRAMP / ITAR (costo significativo)

**Trampa del examen:** SI VES "Tri-Secret Secure está disponible en la edición Enterprise" → **INCORRECTO** porque requiere Business Critical.

**Trampa del examen:** SI VES "el cumplimiento SOC 2 requiere Business Critical" → **INCORRECTO** porque los reportes SOC 2 están disponibles para todas las ediciones.

**Trampa del examen:** SI VES "Tri-Secret Secure significa que Snowflake no puede acceder a tus datos en absoluto" → **INCORRECTO** porque Snowflake aún administra la clave intermedia; el cliente controla la clave externa.

### Preguntas Frecuentes (FAQ)
**P: ¿Cuál es la diferencia entre Business Critical y VPS?**
R: Business Critical agrega cifrado, cumplimiento, PrivateLink. VPS agrega un despliegue de Snowflake dedicado y aislado (almacén de metadatos separado, cómputo separado).

**P: ¿Habilitar Tri-Secret Secure afecta el rendimiento?**
R: Insignificante. El envolvimiento de claves agrega una sobrecarga mínima.


### Ejemplos de Preguntas de Escenario — Compliance

**Escenario:** A US defense contractor needs to process ITAR-controlled data in Snowflake. They also have non-ITAR commercial workloads that don''t require the same isolation. What Snowflake deployment model should the architect recommend?
**Respuesta:** Deploy a Virtual Private Snowflake (VPS) instance on AWS GovCloud specifically for the ITAR-controlled workloads. VPS provides a fully dedicated, isolated Snowflake deployment with a separate metadata store and compute infrastructure — the strongest isolation level Snowflake offers. For non-ITAR commercial workloads, use a standard Business Critical account in a commercial region. Both accounts can be managed under the same Snowflake Organization for centralized billing, but data and compute are completely separated. Never mix ITAR data with commercial workloads in the same account.

**Escenario:** A healthcare company stores PHI in Snowflake and must comply with HIPAA. Their CISO requires the ability to immediately revoke Snowflake''s access to all data in case of a security incident. What combination of features should the architect implement?
**Respuesta:** Deploy on Business Critical edition (minimum for HIPAA/PHI support) and sign a Business Associate Agreement (BAA) with Snowflake. Enable Tri-Secret Secure, which adds a customer-managed key (CMK) via AWS KMS, Azure Key Vault, or GCP Cloud KMS that wraps Snowflake''s encryption key. If the CISO needs to revoke access, they revoke the CMK — Snowflake immediately loses the ability to decrypt any data. Complement with PrivateLink for private connectivity, network policies to block all public access, and `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` to prevent credential leakage in stages.

---

---

## PARES CONFUSOS — Cuentas y Seguridad

| Preguntan sobre... | La respuesta es... | NO... |
|---|---|---|
| ¿Quién **crea usuarios/roles**? | **USERADMIN** | NO SECURITYADMIN (SECURITYADMIN *hereda* de USERADMIN pero su función propia es administrar grants) |
| ¿Quién **administra grants** (GRANT/REVOKE)? | **SECURITYADMIN** | NO USERADMIN (USERADMIN solo crea usuarios/roles) |
| ¿Quién **crea cuentas** en una organización? | **ORGADMIN** | NO ACCOUNTADMIN (ACCOUNTADMIN es por cuenta, no a nivel de organización) |
| **Roles funcionales** vs **roles de acceso** | **Funcional** = función de negocio (Data Analyst), **Acceso** = privilegios sobre objetos (READ_SALES) | No mezclar — los roles funcionales *heredan de* los roles de acceso |
| **Database roles** vs **roles de cuenta** | **Database roles** = limitados a una BD, portables con replicación/clonación | **Roles de cuenta** = a nivel de toda la cuenta, NO portables con la BD |
| **Network policy** vs **network rule** | **Policy** = lista de IPs permitidas/bloqueadas aplicada a cuenta/usuario | **Rule** = más granular (host, puerto, endpoint VPC), adjunta a policies |
| **Column masking** vs **row access policy** | **Masking** = oculta/reemplaza *valores* de columna | **RAP** = oculta *filas* completas — se aplica a tabla, no a columna |
| **Aggregation policy** vs **projection policy** | **Aggregation** = bloquea consultas por debajo del tamaño mínimo de grupo | **Projection** = evita que la columna aparezca en resultados SELECT |
| **External tokenization** vs **dynamic masking** | **External** = servicio de terceros (Protegrity) reemplaza el valor | **Dynamic masking** = integrado en Snowflake, basado en roles al momento de consulta |
| **PrivateLink** vs **VPN** | **PrivateLink** = conexión directa por backbone de nube, sin internet | **VPN** = túnel cifrado *sobre* internet |
| **Authentication policy** vs **security integration** | **Auth policy** = reglas de *cómo* los usuarios pueden iniciar sesión (MFA, tipos de cliente) | **Security integration** = *configuración* de SSO/OAuth con un IdP externo |
| Network policy a nivel de usuario + nivel de cuenta | A nivel de usuario **reemplaza** la de nivel de cuenta para ese usuario | NO es aditiva — la política de cuenta se *ignora* para ese usuario |
| **Snowflake OAuth** vs **External OAuth** | **Snowflake OAuth** = Snowflake emite el token (aplicaciones asociadas) | **External OAuth** = tu IdP emite el token |
| **SCIM** aprovisiona... | **Usuarios y grupos** automáticamente desde el IdP | NO roles — SCIM NO crea roles de Snowflake |
| Nivel de **MIN_DATA_RETENTION** | **Solo a nivel de cuenta** (establece un piso) | NO se puede establecer en esquema o tabla |

---

## ÁRBOLES DE DECISIÓN POR ESCENARIO — Cuentas y Seguridad

**Escenario 1: "Una empresa necesita datos completamente aislados para cumplimiento PCI..."**
- **CORRECTO:** **Cuentas** de Snowflake separadas (datos PCI en su propia cuenta, edición Business Critical)
- TRAMPA: *"Usar diferentes bases de datos en la misma cuenta"* — **INCORRECTO**, misma cuenta = metadatos compartidos, ACCOUNTADMIN compartido, no es aislamiento real

**Escenario 2: "Un analista debería ver SSNs enmascarados pero un gerente ve los reales..."**
- **CORRECTO:** **Dynamic data masking policy** con lógica CASE basada en roles
- TRAMPA: *"Crear dos vistas separadas"* — **INCORRECTO**, no es escalable, difícil de mantener, evade la gobernanza

**Escenario 3: "Bloquear todo el acceso por internet público a Snowflake..."**
- **CORRECTO:** **PrivateLink** + **network policy** bloqueando todas las IPs públicas
- TRAMPA: *"Solo usar una VPN"* — **INCORRECTO**, la VPN aún atraviesa internet público; PrivateLink se mantiene en el backbone de nube

**Escenario 4: "Una cuenta de servicio necesita conectarse a Snowflake desde un pipeline CI/CD..."**
- **CORRECTO:** **Autenticación por par de claves** (RSA 2048-bit)
- TRAMPA: *"Almacenar usuario/contraseña en variables de entorno"* — **INCORRECTO**, las contraseñas son menos seguras y no permiten aplicar MFA

**Escenario 5: "Prevenir que los dueños de tablas otorguen SELECT a roles no autorizados..."**
- **CORRECTO:** **Managed access schema** — solo el dueño del esquema/MANAGE GRANTS puede otorgar
- TRAMPA: *"Usar row access policies"* — **INCORRECTO**, las RAP filtran filas pero no previenen la escalación de grants

**Escenario 6: "Permitir filtrar por SSN en la cláusula WHERE pero nunca mostrar la columna..."**
- **CORRECTO:** **Projection policy** en la columna SSN
- TRAMPA: *"Masking policy"* — **INCORRECTO**, masking aún muestra la columna (con valor enmascarado). Projection la oculta completamente del SELECT

**Escenario 7: "Aplicar MFA para usuarios de Snowsight pero no para cuentas de servicio JDBC..."**
- **CORRECTO:** **Authentication policy** con `CLIENT_TYPES` configurado para aplicar MFA solo para `SNOWFLAKE_UI`
- TRAMPA: *"Network policy"* — **INCORRECTO**, las network policies controlan acceso por IP, no métodos de autenticación

**Escenario 8: "Asegurar que Time Travel nunca pueda establecerse por debajo de 7 días en ninguna tabla..."**
- **CORRECTO:** Establecer **`MIN_DATA_RETENTION_TIME_IN_DAYS = 7`** a nivel de cuenta
- TRAMPA: *"Establecer DATA_RETENTION_TIME_IN_DAYS = 7 en cada esquema"* — **INCORRECTO**, los objetos individuales pueden sobreescribir la configuración del esquema; solo MIN a nivel de cuenta establece un piso verdadero

**Escenario 9: "Las consultas analíticas deben agregar al menos 10 pacientes antes de mostrar resultados..."**
- **CORRECTO:** **Aggregation policy** con tamaño mínimo de grupo de 10
- TRAMPA: *"Row access policy"* — **INCORRECTO**, las RAP filtran filas por rol; no aplican tamaños mínimos de grupo

**Escenario 10: "El cliente quiere control total para revocar el acceso de Snowflake a sus datos..."**
- **CORRECTO:** **Tri-Secret Secure** (la clave del cliente envuelve la clave de Snowflake) en **Business Critical**
- TRAMPA: *"Solo usar el cifrado integrado de Snowflake"* — **INCORRECTO**, el cifrado predeterminado no le da al cliente un interruptor de corte

**Escenario 11: "5,000 usuarios necesitan SSO, con grupos auto-sincronizados desde Okta..."**
- **CORRECTO:** **Security integration SAML 2.0** para SSO + **SCIM** para aprovisionamiento de usuarios/grupos
- TRAMPA: *"Crear usuarios manualmente con contraseñas"* — **INCORRECTO**, no es escalable, sin desaprovisionamiento automático

**Escenario 12: "Nueva columna PII agregada — debe ser enmascarada automáticamente sin intervención manual..."**
- **CORRECTO:** **Enmascaramiento basado en tags** — etiquetar la columna como PII, la masking policy se auto-aplica a todas las columnas con ese tag
- TRAMPA: *"Aplicar una nueva masking policy a cada columna manualmente"* — **INCORRECTO**, no es escalable, fácil de omitir columnas

---

## TARJETAS DE REPASO -- Dominio 1

**P1:** ¿Qué rol puede crear nuevas cuentas en una Snowflake Organization?
**R1:** Solo ORGADMIN.

**P2:** Si un parámetro de sesión y un parámetro de cuenta entran en conflicto, ¿cuál gana?
**R2:** El parámetro de sesión (el más específico gana).

**P3:** ¿Cuál es la edición mínima para PrivateLink?
**R3:** Business Critical.

**P4:** ¿Cuántas masking policies se pueden aplicar a una sola columna?
**R4:** Una.

**P5:** ¿Cuál es la diferencia entre un rol funcional y un rol de acceso?
**R5:** Los roles de acceso contienen privilegios sobre objetos; los roles funcionales representan funciones laborales y heredan de los roles de acceso.

**P6:** ¿Qué proporciona Tri-Secret Secure?
**R6:** Clave administrada por el cliente que envuelve la clave de Snowflake — el cliente puede revocar el acceso a sus datos.

**P7:** ¿Los database roles se pueden otorgar directamente a usuarios?
**R7:** No. Deben otorgarse a roles a nivel de cuenta (u otros database roles dentro de la misma base de datos).

**P8:** ¿Qué hace `MIN_DATA_RETENTION_TIME_IN_DAYS`?
**R8:** Establece un piso para la retención de Time Travel que los objetos individuales no pueden reducir.

**P9:** ¿Qué método de autenticación deberían usar las cuentas de servicio?
**R9:** Autenticación por par de claves.

**P10:** ¿Cuál es el propósito de una projection policy?
**R10:** Evita que una columna aparezca en los resultados SELECT mientras permite su uso en WHERE/JOIN/GROUP BY.

**P11:** ¿Qué hace SCIM en Snowflake?
**R11:** Automatiza el aprovisionamiento/desaprovisionamiento de usuarios y grupos desde un IdP externo.

**P12:** Cuando se establece una network policy a nivel de usuario, ¿qué pasa con la política a nivel de cuenta para ese usuario?
**R12:** La política a nivel de usuario reemplaza completamente (no se fusiona con) la política a nivel de cuenta.

**P13:** ¿Qué edición se requiere para row access policies?
**R13:** Enterprise o superior.

**P14:** ¿Cuál es el período de retención de ACCESS_HISTORY?
**R14:** 365 días.

**P15:** ¿Se pueden combinar aggregation policies con masking policies en la misma tabla?
**R15:** Sí. Sirven para propósitos diferentes y pueden coexistir.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS -- Dominio 1

**1. Estrategia Multi-Cuenta**
Imagina que tienes diferentes cajas de juguetes para diferentes cuartos. La caja del dormitorio tiene juguetes para dormir, la caja del cuarto de juegos tiene juguetes para ensuciarse. Los mantienes separados para que la brillantina no llegue a tu almohada. Eso es multi-cuenta — cajas separadas para cosas separadas.

**2. Jerarquía de Parámetros**
Tus papás dicen "a dormir a las 8pm" (regla de cuenta). Pero para TU cuarto, es "a dormir a las 8:30pm" (regla de objeto). Y esta noche, como es tu cumpleaños, es "a dormir a las 9pm" (regla de sesión). ¡La regla más específica gana!

**3. Herencia de Roles**
Eres el "monitor de galletas" en la escuela. Eso significa que puedes repartir galletas. Tu maestra es la "jefa del salón" y ella tiene TODOS los poderes de monitor, incluyendo los tuyos. Los poderes fluyen HACIA ARRIBA.

**4. Network Policies**
Es como la lista de invitados en una fiesta de cumpleaños. Solo los niños en la lista pueden entrar. Si tu mamá hace una lista especial solo para ti, reemplaza la lista principal — no se suma a ella.

**5. PrivateLink**
En vez de caminar a la casa de tu amigo por la banqueta pública, construyes un túnel secreto entre sus casas. Nadie más puede verte caminar. Eso es PrivateLink.

**6. Masking Policies**
Escribes una nota secreta. Cuando tu mejor amigo la lee, ve las palabras reales. Cuando cualquier otro la lee, ve "XXXXX." Misma nota, diferentes vistas.

**7. Row Access Policies**
Un libro mágico para colorear donde solo puedes ver las páginas que tienen TU nombre. Otros niños tienen el mismo libro pero ven páginas diferentes.

**8. Tri-Secret Secure**
Cierras tu diario con TU candado. Luego lo pones en una caja con el candado de SNOWFLAKE. Se necesitan ambos candados para leerlo. Puedes quitar tu candado en cualquier momento y nadie puede leerlo.

**9. SSO / SAML**
En vez de recordar una contraseña para cada sitio web, tienes una llave mágica (tu credencial de la escuela) que abre todas las puertas.

**10. Object Tagging**
Poner stickers de colores en tus juguetes: rojo para "frágil," azul para "compartir con amigos." Después puedes decir "esconde TODOS los juguetes con sticker rojo" sin listar cada uno.');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 'en',
  '# Domain 2: Data Architecture

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
- Snowflake''s separation of storage and compute makes Data Vault''s insert-only, parallel-load pattern highly efficient

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
- Leverage Snowflake''s compute elasticity — storage savings from snowflake schema rarely justify the query complexity
- Document business keys and grain for every fact table

### Real-World Examples
- **Media conglomerate (20+ ad platforms):** Data Vault integration layer. Each ad platform (Google Ads, Meta, TikTok, programmatic DSPs) feeds into shared Hubs (Campaign, Advertiser, Impression). When a new platform is onboarded, add new Satellites -- Hubs and Links stay untouched. Star schema presentation layer on top for the media buying team''s Tableau dashboards.
- **Regional grocery chain (single POS system):** Star schema directly. One fact table (`sales_transactions`) with dimensions for stores, products, dates, promotions. Stable schema, one source system, 15 analysts who need simple queries. Data Vault overhead is unjustified here -- the schema hasn''t changed in 3 years.
- **Insurance company (claims + underwriting + actuarial):** Inmon 3NF enterprise data warehouse for the canonical model, then Data Vault for integrating external data sources (reinsurers, weather data, fraud detection APIs). Actuarial models consume from the 3NF layer; claims dashboards use star schemas built on top. Three modeling patterns coexisting by design.
- **Startup with one Postgres DB and 8 people:** Flat/OBT (One Big Table) for their core metrics dashboard. A single wide denormalized table with all the fields analysts need. Zero joins, zero complexity. When they grow past 30 people and add more sources, migrate to star schema or Data Vault.
- **Global bank (regulatory reporting across 40 countries):** Data Vault 2.0 with SHA2-512 hash keys. Multi-table INSERT loads Hubs and Satellites in parallel from each country''s source system. HASH_DIFF on Satellites detects changes without scanning full payloads. The audit trail is built into the model -- regulators can trace any number back to its source system and load timestamp.

### Common Questions (FAQ)
**Q: Can I use star schema directly on raw data?**
A: You can, but it''s fragile. Changes in source systems break the model. Better to stage/integrate first.

**Q: Does Snowflake enforce any modeling standard?**
A: No. Snowflake is schema-agnostic. You choose the model that fits your needs.

### Example Scenario Questions — Data Modeling

**Scenario:** A media conglomerate acquires 5 companies, each with different source systems (SAP, Salesforce, custom APIs, flat files). Schemas change frequently due to ongoing integrations. The CFO needs a unified financial reporting layer for quarterly earnings. What data modeling approach should the architect recommend?
**Answer:** Use Data Vault for the integration/raw layer. Hubs capture core business entities (customer, account, transaction) via hash keys, Links capture relationships, and Satellites absorb schema changes without breaking existing structures. Each acquired company''s data feeds into the same Hub/Link structure with separate Satellites tracking the source history. On top of the Data Vault layer, build star schemas for the presentation/consumption layer — the CFO''s reporting team queries denormalized fact and dimension tables optimized for BI dashboards. This two-layer approach absorbs ongoing schema changes in the Data Vault while delivering stable, fast analytics in the star layer.

**Scenario:** A startup with a single Postgres source and 10 analysts wants fast dashboards. They have a small team with no Data Vault experience. The data schema is stable and changes rarely. What modeling approach fits best?
**Answer:** Star schema directly on the curated/presentation layer. With a single stable source, the complexity of Data Vault is unnecessary overhead. Build fact tables for core business events (orders, sessions, payments) surrounded by denormalized dimension tables (customers, products, dates). Star schema provides the simplest joins for BI tools like Tableau or Looker. Since Snowflake''s elastic compute handles joins efficiently, the query performance benefits of denormalized dimensions outweigh the minimal storage savings of a normalized snowflake schema.

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
- **CANNOT change an account''s edition** -- only Snowflake Support can change editions (Standard to Enterprise, etc.)
- **CANNOT delete the last account** in the organization
- ORGADMIN is an organization-level role, separate from ACCOUNTADMIN

**Exam trap:** IF YOU SEE "ORGADMIN can change an account''s edition" → WRONG because only Snowflake Support can change editions.

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
- **Analytics consultancy (many clients, shared Snowflake account):** Naming convention enforced: `<client>_<layer>_<entity>` (e.g., `acme_raw_orders`). Double-quoted identifiers explicitly banned in coding standards -- a new analyst once created `"MyTable"` and nobody could query it without quotes. Account-level network policies restrict access to the consultancy''s VPN IPs only.
- **Data mesh organization (domain ownership):** Each domain team owns their database (`MARKETING_DB`, `PRODUCT_DB`, `FINANCE_DB`). SYSADMIN owns all databases (inherited via role hierarchy). Domain teams get custom admin roles (`MARKETING_ADMIN`) granted to SYSADMIN. Context functions like `CURRENT_DATABASE()` and `CURRENT_SCHEMA()` used in dynamic SQL for domain-agnostic ETL frameworks.
- **Regulated healthcare platform:** `INFORMATION_SCHEMA` for real-time monitoring of active queries and locks during business hours. `ACCOUNT_USAGE.QUERY_HISTORY` for the weekly compliance report (365-day retention). Both views serve different audiences -- ops team uses real-time, compliance team uses historical.

### Common Questions (FAQ)
**Q: What''s the difference between `@~` and `@%table`?**
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
| **Best for** | "What''s happening NOW" -- active queries, current locks | Historical analysis, auditing, compliance |

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

- **Transient:** use for staging/ETL tables where you don''t need Fail-safe (saves storage cost)

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
  - **Requires an external volume** — data is stored on the customer''s cloud storage (S3/Azure/GCS), NOT in Snowflake-managed storage. Snowflake manages the Iceberg metadata and catalog, but the data files reside on the customer''s external volume
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
- **IoT platform (sensor data, 1B rows/day):** Search Optimization Service on the `device_id` and `sensor_type` columns for point-lookup queries. Dynamic tables replace the old stream+task pipeline for hourly rollups. External tables for historical cold data in S3 that''s rarely queried but must remain accessible.

### Semi-Structured Data

**VARIANT Column Access**

- Colon notation: `col:key` or bracket notation: `col[''key'']`
- **Column names** are case-insensitive (standard Snowflake behavior)
- **JSON keys within VARIANT are CASE-SENSITIVE:** `col:Name` != `col:name` -- this is a frequent exam trap
- Nested access: `col:address.city` or `col:address[''city'']`

**Exam trap:** IF YOU SEE "JSON keys in VARIANT are case-insensitive" → WRONG because while Snowflake column names are case-insensitive, JSON keys within VARIANT are CASE-SENSITIVE.

**JSON null vs SQL NULL**

- JSON `null` string values stored in VARIANT degrade query performance because the optimizer cannot skip them during pruning
- Use **`STRIP_NULL_VALUE = TRUE`** in file format options to convert JSON null values to SQL NULLs during ingestion
- SQL NULLs are handled efficiently by Snowflake''s micro-partition metadata

**OBJECT_CONSTRUCT Functions**

- `OBJECT_CONSTRUCT(*)` builds a JSON object from all columns of a table row -- useful for converting relational rows to JSON
- `OBJECT_CONSTRUCT(''key1'', val1, ''key2'', val2)` builds from explicit key-value pairs
- **`OBJECT_CONSTRUCT_KEEP_NULL`** preserves null values in the output (by default, OBJECT_CONSTRUCT omits keys with NULL values)

**INFER_SCHEMA + USING TEMPLATE**

- Auto-create tables from staged file metadata (Parquet, Avro, ORC)
- `SELECT * FROM TABLE(INFER_SCHEMA(LOCATION => ''@my_stage'', FILE_FORMAT => ''my_format''))` detects column names and types
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

**Scenario:** A data platform team runs multi-step ETL pipelines that produce intermediate staging tables. These tables are recreated every run and don''t need historical recovery. Storage costs are a concern because the staging data is 50 TB and growing. What table types should the architect use?
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
- When only a **SCHEMA** is dropped, the schema''s own retention applies to its children
- When only a **TABLE** is dropped, the table''s own retention applies

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
- Clones are independent — changes to clone don''t affect source

**Exam trap:** IF YOU SEE "cloning a table doubles storage immediately" → WRONG because cloning is zero-copy; storage only grows as data diverges.

**Cloning Details and Edge Cases**

- **COPY GRANTS during cloning:** `CREATE TABLE ... CLONE ... COPY GRANTS` copies grants to the clone. Without `COPY GRANTS`, the clone gets default grants only. Supported for tables and views, but NOT for all object types
- **Cloned tasks are always SUSPENDED:** after cloning a database or schema, ALL tasks in the clone start in SUSPENDED state. You must manually `ALTER TASK ... RESUME` each one
- **Cloning scope for pipes:** only pipes referencing **external stages** are cloned. Pipes referencing internal stages are NOT cloned
- **Unconsumed stream records after clone:** stream records that existed before the clone are inaccessible in the cloned copy. The clone''s stream starts fresh from the clone point
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
- **Retail company (Black Friday incident):** A deploy script ran `TRUNCATE TABLE orders` on production instead of staging. Discovered 45 minutes later. Recovery: `CREATE TABLE orders_restored CLONE orders BEFORE(STATEMENT => ''<truncate_query_id>'')`, verify row counts, then `ALTER TABLE orders SWAP WITH orders_restored`. Zero downtime, full recovery. After this, the team set `DATA_RETENTION_TIME_IN_DAYS = 90` on all production tables and `MIN_DATA_RETENTION_TIME_IN_DAYS = 7` at account level.
- **SaaS platform (5 dev teams, 200 TB production):** Each team gets a fresh clone every morning: `CREATE DATABASE dev_team_1 CLONE production`. Zero additional storage until devs make changes. Clones are dropped and recreated daily. Before cloning, they were running CTAS into separate databases -- 1 PB of wasted storage.
- **Healthcare analytics (HIPAA audit trail):** 90-day Time Travel on all PHI tables. When a compliance officer asks "what did patient record X look like on March 15th?", the team queries `SELECT * FROM patients AT(TIMESTAMP => ''2025-03-15 00:00:00''::TIMESTAMP)`. No custom audit tables needed.
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
**Answer:** Use Time Travel to restore the data. Since only 3 hours have passed and the table has at least 1-day Time Travel, the data is fully recoverable. Option 1: `CREATE TABLE customers_restored CLONE customers BEFORE(STATEMENT => ''<truncate_query_id>'')` to create a point-in-time clone, then swap the tables. Option 2: `INSERT INTO customers SELECT * FROM customers BEFORE(OFFSET => -10800)` to repopulate from the 3-hour-ago snapshot. Going forward, the architect should set `DATA_RETENTION_TIME_IN_DAYS = 90` on all critical production tables (Enterprise edition supports up to 90 days) and set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level to prevent anyone from reducing it.

**Scenario:** A data platform team needs to provide fresh copies of the 200 TB production database to 5 development teams daily for testing. Full data copies would cost 1 PB of storage. How should the architect handle this efficiently?
**Answer:** Use zero-copy cloning: `CREATE DATABASE dev_team_1 CLONE production`. Each clone initially shares all underlying micro-partitions with production — zero additional storage. Storage only grows as dev teams make changes to their cloned data. Each morning, drop the previous day''s clones and create fresh ones. Clones inherit Time Travel settings from the source and are fully independent — dev team changes never affect production. This provides 5 teams with full production data at near-zero storage cost.

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
- Essential for true DR — database replication alone doesn''t cover access control
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
- This enables cross-region sharing: replicate the database AND the share to the consumer''s region, so the share is available from the replicated account
- For **Marketplace listings**, Cross-Cloud Auto Fulfillment handles this automatically -- but for **direct shares**, you must manually include shares in failover groups or replicate and recreate them

**Client Redirect**

- Connection URLs that automatically redirect to the active primary
- Minimizes client-side changes during failover
- Uses `CONNECTION` objects: `CREATE CONNECTION`, `ALTER CONNECTION ... PRIMARY`

**Exam trap:** IF YOU SEE "client redirect works without Connection objects" → WRONG because you must create and configure Connection objects for client redirect.

### Why This Matters
A global fintech company runs primary in AWS US-East, secondary in AWS EU-West. If US-East goes down, they promote EU-West in minutes. Client redirect means apps don''t need config changes.

### Best Practices
- Use failover groups (not standalone database replication) for production DR
- Include account objects in your failover group for complete recovery
- Set up client redirect to minimize failover RTO
- Monitor replication lag via `REPLICATION_GROUP_REFRESH_HISTORY`
- Test failover quarterly with real promote/failback drills

### Real-World Examples
- **Global fintech (AWS US-East primary, AWS EU-West secondary):** Failover group includes 4 databases + users, roles, grants, warehouses, network policies, integrations. Replication every 10 minutes (RPO = 10 min). Client redirect via Connection object -- JDBC apps use the Connection URL. During the annual DR drill, they promoted EU-West in 4 minutes. Zero app config changes needed. The CFO approved the replication cost after seeing the 4-minute RTO.
- **E-commerce company (incomplete DR -- what NOT to do):** Replicated only the database, not account objects. During a failover drill, the secondary had the data but nobody could log in -- no users, no roles, no network policies existed. Lesson: always use failover groups that include account-level objects, not standalone database replication.
- **Multi-cloud enterprise (AWS primary, Azure secondary):** Cross-cloud replication from AWS US-East to Azure West-Europe. Both accounts in the same Snowflake Organization. Higher data transfer costs than same-cloud replication, but the company''s risk committee requires cloud-provider redundancy. They monitor `REPLICATION_GROUP_REFRESH_HISTORY` daily for lag spikes.
- **Data provider with cross-region consumers:** Primary account in US-East shares market data. A large consumer in EU wants low-latency access. The provider replicates the database to an account in EU-West, creates a share from the replica. The consumer queries from the EU replica with local latency. For Marketplace listings, Cross-Cloud Auto Fulfillment handles this automatically.
- **Insurance company (regulatory RPO = 1 hour):** Replication refresh scheduled every 15 minutes with alerting if lag exceeds 30 minutes. The secondary account is charged for both data transfer and compute. Budget: ~$2K/month for replication -- cheap insurance against a regional outage that could cost millions in claims processing delays.

### Common Questions (FAQ)
**Q: What''s the difference between database replication and failover groups?**
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
- New tables added to the provider''s schema require **explicit** `GRANT SELECT ON TABLE ... TO SHARE` -- they do NOT auto-appear in the share
- `DROP SHARE` is **permanent** -- you cannot UNDROP a share; must recreate from scratch
- Consuming a share requires both **IMPORT SHARE** and **CREATE DATABASE** privileges on the consumer account

**Exam trap:** IF YOU SEE "shares can include objects from multiple databases" → WRONG because a share is limited to one database. Use secure views to consolidate data from multiple databases.

**Exam trap:** IF YOU SEE "new tables auto-appear in a share" → WRONG because the provider must explicitly GRANT SELECT on each new table to the share.

**Exam trap:** IF YOU SEE "you can UNDROP a share" → WRONG because DROP SHARE is permanent -- no recovery possible.

**Cross-Region / Cross-Cloud Sharing**

- Direct sharing only works within the **same region on the same cloud provider**
- For cross-region or cross-cloud sharing, the provider must: (1) replicate the database to an account in the consumer''s region, (2) create the share from the replicated database
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

- **Provider pays for:** storage of the shared data (data lives in provider''s account)
- **Consumer pays for:** compute (warehouse costs to query shared data)
- **No data movement** -- consumers query the provider''s data in place via metadata pointers
- **Reader accounts exception:** provider pays for BOTH storage AND compute (provider manages the reader account''s warehouse)
- This zero-copy architecture is what makes Snowflake sharing fundamentally different from ETL-based data delivery

**Exam trap:** IF YOU SEE "provider pays for compute when consumers query shared data" → WRONG because the consumer pays for their own compute (warehouse). Provider only pays storage. Exception: reader accounts where provider pays both.

**SIMULATED_DATA_SHARING_CONSUMER Parameter**

- Session parameter to **test what consumers will see** in secure views BEFORE actually sharing
- Syntax: `ALTER SESSION SET SIMULATED_DATA_SHARING_CONSUMER = ''<consumer_account_name>''`
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
A healthcare analytics company wants to share de-identified patient outcome data with 50 hospital partners. Some partners have Snowflake accounts, others don''t. The company uses secure views in a share for Snowflake partners (zero data copy, real-time access) and reader accounts for non-Snowflake partners (provider pays compute). All shared objects use secure views to hide proprietary SQL logic.

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
- **Insurance consortium (claims data sharing):** Five insurance companies share anonymized claims data for fraud detection. Private Data Exchange with strict access controls. Each company provides data via secure views that mask policyholder PII using dynamic data masking policies. Key decision: `SIMULATED_DATA_SHARING_CONSUMER` testing before onboarding each new member -- caught a masking policy gap that would have exposed SSN data to one partner whose `CURRENT_ROLE()` wasn''t in the policy whitelist.

### Common Questions (FAQ)
**Q: Can a consumer modify shared data?**
A: No. Shared objects are read-only. Consumers can create local copies (CTAS) if they need to modify data.

**Q: How do I share data from multiple databases?**
A: Create secure views in a single database that join/union data from other databases, then share that database.

**Q: What happens when the provider revokes a share?**
A: The consumer''s database created from that share becomes inaccessible immediately. The consumer must drop it.

**Q: Can reader accounts access data from multiple providers?**
A: No. A reader account can only consume data from the provider that created it.

**Q: How do I validate what a consumer will see before sharing?**
A: Use `ALTER SESSION SET SIMULATED_DATA_SHARING_CONSUMER = ''<account>''` then query the secure view. This simulates the consumer''s perspective without actually sharing.

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
**Answer:** For the two same-region Snowflake partners: create a share with secure views and grant access directly. For the cross-region Snowflake partner: replicate the database to an account in the partner''s region, then create a share from the replica. For the two non-Snowflake partners: create **reader accounts** (`CREATE MANAGED ACCOUNT`) for each. The pharmaceutical company pays for reader account compute and storage. All shared objects use secure views to hide proprietary query logic and enforce row-level filtering per partner.

---

## CONFUSING PAIRS — Data Architecture

| They ask about... | The answer is... | NOT... |
|---|---|---|
| **Star schema** vs **snowflake schema** | **Star** = denormalized dims, fewer joins, fast queries | **Snowflake schema** = normalized dims, more joins, saves storage but slower |
| **Data Vault** vs **dimensional modeling** | **Data Vault** = integration/raw layer (Hubs, Links, Satellites) | **Dimensional** = presentation/BI layer (facts + dims). They''re *complementary*, not competing |
| **Hub** vs **Link** vs **Satellite** | **Hub** = business key, **Link** = relationship, **Satellite** = descriptive history | Don''t confuse Hub (entity ID) with Satellite (attributes) |
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

## DON''T MIX -- Architecture Concepts That Sound the Same

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

**RULE:** If the query has a JOIN or UDF -- Dynamic Table. If it''s a simple aggregation on ONE table -- Materialized View.

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
- TRAP: *"External table"* — **WRONG**, external tables are read-only and don''t produce Iceberg format

**Scenario 4: "Staging tables hold temporary ETL data — minimize storage costs..."**
- **CORRECT:** **Transient tables** (no Fail-safe = lower storage cost)
- TRAP: *"Temporary tables"* — **WRONG**, temporary tables are session-scoped and vanish when the session ends; not suitable for multi-session ETL

**Scenario 5: "Analyst accidentally deleted 1M rows from production 2 hours ago..."**
- **CORRECT:** **Time Travel** — `INSERT INTO prod SELECT * FROM prod AT(OFFSET => -7200)` or `CREATE TABLE restore CLONE prod AT(...)`
- TRAP: *"Contact Snowflake Support for Fail-safe"* — **WRONG**, Fail-safe is only after Time Travel expires; 2 hours ago is within Time Travel

**Scenario 6: "Need DR to a different cloud region with < 5 min RTO for app connections..."**
- **CORRECT:** **Failover group** (DB + account objects) + **client redirect** (Connection object)
- TRAP: *"Database replication alone"* — **WRONG**, DB replication doesn''t cover roles/users/policies, and no auto-redirect without Connection objects

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

**Scenario 13: "Share data with a partner who doesn''t have a Snowflake account..."**
- **CORRECT:** **Reader account** (`CREATE MANAGED ACCOUNT`) — provider manages and pays
- TRAP: *"Create a share and tell them to sign up"* — **WRONG**, reader accounts exist precisely for non-Snowflake consumers

**Scenario 14: "Share data with a consumer in a different cloud region..."**
- **CORRECT:** **Replicate the database** to the consumer''s region first, then create the share from the replica
- TRAP: *"Create a direct share"* — **WRONG**, direct sharing only works within the same region on the same cloud provider

**Scenario 15: "Need to share data from 3 different databases in one share..."**
- **CORRECT:** Create **secure views** in one database that join/reference the other databases, then share that single database
- TRAP: *"Add objects from all 3 databases to the share"* — **WRONG**, a share can only include objects from ONE database

**Scenario 16: "Need real-time metadata about active queries and current locks..."**
- **CORRECT:** **INFORMATION_SCHEMA** views (real-time, no latency)
- TRAP: *"ACCOUNT_USAGE views"* — **WRONG** for real-time needs; ACCOUNT_USAGE has 2-3 hour latency. Use it for historical analysis instead

**Scenario 17: "Business Critical provider needs to share data with a Standard edition consumer..."**
- **CORRECT:** Set `SHARE_RESTRICTIONS = FALSE` on the share using a role with **OVERRIDE SHARE RESTRICTIONS** privilege
- TRAP: *"Upgrade the consumer to Business Critical"* — **WRONG**, the provider controls the share restriction, not the consumer''s edition

**Scenario 18: "Architect needs to validate that a secure view shows the right data per consumer before sharing..."**
- **CORRECT:** `ALTER SESSION SET SIMULATED_DATA_SHARING_CONSUMER = ''<account>''` then query the secure view
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
**A17:** A managed account created by a provider for consumers who don''t have a Snowflake account. The provider pays for compute and storage.

**Q18:** Can you share data directly across regions?
**A18:** No. Direct sharing requires same region + same cloud provider. Cross-region sharing requires database replication first.

**Q19:** What happens to tasks after cloning a database?
**A19:** All cloned tasks are in SUSPENDED state. You must manually ALTER TASK ... RESUME each one.

**Q20:** Are JSON keys in VARIANT case-sensitive?
**A20:** Yes. Column names are case-insensitive, but JSON keys within VARIANT are case-sensitive. `col:Name` != `col:name`.

**Q21:** What is the difference between INFORMATION_SCHEMA and ACCOUNT_USAGE?
**A21:** INFORMATION_SCHEMA is real-time with 7-14 day retention (current DB only). ACCOUNT_USAGE has 2-3 hour latency but 365-day retention (entire account).

**Q22:** Can ORGADMIN change an account''s edition?
**A22:** No. Only Snowflake Support can change account editions.

**Q23:** What does ADD SEARCH OPTIMIZATION ON do if SOS already exists on the table?
**A23:** It is additive -- it extends the existing search optimization config, it does not replace it.

**Q24:** Who pays for replication compute charges?
**A24:** The target (secondary) account pays for both data transfer and compute during replication refresh.

**Q25:** How do you test what a consumer will see in a shared secure view before sharing?
**A25:** `ALTER SESSION SET SIMULATED_DATA_SHARING_CONSUMER = ''<account>''` then query the secure view. Works with secure views and secure MVs, NOT secure UDFs.

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

## EXPLAIN LIKE I''M 5 -- Domain 2

**1. Data Vault**
Imagine you have a box for each friend''s name (Hub), a string connecting friends who played together (Link), and sticky notes describing what happened each playdate (Satellite). You never throw anything away — you just add more sticky notes!

**2. Star Schema**
Your toy collection: the big toy chest in the middle has all your play sessions (fact table). Around it are shelves labeled "toys," "friends," "days of the week" (dimension tables). Easy to find "which toy did I play with on Tuesday?"

**3. Time Travel**
Your magic undo button. Spilled paint on your drawing? Press undo and go back to before the spill. Works for up to 90 days!

**4. Fail-safe**
Even after your undo button stops working, your parents kept a secret backup of your drawings in a locked drawer. You can''t open it yourself, but they can help if something really bad happens.

**5. Zero-Copy Cloning**
Like taking a photo of your LEGO castle. The photo takes no extra LEGO pieces. But if you change the original castle, only the changed parts need extra pieces.

**6. Transient vs Permanent Tables**
Permanent tables are like your favorite toy kept forever with insurance (Fail-safe). Transient tables are like sand castles — they exist, but no insurance if the tide comes.

**7. Managed Iceberg Tables**
You build with LEGO, but you use the universal LEGO connector system so your friend with a different LEGO brand can also connect to your castle. Snowflake manages the building, but anyone can read the instructions.

**8. Secure Views**
A magic window where you can see the garden but can''t see how the window was built. Different people looking through the same window might see different flowers (filtered!).

**9. Replication**
Like having a backup of your favorite game save file on a USB stick at grandma''s house. If your computer breaks, grandma has the save file. Not quite up-to-the-second, but close.

**10. Client Redirect**
Like a mailbox that follows you. If you move houses, the mailbox automatically goes to your new house, and everyone''s letters still arrive without them knowing you moved.

**11. Data Sharing**
You have a bookshelf with great books. Instead of giving copies to your friends (expensive!), you let them look through a special window into your room. They can read the books but can''t take them, change them, or see how you organized your room. That''s a share with secure views.

**12. Reader Accounts**
Your friend doesn''t have a library card (Snowflake account). So you get them a guest pass that YOU pay for. They can only visit YOUR section of the library, and you control what they see.

**13. Marketplace**
Like a farmers'' market where anyone can browse and buy produce (data). Some stalls are free samples, others charge money. The market organizers make sure every stall is available no matter which entrance you came through (Cross-Cloud Auto Fulfillment).

**14. SIMULATED_DATA_SHARING_CONSUMER**
Before letting your friend look through the window (share), you put on your friend''s glasses to see what THEY would see. If they''d see something they shouldn''t, you fix the window (secure view) before inviting them over.

**15. Data Exchange**
A private club for data. Only members you invite can browse and use the data. The public market (Marketplace) is open to everyone, but the Data Exchange is invite-only -- like a secret treehouse with a "members only" sign.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 'pt',
  '# Domínio 2: Arquitetura de Dados

> **Cobertura do Programa ARA-C01:** Modelagem de Dados, Hierarquia de Objetos, Recuperação de Dados

---

## 2.1 MODELAGEM DE DADOS

**Data Vault**

- Três tipos de entidade principais: **Hubs** (chaves de negócio), **Links** (relacionamentos), **Satellites** (atributos descritivos + histórico)
- Projetado para auditabilidade, flexibilidade e carregamento paralelo
- Hash keys permitem carregamento paralelo, apenas inserção
- Melhor para: data warehouses corporativos com muitos sistemas fonte, esquemas em evolução, requisitos de auditoria
- Desvantagem: queries mais complexas, requer modeladores experientes

**Star Schema**

- **Tabela fato** central (medidas/métricas) cercada por **tabelas dimensão** (contexto descritivo)
- Dimensões desnormalizadas = leituras rápidas, joins simples
- Melhor para: BI/analytics, dashboards, padrões de query conhecidos
- Desvantagem: ETL é mais difícil (precisa manter dims desnormalizadas), menos flexível a mudanças de esquema

**Snowflake Schema**

- Como star schema mas as dimensões são normalizadas (divididas em sub-dimensões)
- Ex: `product_dim` → `category_dim` → `department_dim`
- Melhor para: economizar armazenamento, reduzir redundância em dimensões grandes
- Desvantagem: mais joins = queries mais lentas, mais complexo para analistas

**Quando Usar Cada Um**

| Modelo | Use Quando... |
|---|---|
| Data Vault | Muitas fontes, precisa de trilha de auditoria, esquema muda frequentemente |
| Star | Esquema estável, foco em BI, performance de query é prioridade |
| Snowflake | Dimensões grandes com alta redundância, armazenamento importa |
| Flat/OBT | Analytics simples, fonte única, joins mínimos necessários |

### Por Que Isso Importa
Uma empresa de mídia ingere dados de mais de 20 plataformas de anúncios. Esquemas mudam mensalmente. Data Vault absorve as mudanças nos satellites sem quebrar hubs/links. A camada de BI usa star schemas construídos por cima.

### Melhores Práticas
- Use Data Vault para a camada raw/integração, star schema para a camada de apresentação
- Aproveite a elasticidade de computação do Snowflake — economias de armazenamento do snowflake schema raramente justificam a complexidade das queries
- Documente chaves de negócio e granularidade para cada tabela fato

**Armadilha do exame:** SE VOCÊ VER "star schema é melhor para trilhas de auditoria" → ERRADO porque Data Vault é projetado para auditabilidade.

**Armadilha do exame:** SE VOCÊ VER "snowflake schema é a recomendação padrão para o produto Snowflake" → ERRADO porque a nomenclatura é coincidência. Star schema é mais comum para analytics.

**Armadilha do exame:** SE VOCÊ VER "Data Vault substitui modelagem dimensional" → ERRADO porque Data Vault é para a camada de integração; você ainda constrói star schemas por cima para consumo.

### Perguntas Frequentes (FAQ)
**P: Posso usar star schema diretamente em dados brutos?**
R: Pode, mas é frágil. Mudanças nos sistemas fonte quebram o modelo. Melhor fazer staging/integração primeiro.

**P: O Snowflake impõe algum padrão de modelagem?**
R: Não. O Snowflake é agnóstico a esquema. Você escolhe o modelo que atende suas necessidades.


### Exemplos de Perguntas de Cenário — Data Modeling

**Cenário:** A media conglomerate acquires 5 companies, each with different source systems (SAP, Salesforce, custom APIs, flat files). Schemas change frequently due to ongoing integrations. The CFO needs a unified financial reporting layer for quarterly earnings. What data modeling approach should the architect recommend?
**Resposta:** Use Data Vault for the integration/raw layer. Hubs capture core business entities (customer, account, transaction) via hash keys, Links capture relationships, and Satellites absorb schema changes without breaking existing structures. Each acquired company''s data feeds into the same Hub/Link structure with separate Satellites tracking the source history. On top of the Data Vault layer, build star schemas for the presentation/consumption layer — the CFO''s reporting team queries denormalized fact and dimension tables optimized for BI dashboards. This two-layer approach absorbs ongoing schema changes in the Data Vault while delivering stable, fast analytics in the star layer.

**Cenário:** A startup with a single Postgres source and 10 analysts wants fast dashboards. They have a small team with no Data Vault experience. The data schema is stable and changes rarely. What modeling approach fits best?
**Resposta:** Star schema directly on the curated/presentation layer. With a single stable source, the complexity of Data Vault is unnecessary overhead. Build fact tables for core business events (orders, sessions, payments) surrounded by denormalized dimension tables (customers, products, dates). Star schema provides the simplest joins for BI tools like Tableau or Looker. Since Snowflake''s elastic compute handles joins efficiently, the query performance benefits of denormalized dimensions outweigh the minimal storage savings of a normalized snowflake schema.

---

---

## 2.2 HIERARQUIA DE OBJETOS

**Estrutura de Cima para Baixo**

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

**Pontos-Chave**

- Tudo reside dentro de um namespace `DATABASE.SCHEMA`
- Alguns objetos são no nível de conta: warehouses, users, roles, resource monitors, network policies, integrations, shares
- Stages podem ser no nível de tabela (`@%my_table`), nível de schema (`@my_stage`), ou nível de usuário (`@~`)
- Managed access schemas: apenas o dono do schema (ou MANAGE GRANTS) pode conceder privilégios — impede que donos de objetos concedam acesso independentemente

### Por Que Isso Importa
Uma equipe de plataforma de dados precisa impedir que donos individuais de tabelas concedam SELECT para roles aleatórias. Managed access schemas centralizam o controle de concessões.

### Melhores Práticas
- Use managed access schemas em produção
- Organize schemas por domínio ou camada de dados (raw, curated, presentation)
- Nomeie objetos consistentemente: `<domínio>_<entidade>_<sufixo>` (ex: `sales_orders_fact`)
- Mantenha objetos no nível de conta (warehouses, roles) bem documentados

**Armadilha do exame:** SE VOCÊ VER "warehouses pertencem a um banco de dados" → ERRADO porque warehouses são objetos no nível de conta.

**Armadilha do exame:** SE VOCÊ VER "managed access schemas impedem o dono do schema de conceder" → ERRADO porque o dono do schema PODE ainda conceder em managed access schemas — a restrição é sobre donos de objetos diferentes do dono do schema.

**Armadilha do exame:** SE VOCÊ VER "network policies são objetos no nível de banco de dados" → ERRADO porque são no nível de conta.

### Perguntas Frequentes (FAQ)
**P: Qual é a diferença entre `@~` e `@%table`?**
R: `@~` é o user stage (um por usuário). `@%table` é o table stage (um por tabela). Ambos são internos, mas com escopo diferente.

**P: Posso ter um schema sem um banco de dados?**
R: Não. Schemas sempre residem dentro de um banco de dados.


### Exemplos de Perguntas de Cenário — Object Hierarchy

**Cenário:** A production data platform has 200 tables owned by different teams (marketing, finance, engineering). The security team discovers that individual table owners have been granting SELECT on their tables to unapproved roles, bypassing the central governance model. How should the architect prevent this?
**Resposta:** Convert production schemas to managed access schemas using `ALTER SCHEMA ... ENABLE MANAGED ACCESS`. In a managed access schema, only the schema owner or roles with the MANAGE GRANTS privilege can issue GRANT statements on objects within the schema. Individual table owners lose the ability to grant access independently. This centralizes privilege management without requiring any changes to the object ownership model or existing data pipelines.

**Cenário:** An architect is designing the schema layout for a new analytics platform. They need separate layers for raw ingestion, cleaned/curated data, and presentation-ready datasets. Some objects (warehouses, resource monitors, network policies) need to be shared across all layers. How should this be organized?
**Resposta:** Create a single database (or one per domain) with three schemas: `RAW`, `CURATED`, and `PRESENTATION`. Each schema represents a data layer with its own access controls. Warehouses, resource monitors, network policies, users, and roles are account-level objects — they exist outside the database hierarchy and are shared across all schemas automatically. Use managed access schemas for `CURATED` and `PRESENTATION` to enforce centralized grant control. Name objects consistently with domain prefixes (e.g., `sales_orders_fact`) for discoverability.

---

---

## 2.3 TIPOS DE TABELA E VIEWS

**Tipos de Tabela**

| Tipo | Time Travel | Fail-safe | Persiste Após Sessão | Clonável |
|---|---|---|---|---|
| **Permanent** | 0-90 dias (Enterprise) | 7 dias | Sim | Sim |
| **Transient** | 0-1 dia | Nenhum | Sim | Sim |
| **Temporary** | 0-1 dia | Nenhum | Não (escopo de sessão) | Sim (dentro da sessão) |
| **External** | Não | Não | Sim (apenas metadados) | Não |
| **Dynamic** | 0-90 dias | 7 dias | Sim | Não |

- **Transient:** use para tabelas de staging/ETL onde você não precisa de Fail-safe (economiza custo de armazenamento)
- **Temporary:** use para resultados intermediários com escopo de sessão
- **External:** camada de metadados sobre arquivos em armazenamento externo — somente leitura
- **Dynamic:** atualizada automaticamente com base em uma query e target lag

**Iceberg Tables**

- **Managed (gerenciada pelo Snowflake):** Snowflake gerencia os metadados Iceberg + arquivos de dados
  - Suporte completo a DML (INSERT, UPDATE, DELETE, MERGE)
  - Snowflake cuida da compactação, gerenciamento de snapshots
  - Armazenada em armazenamento gerenciado pelo Snowflake ou external volume do cliente
- **Unmanaged (gerenciada externamente / catalog-linked):** catálogo externo (AWS Glue, Polaris) gerencia metadados
  - Somente leitura a partir do Snowflake (ou escrita limitada dependendo do catálogo)
  - Snowflake lê metadados Iceberg para consultar dados
  - Use para acesso multi-engine (Spark + Snowflake nos mesmos dados)

**Hybrid Tables**

- Projetadas para workloads transacionais (OLTP) dentro do Snowflake
- Suportam buscas rápidas por linha única, índices e integridade referencial (PRIMARY KEY, FOREIGN KEY, UNIQUE aplicadas)
- Armazenadas em formato orientado a linhas para leituras pontuais de baixa latência
- Caso de uso: dados operacionais que também precisam ser unidos com dados analíticos

**Tipos de View**

| Tipo | Materializada? | Segura? | Notas |
|---|---|---|---|
| Standard view | Não | Não | Apenas uma query salva |
| Secure view | Não | Sim | Esconde definição, barreira de otimizador |
| Materialized view | Sim | Não | Pré-computada, mantida automaticamente |
| Secure materialized view | Sim | Sim | Ambos os benefícios |

- **Secure views:** definição da query escondida dos consumidores, otimizador não pode empurrar predicados além da barreira da view
- **Materialized views:** melhor para agregações caras em dados grandes e pouco alterados
- Materialized views têm limitações: sem joins, sem UDFs, sem subqueries na definição

### Por Que Isso Importa
Um marketplace de dados compartilha dados via secure views — consumidores não podem ver a lógica da query subjacente ou contornar segurança no nível de linha.

### Melhores Práticas
- Use tabelas transient para dados de staging (evite custos desnecessários de Fail-safe)
- Use dynamic tables em vez de pipelines complexos de task/stream onde possível
- Use secure views para todos os objetos compartilhados
- Considere Iceberg managed tables quando precisar de interoperabilidade em formato aberto

**Armadilha do exame:** SE VOCÊ VER "tabelas transient têm 7 dias de Fail-safe" → ERRADO porque tabelas transient têm zero Fail-safe.

**Armadilha do exame:** SE VOCÊ VER "tabelas temporary persistem após o término da sessão" → ERRADO porque são descartadas quando a sessão termina.

**Armadilha do exame:** SE VOCÊ VER "materialized views suportam joins" → ERRADO porque definições de MV não podem incluir joins.

**Armadilha do exame:** SE VOCÊ VER "hybrid tables usam armazenamento colunar" → ERRADO porque usam armazenamento orientado a linhas para buscas pontuais rápidas.

**Armadilha do exame:** SE VOCÊ VER "tabelas externas suportam DML" → ERRADO porque tabelas externas são somente leitura.

### Perguntas Frequentes (FAQ)
**P: Posso converter uma tabela permanent para transient?**
R: Não diretamente. Você precisa criar uma nova tabela transient e copiar os dados (ou usar CTAS).

**P: Secure views têm custo de performance?**
R: Sim. A barreira do otimizador impede algumas otimizações, então secure views podem ser mais lentas que standard views.

**P: Quando eu usaria uma managed Iceberg table vs uma tabela Snowflake regular?**
R: Quando você precisa que os dados estejam em formato aberto Iceberg para acesso multi-engine enquanto ainda tem DML completo do Snowflake.


### Exemplos de Perguntas de Cenário — Table Types & Views

**Cenário:** A data platform team runs multi-step ETL pipelines that produce intermediate staging tables. These tables are recreated every run and don''t need historical recovery. Storage costs are a concern because the staging data is 50 TB and growing. What table types should the architect use?
**Resposta:** Use transient tables for all staging/intermediate tables. Transient tables have zero Fail-safe storage (saving 7 days worth of historical data storage per table) and a maximum of 1-day Time Travel. Since these tables are recreated every run, the 7-day Fail-safe of permanent tables provides no value but adds significant storage cost at 50 TB scale. For truly session-scoped scratch work within a single ETL step, temporary tables are even lighter (dropped when the session ends).

**Cenário:** A company runs both Snowflake and Apache Spark. The data science team uses Spark for ML training on feature tables, while the analytics team queries the same tables from Snowflake. Currently, data is duplicated — a Snowflake copy and a Parquet copy in S3. How should the architect eliminate the duplication?
**Resposta:** Migrate the feature tables to managed Iceberg tables with an external volume pointing to S3. Snowflake manages the table lifecycle (writes, compaction, snapshots) and produces Iceberg-formatted data files and metadata in S3. Spark reads the same Iceberg metadata and data files directly — no duplication. Snowflake retains full DML (INSERT, UPDATE, DELETE, MERGE) support, Time Travel, and clustering. The data science team accesses the same data from Spark without any data movement or copy.

**Cenário:** A data marketplace needs to share pre-aggregated sales metrics with external consumers. The underlying query logic is proprietary. Consumers should not see the SQL definition or be able to bypass row-level security through optimizer tricks. What view type should the architect use?
**Resposta:** Use secure views (or secure materialized views for expensive aggregations). Secure views hide the view definition from consumers and impose an optimizer fence that prevents predicate pushdown past the view boundary — this stops consumers from inferring hidden data through clever filtering. For the data marketplace use case, all shared objects should use secure views as a baseline. Note that secure views have a minor performance cost due to the optimizer fence, but this is an acceptable trade-off for data protection in a sharing context.

---

---

## 2.4 RECUPERAÇÃO DE DADOS

**Time Travel**

- Consulte ou restaure dados como existiam em qualquer ponto dentro do período de retenção
- Métodos: `AT` / `BEFORE` com `TIMESTAMP`, `OFFSET`, ou `STATEMENT` (query ID)
- Retenção: 0-1 dia (Standard), 0-90 dias (Enterprise+)
- Funciona em tabelas, schemas e bancos de dados
- Custa armazenamento para dados alterados/deletados

**Fail-safe**

- Período de 7 dias APÓS o Time Travel expirar
- NÃO acessível pelo usuário — apenas o Suporte Snowflake pode recuperar dados
- Apenas para tabelas permanent (não transient, temporary ou external)
- Existe como último recurso para cenários catastróficos

**UNDROP**

- Restaura o objeto mais recentemente descartado: `UNDROP TABLE`, `UNDROP SCHEMA`, `UNDROP DATABASE`
- Usa dados de Time Travel internamente
- Se você descarta e recria um objeto com mesmo nome, o antigo ainda pode ser restaurado (usa versionamento interno)

**Zero-Copy Cloning para Backup**

- `CREATE TABLE backup_table CLONE source_table`
- Sem armazenamento adicional até os dados divergirem
- Clones herdam configurações de Time Travel da origem
- Suporta clonagem de bancos de dados e schemas (clone recursivo de todos os filhos)
- Clones são independentes — mudanças no clone não afetam a origem

**Replicação para DR**

- Replicação de banco de dados: cópia assíncrona do banco de dados para outra conta/região
- Replicação de conta: replica usuários, roles, warehouses, policies
- Failover groups: conjunto de objetos replicados que podem fazer failover juntos
- RPO depende da frequência de replicação; RTO é o tempo para promover o secundário

### Por Que Isso Importa
Um analista acidentalmente executa `DELETE FROM production_table`. Com Time Travel de 90 dias, a equipe de dados restaura a tabela para 5 minutos antes do delete. Sem fitas de backup, sem downtime.

### Melhores Práticas
- Defina Time Travel de 90 dias em tabelas críticas de produção (Enterprise necessário)
- Use tabelas transient para staging para evitar custos de armazenamento do Fail-safe
- Clone produção para dev/teste em vez de copiar dados
- Configure replicação para bancos de dados de missão crítica em uma região secundária
- Teste seus procedimentos de recuperação regularmente

**Armadilha do exame:** SE VOCÊ VER "Dados do Fail-safe podem ser recuperados por usuários via SQL" → ERRADO porque apenas o Suporte Snowflake pode recuperar dados do Fail-safe.

**Armadilha do exame:** SE VOCÊ VER "Retenção de Time Travel pode ser definida para 90 dias na edição Standard" → ERRADO porque o máximo da edição Standard é 1 dia.

**Armadilha do exame:** SE VOCÊ VER "clonar uma tabela dobra o armazenamento imediatamente" → ERRADO porque clonagem é zero-copy; armazenamento só cresce conforme dados divergem.

**Armadilha do exame:** SE VOCÊ VER "UNDROP funciona em tabelas transient após Fail-safe" → ERRADO porque tabelas transient não têm Fail-safe, e UNDROP só funciona durante o período de Time Travel.

### Perguntas Frequentes (FAQ)
**P: Se eu defino Time Travel para 0, ainda posso fazer UNDROP?**
R: Não. UNDROP depende de dados de Time Travel. Com retenção 0, os dados são perdidos imediatamente.

**P: A clonagem copia grants?**
R: Ao clonar bancos de dados/schemas, grants em objetos filhos são copiados. Clones no nível de tabela não copiam grants por padrão (a menos que você use `COPY GRANTS`).

**P: Posso replicar para um provedor de nuvem diferente?**
R: Sim. Replicação cross-cloud é suportada (ex: AWS para Azure), mas ambas as contas devem estar na mesma Organization.


### Exemplos de Perguntas de Cenário — Data Recovery

**Cenário:** A junior engineer accidentally runs `TRUNCATE TABLE customers` on the production database containing 500M rows. The team discovers the mistake 3 hours later. The account is on Enterprise edition with the default 1-day Time Travel retention. How should the architect recover the data?
**Resposta:** Use Time Travel to restore the data. Since only 3 hours have passed and the table has at least 1-day Time Travel, the data is fully recoverable. Option 1: `CREATE TABLE customers_restored CLONE customers BEFORE(STATEMENT => ''<truncate_query_id>'')` to create a point-in-time clone, then swap the tables. Option 2: `INSERT INTO customers SELECT * FROM customers BEFORE(OFFSET => -10800)` to repopulate from the 3-hour-ago snapshot. Going forward, the architect should set `DATA_RETENTION_TIME_IN_DAYS = 90` on all critical production tables (Enterprise edition supports up to 90 days) and set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level to prevent anyone from reducing it.

**Cenário:** A data platform team needs to provide fresh copies of the 200 TB production database to 5 development teams daily for testing. Full data copies would cost 1 PB of storage. How should the architect handle this efficiently?
**Resposta:** Use zero-copy cloning: `CREATE DATABASE dev_team_1 CLONE production`. Each clone initially shares all underlying micro-partitions with production — zero additional storage. Storage only grows as dev teams make changes to their cloned data. Each morning, drop the previous day''s clones and create fresh ones. Clones inherit Time Travel settings from the source and are fully independent — dev team changes never affect production. This provides 5 teams with full production data at near-zero storage cost.

---

---

## 2.5 REPLICAÇÃO E FAILOVER

**Replicação de Banco de Dados**

- Replica um banco de dados da conta primária para uma ou mais contas secundárias
- Secundário é somente leitura até ser promovido (ou até failover)
- Replicação é assíncrona — atualidade dos dados depende do agendamento de refresh
- Replicação inicial copia todos os dados; subsequentes são incrementais (apenas mudanças)

**Replicação de Conta**

- Replica objetos no nível de conta: usuários, roles, grants, warehouses, network policies, parâmetros
- Essencial para DR verdadeiro — replicação de banco de dados sozinha não cobre controle de acesso
- Combinada com replicação de banco de dados em failover groups

**Failover Groups**

- Coleção nomeada de objetos que podem fazer failover como uma unidade
- Tipos de objetos: databases, shares, users, roles, warehouses, integrations, network policies
- Promoção `PRIMARY` → `SECONDARY` via `ALTER FAILOVER GROUP ... PRIMARY`
- Apenas um primário por vez por failover group

**Cross-Region / Cross-Cloud**

- Replicação funciona entre regiões E entre provedores de nuvem
- Ambas as contas devem estar na mesma Snowflake Organization
- Considere regulamentações de residência de dados ao replicar entre regiões
- Custos de replicação: transferência de dados + computação para refresh

**Client Redirect**

- URLs de conexão que redirecionam automaticamente para o primário ativo
- Minimiza mudanças no lado do cliente durante failover
- Usa objetos `CONNECTION`: `CREATE CONNECTION`, `ALTER CONNECTION ... PRIMARY`

### Por Que Isso Importa
Uma empresa global de fintech roda primário em AWS US-East, secundário em AWS EU-West. Se US-East cai, eles promovem EU-West em minutos. Client redirect significa que apps não precisam de mudanças de configuração.

### Melhores Práticas
- Use failover groups (não replicação standalone de banco de dados) para DR de produção
- Inclua objetos de conta no seu failover group para recuperação completa
- Configure client redirect para minimizar RTO de failover
- Monitore lag de replicação via `REPLICATION_GROUP_REFRESH_HISTORY`
- Teste failover trimestralmente com exercícios reais de promoção/failback

**Armadilha do exame:** SE VOCÊ VER "bancos de dados secundários são leitura-escrita" → ERRADO porque bancos de dados secundários são somente leitura até serem promovidos a primário.

**Armadilha do exame:** SE VOCÊ VER "replicação requer o mesmo provedor de nuvem" → ERRADO porque replicação cross-cloud é suportada.

**Armadilha do exame:** SE VOCÊ VER "failover é automático" → ERRADO porque failover deve ser iniciado manualmente (Snowflake não faz auto-failover).

**Armadilha do exame:** SE VOCÊ VER "client redirect funciona sem objetos Connection" → ERRADO porque você deve criar e configurar objetos Connection para client redirect.

### Perguntas Frequentes (FAQ)
**P: Qual é a diferença entre replicação de banco de dados e failover groups?**
R: Replicação de banco de dados cobre um banco de dados. Failover groups agrupam múltiplos bancos de dados + objetos de conta para failover coordenado.

**P: Há perda de dados durante failover?**
R: Potencialmente, sim. RPO = tempo desde o último refresh de replicação bem-sucedido. Qualquer dado escrito após o último refresh não está no secundário.

**P: Posso ter múltiplos failover groups?**
R: Sim. Você pode ter múltiplos failover groups, cada um contendo conjuntos diferentes de objetos. Cada objeto só pode pertencer a um failover group.


### Exemplos de Perguntas de Cenário — Replication & Failover

**Cenário:** A global fintech company runs its primary Snowflake account in AWS US-East-1. Regulators require that the platform can recover from a full regional outage within 5 minutes (RTO) with no more than 15 minutes of data loss (RPO). Applications connect via JDBC using a single connection URL. How should the architect design the DR architecture?
**Resposta:** Set up a failover group containing all critical databases plus account-level objects (users, roles, grants, warehouses, network policies, integrations). Replicate to a secondary account in AWS EU-West-1 (or another region) within the same Organization. Schedule replication refreshes every 10-15 minutes to meet the 15-minute RPO. Configure client redirect using a Connection object — applications connect to the Connection URL, which automatically routes to the active primary. During failover, promote the secondary via `ALTER FAILOVER GROUP ... PRIMARY` and update the Connection object. Apps automatically redirect to the new primary without configuration changes, meeting the 5-minute RTO. Test failover quarterly with real promote/failback drills.

**Cenário:** A company replicates its core database to a secondary account for DR, but during a failover drill, they discover that users cannot log in to the secondary account because roles, grants, and network policies were not replicated. What did the architect miss?
**Resposta:** The architect used database replication alone instead of a failover group with account replication. Database replication only copies the database and its contents — it does not replicate account-level objects like users, roles, grants, warehouses, network policies, or integrations. The correct approach is to create a failover group that includes both the databases AND account-level objects. This ensures that when the secondary is promoted, all access controls, role hierarchies, and network policies are already in place. Always include account objects in failover groups for complete DR.

**Cenário:** An organization operates on AWS for its primary workloads but wants a secondary DR site on Azure for cloud-provider redundancy. Is this possible with Snowflake replication?
**Resposta:** Yes. Snowflake supports cross-cloud replication — you can replicate from an AWS account to an Azure account (or GCP) as long as both accounts are in the same Snowflake Organization. The failover group mechanism works identically across cloud providers. However, the architect should account for cross-cloud data transfer costs, potential latency differences, and data residency regulations that may restrict which regions data can be replicated to. Monitor replication lag via `REPLICATION_GROUP_REFRESH_HISTORY` to ensure RPO targets are met despite cross-cloud overhead.

---

---

## PARES CONFUSOS — Arquitetura de Dados

| Perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| **Star schema** vs **snowflake schema** | **Star** = dims desnormalizadas, menos joins, queries rápidas | **Snowflake schema** = dims normalizadas, mais joins, economiza armazenamento mas mais lento |
| **Data Vault** vs **modelagem dimensional** | **Data Vault** = camada de integração/raw (Hubs, Links, Satellites) | **Dimensional** = camada de apresentação/BI (fatos + dims). São *complementares*, não concorrentes |
| **Hub** vs **Link** vs **Satellite** | **Hub** = chave de negócio, **Link** = relacionamento, **Satellite** = histórico descritivo | Não confunda Hub (ID da entidade) com Satellite (atributos) |
| **Managed Iceberg** vs **unmanaged Iceberg** | **Managed** = Snowflake controla metadados + DML completo | **Unmanaged** = catálogo externo (Glue, Polaris) controla metadados, somente leitura do Snowflake |
| **Time Travel** vs **Fail-safe** | **Time Travel** = acessível pelo usuário, 0-90 dias, consulta/restauração via SQL | **Fail-safe** = apenas Suporte Snowflake, 7 dias APÓS Time Travel expirar |
| **Clone** vs **réplica** | **Clone** = snapshot zero-copy *dentro* da mesma conta, objeto independente | **Réplica** = cópia assíncrona para *outra* conta/região para DR |
| **Tabela permanent** vs **transient** | **Permanent** = Time Travel completo + Fail-safe de 7 dias | **Transient** = máximo 1 dia de Time Travel, **zero** Fail-safe |
| **Tabela temporary** vs **transient** | **Temporary** = escopo de sessão, desaparece quando a sessão termina | **Transient** = persiste entre sessões, apenas sem Fail-safe |
| **Secure view** vs **standard view** | **Secure** = esconde definição + barreira de otimizador (mais lenta) | **Standard** = definição visível, otimizador completo (mais rápida) |
| **Materialized view** vs **dynamic table** | **MV** = mantida automaticamente, sem joins/UDFs permitidos | **Dynamic table** = mais flexível (joins OK), baseada em target lag, substitui stream+task |
| **Hybrid table** vs **tabela regular** | **Hybrid** = orientada a linhas, PK/FK/UNIQUE aplicadas, buscas pontuais rápidas (OLTP) | **Regular** = colunar, sem constraints aplicadas (OLAP) |
| **Replicação de banco de dados** vs **failover group** | **Replicação de DB** = um banco de dados copiado para secundário | **Failover group** = conjunto de DBs + objetos de conta que fazem failover juntos |
| **UNDROP** vs **Time Travel AT** | **UNDROP** = restaura um objeto *descartado* | **AT/BEFORE** = consulta/restaura dados em um *ponto no tempo* (objeto ainda existe) |
| **Client redirect** vs **DNS failover** | **Client redirect** = **objeto Connection** do Snowflake, rota automática para primário ativo | NÃO é DNS genérico — requer configuração explícita do Snowflake |

---

## ÁRVORES DE DECISÃO DE CENÁRIOS — Arquitetura de Dados

**Cenário 1: "Mais de 20 sistemas fonte, esquemas mudam mensalmente, precisa de trilha de auditoria completa..."**
- **CORRETO:** **Data Vault** para a camada de integração (absorve mudanças nos Satellites)
- ARMADILHA: *"Star schema em dados brutos"* — **ERRADO**, star schema é frágil com mudanças frequentes de esquema

**Cenário 2: "Equipe de BI precisa de dashboards rápidos em dados estáveis e bem compreendidos..."**
- **CORRETO:** **Star schema** para a camada de apresentação/consumo
- ARMADILHA: *"Data Vault diretamente para BI"* — **ERRADO**, queries de Data Vault são complexas; construa star schemas por cima

**Cenário 3: "Precisa de dados em formato aberto para Spark e Snowflake lerem/escreverem..."**
- **CORRETO:** **Managed Iceberg table** com external volume (Snowflake escreve formato Iceberg, Spark lê os mesmos arquivos)
- ARMADILHA: *"Tabela externa"* — **ERRADO**, tabelas externas são somente leitura e não produzem formato Iceberg

**Cenário 4: "Tabelas de staging guardam dados temporários de ETL — minimizar custos de armazenamento..."**
- **CORRETO:** **Tabelas transient** (sem Fail-safe = menor custo de armazenamento)
- ARMADILHA: *"Tabelas temporary"* — **ERRADO**, tabelas temporary têm escopo de sessão e desaparecem quando a sessão termina; não adequadas para ETL multi-sessão

**Cenário 5: "Analista acidentalmente deletou 1M de linhas da produção 2 horas atrás..."**
- **CORRETO:** **Time Travel** — `INSERT INTO prod SELECT * FROM prod AT(OFFSET => -7200)` ou `CREATE TABLE restore CLONE prod AT(...)`
- ARMADILHA: *"Contactar Suporte Snowflake para Fail-safe"* — **ERRADO**, Fail-safe é apenas após Time Travel expirar; 2 horas atrás está dentro do Time Travel

**Cenário 6: "Precisa de DR em uma região de nuvem diferente com < 5 min de RTO para conexões de app..."**
- **CORRETO:** **Failover group** (DB + objetos de conta) + **client redirect** (objeto Connection)
- ARMADILHA: *"Replicação de banco de dados sozinha"* — **ERRADO**, replicação de DB não cobre roles/usuários/policies, e sem redirecionamento automático sem objetos Connection

**Cenário 7: "Impedir que donos individuais de tabelas em produção concedam acesso às suas tabelas..."**
- **CORRETO:** **Managed access schema** — centraliza controle de concessões no dono do schema
- ARMADILHA: *"Apenas usar RBAC cuidadosamente"* — **ERRADO**, sem managed access, qualquer dono de objeto pode conceder privilégios

**Cenário 8: "Dados compartilhados com consumidores externos — deve esconder definição da query..."**
- **CORRETO:** **Secure views** (esconde definição, previne bypass de predicate pushdown)
- ARMADILHA: *"Standard views com row access policies"* — **ERRADO**, standard views expõem a definição SQL para consumidores

**Cenário 9: "Precisa de uma tabela resumo pré-computada que atualiza automaticamente, agregação simples, sem joins..."**
- **CORRETO:** **Materialized view** (mantida automaticamente, ótima para agregações simples)
- ARMADILHA: *"Dynamic table"* — não é errado em si, mas MV é mais simples e mais eficiente para agregações de tabela única sem joins

**Cenário 10: "Aplicação precisa de buscas rápidas por linha única por primary key + joins com tabelas de analytics..."**
- **CORRETO:** **Hybrid table** (orientada a linhas, PK aplicada, leituras pontuais rápidas)
- ARMADILHA: *"Tabela Snowflake regular com clustering na PK"* — **ERRADO**, armazenamento colunar não é otimizado para buscas por linha única

**Cenário 11: "Cluster Spark possui o catálogo Iceberg (AWS Glue), Snowflake precisa ler..."**
- **CORRETO:** **Unmanaged (catalog-linked) Iceberg table** com integração de catálogo Glue
- ARMADILHA: *"Managed Iceberg table"* — **ERRADO**, managed significa que Snowflake assume a propriedade do catálogo, conflitando com Spark

**Cenário 12: "Clonar produção para dev para testes sem dobrar armazenamento..."**
- **CORRETO:** **Zero-copy clone** (`CREATE DATABASE dev CLONE prod`)
- ARMADILHA: *"CTAS de todas as tabelas para novo banco de dados"* — **ERRADO**, CTAS copia todos os dados imediatamente, dobrando armazenamento

---

## FLASHCARDS -- Domínio 2

**Q1:** Quais são os três tipos de entidade principais no Data Vault?
**A1:** Hubs (chaves de negócio), Links (relacionamentos), Satellites (atributos descritivos + histórico).

**Q2:** Qual é a retenção máxima de Time Travel na edição Enterprise?
**A2:** 90 dias.

**Q3:** Tabelas transient têm Fail-safe?
**A3:** Não. Zero Fail-safe.

**Q4:** Materialized views podem incluir joins?
**A4:** Não. MVs não podem incluir joins, UDFs ou subqueries.

**Q5:** O que é zero-copy cloning?
**A5:** Criar uma cópia de um objeto que compartilha o armazenamento subjacente até os dados divergirem. Sem armazenamento adicional no momento da clonagem.

**Q6:** Qual é a diferença entre managed e unmanaged Iceberg tables?
**A6:** Managed: Snowflake controla metadados + dados, DML completo. Unmanaged: catálogo externo gerencia metadados, limitado/somente leitura do Snowflake.

**Q7:** Quais objetos um failover group pode conter?
**A7:** Databases, shares, users, roles, warehouses, integrations, network policies e outros objetos de conta.

**Q8:** Como funciona UNDROP se você descarta e recria uma tabela com o mesmo nome?
**A8:** UNDROP usa versionamento interno — restaura a versão descartada mais recentemente, não a atual.

**Q9:** O que torna hybrid tables diferentes de tabelas regulares?
**A9:** Armazenamento orientado a linhas, constraints aplicadas (PK, FK, UNIQUE), buscas pontuais rápidas — projetadas para OLTP.

**Q10:** Replicação é síncrona ou assíncrona?
**A10:** Assíncrona. A atualidade dos dados depende da frequência de refresh.

**Q11:** O que é um managed access schema?
**A11:** Um schema onde apenas o dono do schema (ou detentor de MANAGE GRANTS) pode conceder privilégios em objetos — donos individuais de objetos não podem.

**Q12:** Qual é o overhead de armazenamento do Fail-safe?
**A12:** Até 7 dias de dados históricos além do Time Travel, apenas para tabelas permanent.

**Q13:** Você pode replicar entre provedores de nuvem?
**A13:** Sim, desde que ambas as contas estejam na mesma Organization.

**Q14:** O que uma secure view esconde?
**A14:** Sua definição de query e previne que o otimizador empurre predicados além da barreira da view.

**Q15:** O que é client redirect?
**A15:** Um objeto Connection que roteia automaticamente clientes para a conta primária ativa durante failover.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS -- Domínio 2

**1. Data Vault**
Imagine que você tem uma caixa para o nome de cada amigo (Hub), um barbante conectando amigos que brincaram juntos (Link), e post-its descrevendo o que aconteceu em cada brincadeira (Satellite). Você nunca joga nada fora — só adiciona mais post-its!

**2. Star Schema**
Sua coleção de brinquedos: o grande baú de brinquedos no meio tem todas as suas sessões de brincadeira (tabela fato). Em volta estão prateleiras etiquetadas "brinquedos", "amigos", "dias da semana" (tabelas dimensão). Fácil de encontrar "com qual brinquedo eu brinquei na terça?"

**3. Time Travel**
Seu botão mágico de desfazer. Derramou tinta no seu desenho? Pressione desfazer e volte para antes do derramamento. Funciona por até 90 dias!

**4. Fail-safe**
Mesmo depois que seu botão de desfazer para de funcionar, seus pais guardaram uma cópia secreta dos seus desenhos em uma gaveta trancada. Você não pode abrir sozinho, mas eles podem ajudar se algo realmente ruim acontecer.

**5. Zero-Copy Cloning**
Como tirar uma foto do seu castelo de LEGO. A foto não usa peças de LEGO extras. Mas se você mudar o castelo original, apenas as partes alteradas precisam de peças extras.

**6. Tabelas Transient vs Permanent**
Tabelas permanent são como seu brinquedo favorito guardado para sempre com seguro (Fail-safe). Tabelas transient são como castelos de areia — eles existem, mas sem seguro se a maré chegar.

**7. Managed Iceberg Tables**
Você constrói com LEGO, mas usa o sistema de conector universal de LEGO para que seu amigo com uma marca diferente de LEGO também possa conectar ao seu castelo. Snowflake gerencia a construção, mas qualquer um pode ler as instruções.

**8. Secure Views**
Uma janela mágica onde você pode ver o jardim mas não pode ver como a janela foi construída. Pessoas diferentes olhando pela mesma janela podem ver flores diferentes (filtradas!).

**9. Replicação**
Como ter um backup do seu save de jogo favorito em um pendrive na casa da vovó. Se seu computador quebrar, a vovó tem o save. Não está totalmente atualizado, mas quase.

**10. Client Redirect**
Como uma caixa de correio que te segue. Se você muda de casa, a caixa de correio automaticamente vai para sua nova casa, e as cartas de todo mundo ainda chegam sem eles saberem que você mudou.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 'es',
  '# Dominio 2: Arquitectura de Datos

> **Cobertura del Temario ARA-C01:** Modelado de Datos, Jerarquía de Objetos, Recuperación de Datos

---

## 2.1 MODELADO DE DATOS

**Data Vault**

- Tres tipos de entidades principales: **Hubs** (business keys), **Links** (relaciones), **Satellites** (atributos descriptivos + historial)
- Diseñado para auditabilidad, flexibilidad y carga en paralelo
- Los hash keys permiten carga paralela basada solo en inserciones
- Ideal para: data warehouses empresariales con muchos sistemas fuente, schemas que evolucionan, requisitos de auditoría
- Desventaja: consultas más complejas, requiere modeladores experimentados

**Star Schema**

- **Fact table** central (medidas/métricas) rodeada de **dimension tables** (contexto descriptivo)
- Dimensiones desnormalizadas = lecturas rápidas, joins simples
- Ideal para: BI/analítica, dashboards, patrones de consulta conocidos
- Desventaja: el ETL es más difícil (se deben mantener las dimensiones desnormalizadas), menos flexible a cambios de schema

**Snowflake Schema**

- Similar al star schema pero las dimensiones están normalizadas (divididas en sub-dimensiones)
- Ej., `product_dim` → `category_dim` → `department_dim`
- Ideal para: ahorrar almacenamiento, reducir redundancia en dimensiones grandes
- Desventaja: más joins = consultas más lentas, más complejo para los analistas

**Cuándo usar cada uno**

| Modelo | Usar cuando... |
|---|---|
| Data Vault | Muchas fuentes, necesitas trazabilidad de auditoría, el schema cambia frecuentemente |
| Star | Schema estable, uso intensivo de BI, el rendimiento de consultas es prioridad |
| Snowflake | Dimensiones grandes con alta redundancia, el almacenamiento importa |
| Flat/OBT | Analítica simple, fuente única, mínimos joins necesarios |

### Por qué es importante
Una empresa de medios ingesta datos de más de 20 plataformas de anuncios. Los schemas cambian mensualmente. Data Vault absorbe los cambios en los Satellites sin romper los Hubs/Links. La capa de BI usa star schemas construidos encima.

### Mejores prácticas
- Usa Data Vault para la capa raw/integración, star schema para la capa de presentación
- Aprovecha la elasticidad de cómputo de Snowflake — los ahorros de almacenamiento del snowflake schema rara vez justifican la complejidad de las consultas
- Documenta los business keys y la granularidad de cada fact table

**Trampa del examen:** SI VES "star schema is best for audit trails" → INCORRECTO porque Data Vault está diseñado para auditabilidad.

**Trampa del examen:** SI VES "snowflake schema is the default recommendation for Snowflake the product" → INCORRECTO porque la coincidencia en el nombre es casual. Star schema es más común para analítica.

**Trampa del examen:** SI VES "Data Vault replaces dimensional modeling" → INCORRECTO porque Data Vault es para la capa de integración; aún se construyen star schemas encima para consumo.

### Preguntas frecuentes (FAQ)
**P: ¿Se puede usar star schema directamente sobre datos raw?**
R: Se puede, pero es frágil. Los cambios en los sistemas fuente rompen el modelo. Es mejor pasar por staging/integración primero.

**P: ¿Snowflake impone algún estándar de modelado?**
R: No. Snowflake es agnóstico al schema. Tú eliges el modelo que se adapte a tus necesidades.


### Ejemplos de Preguntas de Escenario — Data Modeling

**Escenario:** A media conglomerate acquires 5 companies, each with different source systems (SAP, Salesforce, custom APIs, flat files). Schemas change frequently due to ongoing integrations. The CFO needs a unified financial reporting layer for quarterly earnings. What data modeling approach should the architect recommend?
**Respuesta:** Use Data Vault for the integration/raw layer. Hubs capture core business entities (customer, account, transaction) via hash keys, Links capture relationships, and Satellites absorb schema changes without breaking existing structures. Each acquired company''s data feeds into the same Hub/Link structure with separate Satellites tracking the source history. On top of the Data Vault layer, build star schemas for the presentation/consumption layer — the CFO''s reporting team queries denormalized fact and dimension tables optimized for BI dashboards. This two-layer approach absorbs ongoing schema changes in the Data Vault while delivering stable, fast analytics in the star layer.

**Escenario:** A startup with a single Postgres source and 10 analysts wants fast dashboards. They have a small team with no Data Vault experience. The data schema is stable and changes rarely. What modeling approach fits best?
**Respuesta:** Star schema directly on the curated/presentation layer. With a single stable source, the complexity of Data Vault is unnecessary overhead. Build fact tables for core business events (orders, sessions, payments) surrounded by denormalized dimension tables (customers, products, dates). Star schema provides the simplest joins for BI tools like Tableau or Looker. Since Snowflake''s elastic compute handles joins efficiently, the query performance benefits of denormalized dimensions outweigh the minimal storage savings of a normalized snowflake schema.

---

---

## 2.2 JERARQUÍA DE OBJETOS

**Estructura de arriba hacia abajo**

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

**Puntos clave**

- Todo vive dentro de un namespace `DATABASE.SCHEMA`
- Algunos objetos son a nivel de cuenta: warehouses, usuarios, roles, resource monitors, network policies, integraciones, shares
- Los stages pueden ser a nivel de tabla (`@%my_table`), a nivel de schema (`@my_stage`), o a nivel de usuario (`@~`)
- Managed access schemas: solo el propietario del schema (o quien tenga MANAGE GRANTS) puede otorgar privilegios — impide que los propietarios de objetos otorguen acceso de manera independiente

### Por qué es importante
Un equipo de plataforma de datos necesita evitar que los propietarios individuales de tablas otorguen SELECT a roles arbitrarios. Los managed access schemas centralizan el control de grants.

### Mejores prácticas
- Usa managed access schemas en producción
- Organiza los schemas por dominio o capa de datos (raw, curado, presentación)
- Nombra los objetos de manera consistente: `<dominio>_<entidad>_<sufijo>` (ej., `sales_orders_fact`)
- Mantén los objetos a nivel de cuenta (warehouses, roles) bien documentados

**Trampa del examen:** SI VES "warehouses belong to a database" → INCORRECTO porque los warehouses son objetos a nivel de cuenta.

**Trampa del examen:** SI VES "managed access schemas prevent the schema owner from granting" → INCORRECTO porque el propietario del schema SÍ PUEDE otorgar permisos en managed access schemas — la restricción es sobre los propietarios de objetos que no son el propietario del schema.

**Trampa del examen:** SI VES "network policies are database-level objects" → INCORRECTO porque son a nivel de cuenta.

### Preguntas frecuentes (FAQ)
**P: ¿Cuál es la diferencia entre `@~` y `@%table`?**
R: `@~` es el stage de usuario (uno por usuario). `@%table` es el stage de tabla (uno por tabla). Ambos son internos, pero con alcance diferente.

**P: ¿Se puede tener un schema sin una base de datos?**
R: No. Los schemas siempre viven dentro de una base de datos.


### Ejemplos de Preguntas de Escenario — Object Hierarchy

**Escenario:** A production data platform has 200 tables owned by different teams (marketing, finance, engineering). The security team discovers that individual table owners have been granting SELECT on their tables to unapproved roles, bypassing the central governance model. How should the architect prevent this?
**Respuesta:** Convert production schemas to managed access schemas using `ALTER SCHEMA ... ENABLE MANAGED ACCESS`. In a managed access schema, only the schema owner or roles with the MANAGE GRANTS privilege can issue GRANT statements on objects within the schema. Individual table owners lose the ability to grant access independently. This centralizes privilege management without requiring any changes to the object ownership model or existing data pipelines.

**Escenario:** An architect is designing the schema layout for a new analytics platform. They need separate layers for raw ingestion, cleaned/curated data, and presentation-ready datasets. Some objects (warehouses, resource monitors, network policies) need to be shared across all layers. How should this be organized?
**Respuesta:** Create a single database (or one per domain) with three schemas: `RAW`, `CURATED`, and `PRESENTATION`. Each schema represents a data layer with its own access controls. Warehouses, resource monitors, network policies, users, and roles are account-level objects — they exist outside the database hierarchy and are shared across all schemas automatically. Use managed access schemas for `CURATED` and `PRESENTATION` to enforce centralized grant control. Name objects consistently with domain prefixes (e.g., `sales_orders_fact`) for discoverability.

---

---

## 2.3 TIPOS DE TABLAS Y VISTAS

**Tipos de tablas**

| Tipo | Time Travel | Fail-safe | Persiste después de la sesión | Clonable |
|---|---|---|---|---|
| **Permanent** | 0-90 días (Enterprise) | 7 días | Sí | Sí |
| **Transient** | 0-1 día | Ninguno | Sí | Sí |
| **Temporary** | 0-1 día | Ninguno | No (alcance de sesión) | Sí (dentro de la sesión) |
| **External** | No | No | Sí (solo metadata) | No |
| **Dynamic** | 0-90 días | 7 días | Sí | No |

- **Transient:** úsalas para tablas de staging/ETL donde no necesitas Fail-safe (ahorra costos de almacenamiento)
- **Temporary:** úsalas para resultados intermedios con alcance de sesión
- **External:** capa de metadata sobre archivos en almacenamiento externo — solo lectura
- **Dynamic:** se actualizan automáticamente basándose en una consulta y un target lag

**Iceberg Tables**

- **Managed (administrada por Snowflake):** Snowflake administra la metadata de Iceberg + los archivos de datos
  - Soporte completo de DML (INSERT, UPDATE, DELETE, MERGE)
  - Snowflake maneja la compactación y la gestión de snapshots
  - Se almacenan en almacenamiento administrado por Snowflake o en un external volume del cliente
- **Unmanaged (administrada externamente / catalog-linked):** un catálogo externo (AWS Glue, Polaris) administra la metadata
  - Solo lectura desde Snowflake (o escritura limitada dependiendo del catálogo)
  - Snowflake lee la metadata de Iceberg para consultar los datos
  - Úsalas para acceso multi-motor (Spark + Snowflake sobre los mismos datos)

**Hybrid Tables**

- Diseñadas para cargas de trabajo transaccionales (OLTP) dentro de Snowflake
- Soportan búsquedas rápidas de una sola fila, índices e integridad referencial (PRIMARY KEY, FOREIGN KEY, UNIQUE enforced)
- Almacenadas en formato orientado a filas para lecturas de baja latencia por punto
- Caso de uso: datos operacionales que también necesitan unirse con datos analíticos

**Tipos de vistas**

| Tipo | ¿Materializada? | ¿Segura? | Notas |
|---|---|---|---|
| Vista estándar | No | No | Solo una consulta guardada |
| Secure view | No | Sí | Oculta la definición, barrera del optimizador |
| Materialized view | Sí | No | Pre-calculada, mantenida automáticamente |
| Secure materialized view | Sí | Sí | Ambos beneficios |

- **Secure views:** la definición de la consulta se oculta de los consumidores, el optimizador no puede empujar predicados más allá del límite de la vista
- **Materialized views:** ideales para agregaciones costosas sobre datos grandes que cambian con poca frecuencia
- Las materialized views tienen limitaciones: no permiten joins, UDFs ni subqueries en su definición

### Por qué es importante
Un marketplace de datos comparte datos mediante secure views — los consumidores no pueden ver la lógica de la consulta subyacente ni eludir la seguridad a nivel de fila.

### Mejores prácticas
- Usa tablas transient para datos de staging (evita costos innecesarios de Fail-safe)
- Usa dynamic tables en lugar de pipelines complejos de task/stream donde sea posible
- Usa secure views para todos los objetos compartidos
- Considera tablas managed Iceberg cuando necesites interoperabilidad en formato abierto

**Trampa del examen:** SI VES "transient tables have 7 days of Fail-safe" → INCORRECTO porque las tablas transient tienen cero Fail-safe.

**Trampa del examen:** SI VES "temporary tables persist after the session ends" → INCORRECTO porque se eliminan cuando la sesión termina.

**Trampa del examen:** SI VES "materialized views support joins" → INCORRECTO porque las definiciones de MVs no pueden incluir joins.

**Trampa del examen:** SI VES "hybrid tables use columnar storage" → INCORRECTO porque usan almacenamiento orientado a filas para búsquedas rápidas por punto.

**Trampa del examen:** SI VES "external tables support DML" → INCORRECTO porque las tablas externas son de solo lectura.

### Preguntas frecuentes (FAQ)
**P: ¿Se puede convertir una tabla permanent a transient?**
R: No directamente. Debes crear una nueva tabla transient y copiar los datos (o usar CTAS).

**P: ¿Las secure views tienen un costo de rendimiento?**
R: Sí. La barrera del optimizador impide algunas optimizaciones, por lo que las secure views pueden ser más lentas que las vistas estándar.

**P: ¿Cuándo usaría una tabla managed Iceberg en vez de una tabla regular de Snowflake?**
R: Cuando necesitas que los datos estén en formato abierto Iceberg para acceso multi-motor y al mismo tiempo tener DML completo de Snowflake.


### Ejemplos de Preguntas de Escenario — Table Types & Views

**Escenario:** A data platform team runs multi-step ETL pipelines that produce intermediate staging tables. These tables are recreated every run and don''t need historical recovery. Storage costs are a concern because the staging data is 50 TB and growing. What table types should the architect use?
**Respuesta:** Use transient tables for all staging/intermediate tables. Transient tables have zero Fail-safe storage (saving 7 days worth of historical data storage per table) and a maximum of 1-day Time Travel. Since these tables are recreated every run, the 7-day Fail-safe of permanent tables provides no value but adds significant storage cost at 50 TB scale. For truly session-scoped scratch work within a single ETL step, temporary tables are even lighter (dropped when the session ends).

**Escenario:** A company runs both Snowflake and Apache Spark. The data science team uses Spark for ML training on feature tables, while the analytics team queries the same tables from Snowflake. Currently, data is duplicated — a Snowflake copy and a Parquet copy in S3. How should the architect eliminate the duplication?
**Respuesta:** Migrate the feature tables to managed Iceberg tables with an external volume pointing to S3. Snowflake manages the table lifecycle (writes, compaction, snapshots) and produces Iceberg-formatted data files and metadata in S3. Spark reads the same Iceberg metadata and data files directly — no duplication. Snowflake retains full DML (INSERT, UPDATE, DELETE, MERGE) support, Time Travel, and clustering. The data science team accesses the same data from Spark without any data movement or copy.

**Escenario:** A data marketplace needs to share pre-aggregated sales metrics with external consumers. The underlying query logic is proprietary. Consumers should not see the SQL definition or be able to bypass row-level security through optimizer tricks. What view type should the architect use?
**Respuesta:** Use secure views (or secure materialized views for expensive aggregations). Secure views hide the view definition from consumers and impose an optimizer fence that prevents predicate pushdown past the view boundary — this stops consumers from inferring hidden data through clever filtering. For the data marketplace use case, all shared objects should use secure views as a baseline. Note that secure views have a minor performance cost due to the optimizer fence, but this is an acceptable trade-off for data protection in a sharing context.

---

---

## 2.4 RECUPERACIÓN DE DATOS

**Time Travel**

- Consulta o restaura datos tal como existían en cualquier punto dentro del período de retención
- Métodos: `AT` / `BEFORE` con `TIMESTAMP`, `OFFSET`, o `STATEMENT` (query ID)
- Retención: 0-1 día (Standard), 0-90 días (Enterprise+)
- Funciona en tablas, schemas y bases de datos
- Tiene costo de almacenamiento por los datos modificados/eliminados

**Fail-safe**

- Período de 7 días DESPUÉS de que Time Travel expire
- NO es accesible por el usuario — solo el Soporte de Snowflake puede recuperar datos
- Solo para tablas permanent (no transient, temporary ni external)
- Existe como último recurso para escenarios catastróficos

**UNDROP**

- Restaura el objeto eliminado más recientemente: `UNDROP TABLE`, `UNDROP SCHEMA`, `UNDROP DATABASE`
- Usa datos de Time Travel internamente
- Si eliminas y recreas un objeto con el mismo nombre, el anterior sigue siendo recuperable con UNDROP (usa versionado interno)

**Zero-Copy Cloning para respaldos**

- `CREATE TABLE backup_table CLONE source_table`
- Sin almacenamiento adicional hasta que los datos divergen
- Los clones heredan la configuración de Time Travel de la fuente
- Soporta clonado de bases de datos y schemas (clonado recursivo de todos los hijos)
- Los clones son independientes — los cambios en el clon no afectan a la fuente

**Replicación para DR**

- Replicación de base de datos: copia asíncrona de una base de datos a otra cuenta/región
- Replicación de cuenta: replica usuarios, roles, warehouses, políticas
- Failover groups: conjunto de objetos replicados que pueden hacer failover juntos
- El RPO depende de la frecuencia de replicación; el RTO es el tiempo para promover el secundario

### Por qué es importante
Un analista ejecuta accidentalmente `DELETE FROM production_table`. Con 90 días de Time Travel, el equipo de datos restaura la tabla a 5 minutos antes del borrado. Sin cintas de respaldo, sin tiempo de inactividad.

### Mejores prácticas
- Configura 90 días de Time Travel en tablas críticas de producción (requiere Enterprise)
- Usa tablas transient para staging para evitar costos de almacenamiento de Fail-safe
- Clona producción a dev/test en lugar de copiar datos
- Configura replicación para bases de datos de misión crítica hacia una región secundaria
- Prueba tus procedimientos de recuperación regularmente

**Trampa del examen:** SI VES "Fail-safe data can be recovered by users via SQL" → INCORRECTO porque solo el Soporte de Snowflake puede recuperar datos de Fail-safe.

**Trampa del examen:** SI VES "Time Travel retention can be set to 90 days on Standard edition" → INCORRECTO porque Standard edition máximo es 1 día.

**Trampa del examen:** SI VES "cloning a table doubles storage immediately" → INCORRECTO porque el clonado es zero-copy; el almacenamiento solo crece cuando los datos divergen.

**Trampa del examen:** SI VES "UNDROP works on transient tables after Fail-safe" → INCORRECTO porque las tablas transient no tienen Fail-safe, y UNDROP solo funciona durante el período de Time Travel.

### Preguntas frecuentes (FAQ)
**P: Si configuro Time Travel en 0, ¿todavía puedo usar UNDROP?**
R: No. UNDROP depende de los datos de Time Travel. Con retención en 0, los datos desaparecen inmediatamente.

**P: ¿El clonado copia los grants?**
R: Al clonar bases de datos/schemas, los grants de los objetos hijos se copian. Los clones a nivel de tabla no copian los grants por defecto (a menos que uses `COPY GRANTS`).

**P: ¿Se puede replicar a un proveedor de nube diferente?**
R: Sí. La replicación cross-cloud es soportada (ej., AWS a Azure), pero ambas cuentas deben estar en la misma Organization.


### Ejemplos de Preguntas de Escenario — Data Recovery

**Escenario:** A junior engineer accidentally runs `TRUNCATE TABLE customers` on the production database containing 500M rows. The team discovers the mistake 3 hours later. The account is on Enterprise edition with the default 1-day Time Travel retention. How should the architect recover the data?
**Respuesta:** Use Time Travel to restore the data. Since only 3 hours have passed and the table has at least 1-day Time Travel, the data is fully recoverable. Option 1: `CREATE TABLE customers_restored CLONE customers BEFORE(STATEMENT => ''<truncate_query_id>'')` to create a point-in-time clone, then swap the tables. Option 2: `INSERT INTO customers SELECT * FROM customers BEFORE(OFFSET => -10800)` to repopulate from the 3-hour-ago snapshot. Going forward, the architect should set `DATA_RETENTION_TIME_IN_DAYS = 90` on all critical production tables (Enterprise edition supports up to 90 days) and set `MIN_DATA_RETENTION_TIME_IN_DAYS` at the account level to prevent anyone from reducing it.

**Escenario:** A data platform team needs to provide fresh copies of the 200 TB production database to 5 development teams daily for testing. Full data copies would cost 1 PB of storage. How should the architect handle this efficiently?
**Respuesta:** Use zero-copy cloning: `CREATE DATABASE dev_team_1 CLONE production`. Each clone initially shares all underlying micro-partitions with production — zero additional storage. Storage only grows as dev teams make changes to their cloned data. Each morning, drop the previous day''s clones and create fresh ones. Clones inherit Time Travel settings from the source and are fully independent — dev team changes never affect production. This provides 5 teams with full production data at near-zero storage cost.

---

---

## 2.5 REPLICACIÓN Y FAILOVER

**Replicación de base de datos**

- Replica una base de datos desde la cuenta primaria a una o más cuentas secundarias
- La secundaria es de solo lectura hasta que se promueve (o hasta el failover)
- La replicación es asíncrona — la frescura de los datos depende del calendario de refresco
- La replicación inicial copia todos los datos; las posteriores son incrementales (solo cambios)

**Replicación de cuenta**

- Replica objetos a nivel de cuenta: usuarios, roles, grants, warehouses, network policies, parámetros
- Esencial para un DR verdadero — la replicación de base de datos por sí sola no cubre el control de acceso
- Se combina con la replicación de base de datos en failover groups

**Failover Groups**

- Colección nombrada de objetos que pueden hacer failover como una unidad
- Tipos de objetos: bases de datos, shares, usuarios, roles, warehouses, integraciones, network policies
- Promoción de `PRIMARY` → `SECONDARY` mediante `ALTER FAILOVER GROUP ... PRIMARY`
- Solo un primario a la vez por failover group

**Cross-Region / Cross-Cloud**

- La replicación funciona entre regiones Y entre proveedores de nube
- Ambas cuentas deben estar en la misma Organization de Snowflake
- Considera las regulaciones de residencia de datos al replicar entre regiones
- Costos de replicación: transferencia de datos + cómputo para el refresco

**Client Redirect**

- URLs de conexión que redirigen automáticamente al primario activo
- Minimiza los cambios del lado del cliente durante el failover
- Usa objetos `CONNECTION`: `CREATE CONNECTION`, `ALTER CONNECTION ... PRIMARY`

### Por qué es importante
Una empresa fintech global ejecuta el primario en AWS US-East, el secundario en AWS EU-West. Si US-East cae, promueven EU-West en minutos. Client redirect significa que las aplicaciones no necesitan cambios de configuración.

### Mejores prácticas
- Usa failover groups (no replicación de base de datos independiente) para DR en producción
- Incluye objetos de cuenta en tu failover group para una recuperación completa
- Configura client redirect para minimizar el RTO del failover
- Monitorea el retraso de replicación mediante `REPLICATION_GROUP_REFRESH_HISTORY`
- Prueba el failover trimestralmente con simulacros reales de promoción/failback

**Trampa del examen:** SI VES "secondary databases are read-write" → INCORRECTO porque las bases de datos secundarias son de solo lectura hasta que se promueven a primarias.

**Trampa del examen:** SI VES "replication requires the same cloud provider" → INCORRECTO porque se soporta replicación cross-cloud.

**Trampa del examen:** SI VES "failover is automatic" → INCORRECTO porque el failover debe iniciarse manualmente (Snowflake no hace auto-failover).

**Trampa del examen:** SI VES "client redirect works without Connection objects" → INCORRECTO porque debes crear y configurar objetos Connection para client redirect.

### Preguntas frecuentes (FAQ)
**P: ¿Cuál es la diferencia entre replicación de base de datos y failover groups?**
R: La replicación de base de datos cubre una base de datos. Los failover groups agrupan múltiples bases de datos + objetos de cuenta para un failover coordinado.

**P: ¿Hay pérdida de datos durante el failover?**
R: Potencialmente, sí. RPO = tiempo desde el último refresco de replicación exitoso. Cualquier dato escrito después del último refresco no está en el secundario.

**P: ¿Se pueden tener múltiples failover groups?**
R: Sí. Puedes tener múltiples failover groups, cada uno conteniendo diferentes conjuntos de objetos. Cada objeto solo puede pertenecer a un failover group.


### Ejemplos de Preguntas de Escenario — Replication & Failover

**Escenario:** A global fintech company runs its primary Snowflake account in AWS US-East-1. Regulators require that the platform can recover from a full regional outage within 5 minutes (RTO) with no more than 15 minutes of data loss (RPO). Applications connect via JDBC using a single connection URL. How should the architect design the DR architecture?
**Respuesta:** Set up a failover group containing all critical databases plus account-level objects (users, roles, grants, warehouses, network policies, integrations). Replicate to a secondary account in AWS EU-West-1 (or another region) within the same Organization. Schedule replication refreshes every 10-15 minutes to meet the 15-minute RPO. Configure client redirect using a Connection object — applications connect to the Connection URL, which automatically routes to the active primary. During failover, promote the secondary via `ALTER FAILOVER GROUP ... PRIMARY` and update the Connection object. Apps automatically redirect to the new primary without configuration changes, meeting the 5-minute RTO. Test failover quarterly with real promote/failback drills.

**Escenario:** A company replicates its core database to a secondary account for DR, but during a failover drill, they discover that users cannot log in to the secondary account because roles, grants, and network policies were not replicated. What did the architect miss?
**Respuesta:** The architect used database replication alone instead of a failover group with account replication. Database replication only copies the database and its contents — it does not replicate account-level objects like users, roles, grants, warehouses, network policies, or integrations. The correct approach is to create a failover group that includes both the databases AND account-level objects. This ensures that when the secondary is promoted, all access controls, role hierarchies, and network policies are already in place. Always include account objects in failover groups for complete DR.

**Escenario:** An organization operates on AWS for its primary workloads but wants a secondary DR site on Azure for cloud-provider redundancy. Is this possible with Snowflake replication?
**Respuesta:** Yes. Snowflake supports cross-cloud replication — you can replicate from an AWS account to an Azure account (or GCP) as long as both accounts are in the same Snowflake Organization. The failover group mechanism works identically across cloud providers. However, the architect should account for cross-cloud data transfer costs, potential latency differences, and data residency regulations that may restrict which regions data can be replicated to. Monitor replication lag via `REPLICATION_GROUP_REFRESH_HISTORY` to ensure RPO targets are met despite cross-cloud overhead.

---

---

## PARES CONFUSOS — Arquitectura de Datos

| Preguntan sobre... | La respuesta es... | NO... |
|---|---|---|
| **Star schema** vs **snowflake schema** | **Star** = dimensiones desnormalizadas, menos joins, consultas rápidas | **Snowflake schema** = dimensiones normalizadas, más joins, ahorra almacenamiento pero más lento |
| **Data Vault** vs **dimensional modeling** | **Data Vault** = capa de integración/raw (Hubs, Links, Satellites) | **Dimensional** = capa de presentación/BI (facts + dims). Son *complementarios*, no competidores |
| **Hub** vs **Link** vs **Satellite** | **Hub** = business key, **Link** = relación, **Satellite** = historial descriptivo | No confundir Hub (ID de entidad) con Satellite (atributos) |
| **Managed Iceberg** vs **unmanaged Iceberg** | **Managed** = Snowflake controla metadata + DML completo | **Unmanaged** = catálogo externo (Glue, Polaris) controla metadata, solo lectura desde Snowflake |
| **Time Travel** vs **Fail-safe** | **Time Travel** = accesible por usuario, 0-90 días, consulta/restaura vía SQL | **Fail-safe** = solo Soporte de Snowflake, 7 días DESPUÉS de que Time Travel expire |
| **Clone** vs **replica** | **Clone** = snapshot zero-copy *dentro* de la misma cuenta, objeto independiente | **Replica** = copia asíncrona a *otra* cuenta/región para DR |
| **Permanent** vs **transient** table | **Permanent** = Time Travel completo + 7 días de Fail-safe | **Transient** = máximo 1 día de Time Travel, **cero** Fail-safe |
| **Temporary** vs **transient** table | **Temporary** = alcance de sesión, desaparece al terminar la sesión | **Transient** = persiste entre sesiones, solo sin Fail-safe |
| **Secure view** vs **standard view** | **Secure** = oculta definición + barrera del optimizador (más lento) | **Standard** = definición visible, optimizador completo (más rápido) |
| **Materialized view** vs **dynamic table** | **MV** = auto-mantenido, no permite joins/UDFs | **Dynamic table** = más flexible (joins OK), basado en target lag, reemplaza stream+task |
| **Hybrid table** vs **regular table** | **Hybrid** = orientado a filas, PK/FK/UNIQUE enforced, búsquedas rápidas por punto (OLTP) | **Regular** = columnar, sin constraints enforced (OLAP) |
| **Database replication** vs **failover group** | **DB replication** = una base de datos copiada a secundario | **Failover group** = conjunto de DBs + objetos de cuenta que hacen failover juntos |
| **UNDROP** vs **Time Travel AT** | **UNDROP** = restaura un objeto *eliminado* | **AT/BEFORE** = consulta/restaura datos en un *punto en el tiempo* (el objeto aún existe) |
| **Client redirect** vs **DNS failover** | **Client redirect** = objeto **Connection** de Snowflake, redirige automáticamente al primario activo | NO es DNS genérico — requiere configuración explícita de Snowflake |

---

## ÁRBOLES DE DECISIÓN POR ESCENARIO — Arquitectura de Datos

**Escenario 1: "20+ sistemas fuente, los schemas cambian mensualmente, necesitan trazabilidad completa de auditoría..."**
- **CORRECTO:** **Data Vault** para la capa de integración (absorbe cambios en Satellites)
- TRAMPA: *"Star schema on raw data"* — **INCORRECTO**, star schema es frágil con cambios frecuentes de schema

**Escenario 2: "El equipo de BI necesita dashboards rápidos sobre datos estables y bien entendidos..."**
- **CORRECTO:** **Star schema** para la capa de presentación/consumo
- TRAMPA: *"Data Vault directly for BI"* — **INCORRECTO**, las consultas de Data Vault son complejas; construye star schemas encima

**Escenario 3: "Necesitan datos en formato abierto para que Spark y Snowflake puedan leer/escribir..."**
- **CORRECTO:** **Managed Iceberg table** con external volume (Snowflake escribe en formato Iceberg, Spark lee los mismos archivos)
- TRAMPA: *"External table"* — **INCORRECTO**, las tablas externas son de solo lectura y no producen formato Iceberg

**Escenario 4: "Las tablas de staging contienen datos temporales de ETL — minimizar costos de almacenamiento..."**
- **CORRECTO:** **Transient tables** (sin Fail-safe = menor costo de almacenamiento)
- TRAMPA: *"Temporary tables"* — **INCORRECTO**, las tablas temporales tienen alcance de sesión y desaparecen al terminar; no son adecuadas para ETL multi-sesión

**Escenario 5: "Un analista eliminó accidentalmente 1M de filas de producción hace 2 horas..."**
- **CORRECTO:** **Time Travel** — `INSERT INTO prod SELECT * FROM prod AT(OFFSET => -7200)` o `CREATE TABLE restore CLONE prod AT(...)`
- TRAMPA: *"Contact Snowflake Support for Fail-safe"* — **INCORRECTO**, Fail-safe es solo después de que Time Travel expire; 2 horas atrás está dentro de Time Travel

**Escenario 6: "Necesitan DR a una región de nube diferente con < 5 min de RTO para conexiones de la app..."**
- **CORRECTO:** **Failover group** (DB + objetos de cuenta) + **client redirect** (objeto Connection)
- TRAMPA: *"Database replication alone"* — **INCORRECTO**, la replicación de DB no cubre roles/usuarios/políticas, y sin objetos Connection no hay redirección automática

**Escenario 7: "Evitar que los propietarios individuales de tablas en producción otorguen acceso a sus tablas..."**
- **CORRECTO:** **Managed access schema** — centraliza el control de grants al propietario del schema
- TRAMPA: *"Just use RBAC carefully"* — **INCORRECTO**, sin managed access, cualquier propietario de objeto puede otorgar privilegios

**Escenario 8: "Datos compartidos con consumidores externos — se debe ocultar la definición de la consulta..."**
- **CORRECTO:** **Secure views** (oculta definición, previene bypass de predicate pushdown)
- TRAMPA: *"Standard views with row access policies"* — **INCORRECTO**, las vistas estándar exponen la definición SQL a los consumidores

**Escenario 9: "Necesitan una tabla resumen pre-calculada que se auto-actualice, agregación simple, sin joins..."**
- **CORRECTO:** **Materialized view** (auto-mantenida, ideal para agregaciones simples)
- TRAMPA: *"Dynamic table"* — no es incorrecto per se, pero MV es más simple y eficiente para agregaciones de una sola tabla sin joins

**Escenario 10: "La aplicación necesita búsquedas rápidas de una sola fila por primary key + joins con tablas analíticas..."**
- **CORRECTO:** **Hybrid table** (orientado a filas, PK enforced, lecturas rápidas por punto)
- TRAMPA: *"Regular Snowflake table with clustering on PK"* — **INCORRECTO**, el almacenamiento columnar no está optimizado para búsquedas de una sola fila

**Escenario 11: "El clúster de Spark es dueño del catálogo Iceberg (AWS Glue), Snowflake necesita leerlo..."**
- **CORRECTO:** **Unmanaged (catalog-linked) Iceberg table** con integración de catálogo Glue
- TRAMPA: *"Managed Iceberg table"* — **INCORRECTO**, managed significa que Snowflake toma control del catálogo, entrando en conflicto con Spark

**Escenario 12: "Clonar producción a dev para pruebas sin duplicar el almacenamiento..."**
- **CORRECTO:** **Zero-copy clone** (`CREATE DATABASE dev CLONE prod`)
- TRAMPA: *"CTAS all tables into new database"* — **INCORRECTO**, CTAS copia todos los datos inmediatamente, duplicando el almacenamiento

---

## TARJETAS DE REPASO -- Dominio 2

**P1:** ¿Cuáles son los tres tipos de entidades principales en Data Vault?
**R1:** Hubs (business keys), Links (relaciones), Satellites (atributos descriptivos + historial).

**P2:** ¿Cuál es la retención máxima de Time Travel en Enterprise edition?
**R2:** 90 días.

**P3:** ¿Las tablas transient tienen Fail-safe?
**R3:** No. Cero Fail-safe.

**P4:** ¿Las materialized views pueden incluir joins?
**R4:** No. Las MVs no pueden incluir joins, UDFs ni subqueries.

**P5:** ¿Qué es zero-copy cloning?
**R5:** Crear una copia de un objeto que comparte el almacenamiento subyacente hasta que los datos divergen. Sin almacenamiento adicional al momento de clonar.

**P6:** ¿Cuál es la diferencia entre tablas Iceberg managed y unmanaged?
**R6:** Managed: Snowflake controla metadata + datos, DML completo. Unmanaged: catálogo externo maneja metadata, limitado/solo lectura desde Snowflake.

**P7:** ¿Qué objetos puede contener un failover group?
**R7:** Bases de datos, shares, usuarios, roles, warehouses, integraciones, network policies y otros objetos de cuenta.

**P8:** ¿Cómo funciona UNDROP si eliminas y recreas una tabla con el mismo nombre?
**R8:** UNDROP usa versionado interno — restaura la versión eliminada más reciente, no la actual.

**P9:** ¿Qué hace diferentes a las hybrid tables de las tablas regulares?
**R9:** Almacenamiento orientado a filas, constraints enforced (PK, FK, UNIQUE), búsquedas rápidas por punto — diseñadas para OLTP.

**P10:** ¿La replicación es síncrona o asíncrona?
**R10:** Asíncrona. La frescura de los datos depende de la frecuencia de refresco.

**P11:** ¿Qué es un managed access schema?
**R11:** Un schema donde solo el propietario del schema (o quien tenga MANAGE GRANTS) puede otorgar privilegios sobre objetos — los propietarios individuales de objetos no pueden.

**P12:** ¿Cuál es el costo de almacenamiento adicional de Fail-safe?
**R12:** Hasta 7 días de datos históricos más allá de Time Travel, solo para tablas permanentes.

**P13:** ¿Se puede replicar entre proveedores de nube?
**R13:** Sí, siempre que ambas cuentas estén en la misma Organization.

**P14:** ¿Qué oculta una secure view?
**R14:** Su definición de consulta y previene que el optimizador empuje predicados más allá del límite de la vista.

**P15:** ¿Qué es client redirect?
**R15:** Un objeto Connection que redirige automáticamente a los clientes a la cuenta primaria activa durante el failover.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS -- Dominio 2

**1. Data Vault**
Imagina que tienes una caja para el nombre de cada amigo (Hub), un hilo conectando a los amigos que jugaron juntos (Link), y notas adhesivas describiendo lo que pasó en cada cita de juegos (Satellite). ¡Nunca tiras nada — solo agregas más notas adhesivas!

**2. Star Schema**
Tu colección de juguetes: el gran cofre de juguetes en el centro tiene todas tus sesiones de juego (fact table). Alrededor hay estantes etiquetados "juguetes," "amigos," "días de la semana" (dimension tables). Fácil de encontrar "¿con qué juguete jugué el martes?"

**3. Time Travel**
Tu botón mágico de deshacer. ¿Derramaste pintura en tu dibujo? Presiona deshacer y regresa a antes del derrame. ¡Funciona hasta por 90 días!

**4. Fail-safe**
Incluso después de que tu botón de deshacer deja de funcionar, tus papás guardaron una copia secreta de tus dibujos en un cajón con llave. Tú no puedes abrirlo, pero ellos pueden ayudar si algo realmente malo pasa.

**5. Zero-Copy Cloning**
Como tomar una foto de tu castillo de LEGO. La foto no usa piezas extra. Pero si cambias el castillo original, solo las partes cambiadas necesitan piezas extra.

**6. Transient vs Permanent Tables**
Las tablas permanentes son como tu juguete favorito guardado para siempre con seguro (Fail-safe). Las tablas transient son como castillos de arena — existen, pero sin seguro si viene la marea.

**7. Managed Iceberg Tables**
Construyes con LEGO, pero usas el sistema de conector universal de LEGO para que tu amigo con una marca diferente de LEGO también pueda conectarse a tu castillo. Snowflake maneja la construcción, pero cualquiera puede leer las instrucciones.

**8. Secure Views**
Una ventana mágica donde puedes ver el jardín pero no puedes ver cómo se construyó la ventana. Diferentes personas mirando por la misma ventana podrían ver flores diferentes (¡filtradas!).

**9. Replication**
Como tener una copia de respaldo de tu archivo de guardado de juego favorito en una USB en casa de la abuela. Si tu computadora se rompe, la abuela tiene el archivo. No es exactamente al segundo, pero cercano.

**10. Client Redirect**
Como un buzón que te sigue. Si te mudas de casa, el buzón automáticamente va a tu nueva casa, y las cartas de todos siguen llegando sin que sepan que te mudaste.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 3.0: Data Engineering', 'en',
  '# Domain 3: Data Engineering

> **ARA-C01 Syllabus Coverage:** Data Loading/Unloading, Data Transformation, Ecosystem Tools

---

## 3.1 DATA LOADING

**COPY INTO (Bulk Loading)**

- Primary command for batch/bulk loading from stages into tables
- Supports: CSV, JSON, Avro, Parquet, ORC, XML
- Key options: `ON_ERROR`, `PURGE`, `FORCE`, `MATCH_BY_COLUMN_NAME`
- `VALIDATION_MODE` — dry-run to check data without loading
- Returns metadata: rows loaded, errors, file names
- Best for: scheduled batch loads, initial data migration, large files

**COPY INTO -- Deep Dive (Exam Details)**

- **Supported transformations during COPY:** Type casts (`col::INTEGER`), column reordering, column omitting (skip columns), loading a subset of columns. Does NOT support: subqueries, window functions, or joins during load.
- **VALIDATION_MODE values:** Three options: `RETURN_ERRORS` (return first error), `RETURN_ALL_ERRORS` (all errors), `RETURN_N_ROWS` (validate N rows). VALIDATION_MODE is **incompatible with transformations** -- you cannot use both. It does NOT load data, only validates.
- **FORCE=TRUE:** Reloads files that were already loaded (bypasses the 14-day dedup). Risk: **causes duplicate data** if the same file is loaded again.
- **LOAD_UNCERTAIN_FILES:** Reloads files whose metadata has expired (past the 14-day tracking window). Useful for recovering from missed loads.
- **Max files in discrete list:** The `FILES = (...)` parameter supports a maximum of **1000 files** per COPY INTO statement.
- **PURGE=TRUE:** Deletes staged files after successful load. Saves storage cost for large one-time migrations.
- **REMOVE from stage after load:** Removing processed files from the stage improves performance of subsequent COPY operations (fewer files for Snowflake to scan metadata for).
- **CURRENT_TIMESTAMP in COPY/Snowpipe:** Evaluated at load operation **compile time** in the cloud services layer, NOT at per-row insert time. All rows in the same COPY batch get the **same timestamp value**.
- **ON_ERROR options:** `CONTINUE` (skip bad rows, keep going), `SKIP_FILE` (skip entire file on error -- slower than CONTINUE), `ABORT_STATEMENT` (stop immediately). SKIP_FILE has performance overhead.
- **ERROR_ON_COLUMN_COUNT_MISMATCH:** When TRUE, rejects files where the number of columns doesn''t match the table. Default is FALSE (extra columns ignored for CSV).
- **MATCH_BY_COLUMN_NAME with CSV:** Works with CSV files only when headers are present. Matches by column name instead of position.
- **File unloading constraints:** Only CSV, JSON, and Parquet formats supported for COPY INTO location (unloading). Only **UTF-8 encoding**. Default `MAX_FILE_SIZE` = 16MB enables parallel unload.
- **AVRO compression:** Supports GZIP, ZSTD, AUTO. Does **NOT** support BZ2.
- **ON_ERROR = SKIP_FILE_n:** A variant of SKIP_FILE that skips the file only when the number of errors reaches `n` (e.g., `SKIP_FILE_3`). Useful for tolerating a small number of bad rows per file while rejecting badly corrupted files.
- **SKIP_FILE reload behavior:** When a file is skipped via `ON_ERROR = SKIP_FILE`, Snowflake marks it as **NOT loaded**. A subsequent `COPY INTO` (without FORCE) will automatically retry that file. You can also use `FILES = (''file5.csv'')` to target it explicitly.
- **S3 Glacier is NOT supported:** Snowpipe and COPY INTO cannot read files from S3 Glacier storage class. Files must be in standard S3 storage tiers.
- **Small file optimization:** Snowflake performs poorly with many tiny files. Best practice is to merge small files into **100-250 MB compressed** files before loading. If unavoidable, a multi-cluster warehouse can help parallelize the scan.
- **Loading ORDER BY for natural clustering:** When loading into reporting/analytics tables, use `ORDER BY <cluster_key_columns>` in the INSERT...SELECT or CTAS from staging. This produces naturally clustered micro-partitions, improving pruning without automatic reclustering cost.
- **Cross-database COPY requires qualified names:** When copying data across databases, use fully qualified names: `database.schema.table`. Unqualified names resolve against the current session context.
- **Pipe modification procedure:** To safely modify a Snowpipe definition: (1) Pause the pipe with `ALTER PIPE ... SET PIPE_EXECUTION_PAUSED = TRUE`, (2) Query `SYSTEM$PIPE_STATUS` and wait until `pendingFileCount` = 0, (3) Recreate the pipe with the new definition, (4) Verify cloud notification config is intact, (5) Resume the pipe.
- **Snowpipe does NOT support PURGE:** The `PURGE = TRUE` copy option is invalid in `CREATE PIPE`. To clean up staged files after Snowpipe loads them, run `REMOVE @stage` periodically as a separate task.
- **Transformations in CREATE PIPE AS COPY:** Supported: type casts (`$1::DATE`), column reordering, column omission. **NOT supported:** joins, subqueries, WHERE clause filtering, `ON_ERROR = ABORT_STATEMENT`, `FILES = (...)`, `PURGE`.
- **AWS vs GCS/Azure auto-ingest:** AWS auto-ingest requires `aws_sns_topic` in the pipe definition. GCS and Azure require an `INTEGRATION` parameter instead. The `INTEGRATION` parameter is only for GCS/Azure -- not AWS.
- **max_concurrency_level for Snowpark:** Set `ALTER WAREHOUSE ... SET MAX_CONCURRENCY_LEVEL = 1` to dedicate all warehouse resources to a single Snowpark stored procedure, maximizing memory and compute for resource-intensive operations.

**Exam trap:** IF YOU SEE "VALIDATION_MODE works with column transformations" → WRONG because VALIDATION_MODE is incompatible with COPY transformations.

**Exam trap:** IF YOU SEE "FORCE=TRUE is safe to use repeatedly" → WRONG because FORCE=TRUE bypasses dedup and will cause duplicate rows.

**Exam trap:** IF YOU SEE "CURRENT_TIMESTAMP in COPY is evaluated per-row" → WRONG because it''s evaluated once at compile time -- all rows get the same value.

**Exam trap:** IF YOU SEE "COPY INTO can unload to ORC or XML" → WRONG because unloading only supports CSV, JSON, and Parquet.

**Snowpipe (Continuous Loading)**

- Serverless, auto-ingest pipeline triggered by cloud events (S3 notifications, GCS Pub/Sub, Azure Event Grid)
- Near real-time (micro-batch, typically seconds to minutes latency)
- Uses a PIPE object: `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO ...`
- Billed per-second of serverless compute + file notification overhead
- Exactly-once semantics via file load metadata (14-day dedup window)

**Snowpipe REST API & Operational Details**

- **Snowpipe REST API endpoints:**

| Endpoint | Purpose | Key Limits |
|---|---|---|
| `insertFiles` | Submit files for loading | Max 5000 files per call, 1024 bytes max path length |
| `insertReport` | Check load status for recently submitted files | Max 10K events returned, 10-minute retention window |
| `loadHistoryScan` | Query historical load status | Rate-limited, returns HTTP 429 on overuse |

- **insertReport vs loadHistoryScan best practice:** Call `insertReport` every ~8 minutes with a 10-minute time range. Use `loadHistoryScan` only for historical investigation. Frequent `loadHistoryScan` calls trigger HTTP 429 rate limiting.
- **insertFiles 200 response:** A 200 HTTP response means the files are **queued**, NOT ingested. Actual loading happens asynchronously.
- **Snowpipe minimum privileges:** OWNERSHIP on the pipe (NOT USAGE), USAGE on the stage (NOT READ for external stages), USAGE on database/schema, INSERT + SELECT on the target table.
- **CREATE PIPE allowed copy options:** `SKIP_HEADER`, `STRIP_OUTER_ARRAY`, `FILE_FORMAT`. Does NOT support: `PURGE`, `FILES=`, `ON_ERROR=ABORT_STATEMENT`.
- **Cloud-specific requirements:** AWS auto-ingest needs `aws_sns_topic` in the pipe definition. GCS and Azure need an `INTEGRATION` parameter instead.
- **Paused pipe notification retention:** When a pipe is paused, event notification messages enter a **14-day limited retention**. After 14 days, messages are lost and must be re-sent.
- **SNS topic deletion impact:** If the AWS SNS topic is deleted, the pipe stops receiving notifications. Must recreate the pipe with a new SNS topic.
- **COPY_HISTORY retention:** Both COPY INTO and Snowpipe load history is available in INFORMATION_SCHEMA for **14 days**.
- **Cross-cloud ingestion:** Snowpipe REST API endpoint can ingest from any cloud (e.g., S3 files into a GCP Snowflake account) as long as the stage is accessible.

**Exam trap:** IF YOU SEE "Snowpipe needs USAGE privilege on the pipe" → WRONG because it needs OWNERSHIP on the pipe, not USAGE.

**Exam trap:** IF YOU SEE "insertFiles 200 means data is loaded" → WRONG because 200 means files are queued for loading, not yet ingested.

**Exam trap:** IF YOU SEE "PURGE can be used in CREATE PIPE" → WRONG because PURGE is not a valid copy option in pipe definitions.

**Snowpipe Streaming**

- Lowest latency option: rows land in seconds, no files involved
- Uses the Snowflake Ingest SDK (Java) — client calls `insertRows()`
- Data is written to a staging area, then automatically migrated to table storage
- No pipe object needed — uses `CHANNEL` objects
- Best for: IoT, clickstream, real-time event data
- Combines with Dynamic Tables for real-time transformation

**Schema Detection & Evolution**

- **Schema detection** (`INFER_SCHEMA`): automatically detect column names/types from staged files
  - Works with Parquet, Avro, ORC, CSV (with headers)
  - `SELECT * FROM TABLE(INFER_SCHEMA(LOCATION => ''@stage'', FILE_FORMAT => ''fmt''))`
  - Use with `CREATE TABLE ... USING TEMPLATE` for auto DDL
- **Schema evolution** (`ENABLE_SCHEMA_EVOLUTION = TRUE`): new columns in source files are automatically added to the table
  - Existing columns are NOT modified or removed
  - Requires file role to have EVOLVE SCHEMA privilege

### Why This Matters
A retail company gets 500 CSV files daily from stores. Snowpipe auto-ingests them as they land in S3. Schema evolution handles new columns (e.g., "loyalty_tier") without manual ALTER TABLE.

### Best Practices
- Use Snowpipe for steady, event-driven streams; COPY INTO for large scheduled batches
- Set `ON_ERROR = CONTINUE` for non-critical loads (with error monitoring)
- Enable schema evolution on staging tables to handle source schema changes
- Use `MATCH_BY_COLUMN_NAME` when source columns don''t match table order
- Monitor Snowpipe via `PIPE_USAGE_HISTORY` and `COPY_HISTORY`

**Exam trap:** IF YOU SEE "Snowpipe Streaming requires a PIPE object" → WRONG because Streaming uses CHANNELS, not pipes.

**Exam trap:** IF YOU SEE "COPY INTO automatically detects schema" → WRONG because you must explicitly use `INFER_SCHEMA` or `USING TEMPLATE`.

**Exam trap:** IF YOU SEE "schema evolution can remove columns" → WRONG because it only ADDS new columns; never removes or modifies existing ones.

**Exam trap:** IF YOU SEE "Snowpipe loads data synchronously" → WRONG because Snowpipe is asynchronous (serverless, event-driven).

### Common Questions (FAQ)
**Q: What''s the dedup window for Snowpipe?**
A: 14 days. Files loaded within the past 14 days won''t be re-loaded (based on file name + metadata).

**Q: Can I use Snowpipe with internal stages?**
A: Yes, but auto-ingest with cloud notifications only works with external stages. For internal stages, you call `insertFiles` REST API manually.

**Q: When should I use Snowpipe Streaming vs regular Snowpipe?**
A: Use Streaming when you need sub-second latency and are generating data programmatically (not files). Use regular Snowpipe when data arrives as files in cloud storage.

### Example Scenario Questions — Data Loading

**Scenario:** A retail chain has 2,000 stores, each uploading daily sales CSV files to S3 at unpredictable times throughout the day. The analytics team needs data available within 5 minutes of upload. Currently, a scheduled COPY INTO job runs hourly, causing up to 60 minutes of latency and occasionally missing late-arriving files. How should the architect redesign the ingestion?
**Answer:** Replace the scheduled COPY INTO with Snowpipe using auto-ingest. Configure S3 event notifications (SQS) on the bucket to trigger Snowpipe whenever a new file lands. Create a PIPE object with `AUTO_INGEST = TRUE` pointing to the S3 stage with the appropriate file format. Snowpipe processes files within seconds to minutes of arrival — well within the 5-minute SLA. It uses serverless compute (no dedicated warehouse), and the 14-day deduplication window prevents re-loading files. Enable schema evolution on the target table to handle any new columns stores may add over time.

**Scenario:** An IoT platform receives 50,000 sensor events per second from industrial equipment. Events must be queryable within 2 seconds for real-time monitoring dashboards. File-based ingestion cannot meet the latency requirement. What ingestion method should the architect use?
**Answer:** Use Snowpipe Streaming via the Snowflake Ingest SDK (Java). The application calls `insertRows()` to write events directly to Snowflake without creating intermediate files — achieving sub-second latency. Data lands in a staging area and is automatically migrated to table storage. No PIPE object is needed; the SDK uses CHANNEL objects. Combine Snowpipe Streaming with dynamic tables for real-time transformation — e.g., a dynamic table with a 1-minute target lag that aggregates raw sensor events into equipment health metrics for the monitoring dashboard.

**Scenario:** A data engineering team is onboarding a new data source that adds new columns to its JSON payloads every few weeks. They don''t want to manually ALTER TABLE each time. How should the architect configure the pipeline to handle this automatically?
**Answer:** Enable schema evolution on the target table: `ALTER TABLE ... SET ENABLE_SCHEMA_EVOLUTION = TRUE`. Use `MATCH_BY_COLUMN_NAME = ''CASE_INSENSITIVE''` in the COPY INTO or Snowpipe definition so that columns are matched by name rather than position. When new columns appear in the source files, Snowflake automatically adds them to the table. Existing columns are never modified or removed. The role running the load must have the EVOLVE SCHEMA privilege on the table. Use `INFER_SCHEMA` for the initial table creation to detect the starting schema from a sample file.

---

## 3.2 STAGES & FILE FORMATS

**Internal Stages**

- **User stage** (`@~`): one per user, cannot be altered or dropped
- **Table stage** (`@%table_name`): one per table, tied to that table
- **Named internal stage** (`@my_stage`): created explicitly, most flexible
- Data stored in Snowflake-managed storage, encrypted at rest

**External Stages**

- Point to cloud storage: S3, GCS, Azure Blob/ADLS
- Require a **storage integration** (best practice) or inline credentials (not recommended)
- Support folder paths: `@ext_stage/path/to/folder/`

**File Formats**

- Reusable format definitions: `CREATE FILE FORMAT`
- Types: CSV, JSON, AVRO, PARQUET, ORC, XML
- Key CSV options: `FIELD_DELIMITER`, `SKIP_HEADER`, `NULL_IF`, `ERROR_ON_COLUMN_COUNT_MISMATCH`
- Key JSON options: `STRIP_OUTER_ARRAY`, `STRIP_NULL_VALUES`
- Can be specified inline in COPY INTO or referenced by name

**Directory Tables**

- Metadata layer on a stage: `ALTER STAGE @my_stage SET DIRECTORY = (ENABLE = TRUE)`
- Lets you query file metadata (name, size, MD5, last_modified) via SQL
- Must be refreshed: `ALTER STAGE @my_stage REFRESH`
- Auto-refresh available for external stages with cloud notifications
- Useful for file inventory, tracking new arrivals, building processing pipelines

**Stages -- Deep Dive (Exam Details)**

- **File format specification precedence:** When loading, the format specified in COPY INTO > stage definition > table definition. Most specific wins.
- **PREVENT_UNLOAD_TO_INTERNAL_STAGES:** User-level parameter that prevents a user from unloading data to internal stages. Minimal administrative overhead for controlling data export.
- **GET command:** Used in SnowSQL to download files from internal stages to local machine. Syntax: `GET @stage/path file:///local/path`
- **Cross-cloud external stages:** An external stage can point to storage on a different cloud than your Snowflake account (e.g., GCS stage for an Azure Snowflake account).
- **Storage integration benefits:** No raw credentials in SQL. Uses IAM roles/service principals. One integration can serve multiple stages. Defines allowed/blocked storage locations.
- **PREVENT_UNLOAD_TO_INLINE_URL:** Account-level parameter. When set to `TRUE`, blocks COPY INTO unloads to URLs that are NOT backed by a named stage with a storage integration. Prevents users from exfiltrating data to arbitrary cloud URLs.
- **PREVENT_UNLOAD_TO_INTERNAL_STAGES:** User-level parameter. When `TRUE`, prevents the user from unloading data to internal stages. Set at the user level for least administrative overhead (not session level).
- **File format specification locations:** A file format can be set in three places: (1) `COPY INTO` statement, (2) `CREATE STAGE`, (3) `CREATE TABLE`. **Precedence:** COPY INTO > stage > table. Most specific wins.
- **Cross-cloud external stages and cost:** An external stage can point to storage on a different cloud than your Snowflake account (e.g., a GCS stage from an Azure Snowflake account). This works but incurs **cross-cloud data transfer fees**. Snowflake does not block it.
- **Storage integration for cross-region ingestion:** A storage integration allows connecting to external cloud storage regardless of the Snowflake account''s region. This enables multi-site companies to ingest from regional buckets into a single Snowflake account.

**Exam trap:** IF YOU SEE "PREVENT_UNLOAD_TO_INTERNAL_STAGES is a session parameter" → WRONG because it is a **user-level** parameter. Setting at user level provides least overhead.

### Why This Matters
A data lake has 2M Parquet files in S3. A directory table provides a queryable inventory without listing objects via AWS CLI. Combined with streams, you can detect new files automatically.

### Best Practices
- Always use storage integrations for external stages (no inline credentials)
- Use named internal stages over table/user stages for production workloads
- Define file formats as reusable objects, not inline specs
- Enable directory tables with auto-refresh for file-driven pipelines

**Exam trap:** IF YOU SEE "user stages can be shared across users" → WRONG because each user''s stage is private and scoped to that user.

**Exam trap:** IF YOU SEE "directory tables store the actual file data" → WRONG because they only store metadata about files.

**Exam trap:** IF YOU SEE "table stages support all stage features" → WRONG because table stages cannot have file formats, and have limited options vs named stages.

### Common Questions (FAQ)
**Q: Can I GRANT access to a user stage?**
A: No. User stages are per-user and cannot be granted to others.

**Q: Do directory tables work on internal stages?**
A: Yes, but auto-refresh is only available for external stages. Internal stages require manual `REFRESH`.

### Example Scenario Questions — Stages & File Formats

**Scenario:** A data lake has 2 million Parquet files in S3 across hundreds of folders. The data engineering team needs to track which files have been processed, identify new arrivals, and build processing pipelines based on file metadata (size, last modified date). Currently, they run AWS CLI `ls` commands which take 30+ minutes. How should the architect improve this?
**Answer:** Create an external stage pointing to the S3 bucket with a storage integration (no inline credentials). Enable a directory table on the stage: `ALTER STAGE @data_lake SET DIRECTORY = (ENABLE = TRUE)`. Configure auto-refresh with S3 event notifications so the directory table updates automatically when new files land. The team can now query file metadata (name, size, MD5, last_modified) via standard SQL in seconds instead of running CLI commands. Combine the directory table with a stream to detect new file arrivals and trigger processing tasks automatically.

**Scenario:** A security audit reveals that several external stages in production were created with inline AWS access keys embedded directly in the stage definition. How should the architect remediate this and prevent recurrence?
**Answer:** Recreate all external stages using storage integrations instead of inline credentials. A storage integration uses IAM roles (on AWS) or service principals (on Azure) — no raw credentials in SQL. After migrating all stages, set the account-level parameter `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` to prevent anyone from creating stages with inline credentials in the future. Rotate the compromised AWS access keys immediately. Use named internal stages over table/user stages for any internally-staged data in production.

---

## 3.3 STREAMS & TASKS

**Streams (Change Data Capture)**

- Track DML changes (INSERT, UPDATE, DELETE) on a source table
- Three types:
  - **Standard:** tracks all three DML types, uses hidden columns
  - **Append-only:** only tracks INSERTs (cheaper, simpler)
  - **Insert-only (on external tables):** tracks new files/rows on external tables
- Metadata columns: `METADATA$ACTION`, `METADATA$ISUPDATE`, `METADATA$ROW_ID`
- Stream is "consumed" when used in a DML transaction (advances the offset)
- A stream has a **staleness window** — if not consumed within the source table''s `DATA_RETENTION_TIME_IN_DAYS` + 14 days, it becomes stale and must be recreated

**Change Tracking**

- Alternative to streams: `ALTER TABLE ... SET CHANGE_TRACKING = TRUE`
- Query changes via `CHANGES` clause: `SELECT * FROM table CHANGES(INFORMATION => DEFAULT) AT(...)`
- Does not have a consumable offset — idempotent queries
- Useful for point-in-time change queries without a dedicated stream object

**Tasks**

- Scheduled SQL execution (standalone or in task trees/DAGs)
- Schedule via CRON expression or `SCHEDULE = ''N MINUTE''`
- Task trees: root task triggers children in dependency order
- Tasks use serverless compute by default (or a specified warehouse)
- Must be explicitly resumed: `ALTER TASK ... RESUME`
- `WHEN` clause: conditional execution (e.g., `WHEN SYSTEM$STREAM_HAS_DATA(''my_stream'')`)

**Task Trees (DAGs)**

- Root task → child tasks → grandchild tasks
- Only the root task has a schedule; children trigger automatically
- Finalizer task: runs after all tasks in the graph complete (success or failure)
- Use `ALLOW_OVERLAPPING_EXECUTION` to control concurrent runs

**Streams & Tasks -- Deep Dive (Exam Details)**

- **TASK_HISTORY function details:** Returns max 10K rows. Shows both completed AND currently running tasks. Covers 7 days of history + next 8 days of scheduled executions.
- **Task scheduling and daylight savings:** Tasks scheduled with UTC are immune to daylight savings changes. Tasks using local time zones may skip or double-execute during DST transitions.
- **Cloned tasks are always SUSPENDED:** When cloning a database or schema, all tasks in the clone are created in SUSPENDED state. Must manually resume each task.
- **Stream staleness extension:** Snowflake automatically extends the data retention period by 14 days beyond the table''s `DATA_RETENTION_TIME_IN_DAYS` for stream offset tracking. This is the "staleness window."
- **Change tracking features:** Both streams AND the `CHANGES` clause can track changes. Streams have a consumable offset; CHANGES clause is idempotent (same query always returns same results for a given time range).
- **Change tracking on views:** You can enable change tracking on views: `ALTER VIEW ... SET CHANGE_TRACKING = TRUE`. Streams can then be created on those views.
- **TASK_HISTORY two sources:** `TABLE(INFORMATION_SCHEMA.TASK_HISTORY())` for recent runs (7 days, max 10K rows). `ACCOUNT_USAGE.TASK_HISTORY` for up to **365 days** of history with 45-minute latency. Use `ERROR_ONLY => TRUE` to filter to only failed/cancelled tasks.
- **SYSTEM$STREAM_HAS_DATA evaluation:** This function runs in the **cloud services layer** (no warehouse compute). A warehouse with `AUTO_SUSPEND` will only start when the stream actually has data and the task body executes.
- **Append-only stream with TRUNCATE:** An append-only stream records ALL inserts regardless of subsequent TRUNCATE or DELETE operations. A standard stream shows the net result (TRUNCATE cancels prior inserts). This is a key behavioral difference tested on the exam.
- **Shareable objects in Data Sharing:** Tables, dynamic tables, external tables, Iceberg tables, secure views, secure materialized views, and secure UDFs can be shared. **NOT shareable:** standard views, stored procedures, streams, tasks, pipes.

**Exam trap:** IF YOU SEE "SYSTEM$STREAM_HAS_DATA requires warehouse compute" → WRONG because it evaluates in the cloud services layer at zero warehouse cost.

**Exam trap:** IF YOU SEE "Append-only streams lose data after TRUNCATE" → WRONG because append-only streams track ALL inserts regardless of subsequent TRUNCATE/DELETE.

**Cloning Impacts on Streams & Tasks**

- **Cloning pipes:** Only pipes referencing **external stages** are cloned. Internal stage pipes are NOT cloned.
- **Cloned privileges:** Child objects (tables, views) inherit their grants. The container (database, schema) does NOT inherit grants from the source.
- **Unconsumed stream records:** After cloning a database/schema, stream records that existed before the clone are **inaccessible** in the cloned version. The clone''s streams start fresh.

**Exam trap:** IF YOU SEE "cloned tasks are active by default" → WRONG because cloned tasks are always SUSPENDED and must be explicitly resumed.

### Why This Matters
An e-commerce platform uses a stream on `raw_orders` and a task that runs every 5 minutes. The task checks `SYSTEM$STREAM_HAS_DATA`, and if true, merges changes into `curated_orders`. CDC without a third-party tool.

### Best Practices
- Use `SYSTEM$STREAM_HAS_DATA` in task WHEN clause to avoid empty runs
- Set appropriate `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors
- Use serverless tasks unless you need to control the warehouse size
- Prefer dynamic tables over stream+task for pure transformation pipelines
- Monitor tasks via `TASK_HISTORY` in ACCOUNT_USAGE

**Exam trap:** IF YOU SEE "streams DON''T work on views" → WRONG because streams DO work on views. `CREATE STREAM ... ON VIEW <view_name>` is valid syntax and works on both regular views and secure views.

**Exam trap:** IF YOU SEE "child tasks can have their own schedule" → WRONG because only the root task has a schedule; children are triggered by parent completion.

**Exam trap:** IF YOU SEE "streams never become stale" → WRONG because a stream becomes stale if not consumed within the source''s Time Travel retention + 14 days.

**Exam trap:** IF YOU SEE "tasks are resumed by default after creation" → WRONG because tasks are created in SUSPENDED state and must be explicitly resumed.

### Common Questions (FAQ)
**Q: Can multiple streams exist on the same table?**
A: Yes. Each stream tracks independently with its own offset.

**Q: What happens if a stream goes stale?**
A: It becomes unusable. You must recreate it. The offset is lost, and you may need to do a full reload.

**Q: Can tasks call stored procedures?**
A: Yes. A task''s body can be any single SQL statement, including `CALL my_procedure()`.

### Example Scenario Questions — Streams & Tasks

**Scenario:** An e-commerce platform needs to merge incremental order updates (inserts, updates, deletes) from a raw orders table into a curated orders table every 5 minutes. The merge logic includes custom conflict resolution (e.g., latest timestamp wins for updates). What pipeline architecture should the architect use?
**Answer:** Create a standard stream on the raw orders table to capture all DML changes (inserts, updates, deletes). Create a task with a 5-minute schedule and a `WHEN SYSTEM$STREAM_HAS_DATA(''orders_stream'')` clause to avoid empty runs. The task body executes a MERGE statement that reads from the stream and applies custom conflict resolution logic (e.g., `WHEN MATCHED AND src.updated_at > tgt.updated_at THEN UPDATE`). Use serverless tasks unless the MERGE is complex enough to warrant a dedicated warehouse. Set `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors and monitor via `TASK_HISTORY`.

**Scenario:** A data platform has a complex ETL pipeline: raw data must be cleaned, then enriched with reference data, then aggregated into summary tables. Each step depends on the previous one completing successfully. If any step fails, a notification must be sent. How should the architect orchestrate this?
**Answer:** Build a task tree (DAG). The root task runs on a schedule and performs the cleaning step. A child task handles enrichment (triggered automatically on root success). A grandchild task handles aggregation. Add a finalizer task to the DAG — it runs after all tasks complete (whether they succeed or fail) and sends an email notification with the outcome. Only the root task has a schedule; children trigger on parent completion. Use `ALLOW_OVERLAPPING_EXECUTION = FALSE` on the root to prevent concurrent runs. Alternatively, if the pipeline is pure SQL transformations without custom merge logic, consider chaining dynamic tables instead — they handle scheduling and incremental refresh declaratively.

---

## 3.4 EXTERNAL & ICEBERG TABLES

**External Tables**

- Read-only table over files in external storage (S3, GCS, Azure)
- Snowflake stores only metadata; data stays in your cloud storage
- Supports auto-refresh of metadata via cloud notifications
- Query performance is slower than native tables (no clustering, no micro-partition optimization)
- Support for partitioning via `PARTITION BY` computed columns
- Streams on external tables: insert-only (tracks new files)

**External Tables -- Deep Dive (Exam Details)**

- **External table schema columns:** The schema includes: `VALUE` (VARIANT with row data), `METADATA$FILE_ROW_NUMBER`, `METADATA$FILENAME`. NOT valid: `METADATA$EXTERNAL_TABLE_PARTITION`, `METADATA$ROW_ID`.
- **Partition columns are virtual columns:** Defined using expressions computed from the file path (e.g., `PARTITION_DATE DATE AS TO_DATE(SPLIT_PART(METADATA$FILENAME, ''/'', 3))`). They are not stored in the data files -- they are derived at query time from the stage path structure.
- **Partitioning for performance:** The single most effective performance improvement for external tables is adding partition columns. This enables Snowflake to prune irrelevant files (partition pruning), processing only relevant subsets of data.
- **External table vs directory table:** External tables query file **contents** (actual data rows). Directory tables query file **metadata** (file name, size, last modified). They serve different purposes and are not interchangeable.
- **Search optimization on external tables:** Search optimization service can be applied to external tables to improve point lookup performance, especially on VARIANT columns containing semi-structured data.

**Managed Iceberg Tables**

- Snowflake manages the table lifecycle (write path, compaction, snapshots)
- External volume defines WHERE data is stored (your cloud storage)
- Full DML: INSERT, UPDATE, DELETE, MERGE
- Catalog integration not required (Snowflake is the catalog)
- Other engines can read the Iceberg metadata/data files
- Supports Time Travel, cloning, replication

**Unmanaged Iceberg Tables (Catalog-Linked)**

- External catalog (Glue, Polaris/OpenCatalog, Unity, REST) manages metadata
- Snowflake reads the catalog to understand table structure
- Read-only from Snowflake (writes go through the external engine)
- Requires CATALOG INTEGRATION object
- Auto-refresh detects catalog changes

**Incremental vs Full Refresh (Dynamic/Iceberg Context)**

- **Full refresh:** recompute entire dataset (expensive but simple)
- **Incremental refresh:** only process changed data (cheaper, requires change tracking)
- Dynamic tables use incremental refresh when possible (operator-dependent)
- Some operations force full refresh (e.g., non-deterministic functions, complex joins)

### Why This Matters
A company runs both Spark and Snowflake. Managed Iceberg tables let Snowflake write data in Iceberg format to S3. Spark reads the same files directly. One copy of data, two engines.

### Best Practices
- Use managed Iceberg for new "open format" requirements with Snowflake as primary engine
- Use unmanaged/catalog-linked for data owned by another engine (Spark, Trino)
- External tables are legacy for read-only access — prefer Iceberg for new projects
- Partition external tables by date/region for query pruning

**Exam trap:** IF YOU SEE "external tables support UPDATE/DELETE" → WRONG because external tables are read-only.

**Exam trap:** IF YOU SEE "unmanaged Iceberg tables support MERGE" → WRONG because writes must go through the external catalog/engine.

**Exam trap:** IF YOU SEE "managed Iceberg tables store data in Snowflake''s internal storage" → WRONG because they write to an external volume (your cloud storage) in Iceberg format.

**Exam trap:** IF YOU SEE "dynamic tables always use incremental refresh" → WRONG because certain operations force full refresh.

### Common Questions (FAQ)
**Q: Can I convert an external table to a native table?**
A: Not directly. You''d CTAS from the external table into a new native (or Iceberg) table.

**Q: Do managed Iceberg tables support clustering?**
A: Yes. You can define clustering keys on managed Iceberg tables.

**Q: What''s the difference between an external table and an unmanaged Iceberg table?**
A: External tables work on raw files (CSV, Parquet, etc.) with Snowflake-defined metadata. Unmanaged Iceberg tables read Iceberg-formatted tables managed by an external catalog with full Iceberg capabilities (snapshots, schema evolution).

### Example Scenario Questions — External & Iceberg Tables

**Scenario:** A company''s data science team uses Apache Spark on EMR to train ML models, and the analytics team uses Snowflake for reporting. Both teams need read/write access to the same feature store tables. Currently, data is duplicated in both Parquet files and Snowflake tables, causing consistency issues. How should the architect unify the data layer?
**Answer:** Migrate the feature store to managed Iceberg tables in Snowflake. Define an external volume pointing to S3 where the Iceberg data and metadata files will be stored. Snowflake manages the table lifecycle — full DML (INSERT, UPDATE, DELETE, MERGE), compaction, and snapshot management. The Spark team reads the same Iceberg metadata and data files from S3 directly using Spark''s Iceberg connector. One copy of data, two engines, full consistency. Managed Iceberg tables also support Time Travel and clustering for the Snowflake analytics team.

**Scenario:** A partner organization manages their data catalog in AWS Glue and writes Iceberg tables from their Spark pipelines. Your company needs to query this data from Snowflake without taking ownership of the catalog. How should the architect set this up?
**Answer:** Create an unmanaged (catalog-linked) Iceberg table in Snowflake. Configure a catalog integration pointing to the partner''s AWS Glue catalog. Snowflake reads the Glue-managed Iceberg metadata to understand the table structure and queries the data files directly from S3. This is read-only from Snowflake — all writes continue through the partner''s Spark pipelines. Enable auto-refresh on the catalog integration so Snowflake detects when the partner updates the table. Do not use a managed Iceberg table here, as that would transfer catalog ownership to Snowflake and conflict with the partner''s Spark writes.

---

## 3.5 DATA TRANSFORMATION

**FLATTEN**

- Converts semi-structured (JSON, ARRAY, VARIANT) data into rows
- Lateral join by default: `SELECT ... FROM table, LATERAL FLATTEN(input => col)`
- Key parameters: `INPUT`, `PATH`, `OUTER` (keep rows with empty arrays), `RECURSIVE`, `MODE`
- Output columns: `SEQ`, `KEY`, `PATH`, `INDEX`, `VALUE`, `THIS`

**UDFs (User-Defined Functions)**

- SQL, JavaScript, Python, Java, Scala
- Scalar UDFs: return one value per input row
- Must be deterministic for use in materialized views / clustering
- Secure UDFs: hide function body from consumers

**UDTFs (User-Defined Table Functions)**

- Return a table (multiple rows per input row)
- Must implement: `PROCESS()` (per-row logic) and optionally `END_PARTITION()` (final output)
- Called with `TABLE()` in FROM clause
- Useful for: parsing, exploding, custom aggregation

**External Functions**

- Call external API endpoints (e.g., AWS Lambda, Azure Functions) from SQL
- Requires: API integration + external function definition
- Synchronous: Snowflake calls the API per batch and waits
- Use for: ML inference, third-party enrichment, custom logic not in Snowflake
- Being replaced by container-based UDFs (SPCS) for new use cases

**External Functions & Parsing -- Deep Dive (Exam Details)**

- **External function requirements:** Must use HTTPS endpoints. Input/output is JSON format. Returns scalar values only (one output per input row).
- **External function costs:** Data transfer charges (data leaves Snowflake to the API) + warehouse compute for the calling query. The external API provider (Lambda, Azure Functions) may also charge independently.
- **External function limitations:** Cannot be stored procedures (only functions). Must return a scalar value (one per input row). Cannot return multiple values. Future grants on external functions are NOT supported.
- **External function batch processing:** Snowflake sends rows in batches to the remote service. The remote service must accept JSON arrays and return JSON arrays of the same length. Batch size is controlled by Snowflake automatically.
- **TRY_PARSE_JSON vs PARSE_JSON:** `TRY_PARSE_JSON` returns NULL on parse failure. `PARSE_JSON` throws an error. Use TRY_ variant for defensive parsing of untrusted data.
- **Stored procedure CALLER vs OWNER rights:** `CALLER` rights = procedure runs with the **invoker''s** privileges (good for dynamic, user-context-dependent operations). `OWNER` rights = procedure runs with the **definer''s** privileges (good for elevated-privilege admin tasks). CALLER rights cannot access objects the caller doesn''t have privileges on. OWNER rights can access objects the owner has privileges on regardless of the caller.
- **Task + UDTF pattern:** For automated pipelines that require import, join, and aggregation across multiple file types (e.g., Parquet + CSV), use a scheduled task that calls a Tabular UDF (UDTF). Materialized views cannot perform joins, so a UDTF is the correct choice for producing joined/aggregated results.
- **Resource monitors for pipeline cost control:** Resource monitors can be applied to warehouses running data pipelines. They monitor credit consumption and can suspend the warehouse or send notifications when thresholds are reached. They do NOT prevent duplicate data or limit concurrent queries.

**Stored Procedures**

- Can contain control flow (IF, LOOP, BEGIN/END), multiple SQL statements
- Languages: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Can run with CALLER rights or OWNER rights
- Use for: admin tasks, complex ETL, multi-step operations
- Key difference from UDFs: procedures can have side effects (DML), UDFs cannot

**Dynamic Tables**

- Declarative transformation: define the target as a SQL query + target lag
- Snowflake automatically refreshes (incremental when possible)
- Replace complex stream+task chains for transformation pipelines
- Target lag: `DOWNSTREAM` (cascade from upstream DTs) or explicit interval
- Streams on dynamic tables are supported (since 2024) for change tracking on dynamic table output

**Secure Functions**

- UDFs/UDTFs with `SECURE` keyword: body is hidden from consumers
- Required for functions used in Secure Data Sharing
- Same optimizer fence as secure views

### Why This Matters
A pipeline flattens raw JSON events, enriches them via an external function (ML scoring), and lands results in a dynamic table with 5-minute target lag. Zero task/stream management.

### Best Practices
- Prefer dynamic tables over stream+task for transformation-only pipelines
- Use SQL UDFs for simple calculations; Python UDFs for complex logic
- Minimize external function calls (network overhead per batch)
- Use stored procedures for administrative workflows, not data transformation
- Set dynamic table target lag based on business SLA, not as low as possible

**Exam trap:** IF YOU SEE "UDFs can execute DML statements" → WRONG because UDFs are read-only; only stored procedures can execute DML.

**Exam trap:** IF YOU SEE "dynamic tables cannot be sources for streams" → WRONG because streams on dynamic tables have been supported since 2024. You CAN create streams on dynamic tables for change tracking.

**Exam trap:** IF YOU SEE "external functions run inside Snowflake compute" → WRONG because they call an external API endpoint outside Snowflake.

**Exam trap:** IF YOU SEE "FLATTEN only works with JSON" → WRONG because FLATTEN works with any semi-structured type: VARIANT, ARRAY, OBJECT.

### Common Questions (FAQ)
**Q: Can I use Python UDFs in materialized views?**
A: No. MVs only support SQL expressions (no UDFs, no external functions).

**Q: What''s the difference between target lag DOWNSTREAM and a specific interval?**
A: DOWNSTREAM means "refresh whenever my upstream dynamic table refreshes." A specific interval (e.g., 5 MINUTES) means "ensure data is no older than 5 minutes."

**Q: Can dynamic tables reference other dynamic tables?**
A: Yes. This creates a dynamic table pipeline (DAG), where upstream refreshes cascade downstream.

### Example Scenario Questions — Data Transformation

**Scenario:** A data platform ingests raw JSON events with deeply nested arrays (e.g., an order contains an array of items, each item contains an array of discounts). The analytics team needs a flat, relational table with one row per discount. Some orders have no discounts and must still appear in the output. How should the architect design the transformation?
**Answer:** Use nested LATERAL FLATTEN to expand the multi-level arrays. First FLATTEN the items array, then FLATTEN the discounts array within each item. Use `OUTER => TRUE` on the discounts FLATTEN to preserve orders/items that have empty discount arrays (they appear as NULL discount rows instead of being dropped). The query pattern: `SELECT ... FROM orders, LATERAL FLATTEN(INPUT => items, OUTER => TRUE) AS i, LATERAL FLATTEN(INPUT => i.VALUE:discounts, OUTER => TRUE) AS d`. Materialize this as a dynamic table with an appropriate target lag so the flat table stays current as new events arrive.

**Scenario:** A company has a complex transformation pipeline: raw → cleaned → enriched → aggregated. Currently this is managed with 4 stream+task pairs, and the team spends significant time debugging task failures, managing stream staleness, and handling scheduling edge cases. How should the architect simplify this?
**Answer:** Replace the stream+task chain with a pipeline of dynamic tables. Define each layer as a dynamic table with a SQL query referencing the previous layer: `raw_dt → cleaned_dt → enriched_dt → aggregated_dt`. Set target lag based on business SLAs — the final aggregated table might use `TARGET_LAG = ''5 MINUTES''` while intermediate tables use `TARGET_LAG = DOWNSTREAM` (refresh when downstream needs data). Snowflake handles scheduling, incremental refresh, and error management declaratively. This eliminates manual stream offset management, task scheduling, and staleness risks. Note: dynamic tables work best for pure SQL transformations; if you need custom merge logic or procedural control flow, stream+task remains appropriate.

**Scenario:** The data engineering team needs a stored procedure that loops through all databases in the account, creates a governance tag on each, and grants APPLY TAG privileges to a specific role. A junior engineer asks why they can''t use a UDF for this. What should the architect explain?
**Answer:** UDFs cannot execute DML or DDL statements — they are read-only functions usable in SELECT. This task requires DDL (`CREATE TAG`) and DCL (`GRANT`) operations, which only stored procedures can perform. Create a stored procedure using Snowflake Scripting (SQL) with a RESULTSET cursor to iterate over `SHOW DATABASES`, then execute `CREATE TAG IF NOT EXISTS` and `GRANT APPLY TAG` for each database. The procedure should run with CALLER rights so it executes under the invoking role''s permissions, ensuring proper authorization checks.

---

## 3.6 KAFKA CONNECTOR

**Kafka Connector for Snowflake:**
- Streams data from Apache Kafka topics into Snowflake tables
- **Auto-creates objects:** For each topic, the connector creates: a target table, an internal stage, and a pipe (one pipe per partition)
- **Table columns:** Two VARIANT columns: `RECORD_CONTENT` (the message payload) and `RECORD_METADATA` (offset, partition, topic, timestamp)
- **Supported formats:** JSON and Avro **only** (no CSV, no Parquet, no ORC)
- **Authentication:** Uses **2048-bit RSA key pair** (same as key-pair auth for service accounts). Does NOT support OAuth or basic username/password.
- **Failed file handling:** Failed files are moved to the **table stage** for the target table (not user stage, not deleted)
- **Cost optimization:** Increase `buffer.flush.time` to batch more records per flush, reducing the number of pipe ingestion operations. Higher flush time = lower cost but higher latency.
- **Required privileges:** The connector''s role needs: CREATE TABLE, CREATE STAGE, CREATE PIPE on the target schema
- **Two ingestion modes:** Snowpipe-based (files to internal stage, then pipe loads them) and Snowpipe Streaming-based (direct row insert, lower latency, no intermediate files)
- **Auto-table creation from unmapped topics:** If the connector subscribes to topics not explicitly mapped to tables, it auto-creates a table using the topic name and adds the standard two VARIANT columns.
- **Dropping Kafka connector pipes:** Use standard `DROP PIPE <pipe_name>` syntax. There is no special Kafka-specific command.
- **Default Kafka topic retention:** Kafka''s default is **7 days** (not 14). This is a Kafka setting, not a Snowflake setting.

**Exam trap:** IF YOU SEE "Kafka connector supports CSV format" → WRONG because only JSON and Avro are supported.

**Exam trap:** IF YOU SEE "Kafka connector creates one pipe per topic" → WRONG because it creates one pipe per PARTITION within each topic.

**Exam trap:** IF YOU SEE "RECORD_CONTENT is a VARCHAR column" → WRONG because both RECORD_CONTENT and RECORD_METADATA are VARIANT columns.

**Exam trap:** IF YOU SEE "Kafka connector uses OAuth authentication" → WRONG because it uses key pair authentication with a 2048-bit RSA minimum.

**Exam trap:** IF YOU SEE "Failed Kafka files are deleted" → WRONG because failed files are moved to the table stage associated with the target table.

---

## 3.7 ECOSYSTEM CONNECTIVITY

**SQL REST API:**
- No client installation required -- call Snowflake from any HTTP client
- Supports: read (SELECT) and write (INSERT, UPDATE, DELETE) operations
- Supports ROLLBACK and multiple SQL statements in a single API call
- Supports asynchronous execution
- Does NOT support: PUT or GET commands (file staging)

**Spark Connector transfer modes:**
- **Internal mode:** Snowflake manages a temporary storage location for data transfer between Spark and Snowflake
- **External mode:** User provides their own cloud storage location for the transfer
- Internal mode is simpler; external mode gives more control over intermediate data

**dbt with Snowflake:**
- dbt handles the **T in ELT** -- transformation and testing only
- Does NOT handle data loading or replication
- Use dbt for: testing data quality, building transformation models, documentation
- Not a replacement for Snowpipe, COPY INTO, or replication

**Data Vault 2.0 patterns in Snowflake:**
- **Multi-table INSERT:** Enables parallel loading of hubs and satellites from a single staging table in one statement
- **HASH_DIFF:** Used for satellite change detection (compare current vs new record hash). Note: it''s `HASH_DIFF`, NOT "HASH_DELTA"
- SHA2-512 recommended for hash keys to minimize collision risk

**ELT vs ETL decision framework:**

| Factor | ELT (preferred in Snowflake) | ETL |
|---|---|---|
| Scalability | Higher -- uses Snowflake compute for transforms | Lower -- transform engine is a bottleneck |
| Error recovery | Easier -- raw data is in Snowflake, re-transform | Harder -- must reload from source |
| Flexibility | High -- change transforms without reloading | Low -- transform logic baked into pipeline |
| When to use | Most Snowflake workloads | When source data requires pre-processing before loading |

Note: COPY INTO DOES support some inline transformations (type cast, column subset), blurring the ELT/ETL boundary.

**Transaction behavior in Snowflake:**
- DDL statements **implicitly commit** any active transaction (auto-commit on DDL)
- `BEGIN TRANSACTION` / `BEGIN WORK` starts an explicit transaction
- `COMMIT WORK` / `ROLLBACK WORK` ends it
- AUTOCOMMIT cannot be changed inside a stored procedure
- Explicit transactions should contain only DML and query statements. DDL (CREATE, ALTER, DROP) will auto-commit the transaction prematurely.

**Connectivity decision guide:**

| Need | Use | Why NOT the others |
|---|---|---|
| No software installation on app server | **SQL REST API** | JDBC, ODBC, SnowSQL all require client installation |
| File download from internal stage | **GET command in SnowSQL** | GET is not available in Snowsight Worksheets or via SQL REST API |
| Stateless serverless functions (Lambda) | **SQL REST API** | JDBC/ODBC connection pooling is impractical in short-lived functions |
| Existing Spark infrastructure | **Spark Connector** | Snowpark requires rewriting; Spark connector integrates natively |
| All compute inside Snowflake | **Snowpark** | Python connector pulls data out; Snowpark keeps it in Snowflake |

**Continuous ELT pipeline components:** A typical continuous ELT pipeline uses Snowpipe (ingestion) + Streams (CDC) + Tasks (scheduling) + Stored Procedures/Dynamic Tables (transformation). **Data Exchange is NOT a pipeline component** -- it is for data collaboration and sharing between accounts.

**Exam trap:** IF YOU SEE "SQL REST API supports PUT/GET" → WRONG because PUT and GET (file staging commands) are not supported via the REST API.

**Exam trap:** IF YOU SEE "dbt handles data loading into Snowflake" → WRONG because dbt only handles transformation and testing, not loading.

---

## 3.8 ECOSYSTEM TOOLS

**Kafka Connector**

- Streams data from Kafka topics into Snowflake tables
- Two versions: **Snowpipe-based** (files to stage, then COPY) and **Snowpipe Streaming** (direct row insert, lower latency)
- Supports exactly-once semantics
- Handles schema evolution (new fields in JSON)
- Managed by Snowflake or self-hosted

**Spark Connector**

- Bi-directional: read from and write to Snowflake from Spark
- Pushes queries down to Snowflake when possible (predicate pushdown)
- Supports DataFrame API and SQL
- Key config: `sfURL`, `sfUser`, `sfPassword`, `sfDatabase`, `sfSchema`, `sfWarehouse`

**Python Connector**

- Native Python library (`snowflake-connector-python`)
- Supports `write_pandas()` for bulk DataFrame uploads
- Integrates with SQLAlchemy
- Async query support for long-running queries
- `snowflake-snowpark-python` — DataFrame API that runs on Snowflake compute

**JDBC / ODBC**

- Standard database connectivity for Java (JDBC) and other languages (ODBC)
- Snowflake provides its own JDBC and ODBC drivers
- Support all standard SQL operations
- Used by most BI tools (Tableau, Power BI, Looker)

**SQL API (REST)**

- HTTP REST endpoint for executing SQL
- Submit statements, check status, retrieve results via REST calls
- Uses OAuth or key-pair tokens for authentication
- Async execution: submit → poll status → fetch results
- Useful for serverless architectures, microservices

**Snowpark**

- Developer framework for Python, Java, Scala
- DataFrame API that executes on Snowflake''s compute (no data movement)
- Supports UDFs, UDTFs, and stored procedures
- Ideal for ML pipelines, complex transformations
- Lazy evaluation: operations build a plan, execute on `.collect()` or action

### Why This Matters
A data platform uses Kafka connector for real-time ingestion, Snowpark for ML feature engineering, and JDBC for BI tools. The architect must know which connector fits each use case.

### Best Practices
- Use Kafka connector with Snowpipe Streaming for lowest latency
- Use Snowpark instead of extracting data to Python/Spark when possible (compute stays in Snowflake)
- Use SQL API for lightweight integrations and serverless apps
- Always use the latest Snowflake-provided drivers (updated frequently)
- Use key-pair auth for all programmatic/service connections

**Exam trap:** IF YOU SEE "the Spark connector always moves all data to Spark" → WRONG because it supports predicate pushdown, pushing filters to Snowflake.

**Exam trap:** IF YOU SEE "SQL API is synchronous only" → WRONG because it supports async execution (submit → poll → fetch).

**Exam trap:** IF YOU SEE "Snowpark requires data to be extracted from Snowflake" → WRONG because Snowpark runs on Snowflake compute; data stays in Snowflake.

**Exam trap:** IF YOU SEE "the Kafka connector only supports JSON" → WRONG because it supports both JSON and Avro formats.

### Common Questions (FAQ)
**Q: When should I use the Spark connector vs Snowpark?**
A: Use Spark connector when you already have Spark infrastructure and need to integrate Snowflake into existing pipelines. Use Snowpark when you want to run all compute in Snowflake without a Spark cluster.

**Q: Can the SQL API handle large result sets?**
A: Yes, via result set pagination. Large results are returned in partitions that you fetch incrementally.

**Q: Does the Kafka connector support schema evolution?**
A: Yes. New fields in JSON payloads are loaded into the VARIANT column. If you use schema evolution on the target table, columns are auto-added.

### Example Scenario Questions — Ecosystem Tools

**Scenario:** A company has an existing Spark-based ML pipeline on Databricks that processes 500 GB of features daily. They''re migrating analytics to Snowflake but don''t want to rewrite the Spark pipeline. The Spark pipeline needs to read from and write to Snowflake tables. How should the architect integrate the two systems?
**Answer:** Use the Snowflake Spark connector. Configure it with the Snowflake connection parameters (`sfURL`, `sfUser`, `sfWarehouse`, etc.) and use key-pair authentication for the service account. The Spark connector supports bidirectional data movement and pushes predicates down to Snowflake when reading (minimizing data transfer). For the longer-term, evaluate migrating the ML pipeline to Snowpark — which runs the DataFrame API directly on Snowflake compute without moving data out. But for immediate integration without rewriting, the Spark connector is the correct choice.

**Scenario:** A microservices architecture on AWS Lambda needs to execute Snowflake queries. The Lambda functions are stateless, short-lived, and cannot maintain persistent database connections. What connectivity approach should the architect recommend?
**Answer:** Use the Snowflake SQL API (REST). Lambda functions submit SQL statements via HTTP POST, then poll for status and fetch results asynchronously. The SQL API supports OAuth or key-pair tokens for authentication — no persistent database connections needed. This fits the stateless, ephemeral nature of Lambda. For larger result sets, the API returns paginated results that Lambda can fetch incrementally. Avoid JDBC/ODBC in Lambda since connection pooling is impractical in short-lived serverless functions.

**Scenario:** A data science team currently extracts 100 GB of data from Snowflake to their local Python environment using the Python connector and pandas for feature engineering. The extraction takes 45 minutes and overwhelms local memory. How should the architect improve this workflow?
**Answer:** Migrate the feature engineering logic to Snowpark. Snowpark provides a pandas-like DataFrame API that executes directly on Snowflake''s compute — no data extraction needed. The data stays in Snowflake, operations are lazily evaluated and pushed down to the warehouse, and results are only materialized on `.collect()` or when writing to a table. This eliminates the 45-minute extraction, local memory constraints, and data movement costs. Snowpark supports Python UDFs and stored procedures for complex ML logic that can''t be expressed in SQL.

---

## CONFUSING PAIRS — Data Engineering

| They ask about... | The answer is... | NOT... |
|---|---|---|
| **Snowpipe** vs **COPY INTO** | **Snowpipe** = serverless, event-driven, continuous (files trigger load) | **COPY INTO** = manual/scheduled batch command, you run it explicitly |
| **Snowpipe** vs **Snowpipe Streaming** | **Snowpipe** = file-based (cloud notifications → micro-batch) | **Streaming** = row-based (Ingest SDK, no files, sub-second latency) |
| **PIPE object** vs **CHANNEL object** | **PIPE** = used by regular Snowpipe (`CREATE PIPE`) | **CHANNEL** = used by Snowpipe Streaming (Ingest SDK, no PIPE needed) |
| **Stream** vs **Task** | **Stream** = CDC tracker (records changes on a table) | **Task** = scheduled SQL executor (cron/interval). They''re *partners*, not substitutes |
| **Standard stream** vs **append-only stream** | **Standard** = tracks INSERT + UPDATE + DELETE | **Append-only** = tracks only INSERTs (cheaper, simpler) |
| **External table** vs **Iceberg table** | **External** = raw files (CSV, Parquet), read-only, Snowflake metadata | **Iceberg** = Iceberg-format, managed = full DML, unmanaged = catalog-linked |
| **Schema detection** vs **schema evolution** | **Detection** (`INFER_SCHEMA`) = reads file to discover columns *once* | **Evolution** = auto-adds new columns to table *ongoing* as source changes |
| **UDF** vs **UDTF** | **UDF** = one value per row (scalar) | **UDTF** = multiple rows per input (table function, uses PROCESS + END_PARTITION) |
| **UDF** vs **stored procedure** | **UDF** = read-only, no side effects, usable in SELECT | **Procedure** = can do DML, control flow, side effects, called via CALL |
| **External function** vs **UDF** | **External function** = calls an API *outside* Snowflake (Lambda, Azure Func) | **UDF** = runs *inside* Snowflake compute |
| **Dynamic table** vs **stream + task** | **Dynamic table** = declarative (define SQL + target lag, Snowflake manages refresh) | **Stream + task** = imperative (you manage CDC + scheduling + error handling) |
| **Directory table** vs **external table** | **Directory table** = metadata about *files* on a stage (name, size, date) | **External table** = queryable *data inside* files on external storage |
| **User stage** vs **table stage** vs **named stage** | **User** (`@~`) = per-user, private, can''t share | **Table** (`@%t`) = per-table, limited options | **Named** (`@s`) = explicit, most flexible |
| **Target lag DOWNSTREAM** vs **explicit interval** | **DOWNSTREAM** = refresh when upstream DT refreshes | **Explicit** (e.g., 5 MIN) = data no older than N minutes |
| **VALIDATION_MODE** vs **ON_ERROR** | **VALIDATION_MODE** = dry run, no data loaded | **ON_ERROR** = controls behavior *during* actual load (CONTINUE, ABORT, SKIP_FILE) |

---

## DON''T MIX -- Data Engineering Concepts the Exam Swaps

### COPY INTO vs Snowpipe vs Snowpipe Streaming -- The Decision Tree

You know all three. The exam tests WHEN to pick each one. Anchor on one word per option.

| | COPY INTO | Snowpipe | Snowpipe Streaming |
|---|---|---|---|
| Trigger | YOU run it (manual/scheduled) | FILE arrives (cloud event) | APP pushes rows (SDK call) |
| Input | Files on a stage | Files on a stage | Rows (no files) |
| Latency | Minutes to hours (batch window) | Seconds to minutes | Sub-second |
| Object | None (it''s a command) | PIPE | CHANNEL |
| Compute | YOUR warehouse | Serverless | Serverless |
| Dedup | No automatic dedup | 14-day file dedup | SDK handles offsets |

**RULE:** Files you control the schedule = COPY INTO. Files arrive unpredictably = Snowpipe. No files at all, raw rows = Streaming.

**The trap:** "Snowpipe Streaming uses a PIPE object" -- WRONG. Streaming uses CHANNELS via the Ingest SDK. PIPE is for regular Snowpipe only.

**The trap:** "Use Snowpipe for IoT with sub-second latency" -- WRONG. Snowpipe is file-based (seconds to minutes). For sub-second you need Streaming.

### Stream vs Change Tracking

Both track changes. The exam tests when you pick each one.

| | Stream | Change Tracking |
|---|---|---|
| Object type | Dedicated object (`CREATE STREAM`) | Property on a table (`SET CHANGE_TRACKING = TRUE`) |
| Offset | Consumable -- advances after DML reads it | No offset -- query any point in time, idempotent |
| Goes stale? | YES (Time Travel + 14 days) | No (as long as Time Travel window covers it) |
| Use case | Pipeline that processes changes ONCE (stream+task) | Ad-hoc "what changed since X?" queries |

**RULE:** Stream = "process changes exactly once, then move forward." Change Tracking = "peek at changes without consuming them."

**The trap:** "Use a stream for ad-hoc change queries" -- works but overkill. Change Tracking + CHANGES clause is simpler and doesn''t risk staleness.

### Dynamic Table vs Stream+Task Pipeline

Both build transformation pipelines. The exam tests the boundary.

| | Dynamic Table | Stream + Task |
|---|---|---|
| Approach | Declarative: "here''s my SQL + target lag" | Imperative: "here''s my stream, here''s my task, here''s my MERGE" |
| Scheduling | Snowflake manages it (target lag) | You manage it (CRON/interval) |
| Custom MERGE logic? | NO (it''s a SELECT, not a MERGE) | YES (full control over conflict resolution) |
| Error handling | Snowflake retries automatically | You handle it (SUSPEND_TASK_AFTER_NUM_FAILURES) |
| Staleness risk? | No (no stream to go stale) | YES (stream can go stale if task fails) |
| Chaining | DT references DT (automatic cascade) | Stream+task+stream+task (manual wiring) |

**RULE:** Pure SQL transforms with no custom merge = Dynamic Table. Custom MERGE with conflict resolution or procedural logic = Stream+Task.

**The trap:** "Dynamic tables replace stream+task in ALL cases" -- WRONG. If you need MERGE with `WHEN MATCHED AND src.ts > tgt.ts THEN UPDATE`, you need stream+task.

### Schema Detection vs Schema Evolution

| | Schema Detection | Schema Evolution |
|---|---|---|
| When | ONE TIME (at table creation) | ONGOING (every load) |
| Function | `INFER_SCHEMA()` / `USING TEMPLATE` | `ENABLE_SCHEMA_EVOLUTION = TRUE` |
| What it does | Reads files to discover columns/types | Auto-adds NEW columns to existing table |
| Removes columns? | N/A (creates fresh) | NEVER removes columns |

**RULE:** Detection = discover schema once. Evolution = adapt schema continuously. Use both together: detection for initial DDL, evolution for ongoing changes.

### UDF vs Stored Procedure -- The Side Effect Rule

| | UDF | Stored Procedure |
|---|---|---|
| Returns | A value (scalar or table) | A status/result |
| Called from | SELECT, WHERE, JOIN | CALL statement only |
| Can do DML? | NO (read-only) | YES (INSERT, UPDATE, DELETE, DDL) |
| Side effects? | NONE allowed | Yes (that''s the point) |
| Use in MV? | SQL UDFs only (no Python/Java) | Cannot be used in MVs |

**RULE:** If it needs to CHANGE data or run DDL = Stored Procedure. If it COMPUTES a value = UDF.

---

## SCENARIO DECISION TREES — Data Engineering

**Scenario 1: "500 CSV files land in S3 daily from store POS systems..."**
- **CORRECT:** **Snowpipe** with auto-ingest (S3 event notification triggers load)
- TRAP: *"Scheduled COPY INTO every hour"* — **WRONG**, misses files between runs, higher latency, more warehouse cost

**Scenario 2: "IoT sensors send 10K events/second, need sub-second latency..."**
- **CORRECT:** **Snowpipe Streaming** (Ingest SDK, row-level, no files)
- TRAP: *"Regular Snowpipe"* — **WRONG**, Snowpipe is file-based with seconds-to-minutes latency; Streaming is sub-second

**Scenario 3: "Source adds new columns frequently, table should adapt automatically..."**
- **CORRECT:** **Schema evolution** (`ENABLE_SCHEMA_EVOLUTION = TRUE`) + `MATCH_BY_COLUMN_NAME`
- TRAP: *"INFER_SCHEMA before every load"* — **WRONG**, INFER_SCHEMA is one-time detection, not ongoing evolution

**Scenario 4: "Need to merge incremental changes from raw into curated every 5 minutes..."**
- **CORRECT:** **Stream on raw table** + **Task** with `SYSTEM$STREAM_HAS_DATA` + MERGE statement
- TRAP: *"Dynamic table"* — possible but dynamic tables don''t support MERGE logic with custom conflict resolution; stream+task gives full control

**Scenario 5: "Build a transformation pipeline: raw → cleaned → aggregated, purely SQL..."**
- **CORRECT:** **Dynamic tables** chained (raw DT → cleaned DT → agg DT with target lag)
- TRAP: *"Three stream+task pairs"* — **WRONG**, overly complex; dynamic tables handle this declaratively

**Scenario 6: "Call an external ML scoring API from within a SQL query..."**
- **CORRECT:** **External function** (API integration + function definition)
- TRAP: *"Python UDF"* — **WRONG**, Python UDF runs inside Snowflake; it can''t call external APIs without an external access integration

**Scenario 7: "Need to flatten nested JSON arrays into rows for analytics..."**
- **CORRECT:** **LATERAL FLATTEN** with `INPUT => column`, optionally `OUTER => TRUE` for empty arrays
- TRAP: *"PARSE_JSON + manual extraction"* — **WRONG**, FLATTEN is purpose-built and handles nested arrays natively

**Scenario 8: "Admin task: loop through databases, create tags, run grants..."**
- **CORRECT:** **Stored procedure** (Snowflake Scripting with IF/LOOP/BEGIN-END)
- TRAP: *"UDF"* — **WRONG**, UDFs cannot execute DML (CREATE, GRANT, ALTER)

**Scenario 9: "Need to track which files exist on a stage and when they arrived..."**
- **CORRECT:** **Directory table** on the stage (`ENABLE = TRUE`, auto-refresh for external)
- TRAP: *"External table"* — **WRONG**, external tables query file *contents*, not file *metadata*

**Scenario 10: "Kafka topics need to land in Snowflake with lowest possible latency..."**
- **CORRECT:** **Kafka connector with Snowpipe Streaming** mode (direct row insert)
- TRAP: *"Kafka connector with Snowpipe mode"* — not wrong, but higher latency (file-based); Streaming mode is lower latency

**Scenario 11: "Data validation before loading — check for bad rows without actually loading..."**
- **CORRECT:** `COPY INTO ... VALIDATION_MODE = ''RETURN_ERRORS''` (dry run)
- TRAP: *"Load with ON_ERROR = CONTINUE then check errors"* — **WRONG**, this actually loads data; VALIDATION_MODE loads nothing

**Scenario 12: "Python ML feature engineering on data already in Snowflake..."**
- **CORRECT:** **Snowpark** (DataFrame API runs on Snowflake compute, no data movement)
- TRAP: *"Python connector + pandas"* — **WRONG**, this pulls data out of Snowflake to local machine; Snowpark keeps compute in Snowflake

---

## FLASHCARDS -- Domain 3

**Q1:** What is the deduplication window for Snowpipe?
**A1:** 14 days. Files loaded in the last 14 days are tracked and won''t be re-ingested.

**Q2:** What object does Snowpipe Streaming use instead of a PIPE?
**A2:** CHANNEL objects (via the Ingest SDK).

**Q3:** Can schema evolution remove columns from a table?
**A3:** No. It only adds new columns.

**Q4:** What are the three stream types?
**A4:** Standard (all DML), Append-only (inserts only), Insert-only (external tables, new files).

**Q5:** What state are tasks created in?
**A5:** SUSPENDED. They must be explicitly resumed.

**Q6:** Can UDFs execute DML?
**A6:** No. Only stored procedures can execute DML (INSERT, UPDATE, DELETE).

**Q7:** What is the key difference between an external function and a UDF?
**A7:** External functions call an API endpoint outside Snowflake; UDFs run inside Snowflake compute.

**Q8:** What does FLATTEN do?
**A8:** Converts semi-structured data (VARIANT, ARRAY, OBJECT) into relational rows.

**Q9:** What is the purpose of a storage integration?
**A9:** Provides secure, credential-free access to external cloud storage using IAM roles or service principals.

**Q10:** How does Snowpark differ from the Python connector?
**A10:** Snowpark executes a DataFrame API on Snowflake''s compute (no data movement). The Python connector runs queries from a Python client.

**Q11:** Can you create a stream on a dynamic table?
**A11:** Yes (since 2024). Streams on dynamic tables are supported for change tracking on dynamic table output.

**Q12:** What does `VALIDATION_MODE` do in COPY INTO?
**A12:** Performs a dry run — validates data without actually loading it.

**Q13:** What is a directory table?
**A13:** A metadata layer on a stage that lets you query file attributes (name, size, last_modified) via SQL.

**Q14:** What triggers child tasks in a task tree?
**A14:** The successful completion of the parent task. Only the root task has a schedule.

**Q15:** What is target lag DOWNSTREAM on a dynamic table?
**A15:** The dynamic table refreshes whenever its upstream dynamic table refreshes, cascading through the pipeline.

---

## EXPLAIN LIKE I''M 5 -- Domain 3

**1. COPY INTO**
Imagine you have a big box of puzzle pieces (files). COPY INTO dumps all those pieces onto your puzzle board (table) at once. You do it when you have a whole box ready.

**2. Snowpipe**
Now imagine someone slides puzzle pieces under your door one by one as they find them. That''s Snowpipe — pieces arrive and get placed automatically without you doing anything.

**3. Snowpipe Streaming**
Even faster: someone is THROWING puzzle pieces through your window as fast as they pick them up. No waiting for a pile. Each piece arrives instantly.

**4. Streams (CDC)**
A magic notepad that writes down every time someone adds, changes, or removes a toy from the toy box. When you read the notepad, it clears itself and starts fresh.

**5. Tasks**
An alarm clock that goes off every N minutes and says "Time to do your chores!" Your chore is a SQL statement. You can set up a chain: "After washing dishes, sweep the floor."

**6. FLATTEN**
You have a bag of bags of candy. FLATTEN opens all the inner bags and pours everything into one big pile so you can count each candy individually.

**7. Dynamic Tables**
A magic whiteboard that automatically updates itself. You wrote the rules once ("show me total sales per store"), and every few minutes the whiteboard erases and redraws with the latest numbers.

**8. External Tables**
Looking through a window at your neighbor''s garden. You can SEE the flowers (read the data) but you can''t touch or rearrange them (no writes). The flowers stay in their garden.

**9. Stages**
Your locker at school. You put your backpack (files) in your locker (stage) before taking things out in class (loading into tables). Some lockers are yours (internal), some are shared storage closets (external).

**10. Kafka Connector**
A conveyor belt from a factory (Kafka) to your warehouse (Snowflake). Items keep rolling in automatically. If the belt uses the Streaming version, items arrive even faster without needing to be boxed first.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 3.0: Data Engineering', 'pt',
  '# Domínio 3: Engenharia de Dados

> **Cobertura do Programa ARA-C01:** Carregamento/Descarregamento de Dados, Transformação de Dados, Ferramentas do Ecossistema

---

## 3.1 CARREGAMENTO DE DADOS

**COPY INTO (Carregamento em Massa)**

- Comando principal para carregamento batch/em massa de stages para tabelas
- Suporta: CSV, JSON, Avro, Parquet, ORC, XML
- Opções-chave: `ON_ERROR`, `PURGE`, `FORCE`, `MATCH_BY_COLUMN_NAME`
- `VALIDATION_MODE` — execução simulada para verificar dados sem carregar
- Retorna metadados: linhas carregadas, erros, nomes de arquivos
- Melhor para: cargas batch agendadas, migração inicial de dados, arquivos grandes

**Snowpipe (Carregamento Contínuo)**

- Pipeline serverless, auto-ingest disparado por eventos de nuvem (notificações S3, GCS Pub/Sub, Azure Event Grid)
- Quase tempo real (micro-batch, tipicamente segundos a minutos de latência)
- Usa um objeto PIPE: `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO ...`
- Cobrado por segundo de computação serverless + overhead de notificação de arquivo
- Semântica exactly-once via metadados de carregamento de arquivo (janela de dedup de 14 dias)

**Snowpipe Streaming**

- Opção de menor latência: linhas chegam em segundos, sem arquivos envolvidos
- Usa o Snowflake Ingest SDK (Java) — cliente chama `insertRows()`
- Dados são escritos em uma área de staging, depois automaticamente migrados para armazenamento de tabela
- Nenhum objeto pipe necessário — usa objetos `CHANNEL`
- Melhor para: IoT, clickstream, dados de eventos em tempo real
- Combina com Dynamic Tables para transformação em tempo real

**Detecção e Evolução de Schema**

- **Detecção de schema** (`INFER_SCHEMA`): detecta automaticamente nomes/tipos de colunas de arquivos em stage
  - Funciona com Parquet, Avro, ORC, CSV (com cabeçalhos)
  - `SELECT * FROM TABLE(INFER_SCHEMA(LOCATION => ''@stage'', FILE_FORMAT => ''fmt''))`
  - Use com `CREATE TABLE ... USING TEMPLATE` para DDL automático
- **Evolução de schema** (`ENABLE_SCHEMA_EVOLUTION = TRUE`): novas colunas nos arquivos fonte são automaticamente adicionadas à tabela
  - Colunas existentes NÃO são modificadas ou removidas
  - Requer que a role do arquivo tenha privilégio EVOLVE SCHEMA

### Por Que Isso Importa
Uma empresa de varejo recebe 500 arquivos CSV diariamente das lojas. Snowpipe faz auto-ingest conforme eles chegam no S3. Evolução de schema lida com novas colunas (ex: "loyalty_tier") sem ALTER TABLE manual.

### Melhores Práticas
- Use Snowpipe para streams contínuos e orientados a eventos; COPY INTO para grandes batches agendados
- Defina `ON_ERROR = CONTINUE` para cargas não críticas (com monitoramento de erros)
- Habilite evolução de schema em tabelas de staging para lidar com mudanças de schema na fonte
- Use `MATCH_BY_COLUMN_NAME` quando colunas da fonte não correspondem à ordem da tabela
- Monitore Snowpipe via `PIPE_USAGE_HISTORY` e `COPY_HISTORY`

**Armadilha do exame:** SE VOCÊ VER "Snowpipe Streaming requer um objeto PIPE" → ERRADO porque Streaming usa CHANNELS, não pipes.

**Armadilha do exame:** SE VOCÊ VER "COPY INTO detecta schema automaticamente" → ERRADO porque você deve usar explicitamente `INFER_SCHEMA` ou `USING TEMPLATE`.

**Armadilha do exame:** SE VOCÊ VER "evolução de schema pode remover colunas" → ERRADO porque ela apenas ADICIONA novas colunas; nunca remove ou modifica existentes.

**Armadilha do exame:** SE VOCÊ VER "Snowpipe carrega dados de forma síncrona" → ERRADO porque Snowpipe é assíncrono (serverless, orientado a eventos).

### Perguntas Frequentes (FAQ)
**P: Qual é a janela de dedup do Snowpipe?**
R: 14 dias. Arquivos carregados nos últimos 14 dias não serão recarregados (baseado em nome de arquivo + metadados).

**P: Posso usar Snowpipe com internal stages?**
R: Sim, mas auto-ingest com notificações de nuvem só funciona com external stages. Para internal stages, você chama a API REST `insertFiles` manualmente.

**P: Quando devo usar Snowpipe Streaming vs Snowpipe regular?**
R: Use Streaming quando precisar de latência sub-segundo e estiver gerando dados programaticamente (não arquivos). Use Snowpipe regular quando dados chegam como arquivos em armazenamento de nuvem.


### Exemplos de Perguntas de Cenário — Data Loading

**Cenário:** A retail chain has 2,000 stores, each uploading daily sales CSV files to S3 at unpredictable times throughout the day. The analytics team needs data available within 5 minutes of upload. Currently, a scheduled COPY INTO job runs hourly, causing up to 60 minutes of latency and occasionally missing late-arriving files. How should the architect redesign the ingestion?
**Resposta:** Replace the scheduled COPY INTO with Snowpipe using auto-ingest. Configure S3 event notifications (SQS) on the bucket to trigger Snowpipe whenever a new file lands. Create a PIPE object with `AUTO_INGEST = TRUE` pointing to the S3 stage with the appropriate file format. Snowpipe processes files within seconds to minutes of arrival — well within the 5-minute SLA. It uses serverless compute (no dedicated warehouse), and the 14-day deduplication window prevents re-loading files. Enable schema evolution on the target table to handle any new columns stores may add over time.

**Cenário:** An IoT platform receives 50,000 sensor events per second from industrial equipment. Events must be queryable within 2 seconds for real-time monitoring dashboards. File-based ingestion cannot meet the latency requirement. What ingestion method should the architect use?
**Resposta:** Use Snowpipe Streaming via the Snowflake Ingest SDK (Java). The application calls `insertRows()` to write events directly to Snowflake without creating intermediate files — achieving sub-second latency. Data lands in a staging area and is automatically migrated to table storage. No PIPE object is needed; the SDK uses CHANNEL objects. Combine Snowpipe Streaming with dynamic tables for real-time transformation — e.g., a dynamic table with a 1-minute target lag that aggregates raw sensor events into equipment health metrics for the monitoring dashboard.

**Cenário:** A data engineering team is onboarding a new data source that adds new columns to its JSON payloads every few weeks. They don''t want to manually ALTER TABLE each time. How should the architect configure the pipeline to handle this automatically?
**Resposta:** Enable schema evolution on the target table: `ALTER TABLE ... SET ENABLE_SCHEMA_EVOLUTION = TRUE`. Use `MATCH_BY_COLUMN_NAME = ''CASE_INSENSITIVE''` in the COPY INTO or Snowpipe definition so that columns are matched by name rather than position. When new columns appear in the source files, Snowflake automatically adds them to the table. Existing columns are never modified or removed. The role running the load must have the EVOLVE SCHEMA privilege on the table. Use `INFER_SCHEMA` for the initial table creation to detect the starting schema from a sample file.

---

---

## 3.2 STAGES E FILE FORMATS

**Internal Stages**

- **User stage** (`@~`): um por usuário, não pode ser alterado ou descartado
- **Table stage** (`@%table_name`): um por tabela, vinculado àquela tabela
- **Named internal stage** (`@my_stage`): criado explicitamente, mais flexível
- Dados armazenados em armazenamento gerenciado pelo Snowflake, criptografados em repouso

**External Stages**

- Apontam para armazenamento de nuvem: S3, GCS, Azure Blob/ADLS
- Requerem uma **storage integration** (melhor prática) ou credenciais inline (não recomendado)
- Suportam caminhos de pasta: `@ext_stage/path/to/folder/`

**File Formats**

- Definições de formato reutilizáveis: `CREATE FILE FORMAT`
- Tipos: CSV, JSON, AVRO, PARQUET, ORC, XML
- Opções-chave de CSV: `FIELD_DELIMITER`, `SKIP_HEADER`, `NULL_IF`, `ERROR_ON_COLUMN_COUNT_MISMATCH`
- Opções-chave de JSON: `STRIP_OUTER_ARRAY`, `STRIP_NULL_VALUES`
- Pode ser especificado inline no COPY INTO ou referenciado por nome

**Directory Tables**

- Camada de metadados em um stage: `ALTER STAGE @my_stage SET DIRECTORY = (ENABLE = TRUE)`
- Permite consultar metadados de arquivo (nome, tamanho, MD5, last_modified) via SQL
- Deve ser atualizado: `ALTER STAGE @my_stage REFRESH`
- Auto-refresh disponível para external stages com notificações de nuvem
- Útil para inventário de arquivos, rastreamento de novas chegadas, construção de pipelines de processamento

### Por Que Isso Importa
Um data lake tem 2M de arquivos Parquet no S3. Uma directory table fornece um inventário consultável sem listar objetos via AWS CLI. Combinado com streams, você pode detectar novos arquivos automaticamente.

### Melhores Práticas
- Sempre use storage integrations para external stages (sem credenciais inline)
- Use named internal stages em vez de table/user stages para workloads de produção
- Defina file formats como objetos reutilizáveis, não specs inline
- Habilite directory tables com auto-refresh para pipelines orientados a arquivos

**Armadilha do exame:** SE VOCÊ VER "user stages podem ser compartilhados entre usuários" → ERRADO porque o stage de cada usuário é privado e com escopo para aquele usuário.

**Armadilha do exame:** SE VOCÊ VER "directory tables armazenam os dados reais dos arquivos" → ERRADO porque elas apenas armazenam metadados sobre arquivos.

**Armadilha do exame:** SE VOCÊ VER "table stages suportam todas as funcionalidades de stage" → ERRADO porque table stages não podem ter file formats e têm opções limitadas vs named stages.

### Perguntas Frequentes (FAQ)
**P: Posso fazer GRANT de acesso a um user stage?**
R: Não. User stages são por usuário e não podem ser concedidos a outros.

**P: Directory tables funcionam em internal stages?**
R: Sim, mas auto-refresh só está disponível para external stages. Internal stages requerem `REFRESH` manual.


### Exemplos de Perguntas de Cenário — Stages & File Formats

**Cenário:** A data lake has 2 million Parquet files in S3 across hundreds of folders. The data engineering team needs to track which files have been processed, identify new arrivals, and build processing pipelines based on file metadata (size, last modified date). Currently, they run AWS CLI `ls` commands which take 30+ minutes. How should the architect improve this?
**Resposta:** Create an external stage pointing to the S3 bucket with a storage integration (no inline credentials). Enable a directory table on the stage: `ALTER STAGE @data_lake SET DIRECTORY = (ENABLE = TRUE)`. Configure auto-refresh with S3 event notifications so the directory table updates automatically when new files land. The team can now query file metadata (name, size, MD5, last_modified) via standard SQL in seconds instead of running CLI commands. Combine the directory table with a stream to detect new file arrivals and trigger processing tasks automatically.

**Cenário:** A security audit reveals that several external stages in production were created with inline AWS access keys embedded directly in the stage definition. How should the architect remediate this and prevent recurrence?
**Resposta:** Recreate all external stages using storage integrations instead of inline credentials. A storage integration uses IAM roles (on AWS) or service principals (on Azure) — no raw credentials in SQL. After migrating all stages, set the account-level parameter `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` to prevent anyone from creating stages with inline credentials in the future. Rotate the compromised AWS access keys immediately. Use named internal stages over table/user stages for any internally-staged data in production.

---

---

## 3.3 STREAMS E TASKS

**Streams (Captura de Dados de Mudança)**

- Rastreiam mudanças DML (INSERT, UPDATE, DELETE) em uma tabela fonte
- Três tipos:
  - **Standard:** rastreia todos os três tipos de DML, usa colunas ocultas
  - **Append-only:** rastreia apenas INSERTs (mais barato, mais simples)
  - **Insert-only (em tabelas externas):** rastreia novos arquivos/linhas em tabelas externas
- Colunas de metadados: `METADATA$ACTION`, `METADATA$ISUPDATE`, `METADATA$ROW_ID`
- Stream é "consumido" quando usado em uma transação DML (avança o offset)
- Um stream tem uma **janela de obsolescência** — se não consumido dentro da retenção de Time Travel, fica obsoleto

**Change Tracking**

- Alternativa a streams: `ALTER TABLE ... SET CHANGE_TRACKING = TRUE`
- Consulte mudanças via cláusula `CHANGES`: `SELECT * FROM table CHANGES(INFORMATION => DEFAULT) AT(...)`
- Não tem offset consumível — queries idempotentes
- Útil para consultas de mudanças pontuais sem um objeto stream dedicado

**Tasks**

- Execução SQL agendada (standalone ou em árvores de task/DAGs)
- Agendamento via expressão CRON ou `SCHEDULE = ''N MINUTE''`
- Árvores de tasks: task raiz dispara filhas em ordem de dependência
- Tasks usam computação serverless por padrão (ou um warehouse especificado)
- Devem ser explicitamente retomadas: `ALTER TASK ... RESUME`
- Cláusula `WHEN`: execução condicional (ex: `WHEN SYSTEM$STREAM_HAS_DATA(''my_stream'')`)

**Árvores de Tasks (DAGs)**

- Task raiz → tasks filhas → tasks netas
- Apenas a task raiz tem agendamento; filhas disparam automaticamente
- Task finalizadora: executa após todas as tasks no grafo completarem (sucesso ou falha)
- Use `ALLOW_OVERLAPPING_EXECUTION` para controlar execuções concorrentes

### Por Que Isso Importa
Uma plataforma de e-commerce usa um stream em `raw_orders` e uma task que executa a cada 5 minutos. A task verifica `SYSTEM$STREAM_HAS_DATA`, e se verdadeiro, faz merge das mudanças em `curated_orders`. CDC sem ferramenta de terceiros.

### Melhores Práticas
- Use `SYSTEM$STREAM_HAS_DATA` na cláusula WHEN da task para evitar execuções vazias
- Defina `SUSPEND_TASK_AFTER_NUM_FAILURES` apropriado para parar erros descontrolados
- Use tasks serverless a menos que precise controlar o tamanho do warehouse
- Prefira dynamic tables em vez de stream+task para pipelines de transformação pura
- Monitore tasks via `TASK_HISTORY` em ACCOUNT_USAGE

**Armadilha do exame:** SE VOCÊ VER "streams funcionam em views" → ERRADO porque streams funcionam em tabelas (e tabelas externas), não views.

**Armadilha do exame:** SE VOCÊ VER "tasks filhas podem ter seu próprio agendamento" → ERRADO porque apenas a task raiz tem agendamento; filhas são disparadas pela conclusão da pai.

**Armadilha do exame:** SE VOCÊ VER "streams nunca ficam obsoletos" → ERRADO porque um stream fica obsoleto se não consumido dentro da retenção de Time Travel da fonte + 14 dias.

**Armadilha do exame:** SE VOCÊ VER "tasks são retomadas por padrão após criação" → ERRADO porque tasks são criadas em estado SUSPENDED e devem ser explicitamente retomadas.

### Perguntas Frequentes (FAQ)
**P: Múltiplos streams podem existir na mesma tabela?**
R: Sim. Cada stream rastreia independentemente com seu próprio offset.

**P: O que acontece se um stream fica obsoleto?**
R: Ele se torna inutilizável. Você deve recriá-lo. O offset é perdido, e pode ser necessário fazer um recarregamento completo.

**P: Tasks podem chamar stored procedures?**
R: Sim. O corpo de uma task pode ser qualquer instrução SQL única, incluindo `CALL my_procedure()`.


### Exemplos de Perguntas de Cenário — Streams & Tasks

**Cenário:** An e-commerce platform needs to merge incremental order updates (inserts, updates, deletes) from a raw orders table into a curated orders table every 5 minutes. The merge logic includes custom conflict resolution (e.g., latest timestamp wins for updates). What pipeline architecture should the architect use?
**Resposta:** Create a standard stream on the raw orders table to capture all DML changes (inserts, updates, deletes). Create a task with a 5-minute schedule and a `WHEN SYSTEM$STREAM_HAS_DATA(''orders_stream'')` clause to avoid empty runs. The task body executes a MERGE statement that reads from the stream and applies custom conflict resolution logic (e.g., `WHEN MATCHED AND src.updated_at > tgt.updated_at THEN UPDATE`). Use serverless tasks unless the MERGE is complex enough to warrant a dedicated warehouse. Set `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors and monitor via `TASK_HISTORY`.

**Cenário:** A data platform has a complex ETL pipeline: raw data must be cleaned, then enriched with reference data, then aggregated into summary tables. Each step depends on the previous one completing successfully. If any step fails, a notification must be sent. How should the architect orchestrate this?
**Resposta:** Build a task tree (DAG). The root task runs on a schedule and performs the cleaning step. A child task handles enrichment (triggered automatically on root success). A grandchild task handles aggregation. Add a finalizer task to the DAG — it runs after all tasks complete (whether they succeed or fail) and sends an email notification with the outcome. Only the root task has a schedule; children trigger on parent completion. Use `ALLOW_OVERLAPPING_EXECUTION = FALSE` on the root to prevent concurrent runs. Alternatively, if the pipeline is pure SQL transformations without custom merge logic, consider chaining dynamic tables instead — they handle scheduling and incremental refresh declaratively.

---

---

## 3.4 TABELAS EXTERNAS E ICEBERG

**External Tables**

- Tabela somente leitura sobre arquivos em armazenamento externo (S3, GCS, Azure)
- Snowflake armazena apenas metadados; dados ficam no seu armazenamento de nuvem
- Suporta auto-refresh de metadados via notificações de nuvem
- Performance de query é mais lenta que tabelas nativas (sem clustering, sem otimização de micro-partition)
- Suporte para particionamento via colunas computadas `PARTITION BY`
- Streams em tabelas externas: insert-only (rastreia novos arquivos)

**Managed Iceberg Tables**

- Snowflake gerencia o ciclo de vida da tabela (caminho de escrita, compactação, snapshots)
- External volume define ONDE dados são armazenados (seu armazenamento de nuvem)
- DML completo: INSERT, UPDATE, DELETE, MERGE
- Integração de catálogo não necessária (Snowflake é o catálogo)
- Outros motores podem ler os metadados/arquivos de dados Iceberg
- Suporta Time Travel, clonagem, replicação

**Unmanaged Iceberg Tables (Catalog-Linked)**

- Catálogo externo (Glue, Polaris/OpenCatalog, Unity, REST) gerencia metadados
- Snowflake lê o catálogo para entender a estrutura da tabela
- Somente leitura do Snowflake (escritas vão pelo motor externo)
- Requer objeto CATALOG INTEGRATION
- Auto-refresh detecta mudanças no catálogo

**Refresh Incremental vs Completo (Contexto Dynamic/Iceberg)**

- **Refresh completo:** recomputa todo o dataset (caro mas simples)
- **Refresh incremental:** processa apenas dados alterados (mais barato, requer rastreamento de mudanças)
- Dynamic tables usam refresh incremental quando possível (dependente do operador)
- Algumas operações forçam refresh completo (ex: funções não determinísticas, joins complexos)

### Por Que Isso Importa
Uma empresa roda tanto Spark quanto Snowflake. Managed Iceberg tables permitem que o Snowflake escreva dados em formato Iceberg no S3. Spark lê os mesmos arquivos diretamente. Uma cópia dos dados, dois motores.

### Melhores Práticas
- Use managed Iceberg para novos requisitos de "formato aberto" com Snowflake como motor principal
- Use unmanaged/catalog-linked para dados de propriedade de outro motor (Spark, Trino)
- Tabelas externas são legadas para acesso somente leitura — prefira Iceberg para novos projetos
- Particione tabelas externas por data/região para pruning de query

**Armadilha do exame:** SE VOCÊ VER "tabelas externas suportam UPDATE/DELETE" → ERRADO porque tabelas externas são somente leitura.

**Armadilha do exame:** SE VOCÊ VER "unmanaged Iceberg tables suportam MERGE" → ERRADO porque escritas devem ir pelo catálogo/motor externo.

**Armadilha do exame:** SE VOCÊ VER "managed Iceberg tables armazenam dados no armazenamento interno do Snowflake" → ERRADO porque elas escrevem em um external volume (seu armazenamento de nuvem) em formato Iceberg.

**Armadilha do exame:** SE VOCÊ VER "dynamic tables sempre usam refresh incremental" → ERRADO porque certas operações forçam refresh completo.

### Perguntas Frequentes (FAQ)
**P: Posso converter uma tabela externa para uma tabela nativa?**
R: Não diretamente. Você faria CTAS da tabela externa para uma nova tabela nativa (ou Iceberg).

**P: Managed Iceberg tables suportam clustering?**
R: Sim. Você pode definir clustering keys em managed Iceberg tables.

**P: Qual é a diferença entre uma tabela externa e uma unmanaged Iceberg table?**
R: Tabelas externas funcionam com arquivos brutos (CSV, Parquet, etc.) com metadados definidos pelo Snowflake. Unmanaged Iceberg tables lêem tabelas formatadas em Iceberg gerenciadas por um catálogo externo com capacidades Iceberg completas (snapshots, evolução de schema).


### Exemplos de Perguntas de Cenário — External & Iceberg Tables

**Cenário:** A company''s data science team uses Apache Spark on EMR to train ML models, and the analytics team uses Snowflake for reporting. Both teams need read/write access to the same feature store tables. Currently, data is duplicated in both Parquet files and Snowflake tables, causing consistency issues. How should the architect unify the data layer?
**Resposta:** Migrate the feature store to managed Iceberg tables in Snowflake. Define an external volume pointing to S3 where the Iceberg data and metadata files will be stored. Snowflake manages the table lifecycle — full DML (INSERT, UPDATE, DELETE, MERGE), compaction, and snapshot management. The Spark team reads the same Iceberg metadata and data files from S3 directly using Spark''s Iceberg connector. One copy of data, two engines, full consistency. Managed Iceberg tables also support Time Travel and clustering for the Snowflake analytics team.

**Cenário:** A partner organization manages their data catalog in AWS Glue and writes Iceberg tables from their Spark pipelines. Your company needs to query this data from Snowflake without taking ownership of the catalog. How should the architect set this up?
**Resposta:** Create an unmanaged (catalog-linked) Iceberg table in Snowflake. Configure a catalog integration pointing to the partner''s AWS Glue catalog. Snowflake reads the Glue-managed Iceberg metadata to understand the table structure and queries the data files directly from S3. This is read-only from Snowflake — all writes continue through the partner''s Spark pipelines. Enable auto-refresh on the catalog integration so Snowflake detects when the partner updates the table. Do not use a managed Iceberg table here, as that would transfer catalog ownership to Snowflake and conflict with the partner''s Spark writes.

---

---

## 3.5 TRANSFORMAÇÃO DE DADOS

**FLATTEN**

- Converte dados semi-estruturados (JSON, ARRAY, VARIANT) em linhas
- Lateral join por padrão: `SELECT ... FROM table, LATERAL FLATTEN(input => col)`
- Parâmetros-chave: `INPUT`, `PATH`, `OUTER` (manter linhas com arrays vazios), `RECURSIVE`, `MODE`
- Colunas de saída: `SEQ`, `KEY`, `PATH`, `INDEX`, `VALUE`, `THIS`

**UDFs (Funções Definidas pelo Usuário)**

- SQL, JavaScript, Python, Java, Scala
- UDFs escalares: retornam um valor por linha de entrada
- Devem ser determinísticas para uso em materialized views / clustering
- Secure UDFs: escondem o corpo da função dos consumidores

**UDTFs (Funções de Tabela Definidas pelo Usuário)**

- Retornam uma tabela (múltiplas linhas por linha de entrada)
- Devem implementar: `PROCESS()` (lógica por linha) e opcionalmente `END_PARTITION()` (saída final)
- Chamadas com `TABLE()` na cláusula FROM
- Úteis para: parsing, explosão, agregação customizada

**External Functions**

- Chamam endpoints de API externa (ex: AWS Lambda, Azure Functions) a partir do SQL
- Requer: API integration + definição de external function
- Síncrono: Snowflake chama a API por batch e espera
- Use para: inferência de ML, enriquecimento de terceiros, lógica customizada não disponível no Snowflake
- Sendo substituídas por UDFs baseadas em contêiner (SPCS) para novos casos de uso

**Stored Procedures**

- Podem conter fluxo de controle (IF, LOOP, BEGIN/END), múltiplas instruções SQL
- Linguagens: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Podem executar com direitos CALLER ou OWNER
- Use para: tarefas administrativas, ETL complexo, operações multi-etapa
- Diferença-chave de UDFs: procedures podem ter efeitos colaterais (DML), UDFs não

**Dynamic Tables**

- Transformação declarativa: defina o alvo como uma query SQL + target lag
- Snowflake atualiza automaticamente (incremental quando possível)
- Substituem cadeias complexas de stream+task para pipelines de transformação
- Target lag: `DOWNSTREAM` (cascata de DTs upstream) ou intervalo explícito
- Não podem ser usadas como fonte direta para streams

**Secure Functions**

- UDFs/UDTFs com palavra-chave `SECURE`: corpo é escondido dos consumidores
- Necessárias para funções usadas em Secure Data Sharing
- Mesma barreira de otimizador que secure views

### Por Que Isso Importa
Um pipeline achata eventos JSON brutos, enriquece-os via external function (scoring de ML), e coloca resultados em uma dynamic table com target lag de 5 minutos. Zero gerenciamento de task/stream.

### Melhores Práticas
- Prefira dynamic tables em vez de stream+task para pipelines de transformação pura
- Use SQL UDFs para cálculos simples; Python UDFs para lógica complexa
- Minimize chamadas de external function (overhead de rede por batch)
- Use stored procedures para workflows administrativos, não transformação de dados
- Defina target lag de dynamic table baseado no SLA de negócio, não o mais baixo possível

**Armadilha do exame:** SE VOCÊ VER "UDFs podem executar instruções DML" → ERRADO porque UDFs são somente leitura; apenas stored procedures podem executar DML.

**Armadilha do exame:** SE VOCÊ VER "dynamic tables podem ser fontes para streams" → ERRADO porque você não pode criar streams em dynamic tables.

**Armadilha do exame:** SE VOCÊ VER "external functions executam dentro da computação do Snowflake" → ERRADO porque elas chamam um endpoint de API externo fora do Snowflake.

**Armadilha do exame:** SE VOCÊ VER "FLATTEN só funciona com JSON" → ERRADO porque FLATTEN funciona com qualquer tipo semi-estruturado: VARIANT, ARRAY, OBJECT.

### Perguntas Frequentes (FAQ)
**P: Posso usar Python UDFs em materialized views?**
R: Não. MVs só suportam expressões SQL (sem UDFs, sem external functions).

**P: Qual é a diferença entre target lag DOWNSTREAM e um intervalo específico?**
R: DOWNSTREAM significa "atualizar sempre que minha dynamic table upstream atualizar." Um intervalo específico (ex: 5 MINUTES) significa "garantir que os dados não sejam mais antigos que 5 minutos."

**P: Dynamic tables podem referenciar outras dynamic tables?**
R: Sim. Isso cria um pipeline de dynamic tables (DAG), onde atualizações upstream cascateiam downstream.


### Exemplos de Perguntas de Cenário — Data Transformation

**Cenário:** A data platform ingests raw JSON events with deeply nested arrays (e.g., an order contains an array of items, each item contains an array of discounts). The analytics team needs a flat, relational table with one row per discount. Some orders have no discounts and must still appear in the output. How should the architect design the transformation?
**Resposta:** Use nested LATERAL FLATTEN to expand the multi-level arrays. First FLATTEN the items array, then FLATTEN the discounts array within each item. Use `OUTER => TRUE` on the discounts FLATTEN to preserve orders/items that have empty discount arrays (they appear as NULL discount rows instead of being dropped). The query pattern: `SELECT ... FROM orders, LATERAL FLATTEN(INPUT => items, OUTER => TRUE) AS i, LATERAL FLATTEN(INPUT => i.VALUE:discounts, OUTER => TRUE) AS d`. Materialize this as a dynamic table with an appropriate target lag so the flat table stays current as new events arrive.

**Cenário:** A company has a complex transformation pipeline: raw → cleaned → enriched → aggregated. Currently this is managed with 4 stream+task pairs, and the team spends significant time debugging task failures, managing stream staleness, and handling scheduling edge cases. How should the architect simplify this?
**Resposta:** Replace the stream+task chain with a pipeline of dynamic tables. Define each layer as a dynamic table with a SQL query referencing the previous layer: `raw_dt → cleaned_dt → enriched_dt → aggregated_dt`. Set target lag based on business SLAs — the final aggregated table might use `TARGET_LAG = ''5 MINUTES''` while intermediate tables use `TARGET_LAG = DOWNSTREAM` (refresh when downstream needs data). Snowflake handles scheduling, incremental refresh, and error management declaratively. This eliminates manual stream offset management, task scheduling, and staleness risks. Note: dynamic tables work best for pure SQL transformations; if you need custom merge logic or procedural control flow, stream+task remains appropriate.

**Cenário:** The data engineering team needs a stored procedure that loops through all databases in the account, creates a governance tag on each, and grants APPLY TAG privileges to a specific role. A junior engineer asks why they can''t use a UDF for this. What should the architect explain?
**Resposta:** UDFs cannot execute DML or DDL statements — they are read-only functions usable in SELECT. This task requires DDL (`CREATE TAG`) and DCL (`GRANT`) operations, which only stored procedures can perform. Create a stored procedure using Snowflake Scripting (SQL) with a RESULTSET cursor to iterate over `SHOW DATABASES`, then execute `CREATE TAG IF NOT EXISTS` and `GRANT APPLY TAG` for each database. The procedure should run with CALLER rights so it executes under the invoking role''s permissions, ensuring proper authorization checks.

---

---

## 3.6 FERRAMENTAS DO ECOSSISTEMA

**Kafka Connector**

- Transmite dados de tópicos Kafka para tabelas Snowflake
- Duas versões: **Baseada em Snowpipe** (arquivos para stage, depois COPY) e **Snowpipe Streaming** (inserção direta de linhas, menor latência)
- Suporta semântica exactly-once
- Lida com evolução de schema (novos campos em JSON)
- Gerenciado pelo Snowflake ou auto-hospedado

**Spark Connector**

- Bidirecional: ler de e escrever para Snowflake a partir do Spark
- Empurra queries para o Snowflake quando possível (predicate pushdown)
- Suporta DataFrame API e SQL
- Configuração-chave: `sfURL`, `sfUser`, `sfPassword`, `sfDatabase`, `sfSchema`, `sfWarehouse`

**Python Connector**

- Biblioteca Python nativa (`snowflake-connector-python`)
- Suporta `write_pandas()` para uploads em massa de DataFrame
- Integra com SQLAlchemy
- Suporte a query assíncrona para queries de longa duração
- `snowflake-snowpark-python` — DataFrame API que executa na computação do Snowflake

**JDBC / ODBC**

- Conectividade padrão de banco de dados para Java (JDBC) e outras linguagens (ODBC)
- Snowflake fornece seus próprios drivers JDBC e ODBC
- Suportam todas as operações SQL padrão
- Usados pela maioria das ferramentas de BI (Tableau, Power BI, Looker)

**SQL API (REST)**

- Endpoint HTTP REST para executar SQL
- Submeter instruções, verificar status, recuperar resultados via chamadas REST
- Usa OAuth ou tokens de par de chaves para autenticação
- Execução assíncrona: submeter → consultar status → buscar resultados
- Útil para arquiteturas serverless, microsserviços

**Snowpark**

- Framework de desenvolvimento para Python, Java, Scala
- DataFrame API que executa na computação do Snowflake (sem movimentação de dados)
- Suporta UDFs, UDTFs e stored procedures
- Ideal para pipelines de ML, transformações complexas
- Avaliação lazy: operações constroem um plano, executam no `.collect()` ou ação

### Por Que Isso Importa
Uma plataforma de dados usa Kafka connector para ingestão em tempo real, Snowpark para engenharia de features de ML, e JDBC para ferramentas de BI. O arquiteto deve saber qual conector se encaixa em cada caso de uso.

### Melhores Práticas
- Use Kafka connector com Snowpipe Streaming para menor latência
- Use Snowpark em vez de extrair dados para Python/Spark quando possível (computação fica no Snowflake)
- Use SQL API para integrações leves e apps serverless
- Sempre use os drivers mais recentes fornecidos pelo Snowflake (atualizados frequentemente)
- Use autenticação por par de chaves para todas as conexões programáticas/de serviço

**Armadilha do exame:** SE VOCÊ VER "o Spark connector sempre move todos os dados para o Spark" → ERRADO porque ele suporta predicate pushdown, empurrando filtros para o Snowflake.

**Armadilha do exame:** SE VOCÊ VER "SQL API é apenas síncrona" → ERRADO porque ela suporta execução assíncrona (submeter → consultar → buscar).

**Armadilha do exame:** SE VOCÊ VER "Snowpark requer que dados sejam extraídos do Snowflake" → ERRADO porque Snowpark executa na computação do Snowflake; dados ficam no Snowflake.

**Armadilha do exame:** SE VOCÊ VER "o Kafka connector só suporta JSON" → ERRADO porque ele suporta JSON, Avro e Protobuf (com schema registry).

### Perguntas Frequentes (FAQ)
**P: Quando devo usar o Spark connector vs Snowpark?**
R: Use Spark connector quando você já tem infraestrutura Spark e precisa integrar Snowflake em pipelines existentes. Use Snowpark quando quiser executar toda a computação no Snowflake sem um cluster Spark.

**P: A SQL API pode lidar com grandes conjuntos de resultados?**
R: Sim, via paginação de conjunto de resultados. Resultados grandes são retornados em partições que você busca incrementalmente.

**P: O Kafka connector suporta evolução de schema?**
R: Sim. Novos campos em payloads JSON são carregados na coluna VARIANT. Se você usar evolução de schema na tabela de destino, colunas são auto-adicionadas.


### Exemplos de Perguntas de Cenário — Ecosystem Tools

**Cenário:** A company has an existing Spark-based ML pipeline on Databricks that processes 500 GB of features daily. They''re migrating analytics to Snowflake but don''t want to rewrite the Spark pipeline. The Spark pipeline needs to read from and write to Snowflake tables. How should the architect integrate the two systems?
**Resposta:** Use the Snowflake Spark connector. Configure it with the Snowflake connection parameters (`sfURL`, `sfUser`, `sfWarehouse`, etc.) and use key-pair authentication for the service account. The Spark connector supports bidirectional data movement and pushes predicates down to Snowflake when reading (minimizing data transfer). For the longer-term, evaluate migrating the ML pipeline to Snowpark — which runs the DataFrame API directly on Snowflake compute without moving data out. But for immediate integration without rewriting, the Spark connector is the correct choice.

**Cenário:** A microservices architecture on AWS Lambda needs to execute Snowflake queries. The Lambda functions are stateless, short-lived, and cannot maintain persistent database connections. What connectivity approach should the architect recommend?
**Resposta:** Use the Snowflake SQL API (REST). Lambda functions submit SQL statements via HTTP POST, then poll for status and fetch results asynchronously. The SQL API supports OAuth or key-pair tokens for authentication — no persistent database connections needed. This fits the stateless, ephemeral nature of Lambda. For larger result sets, the API returns paginated results that Lambda can fetch incrementally. Avoid JDBC/ODBC in Lambda since connection pooling is impractical in short-lived serverless functions.

**Cenário:** A data science team currently extracts 100 GB of data from Snowflake to their local Python environment using the Python connector and pandas for feature engineering. The extraction takes 45 minutes and overwhelms local memory. How should the architect improve this workflow?
**Resposta:** Migrate the feature engineering logic to Snowpark. Snowpark provides a pandas-like DataFrame API that executes directly on Snowflake''s compute — no data extraction needed. The data stays in Snowflake, operations are lazily evaluated and pushed down to the warehouse, and results are only materialized on `.collect()` or when writing to a table. This eliminates the 45-minute extraction, local memory constraints, and data movement costs. Snowpark supports Python UDFs and stored procedures for complex ML logic that can''t be expressed in SQL.

---

---

## PARES CONFUSOS — Engenharia de Dados

| Perguntam sobre... | A resposta é... | NÃO... |
|---|---|---|
| **Snowpipe** vs **COPY INTO** | **Snowpipe** = serverless, orientado a eventos, contínuo (arquivos disparam carga) | **COPY INTO** = comando batch manual/agendado, você executa explicitamente |
| **Snowpipe** vs **Snowpipe Streaming** | **Snowpipe** = baseado em arquivo (notificações de nuvem → micro-batch) | **Streaming** = baseado em linha (Ingest SDK, sem arquivos, latência sub-segundo) |
| **Objeto PIPE** vs **objeto CHANNEL** | **PIPE** = usado pelo Snowpipe regular (`CREATE PIPE`) | **CHANNEL** = usado pelo Snowpipe Streaming (Ingest SDK, sem PIPE necessário) |
| **Stream** vs **Task** | **Stream** = rastreador de CDC (registra mudanças em uma tabela) | **Task** = executor SQL agendado (cron/intervalo). São *parceiros*, não substitutos |
| **Stream standard** vs **stream append-only** | **Standard** = rastreia INSERT + UPDATE + DELETE | **Append-only** = rastreia apenas INSERTs (mais barato, mais simples) |
| **Tabela externa** vs **Iceberg table** | **External** = arquivos brutos (CSV, Parquet), somente leitura, metadados Snowflake | **Iceberg** = formato Iceberg, managed = DML completo, unmanaged = catalog-linked |
| **Detecção de schema** vs **evolução de schema** | **Detecção** (`INFER_SCHEMA`) = lê arquivo para descobrir colunas *uma vez* | **Evolução** = auto-adiciona novas colunas à tabela *continuamente* conforme a fonte muda |
| **UDF** vs **UDTF** | **UDF** = um valor por linha (escalar) | **UDTF** = múltiplas linhas por entrada (função de tabela, usa PROCESS + END_PARTITION) |
| **UDF** vs **stored procedure** | **UDF** = somente leitura, sem efeitos colaterais, utilizável em SELECT | **Procedure** = pode fazer DML, fluxo de controle, efeitos colaterais, chamada via CALL |
| **External function** vs **UDF** | **External function** = chama uma API *fora* do Snowflake (Lambda, Azure Func) | **UDF** = executa *dentro* da computação do Snowflake |
| **Dynamic table** vs **stream + task** | **Dynamic table** = declarativa (defina SQL + target lag, Snowflake gerencia refresh) | **Stream + task** = imperativa (você gerencia CDC + agendamento + tratamento de erros) |
| **Directory table** vs **tabela externa** | **Directory table** = metadados sobre *arquivos* em um stage (nome, tamanho, data) | **Tabela externa** = *dados dentro* de arquivos consultáveis em armazenamento externo |
| **User stage** vs **table stage** vs **named stage** | **User** (`@~`) = por usuário, privado, não compartilhável | **Table** (`@%t`) = por tabela, opções limitadas | **Named** (`@s`) = explícito, mais flexível |
| **Target lag DOWNSTREAM** vs **intervalo explícito** | **DOWNSTREAM** = atualizar quando DT upstream atualizar | **Explícito** (ex: 5 MIN) = dados não mais antigos que N minutos |
| **VALIDATION_MODE** vs **ON_ERROR** | **VALIDATION_MODE** = execução simulada, nenhum dado carregado | **ON_ERROR** = controla comportamento *durante* carga real (CONTINUE, ABORT, SKIP_FILE) |

---

## ÁRVORES DE DECISÃO DE CENÁRIOS — Engenharia de Dados

**Cenário 1: "500 arquivos CSV chegam no S3 diariamente de sistemas POS de lojas..."**
- **CORRETO:** **Snowpipe** com auto-ingest (notificação de evento S3 dispara carga)
- ARMADILHA: *"COPY INTO agendado a cada hora"* — **ERRADO**, perde arquivos entre execuções, maior latência, mais custo de warehouse

**Cenário 2: "Sensores IoT enviam 10K eventos/segundo, precisam de latência sub-segundo..."**
- **CORRETO:** **Snowpipe Streaming** (Ingest SDK, nível de linha, sem arquivos)
- ARMADILHA: *"Snowpipe regular"* — **ERRADO**, Snowpipe é baseado em arquivo com latência de segundos a minutos; Streaming é sub-segundo

**Cenário 3: "Fonte adiciona novas colunas frequentemente, tabela deve adaptar automaticamente..."**
- **CORRETO:** **Evolução de schema** (`ENABLE_SCHEMA_EVOLUTION = TRUE`) + `MATCH_BY_COLUMN_NAME`
- ARMADILHA: *"INFER_SCHEMA antes de cada carga"* — **ERRADO**, INFER_SCHEMA é detecção única, não evolução contínua

**Cenário 4: "Precisa fazer merge de mudanças incrementais de raw para curated a cada 5 minutos..."**
- **CORRETO:** **Stream na tabela raw** + **Task** com `SYSTEM$STREAM_HAS_DATA` + instrução MERGE
- ARMADILHA: *"Dynamic table"* — possível mas dynamic tables não suportam lógica de MERGE com resolução de conflito customizada; stream+task dá controle total

**Cenário 5: "Construir um pipeline de transformação: raw → limpo → agregado, puramente SQL..."**
- **CORRETO:** **Dynamic tables** encadeadas (DT raw → DT limpa → DT agg com target lag)
- ARMADILHA: *"Três pares de stream+task"* — **ERRADO**, excessivamente complexo; dynamic tables lidam com isso declarativamente

**Cenário 6: "Chamar uma API externa de scoring ML de dentro de uma query SQL..."**
- **CORRETO:** **External function** (API integration + definição de função)
- ARMADILHA: *"Python UDF"* — **ERRADO**, Python UDF executa dentro do Snowflake; não pode chamar APIs externas sem uma external access integration

**Cenário 7: "Precisa achatar arrays JSON aninhados em linhas para analytics..."**
- **CORRETO:** **LATERAL FLATTEN** com `INPUT => column`, opcionalmente `OUTER => TRUE` para arrays vazios
- ARMADILHA: *"PARSE_JSON + extração manual"* — **ERRADO**, FLATTEN é feito para esse propósito e lida com arrays aninhados nativamente

**Cenário 8: "Tarefa admin: iterar por bancos de dados, criar tags, executar grants..."**
- **CORRETO:** **Stored procedure** (Snowflake Scripting com IF/LOOP/BEGIN-END)
- ARMADILHA: *"UDF"* — **ERRADO**, UDFs não podem executar DML (CREATE, GRANT, ALTER)

**Cenário 9: "Precisa rastrear quais arquivos existem em um stage e quando chegaram..."**
- **CORRETO:** **Directory table** no stage (`ENABLE = TRUE`, auto-refresh para externo)
- ARMADILHA: *"Tabela externa"* — **ERRADO**, tabelas externas consultam *conteúdo* de arquivos, não *metadados* de arquivos

**Cenário 10: "Tópicos Kafka precisam chegar no Snowflake com a menor latência possível..."**
- **CORRETO:** **Kafka connector com modo Snowpipe Streaming** (inserção direta de linhas)
- ARMADILHA: *"Kafka connector com modo Snowpipe"* — não errado, mas maior latência (baseado em arquivo); modo Streaming é menor latência

**Cenário 11: "Validação de dados antes de carregar — verificar linhas ruins sem realmente carregar..."**
- **CORRETO:** `COPY INTO ... VALIDATION_MODE = ''RETURN_ERRORS''` (execução simulada)
- ARMADILHA: *"Carregar com ON_ERROR = CONTINUE e depois verificar erros"* — **ERRADO**, isso realmente carrega dados; VALIDATION_MODE não carrega nada

**Cenário 12: "Engenharia de features ML em Python em dados já no Snowflake..."**
- **CORRETO:** **Snowpark** (DataFrame API executa na computação do Snowflake, sem movimentação de dados)
- ARMADILHA: *"Python connector + pandas"* — **ERRADO**, isso puxa dados para fora do Snowflake para a máquina local; Snowpark mantém computação no Snowflake

---

## FLASHCARDS -- Domínio 3

**Q1:** Qual é a janela de deduplicação do Snowpipe?
**A1:** 14 dias. Arquivos carregados nos últimos 14 dias não são recarregados.

**Q2:** Snowpipe Streaming usa objetos PIPE ou CHANNEL?
**A2:** CHANNEL. Nenhum objeto PIPE é necessário.

**Q3:** O que `ENABLE_SCHEMA_EVOLUTION = TRUE` faz?
**A3:** Adiciona automaticamente novas colunas à tabela quando arquivos fonte contêm colunas que não existem na tabela. Não remove ou modifica colunas existentes.

**Q4:** O que acontece quando um stream fica obsoleto?
**A4:** Ele se torna inutilizável — você deve recriá-lo e potencialmente fazer um recarregamento completo.

**Q5:** Tabelas externas podem ser atualizadas (UPDATE/DELETE)?
**A5:** Não. Tabelas externas são somente leitura.

**Q6:** Qual é a diferença entre managed e unmanaged Iceberg tables?
**A6:** Managed: Snowflake controla metadados + DML completo. Unmanaged: catálogo externo (Glue, Polaris) controla metadados, somente leitura do Snowflake.

**Q7:** UDFs podem executar instruções DML?
**A7:** Não. UDFs são somente leitura. Use stored procedures para DML.

**Q8:** O que uma directory table armazena?
**A8:** Metadados sobre arquivos em um stage (nome, tamanho, MD5, last_modified) — não os dados reais dos arquivos.

**Q9:** O que é target lag DOWNSTREAM em dynamic tables?
**A9:** Significa "atualizar sempre que minha dynamic table upstream atualizar" (cascata).

**Q10:** O Spark connector sempre puxa todos os dados para o Spark?
**A10:** Não. Ele suporta predicate pushdown, empurrando filtros para o Snowflake.

**Q11:** Apenas a task _____ tem agendamento em uma árvore de tasks.
**A11:** **Raiz**. Tasks filhas são disparadas pela conclusão da task pai.

**Q12:** Qual conector provê menor latência para dados do Kafka?
**A12:** Kafka connector com modo **Snowpipe Streaming** (inserção direta de linhas, sem arquivos).

**Q13:** Streams podem ser criados em dynamic tables?
**A13:** Não. Dynamic tables não podem ser fontes para streams.

**Q14:** O que VALIDATION_MODE faz no COPY INTO?
**A14:** Executa uma simulação — verifica dados sem realmente carregar nada na tabela.

**Q15:** Snowpark executa computação onde?
**A15:** Na computação do **Snowflake** — dados ficam no Snowflake, sem movimentação para fora.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS -- Domínio 3

**1. COPY INTO vs Snowpipe**
COPY INTO é como encher um balde de água no poço — você vai, enche e volta. Snowpipe é como ter um cano que enche automaticamente quando detecta que precisa de água.

**2. Snowpipe Streaming**
É ainda mais rápido que o cano! É como um bebedouro — cada gota (linha de dados) chega no momento que você precisa, sem esperar pelo balde.

**3. Streams**
Um caderno mágico que anota tudo que muda na sua caixa de brinquedos. "Teddy foi adicionado!" "Carrinho foi removido!" Quando você lê o caderno, ele limpa as anotações e começa de novo.

**4. Tasks**
Um despertador que diz "a cada 5 minutos, verifique se tem algo novo no caderno mágico (stream) e organize a estante." Funciona sozinho, sem você precisar lembrar.

**5. Dynamic Tables**
Você diz "eu quero que esta prateleira sempre tenha os brinquedos ordenados por tamanho." O Snowflake automaticamente reorganiza quando você adiciona ou remove brinquedos. Você só descreveu O QUE quer, não COMO fazer.

**6. Stages**
Caixas de correio para seus dados. User stage é SUA caixa pessoal. Table stage é a caixa da mesa específica. Named stage é uma caixa que você pode nomear e compartilhar.

**7. External Tables**
Uma janela que olha para a garagem do vizinho. Você pode VER o que tem lá, mas não pode MOVER nada. Os dados ficam no lugar deles, você só observa.

**8. Iceberg Tables**
Brinquedos que funcionam com qualquer marca. Seu LEGO (Snowflake) e o LEGO do amigo (Spark) podem construir no mesmo tabuleiro. Managed = você controla. Unmanaged = o amigo controla.

**9. FLATTEN**
Você tem uma caixa com caixinhas dentro, que têm brinquedos. FLATTEN abre todas as caixinhas e coloca todos os brinquedos em uma fila organizada.

**10. External Functions**
Quando você precisa de ajuda de fora. É como ligar para a pizzaria (API externa) no meio do jantar — você espera a pizza chegar e continua comendo.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 3.0: Data Engineering', 'es',
  '# Dominio 3: Ingeniería de Datos

> **Cobertura del Temario ARA-C01:** Carga/Descarga de Datos, Transformación de Datos, Herramientas del Ecosistema

---

## 3.1 CARGA DE DATOS

**COPY INTO (Carga Masiva)**

- Comando principal para carga masiva/por lotes desde stages hacia tablas
- Soporta: CSV, JSON, Avro, Parquet, ORC, XML
- Opciones clave: `ON_ERROR`, `PURGE`, `FORCE`, `MATCH_BY_COLUMN_NAME`
- `VALIDATION_MODE` — ejecución de prueba para verificar datos sin cargarlos
- Retorna metadatos: filas cargadas, errores, nombres de archivos
- Ideal para: cargas masivas programadas, migración inicial de datos, archivos grandes

**Snowpipe (Carga Continua)**

- Serverless, pipeline de auto-ingesta disparado por eventos en la nube (notificaciones S3, GCS Pub/Sub, Azure Event Grid)
- Casi en tiempo real (micro-batch, típicamente segundos a minutos de latencia)
- Usa un objeto PIPE: `CREATE PIPE ... AUTO_INGEST = TRUE AS COPY INTO ...`
- Facturado por segundo de cómputo serverless + overhead de notificaciones de archivos
- Semántica de exactamente una vez mediante metadatos de carga de archivos (ventana de deduplicación de 14 días)

**Snowpipe Streaming**

- Opción de menor latencia: las filas llegan en segundos, sin archivos involucrados
- Usa el Snowflake Ingest SDK (Java) — el cliente llama `insertRows()`
- Los datos se escriben en un área de staging, luego se migran automáticamente al almacenamiento de la tabla
- No necesita objeto pipe — usa objetos `CHANNEL`
- Ideal para: IoT, clickstream, datos de eventos en tiempo real
- Se combina con Dynamic Tables para transformación en tiempo real

**Detección y Evolución de Esquema**

- **Detección de esquema** (`INFER_SCHEMA`): detecta automáticamente nombres/tipos de columnas de archivos en stage
  - Funciona con Parquet, Avro, ORC, CSV (con encabezados)
  - `SELECT * FROM TABLE(INFER_SCHEMA(LOCATION => ''@stage'', FILE_FORMAT => ''fmt''))`
  - Usar con `CREATE TABLE ... USING TEMPLATE` para DDL automático
- **Evolución de esquema** (`ENABLE_SCHEMA_EVOLUTION = TRUE`): columnas nuevas en archivos fuente se agregan automáticamente a la tabla
  - Las columnas existentes NO se modifican ni eliminan
  - Requiere privilegio EVOLVE SCHEMA en el rol del archivo

### Por Qué Esto Importa
Una empresa de retail recibe 500 archivos CSV diarios de sus tiendas. Snowpipe los ingesta automáticamente cuando llegan a S3. La evolución de esquema maneja columnas nuevas (ej., "loyalty_tier") sin ALTER TABLE manual.

### Mejores Prácticas
- Usa Snowpipe para flujos constantes y orientados a eventos; COPY INTO para grandes cargas programadas
- Configura `ON_ERROR = CONTINUE` para cargas no críticas (con monitoreo de errores)
- Habilita la evolución de esquema en tablas de staging para manejar cambios en el esquema fuente
- Usa `MATCH_BY_COLUMN_NAME` cuando las columnas fuente no coinciden con el orden de la tabla
- Monitorea Snowpipe via `PIPE_USAGE_HISTORY` y `COPY_HISTORY`

**Trampa del examen:** SI VES "Snowpipe Streaming requiere un objeto PIPE" → **INCORRECTO** porque Streaming usa CHANNELS, no pipes.

**Trampa del examen:** SI VES "COPY INTO detecta automáticamente el esquema" → **INCORRECTO** porque debes usar explícitamente `INFER_SCHEMA` o `USING TEMPLATE`.

**Trampa del examen:** SI VES "la evolución de esquema puede eliminar columnas" → **INCORRECTO** porque solo AGREGA columnas nuevas; nunca elimina ni modifica las existentes.

**Trampa del examen:** SI VES "Snowpipe carga datos sincrónicamente" → **INCORRECTO** porque Snowpipe es asincrónico (serverless, orientado a eventos).

### Preguntas Frecuentes (FAQ)
**P: ¿Cuál es la ventana de deduplicación de Snowpipe?**
R: 14 días. Los archivos cargados en los últimos 14 días no se recargarán (basado en nombre de archivo + metadatos).

**P: ¿Puedo usar Snowpipe con stages internos?**
R: Sí, pero la auto-ingesta con notificaciones en la nube solo funciona con stages externos. Para stages internos, debes llamar la API REST `insertFiles` manualmente.

**P: ¿Cuándo debo usar Snowpipe Streaming vs Snowpipe regular?**
R: Usa Streaming cuando necesites latencia menor a un segundo y estés generando datos programáticamente (no archivos). Usa Snowpipe regular cuando los datos llegan como archivos en almacenamiento en la nube.


### Ejemplos de Preguntas de Escenario — Data Loading

**Escenario:** A retail chain has 2,000 stores, each uploading daily sales CSV files to S3 at unpredictable times throughout the day. The analytics team needs data available within 5 minutes of upload. Currently, a scheduled COPY INTO job runs hourly, causing up to 60 minutes of latency and occasionally missing late-arriving files. How should the architect redesign the ingestion?
**Respuesta:** Replace the scheduled COPY INTO with Snowpipe using auto-ingest. Configure S3 event notifications (SQS) on the bucket to trigger Snowpipe whenever a new file lands. Create a PIPE object with `AUTO_INGEST = TRUE` pointing to the S3 stage with the appropriate file format. Snowpipe processes files within seconds to minutes of arrival — well within the 5-minute SLA. It uses serverless compute (no dedicated warehouse), and the 14-day deduplication window prevents re-loading files. Enable schema evolution on the target table to handle any new columns stores may add over time.

**Escenario:** An IoT platform receives 50,000 sensor events per second from industrial equipment. Events must be queryable within 2 seconds for real-time monitoring dashboards. File-based ingestion cannot meet the latency requirement. What ingestion method should the architect use?
**Respuesta:** Use Snowpipe Streaming via the Snowflake Ingest SDK (Java). The application calls `insertRows()` to write events directly to Snowflake without creating intermediate files — achieving sub-second latency. Data lands in a staging area and is automatically migrated to table storage. No PIPE object is needed; the SDK uses CHANNEL objects. Combine Snowpipe Streaming with dynamic tables for real-time transformation — e.g., a dynamic table with a 1-minute target lag that aggregates raw sensor events into equipment health metrics for the monitoring dashboard.

**Escenario:** A data engineering team is onboarding a new data source that adds new columns to its JSON payloads every few weeks. They don''t want to manually ALTER TABLE each time. How should the architect configure the pipeline to handle this automatically?
**Respuesta:** Enable schema evolution on the target table: `ALTER TABLE ... SET ENABLE_SCHEMA_EVOLUTION = TRUE`. Use `MATCH_BY_COLUMN_NAME = ''CASE_INSENSITIVE''` in the COPY INTO or Snowpipe definition so that columns are matched by name rather than position. When new columns appear in the source files, Snowflake automatically adds them to the table. Existing columns are never modified or removed. The role running the load must have the EVOLVE SCHEMA privilege on the table. Use `INFER_SCHEMA` for the initial table creation to detect the starting schema from a sample file.

---

---

## 3.2 STAGES Y FORMATOS DE ARCHIVO

**Stages Internos**

- **User stage** (`@~`): uno por usuario, no se puede alterar ni eliminar
- **Table stage** (`@%nombre_tabla`): uno por tabla, vinculado a esa tabla
- **Named internal stage** (`@mi_stage`): creado explícitamente, el más flexible
- Datos almacenados en almacenamiento administrado por Snowflake, cifrados en reposo

**Stages Externos**

- Apuntan a almacenamiento en la nube: S3, GCS, Azure Blob/ADLS
- Requieren un **storage integration** (mejor práctica) o credenciales inline (no recomendado)
- Soportan rutas de carpetas: `@ext_stage/ruta/a/carpeta/`

**Formatos de Archivo**

- Definiciones de formato reutilizables: `CREATE FILE FORMAT`
- Tipos: CSV, JSON, AVRO, PARQUET, ORC, XML
- Opciones clave de CSV: `FIELD_DELIMITER`, `SKIP_HEADER`, `NULL_IF`, `ERROR_ON_COLUMN_COUNT_MISMATCH`
- Opciones clave de JSON: `STRIP_OUTER_ARRAY`, `STRIP_NULL_VALUES`
- Se pueden especificar inline en COPY INTO o referenciar por nombre

**Directory Tables**

- Capa de metadatos sobre un stage: `ALTER STAGE @mi_stage SET DIRECTORY = (ENABLE = TRUE)`
- Permite consultar metadatos de archivos (nombre, tamaño, MD5, last_modified) via SQL
- Debe refrescarse: `ALTER STAGE @mi_stage REFRESH`
- Auto-refresh disponible para stages externos con notificaciones en la nube
- Útil para inventario de archivos, rastreo de nuevas llegadas, construcción de pipelines de procesamiento

### Por Qué Esto Importa
Un data lake tiene 2M de archivos Parquet en S3. Una directory table proporciona un inventario consultable sin listar objetos via AWS CLI. Combinado con streams, puedes detectar archivos nuevos automáticamente.

### Mejores Prácticas
- Siempre usa storage integrations para stages externos (sin credenciales inline)
- Usa named internal stages sobre table/user stages para cargas de producción
- Define formatos de archivo como objetos reutilizables, no especificaciones inline
- Habilita directory tables con auto-refresh para pipelines orientados a archivos

**Trampa del examen:** SI VES "los user stages se pueden compartir entre usuarios" → **INCORRECTO** porque el stage de cada usuario es privado y limitado a ese usuario.

**Trampa del examen:** SI VES "las directory tables almacenan los datos reales del archivo" → **INCORRECTO** porque solo almacenan metadatos sobre los archivos.

**Trampa del examen:** SI VES "los table stages soportan todas las funciones de stage" → **INCORRECTO** porque los table stages no pueden tener file formats y tienen opciones limitadas comparados con named stages.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo dar acceso (GRANT) a un user stage?**
R: No. Los user stages son por usuario y no se pueden otorgar a otros.

**P: ¿Las directory tables funcionan en stages internos?**
R: Sí, pero el auto-refresh solo está disponible para stages externos. Los stages internos requieren `REFRESH` manual.


### Ejemplos de Preguntas de Escenario — Stages & File Formats

**Escenario:** A data lake has 2 million Parquet files in S3 across hundreds of folders. The data engineering team needs to track which files have been processed, identify new arrivals, and build processing pipelines based on file metadata (size, last modified date). Currently, they run AWS CLI `ls` commands which take 30+ minutes. How should the architect improve this?
**Respuesta:** Create an external stage pointing to the S3 bucket with a storage integration (no inline credentials). Enable a directory table on the stage: `ALTER STAGE @data_lake SET DIRECTORY = (ENABLE = TRUE)`. Configure auto-refresh with S3 event notifications so the directory table updates automatically when new files land. The team can now query file metadata (name, size, MD5, last_modified) via standard SQL in seconds instead of running CLI commands. Combine the directory table with a stream to detect new file arrivals and trigger processing tasks automatically.

**Escenario:** A security audit reveals that several external stages in production were created with inline AWS access keys embedded directly in the stage definition. How should the architect remediate this and prevent recurrence?
**Respuesta:** Recreate all external stages using storage integrations instead of inline credentials. A storage integration uses IAM roles (on AWS) or service principals (on Azure) — no raw credentials in SQL. After migrating all stages, set the account-level parameter `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION = TRUE` to prevent anyone from creating stages with inline credentials in the future. Rotate the compromised AWS access keys immediately. Use named internal stages over table/user stages for any internally-staged data in production.

---

---

## 3.3 STREAMS Y TASKS

**Streams (Captura de Datos de Cambio)**

- Rastrean cambios DML (INSERT, UPDATE, DELETE) en una tabla fuente
- Tres tipos:
  - **Standard:** rastrean los tres tipos de DML, usan columnas ocultas
  - **Append-only:** solo rastrean INSERTs (más económico, más simple)
  - **Insert-only (en external tables):** rastrean archivos/filas nuevos en external tables
- Columnas de metadatos: `METADATA$ACTION`, `METADATA$ISUPDATE`, `METADATA$ROW_ID`
- El stream se "consume" cuando se usa en una transacción DML (avanza el offset)
- Un stream tiene una **ventana de caducidad** — si no se consume dentro de la retención de Time Travel, se vuelve obsoleto

**Change Tracking**

- Alternativa a streams: `ALTER TABLE ... SET CHANGE_TRACKING = TRUE`
- Consulta cambios via cláusula `CHANGES`: `SELECT * FROM tabla CHANGES(INFORMATION => DEFAULT) AT(...)`
- No tiene un offset consumible — consultas idempotentes
- Útil para consultas de cambios puntuales sin un objeto stream dedicado

**Tasks**

- Ejecución SQL programada (individual o en árboles de tasks/DAGs)
- Programación via expresión CRON o `SCHEDULE = ''N MINUTE''`
- Árboles de tasks: la task raíz dispara las hijas en orden de dependencia
- Las tasks usan cómputo serverless por defecto (o un warehouse especificado)
- Deben reanudarse explícitamente: `ALTER TASK ... RESUME`
- Cláusula `WHEN`: ejecución condicional (ej., `WHEN SYSTEM$STREAM_HAS_DATA(''mi_stream'')`)

**Árboles de Tasks (DAGs)**

- Task raíz → tasks hijas → tasks nietas
- Solo la task raíz tiene programación; las hijas se disparan automáticamente
- Task finalizadora: se ejecuta después de que todas las tasks del grafo terminen (éxito o fallo)
- Usa `ALLOW_OVERLAPPING_EXECUTION` para controlar ejecuciones concurrentes

### Por Qué Esto Importa
Una plataforma de e-commerce usa un stream en `raw_orders` y una task que se ejecuta cada 5 minutos. La task verifica `SYSTEM$STREAM_HAS_DATA`, y si es verdadero, hace merge de los cambios en `curated_orders`. CDC sin herramientas de terceros.

### Mejores Prácticas
- Usa `SYSTEM$STREAM_HAS_DATA` en la cláusula WHEN de la task para evitar ejecuciones vacías
- Configura `SUSPEND_TASK_AFTER_NUM_FAILURES` apropiadamente para detener errores descontrolados
- Usa tasks serverless a menos que necesites controlar el tamaño del warehouse
- Prefiere dynamic tables sobre stream+task para pipelines de transformación pura
- Monitorea tasks via `TASK_HISTORY` en ACCOUNT_USAGE

**Trampa del examen:** SI VES "los streams funcionan en vistas" → **INCORRECTO** porque los streams funcionan en tablas (y external tables), no en vistas.

**Trampa del examen:** SI VES "las tasks hijas pueden tener su propia programación" → **INCORRECTO** porque solo la task raíz tiene programación; las hijas se disparan por la finalización del padre.

**Trampa del examen:** SI VES "los streams nunca caducan" → **INCORRECTO** porque un stream caduca si no se consume dentro de la retención de Time Travel de la fuente + 14 días.

**Trampa del examen:** SI VES "las tasks se reanudan por defecto después de crearlas" → **INCORRECTO** porque las tasks se crean en estado SUSPENDED y deben reanudarse explícitamente.

### Preguntas Frecuentes (FAQ)
**P: ¿Pueden existir múltiples streams en la misma tabla?**
R: Sí. Cada stream rastrea independientemente con su propio offset.

**P: ¿Qué pasa si un stream caduca?**
R: Se vuelve inutilizable. Debes recrearlo. El offset se pierde y puede que necesites una recarga completa.

**P: ¿Las tasks pueden llamar stored procedures?**
R: Sí. El cuerpo de una task puede ser cualquier sentencia SQL individual, incluyendo `CALL mi_procedimiento()`.


### Ejemplos de Preguntas de Escenario — Streams & Tasks

**Escenario:** An e-commerce platform needs to merge incremental order updates (inserts, updates, deletes) from a raw orders table into a curated orders table every 5 minutes. The merge logic includes custom conflict resolution (e.g., latest timestamp wins for updates). What pipeline architecture should the architect use?
**Respuesta:** Create a standard stream on the raw orders table to capture all DML changes (inserts, updates, deletes). Create a task with a 5-minute schedule and a `WHEN SYSTEM$STREAM_HAS_DATA(''orders_stream'')` clause to avoid empty runs. The task body executes a MERGE statement that reads from the stream and applies custom conflict resolution logic (e.g., `WHEN MATCHED AND src.updated_at > tgt.updated_at THEN UPDATE`). Use serverless tasks unless the MERGE is complex enough to warrant a dedicated warehouse. Set `SUSPEND_TASK_AFTER_NUM_FAILURES` to stop runaway errors and monitor via `TASK_HISTORY`.

**Escenario:** A data platform has a complex ETL pipeline: raw data must be cleaned, then enriched with reference data, then aggregated into summary tables. Each step depends on the previous one completing successfully. If any step fails, a notification must be sent. How should the architect orchestrate this?
**Respuesta:** Build a task tree (DAG). The root task runs on a schedule and performs the cleaning step. A child task handles enrichment (triggered automatically on root success). A grandchild task handles aggregation. Add a finalizer task to the DAG — it runs after all tasks complete (whether they succeed or fail) and sends an email notification with the outcome. Only the root task has a schedule; children trigger on parent completion. Use `ALLOW_OVERLAPPING_EXECUTION = FALSE` on the root to prevent concurrent runs. Alternatively, if the pipeline is pure SQL transformations without custom merge logic, consider chaining dynamic tables instead — they handle scheduling and incremental refresh declaratively.

---

---

## 3.4 EXTERNAL TABLES E ICEBERG TABLES

**External Tables**

- Tabla de solo lectura sobre archivos en almacenamiento externo (S3, GCS, Azure)
- Snowflake solo almacena metadatos; los datos permanecen en tu almacenamiento en la nube
- Soporta auto-refresh de metadatos via notificaciones en la nube
- Rendimiento de consultas más lento que tablas nativas (sin clustering, sin optimización de micro-partitions)
- Soporte para particionamiento via columnas calculadas `PARTITION BY`
- Streams en external tables: solo insert (rastrean archivos nuevos)

**Managed Iceberg Tables**

- Snowflake administra el ciclo de vida de la tabla (ruta de escritura, compactación, snapshots)
- El external volume define DÓNDE se almacenan los datos (tu almacenamiento en la nube)
- DML completo: INSERT, UPDATE, DELETE, MERGE
- No se requiere catalog integration (Snowflake es el catálogo)
- Otros motores pueden leer los archivos de metadatos/datos Iceberg
- Soporta Time Travel, cloning, replicación

**Unmanaged Iceberg Tables (Vinculadas a Catálogo)**

- Un catálogo externo (Glue, Polaris/OpenCatalog, Unity, REST) administra los metadatos
- Snowflake lee el catálogo para entender la estructura de la tabla
- Solo lectura desde Snowflake (las escrituras van a través del motor externo)
- Requiere objeto CATALOG INTEGRATION
- Auto-refresh detecta cambios en el catálogo

**Incremental vs Full Refresh (Contexto Dynamic/Iceberg)**

- **Full refresh:** recalcula todo el dataset (costoso pero simple)
- **Incremental refresh:** solo procesa datos cambiados (más económico, requiere change tracking)
- Las dynamic tables usan incremental refresh cuando es posible (depende del operador)
- Algunas operaciones fuerzan full refresh (ej., funciones no determinísticas, joins complejos)

### Por Qué Esto Importa
Una empresa ejecuta tanto Spark como Snowflake. Las managed Iceberg tables permiten a Snowflake escribir datos en formato Iceberg a S3. Spark lee los mismos archivos directamente. Una copia de datos, dos motores.

### Mejores Prácticas
- Usa managed Iceberg para nuevos requisitos de "formato abierto" con Snowflake como motor principal
- Usa unmanaged/vinculadas a catálogo para datos propiedad de otro motor (Spark, Trino)
- Las external tables son legacy para acceso de solo lectura — prefiere Iceberg para proyectos nuevos
- Particiona external tables por fecha/región para query pruning

**Trampa del examen:** SI VES "las external tables soportan UPDATE/DELETE" → **INCORRECTO** porque las external tables son de solo lectura.

**Trampa del examen:** SI VES "las unmanaged Iceberg tables soportan MERGE" → **INCORRECTO** porque las escrituras deben pasar por el catálogo/motor externo.

**Trampa del examen:** SI VES "las managed Iceberg tables almacenan datos en el almacenamiento interno de Snowflake" → **INCORRECTO** porque escriben en un external volume (tu almacenamiento en la nube) en formato Iceberg.

**Trampa del examen:** SI VES "las dynamic tables siempre usan incremental refresh" → **INCORRECTO** porque ciertas operaciones fuerzan full refresh.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo convertir una external table a una tabla nativa?**
R: No directamente. Harías CTAS desde la external table hacia una nueva tabla nativa (o Iceberg).

**P: ¿Las managed Iceberg tables soportan clustering?**
R: Sí. Puedes definir clustering keys en managed Iceberg tables.

**P: ¿Cuál es la diferencia entre una external table y una unmanaged Iceberg table?**
R: Las external tables trabajan con archivos crudos (CSV, Parquet, etc.) con metadatos definidos por Snowflake. Las unmanaged Iceberg tables leen tablas en formato Iceberg administradas por un catálogo externo con capacidades completas de Iceberg (snapshots, evolución de esquema).


### Ejemplos de Preguntas de Escenario — External & Iceberg Tables

**Escenario:** A company''s data science team uses Apache Spark on EMR to train ML models, and the analytics team uses Snowflake for reporting. Both teams need read/write access to the same feature store tables. Currently, data is duplicated in both Parquet files and Snowflake tables, causing consistency issues. How should the architect unify the data layer?
**Respuesta:** Migrate the feature store to managed Iceberg tables in Snowflake. Define an external volume pointing to S3 where the Iceberg data and metadata files will be stored. Snowflake manages the table lifecycle — full DML (INSERT, UPDATE, DELETE, MERGE), compaction, and snapshot management. The Spark team reads the same Iceberg metadata and data files from S3 directly using Spark''s Iceberg connector. One copy of data, two engines, full consistency. Managed Iceberg tables also support Time Travel and clustering for the Snowflake analytics team.

**Escenario:** A partner organization manages their data catalog in AWS Glue and writes Iceberg tables from their Spark pipelines. Your company needs to query this data from Snowflake without taking ownership of the catalog. How should the architect set this up?
**Respuesta:** Create an unmanaged (catalog-linked) Iceberg table in Snowflake. Configure a catalog integration pointing to the partner''s AWS Glue catalog. Snowflake reads the Glue-managed Iceberg metadata to understand the table structure and queries the data files directly from S3. This is read-only from Snowflake — all writes continue through the partner''s Spark pipelines. Enable auto-refresh on the catalog integration so Snowflake detects when the partner updates the table. Do not use a managed Iceberg table here, as that would transfer catalog ownership to Snowflake and conflict with the partner''s Spark writes.

---

---

## 3.5 TRANSFORMACIÓN DE DATOS

**FLATTEN**

- Convierte datos semi-estructurados (JSON, ARRAY, VARIANT) en filas
- Lateral join por defecto: `SELECT ... FROM tabla, LATERAL FLATTEN(input => col)`
- Parámetros clave: `INPUT`, `PATH`, `OUTER` (mantener filas con arrays vacíos), `RECURSIVE`, `MODE`
- Columnas de salida: `SEQ`, `KEY`, `PATH`, `INDEX`, `VALUE`, `THIS`

**UDFs (Funciones Definidas por el Usuario)**

- SQL, JavaScript, Python, Java, Scala
- UDFs escalares: retornan un valor por fila de entrada
- Deben ser determinísticas para uso en materialized views / clustering
- Secure UDFs: ocultan el cuerpo de la función a los consumidores

**UDTFs (Funciones de Tabla Definidas por el Usuario)**

- Retornan una tabla (múltiples filas por fila de entrada)
- Deben implementar: `PROCESS()` (lógica por fila) y opcionalmente `END_PARTITION()` (salida final)
- Se llaman con `TABLE()` en la cláusula FROM
- Útiles para: parsing, explosión, agregación personalizada

**External Functions**

- Llaman endpoints de API externos (ej., AWS Lambda, Azure Functions) desde SQL
- Requieren: API integration + definición de external function
- Sincrónicas: Snowflake llama la API por lote y espera
- Usar para: inferencia ML, enriquecimiento de terceros, lógica personalizada no disponible en Snowflake
- Siendo reemplazadas por UDFs basadas en contenedores (SPCS) para nuevos casos de uso

**Stored Procedures**

- Pueden contener flujo de control (IF, LOOP, BEGIN/END), múltiples sentencias SQL
- Lenguajes: SQL (Snowflake Scripting), JavaScript, Python, Java, Scala
- Pueden ejecutarse con derechos de CALLER o derechos de OWNER
- Usar para: tareas administrativas, ETL complejo, operaciones de múltiples pasos
- Diferencia clave con UDFs: los procedures pueden tener efectos secundarios (DML), las UDFs no

**Dynamic Tables**

- Transformación declarativa: define el objetivo como una consulta SQL + target lag
- Snowflake refresca automáticamente (incremental cuando es posible)
- Reemplazan cadenas complejas de stream+task para pipelines de transformación
- Target lag: `DOWNSTREAM` (cascada desde DTs upstream) o intervalo explícito
- No pueden usarse como fuente directa para streams

**Secure Functions**

- UDFs/UDTFs con palabra clave `SECURE`: el cuerpo se oculta a los consumidores
- Requeridas para funciones usadas en Secure Data Sharing
- Mismo fence del optimizador que las secure views

### Por Qué Esto Importa
Un pipeline aplana eventos JSON crudos, los enriquece via una external function (scoring ML), y deposita los resultados en una dynamic table con target lag de 5 minutos. Cero gestión de task/stream.

### Mejores Prácticas
- Prefiere dynamic tables sobre stream+task para pipelines solo de transformación
- Usa SQL UDFs para cálculos simples; Python UDFs para lógica compleja
- Minimiza las llamadas a external functions (overhead de red por lote)
- Usa stored procedures para flujos de trabajo administrativos, no para transformación de datos
- Configura el target lag de dynamic tables basándote en el SLA del negocio, no lo más bajo posible

**Trampa del examen:** SI VES "las UDFs pueden ejecutar sentencias DML" → **INCORRECTO** porque las UDFs son de solo lectura; solo los stored procedures pueden ejecutar DML.

**Trampa del examen:** SI VES "las dynamic tables pueden ser fuentes para streams" → **INCORRECTO** porque no puedes crear streams sobre dynamic tables.

**Trampa del examen:** SI VES "las external functions se ejecutan dentro del cómputo de Snowflake" → **INCORRECTO** porque llaman a un endpoint de API externo fuera de Snowflake.

**Trampa del examen:** SI VES "FLATTEN solo funciona con JSON" → **INCORRECTO** porque FLATTEN funciona con cualquier tipo semi-estructurado: VARIANT, ARRAY, OBJECT.

### Preguntas Frecuentes (FAQ)
**P: ¿Puedo usar Python UDFs en materialized views?**
R: No. Las MVs solo soportan expresiones SQL (sin UDFs, sin external functions).

**P: ¿Cuál es la diferencia entre target lag DOWNSTREAM y un intervalo específico?**
R: DOWNSTREAM significa "refrescar cada vez que mi dynamic table upstream se refresque." Un intervalo específico (ej., 5 MINUTES) significa "asegurar que los datos no tengan más de 5 minutos de antigüedad."

**P: ¿Las dynamic tables pueden referenciar otras dynamic tables?**
R: Sí. Esto crea un pipeline de dynamic tables (DAG), donde los refreshes upstream se propagan downstream.


### Ejemplos de Preguntas de Escenario — Data Transformation

**Escenario:** A data platform ingests raw JSON events with deeply nested arrays (e.g., an order contains an array of items, each item contains an array of discounts). The analytics team needs a flat, relational table with one row per discount. Some orders have no discounts and must still appear in the output. How should the architect design the transformation?
**Respuesta:** Use nested LATERAL FLATTEN to expand the multi-level arrays. First FLATTEN the items array, then FLATTEN the discounts array within each item. Use `OUTER => TRUE` on the discounts FLATTEN to preserve orders/items that have empty discount arrays (they appear as NULL discount rows instead of being dropped). The query pattern: `SELECT ... FROM orders, LATERAL FLATTEN(INPUT => items, OUTER => TRUE) AS i, LATERAL FLATTEN(INPUT => i.VALUE:discounts, OUTER => TRUE) AS d`. Materialize this as a dynamic table with an appropriate target lag so the flat table stays current as new events arrive.

**Escenario:** A company has a complex transformation pipeline: raw → cleaned → enriched → aggregated. Currently this is managed with 4 stream+task pairs, and the team spends significant time debugging task failures, managing stream staleness, and handling scheduling edge cases. How should the architect simplify this?
**Respuesta:** Replace the stream+task chain with a pipeline of dynamic tables. Define each layer as a dynamic table with a SQL query referencing the previous layer: `raw_dt → cleaned_dt → enriched_dt → aggregated_dt`. Set target lag based on business SLAs — the final aggregated table might use `TARGET_LAG = ''5 MINUTES''` while intermediate tables use `TARGET_LAG = DOWNSTREAM` (refresh when downstream needs data). Snowflake handles scheduling, incremental refresh, and error management declaratively. This eliminates manual stream offset management, task scheduling, and staleness risks. Note: dynamic tables work best for pure SQL transformations; if you need custom merge logic or procedural control flow, stream+task remains appropriate.

**Escenario:** The data engineering team needs a stored procedure that loops through all databases in the account, creates a governance tag on each, and grants APPLY TAG privileges to a specific role. A junior engineer asks why they can''t use a UDF for this. What should the architect explain?
**Respuesta:** UDFs cannot execute DML or DDL statements — they are read-only functions usable in SELECT. This task requires DDL (`CREATE TAG`) and DCL (`GRANT`) operations, which only stored procedures can perform. Create a stored procedure using Snowflake Scripting (SQL) with a RESULTSET cursor to iterate over `SHOW DATABASES`, then execute `CREATE TAG IF NOT EXISTS` and `GRANT APPLY TAG` for each database. The procedure should run with CALLER rights so it executes under the invoking role''s permissions, ensuring proper authorization checks.

---

---

## 3.6 HERRAMIENTAS DEL ECOSISTEMA

**Kafka Connector**

- Transmite datos de topics de Kafka a tablas de Snowflake
- Dos versiones: **basada en Snowpipe** (archivos a stage, luego COPY) y **Snowpipe Streaming** (inserción directa de filas, menor latencia)
- Soporta semántica de exactamente una vez
- Maneja evolución de esquema (campos nuevos en JSON)
- Administrado por Snowflake o auto-hospedado

**Spark Connector**

- Bidireccional: leer desde y escribir a Snowflake desde Spark
- Empuja consultas a Snowflake cuando es posible (predicate pushdown)
- Soporta API de DataFrame y SQL
- Configuración clave: `sfURL`, `sfUser`, `sfPassword`, `sfDatabase`, `sfSchema`, `sfWarehouse`

**Python Connector**

- Librería nativa de Python (`snowflake-connector-python`)
- Soporta `write_pandas()` para carga masiva de DataFrames
- Se integra con SQLAlchemy
- Soporte de consultas asincrónicas para consultas de larga duración
- `snowflake-snowpark-python` — API de DataFrame que se ejecuta en cómputo de Snowflake

**JDBC / ODBC**

- Conectividad estándar de base de datos para Java (JDBC) y otros lenguajes (ODBC)
- Snowflake proporciona sus propios drivers JDBC y ODBC
- Soportan todas las operaciones SQL estándar
- Usados por la mayoría de herramientas de BI (Tableau, Power BI, Looker)

**SQL API (REST)**

- Endpoint HTTP REST para ejecutar SQL
- Enviar sentencias, verificar estado, obtener resultados via llamadas REST
- Usa OAuth o tokens de par de claves para autenticación
- Ejecución asincrónica: enviar → consultar estado → obtener resultados
- Útil para arquitecturas serverless, microservicios

**Snowpark**

- Framework de desarrollo para Python, Java, Scala
- API de DataFrame que se ejecuta en el cómputo de Snowflake (sin movimiento de datos)
- Soporta UDFs, UDTFs y stored procedures
- Ideal para pipelines de ML, transformaciones complejas
- Evaluación perezosa: las operaciones construyen un plan, se ejecutan en `.collect()` o acción

### Por Qué Esto Importa
Una plataforma de datos usa el Kafka connector para ingesta en tiempo real, Snowpark para ingeniería de features de ML, y JDBC para herramientas de BI. El arquitecto debe saber qué conector aplica a cada caso de uso.

### Mejores Prácticas
- Usa Kafka connector con Snowpipe Streaming para la menor latencia
- Usa Snowpark en lugar de extraer datos a Python/Spark cuando sea posible (el cómputo se queda en Snowflake)
- Usa SQL API para integraciones ligeras y apps serverless
- Siempre usa los drivers más recientes proporcionados por Snowflake (se actualizan frecuentemente)
- Usa autenticación key-pair para todas las conexiones programáticas/de servicio

**Trampa del examen:** SI VES "el Spark connector siempre mueve todos los datos a Spark" → **INCORRECTO** porque soporta predicate pushdown, empujando filtros a Snowflake.

**Trampa del examen:** SI VES "SQL API es solo sincrónico" → **INCORRECTO** porque soporta ejecución asincrónica (enviar → consultar → obtener).

**Trampa del examen:** SI VES "Snowpark requiere extraer datos de Snowflake" → **INCORRECTO** porque Snowpark se ejecuta en el cómputo de Snowflake; los datos se quedan en Snowflake.

**Trampa del examen:** SI VES "el Kafka connector solo soporta JSON" → **INCORRECTO** porque soporta JSON, Avro y Protobuf (con schema registry).

### Preguntas Frecuentes (FAQ)
**P: ¿Cuándo debo usar el Spark connector vs Snowpark?**
R: Usa el Spark connector cuando ya tengas infraestructura Spark y necesites integrar Snowflake en pipelines existentes. Usa Snowpark cuando quieras ejecutar todo el cómputo en Snowflake sin un cluster de Spark.

**P: ¿La SQL API puede manejar conjuntos de resultados grandes?**
R: Sí, via paginación de conjuntos de resultados. Los resultados grandes se retornan en particiones que obtienes incrementalmente.

**P: ¿El Kafka connector soporta evolución de esquema?**
R: Sí. Los campos nuevos en payloads JSON se cargan en la columna VARIANT. Si usas evolución de esquema en la tabla destino, las columnas se agregan automáticamente.


### Ejemplos de Preguntas de Escenario — Ecosystem Tools

**Escenario:** A company has an existing Spark-based ML pipeline on Databricks that processes 500 GB of features daily. They''re migrating analytics to Snowflake but don''t want to rewrite the Spark pipeline. The Spark pipeline needs to read from and write to Snowflake tables. How should the architect integrate the two systems?
**Respuesta:** Use the Snowflake Spark connector. Configure it with the Snowflake connection parameters (`sfURL`, `sfUser`, `sfWarehouse`, etc.) and use key-pair authentication for the service account. The Spark connector supports bidirectional data movement and pushes predicates down to Snowflake when reading (minimizing data transfer). For the longer-term, evaluate migrating the ML pipeline to Snowpark — which runs the DataFrame API directly on Snowflake compute without moving data out. But for immediate integration without rewriting, the Spark connector is the correct choice.

**Escenario:** A microservices architecture on AWS Lambda needs to execute Snowflake queries. The Lambda functions are stateless, short-lived, and cannot maintain persistent database connections. What connectivity approach should the architect recommend?
**Respuesta:** Use the Snowflake SQL API (REST). Lambda functions submit SQL statements via HTTP POST, then poll for status and fetch results asynchronously. The SQL API supports OAuth or key-pair tokens for authentication — no persistent database connections needed. This fits the stateless, ephemeral nature of Lambda. For larger result sets, the API returns paginated results that Lambda can fetch incrementally. Avoid JDBC/ODBC in Lambda since connection pooling is impractical in short-lived serverless functions.

**Escenario:** A data science team currently extracts 100 GB of data from Snowflake to their local Python environment using the Python connector and pandas for feature engineering. The extraction takes 45 minutes and overwhelms local memory. How should the architect improve this workflow?
**Respuesta:** Migrate the feature engineering logic to Snowpark. Snowpark provides a pandas-like DataFrame API that executes directly on Snowflake''s compute — no data extraction needed. The data stays in Snowflake, operations are lazily evaluated and pushed down to the warehouse, and results are only materialized on `.collect()` or when writing to a table. This eliminates the 45-minute extraction, local memory constraints, and data movement costs. Snowpark supports Python UDFs and stored procedures for complex ML logic that can''t be expressed in SQL.

---

---

## PARES CONFUSOS — Ingeniería de Datos

| Preguntan sobre... | La respuesta es... | NO... |
|---|---|---|
| **Snowpipe** vs **COPY INTO** | **Snowpipe** = serverless, orientado a eventos, continuo (archivos disparan la carga) | **COPY INTO** = comando manual/programado por lotes, lo ejecutas explícitamente |
| **Snowpipe** vs **Snowpipe Streaming** | **Snowpipe** = basado en archivos (notificaciones en la nube → micro-batch) | **Streaming** = basado en filas (Ingest SDK, sin archivos, latencia sub-segundo) |
| **Objeto PIPE** vs **objeto CHANNEL** | **PIPE** = usado por Snowpipe regular (`CREATE PIPE`) | **CHANNEL** = usado por Snowpipe Streaming (Ingest SDK, no necesita PIPE) |
| **Stream** vs **Task** | **Stream** = rastreador CDC (registra cambios en una tabla) | **Task** = ejecutor SQL programado (cron/intervalo). Son *socios*, no sustitutos |
| **Standard stream** vs **append-only stream** | **Standard** = rastrea INSERT + UPDATE + DELETE | **Append-only** = rastrea solo INSERTs (más económico, más simple) |
| **External table** vs **Iceberg table** | **External** = archivos crudos (CSV, Parquet), solo lectura, metadatos Snowflake | **Iceberg** = formato Iceberg, managed = DML completo, unmanaged = vinculada a catálogo |
| **Detección de esquema** vs **evolución de esquema** | **Detección** (`INFER_SCHEMA`) = lee archivo para descubrir columnas *una vez* | **Evolución** = agrega automáticamente columnas nuevas a la tabla *de forma continua* |
| **UDF** vs **UDTF** | **UDF** = un valor por fila (escalar) | **UDTF** = múltiples filas por entrada (función de tabla, usa PROCESS + END_PARTITION) |
| **UDF** vs **stored procedure** | **UDF** = solo lectura, sin efectos secundarios, usable en SELECT | **Procedure** = puede hacer DML, flujo de control, efectos secundarios, se llama via CALL |
| **External function** vs **UDF** | **External function** = llama una API *fuera* de Snowflake (Lambda, Azure Func) | **UDF** = se ejecuta *dentro* del cómputo de Snowflake |
| **Dynamic table** vs **stream + task** | **Dynamic table** = declarativa (define SQL + target lag, Snowflake administra el refresh) | **Stream + task** = imperativa (tú administras CDC + programación + manejo de errores) |
| **Directory table** vs **external table** | **Directory table** = metadatos sobre *archivos* en un stage (nombre, tamaño, fecha) | **External table** = *datos dentro de* archivos consultables en almacenamiento externo |
| **User stage** vs **table stage** vs **named stage** | **User** (`@~`) = por usuario, privado, no se puede compartir | **Table** (`@%t`) = por tabla, opciones limitadas | **Named** (`@s`) = explícito, el más flexible |
| **Target lag DOWNSTREAM** vs **intervalo explícito** | **DOWNSTREAM** = refrescar cuando la DT upstream se refresque | **Explícito** (ej., 5 MIN) = datos no más antiguos de N minutos |
| **VALIDATION_MODE** vs **ON_ERROR** | **VALIDATION_MODE** = ejecución de prueba, no se cargan datos | **ON_ERROR** = controla comportamiento *durante* la carga real (CONTINUE, ABORT, SKIP_FILE) |

---

## ÁRBOLES DE DECISIÓN POR ESCENARIO — Ingeniería de Datos

**Escenario 1: "500 archivos CSV llegan diariamente a S3 desde sistemas POS de tiendas..."**
- **CORRECTO:** **Snowpipe** con auto-ingesta (notificación de eventos S3 dispara la carga)
- TRAMPA: *"COPY INTO programado cada hora"* — **INCORRECTO**, pierde archivos entre ejecuciones, mayor latencia, más costo de warehouse

**Escenario 2: "Sensores IoT envían 10K eventos/segundo, necesitan latencia sub-segundo..."**
- **CORRECTO:** **Snowpipe Streaming** (Ingest SDK, nivel de fila, sin archivos)
- TRAMPA: *"Snowpipe regular"* — **INCORRECTO**, Snowpipe es basado en archivos con latencia de segundos a minutos; Streaming es sub-segundo

**Escenario 3: "La fuente agrega columnas nuevas frecuentemente, la tabla debe adaptarse automáticamente..."**
- **CORRECTO:** **Evolución de esquema** (`ENABLE_SCHEMA_EVOLUTION = TRUE`) + `MATCH_BY_COLUMN_NAME`
- TRAMPA: *"INFER_SCHEMA antes de cada carga"* — **INCORRECTO**, INFER_SCHEMA es detección de una vez, no evolución continua

**Escenario 4: "Necesito hacer merge de cambios incrementales de raw a curated cada 5 minutos..."**
- **CORRECTO:** **Stream en tabla raw** + **Task** con `SYSTEM$STREAM_HAS_DATA` + sentencia MERGE
- TRAMPA: *"Dynamic table"* — posible pero las dynamic tables no soportan lógica de MERGE con resolución de conflictos personalizada; stream+task da control total

**Escenario 5: "Construir un pipeline de transformación: raw → limpio → agregado, puro SQL..."**
- **CORRECTO:** **Dynamic tables** encadenadas (raw DT → cleaned DT → agg DT con target lag)
- TRAMPA: *"Tres pares de stream+task"* — **INCORRECTO**, innecesariamente complejo; las dynamic tables manejan esto declarativamente

**Escenario 6: "Llamar una API de scoring ML externa desde una consulta SQL..."**
- **CORRECTO:** **External function** (API integration + definición de función)
- TRAMPA: *"Python UDF"* — **INCORRECTO**, Python UDF se ejecuta dentro de Snowflake; no puede llamar APIs externas sin una external access integration

**Escenario 7: "Necesito aplanar arrays JSON anidados en filas para analítica..."**
- **CORRECTO:** **LATERAL FLATTEN** con `INPUT => columna`, opcionalmente `OUTER => TRUE` para arrays vacíos
- TRAMPA: *"PARSE_JSON + extracción manual"* — **INCORRECTO**, FLATTEN está diseñado para esto y maneja arrays anidados nativamente

**Escenario 8: "Tarea administrativa: recorrer bases de datos, crear tags, ejecutar grants..."**
- **CORRECTO:** **Stored procedure** (Snowflake Scripting con IF/LOOP/BEGIN-END)
- TRAMPA: *"UDF"* — **INCORRECTO**, las UDFs no pueden ejecutar DML (CREATE, GRANT, ALTER)

**Escenario 9: "Necesito rastrear qué archivos existen en un stage y cuándo llegaron..."**
- **CORRECTO:** **Directory table** en el stage (`ENABLE = TRUE`, auto-refresh para externo)
- TRAMPA: *"External table"* — **INCORRECTO**, las external tables consultan *contenidos* de archivos, no *metadatos* de archivos

**Escenario 10: "Topics de Kafka necesitan llegar a Snowflake con la menor latencia posible..."**
- **CORRECTO:** **Kafka connector con modo Snowpipe Streaming** (inserción directa de filas)
- TRAMPA: *"Kafka connector con modo Snowpipe"* — no es incorrecto, pero mayor latencia (basado en archivos); el modo Streaming es de menor latencia

**Escenario 11: "Validación de datos antes de cargar — verificar filas malas sin cargar realmente..."**
- **CORRECTO:** `COPY INTO ... VALIDATION_MODE = ''RETURN_ERRORS''` (ejecución de prueba)
- TRAMPA: *"Cargar con ON_ERROR = CONTINUE luego verificar errores"* — **INCORRECTO**, esto realmente carga datos; VALIDATION_MODE no carga nada

**Escenario 12: "Ingeniería de features ML en Python sobre datos ya en Snowflake..."**
- **CORRECTO:** **Snowpark** (API de DataFrame se ejecuta en cómputo de Snowflake, sin movimiento de datos)
- TRAMPA: *"Python connector + pandas"* — **INCORRECTO**, esto saca datos de Snowflake a la máquina local; Snowpark mantiene el cómputo en Snowflake

---

## FLASHCARDS -- Dominio 3

**P1:** ¿Cuál es la ventana de deduplicación de Snowpipe?
**R1:** 14 días. Los archivos cargados en los últimos 14 días se rastrean y no se reingerirán.

**P2:** ¿Qué objeto usa Snowpipe Streaming en lugar de un PIPE?
**R2:** Objetos CHANNEL (via el Ingest SDK).

**P3:** ¿La evolución de esquema puede eliminar columnas de una tabla?
**R3:** No. Solo agrega columnas nuevas.

**P4:** ¿Cuáles son los tres tipos de stream?
**R4:** Standard (todo DML), Append-only (solo inserts), Insert-only (external tables, archivos nuevos).

**P5:** ¿En qué estado se crean las tasks?
**R5:** SUSPENDED. Deben reanudarse explícitamente.

**P6:** ¿Las UDFs pueden ejecutar DML?
**R6:** No. Solo los stored procedures pueden ejecutar DML (INSERT, UPDATE, DELETE).

**P7:** ¿Cuál es la diferencia clave entre una external function y una UDF?
**R7:** Las external functions llaman un endpoint de API fuera de Snowflake; las UDFs se ejecutan dentro del cómputo de Snowflake.

**P8:** ¿Qué hace FLATTEN?
**R8:** Convierte datos semi-estructurados (VARIANT, ARRAY, OBJECT) en filas relacionales.

**P9:** ¿Cuál es el propósito de una storage integration?
**R9:** Proporciona acceso seguro y sin credenciales al almacenamiento externo en la nube usando IAM roles o service principals.

**P10:** ¿Cómo difiere Snowpark del Python connector?
**R10:** Snowpark ejecuta una API de DataFrame en el cómputo de Snowflake (sin movimiento de datos). El Python connector ejecuta consultas desde un cliente Python.

**P11:** ¿Puedes crear un stream sobre una dynamic table?
**R11:** No. Los streams no pueden crearse sobre dynamic tables.

**P12:** ¿Qué hace `VALIDATION_MODE` en COPY INTO?
**R12:** Realiza una ejecución de prueba — valida datos sin cargarlos realmente.

**P13:** ¿Qué es una directory table?
**R13:** Una capa de metadatos en un stage que permite consultar atributos de archivos (nombre, tamaño, last_modified) via SQL.

**P14:** ¿Qué dispara las tasks hijas en un árbol de tasks?
**R14:** La finalización exitosa de la task padre. Solo la task raíz tiene programación.

**P15:** ¿Qué es target lag DOWNSTREAM en una dynamic table?
**R15:** La dynamic table se refresca cada vez que su dynamic table upstream se refresca, propagándose a través del pipeline.

---

## EXPLICAR COMO SI TUVIERA 5 AÑOS -- Dominio 3

**1. COPY INTO**
Imagina que tienes una caja grande de piezas de rompecabezas (archivos). COPY INTO vuelca todas esas piezas en tu tablero de rompecabezas (tabla) de una vez. Lo haces cuando tienes toda una caja lista.

**2. Snowpipe**
Ahora imagina que alguien desliza piezas de rompecabezas por debajo de tu puerta una por una mientras las encuentra. Eso es Snowpipe — las piezas llegan y se colocan automáticamente sin que hagas nada.

**3. Snowpipe Streaming**
Aún más rápido: alguien está LANZANDO piezas de rompecabezas por tu ventana tan rápido como las recoge. Sin esperar a juntar una pila. Cada pieza llega instantáneamente.

**4. Streams (CDC)**
Un cuaderno mágico que anota cada vez que alguien agrega, cambia o quita un juguete de la caja de juguetes. Cuando lees el cuaderno, se borra solo y empieza de nuevo.

**5. Tasks**
Un reloj despertador que suena cada N minutos y dice "¡Hora de hacer tus tareas!" Tu tarea es una sentencia SQL. Puedes configurar una cadena: "Después de lavar los platos, barre el piso."

**6. FLATTEN**
Tienes una bolsa de bolsas de dulces. FLATTEN abre todas las bolsas internas y vierte todo en una gran pila para que puedas contar cada dulce individualmente.

**7. Dynamic Tables**
Una pizarra mágica que se actualiza automáticamente. Escribiste las reglas una vez ("muéstrame ventas totales por tienda"), y cada pocos minutos la pizarra se borra y se redibuja con los números más recientes.

**8. External Tables**
Mirar a través de una ventana al jardín de tu vecino. Puedes VER las flores (leer los datos) pero no puedes tocarlas ni reorganizarlas (sin escrituras). Las flores se quedan en su jardín.

**9. Stages**
Tu casillero en la escuela. Pones tu mochila (archivos) en tu casillero (stage) antes de sacar las cosas en clase (cargar en tablas). Algunos casilleros son tuyos (internos), otros son armarios de almacenamiento compartido (externos).

**10. Kafka Connector**
Una banda transportadora de una fábrica (Kafka) a tu almacén (Snowflake). Los artículos siguen llegando automáticamente. Si la banda usa la versión Streaming, los artículos llegan aún más rápido sin necesitar empaque primero.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 'en',
  '# Domain 4: Performance — Tools, Best Practices & Troubleshooting

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
- If scanned ≈ total → clustering key is missing or filter doesn''t match clustering

### Why This Matters

You have a report query taking 45 minutes. Query Profile shows a JoinFilter with 50B rows output from two 10M-row tables. The join condition is missing a key column — cartesian join. Without Query Profile, you''d just upsize the warehouse and waste credits.

### Best Practices

- Check **"Most Expensive Nodes"** panel first — the top 1-2 nodes are usually the bottleneck
- Look at **Statistics → Spilling** before upsizing warehouses
- Use `SYSTEM$EXPLAIN_PLAN()` for quick checks without running the query
- Compare pruning stats before/after adding clustering keys

**Exam traps:**

- Exam trap: IF YOU SEE "Query is slow, increase warehouse size" → WRONG because you should diagnose with Query Profile first; the problem might be a bad join or missing filter, not insufficient compute
- Exam trap: IF YOU SEE "Spilling to local disk is a critical issue" → WRONG because local spilling is a moderate concern; spilling to **remote storage** is the severe one
- Exam trap: IF YOU SEE "Query Profile shows execution plan before running" → WRONG because Query Profile shows **actual execution** stats; use `EXPLAIN_PLAN` for pre-execution plans

### Query Profile Metric Details

- **"Processing" indicator:** Means the operator is spending time on **CPU computation**. High processing time = complex calculations or functions.
- **"Local Disk IO" indicator:** Means the operator is **blocked waiting for local disk access** (SSD reads/writes). May indicate spilling to local storage.
- **"Percentage scanned from cache":** Refers to the **local disk cache** (warehouse SSD), NOT the result cache. High percentage = good cache utilization.
- **"Bytes scanned" location:** Found in the **Statistics panel**, NOT in the Execution Time screen. Common exam trick.
- **"Bytes sent over the network":** Visible in the Statistics panel. Shows data fetched from **remote storage** (not from cache). High value = poor cache utilization; data is being pulled from cloud storage instead of warehouse SSD.
- **COMPILATION_TIME > EXECUTION_TIME:** When the query spends more time compiling than executing, the cause is overly complex query logic (many joins, nested views, complex functions). Compilation happens in the **cloud services layer**, not the warehouse. Fixes: simplify query, materialize subqueries, reduce nested views. NOT fixed by: SOS, clustering, bigger warehouse, or more clusters.

**Exam traps:**

- **Exam trap:** IF YOU SEE "Compilation time can be reduced by upsizing the warehouse" → WRONG because compilation happens in the cloud services layer, not the warehouse. Fix complex queries, not compute
- **Exam trap:** IF YOU SEE "Percentage scanned from cache refers to the result cache" → WRONG because it refers to the **local disk cache** (warehouse SSD)
- **Exam trap:** IF YOU SEE "Bytes scanned is shown in the Execution Time panel" → WRONG because it''s in the **Statistics panel**

### Common Questions (FAQ)

**Q: Can I see Query Profile for queries run by other users?**
A: Yes, if you have ACCOUNTADMIN or MONITOR privilege on the warehouse. Otherwise, you only see your own queries.

**Q: How long are Query Profiles retained?**
A: 14 days in the web UI. Use ACCOUNT_USAGE.QUERY_HISTORY for up to 365 days (but without the visual DAG).

### Example Scenario Questions — Query Profile

**Scenario:** A nightly reporting job that used to complete in 10 minutes now takes 3 hours. The data engineering team''s first instinct is to upsize the warehouse from Large to 2XL. Before approving the cost increase, what should the architect require?
**Answer:** Require a Query Profile analysis before any warehouse resizing. Open the Query Profile for the slow query and check: (1) the "Most Expensive Nodes" panel to identify the bottleneck operator, (2) spilling statistics — if the query spills to remote storage, upsizing may help; if there''s no spilling, more compute won''t help, (3) TableScan pruning stats — if partitions scanned is close to partitions total, the issue is poor pruning (fix with clustering keys, not bigger warehouse), (4) JoinFilter — check for row explosion from bad join conditions. The root cause is often a missing filter, a cartesian join, or degraded clustering — none of which are fixed by upsizing.

**Scenario:** An analyst reports that a join between two 10-million-row tables produces a Query Profile showing a JoinFilter operator with 50 billion output rows. The warehouse eventually runs out of memory and the query fails. What is the likely root cause and how should the architect fix it?
**Answer:** The 50 billion rows from a join of two 10M-row tables indicates a cartesian or near-cartesian join — the join condition is either missing a key column or using a non-selective predicate. Check the Query Profile''s JoinFilter node for the join condition. The fix is correcting the SQL join logic (adding the missing key column), not upsizing the warehouse. Even a 6XL warehouse cannot efficiently process 50 billion rows from what should be a 10M-row result. Use `SYSTEM$EXPLAIN_PLAN()` to verify the corrected query plan before running it.

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

- Auto-suspend: set in **seconds** (minimum 60 seconds for non-zero values)
- `AUTO_SUSPEND = 0` or `NULL` = **never auto-suspend** (warehouse stays running until manually suspended)
- Auto-resume: `TRUE` by default — warehouse starts when a query hits it
- Suspended warehouses consume **zero credits**
- Each resume incurs provisioning time (~1-2 seconds typically)

### Why This Matters

Your data engineering team runs ETL at 2 AM on a 2XL warehouse that auto-suspends after 10 minutes. But 50 small queries trickle in every few minutes during the day, each resuming the warehouse. You''re paying 2XL credits for X-Small workloads. Solution: separate warehouses by workload type.

### Best Practices

- **Separate warehouses by workload** (ETL vs. BI vs. data science)
- Start small, scale up only after checking Query Profile
- Auto-suspend: **60 seconds** for ETL, **300-600 seconds** for BI (avoids constant resume)
- Use **Economy** scaling policy for cost-sensitive, latency-tolerant workloads
- Use **Standard** scaling policy for user-facing, latency-sensitive workloads

**Exam traps:**

- Exam trap: IF YOU SEE "Larger warehouse always means faster queries" → WRONG because query speed depends on the bottleneck; a bad query plan won''t improve with more compute
- Exam trap: IF YOU SEE "Multi-cluster warehouses run a single query across multiple clusters" → WRONG because each cluster runs separate queries; multi-cluster is for **concurrency**, not single-query parallelism
- Exam trap: IF YOU SEE "Snowpark-optimized warehouses are always better" → WRONG because they cost more and only help memory-intensive workloads (ML, large UDFs); standard is fine for SQL
- Exam trap: IF YOU SEE "AUTO_SUSPEND = 0 suspends the warehouse immediately" → WRONG because `AUTO_SUSPEND = 0` (or `NULL`) means **NEVER auto-suspend** — the warehouse runs indefinitely. The minimum non-zero auto-suspend value is 60 seconds. To suspend immediately, use `ALTER WAREHOUSE ... SUSPEND`

### Multi-Cluster Modes & Parameters

- **Auto-scale mode vs Maximized mode:**

| Mode | Behavior | Cost | Use Case |
|---|---|---|---|
| Auto-scale | Clusters scale between min and max based on load | Cost-effective | Most production workloads |
| Maximized | ALL clusters run at all times (min = max) | Higher cost | Predictable high-concurrency workloads |

- **Scaling policies are NOT modes:** Standard and Economy are the only two scaling policies. "Auto-scale" and "Maximized" are warehouse **modes**, not policies. Exam tests this distinction.
- **MAX_CONCURRENCY_LEVEL parameter:** Default is 8. Controls how many queries can run concurrently on a single cluster. Increase for many small concurrent queries. Set to 1 to give a single query ALL warehouse resources (useful for memory-intensive Snowpark procedures).
- **OPERATE privilege for warehouse resume:** When `AUTO_RESUME = FALSE`, a user needs the **OPERATE** privilege (not USAGE, not MODIFY, not MONITOR) to manually resume a suspended warehouse.
- **Data skew:** When data is non-uniformly distributed, one node processes significantly more data than others. Upsizing the warehouse does NOT help because the bottleneck is a single node. Fix: redistribute data, rewrite the query, or change the clustering key.
- **Warehouse sizing recommendation:** Snowflake officially recommends **experimenting** with different warehouse sizes on the same workload and comparing. Not "always start with X-Small" or "use defaults."

**Exam traps:**

- **Exam trap:** IF YOU SEE "Economy is a warehouse mode" → WRONG because Economy is a **scaling policy**. Auto-scale and Maximized are modes
- **Exam trap:** IF YOU SEE "USAGE privilege is needed to resume a warehouse" → WRONG because you need **OPERATE** privilege to resume a suspended warehouse
- **Exam trap:** IF YOU SEE "MAX_CONCURRENCY_LEVEL = 1 limits the warehouse to 1 query" → WRONG because it means each query gets the **full cluster resources**; the warehouse can still queue additional queries. Use this for memory-intensive operations (Snowpark, large UDFs)
- **Exam trap:** IF YOU SEE "Upsizing always fixes slow queries" → WRONG because data skew causes bottlenecks on single nodes that persist regardless of warehouse size

### Common Questions (FAQ)

**Q: Does warehouse size affect compilation time?**
A: No. Compilation happens in the cloud services layer, not the warehouse.

**Q: Can I resize a warehouse while queries are running?**
A: Yes. Running queries use the old size; new queries use the new size.

### Example Scenario Questions — Warehouses

**Scenario:** A company uses a single 2XL warehouse for all workloads: ETL at 2 AM, BI dashboards during business hours, and ad-hoc data science queries throughout the day. BI users complain about slow dashboards during ETL runs, and costs are high because the 2XL runs 24/7. How should the architect redesign the warehouse strategy?
**Answer:** Separate warehouses by workload type. Create a dedicated ETL warehouse (Large or XL, auto-suspend 60 seconds) that runs only during the 2 AM batch window. Create a BI warehouse (Medium, multi-cluster with Standard scaling policy, auto-suspend 300-600 seconds) for dashboard queries — the multi-cluster handles concurrency spikes during business hours, and the longer auto-suspend avoids constant resume overhead and preserves SSD cache. Create a data science warehouse (Snowpark-optimized if running ML/UDFs, standard otherwise, auto-suspend 120 seconds). This eliminates contention between workloads and right-sizes each warehouse independently.

**Scenario:** A data science team runs ML training jobs using Snowpark Python UDFs that process large in-memory datasets. Jobs frequently fail with out-of-memory errors on a standard XL warehouse. What should the architect recommend?
**Answer:** Switch to a Snowpark-optimized warehouse. Snowpark-optimized warehouses provide 16x more memory per node compared to standard warehouses — specifically designed for memory-intensive workloads like ML training, large UDFs, and Snowpark DataFrames. The cost is approximately 1.5x more credits per hour than a standard warehouse of the same size, but the increased memory eliminates OOM failures and reduces spilling. Do not simply upsize to a standard 4XL — that adds compute nodes but doesn''t provide the same memory density per node as a Snowpark-optimized warehouse.

---

## 4.3 CACHING

Snowflake has **three caching layers**. Understanding them is critical for exam and real life.

### Key Concepts

**1. Result Cache (Cloud Services Layer)**

- Stores **exact query results** for 24 hours. Each time the cached result is reused, the 24-hour counter resets, up to a **maximum of 31 days** from the original caching
- Reused when: same query text + same data (no underlying changes) + same role (result cache is **role-specific**)
- **Free** — no warehouse needed
- Persists even if warehouse is suspended
- Invalidated when underlying data changes (DML) or the 24-hour/31-day window expires
- Can be disabled: `ALTER SESSION SET USE_CACHED_RESULT = FALSE;`

**2. Metadata Cache (Cloud Services Layer)**

- Stores min/max/count/null_count per micro-partition per column
- Powers: `SELECT COUNT(*)`, `MIN()`, `MAX()` on full tables — **instant, no warehouse**
- Works even on tables the warehouse hasn''t queried before (metadata is maintained by cloud services)
- Always active, cannot be disabled

**3. Local Disk Cache (Warehouse SSD)**

- Caches **raw micro-partition data** on warehouse SSD
- Lost when warehouse suspends (SSD cleared)
- Shared across queries on the same warehouse
- Helps repeat scans of the same data within a session
- Reason why longer auto-suspend can sometimes save money (avoid re-fetching data)

### Why This Matters

A dashboard refreshes every 5 minutes with the same 10 queries. If underlying data hasn''t changed, all 10 hit the result cache — zero warehouse credits. But if someone inserts one row, all 10 caches invalidate and the warehouse spins up. Understanding this shapes your ELT scheduling.

### Best Practices

- Schedule data loads at predictable intervals so result cache stays valid between loads
- Don''t disable result cache unless debugging
- Balance auto-suspend timeout: too short = lose SSD cache; too long = waste credits
- Use dedicated warehouses per workload to maximize SSD cache hits
- Metadata cache means `SELECT COUNT(*) FROM big_table` is always instant — no need to cache this yourself

**Exam traps:**

- Exam trap: IF YOU SEE "Result cache works across different roles" → WRONG because result cache is **role-specific**; same query with different roles = cache miss
- Exam trap: IF YOU SEE "Suspending a warehouse clears the result cache" → WRONG because result cache lives in **cloud services layer**, not the warehouse; SSD/local disk cache is what gets cleared
- Exam trap: IF YOU SEE "Result cache lasts 24 hours no matter what" → WRONG because any DML on the underlying tables **invalidates** the cache immediately; also, each reuse resets the 24-hour counter (up to 31 days max from original caching)

### Caching Edge Cases (Exam Details)

- **Metadata cache -- which queries need a warehouse:**

| Query Type | Needs Warehouse? | Why |
|---|---|---|
| `SELECT COUNT(*) FROM table` | No | Metadata cache (full table count) |
| `SELECT MIN(col) FROM table` | No | Metadata cache (min/max per partition) |
| `SELECT MAX(col) FROM table` | No | Metadata cache |
| `SELECT COUNT(col) FROM table GROUP BY x` | **Yes** | GROUP BY requires scanning data |
| `SELECT * FROM table WHERE x = 1` | **Yes** | WHERE requires scanning data |
| `EXPLAIN ...` | No | Uses cloud services only |

- **RESULT_SCAN behavior:** `SELECT * FROM TABLE(RESULT_SCAN(...))` is **free** (reads from cache, no warehouse). But wrapping it in CTAS: `CREATE TABLE t AS SELECT * FROM TABLE(RESULT_SCAN(...))` **costs credits** because INSERT requires warehouse compute.
- **Result cache characteristics (exam-tested):** Persists for 24 hours (reuse resets the counter). Maximum lifetime is 31 days from original caching. NOT shared across different warehouses. NOT related to Time Travel. Does NOT consume storage.
- **Result cache invalidation details:**
  - Exact SQL text match required (whitespace/case differences = cache miss)
  - Disabled by non-deterministic functions (`CURRENT_TIMESTAMP()`, `RANDOM()`, `UUID_STRING()`, etc.)
  - Result cache is **NOT used** if the query contains a UDF
  - Any DML on underlying tables invalidates immediately
- **Result cache pre-warming strategy:** Run key queries via a **scheduled task** before users arrive (e.g., 7 AM). Results get cached for 24 hours. Users hit the cache = zero compute cost. Budget-friendly strategy for "improve performance without increasing cost."

**Exam traps:**

- **Exam trap:** IF YOU SEE "COUNT(*) requires a running warehouse" → WRONG because COUNT(*) on a full table uses the metadata cache and needs no warehouse
- **Exam trap:** IF YOU SEE "RESULT_SCAN with CTAS is free" → WRONG because INSERT operations (including CTAS) require warehouse compute even when reading from cache
- **Exam trap:** IF YOU SEE "Result cache is shared across warehouses" → WRONG because result cache is specific to the query context, not shared across different warehouses

### Common Questions (FAQ)

**Q: Does result cache count toward cloud services billing?**
A: No. Result cache retrieval is free. Cloud services billing only kicks in if cloud services exceed 10% of total compute.

**Q: If two users run the same query with the same role, does user B benefit from user A''s result cache?**
A: Yes — result cache is shared across users if the query text, role, and data are identical.

### Example Scenario Questions — Caching

**Scenario:** A BI dashboard refreshes 20 queries every 5 minutes. The underlying data is only updated once per hour via a scheduled ETL job. The architect notices the BI warehouse is consuming significant credits despite the data being mostly static. How should caching be optimized?
**Answer:** Between ETL runs (55 minutes out of every hour), all 20 queries should hit the result cache since the underlying data hasn''t changed and the queries use the same role. The result cache is free — no warehouse credits consumed. Verify that: (1) result cache is not disabled (`USE_CACHED_RESULT = TRUE`), (2) all dashboard queries use the same role (result cache is role-specific), (3) the ETL job doesn''t do unnecessary DML that would invalidate the cache prematurely. If the dashboard auto-refreshes with slightly different query text each time (e.g., dynamic timestamps), standardize the query text to maximize cache hits. This should reduce warehouse usage by ~90%.

**Scenario:** An analytics team sets warehouse auto-suspend to 10 seconds to save credits. However, they notice that recurring queries throughout the day are slower than expected, and the warehouse is constantly resuming and suspending. What is happening and how should the architect fix it?
**Answer:** The 10-second auto-suspend is clearing the local disk cache (warehouse SSD) too frequently. When the warehouse suspends, all cached micro-partition data on the SSD is lost. When it resumes, queries must re-fetch data from remote storage, making them slower. Increase the auto-suspend to 300-600 seconds for BI workloads — this keeps the SSD cache warm between queries, reducing remote storage reads. The slightly higher idle cost (a few minutes of credits) is offset by faster queries and fewer resume cycles. For ETL warehouses that run in discrete bursts, 60 seconds is appropriate since there''s no cache to preserve between jobs.

---

## 4.4 CLUSTERING & PRUNING

Micro-partition pruning is how Snowflake avoids full table scans. Clustering controls how data is organized.

### Key Concepts

**Micro-partitions:**

- Snowflake stores data in **50-500 MB uncompressed** micro-partitions (immutable, columnar)
- Each partition has **metadata**: min/max values per column
- Queries use this metadata to **skip** irrelevant partitions = pruning

**Natural clustering:**

- Data is clustered by **ingestion order** by default
- Works great if you always filter by a timestamp column and load data chronologically
- Degrades with random inserts, updates, or merges over time

**Clustering keys:**

- Defined with `ALTER TABLE ... CLUSTER BY (col1, col2)`
- Best for: large tables (multi-TB), frequently filtered columns, low-to-medium cardinality
- Snowflake''s **Automatic Clustering** service re-organizes data in the background (serverless, costs credits)
- Check clustering quality: `SYSTEM$CLUSTERING_INFORMATION(''table'', ''(col)'')`
  - `average_depth` — lower is better (1.0 = perfect)
  - `average_overlap` — lower is better (0.0 = no overlap)

**Key selection guidelines:**

- Pick columns used in WHERE, JOIN, ORDER BY
- 3-4 columns max in a clustering key
- Put **low-cardinality columns first** (e.g., `region` before `order_id`)
- Expressions allowed: `CLUSTER BY (TO_DATE(created_at), region)`

### Why This Matters

A 500 TB fact table with `WHERE event_date = ''2025-01-15''` scans 500 TB without clustering. With `CLUSTER BY (event_date)`, it scans maybe 100 MB. That''s the difference between a 30-minute query and a 2-second query.

### Best Practices

- Only cluster tables > 1 TB (or with poor pruning visible in Query Profile)
- Monitor auto-clustering credits in ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
- Don''t cluster by high-cardinality columns alone (e.g., UUID) — ineffective
- Combine with time-based columns for event/log tables: `CLUSTER BY (TO_DATE(ts), category)`
- Re-evaluate clustering keys quarterly as query patterns evolve

**Exam traps:**

- Exam trap: IF YOU SEE "Clustering keys sort the data like a traditional index" → WRONG because Snowflake doesn''t have indexes; clustering keys guide **micro-partition organization** for better pruning
- Exam trap: IF YOU SEE "You should cluster every table" → WRONG because small tables don''t benefit; clustering has ongoing maintenance cost (auto-clustering credits)
- Exam trap: IF YOU SEE "Clustering keys are free to maintain" → WRONG because Automatic Clustering is a **serverless feature that consumes credits**
- Exam trap: IF YOU SEE "High-cardinality column is the best clustering key" → WRONG because low-to-medium cardinality provides better partition pruning; high cardinality means too many distinct values per partition

### Clustering Diagnostics (System Functions)

- **SYSTEM$CLUSTERING_INFORMATION output fields:**
  - `cluster_by_keys`: The current clustering key definition for the table
  - `average_depth`: Average number of micro-partitions a value spans. Lower is better (1.0 = perfect).
  - `average_overlaps`: Average number of overlapping micro-partitions (value ranges that intersect). Lower is better (0.0 = no overlap).
  - `total_partition_count`: Total micro-partitions in the table (current data, not Time Travel partitions).
  - `total_constant_partition_count`: Partitions where the clustering key column has a single distinct value (perfectly clustered partitions). Higher is better.
- **Poor clustering indicators:** `average_depth` > 2-3, `average_overlaps` high, zero `total_constant_partition_count`, or partitions scanned > 50% of total for selective queries = poorly clustered table.
- **SYSTEM$CLUSTERING_DEPTH:** Returns a single depth value for quick assessment. Evaluates how well data is organized for **any** set of columns (not just the current clustering key). Useful for "what-if" analysis before changing the key. Depth = 1 is perfect.
- **Clustering key with expressions:** Use functions to reduce granularity of high-cardinality columns. Examples: `TO_DATE(ts)`, `MONTH(created_at)`, `SUBSTR(name, 1, 2)`, `YEAR(order_date) || QUARTER(order_date)`. Common pattern: `CLUSTER BY (TO_DATE(created_at), region)`.
- **Define alternate clustering via materialized view:** Create an MV with a different clustering key to serve queries that filter on columns not in the base table''s clustering key. The MV acts as an alternate access path. Multiple MVs with different cluster keys = optimal clustering for multiple query patterns on the same table.

**Exam traps:**

- **Exam trap:** IF YOU SEE "SYSTEM$CLUSTERING_DEPTH only works with the current clustering key" → WRONG because you can evaluate clustering depth for **any** columns, even ones not in the current key

### Common Questions (FAQ)

**Q: Can I have multiple clustering keys on one table?**
A: No. One clustering key per table, but it can be a **compound key** with multiple columns.

**Q: Does clustering affect DML performance?**
A: Not directly. But Automatic Clustering runs in the background and consumes serverless credits when data changes.

### Example Scenario Questions — Clustering & Pruning

**Scenario:** A 200 TB event log table is queried primarily by `event_date` and `region`. Queries filtering by `event_date` alone are fast, but queries filtering by both `event_date` and `region` still scan 60% of partitions. The table currently has `CLUSTER BY (event_date)`. How should the architect improve pruning?
**Answer:** Change the clustering key to a compound key: `ALTER TABLE events CLUSTER BY (TO_DATE(event_ts), region)`. Put the lower-cardinality column (`region`, perhaps 10-20 values) first for maximum pruning efficiency, followed by the date expression. This organizes micro-partitions so that data for a specific region and date is co-located, allowing queries with both filters to prune much more aggressively. After changing the key, monitor `SYSTEM$CLUSTERING_INFORMATION(''events'', ''(TO_DATE(event_ts), region)'')` — `average_depth` should decrease toward 1.0 and `average_overlap` toward 0.0 over time as Automatic Clustering reorganizes data. Monitor auto-clustering credits in `AUTOMATIC_CLUSTERING_HISTORY`.

**Scenario:** A product manager asks the architect to add clustering keys to all 500 tables in the analytics database to "make everything faster." What should the architect''s response be?
**Answer:** Clustering should only be applied to large tables (typically >1 TB) with demonstrably poor pruning visible in Query Profile. Small tables fit in a few micro-partitions and don''t benefit from clustering — Snowflake already scans all partitions quickly. Clustering also has ongoing maintenance costs: Automatic Clustering is a serverless feature that consumes credits whenever data changes. For the 500 tables, the architect should analyze Query Profile pruning statistics and `SYSTEM$CLUSTERING_INFORMATION` for the top 10-20 most-queried large tables first, then only apply clustering where partitions scanned is significantly higher than necessary. Re-evaluate clustering keys quarterly as query patterns evolve.

---

## 4.5 PERFORMANCE SERVICES

Three serverless services that accelerate specific query patterns.

### Key Concepts

**1. Query Acceleration Service (QAS)**

- Offloads **portions** of a query to shared serverless compute
- Best for: queries with large scans + selective filters (ad-hoc analytics)
- Enabled per warehouse: `ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE;`
- `QUERY_ACCELERATION_MAX_SCALE_FACTOR` — limits serverless compute (0 = unlimited, default 8)
- Check eligibility: `SYSTEM$ESTIMATE_QUERY_ACCELERATION(''query_id'')`
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
- Don''t enable all three blindly — each has ongoing serverless costs

**Exam traps:**

- Exam trap: IF YOU SEE "QAS replaces the warehouse entirely" → WRONG because QAS **supplements** the warehouse; the warehouse still runs the query, QAS offloads scan-intensive portions
- Exam trap: IF YOU SEE "Search Optimization is like a traditional B-tree index" → WRONG because it''s a **search access path** maintained serverlessly; it''s not a user-managed index
- Exam trap: IF YOU SEE "Materialized views can join multiple tables" → WRONG because MVs in Snowflake support **single base table only** — no joins
- Exam trap: IF YOU SEE "Materialized views must be referenced in the query to be used" → WRONG because the optimizer can **auto-rewrite** queries to use MVs transparently

### Additional Performance Service Details

- **SOS key consideration:** Works best with columns having at least **100K distinct values**. Low-cardinality columns don''t benefit.
- **Performance services cost and use-case comparison:**

| Service | Trigger | Cost Type | Best For |
|---------|---------|-----------|----------|
| QAS | Per-query acceleration | Serverless compute only | Large scan + selective filter (ad-hoc analytics) |
| SOS | Background maintenance | Serverless compute + storage | Point lookups, IN lists, CONTAINS, GEO (100K+ distinct values) |
| MV | Background refresh | Serverless compute + storage | Repeated aggregations on single table |
| Clustering | Background reorganization | Serverless compute + storage | Range/equality filters on large (multi-TB) tables |

- **JSON/VARIANT performance optimization:** Extract frequently-filtered keys from VARIANT into native typed columns (use DATE type, not VARCHAR). Native typed columns enable **partition pruning** which VARIANT columns cannot. VARIANT columns cluster poorly because metadata (min/max) is less effective on semi-structured data.

**Exam traps:**

- **Exam trap:** IF YOU SEE "QAS has storage costs" → WRONG because QAS only has compute costs. Clustering, SOS, and MVs all have both compute AND storage costs

### Common Questions (FAQ)

**Q: Can QAS and Search Optimization be used together?**
A: Yes. They solve different problems — QAS for large scans, SOS for point lookups.

**Q: Do materialized views consume storage?**
A: Yes. They are stored as micro-partitions and contribute to your storage bill.

### Example Scenario Questions — Performance Services

**Scenario:** An analytics platform serves 200 analysts running ad-hoc queries on a 100 TB sales fact table. Some queries scan 80 TB (broad date ranges), while others look up individual orders by `order_id`. The warehouse is frequently overloaded. Which performance services should the architect enable?
**Answer:** Enable Query Acceleration Service (QAS) on the warehouse to help large-scan ad-hoc queries offload scan-intensive portions to shared serverless compute. For the point-lookup queries by `order_id`, add Search Optimization Service (SOS) on the `order_id` column: `ALTER TABLE sales ADD SEARCH OPTIMIZATION ON EQUALITY(order_id)`. SOS builds a persistent search access path for selective point lookups, skipping directly to the relevant partitions. For the most common dashboard aggregations that are queried repeatedly, create materialized views (MVs) on single-table aggregations — the optimizer auto-rewrites queries to use them. Each service addresses a different query pattern: QAS for large scans, SOS for point lookups, MVs for repeated aggregations. Monitor serverless costs for all three via ACCOUNT_USAGE.

**Scenario:** A BI team''s top-10 dashboard shows pre-aggregated metrics (total sales by region, average order value by category) from a single large fact table. These queries run every 5 minutes and always return the same aggregation patterns. The architect wants to pre-compute these results. Should they use a materialized view or a dynamic table?
**Answer:** Use a materialized view (MV). MVs are purpose-built for single-table aggregations with no joins — exactly this use case. Snowflake auto-refreshes the MV when the base table changes (serverless credits) and the optimizer can auto-rewrite queries to use the MV even if the query doesn''t reference it directly. A dynamic table would also work but is heavier — dynamic tables are better suited for multi-table transformations with joins, which MVs don''t support. For simple single-table aggregations, MVs are more efficient and integrate transparently with the optimizer. Enterprise edition is required.

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

- Set log level: `ALTER SESSION SET LOG_LEVEL = ''INFO'';` (OFF, TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
- Set trace level: `ALTER SESSION SET TRACE_LEVEL = ''ON_EVENT'';` (OFF, ALWAYS, ON_EVENT)
- Logs go to the **event table** — queryable via SQL
- Available in UDFs (Python, Java, Scala, JavaScript), stored procedures, Streamlit apps

### Why This Matters

Production dashboard is slow. You check ACCOUNT_USAGE.QUERY_HISTORY and find 500 queries queued on a single warehouse. Resource monitors show you''re burning 2x expected credits. Alerts you set up caught the spike and emailed the team. Without these tools, you wouldn''t know until users complained.

### Best Practices

- Use ACCOUNT_USAGE for historical analysis (365-day retention)
- Use INFORMATION_SCHEMA for real-time debugging (current session/database)
- Set resource monitors on **every production warehouse** — non-negotiable
- Create alerts for: long-running queries, spilling, warehouse queue depth, login failures
- Enable logging (INFO level minimum) for all production UDFs and procedures
- Review WAREHOUSE_METERING_HISTORY weekly to catch cost anomalies early

**Exam traps:**

- Exam trap: IF YOU SEE "INFORMATION_SCHEMA has 365-day retention" → WRONG because that''s **ACCOUNT_USAGE**; INFORMATION_SCHEMA varies (7 days to 6 months by view)
- Exam trap: IF YOU SEE "Resource monitors can limit storage costs" → WRONG because resource monitors only track **compute credits**, not storage
- Exam trap: IF YOU SEE "ACCOUNT_USAGE data is real-time" → WRONG because ACCOUNT_USAGE has **15 minutes to 3 hours latency**
- Exam trap: IF YOU SEE "Any role can create account-level resource monitors" → WRONG because only **ACCOUNTADMIN** can create account-level resource monitors

### Additional Troubleshooting Details

- **STATEMENT_TIMEOUT_IN_SECONDS:** Can be set at Account, User, Session, and Warehouse levels. Maximum default is **172,800 seconds (48 hours)**. Most specific level wins.
- **Cloud services billing threshold:** Cloud services usage up to **10% of daily compute credits** is included free. Only the excess beyond 10% is billed. Example: if you use 100 compute credits in a day, up to 10 cloud services credits are free. This matters for metadata-heavy workloads with small or no warehouses.
- **INFORMATION_SCHEMA vs ACCOUNT_USAGE for performance:**
  - Use INFORMATION_SCHEMA for real-time monitoring (currently running queries, active sessions, current-database scope)
  - Use ACCOUNT_USAGE for historical analysis (query patterns over months, cost trends, cross-database analysis, dropped objects)
  - QUERY_HISTORY in ACCOUNT_USAGE has **45-minute latency** but **365-day retention**
  - Other ACCOUNT_USAGE views may have up to 2-3 hour latency

### Common Questions (FAQ)

**Q: Can I grant ACCOUNT_USAGE access to non-ACCOUNTADMIN roles?**
A: Yes. Grant the `IMPORTED PRIVILEGES` on the SNOWFLAKE database to any role.

**Q: Do resource monitors prevent queries from starting?**
A: With "Suspend Immediately", yes — running queries are killed and new ones blocked. With "Suspend", running queries finish but no new ones start.

**Q: What''s the difference between an Alert and a Task?**
A: A Task runs on a schedule unconditionally. An Alert runs on a schedule but **only triggers its action if a SQL condition is true**.

---

## DON''T MIX -- Performance Concepts the Exam Deliberately Confuses

### QAS vs SOS vs Materialized View -- The Performance Service Triangle

All three "make queries faster." The exam gives you a scenario and wants the RIGHT one.

| | Query Acceleration (QAS) | Search Optimization (SOS) | Materialized View (MV) |
|---|---|---|---|
| What it accelerates | Large SCANS with selective filters | Point LOOKUPS (WHERE id = X) | Repeated AGGREGATIONS |
| How it works | Offloads scan portions to serverless compute | Builds persistent search access paths | Pre-computes and stores results |
| Enabled on | Warehouse | Table (or specific columns) | Defined as a new object |
| Best query pattern | Ad-hoc analytics on huge tables | Needle-in-haystack (find one row in billions) | Same GROUP BY query run 100x/day |
| Joins? | Yes (it accelerates part of any query) | N/A (lookup acceleration) | NO (single table only) |
| Cost model | Serverless credits during query | Serverless credits for building + storage | Serverless credits for refresh + storage |

**RULE:** Big scan, unpredictable filters = QAS. Find-one-row = SOS. Same aggregation repeated = MV.

**The trap:** "Use QAS for point lookups" -- WRONG. QAS helps large scans. For `WHERE id = 12345` on a billion-row table, SOS is the answer.

**The trap:** "Use an MV for a join-based dashboard" -- WRONG. MVs cannot join. Use a Dynamic Table instead.

**The trap:** "SOS is like a traditional index" -- WRONG. It''s a serverless-maintained search access path. You don''t create/manage it like a B-tree.

### Scale UP vs Scale OUT

This one catches people who think in traditional infrastructure.

| | Scale UP | Scale OUT |
|---|---|---|
| What changes | Warehouse SIZE (Small -> Large) | Number of CLUSTERS (1 -> 4) |
| Solves | Single-query speed (more memory, SSD, CPU per query) | CONCURRENCY (more parallel queries) |
| Helps spilling? | YES (bigger warehouse = more memory) | NO (each cluster is same size) |
| Feature | Any warehouse | Multi-cluster warehouse (Enterprise+) |

**RULE:** Slow query = scale UP (bigger size). Many queued queries = scale OUT (more clusters).

**The trap:** "Query is slow, add more clusters" -- WRONG. Multi-cluster doesn''t make ONE query faster. It runs MORE queries in parallel. For a slow single query, you need a bigger warehouse size.

**The trap:** "Multi-cluster warehouses split one query across clusters" -- WRONG. Each cluster runs separate queries. Multi-cluster = concurrency, not parallelism within a query.

### The Three Caches -- What Lives Where

| | Result Cache | Metadata Cache | Local Disk (SSD) Cache |
|---|---|---|---|
| Where | Cloud Services layer | Cloud Services layer | Warehouse nodes |
| What''s cached | Exact query results | Min/max/count per column per partition | Raw micro-partition data |
| Survives warehouse suspend? | YES | YES | NO (cleared on suspend) |
| Cost to use | FREE | FREE | Included in warehouse credits |
| Invalidated by | DML on underlying data, 24h timeout, role change | Never (always current) | Warehouse suspend |
| Can be disabled? | Yes (`USE_CACHED_RESULT = FALSE`) | No (always on) | No (always on while warehouse runs) |

**RULE:** Result cache = exact same query, free, role-specific. Metadata = COUNT/MIN/MAX instant. SSD = warm data on warehouse, lost on suspend.

**The trap:** "Suspending the warehouse clears the result cache" -- WRONG. Result cache is in Cloud Services, not the warehouse. What gets cleared is the SSD/local disk cache.

**The trap:** "Result cache works across roles" -- WRONG. It''s role-specific. Same query + different role = cache miss.

**The trap:** "Set auto-suspend to 10 seconds to save money" -- may COST more because you constantly lose SSD cache, causing slower queries and more remote storage reads.

### Clustering Key vs Search Optimization

Both improve query filtering. Different mechanisms entirely.

| | Clustering Key | Search Optimization |
|---|---|---|
| How it works | Physically re-organizes micro-partitions | Builds a search access path (like an index) |
| Best for | Range filters, WHERE date BETWEEN, low-cardinality GROUP BY | Point lookups, WHERE id = X, CONTAINS, GEO |
| Maintenance | Automatic Clustering (serverless, ongoing) | Search Optimization Service (serverless, ongoing) |
| Apply to | Table level (one compound key) | Column level (can pick specific columns) |
| Works on | Native tables, Iceberg tables | Native tables |

**RULE:** Clustering = organize data for range scans. SOS = build lookup paths for point queries. They can coexist on the same table for different columns.

### INFORMATION_SCHEMA vs ACCOUNT_USAGE

| | INFORMATION_SCHEMA | ACCOUNT_USAGE |
|---|---|---|
| Latency | Real-time | 15 min to 3 hours |
| Retention | 7 days to 6 months (varies by view) | 365 days |
| Scope | Current database only | Entire account |
| Dropped objects | NOT shown | Shown |
| Default access | Any role with DB privileges | ACCOUNTADMIN (can be granted) |
| Use for | "What''s happening RIGHT NOW?" | "What happened last quarter?" |

**RULE:** Debugging now = INFORMATION_SCHEMA. Historical analysis = ACCOUNT_USAGE. The exam loves to swap the retention periods.

**The trap:** "INFORMATION_SCHEMA has 365-day retention" -- WRONG. That''s ACCOUNT_USAGE. INFORMATION_SCHEMA varies (7 days to 6 months).

**The trap:** "ACCOUNT_USAGE is real-time" -- WRONG. It has 15 min to 3 hours of latency.

### Resource Monitor vs Budget

| | Resource Monitor | Budget |
|---|---|---|
| Tracks | Compute CREDITS (warehouse usage) | Dollar SPEND (broader) |
| Can suspend warehouse? | YES (Notify & Suspend actions) | No (notification only) |
| Scope | Account-level or per-warehouse | Account or custom groups |
| Created by | ACCOUNTADMIN only (for account-level) | ACCOUNTADMIN |

**RULE:** Resource Monitor = credit guardrail with teeth (can suspend). Budget = spending visibility with alerts only.

---

### Example Scenario Questions — Troubleshooting

**Scenario:** A production data platform has no cost controls in place. Last month, a developer accidentally left a 4XL warehouse running over a weekend, consuming $15,000 in credits. The CFO demands guardrails. What monitoring and control mechanisms should the architect implement?
**Answer:** Create resource monitors on every production warehouse with tiered thresholds: Notify at 75% of the daily/weekly quota, Notify & Suspend at 100%. For the account level, create an account-level resource monitor (ACCOUNTADMIN only) as an overall safety net. Set up alerts (`CREATE ALERT`) to check for long-running queries (e.g., queries exceeding 30 minutes) and warehouse queue depth, triggering email notifications. Review `ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY` weekly to catch anomalies early. Resource monitors track compute credits only (not storage), so pair them with `STORAGE_USAGE` monitoring for complete cost visibility. Set appropriate auto-suspend timeouts on all warehouses (60s for ETL, 300-600s for BI).

**Scenario:** A Python UDF in production is intermittently failing with cryptic errors. The data engineering team has no visibility into what happens inside the UDF. How should the architect enable observability for UDFs and stored procedures?
**Answer:** Set up an event table for the account: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`. Set the log level to at least INFO: `ALTER SESSION SET LOG_LEVEL = ''INFO''`. Inside the Python UDF, add structured logging using Python''s `logging` module — these logs automatically flow to the event table. Set `TRACE_LEVEL = ''ON_EVENT''` for tracing. The event table is queryable via standard SQL: `SELECT * FROM db.schema.events WHERE RESOURCE_ATTRIBUTES[''snow.executable.name''] = ''MY_UDF''`. This provides full observability — logs, traces, and metrics — for all UDFs, stored procedures, and Streamlit apps. Enable INFO-level logging as a minimum for all production code.

**Scenario:** An architect needs to investigate a performance issue from 3 months ago. INFORMATION_SCHEMA shows no data for that period. Where should they look?
**Answer:** Use `SNOWFLAKE.ACCOUNT_USAGE` views, which have 365-day retention. `INFORMATION_SCHEMA` retention varies by view (7 days to 6 months) and is scoped to the current database only. `ACCOUNT_USAGE.QUERY_HISTORY` provides all query details (execution time, bytes scanned, warehouse, errors) for up to 365 days across the entire account. Note that ACCOUNT_USAGE has 15 minutes to 3 hours of latency (not real-time), and access requires ACCOUNTADMIN or the `IMPORTED PRIVILEGES` grant on the SNOWFLAKE database. For real-time debugging of current issues, use INFORMATION_SCHEMA; for historical analysis, always use ACCOUNT_USAGE.

---

## FLASHCARDS — Domain 4

**Q1: What are the three caching layers in Snowflake?**
A1: Result cache (cloud services, 24h, free), Metadata cache (cloud services, always on), Local disk cache (warehouse SSD, lost on suspend).

**Q2: A query spills to remote storage. What''s the fix?**
A2: Use a **larger warehouse** (more memory/SSD). Also check if the query can be optimized to reduce data volume.

**Q3: What scaling policy should you use for a user-facing BI warehouse?**
A3: **Standard** — scales up quickly when queries queue. Economy is for cost-sensitive, latency-tolerant workloads.

**Q4: How do you check if a table would benefit from clustering?**
A4: `SYSTEM$CLUSTERING_INFORMATION(''table'', ''(columns)'')` — check `average_depth` and `average_overlap`. High values = poor clustering.

**Q5: What is the maximum retention period for ACCOUNT_USAGE views?**
A5: **365 days**.

**Q6: Can materialized views join multiple base tables?**
A6: **No.** Snowflake MVs support a single base table only.

**Q7: What does Query Acceleration Service (QAS) do?**
A7: Offloads scan-intensive portions of eligible queries to serverless compute, supplementing the warehouse.

**Q8: Result cache is invalidated when ____?**
A8: Underlying data changes (DML), 24 hours pass without reuse (though each reuse resets the 24-hour counter, up to 31 days max), or the querying role changes.

**Q9: What''s the minimum auto-suspend setting?**
A9: **60 seconds** is the minimum non-zero value. `AUTO_SUSPEND = 0` or `NULL` means **never auto-suspend**.

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

## EXPLAIN LIKE I''M 5 — Domain 4

**ELI5 #1: Query Profile**
Imagine you''re building a LEGO castle and someone takes a photo at each step. Query Profile is those photos — it shows you exactly which step took the longest and where things got stuck.

**ELI5 #2: Warehouse Sizing**
A warehouse is like hiring workers. X-Small = 1 worker, Small = 2, Medium = 4. More workers cost more money. But if the job needs a special tool (better SQL), hiring more workers won''t help.

**ELI5 #3: Result Cache**
You ask your mom "What''s for dinner?" She says "Pasta." You ask again 5 minutes later — she remembers and says "Pasta" instantly without checking the kitchen. That''s result cache. But if she starts cooking something else, the answer changes.

**ELI5 #4: Micro-partition Pruning**
You have 1,000 labeled toy boxes. Each label says what''s inside (e.g., "cars from 2020"). When you want "cars from 2020", you only open the boxes labeled "2020" instead of all 1,000.

**ELI5 #5: Clustering Keys**
You organize your bookshelf by color first, then by size. Now when someone asks for "all blue books," you go straight to the blue section instead of checking every shelf.

**ELI5 #6: Spilling**
Your desk is too small for your puzzle. You spill pieces onto the floor (local disk) — slower but okay. If the floor fills up, you move pieces to the garage (remote storage) — much slower. Bigger desk = bigger warehouse.

**ELI5 #7: Multi-cluster Warehouses**
One ice cream shop with long lines. Multi-cluster = opening more shops when the line gets too long. Standard policy: open a new shop as soon as someone waits. Economy policy: only open if the line is really, really long.

**ELI5 #8: Search Optimization**
Your teacher made an index at the back of the textbook. Instead of reading every page to find "dinosaurs," you look at the index, get "page 42," and go straight there.

**ELI5 #9: Resource Monitors**
Your parents give you $20 for arcade games. A resource monitor is like a tracker: at $15 it warns you, at $20 it takes the money away so you can''t overspend.

**ELI5 #10: Materialized Views**
Every morning your teacher writes "Today''s Lunch Menu" on the board. Instead of everyone walking to the cafeteria to check, they just look at the board. When the menu changes, the teacher updates the board automatically.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 'pt',
  '# Domínio 4: Performance — Ferramentas, Melhores Práticas e Resolução de Problemas

> **Peso no ARA-C01:** ~20-25% do exame. Este é um domínio de ALTA PRIORIDADE.
> Foco em: Interpretação do Query Profile, dimensionamento de warehouse, camadas de cache, clustering e serviços de performance.

---

## 4.1 QUERY PROFILE

O Query Profile é a sua **ferramenta de diagnóstico mais importante** no Snowflake.

### Conceitos-Chave

- Acesso via: **Aba History → query → Query Profile** (ou `GET_QUERY_OPERATOR_STATS()`)
- Mostra um **DAG (grafo acíclico direcionado)** de operadores — os dados fluem de baixo para cima
- Cada nó de operador mostra: **% do tempo total**, linhas processadas, bytes escaneados

**Operadores críticos que você precisa conhecer:**

| Operador | O Que Faz | Sinal de Alerta |
|----------|-----------|-----------------|
| TableScan | Lê micro-partitions | Partições escaneadas altas vs. total = pruning ruim |
| Filter | Aplica cláusulas WHERE | Deve aparecer APÓS pruning, não no lugar dele |
| Aggregate | GROUP BY / DISTINCT | Memória alta = possível spilling |
| SortWithLimit | ORDER BY + LIMIT | Caro em datasets grandes |
| JoinFilter | Hash join / merge join | Explosão de linhas = condição de join ruim |
| ExternalScan | Tabelas externas / stages | Sempre mais lento que tabelas nativas |
| WindowFunction | Cláusulas OVER() | Intensivo em memória, atenção ao spilling |
| Flatten | Expansão de VARIANT/array | Risco de explosão de linhas |

**Indicadores de spilling:**

- **Bytes spilled to local storage** — SSD do warehouse usado (problema moderado)
- **Bytes spilled to remote storage** — S3/Azure Blob/GCS usado (problema GRAVE)
- Solução: usar um **warehouse maior** (mais memória/SSD) ou otimizar a query

**Estatísticas de pruning (no TableScan):**

- **Partitions scanned** vs. **Partitions total** — o objetivo é scanned << total
- Se scanned ≈ total → clustering key está ausente ou o filtro não corresponde ao clustering

### Por Que Isso Importa

Você tem uma query de relatório levando 45 minutos. O Query Profile mostra um JoinFilter com 50B linhas de saída a partir de duas tabelas de 10M linhas. A condição de join está faltando uma coluna-chave — join cartesiano. Sem o Query Profile, você apenas aumentaria o warehouse e desperdiçaria créditos.

### Melhores Práticas

- Verifique o painel **"Most Expensive Nodes"** primeiro — os 1-2 nós do topo geralmente são o gargalo
- Olhe em **Statistics → Spilling** antes de aumentar warehouses
- Use `SYSTEM$EXPLAIN_PLAN()` para verificações rápidas sem executar a query
- Compare estatísticas de pruning antes/depois de adicionar clustering keys

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "Query está lenta, aumente o tamanho do warehouse" → ERRADO porque você deve diagnosticar com o Query Profile primeiro; o problema pode ser um join ruim ou filtro ausente, não falta de computação
- Armadilha do exame: SE VOCÊ VER "Spilling para disco local é um problema crítico" → ERRADO porque spilling local é uma preocupação moderada; spilling para **remote storage** é o grave
- Armadilha do exame: SE VOCÊ VER "Query Profile mostra o plano de execução antes de executar" → ERRADO porque o Query Profile mostra estatísticas de **execução real**; use `EXPLAIN_PLAN` para planos pré-execução

### Perguntas Frequentes (FAQ)

**P: Posso ver o Query Profile de queries executadas por outros usuários?**
R: Sim, se você tiver ACCOUNTADMIN ou privilégio MONITOR no warehouse. Caso contrário, você só vê suas próprias queries.

**P: Por quanto tempo os Query Profiles são retidos?**
R: 14 dias na interface web. Use ACCOUNT_USAGE.QUERY_HISTORY para até 365 dias (mas sem o DAG visual).


### Exemplos de Perguntas de Cenário — Query Profile

**Cenário:** A nightly reporting job that used to complete in 10 minutes now takes 3 hours. The data engineering team''s first instinct is to upsize the warehouse from Large to 2XL. Before approving the cost increase, what should the architect require?
**Resposta:** Require a Query Profile analysis before any warehouse resizing. Open the Query Profile for the slow query and check: (1) the "Most Expensive Nodes" panel to identify the bottleneck operator, (2) spilling statistics — if the query spills to remote storage, upsizing may help; if there''s no spilling, more compute won''t help, (3) TableScan pruning stats — if partitions scanned is close to partitions total, the issue is poor pruning (fix with clustering keys, not bigger warehouse), (4) JoinFilter — check for row explosion from bad join conditions. The root cause is often a missing filter, a cartesian join, or degraded clustering — none of which are fixed by upsizing.

**Cenário:** An analyst reports that a join between two 10-million-row tables produces a Query Profile showing a JoinFilter operator with 50 billion output rows. The warehouse eventually runs out of memory and the query fails. What is the likely root cause and how should the architect fix it?
**Resposta:** The 50 billion rows from a join of two 10M-row tables indicates a cartesian or near-cartesian join — the join condition is either missing a key column or using a non-selective predicate. Check the Query Profile''s JoinFilter node for the join condition. The fix is correcting the SQL join logic (adding the missing key column), not upsizing the warehouse. Even a 6XL warehouse cannot efficiently process 50 billion rows from what should be a 10M-row result. Use `SYSTEM$EXPLAIN_PLAN()` to verify the corrected query plan before running it.

---

---

## 4.2 WAREHOUSES

Warehouses são seus **motores de computação**. Dimensioná-los corretamente é a principal alavanca de custo.

### Conceitos-Chave

**Tamanhos de warehouse (dimensionamento por camiseta):**

| Tamanho | Nós | Créditos/hr | Caso de Uso |
|---------|-----|-------------|-------------|
| X-Small | 1 | 1 | Dev, queries simples |
| Small | 2 | 2 | Analytics leve |
| Medium | 4 | 4 | Workloads moderados |
| Large | 8 | 8 | Joins complexos, transformações |
| X-Large | 16 | 16 | ETL pesado |
| 2XL–6XL | 32–128 | 32–128 | Workloads massivos |

**Regra de dobra:** Cada tamanho acima = **2x nós, 2x créditos, 2x memória/SSD**. NÃO garante 2x de velocidade.

**Warehouses Otimizados para Snowpark:**

- 16x mais memória por nó que o padrão
- Finalidade: treinamento de ML, UDFs grandes, Snowpark DataFrames, Java/Python UDTFs
- Custo: ~1.5x mais créditos por hora que o padrão do mesmo tamanho

**Warehouses multi-cluster (Enterprise+):**

- Configurações de **Min clusters** e **Max clusters**
- **Políticas de escalonamento:**
  - **Standard (padrão):** Inicia novo cluster quando uma query entra em fila. Scale-down conservador.
  - **Economy:** Espera até haver carga suficiente para manter o novo cluster ocupado por 6 minutos. Economiza créditos mas aumenta enfileiramento.

**Auto-suspend / Auto-resume:**

- Auto-suspend: definido em **segundos** (mínimo 60s, ou 0 para imediato)
- Auto-resume: `TRUE` por padrão — warehouse inicia quando uma query chega
- Warehouses suspensos consomem **zero créditos**
- Cada resume incorre em tempo de provisionamento (~1-2 segundos tipicamente)

### Por Que Isso Importa

Sua equipe de engenharia de dados executa ETL às 2 da manhã em um warehouse 2XL que auto-suspende após 10 minutos. Mas 50 queries pequenas chegam a cada poucos minutos durante o dia, cada uma resumindo o warehouse. Você está pagando créditos de 2XL para workloads de X-Small. Solução: warehouses separados por tipo de workload.

### Melhores Práticas

- **Separe warehouses por workload** (ETL vs. BI vs. ciência de dados)
- Comece pequeno, escale apenas após verificar o Query Profile
- Auto-suspend: **60 segundos** para ETL, **300-600 segundos** para BI (evita resume constante)
- Use política de escalonamento **Economy** para workloads sensíveis a custo e tolerantes a latência
- Use política de escalonamento **Standard** para workloads voltados ao usuário e sensíveis a latência

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "Warehouse maior sempre significa queries mais rápidas" → ERRADO porque a velocidade da query depende do gargalo; um plano de query ruim não melhora com mais computação
- Armadilha do exame: SE VOCÊ VER "Warehouses multi-cluster executam uma única query em múltiplos clusters" → ERRADO porque cada cluster executa queries separadas; multi-cluster é para **concorrência**, não paralelismo de query única
- Armadilha do exame: SE VOCÊ VER "Warehouses otimizados para Snowpark são sempre melhores" → ERRADO porque custam mais e só ajudam workloads intensivos em memória (ML, UDFs grandes); padrão é suficiente para SQL
- Armadilha do exame: SE VOCÊ VER "Auto-suspend 0 significa nunca suspender" → ERRADO porque `AUTO_SUSPEND = 0` significa suspender imediatamente quando ocioso; `NULL` desabilita auto-suspend

### Perguntas Frequentes (FAQ)

**P: O tamanho do warehouse afeta o tempo de compilação?**
R: Não. A compilação acontece na camada de cloud services, não no warehouse.

**P: Posso redimensionar um warehouse enquanto queries estão executando?**
R: Sim. Queries em execução usam o tamanho antigo; novas queries usam o novo tamanho.


### Exemplos de Perguntas de Cenário — Warehouses

**Cenário:** A company uses a single 2XL warehouse for all workloads: ETL at 2 AM, BI dashboards during business hours, and ad-hoc data science queries throughout the day. BI users complain about slow dashboards during ETL runs, and costs are high because the 2XL runs 24/7. How should the architect redesign the warehouse strategy?
**Resposta:** Separate warehouses by workload type. Create a dedicated ETL warehouse (Large or XL, auto-suspend 60 seconds) that runs only during the 2 AM batch window. Create a BI warehouse (Medium, multi-cluster with Standard scaling policy, auto-suspend 300-600 seconds) for dashboard queries — the multi-cluster handles concurrency spikes during business hours, and the longer auto-suspend avoids constant resume overhead and preserves SSD cache. Create a data science warehouse (Snowpark-optimized if running ML/UDFs, standard otherwise, auto-suspend 120 seconds). This eliminates contention between workloads and right-sizes each warehouse independently.

**Cenário:** A data science team runs ML training jobs using Snowpark Python UDFs that process large in-memory datasets. Jobs frequently fail with out-of-memory errors on a standard XL warehouse. What should the architect recommend?
**Resposta:** Switch to a Snowpark-optimized warehouse. Snowpark-optimized warehouses provide 16x more memory per node compared to standard warehouses — specifically designed for memory-intensive workloads like ML training, large UDFs, and Snowpark DataFrames. The cost is approximately 1.5x more credits per hour than a standard warehouse of the same size, but the increased memory eliminates OOM failures and reduces spilling. Do not simply upsize to a standard 4XL — that adds compute nodes but doesn''t provide the same memory density per node as a Snowpark-optimized warehouse.

---

---

## 4.3 CACHING

O Snowflake tem **três camadas de cache**. Entendê-las é crítico para o exame e para a vida real.

### Conceitos-Chave

**1. Result Cache (Camada de Cloud Services)**

- Armazena **resultados exatos de queries** por 24 horas
- Reutilizado quando: mesmo texto da query + mesmos dados (sem alterações subjacentes) + mesma role
- **Gratuito** — nenhum warehouse necessário
- Persiste mesmo se o warehouse estiver suspenso
- Invalidado quando dados subjacentes mudam (DML) ou 24 horas passam
- Pode ser desabilitado: `ALTER SESSION SET USE_CACHED_RESULT = FALSE;`

**2. Metadata Cache (Camada de Cloud Services)**

- Armazena min/max/count/null_count por micro-partition por coluna
- Alimenta: `SELECT COUNT(*)`, `MIN()`, `MAX()` em tabelas completas — **instantâneo, sem warehouse**
- Sempre ativo, não pode ser desabilitado

**3. Local Disk Cache (SSD do Warehouse)**

- Armazena em cache **dados brutos de micro-partition** no SSD do warehouse
- Perdido quando o warehouse suspende (SSD limpo)
- Compartilhado entre queries no mesmo warehouse
- Ajuda escaneamentos repetidos dos mesmos dados dentro de uma sessão
- Razão pela qual auto-suspend mais longo pode às vezes economizar dinheiro (evita re-buscar dados)

### Por Que Isso Importa

Um dashboard atualiza a cada 5 minutos com as mesmas 10 queries. Se os dados subjacentes não mudaram, todas as 10 usam o result cache — zero créditos de warehouse. Mas se alguém insere uma linha, todos os 10 caches são invalidados e o warehouse inicia. Entender isso molda seu agendamento de ELT.

### Melhores Práticas

- Agende cargas de dados em intervalos previsíveis para que o result cache permaneça válido entre as cargas
- Não desabilite o result cache a menos que esteja debugando
- Balance o timeout de auto-suspend: muito curto = perde cache SSD; muito longo = desperdiça créditos
- Use warehouses dedicados por workload para maximizar hits do cache SSD
- Metadata cache significa que `SELECT COUNT(*) FROM big_table` é sempre instantâneo — não precisa fazer cache disso manualmente

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "Result cache funciona entre roles diferentes" → ERRADO porque o result cache é **específico por role**; mesma query com roles diferentes = cache miss
- Armadilha do exame: SE VOCÊ VER "Suspender um warehouse limpa o result cache" → ERRADO porque o result cache fica na **camada de cloud services**, não no warehouse; o cache SSD/disco local é o que é limpo
- Armadilha do exame: SE VOCÊ VER "Result cache dura 24 horas não importa o quê" → ERRADO porque qualquer DML nas tabelas subjacentes **invalida** o cache imediatamente

### Perguntas Frequentes (FAQ)

**P: O result cache conta para a cobrança de cloud services?**
R: Não. A recuperação do result cache é gratuita. A cobrança de cloud services só entra se cloud services exceder 10% do total de computação.

**P: Se dois usuários executam a mesma query com a mesma role, o usuário B se beneficia do result cache do usuário A?**
R: Sim — o result cache é compartilhado entre usuários se o texto da query, role e dados forem idênticos.


### Exemplos de Perguntas de Cenário — Caching

**Cenário:** A BI dashboard refreshes 20 queries every 5 minutes. The underlying data is only updated once per hour via a scheduled ETL job. The architect notices the BI warehouse is consuming significant credits despite the data being mostly static. How should caching be optimized?
**Resposta:** Between ETL runs (55 minutes out of every hour), all 20 queries should hit the result cache since the underlying data hasn''t changed and the queries use the same role. The result cache is free — no warehouse credits consumed. Verify that: (1) result cache is not disabled (`USE_CACHED_RESULT = TRUE`), (2) all dashboard queries use the same role (result cache is role-specific), (3) the ETL job doesn''t do unnecessary DML that would invalidate the cache prematurely. If the dashboard auto-refreshes with slightly different query text each time (e.g., dynamic timestamps), standardize the query text to maximize cache hits. This should reduce warehouse usage by ~90%.

**Cenário:** An analytics team sets warehouse auto-suspend to 10 seconds to save credits. However, they notice that recurring queries throughout the day are slower than expected, and the warehouse is constantly resuming and suspending. What is happening and how should the architect fix it?
**Resposta:** The 10-second auto-suspend is clearing the local disk cache (warehouse SSD) too frequently. When the warehouse suspends, all cached micro-partition data on the SSD is lost. When it resumes, queries must re-fetch data from remote storage, making them slower. Increase the auto-suspend to 300-600 seconds for BI workloads — this keeps the SSD cache warm between queries, reducing remote storage reads. The slightly higher idle cost (a few minutes of credits) is offset by faster queries and fewer resume cycles. For ETL warehouses that run in discrete bursts, 60 seconds is appropriate since there''s no cache to preserve between jobs.

---

---

## 4.4 CLUSTERING E PRUNING

Pruning de micro-partition é como o Snowflake evita full table scans. Clustering controla como os dados são organizados.

### Conceitos-Chave

**Micro-partitions:**

- O Snowflake armazena dados em micro-partitions comprimidas de 50-500 MB (imutáveis, colunares)
- Cada partição tem **metadados**: valores min/max por coluna
- Queries usam esses metadados para **pular** partições irrelevantes = pruning

**Clustering natural:**

- Os dados são clusterizados pela **ordem de ingestão** por padrão
- Funciona muito bem se você sempre filtra por uma coluna timestamp e carrega dados cronologicamente
- Degrada com inserts aleatórios, updates ou merges ao longo do tempo

**Clustering keys:**

- Definidas com `ALTER TABLE ... CLUSTER BY (col1, col2)`
- Melhor para: tabelas grandes (multi-TB), colunas frequentemente filtradas, cardinalidade baixa a média
- O serviço de **Automatic Clustering** do Snowflake reorganiza dados em background (serverless, consome créditos)
- Verificar qualidade do clustering: `SYSTEM$CLUSTERING_INFORMATION(''table'', ''(col)'')`
  - `average_depth` — menor é melhor (1.0 = perfeito)
  - `average_overlap` — menor é melhor (0.0 = sem sobreposição)

**Diretrizes de seleção de chaves:**

- Escolha colunas usadas em WHERE, JOIN, ORDER BY
- Máximo de 3-4 colunas em uma clustering key
- Coloque **colunas de baixa cardinalidade primeiro** (ex: `region` antes de `order_id`)
- Expressões permitidas: `CLUSTER BY (TO_DATE(created_at), region)`

### Por Que Isso Importa

Uma tabela fato de 500 TB com `WHERE event_date = ''2025-01-15''` escaneia 500 TB sem clustering. Com `CLUSTER BY (event_date)`, escaneia talvez 100 MB. Essa é a diferença entre uma query de 30 minutos e uma query de 2 segundos.

### Melhores Práticas

- Só clusterize tabelas > 1 TB (ou com pruning ruim visível no Query Profile)
- Monitore créditos de auto-clustering em ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
- Não clusterize por colunas de alta cardinalidade sozinhas (ex: UUID) — ineficaz
- Combine com colunas baseadas em tempo para tabelas de eventos/log: `CLUSTER BY (TO_DATE(ts), category)`
- Reavalie clustering keys trimestralmente conforme padrões de query evoluem

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "Clustering keys ordenam os dados como um índice tradicional" → ERRADO porque o Snowflake não tem índices; clustering keys guiam a **organização de micro-partitions** para melhor pruning
- Armadilha do exame: SE VOCÊ VER "Você deve clusterizar toda tabela" → ERRADO porque tabelas pequenas não se beneficiam; clustering tem custo de manutenção contínuo (créditos de auto-clustering)
- Armadilha do exame: SE VOCÊ VER "Clustering keys são gratuitas para manter" → ERRADO porque Automatic Clustering é uma **funcionalidade serverless que consome créditos**
- Armadilha do exame: SE VOCÊ VER "Coluna de alta cardinalidade é a melhor clustering key" → ERRADO porque baixa a média cardinalidade proporciona melhor pruning de partições; alta cardinalidade significa muitos valores distintos por partição

### Perguntas Frequentes (FAQ)

**P: Posso ter múltiplas clustering keys em uma tabela?**
R: Não. Uma clustering key por tabela, mas pode ser uma **chave composta** com múltiplas colunas.

**P: Clustering afeta a performance de DML?**
R: Não diretamente. Mas o Automatic Clustering roda em background e consome créditos serverless quando dados mudam.


### Exemplos de Perguntas de Cenário — Clustering & Pruning

**Cenário:** A 200 TB event log table is queried primarily by `event_date` and `region`. Queries filtering by `event_date` alone are fast, but queries filtering by both `event_date` and `region` still scan 60% of partitions. The table currently has `CLUSTER BY (event_date)`. How should the architect improve pruning?
**Resposta:** Change the clustering key to a compound key: `ALTER TABLE events CLUSTER BY (TO_DATE(event_ts), region)`. Put the lower-cardinality column (`region`, perhaps 10-20 values) first for maximum pruning efficiency, followed by the date expression. This organizes micro-partitions so that data for a specific region and date is co-located, allowing queries with both filters to prune much more aggressively. After changing the key, monitor `SYSTEM$CLUSTERING_INFORMATION(''events'', ''(TO_DATE(event_ts), region)'')` — `average_depth` should decrease toward 1.0 and `average_overlap` toward 0.0 over time as Automatic Clustering reorganizes data. Monitor auto-clustering credits in `AUTOMATIC_CLUSTERING_HISTORY`.

**Cenário:** A product manager asks the architect to add clustering keys to all 500 tables in the analytics database to "make everything faster." What should the architect''s response be?
**Resposta:** Clustering should only be applied to large tables (typically >1 TB) with demonstrably poor pruning visible in Query Profile. Small tables fit in a few micro-partitions and don''t benefit from clustering — Snowflake already scans all partitions quickly. Clustering also has ongoing maintenance costs: Automatic Clustering is a serverless feature that consumes credits whenever data changes. For the 500 tables, the architect should analyze Query Profile pruning statistics and `SYSTEM$CLUSTERING_INFORMATION` for the top 10-20 most-queried large tables first, then only apply clustering where partitions scanned is significantly higher than necessary. Re-evaluate clustering keys quarterly as query patterns evolve.

---

---

## 4.5 SERVIÇOS DE PERFORMANCE

Três serviços serverless que aceleram padrões de query específicos.

### Conceitos-Chave

**1. Query Acceleration Service (QAS)**

- Transfere **porções** de uma query para computação serverless compartilhada
- Melhor para: queries com grandes escaneamentos + filtros seletivos (analytics ad-hoc)
- Habilitado por warehouse: `ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE;`
- `QUERY_ACCELERATION_MAX_SCALE_FACTOR` — limita computação serverless (0 = ilimitado, padrão 8)
- Verificar elegibilidade: `SYSTEM$ESTIMATE_QUERY_ACCELERATION(''query_id'')`
- **Não ajuda para:** queries limitadas por operações single-threaded, escaneamentos pequenos ou gargalos de CPU

**2. Search Optimization Service (SOS)**

- Constrói um **caminho de acesso de busca persistente, mantido pelo servidor**
- Melhor para: **buscas pontuais seletivas** em tabelas grandes (WHERE id = X, CONTAINS, GEO)
- Suporta: predicados de igualdade, IN, SUBSTRING, funções GEOGRAPHY/GEOMETRY, campos VARIANT
- Habilitado por tabela ou por coluna: `ALTER TABLE t ADD SEARCH OPTIMIZATION ON EQUALITY(col)`
- Custos: créditos serverless para construção + armazenamento para estruturas de busca
- **Não ajuda para:** range scans, analytics de tabela completa, tabelas pequenas

**3. Materialized Views (MVs)**

- Resultados de query pré-computados, automaticamente mantidos, armazenados como micro-partitions
- Melhor para: subqueries repetidas, pré-agregações, subconjuntos comumente unidos por join
- O Snowflake **atualiza automaticamente** MVs quando a tabela base muda (créditos serverless)
- O otimizador de queries pode **reescrever automaticamente** queries para usar MVs mesmo que não sejam referenciadas diretamente
- Limitações: apenas tabela base única, sem joins, sem UDFs, sem HAVING, funções de janela limitadas
- Requer Enterprise Edition

### Por Que Isso Importa

Uma plataforma de analytics tem 200 usuários executando queries ad-hoc em uma tabela de 100 TB. Algumas queries escaneiam 80 TB, algumas escaneiam 100 MB. QAS ajuda as queries de grande escaneamento a compartilhar computação serverless. SOS ajuda as queries de busca pontual a pular direto para as partições corretas. MVs pré-computam as 10 principais agregações do dashboard.

### Melhores Práticas

- QAS: habilite em warehouses servindo padrões de query **imprevisíveis, ad-hoc**
- SOS: use para padrões de busca de **alta seletividade conhecidos** (buscas por ID, filtros de pesquisa)
- MVs: use para agregações ou views filtradas **estáveis e repetidas**
- Monitore todos os três em ACCOUNT_USAGE: histórico de QAS, histórico de SOS, histórico de refresh de MV
- Não habilite os três cegamente — cada um tem custos serverless contínuos

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "QAS substitui o warehouse inteiramente" → ERRADO porque QAS **complementa** o warehouse; o warehouse ainda executa a query, QAS transfere porções intensivas em escaneamento
- Armadilha do exame: SE VOCÊ VER "Search Optimization é como um índice B-tree tradicional" → ERRADO porque é um **caminho de acesso de busca** mantido por serverless; não é um índice gerenciado pelo usuário
- Armadilha do exame: SE VOCÊ VER "Materialized views podem unir múltiplas tabelas" → ERRADO porque MVs no Snowflake suportam **apenas tabela base única** — sem joins
- Armadilha do exame: SE VOCÊ VER "Materialized views devem ser referenciadas na query para serem usadas" → ERRADO porque o otimizador pode **reescrever automaticamente** queries para usar MVs de forma transparente

### Perguntas Frequentes (FAQ)

**P: QAS e Search Optimization podem ser usados juntos?**
R: Sim. Eles resolvem problemas diferentes — QAS para grandes escaneamentos, SOS para buscas pontuais.

**P: Materialized views consomem armazenamento?**
R: Sim. Elas são armazenadas como micro-partitions e contribuem para sua conta de armazenamento.


### Exemplos de Perguntas de Cenário — Performance Services

**Cenário:** An analytics platform serves 200 analysts running ad-hoc queries on a 100 TB sales fact table. Some queries scan 80 TB (broad date ranges), while others look up individual orders by `order_id`. The warehouse is frequently overloaded. Which performance services should the architect enable?
**Resposta:** Enable Query Acceleration Service (QAS) on the warehouse to help large-scan ad-hoc queries offload scan-intensive portions to shared serverless compute. For the point-lookup queries by `order_id`, add Search Optimization Service (SOS) on the `order_id` column: `ALTER TABLE sales ADD SEARCH OPTIMIZATION ON EQUALITY(order_id)`. SOS builds a persistent search access path for selective point lookups, skipping directly to the relevant partitions. For the most common dashboard aggregations that are queried repeatedly, create materialized views (MVs) on single-table aggregations — the optimizer auto-rewrites queries to use them. Each service addresses a different query pattern: QAS for large scans, SOS for point lookups, MVs for repeated aggregations. Monitor serverless costs for all three via ACCOUNT_USAGE.

**Cenário:** A BI team''s top-10 dashboard shows pre-aggregated metrics (total sales by region, average order value by category) from a single large fact table. These queries run every 5 minutes and always return the same aggregation patterns. The architect wants to pre-compute these results. Should they use a materialized view or a dynamic table?
**Resposta:** Use a materialized view (MV). MVs are purpose-built for single-table aggregations with no joins — exactly this use case. Snowflake auto-refreshes the MV when the base table changes (serverless credits) and the optimizer can auto-rewrite queries to use the MV even if the query doesn''t reference it directly. A dynamic table would also work but is heavier — dynamic tables are better suited for multi-table transformations with joins, which MVs don''t support. For simple single-table aggregations, MVs are more efficient and integrate transparently with the optimizer. Enterprise edition is required.

---

---

## 4.6 RESOLUÇÃO DE PROBLEMAS

Saiba onde olhar e quais ferramentas usar.

### Conceitos-Chave

**INFORMATION_SCHEMA vs. ACCOUNT_USAGE:**

| Característica | INFORMATION_SCHEMA | ACCOUNT_USAGE |
|----------------|-------------------|---------------|
| Latência | Tempo real | 15 min – 3 hr de atraso |
| Retenção | 7 dias–6 meses (varia) | **365 dias** |
| Escopo | Banco de dados atual | Conta inteira |
| Objetos deletados | Não incluídos | **Incluídos** |
| Acesso | Qualquer role com acesso ao DB | ACCOUNTADMIN (ou concedido) |

**Views-chave de ACCOUNT_USAGE para performance:**

- `QUERY_HISTORY` — todas as queries, tempo de execução, bytes escaneados, warehouse, erros
- `WAREHOUSE_METERING_HISTORY` — consumo de créditos por warehouse
- `AUTOMATIC_CLUSTERING_HISTORY` — uso de créditos de auto-clustering
- `SEARCH_OPTIMIZATION_HISTORY` — uso de créditos do SOS
- `MATERIALIZED_VIEW_REFRESH_HISTORY` — uso de créditos de refresh de MV
- `QUERY_ACCELERATION_HISTORY` — uso de créditos do QAS
- `STORAGE_USAGE` — tendências de armazenamento ao longo do tempo
- `LOGIN_HISTORY` — problemas de autenticação

**Resource Monitors:**

- Rastreiam **consumo de créditos** no nível de conta ou warehouse
- Ações nos limites: **Notificar, Notificar e Suspender, Notificar e Suspender Imediatamente**
- Configurado com: `CREATE RESOURCE MONITOR` + atribuir ao warehouse ou conta
- Apenas ACCOUNTADMIN pode criar monitores no nível de conta
- Pode definir **hora de início, frequência (diária/semanal/mensal), cota de créditos**

**Alerts e Event Tables:**

- **Alerts** (`CREATE ALERT`): verificações de condição SQL agendadas → disparam ação (email, task, etc.)
- **Event Table**: armazém centralizado para **logs, traces, métricas** de UDFs, procedures, Streamlit
- Uma event table por conta: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`
- Consulte dados de eventos com SQL padrão: `SELECT * FROM db.schema.events WHERE ...`

**Logging e Tracing:**

- Definir nível de log: `ALTER SESSION SET LOG_LEVEL = ''INFO'';` (OFF, TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
- Definir nível de trace: `ALTER SESSION SET TRACE_LEVEL = ''ON_EVENT'';` (OFF, ALWAYS, ON_EVENT)
- Logs vão para a **event table** — consultável via SQL
- Disponível em UDFs (Python, Java, Scala, JavaScript), stored procedures, apps Streamlit

### Por Que Isso Importa

Dashboard de produção está lento. Você verifica ACCOUNT_USAGE.QUERY_HISTORY e encontra 500 queries enfileiradas em um único warehouse. Resource monitors mostram que você está queimando 2x os créditos esperados. Alerts que você configurou capturaram o pico e enviaram email para a equipe. Sem essas ferramentas, você não saberia até os usuários reclamarem.

### Melhores Práticas

- Use ACCOUNT_USAGE para análise histórica (retenção de 365 dias)
- Use INFORMATION_SCHEMA para debugging em tempo real (sessão/banco de dados atual)
- Configure resource monitors em **todo warehouse de produção** — inegociável
- Crie alerts para: queries de longa duração, spilling, profundidade de fila do warehouse, falhas de login
- Habilite logging (nível INFO no mínimo) para todos os UDFs e procedures de produção
- Revise WAREHOUSE_METERING_HISTORY semanalmente para capturar anomalias de custo cedo

**Armadilhas do exame:**

- Armadilha do exame: SE VOCÊ VER "INFORMATION_SCHEMA tem retenção de 365 dias" → ERRADO porque isso é **ACCOUNT_USAGE**; INFORMATION_SCHEMA varia (7 dias a 6 meses por view)
- Armadilha do exame: SE VOCÊ VER "Resource monitors podem limitar custos de armazenamento" → ERRADO porque resource monitors só rastreiam **créditos de computação**, não armazenamento
- Armadilha do exame: SE VOCÊ VER "Dados de ACCOUNT_USAGE são em tempo real" → ERRADO porque ACCOUNT_USAGE tem **15 minutos a 3 horas de latência**
- Armadilha do exame: SE VOCÊ VER "Qualquer role pode criar resource monitors no nível de conta" → ERRADO porque apenas **ACCOUNTADMIN** pode criar resource monitors no nível de conta

### Perguntas Frequentes (FAQ)

**P: Posso conceder acesso ao ACCOUNT_USAGE para roles que não são ACCOUNTADMIN?**
R: Sim. Conceda `IMPORTED PRIVILEGES` no banco de dados SNOWFLAKE para qualquer role.

**P: Resource monitors impedem queries de iniciar?**
R: Com "Suspend Immediately", sim — queries em execução são encerradas e novas são bloqueadas. Com "Suspend", queries em execução terminam mas novas não iniciam.

**P: Qual é a diferença entre um Alert e uma Task?**
R: Uma Task executa em um agendamento incondicionalmente. Um Alert executa em um agendamento mas **só dispara sua ação se uma condição SQL for verdadeira**.


### Exemplos de Perguntas de Cenário — Troubleshooting

**Cenário:** A production data platform has no cost controls in place. Last month, a developer accidentally left a 4XL warehouse running over a weekend, consuming $15,000 in credits. The CFO demands guardrails. What monitoring and control mechanisms should the architect implement?
**Resposta:** Create resource monitors on every production warehouse with tiered thresholds: Notify at 75% of the daily/weekly quota, Notify & Suspend at 100%. For the account level, create an account-level resource monitor (ACCOUNTADMIN only) as an overall safety net. Set up alerts (`CREATE ALERT`) to check for long-running queries (e.g., queries exceeding 30 minutes) and warehouse queue depth, triggering email notifications. Review `ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY` weekly to catch anomalies early. Resource monitors track compute credits only (not storage), so pair them with `STORAGE_USAGE` monitoring for complete cost visibility. Set appropriate auto-suspend timeouts on all warehouses (60s for ETL, 300-600s for BI).

**Cenário:** A Python UDF in production is intermittently failing with cryptic errors. The data engineering team has no visibility into what happens inside the UDF. How should the architect enable observability for UDFs and stored procedures?
**Resposta:** Set up an event table for the account: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`. Set the log level to at least INFO: `ALTER SESSION SET LOG_LEVEL = ''INFO''`. Inside the Python UDF, add structured logging using Python''s `logging` module — these logs automatically flow to the event table. Set `TRACE_LEVEL = ''ON_EVENT''` for tracing. The event table is queryable via standard SQL: `SELECT * FROM db.schema.events WHERE RESOURCE_ATTRIBUTES[''snow.executable.name''] = ''MY_UDF''`. This provides full observability — logs, traces, and metrics — for all UDFs, stored procedures, and Streamlit apps. Enable INFO-level logging as a minimum for all production code.

**Cenário:** An architect needs to investigate a performance issue from 3 months ago. INFORMATION_SCHEMA shows no data for that period. Where should they look?
**Resposta:** Use `SNOWFLAKE.ACCOUNT_USAGE` views, which have 365-day retention. `INFORMATION_SCHEMA` retention varies by view (7 days to 6 months) and is scoped to the current database only. `ACCOUNT_USAGE.QUERY_HISTORY` provides all query details (execution time, bytes scanned, warehouse, errors) for up to 365 days across the entire account. Note that ACCOUNT_USAGE has 15 minutes to 3 hours of latency (not real-time), and access requires ACCOUNTADMIN or the `IMPORTED PRIVILEGES` grant on the SNOWFLAKE database. For real-time debugging of current issues, use INFORMATION_SCHEMA; for historical analysis, always use ACCOUNT_USAGE.

---

---

## FLASHCARDS — Domínio 4

**Q1: Quais são as três camadas de cache no Snowflake?**
A1: Result cache (cloud services, 24h, gratuito), Metadata cache (cloud services, sempre ativo), Local disk cache (SSD do warehouse, perdido ao suspender).

**Q2: Uma query faz spill para remote storage. Qual é a solução?**
A2: Use um **warehouse maior** (mais memória/SSD). Também verifique se a query pode ser otimizada para reduzir o volume de dados.

**Q3: Qual política de escalonamento você deve usar para um warehouse de BI voltado ao usuário?**
A3: **Standard** — escala rapidamente quando queries enfileiram. Economy é para workloads sensíveis a custo e tolerantes a latência.

**Q4: Como você verifica se uma tabela se beneficiaria de clustering?**
A4: `SYSTEM$CLUSTERING_INFORMATION(''table'', ''(columns)'')` — verifique `average_depth` e `average_overlap`. Valores altos = clustering ruim.

**Q5: Qual é o período máximo de retenção para views de ACCOUNT_USAGE?**
A5: **365 dias**.

**Q6: Materialized views podem unir múltiplas tabelas base?**
A6: **Não.** MVs do Snowflake suportam apenas tabela base única.

**Q7: O que o Query Acceleration Service (QAS) faz?**
A7: Transfere porções intensivas em escaneamento de queries elegíveis para computação serverless, complementando o warehouse.

**Q8: O result cache é invalidado quando ____?**
A8: Dados subjacentes mudam (DML), 24 horas passam, ou o usuário muda de role.

**Q9: Qual é a configuração mínima de auto-suspend?**
A9: **60 segundos** (ou 0 para suspensão imediata).

**Q10: Warehouses otimizados para Snowpark têm ___x mais memória.**
A10: **16x** mais memória por nó comparado a warehouses padrão.

**Q11: INFORMATION_SCHEMA mostra dados para qual escopo?**
A11: Apenas o **banco de dados atual**. Para dados de toda a conta, use ACCOUNT_USAGE.

**Q12: Como funciona o Search Optimization Service?**
A12: Constrói um caminho de acesso de busca persistente (mantido por serverless) para buscas pontuais seletivas, predicados de igualdade e funções geográficas.

**Q13: Resource monitors rastreiam o quê?**
A13: Apenas **créditos de computação**. Eles NÃO rastreiam custos de armazenamento.

**Q14: Para onde vão os logs de UDF/procedure?**
A14: A **event table** — uma única tabela no nível de conta definida via `ALTER ACCOUNT SET EVENT_TABLE`.

**Q15: Quais colunas devem vir primeiro em uma clustering key?**
A15: **Colunas de baixa cardinalidade primeiro** (ex: region, status) para máxima eficiência de pruning.

---

## EXPLIQUE COMO SE EU TIVESSE 5 ANOS — Domínio 4

**ELI5 #1: Query Profile**
Imagine que você está construindo um castelo de LEGO e alguém tira uma foto em cada etapa. O Query Profile são essas fotos — ele mostra exatamente qual etapa demorou mais e onde as coisas travaram.

**ELI5 #2: Dimensionamento de Warehouse**
Um warehouse é como contratar trabalhadores. X-Small = 1 trabalhador, Small = 2, Medium = 4. Mais trabalhadores custam mais dinheiro. Mas se o trabalho precisa de uma ferramenta especial (SQL melhor), contratar mais trabalhadores não vai ajudar.

**ELI5 #3: Result Cache**
Você pergunta para sua mãe "O que tem pra janta?" Ela diz "Macarrão." Você pergunta de novo 5 minutos depois — ela lembra e diz "Macarrão" instantaneamente sem verificar a cozinha. Isso é o result cache. Mas se ela começa a cozinhar outra coisa, a resposta muda.

**ELI5 #4: Pruning de Micro-partition**
Você tem 1.000 caixas de brinquedos etiquetadas. Cada etiqueta diz o que tem dentro (ex: "carros de 2020"). Quando você quer "carros de 2020", você só abre as caixas etiquetadas "2020" em vez de todas as 1.000.

**ELI5 #5: Clustering Keys**
Você organiza sua estante de livros por cor primeiro, depois por tamanho. Agora quando alguém pede "todos os livros azuis", você vai direto para a seção azul em vez de verificar cada prateleira.

**ELI5 #6: Spilling**
Sua mesa é pequena demais para seu quebra-cabeça. Você derrama peças no chão (disco local) — mais lento mas ok. Se o chão lota, você move peças para a garagem (remote storage) — muito mais lento. Mesa maior = warehouse maior.

**ELI5 #7: Warehouses Multi-cluster**
Uma sorveteria com filas longas. Multi-cluster = abrir mais lojas quando a fila fica muito longa. Política Standard: abrir uma nova loja assim que alguém espera. Política Economy: só abrir se a fila estiver realmente, realmente longa.

**ELI5 #8: Search Optimization**
Sua professora fez um índice no final do livro didático. Em vez de ler cada página para encontrar "dinossauros", você olha no índice, encontra "página 42", e vai direto lá.

**ELI5 #9: Resource Monitors**
Seus pais te dão R$20 para jogos de fliperama. Um resource monitor é como um rastreador: em R$15 ele te avisa, em R$20 ele tira o dinheiro para que você não gaste demais.

**ELI5 #10: Materialized Views**
Toda manhã sua professora escreve "Cardápio do Almoço de Hoje" no quadro. Em vez de todo mundo ir à cantina para verificar, eles só olham o quadro. Quando o cardápio muda, a professora atualiza o quadro automaticamente.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 'es',
  '# Dominio 4: Rendimiento — Herramientas, Mejores Prácticas y Solución de Problemas

> **Peso ARA-C01:** ~20-25% del examen. Este es un dominio de ALTA PRIORIDAD.
> Enfócate en: interpretación de Query Profile, dimensionamiento de warehouses, capas de caching, clustering y servicios de rendimiento.

---

## 4.1 QUERY PROFILE

El Query Profile es tu **herramienta de diagnóstico más importante** en Snowflake.

### Conceptos clave

- Acceso vía: **pestaña History → consulta → Query Profile** (o `GET_QUERY_OPERATOR_STATS()`)
- Muestra un **DAG (grafo acíclico dirigido)** de operadores — los datos fluyen de abajo hacia arriba
- Cada nodo de operador muestra: **% del tiempo total**, filas procesadas, bytes escaneados

**Operadores críticos que debes conocer:**

| Operador | Qué hace | Señal de alerta |
|----------|----------|-----------------|
| TableScan | Lee micro-partitions | Alta cantidad de particiones escaneadas vs. total = mal pruning |
| Filter | Aplica cláusulas WHERE | Debería aparecer DESPUÉS del pruning, no en lugar de él |
| Aggregate | GROUP BY / DISTINCT | Alta memoria = posible spilling |
| SortWithLimit | ORDER BY + LIMIT | Costoso en conjuntos de datos grandes |
| JoinFilter | Hash join / merge join | Explosión de filas = mala condición de join |
| ExternalScan | Tablas externas / stages | Siempre más lento que tablas nativas |
| WindowFunction | Cláusulas OVER() | Uso intensivo de memoria, atención al spilling |
| Flatten | Expansión de VARIANT/array | Riesgo de explosión de filas |

**Indicadores de spilling:**

- **Bytes spilled to local storage** — se usa el SSD del warehouse (problema moderado)
- **Bytes spilled to remote storage** — se usa S3/Azure Blob/GCS (problema SEVERO)
- Solución: usar un **warehouse más grande** (más memoria/SSD) u optimizar la consulta

**Estadísticas de pruning (en TableScan):**

- **Partitions scanned** vs. **Partitions total** — el objetivo es que escaneadas << total
- Si escaneadas ≈ total → falta la clustering key o el filtro no coincide con el clustering

### Por qué es importante

Tienes una consulta de reporte que tarda 45 minutos. Query Profile muestra un JoinFilter con 50B filas de salida de dos tablas de 10M filas. A la condición de join le falta una columna clave — join cartesiano. Sin Query Profile, simplemente aumentarías el tamaño del warehouse y desperdiciarías créditos.

### Mejores prácticas

- Revisa primero el panel **"Most Expensive Nodes"** — los 1-2 nodos principales suelen ser el cuello de botella
- Mira **Statistics → Spilling** antes de aumentar el tamaño de los warehouses
- Usa `SYSTEM$EXPLAIN_PLAN()` para verificaciones rápidas sin ejecutar la consulta
- Compara las estadísticas de pruning antes y después de agregar clustering keys

**Trampas del examen:**

- Trampa del examen: SI VES "La consulta es lenta, aumenta el tamaño del warehouse" → INCORRECTO porque deberías diagnosticar con Query Profile primero; el problema podría ser un mal join o un filtro faltante, no insuficiente cómputo
- Trampa del examen: SI VES "Spilling al disco local es un problema crítico" → INCORRECTO porque el spilling local es una preocupación moderada; el spilling a **almacenamiento remoto** es el severo
- Trampa del examen: SI VES "Query Profile muestra el plan de ejecución antes de ejecutar" → INCORRECTO porque Query Profile muestra estadísticas de **ejecución real**; usa `EXPLAIN_PLAN` para planes pre-ejecución

### Preguntas frecuentes (FAQ)

**P: ¿Puedo ver el Query Profile de consultas ejecutadas por otros usuarios?**
R: Sí, si tienes ACCOUNTADMIN o privilegio MONITOR en el warehouse. De lo contrario, solo ves tus propias consultas.

**P: ¿Cuánto tiempo se retienen los Query Profiles?**
R: 14 días en la interfaz web. Usa ACCOUNT_USAGE.QUERY_HISTORY para hasta 365 días (pero sin el DAG visual).


### Ejemplos de Preguntas de Escenario — Query Profile

**Escenario:** A nightly reporting job that used to complete in 10 minutes now takes 3 hours. The data engineering team''s first instinct is to upsize the warehouse from Large to 2XL. Before approving the cost increase, what should the architect require?
**Respuesta:** Require a Query Profile analysis before any warehouse resizing. Open the Query Profile for the slow query and check: (1) the "Most Expensive Nodes" panel to identify the bottleneck operator, (2) spilling statistics — if the query spills to remote storage, upsizing may help; if there''s no spilling, more compute won''t help, (3) TableScan pruning stats — if partitions scanned is close to partitions total, the issue is poor pruning (fix with clustering keys, not bigger warehouse), (4) JoinFilter — check for row explosion from bad join conditions. The root cause is often a missing filter, a cartesian join, or degraded clustering — none of which are fixed by upsizing.

**Escenario:** An analyst reports that a join between two 10-million-row tables produces a Query Profile showing a JoinFilter operator with 50 billion output rows. The warehouse eventually runs out of memory and the query fails. What is the likely root cause and how should the architect fix it?
**Respuesta:** The 50 billion rows from a join of two 10M-row tables indicates a cartesian or near-cartesian join — the join condition is either missing a key column or using a non-selective predicate. Check the Query Profile''s JoinFilter node for the join condition. The fix is correcting the SQL join logic (adding the missing key column), not upsizing the warehouse. Even a 6XL warehouse cannot efficiently process 50 billion rows from what should be a 10M-row result. Use `SYSTEM$EXPLAIN_PLAN()` to verify the corrected query plan before running it.

---

---

## 4.2 WAREHOUSES

Los warehouses son tus **motores de cómputo**. Dimensionarlos correctamente es la palanca de costo #1.

### Conceptos clave

**Tamaños de warehouse (tallas de camiseta):**

| Tamaño | Nodos | Créditos/hr | Caso de uso |
|--------|-------|-------------|-------------|
| X-Small | 1 | 1 | Desarrollo, consultas simples |
| Small | 2 | 2 | Analítica ligera |
| Medium | 4 | 4 | Cargas de trabajo moderadas |
| Large | 8 | 8 | Joins complejos, transformaciones |
| X-Large | 16 | 16 | ETL pesado |
| 2XL–6XL | 32–128 | 32–128 | Cargas de trabajo masivas |

**Regla del doble:** Cada tamaño superior = **2x nodos, 2x créditos, 2x memoria/SSD**. NO garantiza 2x de velocidad.

**Snowpark-Optimized Warehouses:**

- 16x más memoria por nodo que los estándar
- Propósito: entrenamiento de ML, UDFs grandes, Snowpark DataFrames, UDTFs en Java/Python
- Costo: ~1.5x más créditos por hora que un warehouse estándar del mismo tamaño

**Multi-cluster warehouses (Enterprise+):**

- Configuraciones de **Min clusters** y **Max clusters**
- **Políticas de escalamiento:**
  - **Standard (por defecto):** Inicia un nuevo cluster cuando una consulta queda en cola. Reducción conservadora.
  - **Economy:** Espera hasta que haya suficiente carga para mantener un nuevo cluster ocupado por 6 minutos. Ahorra créditos pero aumenta el tiempo en cola.

**Auto-suspend / Auto-resume:**

- Auto-suspend: se configura en **segundos** (mínimo 60s, o 0 para inmediato)
- Auto-resume: `TRUE` por defecto — el warehouse se inicia cuando una consulta lo necesita
- Los warehouses suspendidos consumen **cero créditos**
- Cada reanudación implica tiempo de aprovisionamiento (~1-2 segundos típicamente)

### Por qué es importante

Tu equipo de ingeniería de datos ejecuta ETL a las 2 AM en un warehouse 2XL que se auto-suspende después de 10 minutos. Pero 50 consultas pequeñas llegan cada pocos minutos durante el día, cada una reanudando el warehouse. Estás pagando créditos de 2XL para cargas de trabajo X-Small. Solución: separar warehouses por tipo de carga de trabajo.

### Mejores prácticas

- **Separa warehouses por carga de trabajo** (ETL vs. BI vs. ciencia de datos)
- Comienza pequeño, escala solo después de revisar Query Profile
- Auto-suspend: **60 segundos** para ETL, **300-600 segundos** para BI (evita reanudaciones constantes)
- Usa la política de escalamiento **Economy** para cargas tolerantes a latencia y sensibles al costo
- Usa la política de escalamiento **Standard** para cargas orientadas al usuario y sensibles a latencia

**Trampas del examen:**

- Trampa del examen: SI VES "Un warehouse más grande siempre significa consultas más rápidas" → INCORRECTO porque la velocidad de consulta depende del cuello de botella; un mal plan de consulta no mejorará con más cómputo
- Trampa del examen: SI VES "Multi-cluster warehouses ejecutan una sola consulta en múltiples clusters" → INCORRECTO porque cada cluster ejecuta consultas separadas; multi-cluster es para **concurrencia**, no paralelismo de una sola consulta
- Trampa del examen: SI VES "Snowpark-optimized warehouses siempre son mejores" → INCORRECTO porque cuestan más y solo ayudan con cargas de trabajo intensivas en memoria (ML, UDFs grandes); el estándar está bien para SQL
- Trampa del examen: SI VES "Auto-suspend 0 significa nunca suspender" → INCORRECTO porque `AUTO_SUSPEND = 0` significa suspender inmediatamente cuando esté inactivo; `NULL` deshabilita el auto-suspend

### Preguntas frecuentes (FAQ)

**P: ¿El tamaño del warehouse afecta el tiempo de compilación?**
R: No. La compilación ocurre en el cloud services layer, no en el warehouse.

**P: ¿Puedo redimensionar un warehouse mientras hay consultas ejecutándose?**
R: Sí. Las consultas en ejecución usan el tamaño anterior; las nuevas consultas usan el nuevo tamaño.


### Ejemplos de Preguntas de Escenario — Warehouses

**Escenario:** A company uses a single 2XL warehouse for all workloads: ETL at 2 AM, BI dashboards during business hours, and ad-hoc data science queries throughout the day. BI users complain about slow dashboards during ETL runs, and costs are high because the 2XL runs 24/7. How should the architect redesign the warehouse strategy?
**Respuesta:** Separate warehouses by workload type. Create a dedicated ETL warehouse (Large or XL, auto-suspend 60 seconds) that runs only during the 2 AM batch window. Create a BI warehouse (Medium, multi-cluster with Standard scaling policy, auto-suspend 300-600 seconds) for dashboard queries — the multi-cluster handles concurrency spikes during business hours, and the longer auto-suspend avoids constant resume overhead and preserves SSD cache. Create a data science warehouse (Snowpark-optimized if running ML/UDFs, standard otherwise, auto-suspend 120 seconds). This eliminates contention between workloads and right-sizes each warehouse independently.

**Escenario:** A data science team runs ML training jobs using Snowpark Python UDFs that process large in-memory datasets. Jobs frequently fail with out-of-memory errors on a standard XL warehouse. What should the architect recommend?
**Respuesta:** Switch to a Snowpark-optimized warehouse. Snowpark-optimized warehouses provide 16x more memory per node compared to standard warehouses — specifically designed for memory-intensive workloads like ML training, large UDFs, and Snowpark DataFrames. The cost is approximately 1.5x more credits per hour than a standard warehouse of the same size, but the increased memory eliminates OOM failures and reduces spilling. Do not simply upsize to a standard 4XL — that adds compute nodes but doesn''t provide the same memory density per node as a Snowpark-optimized warehouse.

---

---

## 4.3 CACHING

Snowflake tiene **tres capas de caching**. Entenderlas es crítico para el examen y la vida real.

### Conceptos clave

**1. Result Cache (Cloud Services Layer)**

- Almacena **resultados exactos de consultas** por 24 horas
- Se reutiliza cuando: mismo texto de consulta + mismos datos (sin cambios subyacentes) + mismo rol
- **Gratuito** — no se necesita warehouse
- Persiste incluso si el warehouse está suspendido
- Se invalida cuando los datos subyacentes cambian (DML) o pasan 24 horas
- Se puede deshabilitar: `ALTER SESSION SET USE_CACHED_RESULT = FALSE;`

**2. Metadata Cache (Cloud Services Layer)**

- Almacena min/max/count/null_count por micro-partition por columna
- Potencia: `SELECT COUNT(*)`, `MIN()`, `MAX()` en tablas completas — **instantáneo, sin warehouse**
- Siempre activo, no se puede deshabilitar

**3. Local Disk Cache (SSD del Warehouse)**

- Almacena en caché **datos crudos de micro-partitions** en el SSD del warehouse
- Se pierde cuando el warehouse se suspende (SSD se limpia)
- Compartido entre consultas en el mismo warehouse
- Ayuda con escaneos repetidos de los mismos datos dentro de una sesión
- Razón por la cual un auto-suspend más largo a veces puede ahorrar dinero (evita re-obtener datos)

### Por qué es importante

Un dashboard se refresca cada 5 minutos con las mismas 10 consultas. Si los datos subyacentes no han cambiado, las 10 consultas usan el result cache — cero créditos de warehouse. Pero si alguien inserta una fila, los 10 cachés se invalidan y el warehouse se activa. Entender esto determina la programación de tu ELT.

### Mejores prácticas

- Programa las cargas de datos en intervalos predecibles para que el result cache se mantenga válido entre cargas
- No deshabilites el result cache a menos que estés depurando
- Equilibra el timeout de auto-suspend: muy corto = pierdes caché SSD; muy largo = desperdicias créditos
- Usa warehouses dedicados por carga de trabajo para maximizar los aciertos de caché SSD
- El metadata cache significa que `SELECT COUNT(*) FROM tabla_grande` siempre es instantáneo — no necesitas cachear esto por tu cuenta

**Trampas del examen:**

- Trampa del examen: SI VES "El result cache funciona entre diferentes roles" → INCORRECTO porque el result cache es **específico por rol**; misma consulta con diferentes roles = fallo de caché
- Trampa del examen: SI VES "Suspender un warehouse limpia el result cache" → INCORRECTO porque el result cache vive en el **cloud services layer**, no en el warehouse; el caché SSD/disco local es el que se limpia
- Trampa del examen: SI VES "El result cache dura 24 horas sin importar qué" → INCORRECTO porque cualquier DML en las tablas subyacentes **invalida** el caché inmediatamente

### Preguntas frecuentes (FAQ)

**P: ¿El result cache cuenta para la facturación de cloud services?**
R: No. La recuperación del result cache es gratuita. La facturación de cloud services solo se activa si cloud services excede el 10% del cómputo total.

**P: Si dos usuarios ejecutan la misma consulta con el mismo rol, ¿el usuario B se beneficia del result cache del usuario A?**
R: Sí — el result cache se comparte entre usuarios si el texto de la consulta, el rol y los datos son idénticos.


### Ejemplos de Preguntas de Escenario — Caching

**Escenario:** A BI dashboard refreshes 20 queries every 5 minutes. The underlying data is only updated once per hour via a scheduled ETL job. The architect notices the BI warehouse is consuming significant credits despite the data being mostly static. How should caching be optimized?
**Respuesta:** Between ETL runs (55 minutes out of every hour), all 20 queries should hit the result cache since the underlying data hasn''t changed and the queries use the same role. The result cache is free — no warehouse credits consumed. Verify that: (1) result cache is not disabled (`USE_CACHED_RESULT = TRUE`), (2) all dashboard queries use the same role (result cache is role-specific), (3) the ETL job doesn''t do unnecessary DML that would invalidate the cache prematurely. If the dashboard auto-refreshes with slightly different query text each time (e.g., dynamic timestamps), standardize the query text to maximize cache hits. This should reduce warehouse usage by ~90%.

**Escenario:** An analytics team sets warehouse auto-suspend to 10 seconds to save credits. However, they notice that recurring queries throughout the day are slower than expected, and the warehouse is constantly resuming and suspending. What is happening and how should the architect fix it?
**Respuesta:** The 10-second auto-suspend is clearing the local disk cache (warehouse SSD) too frequently. When the warehouse suspends, all cached micro-partition data on the SSD is lost. When it resumes, queries must re-fetch data from remote storage, making them slower. Increase the auto-suspend to 300-600 seconds for BI workloads — this keeps the SSD cache warm between queries, reducing remote storage reads. The slightly higher idle cost (a few minutes of credits) is offset by faster queries and fewer resume cycles. For ETL warehouses that run in discrete bursts, 60 seconds is appropriate since there''s no cache to preserve between jobs.

---

---

## 4.4 CLUSTERING Y PRUNING

El pruning de micro-partitions es cómo Snowflake evita escaneos completos de tabla. El clustering controla cómo se organizan los datos.

### Conceptos clave

**Micro-partitions:**

- Snowflake almacena datos en micro-partitions comprimidas de 50-500 MB (inmutables, columnares)
- Cada partición tiene **metadatos**: valores min/max por columna
- Las consultas usan estos metadatos para **omitir** particiones irrelevantes = pruning

**Clustering natural:**

- Los datos se organizan por **orden de ingestión** por defecto
- Funciona muy bien si siempre filtras por una columna de timestamp y cargas datos cronológicamente
- Se degrada con inserciones aleatorias, actualizaciones o merges a lo largo del tiempo

**Clustering keys:**

- Se definen con `ALTER TABLE ... CLUSTER BY (col1, col2)`
- Mejor para: tablas grandes (multi-TB), columnas frecuentemente filtradas, cardinalidad baja a media
- El servicio **Automatic Clustering** de Snowflake reorganiza los datos en segundo plano (serverless, consume créditos)
- Verifica la calidad del clustering: `SYSTEM$CLUSTERING_INFORMATION(''table'', ''(col)'')`
  - `average_depth` — menor es mejor (1.0 = perfecto)
  - `average_overlap` — menor es mejor (0.0 = sin superposición)

**Guías para selección de claves:**

- Elige columnas usadas en WHERE, JOIN, ORDER BY
- Máximo 3-4 columnas en una clustering key
- Coloca **columnas de baja cardinalidad primero** (ej., `region` antes de `order_id`)
- Se permiten expresiones: `CLUSTER BY (TO_DATE(created_at), region)`

### Por qué es importante

Una tabla de hechos de 500 TB con `WHERE event_date = ''2025-01-15''` escanea 500 TB sin clustering. Con `CLUSTER BY (event_date)`, escanea quizás 100 MB. Esa es la diferencia entre una consulta de 30 minutos y una consulta de 2 segundos.

### Mejores prácticas

- Solo aplica clustering a tablas > 1 TB (o con mal pruning visible en Query Profile)
- Monitorea los créditos de auto-clustering en ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
- No hagas clustering por columnas de alta cardinalidad solas (ej., UUID) — ineficaz
- Combina con columnas basadas en tiempo para tablas de eventos/logs: `CLUSTER BY (TO_DATE(ts), category)`
- Reevalúa las clustering keys trimestralmente a medida que evolucionan los patrones de consulta

**Trampas del examen:**

- Trampa del examen: SI VES "Las clustering keys ordenan los datos como un índice tradicional" → INCORRECTO porque Snowflake no tiene índices; las clustering keys guían la **organización de micro-partitions** para mejor pruning
- Trampa del examen: SI VES "Deberías aplicar clustering a cada tabla" → INCORRECTO porque las tablas pequeñas no se benefician; el clustering tiene un costo de mantenimiento continuo (créditos de auto-clustering)
- Trampa del examen: SI VES "Las clustering keys son gratuitas de mantener" → INCORRECTO porque el Automatic Clustering es una **funcionalidad serverless que consume créditos**
- Trampa del examen: SI VES "Una columna de alta cardinalidad es la mejor clustering key" → INCORRECTO porque la cardinalidad baja a media proporciona mejor pruning de particiones; alta cardinalidad significa demasiados valores distintos por partición

### Preguntas frecuentes (FAQ)

**P: ¿Puedo tener múltiples clustering keys en una tabla?**
R: No. Una clustering key por tabla, pero puede ser una **clave compuesta** con múltiples columnas.

**P: ¿El clustering afecta el rendimiento de DML?**
R: No directamente. Pero el Automatic Clustering se ejecuta en segundo plano y consume créditos serverless cuando los datos cambian.


### Ejemplos de Preguntas de Escenario — Clustering & Pruning

**Escenario:** A 200 TB event log table is queried primarily by `event_date` and `region`. Queries filtering by `event_date` alone are fast, but queries filtering by both `event_date` and `region` still scan 60% of partitions. The table currently has `CLUSTER BY (event_date)`. How should the architect improve pruning?
**Respuesta:** Change the clustering key to a compound key: `ALTER TABLE events CLUSTER BY (TO_DATE(event_ts), region)`. Put the lower-cardinality column (`region`, perhaps 10-20 values) first for maximum pruning efficiency, followed by the date expression. This organizes micro-partitions so that data for a specific region and date is co-located, allowing queries with both filters to prune much more aggressively. After changing the key, monitor `SYSTEM$CLUSTERING_INFORMATION(''events'', ''(TO_DATE(event_ts), region)'')` — `average_depth` should decrease toward 1.0 and `average_overlap` toward 0.0 over time as Automatic Clustering reorganizes data. Monitor auto-clustering credits in `AUTOMATIC_CLUSTERING_HISTORY`.

**Escenario:** A product manager asks the architect to add clustering keys to all 500 tables in the analytics database to "make everything faster." What should the architect''s response be?
**Respuesta:** Clustering should only be applied to large tables (typically >1 TB) with demonstrably poor pruning visible in Query Profile. Small tables fit in a few micro-partitions and don''t benefit from clustering — Snowflake already scans all partitions quickly. Clustering also has ongoing maintenance costs: Automatic Clustering is a serverless feature that consumes credits whenever data changes. For the 500 tables, the architect should analyze Query Profile pruning statistics and `SYSTEM$CLUSTERING_INFORMATION` for the top 10-20 most-queried large tables first, then only apply clustering where partitions scanned is significantly higher than necessary. Re-evaluate clustering keys quarterly as query patterns evolve.

---

---

## 4.5 SERVICIOS DE RENDIMIENTO

Tres servicios serverless que aceleran patrones de consulta específicos.

### Conceptos clave

**1. Query Acceleration Service (QAS)**

- Descarga **porciones** de una consulta a cómputo serverless compartido
- Mejor para: consultas con escaneos grandes + filtros selectivos (analítica ad-hoc)
- Se habilita por warehouse: `ALTER WAREHOUSE SET ENABLE_QUERY_ACCELERATION = TRUE;`
- `QUERY_ACCELERATION_MAX_SCALE_FACTOR` — limita el cómputo serverless (0 = ilimitado, por defecto 8)
- Verifica elegibilidad: `SYSTEM$ESTIMATE_QUERY_ACCELERATION(''query_id'')`
- **No ayuda con:** consultas limitadas por operaciones de un solo hilo, escaneos pequeños o cuellos de botella de CPU

**2. Search Optimization Service (SOS)**

- Construye una **ruta de acceso de búsqueda persistente, mantenida por el servidor**
- Mejor para: **búsquedas puntuales selectivas** en tablas grandes (WHERE id = X, CONTAINS, GEO)
- Soporta: predicados de igualdad, IN, SUBSTRING, funciones GEOGRAPHY/GEOMETRY, campos VARIANT
- Se habilita por tabla o por columna: `ALTER TABLE t ADD SEARCH OPTIMIZATION ON EQUALITY(col)`
- Costos: créditos serverless para construcción + almacenamiento para estructuras de búsqueda
- **No ayuda con:** escaneos de rango, analítica de tabla completa, tablas pequeñas

**3. Materialized Views (MVs)**

- Resultados de consulta pre-computados, mantenidos automáticamente, almacenados como micro-partitions
- Mejor para: subconsultas repetidas, pre-agregaciones, subconjuntos comúnmente unidos
- Snowflake **auto-refresca** las MVs cuando la tabla base cambia (créditos serverless)
- El optimizador de consultas puede **auto-reescribir** consultas para usar MVs incluso si no se referencian directamente
- Limitaciones: solo una tabla base, sin joins, sin UDFs, sin HAVING, funciones de ventana limitadas
- Requiere Enterprise Edition

### Por qué es importante

Una plataforma de analítica tiene 200 usuarios ejecutando consultas ad-hoc en una tabla de 100 TB. Algunas consultas escanean 80 TB, otras escanean 100 MB. QAS ayuda a las consultas de escaneo grande a compartir cómputo serverless. SOS ayuda a las consultas de búsqueda puntual a ir directamente a las particiones correctas. Las MVs pre-computan las 10 agregaciones principales del dashboard.

### Mejores prácticas

- QAS: habilitar en warehouses que sirven patrones de consulta **impredecibles, ad-hoc**
- SOS: usar para patrones de búsqueda de **alta selectividad conocida** (búsquedas por ID, filtros de búsqueda)
- MVs: usar para agregaciones o vistas filtradas **estables y repetidas**
- Monitorea los tres en ACCOUNT_USAGE: historial de QAS, historial de SOS, historial de refresco de MVs
- No habilites los tres a ciegas — cada uno tiene costos serverless continuos

**Trampas del examen:**

- Trampa del examen: SI VES "QAS reemplaza el warehouse por completo" → INCORRECTO porque QAS **complementa** al warehouse; el warehouse aún ejecuta la consulta, QAS descarga las porciones intensivas en escaneo
- Trampa del examen: SI VES "Search Optimization es como un índice B-tree tradicional" → INCORRECTO porque es una **ruta de acceso de búsqueda** mantenida serverlessly; no es un índice administrado por el usuario
- Trampa del examen: SI VES "Las materialized views pueden unir múltiples tablas" → INCORRECTO porque las MVs en Snowflake soportan **solo una tabla base** — sin joins
- Trampa del examen: SI VES "Las materialized views deben ser referenciadas en la consulta para usarse" → INCORRECTO porque el optimizador puede **auto-reescribir** consultas para usar MVs de forma transparente

### Preguntas frecuentes (FAQ)

**P: ¿Se pueden usar QAS y Search Optimization juntos?**
R: Sí. Resuelven problemas diferentes — QAS para escaneos grandes, SOS para búsquedas puntuales.

**P: ¿Las materialized views consumen almacenamiento?**
R: Sí. Se almacenan como micro-partitions y contribuyen a tu factura de almacenamiento.


### Ejemplos de Preguntas de Escenario — Performance Services

**Escenario:** An analytics platform serves 200 analysts running ad-hoc queries on a 100 TB sales fact table. Some queries scan 80 TB (broad date ranges), while others look up individual orders by `order_id`. The warehouse is frequently overloaded. Which performance services should the architect enable?
**Respuesta:** Enable Query Acceleration Service (QAS) on the warehouse to help large-scan ad-hoc queries offload scan-intensive portions to shared serverless compute. For the point-lookup queries by `order_id`, add Search Optimization Service (SOS) on the `order_id` column: `ALTER TABLE sales ADD SEARCH OPTIMIZATION ON EQUALITY(order_id)`. SOS builds a persistent search access path for selective point lookups, skipping directly to the relevant partitions. For the most common dashboard aggregations that are queried repeatedly, create materialized views (MVs) on single-table aggregations — the optimizer auto-rewrites queries to use them. Each service addresses a different query pattern: QAS for large scans, SOS for point lookups, MVs for repeated aggregations. Monitor serverless costs for all three via ACCOUNT_USAGE.

**Escenario:** A BI team''s top-10 dashboard shows pre-aggregated metrics (total sales by region, average order value by category) from a single large fact table. These queries run every 5 minutes and always return the same aggregation patterns. The architect wants to pre-compute these results. Should they use a materialized view or a dynamic table?
**Respuesta:** Use a materialized view (MV). MVs are purpose-built for single-table aggregations with no joins — exactly this use case. Snowflake auto-refreshes the MV when the base table changes (serverless credits) and the optimizer can auto-rewrite queries to use the MV even if the query doesn''t reference it directly. A dynamic table would also work but is heavier — dynamic tables are better suited for multi-table transformations with joins, which MVs don''t support. For simple single-table aggregations, MVs are more efficient and integrate transparently with the optimizer. Enterprise edition is required.

---

---

## 4.6 SOLUCIÓN DE PROBLEMAS

Saber dónde buscar y qué herramientas usar.

### Conceptos clave

**INFORMATION_SCHEMA vs. ACCOUNT_USAGE:**

| Característica | INFORMATION_SCHEMA | ACCOUNT_USAGE |
|----------------|-------------------|---------------|
| Latencia | Tiempo real | 15 min – 3 hr de retraso |
| Retención | 7 días–6 meses (varía) | **365 días** |
| Alcance | Base de datos actual | Toda la cuenta |
| Objetos eliminados | No incluidos | **Incluidos** |
| Acceso | Cualquier rol con acceso a la BD | ACCOUNTADMIN (o concedido) |

**Vistas clave de ACCOUNT_USAGE para rendimiento:**

- `QUERY_HISTORY` — todas las consultas, tiempo de ejecución, bytes escaneados, warehouse, errores
- `WAREHOUSE_METERING_HISTORY` — consumo de créditos por warehouse
- `AUTOMATIC_CLUSTERING_HISTORY` — uso de créditos de auto-clustering
- `SEARCH_OPTIMIZATION_HISTORY` — uso de créditos de SOS
- `MATERIALIZED_VIEW_REFRESH_HISTORY` — uso de créditos de refresco de MVs
- `QUERY_ACCELERATION_HISTORY` — uso de créditos de QAS
- `STORAGE_USAGE` — tendencias de almacenamiento a lo largo del tiempo
- `LOGIN_HISTORY` — problemas de autenticación

**Resource Monitors:**

- Rastrean **consumo de créditos** a nivel de cuenta o warehouse
- Acciones en umbrales: **Notify, Notify & Suspend, Notify & Suspend Immediately**
- Se configuran con: `CREATE RESOURCE MONITOR` + asignar a warehouse o cuenta
- Solo ACCOUNTADMIN puede crear monitores a nivel de cuenta
- Se puede establecer **hora de inicio, frecuencia (diaria/semanal/mensual), cuota de créditos**

**Alerts y Event Tables:**

- **Alerts** (`CREATE ALERT`): verificaciones programadas de condiciones SQL → activan acción (email, task, etc.)
- **Event Table**: almacén centralizado de **logs, traces, métricas** de UDFs, procedimientos, Streamlit
- Una event table por cuenta: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`
- Consulta datos de eventos con SQL estándar: `SELECT * FROM db.schema.events WHERE ...`

**Logging y Tracing:**

- Configurar nivel de log: `ALTER SESSION SET LOG_LEVEL = ''INFO'';` (OFF, TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
- Configurar nivel de trace: `ALTER SESSION SET TRACE_LEVEL = ''ON_EVENT'';` (OFF, ALWAYS, ON_EVENT)
- Los logs van a la **event table** — consultable vía SQL
- Disponible en UDFs (Python, Java, Scala, JavaScript), stored procedures, aplicaciones Streamlit

### Por qué es importante

El dashboard de producción está lento. Revisas ACCOUNT_USAGE.QUERY_HISTORY y encuentras 500 consultas en cola en un solo warehouse. Los resource monitors muestran que estás quemando 2x los créditos esperados. Los alerts que configuraste detectaron el pico y enviaron email al equipo. Sin estas herramientas, no te enterarías hasta que los usuarios se quejaran.

### Mejores prácticas

- Usa ACCOUNT_USAGE para análisis histórico (retención de 365 días)
- Usa INFORMATION_SCHEMA para depuración en tiempo real (sesión/base de datos actual)
- Configura resource monitors en **cada warehouse de producción** — no es negociable
- Crea alerts para: consultas de larga duración, spilling, profundidad de cola del warehouse, fallos de login
- Habilita logging (nivel INFO como mínimo) para todas las UDFs y procedimientos de producción
- Revisa WAREHOUSE_METERING_HISTORY semanalmente para detectar anomalías de costo temprano

**Trampas del examen:**

- Trampa del examen: SI VES "INFORMATION_SCHEMA tiene retención de 365 días" → INCORRECTO porque eso es **ACCOUNT_USAGE**; INFORMATION_SCHEMA varía (7 días a 6 meses por vista)
- Trampa del examen: SI VES "Los resource monitors pueden limitar costos de almacenamiento" → INCORRECTO porque los resource monitors solo rastrean **créditos de cómputo**, no almacenamiento
- Trampa del examen: SI VES "Los datos de ACCOUNT_USAGE son en tiempo real" → INCORRECTO porque ACCOUNT_USAGE tiene **15 minutos a 3 horas de latencia**
- Trampa del examen: SI VES "Cualquier rol puede crear resource monitors a nivel de cuenta" → INCORRECTO porque solo **ACCOUNTADMIN** puede crear resource monitors a nivel de cuenta

### Preguntas frecuentes (FAQ)

**P: ¿Puedo otorgar acceso a ACCOUNT_USAGE a roles que no sean ACCOUNTADMIN?**
R: Sí. Otorga los `IMPORTED PRIVILEGES` en la base de datos SNOWFLAKE a cualquier rol.

**P: ¿Los resource monitors impiden que las consultas se inicien?**
R: Con "Suspend Immediately", sí — las consultas en ejecución se terminan y las nuevas se bloquean. Con "Suspend", las consultas en ejecución terminan pero no se inician nuevas.

**P: ¿Cuál es la diferencia entre un Alert y un Task?**
R: Un Task se ejecuta en un horario de forma incondicional. Un Alert se ejecuta en un horario pero **solo activa su acción si una condición SQL es verdadera**.


### Ejemplos de Preguntas de Escenario — Troubleshooting

**Escenario:** A production data platform has no cost controls in place. Last month, a developer accidentally left a 4XL warehouse running over a weekend, consuming $15,000 in credits. The CFO demands guardrails. What monitoring and control mechanisms should the architect implement?
**Respuesta:** Create resource monitors on every production warehouse with tiered thresholds: Notify at 75% of the daily/weekly quota, Notify & Suspend at 100%. For the account level, create an account-level resource monitor (ACCOUNTADMIN only) as an overall safety net. Set up alerts (`CREATE ALERT`) to check for long-running queries (e.g., queries exceeding 30 minutes) and warehouse queue depth, triggering email notifications. Review `ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY` weekly to catch anomalies early. Resource monitors track compute credits only (not storage), so pair them with `STORAGE_USAGE` monitoring for complete cost visibility. Set appropriate auto-suspend timeouts on all warehouses (60s for ETL, 300-600s for BI).

**Escenario:** A Python UDF in production is intermittently failing with cryptic errors. The data engineering team has no visibility into what happens inside the UDF. How should the architect enable observability for UDFs and stored procedures?
**Respuesta:** Set up an event table for the account: `ALTER ACCOUNT SET EVENT_TABLE = db.schema.events`. Set the log level to at least INFO: `ALTER SESSION SET LOG_LEVEL = ''INFO''`. Inside the Python UDF, add structured logging using Python''s `logging` module — these logs automatically flow to the event table. Set `TRACE_LEVEL = ''ON_EVENT''` for tracing. The event table is queryable via standard SQL: `SELECT * FROM db.schema.events WHERE RESOURCE_ATTRIBUTES[''snow.executable.name''] = ''MY_UDF''`. This provides full observability — logs, traces, and metrics — for all UDFs, stored procedures, and Streamlit apps. Enable INFO-level logging as a minimum for all production code.

**Escenario:** An architect needs to investigate a performance issue from 3 months ago. INFORMATION_SCHEMA shows no data for that period. Where should they look?
**Respuesta:** Use `SNOWFLAKE.ACCOUNT_USAGE` views, which have 365-day retention. `INFORMATION_SCHEMA` retention varies by view (7 days to 6 months) and is scoped to the current database only. `ACCOUNT_USAGE.QUERY_HISTORY` provides all query details (execution time, bytes scanned, warehouse, errors) for up to 365 days across the entire account. Note that ACCOUNT_USAGE has 15 minutes to 3 hours of latency (not real-time), and access requires ACCOUNTADMIN or the `IMPORTED PRIVILEGES` grant on the SNOWFLAKE database. For real-time debugging of current issues, use INFORMATION_SCHEMA; for historical analysis, always use ACCOUNT_USAGE.

---

---

## TARJETAS DE REPASO — Dominio 4

**P1: ¿Cuáles son las tres capas de caching en Snowflake?**
R1: Result cache (cloud services, 24h, gratuito), Metadata cache (cloud services, siempre activo), Local disk cache (SSD del warehouse, se pierde al suspender).

**P2: Una consulta hace spilling a almacenamiento remoto. ¿Cuál es la solución?**
R2: Usar un **warehouse más grande** (más memoria/SSD). También verificar si la consulta se puede optimizar para reducir el volumen de datos.

**P3: ¿Qué política de escalamiento deberías usar para un warehouse de BI orientado al usuario?**
R3: **Standard** — escala rápidamente cuando las consultas se encolan. Economy es para cargas tolerantes a latencia y sensibles al costo.

**P4: ¿Cómo verificas si una tabla se beneficiaría del clustering?**
R4: `SYSTEM$CLUSTERING_INFORMATION(''table'', ''(columns)'')` — revisa `average_depth` y `average_overlap`. Valores altos = mal clustering.

**P5: ¿Cuál es el período máximo de retención para las vistas de ACCOUNT_USAGE?**
R5: **365 días**.

**P6: ¿Las materialized views pueden unir múltiples tablas base?**
R6: **No.** Las MVs de Snowflake soportan solo una tabla base.

**P7: ¿Qué hace el Query Acceleration Service (QAS)?**
R7: Descarga porciones intensivas en escaneo de consultas elegibles a cómputo serverless, complementando al warehouse.

**P8: El result cache se invalida cuando ____?**
R8: Los datos subyacentes cambian (DML), pasan 24 horas, o el usuario cambia de rol.

**P9: ¿Cuál es la configuración mínima de auto-suspend?**
R9: **60 segundos** (o 0 para suspensión inmediata).

**P10: Los Snowpark-optimized warehouses tienen ___x más memoria.**
R10: **16x** más memoria por nodo comparado con warehouses estándar.

**P11: INFORMATION_SCHEMA muestra datos para qué alcance?**
R11: Solo la **base de datos actual**. Para datos de toda la cuenta, usa ACCOUNT_USAGE.

**P12: ¿Cómo funciona el Search Optimization Service?**
R12: Construye una ruta de acceso de búsqueda persistente (mantenida serverlessly) para búsquedas puntuales selectivas, predicados de igualdad y funciones geo.

**P13: ¿Qué rastrean los resource monitors?**
R13: Solo **créditos de cómputo**. NO rastrean costos de almacenamiento.

**P14: ¿A dónde van los logs de UDFs/procedimientos?**
R14: A la **event table** — una tabla única a nivel de cuenta configurada vía `ALTER ACCOUNT SET EVENT_TABLE`.

**P15: ¿Qué columnas deben ir primero en una clustering key?**
R15: **Columnas de baja cardinalidad primero** (ej., region, status) para máxima eficiencia de pruning.

---

## EXPLÍCALO COMO SI TUVIERA 5 AÑOS — Dominio 4

**ELI5 #1: Query Profile**
Imagina que estás construyendo un castillo de LEGO y alguien toma una foto en cada paso. Query Profile son esas fotos — te muestra exactamente qué paso tomó más tiempo y dónde las cosas se atascaron.

**ELI5 #2: Dimensionamiento de Warehouses**
Un warehouse es como contratar trabajadores. X-Small = 1 trabajador, Small = 2, Medium = 4. Más trabajadores cuestan más dinero. Pero si el trabajo necesita una herramienta especial (mejor SQL), contratar más trabajadores no ayudará.

**ELI5 #3: Result Cache**
Le preguntas a tu mamá "¿Qué hay de cenar?" Ella dice "Pasta." Le preguntas otra vez 5 minutos después — ella recuerda y dice "Pasta" instantáneamente sin revisar la cocina. Eso es el result cache. Pero si ella empieza a cocinar otra cosa, la respuesta cambia.

**ELI5 #4: Pruning de Micro-partitions**
Tienes 1,000 cajas de juguetes etiquetadas. Cada etiqueta dice qué hay adentro (ej., "autos del 2020"). Cuando quieres "autos del 2020", solo abres las cajas etiquetadas "2020" en lugar de las 1,000.

**ELI5 #5: Clustering Keys**
Organizas tu librero por color primero, luego por tamaño. Ahora cuando alguien pide "todos los libros azules", vas directo a la sección azul en lugar de revisar cada estante.

**ELI5 #6: Spilling**
Tu escritorio es muy pequeño para tu rompecabezas. Derramas piezas al piso (disco local) — más lento pero está bien. Si el piso se llena, mueves piezas al garaje (almacenamiento remoto) — mucho más lento. Escritorio más grande = warehouse más grande.

**ELI5 #7: Multi-cluster Warehouses**
Una heladería con filas largas. Multi-cluster = abrir más tiendas cuando la fila se hace muy larga. Política Standard: abrir una nueva tienda apenas alguien espera. Política Economy: solo abrir si la fila es realmente, realmente larga.

**ELI5 #8: Search Optimization**
Tu maestra hizo un índice al final del libro de texto. En lugar de leer cada página para encontrar "dinosaurios", miras el índice, obtienes "página 42" y vas directo ahí.

**ELI5 #9: Resource Monitors**
Tus papás te dan $20 para juegos de arcade. Un resource monitor es como un rastreador: a los $15 te avisa, a los $20 te quita el dinero para que no gastes de más.

**ELI5 #10: Materialized Views**
Cada mañana tu maestra escribe "Menú del almuerzo de hoy" en el pizarrón. En lugar de que todos caminen a la cafetería a revisar, solo miran el pizarrón. Cuando el menú cambia, la maestra actualiza el pizarrón automáticamente.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 'en',
  '# Domain 5: Sharing & Collaboration — Data Sharing Solutions

> **ARA-C01 Weight:** ~10-15% of the exam.
> Focus on: sharing mechanics, cross-region/cloud patterns, reader accounts, marketplace, and Native Apps.

---

## 5.1 SECURE DATA SHARING

The **zero-copy sharing** model is Snowflake''s core differentiator.

### Key Concepts

- **Provider**: the account that owns the data and creates the share
- **Consumer**: the account that receives the share and creates a database from it
- Sharing is **zero-copy** — no data is duplicated; consumer reads from provider''s storage
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
- Grant the minimum objects needed — don''t share entire databases unless necessary
- Monitor shared data access via `SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY`
- Document your shares and review them quarterly

**Exam traps:**

- Exam trap: IF YOU SEE "Consumer pays for storage of shared data" → WRONG because the **provider** pays for storage; the consumer only pays for compute
- Exam trap: IF YOU SEE "Regular views can be shared" → WRONG because only **secure views** can be included in shares; non-secure views expose internal logic
- Exam trap: IF YOU SEE "Shared data can be modified by the consumer" → WRONG because shared data is **read-only** to consumers; they cannot INSERT/UPDATE/DELETE
- Exam trap: IF YOU SEE "Shares create a copy of the data" → WRONG because shares are **zero-copy**; consumers query the provider''s micro-partitions directly

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

A government agency wants to share public datasets with small municipalities that can''t justify a Snowflake subscription. Reader accounts let the agency share data without requiring the municipality to sign a Snowflake contract. But the agency pays all compute costs — so resource monitors are essential.

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
A: No. Reader accounts cannot be converted. The organization would need to sign their own Snowflake contract and you''d set up a regular share.

**Q: How many reader accounts can a provider create?**
A: There is no hard limit documented, but Snowflake may impose soft limits. Contact support for very large numbers.

---

## 5.4 MARKETPLACE & DATA EXCHANGE

Marketplace is Snowflake''s public data catalog. Data Exchange is private.

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

A weather data company publishes daily forecasts on Snowflake Marketplace. A retail chain on Azure East US discovers it, clicks "Get," and instantly has a shared database — no negotiations, no data pipelines, no ETL. Cross-Cloud Auto-Fulfillment means the weather company doesn''t need accounts in every region.

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

- **Purpose:** Two or more parties analyze overlapping data without seeing each other''s raw data
- Built on Snowflake''s sharing + secure views + privacy controls
- **Snowflake Data Clean Rooms** — managed product (powered by Native App Framework)
- Typical use case: advertiser + publisher measuring campaign overlap without exposing customer lists
- **Key guarantee:** no party sees the other''s row-level data — only aggregated/anonymized results

**How it works (simplified):**

1. Party A shares their data into the clean room
2. Party B shares their data into the clean room
3. Pre-approved queries (templates) run on the overlap
4. Results returned are aggregated — minimum thresholds prevent individual identification
5. Neither party downloads the other''s raw data

**Privacy controls:**

- **Differential privacy** — adds statistical noise to prevent re-identification
- **Minimum aggregation thresholds** — query results must represent N+ individuals
- **Column policies** — restrict which columns are joinable/visible

### Why This Matters

A bank and a retailer want to understand shared customers for a co-branded credit card. Neither can share customer lists due to regulations. A data clean room lets them compute "overlap size" and "average spend" without either party seeing individual records.

### Best Practices

- Define **analysis templates** upfront — restrict ad-hoc queries
- Set meaningful minimum aggregation thresholds (e.g., minimum 100 individuals per group)
- Use Snowflake''s managed clean room product rather than building from scratch
- Audit all clean room queries and results
- Involve legal/compliance teams in clean room design

**Exam traps:**

- Exam trap: IF YOU SEE "Data clean rooms let parties see each other''s data" → WRONG because clean rooms **prevent** raw data exposure; only aggregated results are returned
- Exam trap: IF YOU SEE "Clean rooms require data to be copied to a third party" → WRONG because Snowflake clean rooms use **zero-copy sharing** — data stays in each party''s account
- Exam trap: IF YOU SEE "Any query can run in a clean room" → WRONG because queries are restricted to **pre-approved templates** to prevent data leakage

### Common Questions (FAQ)

**Q: Can more than two parties participate in a clean room?**
A: Yes. Multi-party clean rooms are supported, though complexity increases.

**Q: Is a clean room a separate Snowflake account?**
A: The clean room logic runs as a Native App installed in the participating accounts. Data stays in each party''s account.

---

## 5.6 NATIVE APPS

The **Snowflake Native App Framework** lets providers package code + data as installable applications.

### Key Concepts

**Application Package:**

- The **provider-side** container for the app
- Contains: setup scripts, versioned code, shared data content, Streamlit UI, stored procedures, UDFs
- Created with `CREATE APPLICATION PACKAGE`
- Versioned: `ALTER APPLICATION PACKAGE ADD VERSION v1_0 USING ''@stage/v1''`

**Native App (Consumer-side):**

- Installed by the consumer from a listing or directly
- Created from an Application Package
- Runs **inside the consumer''s account** — provider cannot see consumer data
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

A data enrichment company builds a Native App that takes a consumer''s customer table, enriches it with third-party demographic data, and returns results — all without the consumer''s data ever leaving their account. The provider distributes through Marketplace, and each consumer gets their own isolated install.

### Best Practices

- Use **versioned patches** for app updates (consumers can upgrade at their pace)
- Minimize privilege requests — ask only for what the app truly needs
- Include a Streamlit UI for non-SQL users
- Test apps thoroughly in a dev application package before publishing
- Use `manifest.yml` to declare required privileges and configuration

**Exam traps:**

- Exam trap: IF YOU SEE "Native Apps run in the provider''s account" → WRONG because Native Apps run **inside the consumer''s account**; provider cannot see consumer data
- Exam trap: IF YOU SEE "Native Apps automatically have access to consumer data" → WRONG because the consumer must **explicitly grant** privileges; the app requests them, the consumer approves
- Exam trap: IF YOU SEE "Native Apps are just shared databases" → WRONG because Native Apps can include **code** (procedures, UDFs, Streamlit), not just data

### Common Questions (FAQ)

**Q: Can a Native App write data to the consumer''s account?**
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

- Must grant at every level — granting SELECT on a table without USAGE on its schema won''t work
- `GRANT REFERENCE_USAGE ON DATABASE` — allows consumer to create views that reference shared data

**Cross-region sharing requires replication first:**

- You cannot create a share and add a consumer in a different region directly
- Must replicate the database (or use Auto-Fulfillment for listings)
- Replication can be continuous (`REPLICATION_SCHEDULE`) or manual (`ALTER DATABASE REFRESH`)

**Secure UDFs in shares:**

- UDF source code is hidden from consumers (just like secure view definitions)
- Consumers can call them but cannot inspect their logic

### Why This Matters

An architect shares a view containing financial data but forgets to make it secure. The consumer runs `SHOW VIEWS` and sees the SQL definition, which reveals hidden filtering logic and table names. Now they know about tables they shouldn''t. Secure views prevent this.

### Best Practices

- **Always** use secure views — never share regular views
- Grant privileges at the most granular level possible
- Use secure UDFs for business logic you don''t want to expose
- For cross-region consumers, plan replication lag into your SLAs
- Audit shares regularly: `SHOW SHARES`, `DESCRIBE SHARE`

**Exam traps:**

- Exam trap: IF YOU SEE "Regular views can be added to shares" → WRONG because Snowflake **requires secure views** in shares; you''ll get an error adding a non-secure view
- Exam trap: IF YOU SEE "Granting SELECT on a table is enough for sharing" → WRONG because you must also grant **USAGE on the DATABASE and SCHEMA**
- Exam trap: IF YOU SEE "Secure views have identical performance to regular views" → WRONG because secure views restrict certain **optimizer behaviors** to prevent data leakage, which can slightly impact performance

### Common Questions (FAQ)

**Q: Can I share a secure materialized view?**
A: Yes. Secure materialized views can be included in shares.

**Q: If I drop and recreate a table that''s in a share, does the consumer lose access?**
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
A8: In the **consumer''s account** — the provider cannot see consumer data.

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
A15: Consumers see the changes **immediately** (for same-region shares) because sharing is zero-copy — they read the provider''s live micro-partitions.

---

## EXPLAIN LIKE I''M 5 — Domain 5

**ELI5 #1: Secure Data Sharing**
You have a coloring book. Instead of photocopying pages for your friend (which wastes paper), you let them look at your book through a window. They can see and trace it, but they can''t change your book, and you don''t have two copies.

**ELI5 #2: Provider vs. Consumer**
You baked cookies (provider). Your friend eats them (consumer). You bought the ingredients (storage). Your friend uses their own plate and fork (compute).

**ELI5 #3: Reader Accounts**
Your friend doesn''t have a plate or fork. So you give them yours. You''re paying for everything — the cookies AND the plate and fork. That''s a reader account.

**ELI5 #4: Cross-Region Sharing**
Your friend lives in another city. You can''t just hold up the coloring book — they''re too far away. You need to make a copy and send it to their city first (replication), then they can look through the window there.

**ELI5 #5: Marketplace**
Imagine a library where anyone can borrow any book for free (or a small fee). That''s Marketplace. Anyone can browse, find datasets, and "borrow" them instantly.

**ELI5 #6: Data Exchange**
Now imagine a private book club. Only invited members can share and borrow books. That''s Data Exchange.

**ELI5 #7: Data Clean Rooms**
You and your friend each have a bag of marbles. You want to know how many colors you share, but neither wants to show all their marbles. So you each put your bags in a magic box that only tells you "You share 3 colors" — not which specific marbles.

**ELI5 #8: Native Apps**
Someone builds a toy robot and puts it in a box with instructions. You install it in YOUR room, and it plays with YOUR toys. The builder never comes into your room — the robot works on its own.

**ELI5 #9: Secure Views**
A secure view is like a one-way mirror. You can see the data through it, but you can''t see the blueprints of how the mirror was built or what''s hidden behind the wall.

**ELI5 #10: Auto-Fulfillment**
You sell lemonade. Instead of setting up a stand in every neighborhood yourself, a magic helper automatically appears in any neighborhood where someone wants lemonade. You just make the recipe once.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 'pt',
  '# Dominio 5: Compartilhamento e Colaboracao -- Solucoes de Compartilhamento de Dados

> **Peso no ARA-C01:** ~10-15% do exame.
> Foco em: mecanica de compartilhamento, padroes cross-region/cloud, contas reader, marketplace e Native Apps.

---

## 5.1 COMPARTILHAMENTO SEGURO DE DADOS (SECURE DATA SHARING)

O modelo de **compartilhamento sem copia (zero-copy sharing)** e o principal diferencial do Snowflake.

### Conceitos Chave

- **Provider (Provedor)**: a conta que possui os dados e cria o share
- **Consumer (Consumidor)**: a conta que recebe o share e cria um banco de dados a partir dele
- O compartilhamento e **zero-copy** -- nenhum dado e duplicado; o consumidor le do armazenamento do provedor
- O provedor paga pelo **armazenamento**; o consumidor paga pelo **computo** (seu proprio warehouse)
- O compartilhamento usa **shares** -- objetos nomeados contendo bancos de dados, esquemas, tabelas, secure views e UDFs

**O que pode ser compartilhado:**

- Tabelas (completas ou filtradas via secure views)
- Secure views, secure materialized views
- Secure UDFs
- Esquemas (todos os objetos dentro deles)

**O que NAO pode ser compartilhado diretamente:**

- Views nao seguras (devem ser SECURE)
- Stages, pipes, tasks, streams
- Stored procedures
- Tabelas temporarias/transientes (temporary/transient)

**Fluxo de criacao de um share:**

```sql
CREATE SHARE my_share;
GRANT USAGE ON DATABASE mydb TO SHARE my_share;
GRANT USAGE ON SCHEMA mydb.public TO SHARE my_share;
GRANT SELECT ON TABLE mydb.public.customers TO SHARE my_share;
ALTER SHARE my_share ADD ACCOUNTS = consumer_account;
```

**Lado do consumidor:**

```sql
CREATE DATABASE shared_db FROM SHARE provider_account.my_share;
```

### Por Que Isso Importa

Um provedor de servicos de saude precisa compartilhar dados anonimizados de pacientes com um parceiro de pesquisa. Eles criam uma secure view que mascara informacoes pessoais (PII), adicionam ao share, e o parceiro consulta diretamente -- sem copias de dados, sem pipelines ETL, sem dados desatualizados. Em tempo real, sempre atualizado.

### Melhores Praticas

- Sempre usar **secure views** para controlar o que os consumidores veem (filtragem a nivel de linha e coluna)
- Conceder apenas os objetos minimos necessarios -- nao compartilhar bancos de dados inteiros a menos que necessario
- Monitorar o acesso a dados compartilhados via `SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY`
- Documentar seus shares e revisa-los trimestralmente

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "O consumidor paga pelo armazenamento de dados compartilhados" --> ERRADO porque o **provedor** paga pelo armazenamento; o consumidor paga apenas pelo computo
- Armadilha: SE VOCE VIR "Views regulares podem ser compartilhadas" --> ERRADO porque apenas **secure views** podem ser incluidas em shares; views nao seguras expoem a logica interna
- Armadilha: SE VOCE VIR "Dados compartilhados podem ser modificados pelo consumidor" --> ERRADO porque dados compartilhados sao de **somente leitura** para consumidores; eles nao podem fazer INSERT/UPDATE/DELETE
- Armadilha: SE VOCE VIR "Shares criam uma copia dos dados" --> ERRADO porque shares sao **zero-copy**; consumidores consultam diretamente as micro-particoes do provedor

### Perguntas Frequentes (FAQ)

**P: Um consumidor pode re-compartilhar dados que recebeu?**
R: Nao. Consumidores nao podem criar shares a partir de bancos de dados compartilhados. O encadeamento de compartilhamento e bloqueado por design.

**P: O provedor ve as consultas do consumidor?**
R: Nao. O provedor nao tem visibilidade sobre a atividade de consultas do consumidor. Os consumidores controlam seu proprio uso.

---

## 5.2 CENARIOS DE COMPARTILHAMENTO

Diferentes topologias de compartilhamento tem diferentes requisitos.

### Conceitos Chave

| Cenario | Mecanismo | Notas |
|---------|-----------|-------|
| **Mesma conta** | Nao aplicavel -- apenas usar RBAC | O compartilhamento e entre contas, nao dentro de uma mesma |
| **Mesma regiao, mesma nuvem** | Share direto | O mais simples -- zero-copy, sem replicacao |
| **Cross-region (mesma nuvem)** | Replicacao de banco de dados + share | Replicar dados para a regiao destino primeiro, depois compartilhar |
| **Cross-cloud** | Replicacao de banco de dados + share | Igual ao cross-region mas entre AWS/Azure/GCP |
| **Cliente sem Snowflake** | Reader account | O provedor cria uma conta gerenciada para o consumidor |

**Fluxo cross-region / cross-cloud:**

1. O provedor habilita a replicacao: `ALTER DATABASE mydb ENABLE REPLICATION TO ACCOUNTS target_account`
2. A conta destino cria a replica: `CREATE DATABASE mydb AS REPLICA OF source_account.mydb`
3. Atualizar a replica: `ALTER DATABASE mydb REFRESH`
4. Criar o share na regiao destino usando o banco de dados replicado
5. OU: usar **Listing + Cross-Cloud Auto-Fulfillment** (gerencia a replicacao automaticamente)

**Ponto chave:** O compartilhamento direto so funciona dentro da **mesma regiao e provedor de nuvem**. Qualquer coisa cross-region ou cross-cloud requer replicacao primeiro (ou auto-fulfillment).

### Por Que Isso Importa

Uma empresa global de varejo na AWS us-east-1 precisa compartilhar dados de vendas com um parceiro na Azure West Europe. Eles devem replicar o banco de dados para uma conta na Azure West Europe primeiro, e entao criar o share la. Sem entender isso, arquitetos propoem compartilhamento direto e ele falha silenciosamente.

### Melhores Praticas

- Para compartilhamento cross-region frequente, usar **Listings com Auto-Fulfillment** -- automatiza a replicacao
- Monitorar custos de replicacao em `REPLICATION_USAGE_HISTORY`
- A replicacao cross-cloud tem custos de transferencia de dados -- considerar isso na arquitetura
- Usar replication groups para cenarios com multiplos bancos de dados

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "O compartilhamento direto funciona entre regioes" --> ERRADO porque o compartilhamento direto requer **mesma regiao E mesma nuvem**; cross-region precisa de replicacao primeiro
- Armadilha: SE VOCE VIR "O compartilhamento cross-cloud nao e possivel no Snowflake" --> ERRADO porque E possivel via **replicacao de banco de dados** para a nuvem/regiao destino, depois compartilhar
- Armadilha: SE VOCE VIR "Auto-Fulfillment elimina todos os custos de replicacao" --> ERRADO porque auto-fulfillment automatiza a replicacao mas os **custos de transferencia de dados ainda se aplicam**

### Perguntas Frequentes (FAQ)

**P: Posso compartilhar entre duas contas da mesma organizacao mas em regioes diferentes?**
R: Sim, via replicacao de banco de dados + share, ou atraves de um listing do Marketplace com Auto-Fulfillment.

**P: A replicacao e em tempo real?**
R: Nao. A replicacao e quase em tempo real com um cronograma de atualizacao configuravel. Sempre ha algum atraso.

---

## 5.3 CONTAS READER (READER ACCOUNTS)

Para compartilhar com organizacoes que **NAO possuem uma conta Snowflake**.

### Conceitos Chave

- Criadas pelo **provedor** usando `CREATE MANAGED ACCOUNT`
- Reader accounts sao **contas gerenciadas** -- completamente controladas pelo provedor
- **O provedor paga TUDO**: armazenamento e computo
- Os usuarios de reader accounts so podem consultar dados compartilhados -- nao podem carregar seus proprios dados
- Funcionalidade limitada: sem carga de dados, sem shares a partir de reader accounts, administracao minima

**Capacidades das Reader accounts:**

- Consultar dados compartilhados via seu proprio warehouse (financiado pelo provedor)
- Criar usuarios dentro da reader account
- Usar resource monitors (para controlar custos)

**Nao podem:**

- Carregar dados na conta
- Criar shares
- Acessar o Snowflake Marketplace
- Usar funcionalidades avancadas (tasks, streams, etc.)
- Replicar dados

### Por Que Isso Importa

Uma agencia governamental quer compartilhar conjuntos de dados publicos com pequenos municipios que nao podem justificar uma assinatura do Snowflake. Reader accounts permitem que a agencia compartilhe dados sem exigir que o municipio assine um contrato com o Snowflake. Mas a agencia paga todos os custos de computo -- por isso os resource monitors sao essenciais.

### Melhores Praticas

- **Sempre** configurar resource monitors nos warehouses de reader accounts -- voce paga o computo deles
- Manter os warehouses de reader accounts pequenos (X-Small ou Small)
- Configurar auto-suspend agressivo (60 segundos)
- Auditar periodicamente o uso de reader accounts via `RESOURCE_MONITORS` e `MANAGED_ACCOUNTS`
- Considerar listings do Marketplace se deseja que os consumidores paguem seus proprios custos

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Reader accounts podem carregar seus proprios dados" --> ERRADO porque reader accounts **so podem consultar dados compartilhados**; nenhuma carga de dados e permitida
- Armadilha: SE VOCE VIR "O consumidor paga o computo da reader account" --> ERRADO porque o **provedor paga tudo** -- armazenamento E computo para reader accounts
- Armadilha: SE VOCE VIR "Reader accounts podem criar shares para outras contas" --> ERRADO porque reader accounts nao podem criar shares, ponto final

### Perguntas Frequentes (FAQ)

**P: Uma reader account pode ser convertida em uma conta completa do Snowflake?**
R: Nao. Reader accounts nao podem ser convertidas. A organizacao precisaria assinar seu proprio contrato com o Snowflake e voce configuraria um share regular.

**P: Quantas reader accounts um provedor pode criar?**
R: Nao ha um limite rigido documentado, mas o Snowflake pode impor limites flexiveis. Contate o suporte para numeros muito grandes.

---

## 5.4 MARKETPLACE E INTERCAMBIO DE DADOS (DATA EXCHANGE)

Marketplace e o catalogo publico de dados do Snowflake. Data Exchange e privado.

### Conceitos Chave

**Snowflake Marketplace:**

- Catalogo publico onde provedores **listam** conjuntos de dados para qualquer cliente do Snowflake descobrir
- Listings gratuitos ou pagos
- **Personalized listings** -- adaptados a consumidores especificos
- **Standard listings** -- disponiveis para qualquer pessoa
- Consumidores obtem dados instantaneamente -- zero-copy sharing nos bastidores
- Provedores: Snowflake, fornecedores de dados terceiros, qualquer cliente do Snowflake

**Data Exchange (Privado):**

- Grupo **privado, somente por convite** de contas para compartilhamento
- Criado por um cliente do Snowflake ou pelo proprio Snowflake
- Membros podem publicar e descobrir listings dentro do grupo
- Caso de uso: departamentos internos, parceiros de confianca, consorcios industriais

**Cross-Cloud Auto-Fulfillment:**

- Funcionalidade do Marketplace que **replica automaticamente** os listings para consumidores em diferentes regioes/nuvens
- O provedor publica uma vez --> Snowflake gerencia a replicacao para onde quer que o consumidor esteja
- O provedor paga os custos de transferencia/replicacao de dados
- Remove o trabalho manual de replicacao no compartilhamento cross-region/cross-cloud

### Por Que Isso Importa

Uma empresa de dados meteorologicos publica previsoes diarias no Snowflake Marketplace. Uma rede de varejo na Azure East US a descobre, clica em "Get", e instantaneamente tem um banco de dados compartilhado -- sem negociacoes, sem pipelines de dados, sem ETL. Cross-Cloud Auto-Fulfillment significa que a empresa meteorologica nao precisa de contas em cada regiao.

### Melhores Praticas

- Usar Marketplace para distribuicao de dados **publica ou semi-publica**
- Usar Data Exchange para compartilhamento **privado** dentro de um grupo de confianca
- Habilitar Auto-Fulfillment se os consumidores estao em multiplas regioes/nuvens
- Monitorar o uso de listings para entender a demanda e otimizar custos
- Escrever descricoes claras de listings -- consumidores descobrem dados atraves de busca

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Data Exchange e o mesmo que Marketplace" --> ERRADO porque Marketplace e **publico**, Data Exchange e **privado e somente por convite**
- Armadilha: SE VOCE VIR "Auto-Fulfillment e gratuito para provedores" --> ERRADO porque provedores ainda pagam **custos de replicacao e transferencia de dados**
- Armadilha: SE VOCE VIR "Consumidores devem estar na mesma regiao para usar o Marketplace" --> ERRADO porque **Auto-Fulfillment** gerencia a entrega cross-region/cross-cloud automaticamente

### Perguntas Frequentes (FAQ)

**P: Posso cobrar pelos listings do Marketplace?**
R: Sim. O Snowflake suporta listings pagos com precos baseados em uso ou fixos, gerenciados atraves do painel do provedor.

**P: Quem gerencia a cobranca para listings pagos?**
R: O Snowflake gerencia a cobranca. Consumidores pagam atraves de sua fatura do Snowflake, e o Snowflake repassa ao provedor.

---

## 5.5 DATA CLEAN ROOMS

Analise segura de dados entre multiplas partes sem expor dados brutos.

### Conceitos Chave

- **Proposito:** Duas ou mais partes analisam dados sobrepostos sem ver os dados brutos um do outro
- Construido sobre o compartilhamento do Snowflake + secure views + controles de privacidade
- **Snowflake Data Clean Rooms** -- produto gerenciado (alimentado pelo Native App Framework)
- Caso de uso tipico: anunciante + editor medindo a sobreposicao de campanhas sem expor listas de clientes
- **Garantia chave:** nenhuma parte ve os dados a nivel de linha do outro -- apenas resultados agregados/anonimizados

**Como funciona (simplificado):**

1. A Parte A compartilha seus dados no clean room
2. A Parte B compartilha seus dados no clean room
3. Consultas pre-aprovadas (templates) sao executadas sobre a sobreposicao
4. Os resultados retornados sao agregados -- limites minimos previnem a identificacao individual
5. Nenhuma parte baixa os dados brutos do outro

**Controles de privacidade:**

- **Privacidade diferencial** -- adiciona ruido estatistico para prevenir a re-identificacao
- **Limites minimos de agregacao** -- os resultados de consultas devem representar N+ individuos
- **Politicas de coluna** -- restringem quais colunas sao unificaveis/visiveis

### Por Que Isso Importa

Um banco e um varejista querem entender os clientes compartilhados para um cartao de credito co-branded. Nenhum pode compartilhar listas de clientes devido a regulamentacoes. Um data clean room permite que calculem o "tamanho da sobreposicao" e "gasto medio" sem que nenhuma parte veja registros individuais.

### Melhores Praticas

- Definir **templates de analise** antecipadamente -- restringir consultas ad-hoc
- Estabelecer limites minimos de agregacao significativos (ex. minimo 100 individuos por grupo)
- Usar o produto gerenciado de clean room do Snowflake em vez de construir do zero
- Auditar todas as consultas e resultados do clean room
- Envolver equipes juridicas/de compliance no design do clean room

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Data clean rooms permitem que as partes vejam os dados um do outro" --> ERRADO porque clean rooms **previnem** a exposicao de dados brutos; apenas resultados agregados sao retornados
- Armadilha: SE VOCE VIR "Clean rooms exigem que os dados sejam copiados para um terceiro" --> ERRADO porque os clean rooms do Snowflake usam **zero-copy sharing** -- os dados permanecem na conta de cada parte
- Armadilha: SE VOCE VIR "Qualquer consulta pode ser executada em um clean room" --> ERRADO porque as consultas sao restritas a **templates pre-aprovados** para prevenir vazamento de dados

### Perguntas Frequentes (FAQ)

**P: Mais de duas partes podem participar de um clean room?**
R: Sim. Clean rooms com multiplas partes sao suportados, embora a complexidade aumente.

**P: Um clean room e uma conta separada do Snowflake?**
R: A logica do clean room e executada como uma Native App instalada nas contas participantes. Os dados permanecem na conta de cada parte.

---

## 5.6 NATIVE APPS

O **Snowflake Native App Framework** permite que provedores empacotem codigo + dados como aplicacoes instalaveis.

### Conceitos Chave

**Application Package:**

- O contêiner do **lado do provedor** para a app
- Contem: scripts de configuracao, codigo versionado, conteudo de dados compartilhados, UI de Streamlit, stored procedures, UDFs
- Criado com `CREATE APPLICATION PACKAGE`
- Versionado: `ALTER APPLICATION PACKAGE ADD VERSION v1_0 USING ''@stage/v1''`

**Native App (Lado do consumidor):**

- Instalada pelo consumidor a partir de um listing ou diretamente
- Criada a partir de um Application Package
- Executa **dentro da conta do consumidor** -- o provedor nao pode ver os dados do consumidor
- Pode solicitar **privilegios** ao consumidor (ex. acesso a tabelas especificas)
- O consumidor controla qual acesso conceder

**O que as Native Apps podem incluir:**

- Stored procedures e UDFs (SQL, Python, Java, Scala, JavaScript)
- Dashboards de Streamlit (UI)
- Conteudo de dados compartilhados (dados de referencia)
- Tasks e streams (para processamento automatizado)
- Integracoes de acesso externo (chamar APIs externas)

**Script de configuracao (`setup.sql`):**

- Executa quando o consumidor instala a app
- Cria todos os objetos internos (esquemas, views, procedimentos, etc.)
- Define **roles de aplicacao** que mapeiam para os privilegios concedidos pelo consumidor

### Por Que Isso Importa

Uma empresa de enriquecimento de dados constroi uma Native App que recebe a tabela de clientes do consumidor, a enriquece com dados demograficos de terceiros e retorna os resultados -- tudo sem que os dados do consumidor saiam de sua conta. O provedor distribui atraves do Marketplace, e cada consumidor recebe sua propria instalacao isolada.

### Melhores Praticas

- Usar **patches versionados** para atualizacoes de apps (consumidores podem atualizar no seu ritmo)
- Minimizar solicitacoes de privilegios -- pedir apenas o que a app realmente precisa
- Incluir uma UI de Streamlit para usuarios que nao usam SQL
- Testar as apps exaustivamente em um application package de desenvolvimento antes de publicar
- Usar `manifest.yml` para declarar privilegios necessarios e configuracao

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Native Apps executam na conta do provedor" --> ERRADO porque Native Apps executam **dentro da conta do consumidor**; o provedor nao pode ver os dados do consumidor
- Armadilha: SE VOCE VIR "Native Apps automaticamente tem acesso aos dados do consumidor" --> ERRADO porque o consumidor deve **conceder explicitamente** os privilegios; a app os solicita, o consumidor aprova
- Armadilha: SE VOCE VIR "Native Apps sao apenas bancos de dados compartilhados" --> ERRADO porque Native Apps podem incluir **codigo** (procedimentos, UDFs, Streamlit), nao apenas dados

### Perguntas Frequentes (FAQ)

**P: Uma Native App pode gravar dados na conta do consumidor?**
R: Sim, se o consumidor conceder os privilegios necessarios (ex. CREATE TABLE em um esquema).

**P: Como os consumidores recebem atualizacoes de Native Apps?**
R: Provedores publicam novas versoes/patches. Consumidores podem atualizar manualmente ou o provedor pode configurar atualizacao automatica.

---

## 5.7 PADROES DE SEGURANCA PARA COMPARTILHAMENTO

A seguranca nao e negociavel ao compartilhar dados.

### Conceitos Chave

**Secure views sao obrigatorias:**

- Views regulares expoem sua definicao (SQL) a qualquer pessoa com `SHOW VIEWS`
- Secure views ocultam a definicao e previnem a inferencia de dados baseada no otimizador
- **Todas as views em shares DEVEM ser seguras** -- o Snowflake impoe isso
- Compromisso: secure views podem ter otimizacao ligeiramente diferente (restricoes do otimizador de consultas)

**Hierarquia de privilegios do share:**

```
SHARE
  └── USAGE on DATABASE
       └── USAGE on SCHEMA
            └── SELECT on TABLE / VIEW / MATERIALIZED VIEW
            └── USAGE on UDF
```

- Deve-se conceder em cada nivel -- conceder SELECT em uma tabela sem USAGE em seu esquema nao funcionara
- `GRANT REFERENCE_USAGE ON DATABASE` -- permite ao consumidor criar views que referenciem dados compartilhados

**O compartilhamento cross-region requer replicacao primeiro:**

- Nao e possivel criar um share e adicionar um consumidor em uma regiao diferente diretamente
- Deve-se replicar o banco de dados (ou usar Auto-Fulfillment para listings)
- A replicacao pode ser continua (`REPLICATION_SCHEDULE`) ou manual (`ALTER DATABASE REFRESH`)

**Secure UDFs em shares:**

- O codigo-fonte da UDF e oculto para os consumidores (assim como as definicoes de secure views)
- Consumidores podem chama-las mas nao podem inspecionar sua logica

### Por Que Isso Importa

Um arquiteto compartilha uma view contendo dados financeiros mas esquece de torna-la segura. O consumidor executa `SHOW VIEWS` e ve a definicao SQL, que revela logica de filtragem oculta e nomes de tabelas. Agora eles conhecem tabelas que nao deveriam. Secure views previnem isso.

### Melhores Praticas

- **Sempre** usar secure views -- nunca compartilhar views regulares
- Conceder privilegios no nivel mais granular possivel
- Usar secure UDFs para logica de negocio que voce nao quer expor
- Para consumidores cross-region, planejar o atraso de replicacao nos SLAs
- Auditar shares regularmente: `SHOW SHARES`, `DESCRIBE SHARE`

**Armadilhas do exame:**

- Armadilha: SE VOCE VIR "Views regulares podem ser adicionadas a shares" --> ERRADO porque o Snowflake **exige secure views** em shares; voce recebera um erro ao adicionar uma view nao segura
- Armadilha: SE VOCE VIR "Conceder SELECT em uma tabela e suficiente para compartilhar" --> ERRADO porque voce tambem deve conceder **USAGE no DATABASE e no SCHEMA**
- Armadilha: SE VOCE VIR "Secure views tem desempenho identico as views regulares" --> ERRADO porque secure views restringem certos **comportamentos do otimizador** para prevenir vazamento de dados, o que pode impactar ligeiramente o desempenho

### Perguntas Frequentes (FAQ)

**P: Posso compartilhar uma secure materialized view?**
R: Sim. Secure materialized views podem ser incluidas em shares.

**P: Se eu deletar e recriar uma tabela que esta em um share, o consumidor perde acesso?**
R: Sim. O share referencia o objeto especifico. Voce deve re-conceder apos recriar.

---

## CARTOES DE REVISAO -- Dominio 5

**P1: Quem paga o armazenamento em um share direto?**
R1: O **provedor** paga o armazenamento. O consumidor paga apenas pelo seu proprio computo.

**P2: Um consumidor pode modificar dados compartilhados?**
R2: **Nao.** Dados compartilhados sao somente leitura para consumidores.

**P3: O que e necessario para compartilhar dados cross-region?**
R3: **Replicacao de banco de dados** para a regiao destino primeiro, depois criar o share la. Ou usar Marketplace com Auto-Fulfillment.

**P4: Que tipo de view DEVE ser usado em shares?**
R4: **Secure views** -- views regulares nao sao permitidas em shares.

**P5: Quem paga o computo em uma reader account?**
R5: O **provedor** paga tudo -- tanto armazenamento quanto computo.

**P6: Reader accounts podem carregar seus proprios dados?**
R6: **Nao.** Reader accounts so podem consultar dados compartilhados.

**P7: O que e Cross-Cloud Auto-Fulfillment?**
R7: Uma funcionalidade do Marketplace que **replica automaticamente** os listings para consumidores em diferentes regioes/nuvens, para que o provedor publique apenas uma vez.

**P8: Onde uma Native App e executada?**
R8: Na **conta do consumidor** -- o provedor nao pode ver os dados do consumidor.

**P9: O que e um Data Exchange?**
R9: Um grupo **privado, somente por convite** para compartilhar listings entre contas de confianca. Diferente do Marketplace, que e publico.

**P10: O que previne a exposicao de dados brutos em um data clean room?**
R10: **Templates de consulta pre-aprovados**, limites minimos de agregacao e controles de privacidade diferencial.

**P11: Um consumidor pode re-compartilhar dados recebidos atraves de um share?**
R11: **Nao.** O encadeamento de compartilhamento nao e permitido por design.

**P12: Qual arquivo define os metadados e privilegios de uma Native App?**
R12: O arquivo **manifest.yml** declara os privilegios necessarios, configuracao e metadados da app.

**P13: Para que serve o privilegio `REFERENCE_USAGE`?**
R13: Permite que um consumidor **crie views em seu proprio banco de dados que referenciem** objetos no banco de dados compartilhado.

**P14: Como um clean room garante a privacidade individual?**
R14: Os resultados devem atender **limites minimos de agregacao** (ex. 100+ individuos por grupo) e podem usar **ruido de privacidade diferencial**.

**P15: O que acontece se os dados compartilhados subjacentes mudam?**
R15: Os consumidores veem as mudancas **imediatamente** (para shares na mesma regiao) porque o compartilhamento e zero-copy -- eles leem as micro-particoes ao vivo do provedor.

---

## EXPLICADO PARA INICIANTES -- Dominio 5

**Explicacao #1: Compartilhamento Seguro de Dados**
Voce tem um livro de colorir. Em vez de fotocopiar paginas para seu amigo (o que desperdicaria papel), voce o deixa olhar seu livro atraves de uma janela. Ele pode ver e copiar, mas nao pode mudar seu livro, e voce nao tem duas copias.

**Explicacao #2: Provedor vs. Consumidor**
Voce assou biscoitos (provedor). Seu amigo os come (consumidor). Voce comprou os ingredientes (armazenamento). Seu amigo usa seu proprio prato e garfo (computo).

**Explicacao #3: Reader Accounts**
Seu amigo nao tem prato nem garfo. Entao voce da os seus. Voce esta pagando por tudo -- os biscoitos E o prato e garfo. Isso e uma reader account.

**Explicacao #4: Compartilhamento Cross-Region**
Seu amigo mora em outra cidade. Voce nao pode simplesmente segurar o livro de colorir -- ele esta muito longe. Voce precisa fazer uma copia e envia-la para a cidade dele primeiro (replicacao), depois ele pode olhar atraves da janela la.

**Explicacao #5: Marketplace**
Imagine uma biblioteca onde qualquer pessoa pode pegar emprestado qualquer livro de graca (ou por uma pequena taxa). Isso e o Marketplace. Qualquer pessoa pode navegar, encontrar conjuntos de dados e "pega-los emprestados" instantaneamente.

**Explicacao #6: Data Exchange**
Agora imagine um clube do livro privado. Apenas membros convidados podem compartilhar e pegar emprestados livros. Isso e o Data Exchange.

**Explicacao #7: Data Clean Rooms**
Voce e seu amigo tem, cada um, um saco de bolinhas de gude. Voces querem saber quantas cores compartilham, mas nenhum quer mostrar todas as suas bolinhas. Entao cada um coloca seu saco em uma caixa magica que so diz "Voces compartilham 3 cores" -- nao quais bolinhas especificas.

**Explicacao #8: Native Apps**
Alguem constroi um robo de brinquedo e o coloca em uma caixa com instrucoes. Voce o instala no SEU quarto, e ele brinca com SEUS brinquedos. O construtor nunca entra no seu quarto -- o robo funciona por conta propria.

**Explicacao #9: Secure Views**
Uma secure view e como um espelho unidirecional. Voce pode ver os dados atraves dele, mas nao pode ver os projetos de como o espelho foi construido ou o que esta escondido atras da parede.

**Explicacao #10: Auto-Fulfillment**
Voce vende limonada. Em vez de montar uma barraca em cada bairro voce mesmo, um ajudante magico aparece automaticamente em qualquer bairro onde alguem queira limonada. Voce so faz a receita uma vez.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 'es',
  '# Dominio 5: Compartir y Colaborar -- Soluciones de Intercambio de Datos

> **Peso en ARA-C01:** ~10-15% del examen.
> Enfoque en: mecanica de comparticion, patrones cross-region/cloud, cuentas reader, marketplace y Native Apps.

---

## 5.1 INTERCAMBIO SEGURO DE DATOS (SECURE DATA SHARING)

El modelo de **comparticion sin copia (zero-copy sharing)** es el diferenciador principal de Snowflake.

### Conceptos Clave

- **Provider (Proveedor)**: la cuenta que posee los datos y crea el share
- **Consumer (Consumidor)**: la cuenta que recibe el share y crea una base de datos a partir de el
- El intercambio es **zero-copy** -- no se duplican datos; el consumidor lee del almacenamiento del proveedor
- El proveedor paga el **almacenamiento**; el consumidor paga el **computo** (su propio warehouse)
- El intercambio usa **shares** -- objetos con nombre que contienen bases de datos, esquemas, tablas, vistas seguras y UDFs

**Que se puede compartir:**

- Tablas (completas o filtradas mediante vistas seguras)
- Secure views, secure materialized views
- Secure UDFs
- Esquemas (todos los objetos dentro de ellos)

**Que NO se puede compartir directamente:**

- Vistas no seguras (deben ser SECURE)
- Stages, pipes, tasks, streams
- Stored procedures
- Tablas temporales/transitorias (temporary/transient)

**Flujo de creacion de un share:**

```sql
CREATE SHARE my_share;
GRANT USAGE ON DATABASE mydb TO SHARE my_share;
GRANT USAGE ON SCHEMA mydb.public TO SHARE my_share;
GRANT SELECT ON TABLE mydb.public.customers TO SHARE my_share;
ALTER SHARE my_share ADD ACCOUNTS = consumer_account;
```

**Lado del consumidor:**

```sql
CREATE DATABASE shared_db FROM SHARE provider_account.my_share;
```

### Por Que Importa

Un proveedor de servicios de salud necesita compartir datos anonimizados de pacientes con un socio de investigacion. Crean una vista segura que enmascara la informacion personal (PII), la agregan a un share, y el socio la consulta directamente -- sin copias de datos, sin pipelines ETL, sin datos desactualizados. En tiempo real, siempre actualizado.

### Mejores Practicas

- Siempre usar **secure views** para controlar lo que ven los consumidores (filtrado a nivel de fila y columna)
- Otorgar solo los objetos minimos necesarios -- no compartir bases de datos completas a menos que sea necesario
- Monitorear el acceso a datos compartidos via `SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY`
- Documentar los shares y revisarlos trimestralmente

**Trampas del examen:**

- Trampa: SI VES "El consumidor paga el almacenamiento de datos compartidos" --> INCORRECTO porque el **proveedor** paga el almacenamiento; el consumidor solo paga el computo
- Trampa: SI VES "Las vistas regulares se pueden compartir" --> INCORRECTO porque solo las **secure views** pueden incluirse en shares; las vistas no seguras exponen la logica interna
- Trampa: SI VES "Los datos compartidos pueden ser modificados por el consumidor" --> INCORRECTO porque los datos compartidos son de **solo lectura** para los consumidores; no pueden hacer INSERT/UPDATE/DELETE
- Trampa: SI VES "Los shares crean una copia de los datos" --> INCORRECTO porque los shares son **zero-copy**; los consumidores consultan directamente las micro-particiones del proveedor

### Preguntas Frecuentes (FAQ)

**P: Puede un consumidor re-compartir datos que recibio?**
R: No. Los consumidores no pueden crear shares a partir de bases de datos compartidas. El encadenamiento de comparticion esta bloqueado por diseno.

**P: El proveedor ve las consultas del consumidor?**
R: No. El proveedor no tiene visibilidad sobre la actividad de consultas del consumidor. Los consumidores controlan su propio uso.

---

## 5.2 ESCENARIOS DE COMPARTICION

Diferentes topologias de comparticion tienen diferentes requisitos.

### Conceptos Clave

| Escenario | Mecanismo | Notas |
|-----------|-----------|-------|
| **Misma cuenta** | No aplica -- solo usar RBAC | La comparticion es entre cuentas, no dentro de una misma |
| **Misma region, misma nube** | Share directo | El mas simple -- zero-copy, sin replicacion |
| **Cross-region (misma nube)** | Replicacion de base de datos + share | Replicar datos a la region destino primero, luego compartir |
| **Cross-cloud** | Replicacion de base de datos + share | Igual que cross-region pero entre AWS/Azure/GCP |
| **Cliente sin Snowflake** | Reader account | El proveedor crea una cuenta administrada para el consumidor |

**Flujo cross-region / cross-cloud:**

1. El proveedor habilita la replicacion: `ALTER DATABASE mydb ENABLE REPLICATION TO ACCOUNTS target_account`
2. La cuenta destino crea la replica: `CREATE DATABASE mydb AS REPLICA OF source_account.mydb`
3. Actualizar la replica: `ALTER DATABASE mydb REFRESH`
4. Crear el share en la region destino usando la base de datos replicada
5. O: usar **Listing + Cross-Cloud Auto-Fulfillment** (maneja la replicacion automaticamente)

**Punto clave:** La comparticion directa solo funciona dentro de la **misma region y proveedor de nube**. Cualquier cosa cross-region o cross-cloud requiere replicacion primero (o auto-fulfillment).

### Por Que Importa

Una empresa global de retail en AWS us-east-1 necesita compartir datos de ventas con un socio en Azure West Europe. Deben replicar la base de datos a una cuenta en Azure West Europe primero, y luego crear el share alli. Sin entender esto, los arquitectos proponen comparticion directa y esta falla silenciosamente.

### Mejores Practicas

- Para comparticion cross-region frecuente, usar **Listings con Auto-Fulfillment** -- automatiza la replicacion
- Monitorear costos de replicacion en `REPLICATION_USAGE_HISTORY`
- La replicacion cross-cloud tiene costos de transferencia de datos -- considerar esto en la arquitectura
- Usar replication groups para escenarios con multiples bases de datos

**Trampas del examen:**

- Trampa: SI VES "La comparticion directa funciona entre regiones" --> INCORRECTO porque la comparticion directa requiere **misma region Y misma nube**; cross-region necesita replicacion primero
- Trampa: SI VES "La comparticion cross-cloud no es posible en Snowflake" --> INCORRECTO porque SI es posible via **replicacion de base de datos** a la nube/region destino, luego compartir
- Trampa: SI VES "Auto-Fulfillment elimina todos los costos de replicacion" --> INCORRECTO porque auto-fulfillment automatiza la replicacion pero los **costos de transferencia de datos siguen aplicando**

### Preguntas Frecuentes (FAQ)

**P: Puedo compartir entre dos cuentas de la misma organizacion pero en diferentes regiones?**
R: Si, via replicacion de base de datos + share, o a traves de un listing de Marketplace con Auto-Fulfillment.

**P: La replicacion es en tiempo real?**
R: No. La replicacion es casi en tiempo real con un calendario de actualizacion configurable. Siempre hay algo de retraso.

---

## 5.3 CUENTAS READER (READER ACCOUNTS)

Para compartir con organizaciones que **NO tienen una cuenta de Snowflake**.

### Conceptos Clave

- Creadas por el **proveedor** usando `CREATE MANAGED ACCOUNT`
- Las reader accounts son **cuentas administradas** -- completamente controladas por el proveedor
- **El proveedor paga TODO**: almacenamiento y computo
- Los usuarios de reader accounts solo pueden consultar datos compartidos -- no pueden cargar sus propios datos
- Funcionalidad limitada: sin carga de datos, sin shares desde reader accounts, administracion minima

**Capacidades de las Reader accounts:**

- Consultar datos compartidos via su propio warehouse (financiado por el proveedor)
- Crear usuarios dentro de la reader account
- Usar resource monitors (para controlar costos)

**No pueden:**

- Cargar datos en la cuenta
- Crear shares
- Acceder al Snowflake Marketplace
- Usar funciones avanzadas (tasks, streams, etc.)
- Replicar datos

### Por Que Importa

Una agencia gubernamental quiere compartir conjuntos de datos publicos con pequenos municipios que no pueden justificar una suscripcion a Snowflake. Las reader accounts permiten a la agencia compartir datos sin requerir que el municipio firme un contrato con Snowflake. Pero la agencia paga todos los costos de computo -- por lo que los resource monitors son esenciales.

### Mejores Practicas

- **Siempre** configurar resource monitors en los warehouses de reader accounts -- tu pagas su computo
- Mantener los warehouses de reader accounts pequenos (X-Small o Small)
- Configurar auto-suspend agresivo (60 segundos)
- Auditar periodicamente el uso de reader accounts via `RESOURCE_MONITORS` y `MANAGED_ACCOUNTS`
- Considerar listings de Marketplace si se desea que los consumidores paguen sus propios costos

**Trampas del examen:**

- Trampa: SI VES "Las reader accounts pueden cargar sus propios datos" --> INCORRECTO porque las reader accounts **solo pueden consultar datos compartidos**; no se permite carga de datos
- Trampa: SI VES "El consumidor paga el computo de la reader account" --> INCORRECTO porque el **proveedor paga todo** -- almacenamiento Y computo para reader accounts
- Trampa: SI VES "Las reader accounts pueden crear shares a otras cuentas" --> INCORRECTO porque las reader accounts no pueden crear shares, punto

### Preguntas Frecuentes (FAQ)

**P: Se puede convertir una reader account a una cuenta completa de Snowflake?**
R: No. Las reader accounts no pueden convertirse. La organizacion necesitaria firmar su propio contrato con Snowflake y se configuraria un share regular.

**P: Cuantas reader accounts puede crear un proveedor?**
R: No hay un limite estricto documentado, pero Snowflake puede imponer limites flexibles. Contactar soporte para numeros muy grandes.

---

## 5.4 MARKETPLACE E INTERCAMBIO DE DATOS (DATA EXCHANGE)

Marketplace es el catalogo publico de datos de Snowflake. Data Exchange es privado.

### Conceptos Clave

**Snowflake Marketplace:**

- Catalogo publico donde los proveedores **listan** conjuntos de datos para que cualquier cliente de Snowflake los descubra
- Listings gratuitos o de pago
- **Personalized listings** -- adaptados a consumidores especificos
- **Standard listings** -- disponibles para cualquiera
- Los consumidores obtienen datos instantaneamente -- zero-copy sharing detras de escena
- Proveedores: Snowflake, proveedores de datos de terceros, cualquier cliente de Snowflake

**Data Exchange (Privado):**

- Grupo **privado, solo por invitacion** de cuentas para compartir
- Creado por un cliente de Snowflake o por Snowflake mismo
- Los miembros pueden publicar y descubrir listings dentro del grupo
- Caso de uso: departamentos internos, socios de confianza, consorcios industriales

**Cross-Cloud Auto-Fulfillment:**

- Funcion de Marketplace que **replica automaticamente** los listings a consumidores en diferentes regiones/nubes
- El proveedor publica una vez --> Snowflake maneja la replicacion a donde sea que este el consumidor
- El proveedor paga los costos de transferencia/replicacion de datos
- Elimina la carga manual de replicacion en comparticion cross-region/cross-cloud

### Por Que Importa

Una empresa de datos meteorologicos publica pronosticos diarios en Snowflake Marketplace. Una cadena de retail en Azure East US lo descubre, hace clic en "Get", e instantaneamente tiene una base de datos compartida -- sin negociaciones, sin pipelines de datos, sin ETL. Cross-Cloud Auto-Fulfillment significa que la empresa meteorologica no necesita cuentas en cada region.

### Mejores Practicas

- Usar Marketplace para distribucion de datos **publica o semi-publica**
- Usar Data Exchange para comparticion **privada** dentro de un grupo de confianza
- Habilitar Auto-Fulfillment si los consumidores estan en multiples regiones/nubes
- Monitorear el uso de listings para entender la demanda y optimizar costos
- Escribir descripciones claras de listings -- los consumidores descubren datos mediante busqueda

**Trampas del examen:**

- Trampa: SI VES "Data Exchange es lo mismo que Marketplace" --> INCORRECTO porque Marketplace es **publico**, Data Exchange es **privado y solo por invitacion**
- Trampa: SI VES "Auto-Fulfillment es gratuito para los proveedores" --> INCORRECTO porque los proveedores siguen pagando **costos de replicacion y transferencia de datos**
- Trampa: SI VES "Los consumidores deben estar en la misma region para usar Marketplace" --> INCORRECTO porque **Auto-Fulfillment** maneja la entrega cross-region/cross-cloud automaticamente

### Preguntas Frecuentes (FAQ)

**P: Puedo cobrar por los listings de Marketplace?**
R: Si. Snowflake soporta listings de pago con precios basados en uso o fijos, administrados a traves del panel del proveedor.

**P: Quien gestiona la facturacion para listings de pago?**
R: Snowflake maneja la facturacion. Los consumidores pagan a traves de su factura de Snowflake, y Snowflake remite al proveedor.

---

## 5.5 DATA CLEAN ROOMS

Analisis seguro de datos entre multiples partes sin exponer datos crudos.

### Conceptos Clave

- **Proposito:** Dos o mas partes analizan datos superpuestos sin ver los datos crudos del otro
- Construido sobre la comparticion de Snowflake + secure views + controles de privacidad
- **Snowflake Data Clean Rooms** -- producto administrado (impulsado por el Native App Framework)
- Caso de uso tipico: anunciante + editor midiendo la superposicion de campanas sin exponer listas de clientes
- **Garantia clave:** ninguna parte ve los datos a nivel de fila del otro -- solo resultados agregados/anonimizados

**Como funciona (simplificado):**

1. La Parte A comparte sus datos en el clean room
2. La Parte B comparte sus datos en el clean room
3. Consultas pre-aprobadas (plantillas) se ejecutan sobre la superposicion
4. Los resultados devueltos son agregados -- umbrales minimos previenen la identificacion individual
5. Ninguna parte descarga los datos crudos del otro

**Controles de privacidad:**

- **Privacidad diferencial** -- agrega ruido estadistico para prevenir la re-identificacion
- **Umbrales minimos de agregacion** -- los resultados de consultas deben representar N+ individuos
- **Politicas de columna** -- restringen que columnas son unibles/visibles

### Por Que Importa

Un banco y un retailer quieren entender los clientes compartidos para una tarjeta de credito co-branded. Ninguno puede compartir listas de clientes debido a regulaciones. Un data clean room les permite calcular el "tamano de superposicion" y "gasto promedio" sin que ninguna parte vea registros individuales.

### Mejores Practicas

- Definir **plantillas de analisis** por adelantado -- restringir consultas ad-hoc
- Establecer umbrales minimos de agregacion significativos (ej. minimo 100 individuos por grupo)
- Usar el producto administrado de clean room de Snowflake en lugar de construir desde cero
- Auditar todas las consultas y resultados del clean room
- Involucrar a los equipos legales/de cumplimiento en el diseno del clean room

**Trampas del examen:**

- Trampa: SI VES "Los data clean rooms permiten que las partes vean los datos del otro" --> INCORRECTO porque los clean rooms **previenen** la exposicion de datos crudos; solo se devuelven resultados agregados
- Trampa: SI VES "Los clean rooms requieren que los datos se copien a un tercero" --> INCORRECTO porque los clean rooms de Snowflake usan **zero-copy sharing** -- los datos permanecen en la cuenta de cada parte
- Trampa: SI VES "Cualquier consulta puede ejecutarse en un clean room" --> INCORRECTO porque las consultas estan restringidas a **plantillas pre-aprobadas** para prevenir fuga de datos

### Preguntas Frecuentes (FAQ)

**P: Pueden mas de dos partes participar en un clean room?**
R: Si. Los clean rooms multi-parte estan soportados, aunque la complejidad aumenta.

**P: Es un clean room una cuenta separada de Snowflake?**
R: La logica del clean room se ejecuta como una Native App instalada en las cuentas participantes. Los datos permanecen en la cuenta de cada parte.

---

## 5.6 NATIVE APPS

El **Snowflake Native App Framework** permite a los proveedores empaquetar codigo + datos como aplicaciones instalables.

### Conceptos Clave

**Application Package:**

- El contenedor del **lado del proveedor** para la app
- Contiene: scripts de configuracion, codigo versionado, contenido de datos compartidos, UI de Streamlit, stored procedures, UDFs
- Se crea con `CREATE APPLICATION PACKAGE`
- Versionado: `ALTER APPLICATION PACKAGE ADD VERSION v1_0 USING ''@stage/v1''`

**Native App (Lado del consumidor):**

- Instalada por el consumidor desde un listing o directamente
- Creada a partir de un Application Package
- Se ejecuta **dentro de la cuenta del consumidor** -- el proveedor no puede ver los datos del consumidor
- Puede solicitar **privilegios** al consumidor (ej. acceso a tablas especificas)
- El consumidor controla que acceso otorgar

**Que pueden incluir las Native Apps:**

- Stored procedures y UDFs (SQL, Python, Java, Scala, JavaScript)
- Dashboards de Streamlit (UI)
- Contenido de datos compartidos (datos de referencia)
- Tasks y streams (para procesamiento automatizado)
- Integraciones de acceso externo (llamar APIs externas)

**Script de configuracion (`setup.sql`):**

- Se ejecuta cuando el consumidor instala la app
- Crea todos los objetos internos (esquemas, vistas, procedimientos, etc.)
- Define **roles de aplicacion** que se mapean a los privilegios otorgados por el consumidor

### Por Que Importa

Una empresa de enriquecimiento de datos construye una Native App que toma la tabla de clientes del consumidor, la enriquece con datos demograficos de terceros, y devuelve los resultados -- todo sin que los datos del consumidor salgan de su cuenta. El proveedor distribuye a traves de Marketplace, y cada consumidor obtiene su propia instalacion aislada.

### Mejores Practicas

- Usar **parches versionados** para actualizaciones de apps (los consumidores pueden actualizar a su ritmo)
- Minimizar las solicitudes de privilegios -- pedir solo lo que la app realmente necesita
- Incluir una UI de Streamlit para usuarios que no usan SQL
- Probar las apps exhaustivamente en un application package de desarrollo antes de publicar
- Usar `manifest.yml` para declarar privilegios requeridos y configuracion

**Trampas del examen:**

- Trampa: SI VES "Las Native Apps se ejecutan en la cuenta del proveedor" --> INCORRECTO porque las Native Apps se ejecutan **dentro de la cuenta del consumidor**; el proveedor no puede ver los datos del consumidor
- Trampa: SI VES "Las Native Apps automaticamente tienen acceso a los datos del consumidor" --> INCORRECTO porque el consumidor debe **otorgar explicitamente** los privilegios; la app los solicita, el consumidor los aprueba
- Trampa: SI VES "Las Native Apps son solo bases de datos compartidas" --> INCORRECTO porque las Native Apps pueden incluir **codigo** (procedimientos, UDFs, Streamlit), no solo datos

### Preguntas Frecuentes (FAQ)

**P: Puede una Native App escribir datos en la cuenta del consumidor?**
R: Si, si el consumidor otorga los privilegios necesarios (ej. CREATE TABLE en un esquema).

**P: Como reciben los consumidores actualizaciones de Native Apps?**
R: Los proveedores publican nuevas versiones/parches. Los consumidores pueden actualizar manualmente o el proveedor puede configurar actualizacion automatica.

---

## 5.7 PATRONES DE SEGURIDAD PARA COMPARTICION

La seguridad no es negociable al compartir datos.

### Conceptos Clave

**Las secure views son obligatorias:**

- Las vistas regulares exponen su definicion (SQL) a cualquiera con `SHOW VIEWS`
- Las secure views ocultan la definicion y previenen la inferencia de datos basada en el optimizador
- **Todas las vistas en shares DEBEN ser seguras** -- Snowflake impone esto
- Compromiso: las secure views pueden tener optimizacion ligeramente diferente (restricciones del optimizador de consultas)

**Jerarquia de privilegios del share:**

```
SHARE
  └── USAGE on DATABASE
       └── USAGE on SCHEMA
            └── SELECT on TABLE / VIEW / MATERIALIZED VIEW
            └── USAGE on UDF
```

- Se debe otorgar en cada nivel -- otorgar SELECT en una tabla sin USAGE en su esquema no funcionara
- `GRANT REFERENCE_USAGE ON DATABASE` -- permite al consumidor crear vistas que referencien datos compartidos

**La comparticion cross-region requiere replicacion primero:**

- No se puede crear un share y agregar un consumidor en una region diferente directamente
- Se debe replicar la base de datos (o usar Auto-Fulfillment para listings)
- La replicacion puede ser continua (`REPLICATION_SCHEDULE`) o manual (`ALTER DATABASE REFRESH`)

**Secure UDFs en shares:**

- El codigo fuente de la UDF esta oculto para los consumidores (igual que las definiciones de secure views)
- Los consumidores pueden llamarlas pero no pueden inspeccionar su logica

### Por Que Importa

Un arquitecto comparte una vista que contiene datos financieros pero olvida hacerla segura. El consumidor ejecuta `SHOW VIEWS` y ve la definicion SQL, que revela logica de filtrado oculta y nombres de tablas. Ahora conocen tablas que no deberian. Las secure views previenen esto.

### Mejores Practicas

- **Siempre** usar secure views -- nunca compartir vistas regulares
- Otorgar privilegios en el nivel mas granular posible
- Usar secure UDFs para logica de negocio que no se quiere exponer
- Para consumidores cross-region, planificar el retraso de replicacion en los SLAs
- Auditar shares regularmente: `SHOW SHARES`, `DESCRIBE SHARE`

**Trampas del examen:**

- Trampa: SI VES "Las vistas regulares pueden agregarse a shares" --> INCORRECTO porque Snowflake **requiere secure views** en shares; se obtendra un error al agregar una vista no segura
- Trampa: SI VES "Otorgar SELECT en una tabla es suficiente para compartir" --> INCORRECTO porque tambien se debe otorgar **USAGE en la DATABASE y el SCHEMA**
- Trampa: SI VES "Las secure views tienen rendimiento identico a las vistas regulares" --> INCORRECTO porque las secure views restringen ciertos **comportamientos del optimizador** para prevenir fuga de datos, lo que puede impactar ligeramente el rendimiento

### Preguntas Frecuentes (FAQ)

**P: Puedo compartir una secure materialized view?**
R: Si. Las secure materialized views pueden incluirse en shares.

**P: Si elimino y recreo una tabla que esta en un share, el consumidor pierde acceso?**
R: Si. El share referencia el objeto especifico. Se debe re-otorgar despues de recrear.

---

## TARJETAS DE REPASO -- Dominio 5

**P1: Quien paga el almacenamiento en un share directo?**
R1: El **proveedor** paga el almacenamiento. El consumidor paga solo su propio computo.

**P2: Puede un consumidor modificar datos compartidos?**
R2: **No.** Los datos compartidos son de solo lectura para los consumidores.

**P3: Que se requiere para compartir datos cross-region?**
R3: **Replicacion de base de datos** a la region destino primero, luego crear el share alli. O usar Marketplace con Auto-Fulfillment.

**P4: Que tipo de vista DEBE usarse en shares?**
R4: **Secure views** -- las vistas regulares no estan permitidas en shares.

**P5: Quien paga el computo en una reader account?**
R5: El **proveedor** paga todo -- tanto almacenamiento como computo.

**P6: Pueden las reader accounts cargar sus propios datos?**
R6: **No.** Las reader accounts solo pueden consultar datos compartidos.

**P7: Que es Cross-Cloud Auto-Fulfillment?**
R7: Una funcion de Marketplace que **replica automaticamente** los listings a consumidores en diferentes regiones/nubes, para que el proveedor solo publique una vez.

**P8: Donde se ejecuta una Native App?**
R8: En la **cuenta del consumidor** -- el proveedor no puede ver los datos del consumidor.

**P9: Que es un Data Exchange?**
R9: Un grupo **privado, solo por invitacion** para compartir listings entre cuentas de confianza. A diferencia de Marketplace, que es publico.

**P10: Que previene la exposicion de datos crudos en un data clean room?**
R10: **Plantillas de consulta pre-aprobadas**, umbrales minimos de agregacion y controles de privacidad diferencial.

**P11: Puede un consumidor re-compartir datos recibidos a traves de un share?**
R11: **No.** El encadenamiento de comparticion no esta permitido por diseno.

**P12: Que archivo define los metadatos y privilegios de una Native App?**
R12: El archivo **manifest.yml** declara los privilegios requeridos, configuracion y metadatos de la app.

**P13: Para que se usa el privilegio `REFERENCE_USAGE`?**
R13: Permite a un consumidor **crear vistas en su propia base de datos que referencien** objetos en la base de datos compartida.

**P14: Como garantiza un clean room la privacidad individual?**
R14: Los resultados deben cumplir **umbrales minimos de agregacion** (ej. 100+ individuos por grupo) y pueden usar **ruido de privacidad diferencial**.

**P15: Que sucede si los datos compartidos subyacentes cambian?**
R15: Los consumidores ven los cambios **inmediatamente** (para shares en la misma region) porque la comparticion es zero-copy -- leen las micro-particiones en vivo del proveedor.

---

## EXPLICADO PARA PRINCIPIANTES -- Dominio 5

**Explicacion #1: Intercambio Seguro de Datos**
Tienes un libro para colorear. En lugar de fotocopiar paginas para tu amigo (lo que desperdicia papel), le permites mirar tu libro a traves de una ventana. Puede ver y calcar, pero no puede cambiar tu libro, y no tienes dos copias.

**Explicacion #2: Proveedor vs. Consumidor**
Horneaste galletas (proveedor). Tu amigo se las come (consumidor). Tu compraste los ingredientes (almacenamiento). Tu amigo usa su propio plato y tenedor (computo).

**Explicacion #3: Reader Accounts**
Tu amigo no tiene plato ni tenedor. Asi que le das los tuyos. Estas pagando por todo -- las galletas Y el plato y tenedor. Eso es una reader account.

**Explicacion #4: Comparticion Cross-Region**
Tu amigo vive en otra ciudad. No puedes simplemente sostener el libro para colorear -- esta muy lejos. Necesitas hacer una copia y enviarla a su ciudad primero (replicacion), luego puede mirar a traves de la ventana alli.

**Explicacion #5: Marketplace**
Imagina una biblioteca donde cualquiera puede tomar prestado cualquier libro gratis (o por una pequena tarifa). Eso es Marketplace. Cualquiera puede navegar, encontrar conjuntos de datos y "tomarlos prestados" instantaneamente.

**Explicacion #6: Data Exchange**
Ahora imagina un club de lectura privado. Solo los miembros invitados pueden compartir y tomar prestados libros. Eso es Data Exchange.

**Explicacion #7: Data Clean Rooms**
Tu y tu amigo tienen cada uno una bolsa de canicas. Quieren saber cuantos colores comparten, pero ninguno quiere mostrar todas sus canicas. Asi que cada uno pone su bolsa en una caja magica que solo les dice "Comparten 3 colores" -- no cuales canicas especificas.

**Explicacion #8: Native Apps**
Alguien construye un robot de juguete y lo pone en una caja con instrucciones. Lo instalas en TU habitacion, y juega con TUS juguetes. El constructor nunca entra a tu habitacion -- el robot funciona por su cuenta.

**Explicacion #9: Secure Views**
Una secure view es como un espejo unidireccional. Puedes ver los datos a traves de el, pero no puedes ver los planos de como se construyo el espejo o que esta oculto detras de la pared.

**Explicacion #10: Auto-Fulfillment**
Vendes limonada. En lugar de montar un puesto en cada vecindario tu mismo, un ayudante magico aparece automaticamente en cualquier vecindario donde alguien quiera limonada. Tu solo haces la receta una vez.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 'en',
  '# Domain 6: DevOps & Ecosystem — Dev Lifecycle, Workloads, CI/CD, Tools

> **ARA-C01 Weight:** ~10-15% of the exam.
> Focus on: environment patterns, CI/CD with Snowflake, SPCS, AI/ML features, and architectural layers.

---

## 6.1 DEVELOPMENT LIFECYCLE

How to structure environments and promote changes safely.

### Key Concepts

**Environment tiers:**

| Environment | Purpose | Data | Access |
|-------------|---------|------|--------|
| **Production** | Live workloads, real users | Full production data | Restricted, audited |
| **Staging/QA** | Pre-production testing | Copy or subset of prod data | Test team |
| **Development** | Feature building | Synthetic or cloned data | Developers |
| **Sandbox** | Experimentation | Any data | Individual devs |

**Snowflake approach — database-level isolation:**

- Each environment = separate database (e.g., `PROD_DB`, `STAGING_DB`, `DEV_DB`)
- Use **zero-copy clones** to create dev/staging from prod — instant, no extra storage (until data diverges)
- Clones for testing: `CREATE DATABASE staging_db CLONE prod_db;`

**Zones/layers pattern:**

- **Raw/Landing zone** — data as ingested (Snowpipe, COPY INTO)
- **Transform zone** — cleaned, joined, business logic applied
- **Consumption zone** — curated datasets for BI, ML, sharing
- Each zone = separate schema or database for access control clarity

**Object tagging and environment management:**

- Use tags to identify environment: `ALTER TABLE t SET TAG env = ''prod''`
- Use roles to enforce access boundaries between environments
- `ACCOUNTADMIN` should never be used for daily dev work

### Why This Matters

A data engineer accidentally runs a DELETE on a production table during development. With proper environment isolation (separate databases + role restrictions), this is impossible. Without it, one mistake = outage.

### Best Practices

- **Clone production weekly** for staging — keeps test data realistic
- Use separate roles per environment: `DEV_ROLE`, `STAGING_ROLE`, `PROD_ROLE`
- Never grant `DEV_ROLE` write access to production databases
- Use `EXECUTE AS CALLER` vs. `EXECUTE AS OWNER` deliberately in procedures
- Implement a promotion workflow: dev → staging → prod (never skip staging)

**Exam traps:**

- Exam trap: IF YOU SEE "Clones double your storage cost" → WRONG because clones are **zero-copy** initially; you only pay for divergent data
- Exam trap: IF YOU SEE "All environments should use the same database with schema separation" → WRONG because **database-level** isolation provides stronger security boundaries than schemas alone
- Exam trap: IF YOU SEE "Sandbox environments should use production data directly" → WRONG because sandboxes should use **cloned or synthetic** data for safety and compliance

### Common Questions (FAQ)

**Q: Can I clone a share (shared database)?**
A: No. Shared databases cannot be cloned. Clone the source database in the provider account instead.

**Q: Do clones inherit grants?**
A: No by default. Use `CREATE ... CLONE ... COPY GRANTS` to carry over permissions.

---

## 6.2 CI/CD & DEPLOYMENT

Automating Snowflake deployments with modern DevOps practices.

### Key Concepts

**Snowflake CLI (`snow`):**

- Official command-line tool for Snowflake
- Commands: `snow sql`, `snow stage`, `snow connection`, `snow app`, `snow notebook`
- Used in CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins, Azure DevOps)
- Config file: `connections.toml` (stores connection profiles)

**Git integration:**

- Snowflake supports **Git repositories** as first-class objects
- `CREATE GIT REPOSITORY` — links a remote Git repo to Snowflake
- Fetch files directly: `SELECT * FROM @my_repo/branches/main/path/to/file`
- Use for versioned SQL scripts, stored procedure code, UDF source code
- Supports: GitHub, GitLab, Bitbucket, Azure DevOps

**Deployment patterns:**

| Pattern | Description | Best For |
|---------|-------------|----------|
| **Schema migration** | Sequential numbered scripts (V1, V2, V3...) | DDL changes, schema evolution |
| **State-based** | Desired state defined, tool generates diff | Declarative approaches |
| **Blue/green** | Two production copies, switch via SWAP | Zero-downtime deployments |

**Blue/green with `ALTER DATABASE ... SWAP WITH`:**

```sql
-- Deploy new version to BLUE
-- Test BLUE
ALTER DATABASE PROD_DB SWAP WITH BLUE_DB;
-- PROD_DB now has new version, BLUE_DB has the old (for rollback)
```

**Rollback strategies:**

- `UNDROP` — recovers dropped objects within retention period
- `TIME TRAVEL` — query or clone from a point in the past
- `SWAP` — swap back to previous blue/green database
- Keep migration scripts idempotent (`CREATE OR REPLACE`, `IF NOT EXISTS`)

### Why This Matters

A team deploys a broken stored procedure to production at 3 AM. With proper CI/CD: the pipeline ran tests in staging, the deployment was blue/green, and rolling back is one SWAP command. Without CI/CD: manual hotfix, extended outage, and angry stakeholders.

### Best Practices

- Store all DDL/DML in Git — no manual changes in production
- Use `CREATE OR REPLACE` over `CREATE ... IF NOT EXISTS` + `ALTER` when possible
- Run `snow sql -f migration.sql` in CI/CD pipelines
- Test migrations against a **clone of production** before deploying
- Use key-pair authentication (not passwords) in CI/CD pipelines
- Tag deployments: `ALTER SCHEMA SET TAG deployment_version = ''v2.3.1''`

**Exam traps:**

- Exam trap: IF YOU SEE "Snowflake has no native Git integration" → WRONG because Snowflake supports `CREATE GIT REPOSITORY` for direct Git repo integration
- Exam trap: IF YOU SEE "Blue/green requires two separate accounts" → WRONG because blue/green uses two **databases** in the same account, swapped with `ALTER DATABASE SWAP WITH`
- Exam trap: IF YOU SEE "Time Travel can only be used for queries, not rollbacks" → WRONG because you can `CREATE TABLE ... CLONE ... AT(TIMESTAMP => ...)` to restore a table from a previous point

### Common Questions (FAQ)

**Q: What authentication works best for CI/CD pipelines?**
A: **Key-pair authentication** — no passwords in pipeline configs, supports rotation, and is more secure than username/password.

**Q: Can Git repositories in Snowflake trigger pipelines?**
A: Not directly. Use your Git platform''s CI/CD (GitHub Actions, etc.) to trigger deployments. Snowflake Git repos are for reading files, not pipeline orchestration.

---

## 6.3 SNOWPARK CONTAINER SERVICES (SPCS)

Run **custom containers** (Docker) inside Snowflake''s managed infrastructure.

### Key Concepts

**What SPCS provides:**

- Fully managed container runtime inside Snowflake
- Run any Docker image — not limited to SQL/Python UDFs
- Supports: GPUs, networking between services, persistent storage via volumes
- Data **never leaves Snowflake** — container runs in the same cloud/region

**Key objects:**

| Object | Purpose |
|--------|---------|
| **Compute Pool** | Managed cluster of nodes (CPU/GPU) for running containers |
| **Image Repository** | Snowflake-hosted Docker registry for your images |
| **Service** | Running container(s) with defined spec (YAML) |
| **Service Function** | SQL function that calls a running service |
| **Ingress** | Public endpoint for exposing a service externally |

**Workflow:**

1. Push Docker image to Snowflake''s image repository
2. Create a compute pool (`CREATE COMPUTE POOL`)
3. Create a service with a YAML spec defining containers, resources, endpoints
4. Access via service functions (SQL), ingress (HTTP), or service-to-service networking

**Service specification (YAML) includes:**

- Container image reference
- Resource limits (CPU, memory, GPU)
- Endpoints (ports)
- Volume mounts
- Environment variables
- Secrets (for external API keys, etc.)

### Why This Matters

A data science team has a custom PyTorch model that can''t run as a UDF (it needs GPU, custom C++ libraries, and 32 GB RAM). SPCS lets them containerize it, deploy inside Snowflake, and call it from SQL — no data egress, no external infrastructure to manage.

### Best Practices

- Use **Snowpark-optimized warehouses** for memory-intensive SPCS workloads
- Keep container images minimal — faster startup, less storage cost
- Use **service functions** to integrate containers with SQL workflows
- Monitor compute pool usage — suspend when not needed
- Use Snowflake secrets for credentials — never hardcode API keys in images

**Exam traps:**

- Exam trap: IF YOU SEE "SPCS requires you to manage Kubernetes clusters" → WRONG because SPCS is **fully managed** — you define compute pools and services, Snowflake handles orchestration
- Exam trap: IF YOU SEE "SPCS containers can only use CPU" → WRONG because SPCS supports **GPU** compute pools (for ML inference, training, etc.)
- Exam trap: IF YOU SEE "Data must be exported from Snowflake to use SPCS" → WRONG because SPCS runs **inside** Snowflake — data stays within the platform
- Exam trap: IF YOU SEE "SPCS is the same as external functions" → WRONG because external functions call **outside** APIs; SPCS runs containers **inside** Snowflake

### Common Questions (FAQ)

**Q: Can SPCS services communicate with each other?**
A: Yes. Services in the same account can communicate via service-to-service networking using DNS names.

**Q: Are SPCS compute pools always running?**
A: No. Compute pools can be suspended and resumed. You pay only when they''re active.

---

## 6.4 AI/ML IN SNOWFLAKE

Snowflake''s native AI and machine learning capabilities.

### Key Concepts

**Cortex LLM Functions (Serverless):**

| Function | Purpose |
|----------|---------|
| `SNOWFLAKE.CORTEX.COMPLETE()` | Text generation / completion with LLMs |
| `SNOWFLAKE.CORTEX.SUMMARIZE()` | Text summarization |
| `SNOWFLAKE.CORTEX.SENTIMENT()` | Sentiment analysis (-1 to 1) |
| `SNOWFLAKE.CORTEX.TRANSLATE()` | Language translation |
| `SNOWFLAKE.CORTEX.EXTRACT_ANSWER()` | Q&A from text |
| `SNOWFLAKE.CORTEX.EMBED_TEXT_768()` | Text embeddings (768-dim) |
| `SNOWFLAKE.CORTEX.EMBED_TEXT_1024()` | Text embeddings (1024-dim) |

- All run **serverlessly** — no warehouse needed (billed per token/call)
- Data stays in Snowflake — LLMs run on Snowflake''s infrastructure
- Support various models: Llama, Mistral, others (Snowflake-hosted)

**Snowflake ML (formerly Snowpark ML):**

- **ML Functions (SQL-based):** `FORECAST()`, `ANOMALY_DETECTION()`, `CONTRIBUTION_EXPLORER()`, `CLASSIFICATION()`
- These are **automated ML** — no coding required, SQL interface
- Trained on Snowflake compute (serverless or warehouse-based)

**Snowflake ML Python API:**

- `snowflake.ml.modeling` — scikit-learn-compatible API that runs on Snowflake compute
- **Model Registry** — version, deploy, and manage models
- **Feature Store** — centralized feature engineering and sharing
- Models can be deployed as **model services** (container-based inference)

**Cortex Search:**

- Hybrid search (vector + keyword) over text data
- Create a search service: `CREATE CORTEX SEARCH SERVICE`
- Useful for RAG (Retrieval-Augmented Generation) pipelines

### Why This Matters

A retail company wants to classify customer feedback sentiment, forecast next month''s sales, and build a chatbot — all without moving data out of Snowflake. Cortex functions handle sentiment and the chatbot. ML Functions handle forecasting. The model registry tracks all model versions.

### Best Practices

- Use **Cortex LLM functions** for text tasks — avoid building custom NLP pipelines
- Use **ML Functions** for time-series forecasting and anomaly detection before reaching for custom models
- Register all models in the **Model Registry** for reproducibility and governance
- Use **Feature Store** to share feature engineering across teams
- For custom models (PyTorch, TensorFlow): use SPCS with GPU compute pools

**Exam traps:**

- Exam trap: IF YOU SEE "Cortex LLM functions require a running warehouse" → WRONG because Cortex LLM functions are **serverless** — no warehouse needed
- Exam trap: IF YOU SEE "Snowflake ML only supports Python" → WRONG because ML Functions like `FORECAST()` and `ANOMALY_DETECTION()` are accessible via **SQL** — no Python required
- Exam trap: IF YOU SEE "You must export data to train ML models" → WRONG because Snowflake ML training runs **inside Snowflake** on Snowflake compute

### Common Questions (FAQ)

**Q: Can I bring my own ML model to Snowflake?**
A: Yes. Use the Model Registry to log models (scikit-learn, XGBoost, PyTorch, etc.) and deploy them as model services.

**Q: What''s the difference between Cortex LLM functions and ML Functions?**
A: Cortex LLM functions are for **text/language** tasks (completion, sentiment, etc.). ML Functions are for **structured data** tasks (forecasting, anomaly detection, classification).

---

## 6.5 STREAMLIT & NATIVE APPS

Building interactive applications inside Snowflake.

### Key Concepts

**Streamlit in Snowflake (SiS):**

- Build Python-based web apps that run **inside Snowflake**
- No external infrastructure — the app runs on Snowflake compute
- Direct access to Snowflake data via the session — no connectors or credentials
- Supports: charts, tables, forms, file uploads, custom components
- Access controlled by Snowflake RBAC (roles, grants)
- Deployed via Snowsight UI or Snowflake CLI

**Key SiS patterns:**

- `st.connection("snowflake")` — get a Snowflake session
- `session.sql("SELECT ...")` — run queries and display results
- `st.dataframe()` — render DataFrames
- `st.cache_data` — cache query results for performance

**Native App Framework (for distribution):**

- Bundle Streamlit apps + procedures + data into an **Application Package**
- Distribute via Marketplace or direct share
- Consumer installs → gets a full app experience (UI + logic + data)
- Provider can include setup scripts, version management, upgrade paths

**When to use Streamlit vs. Native Apps:**

| Use Case | Tool |
|----------|------|
| Internal dashboard for your team | Streamlit in Snowflake |
| Admin tool for data ops | Streamlit in Snowflake |
| Product you sell to other Snowflake accounts | Native App (with Streamlit inside) |
| Partner integration with code + data | Native App |

### Why This Matters

The analytics team needs a self-service tool for marketing to explore campaign performance. Instead of building a React app with API layers and authentication, they write a 100-line Streamlit app inside Snowflake. It''s live in hours, inherits Snowflake RBAC, and costs nothing extra beyond warehouse compute.

### Best Practices

- Use `st.cache_data` aggressively to avoid redundant queries
- Design Streamlit apps for the warehouse they''ll use — keep queries efficient
- For Native Apps: version everything, use `manifest.yml` for metadata
- Test Native Apps in a dev application package before publishing
- Use Streamlit for prototyping before investing in full frontend apps

**Exam traps:**

- Exam trap: IF YOU SEE "Streamlit in Snowflake requires an external server" → WRONG because SiS runs **entirely within Snowflake** — no external hosting needed
- Exam trap: IF YOU SEE "Streamlit apps bypass Snowflake access control" → WRONG because SiS apps inherit **Snowflake RBAC** — the app runs with the user''s role
- Exam trap: IF YOU SEE "Native Apps are only for data sharing" → WRONG because Native Apps can include **code, UI (Streamlit), procedures, and data** — they''re full applications

### Common Questions (FAQ)

**Q: Can Streamlit apps access external APIs?**
A: Yes, via **external access integrations** that whitelist specific endpoints.

**Q: Who pays for Streamlit app compute?**
A: The account running the app pays — the app uses a Snowflake warehouse for computation.

---

## 6.6 DATA WAREHOUSE LAYERS

Architectural patterns for organizing data within Snowflake.

### Key Concepts

**Medallion Architecture (Bronze / Silver / Gold):**

| Layer | Also Called | Purpose | Data Quality |
|-------|-----------|---------|-------------|
| **Bronze** | Raw, Landing | Ingested data as-is | Low (raw) |
| **Silver** | Cleansed, Curated | Cleaned, deduped, typed | Medium |
| **Gold** | Aggregated, Consumption | Business-ready, aggregated | High |

**Bronze layer:**

- COPY INTO or Snowpipe loads raw data (JSON, CSV, Parquet, etc.)
- No transformations — preserve original data for lineage/audit
- Store as VARIANT for semi-structured, or raw columns for structured
- Append-only — never delete or modify

**Silver layer:**

- Flatten semi-structured data
- Apply data types, null handling, deduplication
- Join reference data
- Apply business rules (e.g., currency conversion, timezone normalization)
- Implemented as: dynamic tables, tasks + streams, dbt models, or procedures

**Gold layer:**

- Business-facing aggregations, KPIs, fact/dimension tables
- Optimized for BI tools (Tableau, Power BI, Sigma)
- Often materialized views or dynamic tables
- Secure views for sharing

**Directory structure in Snowflake:**

```
ANALYTICS_DB
├── RAW (bronze schemas)
│   ├── RAW.SALESFORCE
│   ├── RAW.STRIPE
│   └── RAW.WEB_EVENTS
├── CURATED (silver schemas)
│   ├── CURATED.CUSTOMERS
│   └── CURATED.TRANSACTIONS
└── CONSUMPTION (gold schemas)
    ├── CONSUMPTION.FINANCE_METRICS
    └── CONSUMPTION.MARKETING_DASHBOARD
```

Or use separate databases per layer:
```
RAW_DB → CURATED_DB → ANALYTICS_DB
```

### Why This Matters

A company loads Salesforce, Stripe, and web analytics data into one giant table. Six months later, nobody knows which column means what, transformations are scattered across 50 views, and debugging takes days. The medallion architecture prevents this chaos by enforcing clear boundaries.

### Best Practices

- **One database per major source in bronze** (or one schema per source)
- Silver should be the **single source of truth** — all downstream reads from here
- Gold should be **purpose-built** for specific consumers (BI team, ML team, sharing)
- Use **dynamic tables** for silver/gold layers — automatic incremental refresh
- Document transformations in each layer with comments or a metadata table
- Apply clustering keys at the gold layer (consumption-optimized)

**Exam traps:**

- Exam trap: IF YOU SEE "Bronze layer should clean and transform data" → WRONG because bronze is **raw ingestion only**; cleaning happens in silver
- Exam trap: IF YOU SEE "Gold layer stores all historical data" → WRONG because gold stores **aggregated, consumption-ready** data; full history lives in bronze/silver
- Exam trap: IF YOU SEE "You need exactly three layers" → WRONG because medallion is a **pattern, not a mandate**; some architectures use two layers or add a "platinum" layer
- Exam trap: IF YOU SEE "Each layer must be a separate database" → WRONG because layers can be **schemas within one database** or separate databases — both are valid

### Common Questions (FAQ)

**Q: Should I use separate databases or separate schemas for medallion layers?**
A: Separate databases provide stronger isolation and easier access control. Separate schemas are simpler for smaller projects. Choose based on your governance needs.

**Q: Where do dynamic tables fit in the medallion architecture?**
A: Dynamic tables are ideal for **silver and gold** layers — they automate incremental transformation from their upstream source.

**Q: How does dbt relate to medallion architecture?**
A: dbt models naturally map to medallion layers: `staging` models = silver, `marts` models = gold. dbt orchestrates the transformations between layers.

---

## FLASHCARDS — Domain 6

**Q1: What is the purpose of zero-copy clones in development environments?**
A1: They create **instant copies** of production data for dev/staging with **no additional storage cost** (until data diverges).

**Q2: What authentication method is recommended for CI/CD pipelines?**
A2: **Key-pair authentication** — more secure than passwords, supports rotation, no secrets in plaintext.

**Q3: How does Snowflake''s Git integration work?**
A3: `CREATE GIT REPOSITORY` links a remote repo. You can then reference files directly: `@my_repo/branches/main/path/file.sql`.

**Q4: What is a compute pool in SPCS?**
A4: A **managed cluster of nodes** (CPU or GPU) that runs container services. Can be suspended when idle.

**Q5: Name three Cortex LLM functions.**
A5: `COMPLETE()`, `SUMMARIZE()`, `SENTIMENT()`. Others: `TRANSLATE()`, `EXTRACT_ANSWER()`, `EMBED_TEXT_768()`.

**Q6: Do Cortex LLM functions require a warehouse?**
A6: **No.** They run serverlessly and are billed per token/call.

**Q7: What SQL ML function forecasts time-series data?**
A7: `FORECAST()` — an automated ML function accessible via SQL.

**Q8: Where do Streamlit in Snowflake apps run?**
A8: **Inside Snowflake** — on Snowflake compute, with no external server.

**Q9: What are the three medallion architecture layers?**
A9: **Bronze** (raw), **Silver** (cleansed/curated), **Gold** (aggregated/consumption).

**Q10: What is the blue/green deployment pattern in Snowflake?**
A10: Maintain two databases (blue/green). Deploy to one, test it, then `ALTER DATABASE ... SWAP WITH` for zero-downtime switch.

**Q11: Can SPCS services use GPUs?**
A11: **Yes.** Compute pools can be configured with GPU-enabled node types.

**Q12: What is the Snowflake Model Registry?**
A12: A versioning and deployment system for ML models. Log models, track versions, deploy as inference services.

**Q13: How do Native Apps differ from Streamlit in Snowflake?**
A13: Native Apps are **distributable packages** (code + data + UI) for other accounts. SiS is for **internal apps** within your account.

**Q14: What should the bronze layer contain?**
A14: **Raw data as ingested** — no transformations. Preserves original data for lineage and audit.

**Q15: What is `ALTER DATABASE SWAP WITH` used for?**
A15: **Blue/green deployments** — atomically swaps two databases, enabling zero-downtime releases and instant rollback.

---

## EXPLAIN LIKE I''M 5 — Domain 6

**ELI5 #1: Development Environments**
You''re building a sandcastle. The beach is production — people are enjoying it. You practice in a sandbox first (dev). When your design looks good, you show your parents (staging). Only then do you build it on the beach (production).

**ELI5 #2: Zero-Copy Clones**
You take a photo of the sandcastle instead of rebuilding it. The photo costs almost nothing. If someone draws on the photo, only the drawing costs extra — not the whole castle.

**ELI5 #3: CI/CD**
Imagine a conveyor belt in a toy factory. Someone designs a toy (code), it goes through a quality checker (tests), then gets packaged and shipped (deploy). The belt runs automatically — no one carries toys by hand.

**ELI5 #4: SPCS (Containers)**
You have a special LEGO room inside your house. You can build anything in that room — robots, cars, castles — using any pieces you want. The room is managed by your parents (Snowflake), so you don''t worry about the walls or roof.

**ELI5 #5: Cortex LLM Functions**
You have a really smart friend who lives inside your computer. You can ask them to summarize a story, tell you if an email is happy or sad, or translate something to Spanish. They''re always available and you don''t need any special equipment.

**ELI5 #6: ML Functions (FORECAST)**
You track how tall a plant grows every week: 2cm, 4cm, 6cm. FORECAST looks at the pattern and says "next week it''ll be about 8cm." It learns the pattern from your data.

**ELI5 #7: Streamlit in Snowflake**
You draw a control panel on paper — buttons, sliders, screens. Then magically, it becomes a real control panel that anyone at school can use. No wiring or electronics needed (no server setup).

**ELI5 #8: Medallion Architecture**
You pick apples from a tree (bronze — dirty, some bruised). You wash and sort them (silver — clean, inspected). You make apple pie slices on plates (gold — ready to eat).

**ELI5 #9: Blue/Green Deployment**
You have two identical toy train tracks. You run the old train on Track A. You build the new train on Track B and test it. When it works, you flip a switch and everyone rides Track B. If it breaks, flip back to Track A instantly.

**ELI5 #10: Git Integration**
Your recipe book (Git) is connected to your kitchen (Snowflake). Instead of retyping recipes, your kitchen can read directly from the book. When someone updates the book, the kitchen sees the new recipe next time it looks.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 'pt',
  '# Domain 6: DevOps & Ecosystem — Dev Lifecycle, Workloads, CI/CD, Tools

> **ARA-C01 Weight:** ~10-15% of the exam.
> Focus on: environment patterns, CI/CD with Snowflake, SPCS, AI/ML features, and architectural layers.

---

## 6.1 DEVELOPMENT LIFECYCLE

How to structure environments and promote changes safely.

### Key Concepts

**Environment tiers:**

| Environment | Purpose | Data | Access |
|-------------|---------|------|--------|
| **Production** | Live workloads, real users | Full production data | Restricted, audited |
| **Staging/QA** | Pre-production testing | Copy or subset of prod data | Test team |
| **Development** | Feature building | Synthetic or cloned data | Developers |
| **Sandbox** | Experimentation | Any data | Individual devs |

**Snowflake approach — database-level isolation:**

- Each environment = separate database (e.g., `PROD_DB`, `STAGING_DB`, `DEV_DB`)
- Use **zero-copy clones** to create dev/staging from prod — instant, no extra storage (until data diverges)
- Clones for testing: `CREATE DATABASE staging_db CLONE prod_db;`

**Zones/layers pattern:**

- **Raw/Landing zone** — data as ingested (Snowpipe, COPY INTO)
- **Transform zone** — cleaned, joined, business logic applied
- **Consumption zone** — curated datasets for BI, ML, sharing
- Each zone = separate schema or database for access control clarity

**Object tagging and environment management:**

- Use tags to identify environment: `ALTER TABLE t SET TAG env = ''prod''`
- Use roles to enforce access boundaries between environments
- `ACCOUNTADMIN` should never be used for daily dev work

### Why This Matters

A data engineer accidentally runs a DELETE on a production table during development. With proper environment isolation (separate databases + role restrictions), this is impossible. Without it, one mistake = outage.

### Best Practices

- **Clone production weekly** for staging — keeps test data realistic
- Use separate roles per environment: `DEV_ROLE`, `STAGING_ROLE`, `PROD_ROLE`
- Never grant `DEV_ROLE` write access to production databases
- Use `EXECUTE AS CALLER` vs. `EXECUTE AS OWNER` deliberately in procedures
- Implement a promotion workflow: dev → staging → prod (never skip staging)

**Exam traps:**

- Exam trap: IF YOU SEE "Clones double your storage cost" → WRONG because clones are **zero-copy** initially; you only pay for divergent data
- Exam trap: IF YOU SEE "All environments should use the same database with schema separation" → WRONG because **database-level** isolation provides stronger security boundaries than schemas alone
- Exam trap: IF YOU SEE "Sandbox environments should use production data directly" → WRONG because sandboxes should use **cloned or synthetic** data for safety and compliance

### Common Questions (FAQ)

**Q: Can I clone a share (shared database)?**
A: No. Shared databases cannot be cloned. Clone the source database in the provider account instead.

**Q: Do clones inherit grants?**
A: No by default. Use `CREATE ... CLONE ... COPY GRANTS` to carry over permissions.

---

## 6.2 CI/CD & DEPLOYMENT

Automating Snowflake deployments with modern DevOps practices.

### Key Concepts

**Snowflake CLI (`snow`):**

- Official command-line tool for Snowflake
- Commands: `snow sql`, `snow stage`, `snow connection`, `snow app`, `snow notebook`
- Used in CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins, Azure DevOps)
- Config file: `connections.toml` (stores connection profiles)

**Git integration:**

- Snowflake supports **Git repositories** as first-class objects
- `CREATE GIT REPOSITORY` — links a remote Git repo to Snowflake
- Fetch files directly: `SELECT * FROM @my_repo/branches/main/path/to/file`
- Use for versioned SQL scripts, stored procedure code, UDF source code
- Supports: GitHub, GitLab, Bitbucket, Azure DevOps

**Deployment patterns:**

| Pattern | Description | Best For |
|---------|-------------|----------|
| **Schema migration** | Sequential numbered scripts (V1, V2, V3...) | DDL changes, schema evolution |
| **State-based** | Desired state defined, tool generates diff | Declarative approaches |
| **Blue/green** | Two production copies, switch via SWAP | Zero-downtime deployments |

**Blue/green with `ALTER DATABASE ... SWAP WITH`:**

```sql
-- Deploy new version to BLUE
-- Test BLUE
ALTER DATABASE PROD_DB SWAP WITH BLUE_DB;
-- PROD_DB now has new version, BLUE_DB has the old (for rollback)
```

**Rollback strategies:**

- `UNDROP` — recovers dropped objects within retention period
- `TIME TRAVEL` — query or clone from a point in the past
- `SWAP` — swap back to previous blue/green database
- Keep migration scripts idempotent (`CREATE OR REPLACE`, `IF NOT EXISTS`)

### Why This Matters

A team deploys a broken stored procedure to production at 3 AM. With proper CI/CD: the pipeline ran tests in staging, the deployment was blue/green, and rolling back is one SWAP command. Without CI/CD: manual hotfix, extended outage, and angry stakeholders.

### Best Practices

- Store all DDL/DML in Git — no manual changes in production
- Use `CREATE OR REPLACE` over `CREATE ... IF NOT EXISTS` + `ALTER` when possible
- Run `snow sql -f migration.sql` in CI/CD pipelines
- Test migrations against a **clone of production** before deploying
- Use key-pair authentication (not passwords) in CI/CD pipelines
- Tag deployments: `ALTER SCHEMA SET TAG deployment_version = ''v2.3.1''`

**Exam traps:**

- Exam trap: IF YOU SEE "Snowflake has no native Git integration" → WRONG because Snowflake supports `CREATE GIT REPOSITORY` for direct Git repo integration
- Exam trap: IF YOU SEE "Blue/green requires two separate accounts" → WRONG because blue/green uses two **databases** in the same account, swapped with `ALTER DATABASE SWAP WITH`
- Exam trap: IF YOU SEE "Time Travel can only be used for queries, not rollbacks" → WRONG because you can `CREATE TABLE ... CLONE ... AT(TIMESTAMP => ...)` to restore a table from a previous point

### Common Questions (FAQ)

**Q: What authentication works best for CI/CD pipelines?**
A: **Key-pair authentication** — no passwords in pipeline configs, supports rotation, and is more secure than username/password.

**Q: Can Git repositories in Snowflake trigger pipelines?**
A: Not directly. Use your Git platform''s CI/CD (GitHub Actions, etc.) to trigger deployments. Snowflake Git repos are for reading files, not pipeline orchestration.

---

## 6.3 SNOWPARK CONTAINER SERVICES (SPCS)

Run **custom containers** (Docker) inside Snowflake''s managed infrastructure.

### Key Concepts

**What SPCS provides:**

- Fully managed container runtime inside Snowflake
- Run any Docker image — not limited to SQL/Python UDFs
- Supports: GPUs, networking between services, persistent storage via volumes
- Data **never leaves Snowflake** — container runs in the same cloud/region

**Key objects:**

| Object | Purpose |
|--------|---------|
| **Compute Pool** | Managed cluster of nodes (CPU/GPU) for running containers |
| **Image Repository** | Snowflake-hosted Docker registry for your images |
| **Service** | Running container(s) with defined spec (YAML) |
| **Service Function** | SQL function that calls a running service |
| **Ingress** | Public endpoint for exposing a service externally |

**Workflow:**

1. Push Docker image to Snowflake''s image repository
2. Create a compute pool (`CREATE COMPUTE POOL`)
3. Create a service with a YAML spec defining containers, resources, endpoints
4. Access via service functions (SQL), ingress (HTTP), or service-to-service networking

**Service specification (YAML) includes:**

- Container image reference
- Resource limits (CPU, memory, GPU)
- Endpoints (ports)
- Volume mounts
- Environment variables
- Secrets (for external API keys, etc.)

### Why This Matters

A data science team has a custom PyTorch model that can''t run as a UDF (it needs GPU, custom C++ libraries, and 32 GB RAM). SPCS lets them containerize it, deploy inside Snowflake, and call it from SQL — no data egress, no external infrastructure to manage.

### Best Practices

- Use **Snowpark-optimized warehouses** for memory-intensive SPCS workloads
- Keep container images minimal — faster startup, less storage cost
- Use **service functions** to integrate containers with SQL workflows
- Monitor compute pool usage — suspend when not needed
- Use Snowflake secrets for credentials — never hardcode API keys in images

**Exam traps:**

- Exam trap: IF YOU SEE "SPCS requires you to manage Kubernetes clusters" → WRONG because SPCS is **fully managed** — you define compute pools and services, Snowflake handles orchestration
- Exam trap: IF YOU SEE "SPCS containers can only use CPU" → WRONG because SPCS supports **GPU** compute pools (for ML inference, training, etc.)
- Exam trap: IF YOU SEE "Data must be exported from Snowflake to use SPCS" → WRONG because SPCS runs **inside** Snowflake — data stays within the platform
- Exam trap: IF YOU SEE "SPCS is the same as external functions" → WRONG because external functions call **outside** APIs; SPCS runs containers **inside** Snowflake

### Common Questions (FAQ)

**Q: Can SPCS services communicate with each other?**
A: Yes. Services in the same account can communicate via service-to-service networking using DNS names.

**Q: Are SPCS compute pools always running?**
A: No. Compute pools can be suspended and resumed. You pay only when they''re active.

---

## 6.4 AI/ML IN SNOWFLAKE

Snowflake''s native AI and machine learning capabilities.

### Key Concepts

**Cortex LLM Functions (Serverless):**

| Function | Purpose |
|----------|---------|
| `SNOWFLAKE.CORTEX.COMPLETE()` | Text generation / completion with LLMs |
| `SNOWFLAKE.CORTEX.SUMMARIZE()` | Text summarization |
| `SNOWFLAKE.CORTEX.SENTIMENT()` | Sentiment analysis (-1 to 1) |
| `SNOWFLAKE.CORTEX.TRANSLATE()` | Language translation |
| `SNOWFLAKE.CORTEX.EXTRACT_ANSWER()` | Q&A from text |
| `SNOWFLAKE.CORTEX.EMBED_TEXT_768()` | Text embeddings (768-dim) |
| `SNOWFLAKE.CORTEX.EMBED_TEXT_1024()` | Text embeddings (1024-dim) |

- All run **serverlessly** — no warehouse needed (billed per token/call)
- Data stays in Snowflake — LLMs run on Snowflake''s infrastructure
- Support various models: Llama, Mistral, others (Snowflake-hosted)

**Snowflake ML (formerly Snowpark ML):**

- **ML Functions (SQL-based):** `FORECAST()`, `ANOMALY_DETECTION()`, `CONTRIBUTION_EXPLORER()`, `CLASSIFICATION()`
- These are **automated ML** — no coding required, SQL interface
- Trained on Snowflake compute (serverless or warehouse-based)

**Snowflake ML Python API:**

- `snowflake.ml.modeling` — scikit-learn-compatible API that runs on Snowflake compute
- **Model Registry** — version, deploy, and manage models
- **Feature Store** — centralized feature engineering and sharing
- Models can be deployed as **model services** (container-based inference)

**Cortex Search:**

- Hybrid search (vector + keyword) over text data
- Create a search service: `CREATE CORTEX SEARCH SERVICE`
- Useful for RAG (Retrieval-Augmented Generation) pipelines

### Why This Matters

A retail company wants to classify customer feedback sentiment, forecast next month''s sales, and build a chatbot — all without moving data out of Snowflake. Cortex functions handle sentiment and the chatbot. ML Functions handle forecasting. The model registry tracks all model versions.

### Best Practices

- Use **Cortex LLM functions** for text tasks — avoid building custom NLP pipelines
- Use **ML Functions** for time-series forecasting and anomaly detection before reaching for custom models
- Register all models in the **Model Registry** for reproducibility and governance
- Use **Feature Store** to share feature engineering across teams
- For custom models (PyTorch, TensorFlow): use SPCS with GPU compute pools

**Exam traps:**

- Exam trap: IF YOU SEE "Cortex LLM functions require a running warehouse" → WRONG because Cortex LLM functions are **serverless** — no warehouse needed
- Exam trap: IF YOU SEE "Snowflake ML only supports Python" → WRONG because ML Functions like `FORECAST()` and `ANOMALY_DETECTION()` are accessible via **SQL** — no Python required
- Exam trap: IF YOU SEE "You must export data to train ML models" → WRONG because Snowflake ML training runs **inside Snowflake** on Snowflake compute

### Common Questions (FAQ)

**Q: Can I bring my own ML model to Snowflake?**
A: Yes. Use the Model Registry to log models (scikit-learn, XGBoost, PyTorch, etc.) and deploy them as model services.

**Q: What''s the difference between Cortex LLM functions and ML Functions?**
A: Cortex LLM functions are for **text/language** tasks (completion, sentiment, etc.). ML Functions are for **structured data** tasks (forecasting, anomaly detection, classification).

---

## 6.5 STREAMLIT & NATIVE APPS

Building interactive applications inside Snowflake.

### Key Concepts

**Streamlit in Snowflake (SiS):**

- Build Python-based web apps that run **inside Snowflake**
- No external infrastructure — the app runs on Snowflake compute
- Direct access to Snowflake data via the session — no connectors or credentials
- Supports: charts, tables, forms, file uploads, custom components
- Access controlled by Snowflake RBAC (roles, grants)
- Deployed via Snowsight UI or Snowflake CLI

**Key SiS patterns:**

- `st.connection("snowflake")` — get a Snowflake session
- `session.sql("SELECT ...")` — run queries and display results
- `st.dataframe()` — render DataFrames
- `st.cache_data` — cache query results for performance

**Native App Framework (for distribution):**

- Bundle Streamlit apps + procedures + data into an **Application Package**
- Distribute via Marketplace or direct share
- Consumer installs → gets a full app experience (UI + logic + data)
- Provider can include setup scripts, version management, upgrade paths

**When to use Streamlit vs. Native Apps:**

| Use Case | Tool |
|----------|------|
| Internal dashboard for your team | Streamlit in Snowflake |
| Admin tool for data ops | Streamlit in Snowflake |
| Product you sell to other Snowflake accounts | Native App (with Streamlit inside) |
| Partner integration with code + data | Native App |

### Why This Matters

The analytics team needs a self-service tool for marketing to explore campaign performance. Instead of building a React app with API layers and authentication, they write a 100-line Streamlit app inside Snowflake. It''s live in hours, inherits Snowflake RBAC, and costs nothing extra beyond warehouse compute.

### Best Practices

- Use `st.cache_data` aggressively to avoid redundant queries
- Design Streamlit apps for the warehouse they''ll use — keep queries efficient
- For Native Apps: version everything, use `manifest.yml` for metadata
- Test Native Apps in a dev application package before publishing
- Use Streamlit for prototyping before investing in full frontend apps

**Exam traps:**

- Exam trap: IF YOU SEE "Streamlit in Snowflake requires an external server" → WRONG because SiS runs **entirely within Snowflake** — no external hosting needed
- Exam trap: IF YOU SEE "Streamlit apps bypass Snowflake access control" → WRONG because SiS apps inherit **Snowflake RBAC** — the app runs with the user''s role
- Exam trap: IF YOU SEE "Native Apps are only for data sharing" → WRONG because Native Apps can include **code, UI (Streamlit), procedures, and data** — they''re full applications

### Common Questions (FAQ)

**Q: Can Streamlit apps access external APIs?**
A: Yes, via **external access integrations** that whitelist specific endpoints.

**Q: Who pays for Streamlit app compute?**
A: The account running the app pays — the app uses a Snowflake warehouse for computation.

---

## 6.6 DATA WAREHOUSE LAYERS

Architectural patterns for organizing data within Snowflake.

### Key Concepts

**Medallion Architecture (Bronze / Silver / Gold):**

| Layer | Also Called | Purpose | Data Quality |
|-------|-----------|---------|-------------|
| **Bronze** | Raw, Landing | Ingested data as-is | Low (raw) |
| **Silver** | Cleansed, Curated | Cleaned, deduped, typed | Medium |
| **Gold** | Aggregated, Consumption | Business-ready, aggregated | High |

**Bronze layer:**

- COPY INTO or Snowpipe loads raw data (JSON, CSV, Parquet, etc.)
- No transformations — preserve original data for lineage/audit
- Store as VARIANT for semi-structured, or raw columns for structured
- Append-only — never delete or modify

**Silver layer:**

- Flatten semi-structured data
- Apply data types, null handling, deduplication
- Join reference data
- Apply business rules (e.g., currency conversion, timezone normalization)
- Implemented as: dynamic tables, tasks + streams, dbt models, or procedures

**Gold layer:**

- Business-facing aggregations, KPIs, fact/dimension tables
- Optimized for BI tools (Tableau, Power BI, Sigma)
- Often materialized views or dynamic tables
- Secure views for sharing

**Directory structure in Snowflake:**

```
ANALYTICS_DB
├── RAW (bronze schemas)
│   ├── RAW.SALESFORCE
│   ├── RAW.STRIPE
│   └── RAW.WEB_EVENTS
├── CURATED (silver schemas)
│   ├── CURATED.CUSTOMERS
│   └── CURATED.TRANSACTIONS
└── CONSUMPTION (gold schemas)
    ├── CONSUMPTION.FINANCE_METRICS
    └── CONSUMPTION.MARKETING_DASHBOARD
```

Or use separate databases per layer:
```
RAW_DB → CURATED_DB → ANALYTICS_DB
```

### Why This Matters

A company loads Salesforce, Stripe, and web analytics data into one giant table. Six months later, nobody knows which column means what, transformations are scattered across 50 views, and debugging takes days. The medallion architecture prevents this chaos by enforcing clear boundaries.

### Best Practices

- **One database per major source in bronze** (or one schema per source)
- Silver should be the **single source of truth** — all downstream reads from here
- Gold should be **purpose-built** for specific consumers (BI team, ML team, sharing)
- Use **dynamic tables** for silver/gold layers — automatic incremental refresh
- Document transformations in each layer with comments or a metadata table
- Apply clustering keys at the gold layer (consumption-optimized)

**Exam traps:**

- Exam trap: IF YOU SEE "Bronze layer should clean and transform data" → WRONG because bronze is **raw ingestion only**; cleaning happens in silver
- Exam trap: IF YOU SEE "Gold layer stores all historical data" → WRONG because gold stores **aggregated, consumption-ready** data; full history lives in bronze/silver
- Exam trap: IF YOU SEE "You need exactly three layers" → WRONG because medallion is a **pattern, not a mandate**; some architectures use two layers or add a "platinum" layer
- Exam trap: IF YOU SEE "Each layer must be a separate database" → WRONG because layers can be **schemas within one database** or separate databases — both are valid

### Common Questions (FAQ)

**Q: Should I use separate databases or separate schemas for medallion layers?**
A: Separate databases provide stronger isolation and easier access control. Separate schemas are simpler for smaller projects. Choose based on your governance needs.

**Q: Where do dynamic tables fit in the medallion architecture?**
A: Dynamic tables are ideal for **silver and gold** layers — they automate incremental transformation from their upstream source.

**Q: How does dbt relate to medallion architecture?**
A: dbt models naturally map to medallion layers: `staging` models = silver, `marts` models = gold. dbt orchestrates the transformations between layers.

---

## FLASHCARDS — Domain 6

**Q1: What is the purpose of zero-copy clones in development environments?**
A1: They create **instant copies** of production data for dev/staging with **no additional storage cost** (until data diverges).

**Q2: What authentication method is recommended for CI/CD pipelines?**
A2: **Key-pair authentication** — more secure than passwords, supports rotation, no secrets in plaintext.

**Q3: How does Snowflake''s Git integration work?**
A3: `CREATE GIT REPOSITORY` links a remote repo. You can then reference files directly: `@my_repo/branches/main/path/file.sql`.

**Q4: What is a compute pool in SPCS?**
A4: A **managed cluster of nodes** (CPU or GPU) that runs container services. Can be suspended when idle.

**Q5: Name three Cortex LLM functions.**
A5: `COMPLETE()`, `SUMMARIZE()`, `SENTIMENT()`. Others: `TRANSLATE()`, `EXTRACT_ANSWER()`, `EMBED_TEXT_768()`.

**Q6: Do Cortex LLM functions require a warehouse?**
A6: **No.** They run serverlessly and are billed per token/call.

**Q7: What SQL ML function forecasts time-series data?**
A7: `FORECAST()` — an automated ML function accessible via SQL.

**Q8: Where do Streamlit in Snowflake apps run?**
A8: **Inside Snowflake** — on Snowflake compute, with no external server.

**Q9: What are the three medallion architecture layers?**
A9: **Bronze** (raw), **Silver** (cleansed/curated), **Gold** (aggregated/consumption).

**Q10: What is the blue/green deployment pattern in Snowflake?**
A10: Maintain two databases (blue/green). Deploy to one, test it, then `ALTER DATABASE ... SWAP WITH` for zero-downtime switch.

**Q11: Can SPCS services use GPUs?**
A11: **Yes.** Compute pools can be configured with GPU-enabled node types.

**Q12: What is the Snowflake Model Registry?**
A12: A versioning and deployment system for ML models. Log models, track versions, deploy as inference services.

**Q13: How do Native Apps differ from Streamlit in Snowflake?**
A13: Native Apps are **distributable packages** (code + data + UI) for other accounts. SiS is for **internal apps** within your account.

**Q14: What should the bronze layer contain?**
A14: **Raw data as ingested** — no transformations. Preserves original data for lineage and audit.

**Q15: What is `ALTER DATABASE SWAP WITH` used for?**
A15: **Blue/green deployments** — atomically swaps two databases, enabling zero-downtime releases and instant rollback.

---

## EXPLAIN LIKE I''M 5 — Domain 6

**ELI5 #1: Development Environments**
You''re building a sandcastle. The beach is production — people are enjoying it. You practice in a sandbox first (dev). When your design looks good, you show your parents (staging). Only then do you build it on the beach (production).

**ELI5 #2: Zero-Copy Clones**
You take a photo of the sandcastle instead of rebuilding it. The photo costs almost nothing. If someone draws on the photo, only the drawing costs extra — not the whole castle.

**ELI5 #3: CI/CD**
Imagine a conveyor belt in a toy factory. Someone designs a toy (code), it goes through a quality checker (tests), then gets packaged and shipped (deploy). The belt runs automatically — no one carries toys by hand.

**ELI5 #4: SPCS (Containers)**
You have a special LEGO room inside your house. You can build anything in that room — robots, cars, castles — using any pieces you want. The room is managed by your parents (Snowflake), so you don''t worry about the walls or roof.

**ELI5 #5: Cortex LLM Functions**
You have a really smart friend who lives inside your computer. You can ask them to summarize a story, tell you if an email is happy or sad, or translate something to Spanish. They''re always available and you don''t need any special equipment.

**ELI5 #6: ML Functions (FORECAST)**
You track how tall a plant grows every week: 2cm, 4cm, 6cm. FORECAST looks at the pattern and says "next week it''ll be about 8cm." It learns the pattern from your data.

**ELI5 #7: Streamlit in Snowflake**
You draw a control panel on paper — buttons, sliders, screens. Then magically, it becomes a real control panel that anyone at school can use. No wiring or electronics needed (no server setup).

**ELI5 #8: Medallion Architecture**
You pick apples from a tree (bronze — dirty, some bruised). You wash and sort them (silver — clean, inspected). You make apple pie slices on plates (gold — ready to eat).

**ELI5 #9: Blue/Green Deployment**
You have two identical toy train tracks. You run the old train on Track A. You build the new train on Track B and test it. When it works, you flip a switch and everyone rides Track B. If it breaks, flip back to Track A instantly.

**ELI5 #10: Git Integration**
Your recipe book (Git) is connected to your kitchen (Snowflake). Instead of retyping recipes, your kitchen can read directly from the book. When someone updates the book, the kitchen sees the new recipe next time it looks.
');

INSERT INTO PST.PS_APPS_DEV.CERT_REVIEW_NOTES
(CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 'es',
  '# Domain 6: DevOps & Ecosystem — Dev Lifecycle, Workloads, CI/CD, Tools

> **ARA-C01 Weight:** ~10-15% of the exam.
> Focus on: environment patterns, CI/CD with Snowflake, SPCS, AI/ML features, and architectural layers.

---

## 6.1 DEVELOPMENT LIFECYCLE

How to structure environments and promote changes safely.

### Key Concepts

**Environment tiers:**

| Environment | Purpose | Data | Access |
|-------------|---------|------|--------|
| **Production** | Live workloads, real users | Full production data | Restricted, audited |
| **Staging/QA** | Pre-production testing | Copy or subset of prod data | Test team |
| **Development** | Feature building | Synthetic or cloned data | Developers |
| **Sandbox** | Experimentation | Any data | Individual devs |

**Snowflake approach — database-level isolation:**

- Each environment = separate database (e.g., `PROD_DB`, `STAGING_DB`, `DEV_DB`)
- Use **zero-copy clones** to create dev/staging from prod — instant, no extra storage (until data diverges)
- Clones for testing: `CREATE DATABASE staging_db CLONE prod_db;`

**Zones/layers pattern:**

- **Raw/Landing zone** — data as ingested (Snowpipe, COPY INTO)
- **Transform zone** — cleaned, joined, business logic applied
- **Consumption zone** — curated datasets for BI, ML, sharing
- Each zone = separate schema or database for access control clarity

**Object tagging and environment management:**

- Use tags to identify environment: `ALTER TABLE t SET TAG env = ''prod''`
- Use roles to enforce access boundaries between environments
- `ACCOUNTADMIN` should never be used for daily dev work

### Why This Matters

A data engineer accidentally runs a DELETE on a production table during development. With proper environment isolation (separate databases + role restrictions), this is impossible. Without it, one mistake = outage.

### Best Practices

- **Clone production weekly** for staging — keeps test data realistic
- Use separate roles per environment: `DEV_ROLE`, `STAGING_ROLE`, `PROD_ROLE`
- Never grant `DEV_ROLE` write access to production databases
- Use `EXECUTE AS CALLER` vs. `EXECUTE AS OWNER` deliberately in procedures
- Implement a promotion workflow: dev → staging → prod (never skip staging)

**Exam traps:**

- Exam trap: IF YOU SEE "Clones double your storage cost" → WRONG because clones are **zero-copy** initially; you only pay for divergent data
- Exam trap: IF YOU SEE "All environments should use the same database with schema separation" → WRONG because **database-level** isolation provides stronger security boundaries than schemas alone
- Exam trap: IF YOU SEE "Sandbox environments should use production data directly" → WRONG because sandboxes should use **cloned or synthetic** data for safety and compliance

### Common Questions (FAQ)

**Q: Can I clone a share (shared database)?**
A: No. Shared databases cannot be cloned. Clone the source database in the provider account instead.

**Q: Do clones inherit grants?**
A: No by default. Use `CREATE ... CLONE ... COPY GRANTS` to carry over permissions.

---

## 6.2 CI/CD & DEPLOYMENT

Automating Snowflake deployments with modern DevOps practices.

### Key Concepts

**Snowflake CLI (`snow`):**

- Official command-line tool for Snowflake
- Commands: `snow sql`, `snow stage`, `snow connection`, `snow app`, `snow notebook`
- Used in CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins, Azure DevOps)
- Config file: `connections.toml` (stores connection profiles)

**Git integration:**

- Snowflake supports **Git repositories** as first-class objects
- `CREATE GIT REPOSITORY` — links a remote Git repo to Snowflake
- Fetch files directly: `SELECT * FROM @my_repo/branches/main/path/to/file`
- Use for versioned SQL scripts, stored procedure code, UDF source code
- Supports: GitHub, GitLab, Bitbucket, Azure DevOps

**Deployment patterns:**

| Pattern | Description | Best For |
|---------|-------------|----------|
| **Schema migration** | Sequential numbered scripts (V1, V2, V3...) | DDL changes, schema evolution |
| **State-based** | Desired state defined, tool generates diff | Declarative approaches |
| **Blue/green** | Two production copies, switch via SWAP | Zero-downtime deployments |

**Blue/green with `ALTER DATABASE ... SWAP WITH`:**

```sql
-- Deploy new version to BLUE
-- Test BLUE
ALTER DATABASE PROD_DB SWAP WITH BLUE_DB;
-- PROD_DB now has new version, BLUE_DB has the old (for rollback)
```

**Rollback strategies:**

- `UNDROP` — recovers dropped objects within retention period
- `TIME TRAVEL` — query or clone from a point in the past
- `SWAP` — swap back to previous blue/green database
- Keep migration scripts idempotent (`CREATE OR REPLACE`, `IF NOT EXISTS`)

### Why This Matters

A team deploys a broken stored procedure to production at 3 AM. With proper CI/CD: the pipeline ran tests in staging, the deployment was blue/green, and rolling back is one SWAP command. Without CI/CD: manual hotfix, extended outage, and angry stakeholders.

### Best Practices

- Store all DDL/DML in Git — no manual changes in production
- Use `CREATE OR REPLACE` over `CREATE ... IF NOT EXISTS` + `ALTER` when possible
- Run `snow sql -f migration.sql` in CI/CD pipelines
- Test migrations against a **clone of production** before deploying
- Use key-pair authentication (not passwords) in CI/CD pipelines
- Tag deployments: `ALTER SCHEMA SET TAG deployment_version = ''v2.3.1''`

**Exam traps:**

- Exam trap: IF YOU SEE "Snowflake has no native Git integration" → WRONG because Snowflake supports `CREATE GIT REPOSITORY` for direct Git repo integration
- Exam trap: IF YOU SEE "Blue/green requires two separate accounts" → WRONG because blue/green uses two **databases** in the same account, swapped with `ALTER DATABASE SWAP WITH`
- Exam trap: IF YOU SEE "Time Travel can only be used for queries, not rollbacks" → WRONG because you can `CREATE TABLE ... CLONE ... AT(TIMESTAMP => ...)` to restore a table from a previous point

### Common Questions (FAQ)

**Q: What authentication works best for CI/CD pipelines?**
A: **Key-pair authentication** — no passwords in pipeline configs, supports rotation, and is more secure than username/password.

**Q: Can Git repositories in Snowflake trigger pipelines?**
A: Not directly. Use your Git platform''s CI/CD (GitHub Actions, etc.) to trigger deployments. Snowflake Git repos are for reading files, not pipeline orchestration.

---

## 6.3 SNOWPARK CONTAINER SERVICES (SPCS)

Run **custom containers** (Docker) inside Snowflake''s managed infrastructure.

### Key Concepts

**What SPCS provides:**

- Fully managed container runtime inside Snowflake
- Run any Docker image — not limited to SQL/Python UDFs
- Supports: GPUs, networking between services, persistent storage via volumes
- Data **never leaves Snowflake** — container runs in the same cloud/region

**Key objects:**

| Object | Purpose |
|--------|---------|
| **Compute Pool** | Managed cluster of nodes (CPU/GPU) for running containers |
| **Image Repository** | Snowflake-hosted Docker registry for your images |
| **Service** | Running container(s) with defined spec (YAML) |
| **Service Function** | SQL function that calls a running service |
| **Ingress** | Public endpoint for exposing a service externally |

**Workflow:**

1. Push Docker image to Snowflake''s image repository
2. Create a compute pool (`CREATE COMPUTE POOL`)
3. Create a service with a YAML spec defining containers, resources, endpoints
4. Access via service functions (SQL), ingress (HTTP), or service-to-service networking

**Service specification (YAML) includes:**

- Container image reference
- Resource limits (CPU, memory, GPU)
- Endpoints (ports)
- Volume mounts
- Environment variables
- Secrets (for external API keys, etc.)

### Why This Matters

A data science team has a custom PyTorch model that can''t run as a UDF (it needs GPU, custom C++ libraries, and 32 GB RAM). SPCS lets them containerize it, deploy inside Snowflake, and call it from SQL — no data egress, no external infrastructure to manage.

### Best Practices

- Use **Snowpark-optimized warehouses** for memory-intensive SPCS workloads
- Keep container images minimal — faster startup, less storage cost
- Use **service functions** to integrate containers with SQL workflows
- Monitor compute pool usage — suspend when not needed
- Use Snowflake secrets for credentials — never hardcode API keys in images

**Exam traps:**

- Exam trap: IF YOU SEE "SPCS requires you to manage Kubernetes clusters" → WRONG because SPCS is **fully managed** — you define compute pools and services, Snowflake handles orchestration
- Exam trap: IF YOU SEE "SPCS containers can only use CPU" → WRONG because SPCS supports **GPU** compute pools (for ML inference, training, etc.)
- Exam trap: IF YOU SEE "Data must be exported from Snowflake to use SPCS" → WRONG because SPCS runs **inside** Snowflake — data stays within the platform
- Exam trap: IF YOU SEE "SPCS is the same as external functions" → WRONG because external functions call **outside** APIs; SPCS runs containers **inside** Snowflake

### Common Questions (FAQ)

**Q: Can SPCS services communicate with each other?**
A: Yes. Services in the same account can communicate via service-to-service networking using DNS names.

**Q: Are SPCS compute pools always running?**
A: No. Compute pools can be suspended and resumed. You pay only when they''re active.

---

## 6.4 AI/ML IN SNOWFLAKE

Snowflake''s native AI and machine learning capabilities.

### Key Concepts

**Cortex LLM Functions (Serverless):**

| Function | Purpose |
|----------|---------|
| `SNOWFLAKE.CORTEX.COMPLETE()` | Text generation / completion with LLMs |
| `SNOWFLAKE.CORTEX.SUMMARIZE()` | Text summarization |
| `SNOWFLAKE.CORTEX.SENTIMENT()` | Sentiment analysis (-1 to 1) |
| `SNOWFLAKE.CORTEX.TRANSLATE()` | Language translation |
| `SNOWFLAKE.CORTEX.EXTRACT_ANSWER()` | Q&A from text |
| `SNOWFLAKE.CORTEX.EMBED_TEXT_768()` | Text embeddings (768-dim) |
| `SNOWFLAKE.CORTEX.EMBED_TEXT_1024()` | Text embeddings (1024-dim) |

- All run **serverlessly** — no warehouse needed (billed per token/call)
- Data stays in Snowflake — LLMs run on Snowflake''s infrastructure
- Support various models: Llama, Mistral, others (Snowflake-hosted)

**Snowflake ML (formerly Snowpark ML):**

- **ML Functions (SQL-based):** `FORECAST()`, `ANOMALY_DETECTION()`, `CONTRIBUTION_EXPLORER()`, `CLASSIFICATION()`
- These are **automated ML** — no coding required, SQL interface
- Trained on Snowflake compute (serverless or warehouse-based)

**Snowflake ML Python API:**

- `snowflake.ml.modeling` — scikit-learn-compatible API that runs on Snowflake compute
- **Model Registry** — version, deploy, and manage models
- **Feature Store** — centralized feature engineering and sharing
- Models can be deployed as **model services** (container-based inference)

**Cortex Search:**

- Hybrid search (vector + keyword) over text data
- Create a search service: `CREATE CORTEX SEARCH SERVICE`
- Useful for RAG (Retrieval-Augmented Generation) pipelines

### Why This Matters

A retail company wants to classify customer feedback sentiment, forecast next month''s sales, and build a chatbot — all without moving data out of Snowflake. Cortex functions handle sentiment and the chatbot. ML Functions handle forecasting. The model registry tracks all model versions.

### Best Practices

- Use **Cortex LLM functions** for text tasks — avoid building custom NLP pipelines
- Use **ML Functions** for time-series forecasting and anomaly detection before reaching for custom models
- Register all models in the **Model Registry** for reproducibility and governance
- Use **Feature Store** to share feature engineering across teams
- For custom models (PyTorch, TensorFlow): use SPCS with GPU compute pools

**Exam traps:**

- Exam trap: IF YOU SEE "Cortex LLM functions require a running warehouse" → WRONG because Cortex LLM functions are **serverless** — no warehouse needed
- Exam trap: IF YOU SEE "Snowflake ML only supports Python" → WRONG because ML Functions like `FORECAST()` and `ANOMALY_DETECTION()` are accessible via **SQL** — no Python required
- Exam trap: IF YOU SEE "You must export data to train ML models" → WRONG because Snowflake ML training runs **inside Snowflake** on Snowflake compute

### Common Questions (FAQ)

**Q: Can I bring my own ML model to Snowflake?**
A: Yes. Use the Model Registry to log models (scikit-learn, XGBoost, PyTorch, etc.) and deploy them as model services.

**Q: What''s the difference between Cortex LLM functions and ML Functions?**
A: Cortex LLM functions are for **text/language** tasks (completion, sentiment, etc.). ML Functions are for **structured data** tasks (forecasting, anomaly detection, classification).

---

## 6.5 STREAMLIT & NATIVE APPS

Building interactive applications inside Snowflake.

### Key Concepts

**Streamlit in Snowflake (SiS):**

- Build Python-based web apps that run **inside Snowflake**
- No external infrastructure — the app runs on Snowflake compute
- Direct access to Snowflake data via the session — no connectors or credentials
- Supports: charts, tables, forms, file uploads, custom components
- Access controlled by Snowflake RBAC (roles, grants)
- Deployed via Snowsight UI or Snowflake CLI

**Key SiS patterns:**

- `st.connection("snowflake")` — get a Snowflake session
- `session.sql("SELECT ...")` — run queries and display results
- `st.dataframe()` — render DataFrames
- `st.cache_data` — cache query results for performance

**Native App Framework (for distribution):**

- Bundle Streamlit apps + procedures + data into an **Application Package**
- Distribute via Marketplace or direct share
- Consumer installs → gets a full app experience (UI + logic + data)
- Provider can include setup scripts, version management, upgrade paths

**When to use Streamlit vs. Native Apps:**

| Use Case | Tool |
|----------|------|
| Internal dashboard for your team | Streamlit in Snowflake |
| Admin tool for data ops | Streamlit in Snowflake |
| Product you sell to other Snowflake accounts | Native App (with Streamlit inside) |
| Partner integration with code + data | Native App |

### Why This Matters

The analytics team needs a self-service tool for marketing to explore campaign performance. Instead of building a React app with API layers and authentication, they write a 100-line Streamlit app inside Snowflake. It''s live in hours, inherits Snowflake RBAC, and costs nothing extra beyond warehouse compute.

### Best Practices

- Use `st.cache_data` aggressively to avoid redundant queries
- Design Streamlit apps for the warehouse they''ll use — keep queries efficient
- For Native Apps: version everything, use `manifest.yml` for metadata
- Test Native Apps in a dev application package before publishing
- Use Streamlit for prototyping before investing in full frontend apps

**Exam traps:**

- Exam trap: IF YOU SEE "Streamlit in Snowflake requires an external server" → WRONG because SiS runs **entirely within Snowflake** — no external hosting needed
- Exam trap: IF YOU SEE "Streamlit apps bypass Snowflake access control" → WRONG because SiS apps inherit **Snowflake RBAC** — the app runs with the user''s role
- Exam trap: IF YOU SEE "Native Apps are only for data sharing" → WRONG because Native Apps can include **code, UI (Streamlit), procedures, and data** — they''re full applications

### Common Questions (FAQ)

**Q: Can Streamlit apps access external APIs?**
A: Yes, via **external access integrations** that whitelist specific endpoints.

**Q: Who pays for Streamlit app compute?**
A: The account running the app pays — the app uses a Snowflake warehouse for computation.

---

## 6.6 DATA WAREHOUSE LAYERS

Architectural patterns for organizing data within Snowflake.

### Key Concepts

**Medallion Architecture (Bronze / Silver / Gold):**

| Layer | Also Called | Purpose | Data Quality |
|-------|-----------|---------|-------------|
| **Bronze** | Raw, Landing | Ingested data as-is | Low (raw) |
| **Silver** | Cleansed, Curated | Cleaned, deduped, typed | Medium |
| **Gold** | Aggregated, Consumption | Business-ready, aggregated | High |

**Bronze layer:**

- COPY INTO or Snowpipe loads raw data (JSON, CSV, Parquet, etc.)
- No transformations — preserve original data for lineage/audit
- Store as VARIANT for semi-structured, or raw columns for structured
- Append-only — never delete or modify

**Silver layer:**

- Flatten semi-structured data
- Apply data types, null handling, deduplication
- Join reference data
- Apply business rules (e.g., currency conversion, timezone normalization)
- Implemented as: dynamic tables, tasks + streams, dbt models, or procedures

**Gold layer:**

- Business-facing aggregations, KPIs, fact/dimension tables
- Optimized for BI tools (Tableau, Power BI, Sigma)
- Often materialized views or dynamic tables
- Secure views for sharing

**Directory structure in Snowflake:**

```
ANALYTICS_DB
├── RAW (bronze schemas)
│   ├── RAW.SALESFORCE
│   ├── RAW.STRIPE
│   └── RAW.WEB_EVENTS
├── CURATED (silver schemas)
│   ├── CURATED.CUSTOMERS
│   └── CURATED.TRANSACTIONS
└── CONSUMPTION (gold schemas)
    ├── CONSUMPTION.FINANCE_METRICS
    └── CONSUMPTION.MARKETING_DASHBOARD
```

Or use separate databases per layer:
```
RAW_DB → CURATED_DB → ANALYTICS_DB
```

### Why This Matters

A company loads Salesforce, Stripe, and web analytics data into one giant table. Six months later, nobody knows which column means what, transformations are scattered across 50 views, and debugging takes days. The medallion architecture prevents this chaos by enforcing clear boundaries.

### Best Practices

- **One database per major source in bronze** (or one schema per source)
- Silver should be the **single source of truth** — all downstream reads from here
- Gold should be **purpose-built** for specific consumers (BI team, ML team, sharing)
- Use **dynamic tables** for silver/gold layers — automatic incremental refresh
- Document transformations in each layer with comments or a metadata table
- Apply clustering keys at the gold layer (consumption-optimized)

**Exam traps:**

- Exam trap: IF YOU SEE "Bronze layer should clean and transform data" → WRONG because bronze is **raw ingestion only**; cleaning happens in silver
- Exam trap: IF YOU SEE "Gold layer stores all historical data" → WRONG because gold stores **aggregated, consumption-ready** data; full history lives in bronze/silver
- Exam trap: IF YOU SEE "You need exactly three layers" → WRONG because medallion is a **pattern, not a mandate**; some architectures use two layers or add a "platinum" layer
- Exam trap: IF YOU SEE "Each layer must be a separate database" → WRONG because layers can be **schemas within one database** or separate databases — both are valid

### Common Questions (FAQ)

**Q: Should I use separate databases or separate schemas for medallion layers?**
A: Separate databases provide stronger isolation and easier access control. Separate schemas are simpler for smaller projects. Choose based on your governance needs.

**Q: Where do dynamic tables fit in the medallion architecture?**
A: Dynamic tables are ideal for **silver and gold** layers — they automate incremental transformation from their upstream source.

**Q: How does dbt relate to medallion architecture?**
A: dbt models naturally map to medallion layers: `staging` models = silver, `marts` models = gold. dbt orchestrates the transformations between layers.

---

## FLASHCARDS — Domain 6

**Q1: What is the purpose of zero-copy clones in development environments?**
A1: They create **instant copies** of production data for dev/staging with **no additional storage cost** (until data diverges).

**Q2: What authentication method is recommended for CI/CD pipelines?**
A2: **Key-pair authentication** — more secure than passwords, supports rotation, no secrets in plaintext.

**Q3: How does Snowflake''s Git integration work?**
A3: `CREATE GIT REPOSITORY` links a remote repo. You can then reference files directly: `@my_repo/branches/main/path/file.sql`.

**Q4: What is a compute pool in SPCS?**
A4: A **managed cluster of nodes** (CPU or GPU) that runs container services. Can be suspended when idle.

**Q5: Name three Cortex LLM functions.**
A5: `COMPLETE()`, `SUMMARIZE()`, `SENTIMENT()`. Others: `TRANSLATE()`, `EXTRACT_ANSWER()`, `EMBED_TEXT_768()`.

**Q6: Do Cortex LLM functions require a warehouse?**
A6: **No.** They run serverlessly and are billed per token/call.

**Q7: What SQL ML function forecasts time-series data?**
A7: `FORECAST()` — an automated ML function accessible via SQL.

**Q8: Where do Streamlit in Snowflake apps run?**
A8: **Inside Snowflake** — on Snowflake compute, with no external server.

**Q9: What are the three medallion architecture layers?**
A9: **Bronze** (raw), **Silver** (cleansed/curated), **Gold** (aggregated/consumption).

**Q10: What is the blue/green deployment pattern in Snowflake?**
A10: Maintain two databases (blue/green). Deploy to one, test it, then `ALTER DATABASE ... SWAP WITH` for zero-downtime switch.

**Q11: Can SPCS services use GPUs?**
A11: **Yes.** Compute pools can be configured with GPU-enabled node types.

**Q12: What is the Snowflake Model Registry?**
A12: A versioning and deployment system for ML models. Log models, track versions, deploy as inference services.

**Q13: How do Native Apps differ from Streamlit in Snowflake?**
A13: Native Apps are **distributable packages** (code + data + UI) for other accounts. SiS is for **internal apps** within your account.

**Q14: What should the bronze layer contain?**
A14: **Raw data as ingested** — no transformations. Preserves original data for lineage and audit.

**Q15: What is `ALTER DATABASE SWAP WITH` used for?**
A15: **Blue/green deployments** — atomically swaps two databases, enabling zero-downtime releases and instant rollback.

---

## EXPLAIN LIKE I''M 5 — Domain 6

**ELI5 #1: Development Environments**
You''re building a sandcastle. The beach is production — people are enjoying it. You practice in a sandbox first (dev). When your design looks good, you show your parents (staging). Only then do you build it on the beach (production).

**ELI5 #2: Zero-Copy Clones**
You take a photo of the sandcastle instead of rebuilding it. The photo costs almost nothing. If someone draws on the photo, only the drawing costs extra — not the whole castle.

**ELI5 #3: CI/CD**
Imagine a conveyor belt in a toy factory. Someone designs a toy (code), it goes through a quality checker (tests), then gets packaged and shipped (deploy). The belt runs automatically — no one carries toys by hand.

**ELI5 #4: SPCS (Containers)**
You have a special LEGO room inside your house. You can build anything in that room — robots, cars, castles — using any pieces you want. The room is managed by your parents (Snowflake), so you don''t worry about the walls or roof.

**ELI5 #5: Cortex LLM Functions**
You have a really smart friend who lives inside your computer. You can ask them to summarize a story, tell you if an email is happy or sad, or translate something to Spanish. They''re always available and you don''t need any special equipment.

**ELI5 #6: ML Functions (FORECAST)**
You track how tall a plant grows every week: 2cm, 4cm, 6cm. FORECAST looks at the pattern and says "next week it''ll be about 8cm." It learns the pattern from your data.

**ELI5 #7: Streamlit in Snowflake**
You draw a control panel on paper — buttons, sliders, screens. Then magically, it becomes a real control panel that anyone at school can use. No wiring or electronics needed (no server setup).

**ELI5 #8: Medallion Architecture**
You pick apples from a tree (bronze — dirty, some bruised). You wash and sort them (silver — clean, inspected). You make apple pie slices on plates (gold — ready to eat).

**ELI5 #9: Blue/Green Deployment**
You have two identical toy train tracks. You run the old train on Track A. You build the new train on Track B and test it. When it works, you flip a switch and everyone rides Track B. If it breaks, flip back to Track A instantly.

**ELI5 #10: Git Integration**
Your recipe book (Git) is connected to your kitchen (Snowflake). Instead of retyping recipes, your kitchen can read directly from the book. When someone updates the book, the kitchen sees the new recipe next time it looks.
');
