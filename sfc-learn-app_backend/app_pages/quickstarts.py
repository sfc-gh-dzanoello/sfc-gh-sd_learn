"""Quickstarts -- Browse and follow Snowflake quickstart guides with runnable SQL."""
import streamlit as st
import json
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATALOG_PATH = os.path.join(BASE, "quickstarts", "catalog.json")


def load_catalog():
    try:
        with open(CATALOG_PATH, "r") as f:
            return json.load(f)
    except Exception:
        return []


DIFFICULTY_COLORS = {
    "beginner": "#4ECB71",
    "intermediate": "#FFD93D",
    "advanced": "#FF6B6B",
}

catalog = load_catalog()

# ── View mode: catalog or detail ──
active_qs = st.session_state.get("active_quickstart", None)

if active_qs is None:
    # ── Catalog view ──
    st.markdown("""
    <div style="text-align:center; padding:10px 0 4px;">
        <h1 style="font-size:1.8rem; margin:0; color:#E0F7FA;">Quickstarts</h1>
        <p style="color:#80DEEA; font-size:0.9rem; margin:4px 0 0;">
            Follow step-by-step Snowflake guides with runnable SQL</p>
    </div>
    """, unsafe_allow_html=True)

    st.markdown("")

    cols_per_row = 3
    for row_start in range(0, len(catalog), cols_per_row):
        row_items = catalog[row_start:row_start + cols_per_row]
        cols = st.columns(cols_per_row, gap="medium")

        for col, qs in zip(cols, row_items):
            color = qs.get("color", "#29B5E8")
            diff = qs.get("difficulty", "beginner")
            diff_color = DIFFICULTY_COLORS.get(diff, "#9CA3AF")
            has_steps = len(qs.get("steps", [])) > 0
            badge = "" if has_steps else '<span style="background:#4B5563;color:#D1D5DB;padding:1px 6px;border-radius:6px;font-size:0.65rem;margin-left:4px;">coming soon</span>'
            topics_html = " ".join(
                f'<span style="background:rgba(255,255,255,0.08);color:#80DEEA;padding:2px 8px;border-radius:10px;font-size:0.7rem;">{t}</span>'
                for t in qs.get("topics", [])[:4]
            )

            with col:
                st.markdown(f"""
                <div style="background:linear-gradient(135deg, {color}15, {color}08);
                border:2px solid {color}; border-radius:14px; padding:20px;
                text-align:center; min-height:280px;">
                <h3 style="color:{color}; margin:8px 0 4px; font-size:1.1rem;">{qs['title']}{badge}</h3>
                <p style="color:#9CA3AF; font-size:0.8rem; margin:2px 0 8px;">{qs.get('subtitle', '')}</p>
                <div style="display:flex; gap:6px; justify-content:center; margin:8px 0;">
                <span style="background:{diff_color}22;color:{diff_color};padding:2px 10px;border-radius:10px;font-size:0.75rem;font-weight:600;">{diff}</span>
                <span style="background:rgba(255,255,255,0.08);color:#9CA3AF;padding:2px 10px;border-radius:10px;font-size:0.75rem;">{qs.get('duration', '')}</span>
                </div>
                <p style="color:#B0BEC5; font-size:0.82rem; margin:10px 0;">{qs['description'][:120]}...</p>
                <div style="display:flex; gap:4px; justify-content:center; flex-wrap:wrap; margin:8px 0;">
                {topics_html}
                </div>
                </div>
                """, unsafe_allow_html=True)

                if has_steps:
                    if st.button(f"Start {qs['title'][:25]}", key=f"qs_{qs['id']}",
                                 use_container_width=True, type="primary"):
                        st.session_state.active_quickstart = qs["id"]
                        st.session_state.qs_step = 0
                        st.rerun()
                else:
                    url = qs.get("url", "")
                    if url:
                        st.link_button(f"View on Snowflake", url, use_container_width=True)

else:
    # ── Detail view: step-by-step guide ──
    qs_data = next((q for q in catalog if q["id"] == active_qs), None)
    if not qs_data:
        st.error("Quickstart not found.")
        if st.button("Back to catalog"):
            st.session_state.active_quickstart = None
            st.rerun()
        st.stop()

    steps = qs_data.get("steps", [])
    current_step = st.session_state.get("qs_step", 0)
    current_step = min(current_step, len(steps) - 1)
    color = qs_data.get("color", "#29B5E8")

    # Header
    if st.button("Back to Quickstarts", key="qs_back"):
        st.session_state.active_quickstart = None
        st.session_state.qs_step = 0
        st.rerun()

    st.markdown(f"""
    <h1 style="color:{color}; margin:8px 0 4px; font-size:1.5rem;">{qs_data['title']}</h1>
    <p style="color:#9CA3AF; font-size:0.9rem; margin:0 0 16px;">{qs_data['description']}</p>
    """, unsafe_allow_html=True)

    if qs_data.get("url"):
        st.markdown(f"[View original guide on Snowflake]({qs_data['url']})")

    st.markdown("---")

    # Step progress
    st.markdown(f"**Step {current_step + 1} of {len(steps)}**")
    progress_pct = (current_step + 1) / len(steps)
    st.progress(progress_pct)

    # Current step content
    step = steps[current_step]
    st.markdown(f"### {step['title']}")
    st.markdown(step.get("description", ""))

    if step.get("sql"):
        # Embedded SQL sandbox -- edit and run directly within the quickstart
        sql_key = f"qs_sql_editor_{active_qs}_{current_step}"
        if sql_key not in st.session_state:
            st.session_state[sql_key] = step["sql"]

        st.markdown(f"""
        <div style="background:rgba(41,181,232,0.08);border-left:4px solid #29B5E8;
        border-radius:8px;padding:8px 12px;margin:8px 0 4px;">
        <span style="color:#29B5E8;font-size:0.8rem;font-weight:600;">SQL Sandbox</span>
        </div>
        """, unsafe_allow_html=True)

        edited_sql = st.text_area(
            "Edit SQL",
            value=st.session_state[sql_key],
            height=180,
            key=f"qs_sql_ta_{active_qs}_{current_step}",
            label_visibility="collapsed",
        )
        st.session_state[sql_key] = edited_sql

        btn_cols = st.columns([1, 1, 3])
        with btn_cols[0]:
            run_clicked = st.button("Run", key=f"qs_run_{current_step}",
                                    use_container_width=True, type="primary")
        with btn_cols[1]:
            reset_clicked = st.button("Reset", key=f"qs_reset_{current_step}",
                                      use_container_width=True)

        if reset_clicked:
            st.session_state[sql_key] = step["sql"]
            st.rerun()

        if run_clicked:
            session = None
            try:
                from snowflake.snowpark.context import get_active_session
                session = get_active_session()
            except Exception:
                pass

            if session is None:
                st.info("Deploy the app to Snowflake to run SQL. In local mode, copy the SQL to your Snowflake worksheet.")
                st.code(edited_sql, language="sql")
            else:
                try:
                    with st.spinner("Running..."):
                        result_df = session.sql(edited_sql).to_pandas()
                    st.dataframe(result_df, use_container_width=True)
                    st.caption(f"{len(result_df)} row(s) returned")
                except Exception as e:
                    st.error(f"SQL Error: {e}")

    # Navigation
    st.markdown("")
    nav_cols = st.columns([1, 3, 1])
    with nav_cols[0]:
        if current_step > 0:
            if st.button("Previous", key="qs_prev", use_container_width=True):
                st.session_state.qs_step = current_step - 1
                st.rerun()
    with nav_cols[2]:
        if current_step < len(steps) - 1:
            if st.button("Next", key="qs_next", use_container_width=True, type="primary"):
                st.session_state.qs_step = current_step + 1
                st.rerun()
        else:
            if st.button("Finish", key="qs_finish", use_container_width=True, type="primary"):
                st.session_state.active_quickstart = None
                st.session_state.qs_step = 0
                st.rerun()

    # Step list sidebar
    st.sidebar.markdown("### Steps")
    for i, s in enumerate(steps):
        marker = "> " if i == current_step else "  "
        style = "font-weight:600;" if i == current_step else "color:#9CA3AF;"
        if st.sidebar.button(f"{i+1}. {s['title']}", key=f"qs_nav_{i}", use_container_width=True):
            st.session_state.qs_step = i
            st.rerun()
