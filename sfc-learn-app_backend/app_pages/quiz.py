"""Quiz mode - interactive practice with clear/retry, similar questions, progress saving."""
import streamlit as st
import random
import re
from datetime import datetime

from app_pages.persistence import load_user_notes, save_user_notes
from i18n import t

# ── Sidebar: Navigation buttons ──
_nav1, _nav2 = st.sidebar.columns(2)
with _nav1:
    if st.button(":material/home: Home", key="quiz_home", use_container_width=True):
        st.session_state.app_mode = None
        st.switch_page("app_pages/landing.py")
with _nav2:
    if st.button(":material/arrow_back: Dashboard", key="quiz_dash", use_container_width=True):
        st.switch_page("app_pages/dashboard.py")

DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_CSS_NUM = st.session_state.get("DOMAIN_CSS_NUM", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})

# Load domain tips from registry (dynamic per cert)
active_cert = st.session_state.get("_active_cert", "core")
registry = st.session_state.get("CERT_REGISTRY", {})
cert_info = registry.get(active_cert, registry.get("core", {}))
DOMAIN_TIPS = cert_info.get("domain_tips", {})

MARKER_COLORS = ["yellow", "pink", "blue", "green"]


def _quiz_save_notes():
    """Save quiz highlights to persistence, preserving review highlights."""
    user_notes = load_user_notes()
    quiz_highlights = st.session_state.get("quiz_highlights", [])
    # Preserve review highlights (section keys NOT starting with "quiz_")
    review_highlights = [h for h in user_notes.get("highlights", []) if not h.get("section", "").startswith("quiz_")]
    user_notes["highlights"] = review_highlights + quiz_highlights
    save_user_notes(user_notes)


def _render_quiz_marker(widget_key, section_key):
    """Render a compact text-marking tool for quiz questions."""
    highlights = st.session_state.get("quiz_highlights", [])
    section_highlights = [h for h in highlights if h.get("section") == section_key]

    # Show existing highlights as inline chips
    if section_highlights:
        chips_html = []
        for hl in section_highlights:
            mc = hl.get("color", "yellow")
            chips_html.append(f'<span class="mark-{mc}" style="margin-right:6px;">{hl["text"]}</span>')
        st.markdown(
            f'<div style="background:#FAFAFA;border-radius:8px;padding:8px 12px;margin:4px 0;line-height:2;">'
            f'{"".join(chips_html)}</div>',
            unsafe_allow_html=True,
        )
        # Delete buttons in a compact row
        del_cols = st.columns(min(len(section_highlights), 6))
        for hi, hl in enumerate(section_highlights):
            with del_cols[hi % len(del_cols)]:
                mc = hl.get("color", "yellow")
                label = f"x {hl['text'][:15]}..." if len(hl["text"]) > 15 else f"x {hl['text']}"
                if st.button(label, key=f"qhdel_{widget_key}_{hi}", help=f"Remove: {hl['text']}"):
                    st.session_state.quiz_highlights = [
                        h for h in highlights
                        if not (h.get("section") == section_key and h["text"] == hl["text"])
                    ]
                    _quiz_save_notes()
                    st.rerun()

    # Marker input - compact expander style
    with st.expander("Marker", expanded=st.session_state.get(f"_qmarking_{section_key}", False)):
        color_col, text_col = st.columns([1, 3])
        with color_col:
            mark_color = st.radio(
                "Color", MARKER_COLORS,
                format_func=lambda c: c.title(),
                key=f"qmcolor_{widget_key}",
                horizontal=True, label_visibility="collapsed",
            )
        with text_col:
            mark_text = st.text_input(
                "Text to highlight",
                key=f"qmtext_{widget_key}",
                placeholder="Copy-paste text from the question to highlight it",
                label_visibility="collapsed",
            )
        if st.button("Mark", key=f"qmsave_{widget_key}", type="primary", use_container_width=True, disabled=not mark_text):
            if mark_text.strip():
                st.session_state.setdefault("quiz_highlights", []).append({
                    "section": section_key,
                    "text": mark_text.strip(),
                    "color": mark_color,
                })
                _quiz_save_notes()
                st.rerun()


def _apply_quiz_highlights(text, section_key):
    """Apply saved highlights to question/option text.

    Allows HTML tags between words so highlights work even when text
    is wrapped in <strong>, <code>, etc.
    Uses inline styles to ensure visibility regardless of CSS loading.
    """
    from theme import T
    highlights = st.session_state.get("quiz_highlights", [])
    section_highlights = [h for h in highlights if h.get("section") == section_key]
    for hl in section_highlights:
        mc = hl.get("color", "yellow")
        bg = T.MARKS.get(mc, "#FFF176")
        words = hl["text"].split()
        if not words:
            continue
        tag_gap = r'(?:\s*(?:<[^>]*>\s*)*\s*)'
        pattern = tag_gap.join(re.escape(w) for w in words)
        text = re.sub(
            f'({pattern})',
            f'<span style="background:{bg};color:#1a1a2e;padding:1px 4px;border-radius:2px;">\\1</span>',
            text,
            count=1,
            flags=re.IGNORECASE,
        )
    return text


def _format_option_text(text):
    """Format option text for HTML display, handling multi-step scenario options."""
    if "\n" in text:
        lines = text.split("\n")
        formatted = []
        has_steps = False
        for line in lines:
            step_match = re.match(r'^(\d+\.)\s+(.+)$', line.strip())
            if step_match:
                has_steps = True
                formatted.append(f'<span class="step-num">{step_match.group(1)}</span> {step_match.group(2)}')
            else:
                formatted.append(line)
        inner = "<br>".join(formatted)
        if has_steps:
            return f'<div class="scenario-option">{inner}</div>'
        return inner
    return text

questions = st.session_state.questions

# Load quiz highlights from persistence (once per session)
if "quiz_highlights_loaded" not in st.session_state:
    _saved_notes = load_user_notes()
    st.session_state.quiz_highlights = _saved_notes.get("highlights", [])
    st.session_state.quiz_highlights_loaded = True
st.session_state.setdefault("quiz_highlights", [])

# ── Quiz setup ──
if not st.session_state.quiz_active:
    st.markdown(f"""
    <h1 style="margin-bottom:4px;">{t("quiz_mode_title")}</h1>
    <p style="color:#9CA3AF; margin-top:0;">{t("quiz_mode_subtitle")}</p>
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
            t("filter_by_domain"),
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
            t("filter_by_source"),
            source_options,
            index=default_src,
            key="quiz_source_select",
        )

    with col3:
        # Multi-select only toggle
        pre_multi = st.session_state.pop("quiz_multi_only", False)
        multi_only = st.checkbox(t("multi_select_only"), value=pre_multi, key="quiz_multi_check")

    quiz_size = st.slider(t("num_questions"), min_value=5, max_value=100, value=25, step=5)

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
        st.markdown(
f'<div class="domain-card domain-{css_num}" style="padding:12px 16px;">'
f'<p>{emoji} <strong>{len(pool)}</strong> questions available for <strong>{domain_filter}</strong>'
f' ({multi_in_pool} multi-select)</p>'
'</div>', unsafe_allow_html=True)
    else:
        multi_in_pool = sum(1 for q in pool if q.get("multi_select"))
        st.caption(f"{len(pool)} {t('questions_available')} ({multi_in_pool} multi-select)")

    col1, col2 = st.columns(2)
    with col1:
        if st.button(t("start_quiz_btn"), type="primary", use_container_width=True, disabled=len(pool) == 0):
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
        if st.button(t("full_exam_sim"), use_container_width=True, disabled=len(pool) < 100):
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
        st.markdown(f"### {t('recent_scores')}")
        for entry in reversed(st.session_state.quiz_score_history[-5:]):
            pct = entry["score"] / max(entry["total"], 1) * 100
            if pct >= 75:
                bar_color = "#4ECB71"
                icon = "+"
            elif pct >= 50:
                bar_color = "#FFD93D"
                icon = "~"
            else:
                bar_color = "#FF6B6B"
                icon = "-"
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
    emoji = DOMAIN_EMOJIS.get(domain, "")
    color = DOMAIN_COLORS.get(domain, "#6B7280")

    # Progress bar
    progress = (idx + 1) / total
    st.progress(progress)

    # Navigation bar
    nav_col1, nav_col2, nav_col3, nav_col4 = st.columns([2, 1, 1, 1])

    with nav_col1:
        answered = len(st.session_state.quiz_submitted)
        st.markdown(f"**{t('question_x_of_y').replace('{x}', str(idx + 1)).replace('{y}', str(total))}** | {t('answered')}: **{answered}**/{total}")

    with nav_col2:
        if st.button(t("prev"), disabled=idx == 0, use_container_width=True):
            st.session_state.quiz_index = idx - 1
            st.rerun()

    with nav_col3:
        if st.button("Next", disabled=idx == total - 1, use_container_width=True):
            st.session_state.quiz_index = idx + 1
            st.rerun()

    with nav_col4:
        if st.button(t("end_quiz"), use_container_width=True, type="secondary"):
            correct = 0
            domain_scores = {}  # {domain: {"correct": N, "total": N}}
            for qi, qdata in enumerate(quiz_qs):
                qid = qdata["id"]
                if qid in st.session_state.quiz_submitted:
                    user_ans = st.session_state.quiz_answers.get(qid, [])
                    q_domain = qdata.get("domain", "Unknown")
                    is_correct = sorted(user_ans) == sorted(qdata["correct_indices"])
                    if is_correct:
                        correct += 1
                    ds = domain_scores.setdefault(q_domain, {"correct": 0, "total": 0})
                    ds["total"] += 1
                    if is_correct:
                        ds["correct"] += 1
            entry = {
                "score": correct,
                "total": len(st.session_state.quiz_submitted),
                "domain": st.session_state.quiz_domain_filter,
                "source": st.session_state.quiz_source_filter,
                "date": datetime.now().strftime("%Y-%m-%d %H:%M"),
                "domain_scores": domain_scores,
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
    st.markdown(
f'<div class="q-domain-bar q-domain-bar-{css_num}">'
f'{emoji} {short_domain} &bull; <span style="opacity:0.7;">{q["source"]} Q#{q["question_num"]}</span>{multi_badge}'
'</div>', unsafe_allow_html=True)

    # Question text
    q_hl_key = f"quiz_{active_cert}_{q['id']}"
    q_text_hl = _apply_quiz_highlights(q['question'], q_hl_key)
    st.markdown(f'<div class="question-card"><h3>{q_text_hl}</h3></div>', unsafe_allow_html=True)

    # Multi-select indicator
    num_correct = len(q["correct_indices"])
    if num_correct > 1:
        st.info(t("select_answers").replace("{n}", str(num_correct)))

    qid = q["id"]
    is_submitted = qid in st.session_state.quiz_submitted

    # ── Render options ──
    option_texts = [opt["text"] for opt in q["options"]]

    if num_correct > 1:
        # Multi-select
        selected = st.session_state.quiz_answers.get(qid, [])

        for oi, opt in enumerate(q["options"]):
            opt_key = f"q{idx}_opt{oi}"

            if is_submitted:
                is_correct_opt = oi in q["correct_indices"]
                was_selected = oi in selected

                if is_correct_opt and was_selected:
                    st.markdown(f'<div class="feedback-correct">{_format_option_text(opt["text"])}</div>', unsafe_allow_html=True)
                elif is_correct_opt and not was_selected:
                    st.markdown(f'<div class="feedback-missed">{_format_option_text(opt["text"])} <em>({t("correct_missed")})</em></div>', unsafe_allow_html=True)
                elif not is_correct_opt and was_selected:
                    st.markdown(f'<div class="feedback-wrong">{_format_option_text(opt["text"])}</div>', unsafe_allow_html=True)
                else:
                    st.markdown(f"&emsp;&emsp;{opt['text']}")

                if opt.get("explanation") and (is_correct_opt or was_selected):
                    st.caption(f"&emsp;&emsp;&emsp;{opt['explanation']}")
            else:
                checked = oi in selected
                if st.checkbox(opt["text"], key=opt_key, value=checked):
                    if oi not in selected:
                        selected.append(oi)
                else:
                    if oi in selected:
                        selected.remove(oi)
                st.session_state.quiz_answers[qid] = selected

    else:
        # Single-select
        current_answer = st.session_state.quiz_answers.get(qid, None)
        current_sel = current_answer[0] if current_answer else None

        if is_submitted:
            for oi, opt in enumerate(q["options"]):
                is_correct_opt = oi in q["correct_indices"]
                was_selected = (current_sel == oi)

                if is_correct_opt:
                    st.markdown(f'<div class="feedback-correct">{_format_option_text(opt["text"])}</div>', unsafe_allow_html=True)
                elif was_selected and not is_correct_opt:
                    st.markdown(f'<div class="feedback-wrong">{_format_option_text(opt["text"])}</div>', unsafe_allow_html=True)
                else:
                    st.markdown(f"&emsp;&emsp;{opt['text']}")

                if opt.get("explanation") and (is_correct_opt or was_selected):
                    st.caption(f"&emsp;&emsp;&emsp;{opt['explanation']}")
        else:
            radio_key = f"q{idx}_radio"
            choice = st.radio(
                t("select_your_answer"),
                range(len(option_texts)),
                format_func=lambda i: option_texts[i],
                index=current_sel,
                key=radio_key,
                label_visibility="collapsed",
            )
            # Only store answer if user has explicitly interacted (not auto-default)
            if current_sel is not None or st.session_state.get(f"_radio_touched_{qid}"):
                st.session_state.quiz_answers[qid] = [choice]
                st.session_state[f"_radio_touched_{qid}"] = True
            elif choice != 0:
                # User picked something other than default first option
                st.session_state.quiz_answers[qid] = [choice]
                st.session_state[f"_radio_touched_{qid}"] = True

    # ── Submit / Clear / Feedback ──
    if not is_submitted:
        btn_col1, btn_col2 = st.columns(2)
        with btn_col1:
            if st.button(t("submit_answer"), type="primary", key=f"submit_{idx}", use_container_width=True):
                user_ans = st.session_state.quiz_answers.get(qid, [])
                if user_ans:
                    st.session_state.quiz_submitted[qid] = True
                    tips = DOMAIN_TIPS.get(domain, [])
                    if tips:
                        st.toast(random.choice(tips))
                    st.rerun()
                else:
                    st.warning(t("select_answer_first"))
        with btn_col2:
            if st.button(t("clear_answer"), key=f"clear_{idx}", use_container_width=True):
                st.session_state.quiz_answers.pop(qid, None)
                st.session_state.pop(f"_radio_touched_{qid}", None)
                st.rerun()
    else:
        user_ans = st.session_state.quiz_answers.get(qid, [])
        is_correct = sorted(user_ans) == sorted(q["correct_indices"])

        if is_correct:
            st.markdown(
'<div style="background:rgba(78,203,113,0.15); border:2px solid #4ECB71; border-radius:10px; padding:14px 18px; text-align:center; margin:10px 0;">'
f'<strong style="color:#4ECB71; font-size:1.1rem;">{t("correct_answer")}</strong>'
'</div>', unsafe_allow_html=True)
        else:
            correct_texts = [q["options"][i]["text"] for i in q["correct_indices"] if i < len(q["options"])]
            st.markdown(
'<div style="background:rgba(255,107,107,0.15); border:2px solid #FF6B6B; border-radius:10px; padding:14px 18px; margin:10px 0;">'
f'<strong style="color:#FF6B6B;">{t("incorrect_answer")}</strong>'
f'<br>{t("correct_was")} <strong>{" | ".join(correct_texts)}</strong>'
'</div>', unsafe_allow_html=True)

        # Overall explanation
        if q.get("overall_explanation"):
            with st.expander("Explanation", expanded=True):
                st.markdown(q["overall_explanation"])

        # Per-option explanation button (for questions without per-option explanations)
        has_per_opt = any(opt.get("explanation") for opt in q["options"])
        if not has_per_opt:
            explain_key = f"explain_{idx}"
            if st.button(t("explain_each_option"), key=explain_key, use_container_width=True):
                st.session_state[f"show_explain_{idx}"] = True

            if st.session_state.get(f"show_explain_{idx}", False):
                correct_texts = [q["options"][i]["text"] for i in q["correct_indices"] if i < len(q["options"])]
                overall = q.get("overall_explanation", "")
                st.markdown('<div style="background:rgba(128,128,128,0.08);border-radius:10px;padding:16px;margin:8px 0;">', unsafe_allow_html=True)
                for oi, opt in enumerate(q["options"]):
                    is_corr = oi in q["correct_indices"]
                    if is_corr:
                        st.markdown(
'<div style="background:#E8F5E9;border-left:4px solid #4CAF50;padding:8px 12px;margin:4px 0;border-radius:4px;">'
f'<strong style="color:#2E7D32;">{_format_option_text(opt["text"])}</strong><br>'
f'<span style="color:#1a1a2e;">{t("this_is_correct")} {overall[:200] if overall else ""}</span>'
'</div>', unsafe_allow_html=True)
                    else:
                        st.markdown(
'<div style="background:#FFEBEE;border-left:4px solid #F44336;padding:8px 12px;margin:4px 0;border-radius:4px;">'
f'<strong style="color:#C62828;">{_format_option_text(opt["text"])}</strong><br>'
f'<span style="color:#1a1a2e;">{t("not_correct")} {", ".join(correct_texts)}</span>'
'</div>', unsafe_allow_html=True)
                st.markdown('</div>', unsafe_allow_html=True)

        # Action buttons: retry + similar question
        act_col1, act_col2 = st.columns(2)
        with act_col1:
            if st.button(t("retry_question"), key=f"retry_{idx}", use_container_width=True):
                st.session_state.quiz_submitted.pop(qid, None)
                st.session_state.quiz_answers.pop(qid, None)
                st.session_state.pop(f"_radio_touched_{qid}", None)
                st.rerun()
        with act_col2:
            if st.button(t("similar_question"), key=f"similar_{idx}", use_container_width=True):
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
                    st.toast(f"{t('added_similar')} {short_domain}")
                    st.rerun()
                else:
                    st.toast(t("no_more_questions"))

        # Domain tip
        tips = DOMAIN_TIPS.get(domain, [])
        if tips:
            with st.expander(f"{emoji} {short_domain} -- {t('quick_tip')}"):
                tip = random.choice(tips)
                st.markdown(f'<div class="mnemonic">{tip}</div>', unsafe_allow_html=True)

        # ── Sticky note per question (click to add) ──
        active_cert = st.session_state.get("_active_cert", "core")
        note_key = f"quiz_note_{active_cert}_{q['id']}"
        user_notes = load_user_notes()
        saved_raw = user_notes.get("comments", {}).get(note_key, {})
        # Migrate old string format
        if isinstance(saved_raw, str) and saved_raw:
            saved_raw = {"text": saved_raw, "color": "yellow"}
            user_notes.setdefault("comments", {})[note_key] = saved_raw
            save_user_notes(user_notes)

        _NOTE_COLORS = ["yellow", "pink", "blue", "green", "purple", "orange"]

        if saved_raw and saved_raw.get("text"):
            nc = saved_raw.get("color", "yellow")
            st.markdown(
                f'<div class="sticky-note sticky-{nc}">{saved_raw["text"]}</div>',
                unsafe_allow_html=True,
            )
            ec1, ec2 = st.columns([1, 1])
            with ec1:
                if st.button(t("edit_note"), key=f"qedit_{idx}", use_container_width=True):
                    st.session_state[f"_qediting_{note_key}"] = True
                    st.rerun()
            with ec2:
                if st.button(t("delete_note"), key=f"qdel_{idx}", use_container_width=True):
                    user_notes.get("comments", {}).pop(note_key, None)
                    save_user_notes(user_notes)
                    st.rerun()

        show_editor = st.session_state.get(f"_qediting_{note_key}", False)

        if not (saved_raw and saved_raw.get("text")) and not show_editor:
            if st.button("+  Note", key=f"qplus_{idx}", type="secondary"):
                st.session_state[f"_qediting_{note_key}"] = True
                st.rerun()

        if show_editor or (saved_raw and saved_raw.get("text") and st.session_state.get(f"_qediting_{note_key}")):
            cur_text = saved_raw.get("text", "") if saved_raw else ""
            cur_color = saved_raw.get("color", "yellow") if saved_raw else "yellow"
            ci = _NOTE_COLORS.index(cur_color) if cur_color in _NOTE_COLORS else 0
            qc_col, qc_save, qc_cancel = st.columns([2, 1, 1])
            with qc_col:
                pick_color = st.selectbox(
                    "Color", _NOTE_COLORS, index=ci,
                    format_func=lambda c: c.title(),
                    key=f"qcolor_{idx}", label_visibility="collapsed",
                )
            note_text = st.text_area(
                t("note_placeholder"),
                value=cur_text, key=f"qta_{idx}", height=100,
            )
            with qc_save:
                if st.button(t("save"), key=f"qsave_{idx}", type="primary", use_container_width=True):
                    if note_text.strip():
                        user_notes.setdefault("comments", {})[note_key] = {
                            "text": note_text.strip(), "color": pick_color,
                        }
                    else:
                        user_notes.get("comments", {}).pop(note_key, None)
                    save_user_notes(user_notes)
                    st.session_state.pop(f"_qediting_{note_key}", None)
                    st.rerun()
            with qc_cancel:
                if st.button(t("cancel"), key=f"qcancel_{idx}", use_container_width=True):
                    st.session_state.pop(f"_qediting_{note_key}", None)
                    st.rerun()

        # ── Marker tool per question ──
        marker_q_key = f"qmark_{idx}"
        _render_quiz_marker(marker_q_key, q_hl_key)

    # ── Question navigator ──
    st.markdown("---")
    st.caption("Jump to question:")
    nav_count = min(20, total)
    nav_cols = st.columns(nav_count)
    for qi in range(nav_count):
        with nav_cols[qi]:
            nav_qid = quiz_qs[qi]["id"]
            is_answered = nav_qid in st.session_state.quiz_submitted
            if qi == idx:
                label = f"**[{qi+1}]**"
            elif is_answered:
                user_ans = st.session_state.quiz_answers.get(nav_qid, [])
                if sorted(user_ans) == sorted(quiz_qs[qi]["correct_indices"]):
                    label = "+"
                else:
                    label = "-"
            else:
                label = f"{qi+1}"

            if st.button(label, key=f"nav_{qi}", use_container_width=True):
                st.session_state.quiz_index = qi
                st.rerun()

    if total > 20:
        st.caption(f"Showing first 20 of {total}. Use Prev/Next for the rest.")
