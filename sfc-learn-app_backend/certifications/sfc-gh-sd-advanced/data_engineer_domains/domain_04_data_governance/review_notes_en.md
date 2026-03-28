# Domain 4: Data Governance

> **DEA-C01 Weight:** 14% of the exam

---

## 4.1 Role-Based Access Control (RBAC) and Discretionary Access Control (DAC)

### Key Concepts
- **RBAC (Role-Based Access Control)** is Snowflake's primary access model: privileges are granted to roles, roles are granted to users
- **DAC (Discretionary Access Control)** means the object owner controls who can access it -- the creator role owns the object by default
- **Principle of least privilege:** Grant only the minimum permissions needed for each role
- **Role hierarchy:** Child roles inherit privileges from parent roles; parent roles "see" everything the child roles can see
- **GRANT ROLE child_role TO ROLE parent_role** establishes the hierarchy
- **All privileges flow upward:** If role A is granted to role B, then role B has all of role A's privileges
- **Active role vs primary role:** USE ROLE sets the primary role; secondary roles can be enabled with USE SECONDARY ROLES ALL
- **Ownership** is the most powerful privilege -- the owning role can grant access to others and modify/drop the object

### Why This Matters
Every data engineering pipeline runs under a specific role. Misconfigured roles cause either security holes (too permissive) or pipeline failures (too restrictive). Understanding the role hierarchy is essential for designing secure, functional pipelines.

### Best Practices
- Create functional roles (ETL_ROLE, ANALYTICS_ROLE) rather than granting privileges directly to users
- Build a clear role hierarchy with SYSADMIN at the top of custom role chains
- Always grant custom roles to SYSADMIN so ACCOUNTADMIN can manage all objects
- Avoid granting ACCOUNTADMIN to pipeline service accounts
- Use GRANT OWNERSHIP for transferring object management between roles
- Document the role hierarchy and review it periodically

**Exam trap:** IF YOU SEE "Users inherit privileges directly without roles" -> WRONG because Snowflake requires privileges to be granted to roles, which are then granted to users. Users do not receive direct privileges.

**Exam trap:** IF YOU SEE "ACCOUNTADMIN automatically inherits all custom roles" -> WRONG because ACCOUNTADMIN only inherits custom roles if they are granted to SYSADMIN (or directly to ACCOUNTADMIN). Orphan roles not in the hierarchy are invisible to ACCOUNTADMIN.

### Common Questions (FAQ)
**Q: What happens if a role is dropped that owns objects?**
A: The objects become owned by the role that dropped the owning role. You should transfer ownership first with GRANT OWNERSHIP.

**Q: Can a user have multiple roles active simultaneously?**
A: Yes. Use USE SECONDARY ROLES ALL to activate all granted roles in addition to the primary role.

### Example Scenario Questions
**Scenario:** A company has an ETL pipeline that creates tables in a PROD_DB database. Later, analysts cannot see these tables even though they have SELECT on the database. What is wrong?
**Answer:** The analysts' role likely lacks SELECT privileges on the specific tables or schema. Database-level access alone is insufficient -- privileges must be granted at the schema and table level (or via FUTURE GRANTS). Also verify the ETL role's objects are in the role hierarchy accessible to the analyst role.

---

## 4.2 System-Defined Roles

### Key Concepts
- **ACCOUNTADMIN** = top-level role combining SYSADMIN + SECURITYADMIN; manages billing, resource monitors, shares, readers
- **SYSADMIN** = creates and manages databases, schemas, warehouses, and all database objects
- **SECURITYADMIN** = manages users, roles, grants (owns the MANAGE GRANTS global privilege)
- **USERADMIN** = creates and manages users and roles (subset of SECURITYADMIN)
- **PUBLIC** = automatically granted to every user; use it only for truly public objects
- **ORGADMIN** = manages organization-level operations (account creation, org usage)
- **Role hierarchy default:** ACCOUNTADMIN -> SYSADMIN + SECURITYADMIN -> USERADMIN -> PUBLIC

### Why This Matters
System roles define the security boundary of Snowflake accounts. Data engineers must know which role to use for each operation and avoid over-privileging pipeline roles.

### Best Practices
- Use ACCOUNTADMIN sparingly (billing, shares, account parameters, resource monitors)
- Use SYSADMIN (or a child of SYSADMIN) for creating databases, schemas, tables, warehouses
- Use SECURITYADMIN for managing grants and access control
- Always ensure custom roles roll up to SYSADMIN so objects remain manageable
- Never use ACCOUNTADMIN as the default role for any user

**Exam trap:** IF YOU SEE "SYSADMIN can manage users and roles" -> WRONG because user and role management belongs to SECURITYADMIN (or USERADMIN). SYSADMIN manages database objects.

**Exam trap:** IF YOU SEE "PUBLIC role has no privileges" -> WRONG because PUBLIC is granted to every user and can have privileges granted to it. Any privilege on PUBLIC is available to all users.

**Exam trap:** IF YOU SEE "Only ACCOUNTADMIN can create databases" -> WRONG because SYSADMIN (and any role with CREATE DATABASE privilege) can create databases.

### Common Questions (FAQ)
**Q: Which role should create resource monitors?**
A: ACCOUNTADMIN. Resource monitors are account-level objects that require ACCOUNTADMIN privileges.

**Q: Can SECURITYADMIN create warehouses?**
A: Not by default. SECURITYADMIN manages security (users, roles, grants). Warehouse creation is a SYSADMIN function. However, SECURITYADMIN can grant CREATE WAREHOUSE to any role.

### Example Scenario Questions
**Scenario:** A new data engineer is given ACCOUNTADMIN as their primary role for convenience. What risks does this create?
**Answer:** ACCOUNTADMIN has unrestricted access to everything: billing, all data, user management, shares, and account settings. A misconfigured query or accidental DROP could affect the entire account. The engineer should use a custom role with only the needed privileges, with ACCOUNTADMIN reserved for exceptional administrative tasks.

---

## 4.3 Masking Policies (Dynamic Data Masking)

### Key Concepts
- **Dynamic Data Masking** applies a masking policy to a column that transforms data at query time based on the querying role
- **Policy definition:** CREATE MASKING POLICY ... AS (val <type>) RETURNS <type> -> CASE WHEN ... END
- **Conditional masking:** Use CURRENT_ROLE() or IS_ROLE_IN_SESSION() in the policy body to return full or masked values
- **One policy per column** -- a column can have only one masking policy attached at a time
- **Masking is transparent:** Users see masked results without knowing the policy exists (no query changes needed)
- **Tag-based masking:** Attach masking policies to tags instead of individual columns. Any column with that tag gets masked automatically
- **Masking policies are schema-level objects** with their own ownership and privileges

### Why This Matters
Data engineers build pipelines that serve multiple consumer roles. Dynamic masking allows a single table to serve both privileged and restricted users without maintaining separate copies.

### Best Practices
- Use IS_ROLE_IN_SESSION() instead of CURRENT_ROLE() for hierarchy-aware masking (checks inherited roles)
- Centralize masking policies in a dedicated governance schema
- Use tag-based masking for consistent policy application across many tables
- Test masking policies with each consumer role before deploying to production
- Document which roles see unmasked data for audit purposes

**Exam trap:** IF YOU SEE "Masking policies are applied at the row level" -> WRONG because masking policies are column-level. Row Access Policies handle row-level filtering.

**Exam trap:** IF YOU SEE "CURRENT_ROLE() checks inherited roles" -> WRONG because CURRENT_ROLE() only checks the active primary role. IS_ROLE_IN_SESSION() checks the full hierarchy including inherited roles.

**Exam trap:** IF YOU SEE "You can attach multiple masking policies to one column" -> WRONG because only one masking policy can be attached to a column at a time.

### Common Questions (FAQ)
**Q: Can a masking policy change the data type of the column?**
A: No. The return type of the masking policy must match the column's data type. For example, masking a VARCHAR column must return a VARCHAR.

**Q: What is the difference between dynamic data masking and creating masked views?**
A: Dynamic masking is centralized (policy attached to column, applies everywhere) and role-aware. Masked views require creating and maintaining separate view objects and do not automatically adapt to the querying role.

### Example Scenario Questions
**Scenario:** A company has a customers table with an email column. The analytics team should see full emails, but the marketing team should only see the domain (e.g., "***@company.com"). Both teams query the same table. How do you implement this?
**Answer:** Create a masking policy that returns the full email when IS_ROLE_IN_SESSION('ANALYTICS_ROLE') is true, and returns a masked version (CONCAT('***@', SPLIT_PART(val, '@', 2))) otherwise. Attach the policy to the email column.

---

## 4.4 Row Access Policies

### Key Concepts
- **Row Access Policies (RAP)** filter rows at query time based on the querying role or user context
- **Policy returns a boolean:** Rows where the policy returns TRUE are visible; FALSE rows are hidden
- **One RAP per table/view** -- a table or view can have only one row access policy at a time
- **Mapping table pattern:** Use a separate mapping table to define which roles can see which rows (e.g., region-role mapping)
- **RAP is evaluated before masking policies** -- if a row is filtered out, masking never applies to it
- **Cannot be applied to system tables or materialized views**

### Why This Matters
Row access policies enable multi-tenant data architectures where different teams see different subsets of the same table without maintaining separate filtered views or tables.

### Best Practices
- Use a mapping table to externalize access rules instead of hardcoding roles in the policy
- Keep RAP logic simple to avoid performance degradation (complex subqueries slow every query)
- Test RAPs with all consumer roles to verify correct filtering
- Monitor query performance after applying RAPs -- complex policies add query overhead

**Exam trap:** IF YOU SEE "Row access policies and masking policies cannot coexist on the same table" -> WRONG because they serve different purposes (row filtering vs column masking) and can be applied together.

**Exam trap:** IF YOU SEE "Row access policies are applied after masking" -> WRONG because RAPs are evaluated before masking policies.

### Common Questions (FAQ)
**Q: Can you apply a RAP and a masking policy to the same table?**
A: Yes. RAP filters rows first, then masking transforms visible column values.

**Q: Does a RAP affect the table owner?**
A: Yes, unless the policy explicitly exempts the owner role. RAPs apply to all roles including the owner.

### Example Scenario Questions
**Scenario:** A global company stores all regional sales data in one table. Each regional manager should only see their region's data. New regions are added frequently. What approach scales best?
**Answer:** Create a mapping table (role_name, region). Create a row access policy that joins against the mapping table using IS_ROLE_IN_SESSION(). When a new region is added, just insert a row into the mapping table -- no policy changes needed.

---

## 4.5 Object Tagging and Data Classification

### Key Concepts
- **Tags** are key-value metadata objects attached to Snowflake objects (tables, columns, schemas, warehouses, etc.)
- **CREATE TAG** defines a tag; ALTER TABLE ... SET TAG attaches it to an object
- **Tag lineage/inheritance:** Tags propagate from database -> schema -> table -> column (child inherits parent's tag)
- **Tag-based masking:** Associate a masking policy with a tag. Any column bearing that tag is automatically masked
- **Data Classification** uses SYSTEM$CLASSIFY() or EXTRACT_SEMANTIC_CATEGORIES() to automatically detect PII/sensitive data
- **Classification categories:** IDENTIFIER, QUASI_IDENTIFIER, SENSITIVE, based on semantic and privacy analysis
- **ASSOCIATE_SEMANTIC_CATEGORY_TAGS** applies classification results as system tags automatically

### Why This Matters
Tagging and classification enable scalable governance. Instead of manually applying policies column by column, tags automate policy application across hundreds of tables.

### Best Practices
- Define a tag taxonomy early (e.g., PII_TYPE, DATA_SENSITIVITY, COST_CENTER)
- Use tag-based masking instead of applying masking policies to individual columns
- Run SYSTEM$CLASSIFY on new tables/schemas to auto-detect sensitive columns
- Review classification results before applying them (automated classification can have false positives)
- Use TAG_REFERENCES view to audit tag usage across the account

**Exam trap:** IF YOU SEE "Tags must be set on every column manually" -> WRONG because tags can be set at database, schema, or table level and inherit downward to columns.

**Exam trap:** IF YOU SEE "SYSTEM$CLASSIFY automatically applies masking policies" -> WRONG because SYSTEM$CLASSIFY detects and categorizes sensitive data. It tags columns but does not apply masking policies. Tag-based masking is a separate configuration.

### Common Questions (FAQ)
**Q: What is the difference between SYSTEM$CLASSIFY and EXTRACT_SEMANTIC_CATEGORIES?**
A: EXTRACT_SEMANTIC_CATEGORIES returns classification results as a VARIANT without applying tags. SYSTEM$CLASSIFY also applies the results as tags automatically.

**Q: Can you tag a warehouse?**
A: Yes. Tags can be applied to most Snowflake objects including warehouses, databases, schemas, tables, columns, users, and roles.

### Example Scenario Questions
**Scenario:** A company has 500 tables and needs to identify which columns contain PII. Manually reviewing every column is impractical. What Snowflake feature automates this?
**Answer:** Use SYSTEM$CLASSIFY on each schema. It automatically analyzes column names and sample data to detect PII categories (email, phone, SSN, etc.). Results can be applied as semantic tags, which can then drive tag-based masking policies.

---

## 4.6 Secure Views and Network Policies

### Key Concepts
- **Secure views** (CREATE SECURE VIEW) hide the view definition and prevent query optimizer from exposing underlying data through plan analysis
- Secure views are required for data sharing and recommended for any view exposing sensitive data
- **Performance trade-off:** Secure views may bypass certain optimizations because the optimizer cannot push predicates through them
- **Network policies** restrict account access by IP address (ALLOWED_IP_LIST, BLOCKED_IP_LIST)
- Network policies can be applied at the **account level** or **user level**
- **Access History** (ACCOUNT_USAGE.ACCESS_HISTORY) tracks who accessed which objects and columns, including read/write operations

### Why This Matters
Secure views are foundational for data sharing and for preventing metadata leakage. Network policies provide perimeter-level security. Access history enables compliance auditing.

### Best Practices
- Always use secure views (not regular views) in data shares
- Use secure views when view consumers should not see the view definition
- Apply network policies to restrict access from known IP ranges only
- Query ACCESS_HISTORY for compliance audits and understanding data access patterns
- Be aware that secure views may reduce query performance due to optimizer restrictions

**Exam trap:** IF YOU SEE "Regular views can be included in a share" -> WRONG because only secure views, secure materialized views, and secure UDFs can be shared.

**Exam trap:** IF YOU SEE "Secure views perform the same as regular views" -> WRONG because secure views may prevent certain optimizer optimizations (predicate pushdown), potentially reducing performance.

### Common Questions (FAQ)
**Q: Can users see the definition of a secure view?**
A: No. The definition (SQL query) of a secure view is hidden from users who do not own it.

**Q: What happens if both account-level and user-level network policies exist?**
A: The user-level network policy takes precedence. If a user has their own network policy, the account-level policy does not apply to them.

### Example Scenario Questions
**Scenario:** An analytics view joins sensitive HR data with department data. Analysts need the department aggregations but should not see individual salary records. How do you protect the data?
**Answer:** Create a SECURE VIEW that aggregates salary data by department. The secure view hides the view definition and prevents optimizer-based data exposure. Analysts query the view but cannot see or reverse-engineer individual records.

---

## CONFUSING PAIRS -- Data Governance

| They ask about... | The answer is... | NOT... |
|---|---|---|
| Column-level data transformation at query time | Masking policy | Row access policy (row filtering) |
| Row-level filtering at query time | Row access policy | Masking policy (column masking) |
| Controls which users/roles can access objects | RBAC (roles and grants) | Masking/RAP (controls what data is seen) |
| Object owner controls access | DAC (Discretionary Access Control) | RBAC (admin-assigned roles) |
| Manages users, roles, and grants | SECURITYADMIN | SYSADMIN (manages database objects) |
| Creates databases and warehouses | SYSADMIN | SECURITYADMIN (manages security) |
| Top-level account administration | ACCOUNTADMIN | SYSADMIN (does not manage billing/shares) |
| Hides view definition from consumers | Secure view | Regular view |
| Auto-detects PII in columns | SYSTEM$CLASSIFY / Data Classification | Masking policies (must be manually applied) |
| Applies masking to all columns with a tag | Tag-based masking | Column-level masking (per-column attachment) |

---

## DON'T MIX -- Data Governance

### Masking Policy vs Row Access Policy
| Aspect | Masking Policy | Row Access Policy |
|---|---|---|
| Level | Column-level | Row-level (table/view) |
| Returns | Transformed column value (same type) | Boolean (TRUE = visible, FALSE = hidden) |
| Purpose | Hide/redact sensitive column values | Filter which rows are visible |
| Limit | One per column | One per table/view |
| Evaluation order | After row access policy | Before masking policy |

**RULE:** Masking transforms what you see in a column. RAP controls which rows you see at all.
**The trap:** Both are "security policies" applied to tables. If the question asks about hiding specific values in a column, it is masking. If it asks about hiding entire rows, it is RAP.

### CURRENT_ROLE() vs IS_ROLE_IN_SESSION()
| Aspect | CURRENT_ROLE() | IS_ROLE_IN_SESSION() |
|---|---|---|
| Checks | Only the active primary role | All roles in session (primary + inherited) |
| Hierarchy-aware | No | Yes |
| Use in masking | Fragile (misses inherited roles) | Recommended (catches hierarchy) |
| Example | CURRENT_ROLE() = 'ADMIN' | IS_ROLE_IN_SESSION('ADMIN') |

**RULE:** Always prefer IS_ROLE_IN_SESSION() in security policies for hierarchy-aware evaluation.
**The trap:** CURRENT_ROLE() seems simpler but fails when a user activates a parent role that inherits the target role. IS_ROLE_IN_SESSION() handles this correctly.

### SYSADMIN vs SECURITYADMIN
| Aspect | SYSADMIN | SECURITYADMIN |
|---|---|---|
| Creates/manages | Databases, schemas, tables, warehouses | Users, roles, grants |
| Key privilege | CREATE DATABASE, CREATE WAREHOUSE | MANAGE GRANTS |
| Data access | Yes (owns database objects) | No (manages security, not data) |
| Hierarchy position | Below ACCOUNTADMIN | Below ACCOUNTADMIN, parallel to SYSADMIN |

**RULE:** If the task is creating or modifying data objects, it is SYSADMIN. If the task is managing who can access what, it is SECURITYADMIN.
**The trap:** Both are powerful roles below ACCOUNTADMIN. Questions may describe "admin" tasks ambiguously. Look for whether the action involves objects (SYSADMIN) or access (SECURITYADMIN).

### Tag-Based Masking vs Column-Level Masking
| Aspect | Tag-Based Masking | Column-Level Masking |
|---|---|---|
| Attachment | Policy attached to a tag | Policy attached directly to a column |
| Scale | Automatically applies to all tagged columns | Must be applied column by column |
| Maintenance | Change the tag, masking follows | Must update each column individually |
| Best for | Hundreds of tables with similar PII patterns | One-off columns with unique masking |

**RULE:** Tag-based masking scales. Column-level masking is precise but manual.
**The trap:** Both achieve the same result (masked data). The question will hint at scale ("500 tables", "all PII columns") for tag-based, or specificity ("this one column") for direct attachment.

---

## FLASHCARDS -- Domain 4

**Q1:** What is the difference between RBAC and DAC in Snowflake?
**A1:** RBAC: privileges are assigned to roles, roles to users. DAC: the object creator (owner) controls access. Snowflake uses both -- RBAC for assigning access, DAC for ownership control.

**Q2:** What role manages users, roles, and grants?
**A2:** SECURITYADMIN (and its child, USERADMIN for users/roles specifically). Not SYSADMIN.

**Q3:** What role should create databases and warehouses?
**A3:** SYSADMIN (or custom roles granted to SYSADMIN).

**Q4:** Why should custom roles always be granted to SYSADMIN?
**A4:** So that ACCOUNTADMIN (which inherits SYSADMIN) can manage all objects. Orphan roles outside the hierarchy are invisible to ACCOUNTADMIN.

**Q5:** What does a masking policy return?
**A5:** A value of the same data type as the input column. It transforms the column value (e.g., full email -> masked email) based on role context.

**Q6:** How many masking policies can be applied to a single column?
**A6:** One. Only one masking policy per column at a time.

**Q7:** What is the evaluation order of RAP vs masking policies?
**A7:** Row Access Policies evaluate first (filter rows), then masking policies transform visible column values.

**Q8:** What function should you use in masking policies for hierarchy-aware role checks?
**A8:** IS_ROLE_IN_SESSION(). It checks all roles (primary + inherited). CURRENT_ROLE() only checks the active primary role.

**Q9:** What does SYSTEM$CLASSIFY do?
**A9:** It automatically analyzes table columns to detect sensitive data (PII) and applies semantic category tags based on the results.

**Q10:** What is tag-based masking?
**A10:** A masking policy is associated with a tag (not a column). Any column that has that tag automatically gets the masking policy applied.

**Q11:** Why are secure views required in data sharing?
**A11:** Secure views hide the view definition and prevent query plan analysis from exposing the underlying data, which is required for data sharing security.

**Q12:** Can a row access policy and a masking policy coexist on the same table?
**A12:** Yes. RAP filters rows (applied first), then masking transforms column values of visible rows.

**Q13:** What does the PUBLIC role represent?
**A13:** PUBLIC is automatically granted to every user. Any privilege granted to PUBLIC is available to all users in the account.

**Q14:** What is the difference between EXTRACT_SEMANTIC_CATEGORIES and SYSTEM$CLASSIFY?
**A14:** EXTRACT_SEMANTIC_CATEGORIES returns classification results without applying tags. SYSTEM$CLASSIFY detects sensitive data AND applies semantic category tags.

**Q15:** What does a network policy control?
**A15:** It restricts account or user access by IP address using ALLOWED_IP_LIST and BLOCKED_IP_LIST.

**Q16:** What happens to objects when their owning role is dropped?
**A16:** Ownership transfers to the role that performed the DROP ROLE. Best practice is to transfer ownership explicitly before dropping a role.
