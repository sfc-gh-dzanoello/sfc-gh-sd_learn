"""Landing page — Choose between Certifications or Learn paths (post-login hub)."""
import streamlit as st
import os
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE not in sys.path:
    sys.path.insert(0, BASE)

from i18n import t, get_text

# ── Snowflake SVG logo ──
SF_LOGO = '<svg width="48" height="48" viewBox="0 0 48 48" fill="none"><g transform="translate(24,24)"><g fill="#29B5E8"><rect x="-2" y="-21" width="4" height="21" rx="2"/><rect x="-2" y="0" width="4" height="21" rx="2"/><rect x="-2" y="-21" width="4" height="21" rx="2" transform="rotate(60)"/><rect x="-2" y="0" width="4" height="21" rx="2" transform="rotate(60)"/><rect x="-2" y="-21" width="4" height="21" rx="2" transform="rotate(-60)"/><rect x="-2" y="0" width="4" height="21" rx="2" transform="rotate(-60)"/></g><g fill="#29B5E8"><circle cx="0" cy="-21" r="3.2"/><circle cx="0" cy="21" r="3.2"/><circle cx="18.2" cy="-10.5" r="3.2"/><circle cx="-18.2" cy="10.5" r="3.2"/><circle cx="-18.2" cy="-10.5" r="3.2"/><circle cx="18.2" cy="10.5" r="3.2"/></g><circle cx="0" cy="0" r="4" fill="#29B5E8"/><g fill="#29B5E8" opacity="0.6"><circle cx="7" cy="-14" r="2"/><circle cx="-7" cy="-14" r="2"/><circle cx="7" cy="14" r="2"/><circle cx="-7" cy="14" r="2"/><circle cx="14" cy="-3" r="2"/><circle cx="14" cy="3" r="2"/><circle cx="-14" cy="-3" r="2"/><circle cx="-14" cy="3" r="2"/><circle cx="7" cy="11" r="2"/><circle cx="-7" cy="11" r="2"/><circle cx="7" cy="-11" r="2"/><circle cx="-7" cy="-11" r="2"/></g></g></svg>'

# ── Header ──
st.markdown(f"""
<div style="text-align:center; padding:20px 0 6px;">
    <div style="display:inline-block; margin-bottom:6px;">{SF_LOGO}</div>
    <h1 style="font-size:2rem; margin:0; color:#E0F7FA;">{t('app_title')}</h1>
    <p style="color:#80DEEA; font-size:0.95rem; margin:4px 0 0;">{t('app_subtitle')}</p>
</div>
""", unsafe_allow_html=True)

st.markdown("")

# ── Two main paths ──
_reg = st.session_state.get("CERT_REGISTRY", {})
_available = [v for v in _reg.values() if v.get("available")]
_coming = len(_reg) - len(_available)
_cert_badges = "".join(
    f'<span style="background:{c.get("color","#29B5E8")}; color:#0B1929; padding:3px 10px; border-radius:14px; font-size:0.75rem; font-weight:600;">{c.get("name","")}</span>'
    for c in _available
)
if _coming > 0:
    _cert_badges += f'<span style="background:rgba(255,255,255,0.08); color:#80DEEA; padding:3px 10px; border-radius:14px; font-size:0.75rem;">+{_coming} {t("coming_soon")}</span>'

col1, col2 = st.columns(2, gap="large")

with col1:
    st.markdown(f"""
    <div style="background:linear-gradient(135deg, #0D4A6B, #0A3554); border-radius:14px;
                padding:28px 24px; text-align:center; border:2px solid #29B5E8; min-height:260px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2.8rem; margin:0;">🎓</p>
        <h2 style="color:#E0F7FA; margin:8px 0 6px; font-size:1.4rem;">{t('certifications')}</h2>
        <p style="color:#80DEEA; font-size:0.88rem; margin:0 0 12px;">{t('certifications_desc')}</p>
        <div style="display:flex; gap:6px; justify-content:center; flex-wrap:wrap;">
            {_cert_badges}
        </div>
    </div>
    """, unsafe_allow_html=True)
    if st.button(f"🎓  {t('enter_certifications')}", key="go_cert", use_container_width=True, type="primary"):
        st.session_state.app_mode = "certifications"
        st.switch_page("app_pages/dashboard.py")

with col2:
    st.markdown(f"""
    <div style="background:linear-gradient(135deg, #3D1560, #2A1070); border-radius:14px;
                padding:28px 24px; text-align:center; border:2px solid #AB47BC; min-height:260px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2.8rem; margin:0;">🧪</p>
        <h2 style="color:#F3E5F5; margin:8px 0 6px; font-size:1.4rem;">{t('learn')}</h2>
        <p style="color:#CE93D8; font-size:0.88rem; margin:0 0 12px;">{t('learn_desc')}</p>
        <div style="display:flex; gap:6px; justify-content:center; flex-wrap:wrap;">
            <span style="background:#FF9800; color:#0B1929; padding:3px 10px; border-radius:14px; font-size:0.75rem; font-weight:600;">Data Engineer</span>
            <span style="background:#1E88E5; color:#FFF; padding:3px 10px; border-radius:14px; font-size:0.75rem; font-weight:600;">Architect</span>
            <span style="background:#AB47BC; color:#FFF; padding:3px 10px; border-radius:14px; font-size:0.75rem; font-weight:600;">Analyst</span>
        </div>
    </div>
    """, unsafe_allow_html=True)
    if st.button(f"🧪  {t('enter_learn')}", key="go_learn", use_container_width=True, type="primary"):
        st.session_state.app_mode = "learn"
        st.switch_page("app_pages/learn_tracks.py")

st.markdown("")

# ── Certification overview (from registry) ──
lang = st.session_state.get("lang", "en")
DIFF_COLORS = {"beginner": "#4ECB71", "intermediate": "#FFD93D", "advanced": "#FF6B6B", "expert": "#C084FC"}

registry = st.session_state.get("CERT_REGISTRY", {})
cert_data = []
for rk, rv in registry.items():
    cert_data.append({
        "key": rk,
        "name": rv.get("name", rk),
        "code": rv.get("code", ""),
        "difficulty": rv.get("difficulty", "intermediate"),
        "icon": rv.get("icon", "📋"),
        "info": rv.get("info", {"en": "Coming soon", "pt": "Em breve", "es": "Proximamente"}),
        "color": rv.get("color", "#6B7280"),
        "available": rv.get("available", False),
        "full_name": rv.get("full_name", ""),
    })

st.markdown(f"#### {t('difficulty_overview')}")
cols = st.columns(len(cert_data))
for i, (col, cert) in enumerate(zip(cols, cert_data)):
    dc = DIFF_COLORS.get(cert["difficulty"], "#9CA3AF")
    dl = t(f"difficulty_{cert['difficulty']}")
    info = get_text(cert["info"], lang)
    is_available = cert.get("available", False)
    with col:
        st.markdown(f"""
        <div style="background:#11263B; border-radius:10px; padding:12px; text-align:center;
                    border-top:3px solid {cert['color']};">
            <p style="font-size:1.6rem; margin:0;">{cert['icon']}</p>
            <p style="color:#E0F7FA; font-weight:600; font-size:0.82rem; margin:4px 0 2px;">{cert['name']}</p>
            <p style="color:#546E7A; font-size:0.68rem; margin:0 0 3px;">{cert['code']}</p>
            <span style="background:{dc}22; color:{dc}; padding:1px 7px;
                        border-radius:8px; font-size:0.68rem; font-weight:600;">{dl}</span>
            <p style="color:#80DEEA; font-size:0.72rem; margin-top:5px;">{info}</p>
        </div>
        """, unsafe_allow_html=True)
        if is_available:
            if st.button(f"Enter {cert['name']}", key=f"cert_enter_{i}", use_container_width=True):
                st.session_state.cert_select = cert["full_name"]
                st.session_state.app_mode = "certifications"
                st.switch_page("app_pages/dashboard.py")

# ── Sidebar: Snowflake logo + connection ──
st.sidebar.markdown(f"""
<div style="text-align:center; padding:8px 0;">
    {SF_LOGO}
</div>
""", unsafe_allow_html=True)

st.sidebar.markdown("---")
try:
    from app_pages.sf_connection import connection_status_widget
    connection_status_widget()
except ImportError:
    pass
