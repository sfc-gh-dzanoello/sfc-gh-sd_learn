"""Learn — Create and study custom topics (OpenFlow, Snowpark, Cortex, anything)."""
import streamlit as st
import json
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEARN_FILE = os.path.join(BASE, "learn_topics.json")


def load_topics():
    if os.path.exists(LEARN_FILE):
        with open(LEARN_FILE, "r") as f:
            return json.load(f)
    return {}


def save_topics(topics):
    with open(LEARN_FILE, "w") as f:
        json.dump(topics, f, indent=2, ensure_ascii=False)


if "learn_topics" not in st.session_state:
    st.session_state.learn_topics = load_topics()

topics = st.session_state.learn_topics

st.markdown("""
<h1 style="margin-bottom:4px;">📚 Learn</h1>
<p style="color:#9CA3AF; margin-top:0;">Create custom study topics — add notes, flashcards, and key concepts for anything</p>
""", unsafe_allow_html=True)

# ── Sidebar: topic list ──
st.sidebar.markdown("### 📚 Topics")
topic_names = list(topics.keys())

# Add new topic
with st.expander("➕ Add new topic", expanded=not topic_names):
    new_name = st.text_input("Topic name", placeholder="e.g., OpenFlow, Snowpark Container Services...")
    new_desc = st.text_input("Short description", placeholder="e.g., NiFi-based data integration in Snowflake")
    new_color = st.color_picker("Topic color", "#FF9800")
    if st.button("Create topic", type="primary", disabled=not new_name):
        topics[new_name] = {
            "description": new_desc,
            "color": new_color,
            "notes": "",
            "flashcards": [],
            "key_concepts": [],
        }
        save_topics(topics)
        st.session_state.learn_topics = topics
        st.rerun()

if not topic_names:
    st.info("No topics yet. Create one above to start learning!")
    st.stop()

# Topic selector
selected_topic = st.selectbox("Select topic", topic_names, key="learn_topic_select")
topic = topics[selected_topic]
color = topic.get("color", "#FF9800")

# ── Topic header ──
st.markdown(f"""
<div style="background:linear-gradient(135deg, {color}22, {color}11); border:2px solid {color}; border-radius:14px; padding:16px 20px; margin:12px 0;">
    <h2 style="color:{color}; margin:0 0 4px;">{selected_topic}</h2>
    <p style="color:#9CA3AF; margin:0;">{topic.get('description', '')}</p>
</div>
""", unsafe_allow_html=True)

tabs = st.tabs(["📝 Notes", "🃏 Flashcards", "💡 Key Concepts", "⚙️ Settings"])

# ── TAB 1: Notes ──
with tabs[0]:
    st.markdown("### 📝 Study Notes")
    st.caption("Write your notes in markdown. They auto-save.")

    current_notes = topic.get("notes", "")
    new_notes = st.text_area("Notes (markdown supported)", value=current_notes, height=400,
                             key=f"notes_{selected_topic}", placeholder="Write your study notes here...\n\n## Section 1\n- Point 1\n- Point 2\n\n## Section 2\n...")

    if new_notes != current_notes:
        topics[selected_topic]["notes"] = new_notes
        save_topics(topics)
        st.session_state.learn_topics = topics

    # Preview
    if new_notes:
        with st.expander("👁️ Preview", expanded=True):
            st.markdown(new_notes)

# ── TAB 2: Flashcards ──
with tabs[1]:
    st.markdown("### 🃏 Flashcards")

    flashcards = topic.get("flashcards", [])

    # Add new flashcard
    with st.expander("➕ Add flashcard"):
        fc_q = st.text_input("Question", key=f"fc_q_{selected_topic}", placeholder="What is OpenFlow?")
        fc_a = st.text_area("Answer", key=f"fc_a_{selected_topic}", placeholder="A NiFi-based data integration tool...")
        if st.button("Add flashcard", key=f"fc_add_{selected_topic}"):
            if fc_q and fc_a:
                flashcards.append({"q": fc_q, "a": fc_a})
                topics[selected_topic]["flashcards"] = flashcards
                save_topics(topics)
                st.session_state.learn_topics = topics
                st.rerun()

    # Display flashcards
    for i, fc in enumerate(flashcards):
        st.markdown(f"""
        <div style="background:#FFF;border-left:5px solid {color};border-radius:10px;padding:14px 18px;margin:8px 0;box-shadow:0 1px 4px rgba(0,0,0,0.06);">
            <strong style="color:{color};">Q: {fc['q']}</strong>
        </div>
        """, unsafe_allow_html=True)

        if st.button(f"👁️ Show answer", key=f"fc_show_{selected_topic}_{i}"):
            st.session_state[f"fc_rev_{selected_topic}_{i}"] = not st.session_state.get(f"fc_rev_{selected_topic}_{i}", False)

        if st.session_state.get(f"fc_rev_{selected_topic}_{i}", False):
            st.markdown(f"""
            <div style="background:#E8F5E9;border-left:4px solid #4CAF50;border-radius:8px;padding:10px 14px;margin:0 0 10px;">
                <span style="color:#333;">✅ {fc['a']}</span>
            </div>
            """, unsafe_allow_html=True)

    if not flashcards:
        st.caption("No flashcards yet. Add some above!")

# ── TAB 3: Key Concepts ──
with tabs[2]:
    st.markdown("### 💡 Key Concepts")

    concepts = topic.get("key_concepts", [])

    with st.expander("➕ Add concept"):
        kc_term = st.text_input("Term", key=f"kc_t_{selected_topic}", placeholder="e.g., Processor")
        kc_def = st.text_area("Definition", key=f"kc_d_{selected_topic}", placeholder="A unit of work in a NiFi flow...")
        if st.button("Add concept", key=f"kc_add_{selected_topic}"):
            if kc_term and kc_def:
                concepts.append({"term": kc_term, "definition": kc_def})
                topics[selected_topic]["key_concepts"] = concepts
                save_topics(topics)
                st.session_state.learn_topics = topics
                st.rerun()

    for i, kc in enumerate(concepts):
        st.markdown(f"""
        <div style="background:#FFF;border-left:4px solid {color};border-radius:8px;padding:12px 16px;margin:6px 0;box-shadow:0 1px 3px rgba(0,0,0,0.05);">
            <strong style="color:{color};">{kc['term']}</strong><br>
            <span style="color:#333;font-size:0.9rem;">{kc['definition']}</span>
        </div>
        """, unsafe_allow_html=True)

    if not concepts:
        st.caption("No key concepts yet. Add some above!")

# ── TAB 4: Settings ──
with tabs[3]:
    st.markdown("### ⚙️ Topic Settings")

    new_desc = st.text_input("Description", value=topic.get("description", ""), key=f"desc_{selected_topic}")
    new_color = st.color_picker("Color", value=topic.get("color", "#FF9800"), key=f"color_{selected_topic}")

    if new_desc != topic.get("description") or new_color != topic.get("color"):
        topics[selected_topic]["description"] = new_desc
        topics[selected_topic]["color"] = new_color
        save_topics(topics)
        st.session_state.learn_topics = topics

    st.markdown("---")
    if st.button("🗑️ Delete this topic", type="secondary", key=f"del_{selected_topic}"):
        del topics[selected_topic]
        save_topics(topics)
        st.session_state.learn_topics = topics
        st.rerun()
