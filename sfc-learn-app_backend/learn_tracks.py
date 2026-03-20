"""Learn — Track selector: choose your role-based learning path."""
import streamlit as st
import json
import os
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE not in sys.path:
    sys.path.insert(0, BASE)

from i18n import t, get_text

LABS_DIR = os.path.join(BASE, "labs")

from app_pages.persistence import load_learn_progress

DIFFICULTY_COLORS = {
    "beginner": "#4ECB71",
    "intermediate": "#FFD93D",
    "advanced": "#FF6B6B",
    "expert": "#C084FC",
}


def load_tracks():
    fp = os.path.join(LABS_DIR, "tracks.json")
    if os.path.exists(fp):
        with open(fp, "r") as f:
            return json.load(f)
    return {}


def load_progress():
    return load_learn_progress()


def count_topic_content(track_key, topic_key):
    """Count notes/questions/labs/flashcards for a topic."""
    fp = os.path.join(LABS_DIR, track_key, f"{topic_key}.json")
    if not os.path.exists(fp):
        return {"notes": False, "questions": 0, "labs": 0, "flashcards": 0}
    with open(fp, "r") as f:
        data = json.load(f)
    notes_text = get_text(data.get("notes", ""), "en")
    return {
        "notes": bool(notes_text.strip()),
        "questions": len(data.get("questions", [])),
        "labs": len(data.get("labs", [])),
        "flashcards": len(data.get("flashcards", [])),
    }


# ── Sidebar ──
st.sidebar.markdown("---")
if st.sidebar.button(f"🏠 {t('home')}", use_container_width=True):
    st.session_state.app_mode = None
    st.switch_page("app_pages/landing.py")

# ── Connection status ──
try:
    from app_pages.sf_connection import connection_status_widget
    connection_status_widget()
except ImportError:
    pass

# ── Load data ──
tracks = load_tracks()
progress = load_progress()
lang = st.session_state.get("lang", "en")

# ── Header ──
st.markdown(f"""
<h1 style="margin-bottom:4px;">🧪 {t('learn')}</h1>
<p style="color:#9CA3AF; font-size:1rem; margin-top:0;">{t('learn_desc')}</p>
""", unsafe_allow_html=True)

st.markdown("<br>", unsafe_allow_html=True)

# ── Track cards ──
if not tracks:
    st.warning("No tracks found. Check labs/tracks.json exists.")
    st.stop()

cols = st.columns(len(tracks), gap="large")

for col, (track_key, track) in zip(cols, tracks.items()):
    name = get_text(track["name"], lang)
    desc = get_text(track["description"], lang)
    color = track["color"]
    emoji = track["emoji"]
    difficulty = track.get("difficulty", "intermediate")
    diff_color = DIFFICULTY_COLORS.get(difficulty, "#9CA3AF")
    diff_label = t(f"difficulty_{difficulty}")
    topic_keys = track.get("topics", [])

    # Count content across all topics in this track
    total_labs = 0
    total_questions = 0
    total_flashcards = 0
    topics_with_notes = 0
    for tk in topic_keys:
        counts = count_topic_content(track_key, tk)
        total_labs += counts["labs"]
        total_questions += counts["questions"]
        total_flashcards += counts["flashcards"]
        if counts["notes"]:
            topics_with_notes += 1

    # Track progress
    track_progress = progress.get(track_key, {})
    completed_labs = sum(
        1 for tk in topic_keys
        for lab_id, lab_data in track_progress.get(tk, {}).get("labs", {}).items()
        if lab_data.get("completed", False)
    )

    with col:
        st.markdown(f"""
        <div style="background:linear-gradient(135deg, {color}15, {color}08);
                    border:2px solid {color}; border-radius:16px; padding:24px;
                    text-align:center; min-height:350px;">
            <p style="font-size:3rem; margin:0;">{emoji}</p>
            <h2 style="color:{color}; margin:10px 0 4px; font-size:1.4rem;">{name}</h2>
            <span style="background:{diff_color}22; color:{diff_color}; padding:2px 10px;
                        border-radius:10px; font-size:0.75rem; font-weight:600;">{diff_label}</span>
            <p style="color:#9CA3AF; font-size:0.9rem; margin:12px 0;">{desc}</p>
            <div style="display:flex; gap:6px; justify-content:center; flex-wrap:wrap; margin:12px 0;">
                <span style="background:#1B2332; padding:4px 10px; border-radius:8px;
                            font-size:0.8rem; color:#9CA3AF;">
                    📚 {len(topic_keys)} {t('topics')}
                </span>
                <span style="background:#1B2332; padding:4px 10px; border-radius:8px;
                            font-size:0.8rem; color:#9CA3AF;">
                    🧪 {total_labs} {t('labs')}
                </span>
                <span style="background:#1B2332; padding:4px 10px; border-radius:8px;
                            font-size:0.8rem; color:#9CA3AF;">
                    🧠 {total_questions} {t('questions')}
                </span>
            </div>
        </div>
        """, unsafe_allow_html=True)

        if st.button(f"{emoji} {t('enter')} {name}", key=f"track_{track_key}",
                     use_container_width=True, type="primary"):
            st.session_state.learn_track = track_key
            st.switch_page("app_pages/learn_topics.py")

st.markdown("<br>", unsafe_allow_html=True)

# ── Overall progress summary ──
st.markdown(f"### 📊 {t('progress')}")

total_all_labs = 0
completed_all_labs = 0
for track_key, track in tracks.items():
    for tk in track.get("topics", []):
        counts = count_topic_content(track_key, tk)
        total_all_labs += counts["labs"]
        track_prog = progress.get(track_key, {})
        completed_all_labs += sum(
            1 for lab_id, lab_data in track_prog.get(tk, {}).get("labs", {}).items()
            if lab_data.get("completed", False)
        )

pct = round(completed_all_labs / max(total_all_labs, 1) * 100)

st.markdown(f"""
<div style="background:#1B2332; border-radius:12px; padding:16px 20px;">
    <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
        <span style="color:#FAFAFA; font-weight:600;">{t('labs')} {t('completed')}</span>
        <span style="color:#29B5E8; font-weight:700;">{completed_all_labs}/{total_all_labs}</span>
    </div>
    <div style="background:#2D3748; border-radius:4px; height:8px;">
        <div style="background:#29B5E8; border-radius:4px; height:8px; width:{pct}%;"></div>
    </div>
</div>
""", unsafe_allow_html=True)
