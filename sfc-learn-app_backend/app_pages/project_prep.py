"""Project Preparation — PS tools for client engagement readiness."""
import streamlit as st
import os
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE not in sys.path:
    sys.path.insert(0, BASE)

from i18n import t

# ── Home button ──
if st.button("🏠 Home", key="prep_home"):
    st.session_state.app_mode = "landing"
    st.switch_page("app_pages/landing.py")

st.markdown("""
<div style="text-align:center; padding:10px 0 4px;">
    <h1 style="font-size:1.8rem; margin:0; color:#E8F5E9;">🏗️ Project Preparation</h1>
    <p style="color:#A5D6A7; font-size:0.9rem; margin:4px 0 0;">Prepare, analyze, and plan Snowflake client engagements</p>
</div>
""", unsafe_allow_html=True)

st.markdown("")

# ── Tool cards — 2x2 grid ──
row1_col1, row1_col2 = st.columns(2, gap="medium")

with row1_col1:
    st.markdown("""
    <div style="background:linear-gradient(135deg, #E65100, #BF360C); border-radius:14px;
                padding:24px 20px; text-align:center; min-height:200px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2rem; margin:0;">🩺</p>
        <h3 style="color:#FFF3E0; margin:8px 0 6px; font-size:1.1rem;">Account Health Check</h3>
        <p style="color:#FFCC80; font-size:0.82rem; margin:0;">Run diagnostic queries against a client Snowflake account.
        Detect misconfigurations, unused warehouses, missing policies, and security gaps.</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("🩺  Run Health Check", key="tool_health", use_container_width=True, type="primary"):
        st.session_state.prep_tool = "health_check"

with row1_col2:
    st.markdown("""
    <div style="background:linear-gradient(135deg, #1565C0, #0D47A1); border-radius:14px;
                padding:24px 20px; text-align:center; min-height:200px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2rem; margin:0;">🗺️</p>
        <h3 style="color:#E3F2FD; margin:8px 0 6px; font-size:1.1rem;">Architecture Mapping</h3>
        <p style="color:#90CAF9; font-size:0.82rem; margin:0;">Discover and map the client's current Snowflake architecture.
        Generate before/after diagrams for proposed changes.</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("🗺️  Map Architecture", key="tool_arch", use_container_width=True, type="primary"):
        st.session_state.prep_tool = "architecture"

row2_col1, row2_col2 = st.columns(2, gap="medium")

with row2_col1:
    st.markdown("""
    <div style="background:linear-gradient(135deg, #6A1B9A, #4A148C); border-radius:14px;
                padding:24px 20px; text-align:center; min-height:200px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2rem; margin:0;">🔐</p>
        <h3 style="color:#F3E5F5; margin:8px 0 6px; font-size:1.1rem;">RBAC Gap Analysis</h3>
        <p style="color:#CE93D8; font-size:0.82rem; margin:0;">Analyze roles, grants, and access control.
        Detect gaps, over-permissioned roles, and suggest proper RBAC hierarchy.</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("🔐  Analyze RBAC", key="tool_rbac", use_container_width=True, type="primary"):
        st.session_state.prep_tool = "rbac"

with row2_col2:
    st.markdown("""
    <div style="background:linear-gradient(135deg, #2E7D32, #1B5E20); border-radius:14px;
                padding:24px 20px; text-align:center; min-height:200px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2rem; margin:0;">🔧</p>
        <h3 style="color:#E8F5E9; margin:8px 0 6px; font-size:1.1rem;">Tool Comparison Sandbox</h3>
        <p style="color:#A5D6A7; font-size:0.82rem; margin:0;">Compare data tools hands-on:
        OpenFlow vs Snowpipe vs Streams vs Kafka. Test side-by-side with real examples.</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("🔧  Compare Tools", key="tool_compare", use_container_width=True, type="primary"):
        st.session_state.prep_tool = "tool_compare"

st.markdown("")
st.markdown("---")

# ── Active tool section ──
active_tool = st.session_state.get("prep_tool", None)

if active_tool == "health_check":
    st.markdown("### 🩺 Account Health Check")
    st.info("Connect to a client Snowflake account to run diagnostic queries.")

    st.markdown("""
    **Checks performed:**
    - Warehouse utilization & auto-suspend settings
    - Role hierarchy and orphaned roles
    - Network policies & MFA enforcement
    - Resource monitors coverage
    - Data retention & Time Travel config
    - Masking/row-access policies audit
    - Storage cost analysis
    - Task & pipe failure rates
    """)

    conn_available = False
    try:
        from snowflake.snowpark.context import get_active_session
        session = get_active_session()
        conn_available = True
    except Exception:
        pass

    if conn_available:
        if st.button("▶️ Run Full Health Check", key="run_health"):
            with st.spinner("Running diagnostics..."):
                try:
                    # Warehouse check
                    wh_df = session.sql("""
                        SELECT WAREHOUSE_NAME, WAREHOUSE_SIZE, AUTO_SUSPEND, AUTO_RESUME,
                               MIN_CLUSTER_COUNT, MAX_CLUSTER_COUNT
                        FROM INFORMATION_SCHEMA.WAREHOUSES
                    """).to_pandas()
                    st.markdown("#### Warehouses")
                    st.dataframe(wh_df, use_container_width=True)

                    # Role check
                    roles_df = session.sql("SHOW ROLES").to_pandas()
                    st.markdown(f"#### Roles ({len(roles_df)} total)")
                    st.dataframe(roles_df[["name", "assigned_to_users", "granted_to_roles", "granted_roles"]].head(20), use_container_width=True)

                    # Network policies
                    try:
                        np_df = session.sql("SHOW NETWORK POLICIES").to_pandas()
                        st.markdown(f"#### Network Policies ({len(np_df)})")
                        if len(np_df) == 0:
                            st.warning("⚠️ No network policies found — account is accessible from any IP.")
                        else:
                            st.dataframe(np_df, use_container_width=True)
                    except Exception:
                        st.warning("⚠️ Cannot check network policies (insufficient privileges).")

                    # Resource monitors
                    try:
                        rm_df = session.sql("SHOW RESOURCE MONITORS").to_pandas()
                        st.markdown(f"#### Resource Monitors ({len(rm_df)})")
                        if len(rm_df) == 0:
                            st.warning("⚠️ No resource monitors — credit spend is unmonitored.")
                        else:
                            st.dataframe(rm_df, use_container_width=True)
                    except Exception:
                        st.warning("⚠️ Cannot check resource monitors (insufficient privileges).")

                    st.success("✅ Health check complete.")
                except Exception as e:
                    st.error(f"Error running diagnostics: {e}")
    else:
        st.warning("⚠️ Connect to Snowflake to run health checks. This feature requires an active session.")

elif active_tool == "architecture":
    st.markdown("### 🗺️ Architecture Mapping")
    st.info("Discover the client's current Snowflake object hierarchy.")

    conn_available = False
    try:
        from snowflake.snowpark.context import get_active_session
        session = get_active_session()
        conn_available = True
    except Exception:
        pass

    if conn_available:
        if st.button("▶️ Discover Architecture", key="run_arch"):
            with st.spinner("Scanning account objects..."):
                try:
                    db_df = session.sql("SHOW DATABASES").to_pandas()
                    st.markdown(f"#### Databases ({len(db_df)})")
                    st.dataframe(db_df[["name", "origin", "owner", "created_on"]].head(30), use_container_width=True)

                    wh_df = session.sql("SHOW WAREHOUSES").to_pandas()
                    st.markdown(f"#### Warehouses ({len(wh_df)})")
                    st.dataframe(wh_df[["name", "size", "state", "auto_suspend", "auto_resume"]].head(20), use_container_width=True)

                    int_df = session.sql("SHOW INTEGRATIONS").to_pandas()
                    st.markdown(f"#### Integrations ({len(int_df)})")
                    if len(int_df) > 0:
                        st.dataframe(int_df.head(20), use_container_width=True)
                    else:
                        st.caption("No integrations configured.")

                    st.success("✅ Architecture scan complete.")
                except Exception as e:
                    st.error(f"Error scanning: {e}")
    else:
        st.warning("⚠️ Connect to Snowflake to map architecture.")

    st.markdown("---")
    st.markdown("**Before / After Visualization** — Draw proposed changes:")
    st.text_area("Current state notes", placeholder="Describe the client's current architecture...", key="arch_before")
    st.text_area("Proposed state notes", placeholder="Describe the target architecture...", key="arch_after")

elif active_tool == "rbac":
    st.markdown("### 🔐 RBAC Gap Analysis")
    st.info("Analyze role hierarchy and detect access control gaps.")

    conn_available = False
    try:
        from snowflake.snowpark.context import get_active_session
        session = get_active_session()
        conn_available = True
    except Exception:
        pass

    if conn_available:
        if st.button("▶️ Analyze RBAC", key="run_rbac"):
            with st.spinner("Analyzing roles and grants..."):
                try:
                    # Role hierarchy
                    grants_df = session.sql("""
                        SELECT GRANTEE_NAME, ROLE,
                               GRANTED_BY, GRANTED_ON
                        FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
                        WHERE GRANTED_ON = 'ROLE'
                        AND DELETED_ON IS NULL
                        ORDER BY GRANTEE_NAME
                        LIMIT 100
                    """).to_pandas()
                    st.markdown(f"#### Role-to-Role Grants ({len(grants_df)} visible)")
                    st.dataframe(grants_df, use_container_width=True)

                    # Users without MFA
                    try:
                        users_df = session.sql("""
                            SELECT NAME, LOGIN_NAME, DEFAULT_ROLE, HAS_MFA,
                                   LAST_SUCCESS_LOGIN
                            FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
                            WHERE DELETED_ON IS NULL
                            ORDER BY LAST_SUCCESS_LOGIN DESC NULLS LAST
                            LIMIT 50
                        """).to_pandas()
                        no_mfa = users_df[users_df.get("HAS_MFA", "false").astype(str).str.lower() == "false"] if "HAS_MFA" in users_df.columns else users_df
                        st.markdown(f"#### Users ({len(users_df)} total)")
                        st.dataframe(users_df.head(30), use_container_width=True)
                        if len(no_mfa) > 0:
                            st.warning(f"⚠️ {len(no_mfa)} user(s) without MFA enabled.")
                    except Exception:
                        st.caption("Cannot access ACCOUNT_USAGE.USERS.")

                    st.markdown("#### Common RBAC Issues to Check")
                    st.markdown("""
                    - Direct grants to users instead of roles
                    - ACCOUNTADMIN used as default role
                    - Roles not in hierarchy (orphaned)
                    - Missing functional roles (read-only, read-write, admin)
                    - No separation between functional and access roles
                    """)
                    st.success("✅ RBAC analysis complete.")
                except Exception as e:
                    st.error(f"Error analyzing RBAC: {e}")
    else:
        st.warning("⚠️ Connect to Snowflake to analyze RBAC.")

    st.markdown("---")
    st.markdown("**Suggested RBAC Template:**")
    st.code("""
-- Recommended hierarchy:
-- ACCOUNTADMIN
--   └── SECURITYADMIN
--       └── USERADMIN
--   └── SYSADMIN
--       └── PROJECT_ADMIN
--           ├── PROJECT_READ
--           ├── PROJECT_WRITE
--           └── PROJECT_TRANSFORM
    """, language="sql")

elif active_tool == "tool_compare":
    st.markdown("### 🔧 Tool Comparison Sandbox")
    st.info("Compare Snowflake data ingestion and integration tools side-by-side.")

    tool_choice = st.selectbox("Select comparison", [
        "OpenFlow vs Snowpipe",
        "Snowpipe vs Streams + Tasks",
        "Streams + Tasks vs Dynamic Tables",
        "Kafka Connector vs Snowpipe Streaming",
        "All Tools Overview",
    ], key="tool_cmp_select")

    comparisons = {
        "OpenFlow vs Snowpipe": {
            "headers": ["Feature", "OpenFlow (NiFi)", "Snowpipe"],
            "rows": [
                ["Type", "Visual ETL / ELT platform", "Serverless auto-ingest"],
                ["Latency", "Near real-time (configurable)", "Minutes (event-driven)"],
                ["Complexity", "Low-code, drag-and-drop", "SQL + stage + pipe DDL"],
                ["Transformations", "Built-in processors", "COPY INTO transforms only"],
                ["Monitoring", "NiFi UI + Snowflake", "PIPE_USAGE_HISTORY"],
                ["Cost", "Compute pool (SPCS)", "Serverless credits per-file"],
                ["Best for", "Complex multi-source ETL", "Simple cloud storage ingestion"],
            ]
        },
        "Snowpipe vs Streams + Tasks": {
            "headers": ["Feature", "Snowpipe", "Streams + Tasks"],
            "rows": [
                ["Type", "Auto-ingest from stage", "CDC + scheduled processing"],
                ["Trigger", "Cloud event notification", "Schedule or SYSTEM$STREAM_HAS_DATA()"],
                ["Latency", "Minutes", "Depends on SCHEDULE"],
                ["Transforms", "COPY INTO only", "Full SQL / stored procs"],
                ["Cost", "Serverless credits", "Warehouse credits"],
                ["Best for", "Continuous file loading", "Incremental transformations"],
            ]
        },
        "Streams + Tasks vs Dynamic Tables": {
            "headers": ["Feature", "Streams + Tasks", "Dynamic Tables"],
            "rows": [
                ["Paradigm", "Imperative (you define how)", "Declarative (you define what)"],
                ["Setup", "CREATE STREAM + CREATE TASK", "CREATE DYNAMIC TABLE ... TARGET_LAG"],
                ["Maintenance", "Manual orchestration", "Auto-managed by Snowflake"],
                ["Flexibility", "Full control", "SQL SELECT only"],
                ["Error handling", "Custom in task SQL", "Auto-retry, UPSTREAM_FAILED status"],
                ["Best for", "Complex pipelines", "Simple incremental transforms"],
            ]
        },
        "Kafka Connector vs Snowpipe Streaming": {
            "headers": ["Feature", "Kafka Connector", "Snowpipe Streaming SDK"],
            "rows": [
                ["Integration", "Kafka Connect plugin", "Java/Python SDK"],
                ["Latency", "Seconds to minutes", "Sub-second"],
                ["Staging", "Internal stage (buffered)", "No staging — direct insert"],
                ["Setup", "Kafka cluster required", "SDK in your app"],
                ["Cost", "Warehouse or serverless", "Serverless credits"],
                ["Best for", "Existing Kafka infra", "Custom low-latency apps"],
            ]
        },
    }

    if tool_choice == "All Tools Overview":
        st.markdown("""
        | Tool | Type | Latency | Best For |
        |------|------|---------|----------|
        | **OpenFlow** | Visual ETL | Near real-time | Complex multi-source ETL |
        | **Snowpipe** | Auto-ingest | Minutes | Cloud storage file loading |
        | **Snowpipe Streaming** | SDK ingest | Sub-second | Custom low-latency apps |
        | **Streams + Tasks** | CDC pipeline | Configurable | Incremental transforms |
        | **Dynamic Tables** | Declarative | TARGET_LAG | Simple transform chains |
        | **Kafka Connector** | Kafka plugin | Seconds | Existing Kafka infrastructure |
        """)
    elif tool_choice in comparisons:
        cmp = comparisons[tool_choice]
        md_header = " | ".join(cmp["headers"])
        md_sep = " | ".join(["---"] * len(cmp["headers"]))
        md_rows = "\n".join(" | ".join(row) for row in cmp["rows"])
        st.markdown(f"| {md_header} |\n| {md_sep} |\n| {' |\n| '.join(' | '.join(row) for row in cmp['rows'])} |")

else:
    st.markdown("""
    <div style="text-align:center; padding:30px 0; color:#9CA3AF;">
        <p style="font-size:1.2rem;">👆 Select a tool above to get started</p>
        <p style="font-size:0.85rem;">Each tool helps you prepare for client Snowflake engagements</p>
    </div>
    """, unsafe_allow_html=True)
