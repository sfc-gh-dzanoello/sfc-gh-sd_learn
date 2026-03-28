-- Deploy all study hub content to PST.PS_APPS_DEV
-- Run each file in order using: snow sql -f <file> -c VCVDCXW-YD26998
-- Or execute via Cortex Code / Snowsight

-- Step 1: Registry
-- snow sql -f Scripts/deploy_01_cert_registry.sql -c VCVDCXW-YD26998

-- Step 2: Domains
-- snow sql -f Scripts/deploy_02_cert_domains.sql -c VCVDCXW-YD26998

-- Step 3: Domain Tips
-- snow sql -f Scripts/deploy_03_cert_domain_tips.sql -c VCVDCXW-YD26998

-- Step 4: Questions (architect)
-- snow sql -f Scripts/deploy_04_cert_questions_architect.sql -c VCVDCXW-YD26998

-- Step 5: Review Notes (architect)
-- snow sql -f Scripts/deploy_05_cert_review_notes_architect.sql -c VCVDCXW-YD26998
