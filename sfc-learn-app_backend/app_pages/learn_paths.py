"""Learn Paths -- Role-based study tracks for Snowflake certification preparation."""
import streamlit as st
import json
import os
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE not in sys.path:
    sys.path.insert(0, BASE)

from i18n import t

TRACKS_PATH = os.path.join(BASE, "labs", "tracks.json")

DIFFICULTY_COLORS = {
    "beginner": "#4ECB71",
    "intermediate": "#FFD93D",
    "advanced": "#FF6B6B",
}


def load_tracks():
    try:
        with open(TRACKS_PATH, "r") as f:
            return json.load(f)
    except Exception:
        return {}


tracks = load_tracks()
lang = st.session_state.get("lang", "en")

st.markdown("""
<div style="text-align:center; padding:10px 0 4px;">
    <h1 style="font-size:1.8rem; margin:0; color:#E0F7FA;">Learn Paths</h1>
    <p style="color:#80DEEA; font-size:0.9rem; margin:4px 0 0;">
        Role-based study tracks to guide your certification journey</p>
</div>
""", unsafe_allow_html=True)

st.markdown("")

if not tracks:
    st.warning("No learning tracks found. Check labs/tracks.json.")
    st.stop()

# Track selection view vs detail view
active_track = st.session_state.get("active_track", None)

if active_track is None:
    # -- Card grid --
    cols_per_row = 3
    track_items = list(tracks.items())
    for row_start in range(0, len(track_items), cols_per_row):
        row = track_items[row_start:row_start + cols_per_row]
        cols = st.columns(cols_per_row, gap="medium")

        for col, (track_key, track_data) in zip(cols, row):
            name = track_data.get("name", {}).get(lang, track_data.get("name", {}).get("en", track_key))
            desc = track_data.get("description", {}).get(lang, track_data.get("description", {}).get("en", ""))
            color = track_data.get("color", "#29B5E8")
            diff = track_data.get("difficulty", "beginner")
            diff_color = DIFFICULTY_COLORS.get(diff, "#9CA3AF")
            topics = track_data.get("topics", [])
            topic_count = len(topics)

            with col:
                st.markdown(f"""
                <div style="background:linear-gradient(135deg, {color}15, {color}08);
                border:2px solid {color}; border-radius:14px; padding:20px;
                text-align:center; min-height:260px;">
                <h3 style="color:{color}; margin:8px 0 4px; font-size:1.1rem;">{name}</h3>
                <div style="display:flex; gap:6px; justify-content:center; margin:8px 0;">
                <span style="background:{diff_color}22;color:{diff_color};padding:2px 10px;border-radius:10px;font-size:0.75rem;font-weight:600;">{diff}</span>
                <span style="background:rgba(255,255,255,0.08);color:#9CA3AF;padding:2px 10px;border-radius:10px;font-size:0.75rem;">{topic_count} topics</span>
                </div>
                <p style="color:#B0BEC5; font-size:0.82rem; margin:10px 0;">{desc[:140]}</p>
                </div>
                """, unsafe_allow_html=True)

                if st.button(f"Start {name}", key=f"track_{track_key}", use_container_width=True, type="primary"):
                    st.session_state.active_track = track_key
                    st.rerun()

else:
    # -- Detail view for a specific track --
    track_data = tracks.get(active_track, {})
    if not track_data:
        st.error("Track not found.")
        if st.button("Back to tracks"):
            st.session_state.active_track = None
            st.rerun()
        st.stop()

    name = track_data.get("name", {}).get(lang, track_data.get("name", {}).get("en", active_track))
    desc = track_data.get("description", {}).get(lang, track_data.get("description", {}).get("en", ""))
    color = track_data.get("color", "#29B5E8")
    topics = track_data.get("topics", [])

    if st.button("Back to Learn Paths", key="back_tracks"):
        st.session_state.active_track = None
        st.rerun()

    st.markdown(f"""
    <h1 style="color:{color}; margin:8px 0 4px; font-size:1.5rem;">{name}</h1>
    <p style="color:#9CA3AF; font-size:0.9rem; margin:0 0 16px;">{desc}</p>
    """, unsafe_allow_html=True)

    st.markdown("---")

    # Topic list with progress tracking
    completed_key = f"track_completed_{active_track}"
    completed = st.session_state.get(completed_key, set())

    if topics:
        done_count = len(completed)
        total = len(topics)
        if total > 0:
            st.progress(done_count / total)
            st.caption(f"{done_count} of {total} topics completed")

        st.markdown("")

        for i, topic in enumerate(topics):
            topic_name = topic.get("name", {}).get(lang, topic.get("name", {}).get("en", f"Topic {i+1}"))
            topic_key = topic.get("key", f"topic_{i}")
            is_done = topic_key in completed

            col1, col2 = st.columns([5, 1])
            with col1:
                icon = "check_circle" if is_done else "radio_button_unchecked"
                icon_color = "#4ECB71" if is_done else "#6B7280"
                st.markdown(f"""
                <div style="display:flex; align-items:center; gap:10px; padding:10px 14px;
                background:rgba(255,255,255,0.04); border-radius:8px; margin:4px 0;
                border-left:3px solid {icon_color};">
                <span style="color:{icon_color}; font-size:1.2rem;">{'&#x2705;' if is_done else '&#x2B55;'}</span>
                <span style="color:inherit; font-size:0.95rem;">{topic_name}</span>
                </div>
                """, unsafe_allow_html=True)
            with col2:
                if is_done:
                    if st.button("Undo", key=f"undo_{active_track}_{topic_key}", use_container_width=True):
                        completed.discard(topic_key)
                        st.session_state[completed_key] = completed
                        st.rerun()
                else:
                    if st.button("Done", key=f"done_{active_track}_{topic_key}", use_container_width=True, type="primary"):
                        completed.add(topic_key)
                        st.session_state[completed_key] = completed
                        st.rerun()

        if done_count == total and total > 0:
            st.markdown(f"""
            <div style="background:rgba(78,203,113,0.15);border:2px solid #4ECB71;border-radius:12px;
            padding:20px;text-align:center;margin:20px 0;">
            <span style="font-size:2rem;">&#x1F389;</span><br>
            <strong style="color:#4ECB71;font-size:1.1rem;">Track completed!</strong><br>
            <span style="color:#9CA3AF;">You've covered all topics in the {name} path.</span>
            </div>
            """, unsafe_allow_html=True)
    else:
        st.info("No topics defined for this track yet.")
