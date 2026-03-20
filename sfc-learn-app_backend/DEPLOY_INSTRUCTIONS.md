# Deploying Snowflake Learning Hub to Streamlit in Snowflake (SiS)

## Prerequisites

1. **Snowflake CLI (`snow`)** installed — [Install guide](https://docs.snowflake.com/en/developer-guide/snowflake-cli/installation/installation)
2. A Snowflake account with **ACCOUNTADMIN** or a role with CREATE STREAMLIT privilege
3. A warehouse (e.g., `COMPUTE_WH`)
4. A database and schema to deploy into (e.g., `PST.PS_APPS_DEV`)

## Step 1: Configure your Snowflake CLI connection

If you haven't already, add your connection:

```bash
snow connection add
```

Or verify your existing connection:

```bash
snow connection test -c VCVDCXW-YD26998
```

## Step 2: Set the target database/schema

Make sure you're targeting the right database and schema. You can either:

**Option A** — Set defaults in your connection config (`~/.snowflake/config.toml`):
```toml
[connections.VCVDCXW-YD26998]
account = "VCVDCXW-YD26998"
user = "DZANOELLOMIGRACION"
authenticator = "externalbrowser"
database = "PST"
schema = "PS_APPS_DEV"
warehouse = "COMPUTE_WH"
role = "ACCOUNTADMIN"
```

**Option B** — Pass flags on each command:
```bash
snow streamlit deploy --database PST --schema PS_APPS_DEV --connection VCVDCXW-YD26998
```

## Step 3: Deploy the app

From the project root directory:

```bash
cd /Users/deborazanoello/Desktop/sfc-gh-sd_learn/sfc-certifications/snowprocore

snow streamlit deploy -c VCVDCXW-YD26998
```

This will:
- Upload `streamlit_app.py` as the main file
- Upload all files listed in `snowflake.yml` (pages, i18n, questions, review notes, labs)
- Create or replace the `SNOWFLAKE_LEARNING_HUB` Streamlit app in your target schema

## Step 4: Open the app

After deployment, open in Snowsight:

```bash
snow streamlit get-url SNOWFLAKE_LEARNING_HUB -c VCVDCXW-YD26998
```

Or navigate manually in Snowsight:
1. Go to **Snowsight** → **Streamlit** (left sidebar)
2. Find **SNOWFLAKE_LEARNING_HUB**
3. Click to open

## Redeploying after changes

Whenever you update review notes, questions, or code:

```bash
snow streamlit deploy -c VCVDCXW-YD26998
```

This replaces the existing app with the updated files.

## Troubleshooting

### "File not found" errors
- SiS flattens the directory structure. If your app uses `os.path.dirname(__file__)` for relative paths, those should work as-is since all files are uploaded relative to the main file.

### "Package not available" errors
- The `environment.yml` only lists `streamlit`. All other imports (`json`, `os`, `re`, `random`, etc.) are Python standard library and don't need to be listed.

### Warehouse not running
- Make sure `COMPUTE_WH` is resumed: `ALTER WAREHOUSE COMPUTE_WH RESUME;`

### Permission errors
- Ensure your role has `CREATE STREAMLIT` on the target schema
- `ACCOUNTADMIN` has this by default

## Files created for deployment

| File | Purpose |
|------|---------|
| `snowflake.yml` | Snowflake CLI project definition — lists all files to upload |
| `environment.yml` | Python environment — only `streamlit` needed (rest is stdlib) |
