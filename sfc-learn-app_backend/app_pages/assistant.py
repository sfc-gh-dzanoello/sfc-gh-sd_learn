"""AI Study Assistant — search Snowflake docs and get answers to study questions."""
import streamlit as st

# ── Home button ──
if st.button("🏠 Home", key="assistant_home"):
    st.session_state.app_mode = "landing"
    st.switch_page("app_pages/landing.py")

st.markdown("""
<h1 style="margin-bottom:4px;">🤖 Study Assistant</h1>
<p style="color:#9CA3AF; margin-top:0;">Ask any Snowflake question — searches official docs + your notes</p>
""", unsafe_allow_html=True)

# Initialize chat history
st.session_state.setdefault("chat_history", [])

notes = st.session_state.get("review_notes", {})
questions_bank = st.session_state.get("questions", [])


def search_notes(query):
    """Search across all review notes for relevant content."""
    results = []
    query_lower = query.lower()
    for domain, content in notes.items():
        lines = content.split('\n')
        for i, line in enumerate(lines):
            if query_lower in line.lower():
                # Get surrounding context (3 lines before/after)
                start = max(0, i - 3)
                end = min(len(lines), i + 4)
                context = '\n'.join(lines[start:end])
                results.append({"domain": domain, "context": context, "line": i})
        if len(results) >= 10:
            break
    return results


def search_questions(query):
    """Find questions related to the query."""
    query_lower = query.lower()
    matches = []
    for q in questions_bank:
        score = sum(1 for word in query_lower.split() if len(word) > 3 and word in q["question"].lower())
        if score >= 1:
            matches.append((score, q))
    matches.sort(key=lambda x: -x[0])
    return [q for _, q in matches[:5]]


# Display chat history
for msg in st.session_state.chat_history:
    if msg["role"] == "user":
        st.markdown(f"""
        <div style="background:#1B2332;border-radius:12px;padding:12px 16px;margin:8px 0;border-left:4px solid #29B5E8;">
            <strong style="color:#29B5E8;">You:</strong> {msg["content"]}
        </div>
        """, unsafe_allow_html=True)
    else:
        st.markdown(f"""
        <div style="background:#FFFFFF;border-radius:12px;padding:14px 18px;margin:8px 0;border-left:4px solid #4ECB71;color:#333;">
            <strong style="color:#4ECB71;">Assistant:</strong><br>{msg["content"]}
        </div>
        """, unsafe_allow_html=True)

# Input
user_q = st.chat_input("Ask a Snowflake question... e.g., 'Where is query history stored?' or 'What is micro-partition metadata?'")

if user_q:
    st.session_state.chat_history.append({"role": "user", "content": user_q})

    # Search notes
    note_results = search_notes(user_q)
    q_results = search_questions(user_q)

    # Build response
    response_parts = []

    if note_results:
        response_parts.append(f"<h4 style='color:#29B5E8;'>📖 Found in your notes ({len(note_results)} matches):</h4>")
        for r in note_results[:5]:
            domain_short = r["domain"].split(": ")[1] if ": " in r["domain"] else r["domain"]
            # Clean up context for display
            ctx = r["context"].replace('\n', '<br>')
            ctx = ctx.replace('**', '<strong>').replace('**', '</strong>')
            response_parts.append(
                f"<div style='background:#F5F5F5;border-left:3px solid #29B5E8;padding:8px 12px;margin:6px 0;border-radius:4px;'>"
                f"<span style='color:#29B5E8;font-weight:600;font-size:0.8rem;'>{domain_short}</span><br>"
                f"<span style='font-size:0.9rem;'>{ctx}</span></div>"
            )

    if q_results:
        response_parts.append(f"<h4 style='color:#C084FC;'>🧠 Related practice questions:</h4>")
        for q in q_results[:3]:
            correct = [q["options"][i]["text"] for i in q["correct_indices"] if i < len(q["options"])]
            response_parts.append(
                f"<div style='background:#F3E8FF;border-left:3px solid #C084FC;padding:8px 12px;margin:6px 0;border-radius:4px;'>"
                f"<strong>Q:</strong> {q['question'][:150]}<br>"
                f"<strong style='color:#4CAF50;'>A:</strong> {' | '.join(correct)}</div>"
            )

    if not note_results and not q_results:
        response_parts.append(
            "<p>No matches found in your notes or question bank. Try different keywords, or check the "
            "<a href='https://docs.snowflake.com' target='_blank' style='color:#29B5E8;'>Snowflake Documentation</a>.</p>"
        )

    # Add doc search suggestion
    doc_url = f"https://docs.snowflake.com/en/search#{user_q.replace(' ', '+')}"
    response_parts.append(
        f"<br><a href='{doc_url}' target='_blank' style='color:#29B5E8;text-decoration:none;'>"
        f"🔗 Search Snowflake Docs for \"{user_q}\"</a>"
    )

    full_response = "\n".join(response_parts)
    st.session_state.chat_history.append({"role": "assistant", "content": full_response})
    st.rerun()

# Clear chat button
if st.session_state.chat_history:
    if st.button("🗑️ Clear chat", key="clear_chat"):
        st.session_state.chat_history = []
        st.rerun()

# Tips
st.markdown("---")
st.markdown("""
<div style="background:#1B2332;border-radius:10px;padding:14px;margin-top:12px;">
    <strong style="color:#FFD93D;">💡 Tips:</strong><br>
    <span style="color:#9CA3AF;">
    • Search for concepts: "micro-partition metadata", "Time Travel retention"<br>
    • Search for comparisons: "ACCOUNT_USAGE vs INFORMATION_SCHEMA"<br>
    • Search for traps: "reader account DML"<br>
    • Click the Snowflake Docs link for official documentation
    </span>
</div>
""", unsafe_allow_html=True)
