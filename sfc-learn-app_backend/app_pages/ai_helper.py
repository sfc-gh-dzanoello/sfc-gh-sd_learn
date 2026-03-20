"""AI Helper — Cortex AI-powered learning assistance."""
import streamlit as st

try:
    import snowflake.connector
    SF_AVAILABLE = True
except ImportError:
    SF_AVAILABLE = False


def _get_conn():
    """Get Snowflake connection from session state."""
    from app_pages.sf_connection import get_connection
    return get_connection()


def ai_complete(prompt, model="snowflake-arctic-instruct"):
    """Run SNOWFLAKE.CORTEX.COMPLETE and return the text response."""
    conn = _get_conn()
    if not conn:
        return None
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT SNOWFLAKE.CORTEX.COMPLETE(%s, %s) AS response",
            (model, prompt),
        )
        row = cur.fetchone()
        return row[0] if row else None
    except Exception as e:
        return f"[AI Error] {e}"


def ai_translate(text, source_lang, target_lang):
    """Translate text using SNOWFLAKE.CORTEX.TRANSLATE."""
    lang_map = {"en": "en", "pt": "pt", "es": "es"}
    src = lang_map.get(source_lang, "en")
    tgt = lang_map.get(target_lang, "en")
    if src == tgt:
        return text
    conn = _get_conn()
    if not conn:
        return text
    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT SNOWFLAKE.CORTEX.TRANSLATE(%s, %s, %s) AS translated",
            (text, src, tgt),
        )
        row = cur.fetchone()
        return row[0] if row else text
    except Exception:
        return text


def ai_explain(topic, concept, lang="en"):
    """Ask AI to explain a concept in the user's language."""
    lang_names = {"en": "English", "pt": "Brazilian Portuguese", "es": "Latin American Spanish"}
    lang_name = lang_names.get(lang, "English")
    prompt = (
        f"You are a Snowflake expert tutor. Explain the following concept clearly and concisely "
        f"in {lang_name}. Use examples when helpful.\n\n"
        f"Topic: {topic}\n"
        f"Concept to explain: {concept}\n\n"
        f"Provide a clear, structured explanation suitable for someone learning Snowflake."
    )
    return ai_complete(prompt)


def ai_feedback(question_text, user_answer, correct_answer, explanation, lang="en"):
    """Give feedback on a wrong answer — explain why it's wrong and why the correct one is right."""
    lang_names = {"en": "English", "pt": "Brazilian Portuguese", "es": "Latin American Spanish"}
    lang_name = lang_names.get(lang, "English")
    prompt = (
        f"You are a Snowflake tutor helping a student understand their mistake. "
        f"Respond in {lang_name}.\n\n"
        f"Question: {question_text}\n"
        f"Student's answer: {user_answer}\n"
        f"Correct answer: {correct_answer}\n"
        f"Official explanation: {explanation}\n\n"
        f"Explain:\n"
        f"1. Why the student's answer is incorrect\n"
        f"2. Why the correct answer is right\n"
        f"3. A tip to remember this for next time\n"
        f"Be encouraging but accurate."
    )
    return ai_complete(prompt)


def ai_suggest_next(progress, available_topics, lang="en"):
    """Suggest what to study next based on progress."""
    lang_names = {"en": "English", "pt": "Brazilian Portuguese", "es": "Latin American Spanish"}
    lang_name = lang_names.get(lang, "English")
    progress_summary = "\n".join(
        f"- {topic}: {data.get('completion', 0)}% complete, "
        f"quiz score {data.get('avg_score', 'N/A')}"
        for topic, data in progress.items()
    )
    topics_list = ", ".join(available_topics)
    prompt = (
        f"You are a Snowflake learning advisor. Respond in {lang_name}.\n\n"
        f"Student progress:\n{progress_summary}\n\n"
        f"Available topics: {topics_list}\n\n"
        f"Based on the student's progress, suggest:\n"
        f"1. What topic to study next and why\n"
        f"2. Whether to review any weak areas first\n"
        f"3. A short motivational note\n"
        f"Keep it concise (3-5 sentences)."
    )
    return ai_complete(prompt)


def ai_hint(step_instruction, step_sql, error_message, lang="en"):
    """Help the student when a lab step fails."""
    lang_names = {"en": "English", "pt": "Brazilian Portuguese", "es": "Latin American Spanish"}
    lang_name = lang_names.get(lang, "English")
    prompt = (
        f"You are a Snowflake tutor helping a student with a hands-on lab. "
        f"Respond in {lang_name}.\n\n"
        f"Lab step instruction: {step_instruction}\n"
        f"SQL they ran: {step_sql}\n"
        f"Error: {error_message}\n\n"
        f"Explain what went wrong and give a hint (without giving the full answer). "
        f"Keep it brief and helpful."
    )
    return ai_complete(prompt)


def render_ai_button(key, topic_name, concept_text, button_label=None):
    """Render an 'Ask AI' button that explains a concept when clicked."""
    from i18n import t, get_text
    lang = st.session_state.get("lang", "en")
    label = button_label or t("ask_ai")

    if st.button(f"🤖 {label}", key=key):
        st.session_state[f"_ai_loading_{key}"] = True
        st.rerun()

    if st.session_state.get(f"_ai_loading_{key}", False):
        with st.spinner(t("thinking")):
            topic_str = get_text(topic_name, lang) if isinstance(topic_name, dict) else topic_name
            concept_str = get_text(concept_text, lang) if isinstance(concept_text, dict) else concept_text
            response = ai_explain(topic_str, concept_str, lang)
            st.session_state[f"_ai_loading_{key}"] = False
            if response:
                st.markdown(f"""
                <div style="background:rgba(41,181,232,0.1); border-left:4px solid #29B5E8;
                            border-radius:8px; padding:14px 18px; margin:8px 0;">
                    <strong style="color:#29B5E8;">🤖 AI Tutor</strong><br>
                    <span style="color:#FAFAFA;">{response}</span>
                </div>
                """, unsafe_allow_html=True)
            else:
                st.warning("Could not get AI response. Check your Snowflake connection.")
