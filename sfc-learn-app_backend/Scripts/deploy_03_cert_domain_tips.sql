-- CERT_DOMAIN_TIPS data

TRUNCATE TABLE IF EXISTS PST.PS_APPS_DEV.CERT_DOMAIN_TIPS;

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 1: Architecture', 1, 'B-M-M: Browser -> Brain (Cloud Services) -> Muscle (Compute) -> Memory (Storage)');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 1: Architecture', 2, 'Micro-partitions: columnar, compressed, immutable, 50-500MB. You CANNOT control their size.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 1: Architecture', 3, 'Cloud Services = brain. Handles auth, optimizer, metadata, transactions. Billed only if >10% of daily warehouse credits.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 1: Architecture', 4, 'Caching order: Result cache (24h, free) -> Local disk (warehouse SSD) -> Remote disk (storage layer).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 1: Architecture', 5, 'Snowpark runs in COMPUTE layer, NOT Cloud Services. UDFs and stored procs also run in compute.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 1: Architecture', 6, 'Editions ladder: Standard -> Enterprise -> Business Critical -> VPS. Each adds features, never removes.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 2: Account & Governance', 1, 'Role hierarchy: ACCOUNTADMIN > SECURITYADMIN > USERADMIN + SYSADMIN. ACCOUNTADMIN = SECURITYADMIN + SYSADMIN.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 2: Account & Governance', 2, 'SECURITYADMIN owns MANAGE GRANTS. USERADMIN creates users/roles. SYSADMIN owns warehouses/databases.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 2: Account & Governance', 3, 'Masking policies: ONE policy per column. Enterprise Edition+ required. Attached via ALTER TABLE.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 2: Account & Governance', 4, 'ACCOUNT_USAGE: 45min-3h latency, 365 days retention. INFORMATION_SCHEMA: real-time, 7 days to 6 months retention.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 2: Account & Governance', 5, 'Resource monitors track CREDIT usage, not query count. Can set at ACCOUNT or WAREHOUSE level.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 2: Account & Governance', 6, 'Network policies: ALLOWED_IP_LIST (whitelist) + BLOCKED_IP_LIST (blacklist). Most restrictive wins.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 3: Data Loading', 1, 'Stage types: User (@~), Table (@%table), Named internal (@stage), Named external (@ext_stage).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 3: Data Loading', 2, 'PUT command = INTERNAL stages ONLY. For external stages, upload to cloud storage directly.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 3: Data Loading', 3, 'COPY INTO = bulk batch. Snowpipe = continuous micro-batch (serverless, event-driven).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 3: Data Loading', 4, 'Snowpipe uses Cloud Services compute, NOT a warehouse. Billed per-file.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 3: Data Loading', 5, 'File formats mnemonic: CAJ-OPX (CSV, Avro, JSON, ORC, Parquet, XML).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 3: Data Loading', 6, 'VALIDATION_MODE: checks data WITHOUT loading. RETURN_ERRORS | RETURN_N_ROWS | RETURN_ALL_ERRORS.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 4: Performance & Querying', 1, 'Cache check order: Result cache (free, 24h) -> Local disk (warehouse SSD) -> Remote disk (storage).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 4: Performance & Querying', 2, 'Spilling = warehouse too small -> queries spill to local disk, then remote. Solution: scale UP.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 4: Performance & Querying', 3, 'Queuing = not enough clusters -> queries wait. Solution: scale OUT (multi-cluster).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 4: Performance & Querying', 4, 'Economy scaling = save credits (SOS). Standard scaling = reduce latency (QAS). Know which to pick!');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 4: Performance & Querying', 5, 'Pruning uses micro-partition min/max metadata. ORDER BY on filter columns -> better pruning.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 4: Performance & Querying', 6, 'FLATTEN converts VARIANT/ARRAY/OBJECT -> rows. Usually paired with LATERAL in FROM clause.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 5: Collaboration', 1, 'Shares are READ-ONLY. Consumer cannot modify. Provider pays storage, consumer pays compute.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 5: Collaboration', 2, 'Reader accounts: provider creates AND pays for compute. For consumers without Snowflake.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 5: Collaboration', 3, 'Secure views hide query definition. REQUIRED for shares -- regular views expose the SQL.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 5: Collaboration', 4, 'Time Travel: 0-1 day (Standard), 0-90 days (Enterprise). Then 7 days Fail-safe (Snowflake only).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 5: Collaboration', 5, 'Cloning = zero-copy = metadata-only at creation. Privileges are NOT cloned.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('core', 'Domain 5: Collaboration', 6, 'Data Clean Rooms: secure multi-party analysis without exposing raw data to each other.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 1, 'Tri-Secret Secure: customer-managed key + Snowflake key + composite master key. Business Critical+.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 2, 'Network policies apply at ACCOUNT or USER level. CIDR notation required.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 3, 'SCIM = automated user provisioning. Supports Azure AD, Okta. SECURITYADMIN role required.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 4, 'Private Link: AWS PrivateLink / Azure Private Link. No data over public internet.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 1.0: Accounts and Security', 5, 'Key pair authentication: 2048-bit RSA minimum. Can have 2 active keys for rotation.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 1, 'Global Services layer handles account replication, failover, database replication across regions.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 2, 'Hybrid tables: transactional + analytical. Row-store index for low-latency OLTP lookups.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 3, 'Snowgrid: cross-cloud, cross-region data sharing and replication framework.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 4, 'Replication groups: bundle databases, shares, and other objects for coordinated failover.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 5, 'Client redirect: automatic client failover between primary and secondary connections.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 6, 'Cross-region sharing requires database replication first -- cannot share directly across regions.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 7, 'Auto-Fulfillment handles cross-cloud Marketplace delivery automatically. Manual replication for direct shares.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 8, 'Data Clean Rooms: secure multi-party analysis without exposing raw data.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 9, 'Reader accounts: provider pays EVERYTHING (storage + compute). Read-only access.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 2.0: Snowflake Architecture', 10, 'Secure views REQUIRED for sharing -- regular views expose the SQL definition.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 3.0: Data Engineering', 1, 'Dynamic Tables: declarative pipelines. Set TARGET_LAG, Snowflake auto-refreshes. Replaces streams+tasks.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 3.0: Data Engineering', 2, 'Streams + Tasks: CDC pattern. Stream captures changes, Task runs on schedule or trigger.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 3.0: Data Engineering', 3, 'Snowpipe Streaming: Java/Python SDK, sub-second latency. No staging files needed.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 3.0: Data Engineering', 4, 'Apache Iceberg tables: open format, Snowflake-managed or externally managed catalog.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 3.0: Data Engineering', 5, 'Data sharing + Marketplace: zero-copy, live data. Provider pays storage, consumer pays compute.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 1, 'Query Profile: focus on TableScan (pruning), Sort (spilling), Aggregate (grouping).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 2, 'Search Optimization Service: point lookups, substring search, geo functions. Enterprise+.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 3, 'Materialized Views: auto-refreshed, automatic query rewrite. Enterprise+. Best for heavy aggregations.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 4, 'Clustering keys: large tables (multi-TB), frequently filtered columns. Check SYSTEM$CLUSTERING_INFORMATION.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 4.0: Performance Optimization', 5, 'Multi-cluster warehouse: Standard policy (perf) vs Economy policy (cost). Auto-scale 1-10 clusters.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 1, 'Shares are READ-ONLY. Consumer cannot modify. Provider pays storage, consumer pays compute.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 2, 'Secure views REQUIRED for sharing -- regular views expose the SQL definition to consumers.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 3, 'Reader accounts: provider creates AND pays for compute. For consumers without Snowflake accounts.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 4, 'Cross-region sharing requires database replication first -- cannot share directly across regions.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 5, 'Data Clean Rooms: secure multi-party analysis without exposing raw data to each other.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 5.0: Sharing & Collaboration', 6, 'Native Apps (Application Packages): distribute code + data as installable packages via Marketplace.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 1, 'Zero-copy clones for dev/staging/prod environments. Cloned tasks are suspended by default.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 2, 'SPCS (Snowpark Container Services): run Docker containers in Snowflake compute. GPU support.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 3, 'Snowpark: DataFrame API in Python/Java/Scala. Runs in Snowflake compute, not client-side.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 4, 'CI/CD: use SnowCLI or Terraform for infrastructure-as-code. SchemaChange for migration scripts.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 5, 'Environment isolation: separate databases or accounts per environment. Use managed access schemas.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('architect', 'Domain 6.0: DevOps & Ecosystem', 6, 'Raw -> Transform -> Consumption zone pattern for data pipeline architecture.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 1.0: Data Movement', 1, 'COPY INTO = bulk batch. Snowpipe = continuous serverless. Snowpipe Streaming = sub-second via SDK.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 1.0: Data Movement', 2, 'Snowpipe uses Snowflake-managed serverless compute, NOT your warehouse. Billed per-second.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 1.0: Data Movement', 3, 'AUTO_INGEST requires cloud event notifications: S3 SQS, GCS Pub/Sub, or Azure Event Grid.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 1.0: Data Movement', 4, 'Load metadata stored 64 days. After that, same files can reload without FORCE = TRUE.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 1.0: Data Movement', 5, 'Storage Integration decouples cloud credentials from stage definitions. Uses IAM roles.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 1.0: Data Movement', 6, 'Schema Evolution (ENABLE_SCHEMA_EVOLUTION) only ADDS columns. Never modifies or drops existing ones.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 2.0: Performance Optimization', 1, 'Cache order: Result cache (24h, free) -> Local disk (warehouse SSD) -> Remote disk (storage layer).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 2.0: Performance Optimization', 2, 'Spilling = warehouse too small -> scale UP. Queuing = not enough clusters -> scale OUT.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 2.0: Performance Optimization', 3, 'Clustering keys: best for large tables (multi-TB) with frequent range/equality filters on specific columns.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 2.0: Performance Optimization', 4, 'Search Optimization Service: point lookups, substring search, geo functions. Enterprise+ required.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 2.0: Performance Optimization', 5, 'Query Acceleration Service: offloads portions of eligible queries to shared compute. Good for outlier queries.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 2.0: Performance Optimization', 6, 'Resource monitors track CREDIT usage. Can notify or suspend at account or warehouse level.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 3.0: Storage and Data Protection', 1, 'Time Travel: 0-1 day Standard, 0-90 days Enterprise. Then 7-day Fail-safe (Snowflake only, not queryable).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 3.0: Storage and Data Protection', 2, 'Transient tables: 0-1 day Time Travel, NO Fail-safe. Temporary tables: same, session-scoped.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 3.0: Storage and Data Protection', 3, 'Cloning = zero-copy at creation (metadata only). New writes use separate storage. Privileges NOT cloned.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 3.0: Storage and Data Protection', 4, 'UNDROP works within Time Travel retention. Order matters: most recently dropped restored first.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 3.0: Storage and Data Protection', 5, 'Micro-partitions: columnar, compressed, immutable, 50-500MB. You cannot control their size directly.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 4.0: Data Governance', 1, 'RBAC: privileges granted to roles, roles granted to users. DAC: object owner controls access.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 4.0: Data Governance', 2, 'Masking policies: ONE per column. Enterprise+ required. Attached via ALTER TABLE ... SET MASKING POLICY.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 4.0: Data Governance', 3, 'Row Access Policies: ONE per table/view. Controls which rows users see based on context functions.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 4.0: Data Governance', 4, 'Object tagging: key-value metadata for classification. Tag-based masking = masking policy attached to a tag.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 4.0: Data Governance', 5, 'ACCOUNTADMIN = top role. SECURITYADMIN manages grants. USERADMIN creates users/roles. SYSADMIN owns objects.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 5.0: Data Transformation', 1, 'Streams capture DML changes (inserts, updates, deletes). SYSTEM$STREAM_HAS_DATA() checks for new data.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 5.0: Data Transformation', 2, 'Tasks run on schedule (CRON or interval) or via AFTER triggers (task trees/DAGs).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 5.0: Data Transformation', 3, 'Dynamic Tables: declarative pipelines with TARGET_LAG. Snowflake auto-refreshes. Replaces streams+tasks for many use cases.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 5.0: Data Transformation', 4, 'UDFs return values inline in queries. Stored procedures execute procedural logic and can use SQL, JavaScript, Python, Java.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 5.0: Data Transformation', 5, 'FLATTEN + LATERAL: expand semi-structured arrays/objects into rows. Essential for JSON/VARIANT processing.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('data_engineer', 'Domain 5.0: Data Transformation', 6, 'Snowpark DataFrame API: Python/Java/Scala. Executes in Snowflake compute, not client-side.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 1: Snowflake for Gen AI Overview', 1, 'Cortex suite: COMPLETE, Cortex Search, Cortex Analyst, Cortex Fine-tuning, Cortex Agents (Preview).');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 1: Snowflake for Gen AI Overview', 2, 'CORTEX_MODELS_ALLOWLIST: account parameter to restrict which LLM models users can call.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 1: Snowflake for Gen AI Overview', 3, 'Interfaces: SQL, REST API, Cortex LLM Playground (Preview). Know when to use each.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 1: Snowflake for Gen AI Overview', 4, 'Bring your own models via Model Registry (custom model logging) or Hugging Face on SPCS.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 1: Snowflake for Gen AI Overview', 5, 'Vector types: VECTOR_COSINE_SIMILARITY, VECTOR_L2_DISTANCE, VECTOR_INNER_PRODUCT, VECTOR_L1_DISTANCE.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 1: Snowflake for Gen AI Overview', 6, 'Cross-region inference: CORTEX_ENABLED_CROSS_REGION parameter. Consider latency vs availability tradeoffs.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 2: Snowflake Gen AI & LLM Functions', 1, 'COMPLETE = general LLM. Task-specific: CLASSIFY_TEXT, EXTRACT_ANSWER, SENTIMENT, SUMMARIZE, TRANSLATE.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 2: Snowflake Gen AI & LLM Functions', 2, 'TRY_COMPLETE: returns NULL on failure instead of aborting query. COUNT_TOKENS: varies by model tokenizer.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 2: Snowflake Gen AI & LLM Functions', 3, 'SPLIT_TEXT_RECURSIVE_CHARACTER: chunk text for embedding. Overlapping chunks preserve context.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 2: Snowflake Gen AI & LLM Functions', 4, 'Cortex Analyst: text-to-SQL via semantic model (YAML in stage or semantic views). VQR = Verified Query Repository.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 2: Snowflake Gen AI & LLM Functions', 5, 'Chat: multi-turn architecture needs conversation memory. Build with Streamlit + COMPLETE.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 2: Snowflake Gen AI & LLM Functions', 6, 'SPCS for third-party models: Docker image → image repository → compute pool → service. Model Registry for logging/calling.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 2: Snowflake Gen AI & LLM Functions', 7, 'Cortex Search: hybrid search (semantic + keyword). ATTRIBUTES = metadata for filtering, not searchable content.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 3: Snowflake Gen AI Governance', 1, 'Cortex Guard: filter harmful/unsafe LLM responses. Reduce hallucination with RAG grounding.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 3: Snowflake Gen AI Governance', 2, 'Cost views: CORTEX_FUNCTIONS_USAGE_HISTORY, CORTEX_FUNCTIONS_QUERY_USAGE_HISTORY, METERING_DAILY_HISTORY.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 3: Snowflake Gen AI Governance', 3, 'CORTEX_SEARCH_DAILY_USAGE_HISTORY: three cost types — warehouse, EMBED_TEXT, serving.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 3: Snowflake Gen AI Governance', 4, 'AI Observability (Preview): evaluation metrics, tracing, logging via event tables. Trulens SDK integration.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 3: Snowflake Gen AI Governance', 5, 'Minimize costs: choose smaller models when possible, reduce token count, use task-specific functions over COMPLETE.');

INSERT INTO PST.PS_APPS_DEV.CERT_DOMAIN_TIPS
(CERT_KEY, DOMAIN_NAME, TIP_ORDER, TIP_TEXT)
VALUES ('gen_ai', 'Domain 3: Snowflake Gen AI Governance', 6, 'REST API auth: key pair, OAuth. Data never leaves Snowflake boundary when using Cortex functions.');
