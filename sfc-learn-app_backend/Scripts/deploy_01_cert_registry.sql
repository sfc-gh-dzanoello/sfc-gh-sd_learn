-- CERT_REGISTRY data

TRUNCATE TABLE IF EXISTS PST.PS_APPS_DEV.CERT_REGISTRY;

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'core', 'SnowPro Core', 'COF-C03',
  'SnowPro Core (COF-C03)', 'core', '#29B5E8',
  'linear-gradient(135deg,#0E4D71,#0B3D5B)', '#B2EBF2',
  '#E0F7FA', '#80DEEA',
  'intermediate', TRUE,
  PARSE_JSON('{"questions": 100, "time": "115 min", "cost": "$175", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "100 Qs | 115 min | $175", "pt": "100 Qs | 115 min | $175", "es": "100 Qs | 115 min | $175"}'),
  'certifications/sfc-gh-sd-snowprocore/core_questions.json'
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'architect', 'Architect', 'ARA-C01',
  'SnowPro Architect (ARA-C01)', 'advanced', '#1565C0',
  'linear-gradient(135deg,#1565C0,#0D47A1)', '#BBDEFB',
  '#E3F2FD', '#90CAF9',
  'advanced', TRUE,
  PARSE_JSON('{"questions": 65, "time": "115 min", "cost": "$375", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "65 Qs | 115 min | $375", "pt": "65 Qs | 115 min | $375", "es": "65 Qs | 115 min | $375"}'),
  'certifications/sfc-gh-sd-advanced/architect_domains/architect_questions.json'
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'data_engineer', 'Data Engineer', 'DEA-C01',
  'SnowPro Data Engineer (DEA-C01)', 'advanced', '#FF9800',
  'linear-gradient(135deg,#E65100,#BF360C)', '#FFE0B2',
  '#FFF3E0', '#FFCC80',
  'advanced', TRUE,
  PARSE_JSON('{"questions": 100, "time": "115 min", "cost": "$175", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "Advanced certification for Data Engineers building and optimizing data pipelines in Snowflake.", "pt": "Certificacao avancada para Engenheiros de Dados que constroem e otimizam pipelines de dados no Snowflake.", "es": "Certificacion avanzada para Ingenieros de Datos que construyen y optimizan pipelines de datos en Snowflake."}'),
  'certifications/sfc-gh-sd-advanced/data_engineer_domains/data_engineer_questions.json'
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'gen_ai', 'Gen AI', 'AIG-C01',
  'SnowPro Specialty: Gen AI', 'specialist', '#AB47BC',
  'linear-gradient(135deg,#6A1B9A,#4A148C)', '#E1BEE7',
  '#F3E5F5', '#CE93D8',
  'specialist', TRUE,
  PARSE_JSON('{"questions": 65, "time": "115 min", "cost": "$175", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "65 Qs | 115 min | $175 | Prereq: Core or Associate", "pt": "65 Qs | 115 min | $175 | Pré-req: Core ou Associate", "es": "65 Qs | 115 min | $175 | Prereq: Core o Associate"}'),
  'certifications/sfc-gh-sd-specialist/sfc-gh-sd-gen_ai/ges_c01/gen_ai_questions.json'
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'data_admin', 'Data Administrator', 'DAD-C01',
  'SnowPro Data Administrator (DAD-C01)', 'advanced', '#00897B',
  'linear-gradient(135deg,#00695C,#004D40)', '#B2DFDB',
  '#E0F2F1', '#80CBC4',
  'advanced', FALSE,
  PARSE_JSON('{"questions": 65, "time": "115 min", "cost": "$375", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "Coming soon", "pt": "Em breve", "es": "Proximamente"}'),
  NULL
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'data_science', 'Data Science', 'DSA-C01',
  'SnowPro Data Science (DSA-C01)', 'advanced', '#E91E63',
  'linear-gradient(135deg,#C2185B,#880E4F)', '#F8BBD0',
  '#FCE4EC', '#F48FB1',
  'advanced', FALSE,
  PARSE_JSON('{"questions": 65, "time": "115 min", "cost": "$375", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "Coming soon", "pt": "Em breve", "es": "Proximamente"}'),
  NULL
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'security_engineer', 'Security Engineer', 'SEA-C01',
  'SnowPro Security Engineer (SEA-C01)', 'advanced', '#F44336',
  'linear-gradient(135deg,#D32F2F,#B71C1C)', '#FFCDD2',
  '#FFEBEE', '#EF9A9A',
  'advanced', FALSE,
  PARSE_JSON('{"questions": 65, "time": "115 min", "cost": "$375", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "Coming soon", "pt": "Em breve", "es": "Proximamente"}'),
  NULL
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'data_analyst', 'Data Analyst', 'DAN-C01',
  'SnowPro Data Analyst (DAN-C01)', 'advanced', '#5C6BC0',
  'linear-gradient(135deg,#3949AB,#283593)', '#C5CAE9',
  '#E8EAF6', '#9FA8DA',
  'advanced', FALSE,
  PARSE_JSON('{"questions": 65, "time": "115 min", "cost": "$375", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "Coming soon", "pt": "Em breve", "es": "Proximamente"}'),
  NULL
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'snowpark', 'Snowpark', 'SPA-C01',
  'SnowPro Specialty: Snowpark (SPA-C01)', 'specialist', '#43A047',
  'linear-gradient(135deg,#2E7D32,#1B5E20)', '#C8E6C9',
  '#E8F5E9', '#A5D6A7',
  'specialist', FALSE,
  PARSE_JSON('{"questions": 65, "time": "115 min", "cost": "$175", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "Coming soon", "pt": "Em breve", "es": "Proximamente"}'),
  NULL
);

INSERT INTO PST.PS_APPS_DEV.CERT_REGISTRY
(CERT_KEY, NAME, CODE, FULL_NAME, CATEGORY, COLOR,
 SIDEBAR_GRADIENT, SIDEBAR_ACCENT, SIDEBAR_TEXT, SIDEBAR_SUB,
 DIFFICULTY, AVAILABLE, EXAM_INFO, DISPLAY_INFO, QUESTIONS_FILE)
VALUES (
  'native_app', 'Native App', 'NAP-C01',
  'SnowPro Specialty: Native App (NAP-C01)', 'specialist', '#FF7043',
  'linear-gradient(135deg,#E64A19,#BF360C)', '#FFCCBC',
  '#FBE9E7', '#FFAB91',
  'specialist', FALSE,
  PARSE_JSON('{"questions": 65, "time": "115 min", "cost": "$175", "pass_score": "750/1000"}'), PARSE_JSON('{"en": "Coming soon", "pt": "Em breve", "es": "Proximamente"}'),
  NULL
);
