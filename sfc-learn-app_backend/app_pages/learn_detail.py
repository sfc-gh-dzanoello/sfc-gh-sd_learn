"""Learn -- Topic detail with Notes, Quiz, Labs, and Flashcards tabs."""
import streamlit as st
import os
import sys
import random
from datetime import datetime

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE not in sys.path:
    sys.path.insert(0, BASE)

from i18n import t, get_text
from app_pages.data_layer import get_tracks, get_topic_content
from app_pages.persistence import load_learn_progress, save_learn_progress

DIFFICULTY_COLORS = {
    "beginner": "#4ECB71",
    "intermediate": "#FFD93D",
    "advanced": "#FF6B6B",
    "expert": "#C084FC",
}


def load_tracks():
    return get_tracks()


def load_topic(track_key, topic_key):
    return get_topic_content(track_key, topic_key)


def load_progress():
    return load_learn_progress()


def save_progress(progress):
    save_learn_progress(progress)


# ── Sidebar ──
st.sidebar.markdown("---")

if st.sidebar.button(f"🏠 {t('home')}", use_container_width=True):
    st.session_state.app_mode = None
    st.switch_page("app_pages/landing.py")

if st.sidebar.button(f"← {t('back')}", key="back_topics", use_container_width=True):
    st.switch_page("app_pages/learn_topics.py")

try:
    from app_pages.sf_connection import connection_status_widget
    connection_status_widget()
except ImportError:
    pass

# ── Load data ──
tracks = load_tracks()
track_key = st.session_state.get("learn_track")
topic_key = st.session_state.get("learn_topic")
lang = st.session_state.get("lang", "en")

if not track_key or not topic_key:
    st.warning("No topic selected.")
    st.switch_page("app_pages/learn_tracks.py")
    st.stop()

track = tracks.get(track_key, {})
topic_data = load_topic(track_key, topic_key)

if not topic_data:
    st.error(f"Topic file not found: labs/{track_key}/{topic_key}.json")
    st.stop()

topic_name = get_text(topic_data["topic"], lang)
topic_color = topic_data.get("color", "#29B5E8")
topic_emoji = topic_data.get("emoji", "📚")
topic_diff = topic_data.get("difficulty", "intermediate")
topic_desc = get_text(topic_data.get("description", ""), lang)
diff_color = DIFFICULTY_COLORS.get(topic_diff, "#9CA3AF")
diff_label = t(f"difficulty_{topic_diff}")

# ── Header ──
st.markdown(f"""
<div style="background:linear-gradient(135deg, {topic_color}20, {topic_color}08);
            border-left:5px solid {topic_color}; border-radius:12px; padding:16px 20px; margin-bottom:16px;">
    <h1 style="color:{topic_color}; margin:0 0 4px;">{topic_emoji} {topic_name}</h1>
    <span style="background:{diff_color}22; color:{diff_color}; padding:2px 10px;
                border-radius:10px; font-size:0.8rem; font-weight:600;">{diff_label}</span>
    <p style="color:#9CA3AF; margin:8px 0 0; font-size:0.9rem;">{topic_desc}</p>
</div>
""", unsafe_allow_html=True)

# ── Tabs ──
tab_notes, tab_quiz, tab_labs, tab_flash = st.tabs([
    f"📖 {t('notes')}",
    f"🧠 {t('quiz')}",
    f"🧪 {t('labs')}",
    f"🃏 {t('flashcards')}",
])


# ═══════════════════════════════════════════════
# TAB 1: NOTES
# ═══════════════════════════════════════════════
with tab_notes:
    notes_text = get_text(topic_data.get("notes", ""), lang)
    if notes_text.strip():
        # Split by ## headers and render in colored sections
        sections = notes_text.split("\n## ")
        colors = ["#29B5E8", "#FF6B6B", "#4ECB71", "#FFD93D", "#C084FC"]
        for i, section in enumerate(sections):
            if not section.strip():
                continue
            sec_text = section if i == 0 else f"## {section}"
            color = colors[i % len(colors)]
            st.markdown(f"""
            <div class="notes-section" style="border-color:{color};">
                {sec_text}
            </div>
            """, unsafe_allow_html=True)
    else:
        st.info(t("no_notes_yet"))

    # AI explain button
    try:
        from app_pages.ai_helper import render_ai_button
        st.markdown("---")
        render_ai_button(
            key="ai_notes",
            topic_name=topic_data["topic"],
            concept_text=topic_desc,
            button_label=t("ask_ai"),
        )
    except ImportError:
        pass


# ═══════════════════════════════════════════════
# TAB 2: QUIZ
# ═══════════════════════════════════════════════
with tab_quiz:
    questions = topic_data.get("questions", [])
    if not questions:
        st.info(t("no_questions_yet"))
    else:
        # Quiz state keys scoped to this topic
        qk = f"lq_{track_key}_{topic_key}"

        if not st.session_state.get(f"{qk}_active", False):
            st.markdown(f"### 🧠 {t('quiz')} — {topic_name}")
            st.markdown(f"**{len(questions)}** {t('questions')}")

            # Difficulty breakdown
            diff_counts = {}
            for q in questions:
                d = q.get("difficulty", "intermediate")
                diff_counts[d] = diff_counts.get(d, 0) + 1
            for d, c in diff_counts.items():
                dc = DIFFICULTY_COLORS.get(d, "#9CA3AF")
                dl = t(f"difficulty_{d}")
                st.markdown(f'<span style="color:{dc};">● {dl}: {c}</span>', unsafe_allow_html=True)

            num = st.slider(t("questions"), min_value=1, max_value=len(questions), value=min(5, len(questions)), key=f"{qk}_num")

            if st.button(f"🧠 {t('start')}", key=f"{qk}_start", type="primary"):
                st.session_state[f"{qk}_questions"] = random.sample(questions, num)
                st.session_state[f"{qk}_index"] = 0
                st.session_state[f"{qk}_answers"] = {}
                st.session_state[f"{qk}_submitted"] = {}
                st.session_state[f"{qk}_active"] = True
                st.rerun()
        else:
            quiz_qs = st.session_state[f"{qk}_questions"]
            idx = st.session_state[f"{qk}_index"]
            total = len(quiz_qs)
            q = quiz_qs[idx]

            # Progress bar
            st.progress((idx + 1) / total)

            # Nav
            nav_cols = st.columns([1, 3, 1])
            with nav_cols[0]:
                if st.button(f"← {t('previous')}", key=f"{qk}_prev", disabled=idx == 0):
                    st.session_state[f"{qk}_index"] = idx - 1
                    st.rerun()
            with nav_cols[1]:
                st.markdown(f"<p style='text-align:center; color:#9CA3AF;'>{t('questions')} {idx+1}/{total}</p>", unsafe_allow_html=True)
            with nav_cols[2]:
                if st.button(f"{t('next')} →", key=f"{qk}_next", disabled=idx >= total - 1):
                    st.session_state[f"{qk}_index"] = idx + 1
                    st.rerun()

            # Question difficulty badge
            q_diff = q.get("difficulty", "intermediate")
            q_diff_color = DIFFICULTY_COLORS.get(q_diff, "#9CA3AF")
            q_diff_label = t(f"difficulty_{q_diff}")
            st.markdown(f'<span style="background:{q_diff_color}22; color:{q_diff_color}; padding:2px 10px; border-radius:10px; font-size:0.75rem; font-weight:600;">{q_diff_label}</span>', unsafe_allow_html=True)

            # Question text
            q_text = get_text(q["question"], lang)
            st.markdown(f"### {q_text}")

            # Multi-select hint
            correct_indices = q.get("correct_indices", [0])
            is_multi = len(correct_indices) > 1

            if is_multi:
                st.caption(f"🔵 {t('select')} {len(correct_indices)} {t('correct')}")

            # Options
            options = q.get("options", [])
            submitted = st.session_state[f"{qk}_submitted"].get(idx, False)

            if not submitted:
                if is_multi:
                    selected = []
                    for oi, opt in enumerate(options):
                        opt_text = get_text(opt["text"], lang)
                        if st.checkbox(opt_text, key=f"{qk}_opt_{idx}_{oi}"):
                            selected.append(oi)
                    st.session_state[f"{qk}_answers"][idx] = selected
                else:
                    opt_texts = [get_text(o["text"], lang) for o in options]
                    prev_ans = st.session_state[f"{qk}_answers"].get(idx, None)
                    sel = st.radio(
                        t("select"),
                        range(len(opt_texts)),
                        format_func=lambda i: opt_texts[i],
                        key=f"{qk}_radio_{idx}",
                        index=prev_ans[0] if prev_ans else 0,
                        label_visibility="collapsed",
                    )
                    st.session_state[f"{qk}_answers"][idx] = [sel]

                if st.button(f"✅ {t('submit')}", key=f"{qk}_submit_{idx}", type="primary"):
                    st.session_state[f"{qk}_submitted"][idx] = True
                    st.rerun()
            else:
                # Show feedback
                user_ans = st.session_state[f"{qk}_answers"].get(idx, [])
                for oi, opt in enumerate(options):
                    opt_text = get_text(opt["text"], lang)
                    if oi in correct_indices and oi in user_ans:
                        st.markdown(f'<div class="feedback-correct">✅ {opt_text}</div>', unsafe_allow_html=True)
                    elif oi in user_ans and oi not in correct_indices:
                        st.markdown(f'<div class="feedback-wrong">❌ {opt_text}</div>', unsafe_allow_html=True)
                    elif oi in correct_indices and oi not in user_ans:
                        st.markdown(f'<div class="feedback-missed">⚠️ {opt_text} ({t("correct")} — {t("missed")})</div>', unsafe_allow_html=True)
                    else:
                        st.markdown(f"<p style='color:#6B7280; padding:4px 0;'>○ {opt_text}</p>", unsafe_allow_html=True)

                # Explanation
                explanation = get_text(q.get("explanation", ""), lang)
                if explanation:
                    with st.expander(f"💡 {t('explanation')}", expanded=True):
                        st.markdown(explanation)

                # AI feedback for wrong answers
                if sorted(user_ans) != sorted(correct_indices):
                    try:
                        from app_pages.ai_helper import ai_feedback
                        if st.button(f"🤖 {t('ai_feedback')}", key=f"{qk}_aifb_{idx}"):
                            with st.spinner(t("thinking")):
                                user_texts = [get_text(options[i]["text"], lang) for i in user_ans]
                                correct_texts = [get_text(options[i]["text"], lang) for i in correct_indices]
                                resp = ai_feedback(q_text, ", ".join(user_texts), ", ".join(correct_texts), explanation, lang)
                                if resp:
                                    st.markdown(f"""
                                    <div style="background:rgba(41,181,232,0.1); border-left:4px solid #29B5E8;
                                                border-radius:8px; padding:14px 18px; margin:8px 0;">
                                        <strong style="color:#29B5E8;">🤖 AI Tutor</strong><br>
                                        <span style="color:#FAFAFA;">{resp}</span>
                                    </div>
                                    """, unsafe_allow_html=True)
                    except ImportError:
                        pass

                # Retry button
                if st.button(f"🔄 {t('retry')}", key=f"{qk}_retry_{idx}"):
                    st.session_state[f"{qk}_submitted"].pop(idx, None)
                    st.session_state[f"{qk}_answers"].pop(idx, None)
                    st.rerun()

            # End quiz button
            st.markdown("---")
            if st.button(f"🏁 {t('finish')}", key=f"{qk}_end"):
                # Calculate score
                correct = 0
                answered = 0
                for qi in range(total):
                    if qi in st.session_state[f"{qk}_submitted"]:
                        answered += 1
                        user_a = st.session_state[f"{qk}_answers"].get(qi, [])
                        if sorted(user_a) == sorted(quiz_qs[qi].get("correct_indices", [])):
                            correct += 1
                score_pct = round(correct / max(answered, 1) * 100)

                # Save progress
                progress = load_progress()
                progress.setdefault(track_key, {}).setdefault(topic_key, {}).setdefault("quiz_scores", [])
                progress[track_key][topic_key]["quiz_scores"].append(score_pct)
                save_progress(progress)

                st.session_state[f"{qk}_active"] = False

                # Show result
                score_color = "#4ECB71" if score_pct >= 70 else "#FFD93D" if score_pct >= 50 else "#FF6B6B"
                st.markdown(f"""
                <div style="background:#1B2332; border-radius:12px; padding:20px; text-align:center; border-top:4px solid {score_color};">
                    <p style="font-size:2.5rem; margin:0;">{score_pct}%</p>
                    <p style="color:{score_color}; font-weight:600;">{correct}/{answered} {t('correct')}</p>
                </div>
                """, unsafe_allow_html=True)
                st.rerun()


# ═══════════════════════════════════════════════
# TAB 3: LABS
# ═══════════════════════════════════════════════
with tab_labs:
    labs = topic_data.get("labs", [])
    if not labs:
        st.info(t("no_labs_yet"))
    else:
        # Lab selector if multiple
        lab_names = [get_text(lab["title"], lang) for lab in labs]
        if len(labs) > 1:
            selected_lab_idx = st.selectbox(t("select_lab"), range(len(lab_names)),
                                            format_func=lambda i: lab_names[i], key="lab_select")
        else:
            selected_lab_idx = 0

        lab = labs[selected_lab_idx]
        lab_id = lab["id"]
        lab_title = get_text(lab["title"], lang)
        lab_desc = get_text(lab.get("description", ""), lang)
        lab_diff = lab.get("difficulty", "beginner")
        lab_diff_color = DIFFICULTY_COLORS.get(lab_diff, "#9CA3AF")
        lab_diff_label = t(f"difficulty_{lab_diff}")
        lab_minutes = lab.get("estimated_minutes", 15)
        steps = lab.get("steps", [])

        # Lab state key
        lk = f"lab_{track_key}_{topic_key}_{lab_id}"

        # Lab header card
        st.markdown(f"""
        <div style="background:#1B2332; border-radius:12px; padding:16px 20px; margin:8px 0;
                    border-top:4px solid {topic_color};">
            <h3 style="color:{topic_color}; margin:0 0 6px;">🧪 {lab_title}</h3>
            <div style="display:flex; gap:8px; margin-bottom:8px;">
                <span style="background:{lab_diff_color}22; color:{lab_diff_color}; padding:2px 10px;
                            border-radius:10px; font-size:0.75rem; font-weight:600;">{lab_diff_label}</span>
                <span style="background:#29B5E822; color:#29B5E8; padding:2px 10px; border-radius:10px;
                            font-size:0.75rem;">⏱️ ~{lab_minutes} {t('minutes')}</span>
                <span style="background:#C084FC22; color:#C084FC; padding:2px 10px; border-radius:10px;
                            font-size:0.75rem;">{len(steps)} {t('steps')}</span>
            </div>
            <p style="color:#9CA3AF; margin:0; font-size:0.9rem;">{lab_desc}</p>
        </div>
        """, unsafe_allow_html=True)

        # Check connection
        sf_connected = False
        try:
            from app_pages.sf_connection import get_connection, run_sql
            conn = get_connection()
            sf_connected = conn is not None
        except ImportError:
            pass

        if not sf_connected:
            st.warning(f"⚠️ {t('disconnected')} — {t('connect_to_run_labs')}")

        # Lab active state
        if not st.session_state.get(f"{lk}_active", False):
            if st.button(f"🚀 {t('start_lab')}", key=f"{lk}_start", type="primary", disabled=not sf_connected):
                # Run setup SQL
                setup_sql = lab.get("setup_sql", "")
                if setup_sql:
                    result = run_sql(setup_sql)
                    if isinstance(result, dict) and result.get("status") == "error":
                        st.error(f"Setup failed: {result['message']}")
                        st.stop()
                st.session_state[f"{lk}_active"] = True
                st.session_state[f"{lk}_step"] = 0
                st.session_state[f"{lk}_validated"] = {}
                st.rerun()
        else:
            current_step = st.session_state.get(f"{lk}_step", 0)
            validated = st.session_state.get(f"{lk}_validated", {})

            # Progress bar
            completed_steps = sum(1 for v in validated.values() if v)
            st.progress(completed_steps / max(len(steps), 1))
            st.caption(f"{t('step_x_of_y').format(x=current_step+1, y=len(steps))} — {completed_steps}/{len(steps)} {t('completed')}")

            # Step navigator (dot indicators)
            nav_cols = st.columns(min(len(steps), 10))
            for si, nav_col in zip(range(len(steps)), nav_cols):
                with nav_col:
                    if validated.get(si, False):
                        label = "✅"
                    elif si == current_step:
                        label = f"**{si+1}**"
                    else:
                        label = str(si + 1)
                    if st.button(label, key=f"{lk}_nav_{si}", use_container_width=True):
                        st.session_state[f"{lk}_step"] = si
                        st.rerun()

            if current_step < len(steps):
                step = steps[current_step]
                step_title = get_text(step.get("title", f"Step {current_step+1}"), lang)
                step_instruction = get_text(step["instruction"], lang)
                step_sql = step.get("sql", "")
                step_hint = get_text(step.get("hint", ""), lang)
                step_expected = step.get("expected", "")

                st.markdown(f"### {t('step_x_of_y').format(x=current_step+1, y=len(steps))}: {step_title}")
                st.markdown(step_instruction)

                # SQL code block
                if step_sql:
                    st.code(step_sql, language="sql")

                    # Run button
                    btn_cols = st.columns([1, 1, 1, 2])
                    with btn_cols[0]:
                        if st.button(f"▶️ {t('run_sql')}", key=f"{lk}_run_{current_step}", type="primary"):
                            with st.spinner(t("running")):
                                result = run_sql(step_sql)
                                st.session_state[f"{lk}_result_{current_step}"] = result

                    with btn_cols[1]:
                        if st.button(f"✓ {t('validate')}", key=f"{lk}_val_{current_step}"):
                            val_sql = step.get("validation_sql", "")
                            if val_sql:
                                with st.spinner(t("validating")):
                                    val_result = run_sql(val_sql)
                                    if isinstance(val_result, list) and len(val_result) > 0:
                                        st.session_state[f"{lk}_validated"][current_step] = True
                                        st.success(f"✅ {t('step_validated')}")
                                        st.rerun()
                                    else:
                                        st.error(f"❌ {t('step_not_validated')}")
                            else:
                                # No validation SQL — mark as done on run
                                st.session_state[f"{lk}_validated"][current_step] = True
                                st.rerun()

                    with btn_cols[2]:
                        if st.button(f"💡 {t('hint')}", key=f"{lk}_hint_{current_step}"):
                            st.session_state[f"{lk}_show_hint_{current_step}"] = True

                    # Show run result
                    result = st.session_state.get(f"{lk}_result_{current_step}")
                    if result is not None:
                        if isinstance(result, list):
                            if result:
                                import pandas as pd
                                st.dataframe(pd.DataFrame(result), use_container_width=True)
                            else:
                                st.info("Query returned no rows.")
                        elif isinstance(result, dict):
                            if result.get("status") == "error":
                                st.error(f"❌ {result['message']}")
                                # AI hint on error
                                try:
                                    from app_pages.ai_helper import ai_hint
                                    if st.button(f"🤖 {t('ask_ai')}", key=f"{lk}_ai_{current_step}"):
                                        with st.spinner(t("thinking")):
                                            hint_resp = ai_hint(step_instruction, step_sql, result['message'], lang)
                                            if hint_resp:
                                                st.info(f"🤖 {hint_resp}")
                                except ImportError:
                                    pass
                            else:
                                st.success(f"✅ {result.get('message', 'Success')}")

                    # Show hint
                    if st.session_state.get(f"{lk}_show_hint_{current_step}", False):
                        st.markdown(f"""
                        <div class="mnemonic">
                            💡 <strong>Hint:</strong> {step_hint}
                        </div>
                        """, unsafe_allow_html=True)

                # Step navigation
                st.markdown("---")
                step_nav = st.columns([1, 1, 3])
                with step_nav[0]:
                    if st.button(f"← {t('previous')}", key=f"{lk}_prev", disabled=current_step == 0):
                        st.session_state[f"{lk}_step"] = current_step - 1
                        st.rerun()
                with step_nav[1]:
                    if st.button(f"{t('next')} →", key=f"{lk}_next", disabled=current_step >= len(steps) - 1):
                        st.session_state[f"{lk}_step"] = current_step + 1
                        st.rerun()

            # Check if all steps validated
            if all(validated.get(i, False) for i in range(len(steps))):
                st.markdown(f"""
                <div style="background:rgba(78,203,113,0.15); border:2px solid #4ECB71;
                            border-radius:12px; padding:20px; text-align:center; margin-top:16px;">
                    <p style="font-size:2rem; margin:0;">🎉</p>
                    <h3 style="color:#4ECB71; margin:8px 0;">{t('lab_complete')}</h3>
                    <p style="color:#9CA3AF;">{t('all_steps_validated')}</p>
                </div>
                """, unsafe_allow_html=True)

                # Save completion
                progress = load_progress()
                progress.setdefault(track_key, {}).setdefault(topic_key, {}).setdefault("labs", {})
                progress[track_key][topic_key]["labs"][lab_id] = {
                    "completed": True,
                    "date": datetime.now().isoformat(),
                }
                save_progress(progress)

            # Cleanup button
            st.markdown("---")
            cleanup_sql = lab.get("cleanup_sql", "")
            if cleanup_sql:
                if st.button(f"🧹 {t('run_cleanup')}", key=f"{lk}_cleanup"):
                    with st.spinner(t("cleaning")):
                        result = run_sql(cleanup_sql)
                        if isinstance(result, dict) and result.get("status") == "error":
                            st.error(f"Cleanup failed: {result['message']}")
                        else:
                            st.success(f"✅ {t('cleanup_done')}")
                            st.session_state[f"{lk}_active"] = False
                            st.rerun()

            if st.button(f"🚪 {t('end_lab')}", key=f"{lk}_endlab"):
                st.session_state[f"{lk}_active"] = False
                st.rerun()


# ═══════════════════════════════════════════════
# TAB 4: FLASHCARDS
# ═══════════════════════════════════════════════
with tab_flash:
    flashcards = topic_data.get("flashcards", [])
    if not flashcards:
        st.info(t("no_flashcards_yet"))
    else:
        st.markdown(f"### 🃏 {t('flashcards')} — {len(flashcards)} cards")

        # Shuffle option
        if st.checkbox(t("shuffle"), key="fc_shuffle"):
            fc_list = random.sample(flashcards, len(flashcards))
        else:
            fc_list = flashcards

        for i, fc in enumerate(fc_list):
            fc_q = get_text(fc["q"], lang)
            fc_a = get_text(fc["a"], lang)

            st.markdown(f"""
            <div class="flashcard">
                <div class="flashcard-q">❓ {fc_q}</div>
            </div>
            """, unsafe_allow_html=True)

            if st.button(f"👁️ {t('show_answer')}", key=f"fc_show_{topic_key}_{i}"):
                st.session_state[f"fc_rev_{topic_key}_{i}"] = not st.session_state.get(f"fc_rev_{topic_key}_{i}", False)

            if st.session_state.get(f"fc_rev_{topic_key}_{i}", False):
                st.markdown(f"""
                <div style="background:rgba(78,203,113,0.1); border-left:4px solid #4ECB71;
                            border-radius:8px; padding:12px 16px; margin:0 0 12px;">
                    <span style="color:#4ECB71;">✅ {fc_a}</span>
                </div>
                """, unsafe_allow_html=True)
