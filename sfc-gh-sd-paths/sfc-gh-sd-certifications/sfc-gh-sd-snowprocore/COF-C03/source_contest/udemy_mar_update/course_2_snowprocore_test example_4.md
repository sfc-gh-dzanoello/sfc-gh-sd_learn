Question 1
Incorrect
A retail company wants to use 'Private Link'. Which layer of the Snowflake architecture does this primarily protect?
Your answer is incorrect
Storage Layer.
Explanation
No.
Correct answer
Cloud Services / Connectivity Layer.
Explanation
Correct. Secures the entry point to the Snowflake account.
Micro-partitions.
Explanation
No.
Compute Layer.
Explanation
No.
Overall explanation
Private Link ensures that the 'front door' of your Snowflake account is only accessible via private network routing. Ref: https://docs.snowflake.com/en/user-guide/admin-security-privatelink
Domain
Security
Question 2
Skipped
Which of the following are 'Semi-structured' data types? (Select 2)
TIMESTAMP.
Explanation
Incorrect.
Correct selection
VARIANT.
Explanation
Correct.
FLOAT.
Explanation
Incorrect.
Correct selection
ARRAY.
Explanation
Correct.
Overall explanation
VARIANT, ARRAY, and OBJECT are the core semi-structured types. Ref: https://docs.snowflake.com/en/sql-reference/data-types-semistructured
Domain
Storage and Protection
Question 3
Skipped
What is the effect of the command: ALTER USER my_user SET MINS_TO_BYPASS_NETWORK_POLICY = 60;?
It forces the user to change their password every 60 minutes.
Explanation
No.
It limits the user's session to 60 minutes.
Explanation
No.
Correct answer
It allows the user to log in from any IP for 60 minutes after the policy is applied.
Explanation
Correct. Used to prevent lockouts during configuration.
It deletes the user's network policy.
Explanation
No.
Overall explanation
This parameter is a safety valve to ensure administrators don't accidentally lock themselves out. Ref: https://docs.snowflake.com/en/sql-reference/sql/alter-user
Domain
Security
Question 4
Skipped
Which of the following can trigger a 'Task' to run? (Select 2)
A user logging in.
Explanation
Incorrect.
A file being uploaded to S3.
Explanation
Incorrect (that triggers Snowpipe).
Correct selection
A specific schedule (e.g., every 5 minutes).
Explanation
Correct.
Correct selection
The completion of another task.
Explanation
Correct. Creating a DAG (Directed Acyclic Graph).
Overall explanation
Tasks are either time-driven or dependency-driven within a workflow. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 5
Skipped
Which of the following are TRUE about 'External Tables'? (Select 2)
Correct selection
They store data outside of Snowflake (e.g., in S3).
Explanation
Correct. They point to files in a cloud stage.
They support 90 days of Time Travel.
Explanation
Incorrect. They have no Time Travel.
Correct selection
They are read-only.
Explanation
Correct. You cannot perform DML (Insert/Update) on them.
They are faster than internal tables.
Explanation
Incorrect.
Overall explanation
External tables are great for querying data lakes directly but are less performant than internal tables. Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro
Domain
Data Movement
Question 6
Skipped
Which role is required to create a 'Resource Monitor'?
USERADMIN.
Explanation
No.
SYSADMIN.
Explanation
No.
SECURITYADMIN.
Explanation
No.
Correct answer
ACCOUNTADMIN.
Explanation
Correct. (Can also be granted to other roles).
Overall explanation
Resource monitors control billing and are thus restricted to top-level admins. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 7
Skipped
What is the impact of setting 'AUTO_RESUME = TRUE' on a Virtual Warehouse?
Correct answer
It automatically starts the warehouse when a query is submitted to it.
Explanation
Correct. Ensures high availability without manual intervention.
It prevents the warehouse from ever suspending.
Explanation
No.
It starts the warehouse every day at 8 AM.
Explanation
No.
It resizes the warehouse when it gets busy.
Explanation
No.
Overall explanation
Auto-resume ensures that compute resources are available the moment a user or task needs them. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 8
Skipped
Which of the following is a benefit of 'Snowpark'?
It is only for Java.
Explanation
No.
Correct answer
It allows developers to use familiar programming constructs like DataFrames.
Explanation
Correct.
It makes data public.
Explanation
No.
It allows writing SQL.
Explanation
No.
Overall explanation
Snowpark bridges the gap between data engineering and application development. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 9
Skipped
What is the benefit of 'Zero-copy Cloning' for testing?
It encrypts the test data.
Explanation
No.
It speeds up queries.
Explanation
No.
Correct answer
It allows testing on production-like data without storage costs.
Explanation
Correct. Very fast and cost-effective.
It creates a full copy of the data.
Explanation
No.
Overall explanation
Cloning is the most popular way to create 'Sandboxes' for developers. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 10
Skipped
Which of the following is NOT a valid 'Scaling Policy'?
Economy.
Explanation
Valid.
Standard is the default.
Explanation
No.
Standard.
Explanation
Valid.
Correct answer
Balanced.
Explanation
Correct. (This is NOT a Snowflake policy).
Overall explanation
There are only two policies: Standard and Economy. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 11
Skipped
Which command is used to upload a file from a local folder to a Snowflake internal stage?
UPLOAD
Explanation
Not a valid Snowflake command.
COPY INTO
Explanation
Loads from stage to table.
GET
Explanation
Downloads from cloud to local.
Correct answer
PUT
Explanation
Correct. The standard command for local-to-cloud transfer.
Overall explanation
The PUT command is part of the SnowSQL tool and other drivers for file staging. Ref: https://docs.snowflake.com/en/sql-reference/sql/put
Domain
Data Movement
Question 12
Skipped
A user with the role 'ANALYST' cannot see data in a table, even though they have SELECT privileges. What is the most likely reason?
The user is using the wrong driver.
Explanation
No.
The warehouse is suspended.
Explanation
No, they would still see metadata.
The table is empty.
Explanation
They would see headers.
Correct answer
The user does not have USAGE privilege on the parent Database and Schema.
Explanation
Correct. Privilege inheritance is required.
Overall explanation
In Snowflake's RBAC, you must have USAGE on all container objects to access a leaf object. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 13
Skipped
Which of the following are TRUE about 'Materialized Views'? (Select 3)
Correct selection
They incur storage costs for the results.
Explanation
Correct.
They can be created on any view.
Explanation
Incorrect. Only on base tables.
Correct selection
They can improve the performance of queries that use a small subset of a large table.
Explanation
Correct.
Correct selection
They incur compute costs for the background update service.
Explanation
Correct.
They require manual refreshes by the user.
Explanation
Incorrect. Snowflake maintains them.
Overall explanation
Materialized views are a trade-off: higher cost for faster performance on specific patterns. Ref: https://docs.snowflake.com/en/user-guide/views-materialized
Domain
Performance and Warehouses
Question 14
Skipped
Which of the following is TRUE about 'Stored Procedures' in Snowflake?
They can only be called from a SELECT statement.
Explanation
No, they are called with CALL.
They cannot use variables.
Explanation
No.
They must always return a value.
Explanation
No.
Correct answer
They can perform DDL and DML operations.
Explanation
Correct. Unlike functions, they are designed for administrative tasks.
Overall explanation
Stored Procedures are the 'scripts' of Snowflake, capable of modifying the environment and data. Ref: https://docs.snowflake.com/en/sql-reference/stored-procedures-usage
Domain
Account and Data Sharing
Question 15
Skipped
Which command is used to check the progress of a currently running data load (COPY INTO)?
SELECT * FROM table_history.
Explanation
No.
SHOW LOADS.
Explanation
No.
Correct answer
Check the 'Query History' tab in the UI.
Explanation
Correct. Shows rows loaded and status in real-time.
LIST @stage.
Explanation
Shows files, not load progress.
Overall explanation
The Query History provides the most granular view of any active operation in Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/functions/query_history
Domain
Data Movement
Question 16
Skipped
Which of the following are TRUE about 'Materialized Views' in Snowflake? (Select 2)
Correct selection
They consume credits for maintenance.
Explanation
Correct. Uses a serverless background service.
Correct selection
They are automatically maintained by Snowflake.
Explanation
Correct. Background process updates them when base tables change.
They always improve performance for any query.
Explanation
Incorrect. Only for specific query patterns.
They can be created on top of other Materialized Views.
Explanation
Incorrect.
Overall explanation
Materialized views are useful for pre-aggregating data but come with background maintenance costs. Ref: https://docs.snowflake.com/en/user-guide/views-materialized
Domain
Performance and Warehouses
Question 17
Skipped
Which command is used to download a file from a stage to your computer?
PUT.
Explanation
Uploads.
COPY OUT.
Explanation
No.
DOWNLOAD.
Explanation
No.
Correct answer
GET.
Explanation
Correct.
Overall explanation
GET is the reverse of PUT and is used for data export. Ref: https://docs.snowflake.com/en/sql-reference/sql/get
Domain
Data Movement
Question 18
Skipped
Which of the following are valid 'Trust Relationships' for an API Integration in Snowflake? (Select 2)
Correct selection
Azure Service Principal.
Explanation
Correct. Used for Azure integrations.
A Google Personal Account.
Explanation
Incorrect. Needs a Service Account/Identity.
Snowflake Password.
Explanation
Incorrect.
Correct selection
AWS IAM Role.
Explanation
Correct. Used for AWS integrations.
Overall explanation
API Integrations rely on cloud-native identity services for secure communication. Ref: https://docs.snowflake.com/en/sql-reference/sql/create-api-integration
Domain
Security
Question 19
Skipped
Which of the following describes 'Zero-copy Cloning' correctly?
Correct answer
It creates a new set of metadata pointing to the same micro-partitions.
Explanation
Correct. Instant and cost-free initially.
It is only available for tables, not databases.
Explanation
No.
It requires a running warehouse.
Explanation
No, it is a metadata operation.
It copies the data to a new storage location.
Explanation
No.
Overall explanation
Cloning is efficient because it shares the underlying immutable data blocks until they are modified. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 20
Skipped
Which component of the Snowflake architecture ensures 'Data Durability' across multiple availability zones?
Cloud Services Layer.
Explanation
No.
Virtual Warehouse.
Explanation
No.
Correct answer
Storage Layer.
Explanation
Correct. Data is replicated automatically by the cloud provider.
Compute Layer.
Explanation
No.
Overall explanation
Snowflake leverages the underlying cloud storage (S3, etc.) which is natively durable across zones. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 21
Skipped
In the Snowflake 'Information Schema', which view shows the total size of all tables in a schema?
Correct answer
TABLES.
Explanation
Correct. Contains the 'BYTES' column for each table.
TABLE_STORAGE_METRICS.
Explanation
This is in Account Usage.
STORAGE_USAGE.
Explanation
No.
SCHEMATA.
Explanation
No.
Overall explanation
The Information Schema provides a real-time snapshot of the objects in the current database. Ref: https://docs.snowflake.com/en/sql-reference/info-schema/tables
Domain
Account and Data Sharing
Question 22
Skipped
What is the effect of 'ALTER WAREHOUSE my_wh SUSPEND;'?
It deletes the warehouse.
Explanation
No.
It resizes the warehouse to 0.
Explanation
No.
It hides the warehouse.
Explanation
No.
Correct answer
It immediately stops the warehouse from running and consuming credits.
Explanation
Correct. (Wait for queries to finish depends on parameters).
Overall explanation
Suspending warehouses when not in use is the #1 way to save credits. Ref: https://docs.snowflake.com/en/sql-reference/sql/alter-warehouse
Domain
Performance and Warehouses
Question 23
Skipped
What is the purpose of the 'GET_PRESIGNED_URL' function?
To create a new stage.
Explanation
No.
To login to Snowflake.
Explanation
No.
To encrypt a file.
Explanation
No.
Correct answer
To provide a temporary, public URL to download a file from a stage.
Explanation
Correct. No Snowflake credentials required for the link.
Overall explanation
Pre-signed URLs are perfect for sharing data files with external users or applications securely. Ref: https://docs.snowflake.com/en/sql-reference/functions/get_presigned_url
Domain
Data Movement
Question 24
Skipped
What is the function of the 'Object Tagging' feature in data governance? (Select 2)
Correct selection
To automatically mask columns based on a tag (Tag-based masking).
Explanation
Correct. A powerful automation for security.
To speed up queries on tagged tables.
Explanation
No.
Correct selection
To group objects for easier discovery.
Explanation
Correct.
To reduce storage costs.
Explanation
No.
Overall explanation
Tags provide the metadata foundation for advanced policies like masking and row-level security. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 25
Skipped
A retail company wants to share data with a company in a DIFFERENT cloud region. Which feature should they use?
Reader Account.
Explanation
Still limited to the provider's region.
Correct answer
Account Replication followed by Sharing.
Explanation
Correct. Data must be replicated to the consumer's region first.
Direct Sharing.
Explanation
Only works in the same region.
Private Link.
Explanation
Security feature, not sharing.
Overall explanation
Snowflake Data Sharing is region-bound; cross-region sharing requires the provider to replicate the data first. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 26
Skipped
Which function is used to 'flatten' a JSON array into multiple rows?
PARSER()
Explanation
No.
UNNEST()
Explanation
No.
Correct answer
FLATTEN()
Explanation
Correct. Often used with LATERAL JOIN.
SPLIT()
Explanation
No.
Overall explanation
FLATTEN is the primary tool for relationalizing semi-structured data. Ref: https://docs.snowflake.com/en/sql-reference/functions/flatten
Domain
Storage and Protection
Question 27
Skipped
Which of the following are TRUE regarding 'Snowflake Stored Procedures'? (Select 2)
They must return a table.
Explanation
Incorrect. They can return a single value or nothing.
They are always faster than SQL queries.
Explanation
Incorrect.
Correct selection
They are called using the CALL command.
Explanation
Correct.
Correct selection
They can be used to automate administrative tasks.
Explanation
Correct. They have 'owner' rights to perform DDL.
Overall explanation
Stored procedures are designed for procedural logic and administrative automation. Ref: https://docs.snowflake.com/en/sql-reference/stored-procedures-usage
Domain
Account and Data Sharing
Question 28
Skipped
A retail company wants to use 'Object Tagging'. Which role is needed to create a Tag?
USERADMIN
Explanation
No.
PUBLIC
Explanation
No.
Correct answer
A role with the CREATE TAG privilege.
Explanation
Correct. Typically granted to a security or governance role.
SYSADMIN only.
Explanation
No.
Overall explanation
Access to tagging is controlled via standard Snowflake RBAC privileges. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 29
Skipped
In Snowflake, what is a 'Reader Account'?
An account for reading documentation.
Explanation
No.
An account that can only see metadata.
Explanation
No.
Correct answer
A cost-free account created by a provider for a consumer to query shared data.
Explanation
Correct. The provider pays for the consumer's compute.
A developer account.
Explanation
No.
Overall explanation
Reader accounts are the solution for sharing data with partners who do not yet use Snowflake. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 30
Skipped
Which of the following are characteristics of 'SCIM' in Snowflake? (Select 2)
It replaces the need for MFA.
Explanation
Incorrect.
It is used to move data between regions.
Explanation
Incorrect.
Correct selection
It stands for System for Cross-domain Identity Management.
Explanation
Correct.
Correct selection
It allows for automatic provisioning of users from Okta or Azure AD.
Explanation
Correct. Syncs identities automatically.
Overall explanation
SCIM is the bridge that keeps your Snowflake users in sync with your corporate directory. Ref: https://docs.snowflake.com/en/user-guide/scim-intro
Domain
Security
Question 31
Skipped
What is the 'Fail-safe' duration for 'Transient' tables?
90 days.
Explanation
No.
Correct answer
0 days.
Explanation
Correct. (Transient tables do NOT have Fail-safe).
1 day.
Explanation
No.
7 days.
Explanation
No.
Overall explanation
Transient tables are cheaper because they skip the 7-day Fail-safe storage cost. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 32
Skipped
Which function can be used to recover a table that was accidentally dropped 10 minutes ago?
SELECT * FROM RECYCLE_BIN
Explanation
No.
GET_DROPPED_TABLE
Explanation
No.
RESTORE TABLE
Explanation
No.
Correct answer
UNDROP TABLE
Explanation
Correct. Leveraging Time Travel metadata.
Overall explanation
UNDROP is a metadata operation that restores a dropped object instantly if it is within the Time Travel window. Ref: https://docs.snowflake.com/en/sql-reference/sql/undrop-table
Domain
Storage and Protection
Question 33
Skipped
Which scaling policy in a Multi-cluster Warehouse will 'Shut down clusters as soon as possible' to save credits?
Balanced
Explanation
Not a policy.
Correct answer
Economy
Explanation
Correct. Prioritizes credit saving by consolidating load.
Aggressive
Explanation
Not a policy.
Standard
Explanation
Incorrect.
Overall explanation
Economy mode is designed to keep clusters as full as possible and spin them down quickly. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 34
Skipped
Which of the following can be used to monitor credit consumption? (Select 2)
Search Optimization Service.
Explanation
Incorrect. This consumes credits, doesn't monitor them.
Correct selection
The ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY view.
Explanation
Correct. For historical auditing.
Correct selection
Resource Monitors.
Explanation
Correct. Can set quotas and alerts.
The Information Schema.
Explanation
Incorrect. (Does not have warehouse metering).
Overall explanation
Snowflake provides both real-time governance (Resource Monitors) and deep audit logs (Account Usage). Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 35
Skipped
Which of the following are components of the 'Cloud Services' layer? (Select 3)
Compute Nodes.
Explanation
Incorrect.
Correct selection
Security Manager.
Explanation
Correct.
Correct selection
Metadata Manager.
Explanation
Correct.
Correct selection
Query Optimizer.
Explanation
Correct.
Data Storage.
Explanation
Incorrect.
Overall explanation
Cloud Services is the 'Always-on' management layer. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 36
Skipped
What is the main benefit of 'Micro-partitioning'?
Correct answer
It enables fine-grained 'pruning' during queries.
Explanation
Correct. Only necessary data is read.
It encrypts data at rest.
Explanation
No.
It prevents data sharing.
Explanation
No.
It allows users to manually sort data.
Explanation
No.
Overall explanation
Micro-partitioning is the core technology that makes Snowflake's 'zero-tuning' performance possible. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 37
Skipped
Which of the following is TRUE about 'Multi-cluster Warehouses'?
They are only in Standard Edition.
Explanation
No.
Correct answer
They improve concurrency for many users.
Explanation
Correct. (Horizontal scaling).
They improve the speed of a single query.
Explanation
No (Vertical scaling does).
They are free.
Explanation
No.
Overall explanation
Multi-cluster warehouses prevent 'queuing' when many people query at once. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 38
Skipped
What is the maximum number of days for 'Time Travel' in 'Standard' edition?
0.
Explanation
No.
7.
Explanation
No.
90.
Explanation
No.
Correct answer
1.
Explanation
Correct. (Standard is limited to 1 day).
Overall explanation
Edition selection is critical for data retention strategy. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 39
Skipped
Which of the following are 'Stage' types in Snowflake? (Select 3)
Database Stage
Explanation
Incorrect.
Correct selection
User Stage
Explanation
Correct (@~).
Correct selection
Named Stage
Explanation
Correct (@).
Account Stage
Explanation
Incorrect.
Correct selection
Table Stage
Explanation
Correct (@%).
Overall explanation
Snowflake provides different stage 'scopes' depending on who needs to access the files. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 40
Skipped
Which of the following are 'Stored Procedure' languages supported by Snowflake? (Select 3)
Correct selection
SQL
Explanation
Correct. Using Snowflake Scripting.
Ruby
Explanation
Incorrect.
Correct selection
JavaScript
Explanation
Correct. The original procedural language in Snowflake.
C++
Explanation
Incorrect.
Correct selection
Python
Explanation
Correct. Via the Snowpark framework.
Overall explanation
Snowflake has expanded its procedural support to include modern languages like Python and Java. Ref: https://docs.snowflake.com/en/sql-reference/stored-procedures-usage
Domain
Account and Data Sharing
Question 41
Skipped
Which command would you use to find out why a Snowpipe is not loading files?
SHOW PIPES.
Explanation
Shows configuration, not health.
LIST @my_stage.
Explanation
Shows files, not pipe status.
SELECT * FROM table_history.
Explanation
No.
Correct answer
SELECT SYSTEM$PIPE_STATUS('my_pipe').
Explanation
Correct. Returns real-time execution and error state.
Overall explanation
SYSTEM$PIPE_STATUS is the first step in troubleshooting automated ingestion. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_pipe_status
Domain
Data Movement
Question 42
Skipped
Which command is used to 'remove' a file from an internal stage?
PURGE @stage.
Explanation
Incorrect (though PURGE is an option in COPY).
DELETE FROM @stage.
Explanation
Incorrect.
DROP FILE @stage.
Explanation
Incorrect.
Correct answer
REMOVE @stage/file_name.
Explanation
Correct. Cleans up staged files.
Overall explanation
Proper maintenance includes removing files from stages after they have been successfully loaded. Ref: https://docs.snowflake.com/en/sql-reference/sql/remove
Domain
Data Movement
Question 43
Skipped
Which of the following can be used to 'Secure' a Snowflake account? (Select 3)
Zero-copy Cloning.
Explanation
Incorrect. Performance/Dev feature.
Correct selection
MFA.
Explanation
Correct. Second factor of authentication.
Correct selection
Single Sign-On (SSO).
Explanation
Correct. Centralized identity management.
Clustering.
Explanation
Incorrect.
Correct selection
Network Policies.
Explanation
Correct. Restricts IP access.
Overall explanation
Snowflake provides a multi-layered security model from network to identity. Ref: https://docs.snowflake.com/en/user-guide/admin-security
Domain
Security
Question 44
Skipped
Which of the following statements about 'Fail-safe' are TRUE? (Select 2)
It applies to Temporary and Transient tables.
Explanation
Incorrect. Only Permanent tables have Fail-safe.
Correct selection
It starts immediately after the Time Travel period ends.
Explanation
Correct. It is the final stage of the data lifecycle.
Users can query Fail-safe data using the AT keyword.
Explanation
Incorrect. Users cannot access Fail-safe data directly.
Correct selection
It is a 7-day period for data recovery by Snowflake Support.
Explanation
Correct. Non-configurable disaster recovery window.
Overall explanation
Storage and Protection
Question 45
Skipped
Which of the following are 'Account-level' objects in Snowflake? (Select 3)
Tables
Explanation
Incorrect. Database-level.
Correct selection
Roles
Explanation
Correct. Global to the account.
Correct selection
Warehouses
Explanation
Correct. Global to the account.
Correct selection
Users
Explanation
Correct. Global to the account.
Schemas
Explanation
Incorrect. Database-level.
Overall explanation
Account-level objects are shared across all databases within that specific Snowflake account. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Account and Data Sharing
Question 46
Skipped
Which of the following are 'Serverless' features in Snowflake? (Select 3)
Correct selection
Automatic Re-clustering.
Explanation
Correct.
Correct selection
Snowpipe.
Explanation
Correct.
External Tables.
Explanation
Incorrect.
Virtual Warehouse queries.
Explanation
Incorrect. User-managed.
Correct selection
Materialized View Maintenance.
Explanation
Correct.
Overall explanation
Serverless features are managed by Snowflake and billed separately from virtual warehouses. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 47
Skipped
Which function is used to convert a JSON string into a 'Variant'?
Correct answer
PARSE_JSON
Explanation
Correct. Essential for semi-structured processing.
GET_JSON
Explanation
No.
CONVERT_JSON
Explanation
No.
TO_JSON
Explanation
No.
Overall explanation
PARSE_JSON validates the string and prepares it for dot-notation querying. Ref: https://docs.snowflake.com/en/sql-reference/functions/parse_json
Domain
Storage and Protection
Question 48
Skipped
A retail company wants to analyze logs in S3. Which feature allows them to 'see' the files as a table without moving them?
Correct answer
External Tables.
Explanation
Correct. Virtualized table over cloud files.
Internal Stages.
Explanation
Used for storage.
Snowpipe.
Explanation
Loads them.
Secure Views.
Explanation
Logic over tables.
Overall explanation
External tables provide a SQL interface for data lakes without the ingestion cost. Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro
Domain
Data Movement
Question 49
Skipped
What is the purpose of 'Row Access Policies'?
To limit the number of rows returned by a query.
Explanation
No.
To mask specific columns like credit cards.
Explanation
No, that is Masking Policies.
Correct answer
To restrict which rows a user can see based on their role or attributes.
Explanation
Correct. Implements row-level security.
To delete rows automatically.
Explanation
No.
Overall explanation
Row Access Policies act as a filter that is automatically applied to every query on a table. Ref: https://docs.snowflake.com/en/user-guide/security-row-intro
Domain
Security
Question 50
Skipped
Which of the following is TRUE about 'Dynamic Data Masking' policies?
Correct answer
They are applied to a specific column.
Explanation
Correct. (Then users see masked or unmasked data).
They are applied to a table.
Explanation
No.
They are applied to a user.
Explanation
No.
They are applied to a database.
Explanation
No.
Overall explanation
Column-level security is a pillar of Snowflake governance. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 51
Skipped
A retail company wants to use 'Key Pair Authentication' with a 'Service Account'. Which command associates the public key with the user?
ALTER USER set password = '...'.
Explanation
No.
Correct answer
ALTER USER set RSA_PUBLIC_KEY = '...'.
Explanation
Correct. Stores the key in the user's metadata.
GRANT KEY TO USER.
Explanation
No.
CREATE KEY PAIR...
Explanation
No.
Overall explanation
Key pair authentication is the standard for secure, automated service-to-service communication. Ref: https://docs.snowflake.com/en/user-guide/key-pair-auth
Question 52
Skipped
What is the 'Result Cache' retention period for a query that hasn't been run again?
Unlimited.
Explanation
No.
Correct answer
24 hours.
Explanation
Correct. After 24 hours the cache expires.
1 hour.
Explanation
No.
7 days.
Explanation
No.
Overall explanation
The 24-hour window is reset every time the exact same query is run again. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 53
Skipped
Which of the following are TRUE about 'External Functions'? (Select 2)
They can only return strings.
Explanation
Incorrect.
They are stored in internal stages.
Explanation
Incorrect.
Correct selection
They require an API Integration object.
Explanation
Correct. For security.
Correct selection
They allow Snowflake to call APIs outside of the platform.
Explanation
Correct.
Overall explanation
External functions extend Snowflake's capabilities to include external machine learning or custom logic. Ref: https://docs.snowflake.com/en/user-guide/external-functions-intro
Domain
Account and Data Sharing
Question 54
Skipped
What is 'Clustering Depth'?
The number of columns in a clustering key.
Explanation
No.
The storage size of a partition.
Explanation
No.
The number of rows in a partition.
Explanation
No.
Correct answer
A metric that represents how well a table is clustered.
Explanation
Correct. Lower depth means better clustering/pruning.
Overall explanation
Clustering depth of 1.0 is ideal. High depth indicates overlapping partitions and poor pruning. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions
Domain
Performance and Warehouses
Question 55
Skipped
What is 'Pruning' in Snowflake?
Resizing a warehouse.
Explanation
No.
Deleting old data.
Explanation
No.
Masking data.
Explanation
No.
Correct answer
The process of skipping micro-partitions that do not match the query filters.
Explanation
Correct. Essential for performance.
Overall explanation
Pruning reduces the I/O needed to answer a query. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Performance and Warehouses
Question 56
Skipped
What is the default 'Time Travel' period for a 'Permanent' table in the 'Standard' edition?
90 days.
Explanation
Requires Enterprise+.
0 days.
Explanation
No.
Correct answer
1 day.
Explanation
Correct. Standard edition is limited to 1 day for all tables.
7 days.
Explanation
No.
Overall explanation
Standard edition offers baseline protection; Enterprise is required for extended history. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 57
Skipped
Which of the following describes 'Automatic Re-clustering'?
It is only available for Temporary tables.
Explanation
No.
It is free.
Explanation
No.
It is a manual process.
Explanation
No.
Correct answer
It is a serverless background service that maintains table clustering.
Explanation
Correct.
Overall explanation
Re-clustering is vital for large tables that are frequently updated. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 58
Skipped
What is the maximum number of clusters a 'Multi-cluster Warehouse' can have?
20
Explanation
No.
5
Explanation
Standard default.
Unlimited
Explanation
No.
Correct answer
10
Explanation
Correct. This is the typical maximum limit.
Overall explanation
While 10 is the standard UI limit, larger limits can sometimes be requested from support. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 59
Skipped
When using 'Dynamic Data Masking', what happens if a user with a masked role performs a CREATE TABLE AS SELECT (CTAS) on masked data?
Snowflake will automatically unmask the data for the new table.
Explanation
Incorrect.
Correct answer
The new table will contain the masked values (e.g., '****').
Explanation
Correct. This prevents data leakage.
The new table will contain the original, unmasked values.
Explanation
Incorrect.
The operation will fail with a security error.
Explanation
Incorrect.
Overall explanation
Snowflake ensures that if you can only see masked data, you can only 'write' masked data to new objects. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 60
Skipped
Which function allows you to see the exact SQL text of a query executed 10 days ago?
LAST_QUERY_ID
Explanation
Only for the current session.
Correct answer
QUERY_HISTORY
Explanation
Correct. Available in Information Schema (7 days) or Account Usage (365 days).
TABLE_HISTORY
Explanation
No.
TASK_HISTORY
Explanation
Only for tasks.
Overall explanation
QUERY_HISTORY is the primary audit trail for all SQL activity in the account. Ref: https://docs.snowflake.com/en/sql-reference/functions/query_history
Domain
Account and Data Sharing
Question 61
Skipped
When a Warehouse is resized from Small to Medium, what happens to the currently running queries?
Correct answer
They continue to run on the Small configuration until they finish.
Explanation
Correct. The new size only affects new queries.
The warehouse waits for them to finish before resizing.
Explanation
No.
They are automatically moved to the Medium configuration.
Explanation
No.
They are cancelled.
Explanation
No.
Overall explanation
Resizing is transparent; current queries finish on existing hardware, and new queries start on the new, larger hardware. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Question 62
Skipped
What is 'Result Reuse'?
When a warehouse is restarted.
Explanation
No.
Correct answer
When a user runs the same query twice and Snowflake uses the cached result.
Explanation
Correct. Saves time and credits.
When a result is shared via Email.
Explanation
No.
When a user copies a table.
Explanation
No.
Overall explanation
Result reuse is a 'free' performance boost provided by the Cloud Services layer. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 63
Skipped
Which of the following is TRUE about 'Secure UDFs'?
They do not require a warehouse to run.
Explanation
No.
They can only be written in Python.
Explanation
No.
Correct answer
They prevent users from seeing the internal logic using SHOW FUNCTIONS.
Explanation
Correct. Protecting intellectual property.
They are always faster than standard UDFs.
Explanation
No.
Overall explanation
Secure UDFs (and views) are essential for sharing logic without revealing the underlying data structures. Ref: https://docs.snowflake.com/en/user-guide/views-secure
Domain
Account and Data Sharing
Question 64
Skipped
Which of the following are TRUE about 'Dynamic Data Masking'? (Select 2)
It masks data in the storage layer.
Explanation
Incorrect. Data is stored unmasked.
Correct selection
It masks data at the time of the query.
Explanation
Correct. Logic is applied as results are generated.
Correct selection
It depends on the Role of the user querying the data.
Explanation
Correct. Different roles see different masking.
It can only be used on Numeric columns.
Explanation
Incorrect. Supports all types.
Overall explanation
Masking is a 'presentation-layer' security feature that doesn't affect the physical data. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 65
Skipped
Which of the following is a TRUE statement about 'Fail-safe'?
It is only for Business Critical accounts.
Explanation
No.
Correct answer
It is a 7-day period during which only Snowflake Support can recover data.
Explanation
Correct.
It replaces Time Travel.
Explanation
No.
Users can manage it.
Explanation
No.
Overall explanation
Fail-safe is the 'last resort' for data recovery. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 66
Skipped
What is the maximum retention for 'Time Travel' in a 'Permanent' table in the 'Enterprise' edition?
365 days.
Explanation
No.
Correct answer
90 days.
Explanation
Correct. Requires Enterprise or higher.
1 day.
Explanation
No.
7 days.
Explanation
No.
Overall explanation
Enterprise Edition allows for historical analysis up to 90 days back. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 67
Skipped
What is the maximum retention period for 'Time Travel' in a 'Transient' table?
Unlimited.
Explanation
No.
90 days.
Explanation
No.
Correct answer
1 day.
Explanation
Correct. Transient tables are limited to 0 or 1 day.
0 days.
Explanation
No.
Overall explanation
Transient tables trade off extended protection for reduced storage costs (no Fail-safe). Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 68
Skipped
In the context of 'Information Schema', where are the views located?
Correct answer
In every database within a schema called INFORMATION_SCHEMA.
Explanation
Correct. Real-time and scoped to that DB.
In the PUBLIC schema.
Explanation
No.
In the SNOWFLAKE database.
Explanation
No, that is Account Usage.
In the SYSTEM schema.
Explanation
No.
Overall explanation
Information Schema is the SQL standard for real-time metadata discovery within a database. Ref: https://docs.snowflake.com/en/sql-reference/info-schema
Domain
Account and Data Sharing
Question 69
Skipped
What is the maximum file size recommended for optimal parallel loading in Snowflake?
5 GB.
Explanation
Too large, limits parallelism.
1 GB to 2 GB.
Explanation
No.
10 MB to 50 MB.
Explanation
Too small, creates too many files.
Correct answer
100 MB to 250 MB compressed.
Explanation
Correct. This allows Snowflake to distribute the work effectively.
Overall explanation
Sizing files correctly is a key part of optimizing data ingestion performance. Ref: https://docs.snowflake.com/en/user-guide/data-load-considerations-prepare
Domain
Data Movement
Question 70
Skipped
What happens to the 'Result Cache' if the Virtual Warehouse used to execute the original query is deleted?
The cache is moved to another warehouse.
Explanation
No.
The cache is only valid for 1 hour.
Explanation
No.
The cache is deleted.
Explanation
No.
Correct answer
The cache remains available for 24 hours.
Explanation
Correct. It is stored in the Cloud Services layer, independent of compute.
Overall explanation
The Result Cache's persistence is one of Snowflake's most efficient cost-saving features. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 71
Skipped
Which of the following are valid 'Privileges' that can be granted on a Schema? (Select 3)
Correct selection
MODIFY
Explanation
Correct. Allows altering schema properties.
Correct selection
USAGE
Explanation
Correct. Allows seeing the schema.
SELECT
Explanation
Incorrect. This is a table-level privilege.
Correct selection
CREATE STAGE
Explanation
Correct.
Correct selection
CREATE TABLE
Explanation
Correct. Allows creating new tables.
Overall explanation
Schema privileges control what objects can be created and if the schema itself is accessible. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Security
Question 72
Skipped
Which of the following are TRUE about 'Micro-partitions'? (Select 2)
Correct selection
They are immutable.
Explanation
Correct. They are never changed; new ones are written.
Correct selection
They store data in a columnar format.
Explanation
Correct. Optimization for analytics.
They are 1 TB in size.
Explanation
Incorrect (50-500 MB).
They are managed by the user.
Explanation
Incorrect.
Overall explanation
Immutability is what allows for Time Travel and Cloning. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 73
Skipped
How can you determine which micro-partitions contain a specific value without scanning the entire table?
Correct answer
By using a Search Optimization Service.
Explanation
Correct. It uses metadata to point to specific partitions.
By using a Temporary Table.
Explanation
No.
By using a Secure View.
Explanation
No.
By running SELECT *.
Explanation
No.
Overall explanation
The SOS service acts as a 'super-index' for point lookups on large datasets. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 74
Skipped
Which component handles the 'Query Result Cache'?
Correct answer
The Cloud Services Layer.
Explanation
Correct. It persists results globally for 24 hours.
The Storage Layer.
Explanation
No.
The Local Node SSD.
Explanation
No.
The Compute Layer.
Explanation
No.
Overall explanation
Because Cloud Services is 'always on', it can serve cached results without waking up a warehouse. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Snowflake Architecture
Question 75
Skipped
In a 'Data Share', can a consumer see the 'Query Profile' of the provider's execution?
Yes, always.
Explanation
No.
Yes, if they are an ACCOUNTADMIN.
Explanation
No.
Only if the provider explicitly grants it.
Explanation
No.
Correct answer
No, the Query Profile is only visible to the account that executed the query.
Explanation
Correct. Important for security and privacy.
Overall explanation
Metadata about query execution stays within the account that pays for and runs the warehouse. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 76
Skipped
In the context of 'Snowpipe', what is the purpose of the 'STRIP_OUTER_ARRAY' file format option?
To compress the file.
Explanation
No.
Correct answer
To remove the enclosing [ ] brackets from a JSON file and load records individually.
Explanation
Correct. Required if the JSON is an array of objects.
To delete the file from the stage after loading.
Explanation
No.
To remove the headers from a CSV file.
Explanation
No.
Overall explanation
This option allows Snowflake to treat each element of a top-level JSON array as a separate row. Ref: https://docs.snowflake.com/en/sql-reference/sql/create-file-format
Domain
Data Movement
Question 77
Skipped
In the context of 'Snowpark', what does the 'df.select()' method return?
A list of values.
Explanation
No.
Correct answer
A new DataFrame with the specified columns.
Explanation
Correct. It is a transformation.
The count of rows.
Explanation
No.
A JSON string.
Explanation
No.
Overall explanation
Almost every method in the Snowpark DataFrame API returns a new DataFrame object. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 78
Skipped
Which of the following are supported file formats for semi-structured data ingestion? (Select 3)
Correct selection
Avro
Explanation
Correct. Binary serialization format.
Correct selection
Parquet
Explanation
Correct. Columnar format.
Correct selection
XML
Explanation
Correct. Supported via the VARIANT data type.
MP3
Explanation
Incorrect. Unstructured data is not natively parsed.
PNG
Explanation
Incorrect.
Overall explanation
Snowflake natively parses JSON, Avro, ORC, Parquet, and XML into VARIANT columns. Ref: https://docs.snowflake.com/en/user-guide/data-load-prepare
Domain
Data Movement
Question 79
Skipped
Which of the following is NOT a Snowflake 'Edition'?
Correct answer
Premier Plus.
Explanation
Correct. (This is NOT an edition).
Standard.
Explanation
Valid.
Business Critical.
Explanation
Valid.
Enterprise.
Explanation
Valid.
Overall explanation
Snowflake has 4 main editions: Standard, Enterprise, Business Critical, and VPS. Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Account and Data Sharing
Question 80
Skipped
What is the purpose of the 'SYSTEM$GLOBAL_NAMES_DICT' function?
To check the status of cross-region replication names.
Explanation
Incorrect.
Correct answer
None of the above.
Explanation
Correct. (This is a distractor/made-up function).
To list all databases.
Explanation
No.
To provide a dictionary of reserved words in Snowflake.
Explanation
Incorrect.
Overall explanation
Be wary of functions that look official but don't exist in the documentation.
Domain
Performance and Warehouses
Question 81
Skipped
Which of the following can be used to authenticate with SnowSQL? (Select 3)
Correct selection
Key Pair.
Explanation
Correct.
Correct selection
Username and Password.
Explanation
Correct.
Social Media login.
Explanation
Incorrect.
Correct selection
SSO.
Explanation
Correct.
Biometric.
Explanation
Incorrect.
Overall explanation
SnowSQL supports a wide range of enterprise authentication methods. Ref: https://docs.snowflake.com/en/user-guide/snowsql-config
Domain
Security
Question 82
Skipped
Which function is used to see the credit usage of 'Snowpipe'?
SNOWPIPE_STATS.
Explanation
No.
Correct answer
PIPE_USAGE_HISTORY.
Explanation
Correct.
WAREHOUSE_METERING_HISTORY.
Explanation
No.
CREDIT_USAGE.
Explanation
No.
Overall explanation
Snowpipe is a serverless feature and its usage is tracked in its own history view. Ref: https://docs.snowflake.com/en/sql-reference/functions/pipe_usage_history
Domain
Data Movement
Question 83
Skipped
Which of the following are TRUE regarding 'Snowflake Data Exchange'? (Select 2)
It only allows sharing of CSV files.
Explanation
Incorrect. Shares live data.
Correct selection
It is a private marketplace for a specific group of invited members.
Explanation
Correct. Restricted visibility.
Correct selection
It is managed by a 'Provider' who controls the membership.
Explanation
Correct. Allows for governance within a consortium.
It is accessible to every Snowflake customer globally.
Explanation
Incorrect. That is the Marketplace.
Overall explanation
Data Exchanges allow organizations to build their own curated data ecosystems. Ref: https://docs.snowflake.com/en/user-guide/data-exchange-intro
Domain
Account and Data Sharing
Question 84
Skipped
Which of the following is TRUE about 'Clustering Keys'?
Correct answer
They are most effective on tables with many terabytes of data.
Explanation
Correct. Helps with massive scans.
They are free to maintain.
Explanation
No.
They should be defined on every table.
Explanation
No.
They replace the need for micro-partitions.
Explanation
No.
Overall explanation
Clustering keys should be used selectively on tables where pruning is naturally poor. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 85
Skipped
Which of the following are components of the Cloud Services layer in Snowflake? (Select 3)
Data storage in micro-partitions
Explanation
Incorrect. This is the Storage Layer.
Correct selection
Query optimization
Explanation
Correct. Analyzes and optimizes SQL plans.
Correct selection
Metadata management
Explanation
Correct. Stores partition and statistical data.
Local SSD caching
Explanation
Incorrect. This is part of Compute nodes.
Virtual Warehouse execution
Explanation
Incorrect. This is the Compute Layer.
Correct selection
Access control and security
Explanation
Correct. Manages authentication and RBAC.
Overall explanation
The Cloud Services layer is the 'brain' of Snowflake, managing everything except raw data storage and heavy compute. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 86
Skipped
Which of the following are 'Actions' in a Snowpark DataFrame? (Select 2)
.select()
Explanation
Incorrect (Transformation).
Correct selection
.count()
Explanation
Correct.
.filter()
Explanation
Incorrect (Transformation).
Correct selection
.collect()
Explanation
Correct.
Overall explanation
Actions trigger the execution of the lazy-evaluated plan. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 87
Skipped
Which of the following are TRUE about 'Reader Accounts'? (Select 2)
Correct selection
The Provider can restrict which data the Reader Account can see.
Explanation
Correct. Uses standard Data Sharing.
The Consumer pays for the compute costs.
Explanation
Incorrect. The Provider pays.
Correct selection
They are created and managed by the Provider account.
Explanation
Correct.
Reader accounts can have their own local tables.
Explanation
Incorrect. They are strictly for consuming shared data.
Overall explanation
Reader accounts are a 'gift' of data and compute from a provider to a non-Snowflake user. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 88
Skipped
Which privilege is required to see the 'Credit Usage' of a specific Warehouse?
SELECT on the warehouse.
Explanation
No.
Correct answer
MONITOR on the warehouse.
Explanation
Correct. Specific privilege for observing activity and consumption.
USAGE on the warehouse.
Explanation
No.
OPERATE on the warehouse.
Explanation
No.
Overall explanation
The MONITOR privilege allows roles to see what is happening on a compute resource without necessarily using it. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Security
Question 89
Skipped
A retail company wants to implement a 'Data Clean Room'. Which Snowflake feature is the foundation for this?
Snowpipe
Explanation
Used for loading.
Search Optimization
Explanation
Performance feature.
Correct answer
Secure Data Sharing
Explanation
Correct. Allows sharing data without moving it or exposing PII via secure logic.
External Tables
Explanation
Storage feature.
Overall explanation
Account and Data Sharing
Question 90
Skipped
What happens to the 'Fail-safe' data if a table is dropped and then 'Undropped'?
Snowflake Support must be called.
Explanation
No.
It is moved to Time Travel.
Explanation
No.
Correct answer
It is fully restored along with the table.
Explanation
Correct. The metadata and associated storage are linked.
It is lost.
Explanation
No.
Overall explanation
UNDROP restores the object's entire lifecycle state, including its protection windows. Ref: https://docs.snowflake.com/en/sql-reference/sql/undrop-table
Domain
Storage and Protection
Question 91
Skipped
Which metadata-only function returns the amount of storage (in bytes) used by a table and its clones?
Correct answer
None of the above (it's a view)
Explanation
Correct. This information is found in the TABLE_STORAGE_METRICS view in ACCOUNT_USAGE.
TABLE_STORAGE_USAGE
Explanation
No.
TABLE_STORAGE_SUMMARY
Explanation
No.
TABLE_STORAGE_METRICS
Explanation
No.
Overall explanation
Storage metrics are retrieved from views in the SNOWFLAKE database, not simple scalar functions. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/table_storage_metrics
Domain
Account and Data Sharing
Question 92
Skipped
In the context of 'Multi-factor Authentication' (MFA), which role is highly recommended to have it enabled?
USERADMIN
Explanation
No.
SYSADMIN
Explanation
Good, but not the most critical.
PUBLIC
Explanation
No.
Correct answer
ACCOUNTADMIN
Explanation
Correct. Due to its unrestricted power over the account.
Overall explanation
Every ACCOUNTADMIN should be protected by MFA as a mandatory security best practice. Ref: https://docs.snowflake.com/en/user-guide/security-mfa
Domain
Security
Question 93
Skipped
What is the purpose of the 'VALIDATE_MODE' parameter in the COPY INTO command?
To check if the user has permissions.
Explanation
No.
Correct answer
To parse the files and return errors without loading data.
Explanation
Correct. Prevents partial/bad loads.
To encrypt the data during transit.
Explanation
No.
To compress the data.
Explanation
No.
Overall explanation
Validation mode is a best practice to test ingestion logic before executing the actual load. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 94
Skipped
Which of the following are 'Semi-structured' data types in Snowflake? (Select 2)
TIMESTAMP
Explanation
Incorrect.
GEOGRAPHY
Explanation
Incorrect. This is a spatial type.
Correct selection
VARIANT
Explanation
Correct. Stores any semi-structured data up to 16MB.
Correct selection
ARRAY
Explanation
Correct. A list of values.
Overall explanation
VARIANT, OBJECT, and ARRAY are the three pillars of semi-structured storage in Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/data-types-semistructured
Domain
Storage and Protection
Question 95
Skipped
Which role is the only one that can manage 'Credit Card' and 'Billing' information?
USERADMIN.
Explanation
No.
SECURITYADMIN.
Explanation
No.
Correct answer
ACCOUNTADMIN.
Explanation
Correct. (Sometimes ORGADMIN for multi-account).
SYSADMIN.
Explanation
No.
Overall explanation
Financial operations are strictly limited to the ACCOUNTADMIN role. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Account and Data Sharing
Question 96
Skipped
Which of the following describes 'Snowpipe' correctly?
It is for bulk loading.
Explanation
No.
It requires a manual warehouse.
Explanation
No (Serverless).
Correct answer
It is a continuous data ingestion service.
Explanation
Correct.
It only works with CSV.
Explanation
No.
Overall explanation
Snowpipe is designed for 'near real-time' data ingestion. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
Domain
Data Movement
Question 97
Skipped
A retail analyst wants to query a 'Stream'. What data will they see?
Correct answer
Only the rows that have changed (DML) since the last time the stream was consumed.
Explanation
Correct. It is a 'delta' view.
The deleted rows only.
Explanation
No.
The entire history of the table.
Explanation
No.
The current state of the table.
Explanation
No.
Overall explanation
Streams provide Change Data Capture (CDC) to enable incremental processing. Ref: https://docs.snowflake.com/en/user-guide/streams-intro
Domain
Account and Data Sharing
Question 98
Skipped
In Snowpark, what is the difference between a Transformation and an Action? (Select 2)
Actions are only available in Scala.
Explanation
Incorrect. Available in Python and Java too.
Transformations are executed on the client machine.
Explanation
Incorrect. Both are eventually executed in Snowflake.
Correct selection
Transformations are lazy and do not trigger execution.
Explanation
Correct. They just build the logical plan.
Correct selection
Actions are eager and trigger the execution on the warehouse.
Explanation
Correct. Examples include collect() and count().
Overall explanation
Performance and Warehouses
Question 99
Skipped
Which of the following is NOT a characteristic of 'Zero-copy Cloning'?
Correct answer
It duplicates the physical data on disk.
Explanation
Correct. This is NOT true; it only copies metadata.
It supports Databases, Schemas, and Tables.
Explanation
Characteristic.
It is nearly instantaneous.
Explanation
Characteristic.
The clone has its own lifecycle.
Explanation
Characteristic.
Overall explanation
Cloning is efficient because it avoids data duplication until changes are made. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 100
Skipped
Which of the following functions returns the Snowflake account identifier?
Correct answer
CURRENT_ACCOUNT()
Explanation
Correct. Returns the account name.
GET_ACCOUNT_ID()
Explanation
No.
CURRENT_REGION()
Explanation
Returns the region.
SYSTEM$ACCOUNT_NAME()
Explanation
No.
Overall explanation
Essential for building dynamic scripts or identifying the environment. Ref: https://docs.snowflake.com/en/sql-reference/functions/current_account
Domain
Account and Data Sharing
Question 101
Skipped
Which of the following functions or views can be used to monitor 'Auto-Ingest' Snowpipe latency? (Select 2)
Correct selection
PIPE_USAGE_HISTORY
Explanation
Correct. Shows credit consumption and file counts.
WAREHOUSE_METERING_HISTORY
Explanation
Incorrect. Snowpipe uses serverless compute.
Correct selection
COPY_HISTORY
Explanation
Correct. Shows the time files were loaded into tables.
SNOWPIPE_STREAMING_STATS
Explanation
Incorrect. This is for the Streaming API.
Overall explanation
Monitoring latency involves checking when files arrive in the stage versus when they finish loading via COPY_HISTORY. Ref: https://docs.snowflake.com/en/sql-reference/functions/pipe_usage_history
Domain
Data Movement
Question 102
Skipped
A retail company wants to minimize 'Remote Disk Spilling'. Which of the following is the most direct action to take?
Create a Clustering Key.
Explanation
Speeds up scans, doesn't solve memory issues.
Use a Secure View.
Explanation
No.
Correct answer
Increase the Warehouse size.
Explanation
Correct. Provides more RAM to keep the data local.
Enable Auto-scaling.
Explanation
Handles concurrency, not memory for one query.
Overall explanation
Spilling happens when a query's working set exceeds the available RAM of the warehouse nodes. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 103
Skipped
Which role is considered the 'Owner' of an object in Snowflake?
The person who created it.
Explanation
Incorrect. The role that created it.
The SYSADMIN.
Explanation
No.
ACCOUNTADMIN.
Explanation
No.
Correct answer
The role that has the OWNERSHIP privilege on the object.
Explanation
Correct. Privileges are tied to roles, not users.
Overall explanation
Snowflake's RBAC model ensures that permissions are managed through roles for consistency. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 104
Skipped
Which command is used to see the list of 'Stages' in a database?
LIST STAGES.
Explanation
No.
DESCRIBE DATABASE.
Explanation
No.
Correct answer
SHOW STAGES.
Explanation
Correct. Displays all stages you have privileges to see.
GET STAGES.
Explanation
No.
Overall explanation
SHOW commands are the standard for discovering objects in Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/sql/show-stages
Domain
Data Movement
Question 105
Skipped
What is the maximum number of 'Fail-safe' days for a 'Permanent' table in the 'Enterprise' edition?
90 days.
Explanation
No.
Correct answer
7 days.
Explanation
Correct. Fail-safe is always 7 days for Permanent tables across all editions.
1 day.
Explanation
No.
0 days.
Explanation
No.
Overall explanation
Do not confuse Time Travel (up to 90 days) with Fail-safe (fixed 7 days). Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 106
Skipped
What is 'Clustering Depth' used to measure?
Correct answer
The effectiveness of a table's clustering.
Explanation
Correct. (Lower is better).
The size of a warehouse.
Explanation
No.
How many rows are in a table.
Explanation
No.
The depth of a JSON file.
Explanation
No.
Overall explanation
A well-clustered table has low depth, meaning filters can skip more data. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions
Domain
Performance and Warehouses
Question 107
Skipped
Which function is used to get the 'Query ID' of the last query executed in the session?
QUERY_ID()
Explanation
No.
GET_ID()
Explanation
No.
Correct answer
LAST_QUERY_ID()
Explanation
Correct. Returns the UUID of the most recent query.
LAST_ID()
Explanation
No.
Overall explanation
This ID is often needed for troubleshooting or passing to other functions like VALIDATE. Ref: https://docs.snowflake.com/en/sql-reference/functions/last_query_id
Domain
Performance and Warehouses
Question 108
Skipped
Which of the following are TRUE regarding 'Internal Stages'? (Select 2)
Internal stages can be shared with other accounts.
Explanation
Incorrect. Sharing is for data, not stages.
Correct selection
Each table has its own stage (@%).
Explanation
Correct. Used for loading into that specific table.
They are hosted in the customer's own S3 bucket.
Explanation
Incorrect. Hosted by Snowflake.
Correct selection
Each user has a personal stage (@~).
Explanation
Correct. Private to the user.
Overall explanation
Snowflake provides managed stages (User, Table, Named) to simplify file handling. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 109
Skipped
Which of the following views allows you to check if a specific 'Task' is currently 'Suspended' or 'Started'?
WAREHOUSE_METRICS
Explanation
No.
Correct answer
TASKS
Explanation
Correct. Contains the 'STATE' column.
TASK_HISTORY
Explanation
Shows history, not current state.
QUERY_HISTORY
Explanation
No.
Overall explanation
The TASKS view in the Information Schema or Account Usage provides the current definition and status of tasks. Ref: https://docs.snowflake.com/en/sql-reference/info-schema/tasks
Domain
Account and Data Sharing
Question 110
Skipped
Which command is used to see all the users in a Snowflake account?
LIST USERS.
Explanation
No.
SELECT * FROM USERS.
Explanation
No.
Correct answer
SHOW USERS.
Explanation
Correct.
DESCRIBE USERS.
Explanation
No.
Overall explanation
SHOW USERS provides metadata about every user identity in the account. Ref: https://docs.snowflake.com/en/sql-reference/sql/show-users
Domain
Security
Question 111
Skipped
What is the purpose of 'Private Link' (AWS/Azure/GCP)?
To share data with other regions.
Explanation
No.
To compress data.
Explanation
No.
Correct answer
To allow access to Snowflake without traversing the public internet.
Explanation
Correct. Increases security and privacy.
To speed up queries.
Explanation
No.
Overall explanation
Private Link keeps all traffic within the cloud provider's backbone network. Ref: https://docs.snowflake.com/en/user-guide/admin-security-privatelink
Domain
Security
Question 112
Skipped
What is the purpose of 'Object Tagging'?
To speed up data loading.
Explanation
No.
Correct answer
To categorize and manage objects for governance and billing.
Explanation
Correct.
To delete data.
Explanation
No.
To clone tables.
Explanation
No.
Overall explanation
Tags help track sensitive data and attribute costs to departments. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 113
Skipped
Which of the following describes 'Search Optimization Service' maintenance?
Correct answer
It is automatic and uses Snowflake-managed serverless compute.
Explanation
Correct. Credits are billed to the account.
It is manual and requires a warehouse.
Explanation
No.
It is free of charge.
Explanation
No.
It only happens once a day.
Explanation
No.
Overall explanation
Like re-clustering, Search Optimization maintenance is a background service managed by Snowflake. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 114
Skipped
What is the function of 'Automatic Re-clustering'?
To delete old data.
Explanation
No.
To encrypt data.
Explanation
No.
Correct answer
To maintain the optimal data layout for a table as data changes.
Explanation
Correct. Background serverless service.
To resize the warehouse.
Explanation
No.
Overall explanation
Re-clustering prevents performance degradation as new data is inserted or updated in a clustered table. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 115
Skipped
Which of the following can be used to 'Trigger' a Snowflake Task? (Select 2)
Correct selection
The completion of a predecessor task (Task Tree).
Explanation
Correct. Using the AFTER keyword.
A specific data row being inserted into a table.
Explanation
Incorrect. That would be a Stream + Task combo.
A manual email sent to Snowflake.
Explanation
Incorrect.
Correct selection
A cron-based schedule.
Explanation
Correct. Traditional time-based triggering.
Overall explanation
Tasks are orchestrated via schedules or dependencies within a DAG. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 116
Skipped
What is the maximum number of 'Tags' that can be applied to a single Snowflake object?
Correct answer
50
Explanation
Correct. This is the current system limit.
100
Explanation
No.
Unlimited
Explanation
No.
10
Explanation
No.
Overall explanation
Tags allow for rich governance but have a logical limit of 50 per object. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 117
Skipped
What is the maximum number of 'Search Optimization' paths that can be added to a table?
1
Explanation
No.
5
Explanation
No.
10
Explanation
No.
Correct answer
Unlimited
Explanation
Correct. You can add it for many columns and predicates.
Overall explanation
While you can add many, each one increases the maintenance cost of the table. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 118
Skipped
What is the purpose of the 'SCIM' protocol in Snowflake?
To encrypt data in transit.
Explanation
No.
To monitor warehouse credits.
Explanation
No.
Correct answer
To automate user provisioning from an external identity provider.
Explanation
Correct. Keeps users and roles in sync.
To share data.
Explanation
No.
Overall explanation
SCIM stands for System for Cross-domain Identity Management. Ref: https://docs.snowflake.com/en/user-guide/scim-intro
Domain
Security
Question 119
Skipped
Which function is used to convert an 'Array' into multiple rows?
EXPLODE
Explanation
Spark function name.
SPLIT
Explanation
Creates an array from a string.
Correct answer
FLATTEN
Explanation
Correct. Essential for unnesting data.
CONCAT
Explanation
Joins strings.
Overall explanation
FLATTEN takes a VARIANT, OBJECT, or ARRAY and explodes it into a set of rows. Ref: https://docs.snowflake.com/en/sql-reference/functions/flatten
Domain
Storage and Protection
Question 120
Skipped
Which of the following are 'System-defined' Roles? (Select 3)
Correct selection
ACCOUNTADMIN.
Explanation
Correct. Highest level in an account.
DATA_SCIENTIST.
Explanation
Incorrect (custom role).
DBA.
Explanation
Incorrect (custom role).
Correct selection
ORGADMIN.
Explanation
Correct. Manages organizations and accounts.
Correct selection
SECURITYADMIN.
Explanation
Correct. Manages security objects.
Overall explanation
Snowflake comes with a set of default roles that cannot be deleted. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 121
Skipped
A retail company wants to use 'Snowpark' for data science. Which of the following is NOT a benefit of Snowpark?
Logic is executed near the data.
Explanation
This is a benefit.
Correct answer
It eliminates the need for a Virtual Warehouse.
Explanation
Correct. Snowpark still requires a warehouse to execute logic.
It supports multiple languages (Python, Java, Scala).
Explanation
This is a benefit.
It reduces data egress costs.
Explanation
This is a benefit.
Overall explanation
Snowpark is a framework, but it still relies on Snowflake's compute layer (Warehouses). Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 122
Skipped
What is 'Vertical Scaling' in a Snowflake Virtual Warehouse?
Adding more users.
Explanation
No.
Correct answer
Changing the size from Small to Medium.
Explanation
Correct. Increases power per query.
Adding more clusters.
Explanation
No (Horizontal).
Moving to another region.
Explanation
No.
Overall explanation
Vertical scaling (Scale-up) provides more memory and CPU for complex queries. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses