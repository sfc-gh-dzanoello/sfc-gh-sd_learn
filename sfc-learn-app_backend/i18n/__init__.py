"""i18n -- Internationalization helper for the Snowflake PS Platform."""
import json
import os
import streamlit as st

_BASE = os.path.dirname(os.path.abspath(__file__))
_STRINGS_FILE = os.path.join(_BASE, "strings.json")

# Supported languages
LANGUAGES = {"en": "English", "pt": "Portugues", "es": "Espanol"}

# Module-level cache
_strings_cache = None


def _load_strings():
    """Load UI strings from Snowflake (SiS) or local file."""
    global _strings_cache
    if _strings_cache is not None:
        return _strings_cache

    # Try loading from data_layer (works in SiS and local)
    try:
        from app_pages.data_layer import get_i18n_strings, _IN_SIS
        if _IN_SIS:
            _strings_cache = get_i18n_strings()
            if _strings_cache:
                return _strings_cache
    except ImportError:
        pass

    # Fallback: load from local strings.json
    if os.path.exists(_STRINGS_FILE):
        with open(_STRINGS_FILE, "r", encoding="utf-8") as f:
            _strings_cache = json.load(f)
    else:
        _strings_cache = {}

    return _strings_cache


def t(key):
    """Get translated UI string by key. Falls back to English, then to the key itself."""
    lang = st.session_state.get("lang", "en")
    strings = _load_strings()
    entry = strings.get(key, {})
    if isinstance(entry, dict):
        return entry.get(lang, entry.get("en", key))
    return entry if entry else key


def get_text(value, lang=None):
    """Handle both plain strings (old format) and {en/pt/es} dicts (new format).
    Falls back to English if the requested language is missing."""
    if lang is None:
        lang = st.session_state.get("lang", "en")
    if isinstance(value, dict):
        return value.get(lang, value.get("en", ""))
    return value if value else ""


def language_selector():
    """Render a language selector in the sidebar."""
    st.sidebar.markdown("### Language")
    lang_keys = list(LANGUAGES.keys())
    lang_labels = list(LANGUAGES.values())
    current = st.session_state.get("lang", "en")
    current_idx = lang_keys.index(current) if current in lang_keys else 0
    selected = st.sidebar.selectbox(
        "Language",
        lang_keys,
        index=current_idx,
        format_func=lambda k: LANGUAGES[k],
        key="_lang_selector",
        label_visibility="collapsed",
    )
    if selected != st.session_state.get("lang"):
        st.session_state.lang = selected
        st.rerun()
