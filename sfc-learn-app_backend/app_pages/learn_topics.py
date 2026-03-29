"""Learn -- Topic list for a selected track."""
import streamlit as st
import os
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE not in sys.path:
    sys.path.insert(0, BASE)

from i18n import t, get_text
from app_pages.data_layer import get_tracks, get_topic_content
from app_pages.persistence import load_learn_progress

from theme import T
DIFFICULTY_COLORS = T.DIFFICULTY


def load_tracks():
    return get_tracks()


def load_topic(track_key, topic_key):
    return get_topic_content(track_key, topic_key)


def load_progress():
    return load_learn_progress()


# ── Sidebar ──
if st.sidebar.button(f"← {t('back')}", key="back_tracks", use_container_width=True):
    st.switch_page("app_pages/learn_tracks.py")

try:
    from app_pages.sf_connection import connection_status_widget
    connection_status_widget()
except ImportError:
    pass

# ── Load data ──
tracks = load_tracks()
track_key = st.session_state.get("learn_track")
lang = st.session_state.get("lang", "en")
progress = load_progress()

if not track_key or track_key not in tracks:
    st.warning("No track selected.")
    if st.button(f"← {t('back')}"):
        st.switch_page("app_pages/learn_tracks.py")
    st.stop()

track = tracks[track_key]
track_name = get_text(track["name"], lang)
track_color = track["color"]
track_emoji = track["emoji"]
track_difficulty = track.get("difficulty", "intermediate")
topic_keys = track.get("topics", [])

# ── Header ──
diff_color = DIFFICULTY_COLORS.get(track_difficulty, "#9CA3AF")
diff_label = t(f"difficulty_{track_difficulty}")

st.markdown(f"""
<div style="background:linear-gradient(135deg, {track_color}20, {track_color}08);
            border-left:5px solid {track_color}; border-radius:12px; padding:16px 20px; margin-bottom:16px;">
    <h1 style="color:{track_color}; margin:0 0 4px;">{track_emoji} {track_name}</h1>
    <span style="background:{diff_color}22; color:{diff_color}; padding:2px 10px;
                border-radius:10px; font-size:0.8rem; font-weight:600;">{diff_label}</span>
    <span style="color:#9CA3AF; margin-left:12px; font-size:0.9rem;">
        {len(topic_keys)} {t('topics')}
    </span>
</div>
""", unsafe_allow_html=True)

# ── Topic cards ──
if not topic_keys:
    st.info("No topics available for this track yet.")
    st.stop()

for topic_key in topic_keys:
    topic_data = load_topic(track_key, topic_key)

    if not topic_data:
        # Topic file doesn't exist yet — show placeholder
        st.markdown(f"""
        <div style="background:#1B2332; border-radius:12px; padding:16px 20px; margin:8px 0;
                    border-left:4px solid #2D3748; opacity:0.5;">
            <h3 style="color:#9CA3AF; margin:0;">📋 {topic_key.replace('_', ' ').title()}</h3>
            <p style="color:#6B7280; margin:4px 0 0; font-size:0.85rem;">{t('coming_soon')}</p>
        </div>
        """, unsafe_allow_html=True)
        continue

    topic_name = get_text(topic_data["topic"], lang)
    topic_color = topic_data.get("color", track_color)
    topic_emoji = topic_data.get("emoji", "📚")
    topic_diff = topic_data.get("difficulty", "intermediate")
    topic_desc = get_text(topic_data.get("description", ""), lang)
    topic_diff_color = DIFFICULTY_COLORS.get(topic_diff, "#9CA3AF")
    topic_diff_label = t(f"difficulty_{topic_diff}")

    # Content counts
    notes_text = get_text(topic_data.get("notes", ""), "en")
    has_notes = bool(notes_text.strip())
    num_questions = len(topic_data.get("questions", []))
    num_labs = len(topic_data.get("labs", []))
    num_flashcards = len(topic_data.get("flashcards", []))

    # Progress for this topic
    topic_progress = progress.get(track_key, {}).get(topic_key, {})
    labs_completed = sum(
        1 for lid, ld in topic_progress.get("labs", {}).items()
        if ld.get("completed", False)
    )
    quiz_scores = topic_progress.get("quiz_scores", [])
    avg_score = round(sum(quiz_scores) / max(len(quiz_scores), 1)) if quiz_scores else None

    # Build card
    col1, col2 = st.columns([5, 1])

    with col1:
        progress_badges = ""
        if labs_completed > 0:
            progress_badges += f'<span style="background:#4ECB7122; color:#4ECB71; padding:2px 8px; border-radius:8px; font-size:0.75rem; margin-right:4px;">✓ {labs_completed}/{num_labs} labs</span>'
        if avg_score is not None:
            score_color = "#4ECB71" if avg_score >= 70 else "#FFD93D" if avg_score >= 50 else "#FF6B6B"
            progress_badges += f'<span style="background:{score_color}22; color:{score_color}; padding:2px 8px; border-radius:8px; font-size:0.75rem;">Quiz: {avg_score}%</span>'

        st.markdown(f"""
        <div style="background:#1B2332; border-radius:12px; padding:16px 20px; margin:8px 0;
                    border-left:4px solid {topic_color};">
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <h3 style="color:{topic_color}; margin:0;">{topic_emoji} {topic_name}</h3>
                <span style="background:{topic_diff_color}22; color:{topic_diff_color}; padding:2px 10px;
                            border-radius:10px; font-size:0.75rem; font-weight:600;">{topic_diff_label}</span>
            </div>
            <p style="color:#9CA3AF; margin:6px 0; font-size:0.9rem;">{topic_desc}</p>
            <div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:8px;">
                {'<span style="background:#29B5E822; color:#29B5E8; padding:2px 8px; border-radius:8px; font-size:0.75rem;">📖 ' + t("notes") + '</span>' if has_notes else ''}
                <span style="background:#C084FC22; color:#C084FC; padding:2px 8px; border-radius:8px; font-size:0.75rem;">🧠 {num_questions} {t('questions')}</span>
                <span style="background:#FF980022; color:#FF9800; padding:2px 8px; border-radius:8px; font-size:0.75rem;">🧪 {num_labs} {t('labs')}</span>
                <span style="background:#4ECB7122; color:#4ECB71; padding:2px 8px; border-radius:8px; font-size:0.75rem;">🃏 {num_flashcards} {t('flashcards')}</span>
                {progress_badges}
            </div>
        </div>
        """, unsafe_allow_html=True)

    with col2:
        st.markdown("<br>", unsafe_allow_html=True)
        if st.button(f"→ {t('enter')}", key=f"topic_{topic_key}", use_container_width=True, type="primary"):
            st.session_state.learn_topic = topic_key
            st.switch_page("app_pages/learn_detail.py")
