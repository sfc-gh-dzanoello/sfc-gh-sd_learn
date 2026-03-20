-- =============================================================================
-- Snowflake PS Platform -- Table DDL
-- Creates all application data tables in the current schema.
-- Run this in Snowsight with a role that has CREATE TABLE on PST.PS_APPS_DEV.
-- =============================================================================

-- 1. Certification Registry
--    One row per certification (core, architect, gen_ai, etc.)
CREATE TABLE IF NOT EXISTS CERT_REGISTRY (
    CERT_KEY        VARCHAR(50)   NOT NULL PRIMARY KEY,
    NAME            VARCHAR(100)  NOT NULL,
    CODE            VARCHAR(20),
    FULL_NAME       VARCHAR(200),
    CATEGORY        VARCHAR(20),       -- core | advanced | specialist
    COLOR           VARCHAR(10),
    SIDEBAR_GRADIENT VARCHAR(200),
    SIDEBAR_ACCENT  VARCHAR(10),
    SIDEBAR_TEXT    VARCHAR(10),
    SIDEBAR_SUB     VARCHAR(10),
    DIFFICULTY      VARCHAR(20),
    AVAILABLE       BOOLEAN DEFAULT FALSE,
    EXAM_INFO       VARIANT,           -- {questions, time, cost, pass_score}
    DISPLAY_INFO    VARIANT,           -- {en, pt, es} info strings
    QUESTIONS_FILE  VARCHAR(200),      -- legacy reference, nullable
    UPDATED_AT      TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- 2. Certification Domains
--    One row per domain per certification
CREATE TABLE IF NOT EXISTS CERT_DOMAINS (
    CERT_KEY        VARCHAR(50)   NOT NULL,
    DOMAIN_NAME     VARCHAR(200)  NOT NULL,
    DOMAIN_DIR      VARCHAR(300),      -- file path (legacy, nullable after migration)
    COLOR           VARCHAR(10),
    CSS_NUM         VARCHAR(10),
    WEIGHT          VARCHAR(30),
    SORT_ORDER      INTEGER DEFAULT 0,
    UPDATED_AT      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (CERT_KEY, DOMAIN_NAME)
);

-- 3. Domain Tips
--    One row per tip per domain
CREATE TABLE IF NOT EXISTS CERT_DOMAIN_TIPS (
    CERT_KEY        VARCHAR(50)   NOT NULL,
    DOMAIN_NAME     VARCHAR(200)  NOT NULL,
    TIP_ORDER       INTEGER       NOT NULL,
    TIP_TEXT        VARCHAR(2000) NOT NULL,
    PRIMARY KEY (CERT_KEY, DOMAIN_NAME, TIP_ORDER)
);

-- 4. Certification Questions
--    One row per question. Supports multi-select and explanations.
CREATE TABLE IF NOT EXISTS CERT_QUESTIONS (
    QUESTION_ID     VARCHAR(100)  NOT NULL PRIMARY KEY,
    CERT_KEY        VARCHAR(50)   NOT NULL,
    SOURCE          VARCHAR(100),
    DOMAIN          VARCHAR(200),
    QUESTION_TEXT   VARCHAR(5000) NOT NULL,
    OPTIONS         VARIANT       NOT NULL,  -- [{text, is_correct}]
    CORRECT_INDICES VARIANT       NOT NULL,  -- [0, 2] etc.
    EXPLANATION     VARCHAR(5000),
    DIFFICULTY      VARCHAR(20),
    UPDATED_AT      TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- 5. Review Notes
--    One row per domain + language. Content is the full markdown text.
CREATE TABLE IF NOT EXISTS CERT_REVIEW_NOTES (
    CERT_KEY        VARCHAR(50)   NOT NULL,
    DOMAIN_NAME     VARCHAR(200)  NOT NULL,
    LANG            VARCHAR(5)    NOT NULL,  -- en | pt | es
    CONTENT         VARCHAR(16777216),       -- full markdown (up to 16MB)
    UPDATED_AT      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (CERT_KEY, DOMAIN_NAME, LANG)
);

-- 6. i18n Strings
--    One row per UI string key with translations.
CREATE TABLE IF NOT EXISTS APP_I18N (
    STRING_KEY      VARCHAR(100)  NOT NULL PRIMARY KEY,
    EN              VARCHAR(2000),
    PT              VARCHAR(2000),
    ES              VARCHAR(2000),
    UPDATED_AT      TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- 7. Learning Tracks
--    One row per track with metadata. Topics list as VARIANT.
CREATE TABLE IF NOT EXISTS LEARN_TRACKS (
    TRACK_KEY       VARCHAR(50)   NOT NULL PRIMARY KEY,
    NAME            VARIANT       NOT NULL,  -- {en, pt, es}
    DESCRIPTION     VARIANT,                 -- {en, pt, es}
    COLOR           VARCHAR(10),
    EMOJI           VARCHAR(10),
    DIFFICULTY      VARCHAR(20),
    TOPICS          VARIANT,                 -- ["openflow", "dynamic_tables", ...]
    UPDATED_AT      TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- 8. Learning Topic Content
--    One row per topic per track. Full content as VARIANT.
CREATE TABLE IF NOT EXISTS LEARN_CONTENT (
    TRACK_KEY       VARCHAR(50)   NOT NULL,
    TOPIC_KEY       VARCHAR(50)   NOT NULL,
    TOPIC_DATA      VARIANT       NOT NULL,  -- full topic JSON (notes, questions, labs, flashcards)
    UPDATED_AT      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (TRACK_KEY, TOPIC_KEY)
);

-- 9. Miscellaneous App Content
--    For standalone content like exam_strategy_partners.md
CREATE TABLE IF NOT EXISTS APP_CONTENT (
    CONTENT_KEY     VARCHAR(100)  NOT NULL,
    LANG            VARCHAR(5)    NOT NULL DEFAULT 'en',
    CONTENT         VARCHAR(16777216),
    UPDATED_AT      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (CONTENT_KEY, LANG)
);

-- 10. User App Data (already exists via persistence.py auto-create)
--     Included here for completeness. Safe to re-run.
CREATE TABLE IF NOT EXISTS USER_APP_DATA (
    USER_NAME       VARCHAR       DEFAULT CURRENT_USER(),
    DATA_KEY        VARCHAR       NOT NULL,
    DATA_VALUE      VARIANT,
    UPDATED_AT      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (USER_NAME, DATA_KEY)
);
