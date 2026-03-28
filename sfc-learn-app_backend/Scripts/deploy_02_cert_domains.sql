-- CERT_DOMAINS data

TRUNCATE TABLE IF EXISTS PST.PS_APPS_DEV.CERT_DOMAINS;

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('core', 'Domain 1: Architecture', 'certifications/sfc-gh-sd-snowprocore/domain_01_architecture',
  '#29B5E8', '1',
  '25-30%', 1);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('core', 'Domain 2: Account & Governance', 'certifications/sfc-gh-sd-snowprocore/domain_02_account_governance',
  '#FF6B6B', '2',
  '20-25%', 2);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('core', 'Domain 3: Data Loading', 'certifications/sfc-gh-sd-snowprocore/domain_03_data_loading',
  '#4ECB71', '3',
  '10-15%', 3);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('core', 'Domain 4: Performance & Querying', 'certifications/sfc-gh-sd-snowprocore/domain_04_performance_querying',
  '#FFD93D', '4',
  '15-20%', 4);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('core', 'Domain 5: Collaboration', 'certifications/sfc-gh-sd-snowprocore/domain_05_collaboration',
  '#C084FC', '5',
  '10-15%', 5);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 'certifications/sfc-gh-sd-advanced/architect_domains/architect/architect_2/domain_01_accounts_and_security',
  '#29B5E8', '1',
  '25%', 1);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 'certifications/sfc-gh-sd-advanced/architect_domains/architect/architect_2/domain_02_snowflake_architecture',
  '#FF6B6B', '2',
  '30%', 2);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('architect', 'Domain 3.0: Data Engineering', 'certifications/sfc-gh-sd-advanced/architect_domains/architect/architect_2/domain_03_data_engineering',
  '#4ECB71', '3',
  '25%', 3);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 'certifications/sfc-gh-sd-advanced/architect_domains/architect/architect_2/domain_04_performance_optimization',
  '#FFD93D', '4',
  '20%', 4);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 'certifications/sfc-gh-sd-advanced/architect_domains/architect/architect_2/domain_05_sharing_collaboration',
  '#C084FC', '5',
  'included', 5);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 'certifications/sfc-gh-sd-advanced/architect_domains/architect/architect_2/domain_06_devops_ecosystem',
  '#FF7043', '6',
  'included', 6);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('data_engineer', 'Domain 1.0: Data Movement', 'certifications/sfc-gh-sd-advanced/data_engineer_domains/domain_01_data_movement',
  '#1565C0', '1',
  '28%', 1);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('data_engineer', 'Domain 2.0: Performance Optimization', 'certifications/sfc-gh-sd-advanced/data_engineer_domains/domain_02_performance_optimization',
  '#00838F', '2',
  '19%', 2);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('data_engineer', 'Domain 3.0: Storage and Data Protection', 'certifications/sfc-gh-sd-advanced/data_engineer_domains/domain_03_storage_data_protection',
  '#2E7D32', '3',
  '14%', 3);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('data_engineer', 'Domain 4.0: Data Governance', 'certifications/sfc-gh-sd-advanced/data_engineer_domains/domain_04_data_governance',
  '#6A1B9A', '4',
  '14%', 4);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('data_engineer', 'Domain 5.0: Data Transformation', 'certifications/sfc-gh-sd-advanced/data_engineer_domains/domain_05_data_transformation',
  '#E65100', '5',
  '25%', 5);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('gen_ai', 'Domain 1: Snowflake for Gen AI Overview', 'certifications/sfc-gh-sd-specialist/sfc-gh-sd-gen_ai/ges_c01/domain_01_gen_ai_overview',
  '#AB47BC', '1',
  '30%', 1);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('gen_ai', 'Domain 2: Snowflake Gen AI & LLM Functions', 'certifications/sfc-gh-sd-specialist/sfc-gh-sd-gen_ai/ges_c01/domain_02_gen_ai_llm_functions',
  '#7E57C2', '2',
  '44%', 2);

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAINS
(CERT_KEY, DOMAIN_NAME, DOMAIN_DIR, COLOR, CSS_NUM, WEIGHT, SORT_ORDER)
VALUES ('gen_ai', 'Domain 3: Snowflake Gen AI Governance', 'certifications/sfc-gh-sd-specialist/sfc-gh-sd-gen_ai/ges_c01/domain_03_gen_ai_governance',
  '#5C6BC0', '3',
  '26%', 3);
