"""Deploy Streamlit app to Snowflake SiS using Python connector.

Bypasses snow CLI role issue by connecting directly with TECHNICAL_ACCOUNT_MANAGER.
Uploads all files to the stage. The app already reads from STUDY_HUB_STAGE.

Usage:
    python3 Scripts/deploy_to_sis.py          # Upload files only (normal update)
    python3 Scripts/deploy_to_sis.py --create  # Also recreate the streamlit object
"""
import snowflake.connector
import os
import sys
import glob

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STAGE = "@PST.PS_APPS_DEV.STUDY_HUB_STAGE"

CONNECT_PARAMS = dict(
    account="SFCOGSOPS-SNOWHOUSE_AWS_US_WEST_2",
    user="DZANOELLO",
    authenticator="externalbrowser",
    role="TECHNICAL_ACCOUNT_MANAGER",
    warehouse="SNOWADHOC",
    database="PST",
    schema="PS_APPS_DEV",
)

# Files/dirs to upload (relative to project dir)
MAIN_FILE = "streamlit_app.py"
PAGES_DIR = "app_pages"
ARTIFACTS = ["i18n", "certifications", "registry.json", "environment.yml", "theme.py"]


def collect_files():
    """Collect all files to upload as (local_path, stage_subpath) tuples."""
    files = []

    # Main file
    files.append((os.path.join(PROJECT_DIR, MAIN_FILE), MAIN_FILE))

    # Pages dir
    for py in sorted(glob.glob(os.path.join(PROJECT_DIR, PAGES_DIR, "*.py"))):
        rel = os.path.relpath(py, PROJECT_DIR)
        files.append((py, rel))

    # Artifacts
    for art in ARTIFACTS:
        art_path = os.path.join(PROJECT_DIR, art)
        if os.path.isfile(art_path):
            files.append((art_path, art))
        elif os.path.isdir(art_path):
            for root, _dirs, fnames in os.walk(art_path):
                # Skip __pycache__
                if "__pycache__" in root:
                    continue
                for fname in sorted(fnames):
                    full = os.path.join(root, fname)
                    rel = os.path.relpath(full, PROJECT_DIR)
                    files.append((full, rel))

    return files


def upload_files(cur, files):
    """Upload files to the stage."""
    for local_path, rel_path in files:
        stage_dir = os.path.dirname(rel_path)
        if stage_dir:
            target = f"{STAGE}/{stage_dir}/"
        else:
            target = f"{STAGE}/"
        sql = f"PUT 'file://{local_path}' '{target}' OVERWRITE=TRUE AUTO_COMPRESS=FALSE"
        try:
            cur.execute(sql)
            result = cur.fetchone()
            status = result[6] if result and len(result) > 6 else "OK"
            print(f"  [{status}] {rel_path}")
        except Exception as e:
            print(f"  [ERROR] {rel_path}: {e}")


def create_streamlit(cur):
    """Create or replace the streamlit app from staged files."""
    sql = """
    CREATE OR REPLACE STREAMLIT PST.PS_APPS_DEV.PRQZ2EGXBDMF6UTA
        FROM '@PST.PS_APPS_DEV.STUDY_HUB_STAGE'
        MAIN_FILE = 'streamlit_app.py'
        QUERY_WAREHOUSE = 'SNOWADHOC'
        TITLE = 'Snowflake Certification Study Hub'
    """
    cur.execute(sql)
    print("Streamlit app created/replaced successfully!")


def main():
    do_create = "--create" in sys.argv

    files = collect_files()
    print(f"Collected {len(files)} files to upload.\n")

    print("Connecting to Snowflake...")
    conn = snowflake.connector.connect(**CONNECT_PARAMS)
    cur = conn.cursor()

    cur.execute("SELECT CURRENT_ROLE()")
    role = cur.fetchone()[0]
    print(f"Connected with role: {role}\n")

    if role != "TECHNICAL_ACCOUNT_MANAGER":
        print(f"ERROR: Expected TECHNICAL_ACCOUNT_MANAGER, got {role}")
        return

    print("Uploading files to stage...")
    upload_files(cur, files)

    if do_create:
        print("\nRecreating streamlit app from stage...")
        create_streamlit(cur)
    else:
        print("\nFiles uploaded. App reads from stage -- refresh the app page to see changes.")

    # Verify
    cur.execute("DESCRIBE STREAMLIT PST.PS_APPS_DEV.PRQZ2EGXBDMF6UTA")
    row = cur.fetchone()
    print(f"\nApp title: {row[0]}")
    print(f"Main file: {row[1]}")
    print(f"Warehouse: {row[2]}")
    print(f"\nURL: https://app.snowflake.com/sfcogsops/snowhouse_aws_us_west_2/#/streamlit-apps/PST.PS_APPS_DEV.PRQZ2EGXBDMF6UTA")

    cur.close()
    conn.close()
    print("\nDone!")


if __name__ == "__main__":
    main()
