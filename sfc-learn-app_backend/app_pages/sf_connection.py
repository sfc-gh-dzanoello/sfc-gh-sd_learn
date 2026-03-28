"""Snowflake connection helper — works both locally and in Streamlit-in-Snowflake (SiS)."""
import streamlit as st

try:
    import snowflake.connector
    SF_CONNECTOR_AVAILABLE = True
except ImportError:
    SF_CONNECTOR_AVAILABLE = False

try:
    from snowflake.snowpark.context import get_active_session
    get_active_session()
    IN_SIS = True
except Exception:
    IN_SIS = False


def get_connection():
    """Get a Snowflake connection. Returns None if unavailable.
    - In SiS: uses the built-in Snowpark session
    - Locally: uses snowflake.connector with st.secrets
    """
    # Return cached connection if available
    if "_sf_conn" in st.session_state:
        conn = st.session_state._sf_conn
        try:
            # Quick check if still alive
            if hasattr(conn, "cursor"):
                conn.cursor().execute("SELECT 1")
                return conn
            elif hasattr(conn, "sql"):
                # Snowpark session
                return conn
        except Exception:
            st.session_state.pop("_sf_conn", None)

    # In Streamlit-in-Snowflake — use built-in session
    if IN_SIS:
        try:
            session = get_active_session()
            st.session_state._sf_conn = session
            return session
        except Exception:
            pass

    # Local — use snowflake.connector with secrets
    if not SF_CONNECTOR_AVAILABLE:
        return None

    try:
        secrets = st.secrets.get("snowflake", {})
        if not secrets:
            return None
        conn = snowflake.connector.connect(
            account=secrets.get("account", ""),
            user=secrets.get("user", ""),
            role=secrets.get("role", "ACCOUNTADMIN"),
            warehouse=secrets.get("warehouse", "COMPUTE_WH"),
            authenticator=secrets.get("authenticator", "externalbrowser"),
        )
        st.session_state._sf_conn = conn
        return conn
    except Exception:
        return None


def run_sql(sql, params=None):
    """Execute SQL and return results.
    - SELECT queries return list of dicts
    - DDL/DML returns {"status": "success", "message": "..."}
    - Errors return {"status": "error", "message": "..."}
    """
    conn = get_connection()
    if conn is None:
        return {"status": "error", "message": "No Snowflake connection available"}

    try:
        # Snowpark session (SiS)
        if hasattr(conn, "sql"):
            if params:
                df = conn.sql(sql, params=params).collect()
            else:
                df = conn.sql(sql).collect()
            return [row.as_dict() for row in df]

        # snowflake.connector
        cur = conn.cursor()
        cur.execute(sql, params)

        # Check if there are results (SELECT)
        if cur.description:
            columns = [col[0] for col in cur.description]
            rows = cur.fetchall()
            return [dict(zip(columns, row)) for row in rows]
        else:
            return {"status": "success", "message": f"Statement executed successfully. Rows affected: {cur.rowcount}"}

    except Exception as e:
        return {"status": "error", "message": str(e)}


def test_connection():
    """Test if connection works. Returns status dict."""
    conn = get_connection()
    if conn is None:
        return {"connected": False, "user": "", "role": "", "warehouse": ""}

    try:
        if hasattr(conn, "sql"):
            row = conn.sql("SELECT CURRENT_USER() AS u, CURRENT_ROLE() AS r, CURRENT_WAREHOUSE() AS w").collect()[0]
            return {"connected": True, "user": row["U"], "role": row["R"], "warehouse": row["W"] or ""}
        else:
            cur = conn.cursor()
            cur.execute("SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_WAREHOUSE()")
            row = cur.fetchone()
            return {"connected": True, "user": row[0], "role": row[1], "warehouse": row[2] or ""}
    except Exception:
        return {"connected": False, "user": "", "role": "", "warehouse": ""}


def connection_status_widget():
    """Render connection status in sidebar."""
    st.sidebar.markdown("---")
    st.sidebar.markdown("### ❄️ Snowflake")

    if st.sidebar.button("🔌 Connect", key="_sf_connect_btn", use_container_width=True):
        with st.spinner("Connecting..."):
            status = test_connection()
            st.session_state._sf_status = status

    status = st.session_state.get("_sf_status", None)

    if status and status.get("connected"):
        st.sidebar.markdown(
'<div style="background:rgba(78,203,113,0.1); border-left:3px solid #4ECB71;'
' border-radius:6px; padding:8px 12px; margin:4px 0;">'
f'<span style="color:#4ECB71; font-weight:600;">Connected</span><br>'
f'<span style="color:#9CA3AF; font-size:0.8rem;">{status["user"]} - {status["role"]}</span>'
'</div>', unsafe_allow_html=True)
    elif IN_SIS:
        st.sidebar.markdown(
'<div style="background:rgba(41,181,232,0.1); border-left:3px solid #29B5E8;'
' border-radius:6px; padding:8px 12px; margin:4px 0;">'
'<span style="color:#29B5E8; font-weight:600;">SiS Mode</span><br>'
'<span style="color:#9CA3AF; font-size:0.8rem;">Built-in connection</span>'
'</div>', unsafe_allow_html=True)
    else:
        st.sidebar.markdown(
'<div style="background:rgba(255,107,107,0.1); border-left:3px solid #FF6B6B;'
' border-radius:6px; padding:8px 12px; margin:4px 0;">'
'<span style="color:#FF6B6B; font-weight:600;">Not connected</span><br>'
'<span style="color:#9CA3AF; font-size:0.8rem;">Click Connect above</span>'
'</div>', unsafe_allow_html=True)


def close_connection():
    """Close the cached connection."""
    conn = st.session_state.pop("_sf_conn", None)
    st.session_state.pop("_sf_status", None)
    if conn and hasattr(conn, "close"):
        try:
            conn.close()
        except Exception:
            pass
