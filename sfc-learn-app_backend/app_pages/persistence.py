"""Persistence helper — stores user data in Snowflake (SiS) or local JSON (dev).

In Streamlit-in-Snowflake: data goes to a USER_APP_DATA table (per-user, persists across sessions).
Locally: falls back to JSON files on disk (same behavior as before).
"""
import json
import os
import streamlit as st

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Detect SiS
try:
    from snowflake.snowpark.context import get_active_session
    get_active_session()
    _IN_SIS = True
except Exception:
    _IN_SIS = False

# Local file paths (fallback)
_LOCAL_FILES = {
    "study_progress": os.path.join(BASE, "study_progress.json"),
    "learn_progress": os.path.join(BASE, "learn_progress.json"),
    "user_notes": os.path.join(BASE, "user_notes_data.json"),
    "learn_custom_topics": os.path.join(BASE, "learn_topics.json"),
}

# Default empty values
_DEFAULTS = {
    "study_progress": {"quiz_score_history": [], "question_history": {}},
    "learn_progress": {},
    "user_notes": {"comments": {}, "highlights": []},
    "learn_custom_topics": {},
}

_TABLE = "USER_APP_DATA"
_TABLE_ENSURED = False


def _ensure_table():
    """Create the storage table if it doesn't exist (SiS only). Runs once per session."""
    global _TABLE_ENSURED
    if _TABLE_ENSURED:
        return
    try:
        session = get_active_session()
        session.sql(f"""
            CREATE TABLE IF NOT EXISTS {_TABLE} (
                USER_NAME VARCHAR DEFAULT CURRENT_USER(),
                DATA_KEY VARCHAR,
                DATA_VALUE VARIANT,
                UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
                PRIMARY KEY (USER_NAME, DATA_KEY)
            )
        """).collect()
        _TABLE_ENSURED = True
    except Exception as e:
        st.warning(f"Could not create storage table: {e}")


def _load_from_snowflake(key):
    """Load a JSON blob from Snowflake by key for the current user."""
    _ensure_table()
    try:
        session = get_active_session()
        rows = session.sql(f"""
            SELECT DATA_VALUE
            FROM {_TABLE}
            WHERE USER_NAME = CURRENT_USER() AND DATA_KEY = ?
        """, params=[key]).collect()
        if rows:
            raw = rows[0]["DATA_VALUE"]
            if isinstance(raw, str):
                return json.loads(raw)
            return raw
    except Exception:
        pass
    return None


def _save_to_snowflake(key, data):
    """Save a JSON blob to Snowflake for the current user."""
    _ensure_table()
    try:
        session = get_active_session()
        json_str = json.dumps(data)
        session.sql(f"""
            MERGE INTO {_TABLE} AS t
            USING (SELECT CURRENT_USER() AS USER_NAME, ? AS DATA_KEY) AS s
            ON t.USER_NAME = s.USER_NAME AND t.DATA_KEY = s.DATA_KEY
            WHEN MATCHED THEN UPDATE SET
                DATA_VALUE = PARSE_JSON(?),
                UPDATED_AT = CURRENT_TIMESTAMP()
            WHEN NOT MATCHED THEN INSERT (USER_NAME, DATA_KEY, DATA_VALUE, UPDATED_AT)
                VALUES (CURRENT_USER(), ?, PARSE_JSON(?), CURRENT_TIMESTAMP())
        """, params=[key, json_str, key, json_str]).collect()
    except Exception as e:
        st.warning(f"Could not save data: {e}")


def _load_from_file(key):
    """Load from local JSON file."""
    fp = _LOCAL_FILES.get(key)
    if fp and os.path.exists(fp):
        with open(fp, "r") as f:
            return json.load(f)
    return None


def _save_to_file(key, data):
    """Save to local JSON file."""
    fp = _LOCAL_FILES.get(key)
    if fp:
        with open(fp, "w") as f:
            json.dump(data, f, indent=2)


# ── Public API ──

def load_data(key):
    """Load user data by key. Returns default if not found."""
    if _IN_SIS:
        result = _load_from_snowflake(key)
    else:
        result = _load_from_file(key)
    return result if result is not None else _DEFAULTS.get(key, {}).copy()


def save_data(key, data):
    """Save user data by key."""
    if _IN_SIS:
        _save_to_snowflake(key, data)
    else:
        _save_to_file(key, data)


# ── Convenience wrappers (match the old function signatures) ──

def load_study_progress():
    return load_data("study_progress")

def save_study_progress(data):
    save_data("study_progress", data)

def load_learn_progress():
    return load_data("learn_progress")

def save_learn_progress(data):
    save_data("learn_progress", data)

def load_user_notes():
    return load_data("user_notes")

def save_user_notes(data):
    save_data("user_notes", data)

def load_custom_topics():
    return load_data("learn_custom_topics")

def save_custom_topics(data):
    save_data("learn_custom_topics", data)
