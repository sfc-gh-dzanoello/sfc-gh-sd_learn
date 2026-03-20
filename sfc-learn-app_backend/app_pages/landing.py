"""Landing page — Choose between Certifications, Project Preparation, or Learn & Train."""
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

# ── Three main paths ──
_reg = st.session_state.get("CERT_REGISTRY", {})
_available = [v for v in _reg.values() if v.get("available")]
_coming = len(_reg) - len(_available)
_cert_badges = "".join(
    f'<span style="background:{c.get("color","#29B5E8")}; color:#0B1929; padding:3px 10px; border-radius:14px; font-size:0.75rem; font-weight:600;">{c.get("name","")}</span>'
    for c in _available
)
if _coming > 0:
    _cert_badges += f'<span style="background:rgba(255,255,255,0.08); color:#80DEEA; padding:3px 10px; border-radius:14px; font-size:0.75rem;">+{_coming} {t("coming_soon")}</span>'

col1, col2, col3 = st.columns(3, gap="medium")

with col1:
    st.markdown(f"""
    <div style="background:linear-gradient(135deg, #0D4A6B, #0A3554); border-radius:14px;
                padding:24px 20px; text-align:center; border:2px solid #29B5E8; min-height:280px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2.4rem; margin:0;">🎓</p>
        <h2 style="color:#E0F7FA; margin:8px 0 6px; font-size:1.25rem;">{t('certifications')}</h2>
        <p style="color:#80DEEA; font-size:0.82rem; margin:0 0 10px;">{t('certifications_desc')}</p>
        <div style="display:flex; gap:5px; justify-content:center; flex-wrap:wrap;">
            {_cert_badges}
        </div>
    </div>
    """, unsafe_allow_html=True)
    if st.button(f"🎓  {t('enter_certifications')}", key="go_cert", use_container_width=True, type="primary"):
        st.session_state.app_mode = "certifications"
        st.switch_page("app_pages/dashboard.py")

with col2:
    st.markdown(f"""
    <div style="background:linear-gradient(135deg, #1B5E20, #0D3B11); border-radius:14px;
                padding:24px 20px; text-align:center; border:2px solid #4CAF50; min-height:280px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2.4rem; margin:0;">🏗️</p>
        <h2 style="color:#E8F5E9; margin:8px 0 6px; font-size:1.25rem;">{t('project_preparation')}</h2>
        <p style="color:#A5D6A7; font-size:0.82rem; margin:0 0 10px;">{t('project_prep_desc')}</p>
        <div style="display:flex; gap:5px; justify-content:center; flex-wrap:wrap;">
            <span style="background:#FF9800; color:#0B1929; padding:3px 10px; border-radius:14px; font-size:0.7rem; font-weight:600;">Health Check</span>
            <span style="background:#2196F3; color:#FFF; padding:3px 10px; border-radius:14px; font-size:0.7rem; font-weight:600;">RBAC</span>
            <span style="background:#9C27B0; color:#FFF; padding:3px 10px; border-radius:14px; font-size:0.7rem; font-weight:600;">Architecture</span>
            <span style="background:#4CAF50; color:#FFF; padding:3px 10px; border-radius:14px; font-size:0.7rem; font-weight:600;">Tools</span>
        </div>
    </div>
    """, unsafe_allow_html=True)
    if st.button(f"🏗️  {t('enter_project_prep')}", key="go_prep", use_container_width=True, type="primary"):
        st.session_state.app_mode = "project_prep"
        st.switch_page("app_pages/project_prep.py")

with col3:
    st.markdown(f"""
    <div style="background:linear-gradient(135deg, #3D1560, #2A1070); border-radius:14px;
                padding:24px 20px; text-align:center; border:2px solid #AB47BC; min-height:280px;
                display:flex; flex-direction:column; justify-content:center;">
        <p style="font-size:2.4rem; margin:0;">🧪</p>
        <h2 style="color:#F3E5F5; margin:8px 0 6px; font-size:1.25rem;">{t('learn')}</h2>
        <p style="color:#CE93D8; font-size:0.82rem; margin:0 0 10px;">{t('learn_desc')}</p>
        <div style="display:flex; gap:5px; justify-content:center; flex-wrap:wrap;">
            <span style="background:#FF9800; color:#0B1929; padding:3px 10px; border-radius:14px; font-size:0.7rem; font-weight:600;">Data Engineer</span>
            <span style="background:#1E88E5; color:#FFF; padding:3px 10px; border-radius:14px; font-size:0.7rem; font-weight:600;">Architect</span>
            <span style="background:#AB47BC; color:#FFF; padding:3px 10px; border-radius:14px; font-size:0.7rem; font-weight:600;">Analyst</span>
        </div>
    </div>
    """, unsafe_allow_html=True)
    if st.button(f"🧪  {t('enter_learn')}", key="go_learn", use_container_width=True, type="primary"):
        st.session_state.app_mode = "learn"
        st.switch_page("app_pages/learn_tracks.py")

st.markdown("")

# ── Certification overview — grouped by Core / Advanced / Specialist ──
lang = st.session_state.get("lang", "en")

CATEGORY_META = {
    "core": {"title": "Core", "icon": "🎯", "color": "#29B5E8", "border": "#29B5E8",
             "desc": {"en": "Foundation certification — start here", "pt": "Certificacao base — comece aqui", "es": "Certificacion base — empieza aqui"}},
    "advanced": {"title": "Advanced", "icon": "🚀", "color": "#FF6B6B", "border": "#FF6B6B",
                 "desc": {"en": "Role-based deep expertise", "pt": "Expertise profunda por funcao", "es": "Expertise profunda por rol"}},
    "specialist": {"title": "Specialist", "icon": "🔬", "color": "#AB47BC", "border": "#AB47BC",
                   "desc": {"en": "Technology-focused specializations", "pt": "Especializacoes por tecnologia", "es": "Especializaciones por tecnologia"}},
}

registry = st.session_state.get("CERT_REGISTRY", {})
# Group certs by category
grouped = {"core": [], "advanced": [], "specialist": []}
for rk, rv in registry.items():
    cat = rv.get("category", "core")
    grouped.setdefault(cat, []).append({"key": rk, **rv})

st.markdown("""
<div style="margin:10px 0 4px; text-align:center;">
    <h3 style="color:#E0F7FA; font-size:1.1rem; margin:0;">📋 Certifications — Core / Advanced / Specialist</h3>
</div>
""", unsafe_allow_html=True)

for cat_key in ["core", "advanced", "specialist"]:
    certs = grouped.get(cat_key, [])
    if not certs:
        continue
    meta = CATEGORY_META[cat_key]
    cat_desc = get_text(meta["desc"], lang)

    st.markdown(f"""
    <div style="margin:14px 0 8px; padding:10px 16px; border-left:4px solid {meta['border']};
                background:rgba({','.join(str(int(meta['color'].lstrip('#')[i:i+2], 16)) for i in (0,2,4))},0.08);
                border-radius:0 8px 8px 0;">
        <span style="font-size:1.3rem;">{meta['icon']}</span>
        <strong style="color:{meta['color']}; font-size:1.1rem; margin-left:6px;">{meta['title']}</strong>
        <span style="color:#9CA3AF; font-size:0.82rem; margin-left:10px;">{cat_desc}</span>
    </div>
    """, unsafe_allow_html=True)

    cols = st.columns(min(len(certs), 4))
    for i, cert in enumerate(certs):
        info = get_text(cert.get("info", {}), lang)
        is_available = cert.get("available", False)
        opacity = "1" if is_available else "0.55"
        tag = "" if is_available else '<span style="background:#4B5563; color:#D1D5DB; padding:1px 6px; border-radius:6px; font-size:0.65rem; margin-left:4px;">soon</span>'
        with cols[i % len(cols)]:
            st.markdown(f"""
            <div style="background:#11263B; border-radius:10px; padding:14px; text-align:center;
                        border-top:3px solid {cert.get('color','#6B7280')}; opacity:{opacity}; min-height:140px;">
                <p style="font-size:1.6rem; margin:0;">{cert.get('icon','📋')}</p>
                <p style="color:#E0F7FA; font-weight:600; font-size:0.82rem; margin:4px 0 2px;">{cert.get('name','')}{tag}</p>
                <p style="color:#546E7A; font-size:0.68rem; margin:0 0 3px;">{cert.get('code','')}</p>
                <p style="color:#80DEEA; font-size:0.72rem; margin-top:5px;">{info}</p>
            </div>
            """, unsafe_allow_html=True)
            if is_available:
                if st.button(f"Enter {cert.get('name','')}", key=f"cert_enter_{cat_key}_{i}", use_container_width=True):
                    st.session_state.cert_select = cert.get("full_name", "")
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
