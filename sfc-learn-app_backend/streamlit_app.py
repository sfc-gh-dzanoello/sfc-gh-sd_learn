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
# _active_cert is the source of truth (persists across page switches).
active_cert = st.session_state.get("_active_cert", "core")

# If landing page or dashboard set _pending_cert, resolve it to a registry key
pending = st.session_state.pop("_pending_cert", None)
if pending:
    for rk, rv in CERT_REGISTRY.items():
        if rv.get("full_name") == pending:
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

# ── Sidebar: Snowflake logo at top ──
SF_LOGO_SM = '<svg width="32" height="32" viewBox="0 0 48 48" fill="none"><g transform="translate(24,24)"><g fill="#29B5E8"><rect x="-2" y="-21" width="4" height="21" rx="2"/><rect x="-2" y="0" width="4" height="21" rx="2"/><rect x="-2" y="-21" width="4" height="21" rx="2" transform="rotate(60)"/><rect x="-2" y="0" width="4" height="21" rx="2" transform="rotate(60)"/><rect x="-2" y="-21" width="4" height="21" rx="2" transform="rotate(-60)"/><rect x="-2" y="0" width="4" height="21" rx="2" transform="rotate(-60)"/></g><g fill="#29B5E8"><circle cx="0" cy="-21" r="3.2"/><circle cx="0" cy="21" r="3.2"/><circle cx="18.2" cy="-10.5" r="3.2"/><circle cx="-18.2" cy="10.5" r="3.2"/><circle cx="-18.2" cy="-10.5" r="3.2"/><circle cx="18.2" cy="10.5" r="3.2"/></g><circle cx="0" cy="0" r="4" fill="#29B5E8"/></g></svg>'
st.sidebar.markdown(
    f'<div style="text-align:center; padding:10px 0 4px;">'
    f'{SF_LOGO_SM}'
    f'<p style="color:#80DEEA; font-size:0.75rem; margin:4px 0 0;">Study Hub</p>'
    f'</div>', unsafe_allow_html=True)

# ── Language selector ──
language_selector()

# ── Sidebar: search (below navigation) ──
st.sidebar.markdown("---")
global_search = st.sidebar.text_input("Search notes + questions", key="global_search", placeholder="e.g., Time Travel, RBAC...")

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

# ── Build page list (mode-aware) ──
landing = st.Page("app_pages/landing.py", title="Home", icon=":material/home:", default=True)

# All pages that must always be registered for switch_page to work
tracker_pages = [
    st.Page("app_pages/progress.py", title="Score tracker", icon=":material/trending_up:"),
]
cert_pages = [
    st.Page("app_pages/dashboard.py", title="Certification Hub", icon=":material/dashboard:"),
    st.Page("app_pages/quiz.py", title="Quiz mode", icon=":material/quiz:"),
    st.Page("app_pages/review.py", title="Review content", icon=":material/menu_book:"),
    st.Page("app_pages/learn.py", title="My Notes & Cards", icon=":material/edit_note:"),
    st.Page("app_pages/strategy.py", title="Exam strategy", icon=":material/strategy:"),
]
tools_pages = [
    st.Page("app_pages/learn_paths.py", title="Learn Paths", icon=":material/route:"),
    st.Page("app_pages/learn_tracks.py", title="Project Preparation", icon=":material/build:"),
    st.Page("app_pages/sandbox.py", title="SQL Sandbox", icon=":material/code:"),
    st.Page("app_pages/quickstarts.py", title="Quickstarts", icon=":material/rocket_launch:"),
    st.Page("app_pages/assistant.py", title="Study Assistant", icon=":material/smart_toy:"),
]
# Pages navigated programmatically (no visibility param for SiS compatibility)
extra_pages = [
    st.Page("app_pages/learn_topics.py", title="Topics"),
    st.Page("app_pages/learn_detail.py", title="Topic Detail"),
]

if app_mode == "certifications":
    nav_config = {
        "": [landing] + tracker_pages,
        "Certification": cert_pages,
        "Tools": tools_pages,
        " ": extra_pages,
    }
elif app_mode == "project_prep":
    nav_config = {
        "": [landing] + tracker_pages,
        "Tools": tools_pages,
        " ": cert_pages + extra_pages,
    }
elif app_mode == "learn":
    nav_config = {
        "": [landing] + tracker_pages,
        "Tools": tools_pages,
        " ": cert_pages + extra_pages,
    }
else:
    # Landing mode — show all sections so user can freely navigate
    nav_config = {
        "": [landing] + tracker_pages,
        "Certification": cert_pages,
        "Tools": tools_pages,
        " ": extra_pages,
    }

page = st.navigation(nav_config, position="sidebar")
page.run()
