"""Data access layer -- reads all app data from Snowflake tables.

Replaces all file-based reads (JSON, markdown) with session.sql() queries.
Every function is cached with @st.cache_data for performance.
Falls back to file-based reads when not running in SiS (local dev).
"""
import json
import os
import streamlit as st

# Detect SiS environment (import alone is not enough -- snowpark may be
# installed locally without an active session)
try:
    from snowflake.snowpark.context import get_active_session
    get_active_session()
    _IN_SIS = True
except Exception:
    _IN_SIS = False

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# Registry paths already include "certifications/" prefix, so base is the app root
CONTENT_BASE = BASE


def _session():
    """Get Snowpark session (SiS only)."""
    return get_active_session()


# =====================================================================
# CERT REGISTRY
# =====================================================================

@st.cache_data(ttl=600)
def get_cert_registry():
    """Load all certifications as a dict keyed by cert_key.
    Returns the same shape as the old registry.json for backwards compatibility."""
    if not _IN_SIS:
        return _file_cert_registry()

    session = _session()
    rows = session.sql("""
        SELECT r.CERT_KEY, r.NAME, r.CODE, r.FULL_NAME, r.CATEGORY, r.COLOR,
               r.SIDEBAR_GRADIENT, r.SIDEBAR_ACCENT, r.SIDEBAR_TEXT, r.SIDEBAR_SUB,
               r.DIFFICULTY, r.AVAILABLE, r.EXAM_INFO, r.DISPLAY_INFO, r.QUESTIONS_FILE
        FROM CERT_REGISTRY r
        ORDER BY r.CERT_KEY
    """).collect()

    domain_rows = session.sql("""
        SELECT CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER
        FROM CERT_DOMAINS ORDER BY CERT_KEY, SORT_ORDER
    """).collect()

    tip_rows = session.sql("""
        SELECT CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT
        FROM CERT_DOMAIN_TIPS ORDER BY CERT_KEY, DOMAIN_NAME, TIP_ORDER
    """).collect()

    # Build domains lookup
    domains_by_cert = {}
    for dr in domain_rows:
        ck = dr["CERT_KEY"]
        domains_by_cert.setdefault(ck, {})[dr["DOMAIN_NAME"]] = {
            "dir": dr["DOMAIN_DIR"] or "",
            "color": dr["COLOR"] or "#6B7280",
            "css_num": dr["CSS_NUM"] or "1",
            "weight": dr["WEIGHT"] or "",
        }

    # Build tips lookup
    tips_by_cert = {}
    for tr in tip_rows:
        ck = tr["CERT_KEY"]
        dn = tr["DOMAIN_NAME"]
        tips_by_cert.setdefault(ck, {}).setdefault(dn, []).append(tr["TIP_TEXT"])

    registry = {}
    for r in rows:
        ck = r["CERT_KEY"]
        exam = r["EXAM_INFO"]
        if isinstance(exam, str):
            exam = json.loads(exam)
        info = r["DISPLAY_INFO"]
        if isinstance(info, str):
            info = json.loads(info)

        registry[ck] = {
            "name": r["NAME"],
            "code": r["CODE"],
            "full_name": r["FULL_NAME"],
            "category": r["CATEGORY"],
            "color": r["COLOR"],
            "sidebar_gradient": r["SIDEBAR_GRADIENT"],
            "sidebar_accent": r["SIDEBAR_ACCENT"],
            "sidebar_text": r["SIDEBAR_TEXT"],
            "sidebar_sub": r["SIDEBAR_SUB"],
            "difficulty": r["DIFFICULTY"],
            "available": r["AVAILABLE"],
            "exam": exam or {},
            "info": info or {},
            "questions_file": r["QUESTIONS_FILE"],
            "domains": domains_by_cert.get(ck, {}),
            "domain_tips": tips_by_cert.get(ck, {}),
        }
    return registry


def _file_cert_registry():
    """Fallback: load from registry.json for local dev."""
    fp = os.path.join(BASE, "registry.json")
    if os.path.exists(fp):
        with open(fp, "r", encoding="utf-8") as f:
            return json.load(f).get("certifications", {})
    return {}


# =====================================================================
# QUESTIONS
# =====================================================================

@st.cache_data(ttl=600)
def get_questions(cert_key="core"):
    """Load all questions for a certification."""
    if not _IN_SIS:
        return _file_questions(cert_key)

    session = _session()
    rows = session.sql("""
        SELECT QUESTION_ID, SOURCE, DOMAIN, QUESTION_TEXT, OPTIONS,
               CORRECT_INDICES, EXPLANATION, DIFFICULTY
        FROM CERT_QUESTIONS
        WHERE CERT_KEY = ?
        ORDER BY QUESTION_ID
    """, params=[cert_key]).collect()

    questions = []
    for r in rows:
        options = r["OPTIONS"]
        if isinstance(options, str):
            options = json.loads(options)
        correct = r["CORRECT_INDICES"]
        if isinstance(correct, str):
            correct = json.loads(correct)
        correct = correct or []
        is_multi = len(correct) > 1
        questions.append({
            "id": r["QUESTION_ID"],
            "source": r["SOURCE"],
            "question_num": r["QUESTION_ID"],
            "domain": r["DOMAIN"],
            "domain_raw": r["DOMAIN"],
            "question": r["QUESTION_TEXT"],
            "options": options or [],
            "correct_indices": correct,
            "multi_select": is_multi,
            "multi_select_count": len(correct) if is_multi else None,
            "overall_explanation": r["EXPLANATION"] or "",
            "explanation": r["EXPLANATION"] or "",
            "difficulty": r["DIFFICULTY"],
        })
    return questions


def _file_questions(cert_key):
    """Fallback: load from question JSON files."""
    registry = _file_cert_registry()
    cert_info = registry.get(cert_key, registry.get("core", {}))
    qfile = cert_info.get("questions_file")
    if not qfile:
        return []
    fp = os.path.join(CONTENT_BASE, qfile)
    if os.path.exists(fp):
        with open(fp, "r", encoding="utf-8") as f:
            return json.load(f)
    return []


# =====================================================================
# REVIEW NOTES
# =====================================================================

@st.cache_data(ttl=600)
def get_review_notes(cert_key="core", lang="en"):
    """Load review notes for all domains of a cert. Returns {domain_name: markdown_content}."""
    if not _IN_SIS:
        return _file_review_notes(cert_key, lang)

    session = _session()
    rows = session.sql("""
        SELECT DOMAIN_NAME, CONTENT
        FROM CERT_REVIEW_NOTES
        WHERE CERT_KEY = ? AND LANG = ?
        ORDER BY DOMAIN_NAME
    """, params=[cert_key, lang]).collect()

    # Fallback to English if nothing found
    if not rows and lang != "en":
        rows = session.sql("""
            SELECT DOMAIN_NAME, CONTENT
            FROM CERT_REVIEW_NOTES
            WHERE CERT_KEY = ? AND LANG = 'en'
            ORDER BY DOMAIN_NAME
        """, params=[cert_key]).collect()

    return {r["DOMAIN_NAME"]: r["CONTENT"] for r in rows}


def _file_review_notes(cert_key, lang):
    """Fallback: load from .md files for local dev."""
    registry = _file_cert_registry()
    cert_info = registry.get(cert_key, registry.get("core", {}))
    notes = {}
    for domain, info in cert_info.get("domains", {}).items():
        dirname = info.get("dir", "")
        filepath = os.path.join(CONTENT_BASE, dirname, f"review_notes_{lang}.md")
        if not os.path.exists(filepath):
            filepath = os.path.join(CONTENT_BASE, dirname, "review_notes_en.md")
        if os.path.exists(filepath):
            with open(filepath, "r", encoding="utf-8") as f:
                notes[domain] = f.read()
    return notes


# =====================================================================
# I18N STRINGS
# =====================================================================

@st.cache_data(ttl=3600)
def get_i18n_strings():
    """Load all i18n strings. Returns {key: {en, pt, es}}.
    Always reads from strings.json (deployed with the app via Git).
    """
    return _file_i18n_strings()


def _file_i18n_strings():
    """Fallback: load from strings.json."""
    fp = os.path.join(BASE, "i18n", "strings.json")
    if os.path.exists(fp):
        with open(fp, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


# =====================================================================
# LEARNING TRACKS
# =====================================================================

@st.cache_data(ttl=600)
def get_tracks():
    """Load all learning tracks. Returns same shape as tracks.json."""
    if not _IN_SIS:
        return _file_tracks()

    session = _session()
    rows = session.sql("SELECT * FROM LEARN_TRACKS ORDER BY TRACK_KEY").collect()
    tracks = {}
    for r in rows:
        name = r["NAME"]
        if isinstance(name, str):
            name = json.loads(name)
        desc = r["DESCRIPTION"]
        if isinstance(desc, str):
            desc = json.loads(desc)
        topics = r["TOPICS"]
        if isinstance(topics, str):
            topics = json.loads(topics)
        tracks[r["TRACK_KEY"]] = {
            "name": name or {},
            "description": desc or {},
            "color": r["COLOR"],
            "emoji": r["EMOJI"],
            "difficulty": r["DIFFICULTY"],
            "topics": topics or [],
        }
    return tracks


def _file_tracks():
    """Fallback: load from labs/tracks.json."""
    fp = os.path.join(BASE, "labs", "tracks.json")
    if os.path.exists(fp):
        with open(fp, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


@st.cache_data(ttl=600)
def get_topic_content(track_key, topic_key):
    """Load a single topic's full content (notes, questions, labs, flashcards)."""
    if not _IN_SIS:
        return _file_topic_content(track_key, topic_key)

    session = _session()
    rows = session.sql("""
        SELECT TOPIC_DATA FROM LEARN_CONTENT
        WHERE TRACK_KEY = ? AND TOPIC_KEY = ?
    """, params=[track_key, topic_key]).collect()
    if rows:
        data = rows[0]["TOPIC_DATA"]
        if isinstance(data, str):
            return json.loads(data)
        return data
    return None


def _file_topic_content(track_key, topic_key):
    """Fallback: load from content JSON files."""
    # Try CONTENT_BASE first (sfc-gh-sd-paths), then BASE (backend)
    for base in [CONTENT_BASE, BASE]:
        fp = os.path.join(base, "labs", track_key, f"{topic_key}.json")
        if os.path.exists(fp):
            with open(fp, "r", encoding="utf-8") as f:
                return json.load(f)
    return None


# =====================================================================
# APP CONTENT (misc standalone content)
# =====================================================================

@st.cache_data(ttl=3600)
def get_app_content(content_key, lang="en"):
    """Load standalone content (e.g. exam strategy doc)."""
    if not _IN_SIS:
        return _file_app_content(content_key, lang)

    session = _session()
    rows = session.sql("""
        SELECT CONTENT FROM APP_CONTENT
        WHERE CONTENT_KEY = ? AND LANG = ?
    """, params=[content_key, lang]).collect()
    if rows:
        return rows[0]["CONTENT"]
    return ""


def _file_app_content(content_key, lang):
    """Fallback: load from known file paths."""
    known_paths = {
        "exam_strategy_partners": os.path.join(BASE, "certifications", "exam_strategy_partners.md"),
    }
    fp = known_paths.get(content_key, "")
    if fp and os.path.exists(fp):
        with open(fp, "r", encoding="utf-8") as f:
            return f.read()
    return ""
