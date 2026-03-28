"""Load all certification content into Snowflake tables.

Reads registry.json and question files, inserts into:
  - CERT_DOMAINS (domains per cert)
  - CERT_DOMAIN_TIPS (tips per domain per cert)
  - CERT_QUESTIONS (all questions across all certs)
  - CERT_REVIEW_NOTES (markdown review notes per domain/lang)

Usage:
    python3 Scripts/load_tables.py
"""
import snowflake.connector
import json
import os
import glob

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CONNECT_PARAMS = dict(
    account="SFCOGSOPS-SNOWHOUSE_AWS_US_WEST_2",
    user="DZANOELLO",
    authenticator="externalbrowser",
    role="TECHNICAL_ACCOUNT_MANAGER",
    warehouse="SNOWADHOC",
    database="PST",
    schema="PS_APPS_DEV",
)


def load_registry():
    with open(os.path.join(PROJECT_DIR, "registry.json")) as f:
        return json.load(f)["certifications"]


def insert_domains(cur, certs):
    """Insert into CERT_DOMAINS."""
    cur.execute("DELETE FROM CERT_DOMAINS")
    rows = []
    for cert_key, cert in certs.items():
        for i, (dname, dinfo) in enumerate(cert.get("domains", {}).items(), 1):
            rows.append((
                cert_key,
                dname,
                dinfo.get("dir", ""),
                dinfo.get("color", ""),
                dinfo.get("css_num", ""),
                dinfo.get("weight", ""),
                i,
            ))
    if rows:
        cur.executemany(
            "INSERT INTO CERT_DOMAINS (CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            rows,
        )
    print(f"  CERT_DOMAINS: {len(rows)} rows inserted")


def insert_domain_tips(cur, certs):
    """Insert into CERT_DOMAIN_TIPS."""
    cur.execute("DELETE FROM CERT_DOMAIN_TIPS")
    rows = []
    for cert_key, cert in certs.items():
        for dname, tips in cert.get("domain_tips", {}).items():
            for i, tip in enumerate(tips, 1):
                rows.append((cert_key, dname, i, tip))
    if rows:
        cur.executemany(
            "INSERT INTO CERT_DOMAIN_TIPS (CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT) "
            "VALUES (%s, %s, %s, %s)",
            rows,
        )
    print(f"  CERT_DOMAIN_TIPS: {len(rows)} rows inserted")


def insert_questions(cur, certs):
    """Insert into CERT_QUESTIONS."""
    cur.execute("DELETE FROM CERT_QUESTIONS")
    total = 0
    for cert_key, cert in certs.items():
        qfile = cert.get("questions_file")
        if not qfile:
            continue
        qpath = os.path.join(PROJECT_DIR, qfile)
        if not os.path.exists(qpath):
            print(f"  WARNING: {qpath} not found, skipping {cert_key}")
            continue
        with open(qpath) as f:
            data = json.load(f)
        questions = data.get("questions", data) if isinstance(data, dict) else data
        count = 0
        for q in questions:
            if q.get("archived"):
                continue
            options_json = json.dumps(q.get("options", []))
            indices_json = json.dumps(q.get("correct_indices", []))
            cur.execute(
                "INSERT INTO CERT_QUESTIONS (CERT_KEY, QUESTION_ID, SOURCE, DOMAIN, "
                "QUESTION_TEXT, OPTIONS, CORRECT_INDICES, EXPLANATION, DIFFICULTY) "
                "SELECT %s, %s, %s, %s, %s, PARSE_JSON(%s), PARSE_JSON(%s), %s, %s",
                (
                    cert_key,
                    q.get("id", ""),
                    q.get("source", ""),
                    q.get("domain", ""),
                    q.get("question", ""),
                    options_json,
                    indices_json,
                    q.get("overall_explanation", ""),
                    q.get("difficulty", ""),
                ),
            )
            count += 1
        total += count
        print(f"  CERT_QUESTIONS [{cert_key}]: {count} questions")
    print(f"  CERT_QUESTIONS total: {total} rows inserted")


def insert_review_notes(cur, certs):
    """Insert into CERT_REVIEW_NOTES."""
    cur.execute("DELETE FROM CERT_REVIEW_NOTES")
    rows = []
    for cert_key, cert in certs.items():
        for dname, dinfo in cert.get("domains", {}).items():
            ddir = dinfo.get("dir", "")
            if not ddir:
                continue
            abs_dir = os.path.join(PROJECT_DIR, ddir)
            if not os.path.isdir(abs_dir):
                continue
            for md_file in glob.glob(os.path.join(abs_dir, "review_notes_*.md")):
                fname = os.path.basename(md_file)
                # Extract lang from filename: review_notes_en.md -> en
                lang = fname.replace("review_notes_", "").replace(".md", "")
                if lang not in ("en", "pt", "es"):
                    continue
                with open(md_file, "r", encoding="utf-8") as f:
                    content = f.read()
                if content.strip():
                    rows.append((cert_key, dname, lang, content))
    if rows:
        cur.executemany(
            "INSERT INTO CERT_REVIEW_NOTES (CERT_KEY, DOMAIN_NAME, LANG, CONTENT) "
            "VALUES (%s, %s, %s, %s)",
            rows,
        )
    print(f"  CERT_REVIEW_NOTES: {len(rows)} rows inserted")


def main():
    print("Loading registry.json...")
    certs = load_registry()
    active = [k for k, v in certs.items() if v.get("domains")]
    print(f"Found {len(certs)} certs ({len(active)} with domains: {', '.join(active)})\n")

    print("Connecting to Snowflake...")
    conn = snowflake.connector.connect(**CONNECT_PARAMS)
    cur = conn.cursor()
    cur.execute("SELECT CURRENT_ROLE()")
    print(f"Connected with role: {cur.fetchone()[0]}\n")

    print("Loading tables...")
    insert_domains(cur, certs)
    insert_domain_tips(cur, certs)
    insert_questions(cur, certs)
    insert_review_notes(cur, certs)

    print("\nVerifying row counts...")
    for table in ["CERT_REGISTRY", "CERT_DOMAINS", "CERT_DOMAIN_TIPS", "CERT_QUESTIONS", "CERT_REVIEW_NOTES"]:
        cur.execute(f"SELECT COUNT(*) FROM {table}")
        count = cur.fetchone()[0]
        print(f"  {table}: {count} rows")

    cur.close()
    conn.close()
    print("\nDone!")


if __name__ == "__main__":
    main()
