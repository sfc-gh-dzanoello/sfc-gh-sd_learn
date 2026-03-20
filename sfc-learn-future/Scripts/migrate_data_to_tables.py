"""
migrate_data_to_tables.py
Reads all file-based data (registry, questions, review notes, i18n, tracks, content)
and generates SQL INSERT statements to populate the Snowflake tables.

Usage:
    python Scripts/migrate_data_to_tables.py > Scripts/seed_data.sql

Then run seed_data.sql in Snowsight with the correct role on PST.PS_APPS_DEV.
"""
import json
import os
import sys
import glob

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def escape_sql(text):
    """Escape single quotes for SQL string literals."""
    if text is None:
        return "NULL"
    return "'" + str(text).replace("'", "''") + "'"


def variant_literal(obj):
    """Convert a Python object to a PARSE_JSON('...') SQL literal."""
    if obj is None:
        return "NULL"
    return "PARSE_JSON(" + escape_sql(json.dumps(obj, ensure_ascii=False)) + ")"


def emit(sql):
    print(sql)


def migrate_registry():
    """Migrate certifications/registry.json -> CERT_REGISTRY + CERT_DOMAINS + CERT_DOMAIN_TIPS."""
    fp = os.path.join(BASE, "certifications", "registry.json")
    with open(fp, "r", encoding="utf-8") as f:
        data = json.load(f)

    certs = data.get("certifications", {})

    emit("-- ========================================")
    emit("-- CERT_REGISTRY")
    emit("-- ========================================")

    for key, cert in certs.items():
        emit(f"""INSERT INTO CERT_REGISTRY (CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
    SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
    DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
SELECT {escape_sql(key)}, {escape_sql(cert.get('name'))}, {escape_sql(cert.get('code'))},
    {escape_sql(cert.get('full_name'))}, {escape_sql(cert.get('category'))}, {escape_sql(cert.get('color'))},
    {escape_sql(cert.get('sidebar_gradient'))}, {escape_sql(cert.get('sidebar_accent'))},
    {escape_sql(cert.get('sidebar_text'))}, {escape_sql(cert.get('sidebar_sub'))},
    {escape_sql(cert.get('difficulty'))}, {str(cert.get('available', False)).upper()},
    {variant_literal(cert.get('exam'))}, {variant_literal(cert.get('info'))},
    {escape_sql(cert.get('questions_file'))}
WHERE NOT EXISTS (SELECT 1 FROM CERT_REGISTRY WHERE CERT_KEY = {escape_sql(key)});
""")

    emit("-- ========================================")
    emit("-- CERT_DOMAINS")
    emit("-- ========================================")

    for key, cert in certs.items():
        domains = cert.get("domains", {})
        for i, (dname, dinfo) in enumerate(domains.items()):
            emit(f"""INSERT INTO CERT_DOMAINS (CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
SELECT {escape_sql(key)}, {escape_sql(dname)}, {escape_sql(dinfo.get('dir'))},
    {escape_sql(dinfo.get('color'))}, {escape_sql(dinfo.get('css_num'))},
    {escape_sql(dinfo.get('weight'))}, {i + 1}
WHERE NOT EXISTS (SELECT 1 FROM CERT_DOMAINS WHERE CERT_KEY = {escape_sql(key)} AND DOMAIN_NAME = {escape_sql(dname)});
""")

    emit("-- ========================================")
    emit("-- CERT_DOMAIN_TIPS")
    emit("-- ========================================")

    for key, cert in certs.items():
        tips = cert.get("domain_tips", {})
        for dname, tip_list in tips.items():
            for j, tip in enumerate(tip_list):
                emit(f"""INSERT INTO CERT_DOMAIN_TIPS (CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
SELECT {escape_sql(key)}, {escape_sql(dname)}, {j + 1}, {escape_sql(tip)}
WHERE NOT EXISTS (SELECT 1 FROM CERT_DOMAIN_TIPS WHERE CERT_KEY = {escape_sql(key)} AND DOMAIN_NAME = {escape_sql(dname)} AND TIP_ORDER = {j + 1});
""")


def migrate_questions():
    """Migrate question JSON files -> CERT_QUESTIONS."""
    emit("-- ========================================")
    emit("-- CERT_QUESTIONS")
    emit("-- ========================================")

    questions_dir = os.path.join(BASE, "certifications", "questions")
    file_map = {
        "core_questions.json": "core",
        "architect_questions.json": "architect",
        "gen_ai_questions.json": "gen_ai",
    }

    for filename, cert_key in file_map.items():
        fp = os.path.join(questions_dir, filename)
        if not os.path.exists(fp):
            continue
        with open(fp, "r", encoding="utf-8") as f:
            questions = json.load(f)

        for q in questions:
            qid = q.get("id", "")
            emit(f"""INSERT INTO CERT_QUESTIONS (QUESTION_ID, CERT_KEY, SOURCE, DOMAIN, QUESTION_TEXT, OPTIONS, CORRECT_INDICES, EXPLANATION, DIFFICULTY)
SELECT {escape_sql(qid)}, {escape_sql(cert_key)}, {escape_sql(q.get('source'))},
    {escape_sql(q.get('domain'))}, {escape_sql(q.get('question'))},
    {variant_literal(q.get('options'))}, {variant_literal(q.get('correct_indices'))},
    {escape_sql(q.get('explanation'))}, {escape_sql(q.get('difficulty'))}
WHERE NOT EXISTS (SELECT 1 FROM CERT_QUESTIONS WHERE QUESTION_ID = {escape_sql(qid)});
""")


def migrate_review_notes():
    """Migrate review_notes_*.md files -> CERT_REVIEW_NOTES."""
    emit("-- ========================================")
    emit("-- CERT_REVIEW_NOTES")
    emit("-- ========================================")

    certs_dir = os.path.join(BASE, "certifications")
    fp = os.path.join(certs_dir, "registry.json")
    with open(fp, "r", encoding="utf-8") as f:
        registry = json.load(f).get("certifications", {})

    for cert_key, cert in registry.items():
        domains = cert.get("domains", {})
        for dname, dinfo in domains.items():
            ddir = dinfo.get("dir", "")
            if not ddir:
                continue
            full_dir = os.path.join(BASE, ddir)
            for lang in ["en", "es", "pt"]:
                md_path = os.path.join(full_dir, f"review_notes_{lang}.md")
                if not os.path.exists(md_path):
                    continue
                with open(md_path, "r", encoding="utf-8") as f:
                    content = f.read()
                emit(f"""INSERT INTO CERT_REVIEW_NOTES (CERT_KEY, DOMAIN_NAME, LANG, CONTENT)
SELECT {escape_sql(cert_key)}, {escape_sql(dname)}, {escape_sql(lang)}, {escape_sql(content)}
WHERE NOT EXISTS (SELECT 1 FROM CERT_REVIEW_NOTES WHERE CERT_KEY = {escape_sql(cert_key)} AND DOMAIN_NAME = {escape_sql(dname)} AND LANG = {escape_sql(lang)});
""")


def migrate_i18n():
    """Migrate i18n/strings.json -> APP_I18N."""
    emit("-- ========================================")
    emit("-- APP_I18N")
    emit("-- ========================================")

    fp = os.path.join(BASE, "i18n", "strings.json")
    with open(fp, "r", encoding="utf-8") as f:
        strings = json.load(f)

    for key, translations in strings.items():
        en = translations.get("en", "") if isinstance(translations, dict) else str(translations)
        pt = translations.get("pt", "") if isinstance(translations, dict) else ""
        es = translations.get("es", "") if isinstance(translations, dict) else ""
        emit(f"""INSERT INTO APP_I18N (STRING_KEY, EN, PT, ES)
SELECT {escape_sql(key)}, {escape_sql(en)}, {escape_sql(pt)}, {escape_sql(es)}
WHERE NOT EXISTS (SELECT 1 FROM APP_I18N WHERE STRING_KEY = {escape_sql(key)});
""")


def migrate_tracks():
    """Migrate labs/tracks.json + topic JSONs -> LEARN_TRACKS + LEARN_CONTENT."""
    emit("-- ========================================")
    emit("-- LEARN_TRACKS")
    emit("-- ========================================")

    labs_dir = os.path.join(BASE, "labs")
    tracks_fp = os.path.join(labs_dir, "tracks.json")
    if not os.path.exists(tracks_fp):
        return
    with open(tracks_fp, "r", encoding="utf-8") as f:
        tracks = json.load(f)

    for track_key, track in tracks.items():
        emit(f"""INSERT INTO LEARN_TRACKS (TRACK_KEY, NAME, DESCRIPTION, COLOR, EMOJI, DIFFICULTY, TOPICS)
SELECT {escape_sql(track_key)}, {variant_literal(track.get('name'))}, {variant_literal(track.get('description'))},
    {escape_sql(track.get('color'))}, {escape_sql(track.get('emoji'))},
    {escape_sql(track.get('difficulty'))}, {variant_literal(track.get('topics'))}
WHERE NOT EXISTS (SELECT 1 FROM LEARN_TRACKS WHERE TRACK_KEY = {escape_sql(track_key)});
""")

    emit("-- ========================================")
    emit("-- LEARN_CONTENT")
    emit("-- ========================================")

    for track_key, track in tracks.items():
        topic_keys = track.get("topics", [])
        for topic_key in topic_keys:
            topic_fp = os.path.join(labs_dir, track_key, f"{topic_key}.json")
            if not os.path.exists(topic_fp):
                continue
            with open(topic_fp, "r", encoding="utf-8") as f:
                topic_data = json.load(f)
            emit(f"""INSERT INTO LEARN_CONTENT (TRACK_KEY, TOPIC_KEY, TOPIC_DATA)
SELECT {escape_sql(track_key)}, {escape_sql(topic_key)}, {variant_literal(topic_data)}
WHERE NOT EXISTS (SELECT 1 FROM LEARN_CONTENT WHERE TRACK_KEY = {escape_sql(track_key)} AND TOPIC_KEY = {escape_sql(topic_key)});
""")


def migrate_app_content():
    """Migrate standalone content files -> APP_CONTENT."""
    emit("-- ========================================")
    emit("-- APP_CONTENT")
    emit("-- ========================================")

    strategy_fp = os.path.join(BASE, "certifications", "exam_strategy_partners.md")
    if os.path.exists(strategy_fp):
        with open(strategy_fp, "r", encoding="utf-8") as f:
            content = f.read()
        emit(f"""INSERT INTO APP_CONTENT (CONTENT_KEY, LANG, CONTENT)
SELECT 'exam_strategy_partners', 'en', {escape_sql(content)}
WHERE NOT EXISTS (SELECT 1 FROM APP_CONTENT WHERE CONTENT_KEY = 'exam_strategy_partners' AND LANG = 'en');
""")


if __name__ == "__main__":
    emit("-- Auto-generated seed data for Snowflake PS Platform tables")
    emit("-- Generated by Scripts/migrate_data_to_tables.py")
    emit("-- Run after Scripts/create_app_tables.sql")
    emit("")
    migrate_registry()
    migrate_questions()
    migrate_review_notes()
    migrate_i18n()
    migrate_tracks()
    migrate_app_content()
    emit("-- Done. Verify with:")
    emit("-- SELECT 'CERT_REGISTRY' AS TBL, COUNT(*) AS ROWS FROM CERT_REGISTRY")
    emit("-- UNION ALL SELECT 'CERT_DOMAINS', COUNT(*) FROM CERT_DOMAINS")
    emit("-- UNION ALL SELECT 'CERT_DOMAIN_TIPS', COUNT(*) FROM CERT_DOMAIN_TIPS")
    emit("-- UNION ALL SELECT 'CERT_QUESTIONS', COUNT(*) FROM CERT_QUESTIONS")
    emit("-- UNION ALL SELECT 'CERT_REVIEW_NOTES', COUNT(*) FROM CERT_REVIEW_NOTES")
    emit("-- UNION ALL SELECT 'APP_I18N', COUNT(*) FROM APP_I18N")
    emit("-- UNION ALL SELECT 'LEARN_TRACKS', COUNT(*) FROM LEARN_TRACKS")
    emit("-- UNION ALL SELECT 'LEARN_CONTENT', COUNT(*) FROM LEARN_CONTENT")
    emit("-- UNION ALL SELECT 'APP_CONTENT', COUNT(*) FROM APP_CONTENT;")
