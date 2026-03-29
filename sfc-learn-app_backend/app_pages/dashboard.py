"""Dashboard page - visual overview with CLICKABLE domain cards. Works for any certification."""
import streamlit as st
from collections import Counter
from i18n import t
from theme import T

# Detect active cert — read exam metadata from registry
active_cert = st.session_state.get("_active_cert", "core")
registry = st.session_state.get("CERT_REGISTRY", {})
cert_info = registry.get(active_cert, registry.get("core", {}))

# ── Cert selector (top of dashboard) ──
cert_options = []
cert_keys = []
for rk, rv in registry.items():
    if rv.get("available"):
        cert_options.append(rv["full_name"])
        cert_keys.append(rk)
    else:
        cert_options.append(f"{rv['full_name']} (coming soon)")
        cert_keys.append(rk)

current_full_name = cert_info.get("full_name", "SnowPro Core (COF-C03)")
current_idx = cert_options.index(current_full_name) if current_full_name in cert_options else 0

selected_cert = st.selectbox("Select certification", cert_options, index=current_idx, key="dash_cert_select")
if "coming soon" not in selected_cert:
    # Find the registry key for the selected cert
    sel_idx = cert_options.index(selected_cert)
    sel_key = cert_keys[sel_idx]
    if sel_key != active_cert:
        st.session_state._pending_cert = selected_cert
        st.session_state.app_mode = "certifications"
        st.rerun()

# Refresh cert_info after potential change
cert_info = registry.get(active_cert, registry.get("core", {}))
exam = cert_info.get("exam", {})
cert_name = f"{cert_info.get('name', 'SnowPro Core')} {cert_info.get('code', 'COF-C03')}"
exam_qs = exam.get("questions", 100)
exam_time = exam.get("time", "115 min")
exam_cost = exam.get("cost", "$175")
pass_score = exam.get("pass_score", "750/1000")

DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_CSS_NUM = st.session_state.get("DOMAIN_CSS_NUM", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})
DOMAIN_WEIGHTS = st.session_state.get("DOMAIN_WEIGHTS", {})

questions = st.session_state.questions
domain_counts = Counter(q["domain"] for q in questions)
multi_count = sum(1 for q in questions if q.get("multi_select"))

# ── Header ──
st.markdown(
f'<h1 style="margin-bottom:4px;">{cert_name} {t("study_hub")}</h1>'
f'<p style="color:{T.TEXT_SECONDARY}; font-size:1rem; margin-top:0;">'
f'{len(questions):,} {t("practice_questions")} &bull; {t("click_domain_quiz")}'
'</p>', unsafe_allow_html=True)

# ── Stat cards row ──
cols = st.columns(5)
stats = [
    (f"{len(questions):,}", t("total_qs"), T.PRIMARY),
    (f"{multi_count}", t("multi_select"), T.PURPLE),
    (f"{exam_qs}", t("exam_qs"), T.YELLOW),
    (exam_time, t("time_limit"), T.RED),
    (pass_score, t("pass_score"), T.GREEN),
]
for col, (value, label, color) in zip(cols, stats):
    with col:
        st.markdown(
        '<div class="stat-card">'
        f'<p class="stat-value" style="color:{color};">{value}</p>'
        f'<p class="stat-label">{label}</p>'
        '</div>', unsafe_allow_html=True)

st.markdown("<br>", unsafe_allow_html=True)

# ── Domain breakdown — DYNAMIC from actual questions ──
st.markdown(f"## {t('domains_click_quiz')}")

# Get domains from questions (excluding Untagged), sorted
DOMAINS_ORDERED = sorted(set(q["domain"] for q in questions if q["domain"] != "Untagged"))

for di, domain in enumerate(DOMAINS_ORDERED):
    count = domain_counts.get(domain, 0)
    css_num = DOMAIN_CSS_NUM.get(domain, "unknown")
    emoji = DOMAIN_EMOJIS.get(domain, "")
    weight = DOMAIN_WEIGHTS.get(domain, "")
    color = DOMAIN_COLORS.get(domain, T.GRAY)
    pct = count / len(questions) * 100
    bar_width = min(pct * 2.5, 100)
    short_name = domain.split(": ")[1] if ": " in domain else domain
    domain_multi = sum(1 for q in questions if q["domain"] == domain and q.get("multi_select"))

    col1, col2, col3 = st.columns([5, 1, 1])

    with col1:
        st.markdown(
        f'<div class="domain-card domain-{css_num}">'
        f'<h3>{emoji} {short_name}</h3>'
        f'<p><strong>{count}</strong> {t("questions_lc")} ({domain_multi} {t("multi_select").lower()}) &bull; {t("exam_weight")}: <strong>{weight}</strong></p>'
        f'<div class="color-bar" style="background: linear-gradient(90deg, {color} {bar_width}%, {T.BG_CARD_BORDER} {bar_width}%);"></div>'
        '</div>', unsafe_allow_html=True)

    with col2:
        if st.button(t("quiz"), key=f"dash_quiz_d{di}", use_container_width=True, type="primary"):
            st.session_state.quiz_domain_filter = domain
            st.session_state.quiz_source_filter = "All"
            st.switch_page("app_pages/quiz.py")

    with col3:
        if st.button(t("notes"), key=f"dash_notes_d{di}", use_container_width=True):
            st.session_state.selected_domain = domain
            st.switch_page("app_pages/review.py")

# Untagged section
untagged_count = domain_counts.get("Untagged", 0)
if untagged_count:
    col1, col2, _ = st.columns([5, 1, 1])
    with col1:
        st.markdown(
        f'<div class="domain-card" style="background:rgba(107,114,128,0.08); border-color:{T.GRAY};">'
        '<h3>Untagged</h3>'
        f'<p><strong>{untagged_count}</strong> questions — auto-tagging couldn\'t classify these</p>'
        '</div>', unsafe_allow_html=True)
    with col2:
        if st.button("Quiz", key="dash_quiz_untagged", use_container_width=True):
            st.session_state.quiz_domain_filter = "Untagged"
            st.switch_page("app_pages/quiz.py")

st.markdown("<br>", unsafe_allow_html=True)

# ── Quick filters ──
st.markdown(f"## {t('quick_filters')}")
qcol1, qcol2, qcol3 = st.columns(3)

with qcol1:
    st.markdown(
    f'<div class="stat-card" style="border-left:4px solid {T.PURPLE};">'
    f'<p class="stat-value" style="color:{T.PURPLE}; font-size:1.5rem;">{multi_count}</p>'
    f'<p class="stat-label">{t("multi_select_questions")}</p>'
    '</div>', unsafe_allow_html=True)
    if st.button(t("practice_multi_only"), key="dash_multi", use_container_width=True, type="primary"):
        st.session_state.quiz_multi_only = True
        st.switch_page("app_pages/quiz.py")

with qcol2:
    # Get unique sources
    sources = sorted(set(q["source"] for q in questions))
    src_count_1 = len(sources)
    st.markdown(
    f'<div class="stat-card" style="border-left:4px solid {T.GREEN};">'
    f'<p class="stat-value" style="color:{T.GREEN}; font-size:1.5rem;">{len(questions):,}</p>'
    f'<p class="stat-label">{t("total_questions_from").replace("{n}", str(src_count_1))}</p>'
    '</div>', unsafe_allow_html=True)
    if st.button(t("start_full_quiz"), key="dash_full", use_container_width=True):
        st.switch_page("app_pages/quiz.py")

with qcol3:
    untagged = domain_counts.get("Untagged", 0)
    tagged_pct = round((1 - untagged / max(len(questions), 1)) * 100)
    st.markdown(
    f'<div class="stat-card" style="border-left:4px solid {T.PRIMARY};">'
    f'<p class="stat-value" style="color:{T.PRIMARY}; font-size:1.5rem;">{tagged_pct}%</p>'
    f'<p class="stat-label">{t("questions_tagged")}</p>'
    '</div>', unsafe_allow_html=True)
    if st.button(t("view_review_notes"), key="dash_notes_qf", use_container_width=True):
        st.switch_page("app_pages/review.py")

st.markdown("<br>", unsafe_allow_html=True)

# ── Starty ──
st.markdown(f"## {t('starty')}")

col1, col2, col3 = st.columns(3)

with col1:
    st.markdown(
    '<div class="stat-card">'
    f'<p class="stat-value" style="font-size:2.5rem;color:{T.PRIMARY};">Q</p>'
    f'<p style="color:{T.TEXT_PRIMARY}; font-weight:600; margin:6px 0;">{t("quiz_mode")}</p>'
    f'<p class="stat-label">{t("quiz_mode_desc")}</p>'
    '</div>', unsafe_allow_html=True)
    if st.button(t("start_quiz"), key="dash_quiz_main", use_container_width=True, type="primary"):
        st.switch_page("app_pages/quiz.py")

with col2:
    st.markdown(
    '<div class="stat-card">'
    f'<p class="stat-value" style="font-size:2.5rem;color:{T.GREEN};">N</p>'
    f'<p style="color:{T.TEXT_PRIMARY}; font-weight:600; margin:6px 0;">{t("review_notes")}</p>'
    f'<p class="stat-label">{t("review_notes_desc")}</p>'
    '</div>', unsafe_allow_html=True)
    if st.button(t("open_notes"), key="dash_notes_main", use_container_width=True):
        st.switch_page("app_pages/review.py")

with col3:
    st.markdown(
    '<div class="stat-card">'
    f'<p class="stat-value" style="font-size:2.5rem;color:{T.RED};">S</p>'
    f'<p style="color:{T.TEXT_PRIMARY}; font-weight:600; margin:6px 0;">{t("exam_strategy")}</p>'
    f'<p class="stat-label">{t("exam_strategy_desc")}</p>'
    '</div>', unsafe_allow_html=True)
    if st.button(t("view_strategy"), key="dash_strategy", use_container_width=True):
        st.switch_page("app_pages/strategy.py")
