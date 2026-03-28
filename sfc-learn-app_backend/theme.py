"""
theme.py -- Single source of truth for ALL colors and visual styling.
Edit colors HERE -- they flow to every page automatically.

HOW TO USE:
  from theme import T
  T.PRIMARY        -> "#29B5E8"   (Snowflake blue)
  T.CORRECT        -> "#4ECB71"   (green)
  T.domain(1)      -> {"bg": "rgba(41,181,232,0.18)", "border": "#29B5E8", "bar_bg": ...}
  T.css()          -> full <style> block for streamlit_app.py
  T.semantic("why this matters") -> {"bg": "#E8F5E9", "border": "#2E7D32", ...}
"""


class _Theme:
    """App-wide color and styling constants."""

    # ── Core palette ──
    PRIMARY = "#29B5E8"       # Snowflake blue -- main accent
    RED = "#FF6B6B"           # errors, wrong answers, domain 2
    GREEN = "#4ECB71"         # correct, success, domain 3
    YELLOW = "#FFD93D"        # warnings, missed, domain 4
    PURPLE = "#C084FC"        # multi-select, domain 5
    GRAY = "#6B7280"          # untagged, muted text
    ORANGE = "#FF9800"        # labs, badges

    # ── Feedback aliases (quiz) ──
    CORRECT = GREEN
    WRONG = RED
    MISSED = YELLOW

    # ── Text colors ──
    TEXT_PRIMARY = "#FAFAFA"   # white text on dark bg
    TEXT_SECONDARY = "#9CA3AF" # gray subtext
    TEXT_DARK = "#1a1a2e"      # dark text on light bg
    TEXT_BODY = "#333"         # body text inside note cards

    # ── Background colors ──
    BG_CARD = "#1B2332"        # dark card background
    BG_CARD_BORDER = "#2D3748" # card border / progress track
    BG_SECTION = "#FAFAFA"     # white note section
    BG_CODE = "#e8e8e8"        # inline code background

    # ── Landing page gradients ──
    LANDING_CERT_BG = "linear-gradient(135deg, #0D4A6B, #0A3554)"
    LANDING_CERT_BORDER = PRIMARY
    LANDING_CERT_TITLE = "#E0F7FA"
    LANDING_CERT_SUB = "#80DEEA"
    LANDING_PROJ_BG = "linear-gradient(135deg, #1B5E20, #0D3B11)"
    LANDING_PROJ_BORDER = "#4CAF50"
    LANDING_PROJ_TITLE = "#E8F5E9"
    LANDING_PROJ_SUB = "#A5D6A7"
    LANDING_LEARN_BG = "linear-gradient(135deg, #3D1560, #2A1070)"
    LANDING_LEARN_BORDER = "#AB47BC"
    LANDING_LEARN_TITLE = "#F3E5F5"
    LANDING_LEARN_SUB = "#CE93D8"

    # ── Domain colors (index 1-5) ──
    _DOMAINS = {
        1: {"hex": "#29B5E8", "rgb": "41,181,232"},
        2: {"hex": "#FF6B6B", "rgb": "255,107,107"},
        3: {"hex": "#4ECB71", "rgb": "78,203,113"},
        4: {"hex": "#FFD93D", "rgb": "255,217,61"},
        5: {"hex": "#C084FC", "rgb": "192,132,252"},
    }
    DOMAIN_OPACITY = 0.18  # card background transparency

    def domain(self, n):
        """Get domain color dict: bg, border, bar_bg, bar_text."""
        d = self._DOMAINS.get(n, {"hex": self.GRAY, "rgb": "107,114,128"})
        op = self.DOMAIN_OPACITY
        return {
            "hex": d["hex"],
            "bg": f"rgba({d['rgb']},{op})",
            "border": d["hex"],
            "bar_bg": f"rgba({d['rgb']},0.2)",
            "bar_text": d["hex"],
        }

    def domain_hex(self, n):
        """Shortcut: get hex color for domain N."""
        return self._DOMAINS.get(n, {"hex": self.GRAY})["hex"]

    # ── Difficulty colors ──
    DIFFICULTY = {
        "beginner": "#4ECB71",
        "intermediate": "#FFD93D",
        "advanced": "#FF6B6B",
        "expert": "#C084FC",
    }

    # ── Semantic blocks (review notes) ──
    _SEMANTIC = {
        "why this matters": {
            "bg": "#E8F5E9", "border": "#2E7D32",
            "summary_bg": "#C8E6C9", "summary_color": "#1B5E20",
            "icon": "&#x1F3AF;",
        },
        "best practices": {
            "bg": "#E3F2FD", "border": "#1565C0",
            "summary_bg": "#BBDEFB", "summary_color": "#0D47A1",
            "icon": "&#x2705;",
        },
        "real-world examples": {
            "bg": "#FFF3E0", "border": "#E65100",
            "summary_bg": "#FFE0B2", "summary_color": "#BF360C",
            "icon": "&#x1F3E2;",
        },
        "common confusion": {
            "bg": "#FFF8E1", "border": "#F9A825",
            "summary_bg": "#FFF9C4", "summary_color": "#F57F17",
            "icon": "&#x26A0;",
        },
        "confusing pairs": {
            "bg": "#FFF8E1", "border": "#F9A825",
            "summary_bg": "#FFF9C4", "summary_color": "#F57F17",
            "icon": "&#x1F500;",
        },
        "scenario decision tree": {
            "bg": "#F3E5F5", "border": "#7B1FA2",
            "summary_bg": "#E1BEE7", "summary_color": "#4A148C",
            "icon": "&#x1F333;",
        },
        "example scenario questions": {
            "bg": "#F3E5F5", "border": "#7B1FA2",
            "summary_bg": "#E1BEE7", "summary_color": "#4A148C",
            "icon": "&#x1F914;",
        },
        "scenario-based faq": {
            "bg": "#F3E5F5", "border": "#7B1FA2",
            "summary_bg": "#E1BEE7", "summary_color": "#4A148C",
            "icon": "&#x2753;",
        },
        "eli5": {
            "bg": "#E0F7FA", "border": "#00ACC1",
            "summary_bg": "#B2EBF2", "summary_color": "#006064",
            "icon": "&#x1F476;",
        },
        "mnemonics": {
            "bg": "#FCE4EC", "border": "#AD1457",
            "summary_bg": "#F8BBD0", "summary_color": "#880E4F",
            "icon": "&#x1F9E0;",
        },
        "top traps": {
            "bg": "#FFEBEE", "border": "#C62828",
            "summary_bg": "#FFCDD2", "summary_color": "#B71C1C",
            "icon": "&#x1F6A8;",
        },
        "pattern shortcuts": {
            "bg": "#EDE7F6", "border": "#5E35B1",
            "summary_bg": "#D1C4E9", "summary_color": "#311B92",
            "icon": "&#x26A1;",
        },
    }

    # ── Inline callout styles (visual anchors inside body text) ──
    CALLOUTS = {
        "remember": {"bg": "#E3F2FD", "border": "#1565C0", "label_color": "#0D47A1"},
        "dont_confuse": {"bg": "#FFF3E0", "border": "#E65100", "label_color": "#BF360C"},
        "precedence": {"bg": "#F3E5F5", "border": "#7B1FA2", "label_color": "#4A148C"},
    }

    def semantic(self, key):
        """Get semantic block style dict for a heading key (lowercased)."""
        return self._SEMANTIC.get(key.lower().strip())

    # ── Sticky note colors ──
    STICKY = {
        "yellow": {"bg": "#FFF9C4", "border": "#F9A825"},
        "pink":   {"bg": "#FCE4EC", "border": "#E91E63"},
        "blue":   {"bg": "#E3F2FD", "border": "#1565C0"},
        "green":  {"bg": "#E8F5E9", "border": "#2E7D32"},
        "purple": {"bg": "#F3E5F5", "border": "#7B1FA2"},
        "orange": {"bg": "#FFF3E0", "border": "#E65100"},
    }

    # ── Highlight marker colors ──
    MARKS = {
        "yellow": "#FFF176", "pink": "#F48FB1", "blue": "#90CAF9",
        "green": "#A5D6A7", "orange": "#FFB74D", "purple": "#CE93D8",
        "red": "#EF9A9A", "cyan": "#80DEEA",
    }

    # ── Score color helper ──
    def score_color(self, pct):
        """Return green/yellow/red based on score percentage."""
        if pct >= 70:
            return self.GREEN
        if pct >= 50:
            return self.YELLOW
        return self.RED

    # ── Generate full CSS block ──
    def css(self):
        """Return the complete <style> block for streamlit_app.py."""
        d = self._DOMAINS
        op = self.DOMAIN_OPACITY
        lines = []
        lines.append("<style>")

        # Domain cards
        lines.append("""
.domain-card {
    border-radius: 12px;
    padding: 18px 20px;
    margin-bottom: 12px;
    border-left: 5px solid;
}
.domain-card h3 { margin: 0 0 6px 0; font-size: 1.1rem; }
.domain-card p { margin: 0; opacity: 0.85; font-size: 0.9rem; }
""")
        for n, info in d.items():
            lines.append(f".domain-{n} {{ background: rgba({info['rgb']},{op}); border-color: {info['hex']}; }}")
        lines.append(f".domain-card h3 {{ color: {self.TEXT_DARK}; }}")
        lines.append(f".domain-card .domain-weight {{ font-size: 1.6rem; font-weight: 800; color: {self.TEXT_DARK}; margin: 0; }}")

        # Domain badges
        lines.append(f"""
.domain-badge {{
    display: inline-block;
    padding: 3px 12px;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 600;
    color: #0E1117;
    margin-right: 8px;
}}""")
        for n, info in d.items():
            lines.append(f".badge-d{n} {{ background: {info['hex']}; }}")
        lines.append(f".badge-gray {{ background: {self.GRAY}; color: {self.TEXT_PRIMARY}; }}")

        # Stat cards
        lines.append(f"""
.stat-card {{
    background: {self.BG_CARD};
    border-radius: 12px;
    padding: 16px 20px;
    text-align: center;
}}
.stat-card .stat-value {{
    font-size: 2rem;
    font-weight: 700;
    color: {self.PRIMARY};
    margin: 0;
}}
.stat-card .stat-label {{
    font-size: 0.85rem;
    color: {self.TEXT_SECONDARY};
    margin: 4px 0 0 0;
}}""")

        # Flashcards
        lines.append(f"""
.flashcard {{
    background: {self.BG_CARD};
    border-radius: 12px;
    padding: 24px;
    margin: 10px 0;
    border: 1px solid {self.BG_CARD_BORDER};
    cursor: pointer;
    transition: border-color 0.2s;
}}
.flashcard:hover {{ border-color: {self.PRIMARY}; }}
.flashcard-q {{ font-weight: 700; font-size: 1rem; color: {self.TEXT_PRIMARY}; }}
.flashcard-a {{ color: {self.GREEN}; font-size: 0.95rem; margin-top: 10px; }}""")

        # Progress bar
        lines.append(".color-bar { height: 8px; border-radius: 4px; margin: 6px 0 12px 0; }")

        # Quiz feedback
        for cls, color in [("correct", self.GREEN), ("wrong", self.RED), ("missed", self.YELLOW)]:
            lines.append(f"""
.feedback-{cls} {{
    background: rgba({self._hex_to_rgb(color)},0.15);
    border-left: 4px solid {color};
    padding: 12px 16px;
    border-radius: 8px;
    margin: 4px 0;
}}""")

        # Exam trap + mnemonic
        lines.append(f"""
.exam-trap {{
    background: rgba({self._hex_to_rgb(self.RED)},0.1);
    border-left: 4px solid {self.RED};
    padding: 10px 14px;
    border-radius: 6px;
    margin: 8px 0;
    font-size: 0.9rem;
}}
.mnemonic {{
    background: rgba({self._hex_to_rgb(self.PRIMARY)},0.1);
    border-left: 4px solid {self.PRIMARY};
    padding: 10px 14px;
    border-radius: 6px;
    margin: 8px 0;
    font-size: 0.9rem;
}}""")

        # Question domain bar
        lines.append("""
.q-domain-bar {
    padding: 8px 16px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-weight: 600;
    font-size: 0.9rem;
}""")
        for n, info in d.items():
            lines.append(f".q-domain-bar-{n} {{ background: rgba({info['rgb']},0.2); color: {info['hex']}; }}")
        lines.append(f".q-domain-bar-unknown {{ background: rgba(107,114,128,0.2); color: {self.TEXT_SECONDARY}; }}")

        # Question card
        lines.append(f"""
.question-card {{
    background: #FFFFFF;
    border-radius: 12px;
    padding: 20px 24px;
    margin: 12px 0;
    border: 1px solid #E5E7EB;
    color: {self.TEXT_DARK};
    box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}}
.question-card h3 {{ color: {self.TEXT_DARK}; margin-top: 0; }}
.scenario-option {{
    background: #F8FAFC;
    border: 1px solid #E2E8F0;
    border-radius: 8px;
    padding: 12px 16px;
    margin: 6px 0;
    line-height: 1.6;
}}
.scenario-option .step-num {{ color: #1565C0; font-weight: 700; margin-right: 4px; }}""")

        # Timeline
        lines.append(f"""
.timeline-step {{ display: flex; align-items: flex-start; gap: 14px; margin: 12px 0; }}
.timeline-dot {{
    width: 28px; height: 28px; border-radius: 50%;
    background: {self.PRIMARY};
    display: flex; align-items: center; justify-content: center;
    font-weight: 700; font-size: 0.8rem; color: #0E1117; flex-shrink: 0;
}}
.timeline-content {{ flex: 1; }}
.timeline-content strong {{ color: {self.TEXT_PRIMARY}; }}
.timeline-content p {{ color: {self.TEXT_SECONDARY}; margin: 2px 0 0 0; font-size: 0.9rem; }}""")

        # Tables
        lines.append(f"""
table {{ border-collapse: collapse; width: 100%; }}
th {{ background: {self.BG_CARD} !important; color: {self.PRIMARY} !important; }}
td.yes {{ color: {self.GREEN} !important; font-weight: 600; }}
td.no {{ color: #4B5563 !important; }}""")

        # Notes section
        lines.append(f"""
.notes-section {{
    background: {self.BG_SECTION};
    color: {self.TEXT_DARK};
    border-radius: 12px;
    padding: 20px 24px;
    margin: 12px 0;
    border-left: 5px solid;
}}
.notes-section h1, .notes-section h2, .notes-section h3 {{ color: {self.TEXT_DARK}; }}
.notes-section p, .notes-section li, .notes-section td {{ color: {self.TEXT_BODY}; }}
.notes-section code {{ background: {self.BG_CODE}; color: #c7254e; padding: 2px 4px; border-radius: 3px; }}
.notes-imp-red {{ border-color: {self.RED}; }}
.notes-imp-green {{ border-color: {self.GREEN}; }}
.notes-imp-blue {{ border-color: {self.PRIMARY}; }}
.notes-imp-yellow {{ border-color: {self.YELLOW}; }}
.notes-imp-purple {{ border-color: {self.PURPLE}; }}""")

        # Sticky notes
        lines.append(f"""
.sticky-note {{
    color: {self.TEXT_BODY};
    border-radius: 4px 24px 4px 4px;
    padding: 12px 16px;
    margin: 8px 0;
    font-size: 0.9rem;
    box-shadow: 2px 3px 8px rgba(0,0,0,0.12);
    position: relative;
    line-height: 1.5;
    font-family: 'Segoe UI', sans-serif;
}}
.sticky-note::before {{ position: absolute; top: -10px; right: 10px; font-size: 0.9rem; }}""")
        for name, colors in self.STICKY.items():
            lines.append(f".sticky-{name} {{ background: {colors['bg']}; border-left: 4px solid {colors['border']}; }}")
            lines.append(f'.sticky-{name}::before {{ content: "pin"; color: {colors["border"]}; }}')

        # Highlight marks
        for name, color in self.MARKS.items():
            lines.append(f".mark-{name} {{ background: {color}; padding: 1px 4px; border-radius: 2px; }}")

        lines.append("</style>")
        return "\n".join(lines)

    @staticmethod
    def _hex_to_rgb(hex_color):
        """Convert #RRGGBB to 'R,G,B' string."""
        h = hex_color.lstrip("#")
        return f"{int(h[0:2],16)},{int(h[2:4],16)},{int(h[4:6],16)}"


# Singleton -- import this everywhere
T = _Theme()
