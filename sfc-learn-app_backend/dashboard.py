"""Dashboard page - visual overview with CLICKABLE domain cards. Works for any certification."""
import streamlit as st
from collections import Counter

# ── Sidebar: Home button ──
if st.sidebar.button("🏠 Home", key="dash_home", use_container_width=True):
    st.session_state.app_mode = None
    st.switch_page("app_pages/landing.py")

DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_CSS_NUM = st.session_state.get("DOMAIN_CSS_NUM", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})
DOMAIN_WEIGHTS = st.session_state.get("DOMAIN_WEIGHTS", {})

questions = st.session_state.questions
domain_counts = Counter(q["domain"] for q in questions)
multi_count = sum(1 for q in questions if q.get("multi_select"))

# Detect active cert — read exam metadata from registry
active_cert = st.session_state.get("_active_cert", "core")
registry = st.session_state.get("CERT_REGISTRY", {})
cert_info = registry.get(active_cert, registry.get("core", {}))
exam = cert_info.get("exam", {})
cert_name = f"{cert_info.get('name', 'SnowPro Core')} {cert_info.get('code', 'COF-C03')}"
exam_qs = exam.get("questions", 100)
exam_time = exam.get("time", "115 min")
exam_cost = exam.get("cost", "$175")
pass_score = exam.get("pass_score", "750/1000")

# ── Header ──
st.markdown(f"""
<h1 style="margin-bottom:4px;">🎯 {cert_name} Study Hub</h1>
<p style="color:#9CA3AF; font-size:1rem; margin-top:0;">
{len(questions):,} practice questions &bull; Click any domain to start a quiz
</p>
""", unsafe_allow_html=True)

# ── Stat cards row ──
cols = st.columns(5)
stats = [
    (f"{len(questions):,}", "Total Qs", "#29B5E8"),
    (f"{multi_count}", "Multi-select", "#C084FC"),
    (f"{exam_qs}", "Exam Qs", "#FFD93D"),
    (exam_time, "Time limit", "#FF6B6B"),
    (pass_score, "Pass score", "#4ECB71"),
]
for col, (value, label, color) in zip(cols, stats):
    with col:
        st.markdown(f"""
        <div class="stat-card">
            <p class="stat-value" style="color:{color};">{value}</p>
            <p class="stat-label">{label}</p>
        </div>
        """, unsafe_allow_html=True)

st.markdown("<br>", unsafe_allow_html=True)

# ── Domain breakdown — DYNAMIC from actual questions ──
st.markdown("## 📊 Domains — Click to start a quiz")

# Get domains from questions (excluding Untagged), sorted
DOMAINS_ORDERED = sorted(set(q["domain"] for q in questions if q["domain"] != "Untagged"))

for di, domain in enumerate(DOMAINS_ORDERED):
    count = domain_counts.get(domain, 0)
    css_num = DOMAIN_CSS_NUM.get(domain, "unknown")
    emoji = DOMAIN_EMOJIS.get(domain, "📋")
    weight = DOMAIN_WEIGHTS.get(domain, "")
    color = DOMAIN_COLORS.get(domain, "#6B7280")
    pct = count / len(questions) * 100
    bar_width = min(pct * 2.5, 100)
    short_name = domain.split(": ")[1] if ": " in domain else domain
    domain_multi = sum(1 for q in questions if q["domain"] == domain and q.get("multi_select"))

    col1, col2, col3 = st.columns([5, 1, 1])

    with col1:
        st.markdown(f"""
        <div class="domain-card domain-{css_num}">
            <h3>{emoji} {short_name}</h3>
            <p><strong>{count}</strong> questions ({domain_multi} multi-select) &bull; Exam weight: <strong>{weight}</strong></p>
            <div class="color-bar" style="background: linear-gradient(90deg, {color} {bar_width}%, #2D3748 {bar_width}%);"></div>
        </div>
        """, unsafe_allow_html=True)

    with col2:
        if st.button(f"🧠 Quiz", key=f"dash_quiz_d{di}", use_container_width=True, type="primary"):
            st.session_state.quiz_domain_filter = domain
            st.session_state.quiz_source_filter = "All"
            st.switch_page("app_pages/quiz.py")

    with col3:
        if st.button(f"📖 Notes", key=f"dash_notes_d{di}", use_container_width=True):
            st.session_state.selected_domain = domain
            st.switch_page("app_pages/review.py")

# Untagged section
untagged_count = domain_counts.get("Untagged", 0)
if untagged_count:
    col1, col2, _ = st.columns([5, 1, 1])
    with col1:
        st.markdown(f"""
        <div class="domain-card" style="background:rgba(107,114,128,0.08); border-color:#6B7280;">
            <h3>📋 Untagged</h3>
            <p><strong>{untagged_count}</strong> questions — auto-tagging couldn't classify these</p>
        </div>
        """, unsafe_allow_html=True)
    with col2:
        if st.button("🧠 Quiz", key="dash_quiz_untagged", use_container_width=True):
            st.session_state.quiz_domain_filter = "Untagged"
            st.switch_page("app_pages/quiz.py")

st.markdown("<br>", unsafe_allow_html=True)

# ── Quick filters ──
st.markdown("## 🎯 Quick Filters")
qcol1, qcol2, qcol3 = st.columns(3)

with qcol1:
    st.markdown(f"""
    <div class="stat-card" style="border-left:4px solid #C084FC;">
        <p class="stat-value" style="color:#C084FC; font-size:1.5rem;">{multi_count}</p>
        <p class="stat-label">Multi-select questions</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("Practice multi-select only", key="dash_multi", use_container_width=True, type="primary"):
        st.session_state.quiz_multi_only = True
        st.switch_page("app_pages/quiz.py")

with qcol2:
    # Get unique sources
    sources = sorted(set(q["source"] for q in questions))
    src_count_1 = len(sources)
    st.markdown(f"""
    <div class="stat-card" style="border-left:4px solid #4ECB71;">
        <p class="stat-value" style="color:#4ECB71; font-size:1.5rem;">{len(questions):,}</p>
        <p class="stat-label">Total questions from {src_count_1} tests</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("Start full quiz", key="dash_full", use_container_width=True):
        st.switch_page("app_pages/quiz.py")

with qcol3:
    untagged = domain_counts.get("Untagged", 0)
    tagged_pct = round((1 - untagged / max(len(questions), 1)) * 100)
    st.markdown(f"""
    <div class="stat-card" style="border-left:4px solid #29B5E8;">
        <p class="stat-value" style="color:#29B5E8; font-size:1.5rem;">{tagged_pct}%</p>
        <p class="stat-label">Questions tagged to domains</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("View review notes", key="dash_notes_qf", use_container_width=True):
        st.switch_page("app_pages/review.py")

st.markdown("<br>", unsafe_allow_html=True)

# ── Quick start ──
st.markdown("## 🚀 Quick Start")

col1, col2, col3 = st.columns(3)

with col1:
    st.markdown("""
    <div class="stat-card">
        <p class="stat-value" style="font-size:2.5rem;">🧠</p>
        <p style="color:#FAFAFA; font-weight:600; margin:6px 0;">Quiz Mode</p>
        <p class="stat-label">Practice with instant feedback, explanations, and domain tips</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("Start quiz", key="dash_quiz_main", use_container_width=True, type="primary"):
        st.switch_page("app_pages/quiz.py")

with col2:
    st.markdown("""
    <div class="stat-card">
        <p class="stat-value" style="font-size:2.5rem;">📖</p>
        <p style="color:#FAFAFA; font-weight:600; margin:6px 0;">Review Notes</p>
        <p class="stat-label">Flashcards, mnemonics, exam traps, and ELI5 explanations</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("Open notes", key="dash_notes_main", use_container_width=True):
        st.switch_page("app_pages/review.py")

with col3:
    st.markdown("""
    <div class="stat-card">
        <p class="stat-value" style="font-size:2.5rem;">🎯</p>
        <p style="color:#FAFAFA; font-weight:600; margin:6px 0;">Exam Strategy</p>
        <p class="stat-label">Time management, edition cheatsheet, partner framework</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("View strategy", key="dash_strategy", use_container_width=True):
        st.switch_page("app_pages/strategy.py")
