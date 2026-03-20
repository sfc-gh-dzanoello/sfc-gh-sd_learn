"""SQL Sandbox — Free-form SQL editor with templates and AI assistance."""
import time
import streamlit as st
from i18n import t

# ── Home button ──
if st.button("🏠 Home", key="sandbox_home"):
    st.session_state.app_mode = "landing"
    st.switch_page("app_pages/landing.py")

# ── SQL Templates by category ──
TEMPLATES = {
    "Account & Access": [
        ("Show current role & warehouse", "SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();"),
        ("List all roles", "SHOW ROLES;"),
        ("List warehouses", "SHOW WAREHOUSES;"),
        ("List databases", "SHOW DATABASES;"),
        ("Show grants to current role", "SHOW GRANTS TO ROLE IDENTIFIER(CURRENT_ROLE());"),
    ],
    "Data & Tables": [
        ("List schemas", "SHOW SCHEMAS IN DATABASE;"),
        ("List tables", "SHOW TABLES;"),
        ("Describe a table", "DESCRIBE TABLE my_table;"),
        ("Sample 10 rows", "SELECT * FROM my_table LIMIT 10;"),
        ("Row count", "SELECT COUNT(*) AS row_count FROM my_table;"),
    ],
    "Data Loading": [
        ("List stages", "SHOW STAGES;"),
        ("List files in stage", "LIST @my_stage;"),
        ("Create CSV file format", "CREATE OR REPLACE FILE FORMAT my_csv_format\n  TYPE = 'CSV'\n  FIELD_DELIMITER = ','\n  SKIP_HEADER = 1\n  FIELD_OPTIONALLY_ENCLOSED_BY = '\"';"),
        ("COPY INTO example", "COPY INTO my_table\n  FROM @my_stage/data.csv\n  FILE_FORMAT = (FORMAT_NAME = 'my_csv_format')\n  ON_ERROR = 'CONTINUE';"),
        ("Validate pipe load", "SELECT * FROM TABLE(VALIDATE_PIPE_LOAD(\n  PIPE_NAME => 'my_pipe',\n  START_TIME => DATEADD(HOUR, -1, CURRENT_TIMESTAMP())\n));"),
    ],
    "Performance": [
        ("Query history (last hour)", "SELECT QUERY_ID, QUERY_TEXT, EXECUTION_STATUS,\n  TOTAL_ELAPSED_TIME/1000 AS elapsed_sec\nFROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY(\n  DATEADD('HOURS', -1, CURRENT_TIMESTAMP()),\n  CURRENT_TIMESTAMP()\n))\nORDER BY START_TIME DESC\nLIMIT 20;"),
        ("Warehouse metering (today)", "SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY\nWHERE START_TIME >= CURRENT_DATE()\nORDER BY START_TIME DESC;"),
        ("Table clustering info", "SELECT SYSTEM$CLUSTERING_INFORMATION('my_table');"),
        ("Auto-clustering history", "SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY\nWHERE START_TIME >= DATEADD(DAY, -7, CURRENT_TIMESTAMP())\nORDER BY START_TIME DESC LIMIT 20;"),
    ],
    "Governance": [
        ("List masking policies", "SHOW MASKING POLICIES;"),
        ("List row access policies", "SHOW ROW ACCESS POLICIES;"),
        ("List tags", "SHOW TAGS;"),
        ("Show tag references", "SELECT * FROM TABLE(INFORMATION_SCHEMA.TAG_REFERENCES(\n  'my_table', 'TABLE'\n));"),
        ("Login history (last 24h)", "SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY\nWHERE EVENT_TIMESTAMP >= DATEADD(HOUR, -24, CURRENT_TIMESTAMP())\nORDER BY EVENT_TIMESTAMP DESC LIMIT 20;"),
    ],
}


def _init_state():
    """Initialize session state for sandbox."""
    if "sandbox_sql" not in st.session_state:
        st.session_state.sandbox_sql = ""
    if "sandbox_history" not in st.session_state:
        st.session_state.sandbox_history = []
    if "sandbox_result" not in st.session_state:
        st.session_state.sandbox_result = None
    if "sandbox_error" not in st.session_state:
        st.session_state.sandbox_error = None
    if "sandbox_elapsed" not in st.session_state:
        st.session_state.sandbox_elapsed = None
    if "sandbox_ai_fix" not in st.session_state:
        st.session_state.sandbox_ai_fix = None


def _run_query(sql):
    """Execute SQL and store result in session state."""
    from app_pages.sf_connection import run_sql

    start = time.time()
    result = run_sql(sql)
    elapsed = round(time.time() - start, 2)

    # Add to history (keep last 15)
    st.session_state.sandbox_history.insert(0, {
        "sql": sql,
        "time": elapsed,
        "success": not (isinstance(result, dict) and result.get("status") == "error"),
    })
    st.session_state.sandbox_history = st.session_state.sandbox_history[:15]

    st.session_state.sandbox_elapsed = elapsed

    if isinstance(result, dict) and result.get("status") == "error":
        st.session_state.sandbox_error = result["message"]
        st.session_state.sandbox_result = None
    else:
        st.session_state.sandbox_result = result
        st.session_state.sandbox_error = None


def _ai_fix_sql(sql, error_msg):
    """Ask Cortex AI to fix the SQL."""
    try:
        from app_pages.ai_helper import ai_complete
        lang = st.session_state.get("lang", "en")
        lang_names = {"en": "English", "pt": "Brazilian Portuguese", "es": "Latin American Spanish"}
        lang_name = lang_names.get(lang, "English")
        prompt = (
            f"You are a Snowflake SQL expert. Respond in {lang_name}.\n\n"
            f"The following SQL query failed:\n```sql\n{sql}\n```\n\n"
            f"Error message: {error_msg}\n\n"
            f"Please:\n"
            f"1. Explain what went wrong (1-2 sentences)\n"
            f"2. Provide the corrected SQL inside a ```sql code block\n"
            f"3. Briefly explain what you changed\n"
        )
        return ai_complete(prompt)
    except ImportError:
        return None


# ── Main page ──

_init_state()

st.markdown(f"""
<div style="margin-bottom:16px;">
    <h2 style="color:#29B5E8; margin:0;">
        <span style="margin-right:8px;">&#128187;</span>{t('sql_sandbox')}
    </h2>
    <p style="color:#9CA3AF; margin:4px 0 0;">{t('sql_sandbox_desc')}</p>
</div>
""", unsafe_allow_html=True)

# ── Check connection ──
sf_connected = False
try:
    from app_pages.sf_connection import get_connection, run_sql
    conn = get_connection()
    sf_connected = conn is not None
except ImportError:
    pass

if not sf_connected:
    st.warning(f"⚠️ {t('disconnected')} — {t('no_connection_sandbox')}")

# ── Layout: editor (left) + templates/history (right) ──
editor_col, side_col = st.columns([3, 1])

with editor_col:
    st.markdown(f"### {t('sql_editor')}")

    sql_input = st.text_area(
        t("sql_editor"),
        value=st.session_state.sandbox_sql,
        height=200,
        key="sandbox_editor_input",
        label_visibility="collapsed",
        placeholder="SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE();",
    )
    # Sync back to session state
    st.session_state.sandbox_sql = sql_input

    # Action buttons
    btn_cols = st.columns([1, 1, 2, 2])
    with btn_cols[0]:
        run_clicked = st.button(
            f"▶ {t('run_query')}",
            type="primary",
            disabled=not sf_connected or not sql_input.strip(),
            use_container_width=True,
        )
    with btn_cols[1]:
        if st.button(f"🗑 {t('clear_editor')}", use_container_width=True):
            st.session_state.sandbox_sql = ""
            st.session_state.sandbox_result = None
            st.session_state.sandbox_error = None
            st.session_state.sandbox_ai_fix = None
            st.session_state.sandbox_elapsed = None
            st.rerun()

    # Execute
    if run_clicked and sql_input.strip():
        with st.spinner(t("running")):
            _run_query(sql_input.strip())
        st.rerun()

    # ── Display result ──
    if st.session_state.sandbox_error:
        st.error(f"❌ {t('query_error')}: {st.session_state.sandbox_error}")
        if st.session_state.sandbox_elapsed is not None:
            st.caption(f"{t('execution_time')}: {st.session_state.sandbox_elapsed}s")

        # AI Fix button
        if st.button(f"🤖 {t('fix_my_sql')}", type="secondary"):
            with st.spinner(t("ai_fixing")):
                fix = _ai_fix_sql(sql_input, st.session_state.sandbox_error)
                st.session_state.sandbox_ai_fix = fix

        if st.session_state.sandbox_ai_fix:
            st.markdown(f"""
            <div style="background:rgba(41,181,232,0.08); border-left:4px solid #29B5E8;
                        border-radius:8px; padding:14px 18px; margin:8px 0;">
                <strong style="color:#29B5E8;">🤖 {t('ai_suggestion')}</strong>
            </div>
            """, unsafe_allow_html=True)
            st.markdown(st.session_state.sandbox_ai_fix)

            # Extract SQL from AI response (look for ```sql blocks)
            ai_text = st.session_state.sandbox_ai_fix
            fixed_sql = None
            if "```sql" in ai_text:
                parts = ai_text.split("```sql")
                if len(parts) > 1:
                    fixed_sql = parts[1].split("```")[0].strip()
            elif "```" in ai_text:
                parts = ai_text.split("```")
                if len(parts) > 2:
                    fixed_sql = parts[1].strip()

            if fixed_sql:
                if st.button(f"✅ {t('copy_to_editor')}"):
                    st.session_state.sandbox_sql = fixed_sql
                    st.session_state.sandbox_ai_fix = None
                    st.session_state.sandbox_error = None
                    st.rerun()

    elif st.session_state.sandbox_result is not None:
        result = st.session_state.sandbox_result
        if st.session_state.sandbox_elapsed is not None:
            st.caption(f"{t('execution_time')}: {st.session_state.sandbox_elapsed}s")

        if isinstance(result, list):
            if result:
                import pandas as pd
                df = pd.DataFrame(result)
                st.markdown(f"**{t('query_result')}** — {len(df)} {t('rows_returned')}")
                st.dataframe(df, use_container_width=True)
            else:
                st.info("Query returned 0 rows.")
        elif isinstance(result, dict):
            st.success(f"✅ {result.get('message', 'Success')}")

# ── Sidebar: Templates + History ──
with side_col:
    # Templates
    st.markdown(f"### {t('templates')}")
    for category, items in TEMPLATES.items():
        with st.expander(category, expanded=False):
            for label, sql in items:
                if st.button(
                    label,
                    key=f"tpl_{category}_{label}",
                    use_container_width=True,
                ):
                    st.session_state.sandbox_sql = sql
                    st.session_state.sandbox_result = None
                    st.session_state.sandbox_error = None
                    st.session_state.sandbox_ai_fix = None
                    st.rerun()

    # History
    st.markdown("---")
    st.markdown(f"### {t('query_history')}")
    history = st.session_state.sandbox_history
    if not history:
        st.caption("No queries yet.")
    else:
        for i, entry in enumerate(history):
            status = "✅" if entry["success"] else "❌"
            short_sql = entry["sql"][:50].replace("\n", " ")
            if len(entry["sql"]) > 50:
                short_sql += "..."
            if st.button(
                f"{status} {short_sql}",
                key=f"hist_{i}",
                use_container_width=True,
            ):
                st.session_state.sandbox_sql = entry["sql"]
                st.session_state.sandbox_result = None
                st.session_state.sandbox_error = None
                st.session_state.sandbox_ai_fix = None
                st.rerun()
