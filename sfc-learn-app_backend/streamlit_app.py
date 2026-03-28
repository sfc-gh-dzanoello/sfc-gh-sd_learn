"""
Snowflake PS Platform
Main entry point - multi-page navigation with global styling.
Data is loaded from Snowflake tables via data_layer (falls back to files for local dev).
"""
import streamlit as st
import os

from i18n import language_selector
from theme import T
from app_pages.data_layer import get_cert_registry, get_questions, get_review_notes

BASE = os.path.dirname(os.path.abspath(__file__))


# ── Registry-driven certification config ──
def load_cert_registry():
    """Load certification definitions from Snowflake tables (or files for local dev)."""
    return get_cert_registry()


def _build_cert_domains(registry):
    """Build CERT_DOMAINS dict dynamically from registry (backwards-compatible)."""
    result = {}
    for key, cert in registry.items():
        if not cert.get("domains"):
            continue
        domains = cert["domains"]
        result[key] = {
            "colors": {d: info.get("color", "#6B7280") for d, info in domains.items()},
            "css_num": {d: info.get("css_num", "unknown") for d, info in domains.items()},
            "emojis": {d: info.get("emoji", "") for d, info in domains.items()},
            "weights": {d: info.get("weight", "") for d, info in domains.items()},
        }
        # Add Untagged defaults
        result[key]["colors"]["Untagged"] = "#6B7280"
        result[key]["css_num"]["Untagged"] = "unknown"
        result[key]["emojis"]["Untagged"] = ""
    return result

st.set_page_config(
    page_title="Snowflake Certification Study Hub",
    page_icon=":material/school:",
    layout="wide",
)

# ── Global CSS (generated from theme.py -- edit colors there) ──
st.markdown(T.css(), unsafe_allow_html=True)


# ── Shared constants (built dynamically from registry) ──
CERT_REGISTRY = load_cert_registry()
CERT_DOMAINS = _build_cert_domains(CERT_REGISTRY)
# Make registry available to all pages via session state
st.session_state["CERT_REGISTRY"] = CERT_REGISTRY


def _apply_cert_domains(cert):
    """Replace domain dicts completely for the active certification."""
    d = CERT_DOMAINS.get(cert, CERT_DOMAINS["core"])
    st.session_state["DOMAIN_COLORS"] = d["colors"]
    st.session_state["DOMAIN_CSS_NUM"] = d["css_num"]
    st.session_state["DOMAIN_EMOJIS"] = d["emojis"]
    st.session_state["DOMAIN_WEIGHTS"] = d["weights"]


# ── Progress persistence ──
from app_pages.persistence import load_study_progress, save_study_progress

def load_progress():
    return load_study_progress()


def save_progress():
    data = {
        "quiz_score_history": st.session_state.get("quiz_score_history", []),
        "question_history": st.session_state.get("question_history", {}),
    }
    save_study_progress(data)


def load_questions(cert="core"):
    """Load questions from Snowflake tables (or files for local dev)."""
    return get_questions(cert)


def load_review_notes(cert="core", lang="en"):
    """Load review notes from Snowflake tables (or files for local dev)."""
    return get_review_notes(cert, lang)


# Load data into session state
# Determine active certification from registry
# _active_cert is the source of truth (persists even when selectbox doesn't render).
# cert_select is a widget key that Streamlit purges when the selectbox doesn't render
# (e.g., when app_mode != "certifications"), so we must NOT rely on it for data loading.
active_cert = st.session_state.get("_active_cert", "core")

# If landing page set _pending_cert, resolve it to a registry key
# and seed cert_select so the sidebar selectbox will show the right value.
pending = st.session_state.pop("_pending_cert", None)
if pending:
    for rk, rv in CERT_REGISTRY.items():
        if rv.get("full_name") == pending:
            active_cert = rk
            break
    # Pre-seed cert_select BEFORE the widget renders (safe at this point)
    st.session_state.cert_select = pending

# If cert_select was changed via the sidebar selectbox, resolve it
cert_key = st.session_state.get("cert_select")
if cert_key:
    for rk, rv in CERT_REGISTRY.items():
        if rv.get("full_name") == cert_key:
            active_cert = rk
            break

# Reload data if cert or language changed
active_lang = st.session_state.get("lang", "en")
cert_changed = st.session_state.get("_active_cert") != active_cert
lang_changed = st.session_state.get("_active_lang") != active_lang

if cert_changed:
    # Clear all cached data FIRST to ensure fresh reads for new cert
    st.cache_data.clear()
if cert_changed or lang_changed:
    st.session_state.review_notes = load_review_notes(active_cert, active_lang)
    st.session_state._active_lang = active_lang
if cert_changed:
    st.session_state.questions = load_questions(active_cert)
    st.session_state._active_cert = active_cert
    _apply_cert_domains(active_cert)
    # Reset quiz state -- old questions belong to previous cert
    st.session_state.quiz_active = False
    st.session_state.quiz_questions = []
    st.session_state.quiz_index = 0
    st.session_state.quiz_answers = {}
    st.session_state.quiz_submitted = {}
    st.session_state.quiz_domain_filter = "All"
    st.session_state.quiz_source_filter = "All"
    # Reset page-level state so pages reload for new cert
    st.session_state.pop("review_selected", None)
    st.session_state.pop("quiz_highlights_loaded", None)
    st.session_state.pop("user_data_loaded", None)
    # Force a clean re-render so all pages see the new data
    st.rerun()

if "questions" not in st.session_state:
    st.session_state.questions = load_questions(active_cert)

if "review_notes" not in st.session_state:
    st.session_state.review_notes = load_review_notes(active_cert, active_lang)

# Ensure domain dicts are always set (first load or page refresh)
if "DOMAIN_COLORS" not in st.session_state:
    _apply_cert_domains(active_cert)

# Load saved progress from disk
if "progress_loaded" not in st.session_state:
    saved = load_progress()
    st.session_state.quiz_score_history = saved.get("quiz_score_history", [])
    st.session_state.question_history = saved.get("question_history", {})
    st.session_state.progress_loaded = True

# Quiz state defaults
st.session_state.setdefault("quiz_active", False)
st.session_state.setdefault("quiz_questions", [])
st.session_state.setdefault("quiz_index", 0)
st.session_state.setdefault("quiz_answers", {})
st.session_state.setdefault("quiz_submitted", {})
st.session_state.setdefault("quiz_score_history", [])
st.session_state.setdefault("question_history", {})
st.session_state.setdefault("quiz_domain_filter", "All")
st.session_state.setdefault("quiz_source_filter", "All")
st.session_state.setdefault("quiz_size", 25)
# Sticky notes state
st.session_state.setdefault("sticky_notes", {})

# Make save_progress accessible
st.session_state["_save_progress"] = save_progress

# ── Determine app mode ──
app_mode = st.session_state.get("app_mode", "landing")

# ── Sidebar: cert selector + search (only in certification mode) ──
if app_mode == "certifications":
    st.sidebar.markdown("---")
    st.sidebar.markdown("### Certification")
    # Build cert options dynamically from registry
    cert_options = []
    for rk, rv in CERT_REGISTRY.items():
        if rv.get("available"):
            cert_options.append(rv["full_name"])
        else:
            cert_options.append(f"{rv['full_name']} (coming soon)")
    # Pre-sync: if cert_select was purged (widget didn't render last run),
    # restore it from _active_cert so the selectbox shows the right value
    if "cert_select" not in st.session_state:
        cert_info = CERT_REGISTRY.get(active_cert, {})
        st.session_state.cert_select = cert_info.get("full_name", "SnowPro Core (COF-C03)")
    selected_cert = st.sidebar.selectbox("Select certification", cert_options, key="cert_select")
    if "coming soon" in selected_cert:
        st.sidebar.info(f"{selected_cert} -- materials coming soon.")
    else:
        # Find the matching registry entry for the sidebar card
        sidebar_cert = CERT_REGISTRY.get(active_cert, {})
        exam = sidebar_cert.get("exam", {})
        num_domains = len(sidebar_cert.get("domains", {}))
        st.sidebar.markdown(
        f'<div style="background:{sidebar_cert.get("sidebar_gradient", "linear-gradient(135deg,#0E4D71,#0B3D5B)")};border-radius:10px;padding:10px 14px;margin:6px 0;text-align:center;">'
        f'<span style="color:{sidebar_cert.get("sidebar_accent", "#B2EBF2")};font-size:0.8rem;">ACTIVE CERT</span><br>'
        f'<strong style="color:{sidebar_cert.get("sidebar_text", "#E0F7FA")};font-size:1rem;">{sidebar_cert.get("name", "")} {sidebar_cert.get("code", "")}</strong><br>'
        f'<span style="color:{sidebar_cert.get("sidebar_sub", "#80DEEA")};font-size:0.75rem;">{exam.get("questions", "")} Qs &bull; {num_domains} domains &bull; {exam.get("cost", "")}</span>'
        '</div>', unsafe_allow_html=True)

    st.sidebar.markdown("---")
    st.sidebar.markdown("### Global Search")
    global_search = st.sidebar.text_input("Search all notes + questions", key="global_search", placeholder="e.g., Time Travel, RBAC...")

    if global_search:
        results_notes = []
        for d, content in st.session_state.get("review_notes", {}).items():
            if global_search.lower() in content.lower():
                count = content.lower().count(global_search.lower())
                results_notes.append((d, count))

        results_qs = []
        for q in st.session_state.get("questions", []):
            if global_search.lower() in q["question"].lower():
                results_qs.append(q)

        st.sidebar.markdown(f"**Found in notes:** {len(results_notes)} domains")
        for d, count in sorted(results_notes, key=lambda x: -x[1]):
            short = d.split(": ")[1] if ": " in d else d
            emoji = st.session_state.get("DOMAIN_EMOJIS", {}).get(d, "")
            st.sidebar.markdown(f"- {emoji} {short}: **{count}** matches")

        st.sidebar.markdown(f"**Found in questions:** {len(results_qs[:10])} questions")
        for q in results_qs[:5]:
            st.sidebar.caption(f"Q: {q['question'][:80]}...")

# ── Language selector (always visible in sidebar) ──
language_selector()

# ── Build page list (mode-aware) ──
landing = st.Page("app_pages/landing.py", title="Home", icon=":material/home:", default=True)

# All pages that must always be registered for switch_page to work
cert_pages = [
    st.Page("app_pages/dashboard.py", title="Dashboard", icon=":material/dashboard:"),
    st.Page("app_pages/quiz.py", title="Quiz mode", icon=":material/quiz:"),
    st.Page("app_pages/review.py", title="Review notes", icon=":material/menu_book:"),
    st.Page("app_pages/learn.py", title="My Notes & Cards", icon=":material/edit_note:"),
]
exam_pages = [
    st.Page("app_pages/strategy.py", title="Exam strategy", icon=":material/strategy:"),
    st.Page("app_pages/exam_day.py", title="EXAM DAY", icon=":material/emergency:"),
    st.Page("app_pages/progress.py", title="Score tracker", icon=":material/trending_up:"),
]
learn_pages = [
    st.Page("app_pages/learn_tracks.py", title="Learning Tracks", icon=":material/school:"),
    st.Page("app_pages/assistant.py", title="Study Assistant", icon=":material/smart_toy:"),
    st.Page("app_pages/sandbox.py", title="SQL Sandbox", icon=":material/code:"),
    st.Page("app_pages/project_prep.py", title="Project Preparation", icon=":material/build:"),
]
# Hidden pages (navigated programmatically, not shown in sidebar)
hidden_pages = [
    st.Page("app_pages/learn_topics.py", title="Topics", visibility="hidden"),
    st.Page("app_pages/learn_detail.py", title="Topic Detail", visibility="hidden"),
]

if app_mode == "certifications":
    nav_config = {
        "": [landing],
        "Certification": cert_pages,
        "Exam Prep": exam_pages,
        "Learn": learn_pages,
        " ": hidden_pages,
    }
elif app_mode == "project_prep":
    nav_config = {
        "": [landing],
        "Learn": learn_pages,
        " ": cert_pages + exam_pages + hidden_pages,
    }
elif app_mode == "learn":
    nav_config = {
        "": [landing],
        "Learn": learn_pages,
        " ": cert_pages + exam_pages + hidden_pages,
    }
else:
    # Landing mode — show all sections so user can freely navigate
    nav_config = {
        "": [landing],
        "Certification": cert_pages,
        "Exam Prep": exam_pages,
        "Learn": learn_pages,
    }

page = st.navigation(nav_config, position="sidebar")
page.run()
