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

**Segmentation Patterns**

- **By environment:** dev / staging / prod accounts
- **By region:** accounts in different cloud regions for data residency
- **By business unit:** finance, marketing, engineering each get their own
- **By compliance:** PCI-scoped account, HIPAA-scoped account

### Why This Matters
A healthcare company needs HIPAA data isolated from marketing analytics. Multi-account with org-level replication lets them share non-PHI data across accounts while keeping PHI locked down.

### Best Practices
- Use Organizations to centrally manage accounts and billing
- Replicate security objects (network policies, RBAC) via account replication
- Keep production accounts on Business Critical or higher edition for compliance

**Exam trap:** IF YOU SEE "use a single account with separate databases for PCI isolation" → WRONG because PCI requires account-level isolation, not just database-level.

**Exam trap:** IF YOU SEE "ACCOUNTADMIN can create new accounts" → WRONG because only ORGADMIN can create accounts within an Organization.

**Exam trap:** IF YOU SEE "Organizations require Enterprise edition" → WRONG because Organizations are available on all editions.

### Common Questions (FAQ)
**Q: Can I share data across accounts without Organizations?**
A: Yes, via Secure Data Sharing (listings), but Organizations add replication, failover, and centralized management.

**Q: Does each account in an org get separate billing?**
A: By default billing is consolidated at the org level, but you can view per-account usage.

---

## 1.2 PARAMETER HIERARCHY

**Three Levels (top to bottom):**

1. **Account** — set by ACCOUNTADMIN, applies globally
2. **Object** — set on warehouse, database, schema, table, user
3. **Session** — set by user for their current session (`ALTER SESSION`)

**Precedence Rule:** Most specific wins. Session > Object > Account.

**Key Parameters to Know:**

| Parameter | Typical Level | Notes |
|---|---|---|
| `STATEMENT_TIMEOUT_IN_SECONDS` | Account / Session | Kills long queries |
| `DATA_RETENTION_TIME_IN_DAYS` | Account / Object | Time Travel window (0-90) |
| `MIN_DATA_RETENTION_TIME_IN_DAYS` | Account only | Floor that objects cannot go below |
| `NETWORK_POLICY` | Account / User | User-level overrides account-level |
| `REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION` | Account | Security hardening |

### Why This Matters
A DBA sets account-level timeout to 1 hour. A data scientist sets session timeout to 4 hours for a big ML job. The session-level wins for that user.

### Best Practices
- Set `MIN_DATA_RETENTION_TIME_IN_DAYS` at account level to prevent users from setting Time Travel to 0
- Use `STATEMENT_TIMEOUT_IN_SECONDS` on warehouses to prevent runaway queries
- Document which parameters are set at which level

**Exam trap:** IF YOU SEE "account parameter always overrides session parameter" → WRONG because session is more specific and wins.

**Exam trap:** IF YOU SEE "MIN_DATA_RETENTION_TIME_IN_DAYS can be set on a schema" → WRONG because it is account-level only.

**Exam trap:** IF YOU SEE "a user-level network policy is additive to account-level" → WRONG because user-level network policy **replaces** the account-level policy for that user.

### Common Questions (FAQ)
**Q: If I set DATA_RETENTION_TIME_IN_DAYS = 1 on a table but the account MIN is 7, which wins?**
A: The MIN wins — the table gets 7 days. MIN sets a floor.

**Q: Can a non-ACCOUNTADMIN set account parameters?**
A: No. Only ACCOUNTADMIN (or roles granted the privilege) can set account-level parameters.

---

## 1.3 ROLE-BASED ACCESS CONTROL

**Core Concepts**

- Snowflake uses **Role-Based Access Control (RBAC)** — privileges are granted to roles, roles are granted to users
- Roles form a hierarchy: child role privileges flow UP to parent roles
- **System-defined roles:** ORGADMIN > ACCOUNTADMIN > SECURITYADMIN > SYSADMIN > USERADMIN > PUBLIC

**Privilege Inheritance**

- If Role A is granted to Role B, then Role B inherits ALL privileges of Role A
- ACCOUNTADMIN should inherit from both SECURITYADMIN and SYSADMIN
- Never use ACCOUNTADMIN for daily work

**Database Roles**

- Scoped to a single database (portable with the database during replication/cloning)
- Granted to account-level roles or other database roles
- Ideal for sharing: consumers get database roles, not account roles

**Functional vs Access Roles Pattern**

- **Access roles:** hold object privileges (e.g., `ANALYST_READ` has SELECT on tables)
- **Functional roles:** represent job functions, inherit from access roles (e.g., `DATA_ANALYST` inherits `ANALYST_READ` + `DASHBOARD_WRITE`)
- This two-layer model simplifies management at scale

**Secondary Roles**

- `USE SECONDARY ROLES ALL` — user gets union of privileges from all granted roles
- Avoids constant role switching
- Default secondary role can be set on user object

### Why This Matters
A 500-person analytics team needs granular access. Functional roles (Data Analyst, Data Engineer) inherit from fine-grained access roles. New hire? Grant one functional role. Done.

### Best Practices
- Never grant privileges directly to users — always use roles
- SYSADMIN should own all databases/warehouses (or custom roles granted to SYSADMIN)
- Use database roles for objects shared via Secure Sharing
- Separate SECURITYADMIN (manages grants) from SYSADMIN (manages objects)

**Exam trap:** IF YOU SEE "ACCOUNTADMIN should be the default role for admins" → WRONG because ACCOUNTADMIN is for break-glass only; daily work should use lower roles.

**Exam trap:** IF YOU SEE "database roles can be granted directly to users" → WRONG because database roles must be granted to account-level roles first (or other database roles).

**Exam trap:** IF YOU SEE "privilege inheritance flows downward" → WRONG because it flows UPWARD in the role hierarchy.

### Common Questions (FAQ)
**Q: What's the difference between SECURITYADMIN and USERADMIN?**
A: USERADMIN manages users and roles. SECURITYADMIN inherits USERADMIN and can also manage grants (GRANT/REVOKE).

**Q: Can I use secondary roles with Secure Sharing?**
A: No. Shares use the share's designated database role; secondary roles don't apply in sharing context.

---

## 1.4 NETWORK SECURITY

**Network Policies**

- IP allow/block lists applied at account or user level
- Use `ALLOWED_IP_LIST` and `BLOCKED_IP_LIST`
- User-level policy **replaces** (not supplements) account-level policy

**Network Rules (newer, more flexible)**

- Can reference IP ranges, VPC endpoints, host names
- Attached to network policies for modular, reusable rules
- Support `INGRESS` (inbound) and `EGRESS` (outbound) directions

**AWS PrivateLink / Azure Private Link / GCP Private Service Connect**

- Private connectivity from your VPC to Snowflake — no public internet
- Requires Business Critical edition or higher
- You get a private endpoint URL (e.g., `account.privatelink.snowflakecomputing.com`)
- Does NOT replace network policies — use both together

**External Access Integrations**

- Allow UDFs/procedures to call external APIs (e.g., REST endpoints)
- Requires creating an External Access Integration + Network Rule (egress)
- Secrets stored in Snowflake secret objects, not in code

### Why This Matters
A bank needs all Snowflake traffic to stay on their private network. PrivateLink + network policies + block public access = zero public internet exposure.

### Best Practices
- Always set an account-level network policy (even if broad) as a safety net
- Use PrivateLink for production workloads in regulated industries
- Test network policies in non-prod before applying to account level
- Use network rules instead of raw IP lists for maintainability

**Exam trap:** IF YOU SEE "PrivateLink is available on Standard edition" → WRONG because it requires Business Critical or higher.

**Exam trap:** IF YOU SEE "network policies support FQDN/hostname blocking" → WRONG for network policies alone; you need network rules for hostname-based controls.

**Exam trap:** IF YOU SEE "PrivateLink eliminates the need for network policies" → WRONG because they serve different purposes and should be used together.

### Common Questions (FAQ)
**Q: If I block all public IPs, can I still use Snowsight?**
A: Only via PrivateLink-enabled Snowsight URL or if you allowlist Snowflake's Snowsight IPs.

**Q: Can I have both account and user network policies?**
A: Yes, but the user-level policy fully replaces (not merges with) the account policy for that user.

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

**Exam trap:** IF YOU SEE "Snowflake OAuth and External OAuth are the same" → WRONG because Snowflake OAuth is issued by Snowflake; External OAuth comes from your IdP.

**Exam trap:** IF YOU SEE "key-pair authentication requires Enterprise edition" → WRONG because it's available on all editions.

**Exam trap:** IF YOU SEE "MFA can be enforced via a network policy" → WRONG because MFA enforcement uses authentication policies, not network policies.

**Exam trap:** IF YOU SEE "SCIM creates roles automatically" → WRONG because SCIM provisions users and groups but does NOT create Snowflake roles automatically.

### Common Questions (FAQ)
**Q: Can I use both SSO and password login?**
A: Yes, unless you set an authentication policy that blocks password auth. By default both work.

**Q: What happens if a user loses their key pair?**
A: Admin can set a new public key on the user object. The second key slot enables rotation without downtime.

---

## 1.6 DATA GOVERNANCE

**Masking Policies (Dynamic Data Masking)**

- Column-level security: returns masked value based on the querying role
- Policy is a SQL function: `CREATE MASKING POLICY ... RETURNS <type> -> CASE WHEN ...`
- Applied to columns via `ALTER TABLE ... ALTER COLUMN ... SET MASKING POLICY`
- One masking policy per column
- Supports conditional masking (based on role, another column, etc.)

**Row Access Policies (RAP)**

- Row-level security: filters rows based on querying context
- Returns `TRUE` (row visible) or `FALSE` (row hidden)
- One RAP per table/view
- Can reference mapping tables for role-to-region filtering

**Aggregation Policies**

- Prevent queries that return results below a minimum group size
- Protects against re-identification in analytics
- Entity-level privacy (e.g., must aggregate at least 5 patients)

**Projection Policies**

- Prevent `SELECT column` directly — column can only be used in WHERE, JOIN, GROUP BY
- Use case: allow filtering on SSN but never displaying it

**Object Tagging**

- Key-value metadata on any object (table, column, warehouse, etc.)
- Tag lineage: tags propagate through views
- Foundation for tag-based masking policies (apply masking to all columns with tag X)
- System tags from classification (e.g., `SNOWFLAKE.CORE.SEMANTIC_CATEGORY = EMAIL`)

**Data Lineage (ACCESS_HISTORY)**

- `SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY` — tracks reads/writes at column level
- Shows which columns were accessed, by whom, and how data flowed
- 365-day retention
- Requires Enterprise edition or higher

### Why This Matters
A retail company tags all PII columns, then applies a single masking policy to every column with the PII tag. When a new PII column is added and tagged, masking is automatic.

### Best Practices
- Use tag-based masking for scalable governance
- Combine RAP + masking for defense-in-depth
- Use aggregation policies for analytics datasets exposed to broad audiences
- Run data classification to auto-detect sensitive data

**Exam trap:** IF YOU SEE "you can apply two masking policies to the same column" → WRONG because only one masking policy per column is allowed.

**Exam trap:** IF YOU SEE "row access policies are applied to columns" → WRONG because RAP is applied to tables/views, not individual columns.

**Exam trap:** IF YOU SEE "object tags require Business Critical edition" → WRONG because tagging is available on Enterprise and above.

**Exam trap:** IF YOU SEE "aggregation policies filter rows" → WRONG because they block queries that produce groups below the minimum size, not filter individual rows.

### Common Questions (FAQ)
**Q: Can masking policies reference other tables?**
A: Yes. You can query a mapping table inside the masking policy body (subquery).

**Q: Do row access policies work on materialized views?**
A: No. RAP is not supported on materialized views.

**Q: What's the difference between projection policy and masking policy?**
A: Masking replaces the value (e.g., `***`). Projection prevents the column from appearing in results entirely but allows its use in predicates.

---

## 1.7 COMPLIANCE

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

**Exam trap:** IF YOU SEE "Tri-Secret Secure is available on Enterprise edition" → WRONG because it requires Business Critical.

**Exam trap:** IF YOU SEE "SOC 2 compliance requires Business Critical" → WRONG because SOC 2 reports are available for all editions.

**Exam trap:** IF YOU SEE "Tri-Secret Secure means Snowflake cannot access your data at all" → WRONG because Snowflake still manages the middle key; the customer controls the outer key.

### Common Questions (FAQ)
**Q: What's the difference between Business Critical and VPS?**
A: Business Critical adds encryption, compliance, PrivateLink. VPS adds a dedicated, isolated Snowflake deployment (separate metadata store, compute).

**Q: Does enabling Tri-Secret Secure affect performance?**
A: Negligible. The key wrapping adds minimal overhead.

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
| **SCIM** provisions... | **Users and groups** automatically from IdP | NOT roles — SCIM does NOT create Snowflake roles |
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
Putting colored stickers on your toys: red for "fragile," blue for "share with friends." Later you can say "hide ALL red-sticker toys" without listing each one.
