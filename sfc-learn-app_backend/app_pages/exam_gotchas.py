"""Exam Gotchas -- deep-dive trap explanations with comparison tables and decision rules."""
import streamlit as st
import json
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})

# ── Load gotchas ──
@st.cache_data(ttl=3600)
def _load_gotchas(active_cert: str, lang: str):
    if active_cert == "architect":
        path = os.path.join(
            BASE,
            "certifications", "sfc-gh-sd-advanced", "architect_domains",
            f"exam_gotchas_{lang}.json",
        )
        if not os.path.exists(path):
            path = os.path.join(
                BASE,
                "certifications", "sfc-gh-sd-advanced", "architect_domains",
                "exam_gotchas_en.json",
            )
    else:
        path = os.path.join(
            BASE,
            "certifications", "sfc-gh-sd-advanced", "architect_domains",
            "exam_gotchas_en.json",
        )
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    return []


_active_cert = st.session_state.get("_active_cert", "core")
_lang = st.session_state.get("lang", "en")
gotchas = _load_gotchas(_active_cert, _lang)

# ── Header ──
st.markdown("""
<div style="text-align:center; padding:10px 0 4px;">
    <h1 style="font-size:1.8rem; margin:0; color:#E0F7FA;">Exam Gotchas</h1>
    <p style="color:#80DEEA; font-size:0.9rem; margin:4px 0 0;">
        Deep-dive explanations of the trickiest exam traps with comparison tables and decision rules</p>
</div>
""", unsafe_allow_html=True)

if not gotchas:
    st.info("No exam gotchas available for the current certification yet.")
    st.stop()

# ── Filters ──
domains = sorted(set(g["domain"] for g in gotchas))
col_f1, col_f2 = st.columns([1, 2])
with col_f1:
    domain_filter = st.selectbox("Filter by domain", ["All"] + domains, key="gotcha_domain")
with col_f2:
    search = st.text_input("Search gotchas", key="gotcha_search", placeholder="e.g., replication, clustering...")

filtered = gotchas
if domain_filter != "All":
    filtered = [g for g in filtered if g["domain"] == domain_filter]
if search:
    s = search.lower()
    filtered = [
        g for g in filtered
        if s in g["title"].lower()
        or s in g.get("problem", "").lower()
        or s in g.get("solution", "").lower()
        or any(s in kw.lower() for kw in g.get("exam_keywords", []))
    ]

st.caption(f"Showing {len(filtered)} of {len(gotchas)} gotchas")

# ── Render each gotcha ──
for gi, g in enumerate(filtered):
    domain = g["domain"]
    color = DOMAIN_COLORS.get(domain, "#29B5E8")
    emoji = DOMAIN_EMOJIS.get(domain, "")
    short_domain = domain.split(": ")[1] if ": " in domain else domain

    with st.expander(f"{g['title']}", expanded=gi == 0):
        # Domain badge
        st.markdown(
            f'<div style="display:flex; gap:8px; align-items:center; margin-bottom:8px;">'
            f'<span style="background:{color}22; color:{color}; padding:2px 10px; '
            f'border-radius:10px; font-size:0.8rem; font-weight:600;">'
            f'{emoji} {short_domain}</span>'
            f'<span style="background:rgba(255,255,255,0.08); color:#9CA3AF; padding:2px 8px; '
            f'border-radius:10px; font-size:0.75rem;">'
            f'Topics: {", ".join(g.get("sub_topics", []))}</span>'
            f'</div>',
            unsafe_allow_html=True,
        )

        # The Problem (trap scenario)
        st.markdown(
            f'<div style="background:#FFEBEE; border-left:4px solid #E53935; '
            f'border-radius:0 8px 8px 0; padding:12px 16px; margin:8px 0;">'
            f'<strong style="color:#C62828; font-size:0.9rem;">THE TRAP</strong>'
            f'<p style="color:#1a1a2e; margin:6px 0 0; font-size:0.88rem; line-height:1.5;">'
            f'{g["problem"]}</p></div>',
            unsafe_allow_html=True,
        )

        # The Solution
        st.markdown(
            f'<div style="background:#E8F5E9; border-left:4px solid #2E7D32; '
            f'border-radius:0 8px 8px 0; padding:12px 16px; margin:8px 0;">'
            f'<strong style="color:#2E7D32; font-size:0.9rem;">THE CORRECT ANSWER</strong>'
            f'<p style="color:#1a1a2e; margin:6px 0 0; font-size:0.88rem; line-height:1.5;">'
            f'{g["solution"]}</p></div>',
            unsafe_allow_html=True,
        )

        # Comparison Table
        table = g.get("comparison_table")
        if table:
            headers = table.get("headers", [])
            rows = table.get("rows", [])
            header_html = "".join(
                f'<th style="background:#1B2332; color:#29B5E8; padding:10px 12px; '
                f'text-align:left; font-size:0.82rem;">{h}</th>'
                for h in headers
            )
            rows_html = ""
            for ri, row in enumerate(rows):
                bg = "#F9F9F9" if ri % 2 == 0 else "#FFFFFF"
                cells = "".join(
                    f'<td style="padding:8px 12px; color:#1a1a2e; border-bottom:1px solid #E0E0E0; '
                    f'background:{bg}; font-size:0.82rem;">{c}</td>'
                    for c in row
                )
                rows_html += f"<tr>{cells}</tr>"

            st.markdown(
                f'<div style="margin:10px 0; overflow-x:auto;">'
                f'<table style="width:100%; border-collapse:collapse; border-radius:8px; '
                f'overflow:hidden; border:1px solid #E0E0E0;">'
                f'<thead><tr>{header_html}</tr></thead>'
                f'<tbody>{rows_html}</tbody>'
                f'</table></div>',
                unsafe_allow_html=True,
            )

        # Rule of Thumb
        rot = g.get("rule_of_thumb", "")
        if rot:
            st.markdown(
                f'<div style="background:#E3F2FD; border-left:4px solid #1565C0; '
                f'border-radius:0 8px 8px 0; padding:10px 16px; margin:8px 0;">'
                f'<strong style="color:#0D47A1; font-size:0.85rem;">RULE OF THUMB</strong>'
                f'<p style="color:#1a1a2e; margin:4px 0 0; font-size:0.88rem;">{rot}</p>'
                f'</div>',
                unsafe_allow_html=True,
            )

        # Pro Tip
        tip = g.get("pro_tip", "")
        if tip:
            st.markdown(
                f'<div style="background:#FFF8E1; border-left:4px solid #F9A825; '
                f'border-radius:0 8px 8px 0; padding:10px 16px; margin:8px 0;">'
                f'<strong style="color:#F57F17; font-size:0.85rem;">PRO TIP</strong>'
                f'<p style="color:#1a1a2e; margin:4px 0 0; font-size:0.88rem;">{tip}</p>'
                f'</div>',
                unsafe_allow_html=True,
            )

        # Quiz shortcut
        sub_topics = g.get("sub_topics", [])
        if sub_topics:
            questions = st.session_state.get("questions", [])
            related = [
                q for q in questions
                if q.get("sub_topic") in sub_topics
            ]
            if related:
                st.markdown(
                    f'<p style="color:#80DEEA; font-size:0.8rem; margin:10px 0 4px;">'
                    f'{len(related)} related quiz questions available</p>',
                    unsafe_allow_html=True,
                )
                if st.button(
                    f"Quiz related questions",
                    key=f"gotcha_quiz_{gi}",
                    use_container_width=True,
                    type="secondary",
                ):
                    st.session_state.quiz_domain_filter = domain
                    st.session_state.quiz_source_filter = "All"
                    st.switch_page("app_pages/quiz.py")

        # Keywords
        keywords = g.get("exam_keywords", [])
        if keywords:
            kw_html = " ".join(
                f'<span style="background:rgba(255,255,255,0.08); color:#9CA3AF; '
                f'padding:2px 8px; border-radius:10px; font-size:0.7rem;">{kw}</span>'
                for kw in keywords
            )
            st.markdown(
                f'<div style="margin:8px 0 0; display:flex; gap:4px; flex-wrap:wrap;">'
                f'{kw_html}</div>',
                unsafe_allow_html=True,
            )
