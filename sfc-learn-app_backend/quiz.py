"""Quiz mode - interactive practice with clear/retry, similar questions, progress saving."""
import streamlit as st
import random
from datetime import datetime

# ── Sidebar: Home button ──
if st.sidebar.button("🏠 Home", key="quiz_home", use_container_width=True):
    st.session_state.app_mode = None
    st.switch_page("app_pages/landing.py")

DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_CSS_NUM = st.session_state.get("DOMAIN_CSS_NUM", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})

# Load domain tips from registry (dynamic per cert)
active_cert = st.session_state.get("_active_cert", "core")
registry = st.session_state.get("CERT_REGISTRY", {})
cert_info = registry.get(active_cert, registry.get("core", {}))
DOMAIN_TIPS = cert_info.get("domain_tips", {})

questions = st.session_state.questions

# ── Quiz setup ──
if not st.session_state.quiz_active:
    st.markdown("""
    <h1 style="margin-bottom:4px;">🧠 Quiz Mode</h1>
    <p style="color:#9CA3AF; margin-top:0;">Configure your quiz, start practicing, get instant feedback.</p>
    """, unsafe_allow_html=True)

    col1, col2, col3 = st.columns(3)

    with col1:
        domains = ["All"] + sorted(set(q["domain"] for q in questions if q["domain"] != "Untagged")) + ["Untagged"]
        # Pre-select domain if coming from dashboard
        default_idx = 0
        pre_domain = st.session_state.get("quiz_domain_filter", "All")
        if pre_domain in domains:
            default_idx = domains.index(pre_domain)
        domain_filter = st.selectbox(
            "Filter by domain",
            domains,
            index=default_idx,
            key="quiz_domain_select",
        )

    with col2:
        # Dynamic source filter based on actual question sources
        all_prefixes = sorted(set(q["source"].rsplit("_test", 1)[0] if "_test" in q["source"] else q["source"] for q in questions))
        source_options = ["All"] + all_prefixes
        pre_source = st.session_state.get("quiz_source_filter", "All")
        default_src = source_options.index(pre_source) if pre_source in source_options else 0
        source_filter = st.selectbox(
            "Filter by source",
            source_options,
            index=default_src,
            key="quiz_source_select",
        )

    with col3:
        # Multi-select only toggle
        pre_multi = st.session_state.pop("quiz_multi_only", False)
        multi_only = st.checkbox("Multi-select only", value=pre_multi, key="quiz_multi_check")

    quiz_size = st.slider("Number of questions", min_value=5, max_value=100, value=25, step=5)

    # Filter questions
    pool = questions.copy()
    if domain_filter != "All":
        pool = [q for q in pool if q["domain"] == domain_filter]
    if source_filter != "All":
        pool = [q for q in pool if q["source"].startswith(source_filter)]
    if multi_only:
        pool = [q for q in pool if q.get("multi_select")]

    # Show pool info
    if domain_filter != "All" and domain_filter != "Untagged":
        css_num = DOMAIN_CSS_NUM.get(domain_filter, "unknown")
        emoji = DOMAIN_EMOJIS.get(domain_filter, "")
        multi_in_pool = sum(1 for q in pool if q.get("multi_select"))
        st.markdown(f"""
        <div class="domain-card domain-{css_num}" style="padding:12px 16px;">
            <p>{emoji} <strong>{len(pool)}</strong> questions available for <strong>{domain_filter}</strong>
            ({multi_in_pool} multi-select)</p>
        </div>
        """, unsafe_allow_html=True)
    else:
        multi_in_pool = sum(1 for q in pool if q.get("multi_select"))
        st.caption(f"{len(pool)} questions available ({multi_in_pool} multi-select)")

    col1, col2 = st.columns(2)
    with col1:
        if st.button("🚀 Start quiz", type="primary", use_container_width=True, disabled=len(pool) == 0):
            selected = random.sample(pool, min(quiz_size, len(pool)))
            st.session_state.quiz_questions = selected
            st.session_state.quiz_index = 0
            st.session_state.quiz_answers = {}
            st.session_state.quiz_submitted = {}
            st.session_state.quiz_active = True
            st.session_state.quiz_domain_filter = domain_filter
            st.session_state.quiz_source_filter = source_filter
            st.session_state.quiz_size = quiz_size
            st.session_state.quiz_start_time = datetime.now().isoformat()
            st.rerun()

    with col2:
        if st.button("🎯 Full exam simulation (100 Qs)", use_container_width=True, disabled=len(pool) < 100):
            selected = random.sample(pool, 100)
            st.session_state.quiz_questions = selected
            st.session_state.quiz_index = 0
            st.session_state.quiz_answers = {}
            st.session_state.quiz_submitted = {}
            st.session_state.quiz_active = True
            st.session_state.quiz_domain_filter = domain_filter
            st.session_state.quiz_source_filter = source_filter
            st.session_state.quiz_size = 100
            st.session_state.quiz_start_time = datetime.now().isoformat()
            st.rerun()

    # Show recent scores
    if st.session_state.quiz_score_history:
        st.markdown("### 📈 Recent Scores")
        for entry in reversed(st.session_state.quiz_score_history[-5:]):
            pct = entry["score"] / max(entry["total"], 1) * 100
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
            <div style="background:#1B2332; border-radius:8px; padding:10px 16px; margin:6px 0; border-left:4px solid {bar_color};">
                {icon} <strong>{entry['score']}/{entry['total']}</strong> ({pct:.0f}%) —
                {entry.get('domain','All')} | {entry.get('source','All')} | {entry.get('date','')}
            </div>
            """, unsafe_allow_html=True)

else:
    # ── Active quiz ──
    quiz_qs = st.session_state.quiz_questions
    idx = st.session_state.quiz_index
    total = len(quiz_qs)
    q = quiz_qs[idx]
    domain = q["domain"]
    css_num = DOMAIN_CSS_NUM.get(domain, "unknown")
    emoji = DOMAIN_EMOJIS.get(domain, "📋")
    color = DOMAIN_COLORS.get(domain, "#6B7280")

    # Progress bar
    progress = (idx + 1) / total
    st.progress(progress)

    # Navigation bar
    nav_col1, nav_col2, nav_col3, nav_col4 = st.columns([2, 1, 1, 1])

    with nav_col1:
        answered = len(st.session_state.quiz_submitted)
        st.markdown(f"**Question {idx + 1} of {total}** | Answered: **{answered}**/{total}")

    with nav_col2:
        if st.button("⬅️ Prev", disabled=idx == 0, use_container_width=True):
            st.session_state.quiz_index = idx - 1
            st.rerun()

    with nav_col3:
        if st.button("Next ➡️", disabled=idx == total - 1, use_container_width=True):
            st.session_state.quiz_index = idx + 1
            st.rerun()

    with nav_col4:
        if st.button("🛑 End quiz", use_container_width=True, type="secondary"):
            correct = 0
            for qi, qdata in enumerate(quiz_qs):
                if qi in st.session_state.quiz_submitted:
                    user_ans = st.session_state.quiz_answers.get(qi, [])
                    if sorted(user_ans) == sorted(qdata["correct_indices"]):
                        correct += 1
            entry = {
                "score": correct,
                "total": len(st.session_state.quiz_submitted),
                "domain": st.session_state.quiz_domain_filter,
                "source": st.session_state.quiz_source_filter,
                "date": datetime.now().strftime("%Y-%m-%d %H:%M"),
            }
            st.session_state.quiz_score_history.append(entry)
            # Save progress to disk
            save_fn = st.session_state.get("_save_progress")
            if save_fn:
                save_fn()
            st.session_state.quiz_active = False
            st.rerun()

    # ── Domain color bar ──
    short_domain = domain.split(": ")[1] if ": " in domain else domain
    is_multi = q.get("multi_select", False)
    multi_badge = ' <span style="background:#C084FC;color:#0E1117;padding:2px 8px;border-radius:10px;font-size:0.75rem;margin-left:8px;">MULTI-SELECT</span>' if is_multi else ""
    st.markdown(f"""
    <div class="q-domain-bar q-domain-bar-{css_num}">
        {emoji} {short_domain} &bull; <span style="opacity:0.7;">{q['source']} Q#{q['question_num']}</span>{multi_badge}
    </div>
    """, unsafe_allow_html=True)

    # Question text
    st.markdown(f"### {q['question']}")

    # Multi-select indicator
    num_correct = len(q["correct_indices"])
    if num_correct > 1:
        st.info(f"📋 Select **{num_correct}** answers", icon="ℹ️")

    is_submitted = idx in st.session_state.quiz_submitted

    # ── Render options ──
    option_texts = [opt["text"] for opt in q["options"]]

    if num_correct > 1:
        # Multi-select
        selected = st.session_state.quiz_answers.get(idx, [])

        for oi, opt in enumerate(q["options"]):
            opt_key = f"q{idx}_opt{oi}"

            if is_submitted:
                is_correct_opt = oi in q["correct_indices"]
                was_selected = oi in selected

                if is_correct_opt and was_selected:
                    st.markdown(f'<div class="feedback-correct">✅ {opt["text"]}</div>', unsafe_allow_html=True)
                elif is_correct_opt and not was_selected:
                    st.markdown(f'<div class="feedback-missed">⚠️ {opt["text"]} <em>(correct — you missed this)</em></div>', unsafe_allow_html=True)
                elif not is_correct_opt and was_selected:
                    st.markdown(f'<div class="feedback-wrong">❌ {opt["text"]}</div>', unsafe_allow_html=True)
                else:
                    st.markdown(f"&emsp;&emsp;{opt['text']}")

                if opt.get("explanation") and (is_correct_opt or was_selected):
                    st.caption(f"&emsp;&emsp;&emsp;💡 {opt['explanation']}")
            else:
                checked = oi in selected
                if st.checkbox(opt["text"], key=opt_key, value=checked):
                    if oi not in selected:
                        selected.append(oi)
                else:
                    if oi in selected:
                        selected.remove(oi)
                st.session_state.quiz_answers[idx] = selected

    else:
        # Single-select
        current_answer = st.session_state.quiz_answers.get(idx, None)
        current_sel = current_answer[0] if current_answer else None

        if is_submitted:
            for oi, opt in enumerate(q["options"]):
                is_correct_opt = oi in q["correct_indices"]
                was_selected = (current_sel == oi)

                if is_correct_opt:
                    st.markdown(f'<div class="feedback-correct">✅ {opt["text"]}</div>', unsafe_allow_html=True)
                elif was_selected and not is_correct_opt:
                    st.markdown(f'<div class="feedback-wrong">❌ {opt["text"]}</div>', unsafe_allow_html=True)
                else:
                    st.markdown(f"&emsp;&emsp;{opt['text']}")

                if opt.get("explanation") and (is_correct_opt or was_selected):
                    st.caption(f"&emsp;&emsp;&emsp;💡 {opt['explanation']}")
        else:
            choice = st.radio(
                "Select your answer",
                range(len(option_texts)),
                format_func=lambda i: option_texts[i],
                index=current_sel,
                key=f"q{idx}_radio",
                label_visibility="collapsed",
            )
            st.session_state.quiz_answers[idx] = [choice]

    # ── Submit / Clear / Feedback ──
    if not is_submitted:
        btn_col1, btn_col2 = st.columns(2)
        with btn_col1:
            if st.button("✅ Submit answer", type="primary", key=f"submit_{idx}", use_container_width=True):
                user_ans = st.session_state.quiz_answers.get(idx, [])
                if user_ans:
                    st.session_state.quiz_submitted[idx] = True
                    tips = DOMAIN_TIPS.get(domain, [])
                    if tips:
                        st.toast(f"💡 {random.choice(tips)}", icon="🧠")
                    st.rerun()
                else:
                    st.warning("Select an answer first")
        with btn_col2:
            if st.button("🗑️ Clear answer", key=f"clear_{idx}", use_container_width=True):
                st.session_state.quiz_answers.pop(idx, None)
                st.rerun()
    else:
        user_ans = st.session_state.quiz_answers.get(idx, [])
        is_correct = sorted(user_ans) == sorted(q["correct_indices"])

        if is_correct:
            st.markdown("""
            <div style="background:rgba(78,203,113,0.15); border:2px solid #4ECB71; border-radius:10px; padding:14px 18px; text-align:center; margin:10px 0;">
                <span style="font-size:1.4rem;">🎉</span> <strong style="color:#4ECB71; font-size:1.1rem;">Correct!</strong>
            </div>
            """, unsafe_allow_html=True)
        else:
            correct_texts = [q["options"][i]["text"] for i in q["correct_indices"] if i < len(q["options"])]
            st.markdown(f"""
            <div style="background:rgba(255,107,107,0.15); border:2px solid #FF6B6B; border-radius:10px; padding:14px 18px; margin:10px 0;">
                <span style="font-size:1.2rem;">❌</span> <strong style="color:#FF6B6B;">Incorrect.</strong>
                <br>Correct: <strong>{' | '.join(correct_texts)}</strong>
            </div>
            """, unsafe_allow_html=True)

        # Overall explanation
        if q.get("overall_explanation"):
            with st.expander("💡 Explanation", expanded=True):
                st.markdown(q["overall_explanation"])

        # Per-option explanation button (for questions without per-option explanations)
        has_per_opt = any(opt.get("explanation") for opt in q["options"])
        if not has_per_opt:
            explain_key = f"explain_{idx}"
            if st.button("🧠 Explain each option", key=explain_key, use_container_width=True):
                st.session_state[f"show_explain_{idx}"] = True

            if st.session_state.get(f"show_explain_{idx}", False):
                correct_texts = [q["options"][i]["text"] for i in q["correct_indices"] if i < len(q["options"])]
                overall = q.get("overall_explanation", "")
                st.markdown('<div style="background:#F5F5F5;border-radius:10px;padding:16px;margin:8px 0;">', unsafe_allow_html=True)
                for oi, opt in enumerate(q["options"]):
                    is_corr = oi in q["correct_indices"]
                    if is_corr:
                        st.markdown(f"""
                        <div style="background:#E8F5E9;border-left:4px solid #4CAF50;padding:8px 12px;margin:4px 0;border-radius:4px;">
                            <strong style="color:#2E7D32;">✅ {opt["text"]}</strong><br>
                            <span style="color:#333;">This is correct. {overall[:200] if overall else "This matches the Snowflake documentation."}</span>
                        </div>
                        """, unsafe_allow_html=True)
                    else:
                        st.markdown(f"""
                        <div style="background:#FFEBEE;border-left:4px solid #F44336;padding:8px 12px;margin:4px 0;border-radius:4px;">
                            <strong style="color:#C62828;">❌ {opt["text"]}</strong><br>
                            <span style="color:#333;">Not correct. The right answer is: {', '.join(correct_texts)}</span>
                        </div>
                        """, unsafe_allow_html=True)
                st.markdown('</div>', unsafe_allow_html=True)

        # Action buttons: retry + similar question
        act_col1, act_col2 = st.columns(2)
        with act_col1:
            if st.button("🔄 Retry this question", key=f"retry_{idx}", use_container_width=True):
                st.session_state.quiz_submitted.pop(idx, None)
                st.session_state.quiz_answers.pop(idx, None)
                st.rerun()
        with act_col2:
            if st.button("🔍 Similar question", key=f"similar_{idx}", use_container_width=True):
                # Find a question from same domain that isn't in current quiz
                quiz_ids = {qq["id"] for qq in quiz_qs}
                candidates = [qq for qq in questions
                              if qq["domain"] == domain
                              and qq["id"] not in quiz_ids
                              and qq["id"] != q["id"]]
                if candidates:
                    similar = random.choice(candidates)
                    # Insert it after current question
                    quiz_qs.insert(idx + 1, similar)
                    st.session_state.quiz_questions = quiz_qs
                    st.session_state.quiz_index = idx + 1
                    st.toast(f"Added similar question from {short_domain}", icon="🔍")
                    st.rerun()
                else:
                    st.toast("No more questions available in this domain", icon="⚠️")

        # Domain tip
        tips = DOMAIN_TIPS.get(domain, [])
        if tips:
            with st.expander(f"{emoji} {short_domain} — Quick Tip"):
                tip = random.choice(tips)
                st.markdown(f'<div class="mnemonic">{tip}</div>', unsafe_allow_html=True)

    # ── Question navigator ──
    st.markdown("---")
    st.caption("Jump to question:")
    nav_count = min(20, total)
    nav_cols = st.columns(nav_count)
    for qi in range(nav_count):
        with nav_cols[qi]:
            is_answered = qi in st.session_state.quiz_submitted
            if qi == idx:
                label = f"**[{qi+1}]**"
            elif is_answered:
                user_ans = st.session_state.quiz_answers.get(qi, [])
                if sorted(user_ans) == sorted(quiz_qs[qi]["correct_indices"]):
                    label = "✅"
                else:
                    label = "❌"
            else:
                label = f"{qi+1}"

            if st.button(label, key=f"nav_{qi}", use_container_width=True):
                st.session_state.quiz_index = qi
                st.rerun()

    if total > 20:
        st.caption(f"Showing first 20 of {total}. Use Prev/Next for the rest.")
