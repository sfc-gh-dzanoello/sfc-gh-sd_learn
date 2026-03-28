# DOMAIN 2: ACCOUNT MANAGEMENT & DATA GOVERNANCE
## 20% of exam = ~20 questions

---

## 2.1 ACCESS CONTROL MODEL

Snowflake uses TWO models together:

### RBAC (Role-Based Access Control):
- Privileges → granted to ROLES → roles granted to USERS
- This is the primary model
- "Who can do what" is determined by ROLE, not by user

### DAC (Discretionary Access Control):
- The OWNER of an object can grant access to it
- Every object has exactly ONE owner role
- Owner = the role that created the object (by default)
- Owner can transfer ownership: GRANT OWNERSHIP

**Exam trap**: "DAC means..." → The OWNER of an object decides who gets access. IF YOU SEE "roles determine access" with DAC → WRONG! That's RBAC. DAC = ownership-based control.
**Exam trap**: "RBAC means..." → Privileges are assigned to ROLES, roles to users. IF YOU SEE "owner grants access" with RBAC → WRONG! That's DAC. RBAC = role-based, not owner-based.

### How they work together:
- RBAC determines what a role CAN do
- DAC determines who OWNS the object and can grant/revoke

### Example Scenario Questions — Access Control Model

**Scenario:** A data engineer on the ANALYTICS_TEAM role created a staging table. Now the FINANCE_TEAM role needs SELECT access to that table. The finance lead asks: "Who needs to grant us access?"
**Answer:** Under Snowflake's DAC model, the **owner** of the object controls who gets access. The ANALYTICS_TEAM role owns the table (because it created it), so someone using that role (or a higher role in the hierarchy like SECURITYADMIN with MANAGE GRANTS) must run `GRANT SELECT ON TABLE ... TO ROLE FINANCE_TEAM`. The finance team cannot grant themselves access — only the owner or a role with MANAGE GRANTS can. This is DAC in action: the owner decides.

**Scenario:** A security auditor asks: "Does Snowflake use RBAC or DAC?" A junior DBA responds: "It uses DAC because the object owner controls access." Is the DBA correct?
**Answer:** Partially correct but incomplete. Snowflake uses **both RBAC and DAC together**. RBAC is the primary model — privileges are granted to roles, and roles are granted to users. DAC complements it because every object has an owner role, and that owner can grant/revoke access. Saying "only DAC" ignores that all access flows through roles (RBAC). The correct answer on the exam is always "both models working together."

**Scenario:** A company wants to transfer ownership of a production database from the DEV_ADMIN role to the PROD_ADMIN role. What command is needed, and what happens to existing grants?
**Answer:** Use `GRANT OWNERSHIP ON DATABASE prod_db TO ROLE PROD_ADMIN`. After transfer, PROD_ADMIN becomes the new owner and controls access (DAC). By default, existing grants are preserved with the `COPY CURRENT GRANTS` option. Without it, existing grants may be revoked. This is a key DAC concept: ownership transfer changes who controls the object's access grants.

### Managed Access Schemas

In a **regular schema**, any role that OWNS an object inside the schema can grant access to that object to other roles. This is standard DAC behavior -- the object owner decides who gets access.

In a **managed access schema** (`CREATE SCHEMA ... WITH MANAGED ACCESS`), object owners LOSE the ability to grant access. Only the **schema owner** (the role with OWNERSHIP on the schema) or a role with **MANAGE GRANTS** can control who accesses objects inside the schema.

**Why this matters:**
- Normal schema = decentralized access control (each object owner gives out their own keys)
- Managed access = centralized access control (only the building manager gives out keys)
- Prevents "permission drift" where individual data engineers grant ad-hoc access without oversight

**Syntax:**
```sql
-- Create a managed access schema
CREATE SCHEMA finance.secure WITH MANAGED ACCESS;

-- Convert existing schema to managed access
ALTER SCHEMA my_schema ENABLE MANAGED ACCESS;

-- Revert to regular schema
ALTER SCHEMA my_schema DISABLE MANAGED ACCESS;
```

### ELI5: The Apartment Building (Managed Access Schemas)

In a **normal schema**, each apartment resident (object owner) can give copies of their key to anyone they want. The building manager has no idea who has keys to what.

In a **managed access schema**, only the building manager (schema owner or MANAGE GRANTS role) can give out keys. A resident can build furniture inside their apartment (they still OWN the object), but they CANNOT hand their key to a stranger. If someone needs access, they must go through the building manager.

**Exam trigger:** "centralize access control" / "prevent owners from granting access" / "production environment governance" → Managed Access Schema.

**Exam trap**: "Object owners can grant access in managed access schemas?" → WRONG! In managed access, only the schema owner or MANAGE GRANTS role can grant access. Object owners retain OWNERSHIP but cannot manage grants.
**Exam trap**: "Managed access requires Enterprise edition?" → NO! Available on ALL editions.

---

### ELI5 -- Where do objects live?

In Snowflake, "object" does NOT just mean tables and views. EVERYTHING you can create, alter, or grant permissions on is an object. They live on different "floors":

**Account-level objects (the lobby)** -- these live OUTSIDE databases, directly in the account:
- USER -- people who log in
- ROLE -- permission badges
- WAREHOUSE -- compute engines
- DATABASE -- containers for data objects
- NETWORK POLICY -- IP access rules
- RESOURCE MONITOR -- credit spending limits

**Database/Schema-level objects (inside the rooms)** -- these only exist INSIDE a database + schema:
- SCHEMA -- folders inside the database
- TABLE, VIEW, STAGE, PIPE, STREAM, TASK, SEQUENCE, UDF, PROCEDURE

Why this matters: because USER is an account-level object, you can attach settings directly to it (like NETWORK_POLICY). That's why ALTER USER debora SET NETWORK_POLICY = 'strict' works -- the user object lives at account level, and the policy is attached to it. This is NOT the same as a session setting.

Don't confuse "object" with "table." On the exam, when they say "object-level parameter," they could mean warehouse, database, schema, OR table -- not just table. And when they say "user-level," they mean the USER object at account level.

---

## 2.2 SYSTEM-DEFINED ROLES (VERY HEAVILY TESTED)

### Role Hierarchy (top to bottom):

```
    ACCOUNTADMIN
    ├── SECURITYADMIN
    │   └── USERADMIN
    └── SYSADMIN
         └── (custom roles should be here)
              └── PUBLIC (everyone)
```

### Each role's job:

**ACCOUNTADMIN** (top-level, most powerful):
- Encapsulates SYSADMIN + SECURITYADMIN
- Only role that can: view billing, manage resource monitors, view ACCOUNT_USAGE
- Can create Shares for data sharing
- Should be assigned to LIMITED users (2-3 people max)
- Best practice: use MFA, do NOT use as default role
- This is a **break-glass role** ("break the glass in case of emergency") -- keep it locked away for emergencies only
- Follows the **Principle of Least Privilege (PoLP)**: users should only have the exact level of power needed for their task, nothing more

### ELI5: The Tank at the Bakery (Why NEVER Use ACCOUNTADMIN Daily)

ACCOUNTADMIN is "God Mode" in Snowflake. It can see all credit card data, change everyone's passwords, alter the network, and -- worst of all -- delete the entire account.

Using ACCOUNTADMIN for daily work (like running a SELECT or creating a small table) is like driving a missile-launching tank to buy bread at the bakery. Will you get the bread? Yes. But if you sneeze and bump a button, you blow up the entire block.

**The "Oops" protection:** Imagine it's a tired Friday and you accidentally type `DROP DATABASE production_db;`
- If you're on your normal role (e.g., DATA_ENGINEER): Snowflake slaps your hand -- "Error: You don't have permission." Your job is saved.
- If you're on ACCOUNTADMIN: Snowflake says "Your wish is my command" and DELETES everything in 1 second. No second question.

**When is the ONLY time to use ACCOUNTADMIN?** Billing, resource monitors, account-level integrations, or true emergencies. For everything else: SYSADMIN (build things), SECURITYADMIN (manage access), or custom roles.

**SECURITYADMIN**:
- Manage grants (MANAGE GRANTS privilege)
- Manage network policies
- Can grant/revoke privileges on ANY object
- Best for: managing who can access what

**USERADMIN**:
- Create and manage users and roles
- CREATE USER, CREATE ROLE privileges
- Does NOT automatically get access to data
- Reports to SECURITYADMIN

**SYSADMIN**:
- Create and manage databases, schemas, warehouses
- Should own all custom roles (best practice: grant custom roles TO SYSADMIN)
- The "builder" role

**PUBLIC**:
- Auto-granted to every user
- Lowest level
- Any privilege granted to PUBLIC is available to everyone

**ORGADMIN**:
- Organization-level management
- Create and manage accounts within the organization
- View org-level usage
- NOT in the regular role hierarchy diagram

### Key rules:
- Higher roles INHERIT privileges of lower roles in the hierarchy
- ACCOUNTADMIN inherits everything from SYSADMIN + SECURITYADMIN
- But: owning a role does NOT mean you inherit its privileges (only hierarchy does)
- Custom roles should be granted to SYSADMIN (best practice)

### ELI5: The Divided Company (The Y-Shape)

Your Snowflake account is a company. Forget the bullet points -- picture a **Y**.

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
Because the Master Builder (SYSADMIN) has ZERO power over HR (USERADMIN). They're on separate branches of the Y. One handles bricks and cement (Data), the other handles badges (People). They're siblings who only share one boss: the CEO (ACCOUNTADMIN).

**Anchor words to remember the Y:**
- Left side: Security & HR (SECURITY > USER)
- Right side: Construction (SYSADMIN)
- The two sides do NOT mix!

### Why This Matters + Use Cases

**Real scenario — "An intern accidentally dropped a production database"**
The intern had ACCOUNTADMIN. Solution: NEVER give ACCOUNTADMIN for daily work. Create custom roles with minimum needed privileges. Grant those to SYSADMIN hierarchy.

**Real scenario — "We need to hide salary data from analysts"**
Analysts need to query the employees table but shouldn't see the salary column. Solution: Dynamic Data Masking policy (Enterprise+). Analysts see '****', managers see real values. ONE policy per column.

**Real scenario — "ACCOUNT_USAGE shows no data for today"**
ACCOUNT_USAGE has 45min-3h latency (varies by view). If you need real-time usage info, use INFORMATION_SCHEMA (real-time, but 7 days to 6 months of history depending on the view).

---

### Best Practices — Roles
- NEVER use ACCOUNTADMIN for daily work — create custom roles
- Grant ACCOUNTADMIN to minimum people (2-3 max for emergencies)
- Always use role hierarchy: custom roles granted to SYSADMIN
- Use SECURITYADMIN to manage grants, USERADMIN to create users
- Enable MFA for ALL users with ACCOUNTADMIN

**Exam trap**: "Which role monitors billing?" → ACCOUNTADMIN. IF YOU SEE "billing" with SYSADMIN → WRONG! SYSADMIN builds objects. Only ACCOUNTADMIN sees billing/costs.
**Exam trap**: "Which role manages network policies?" → SECURITYADMIN. IF YOU SEE "network policies" with ACCOUNTADMIN → trap! SECURITYADMIN is the designated security role.
**Exam trap**: "Which role creates users?" → USERADMIN. IF YOU SEE "creates users" with SECURITYADMIN → WRONG! SECURITYADMIN manages GRANTS. USERADMIN creates users.
**Exam trap**: "Which role creates databases/warehouses?" → SYSADMIN. IF YOU SEE "creates databases" with ACCOUNTADMIN → trap! SYSADMIN is the builder. ACCOUNTADMIN is overkill.
**Exam trap**: "Which role creates accounts in an org?" → ORGADMIN. IF YOU SEE "creates accounts" with ACCOUNTADMIN → WRONG! ACCOUNTADMIN is per-account. ORGADMIN is org-level.
**Exam trap**: "Which role creates Shares?" → ACCOUNTADMIN. IF YOU SEE "creates Shares" with SYSADMIN → WRONG! Only ACCOUNTADMIN can create Shares for data sharing.

### Example Scenario Questions — System-Defined Roles

**Scenario:** A new data team lead needs to create a warehouse for their analytics workload. They ask the admin to give them ACCOUNTADMIN. Is this appropriate?
**Answer:** No. ACCOUNTADMIN is the most powerful role and should be reserved for limited use. The correct approach is to use SYSADMIN to create the warehouse (SYSADMIN is the "builder" role for databases, schemas, and warehouses). Either grant SYSADMIN to the lead, or create a custom role with CREATE WAREHOUSE privilege and grant it to SYSADMIN in the hierarchy.

**Scenario:** An organization wants to set up SSO for all employees. Which system role should configure the network policies and security settings?
**Answer:** SECURITYADMIN. This role has the MANAGE GRANTS privilege and is the designated role for security-related configuration including network policies, grants, and access control. While ACCOUNTADMIN can also do this (it inherits SECURITYADMIN privileges), best practice is to use the most specific role for the task.

**Scenario:** A company has 15 custom roles but none of them can access databases created by SYSADMIN. What's likely wrong with their role hierarchy?
**Answer:** The custom roles are not granted to SYSADMIN. Best practice: all custom roles should be granted to SYSADMIN (`GRANT ROLE custom_role TO ROLE SYSADMIN`). This ensures the hierarchy flows properly — SYSADMIN inherits custom role privileges, and ACCOUNTADMIN inherits everything. Without this, custom roles are isolated from the hierarchy.

---

## 2.3 ROLE TYPES

### Account Roles:
- Regular roles scoped to the entire account
- Can access any object in the account (if granted)

### Database Roles:
- Scoped to a single database
- Cannot be activated directly in a session
- Must be granted to an account role
- Useful for managing access within one database

**Exam trap**: "Can a database role be activated directly in a session?" → NO. IF YOU SEE "activate directly" with database role → WRONG! Must be granted to an ACCOUNT role first.
**Exam trap**: "Database role vs account role scope?" → Database role = one database only. IF YOU SEE "entire account" with database role → WRONG! Account role = entire account. Database role = single database.

### Secondary Roles:
- A user can activate MULTIPLE roles in one session
- Primary role = the role set with `USE ROLE` (owns created objects)
- Secondary roles = additional roles that add permissions for the session
- Three syntax options:
  - `USE SECONDARY ROLES ALL` → activates ALL granted roles as secondary
  - `USE SECONDARY ROLES NONE` → disables all secondary roles (only primary active)
  - `USE SECONDARY ROLES role1, role2` → activates SPECIFIC roles as secondary
- Combines permissions from all active roles (primary + secondary)
- **Critical rule: CREATE (DDL) is restricted to the PRIMARY role ONLY**
  - Secondary roles can do: SELECT, INSERT, UPDATE, DELETE, TRUNCATE (DML)
  - Secondary roles CANNOT do: CREATE TABLE, CREATE VIEW, CREATE SCHEMA, etc.
  - Reason: created objects need exactly one OWNER, and that is the primary role
- `DEFAULT_SECONDARY_ROLES` user property controls session startup behavior:
  - `ALTER USER ... SET DEFAULT_SECONDARY_ROLES = ('ALL')` → auto-enable all on login
  - `ALTER USER ... SET DEFAULT_SECONDARY_ROLES = ()` → none on login
  - Since BCR-1692 (2024), new accounts may default to ALL instead of NONE
  - IMPORTANT: DEFAULT_SECONDARY_ROLES only accepts ('ALL') or () -- you CANNOT specify individual role names at the user level
- Session-level vs User-level (key exam distinction):
  - `USE SECONDARY ROLES ...` = SESSION level, temporary, dies when you log off
  - `ALTER USER SET DEFAULT_SECONDARY_ROLES` = USER object property, permanent, auto-applies on every login
  - Session policies (`ALLOWED_SECONDARY_ROLES`) can further restrict which secondary roles are allowed

### ELI5: The T-Shirt and the Backpack (Primary vs Secondary Roles)

Think of your primary role as the T-shirt you're wearing -- it's the one everyone sees and it has YOUR NAME on it. When you build something (CREATE), your T-shirt name goes on it as the owner.

Your secondary roles are tools in your backpack. You can reach into the backpack to READ things (SELECT), MODIFY things (INSERT, UPDATE, DELETE) -- but when you BUILD something new (CREATE TABLE), only the name on your T-shirt goes on it.

You have three choices for your backpack:
- Pack EVERYTHING you own (`USE SECONDARY ROLES ALL`)
- Pack NOTHING (`USE SECONDARY ROLES NONE`)
- Pick specific tools (`USE SECONDARY ROLES role_a, role_b`)

**Exam trap**: "CREATE operations use permissions from secondary roles?" → WRONG! CREATE (DDL) is authorized ONLY by the primary role. Secondary roles only add DML permissions.
**Exam trap**: "USE SECONDARY ROLES only accepts ALL or NONE?" → WRONG! You CAN specify individual role names: `USE SECONDARY ROLES role1, role2;`
**Exam trap**: "Who owns objects created with secondary roles active?" → The PRIMARY role. IF YOU SEE "secondary role owns" → WRONG! Secondary roles add permissions but PRIMARY role owns created objects.
**Exam trap**: "USE SECONDARY ROLES is a permanent change?" → WRONG! USE = session level, temporary. ALTER USER SET DEFAULT_SECONDARY_ROLES = permanent. If the question says "persists after logoff" with USE → WRONG!
**Exam trap**: "DEFAULT_SECONDARY_ROLES = ('role1', 'role2')?" → WRONG! The user property only accepts ('ALL') or () empty. Individual role names only work with the session-level USE SECONDARY ROLES command.

### Example Scenario Questions — Role Types

**Scenario:** A DBA creates a database role called ANALYTICS_DB.READER to manage read access within the ANALYTICS_DB database. An analyst tries to run `USE ROLE ANALYTICS_DB.READER` in their session. What happens?
**Answer:** It fails. Database roles cannot be activated directly in a session. The database role must first be granted to an account role (e.g., `GRANT DATABASE ROLE ANALYTICS_DB.READER TO ROLE ANALYST_ROLE`), and the analyst activates the account role instead. Database roles are always accessed indirectly through account roles.

**Scenario:** A data engineer needs SELECT on tables from both the MARKETING and FINANCE databases in a single query. They have separate roles for each. How can they access both without switching roles?
**Answer:** Use secondary roles: `USE SECONDARY ROLES ALL`. This activates all granted roles simultaneously, combining their permissions. The engineer can now query both databases in one session. Note: any new objects created will be owned by the PRIMARY role (the active role), not the secondary roles.

---

## 2.4 AUTHENTICATION METHODS

### Multi-Factor Authentication (MFA):
- Powered by Duo Security
- Users self-enroll via Snowflake web interface
- Available ALL editions
- Can be enforced at account level (AUTHENTICATION POLICY)

### Federated Authentication / SSO:
- Integrate with external identity providers (IdP)
- SAML 2.0 based
- Available ALL editions

### OAuth:
- Authorize access without sharing login credentials
- External OAuth (custom IdP) or Snowflake OAuth
- Available ALL editions

### Key Pair Authentication:
- Uses RSA key pair (public + private key)
- No password needed
- Common for: programmatic access, SnowSQL, connectors, service accounts
- Private key stays with user, public key registered in Snowflake

**Exam trap**: "Key pair is used for..." → Programmatic/CLI access without passwords. IF YOU SEE "web UI login" with key pair → WRONG! Key pair = service accounts/scripts. Web UI uses password/SSO.
**Exam trap**: "MFA is powered by..." → Duo Security. IF YOU SEE "Google Authenticator" or "Okta" with MFA → WRONG! Snowflake MFA = Duo Security only. Okta = SSO/federated auth.
**Exam trap**: "MFA enrollment is..." → Self-service by users. IF YOU SEE "admin enrolls users" → WRONG! Users self-enroll. Admins can ENFORCE MFA via policy, but enrollment is self-service.

### Example Scenario Questions — Authentication Methods

**Scenario:** A company has a nightly ETL pipeline running via a Python script. The script currently uses a username/password to connect to Snowflake. The security team says passwords in scripts are a risk. What's the recommended alternative?
**Answer:** Use Key Pair Authentication. Generate an RSA key pair, register the public key with the Snowflake user (`ALTER USER etl_user SET RSA_PUBLIC_KEY = '...'`), and configure the Python connector to use the private key. No password stored in scripts. Key pair auth is the standard for programmatic/service account access.

**Scenario:** A company uses Okta as their identity provider and wants employees to log into Snowflake using their Okta credentials. Which authentication method should they configure?
**Answer:** Federated Authentication / SSO using SAML 2.0. Configure Okta as the external IdP for Snowflake. This is available on ALL editions. Do NOT confuse with MFA — MFA uses Duo Security for second-factor verification, while SSO/federated auth delegates the entire login to an external IdP like Okta.

---

## 2.5 NETWORK POLICIES

- Control access by IP address
- Allowed IPs (whitelist) and Blocked IPs (blacklist)
- Can apply at: account level, security integration level, OR user level
- User-level policy overrides account-level
- Security integration policy overrides BOTH account and user
- Available ALL editions
- Managed by SECURITYADMIN (or role with MANAGE GRANTS)

### Network Policy Precedence (most specific wins):

| Level | Overrides | Set by |
|---|---|---|
| Security Integration | Account + User | ALTER SECURITY INTEGRATION ... SET NETWORK_POLICY |
| User | Account | ALTER USER ... SET NETWORK_POLICY |
| Account | Nothing (default) | ALTER ACCOUNT SET NETWORK_POLICY |

### ELI5 -- The VIP List at the Club (Network Policy Replaces, Never Adds)

Imagine a nightclub with a guest list.

**Account-level policy (the general list):** The manager tells the bouncer: "Only people from Sao Paulo (IP 1.1.1.1) can enter." This rule applies to everyone by default.

**User-level policy (the VIP list):** Neymar rented the VIP section. He hands his OWN list to the bouncer: "In my section, only people from Santos (IP 2.2.2.2) can enter."

What does the bouncer do? He THROWS AWAY the general list for Neymar. He does NOT combine the two lists. If Neymar's friend from Sao Paulo (IP 1.1.1.1) tries to enter Neymar's section, they get BLOCKED -- because the general list no longer applies to Neymar.

Don't confuse "user-level overrides account-level" with "user-level adds to account-level." Override means REPLACE. If account allows IPs A and B, and user allows IP C, the user can ONLY connect from IP C. Not A, not B, not A+B+C. ONLY C.

Remember: The user-level policy must include ALL IPs the user needs -- including the office IP if they still need office access. Nothing is inherited from the account policy.

**Exam trap**: "Restrict access from corporate IP only?" → Network Policy. IF YOU SEE "firewall" or "VPN required" → trap! Snowflake uses NETWORK POLICIES (IP allow/block lists), not firewalls or VPNs.
**Exam trap**: "Account allows IPs A and B, user allows IP C. Where can the user connect from?" → ONLY C. IF YOU SEE "A, B, and C" or "A + B + C" → WRONG because user-level REPLACES account-level, it does NOT add to it.
**Exam trap**: "Network policy levels?" → Account, Security Integration, and User. IF YOU SEE "schema" or "database" or "role" + "network policy" → WRONG because network policies only apply at account, security integration, and user levels.

### Example Scenario Questions — Network Policies

**Scenario:** A company wants all employees to access Snowflake only from the office (IP range 10.0.0.0/16), but the DBA needs access from home too (IP 203.0.113.50). How should they configure this?
**Answer:** Create an account-level network policy with ALLOWED_IP_LIST = '10.0.0.0/16' for the office. Then create a separate user-level network policy for the DBA that includes both the office range and the home IP. User-level policy overrides account-level, so the DBA gets access from both locations while everyone else is restricted to the office.

### Network Rules vs Network Policies (Key Distinction)

Network Policies ALONE can only handle IP addresses (ALLOWED_IP_LIST / BLOCKED_IP_LIST). But what if you need to control access by hostname, FQDN, or private endpoint ID? That's where **Network Rules** come in.

**Network Rules** are schema-level objects that group network identifiers into logical units. They support multiple identifier types:
- **IPV4** -- IP addresses and CIDR ranges (e.g., `192.168.1.0/24`)
- **AWSVPCEID** -- AWS VPC endpoint IDs (for PrivateLink on AWS)
- **AZURELINKID** -- Azure private endpoint Link IDs (for PrivateLink on Azure)
- **HOST_PORT** -- hostnames/FQDNs for egress rules (outbound access from UDFs/procedures)

**Network Policies** reference Network Rules instead of containing raw IP lists directly. The flow:
1. Create Network Rule(s) → define WHO/WHAT (IPs, endpoint IDs, hostnames)
2. Create Network Policy → reference rules via `ALLOWED_NETWORK_RULE_LIST` / `BLOCKED_NETWORK_RULE_LIST`
3. Activate policy → attach to account, user, or security integration

**Key differences:**
- Network Rules = **schema-level** objects (live inside database.schema)
- Network Policies = **account-level** objects
- Network Rules support INGRESS (inbound) and EGRESS (outbound) modes
- One network rule can be referenced by MULTIPLE policies (reusable)

**Important precedence rules:**
- Private connectivity rules (AWSVPCEID / AZURELINKID) take **precedence** over IPV4 rules
- If a request comes via PrivateLink and matches an allowed private endpoint rule, ALL IPV4 rules are ignored for that request
- Blocked list takes precedence if the same identifier appears in both allowed and blocked lists

```sql
-- Example: Allow only PrivateLink, block all public internet
CREATE NETWORK RULE allow_private
  MODE = INGRESS TYPE = AWSVPCEID
  VALUE_LIST = ('vpce-0fa383eb170331202');

CREATE NETWORK RULE block_public
  MODE = INGRESS TYPE = IPV4
  VALUE_LIST = ('0.0.0.0/0');

CREATE NETWORK POLICY private_only
  ALLOWED_NETWORK_RULE_LIST = ('allow_private')
  BLOCKED_NETWORK_RULE_LIST = ('block_public');
```

### ELI5: The Bouncer's Upgrade (Network Rules vs Network Policies)

Remember the bouncer at the nightclub (Network Policy)? He used to only check your ID card (IP address). That was his ONE trick.

But the club got fancier. Now they need to check:
- Your IP (old-style ID card)
- Your VIP wristband (AWS PrivateLink endpoint ID)
- Your company badge (Azure Link ID)
- Your invitation letter (hostname/FQDN for outbound access)

The bouncer can't handle all these documents himself. So the club hired **specialists** (Network Rules). Each specialist checks ONE type of document. The bouncer (Network Policy) just asks the specialists: "Is this person on the allowed list or the blocked list?"

**The old way**: the bouncer had a paper list of IP addresses taped to his clipboard.
**The new way**: the bouncer references specialist teams (Network Rules) who each manage their own lists.

**Exam trap**: "Network Policy alone can control access by hostname/FQDN?" → WRONG! Network Policies alone only handle IPs. You need **Network Rules** (type HOST_PORT) for FQDN-based control. Then the rule is referenced by the policy.
**Exam trap**: "Network Rules are account-level objects?" → WRONG! Network Rules are **schema-level** objects (inside database.schema). Network **Policies** are account-level.
**Exam trap**: "You must explicitly block all public IPs when using PrivateLink?" → YES, if you want to block public access. Just allowing a PrivateLink rule does NOT automatically block public IPs. You need a separate IPV4 rule in the blocked list with `0.0.0.0/0`.

---

### PrivateLink vs Network Policies (Defense in Depth)

These are TWO DIFFERENT things that solve TWO DIFFERENT problems:

| | PrivateLink | Network Policy |
|---|---|---|
| **What it does** | Creates a **private tunnel** between your cloud network and Snowflake | Controls **who can enter** via IP/endpoint filtering |
| **Problem it solves** | **Connectivity** -- data never crosses the public internet | **Access control** -- only approved sources can connect |
| **Analogy** | Building a private underground tunnel to the bank | Putting a bouncer at the bank's door |
| **Edition** | Business Critical+ | ALL editions |
| **Without the other** | Traffic is private but ANYONE on your internal network can access Snowflake | Traffic goes over public internet but only approved IPs can connect |

**Defense in depth = use BOTH together:**
- PrivateLink ensures traffic stays off the public internet (private tunnel)
- Network Policy ensures only authorized endpoints/IPs can connect (access control)
- PrivateLink ALONE does NOT prevent unauthorized access from within your private network

**Exam triggers:**
- "no public internet" + "private connection" → PrivateLink (Business Critical+)
- "restrict who can connect" + "IP filtering" → Network Policy (all editions)
- "maximum security" + "both private connectivity AND access control" → PrivateLink + Network Policy together
- "banking" / "healthcare" / "HIPAA" / "no public internet" → Business Critical+ (PrivateLink available)

**Exam trap**: "PrivateLink replaces Network Policies?" → WRONG! They serve different purposes. PrivateLink = tunnel (connectivity). Network Policy = bouncer (access control). You need BOTH for maximum security.
**Exam trap**: "PrivateLink is available on Enterprise edition?" → WRONG! PrivateLink requires **Business Critical+**.

---

## 2.6 ENCRYPTION & KEY MANAGEMENT

### Default encryption:
- ALL data encrypted at rest and in transit
- AES-256 encryption
- Automatic, no setup needed
- Available ALL editions

### Key rotation:
- Snowflake automatically rotates keys every 30 days
- Periodic rekeying = Enterprise+ (re-encrypts data with new key)

### Tri-Secret Secure (Business Critical+):
- Customer-managed key + Snowflake-managed key = composite key
- Customer controls one of the encryption keys
- If customer revokes their key → data becomes inaccessible
- Maximum customer control over encryption

**Exam trap**: "Customer-managed keys?" → Tri-Secret Secure (BC+). IF YOU SEE "customer-managed key" with Enterprise edition → WRONG! Tri-Secret Secure requires BUSINESS CRITICAL+, not Enterprise.
**Exam trap**: "Keys rotated every?" → 30 days (automatic). IF YOU SEE "90 days" or "annual" → WRONG! Snowflake rotates keys every 30 DAYS automatically, all editions.
**Exam trap**: "Periodic rekeying edition?" → Enterprise+. IF YOU SEE "periodic rekeying" with "all editions" → WRONG! Rekeying (re-encrypts OLD data) = Enterprise+. Key ROTATION (new key for new data) = all editions.

### Example Scenario Questions — Encryption & Key Management

**Scenario:** A healthcare company on Business Critical edition needs maximum control over their encryption keys. If there's a security breach, they want the ability to instantly make all Snowflake data inaccessible. What feature should they use?
**Answer:** Tri-Secret Secure (Business Critical+). This creates a composite encryption key from a customer-managed key (in their cloud KMS) + Snowflake's key. If the customer revokes their key, all data becomes instantly inaccessible. This gives maximum customer control over encryption — the "kill switch" for data access.

**Scenario:** An auditor asks: "How often are encryption keys rotated in Snowflake?" and "Is old data re-encrypted with new keys?" What are the correct answers?
**Answer:** Keys are automatically rotated every 30 days on ALL editions — this means new data gets encrypted with the new key. However, periodic rekeying (re-encrypting OLD data with the new key) requires Enterprise+ edition. Key rotation (all editions) ≠ periodic rekeying (Enterprise+). This distinction is a common exam trap.

---

## 2.7 DATA GOVERNANCE FEATURES

### Dynamic Data Masking (Column-Level Security, Enterprise+):
- Apply masking policies to columns
- Different roles see different data (e.g., HR sees SSN, others see ****)
- Policy is a SQL function that returns masked or unmasked value
- Attached to columns in tables or views

**Exam trap**: "SSN visible only to HR_MANAGER?" → Dynamic Data Masking. IF YOU SEE "filter rows" or "hide rows" for column visibility → WRONG! That's Row Access Policy. Masking = COLUMN values, not rows.

### Row Access Policies (Row-Level Security, Enterprise+):
- Control which ROWS a role can see
- Policy returns TRUE (show row) or FALSE (hide row)
- Applied to tables or views
- Example: region-based access (US team sees only US rows)

### Projection Policies (Enterprise+):
- Control which columns can be projected (SELECTed)
- Prevents specific roles from running SELECT on certain columns

### Aggregation Policies (Enterprise+):
- Force queries to aggregate data (no individual rows)
- Privacy protection

### Object Tagging:
- Apply tags to any Snowflake object
- Key-value pairs
- Track sensitive data, categorize objects
- Tags propagate through lineage
- Available ALL editions (some features Enterprise+)

### Tag-Based Masking (Enterprise+):

Tag-based masking combines **object tagging** + **masking policies** to automatically protect columns at scale.

**The problem it solves:** In a large enterprise with hundreds of tables, manually attaching a masking policy to every sensitive column is slow, error-prone, and impossible to maintain as new columns are added.

**How it works (3 steps):**
1. **Create a Tag** (e.g., `PII_TYPE`)
2. **Attach masking policy TO the tag** (`ALTER TAG PII_TYPE SET MASKING POLICY mask_pii`)
3. **Apply the tag to columns** (`ALTER TABLE ... MODIFY COLUMN ssn SET TAG PII_TYPE = 'SSN'`)

Now, ANY column with that tag automatically gets the masking policy applied. When a new column is tagged, it's instantly protected -- no manual policy assignment needed.

**Scaling magic:** You can set a tag at the **table level**, and ALL columns in that table inherit the tag + its masking policy (where data types match). Set it at the **schema level**, and all new tables/columns are protected automatically.

```sql
-- Step 1: Create a tag
CREATE TAG governance.tags.pii_type;

-- Step 2: Create masking policy and attach to tag
CREATE MASKING POLICY mask_pii AS (val STRING) RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() IN ('HR_ADMIN') THEN val
    ELSE '***MASKED***'
  END;

ALTER TAG governance.tags.pii_type SET MASKING POLICY mask_pii;

-- Step 3: Tag columns -- they're instantly masked
ALTER TABLE employees MODIFY COLUMN ssn SET TAG governance.tags.pii_type = 'SSN';
ALTER TABLE employees MODIFY COLUMN email SET TAG governance.tags.pii_type = 'EMAIL';
-- Both columns are now masked for non-HR roles, automatically
```

### ELI5: The Magic Sticker (Tag-Based Masking)

Imagine you have a magic sticker that says "HIDE THIS." Any paper you put this sticker on becomes invisible to strangers, but visible to the boss.

Instead of taping an "invisible spell" (masking policy) to every single paper (column) one by one, you just slap the magic sticker (tag) on any paper. The sticker carries the spell with it.

Even better: if you stick it on a **folder** (table), every paper inside the folder gets the spell. Stick it on the **filing cabinet** (schema), and every folder + paper inside is protected.

**Exam trigger:** "scalable governance" / "automatic protection for new columns" / "hundreds of tables with PII" → Tag-based Masking.
**Exam trigger:** "policy follows the tag" / "one policy, many columns" → Tag-based Masking.

**Exam trap**: "Tag-based masking requires a separate policy for each column?" → WRONG! ONE policy attached to ONE tag can protect unlimited columns. That's the whole point.
**Exam trap**: "New columns with the same tag need manual policy assignment?" → WRONG! The masking policy is on the TAG, not the column. New columns with the tag are automatically protected.

### Data Classification (Enterprise+):
- Automatically detect sensitive data (PII, PHI)
- Uses SYSTEM$CLASSIFY function
- Identifies semantic categories (email, phone, SSN, etc.)
- Can auto-apply tags

### Access History (Enterprise+):
- ACCOUNT_USAGE.ACCESS_HISTORY view
- Shows: who accessed what columns, when
- Useful for GDPR compliance, audit
- Tracks read and write access

### Data Lineage:
- Track data flow from source to destination
- OBJECT_DEPENDENCIES view in ACCOUNT_USAGE
- See which views/tables depend on other objects

### Trust Center (NEW for COF-C03):
- Security evaluation tool
- Scans account against security best practices
- Identifies security risks and recommendations
- CIS benchmarks

### Best Practices — Security
- ONE masking policy per column (can't stack)
- Use tag-based masking for scalability (tag columns, policy follows tag)
- Network policies: start with ALLOWED_IP_LIST, add BLOCKED_IP_LIST for exceptions
- Set DATA_RETENTION_TIME_IN_DAYS based on compliance needs, not defaults

### Example Scenario Questions — Data Governance Features

**Scenario:** A company's HR table has a SALARY column. HR managers should see actual salaries, but all other roles should see '****'. What feature should they use, and what's the limitation?
**Answer:** Dynamic Data Masking (Enterprise+). Create a masking policy that checks the current role — if HR_MANAGER, return the actual value; otherwise return '****'. Attach it to the SALARY column. Key limitation: only ONE masking policy per column (you can't stack multiple policies). For scaling across many columns, use tag-based masking — tag columns as "sensitive" and the policy follows the tag.

**Scenario:** A multinational company wants US-based analysts to only see US customer rows, and EU analysts to only see EU rows, from the same CUSTOMERS table. What feature should they use?
**Answer:** Row Access Policy (Enterprise+). Create a policy that checks the current role and returns TRUE only for rows matching that role's region. Apply it to the CUSTOMERS table. This is Row-Level Security — it filters ROWS, not columns. Do NOT confuse with Dynamic Data Masking, which hides column VALUES (not rows).

**Scenario:** A compliance officer needs to know which analysts accessed the PATIENT_RECORDS table's SSN column last month for a HIPAA audit. Where should they look?
**Answer:** ACCOUNT_USAGE.ACCESS_HISTORY (Enterprise+). This view tracks who accessed which columns, when, and whether it was a read or write. It provides column-level access tracking — exactly what HIPAA/GDPR audits require. It has 365 days of retention with up to 3-hour latency.

---

## 2.8 PRIVACY POLICIES

### Data Clean Rooms:
- Secure environments for multi-party data collaboration
- Each party keeps data private
- Run approved analyses without exposing raw data

### Differential Privacy:
- Protects against targeted privacy attacks
- Enterprise+

**Exam trap**: "Data Clean Room vs Row Access Policy?" → Clean Rooms = MULTI-PARTY collaboration with SEPARATE data. IF YOU SEE "filtering rows in your own table" with Clean Room → WRONG! That's Row Access Policy. Clean Room = cross-org collaboration.
**Exam trap**: "Differential Privacy edition?" → Enterprise+. IF YOU SEE "Differential Privacy" with "Standard edition" → WRONG! Also don't confuse with Data Clean Rooms (different feature entirely).

### Example Scenario Questions — Privacy Policies

**Scenario:** Two competing retail companies want to find how many customers they share in common without revealing their full customer lists to each other. What Snowflake feature enables this?
**Answer:** Data Clean Rooms. Each party loads their customer data into the clean room environment. They run approved overlap analysis queries, but raw data stays private to each party — only aggregate results (e.g., "12,500 shared customers") are visible. Neither company sees the other's full customer list.

---

## 2.8b EDITIONS & COMPLIANCE MAPPING (EXAM FAVORITE)

This is one of the most tested areas. You MUST know which features require which edition.

### Standard Edition (baseline -- included in ALL editions):
- Automatic encryption (AES-256, at rest + in transit)
- Network policies (IP allow/block lists)
- MFA support
- OAuth, SSO, federated authentication
- Object-level access control (RBAC + DAC)
- Standard Time Travel (up to **1 day**)
- Fail-safe (7 days beyond Time Travel)
- Object tags (basic)
- Database replication (cross-account/cross-region)
- Streams, Tasks, Snowpipe
- Managed Access Schemas

### Enterprise Edition (adds governance + performance):
- **Dynamic Data Masking** (column-level security)
- **Row Access Policies** (row-level security)
- **Aggregation Policies**, **Projection Policies**
- Extended Time Travel (up to **90 days**)
- Periodic rekeying of encrypted data
- **Data Classification** (SYSTEM$CLASSIFY)
- **ACCESS_HISTORY** view (column-level audit)
- Multi-cluster warehouses
- Search optimization service
- Materialized views
- Query acceleration service
- Data Quality / Data Metric Functions
- MIN_DATA_RETENTION_TIME_IN_DAYS parameter

### Business Critical Edition (adds compliance + private connectivity):
- Everything in Enterprise PLUS:
- **Tri-Secret Secure** (customer-managed keys)
- **PrivateLink** (AWS PrivateLink, Azure Private Link, GCP Private Service Connect)
- **HIPAA** and **HITRUST CSF** compliance
- **PCI DSS** compliance
- **Account Failover/Failback** (disaster recovery)
- Client redirect for business continuity
- Private connectivity to internal stages
- Amazon API Gateway private endpoints for external functions

### Virtual Private Snowflake (VPS) (maximum isolation):
- Everything in Business Critical PLUS:
- **Dedicated metadata store** (separate from shared infrastructure)
- **Dedicated compute pool** (isolated virtual warehouses)
- **ITAR** compliance (International Traffic in Arms Regulations)
- **FedRAMP** compliance (US Federal)
- **GovCloud** support

### Quick Reference — "Which Edition?" Decision Tree

| If the question mentions... | Answer |
|---|---|
| Masking, row access, projection, aggregation policies | **Enterprise+** |
| 90-day Time Travel | **Enterprise+** |
| Periodic rekeying | **Enterprise+** |
| Multi-cluster warehouses | **Enterprise+** |
| Search optimization, materialized views | **Enterprise+** |
| Data classification (SYSTEM$CLASSIFY) | **Enterprise+** |
| PrivateLink / private connectivity | **Business Critical+** |
| Tri-Secret Secure / customer-managed keys | **Business Critical+** |
| HIPAA, PCI DSS, HITRUST | **Business Critical+** |
| Failover / failback | **Business Critical+** |
| Dedicated metadata / dedicated compute | **VPS only** |
| ITAR, FedRAMP, GovCloud | **VPS** |
| Network policies, MFA, encryption, replication | **ALL editions** (Standard+) |
| Managed Access Schemas | **ALL editions** |

### ELI5: The Hotel Tiers (Editions)

Think of Snowflake editions as hotel tiers:

**Standard** = a clean, safe hotel room. You get a bed (encryption), a lock on the door (network policies), and a front desk (MFA). It works perfectly fine for most guests.

**Enterprise** = a boutique hotel. You get everything from Standard PLUS a safe in the room (masking policies), room service that only brings you YOUR food (row access), a concierge who tracks every visitor (ACCESS_HISTORY), and a nicer view (materialized views, search optimization).

**Business Critical** = a luxury private resort. You get everything from Enterprise PLUS your own private entrance (PrivateLink), your own key to the vault (Tri-Secret Secure), compliance certifications on the wall (HIPAA, PCI), and a backup resort in another city (failover).

**VPS** = your own private island. Everything from Business Critical PLUS your own staff (dedicated compute), your own records room (dedicated metadata), and government-level clearance (ITAR, FedRAMP).

**Exam trap**: "PrivateLink is available on Enterprise?" → WRONG! Business Critical+.
**Exam trap**: "Database replication requires Business Critical?" → WRONG! Replication is available on ALL editions. FAILOVER requires Business Critical+.
**Exam trap**: "Masking policies are available on Standard?" → WRONG! Enterprise+.
**Exam trap**: "90-day Time Travel on Standard?" → WRONG! Standard = 1 day max. Enterprise+ = up to 90 days.

---

## 2.9 ALERTS AND NOTIFICATIONS

### Alerts:
- Monitor conditions in your account
- Trigger when a condition is met
- Can send notifications
- Use SQL conditions

### Notifications:
- Email notifications
- Webhook integrations
- Triggered by alerts, resource monitors, tasks

**Exam trap**: "Alerts vs Resource Monitors?" → Alerts = custom SQL conditions on ANY data. IF YOU SEE "credit usage" with Alerts → trap! Resource Monitors track CREDITS. Alerts monitor ANY SQL condition.
**Exam trap**: "Who runs alert evaluations?" → Cloud Services layer (serverless). IF YOU SEE "warehouse" running alerts → WRONG! Alerts run on CLOUD SERVICES compute, NOT a warehouse.
**Exam trap**: "Alerts can trigger..." → Notifications AND task execution. IF YOU SEE "suspend warehouse" with Alerts → WRONG! That's resource monitor actions. Alerts trigger notifications/tasks, not suspend.

### Example Scenario Questions — Alerts and Notifications

**Scenario:** A data team wants to be notified whenever a specific staging table hasn't been updated in the last 24 hours. Should they use a Resource Monitor or an Alert?
**Answer:** An Alert. Alerts use custom SQL conditions to monitor ANY data condition — including checking timestamps. Example: `CREATE ALERT ... IF (SELECT DATEDIFF('hour', MAX(load_ts), CURRENT_TIMESTAMP()) FROM staging_table) > 24 THEN ...`. Resource Monitors only track credit usage, not data conditions.

**Scenario:** A finance team wants to automatically suspend a warehouse when it exceeds 80% of its monthly credit budget. Should they use an Alert or a Resource Monitor?
**Answer:** A Resource Monitor. Set up a resource monitor with an 80% threshold and "Notify & Suspend" action. Resource monitors are specifically designed for credit tracking and warehouse control. Alerts cannot suspend warehouses — they can only send notifications or trigger tasks.

---

## 2.10 REPLICATION AND FAILOVER

### Database Replication:
- Copy databases across accounts/regions
- Needed for: cross-region data sharing, disaster recovery
- Primary database (read-write) → Secondary database (read-only)
- Refresh secondary to sync changes

### Account Failover (Business Critical+):
- Promote secondary account to primary
- For disaster recovery
- Business continuity when primary region is unavailable

**Exam trap**: "Share data cross-region?" → Need REPLICATION first. IF YOU SEE "direct share" with cross-region → WRONG! Shares are same-region only. Cross-region requires replication THEN sharing.
**Exam trap**: "Failover edition?" → Business Critical+. IF YOU SEE "failover" with Enterprise edition → WRONG! Account failover = BC+ only. Don't confuse with database REPLICATION (available at lower tiers).

### Example Scenario Questions — Replication and Failover

**Scenario:** A company on AWS US-East wants to share a database with their team on Azure Europe. Can they create a direct share?
**Answer:** No. Direct shares only work within the same region AND same cloud provider. For cross-region or cross-cloud sharing, you must first replicate the database to the target region (`CREATE DATABASE ... AS REPLICA OF ...`), then create the share in that region. Replication first, then share.

**Scenario:** A company's primary Snowflake account in US-West goes down due to a regional outage. They have a replicated account in US-East. Can they switch to the US-East account? What edition do they need?
**Answer:** They need Business Critical+ edition to use account failover. With failover enabled, they can promote the secondary account in US-East to primary. Database replication alone (available on lower tiers) copies data but doesn't allow you to promote secondary to primary — that's the failover capability that requires BC+.

---

## 2.11 RESOURCE MONITORS (HEAVILY TESTED)

### What they do:
- Track credit usage for warehouses
- Set credit quotas (monthly, weekly, daily, etc.)
- NO additional cost (they just monitor)

### Actions when threshold is reached:
1. **Notify**: send alert only
2. **Notify & Suspend**: finish current queries, then suspend warehouse
3. **Notify & Suspend Immediately (Hard Suspend)**: cancel ALL running queries AND suspend warehouse

**Exam trap**: "Hard Suspend does what?" → CANCELS running queries immediately. IF YOU SEE "waits for queries to finish" with Hard Suspend → WRONG! That's regular Suspend. HARD Suspend = immediate cancellation.
**Exam trap**: "Do resource monitors cost credits?" → NO, zero cost. IF YOU SEE "credits per monitor" or "additional cost" → WRONG! Resource monitors are FREE. They only monitor, no compute cost.
**Exam trap**: "Who creates resource monitors?" → ACCOUNTADMIN. IF YOU SEE "SYSADMIN creates resource monitors" → WRONG! Only ACCOUNTADMIN (or role with CREATE RESOURCE MONITOR privilege).

### Can be set at:
- Account level (monitors all warehouses)
- Warehouse level (monitors specific warehouse)

### Example Scenario Questions — Resource Monitors

**Scenario:** An analytics warehouse is burning through credits. The admin sets a resource monitor at 90% with "Notify & Suspend." A critical report is running when the threshold is hit. What happens to the running query?
**Answer:** With "Notify & Suspend" (regular suspend), the running query finishes first, then the warehouse suspends. If you need to stop queries immediately, use "Notify & Suspend Immediately" (hard suspend) — that cancels ALL running queries and suspends the warehouse instantly. This is a key exam distinction.

**Scenario:** The CFO asks: "How much does it cost to set up resource monitors across all our warehouses?" What's the answer?
**Answer:** Zero. Resource monitors have NO additional cost — they are free. They simply track credit usage and trigger actions (notify, suspend, or hard suspend) when thresholds are reached. Only ACCOUNTADMIN (or a role with CREATE RESOURCE MONITOR privilege) can create them.

---

## 2.12 ACCOUNT_USAGE vs INFORMATION_SCHEMA (VERY HEAVILY TESTED)

| | ACCOUNT_USAGE | INFORMATION_SCHEMA |
|---|---|---|
| Location | SNOWFLAKE shared database | Each database |
| Latency | Up to 45 min - 3 hours | Real-time (no latency) |
| Retention | 1 year (365 days) | 7 days to 6 months (varies) |
| Dropped objects | YES (includes dropped) | NO |
| Scope | Entire account | Single database |
| Access | ACCOUNTADMIN (by default) | Any role with database access |

### Key ACCOUNT_USAGE views:
- **QUERY_HISTORY** → all queries (365 days)
- **LOGIN_HISTORY** → login attempts including failures (365 days)
- **WAREHOUSE_METERING_HISTORY** → warehouse credit usage
- **METERING_DAILY_HISTORY** → ALL credit usage (warehouses + serverless)
- **TABLE_STORAGE_METRICS** → storage including Fail-safe
- **ACCESS_HISTORY** → who accessed what (Enterprise+)
- **OBJECT_DEPENDENCIES** → lineage

### Key INFORMATION_SCHEMA views:
- QUERY_HISTORY() → function, 7 days max
- SERVERLESS_TASK_HISTORY() → task credits
- Real-time, no latency

**Exam trap**: "Credit usage for Search Optimization + Clustering?" → METERING_DAILY_HISTORY. IF YOU SEE "WAREHOUSE_METERING_HISTORY" for serverless → WRONG! WAREHOUSE = warehouses only. DAILY = ALL services including serverless.
**Exam trap**: "Failed logins for 6 months?" → ACCOUNT_USAGE.LOGIN_HISTORY. IF YOU SEE "INFORMATION_SCHEMA" with "6 months" → WRONG! INFORMATION_SCHEMA max = 7 days. 6 months requires ACCOUNT_USAGE (365 days).
**Exam trap**: "Includes dropped objects?" → ACCOUNT_USAGE. IF YOU SEE "INFORMATION_SCHEMA" with "dropped objects" → WRONG! INFORMATION_SCHEMA excludes dropped objects. Only ACCOUNT_USAGE shows them.
**Exam trap**: "Real-time query results?" → INFORMATION_SCHEMA. IF YOU SEE "ACCOUNT_USAGE" with "real-time" → WRONG! ACCOUNT_USAGE has 45min-3hr latency. INFORMATION_SCHEMA = real-time, no delay.
**Exam trap**: "QUERY_HISTORY max in Information Schema?" → 7 days. IF YOU SEE "365 days" with INFORMATION_SCHEMA → WRONG! 365 days = ACCOUNT_USAGE. INFORMATION_SCHEMA QUERY_HISTORY = 7 days max.

### Example Scenario Questions — ACCOUNT_USAGE vs INFORMATION_SCHEMA

**Scenario:** A security team needs to investigate failed login attempts from the past 3 months. Which view should they query?
**Answer:** ACCOUNT_USAGE.LOGIN_HISTORY (365 days retention). INFORMATION_SCHEMA only retains data for 7 days maximum, so 3-month-old data is only available in ACCOUNT_USAGE. Note: ACCOUNT_USAGE has up to 3-hour latency, so very recent logins (last few hours) might not appear yet.

**Scenario:** A DBA needs to check the current running queries RIGHT NOW to troubleshoot a performance issue. Should they use ACCOUNT_USAGE or INFORMATION_SCHEMA?
**Answer:** INFORMATION_SCHEMA — it's real-time with no latency. Use `SELECT * FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())` to see current and recent queries instantly. ACCOUNT_USAGE has up to 3-hour latency, which is useless for real-time troubleshooting.

**Scenario:** An admin wants to find all tables that were dropped in the last 6 months across the entire account. Which should they use?
**Answer:** ACCOUNT_USAGE. It has two key advantages here: (1) it includes dropped objects (INFORMATION_SCHEMA does NOT show dropped objects), and (2) it has 365-day retention (INFORMATION_SCHEMA max is 7 days). ACCOUNT_USAGE also covers the entire account scope, not just one database.

---

## 2.13 CALCULATING WAREHOUSE CREDITS

### Formula:
Credits = (warehouse_size_credits_per_hour) × (running_time_in_hours) × (number_of_clusters)

### Examples:
- XS warehouse running 1 hour = 1 credit
- Large warehouse running 30 minutes = 8 × 0.5 = 4 credits
- Multi-cluster (2 clusters) Medium running 1 hour = 4 × 1 × 2 = 8 credits

### Billing rules:
- Per-second billing with 60-second minimum
- Suspended warehouse = 0 credits
- Resizing takes effect for NEW queries (running queries use old size)
- Cloud Services: only billed if > 10% of daily warehouse credits

**Exam trap**: "Minimum billing for a warehouse?" → 60 seconds. IF YOU SEE "1 second" as minimum → WRONG! Per-second billing starts AFTER the 60-second minimum. First minute always billed in full.
**Exam trap**: "XL warehouse for 1 hour?" → 16 credits. IF YOU SEE "8 credits" for XL → WRONG! Each size DOUBLES: XS=1, S=2, M=4, L=8, XL=16. L=8, XL=16.
**Exam trap**: "Cloud Services always cost extra?" → WRONG. IF YOU SEE "always billed" with Cloud Services → trap! Only billed if Cloud Services exceed 10% of daily warehouse credits. Under 10% = FREE.

### Example Scenario Questions — Calculating Warehouse Credits

**Scenario:** A company runs a multi-cluster warehouse (Medium size, 3 clusters active) for 2 hours. How many credits does this consume?
**Answer:** Medium = 4 credits/hour. With 3 clusters running for 2 hours: 4 × 3 × 2 = 24 credits. Each cluster is a separate instance of the warehouse, so credits multiply by the number of active clusters.

**Scenario:** An admin resizes a warehouse from Small to XL while a query is still running. Does the running query benefit from the larger size?
**Answer:** No. Running queries continue on the OLD size. Only NEW queries submitted after the resize use the XL warehouse. The running query completes on the Small warehouse. This is a common exam trap — resizing is not retroactive for in-flight queries.

---

## 2.14 LOGGING AND TRACING

### Event Tables:
- Capture log messages, trace events from UDFs and procedures
- Associate event table with a database
- Available ALL editions (some features Enterprise+)

### Activity Logging:
- Query history, login history in ACCOUNT_USAGE
- Can track user activity for compliance

**Exam trap**: "Event tables vs ACCOUNT_USAGE query history?" → Event tables = UDF/procedure logs and traces. IF YOU SEE "SQL query history" with event tables → WRONG! SQL queries go to ACCOUNT_USAGE. Event tables = UDF/procedure runtime logs.
**Exam trap**: "Event tables require Enterprise?" → NO, ALL editions. IF YOU SEE "Enterprise required" with event tables → WRONG! Event tables are available ALL editions (some advanced features Enterprise+).
**Exam trap**: "Where do you set up an event table?" → Event tables can be associated at the ACCOUNT level (ALTER ACCOUNT SET EVENT_TABLE = 'db.schema.table') or at the DATABASE level. IF YOU SEE "schema level only" with event table setup → WRONG! Event tables can be set at account or database level.

### Example Scenario Questions — Logging and Tracing

**Scenario:** A Python UDF is throwing intermittent errors in production. The developer wants to add logging to understand what's happening at runtime. Where do the logs go?
**Answer:** Configure an Event Table and associate it with the database. The UDF can emit log messages that are captured in the event table. Event tables store UDF/procedure runtime logs and trace events — this is different from ACCOUNT_USAGE.QUERY_HISTORY, which tracks SQL query execution (not UDF internal logs). Event tables are available on ALL editions.

**Scenario:** An auditor wants to see all SQL queries executed against the FINANCE database in the last 90 days. Should they use event tables or ACCOUNT_USAGE?
**Answer:** ACCOUNT_USAGE.QUERY_HISTORY — it stores SQL query history for 365 days across the entire account. Event tables are for UDF/procedure runtime logs and traces, NOT for SQL query history. This is a key distinction: SQL queries → ACCOUNT_USAGE. UDF/procedure logs → Event Tables.

---

## 2.15 PARAMETER LEVELS AND PRECEDENCE

Snowflake has FOUR levels where settings can be applied. Not all parameters support all levels.

### The four levels:
- **Account** -- set by ACCOUNTADMIN, applies to everyone (ALTER ACCOUNT SET ...)
- **Object** -- set on a specific warehouse, database, schema, or table (ALTER WAREHOUSE wh1 SET ...)
- **User** -- set BY AN ADMIN on a user object (ALTER USER debora SET ...). The user CANNOT change this themselves.
- **Session** -- set by the user for their current connection only (ALTER SESSION SET ...)

Don't confuse USER-level with SESSION-level. User-level = an admin assigns a setting TO a user (the user cannot change it). Session-level = the user sets it FOR themselves (temporary, current connection only).

### Precedence Rule: Most specific wins (for parameters)
- Session > Object > Account
- Example: Account timeout = 3600s, Warehouse timeout = 600s, you run ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 120 -- your queries timeout at 120s

### Key parameters to know:

| Parameter | Levels | Notes |
|---|---|---|
| STATEMENT_TIMEOUT_IN_SECONDS | Account, Object (warehouse), Session | Kills long queries. Session overrides. |
| DATA_RETENTION_TIME_IN_DAYS | Account, Object (database/schema/table) | Time Travel window (0-90 days). Table > Schema > Database > Account. NOT session-settable. |
| MIN_DATA_RETENTION_TIME_IN_DAYS | Account only | Floor that objects cannot go below. Enterprise+ only. |
| NETWORK_POLICY | Account, User | User-level overrides account-level. NOT session-settable. Admin-controlled only. |
| REQUIRE_STORAGE_INTEGRATION_FOR_STAGE_CREATION | Account only | Security hardening. Forces storage integration for external stages. |
| TIMEZONE | Account, Session | Default UTC. Session overrides account. |

**Exam trap**: "Session overrides everything" -- WRONG. Session only overrides PARAMETERS (timeout, timezone). Security policies (network policy, masking, row access) are ENFORCED regardless of session. IF YOU SEE "ALTER SESSION" + "bypass policy" in a question -- the answer is WRONG.
**Exam trap**: "User-level and session-level are the same thing" -- WRONG. User-level = admin sets it ON the user (ALTER USER). Session-level = user sets it FOR themselves (ALTER SESSION). Network policies are user-level (admin-controlled), NOT session-level.
**Exam trap**: "DATA_RETENTION_TIME_IN_DAYS can be set in session" -- WRONG. It is an OBJECT-level parameter (table, schema, database, account). You cannot ALTER SESSION to change Time Travel retention.

### What CAN vs CANNOT be overridden by session:

| Can session override? | Yes | No |
|---|---|---|
| Examples | STATEMENT_TIMEOUT, TIMEZONE, DATE_OUTPUT_FORMAT, QUERY_TAG | DATA_RETENTION, NETWORK_POLICY, REQUIRE_STORAGE_INTEGRATION, MIN_DATA_RETENTION |
| Why | These are user preferences / query behavior | These are security/governance -- admin-controlled |

### The Funnel Concept (Parameter Hierarchy)

Think of parameter precedence as a **funnel** -- settings flow from the broadest level (Account) down to the narrowest (Session), and the narrowest wins:

```
┌─────────────────────────────────┐
│         ACCOUNT (broadest)      │  ← Default for everyone
│   ┌─────────────────────────┐   │
│   │    OBJECT (warehouse,   │   │  ← Overrides account for this object
│   │    database, schema,    │   │
│   │    table)               │   │
│   │   ┌─────────────────┐   │   │
│   │   │   SESSION        │   │   │  ← Overrides everything (most specific)
│   │   │   (narrowest)    │   │   │
│   │   └─────────────────┘   │   │
│   └─────────────────────────┘   │
└─────────────────────────────────┘
```

**But there are EXCEPTIONS to "most specific wins":**

1. **Network Policy**: User-level **REPLACES** (not supplements) account-level. If account allows IPs A+B and user allows only C, the user can ONLY connect from C. This is NOT additive -- it's a full replacement.

2. **MIN_DATA_RETENTION_TIME_IN_DAYS** (Enterprise+): This is an account-level **FLOOR**. Nobody can set DATA_RETENTION_TIME_IN_DAYS lower than this value, even on individual objects. If MIN is set to 7, you cannot set a table's retention to 1 day -- Snowflake enforces the minimum. This protects against accidental or malicious data purge.

3. **Security policies** (masking, row access, network): These are **ENFORCED regardless of session**. A user cannot ALTER SESSION to bypass any security policy. Period.

### Common Confusion

Don't confuse these similar-sounding concepts:
- **Network policy at user level** vs **session parameter**: Network policy is set BY AN ADMIN on the user object. The user cannot change it. It is NOT a session setting.
- **DATA_RETENTION on table** vs **session override**: Retention is set on the object. You cannot ALTER SESSION to change how long Time Travel works.
- **"Most specific wins"** applies to PARAMETERS. For SECURITY POLICIES, the rule is "always enforced" -- there is no override chain.
- **MIN_DATA_RETENTION vs DATA_RETENTION**: MIN is an account-level FLOOR (Enterprise+). DATA_RETENTION is settable per object. MIN prevents anyone from going below the floor. If MIN=7 and someone tries to set a table to 1, Snowflake uses 7.

### Example Scenario Questions -- Parameter Precedence

**Scenario:** The account has STATEMENT_TIMEOUT_IN_SECONDS = 3600 (1 hour). A warehouse has it set to 600 (10 minutes). A user runs ALTER SESSION SET STATEMENT_TIMEOUT_IN_SECONDS = 120 (2 minutes). What timeout applies to their queries?
**Answer:** 120 seconds (2 minutes). Session overrides object (warehouse), which overrides account. Most specific wins for parameters.

**Scenario:** An admin sets a network policy at account level allowing only office IPs. A user tries to run ALTER SESSION to add their home IP. Does it work?
**Answer:** No. Network policies are NOT session-settable. They can only be set at account level or user level BY AN ADMIN. The user cannot override network policies from their session.

**Scenario:** A table has DATA_RETENTION_TIME_IN_DAYS = 1. A developer wants to run ALTER SESSION SET DATA_RETENTION_TIME_IN_DAYS = 90 to recover data from 30 days ago. Does it work?
**Answer:** No. DATA_RETENTION_TIME_IN_DAYS is an object-level parameter, not a session parameter. The developer must ALTER TABLE to change it (and needs appropriate privileges). Even then, data already purged beyond the original 1-day window cannot be recovered.

---

## RAPID-FIRE REVIEW — Domain 2

1. RBAC = privileges to roles to users. DAC = owner grants access.
2. ACCOUNTADMIN = top role, billing, shares, resource monitors
3. SECURITYADMIN = grants, network policies
4. USERADMIN = create users and roles
5. SYSADMIN = create databases, warehouses, schemas
6. ORGADMIN = organization-level, create accounts
7. Custom roles → grant to SYSADMIN (best practice)
8. Object owner = role that created it
9. MFA = Duo Security, self-enrollment
10. Key pair = programmatic access, no password
11. Network policies = IP allow/block lists, ALL editions
12. All data encrypted AES-256 automatically
13. Tri-Secret Secure = BC+, customer-managed key
14. Masking policies = Enterprise+, column-level
15. Row access policies = Enterprise+, row-level
16. Data classification = Enterprise+, auto-detect PII
17. Access History = Enterprise+, audit who accessed what
18. Trust Center = security posture evaluation (NEW)
19. Resource monitors = zero cost, track credits, can suspend
20. Hard Suspend = cancels running queries immediately
21. ACCOUNT_USAGE: 365 days, up to 3hr latency, includes dropped objects
22. INFORMATION_SCHEMA: real-time, 7 days, per-database
23. METERING_DAILY_HISTORY = all credit usage (serverless included)
24. Replication needed for cross-region sharing
25. Failover = BC+ only

---

## CONFUSING PAIRS — Domain 2

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Who manages grants | SECURITYADMIN | ACCOUNTADMIN |
| Who creates users | USERADMIN | SECURITYADMIN |
| Who creates databases | SYSADMIN | ACCOUNTADMIN |
| Who views billing | ACCOUNTADMIN | SYSADMIN |
| Who creates Shares | ACCOUNTADMIN | SYSADMIN |
| Who creates org accounts | ORGADMIN | ACCOUNTADMIN |
| Column masking | Dynamic Data Masking (Enterprise+) | Row Access Policy |
| Row filtering | Row Access Policy (Enterprise+) | Masking Policy |
| Customer-managed keys | Tri-Secret Secure (BC+) | Periodic rekeying |
| Periodic rekeying | Enterprise+ | Business Critical |
| Resource monitor cost | Zero (free) | Credits per monitor |
| Hard Suspend | Cancels running queries | Waits for queries to finish |
| Suspend | Waits for queries to finish | Cancels immediately |
| Account Usage latency | Up to 3 hours | Real-time |
| Information Schema retention | 7 days (QUERY_HISTORY) | 365 days |
| Dropped objects visible | ACCOUNT_USAGE | INFORMATION_SCHEMA |
| METERING_DAILY_HISTORY | All services (serverless too) | Warehouses only |
| WAREHOUSE_METERING_HISTORY | Warehouses only | Serverless services |

---

## BRAIN-FRIENDLY SUMMARY — Domain 2

### SCENARIO DECISION TREES
When you read a question, find the pattern:

**"A client's security team wants to control who manages access grants across the entire account..."**
→ SECURITYADMIN
→ NOT ACCOUNTADMIN (ACCOUNTADMIN can, but SECURITYADMIN is the designated role for grants)

**"A client asks: who should create the data warehouse and databases for the analytics team?"**
→ SYSADMIN (the builder)
→ NOT ACCOUNTADMIN (overkill for this)

**"An organization needs to create a new Snowflake account in a different region..."**
→ ORGADMIN
→ NOT ACCOUNTADMIN (ACCOUNTADMIN is per-account, not org-level)

**"A client wants their HR team to see full SSN but everyone else sees masked values..."**
→ Dynamic Data Masking (column-level, Enterprise+)
→ NOT Row Access Policy (that filters rows, not columns)

**"A client's US team should only see US customer rows..."**
→ Row Access Policy (Enterprise+)
→ NOT Dynamic Data Masking (that hides column values, not rows)

**"A healthcare client needs to control their own encryption keys..."**
→ Tri-Secret Secure (Business Critical+)
→ NOT just "encryption" (encryption is automatic for everyone)

**"A client wants to know total credit usage including serverless features..."**
→ METERING_DAILY_HISTORY (covers everything)
→ NOT WAREHOUSE_METERING_HISTORY (warehouses only)

**"A client wants real-time data about currently running queries..."**
→ INFORMATION_SCHEMA (real-time, no latency)
→ NOT ACCOUNT_USAGE (up to 3hr delay)

**"A client wants login history from 6 months ago..."**
→ ACCOUNT_USAGE.LOGIN_HISTORY (365 days)
→ NOT INFORMATION_SCHEMA (max 7 days)

**"An admin needs to stop a runaway warehouse from burning credits..."**
→ Resource Monitor → Notify & Suspend Immediately (hard suspend)
→ Zero cost to set up the monitor itself

**"A new data engineer joins the company. The admin creates their user. Which role does the engineer automatically get?"**
→ PUBLIC (every user gets PUBLIC automatically)
→ Additional roles must be explicitly granted

**"A client's custom roles can't access databases that SYSADMIN created. Why?"**
→ Custom roles are NOT granted to SYSADMIN (best practice violation)
→ Fix: GRANT custom_role TO ROLE SYSADMIN (so hierarchy flows properly)

**"A compliance team needs to know which columns an analyst accessed last month..."**
→ Access History (ACCOUNT_USAGE.ACCESS_HISTORY, Enterprise+)
→ Shows who read/wrote which columns and when

**"A client's data has PII (emails, SSN, phone numbers) scattered across hundreds of tables..."**
→ Data Classification (SYSTEM$CLASSIFY, Enterprise+)
→ Automatically detects sensitive data categories

**"A security audit asks: are we following Snowflake security best practices?"**
→ Trust Center (scans account, CIS benchmarks, recommendations)

**"A client wants to connect their Okta identity provider for single sign-on..."**
→ Federated Authentication / SSO (SAML 2.0)
→ Available ALL editions

**"A service account needs to connect to Snowflake from a Python script without a password..."**
→ Key Pair Authentication (RSA public/private key)
→ NOT OAuth (that's for user-facing apps)

**"A client has a resource monitor set at 80% threshold with Notify & Suspend. Current queries keep running. They want queries to STOP immediately..."**
→ Change to Notify & Suspend Immediately (hard suspend)
→ Regular Suspend waits for queries to finish; Hard Suspend cancels them

**"A client wants to see a dropped table that was deleted 3 months ago in their query history..."**
→ ACCOUNT_USAGE (includes dropped objects, 365 days retention)
→ NOT INFORMATION_SCHEMA (does NOT show dropped objects)

**"A client needs different network policies for their admin users vs regular users..."**
→ User-level network policy (REPLACES account-level, does NOT add to it)
→ If account allows IPs A+B and user allows IP C, user can ONLY connect from C

**"A client asks: how often does Snowflake rotate encryption keys?"**
→ Every 30 days (automatic, all editions)
→ Periodic rekeying (re-encrypts data with new key) = Enterprise+
→ These are DIFFERENT: rotation = new key for new data, rekeying = re-encrypt old data too

**"A database role is created to manage access within the ANALYTICS database. Can a user activate it directly?"**
→ NO. Database roles cannot be activated directly in a session.
→ Must be granted to an account role first.

**"A user needs permissions from multiple roles at the same time in one session..."**
→ Secondary Roles (USE SECONDARY ROLES ALL)
→ Combines permissions from all granted roles

---

### MNEMONICS TO LOCK IN

**Role hierarchy = "A-S-U-S-P" (top to bottom)**
- **A**CCOUNTADMIN → the boss (billing, shares, resource monitors)
- **S**ECURITYADMIN → the bouncer (grants, network policies)
- **U**SERADMIN → HR (creates users & roles)
- **S**YSADMIN → the builder (databases, warehouses, schemas)
- **P**UBLIC → everyone gets this automatically

**Who does what = "BASU"**
- **B**illing → ACCOUNTADMIN
- **A**ccess grants → SECURITYADMIN
- **S**tuff (objects) → SYSADMIN
- **U**sers → USERADMIN

**ACCOUNT_USAGE vs INFORMATION_SCHEMA = "Old vs Now"**
- ACCOUNT_USAGE = OLD data (365 days, but delayed up to 3hr)
- INFORMATION_SCHEMA = NOW data (real-time, but only 7 days)

**Encryption tiers = "A-P-T" (All-Periodic-Tri)**
- **A**ES-256 = ALL editions (automatic)
- **P**eriodic rekeying = Enterprise+
- **T**ri-Secret Secure = Business Critical+

**Enterprise+ governance = "MARC" (Masking, Access history, Row access, Classification)**
- All four are Enterprise+ features
- Think: "You MARC sensitive data"

---

### TOP TRAPS — Domain 2

1. **"ACCOUNTADMIN should be the default role"** → WRONG. Best practice: use SYSADMIN or lower as default.
2. **"SECURITYADMIN creates users"** → WRONG. USERADMIN creates users.
3. **"ACCOUNTADMIN manages grants"** → TRICKY. SECURITYADMIN is the designated grants manager. ACCOUNTADMIN CAN do it (inherits everything), but the exam wants SECURITYADMIN.
4. **"Network policies require Enterprise"** → WRONG. ALL editions.
5. **"MFA requires Enterprise"** → WRONG. ALL editions.
6. **"Resource monitors cost credits"** → WRONG. Zero cost.
7. **"Hard Suspend waits for queries to finish"** → WRONG. Hard Suspend CANCELS running queries immediately.
8. **"INFORMATION_SCHEMA shows dropped objects"** → WRONG. Only ACCOUNT_USAGE shows dropped objects.
9. **"ACCOUNT_USAGE is real-time"** → WRONG. Up to 3 hours latency.
10. **"Masking policy = row filtering"** → WRONG. Masking = column values. Row Access Policy = row filtering.

---

### PATTERN SHORTCUTS — "If you see ___, answer is ___"

| If the question mentions... | The answer is almost always... |
|---|---|
| "billing", "cost monitoring" | ACCOUNTADMIN |
| "manage grants", "revoke access" | SECURITYADMIN |
| "create users", "create roles" | USERADMIN |
| "create database", "create warehouse" | SYSADMIN |
| "create accounts in org" | ORGADMIN |
| "hide column values per role" | Dynamic Data Masking (Enterprise+) |
| "filter rows per role" | Row Access Policy (Enterprise+) |
| "customer-managed key" | Tri-Secret Secure (BC+) |
| "key rotation every 30 days" | Automatic (all editions) |
| "periodic rekeying" | Enterprise+ |
| "detect PII automatically" | Data Classification (Enterprise+) |
| "who accessed what column" | Access History (Enterprise+) |
| "security posture", "CIS benchmark" | Trust Center |
| "IP allow/block list" | Network Policy (all editions) |
| "programmatic access, no password" | Key Pair Authentication |
| "Duo Security" | MFA |
| "SAML 2.0" | Federated Auth / SSO |
| "365 days history" | ACCOUNT_USAGE |
| "real-time query info" | INFORMATION_SCHEMA |
| "serverless credit usage" | METERING_DAILY_HISTORY |
| "warehouse-only credit usage" | WAREHOUSE_METERING_HISTORY |
| "stop warehouse burning credits" | Resource Monitor |

---

## EXAM DAY TIPS — Domain 2 (20% = ~20 questions)

**Before studying this domain:**
- Flashcard the 5 system roles + what each does — this is the #1 tested topic here
- Flashcard ACCOUNT_USAGE vs INFORMATION_SCHEMA differences (latency, retention, dropped objects)
- Know the Enterprise+ governance features: "MARC" (Masking, Access history, Row access, Classification)

**During the exam — Domain 2 questions:**
- Read the LAST sentence first (the actual question) — then read the scenario
- Eliminate 2 obviously wrong answers immediately
- If they ask "which ROLE" → mentally walk the hierarchy: ACCOUNTADMIN > SECURITYADMIN > USERADMIN > SYSADMIN > PUBLIC
- If they ask about SEEING old data → check: how old? Real-time = INFORMATION_SCHEMA. Historical = ACCOUNT_USAGE.
- If they ask about SECURITY FEATURES → check: all editions? Enterprise+? BC+?
- If they mention ENCRYPTION → think A-P-T: AES (all), Periodic rekeying (Ent+), Tri-Secret (BC+)

---

## ONE-LINE PER TOPIC — Domain 2

| Topic | One-line summary |
|---|---|
| RBAC + DAC | RBAC: privileges → roles → users. DAC: object owner grants access. Both work together. |
| ACCOUNTADMIN | Top role: billing, shares, resource monitors. NOT for daily use. |
| SECURITYADMIN | Manages grants and network policies. The "bouncer." |
| USERADMIN | Creates users and roles. The "HR department." |
| SYSADMIN | Creates databases, warehouses, schemas. The "builder." Custom roles → grant here. |
| ORGADMIN | Organization-level: creates accounts across regions. Not in regular hierarchy. |
| PUBLIC | Every user gets this automatically. Lowest level. |
| Database roles | Scoped to one database, cannot activate directly, must grant to account role. |
| Secondary roles | USE SECONDARY ROLES ALL = combine permissions from multiple roles in one session. |
| MFA | Duo Security, self-enrollment, all editions. Best practice for ACCOUNTADMIN. |
| SSO / Federated Auth | SAML 2.0, external IdP (Okta, Azure AD), all editions. |
| OAuth | External or Snowflake OAuth, no password sharing, all editions. |
| Key Pair Auth | RSA keys for programmatic/CLI access, no password needed. |
| Network Policies | IP allow/block lists, account or user level, user overrides account, all editions. |
| Encryption | AES-256 automatic (all), periodic rekeying (Ent+), Tri-Secret Secure (BC+). |
| Dynamic Data Masking | Column-level, role-based, Enterprise+. HR sees SSN, others see ****. |
| Row Access Policies | Row-level filtering by role, Enterprise+. US team sees US rows only. |
| Data Classification | SYSTEM$CLASSIFY auto-detects PII, Enterprise+. |
| Access History | Who accessed what columns and when, Enterprise+, ACCOUNT_USAGE. |
| Trust Center | Security posture scan, CIS benchmarks, recommendations. NEW topic. |
| Object Tagging | Key-value tags on any object, propagate through lineage. |
| Resource Monitors | Track credit usage, zero cost, can notify/suspend/hard-suspend. |
| ACCOUNT_USAGE | 365 days, up to 3hr latency, includes dropped objects, ACCOUNTADMIN access. |
| INFORMATION_SCHEMA | Real-time, 7 days max, per-database, any role with DB access. |
| METERING_DAILY_HISTORY | All credit usage including serverless (clustering, pipes, etc.). |
| Replication | Copy databases across accounts/regions. Needed for cross-region sharing. |
| Failover | Promote secondary to primary. BC+ only. For disaster recovery. |

---

## FLASHCARDS — Domain 2

**Q:** What is the role hierarchy from top to bottom?
**A:** ACCOUNTADMIN > SECURITYADMIN > USERADMIN + SYSADMIN > PUBLIC. ACCOUNTADMIN = SECURITYADMIN + SYSADMIN combined.

**Q:** What does SECURITYADMIN do?
**A:** Owns MANAGE GRANTS — can grant/revoke any privilege on any object. Also inherits USERADMIN.

**Q:** What does USERADMIN do?
**A:** Creates and manages users and roles. Does NOT own data objects.

**Q:** What does SYSADMIN do?
**A:** Creates and owns warehouses, databases, schemas, and all data objects. Recommended default for creating objects.

**Q:** What access control models does Snowflake use?
**A:** Both RBAC (Role-Based) AND DAC (Discretionary). RBAC for roles, DAC because object owners control access.

**Q:** What is the difference between ACCOUNT_USAGE and INFORMATION_SCHEMA?
**A:** ACCOUNT_USAGE: 45min-3h latency, 365 days retention, in SNOWFLAKE shared database. INFORMATION_SCHEMA: real-time, 7 days to 6 months (varies by view), per-database only.

**Q:** How do network policies work?
**A:** ALLOWED_IP_LIST (whitelist) + BLOCKED_IP_LIST (blacklist). Most restrictive wins. Can be set at account or user level.

**Q:** What does a resource monitor track?
**A:** CREDIT usage, NOT query count. Actions: Notify, Notify & Suspend, Notify & Suspend Immediately. Can be set at ACCOUNT or WAREHOUSE level.

**Q:** What edition is needed for masking policies?
**A:** Enterprise Edition or higher. One masking policy per column. Attached via ALTER TABLE.

**Q:** What is Tri-Secret Secure?
**A:** Customer-managed key (via cloud KMS) + Snowflake-managed key = composite master key. Business Critical+ only. If customer revokes their key, data is inaccessible.

**Q:** What is periodic rekeying?
**A:** Snowflake automatically re-encrypts data with new keys. Enterprise+. Happens transparently in background.

**Q:** What are the authentication methods?
**A:** Username/password, MFA (via Duo), key pair authentication, SSO (SAML 2.0 via Okta/ADFS/etc.), OAuth (Snowflake OAuth or External OAuth).

**Q:** What is object tagging?
**A:** Labeling objects (tables, columns) with key-value tags for governance. Useful for classifying sensitive data. Tags propagate via lineage.

**Q:** What is access history?
**A:** ACCOUNT_USAGE.ACCESS_HISTORY view — shows who read/wrote what data, including columns. For audit and compliance.

**Q:** Row access policy vs masking policy?
**A:** Row access policy: filters ROWS based on user context (role, user). Masking policy: masks COLUMN values (e.g., show only last 4 digits of SSN).

**Q:** What can resource monitors NOT do?
**A:** Cannot track serverless costs (Snowpipe, auto-clustering). Note: with SUSPEND_IMMEDIATE (Hard Suspend), resource monitors CAN cancel already-running queries — only regular SUSPEND waits for running queries to finish before suspending.

**Q:** What is the difference between database replication and account replication?
**A:** Database replication: copies data + objects. Account replication: copies users, roles, warehouses, resource monitors, network policies.

**Q:** How do you calculate warehouse credits?
**A:** XS=1, S=2, M=4, L=8, XL=16, 2XL=32, 3XL=64, 4XL=128. Each size doubles. Per-second billing, 60-second minimum.

**Q:** What is a projection policy?
**A:** Controls which columns can appear in query results. Different from masking — projection completely hides the column, masking transforms the value.

**Q:** What are alerts?
**A:** Scheduled SQL checks that trigger actions (email, task) when conditions are met. Evaluated by Cloud Services compute.

---

## EXPLAIN LIKE I'M 5 — Domain 2

**ACCOUNTADMIN**: The super boss who can do everything. Use carefully — like giving someone the master key to the entire building.

**SECURITYADMIN**: The security guard who decides who gets which keys (grants/revokes access).

**USERADMIN**: The HR person who creates new employees (users) and assigns them to teams (roles).

**SYSADMIN**: The facilities manager who builds and owns the rooms (databases, warehouses) where work happens.

**PUBLIC**: Everyone gets this role automatically. It's like the lobby — open to all.

**RBAC**: Instead of giving permissions to each person, you give permissions to a role (like "Manager"), then give people the role.

**Network policy**: A bouncer at the door who checks your ID (IP address). If you're on the list, you get in. If not, go away.

**Resource monitor**: A credit card spending alert. It watches how many credits your warehouses use and warns you (or stops them) if you spend too much.

**Masking policy**: Like putting a sticker over part of a credit card number so people can only see the last 4 digits.

**Row access policy**: Like a filter that shows different people different rows. Sales team sees only their region's data.

**Tri-Secret Secure**: You AND Snowflake each hold a key. Both keys are needed to unlock the data. If you take away your key, nobody can read it.

**ACCOUNT_USAGE**: A detailed diary of everything that happened in your account, but it takes 45 minutes to 2 hours to write entries, and keeps records for a year.

**INFORMATION_SCHEMA**: A quick snapshot of what exists right now. Instant answers, but only remembers the last 14 days.

**Object tagging**: Putting sticky labels on your data saying "this is sensitive" or "this is PII" so you can find and protect it.

**Access history**: A security camera recording who looked at what data and when.

**MFA**: A second lock on the door — even if someone steals your password, they still need the code from your phone.

**Periodic rekeying**: Snowflake automatically changes the locks on your data. Like changing passwords regularly, but for encryption.

**Projection policy**: Completely hiding a column from query results — not masking it, just making it invisible.
