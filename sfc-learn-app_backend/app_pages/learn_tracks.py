"""Project Preparation — PS tools for client engagement readiness."""
import streamlit as st
import os
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE not in sys.path:
    sys.path.insert(0, BASE)

from i18n import t
from theme import T

st.markdown("""
<div style="text-align:center; padding:10px 0 4px;">
    <h1 style="font-size:1.8rem; margin:0; color:#E8F5E9;">Project Preparation</h1>
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
        <p style="font-size:2rem; margin:0;">&#x1FA7A;</p>
        <h3 style="color:#FFF3E0; margin:8px 0 6px; font-size:1.1rem;">Account Health Check</h3>
        <p style="color:#FFCC80; font-size:0.82rem; margin:0;">Run diagnostic queries against a client Snowflake account.
        Detect misconfigurations, unused warehouses, missing policies, and security gaps.</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("Run Health Check", key="tool_health", use_container_width=True, type="primary"):
        st.session_state.prep_tool = "health_check"

with row1_col2:
    st.markdown("""
    <div style="background:linear-gradient(135deg, #1565C0, #0D47A1); border-radius:14px;
                padding:24px 20px; text-align:center; min-height:200px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2rem; margin:0;">&#x1F5FA;</p>
        <h3 style="color:#E3F2FD; margin:8px 0 6px; font-size:1.1rem;">Architecture Mapping</h3>
        <p style="color:#90CAF9; font-size:0.82rem; margin:0;">Discover and map the client's current Snowflake architecture.
        Generate before/after diagrams for proposed changes.</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("Map Architecture", key="tool_arch", use_container_width=True, type="primary"):
        st.session_state.prep_tool = "architecture"

row2_col1, row2_col2 = st.columns(2, gap="medium")

with row2_col1:
    st.markdown("""
    <div style="background:linear-gradient(135deg, #6A1B9A, #4A148C); border-radius:14px;
                padding:24px 20px; text-align:center; min-height:200px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2rem; margin:0;">&#x1F510;</p>
        <h3 style="color:#F3E5F5; margin:8px 0 6px; font-size:1.1rem;">RBAC Gap Analysis</h3>
        <p style="color:#CE93D8; font-size:0.82rem; margin:0;">Analyze roles, grants, and access control.
        Detect gaps, over-permissioned roles, and suggest proper RBAC hierarchy.</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("Analyze RBAC", key="tool_rbac", use_container_width=True, type="primary"):
        st.session_state.prep_tool = "rbac"

with row2_col2:
    st.markdown("""
    <div style="background:linear-gradient(135deg, #2E7D32, #1B5E20); border-radius:14px;
                padding:24px 20px; text-align:center; min-height:200px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2rem; margin:0;">&#x1F527;</p>
        <h3 style="color:#E8F5E9; margin:8px 0 6px; font-size:1.1rem;">Tool Comparison Sandbox</h3>
        <p style="color:#A5D6A7; font-size:0.82rem; margin:0;">Compare data tools hands-on:
        OpenFlow vs Snowpipe vs Streams vs Kafka. Test side-by-side with real examples.</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("Compare Tools", key="tool_compare", use_container_width=True, type="primary"):
        st.session_state.prep_tool = "tool_compare"

st.markdown("")
st.markdown("---")

# ── Active tool section ──
active_tool = st.session_state.get("prep_tool", None)

if active_tool == "health_check":
    st.markdown("### Account Deep Dive")

    # Try to get Snowflake session
    session = None
    try:
        from snowflake.snowpark.context import get_active_session
        session = get_active_session()
    except Exception:
        pass

    if session is None:
        st.info("This tool runs inside Snowflake. Deploy the app to SiS to use the deep dive.")
        st.markdown("""
        **What it scans:**
        - Databases, schemas, tables, views, stages count
        - Warehouse inventory with size & auto-suspend config
        - Role hierarchy overview
        - Network policies & resource monitors
        - Masking & row access policies
        - Task & pipe status
        """)
    else:
        if st.button("Run Deep Dive", key="run_health", type="primary"):
            with st.spinner("Scanning account..."):
                findings = {}
                try:
                    # -- Databases & object counts --
                    db_df = session.sql("SHOW DATABASES").to_pandas()
                    findings["databases"] = len(db_df)

                    total_schemas = 0
                    total_tables = 0
                    total_views = 0
                    db_details = []
                    for _, row in db_df.iterrows():
                        db_name = row["name"]
                        try:
                            s_df = session.sql(f"SHOW SCHEMAS IN DATABASE \"{db_name}\"").to_pandas()
                            t_df = session.sql(f"SHOW TABLES IN DATABASE \"{db_name}\"").to_pandas()
                            v_df = session.sql(f"SHOW VIEWS IN DATABASE \"{db_name}\"").to_pandas()
                            s_count = len(s_df)
                            t_count = len(t_df)
                            v_count = len(v_df)
                        except Exception:
                            s_count = t_count = v_count = 0
                        total_schemas += s_count
                        total_tables += t_count
                        total_views += v_count
                        db_details.append({
                            "Database": db_name,
                            "Owner": row.get("owner", ""),
                            "Schemas": s_count,
                            "Tables": t_count,
                            "Views": v_count,
                        })
                    findings["schemas"] = total_schemas
                    findings["tables"] = total_tables
                    findings["views"] = total_views

                    # -- Warehouses --
                    wh_df = session.sql("SHOW WAREHOUSES").to_pandas()
                    findings["warehouses"] = len(wh_df)

                    # -- Roles --
                    roles_df = session.sql("SHOW ROLES").to_pandas()
                    findings["roles"] = len(roles_df)

                    # -- Stages --
                    try:
                        stg_df = session.sql("SHOW STAGES").to_pandas()
                        findings["stages"] = len(stg_df)
                    except Exception:
                        findings["stages"] = "N/A"

                    # -- Tasks --
                    try:
                        task_df = session.sql("SHOW TASKS").to_pandas()
                        findings["tasks"] = len(task_df)
                    except Exception:
                        findings["tasks"] = "N/A"

                    # -- Pipes --
                    try:
                        pipe_df = session.sql("SHOW PIPES").to_pandas()
                        findings["pipes"] = len(pipe_df)
                    except Exception:
                        findings["pipes"] = "N/A"

                    # -- Network Policies --
                    try:
                        np_df = session.sql("SHOW NETWORK POLICIES").to_pandas()
                        findings["network_policies"] = len(np_df)
                    except Exception:
                        findings["network_policies"] = "N/A"

                    # -- Resource Monitors --
                    try:
                        rm_df = session.sql("SHOW RESOURCE MONITORS").to_pandas()
                        findings["resource_monitors"] = len(rm_df)
                    except Exception:
                        findings["resource_monitors"] = "N/A"

                    # -- Masking Policies --
                    try:
                        mp_df = session.sql("SHOW MASKING POLICIES").to_pandas()
                        findings["masking_policies"] = len(mp_df)
                    except Exception:
                        findings["masking_policies"] = "N/A"

                    # -- Row Access Policies --
                    try:
                        rap_df = session.sql("SHOW ROW ACCESS POLICIES").to_pandas()
                        findings["row_access_policies"] = len(rap_df)
                    except Exception:
                        findings["row_access_policies"] = "N/A"

                    # ── Summary stat cards ──
                    st.markdown("#### Account Overview")
                    c1, c2, c3, c4 = st.columns(4)
                    stats_row1 = [
                        (findings["databases"], "Databases", "#29B5E8"),
                        (findings["schemas"], "Schemas", "#4ECB71"),
                        (findings["tables"], "Tables", "#FF6B6B"),
                        (findings["views"], "Views", "#C084FC"),
                    ]
                    for col, (val, label, color) in zip([c1, c2, c3, c4], stats_row1):
                        with col:
                            st.markdown(
                                f'<div style="background:rgba(255,255,255,0.04);border-radius:10px;padding:12px;text-align:center;">'
                                f'<p style="color:{color};font-size:1.8rem;font-weight:700;margin:0;">{val}</p>'
                                f'<p style="color:#9CA3AF;font-size:0.8rem;margin:0;">{label}</p></div>',
                                unsafe_allow_html=True)

                    c5, c6, c7, c8 = st.columns(4)
                    stats_row2 = [
                        (findings["warehouses"], "Warehouses", "#FFD93D"),
                        (findings["roles"], "Roles", "#F97316"),
                        (findings["stages"], "Stages", "#29B5E8"),
                        (findings["tasks"], "Tasks", "#4ECB71"),
                    ]
                    for col, (val, label, color) in zip([c5, c6, c7, c8], stats_row2):
                        with col:
                            st.markdown(
                                f'<div style="background:rgba(255,255,255,0.04);border-radius:10px;padding:12px;text-align:center;">'
                                f'<p style="color:{color};font-size:1.8rem;font-weight:700;margin:0;">{val}</p>'
                                f'<p style="color:#9CA3AF;font-size:0.8rem;margin:0;">{label}</p></div>',
                                unsafe_allow_html=True)

                    st.markdown("")

                    # ── Security summary ──
                    st.markdown("#### Security & Governance")
                    sc1, sc2, sc3, sc4 = st.columns(4)
                    sec_stats = [
                        (findings["network_policies"], "Network Policies", "#FFD93D"),
                        (findings["resource_monitors"], "Resource Monitors", "#F97316"),
                        (findings["masking_policies"], "Masking Policies", "#C084FC"),
                        (findings["row_access_policies"], "Row Access Policies", "#FF6B6B"),
                    ]
                    for col, (val, label, color) in zip([sc1, sc2, sc3, sc4], sec_stats):
                        with col:
                            warn = ""
                            if val == 0:
                                warn = ' style="border:1px solid #FF6B6B;"'
                            st.markdown(
                                f'<div{warn} style="background:rgba(255,255,255,0.04);border-radius:10px;padding:12px;text-align:center;">'
                                f'<p style="color:{color};font-size:1.8rem;font-weight:700;margin:0;">{val}</p>'
                                f'<p style="color:#9CA3AF;font-size:0.8rem;margin:0;">{label}</p></div>',
                                unsafe_allow_html=True)

                    st.markdown("")

                    # ── Detail sections ──
                    import pandas as pd
                    with st.expander("Database Details", expanded=False):
                        st.dataframe(pd.DataFrame(db_details), use_container_width=True)

                    with st.expander("Warehouses", expanded=False):
                        cols_to_show = [c for c in ["name", "size", "state", "auto_suspend", "auto_resume", "type"] if c in wh_df.columns]
                        st.dataframe(wh_df[cols_to_show] if cols_to_show else wh_df, use_container_width=True)

                    with st.expander(f"Roles ({findings['roles']} total)", expanded=False):
                        cols_to_show = [c for c in ["name", "assigned_to_users", "granted_to_roles", "granted_roles"] if c in roles_df.columns]
                        st.dataframe(roles_df[cols_to_show].head(30) if cols_to_show else roles_df.head(30), use_container_width=True)

                    st.success("Deep dive complete.")
                except Exception as e:
                    st.error(f"Error during scan: {e}")

elif active_tool == "architecture":
    st.markdown("### Architecture Mapping")
    st.info("Discover the client's current Snowflake object hierarchy.")

    conn_available = False
    try:
        from snowflake.snowpark.context import get_active_session
        session = get_active_session()
        conn_available = True
    except Exception:
        pass

    if conn_available:
        if st.button("Discover Architecture", key="run_arch"):
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

                    st.success("Architecture scan complete.")
                except Exception as e:
                    st.error(f"Error scanning: {e}")
    else:
        st.warning("Connect to Snowflake to map architecture.")

    st.markdown("---")
    st.markdown("**Before / After Visualization** -- Draw proposed changes:")
    st.text_area("Current state notes", placeholder="Describe the client's current architecture...", key="arch_before")
    st.text_area("Proposed state notes", placeholder="Describe the target architecture...", key="arch_after")

elif active_tool == "rbac":
    st.markdown("### RBAC Gap Analysis")
    st.info("Analyze role hierarchy and detect access control gaps.")

    conn_available = False
    try:
        from snowflake.snowpark.context import get_active_session
        session = get_active_session()
        conn_available = True
    except Exception:
        pass

    if conn_available:
        if st.button("Analyze RBAC", key="run_rbac"):
            with st.spinner("Analyzing roles and grants..."):
                try:
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
                            st.warning(f"{len(no_mfa)} user(s) without MFA enabled.")
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
                    st.success("RBAC analysis complete.")
                except Exception as e:
                    st.error(f"Error analyzing RBAC: {e}")
    else:
        st.warning("Connect to Snowflake to analyze RBAC.")

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
    st.markdown("### Tool Comparison Sandbox")
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
                ["Staging", "Internal stage (buffered)", "No staging -- direct insert"],
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
        md_rows = "\n| ".join(" | ".join(row) for row in cmp["rows"])
        st.markdown(f"| {md_header} |\n| {md_sep} |\n| {md_rows} |")

else:
    st.markdown("""
    <div style="text-align:center; padding:30px 0; color:#9CA3AF;">
        <p style="font-size:1.2rem;">Select a tool above to get started</p>
        <p style="font-size:0.85rem;">Each tool helps you prepare for client Snowflake engagements</p>
    </div>
    """, unsafe_allow_html=True)
