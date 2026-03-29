"""
Snowflake PS Platform
Main entry point - multi-page navigation with global styling.
Data is loaded from Snowflake tables via data_layer (falls back to files for local dev).
"""
import streamlit as st
import os

from i18n import language_selector
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
            "colors": {d: info["color"] for d, info in domains.items()},
            "css_num": {d: info["css_num"] for d, info in domains.items()},
            "emojis": {d: info["emoji"] for d, info in domains.items()},
            "weights": {d: info["weight"] for d, info in domains.items()},
        }
        # Add Untagged defaults
        result[key]["colors"]["Untagged"] = "#6B7280"
        result[key]["css_num"]["Untagged"] = "unknown"
        result[key]["emojis"]["Untagged"] = "📋"
    return result

st.set_page_config(
    page_title="Snowflake Certification Study Hub",
    page_icon=":material/school:",
    layout="wide",
)

# ── Global CSS for colored domain cards, badges, and visual elements ──
st.markdown("""
<style>
/* Domain color cards */
.domain-card {
    border-radius: 12px;
    padding: 18px 20px;
    margin-bottom: 12px;
    border-left: 5px solid;
}
.domain-card h3 { margin: 0 0 6px 0; font-size: 1.1rem; }
.domain-card p { margin: 0; opacity: 0.85; font-size: 0.9rem; }

.domain-1 { background: rgba(41,181,232,0.13); border-color: #29B5E8; }
.domain-2 { background: rgba(255,107,107,0.13); border-color: #FF6B6B; }
.domain-3 { background: rgba(78,203,113,0.13); border-color: #4ECB71; }
.domain-4 { background: rgba(255,217,61,0.13); border-color: #FFD93D; }
.domain-5 { background: rgba(192,132,252,0.13); border-color: #C084FC; }

/* Domain badge pills */
.domain-badge {
    display: inline-block;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 600;
    color: #0E1117;
    margin-right: 8px;
}
.badge-d1 { background: #29B5E8; }
.badge-d2 { background: #FF6B6B; }
.badge-d3 { background: #4ECB71; }
.badge-d4 { background: #FFD93D; }
.badge-d5 { background: #C084FC; }
.badge-gray { background: #6B7280; color: #FAFAFA; }

/* Stat cards */
.stat-card {
    background: #1B2332;
    border-radius: 12px;
    padding: 16px 20px;
    text-align: center;
}
.stat-card .stat-value {
    font-size: 2rem;
    font-weight: 700;
    color: #29B5E8;
    margin: 0;
}
.stat-card .stat-label {
    font-size: 0.85rem;
    color: #9CA3AF;
    margin: 4px 0 0 0;
}

/* Flashcard styling */
.flashcard {
    background: #1B2332;
    border-radius: 12px;
    padding: 24px;
    margin: 10px 0;
    border: 1px solid #2D3748;
    cursor: pointer;
    transition: border-color 0.2s;
}
.flashcard:hover { border-color: #29B5E8; }
.flashcard-q { font-weight: 700; font-size: 1rem; color: #FAFAFA; }
.flashcard-a { color: #4ECB71; font-size: 0.95rem; margin-top: 10px; }

/* Colored progress bar replacement */
.color-bar {
    height: 8px;
    border-radius: 4px;
    margin: 6px 0 12px 0;
}

/* Quiz feedback */
.feedback-correct {
    background: rgba(78,203,113,0.15);
    border-left: 4px solid #4ECB71;
    padding: 12px 16px;
    border-radius: 8px;
    margin: 4px 0;
}
.feedback-wrong {
    background: rgba(255,107,107,0.15);
    border-left: 4px solid #FF6B6B;
    padding: 12px 16px;
    border-radius: 8px;
    margin: 4px 0;
}
.feedback-missed {
    background: rgba(255,217,61,0.15);
    border-left: 4px solid #FFD93D;
    padding: 12px 16px;
    border-radius: 8px;
    margin: 4px 0;
}

/* Exam trap callout */
.exam-trap {
    background: rgba(255,107,107,0.1);
    border-left: 4px solid #FF6B6B;
    padding: 10px 14px;
    border-radius: 6px;
    margin: 8px 0;
    font-size: 0.9rem;
}

/* Mnemonic callout */
.mnemonic {
    background: rgba(41,181,232,0.1);
    border-left: 4px solid #29B5E8;
    padding: 10px 14px;
    border-radius: 6px;
    margin: 8px 0;
    font-size: 0.9rem;
}

/* Question domain header bar */
.q-domain-bar {
    padding: 8px 16px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-weight: 600;
    font-size: 0.9rem;
}
.q-domain-bar-1 { background: rgba(41,181,232,0.2); color: #29B5E8; }
.q-domain-bar-2 { background: rgba(255,107,107,0.2); color: #FF6B6B; }
.q-domain-bar-3 { background: rgba(78,203,113,0.2); color: #4ECB71; }
.q-domain-bar-4 { background: rgba(255,217,61,0.2); color: #FFD93D; }
.q-domain-bar-5 { background: rgba(192,132,252,0.2); color: #C084FC; }
.q-domain-bar-unknown { background: rgba(107,114,128,0.2); color: #9CA3AF; }

/* Timeline step */
.timeline-step {
    display: flex;
    align-items: flex-start;
    gap: 14px;
    margin: 12px 0;
}
.timeline-dot {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: #29B5E8;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 0.8rem;
    color: #0E1117;
    flex-shrink: 0;
}
.timeline-content { flex: 1; }
.timeline-content strong { color: #FAFAFA; }
.timeline-content p { color: #9CA3AF; margin: 2px 0 0 0; font-size: 0.9rem; }

/* Edition table colors */
table { border-collapse: collapse; width: 100%; }
th { background: #1B2332 !important; color: #29B5E8 !important; }
td.yes { color: #4ECB71 !important; font-weight: 600; }
td.no { color: #4B5563 !important; }

/* ── Review Notes: white-bg colored sections ── */
.notes-section {
    background: #FAFAFA;
    color: #1a1a2e;
    border-radius: 12px;
    padding: 20px 24px;
    margin: 12px 0;
    border-left: 5px solid;
}
.notes-section h1, .notes-section h2, .notes-section h3 {
    color: #1a1a2e;
}
.notes-section p, .notes-section li, .notes-section td {
    color: #333;
}
.notes-section code { background: #e8e8e8; color: #c7254e; padding: 2px 4px; border-radius: 3px; }

.notes-imp-red { border-color: #FF6B6B; }
.notes-imp-green { border-color: #4ECB71; }
.notes-imp-blue { border-color: #29B5E8; }
.notes-imp-yellow { border-color: #FFD93D; }
.notes-imp-purple { border-color: #C084FC; }

/* Sticky note - base */
.sticky-note {
    color: #333;
    border-radius: 4px 24px 4px 4px;
    padding: 12px 16px;
    margin: 8px 0;
    font-size: 0.9rem;
    box-shadow: 2px 3px 8px rgba(0,0,0,0.12);
    position: relative;
    line-height: 1.5;
    font-family: 'Segoe UI', sans-serif;
}
.sticky-note::before {
    position: absolute;
    top: -10px;
    right: 10px;
    font-size: 0.9rem;
}
/* Post-it colors */
.sticky-yellow { background: #FFF9C4; border-left: 4px solid #F9A825; }
.sticky-yellow::before { content: "pin"; color: #F9A825; }
.sticky-pink { background: #FCE4EC; border-left: 4px solid #E91E63; }
.sticky-pink::before { content: "pin"; color: #E91E63; }
.sticky-blue { background: #E3F2FD; border-left: 4px solid #1565C0; }
.sticky-blue::before { content: "pin"; color: #1565C0; }
.sticky-green { background: #E8F5E9; border-left: 4px solid #2E7D32; }
.sticky-green::before { content: "pin"; color: #2E7D32; }
.sticky-purple { background: #F3E5F5; border-left: 4px solid #7B1FA2; }
.sticky-purple::before { content: "pin"; color: #7B1FA2; }
.sticky-orange { background: #FFF3E0; border-left: 4px solid #E65100; }
.sticky-orange::before { content: "pin"; color: #E65100; }
/* Highlight marker styles */
.mark-yellow { background: #FFF176; padding: 1px 4px; border-radius: 2px; }
.mark-pink { background: #F48FB1; padding: 1px 4px; border-radius: 2px; }
.mark-blue { background: #90CAF9; padding: 1px 4px; border-radius: 2px; }
.mark-green { background: #A5D6A7; padding: 1px 4px; border-radius: 2px; }
</style>
""", unsafe_allow_html=True)


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
cert_key = st.session_state.get("cert_select", "SnowPro Core (COF-C03)")
# Match cert_select string to registry key
active_cert = "core"
for rk, rv in CERT_REGISTRY.items():
    if rv.get("full_name") == cert_key:
        active_cert = rk
        break

# Reload data if cert or language changed
active_lang = st.session_state.get("lang", "en")
cert_changed = st.session_state.get("_active_cert") != active_cert
lang_changed = st.session_state.get("_active_lang") != active_lang

if cert_changed or lang_changed:
    st.session_state.review_notes = load_review_notes(active_cert, active_lang)
    st.session_state._active_lang = active_lang
if cert_changed:
    st.session_state.questions = load_questions(active_cert)
    st.session_state._active_cert = active_cert
    _apply_cert_domains(active_cert)
    # Reset quiz state — old questions belong to previous cert
    st.session_state.quiz_active = False
    st.session_state.quiz_questions = []
    st.session_state.quiz_index = 0
    st.session_state.quiz_answers = {}
    st.session_state.quiz_submitted = {}
    st.session_state.quiz_domain_filter = "All"
    st.session_state.quiz_source_filter = "All"

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
    st.sidebar.markdown("### 🎓 Certification")
    # Build cert options dynamically from registry
    cert_options = []
    for rk, rv in CERT_REGISTRY.items():
        if rv.get("available"):
            cert_options.append(rv["full_name"])
        else:
            cert_options.append(f"{rv['full_name']} (coming soon)")
    selected_cert = st.sidebar.selectbox("Select certification", cert_options, key="cert_select")
    if "coming soon" in selected_cert:
        st.sidebar.info(f"📌 {selected_cert} — materials coming soon.")
    else:
        # Find the matching registry entry for the sidebar card
        sidebar_cert = CERT_REGISTRY.get(active_cert, {})
        exam = sidebar_cert.get("exam", {})
        num_domains = len(sidebar_cert.get("domains", {}))
        st.sidebar.markdown(f"""
        <div style="background:{sidebar_cert.get('sidebar_gradient', 'linear-gradient(135deg,#0E4D71,#0B3D5B)')};border-radius:10px;padding:10px 14px;margin:6px 0;text-align:center;">
            <span style="color:{sidebar_cert.get('sidebar_accent', '#B2EBF2')};font-size:0.8rem;">ACTIVE CERT</span><br>
            <strong style="color:{sidebar_cert.get('sidebar_text', '#E0F7FA')};font-size:1rem;">{sidebar_cert.get('icon', '🎯')} {sidebar_cert.get('name', '')} {sidebar_cert.get('code', '')}</strong><br>
            <span style="color:{sidebar_cert.get('sidebar_sub', '#80DEEA')};font-size:0.75rem;">{exam.get('questions', '')} Qs &bull; {num_domains} domains &bull; {exam.get('cost', '')}</span>
        </div>
        """, unsafe_allow_html=True)

    st.sidebar.markdown("---")
    st.sidebar.markdown("### 🔍 Global Search")
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
            emoji = st.session_state.get("DOMAIN_EMOJIS", {}).get(d, "📋")
            st.sidebar.markdown(f"- {emoji} {short}: **{count}** matches")

        st.sidebar.markdown(f"**Found in questions:** {len(results_qs[:10])} questions")
        for q in results_qs[:5]:
            st.sidebar.caption(f"Q: {q['question'][:80]}...")

# ── Language selector (always visible in sidebar) ──
language_selector()

# ── Build page list (mode-aware) ──
landing = st.Page("app_pages/landing.py", title="Home", icon=":material/home:", default=True)

tool_pages = [
    st.Page("app_pages/assistant.py", title="Study Assistant", icon=":material/smart_toy:"),
    st.Page("app_pages/sandbox.py", title="SQL Sandbox", icon=":material/code:"),
]

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
    st.Page("app_pages/learn_topics.py", title="Topics", visibility="hidden"),
    st.Page("app_pages/learn_detail.py", title="Topic Detail", visibility="hidden"),
]
prep_pages = [
    st.Page("app_pages/project_prep.py", title="Project Preparation", icon=":material/build:"),
]

if app_mode == "certifications":
    nav_config = {
        "": [landing],
        "Certification": cert_pages,
        "Exam Prep": exam_pages,
        "Tools": tool_pages,
        " ": learn_pages + prep_pages,  # hidden
    }
elif app_mode == "project_prep":
    nav_config = {
        "": [landing],
        "Project Prep": prep_pages,
        "Tools": tool_pages,
        " ": cert_pages + exam_pages + learn_pages,  # hidden
    }
elif app_mode == "learn":
    nav_config = {
        "": [landing],
        "Learn": learn_pages,
        "Tools": tool_pages,
        " ": cert_pages + exam_pages + prep_pages,  # hidden
    }
else:
    # Landing mode — show all sections so user can freely navigate
    nav_config = {
        "": [landing],
        "Certification": cert_pages,
        "Exam Prep": exam_pages,
        "Project Prep": prep_pages,
        "Learn": learn_pages,
        "Tools": tool_pages,
    }

page = st.navigation(nav_config, position="sidebar")
page.run()
