"""Review notes — candy colors, font size, sub-topic comments saved to disk, sample questions popup, translation."""
import streamlit as st
import re, json, os, hashlib

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ── Sidebar: Home button ──
if st.sidebar.button("🏠 Home", key="review_home", use_container_width=True):
    st.session_state.app_mode = None
    st.switch_page("app_pages/landing.py")

from app_pages.persistence import load_user_notes, save_user_notes

DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_CSS_NUM = st.session_state.get("DOMAIN_CSS_NUM", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})

CANDY = ["#E91E63", "#9C27B0", "#3F51B5", "#00BCD4", "#4CAF50", "#FF9800",
         "#F44336", "#673AB7", "#2196F3", "#009688", "#8BC34A", "#FF5722"]

notes = st.session_state.get("review_notes", {})
questions = st.session_state.get("questions", [])


# ── Persist notes/highlights ──
def load_user_data():
    return load_user_notes()

def save_user_data():
    data = {"comments": st.session_state.get("user_comments", {}),
            "highlights": st.session_state.get("user_highlights", [])}
    save_user_notes(data)

if "user_data_loaded" not in st.session_state:
    saved = load_user_data()
    st.session_state.user_comments = saved.get("comments", {})
    st.session_state.user_highlights = saved.get("highlights", [])
    st.session_state.user_data_loaded = True

st.session_state.setdefault("user_comments", {})


# ── Header ──
st.markdown("""
<h1 style="margin-bottom:4px;">📖 Review Notes</h1>
<p style="color:#9CA3AF; margin-top:0;">Candy-colored sections — add comments per topic, resize text, see sample questions</p>
""", unsafe_allow_html=True)

# ── Sidebar controls ──
with st.sidebar:
    st.markdown("### 📖 Notes Settings")
    font_size = st.slider("Font size", 12, 24, 15, 1, key="note_font")
    lang_code = st.session_state.get("lang", "en")
    lang = {"en": "English", "pt": "Portugues", "es": "Espanol"}.get(lang_code, "English")
    st.caption(f"Comments saved to: `user_notes_data.json`")

# Translation hints (simple labels, not full translation — Streamlit can't translate markdown content)
LABELS = {
    "English": {"add_note": "Add a note...", "sample_qs": "Sample questions", "search": "Search in notes", "jump": "Jump to section", "no_match": "No sections match"},
    "Portugues": {"add_note": "Adicionar nota...", "sample_qs": "Questoes exemplo", "search": "Buscar nas notas", "jump": "Ir para secao", "no_match": "Nenhuma secao encontrada"},
    "Espanol": {"add_note": "Agregar nota...", "sample_qs": "Preguntas ejemplo", "search": "Buscar en notas", "jump": "Ir a seccion", "no_match": "No se encontraron secciones"},
}
L = LABELS.get(lang, LABELS["English"])

# ── Domain selector ──
domains = list(notes.keys()) if notes else list(DOMAIN_COLORS.keys())
preselected = st.session_state.pop("selected_domain", None)
if preselected and preselected in domains and "review_selected" not in st.session_state:
    st.session_state.review_selected = domains.index(preselected)

num_cols = min(len(domains), 6)
cols = st.columns(num_cols)
for i, d in enumerate(domains):
    em = DOMAIN_EMOJIS.get(d, "")
    short = d.split(": ")[1] if ": " in d else d
    col_idx = i % num_cols
    with cols[col_idx]:
        active = st.session_state.get("review_selected", 0) == i
        if st.button(f"{em} {short}", key=f"rv_{i}", use_container_width=True, type="primary" if active else "secondary"):
            st.session_state.review_selected = i
            st.rerun()

sel = min(st.session_state.get("review_selected", 0), len(domains) - 1)
domain = domains[sel]
color = DOMAIN_COLORS.get(domain, "#29B5E8")
css_num = DOMAIN_CSS_NUM.get(domain, "1")
emoji = DOMAIN_EMOJIS.get(domain, "")

st.markdown(f'<div class="domain-card domain-{css_num}" style="margin-top:12px;"><h3>{emoji} {domain}</h3></div>', unsafe_allow_html=True)

content = notes.get(domain, "_No notes._")


def clean_title(t):
    """Remove HEAVILY TESTED, VERY HEAVILY TESTED etc from titles."""
    t = re.sub(r'\s*\((?:VERY\s+)?HEAVILY TESTED\)', '', t, flags=re.IGNORECASE)
    t = re.sub(r'\s*\((?:HEAVILY TESTED)\)', '', t, flags=re.IGNORECASE)
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


def get_sample_questions(domain_name, section_title):
    """Find 3 questions from the bank that match this section's keywords."""
    keywords = set(re.findall(r'\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b', section_title))
    title_words = set(section_title.lower().split())
    matches = []
    for q in questions:
        if q["domain"] != domain_name and q["domain"] != "Untagged":
            continue
        q_lower = q["question"].lower()
        score = sum(1 for w in title_words if len(w) > 3 and w in q_lower)
        if score >= 1:
            matches.append((score, q))
    matches.sort(key=lambda x: -x[0])
    return [q for _, q in matches[:3]]


def md_to_html(text, section_color, fs):
    h = text
    h = re.sub(r'^(Exam trap:.+)$',
               r'<div style="background:#FFF0F0;border-left:4px solid #F44336;padding:8px 12px;margin:6px 0;border-radius:4px;color:#B71C1C;font-weight:500;font-size:{fs}px;">\1</div>'.replace("{fs}", str(fs)),
               h, flags=re.MULTILINE)
    h = re.sub(r'\*\*(.+?)\*\*', r'<strong style="color:#1a1a2e;">\1</strong>', h)
    h = re.sub(r'(?<!\*)\*([^*]+?)\*(?!\*)', r'<em>\1</em>', h)
    h = re.sub(r'`([^`]+)`', r'<code style="background:#E8EAF6;color:#283593;padding:1px 5px;border-radius:3px;">\1</code>', h)
    def color_h3(m):
        idx = int(hashlib.md5(m.group(1).encode()).hexdigest(), 16) % len(CANDY)
        c = CANDY[idx]
        return f'<h4 style="color:{c};margin:16px 0 8px;font-size:{fs+2}px;border-bottom:2px solid {c};padding-bottom:4px;">{m.group(1)}</h4>'
    h = re.sub(r'^### (.+)$', color_h3, h, flags=re.MULTILINE)
    def convert_table(m):
        rows = m.group(1).strip().split('\n')
        out = f'<table style="width:100%;border-collapse:collapse;margin:10px 0;font-size:{fs-1}px;">'
        for ri, row in enumerate(rows):
            cells = [c.strip() for c in row.strip('|').split('|')]
            if all(set(c.strip()) <= set('-: ') for c in cells): continue
            if ri == 0:
                out += '<tr>' + ''.join(f'<th style="background:{section_color};color:white;padding:8px 10px;text-align:left;">{c}</th>' for c in cells) + '</tr>'
            else:
                bg = '#F5F5F5' if ri % 2 == 0 else '#FFFFFF'
                out += '<tr>' + ''.join(f'<td style="padding:6px 10px;border-bottom:1px solid #E0E0E0;color:#333;background:{bg};">{c}</td>' for c in cells) + '</tr>'
        return out + '</table>'
    h = re.compile(r'((?:^\|.+\|\s*\n)+)', re.MULTILINE).sub(convert_table, h)
    h = re.sub(r'^- (.+)$', lambda m: f'<li style="margin:3px 0;color:#333;"><span style="color:{section_color};font-weight:bold;">•</span> {m.group(1)}</li>', h, flags=re.MULTILINE)
    h = re.sub(r'((?:<li[^>]*>.*?</li>\s*)+)', r'<ul style="margin:6px 0;padding-left:16px;list-style:none;">\1</ul>', h)
    h = re.sub(r'^\d+\. (.+)$', r'<li style="margin:3px 0;color:#333;">\1</li>', h, flags=re.MULTILINE)
    h = re.sub(r'→', f'<span style="color:{section_color};font-weight:bold;">→</span>', h)
    h = h.replace('\n\n', '<br><br>').replace('\n', '<br>')
    return h


def highlight_search(text, term):
    if not term: return text
    return re.sub(f'({re.escape(term)})', r'<mark style="background:#FFEB3B;padding:1px 3px;border-radius:3px;">\1</mark>', text, flags=re.IGNORECASE)


sections = split_sections(content)

# ── Section nav — selectbox to jump to a section ──
section_names = ["All sections"] + [t for t, _ in sections]
selected_section = st.selectbox(f"📑 {L['jump']}", section_names, key="section_jump")

search = st.text_input(f"🔍 {L['search']}", key="ns", placeholder="e.g., micro-partition, masking...")
st.markdown("---")

# ── Filter sections ──
filtered = sections
if selected_section != "All sections":
    filtered = [(t, b) for t, b in sections if t == selected_section]
if search:
    filtered = [(t, b) for t, b in filtered if search.lower() in t.lower() or search.lower() in b.lower()]
    if not filtered:
        st.warning(L['no_match'])

for si, (title, body) in enumerate(filtered):
    candy_color = CANDY[si % len(CANDY)]
    display_title = highlight_search(title, search) if search else title

    # Split body into sub-sections by ### headings
    sub_parts = re.split(r'(?:^|\n)(### .+)', body)

    # Intro text (before first ###)
    intro = sub_parts[0].strip() if sub_parts[0].strip() else ""

    # Sub-sections as (subtitle, subbody) pairs
    subsections = []
    i = 1
    while i < len(sub_parts):
        subtitle = sub_parts[i].lstrip("# ").strip()
        subbody = sub_parts[i + 1].strip() if i + 1 < len(sub_parts) else ""
        subsections.append((subtitle, subbody))
        i += 2

    # ── Outer container (topic border) ──
    st.markdown(
        f'<div style="background:rgba({",".join(str(int(candy_color.lstrip("#")[j:j+2],16)) for j in (0,2,4))},0.06);'
        f'border:2px solid {candy_color};border-radius:16px;padding:6px 8px;margin:16px 0;">'
        f'<h3 style="color:{candy_color};margin:8px 12px;font-size:{font_size+5}px;">{display_title}</h3>'
        f'</div>',
        unsafe_allow_html=True,
    )

    # ── Intro content (if any, before first ###) ──
    if intro:
        intro_html = md_to_html(intro, candy_color, font_size)
        if search:
            intro_html = highlight_search(intro_html, search)
        st.markdown(
            f'<div style="background:#FFFFFF;border-radius:10px;padding:16px 20px;margin:4px 12px 8px 12px;'
            f'border-left:4px solid {candy_color};box-shadow:0 1px 4px rgba(0,0,0,0.06);">'
            f'<div style="color:#333;font-size:{font_size}px;line-height:1.6;">{intro_html}</div>'
            f'</div>',
            unsafe_allow_html=True,
        )

    # ── Sub-section cards (inner blocks) ──
    for ssi, (subtitle, subbody) in enumerate(subsections):
        sub_candy = CANDY[(si * 3 + ssi + 2) % len(CANDY)]
        sub_html = md_to_html(subbody, sub_candy, font_size)
        if search:
            sub_html = highlight_search(sub_html, search)
            subtitle = highlight_search(subtitle, search)

        st.markdown(
            f'<div style="background:#FFFFFF;border-radius:10px;padding:14px 18px;margin:4px 12px 6px 24px;'
            f'border-left:4px solid {sub_candy};box-shadow:0 1px 4px rgba(0,0,0,0.05);">'
            f'<h4 style="color:{sub_candy};margin:0 0 8px;font-size:{font_size+1}px;">{subtitle}</h4>'
            f'<div style="color:#333;font-size:{font_size}px;line-height:1.6;">{sub_html}</div>'
            f'</div>',
            unsafe_allow_html=True,
        )

        # Comment per sub-topic
        sub_comment_key = f"{domain}::{title}::{subtitle}"
        saved_sub = st.session_state.user_comments.get(sub_comment_key, "")
        if saved_sub:
            st.markdown(f'<div class="sticky-note" style="margin-left:24px;">{saved_sub}</div>', unsafe_allow_html=True)
        new_sub = st.text_input(f"📝 {subtitle}", value=saved_sub, key=f"scm_{domain}_{si}_{ssi}", placeholder=L["add_note"])
        if new_sub != saved_sub:
            st.session_state.user_comments[sub_comment_key] = new_sub
            save_user_data()
            st.rerun()

    # ── Sample questions popup ──
    sample_qs = get_sample_questions(domain, title)
    if sample_qs:
        with st.expander(f"🧠 {L['sample_qs']} ({len(sample_qs)})"):
            for sq in sample_qs:
                correct = [sq["options"][i]["text"] for i in sq["correct_indices"] if i < len(sq["options"])]
                st.markdown(f"**Q:** {sq['question'][:200]}")
                st.markdown(f"**A:** {' | '.join(correct)}")
                st.markdown("---")

    # ── Section-level comment ──
    comment_key = f"{domain}::{title}"
    saved_comment = st.session_state.user_comments.get(comment_key, "")
    if saved_comment:
        st.markdown(f'<div class="sticky-note">{saved_comment}</div>', unsafe_allow_html=True)
    new_comment = st.text_input(f"📝 {title}", value=saved_comment, key=f"cm_{domain}_{si}", placeholder=L["add_note"])
    if new_comment != saved_comment:
        st.session_state.user_comments[comment_key] = new_comment
        save_user_data()
        st.rerun()

# ── Floating AI Assistant ──
st.markdown("""
<style>
.ai-float-btn {
    position: fixed; bottom: 24px; right: 24px; z-index: 9999;
    background: linear-gradient(135deg, #29B5E8, #1565C0);
    color: white; border: none; border-radius: 50%; width: 56px; height: 56px;
    font-size: 1.5rem; cursor: pointer; box-shadow: 0 4px 12px rgba(41,181,232,0.4);
    display: flex; align-items: center; justify-content: center;
    transition: transform 0.2s, box-shadow 0.2s;
}
.ai-float-btn:hover {
    transform: scale(1.1);
    box-shadow: 0 6px 20px rgba(41,181,232,0.6);
}
</style>
""", unsafe_allow_html=True)

st.session_state.setdefault("ai_chat_open", False)

if st.button("🤖 AI Assistant", key="ai_float_toggle", type="secondary"):
    st.session_state.ai_chat_open = not st.session_state.ai_chat_open
    st.rerun()

if st.session_state.ai_chat_open:
    st.markdown("---")
    st.markdown(
        '<div style="background:#0D2137; border:1px solid #29B5E8; border-radius:12px; padding:16px; margin-top:8px;">'
        '<h4 style="color:#29B5E8; margin:0 0 8px;">🤖 AI Study Assistant</h4>'
        '</div>',
        unsafe_allow_html=True,
    )
    ai_question = st.text_input(
        "Ask a question about Snowflake...",
        key="ai_chat_input",
        placeholder="e.g., What is a micro-partition?",
    )
    if st.button("Ask", key="ai_chat_send", type="primary"):
        if ai_question.strip():
            st.info("AI assistant coming soon — connect your Snowflake account to enable Cortex AI.")
        else:
            st.warning("Please type a question first.")
