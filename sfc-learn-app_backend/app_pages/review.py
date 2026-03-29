"""Review notes -- collapsible sections, exam trap cards, per-section AI, markers."""
import streamlit as st
import re, os, hashlib, random

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
from app_pages.ai_helper import ai_complete
from theme import T

try:
    from snowflake.snowpark.context import get_active_session
    get_active_session()
    _HAS_CORTEX = True
except Exception:
    _HAS_CORTEX = False

# ── Cert selector (top of page) ──
active_cert = st.session_state.get("_active_cert", "core")
registry = st.session_state.get("CERT_REGISTRY", {})
cert_info = registry.get(active_cert, registry.get("core", {}))

cert_options = []
cert_keys = []
for rk, rv in registry.items():
    if rv.get("available"):
        cert_options.append(rv["full_name"])
        cert_keys.append(rk)
    else:
        cert_options.append(f"{rv['full_name']} (coming soon)")
        cert_keys.append(rk)

current_full_name = cert_info.get("full_name", "SnowPro Core (COF-C03)")
current_idx = cert_options.index(current_full_name) if current_full_name in cert_options else 0

selected_cert = st.selectbox("Select certification", cert_options, index=current_idx, key="review_cert_select")
if "coming soon" not in selected_cert:
    sel_idx = cert_options.index(selected_cert)
    sel_key = cert_keys[sel_idx]
    if sel_key != active_cert:
        st.session_state._pending_cert = selected_cert
        st.session_state.app_mode = "certifications"
        st.rerun()

# Sidebar quiz shortcut (always visible)
st.sidebar.markdown("---")
_sidebar_domain = st.session_state.get("_review_domain_for_quiz", "")
_sidebar_qs = [q for q in st.session_state.get("questions", []) if q.get("domain") == _sidebar_domain]
if _sidebar_qs:
    _short = _sidebar_domain.split(": ")[1] if ": " in _sidebar_domain else _sidebar_domain
    st.sidebar.markdown(
        f'<div style="background:{T.BG_CARD};border-radius:8px;padding:10px 12px;text-align:center;">'
        f'<p style="color:{T.TEXT_PRIMARY};font-weight:600;margin:0 0 4px;font-size:0.9rem;">{_short}</p>'
        f'<p style="color:{T.TEXT_SECONDARY};margin:0;font-size:0.8rem;">{len(_sidebar_qs)} questions available</p>'
        f'</div>', unsafe_allow_html=True)
if st.sidebar.button(":material/quiz: Quiz this domain", key="review_sidebar_quiz",
                     use_container_width=True, type="primary"):
    if _sidebar_domain:
        st.session_state.quiz_domain_filter = _sidebar_domain
        st.session_state.quiz_source_filter = "All"
        st.switch_page("app_pages/quiz.py")

from app_pages.persistence import load_user_notes, save_user_notes

# ── State ──
DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_CSS_NUM = st.session_state.get("DOMAIN_CSS_NUM", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})
DOMAIN_WEIGHTS = st.session_state.get("DOMAIN_WEIGHTS", {})

CANDY = ["#E91E63", "#9C27B0", "#3F51B5", "#00BCD4", "#4CAF50", "#FF9800",
         "#F44336", "#673AB7", "#2196F3", "#009688", "#8BC34A", "#FF5722"]

notes = st.session_state.get("review_notes", {})
questions = st.session_state.get("questions", [])


# ── Persist notes/highlights ──
def load_user_data():
    return load_user_notes()

def save_user_data():
    existing = load_user_notes()
    review_highlights = st.session_state.get("user_highlights", [])
    quiz_highlights = [h for h in existing.get("highlights", []) if h.get("section", "").startswith("quiz_")]
    data = {"comments": st.session_state.get("user_comments", {}),
            "highlights": review_highlights + quiz_highlights}
    save_user_notes(data)

if "user_data_loaded" not in st.session_state:
    saved = load_user_data()
    st.session_state.user_comments = saved.get("comments", {})
    all_hl = saved.get("highlights", [])
    st.session_state.user_highlights = [h for h in all_hl if not h.get("section", "").startswith("quiz_")]
    st.session_state.user_data_loaded = True

st.session_state.setdefault("user_comments", {})


# ── Color constants ──
NOTE_COLORS = ["yellow", "pink", "blue", "green", "purple", "orange"]
NOTE_COLOR_LABELS = {
    "yellow": "Yellow", "pink": "Pink", "blue": "Blue",
    "green": "Green", "purple": "Purple", "orange": "Orange",
}

MARKER_COLORS = ["yellow", "pink", "blue", "green", "orange", "purple", "red", "cyan"]
MARKER_COLOR_LABELS = {
    "yellow": "Yellow", "pink": "Pink", "blue": "Blue", "green": "Green",
    "orange": "Orange", "purple": "Purple", "red": "Red", "cyan": "Cyan",
}


# ── Helper: Note editor ──
def _render_note_editor(widget_key, comment_key, existing, save_fn):
    current_text = existing.get("text", "") if existing else ""
    current_color = existing.get("color", "yellow") if existing else "yellow"
    color_idx = NOTE_COLORS.index(current_color) if current_color in NOTE_COLORS else 0
    col_color, col_save, col_cancel = st.columns([2, 1, 1])
    with col_color:
        chosen_color = st.selectbox(
            "Color", NOTE_COLORS, index=color_idx,
            format_func=lambda c: NOTE_COLOR_LABELS.get(c, c),
            key=f"color_{widget_key}", label_visibility="collapsed",
        )
    new_text = st.text_area(
        "Write your note (markdown: **bold**, *italic*, - bullets)",
        value=current_text, key=f"ta_{widget_key}", height=100,
    )
    if new_text.strip():
        st.markdown(
            f'<div class="sticky-note sticky-{chosen_color}" style="font-size:0.85rem;opacity:0.85;">'
            f'{new_text}</div>', unsafe_allow_html=True,
        )
    with col_save:
        if st.button("Save", key=f"save_{widget_key}", type="primary", use_container_width=True):
            if new_text.strip():
                st.session_state.user_comments[comment_key] = {"text": new_text.strip(), "color": chosen_color}
            else:
                st.session_state.user_comments.pop(comment_key, None)
            save_fn()
            st.session_state.pop(f"_editing_{comment_key}", None)
            st.rerun()
    with col_cancel:
        if st.button("Cancel", key=f"cancel_{widget_key}", use_container_width=True):
            st.session_state.pop(f"_editing_{comment_key}", None)
            st.rerun()


# ── Helper: Marker tool ──
def _render_marker_tool(widget_key, section_key, save_fn):
    highlights = st.session_state.get("user_highlights", [])
    section_highlights = [h for h in highlights if h.get("section") == section_key]
    if section_highlights:
        chips = []
        for hl in section_highlights:
            mc = hl.get("color", "yellow")
            chips.append(f'<span class="mark-{mc}" style="margin-right:6px;">{hl["text"]}</span>')
        st.markdown(
            f'<div style="background:#FAFAFA;border-radius:8px;padding:8px 12px;margin:4px 0;line-height:2;">'
            f'{"".join(chips)}</div>', unsafe_allow_html=True,
        )
        del_cols = st.columns(min(len(section_highlights), 6))
        for hi, hl in enumerate(section_highlights):
            with del_cols[hi % len(del_cols)]:
                label = f"x {hl['text'][:12]}..." if len(hl["text"]) > 12 else f"x {hl['text']}"
                if st.button(label, key=f"hdel_{widget_key}_{hi}", help=f"Remove: {hl['text']}"):
                    st.session_state.user_highlights = [
                        h for h in highlights
                        if not (h.get("section") == section_key and h["text"] == hl["text"])
                    ]
                    save_fn()
                    st.rerun()

    with st.expander("Marker", expanded=st.session_state.get(f"_marking_{section_key}", False)):
        color_col, text_col = st.columns([1, 3])
        with color_col:
            mark_color = st.radio(
                "Color", MARKER_COLORS,
                format_func=lambda c: c.title(),
                key=f"mcolor_{widget_key}", horizontal=True, label_visibility="collapsed",
            )
        with text_col:
            mark_text = st.text_input(
                "Text to highlight", key=f"mtext_{widget_key}",
                placeholder="Copy-paste text to highlight", label_visibility="collapsed",
            )
        if st.button("Mark", key=f"msave_{widget_key}", type="primary", use_container_width=True, disabled=not mark_text):
            if mark_text.strip():
                st.session_state.setdefault("user_highlights", []).append({
                    "section": section_key, "text": mark_text.strip(), "color": mark_color,
                })
                save_fn()
                st.rerun()


# ── Helper: Apply highlights (tag-gap regex with permissive fallback) ──
def _apply_highlights(html_text, section_key):
    from theme import T
    import html as html_module
    highlights = st.session_state.get("user_highlights", [])
    section_highlights = [h for h in highlights if h.get("section") == section_key]
    for hl in section_highlights:
        mc = hl.get("color", "yellow")
        bg = T.MARKS.get(mc, "#FFF176")
        wrap = (f'<span style="background:{bg};color:#1a1a2e;'
                f'padding:1px 4px;border-radius:2px;">\\1</span>')

        # Normalise user text: strip leading decoration characters
        # (bullets, checkmarks, arrows) that the browser copies but
        # are entities/tags in the HTML source.
        clean_text = hl["text"].lstrip(
            '\u2022\u2023\u2043\u25CB\u25CF'   # bullets
            '\u2713\u2714\u2705\u2611\u2612'   # checkmarks
            '\u25B6\u25B8\u25BA\u2192\u2190'   # arrows
            '\u274C\u2757\u26A0'               # warnings
            ' \t'
        )
        words = clean_text.split()
        if not words:
            continue

        # Strategy 1: strict tag-gap regex (tags + whitespace between words)
        tag_gap = r'(?:\s*(?:<[^>]*>\s*)*\s*)'
        pattern = tag_gap.join(re.escape(w) for w in words)
        new_html = re.sub(f'({pattern})', wrap, html_text,
                          count=1, flags=re.IGNORECASE)
        if new_html != html_text:
            html_text = new_html
            continue

        # Strategy 2: permissive -- allow tags, entities, AND whitespace
        # anywhere between words (handles </strong>: and &#x2022; etc.)
        permissive_gap = r'(?:(?:\s|<[^>]*>|&[#\w]+;)*)'
        pattern2 = permissive_gap.join(re.escape(w) for w in words)
        new_html = re.sub(f'({pattern2})', wrap, html_text,
                          count=1, flags=re.IGNORECASE)
        if new_html != html_text:
            html_text = new_html
            continue

        # Strategy 3: plain-text fallback -- decode entities, strip tags,
        # match in plain text, then wrap the corresponding HTML span.
        # Replace <br> with space first so cross-line matches work.
        stripped = re.sub(r'<br\s*/?\s*>', ' ', html_text)
        stripped = re.sub(r'<[^>]+>', '', stripped)
        stripped = html_module.unescape(stripped)
        # Use regex with flexible whitespace so we don't need to
        # collapse spaces in stripped (avoids walker desync).
        target_pat = r'\s+'.join(re.escape(w) for w in words)
        m3 = re.search(target_pat, stripped, re.IGNORECASE)
        if not m3:
            continue
        pos = m3.start()
        matched_len = m3.end() - m3.start()

        # Map plain-text [pos, pos+matched_len) back to HTML position.
        # Walk html_text char by char; <br> → 1 plain char (space),
        # other tags → skip, entities → decoded length, else → 1 char.
        html_start = html_end = None
        plain_i = 0
        i = 0
        while i < len(html_text):
            if plain_i == pos and html_start is None:
                html_start = i
            if plain_i == pos + matched_len:
                html_end = i
                break
            if html_text[i] == '<':
                br_m = re.match(r'<br\s*/?\s*>', html_text[i:], re.IGNORECASE)
                if br_m:
                    plain_i += 1          # <br> became a space
                    i += len(br_m.group(0))
                else:
                    end_tag = html_text.find('>', i)
                    i = end_tag + 1 if end_tag != -1 else i + 1
            elif html_text[i] == '&':
                end_ent = html_text.find(';', i)
                if end_ent != -1 and end_ent - i < 12:
                    decoded = html_module.unescape(html_text[i:end_ent + 1])
                    plain_i += len(decoded)   # entity → decoded chars
                    i = end_ent + 1
                else:
                    plain_i += 1
                    i += 1
            else:
                plain_i += 1
                i += 1
        if html_end is None and plain_i == pos + matched_len:
            html_end = i
        if html_start is not None and html_end is not None:
            snippet = html_text[html_start:html_end]
            highlighted = (f'<span style="background:{bg};color:#1a1a2e;'
                           f'padding:1px 4px;border-radius:2px;">'
                           f'{snippet}</span>')
            html_text = html_text[:html_start] + highlighted + html_text[html_end:]
    return html_text


# ── Helper: Extract exam traps from markdown ──
def extract_exam_traps(text):
    traps = []
    clean = []
    for line in text.split('\n'):
        m = re.match(r'^(?:- )?\*{0,2}Exam\s+trap:?\*{0,2}\s*(.+)$', line, re.IGNORECASE)
        if m:
            # Clean bold markers from the trap content
            trap_text = re.sub(r'\*{1,2}', '', m.group(1)).strip()
            traps.append(trap_text)
        else:
            clean.append(line)
    return '\n'.join(clean), traps


# ── Helper: Inline callout boxes (visual anchors) ──
def _apply_inline_callouts(html, fs):
    """Wrap key study patterns in colored callout boxes so they stand out."""
    from theme import T
    callouts = T.CALLOUTS

    # Each rule: (regex pattern, callout style key, label text)
    rules = [
        # "Remember:" -- key facts to lock in
        (r'((?:<[^>]*>)*)(\bRemember:\s*)(.+?)(?=<br>|</li>|</div>|</td>|$)',
         "remember", "Remember"),
        # "Don't confuse" -- prevent mix-ups
        (r"((?:<[^>]*>)*)(Don['\u2019]t confuse\b)(.+?)(?=<br>|</li>|</div>|</td>|$)",
         "dont_confuse", "Don't Mix Up"),
    ]

    for pattern, style_key, label in rules:
        style = callouts.get(style_key)
        if not style:
            continue

        def _wrap(m, s=style, lbl=label):
            prefix = m.group(1) or ""
            trigger = m.group(2)
            rest = m.group(3)
            return (
                f'{prefix}<div style="background:{s["bg"]};border-left:4px solid {s["border"]};'
                f'border-radius:4px;padding:6px 12px;margin:6px 0;color:#1a1a2e;font-size:{fs}px;">'
                f'<strong style="color:{s["label_color"]};">{lbl}:</strong> '
                f'{rest.lstrip(": ")}</div>'
            )
        html = re.sub(pattern, _wrap, html, flags=re.IGNORECASE)

    # Precedence patterns: "X > Y > Z" or "most specific wins" -- highlight hierarchy
    prec_style = callouts.get("precedence", {})
    if prec_style:
        prec_pattern = (
            r'((?:<[^>]*>)*)'
            r'((?:Precedence|Priority)\s*(?:Rule|Order)?:\s*)'
            r'(.+?)(?=<br>|</li>|</div>|</td>|$)'
        )

        def _wrap_prec(m):
            prefix = m.group(1) or ""
            trigger = m.group(2)
            rest = m.group(3)
            return (
                f'{prefix}<div style="background:{prec_style["bg"]};border-left:4px solid {prec_style["border"]};'
                f'border-radius:4px;padding:6px 12px;margin:6px 0;color:#1a1a2e;font-size:{fs}px;">'
                f'<strong style="color:{prec_style["label_color"]};">Precedence:</strong> '
                f'{rest.lstrip(": ")}</div>'
            )
        html = re.sub(prec_pattern, _wrap_prec, html, flags=re.IGNORECASE)

    return html


# ── Helper: md_to_html (exam traps extracted separately) ──
def md_to_html(text, section_color, fs):
    h = text
    # Code blocks (```...```) -- dark bg is fine for code
    def _code_block(m):
        code = m.group(1).strip().replace('<', '&lt;').replace('>', '&gt;')
        return (f'<pre style="background:#263238;color:#EEFFFF;padding:12px 16px;'
                f'border-radius:6px;overflow-x:auto;font-size:{fs-1}px;margin:8px 0;'
                f'line-height:1.5;white-space:pre;"><code>{code}</code></pre>')
    h = re.sub(r'```\w*\n(.*?)```', _code_block, h, flags=re.DOTALL)
    # Blockquotes
    h = re.sub(r'^> (.+)$',
               lambda m: (f'<blockquote style="border-left:4px solid #90CAF9;padding:8px 16px;'
                           f'margin:8px 0;background:#F5F8FF;color:#1a1a2e;'
                           f'font-style:italic;">{m.group(1)}</blockquote>'),
               h, flags=re.MULTILINE)
    h = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', h)
    h = re.sub(r'(?<!\*)\*([^*]+?)\*(?!\*)', r'<em>\1</em>', h)
    h = re.sub(r'`([^`]+)`',
               r'<code style="background:#E8EAF6;color:#283593;padding:1px 5px;border-radius:3px;">\1</code>', h)
    def color_h3(m):
        idx = int(hashlib.md5(m.group(1).encode()).hexdigest(), 16) % len(CANDY)
        c = CANDY[idx]
        return (f'<h4 style="color:{c};margin:16px 0 8px;font-size:{fs+2}px;'
                f'border-bottom:2px solid {c};padding-bottom:4px;">{m.group(1)}</h4>')
    h = re.sub(r'^### (.+)$', color_h3, h, flags=re.MULTILINE)
    def convert_table(m):
        rows = m.group(1).strip().split('\n')
        out = f'<table style="width:100%;border-collapse:collapse;margin:10px 0;font-size:{fs-1}px;">'
        for ri, row in enumerate(rows):
            cells = [c.strip() for c in row.strip('|').split('|')]
            if all(set(c.strip()) <= set('-: ') for c in cells):
                continue
            if ri == 0:
                out += '<tr>' + ''.join(
                    f'<th style="background:{section_color};color:white;padding:8px 10px;text-align:left;">{c}</th>'
                    for c in cells) + '</tr>'
            else:
                bg = '#F9F9F9' if ri % 2 == 0 else '#FFFFFF'
                out += '<tr>' + ''.join(
                    f'<td style="padding:6px 10px;border-bottom:1px solid #E0E0E0;color:#1a1a2e;background:{bg};">{c}</td>'
                    for c in cells) + '</tr>'
        return out + '</table>'
    h = re.compile(r'((?:^\|.+\|\s*\n)+)', re.MULTILINE).sub(convert_table, h)
    # Bullets
    def _bullet_replace(m):
        indent = len(m.group(1) or "")
        pad = f"padding-left:{indent * 10}px;" if indent else ""
        return (f'<li style="margin:3px 0;color:#1a1a2e;{pad}">'
                f'<span style="color:{section_color};font-weight:bold;">&#x2022;</span> '
                f'{m.group(2)}</li>')
    h = re.sub(r'^(\s*)[-*] (.+)$', _bullet_replace, h, flags=re.MULTILINE)
    h = re.sub(r'((?:<li[^>]*>.*?</li>\s*)+)',
               r'<ul style="margin:6px 0;padding-left:16px;list-style:none;">\1</ul>', h)
    h = re.sub(r'^\d+\. (.+)$', r'<li style="margin:3px 0;color:#1a1a2e;">\1</li>', h, flags=re.MULTILINE)
    h = re.sub(r'\u2192', f'<span style="color:{section_color};font-weight:bold;">\u2192</span>', h)
    # Replace newlines with <br> but protect <pre> blocks (code diagrams)
    parts = re.split(r'(<pre[^>]*>.*?</pre>)', h, flags=re.DOTALL)
    for i, part in enumerate(parts):
        if not part.startswith('<pre'):
            parts[i] = part.replace('\n\n', '<br><br>').replace('\n', '<br>')
    h = ''.join(parts)
    # ── Inline callout boxes (visual anchors for study) ──
    h = _apply_inline_callouts(h, fs)
    return h


# ── Helper: Get sample questions with fallback ──
def get_sample_questions(domain_name, section_title):
    title_words = set(section_title.lower().split())
    domain_qs = [q for q in questions if q.get("domain") == domain_name or q.get("domain") == "Untagged"]
    # Primary: keyword match
    matches = []
    for q in domain_qs:
        q_lower = q["question"].lower()
        score = sum(1 for w in title_words if len(w) > 3 and w in q_lower)
        if score >= 1:
            matches.append((score, q))
    matches.sort(key=lambda x: -x[0])
    result = [q for _, q in matches[:3]]
    # Fallback: deterministic random from domain if < 3 matches
    if len(result) < 3 and domain_qs:
        existing_ids = {id(q) for q in result}
        remaining = [q for q in domain_qs if id(q) not in existing_ids]
        if remaining:
            rng = random.Random(hash(section_title) % (2**31))
            result.extend(rng.sample(remaining, min(3 - len(result), len(remaining))))
    return result


# ── Helper: Search highlight ──
def highlight_search(text, term):
    if not term:
        return text
    return re.sub(f'({re.escape(term)})',
                  r'<mark style="background:#FFEB3B;padding:1px 3px;border-radius:3px;">\1</mark>',
                  text, flags=re.IGNORECASE)


# ── Helper: Per-section CoCo AI ──
def _render_coco_section(widget_key, section_title, body_preview):
    key_open = f"_coco_{widget_key}"
    if st.button(":material/smart_toy: Ask CoCo", key=f"coco_btn_{widget_key}",
                 type="secondary", use_container_width=True):
        st.session_state[key_open] = not st.session_state.get(key_open, False)
        st.rerun()

    if st.session_state.get(key_open):
        st.markdown(
            '<div style="background:#0D2137;border:1px solid #29B5E8;border-radius:8px;padding:10px;margin:6px 0;">'
            '<strong style="color:#29B5E8;">CoCo - AI Study Assistant</strong></div>',
            unsafe_allow_html=True,
        )
        ai_q = st.text_input(
            "Question", key=f"coco_input_{widget_key}", label_visibility="collapsed",
            placeholder=f"Ask about {section_title[:40]}...",
        )
        c_ask, c_close = st.columns([3, 1])
        with c_ask:
            ask = st.button("Ask", key=f"coco_ask_{widget_key}", type="primary", use_container_width=True)
        with c_close:
            if st.button("Close", key=f"coco_close_{widget_key}", use_container_width=True):
                st.session_state.pop(key_open, None)
                st.session_state.pop(f"coco_a_{widget_key}", None)
                st.rerun()

        if ask and ai_q.strip():
            if not _HAS_CORTEX:
                st.session_state[f"coco_a_{widget_key}"] = (
                    "CoCo AI requires Snowflake. Deploy the app to enable AI answers.")
            else:
                cert_name = st.session_state.get("CERT_REGISTRY", {}).get(
                    st.session_state.get("_active_cert", "core"), {}
                ).get("full_name", "Snowflake")
                lang_code = st.session_state.get("lang", "en")
                lang_name = {"en": "English", "pt": "Portuguese", "es": "Spanish"}.get(lang_code, "English")
                prompt = (
                    f"You are CoCo, a study assistant for the {cert_name} exam. "
                    f"Section: {section_title}. Context: {body_preview[:400]}. "
                    f"Answer concisely in {lang_name}. Use bullet points.\n\n"
                    f"Question: {ai_q}"
                )
                with st.spinner("CoCo is thinking..."):
                    try:
                        st.session_state[f"coco_a_{widget_key}"] = ai_complete(prompt)
                    except Exception as e:
                        st.session_state[f"coco_a_{widget_key}"] = f"Error: {e}"
                st.rerun()

        answer = st.session_state.get(f"coco_a_{widget_key}")
        if answer:
            st.markdown(
                f'<div style="background:#0D2137;border-left:3px solid #29B5E8;border-radius:8px;'
                f'padding:12px;margin:8px 0;">'
                f'<strong style="color:#29B5E8;">CoCo:</strong> '
                f'<span style="color:#F0F4F8;">{answer}</span></div>',
                unsafe_allow_html=True,
            )


# ── Helper: Render sticky note (view + edit/delete) ──
def _render_sticky_note(comment_key, widget_prefix, si_tag, save_fn):
    saved = st.session_state.user_comments.get(comment_key, {})
    if isinstance(saved, str) and saved:
        saved = {"text": saved, "color": "yellow"}
        st.session_state.user_comments[comment_key] = saved
        save_fn()

    if saved and saved.get("text"):
        nc = saved.get("color", "yellow")
        st.markdown(f'<div class="sticky-note sticky-{nc}">{saved["text"]}</div>', unsafe_allow_html=True)
        c1, c2 = st.columns(2)
        with c1:
            if st.button("Edit", key=f"ebtn_{widget_prefix}_{si_tag}", use_container_width=True):
                st.session_state[f"_editing_{comment_key}"] = True
                st.rerun()
        with c2:
            if st.button("Delete", key=f"dbtn_{widget_prefix}_{si_tag}", use_container_width=True):
                st.session_state.user_comments.pop(comment_key, None)
                save_fn()
                st.rerun()

    if st.session_state.get(f"_editing_{comment_key}") or (not saved or not saved.get("text")):
        add_key = f"add_{widget_prefix}_{si_tag}"
        if saved and saved.get("text"):
            _render_note_editor(add_key, comment_key, saved, save_fn)
        else:
            if st.button("+  Note", key=f"plus_{add_key}", type="secondary"):
                st.session_state[f"_editing_{comment_key}"] = True
                st.rerun()
            if st.session_state.get(f"_editing_{comment_key}"):
                _render_note_editor(add_key, comment_key, {}, save_fn)


# ── Helper: split & clean ──
def clean_title(t):
    t = re.sub(r'\s*\((?:VERY\s+)?HEAVILY TESTED\)', '', t, flags=re.IGNORECASE)
    t = re.sub(r'\s*\(HEAVILY TESTED\)', '', t, flags=re.IGNORECASE)
    t = re.sub(r'\s*\(NEW for COF-C03\)', ' (NEW)', t, flags=re.IGNORECASE)
    return t.strip()


def split_sections(md):
    parts = re.split(r"(?:^|\n)(## .+)", md)
    secs = []
    if parts[0].strip():
        secs.append(("Overview", parts[0].strip()))
    i = 1
    while i < len(parts):
        title = clean_title(parts[i].lstrip("# ").strip())
        body = parts[i + 1].strip() if i + 1 < len(parts) else ""
        secs.append((title, body))
        i += 2
    return secs


def split_subsections(body):
    """Split section body into (intro, [(subtitle, subbody), ...]).

    Detects both ``### Heading`` lines AND standalone ``**Bold Title**``
    lines (a line whose *only* content is bold text, at least 4 chars).
    """
    lines = body.split('\n')
    intro_lines = []
    subsections = []
    current_title = None
    current_body = []

    for line in lines:
        h3 = re.match(r'^### (.+)$', line)
        # Standalone bold: entire line is **text** (min 4 chars inside), no extra content
        # Skip Q&A lines (e.g. **Q: How do I...?**) — those belong in their parent section
        bold = None
        if not h3:
            bm = re.match(r'^\*\*([^*]{4,})\*\*\s*$', line)
            if bm and not bm.group(1).strip().startswith('Q:'):
                bold = bm

        if h3 or bold:
            title_text = (h3.group(1) if h3 else bold.group(1)).strip()
            # Flush previous
            if current_title is not None:
                subsections.append((current_title, '\n'.join(current_body).strip()))
            else:
                intro_lines = current_body[:]
            current_title = title_text
            current_body = []
        else:
            current_body.append(line)

    # Flush last
    if current_title is not None:
        subsections.append((current_title, '\n'.join(current_body).strip()))
    elif current_body:
        intro_lines = current_body

    return '\n'.join(intro_lines).strip(), subsections


# ══════════════════════════════════════════════════════════════
# ── MAIN PAGE ──
# ══════════════════════════════════════════════════════════════

st.markdown("""
<h1 style="margin-bottom:4px;">Review Notes</h1>
<p style="color:#9CA3AF; margin-top:0;">Collapsible sections with exam traps, AI assistant, and markers</p>
""", unsafe_allow_html=True)

# ── Sidebar controls ──
with st.sidebar:
    st.markdown("### Notes Settings")
    font_size = st.slider("Font size", 12, 24, 15, 1, key="note_font")
    lang_code = st.session_state.get("lang", "en")
    lang = {"en": "English", "pt": "Portugues", "es": "Espanol"}.get(lang_code, "English")
    st.caption("Comments saved to: `user_notes_data.json`")

LABELS = {
    "English": {"search": "Search in notes", "jump": "Jump to section", "no_match": "No sections match"},
    "Portugues": {"search": "Buscar nas notas", "jump": "Ir para secao", "no_match": "Nenhuma secao encontrada"},
    "Espanol": {"search": "Buscar en notas", "jump": "Ir a seccion", "no_match": "No se encontraron secciones"},
}
L = LABELS.get(lang, LABELS["English"])

# ── Domain selector ──
domains = list(notes.keys()) if notes else list(DOMAIN_COLORS.keys())
if not domains:
    st.warning("No review notes loaded. Select a certification from the dashboard.")
    st.stop()

preselected = st.session_state.pop("selected_domain", None)
if preselected and preselected in domains and "review_selected" not in st.session_state:
    st.session_state.review_selected = domains.index(preselected)

num_cols = max(1, min(len(domains), 6))
cols = st.columns(num_cols)
for i, d in enumerate(domains):
    em = DOMAIN_EMOJIS.get(d, "")
    short = d.split(": ")[1] if ": " in d else d
    with cols[i % num_cols]:
        active = st.session_state.get("review_selected", 0) == i
        if st.button(f"{em} {short}", key=f"rv_{i}", use_container_width=True,
                     type="primary" if active else "secondary"):
            st.session_state.review_selected = i
            st.rerun()

sel = min(st.session_state.get("review_selected", 0), len(domains) - 1)
domain = domains[sel]
color = DOMAIN_COLORS.get(domain, "#29B5E8")
css_num = DOMAIN_CSS_NUM.get(domain, "1")
emoji = DOMAIN_EMOJIS.get(domain, "")

# Store for sidebar quiz button
st.session_state._review_domain_for_quiz = domain

weight = DOMAIN_WEIGHTS.get(domain, "")
weight_html = f'<p class="domain-weight">{weight}</p>' if weight else ""
st.markdown(
    f'<div class="domain-card domain-{css_num}" style="margin-top:12px;">'
    f'<h3>{emoji} {domain}</h3>{weight_html}</div>',
    unsafe_allow_html=True,
)

content = notes.get(domain, "_No notes._")
sections = split_sections(content)

# ── Section nav + search ──
section_names = ["All sections"] + [t for t, _ in sections]
selected_section = st.selectbox(L['jump'], section_names, key="section_jump")
search = st.text_input(L['search'], key="ns", placeholder="e.g., micro-partition, masking...")

# ── Filter ──
filtered = sections
if selected_section != "All sections":
    filtered = [(t, b) for t, b in sections if t == selected_section]
if search:
    filtered = [(t, b) for t, b in filtered if search.lower() in t.lower() or search.lower() in b.lower()]
    if not filtered:
        st.warning(L['no_match'])


# ══════════════════════════════════════════════════════════════
# ── RENDER SECTIONS ──
# ══════════════════════════════════════════════════════════════

def _render_traps_html(traps, fs, hl_keys=None):
    """Render exam traps as a collapsible HTML card -- white bg, readable text.
    hl_keys: list of section keys to apply marker highlights against."""
    if not traps:
        return ""
    items = ""
    for trap in traps:
        trap_html = trap.replace('<', '&lt;').replace('>', '&gt;')
        # Apply marker highlights to trap text
        if hl_keys:
            for hk in hl_keys:
                trap_html = _apply_highlights(trap_html, hk)
        items += (
            f'<div style="color:#1a1a2e;margin:6px 0;padding:8px 12px;background:#FFFFFF;'
            f'border:1px solid #FFCDD2;border-left:3px solid #E53935;border-radius:4px;'
            f'box-shadow:0 1px 2px rgba(0,0,0,0.05);font-size:{fs}px;">'
            f'{trap_html}</div>'
        )
    lang_code = st.session_state.get("lang", "en")
    header = {"en": "Exam Traps", "pt": "Armadilhas do Exame",
              "es": "Trampas del Examen"}.get(lang_code, "Exam Traps")
    return (
        f'<details open style="margin:8px 0;">'
        f'<summary style="cursor:pointer;background:#FFEBEE;color:#C62828;'
        f'font-weight:bold;font-size:{fs}px;padding:8px 12px;'
        f'border-radius:6px;border-left:4px solid #E53935;">'
        f'{header} ({len(traps)})</summary>'
        f'<div style="background:#FFF5F5;border:1px solid #FFCDD2;'
        f'border-radius:0 0 6px 6px;padding:6px;">'
        f'{items}</div></details>'
    )


def _render_sample_qs_interactive(qs_list, fs, domain, section_idx, subsection_idx):
    """Render sample questions with clickable options and answer reveal."""
    if not qs_list:
        return
    _esc = lambda s: s.replace("<", "&lt;").replace(">", "&gt;")
    letters = "ABCDEFGH"
    lang_code = st.session_state.get("lang", "en")
    header = {"en": "Practice Questions", "pt": "Questoes Praticas",
              "es": "Preguntas de Practica"}.get(lang_code, "Practice Questions")
    check_lbl = {"en": "Check answer", "pt": "Verificar",
                 "es": "Verificar"}.get(lang_code, "Check answer")
    retry_lbl = {"en": "Try again", "pt": "Tentar de novo",
                 "es": "Intentar de nuevo"}.get(lang_code, "Try again")

    with st.expander(f"{header} ({len(qs_list)})", expanded=False):
        for qi, sq in enumerate(qs_list):
            q_text = _esc(sq["question"])
            correct_idx = set(sq.get("correct_indices", []))
            options = sq.get("options", [])
            explanation = sq.get("overall_explanation", "") or sq.get("explanation", "")
            multi = len(correct_idx) > 1
            multi_tag = (f' <span style="background:#E1BEE7;color:#6A1B9A;padding:1px 6px;'
                         f'border-radius:8px;font-size:{fs - 3}px;">Multi</span>') if multi else ""
            sel_hint = ""
            if multi:
                sel_hint = {"en": " (select all that apply)",
                            "pt": " (selecione todas corretas)",
                            "es": " (seleccione todas)"}.get(lang_code, "")

            uid = f"{domain}_{section_idx}_{subsection_idx}_{qi}"
            checked_key = f"pq_checked_{uid}"
            is_checked = st.session_state.get(checked_key, False)

            # Question card -- white bg, black text
            st.markdown(
                f'<div style="margin:6px 0 4px;padding:10px 14px;'
                f'background:#FFFFFF;border:1px solid #E0E0E0;'
                f'border-left:3px solid #29B5E8;border-radius:6px;">'
                f'<div style="color:#1a1a2e;font-size:{fs}px;font-weight:600;">'
                f'Q{qi + 1}.{multi_tag}{sel_hint} {q_text}</div></div>',
                unsafe_allow_html=True,
            )

            # Options -- clickable radio/checkboxes
            opt_texts = []
            for oi, opt in enumerate(options):
                letter = letters[oi] if oi < len(letters) else str(oi + 1)
                opt_text = opt["text"] if isinstance(opt, dict) else str(opt)
                opt_texts.append(f"{letter}. {opt_text}")

            if multi:
                # Multi-select: checkboxes
                selected = set()
                cols = st.columns(1)  # single column, stacked
                for oi, ot in enumerate(opt_texts):
                    cb_key = f"pq_opt_{uid}_{oi}"
                    if st.checkbox(ot, key=cb_key, disabled=is_checked):
                        selected.add(oi)
            else:
                # Single-select: radio
                radio_key = f"pq_radio_{uid}"
                choice = st.radio(
                    "Select your answer:",
                    opt_texts,
                    key=radio_key,
                    label_visibility="collapsed",
                    disabled=is_checked,
                )
                selected = set()
                if choice:
                    for oi, ot in enumerate(opt_texts):
                        if ot == choice:
                            selected.add(oi)

            # Check / Try again buttons
            if not is_checked:
                if st.button(check_lbl, key=f"pq_check_{uid}",
                             use_container_width=True, type="primary",
                             disabled=len(selected) == 0):
                    st.session_state[checked_key] = True
                    st.session_state[f"pq_sel_{uid}"] = selected
                    st.rerun()
            else:
                # Retrieve what user picked
                user_sel = st.session_state.get(f"pq_sel_{uid}", set())
                is_correct = user_sel == correct_idx

                # Show per-option feedback
                for oi, ot in enumerate(opt_texts):
                    in_user = oi in user_sel
                    in_correct = oi in correct_idx
                    if in_user and in_correct:
                        icon, bg, border = "Correct", "#E8F5E9", "#2E7D32"
                    elif in_user and not in_correct:
                        icon, bg, border = "Wrong", "#FFEBEE", "#E53935"
                    elif not in_user and in_correct:
                        icon, bg, border = "Missed", "#FFF3E0", "#FB8C00"
                    else:
                        continue
                    st.markdown(
                        f'<div style="background:{bg};border-left:3px solid {border};'
                        f'border-radius:4px;padding:4px 10px;margin:2px 0;'
                        f'font-size:{fs - 1}px;color:#1a1a2e;">'
                        f'<strong style="color:{border};">{icon}:</strong> {_esc(ot)}</div>',
                        unsafe_allow_html=True,
                    )

                # Overall result
                if is_correct:
                    st.markdown(
                        f'<div style="background:#E8F5E9;border:1px solid #2E7D32;'
                        f'border-radius:6px;padding:8px 12px;margin:6px 0;'
                        f'font-size:{fs}px;color:#2E7D32;font-weight:600;text-align:center;">'
                        f'Correct!</div>', unsafe_allow_html=True)
                else:
                    st.markdown(
                        f'<div style="background:#FFEBEE;border:1px solid #E53935;'
                        f'border-radius:6px;padding:8px 12px;margin:6px 0;'
                        f'font-size:{fs}px;color:#C62828;font-weight:600;text-align:center;">'
                        f'Not quite -- see the feedback above.</div>',
                        unsafe_allow_html=True)

                # Explanation
                if explanation:
                    st.markdown(
                        f'<div style="background:#FFFFFF;border:1px solid #E0E0E0;'
                        f'border-left:3px solid #F9A825;'
                        f'border-radius:4px;padding:8px 12px;margin:4px 0;'
                        f'font-size:{fs - 1}px;color:#1a1a2e;">'
                        f'<strong style="color:#F57F17;">Why:</strong> '
                        f'{_esc(explanation)}</div>',
                        unsafe_allow_html=True,
                    )

                # Try again
                if st.button(retry_lbl, key=f"pq_retry_{uid}", use_container_width=True):
                    st.session_state.pop(checked_key, None)
                    st.session_state.pop(f"pq_sel_{uid}", None)
                    # Clear individual checkbox states
                    for oi in range(len(options)):
                        st.session_state.pop(f"pq_opt_{uid}_{oi}", None)
                    st.session_state.pop(f"pq_radio_{uid}", None)
                    st.rerun()

            if qi < len(qs_list) - 1:
                st.markdown('<hr style="margin:10px 0;border:none;'
                            'border-top:1px solid #E0E0E0;">',
                            unsafe_allow_html=True)


# ── Helper: Quick Reference card (key rules from section body) ──
def _render_quick_reference(section_body, fs):
    """Extract key rules, traps, and memory aids from section text
    and render a collapsed quick-reference card at the top."""
    from theme import T
    items = []

    for line in section_body.split('\n'):
        stripped = line.strip().lstrip('- ')
        low = stripped.lower()

        # Exam traps
        m = re.match(r'^\*{0,2}Exam\s+trap:?\*{0,2}\s*(.+)$', stripped, re.IGNORECASE)
        if m:
            trap_text = re.sub(r'\*{1,2}', '', m.group(1)).strip()
            items.append(("trap", trap_text))
            continue

        # "Remember:" sentences
        m2 = re.search(r'Remember:\s*(.+)', stripped, re.IGNORECASE)
        if m2:
            items.append(("remember", m2.group(1).strip()))
            continue

        # "Don't confuse" sentences
        m3 = re.search(r"Don['\u2019]t confuse\b(.+)", stripped, re.IGNORECASE)
        if m3:
            items.append(("confuse", m3.group(1).strip()))
            continue

        # Precedence / Priority rules
        m4 = re.search(r'(?:Precedence|Priority)\s*(?:Rule|Order)?:\s*(.+)', stripped, re.IGNORECASE)
        if m4:
            items.append(("precedence", m4.group(1).strip()))
            continue

    if not items:
        return

    callouts = T.CALLOUTS
    style_map = {
        "trap": {"bg": "#FFEBEE", "border": "#C62828", "label": "Trap", "label_color": "#B71C1C"},
        "remember": {**callouts.get("remember", {}), "label": "Remember"},
        "confuse": {**callouts.get("dont_confuse", {}), "label": "Don't Mix Up"},
        "precedence": {**callouts.get("precedence", {}), "label": "Precedence"},
    }

    rows = ""
    seen = set()
    for kind, text in items:
        # Deduplicate
        key = text[:60].lower()
        if key in seen:
            continue
        seen.add(key)
        s = style_map.get(kind, {})
        clean_text = re.sub(r'\*{1,2}', '', text)
        clean_text = clean_text.replace('<', '&lt;').replace('>', '&gt;')
        rows += (
            f'<div style="margin:3px 0;padding:4px 10px;border-left:3px solid {s.get("border", "#999")};'
            f'background:{s.get("bg", "#F5F5F5")};border-radius:3px;font-size:{fs - 1}px;color:#1a1a2e;">'
            f'<strong style="color:{s.get("label_color", s.get("border", "#333"))};">'
            f'{s.get("label", "Note")}:</strong> {clean_text}</div>'
        )

    lang_code = st.session_state.get("lang", "en")
    header = {"en": "Key Rules - Quick Reference",
              "pt": "Regras Chave - Referencia Rapida",
              "es": "Reglas Clave - Referencia Rapida"}.get(lang_code, "Key Rules - Quick Reference")
    count = len(seen)

    st.markdown(
        f'<details style="margin:4px 0 10px 0;">'
        f'<summary style="cursor:pointer;padding:8px 14px;'
        f'background:linear-gradient(135deg, #E8EAF6, #C5CAE9);'
        f'border-left:4px solid #3F51B5;border-radius:6px;'
        f'font-size:{fs}px;color:#1A237E;font-weight:600;">'
        f'{header} ({count})</summary>'
        f'<div style="background:#FFFFFF;border:1px solid #C5CAE9;'
        f'border-radius:0 0 6px 6px;padding:8px 12px;">'
        f'{rows}</div></details>',
        unsafe_allow_html=True,
    )


# ── Semantic block styling (from theme.py) ──
def _get_semantic_style(subtitle):
    """Check if a subsection title matches a semantic block pattern.
    Returns the style dict or None for default styling."""
    title_lower = subtitle.lower().strip()
    for pattern in ["why this matters", "best practices", "real-world examples",
                    "common confusion", "confusing pairs", "scenario decision tree",
                    "example scenario questions", "scenario-based faq", "eli5",
                    "mnemonics", "top traps", "pattern shortcuts"]:
        if pattern in title_lower:
            return T.semantic(pattern)
    return None


for si, (title, body) in enumerate(filtered):
    candy_color = CANDY[si % len(CANDY)]
    display_title = highlight_search(title, search) if search else title

    # Split body into intro + sub-sections (handles ### and **Bold Title**)
    intro_raw, subsections_raw = split_subsections(body)

    # Extract exam traps from intro (keep sub-section traps per sub-section)
    clean_intro, intro_traps = extract_exam_traps(intro_raw)

    section_hl_key = f"{domain}::{title}"

    # ── Collapsible section ──
    with st.expander(f"{emoji} {display_title}", expanded=True):

        # ── Quick Reference card (key rules from full section) ──
        _render_quick_reference(body, font_size)

        # ── Intro content ──
        if clean_intro:
            intro_html = md_to_html(clean_intro, candy_color, font_size)
            intro_html = _apply_highlights(intro_html, section_hl_key)
            if search:
                intro_html = highlight_search(intro_html, search)
            st.markdown(
                f'<div style="background:#FFFFFF;border-radius:10px;padding:16px 20px;margin:4px 0 8px 0;'
                f'border-left:4px solid {candy_color};border:1px solid #E0E0E0;border-left:4px solid {candy_color};'
                f'box-shadow:0 1px 4px rgba(0,0,0,0.06);">'
                f'<div style="color:#1a1a2e;font-size:{font_size}px;line-height:1.6;">{intro_html}</div>'
                f'</div>', unsafe_allow_html=True,
            )

        # Intro-level traps (if any)
        if intro_traps:
            st.markdown(_render_traps_html(intro_traps, font_size, hl_keys=[section_hl_key]),
                        unsafe_allow_html=True)

        # ── Sub-sections: each is a self-contained study block ──
        for ssi, (subtitle, subbody_raw) in enumerate(subsections_raw):
            sub_candy = CANDY[(si * 3 + ssi + 2) % len(CANDY)]
            sub_hl_key = f"{domain}::{title}::{subtitle}"

            # Extract this sub-section's own traps
            clean_sub, sub_traps = extract_exam_traps(subbody_raw)

            sub_html = md_to_html(clean_sub, sub_candy, font_size)
            sub_html = _apply_highlights(sub_html, sub_hl_key)
            # Also apply section-level highlights so the bottom marker
            # works across ALL text in the section, not just the intro.
            sub_html = _apply_highlights(sub_html, section_hl_key)
            if search:
                sub_html = highlight_search(sub_html, search)
                subtitle_display = highlight_search(subtitle, search)
            else:
                subtitle_display = subtitle

            # ── Check for semantic block styling ──
            sem = _get_semantic_style(subtitle)

            if sem:
                # Semantic block: distinct colored collapsible card
                st.markdown(
                    f'<details open style="margin:8px 0;">'
                    f'<summary style="cursor:pointer;padding:10px 14px;background:{sem["summary_bg"]};'
                    f'border-left:4px solid {sem["border"]};border-radius:6px;margin:2px 0;">'
                    f'<strong style="color:{sem["summary_color"]};font-size:{font_size+1}px;">'
                    f'{sem["icon"]} {subtitle_display}</strong>'
                    f'</summary>'
                    f'<div style="background:#FFFFFF;border-radius:0 0 10px 10px;padding:14px 18px;'
                    f'border-left:4px solid {sem["border"]};border:1px solid #E0E0E0;'
                    f'border-left:4px solid {sem["border"]};margin:0 0 4px 0;'
                    f'box-shadow:0 1px 4px rgba(0,0,0,0.05);">'
                    f'<div style="color:#1a1a2e;font-size:{font_size}px;line-height:1.6;">{sub_html}</div>'
                    f'</div></details>',
                    unsafe_allow_html=True,
                )
            else:
                # Default sub-section styling (candy color)
                st.markdown(
                    f'<details open style="margin:6px 0;">'
                    f'<summary style="cursor:pointer;padding:8px 12px;background:#F5F5F5;'
                    f'border-left:4px solid {sub_candy};border-radius:6px;margin:2px 0;">'
                    f'<strong style="color:{sub_candy};font-size:{font_size+1}px;">{subtitle_display}</strong>'
                    f'</summary>'
                    f'<div style="background:#FFFFFF;border-radius:0 0 10px 10px;padding:14px 18px;'
                    f'border-left:4px solid {sub_candy};border:1px solid #E0E0E0;'
                    f'border-left:4px solid {sub_candy};margin:0 0 4px 0;'
                    f'box-shadow:0 1px 4px rgba(0,0,0,0.05);">'
                    f'<div style="color:#1a1a2e;font-size:{font_size}px;line-height:1.6;">{sub_html}</div>'
                    f'</div></details>',
                    unsafe_allow_html=True,
                )

            # ── This sub-section's exam traps ──
            if sub_traps:
                st.markdown(_render_traps_html(sub_traps, font_size,
                            hl_keys=[sub_hl_key, section_hl_key]),
                            unsafe_allow_html=True)

            # ── This sub-section's sample questions ──
            sub_qs = get_sample_questions(domain, subtitle)
            if sub_qs:
                _render_sample_qs_interactive(sub_qs, font_size, domain, si, ssi)

            # ── Sub-section note + marker ──
            sub_comment_key = f"{domain}::{title}::{subtitle}"
            _render_sticky_note(sub_comment_key, "sub", f"{si}_{ssi}", save_user_data)
            _render_marker_tool(f"mark_sub_{domain}_{si}_{ssi}", sub_hl_key, save_user_data)

        st.markdown("---")

        # ── Section-level note + marker ──
        _render_sticky_note(section_hl_key, "sec", str(si), save_user_data)
        _render_marker_tool(f"mark_sec_{domain}_{si}", section_hl_key, save_user_data)

        # ── Per-section CoCo AI assistant ──
        _render_coco_section(f"sec_{si}", title, body[:500])

# ── "Test what you learned" — quiz shortcut for this domain ──
domain_qs = [q for q in questions if q.get("domain") == domain]
if domain_qs:
    q_count = len(domain_qs)
    multi_count = sum(1 for q in domain_qs if q.get("multi_select"))
    st.markdown(
        f'<div style="background:linear-gradient(135deg, #0D4A6B, #0A3554);border-radius:12px;'
        f'padding:20px 24px;margin:16px 0;border:2px solid {color};text-align:center;">'
        f'<h3 style="color:#E0F7FA;margin:0 0 6px;">Test what you learned</h3>'
        f'<p style="color:#80DEEA;margin:0 0 4px;font-size:0.9rem;">'
        f'{q_count} questions available ({multi_count} multi-select)</p>'
        f'</div>', unsafe_allow_html=True,
    )
    if st.button(f"Start quiz -- {domain}", key="review_quiz_go", use_container_width=True, type="primary"):
        st.session_state.quiz_domain_filter = domain
        st.session_state.quiz_source_filter = "All"
        st.switch_page("app_pages/quiz.py")
