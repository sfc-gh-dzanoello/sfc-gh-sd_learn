"""EXAM DAY — Last-minute cheat sheet of the most confusing topics and trap patterns."""
import streamlit as st
from i18n import t

# ── Sidebar: Navigation buttons ──
_nav1, _nav2 = st.sidebar.columns(2)
with _nav1:
    if st.button(":material/home: Home", key="examday_home", use_container_width=True):
        st.session_state.app_mode = None
        st.switch_page("app_pages/landing.py")
with _nav2:
    if st.button(":material/arrow_back: Dashboard", key="examday_dash", use_container_width=True):
        st.switch_page("app_pages/dashboard.py")

active_cert = st.session_state.get("_active_cert", "core")
registry = st.session_state.get("CERT_REGISTRY", {})

st.markdown(f"""
<h1 style="margin-bottom:4px;">🚨 {t("exam_day_title")}</h1>
<p style="color:#FF6B6B; margin-top:0; font-weight:600;">{t("exam_day_subtitle")}</p>
""", unsafe_allow_html=True)

tabs = st.tabs([f"⚡ {t('tab_top_traps')}", f"🔄 {t('tab_confusing_pairs')}", f"📊 {t('tab_query_profile')}", f"📦 {t('tab_loading')}", f"🔐 {t('tab_security')}", f"🤝 {t('tab_sharing')}", f"⏰ {t('tab_time_travel')}"])

# ── TAB 1: TOP TRAPS ──
with tabs[0]:
    if active_cert == "architect":
        st.markdown(f"### 🚨 {t('traps_architect_title')}")

        traps = [
            ("Cross-region sharing requires replication first", "You must replicate the database to the target region, THEN create a share on the replica. IF YOU SEE 'share directly cross-region' → WRONG.", "#FF6B6B"),
            ("Auto-Fulfillment vs manual replication", "Auto-Fulfillment handles cross-cloud delivery automatically for Marketplace listings. Manual replication is for direct shares between known accounts. Don't confuse them.", "#E91E63"),
            ("Data Vault vs Star Schema", "Data Vault = auditability, parallel loads, evolving schemas. Star = fast BI queries, simple joins. Exam tests WHEN to recommend each. Vault ≠ always better.", "#9C27B0"),
            ("Functional roles vs Access roles", "Functional = job-based (analyst, engineer, loader). Access = object-based (read_sales, write_orders). Exam tests when to use which pattern.", "#3F51B5"),
            ("Database roles vs Account roles", "Database roles are scoped to a SINGLE database. Cannot be granted to users directly — must be granted to account roles first. IF YOU SEE 'grant database role to user' → WRONG.", "#00BCD4"),
            ("Network policies vs Network rules", "Policies = IP allow/block lists (legacy approach). Rules = new model, supports host names + service endpoints, can be applied to specific objects. Know which is newer.", "#4CAF50"),
            ("Query Acceleration Service limitations", "Only helps with large scans + selective filters (OLAP patterns). Does NOT help DML, does NOT help if bottleneck is joins or UDFs. IF YOU SEE 'QAS speeds up all queries' → WRONG.", "#FF9800"),
            ("Snowpipe vs Snowpipe Streaming", "Snowpipe = file-based (S3 event notifications → loads files). Streaming = row-based (Java/Python SDK, Kafka connector). Streaming = lower latency but requires code.", "#F44336"),
            ("Dynamic tables vs Materialized views", "DT = complex queries with joins, ALL editions, configurable target lag. MV = single-table aggregations only, Enterprise+, auto-refresh. IF YOU SEE 'MV with joins' → WRONG.", "#673AB7"),
            ("Iceberg managed vs unmanaged", "Managed = Snowflake writes Iceberg files (full control). Unmanaged = external catalog (e.g., Glue) writes files, Snowflake reads only. IF YOU SEE 'write to unmanaged Iceberg' → WRONG.", "#2196F3"),
            ("Replication vs Failover groups", "Replication = copy data to another account/region. Failover groups = replication + automatic failover for DR. Replication alone does NOT give you automatic failover.", "#009688"),
            ("Tri-Secret Secure = Business Critical+", "Customer-managed key + Snowflake key + composite key. NOT available on Standard or Enterprise. IF YOU SEE 'Tri-Secret' + 'Enterprise edition' → WRONG.", "#8BC34A"),
            ("External tokenization vs Dynamic Data Masking", "Tokenization = 3rd-party service replaces sensitive data with tokens. DDM = policy-based column masking per role. Both require Enterprise+. Don't confuse the mechanism.", "#FF5722"),
            ("SYSTEM$CLUSTERING_INFORMATION vs CLUSTERING_DEPTH", "INFORMATION = complete stats (avg depth, overlap, constant partitions). DEPTH = single numeric depth value only. Know which gives full picture vs quick check.", "#E91E63"),
            ("Search Optimization vs Clustering", "Search Optimization = point lookups (equality, IN, GEOGRAPHY). Clustering = range scans (BETWEEN, >, <). They are NOT interchangeable. Can be used together.", "#9C27B0"),
        ]
    else:
        st.markdown(f"### 🚨 {t('traps_core_title')}")

        traps = [
            ("Scale UP vs Scale OUT", "Spilling to disk = scale UP (bigger warehouse). Queries queuing = scale OUT (more clusters). NEVER the reverse.", "#FF6B6B"),
            ("Economy vs Standard scaling", "Economy = save money, waits 6 min. Standard = fast response, starts immediately. IF YOU SEE 'immediately' → Standard.", "#E91E63"),
            ("Micro-partition size", "50-500 MB UNCOMPRESSED. IF YOU SEE 'compressed' → WRONG. The word 'compressed' is the trap.", "#9C27B0"),
            ("Warehouse suspend = cache gone", "SSD cache is LOST when warehouse suspends. IF YOU SEE 'cache persists after suspend' → WRONG.", "#3F51B5"),
            ("Result cache = FREE, no warehouse", "Result cache served by Cloud Services. No warehouse needed. 24h. IF YOU SEE 'requires warehouse' → WRONG.", "#00BCD4"),
            ("Snowpark runs INSIDE warehouse", "NOT on your laptop. NOT in Cloud Services. IF YOU SEE 'client-side' or 'local execution' → WRONG.", "#4CAF50"),
            ("Cloud Services = brain, NOT executor", "Optimizer, auth, metadata, transactions. IF YOU SEE 'Cloud Services executes queries' → WRONG.", "#FF9800"),
            ("One account = one cloud provider", "Cannot span AWS + Azure. IF YOU SEE 'multi-cloud account' → WRONG. Need Organizations + separate accounts.", "#F44336"),
            ("Temporary table = SESSION-scoped, NOT connection-scoped", "Temp tables persist until the SESSION ends (4h inactivity timeout). Disconnecting does NOT terminate the session. IF YOU SEE 'dropped on disconnect' → WRONG.", "#673AB7"),
            ("Permanent table Fail-safe = ALWAYS 7 days", "You CANNOT change it. You CANNOT disable it. Only way to avoid = use Transient/Temporary.", "#2196F3"),
            ("Transient = NO Fail-safe", "Transient persists across sessions but has ZERO Fail-safe. IF YOU SEE 'Fail-safe' + 'transient' → WRONG.", "#009688"),
            ("Cannot convert table types", "Cannot ALTER transient to permanent. Must DROP and recreate. IF YOU SEE 'ALTER TABLE SET TYPE' → WRONG.", "#8BC34A"),
            ("Clustering = ALL editions", "Automatic clustering available in Standard. MULTI-CLUSTER warehouses = Enterprise+. Don't confuse them!", "#FF5722"),
            ("Materialized views = Enterprise+", "NOT available in Standard. IF YOU SEE 'Standard edition' + 'materialized view' → WRONG.", "#E91E63"),
            ("Secure views REQUIRED for sharing", "Regular views expose SQL. IF YOU SEE 'share a regular view' → WRONG.", "#9C27B0"),
            ("PUT = internal stages ONLY", "IF YOU SEE 'PUT' + 'external stage' → WRONG. For external, upload directly to S3/Azure/GCS.", "#3F51B5"),
            ("Snowpipe = serverless, NO warehouse", "Uses Cloud Services compute. IF YOU SEE 'Snowpipe requires a warehouse' → WRONG.", "#00BCD4"),
            ("Reader accounts = provider pays EVERYTHING", "Storage + compute. IF YOU SEE 'consumer pays' for reader account → WRONG.", "#4CAF50"),
            ("Clone = NO privileges copied", "Data is cloned, privileges are NOT. IF YOU SEE 'clone inherits privileges' → WRONG (except DB/schema child objects).", "#FF9800"),
            ("Hybrid tables = ENFORCED constraints", "Regular tables = informational only. IF YOU SEE 'enforced primary key' → Hybrid Table.", "#F44336"),
        ]

    for title, desc, color in traps:
        st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-left:6px solid '
f'{color};border-radius:8px;padding:12px 16px;margin:8px 0;'
'box-shadow:0 1px 4px rgba(0,0,0,0.08);">'
f'<strong style="color:{color};font-size:1rem;">{title}</strong><br>'
f'<span style="color:inherit;font-size:0.9rem;">{desc}</span>'
'</div>', unsafe_allow_html=True)

# ── TAB 2: CONFUSING PAIRS ──
with tabs[1]:
    if active_cert == "architect":
        st.markdown(f"### 🔄 {t('confusing_pairs_architect')}")

        pairs = [
            ("Data Vault vs Star Schema", "Data Vault = hub/link/satellite, auditability, parallel ETL, evolving schemas, historized by default", "Star Schema = fact/dimension, fast BI queries, simple joins, denormalized, easier for analysts", "#E91E63"),
            ("Functional Roles vs Access Roles", "Functional = job-based (DATA_ENGINEER, ANALYST). Assigned to people by job title", "Access = object-based (READ_SALES, WRITE_ORDERS). Granted to functional roles. Composable.", "#9C27B0"),
            ("Database Roles vs Account Roles", "Database roles = scoped to ONE database, portable with shares, cannot be granted to users directly", "Account roles = global scope, granted to users, can hold database roles", "#3F51B5"),
            ("Snowpipe vs Snowpipe Streaming", "Snowpipe = file-based ingestion, S3 event notifications, serverless, micro-batch loads", "Snowpipe Streaming = row-based via SDK (Java/Python), sub-second latency, requires code", "#00BCD4"),
            ("External Tables vs Iceberg Tables", "External = Snowflake-proprietary metadata, read-only, only Snowflake queries it", "Iceberg = Apache open format, read/write (if managed), Spark/Flink/Snowflake interop", "#4CAF50"),
            ("Managed Iceberg vs Unmanaged Iceberg", "Managed = Snowflake owns the catalog + writes Iceberg files, full DML support", "Unmanaged = external catalog (Glue, etc.) writes, Snowflake reads only, no DML from SF", "#FF9800"),
            ("Replication vs Failover Groups", "Replication = copy database/share objects to another region/account, manual promotion", "Failover Groups = replication + automatic failover + client redirect for DR", "#F44336"),
            ("Network Policies vs Network Rules", "Network Policies = IP allow/block lists, account or user level, legacy approach", "Network Rules = new model, supports hostnames + service endpoints, object-level granularity", "#673AB7"),
            ("Cross-region Sharing vs Auto-Fulfillment", "Cross-region sharing = manual: replicate DB → create share on replica → consumer accesses", "Auto-Fulfillment = automatic: Marketplace listing → Snowflake handles cross-cloud delivery", "#2196F3"),
            ("Dynamic Tables vs Materialized Views", "Dynamic Tables = complex queries (joins, subqueries), ALL editions, configurable target lag", "Materialized Views = single-table aggregations, Enterprise+, automatic refresh, no joins", "#009688"),
        ]
    else:
        st.markdown(f"### 🔄 {t('confusing_pairs_core')}")

        pairs = [
            ("Clustering vs Multi-cluster", "Clustering = how DATA is organized in micro-partitions (ALL editions)", "Multi-cluster = how WAREHOUSES scale out with more clusters (Enterprise+)", "#E91E63"),
            ("Scale UP vs Scale OUT", "UP = bigger warehouse size (1 query faster, fixes spilling)", "OUT = more clusters (many users, fixes queuing)", "#9C27B0"),
            ("Result Cache vs Warehouse Cache", "Result cache = exact same query, 24h, FREE, Cloud Services", "Warehouse cache = SSD on warehouse nodes, LOST on suspend", "#3F51B5"),
            ("ACCOUNT_USAGE vs INFORMATION_SCHEMA", "ACCOUNT_USAGE = 45min-3h latency, 365 days history, in SNOWFLAKE database", "INFORMATION_SCHEMA = real-time, 7 days to 6 months retention, per-database", "#00BCD4"),
            ("Transient vs Temporary", "Transient = persists across sessions, visible to others, no Fail-safe", "Temporary = session-only, invisible to others, dropped when session ends (NOT on disconnect)", "#4CAF50"),
            ("External Table vs Iceberg Table", "External = Snowflake metadata format, only Snowflake reads it", "Iceberg = Apache open format, Spark/Flink/Snowflake all read it", "#FF9800"),
            ("Dynamic Table vs Materialized View", "Dynamic = complex queries (joins, subqueries), target lag, ALL editions", "Materialized View = single-table only, Enterprise+, auto-refreshed", "#F44336"),
            ("Stored Procedure vs UDF", "Procedure = CALL to execute, can do DDL/DML, doesn't return in SELECT", "UDF = used IN SELECT/WHERE, returns a value, cannot do DDL", "#673AB7"),
            ("COPY INTO vs Snowpipe", "COPY INTO = batch, needs warehouse, manual/scheduled trigger", "Snowpipe = continuous, serverless (Cloud Services), event-driven (S3 notification)", "#2196F3"),
            ("SECURITYADMIN vs USERADMIN", "SECURITYADMIN = manages GRANTS and network policies", "USERADMIN = creates USERS and ROLES", "#009688"),
            ("Time Travel vs Fail-safe", "Time Travel = YOU control (0-90 days depending on edition). YOU recover with SQL", "Fail-safe = Snowflake controls (always 7 days), only SUPPORT can recover", "#8BC34A"),
            ("Shares vs Replication", "Share = real-time read-only access, same region, no data copy", "Replication = full database copy to another region/account, for DR", "#FF5722"),
        ]

    for title, desc1, desc2, color in pairs:
        st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-radius:12px;padding:16px;'
f'margin:10px 0;border:2px solid {color};box-shadow:0 2px 6px rgba(0,0,0,0.06);">'
f'<h4 style="color:{color};margin:0 0 8px;">{title}</h4>'
'<div style="display:flex;gap:12px;">'
'<div style="flex:1;background:rgba(76,175,80,0.1);border-radius:8px;padding:10px;border-left:3px solid #4CAF50;">'
f'<span style="color:inherit;font-size:0.88rem;">{desc1}</span></div>'
'<div style="flex:1;background:rgba(244,67,54,0.1);border-radius:8px;padding:10px;border-left:3px solid #F44336;">'
f'<span style="color:inherit;font-size:0.88rem;">{desc2}</span></div>'
'</div></div>', unsafe_allow_html=True)

# ── TAB 3: QUERY PROFILE ──
with tabs[2]:
    st.markdown("### 📊 Query Profile — What It Shows vs What It Doesn't")

    st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-radius:12px;padding:18px;'
'margin:10px 0;border-left:6px solid #3F51B5;">'
'<h4 style="color:#3F51B5;">Query Profile DOES show:</h4>'
'<ul style="color:inherit;">'
'<li><strong style="color:#4CAF50;">Data spilling</strong> to local or remote disk (memory overflow)</li>'
'<li><strong style="color:#4CAF50;">Inefficient micro-partition pruning</strong> (scanning too many partitions)</li>'
'<li>Operator statistics (bytes scanned, rows produced)</li>'
'<li>Execution tree (which operators ran and how long each took)</li>'
'<li>Join explosion or cartesian products</li></ul>'
'<h4 style="color:#F44336;margin-top:16px;">Query Profile does NOT show:</h4>'
'<ul style="color:inherit;">'
'<li><strong style="color:#F44336;">Logical issues with queries</strong> (it shows WHAT happened, not if your logic is correct)</li>'
'<li><strong style="color:#F44336;">Future predictions</strong> (it can\'t tell you a query will be slow BEFORE you run it)</li>'
'<li><strong style="color:#F44336;">Credit consumption per query</strong> (use QUERY_HISTORY for that)</li></ul>'
'<div style="background:rgba(244,67,54,0.08);border-left:4px solid #F44336;padding:10px;margin-top:12px;border-radius:4px;color:inherit;">'
'<strong>YOUR QUESTION:</strong> "What are common issues found by using the Query Profile? (Choose two.)"<br>'
'&#x2705; Data spilling to local or remote disk<br>'
'&#x2705; Identifying inefficient micro-partition pruning<br>'
'&#x274C; "Identifying logical issues" &#x2192; WRONG, QP shows execution stats, not logic errors<br>'
'&#x274C; "Identifying queries that will run slowly before executing" &#x2192; WRONG, QP is POST-execution analysis<br>'
'&#x274C; "Locating queries that consume high credits" &#x2192; WRONG, use QUERY_HISTORY or resource monitors for credits'
'</div></div>', unsafe_allow_html=True)

    st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-radius:12px;padding:18px;'
'margin:10px 0;border-left:6px solid #FF9800;">'
'<h4 style="color:#FF9800;">Memory trick: Query Profile = X-RAY of a query AFTER it ran</h4>'
'<p style="color:inherit;">It\'s like a doctor\'s X-ray &#x2014; it shows what happened inside, '
'but it can\'t predict the future or tell you if your treatment plan (query logic) makes sense.</p>'
'</div>', unsafe_allow_html=True)

# ── TAB 4: LOADING ──
with tabs[3]:
    st.markdown("### 📦 Data Loading — When to Use What")

    st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-radius:12px;padding:18px;'
'margin:10px 0;border-left:6px solid #4CAF50;">'
'<h4 style="color:#4CAF50;">Decision tree:</h4>'
'<p style="color:inherit;">'
'Need data within <strong>1 minute</strong>? &#x2192; <strong style="color:#4CAF50;">Snowpipe</strong> (serverless, event-driven)<br>'
'Loading <strong>large batches on schedule</strong>? &#x2192; <strong style="color:#3F51B5;">COPY INTO</strong> (needs warehouse)<br>'
'Want <strong>auto-refreshing table</strong>? &#x2192; <strong style="color:#FF9800;">Dynamic Table</strong> (target lag)<br>'
'Need <strong>continuous CDC tracking</strong>? &#x2192; <strong style="color:#9C27B0;">Streams + Tasks</strong><br></p>'
'<h4 style="color:#F44336;margin-top:12px;">Common traps:</h4>'
'<ul style="color:inherit;">'
'<li>"Snowpipe requires a warehouse" &#x2192; <strong>WRONG</strong>. Serverless (Cloud Services compute)</li>'
'<li>"PUT works with external stages" &#x2192; <strong>WRONG</strong>. PUT = internal ONLY</li>'
'<li>"COPY INTO is continuous loading" &#x2192; <strong>WRONG</strong>. COPY INTO = batch. Snowpipe = continuous</li>'
'<li>"Snowpipe is cheaper for large one-time loads" &#x2192; <strong>WRONG</strong>. Use COPY INTO for bulk batch (cheaper for large files)</li>'
'<li>"Streams modify the source table" &#x2192; <strong>WRONG</strong>. Streams are read-only trackers</li>'
'</ul></div>', unsafe_allow_html=True)

    st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-radius:12px;padding:18px;'
'margin:10px 0;border-left:6px solid #9C27B0;">'
'<h4 style="color:#9C27B0;">Stage types &#x2014; don\'t mix them up!</h4>'
'<table style="width:100%;border-collapse:collapse;font-size:0.9rem;">'
'<tr><th style="background:#9C27B0;color:white;padding:8px;">Stage</th><th style="background:#9C27B0;color:white;padding:8px;">Symbol</th><th style="background:#9C27B0;color:white;padding:8px;">Scope</th></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">User stage</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">@~</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Per user, automatic</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Table stage</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">@%table_name</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Per table, automatic</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Named internal</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">@my_stage</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Created by user</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Named external</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">@my_ext_stage</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Points to S3/Azure/GCS</td></tr>'
'</table></div>', unsafe_allow_html=True)

# ── TAB 5: SECURITY ──
with tabs[4]:
    st.markdown("### 🔐 Security — Role Confusion Solved")

    st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-radius:12px;padding:18px;'
'margin:10px 0;border-left:6px solid #F44336;">'
'<h4 style="color:#F44336;">Who does what? (The #1 confusion topic)</h4>'
'<table style="width:100%;border-collapse:collapse;font-size:0.9rem;">'
'<tr><th style="background:#F44336;color:white;padding:8px;">Role</th><th style="background:#F44336;color:white;padding:8px;">Creates</th><th style="background:#F44336;color:white;padding:8px;">Manages</th></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;"><strong>ACCOUNTADMIN</strong></td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Shares, resource monitors</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Everything (= SECURITYADMIN + SYSADMIN)</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;"><strong>SECURITYADMIN</strong></td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Network policies</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">GRANTS (MANAGE GRANTS privilege)</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;"><strong>USERADMIN</strong></td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Users and roles</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Users and roles only</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;"><strong>SYSADMIN</strong></td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Warehouses, databases</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">All data objects</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;"><strong>ORGADMIN</strong></td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Accounts</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Organization-level operations</td></tr>'
'</table>'
'<div style="background:rgba(244,67,54,0.08);border-left:4px solid #F44336;padding:10px;margin-top:12px;border-radius:4px;color:inherit;">'
'<strong>TRAP:</strong> "SECURITYADMIN creates users" &#x2192; WRONG! USERADMIN creates users.<br>'
'<strong>TRAP:</strong> "SYSADMIN manages grants" &#x2192; WRONG! SECURITYADMIN has MANAGE GRANTS.<br>'
'<strong>TRAP:</strong> "USERADMIN manages network policies" &#x2192; WRONG! SECURITYADMIN manages network policies.'
'</div></div>', unsafe_allow_html=True)

# ── TAB 6: SHARING ──
with tabs[5]:
    st.markdown("### 🤝 Data Sharing — Who Pays What")

    st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-radius:12px;padding:18px;'
'margin:10px 0;border-left:6px solid #00BCD4;">'
'<h4 style="color:#00BCD4;">The billing rule:</h4>'
'<table style="width:100%;border-collapse:collapse;font-size:0.9rem;">'
'<tr><th style="background:#00BCD4;color:white;padding:8px;">Scenario</th><th style="background:#00BCD4;color:white;padding:8px;">Storage</th><th style="background:#00BCD4;color:white;padding:8px;">Compute</th></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Normal sharing</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:#1a1a2e;background:#E8F5E9;">Provider pays</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:#1a1a2e;background:#E3F2FD;">Consumer pays (own WH)</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Reader account</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:#1a1a2e;background:#FFEBEE;">Provider pays</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:#1a1a2e;background:#FFEBEE;">Provider pays EVERYTHING</td></tr>'
'</table>'
'<div style="background:rgba(244,67,54,0.08);border-left:4px solid #F44336;padding:10px;margin-top:12px;border-radius:4px;color:inherit;">'
'<strong>TRAP:</strong> "Consumer pays for storage in sharing" &#x2192; WRONG! Provider always pays storage.<br>'
'<strong>TRAP:</strong> "Reader accounts can do DML (INSERT/UPDATE)" &#x2192; WRONG! Reader = READ-ONLY.<br>'
'<strong>TRAP:</strong> "Regular views can be shared" &#x2192; WRONG! Only SECURE views.<br>'
'<strong>TRAP:</strong> "Cross-region sharing works directly" &#x2192; WRONG! Replicate database first.'
'</div></div>', unsafe_allow_html=True)

# ── TAB 7: TIME TRAVEL ──
with tabs[6]:
    st.markdown("### ⏰ Time Travel & Fail-safe — The Rules")

    st.markdown(
'<div style="background:rgba(128,128,128,0.06);border-radius:12px;padding:18px;'
'margin:10px 0;border-left:6px solid #FF9800;">'
'<table style="width:100%;border-collapse:collapse;font-size:0.9rem;">'
'<tr><th style="background:#FF9800;color:white;padding:8px;">Table Type</th><th style="background:#FF9800;color:white;padding:8px;">Time Travel</th><th style="background:#FF9800;color:white;padding:8px;">Fail-safe</th><th style="background:#FF9800;color:white;padding:8px;">Who recovers</th></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Permanent (Standard)</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">0-1 day</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">7 days</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">TT=you, FS=Snowflake support</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Permanent (Enterprise+)</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">0-90 days</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">7 days</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">TT=you, FS=Snowflake support</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Transient</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">0-1 day</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:#1a1a2e;background:#FFEBEE;"><strong>NONE</strong></td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">TT=you only</td></tr>'
'<tr><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">Temporary</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">0-1 day</td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:#1a1a2e;background:#FFEBEE;"><strong>NONE</strong></td><td style="padding:6px;border:1px solid rgba(128,128,128,0.3);color:inherit;">TT=you only (if session alive)</td></tr>'
'</table>'
'<div style="background:rgba(244,67,54,0.08);border-left:4px solid #F44336;padding:10px;margin-top:12px;border-radius:4px;color:inherit;">'
'<strong>GOLDEN RULES:</strong><br>'
'1. YOU control Time Travel (0-90 days depending on edition). SNOWFLAKE controls Fail-safe (always 7, always support-only).<br>'
'2. Fail-safe = ALWAYS 7 days for permanent. You CANNOT change it, disable it, or access it yourself.<br>'
'3. Only way to avoid Fail-safe cost = use Transient or Temporary tables.<br>'
'4. AT = data at that moment. BEFORE = data just before a statement ran. Don\'t mix them up!'
'</div></div>', unsafe_allow_html=True)

st.markdown("---")
st.markdown(
'<div style="background:rgba(78,203,113,0.15);border:2px solid #4ECB71;border-radius:12px;'
'padding:20px;text-align:center;margin:20px 0;">'
'<span style="font-size:2rem;">&#x1F340;</span><br>'
f'<strong style="color:#4ECB71;font-size:1.2rem;">{t("you_got_this")}</strong><br>'
f'<span style="color:#9CA3AF;">{t("read_last_sentence")}</span>'
'</div>', unsafe_allow_html=True)
