-- Run this in Snowsight on Snowhouse with a role that has CREATE TABLE on PST.PS_APPS_DEV
-- This table stores per-user data (progress, notes) for the Streamlit app

USE DATABASE PST;
USE SCHEMA PS_APPS_DEV;

CREATE TABLE IF NOT EXISTS USER_APP_DATA (
    USER_NAME VARCHAR DEFAULT CURRENT_USER(),
    DATA_KEY VARCHAR,
    DATA_VALUE VARIANT,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (USER_NAME, DATA_KEY)
);

-- Grant access so the Streamlit app can read/write
-- Replace YOUR_APP_ROLE with the role the Streamlit app runs as
-- GRANT SELECT, INSERT, UPDATE ON TABLE USER_APP_DATA TO ROLE YOUR_APP_ROLE;
