"""Score tracker page - visual performance tracking with domain colors."""
import streamlit as st

# ── Sidebar: Home button ──
if st.sidebar.button("🏠 Home", key="progress_home", use_container_width=True):
    st.session_state.app_mode = None
    st.switch_page("app_pages/landing.py")

DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_CSS_NUM = st.session_state.get("DOMAIN_CSS_NUM", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})

st.markdown("""
<h1 style="margin-bottom:4px;">📈 Score Tracker</h1>
<p style="color:#9CA3AF; margin-top:0;">Track your quiz performance and identify weak areas</p>
""", unsafe_allow_html=True)

history = st.session_state.quiz_score_history

if not history:
    st.markdown("""
    <div style="background:#1B2332; border-radius:12px; padding:40px; text-align:center; margin:20px 0;">
        <p style="font-size:2.5rem; margin:0;">🧠</p>
        <p style="font-size:1.2rem; color:#FAFAFA; margin:10px 0;">No quiz scores yet</p>
        <p style="color:#9CA3AF;">Go to <strong>Quiz Mode</strong> to start practicing!</p>
    </div>
    """, unsafe_allow_html=True)
    if st.button("🚀 Start a quiz", type="primary"):
        st.switch_page("app_pages/quiz.py")
else:
    # ── Overall stats ──
    total_answered = sum(e["total"] for e in history)
    total_correct = sum(e["score"] for e in history)
    overall_pct = total_correct / total_answered * 100 if total_answered > 0 else 0

    cols = st.columns(4)
    stats = [
        (str(len(history)), "Quizzes taken"),
        (str(total_answered), "Questions answered"),
        (f"{overall_pct:.1f}%", "Overall accuracy"),
    ]

    for col, (val, label) in zip(cols[:3], stats):
        with col:
            st.markdown(f"""
            <div class="stat-card">
                <p class="stat-value" style="font-size:1.5rem;">{val}</p>
                <p class="stat-label">{label}</p>
            </div>
            """, unsafe_allow_html=True)

    # Readiness badge
    with cols[3]:
        if overall_pct >= 75 and total_answered >= 20:
            badge_color = "#4ECB71"
            badge_text = "✅ Ready"
            badge_sub = f"+{overall_pct - 75:.1f}% above 75%"
        elif total_answered < 20:
            badge_color = "#FFD93D"
            badge_text = "📝 Keep going"
            badge_sub = f"Need {20 - total_answered} more Qs"
        else:
            badge_color = "#FF6B6B"
            badge_text = "📖 Keep studying"
            badge_sub = f"{75 - overall_pct:.1f}% below 75%"

        st.markdown(f"""
        <div class="stat-card" style="border:2px solid {badge_color};">
            <p class="stat-value" style="font-size:1.3rem; color:{badge_color};">{badge_text}</p>
            <p class="stat-label">{badge_sub}</p>
        </div>
        """, unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)

    # ── Score trend chart ──
    st.markdown("### 📊 Score Trend")

    if len(history) >= 2:
        import altair as alt
        import pandas as pd

        chart_data = pd.DataFrame([
            {
                "Quiz": i + 1,
                "Score (%)": e["score"] / e["total"] * 100,
                "Domain": e["domain"],
            }
            for i, e in enumerate(history)
        ])

        line = alt.Chart(chart_data).mark_line(
            point=alt.OverlayMarkDef(filled=True, size=60),
            color="#29B5E8",
        ).encode(
            x=alt.X("Quiz:Q", title="Quiz number"),
            y=alt.Y("Score (%):Q", title="Score %", scale=alt.Scale(domain=[0, 100])),
            tooltip=["Quiz", "Score (%)", "Domain"],
        )

        threshold = alt.Chart(
            pd.DataFrame({"y": [75]})
        ).mark_rule(color="#FF6B6B", strokeDash=[5, 5]).encode(
            y="y:Q",
        )

        st.altair_chart(line + threshold, use_container_width=True)
        st.caption("Red dashed line = 75% passing threshold")
    else:
        st.caption("Take at least 2 quizzes to see your trend chart.")

    st.markdown("<br>", unsafe_allow_html=True)

    # ── Domain breakdown with colored bars ──
    st.markdown("### 🎯 Performance by Domain")

    domain_scores = {}
    for e in history:
        d = e["domain"]
        if d not in domain_scores:
            domain_scores[d] = {"correct": 0, "total": 0}
        domain_scores[d]["correct"] += e["score"]
        domain_scores[d]["total"] += e["total"]

    for domain in [
        "Domain 1: Architecture",
        "Domain 2: Account & Governance",
        "Domain 3: Data Loading",
        "Domain 4: Performance & Querying",
        "Domain 5: Collaboration",
        "All",
    ]:
        if domain in domain_scores:
            data = domain_scores[domain]
            pct = data["correct"] / data["total"] * 100
            color = DOMAIN_COLORS.get(domain, "#6B7280")
            css_num = DOMAIN_CSS_NUM.get(domain, "unknown")
            emoji = DOMAIN_EMOJIS.get(domain, "📋")
            short = domain.split(": ")[1] if ": " in domain else domain
            bar_width = min(pct, 100)

            if pct >= 75:
                status = "✅ On track"
                status_color = "#4ECB71"
            elif pct >= 50:
                status = "⚠️ Needs work"
                status_color = "#FFD93D"
            else:
                status = "🔴 Focus here"
                status_color = "#FF6B6B"

            st.markdown(f"""
            <div style="background:#1B2332; border-radius:10px; padding:14px 18px; margin:8px 0; border-left:4px solid {color};">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                    <span>{emoji} <strong>{short}</strong> — <span style="color:{color}; font-weight:700;">{pct:.0f}%</span> ({data['correct']}/{data['total']})</span>
                    <span style="color:{status_color}; font-size:0.85rem;">{status}</span>
                </div>
                <div style="background:#2D3748; border-radius:4px; height:8px; overflow:hidden;">
                    <div style="background:{color}; width:{bar_width}%; height:100%; border-radius:4px;"></div>
                </div>
            </div>
            """, unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)

    # ── Weak areas ──
    st.markdown("### ⚠️ Weak Areas to Focus On")

    weak = []
    for domain, data in domain_scores.items():
        pct = data["correct"] / data["total"] * 100
        if pct < 75 and domain != "All":
            weak.append((domain, pct, data["total"]))

    if weak:
        weak.sort(key=lambda x: x[1])
        for domain, pct, total_q in weak:
            color = DOMAIN_COLORS.get(domain, "#6B7280")
            emoji = DOMAIN_EMOJIS.get(domain, "")
            st.markdown(f"""
            <div class="exam-trap">
                {emoji} <strong>{domain}</strong> — {pct:.0f}% accuracy ({total_q} questions).
                Review notes and take a domain-focused quiz.
            </div>
            """, unsafe_allow_html=True)
    else:
        if total_answered >= 50:
            st.markdown("""
            <div class="feedback-correct" style="text-align:center;">
                🎉 <strong>All domains above 75%! You're looking good for the exam.</strong>
            </div>
            """, unsafe_allow_html=True)
        else:
            st.caption("Keep taking quizzes to identify weak areas (need 50+ questions for reliable data).")

    st.markdown("<br>", unsafe_allow_html=True)

    # ── Quiz history ──
    st.markdown("### 📋 Quiz History")

    for i, e in enumerate(reversed(history)):
        pct = e["score"] / e["total"] * 100
        if pct >= 75:
            bar_color = "#4ECB71"
            icon = "✅"
        elif pct >= 50:
            bar_color = "#FFD93D"
            icon = "⚠️"
        else:
            bar_color = "#FF6B6B"
            icon = "❌"

        st.markdown(f"""
        <div style="background:#1B2332; border-radius:8px; padding:10px 16px; margin:4px 0; border-left:4px solid {bar_color};">
            {icon} <strong>{e['score']}/{e['total']}</strong> ({pct:.0f}%) —
            {e['domain']} | {e['source']} | {e['date']}
        </div>
        """, unsafe_allow_html=True)

    # ── Clear history ──
    st.markdown("---")
    if st.button("🗑️ Clear all scores", type="secondary"):
        st.session_state.quiz_score_history = []
        st.rerun()
