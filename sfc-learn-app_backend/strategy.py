"""Exam strategy page - organized into tabs: Flashcards, Editions, Partners, Exam Day."""
import streamlit as st
import random
import re
import os

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ── Sidebar: Home button ──
if st.sidebar.button("🏠 Home", key="strategy_home", use_container_width=True):
    st.session_state.app_mode = None
    st.switch_page("app_pages/landing.py")

DOMAIN_COLORS = st.session_state.get("DOMAIN_COLORS", {})
DOMAIN_CSS_NUM = st.session_state.get("DOMAIN_CSS_NUM", {})
DOMAIN_EMOJIS = st.session_state.get("DOMAIN_EMOJIS", {})
DOMAIN_WEIGHTS = st.session_state.get("DOMAIN_WEIGHTS", {})

cert_key = st.session_state.get("cert_select", "SnowPro Core (COF-C03)")
active_cert = st.session_state.get("_active_cert", "core")
registry = st.session_state.get("CERT_REGISTRY", {})


def _hex_to_rgb(hex_color):
    h = hex_color.lstrip("#")
    return f"{int(h[0:2],16)},{int(h[2:4],16)},{int(h[4:6],16)}"


st.markdown("""
<h1 style="margin-bottom:4px;">🎯 Exam Strategy</h1>
<p style="color:#9CA3AF; margin-top:0;">Everything you need — organized by topic. Click a tab.</p>
""", unsafe_allow_html=True)

# ── Exam overview stat cards ──
cols = st.columns(5)
cert_exam = registry.get(active_cert, {}).get("exam", {})
num_questions = cert_exam.get("questions", 100 if active_cert == "core" else 65)
exam_time = cert_exam.get("time", "115 min")
pass_score = cert_exam.get("pass_score", "750/1000")
time_minutes = int(re.search(r"\d+", exam_time).group()) if re.search(r"\d+", exam_time) else 115
per_q_sec = round(time_minutes * 60 / num_questions)
exam_stats = [
    (str(num_questions), "Questions", "#29B5E8"),
    (exam_time, "Time", "#FFD93D"),
    (f"~{per_q_sec} sec", "Per question", "#4ECB71"),
    (pass_score, "Pass score", "#FF6B6B"),
    ("Single + Multi", "Types", "#C084FC"),
]
for col, (val, label, color) in zip(cols, exam_stats):
    with col:
        st.markdown(f"""
        <div class="stat-card">
            <p class="stat-value" style="font-size:1.4rem; color:{color};">{val}</p>
            <p class="stat-label">{label}</p>
        </div>
        """, unsafe_allow_html=True)

st.markdown("<br>", unsafe_allow_html=True)

# ══════════════════════════════════════════
# ── TABS ──
# ══════════════════════════════════════════
tab_fc, tab_strat, tab_editions, tab_partners, tab_domains, tab_exam_day = st.tabs([
    "🃏 Flashcards", "📝 Strategies", "📋 Editions", "🤝 Partners", "📊 Domains", "⏱️ Exam Day"
])

# ── TAB 1: FLASHCARDS ──
with tab_fc:
    st.markdown("### 🃏 Interactive Flashcards")
    st.caption("Click to reveal answers. Use these to make handwritten flashcards.")

    def extract_flashcards_from_notes():
        notes = st.session_state.get("review_notes", {})
        all_cards = []
        for domain, content in notes.items():
            match = re.search(r"## FLASHCARDS.*?\n(.*?)(?=\n## |\Z)", content, re.DOTALL)
            if match:
                section = match.group(1)
                pairs = re.findall(
                    r"\*\*Q:\*\*\s*(.*?)\s*\n\s*\*\*A:\*\*\s*(.*?)(?=\n\s*\*\*Q:\*\*|\n\n|\Z)",
                    section, re.DOTALL
                )
                for q, a in pairs:
                    all_cards.append({"domain": domain, "q": q.strip(), "a": a.strip()})
        return all_cards

    flashcards = extract_flashcards_from_notes()

    if len(flashcards) < 10:
        if active_cert == "architect":
            flashcards = [
                {"domain": "Domain 1: Account & Security", "q": "What is Tri-Secret Secure?", "a": "Composite encryption: Snowflake-managed key + customer-managed key (via KMS). Both required to decrypt data."},
                {"domain": "Domain 2: Data Architecture", "q": "Data Vault vs Star Schema?", "a": "Data Vault: Hubs (keys), Links (relationships), Satellites (attributes). Star: Fact tables + dimension tables. DV is more agile for change."},
                {"domain": "Domain 3: Data Engineering", "q": "Snowpark vs connectors?", "a": "Snowpark: DataFrame API running natively in Snowflake (Python/Java/Scala). Connectors: external drivers (JDBC, ODBC, Python connector) for app integration."},
                {"domain": "Domain 4: Performance", "q": "When to use clustering vs search optimization?", "a": "Clustering: large tables with range/equality filters on known columns. Search Optimization: point lookups, substring, geo, variant queries."},
            ]
        else:
            flashcards = [
                {"domain": "Domain 1: Architecture", "q": "What are the 3 layers of Snowflake?", "a": "Cloud Services (brain), Compute (muscle), Storage (memory). All scale independently."},
                {"domain": "Domain 2: Account & Governance", "q": "What is the role hierarchy?", "a": "ACCOUNTADMIN > SECURITYADMIN > USERADMIN + SYSADMIN > PUBLIC."},
                {"domain": "Domain 3: Data Loading", "q": "COPY INTO vs Snowpipe?", "a": "COPY INTO = bulk batch (needs warehouse). Snowpipe = continuous micro-batch (serverless)."},
                {"domain": "Domain 4: Performance & Querying", "q": "Cache check order?", "a": "1) Result cache (free, 24h) → 2) Local disk (SSD) → 3) Remote disk (storage)."},
                {"domain": "Domain 5: Collaboration", "q": "Time Travel vs Fail-safe?", "a": "TT: user-accessible, 0-90 days. Fail-safe: Snowflake-only, 7 days after TT ends."},
            ]

    fc_domains = ["All"] + sorted(set(c["domain"] for c in flashcards))
    fc_filter = st.selectbox("Filter by domain", fc_domains, key="fc_domain_filter")
    filtered_cards = flashcards if fc_filter == "All" else [c for c in flashcards if c["domain"] == fc_filter]

    if st.button("🔀 Shuffle cards", key="shuffle_fc"):
        random.shuffle(filtered_cards)

    st.caption(f"Showing {len(filtered_cards)} flashcards")

    for ci, card in enumerate(filtered_cards):
        domain = card["domain"]
        color = DOMAIN_COLORS.get(domain, "#6B7280")
        emoji = DOMAIN_EMOJIS.get(domain, "📋")
        short = domain.split(": ")[1] if ": " in domain else domain

        col1, col2 = st.columns([4, 1])
        with col1:
            st.markdown(f"""
            <div style="background:rgba({_hex_to_rgb(color)},0.08); border-left:4px solid {color}; border-radius:8px; padding:14px 18px; margin:6px 0;">
                <span style="font-size:0.75rem; color:{color}; font-weight:600;">{emoji} {short}</span><br>
                <strong style="color:#FAFAFA;">{card['q']}</strong>
            </div>
            """, unsafe_allow_html=True)
        with col2:
            if st.button("👁️ Show", key=f"show_fc_{ci}", use_container_width=True):
                st.session_state[f"fc_revealed_{ci}"] = not st.session_state.get(f"fc_revealed_{ci}", False)

        if st.session_state.get(f"fc_revealed_{ci}", False):
            st.markdown(f"""
            <div style="background:rgba(78,203,113,0.1); border-left:4px solid #4ECB71; border-radius:8px; padding:12px 18px; margin:0 0 10px 0;">
                ✅ {card['a']}
            </div>
            """, unsafe_allow_html=True)

# ── TAB 2: STRATEGIES ──
with tab_strat:
    st.markdown("### 📝 During Exam Strategies")

    col1, col2, col3 = st.columns(3)
    with col1:
        st.markdown("""
        <div class="domain-card domain-1">
            <h3>📖 Reading Technique</h3>
            <p>1. Read the <strong>LAST sentence first</strong> (the actual question)<br>
            2. Then read the scenario context<br>
            3. Saves time — many scenarios are long but the question is simple</p>
        </div>
        """, unsafe_allow_html=True)
    with col2:
        st.markdown("""
        <div class="domain-card domain-2">
            <h3>🎯 Elimination Technique</h3>
            <p>1. Eliminate 2 obviously wrong answers first<br>
            2. Choose between remaining 2<br>
            3. If unsure — go with first instinct<br>
            4. <strong>NEVER leave blank</strong> (no penalty)</p>
        </div>
        """, unsafe_allow_html=True)
    with col3:
        if active_cert == "architect":
            energy_text = (
                "Q 1-20: fresh, go steady<br>"
                "Q 20-40: stay focused, keep pace<br>"
                "Q 40-55: fatigue zone, take a breath<br>"
                "Q 55-65: final push, review flagged"
            )
        else:
            energy_text = (
                "Q 1-30: fresh, go steady<br>"
                "Q 30-60: stay focused, keep pace<br>"
                "Q 60-80: fatigue zone, take a breath<br>"
                "Q 80-100: final push, review flagged"
            )
        st.markdown(f"""
        <div class="domain-card domain-3">
            <h3>⚡ Energy Management</h3>
            <p>{energy_text}</p>
        </div>
        """, unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)

    # ADHD tips
    st.markdown("### 🧠 ADHD-Specific Tips")
    tips = [
        ("🎧", "Noise", "Use noise-cancelling headphones or earplugs. Test center noise is real."),
        ("⏸️", "Zone out?", "If you zone out mid-question, re-read the LAST sentence only."),
        ("🚩", "Flag it", "If you spend >90 seconds, FLAG and move on. Come back later."),
        ("💧", "Body", "Bring water. Take a 10-second stretch at Q60. Your brain needs it."),
        ("✋", "First instinct", "When reviewing flagged Qs, change answer ONLY if you're certain."),
    ]
    for emoji, title, desc in tips:
        st.markdown(f"""
        <div class="mnemonic">
            {emoji} <strong>{title}:</strong> {desc}
        </div>
        """, unsafe_allow_html=True)

# ── TAB 3: EDITION FEATURES ──
with tab_editions:
    st.markdown("### 📋 Edition Features Cheatsheet")
    st.caption("Know which features require which edition — this is heavily tested.")

    edition_data = [
        ("Virtual warehouses, MFA, encryption", True, True, True, True),
        ("Time Travel (1 day)", True, True, True, True),
        ("Fail-safe (7 days)", True, True, True, True),
        ("Multi-cluster warehouses", False, True, True, True),
        ("Time Travel up to 90 days", False, True, True, True),
        ("Column-level security", False, True, True, True),
        ("Row access policies", False, True, True, True),
        ("Materialized views", False, True, True, True),
        ("Search optimization", False, True, True, True),
        ("Query acceleration", False, True, True, True),
        ("Dynamic data masking", False, True, True, True),
        ("Periodic rekeying", False, True, True, True),
        ("Tri-Secret Secure", False, False, True, True),
        ("Private connectivity (PrivateLink)", False, False, True, True),
        ("PHI / HIPAA support", False, False, True, True),
        ("PCI DSS compliance", False, False, True, True),
        ("Account failover/failback", False, False, True, True),
        ("Dedicated metadata store", False, False, False, True),
        ("Isolated compute pool", False, False, False, True),
    ]

    rows_html = ""
    for feature, std, ent, bc, vps in edition_data:
        def cell(val):
            return '<td style="color:#4ECB71;font-weight:600;text-align:center;">✅</td>' if val else '<td style="color:#4B5563;text-align:center;">—</td>'
        rows_html += f"<tr><td style='padding:8px 12px;'>{feature}</td>{cell(std)}{cell(ent)}{cell(bc)}{cell(vps)}</tr>"

    st.markdown(f"""
    <table style="width:100%; border-collapse:collapse; font-size:0.9rem;">
    <thead>
    <tr style="background:#1B2332;">
        <th style="text-align:left; padding:10px 12px; color:#29B5E8;">Feature</th>
        <th style="text-align:center; padding:10px; color:#9CA3AF;">Standard</th>
        <th style="text-align:center; padding:10px; color:#FFD93D;">Enterprise</th>
        <th style="text-align:center; padding:10px; color:#FF6B6B;">Business Critical</th>
        <th style="text-align:center; padding:10px; color:#C084FC;">VPS</th>
    </tr>
    </thead>
    <tbody>{rows_html}</tbody>
    </table>
    """, unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)
    st.markdown("""
    <div class="mnemonic">
        <strong>Memory trick:</strong> Standard = basics. Enterprise = everything cool (MV, masking, MCW, 90d TT).
        Business Critical = security (Tri-Secret, PrivateLink, HIPAA). VPS = isolation.
    </div>
    """, unsafe_allow_html=True)

# ── TAB 4: PARTNERS ──
with tab_partners:
    st.markdown("### 🤝 Partner Cheatsheet")
    st.caption("When the exam asks 'which partner does X?' — know these categories.")

    col1, col2 = st.columns(2)
    with col1:
        st.markdown("""
        <div class="domain-card domain-1">
            <h3>📦 Data Integration / ETL</h3>
            <p>Fivetran, Matillion, Informatica, Hevo Data<br>Etleap, Striim, Keboola, SnapLogic</p>
        </div>
        """, unsafe_allow_html=True)
        st.markdown("""
        <div class="domain-card domain-3">
            <h3>🔄 Data Transformation</h3>
            <p>dbt Labs, Coalesce, Matillion</p>
        </div>
        """, unsafe_allow_html=True)
        st.markdown("""
        <div class="domain-card domain-4">
            <h3>📊 BI / Visualization</h3>
            <p>Sigma, ThoughtSpot, Domo</p>
        </div>
        """, unsafe_allow_html=True)
        st.markdown("""
        <div class="domain-card domain-5">
            <h3>📚 Data Governance / Catalog</h3>
            <p>Alation (catalog), Collibra (catalog)</p>
        </div>
        """, unsafe_allow_html=True)

    with col2:
        st.markdown("""
        <div class="domain-card domain-2">
            <h3>🧪 Data Science / ML</h3>
            <p>Dataiku, Hex</p>
        </div>
        """, unsafe_allow_html=True)
        st.markdown("""
        <div class="domain-card" style="background:rgba(255,107,107,0.08); border-color:#FF6B6B;">
            <h3>🔒 Security</h3>
            <p>Protegrity (tokenization), ALTR (data access)<br>Hunters (security analytics)</p>
        </div>
        """, unsafe_allow_html=True)
        st.markdown("""
        <div class="domain-card" style="background:rgba(192,132,252,0.08); border-color:#C084FC;">
            <h3>⬅️ Reverse ETL</h3>
            <p>Census, Hightouch</p>
        </div>
        """, unsafe_allow_html=True)
        st.markdown("""
        <div class="domain-card" style="background:rgba(107,114,128,0.08); border-color:#6B7280;">
            <h3>🏗️ Data Modeling</h3>
            <p>SqlDBM</p>
        </div>
        """, unsafe_allow_html=True)

# ── TAB 5: DOMAIN WEIGHTS ──
with tab_domains:
    st.markdown("### 📊 Domain Weight Strategy")
    st.caption("Focus your study time proportionally to exam weight.")

    if active_cert == "architect":
        DOMAINS_ORDERED = [
            ("Domain 1: Account & Security", "Account strategy, RBAC, security principles, encryption, network security, authentication"),
            ("Domain 2: Data Architecture", "Data models (Data Vault, Star Schema), data sharing, development lifecycle, object hierarchy, data recovery"),
            ("Domain 3: Data Engineering", "Data loading/unloading, ecosystem tools (connectors, drivers, Snowpark), data transformation"),
            ("Domain 4: Performance", "Query profiling, warehouse configs, clustering, search optimization, caching, troubleshooting"),
            ("Domain 5: Sharing & Collaboration", "Cross-region sharing, replication, Marketplace, Auto-Fulfillment, Data Clean Rooms"),
        ]
    else:
        DOMAINS_ORDERED = [
            ("Domain 1: Architecture", "Three layers, micro-partitions, caching, editions, Snowpark"),
            ("Domain 2: Account & Governance", "RBAC, system roles, masking, encryption, network policies"),
            ("Domain 3: Data Loading", "Stages, COPY INTO, Snowpipe, file formats, tasks & streams"),
            ("Domain 4: Performance & Querying", "Warehouses, caching, clustering, query profile, SQL functions"),
            ("Domain 5: Collaboration", "Shares, replication, Time Travel, Fail-safe, cloning"),
        ]

    for domain, topics in DOMAINS_ORDERED:
        css_num = DOMAIN_CSS_NUM.get(domain, "unknown")
        emoji = DOMAIN_EMOJIS.get(domain, "")
        weight = DOMAIN_WEIGHTS.get(domain, "")
        color = DOMAIN_COLORS.get(domain, "#6B7280")
        short = domain.split(": ")[1] if ": " in domain else domain

        st.markdown(f"""
        <div class="domain-card domain-{css_num}">
            <h3>{emoji} {short} — <span style="color:{color};">{weight}</span></h3>
            <p>{topics}</p>
        </div>
        """, unsafe_allow_html=True)

# ── TAB 6: EXAM DAY TIMELINE ──
with tab_exam_day:
    st.markdown("### ⏱️ ADHD-Friendly Exam Day Timeline")

    if active_cert == "architect":
        steps = [
            ("1", "#29B5E8", "Check in", "Deep breath. You are prepared."),
            ("2", "#4ECB71", "Minutes 0-35", "Questions 1-20. Steady pace. Flag anything you're unsure about."),
            ("3", "#FFD93D", "Minutes 35-70", "Questions 20-40. Stay focused. If you zone out, re-read the last sentence."),
            ("4", "#FF6B6B", "Minutes 70-95", "Questions 40-55. Fatigue zone — take a 10-second stretch/breath."),
            ("5", "#C084FC", "Minutes 95-105", "Questions 55-65. Final push. Don't second-guess."),
            ("6", "#FFD93D", "Minutes 105-115", "Review flagged questions. Trust your first instinct unless certain."),
            ("✓", "#4ECB71", "Submit", "You did it. Every attempt makes you stronger."),
        ]
    else:
        steps = [
            ("1", "#29B5E8", "Check in", "Deep breath. You are prepared."),
            ("2", "#4ECB71", "Minutes 0-35", "Questions 1-30. Steady pace. Flag anything you're unsure about."),
            ("3", "#FFD93D", "Minutes 35-70", "Questions 30-60. Stay focused. If you zone out, re-read the last sentence."),
            ("4", "#FF6B6B", "Minutes 70-95", "Questions 60-80. Fatigue zone — take a 10-second stretch/breath."),
            ("5", "#C084FC", "Minutes 95-105", "Questions 80-100. Final push. Don't second-guess."),
            ("6", "#FFD93D", "Minutes 105-115", "Review flagged questions. Trust your first instinct unless certain."),
            ("✓", "#4ECB71", "Submit", "You did it. Every attempt makes you stronger."),
        ]

    for num, color, phase, desc in steps:
        st.markdown(f"""
        <div class="timeline-step">
            <div class="timeline-dot" style="background:{color};">{num}</div>
            <div class="timeline-content">
                <strong>{phase}</strong>
                <p>{desc}</p>
            </div>
        </div>
        """, unsafe_allow_html=True)

    st.markdown("<br>", unsafe_allow_html=True)

    # Full strategy doc
    strategy_path = os.path.join(BASE, "exam_strategy_partners.md")
    if os.path.exists(strategy_path):
        with st.expander("📄 Full strategy document"):
            with open(strategy_path, "r") as f:
                st.markdown(f.read())
