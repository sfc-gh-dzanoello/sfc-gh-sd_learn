Question 1
Incorrect
Which type of object can be 'Shared' using Snowflake Data Sharing? (Select 3)
Your selection is correct
Tables.
Explanation
Correct.
Virtual Warehouses.
Explanation
Incorrect. Consumers use their own compute.
Your selection is incorrect
Users.
Explanation
Incorrect.
Your selection is correct
Secure Views.
Explanation
Correct.
Correct selection
Secure Materialized Views.
Explanation
Correct.
Overall explanation
Sharing is focused on data objects (tables, views, functions) while keeping logic secure. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 2
Skipped
True or False: A 'Masking Policy' can be applied to a column within a 'Secure View'.
Correct answer
TRUE
Explanation
Correct. They can be layered for maximum security.
FALSE
Explanation
They are compatible.
Overall explanation
Snowflake's security features like masking and secure views are designed to work together to protect sensitive data. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 3
Skipped
What information can be found in a 'Directory Table' for a stage? (Select 2)
Correct selection
File size and Checksum.
Explanation
Correct. Metadata about the physical files.
Correct selection
File URLs and Scoped URLs for the files.
Explanation
Correct. Used to access the files via SQL.
The names of the users who uploaded the files.
Explanation
Incorrect. This is found in load history views.
The specific data rows within a CSV file.
Explanation
Incorrect. This requires a SELECT on the file.
Overall explanation
Directory tables store file-level metadata and provide a SQL interface to staged files. Ref: https://docs.snowflake.com/en/user-guide/data-load-dirtables-intro
Domain
Data Movement
Question 4
Skipped
Which command is used to see the credit usage for each Virtual Warehouse?
Correct answer
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY.
Explanation
Correct. Provides detailed usage logs for billing.
SHOW WAREHOUSES.
Explanation
Shows status, not history.
LIST WAREHOUSES.
Explanation
Incorrect.
SHOW BILLING.
Explanation
Incorrect command.
Overall explanation
Monitoring usage history is vital for budget management and optimization. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/warehouse_metering_history
Domain
Account and Data Sharing
Question 5
Skipped
A retail company wants to use 'Snowpipe' for auto-ingestion. Which cloud services provide event notifications to trigger Snowpipe? (Select 3)
Local Hard Drive.
Explanation
Incorrect. Snowpipe requires cloud storage.
Snowflake Internal Stage.
Explanation
Incorrect. Auto-ingestion is for external stages.
Correct selection
Google Cloud Storage.
Explanation
Correct. Via Pub/Sub.
Correct selection
AWS S3.
Explanation
Correct. Via SQS/SNS.
Correct selection
Azure Blob Storage.
Explanation
Correct. Via Event Grid.
Overall explanation
Snowpipe leverages cloud-native notification services to achieve automated, near-real-time loading. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3
Domain
Data Movement
Question 6
Skipped
What are the characteristics of a 'Temporary Table' in Snowflake? (Select 2)
Correct selection
It is only visible to the user who created it.
Explanation
Correct. It is session-specific.
Correct selection
It does not have a Fail-safe period.
Explanation
Correct. Reduces storage costs for transient data.
It persists after the session ends.
Explanation
Incorrect. It is dropped when the session closes.
It can have up to 90 days of Time Travel.
Explanation
Incorrect. Max is 1 day.
Overall explanation
Temporary tables are session-bound and cost-effective as they skip the Fail-safe stage. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 7
Skipped
Which of the following are requirements for 'Zero-copy Cloning'? (Select 2)
The database must be in the Business Critical edition.
Explanation
Incorrect. Available in all editions.
A running Virtual Warehouse.
Explanation
Incorrect. Cloning is a metadata-only operation and doesn't need compute.
Correct selection
The user must have the CLONE privilege on the object.
Explanation
Correct. Security is always required.
Correct selection
The source and clone must be in the same account.
Explanation
Correct. You cannot clone across accounts directly.
Overall explanation
Cloning is efficient because it only creates new metadata pointers to existing micro-partitions. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 8
Skipped
What happens to a 'Task' if its dependent 'Stream' has no new data?
The task fails with an error.
Explanation
No.
Correct answer
The task can be configured to skip execution using the WHEN clause.
Explanation
Correct. 'WHEN SYSTEM$STREAM_HAS_DATA' saves credits.
The task is automatically suspended.
Explanation
No.
The task runs and processes 0 rows.
Explanation
No.
Overall explanation
Using the WHEN clause in a task ensures that compute resources are only used when there is work to do. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 9
Skipped
What is the primary benefit of 'Micro-partitions'?
They allow for row-level locking.
Explanation
No, Snowflake uses partition-level metadata.
They encrypt the data.
Explanation
No.
They store data in plain text.
Explanation
No.
Correct answer
They enable efficient data pruning during query execution.
Explanation
Correct. Snowflake skips partitions that don't match filters.
Overall explanation
Micro-partitions store columnar data and metadata, allowing the optimizer to ignore irrelevant data. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 10
Skipped
Which of the following are components of the 'Compute Layer' (Virtual Warehouses)? (Select 2)
Correct selection
RAM for data processing.
Explanation
Correct. Used for joins, sorts, and aggregations.
Metadata storage.
Explanation
Incorrect. This is Cloud Services.
Correct selection
SSD for local caching.
Explanation
Correct. Each node has SSD for the 'Local Cache'.
Global Transaction Manager.
Explanation
Incorrect. This is Cloud Services.
Overall explanation
Virtual Warehouses are MPP (Massively Parallel Processing) engines with their own local memory and disk. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Snowflake Architecture
Question 11
Skipped
Which Snowflake edition includes support for 'Database Failover and Failback' for Business Continuity?
Virtual Private Snowflake.
Explanation
Yes, but Business Critical is the minimum tier.
Standard.
Explanation
No.
Enterprise.
Explanation
No.
Correct answer
Business Critical.
Explanation
Correct. High-end disaster recovery feature.
Overall explanation
Business Critical (and above) provides the multi-region resilience required for critical apps. Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Account and Data Sharing
Question 12
Skipped
What is the function of 'Clustering Keys' in Snowflake?
To manage user roles.
Explanation
No.
Correct answer
To co-locate similar data in micro-partitions to improve query pruning.
Explanation
Correct. Speeds up queries on large tables.
To backup the data.
Explanation
No.
To encrypt the data.
Explanation
No.
Overall explanation
Clustering keys are vital for multi-terabyte tables where standard sorting isn't enough. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 13
Skipped
What is the maximum size of a single 'VARIANT' value?
Correct answer
16 MB
Explanation
Correct. Compressed.
128 MB
Explanation
No.
1 MB
Explanation
No.
No limit
Explanation
No.
Overall explanation
While large, VARIANT columns are limited to 16MB per row. Ref: https://docs.snowflake.com/en/sql-reference/data-types-semistructured
Domain
Storage and Protection
Question 14
Skipped
In a retail inventory scenario, a 'Stream' is placed on a table. What are the three columns automatically added by the stream? (Select 3)
METADATA$TIMESTAMP
Explanation
Incorrect.
METADATA$USER
Explanation
Incorrect.
METADATA$TABLE_NAME
Explanation
Incorrect.
Correct selection
METADATA$ISUPDATE
Explanation
Correct. Indicates if the change was part of an UPDATE.
Correct selection
METADATA$ACTION
Explanation
Correct. Shows if the change was INSERT or DELETE.
Correct selection
METADATA$ROW_ID
Explanation
Correct. A unique ID for the row during the stream's lifecycle.
Overall explanation
These metadata columns allow Snowflake to track the exact nature of DML changes. Ref: https://docs.snowflake.com/en/user-guide/streams-intro
Domain
Account and Data Sharing
Question 15
Skipped
Which of the following are valid ways to improve the performance of a Snowpark Python application? (Select 2)
Correct selection
Minimize the use of .collect() until the final result is needed.
Explanation
Correct. Reduces data transfer between Snowflake and the client.
Correct selection
Use a larger Virtual Warehouse.
Explanation
Correct. Provides more memory for complex DataFrame operations.
Write the code in a single long string instead of using DataFrames.
Explanation
Incorrect. DataFrames are optimized by Snowflake.
Install more RAM on the developer's laptop.
Explanation
Incorrect. Snowpark runs in the Snowflake warehouse.
Overall explanation
Optimization in Snowpark focuses on maximizing push-down and providing enough warehouse resources. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 16
Skipped
A developer wants to use Snowpark Python to build a data pipeline. Which statements are TRUE about Snowpark? (Select 2)
Correct selection
It uses 'Lazy Evaluation' to optimize queries before execution.
Explanation
Correct. Execution only happens when an action like collect() is called.
It requires a separate server to run the Python code.
Explanation
Incorrect. Code runs inside the Snowflake Warehouse.
It is only available in the Business Critical edition.
Explanation
Incorrect. Available in most editions.
Correct selection
It translates DataFrame operations into SQL.
Explanation
Correct. It pushes the logic down to the data.
Overall explanation
Snowpark allows developers to write code in Python/Java/Scala that Snowflake executes as optimized SQL. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 17
Skipped
In Snowflake, who owns the 'Fail-safe' data?
The Cloud Provider (AWS/Azure).
Explanation
Incorrect.
The Customer.
Explanation
Incorrect.
Correct answer
Snowflake Support.
Explanation
Correct. Only Snowflake can recover data from Fail-safe.
The ACCOUNTADMIN.
Explanation
Incorrect.
Overall explanation
Fail-safe is a 7-day disaster recovery window managed exclusively by Snowflake. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 18
Skipped
Which roles are considered 'System-Defined' in Snowflake? (Select 3)
Correct selection
ACCOUNTADMIN
Explanation
Correct. The highest-level role in the system.
Correct selection
SECURITYADMIN
Explanation
Correct. Manages grants and security objects.
DATA_ENGINEER
Explanation
Incorrect. This is typically a custom role.
DBA
Explanation
Incorrect. Usually a custom role.
Correct selection
USERADMIN
Explanation
Correct. Dedicated to managing users and roles.
Overall explanation
Snowflake has 5 system roles: ORGADMIN, ACCOUNTADMIN, SECURITYADMIN, USERADMIN, SYSADMIN, and PUBLIC. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 19
Skipped
Which features are available in 'Enterprise Edition' but NOT in 'Standard Edition'? (Select 2)
Correct selection
Multi-cluster Warehouses.
Explanation
Correct. Standard only allows single-cluster.
Correct selection
Up to 90 days of Time Travel.
Explanation
Correct. Standard is limited to 1 day.
Support for JSON/VARIANT.
Explanation
Incorrect. Available in all editions.
Bulk Data Loading.
Explanation
Incorrect. Available in all editions.
Overall explanation
Enterprise Edition adds critical features for scale (Multi-cluster) and governance (extended Time Travel). Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Account and Data Sharing
Question 20
Skipped
Which of the following describes 'Snowflake Scripting'?
A way to write Java code.
Explanation
No.
Correct answer
An extension to Snowflake SQL that allows for procedural logic like loops and variables.
Explanation
Correct.
A tool for scripting account creation.
Explanation
No.
A data visualization library.
Explanation
No.
Overall explanation
Snowflake Scripting brings procedural power (PL/SQL style) to the native SQL interface. Ref: https://docs.snowflake.com/en/developer-guide/snowflake-scripting/index
Domain
Account and Data Sharing
Question 21
Skipped
Which function is used to check the status of 'Snowpipe'?
SHOW PIPES
Explanation
Shows metadata, not real-time status.
PIPE_STATUS()
Explanation
Incorrect.
DESC PIPE
Explanation
No.
Correct answer
SYSTEM$PIPE_STATUS()
Explanation
Correct. Returns info on whether the pipe is running or stalled.
Overall explanation
Monitoring Snowpipe status is critical for ensuring data is flowing from cloud storage correctly. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_pipe_status
Domain
Data Movement
Question 22
Skipped
Which role is required to create a 'Resource Monitor' at the account level?
SECURITYADMIN
Explanation
Incorrect.
SYSADMIN
Explanation
Incorrect.
USERADMIN
Explanation
Incorrect.
Correct answer
ACCOUNTADMIN
Explanation
Correct. Resource monitors impact billing and are restricted to admins.
Overall explanation
Managing account-level credits is a core responsibility of the ACCOUNTADMIN role. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 23
Skipped
What is the function of the 'FLATTEN' function?
Correct answer
To convert semi-structured data (arrays/objects) into multiple rows.
Explanation
Correct.
To compress large tables.
Explanation
No.
To merge two tables.
Explanation
No.
To encrypt a VARIANT column.
Explanation
No.
Overall explanation
FLATTEN is a table function that 'un-nests' complex data structures for relational analysis. Ref: https://docs.snowflake.com/en/sql-reference/functions/flatten
Domain
Storage and Protection
Question 24
Skipped
Which role is required to see 'Account Usage' views in the SNOWFLAKE database?
PUBLIC
Explanation
Incorrect.
Correct answer
ACCOUNTADMIN
Explanation
Correct. Inherent privilege for this role.
USERADMIN
Explanation
Incorrect.
SYSADMIN
Explanation
Incorrect.
Overall explanation
The SNOWFLAKE database contains sensitive metadata and is strictly controlled. Ref: https://docs.snowflake.com/en/sql-reference/account-usage
Domain
Account and Data Sharing
Question 25
Skipped
How can you prevent a Virtual Warehouse from consuming too many credits if a query runs longer than expected?
Enable Multi-cluster.
Explanation
No.
Increase the Warehouse size.
Explanation
This would spend credits faster.
Correct answer
Use the STATEMENT_TIMEOUT_IN_SECONDS parameter.
Explanation
Correct. Aborts queries that exceed a time limit.
Set the AUTO_SUSPEND to 0.
Explanation
Incorrect. This disables auto-suspend.
Overall explanation
Statement timeout is a key guardrail to prevent 'runaway' queries from wasting budget. Ref: https://docs.snowflake.com/en/sql-reference/parameters#statement-timeout-in-seconds
Domain
Performance and Warehouses
Question 26
Skipped
Which command will change the size of an existing Virtual Warehouse?
UPDATE WAREHOUSE...
Explanation
No.
Correct answer
ALTER WAREHOUSE <name> SET WAREHOUSE_SIZE = 'L'.
Explanation
Correct. Resizes the warehouse immediately.
SET WAREHOUSE_SIZE...
Explanation
No.
RESIZE WAREHOUSE...
Explanation
No.
Overall explanation
Resizing a warehouse is a DDL operation that can be done while the warehouse is running. Ref: https://docs.snowflake.com/en/sql-reference/sql/alter-warehouse
Domain
Performance and Warehouses
Question 27
Skipped
Which statement is TRUE regarding the 'Search Optimization Service'?
It replaces the need for micro-partitions.
Explanation
Incorrect. It complements them.
It is a free feature in all editions.
Explanation
Incorrect. It is Enterprise+ and has a credit cost.
It speeds up massive aggregation queries.
Explanation
Incorrect. Materialized views are better for this.
Correct answer
It is used to improve the performance of point lookup queries on large tables.
Explanation
Correct. It acts like an index for specific values.
Overall explanation
Search Optimization Service creates an access path to speed up 'needle-in-a-haystack' queries. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 28
Skipped
True or False: Snowflake allows the use of 'Python' inside a Stored Procedure.
FALSE
Explanation
Snowpark allows this.
Correct answer
TRUE
Explanation
Correct. Python is a supported language for Stored Procedures.
Overall explanation
Snowflake supports multiple languages for Stored Procedures, including SQL, JavaScript, Python, Java, and Scala. Ref: https://docs.snowflake.com/en/sql-reference/stored-procedures-usage
Domain
Account and Data Sharing
Question 29
Skipped
What is the default retention period for 'Time Travel' in all Snowflake accounts?
0 days.
Explanation
Incorrect.
7 days.
Explanation
This is Fail-safe.
Correct answer
1 day.
Explanation
Correct. This is the baseline for all accounts and editions.
90 days.
Explanation
Requires Enterprise+.
Overall explanation
All tables automatically get 1 day of Time Travel unless configured otherwise. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 30
Skipped
What happens when the 'Auto-suspend' timer is reached for a Virtual Warehouse?
The warehouse is deleted.
Explanation
No.
The queries currently running are cancelled.
Explanation
No, it waits for active queries to finish.
Correct answer
The warehouse stops running and stops consuming credits.
Explanation
Correct. Credits are saved.
The warehouse moves to a smaller size.
Explanation
No.
Overall explanation
Auto-suspend is a key cost-saving feature that stops warehouses when they are idle. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 31
Skipped
Which type of URL is used to provide permanent, secure access to a file that still requires Snowflake authentication?
Pre-signed URL.
Explanation
Temporary and public.
Web URL.
Explanation
No.
Scoped URL.
Explanation
Temporary and session-bound.
Correct answer
File URL.
Explanation
Correct. Persistent but requires a session.
Overall explanation
File URLs are the best way to reference stage files in internal applications that handle their own login. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-files
Domain
Data Movement
Question 32
Skipped
Which of the following describes the 'ACCOUNT_USAGE' schema? (Select 3)
Correct selection
It contains 365 days of historical metadata.
Explanation
Correct. High retention for auditing.
Correct selection
It includes data for dropped objects.
Explanation
Correct. Essential for compliance audits.
Correct selection
It is part of the shared SNOWFLAKE database.
Explanation
Correct. Provided as a read-only share.
It is stored in the Information Schema.
Explanation
Incorrect. These are different schemas.
It reflects changes in near real-time (latency of seconds).
Explanation
Incorrect. It has a latency of minutes to hours.
Overall explanation
ACCOUNT_USAGE is the go-to schema for long-term auditing and consumption analysis. Ref: https://docs.snowflake.com/en/sql-reference/account-usage
Domain
Account and Data Sharing
Question 33
Skipped
Which of the following can be used as a 'stage' for data loading? (Select 3)
External Table.
Explanation
Incorrect. This is a table type, not a stage.
Internal Database Stage.
Explanation
Incorrect.
Correct selection
Internal Named Stage.
Explanation
Correct. A flexible object created by users.
Correct selection
Internal Table Stage.
Explanation
Correct. Automatically assigned to each table.
Correct selection
Internal User Stage.
Explanation
Correct. Automatically assigned to each user.
Overall explanation
Snowflake supports various internal stage types (User, Table, Named) and External stages (S3, GCS, Azure). Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 34
Skipped
What is the 'Fail-safe' duration for 'Transient' tables?
7 days.
Explanation
Only for Permanent tables.
90 days.
Explanation
No.
1 day.
Explanation
This is Time Travel.
Correct answer
0 days.
Explanation
Correct. Transient tables skip Fail-safe to save costs.
Overall explanation
The lack of Fail-safe is what makes Transient tables cheaper to store for ETL. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 35
Skipped
Which scaling policy is best for a warehouse that needs to prioritize query speed above all else?
Aggressive
Explanation
Not a valid scaling policy.
Optimized
Explanation
Not a valid scaling policy.
Economy
Explanation
Prioritizes cost.
Correct answer
Standard
Explanation
Correct. Starts clusters as soon as one query is queued.
Overall explanation
Standard mode starts new clusters immediately to eliminate queuing delays. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 36
Skipped
A retail company wants to 'Zero-copy Clone' a table from 2 days ago. Which feature allows this?
Fail-safe.
Explanation
No.
Data Sharing.
Explanation
No.
Database Replication.
Explanation
Used for cross-region.
Correct answer
Time Travel.
Explanation
Correct. You can clone using the AT or BEFORE clause.
Overall explanation
Cloning combined with Time Travel is a powerful way to recover data or test with historical states. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 37
Skipped
What is the function of the 'QUERY_ID' in Snowflake?
It identifies the database.
Explanation
No.
It is a random number.
Explanation
No.
Correct answer
A unique identifier for every query executed, used for tracking and troubleshooting.
Explanation
Correct. Found in history views.
It is the user's login ID.
Explanation
No.
Overall explanation
Every query in Snowflake is logged with a Query ID, which is the 'DNA' of the operation. Ref: https://docs.snowflake.com/en/sql-reference/functions/last_query_id
Domain
Performance and Warehouses
Question 38
Skipped
In Snowpark, which method is used to join two DataFrames?
.union()
Explanation
Used for appending, not joining.
Correct answer
.join()
Explanation
Correct. Follows standard Spark-like syntax.
.merge()
Explanation
Common in Pandas, not Snowpark.
.combine()
Explanation
No.
Overall explanation
Snowpark's .join() allows for inner, left, right, and full outer joins between datasets. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/reference/python/api/snowflake.snowpark.DataFrame.join
Domain
Performance and Warehouses
Question 39
Skipped
A retail company wants to track changes to a 'Products' table in real-time. Which object should they use?
View
Explanation
A logical representation of data.
Stage
Explanation
Used for file storage.
Task
Explanation
Executes code, doesn't track changes.
Correct answer
Stream
Explanation
Correct. Captures DML changes (inserts/updates/deletes) on a table.
Overall explanation
Streams provide Change Data Capture (CDC) capabilities for Snowflake tables. Ref: https://docs.snowflake.com/en/user-guide/streams-intro
Domain
Account and Data Sharing
Question 40
Skipped
Which command is used to see the list of files in a stage?
SELECT * FROM STAGE
Explanation
Incorrect syntax.
SHOW FILES
Explanation
Incorrect.
Correct answer
LIST (or LS)
Explanation
Correct. Shows file names, sizes, and md5.
DESCRIBE STAGE
Explanation
Shows stage parameters, not files.
Overall explanation
The LIST command allows users to inspect what is currently stored in a stage. Ref: https://docs.snowflake.com/en/sql-reference/sql/list
Domain
Data Movement
Question 41
Skipped
Which of the following is a 'Serverless' feature in Snowflake?
External Stage
Explanation
This is a storage reference.
Correct answer
Automatic Clustering
Explanation
Correct. Snowflake manages the compute behind the scenes.
SnowSQL
Explanation
This is a client tool.
Virtual Warehouse
Explanation
Requires user management.
Overall explanation
Serverless features like Clustering, Search Optimization, and Snowpipe don't require user-managed warehouses. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 42
Skipped
When using Snowpark, which operation is considered an 'Action' that triggers execution?
.filter()
Explanation
Incorrect. This is a transformation.
.select()
Explanation
Incorrect. This is a transformation.
Correct answer
.collect()
Explanation
Correct. This action sends the query to the warehouse.
.limit()
Explanation
Incorrect. This is a transformation.
Overall explanation
Actions like collect(), count(), or save_as_table() are required to execute the lazy-evaluated Snowpark plan. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 43
Skipped
Which of the following is TRUE about 'Secure Views'?
They are always faster than standard views.
Explanation
No.
They do not require a warehouse.
Explanation
No.
They can only be created by ACCOUNTADMIN.
Explanation
No.
Correct answer
They prevent users from seeing the underlying SQL definition.
Explanation
Correct. Protects intellectual property.
Overall explanation
Secure views ensure that users cannot infer data or see the logic behind the view using metadata functions. Ref: https://docs.snowflake.com/en/user-guide/views-secure
Domain
Account and Data Sharing
Question 44
Skipped
What is the maximum retention period for 'Time Travel' in a Permanent table (Enterprise Edition)?
365 days
Explanation
Incorrect.
1 day
Explanation
Standard edition limit.
7 days
Explanation
Fail-safe duration.
Correct answer
90 days
Explanation
Correct.
Overall explanation
Enterprise and higher editions allow up to 90 days of data history retention. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 45
Skipped
Which of the following is NOT a type of 'Internal Stage'?
Correct answer
Schema Stage.
Explanation
Incorrect. Named stages can be in a schema, but 'Schema Stage' is not a native type.
Named Stage.
Explanation
Valid.
Table Stage.
Explanation
Valid.
User Stage.
Explanation
Valid.
Overall explanation
Snowflake has three specific internal stage types: User (~), Table (%), and Named (@). Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 46
Skipped
Which type of table is best for storing large amounts of 'staged' or ETL-intermediate data that doesn't need long-term protection?
Temporary Table.
Explanation
Will disappear when the session ends.
Correct answer
Transient Table.
Explanation
Correct. Persists but has no Fail-safe, saving costs.
External Table.
Explanation
Stored outside Snowflake.
Permanent Table.
Explanation
Too expensive due to Fail-safe.
Overall explanation
Transient tables are the ideal 'middle ground' for ETL processing. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 47
Skipped
Which function is used to flatten a nested array in a JSON VARIANT column into individual rows?
UNNEST()
Explanation
Used in other SQL dialects.
EXPLODE()
Explanation
Used in Spark, not Snowflake.
Correct answer
FLATTEN()
Explanation
Correct. Often used with a LATERAL join.
SPLIT()
Explanation
Used for strings.
Overall explanation
FLATTEN is the essential tool for 'relationalizing' semi-structured arrays. Ref: https://docs.snowflake.com/en/sql-reference/functions/flatten
Domain
Storage and Protection
Question 48
Skipped
Which of the following are supported methods for 'Data Sharing' in Snowflake? (Select 3)
Correct selection
Direct Sharing.
Explanation
Correct. Direct provider-to-consumer.
FTP.
Explanation
Incorrect.
Correct selection
Snowflake Marketplace.
Explanation
Correct. For public or commercial data listings.
Emailing a CSV file.
Explanation
Incorrect.
Correct selection
Data Exchange.
Explanation
Correct. A private hub for a group of companies.
Overall explanation
Snowflake offers multiple tiers of sharing from 1-to-1 to a global marketplace. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 49
Skipped
A company has a 'Business Critical' edition. What additional security feature do they have access to?
Correct answer
Customer Managed Keys (Tri-Secret Secure).
Explanation
Correct. Gives the customer control over the encryption key.
Time Travel of 1 day.
Explanation
Available in all editions.
Standard MFA.
Explanation
Available in all editions.
Bulk Loading.
Explanation
Available in all editions.
Overall explanation
Business Critical is designed for highly sensitive data and requires extra layers of control. Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Security
Question 50
Skipped
Which tool is used to upload data from a local machine to an internal stage?
Correct answer
PUT
Explanation
Correct. Uploads local files to Snowflake stages.
Snowpipe
Explanation
Automated continuous loading.
COPY INTO
Explanation
Loads data from stage to table.
GET
Explanation
Downloads files from Snowflake.
Overall explanation
The PUT command is part of SnowSQL and allows secure file uploads. Ref: https://docs.snowflake.com/en/sql-reference/sql/put
Domain
Data Movement
Question 51
Skipped
What is the primary purpose of 'Key Pair Authentication'?
To create a Multi-cluster warehouse.
Explanation
No.
Correct answer
To provide secure, non-interactive login for automated scripts and tools.
Explanation
Correct. High security for ETL.
To share a password between users.
Explanation
No.
To encrypt micro-partitions.
Explanation
No.
Overall explanation
Key pair authentication avoids hardcoded passwords in scripts by using RSA keys. Ref: https://docs.snowflake.com/en/user-guide/key-pair-auth
Domain
Security
Question 52
Skipped
What is the purpose of 'Information Schema'?
To manage user passwords.
Explanation
Incorrect.
To backup data.
Explanation
Incorrect.
Correct answer
To provide real-time metadata about objects within a specific database.
Explanation
Correct. It is a set of system-defined views.
To store long-term billing data.
Explanation
Incorrect. Use Account Usage.
Overall explanation
Every database in Snowflake contains an Information Schema with real-time metadata. Ref: https://docs.snowflake.com/en/sql-reference/info-schema
Domain
Account and Data Sharing
Question 53
Skipped
Which of the following are benefits of a 'Multi-cluster Warehouse'? (Select 2)
It provides high availability across different regions.
Explanation
Incorrect. This is for cross-region replication.
It improves the performance of a single complex query.
Explanation
Incorrect. That is Scale-up (resizing).
Correct selection
It can be configured to start and stop clusters based on demand.
Explanation
Correct. This is the 'Auto-scale' feature.
Correct selection
It handles high concurrency by adding clusters automatically.
Explanation
Correct. It adds clusters to process more queries at once.
Overall explanation
Multi-cluster warehouses scale horizontally to support many users running queries at the same time. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 54
Skipped
Which of the following is NOT a semi-structured data type supported by Snowflake?
PARQUET
Explanation
Supported.
JSON
Explanation
Supported.
ORC
Explanation
Supported.
Correct answer
MP3
Explanation
Not supported. Snowflake is for structured/semi-structured/unstructured metadata.
Overall explanation
Snowflake focuses on data formats used for analytics and data warehousing. Ref: https://docs.snowflake.com/en/user-guide/data-load-prepare
Domain
Data Movement
Question 55
Skipped
A retail company needs to delete data older than 7 years for GDPR compliance. Which feature helps automate this?
Time Travel.
Explanation
No.
Correct answer
Tasks combined with DELETE statements.
Explanation
Correct. Tasks can be scheduled to run maintenance SQL.
Streams.
Explanation
No.
Resource Monitors.
Explanation
No.
Overall explanation
Tasks are the built-in scheduling tool for automating routine DML operations. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 56
Skipped
A retail company detects that a query is taking too long due to 'External Function' latencies. Which factors could be causing this? (Select 2)
Correct selection
The remote service (e.g., AWS Lambda) is taking too long to process the batches.
Explanation
Correct. Latency in the external service directly affects the query performance.
The Virtual Warehouse is too small.
Explanation
External functions run outside the warehouse, though the warehouse waits for them.
The table has too many micro-partitions.
Explanation
Not directly related to external function latency.
Correct selection
Network overhead between Snowflake and the API Gateway.
Explanation
Correct. The data transfer over the network adds to the total execution time.
Overall explanation
External Function performance depends heavily on the remote service's response time and network throughput. Ref: https://docs.snowflake.com/en/user-guide/external-functions-intro
Domain
Performance and Warehouses
Question 57
Skipped
A retail company needs to connect their on-premise data center to Snowflake without using the public internet. What is the best solution?
Correct answer
AWS PrivateLink (or Azure/GCP equivalent).
Explanation
Correct. Creates a private connection between the VPC and Snowflake.
SnowSQL with MFA.
Explanation
Uses the public internet.
Standard Snowflake Login.
Explanation
Uses the public internet.
IP Whitelisting.
Explanation
Still uses the public internet.
Overall explanation
Private Link ensures traffic stays within the cloud provider's network backbone. Ref: https://docs.snowflake.com/en/user-guide/admin-security-privatelink
Domain
Security
Question 58
Skipped
What is the function of 'Object Tagging' in a retail governance strategy? (Select 2)
To improve query performance.
Explanation
Incorrect.
To automatically delete old data.
Explanation
Incorrect.
Correct selection
To classify sensitive data (e.g., PII) for compliance.
Explanation
Correct.
Correct selection
To track credit usage by cost center.
Explanation
Correct. Tags on warehouses help in cost attribution.
Overall explanation
Object tagging is a foundation for both security (classification) and financial management (cost centers). Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 59
Skipped
What is the purpose of the 'VALIDATION_MODE' parameter in a COPY INTO statement?
To speed up the load.
Explanation
Incorrect.
To change the data types of columns.
Explanation
Incorrect.
To encrypt the data during load.
Explanation
Incorrect.
Correct answer
To test the data load and return errors without actually loading the data.
Explanation
Correct. Very useful for debugging.
Overall explanation
VALIDATION_MODE allows you to verify file integrity before committing credits to a full load. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 60
Skipped
A retail company is using a 'Kafka Connector'. What is the target format for data landed in Snowflake?
A plain text column.
Explanation
No.
An Excel file.
Explanation
No.
A CSV file.
Explanation
No.
Correct answer
A table with a VARIANT column containing the JSON message.
Explanation
Correct. Allows for flexible ingestion of streaming data.
Overall explanation
Kafka data is typically landed as semi-structured VARIANT data for later processing. Ref: https://docs.snowflake.com/en/user-guide/kafka-connector
Domain
Data Movement
Question 61
Skipped
Which of the following describes 'Query Acceleration Service' (QAS) correctly?
Correct answer
It uses a shared pool of serverless compute resources to speed up large scans.
Explanation
Correct. It offloads parts of the query to serverless nodes.
It only works for INSERT statements.
Explanation
No.
It automatically resizes the warehouse to a larger size.
Explanation
No.
It is only available for Business Critical accounts.
Explanation
No, it is Enterprise and higher.
Overall explanation
QAS is a powerful tool for accelerating heavy scan queries without manual warehouse resizing. Ref: https://docs.snowflake.com/en/user-guide/query-acceleration-service
Domain
Performance and Warehouses
Question 62
Skipped
What is the maximum number of days for 'Fail-safe' in a Permanent table?
Correct answer
7 days.
Explanation
Correct. This is a non-configurable fixed period.
30 days.
Explanation
No.
1 day.
Explanation
No.
90 days.
Explanation
No.
Overall explanation
Fail-safe is the final safety net after Time Travel expires, managed only by Snowflake Support. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 63
Skipped
What is 'OCSP' in the context of Snowflake connectivity?
Correct answer
A protocol for checking the validity of SSL certificates.
Explanation
Correct. Used for secure connections.
A type of virtual warehouse.
Explanation
No.
A data compression protocol.
Explanation
No.
A data sharing method.
Explanation
No.
Overall explanation
OCSP (Online Certificate Status Protocol) helps drivers ensure that Snowflake's security certificates are valid and not revoked. Ref: https://docs.snowflake.com/en/user-guide/admin-security-ocsp
Domain
Security
Question 64
Skipped
A retail company wants to automate their data pipeline. Which feature allows a Task to start immediately after another Task finishes?
Correct answer
Task Trees (DAGs).
Explanation
Correct. Using the AFTER keyword to create dependencies.
Task Scheduling.
Explanation
Based on time.
Snowpipe.
Explanation
Used for loading, not task logic.
Stream Triggering.
Explanation
Triggers a task based on data change.
Overall explanation
Task dependencies allow for complex, ordered workflows without manual intervention. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 65
Skipped
What happens to the 'Metadata Cache' when a Virtual Warehouse is suspended?
It is deleted.
Explanation
Incorrect.
It is moved to S3.
Explanation
Incorrect.
It is moved to the Result Cache.
Explanation
Incorrect.
Correct answer
It remains in the Cloud Services layer.
Explanation
Correct. Cloud Services are independent of warehouses.
Overall explanation
Since Cloud Services are global and 'always on', metadata persists even if compute is off. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 66
Skipped
When cloning a database that has 'Time Travel' data, what happens to the Time Travel in the clone?
Correct answer
The clone begins its own Time Travel history from the moment of cloning.
Explanation
Correct. It does not inherit the parent's historical data.
Cloning is not possible if Time Travel is enabled.
Explanation
Incorrect.
The clone has no Time Travel data.
Explanation
Incorrect.
The clone inherits the full 90 days of history from the parent.
Explanation
Incorrect.
Overall explanation
Clones are point-in-time snapshots and start their own metadata lifecycle. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 67
Skipped
A retail company wants to use 'Dynamic Data Masking'. Where is the masking policy applied?
Correct answer
To a specific column.
Explanation
Correct. Targeted protection of sensitive data.
To the whole table.
Explanation
Incorrect.
To the entire database.
Explanation
Incorrect.
To the warehouse.
Explanation
Incorrect.
Overall explanation
Masking policies are assigned to columns to protect data based on the role of the user. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 68
Skipped
Which command is used to download files from a Snowflake stage to a local machine?
PUT
Explanation
Uploads files.
Correct answer
GET
Explanation
Correct. The opposite of PUT.
COPY INTO
Explanation
Loads to tables.
DOWNLOAD
Explanation
Not a valid command.
Overall explanation
GET allows users to export data from Snowflake internal stages to their local file system. Ref: https://docs.snowflake.com/en/sql-reference/sql/get
Domain
Data Movement
Question 69
Skipped
A retail company wants to ensure that store managers can only see sales data for their own store. Which features should be combined? (Select 2)
Correct selection
Row Access Policy.
Explanation
Correct. Used to filter rows based on user attributes.
Network Policy.
Explanation
Incorrect. This restricts IP access.
Correct selection
A mapping table with Manager IDs and Store IDs.
Explanation
Correct. The policy uses this table to authorize access.
Dynamic Data Masking.
Explanation
Incorrect. This masks columns, not rows.
Overall explanation
Row Access Policies use mapping logic to restrict data visibility at the row level. Ref: https://docs.snowflake.com/en/user-guide/security-row-intro
Domain
Security
Question 70
Skipped
In Snowpark, what is the 'Session' object used for?
Correct answer
To act as the main entry point to connect to Snowflake and create DataFrames.
Explanation
Correct. Essential for the Snowpark context.
To manage the browser session.
Explanation
No.
To store the user's password.
Explanation
No.
To speed up the network.
Explanation
No.
Overall explanation
The Session object is the 'brain' of a Snowpark application, managing the connection and plan generation. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 71
Skipped
What is the primary purpose of 'SCIM' (System for Cross-domain Identity Management) in Snowflake?
To encrypt data in transit.
Explanation
No.
To share data between accounts.
Explanation
No.
To monitor credit usage.
Explanation
No.
Correct answer
To automate the provisioning and de-provisioning of users and roles from an IdP.
Explanation
Correct. It syncs users from providers like Okta or Azure AD.
Overall explanation
SCIM reduces administrative overhead by synchronizing identity management with external providers. Ref: https://docs.snowflake.com/en/user-guide/scim-intro
Domain
Security
Question 72
Skipped
Which tool allows you to visualize the execution plan and see which step of a query is taking the most time?
Resource Monitor.
Explanation
Used for billing.
History tab.
Explanation
Shows status but not the internal plan.
Account Usage views.
Explanation
Good for history, not visual plan.
Correct answer
Query Profile.
Explanation
Correct. Provides a detailed graphical breakdown of query execution.
Overall explanation
The Query Profile is the primary tool for performance tuning and troubleshooting. Ref: https://docs.snowflake.com/en/user-guide/ui-query-profile
Domain
Performance and Warehouses
Question 73
Skipped
What happens to the 'Result Cache' if the underlying data in a table is updated?
The warehouse is automatically resized.
Explanation
No.
The update is blocked.
Explanation
No.
The cache remains valid.
Explanation
Incorrect.
Correct answer
The cache for that table is invalidated.
Explanation
Correct. Snowflake ensures you always get the most current data.
Overall explanation
Snowflake's smart caching ensures that results are only reused if the data hasn't changed. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 74
Skipped
Which of the following are TRUE about 'Search Optimization Service' costs? (Select 2)
It uses the user's active virtual warehouse for maintenance.
Explanation
Incorrect. It uses Snowflake-managed compute.
There is no storage cost associated with it.
Explanation
Incorrect. It requires additional storage for its search structures.
Correct selection
It incurs a cost for both compute and storage.
Explanation
Correct. It is a premium performance feature.
Correct selection
It consumes credits for the background maintenance of search access paths.
Explanation
Correct. This is a serverless cost.
Overall explanation
SOS is highly effective but involves both serverless compute credits and storage overhead. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 75
Skipped
What is the result of 'Zero-copy Cloning'?
Correct answer
It creates a metadata-only copy that shares the same storage as the original.
Explanation
Correct. Very fast and cost-effective.
It moves the data to a different region.
Explanation
Incorrect.
It creates a physical copy of all data.
Explanation
Incorrect.
It only clones the table structure.
Explanation
Incorrect. It clones data too.
Overall explanation
Cloning creates a new object using the same micro-partitions, so it's nearly instantaneous and free until the data is changed. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 76
Skipped
A retail company is experiencing 'Remote Disk Spilling' during end-of-month processing. What are the most effective ways to address this? (Select 2)
Correct selection
Optimize the query to reduce the amount of data being joined or sorted.
Explanation
Correct. Reducing the memory footprint of the query prevents the need for spilling.
Enable Search Optimization Service.
Explanation
SOS helps with point lookups, not memory management for large joins.
Correct selection
Increase the Virtual Warehouse size.
Explanation
Correct. Larger warehouses have more RAM and local SSD to prevent spilling to remote storage.
Decrease the Warehouse size.
Explanation
This would reduce available memory and worsen the spilling.
Overall explanation
Remote spilling occurs when compute nodes exhaust both RAM and local SSD. Increasing size or optimizing logic are the primary fixes. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 77
Skipped
Which of the following are characteristics of 'External Functions'? (Select 2)
Correct selection
They allow Snowflake to call code outside of Snowflake (e.g., AWS Lambda).
Explanation
Correct. Extends Snowflake logic to external services.
They are stored in a stage.
Explanation
Incorrect.
Correct selection
They use an 'API Integration' object.
Explanation
Correct. Required for security and connectivity.
They can only be written in SQL.
Explanation
Incorrect.
Overall explanation
External functions bridge the gap between Snowflake and external compute services like Lambda or Azure Functions. Ref: https://docs.snowflake.com/en/user-guide/external-functions
Domain
Account and Data Sharing
Question 78
Skipped
Which of the following are benefits of 'Micro-partitions'? (Select 2)
They are always 1GB in size.
Explanation
Incorrect. They are typically 50MB to 500MB uncompressed.
Correct selection
They allow for columnar compression.
Explanation
Correct. Saves storage and speeds up I/O.
They require manual indexing.
Explanation
Incorrect. No indexes in Snowflake.
Correct selection
They provide automatic horizontal partitioning.
Explanation
Correct. Snowflake manages this without user effort.
Overall explanation
Micro-partitions are the foundation of Snowflake's performance and zero-management architecture. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 79
Skipped
Which function is used to convert a VARIANT value into a specific string format?
FLATTEN().
Explanation
Explodes arrays.
GET().
Explanation
Retrieves files.
Correct answer
TO_VARCHAR().
Explanation
Correct. e.g., TO_VARCHAR(variant_col).
PARSE_JSON().
Explanation
Converts to variant.
Overall explanation
Casting or using conversion functions is necessary to extract typed values from VARIANT columns. Ref: https://docs.snowflake.com/en/sql-reference/functions/to_char
Domain
Storage and Protection
Question 80
Skipped
Which of the following is NOT a valid 'Scaling Policy' for a Multi-cluster warehouse?
None.
Explanation
No.
Correct answer
Performance.
Explanation
Incorrect. (Note: Standard *is* the performance policy).
Standard.
Explanation
Valid.
Economy.
Explanation
Valid.
Overall explanation
There are only two policies: Standard (Performance-focused) and Economy (Cost-focused). Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 81
Skipped
Which component of the Cloud Services layer handles 'Transaction Management'?
The Optimizer
Explanation
Creates execution plans.
The Metadata Manager
Explanation
Stores partition info.
The Security Manager
Explanation
Manages RBAC.
Correct answer
The Transaction Manager
Explanation
Correct. Ensures ACID compliance.
Overall explanation
The Transaction Manager ensures that all DML operations across Snowflake are atomic and consistent. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 82
Skipped
What is the purpose of the 'SYSTEM$ALLOWLIST' function?
To list all users in the account.
Explanation
No.
Correct answer
To return the hostnames and ports required for network firewall configuration to access Snowflake.
Explanation
Correct. Essential for IT/Network teams.
To see which IP addresses are blocked.
Explanation
No.
To manage SSO.
Explanation
No.
Overall explanation
This function provides the 'connectivity map' needed to allow traffic through corporate firewalls. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_allowlist
Domain
Security
Question 83
Skipped
What happens to the credit consumption of a 'Multi-cluster Warehouse' in 'Economy' scaling mode?
It prioritizes speed over cost.
Explanation
Incorrect. That is Standard mode.
It never starts more than one cluster.
Explanation
Incorrect.
Correct answer
It waits to start a new cluster until there is enough load to keep it busy for 6 minutes.
Explanation
Correct. It prioritizes saving credits.
It runs all clusters at the same time.
Explanation
Incorrect.
Overall explanation
Economy mode is designed to optimize for cost by ensuring clusters are fully utilized before starting more. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 84
Skipped
Which Snowflake object is used to automate the execution of a SQL statement or a Stored Procedure on a schedule?
Stream.
Explanation
Tracks changes.
Correct answer
Task.
Explanation
Correct. Can be scheduled or triggered by a stream.
Pipe.
Explanation
Used for data loading.
Sequence.
Explanation
Generates numbers.
Overall explanation
Tasks can be chained to create a serverless data pipeline (DAG). Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 85
Skipped
Which of the following is TRUE about the 'Result Cache'?
It is local to a specific Virtual Warehouse.
Explanation
No.
It is stored in the micro-partitions.
Explanation
No.
Correct answer
It is global across the account and persists for 24 hours.
Explanation
Correct. Results can be reused by different warehouses.
It only works for SELECT * queries.
Explanation
No.
Overall explanation
The Result Cache is maintained by the Cloud Services layer and can significantly reduce costs. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 86
Skipped
What is the correct syntax to call a 'UDF' (User Defined Function) in a SELECT statement?
Correct answer
SELECT my_function(col) FROM my_table.
Explanation
Correct. UDFs are used like built-in functions in SQL.
CALL my_function(col).
Explanation
No, CALL is for Stored Procedures.
EXECUTE my_function(col).
Explanation
No.
RUN my_function(col).
Explanation
No.
Overall explanation
UDFs return a value and are used within SQL expressions, unlike Stored Procedures which are called independently. Ref: https://docs.snowflake.com/en/sql-reference/udf-overview
Domain
Account and Data Sharing
Question 87
Skipped
True or False: A single Snowflake account can be hosted across multiple cloud providers (e.g., AWS and Azure simultaneously).
TRUE
Explanation
Incorrect.
Correct answer
FALSE
Explanation
Correct. An account is tied to one region and one cloud provider.
Overall explanation
While you can have multiple accounts in different clouds, a single account is fixed to one location. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Account and Data Sharing
Question 88
Skipped
In Snowflake, which role is recommended for creating and managing users and roles?
SYSADMIN
Explanation
Focuses on data objects.
Correct answer
USERADMIN
Explanation
Correct. Specifically designed for user and role administration.
ACCOUNTADMIN
Explanation
Too powerful for daily user management.
SECURITYADMIN
Explanation
Focuses on grants and policies.
Overall explanation
USERADMIN is the 'lowest' role in the hierarchy that can create and manage other users. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 89
Skipped
Which of the following URL types are used to access files in an internal stage? (Select 3)
Correct selection
Pre-signed URL
Explanation
Correct. Allows time-limited access without a login.
Database URL
Explanation
Incorrect. Not a valid Snowflake file access type.
External URL
Explanation
Incorrect. Used for external stages.
Correct selection
File URL
Explanation
Correct. A permanent URL requiring authentication.
Correct selection
Scoped URL
Explanation
Correct. Tied to the current session.
Overall explanation
Snowflake provides three specific URL types for stage file access depending on security and persistence needs. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-files
Domain
Data Movement
Question 90
Skipped
In the Snowflake RBAC model, if Role A is granted to Role B, which statement is true?
Correct answer
Role B inherits all privileges of Role A.
Explanation
Correct. This creates a role hierarchy.
Role B can no longer access the warehouse.
Explanation
Incorrect.
Role A inherits all privileges of Role B.
Explanation
Incorrect.
Both roles are deleted.
Explanation
Incorrect.
Overall explanation
Role hierarchy allows for efficient management of permissions by 'nesting' roles. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 91
Skipped
Which of the following is TRUE about 'External Tables'?
Correct answer
They allow you to use Snowflake to query data in Parquet or CSV format sitting in S3.
Explanation
Correct. Great for data lake integration.
They store data inside Snowflake micro-partitions.
Explanation
Incorrect. Data stays in cloud storage.
They support the same performance as internal tables.
Explanation
Incorrect. They are usually slower.
They cannot be joined with internal tables.
Explanation
Incorrect. They can be joined freely.
Overall explanation
External tables are a bridge to your data lake, allowing SQL access without moving the files. Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro
Domain
Data Movement
Question 92
Skipped
Which of the following is a benefit of the 'Accountadmin' role?
It is the default role for all new users.
Explanation
No, PUBLIC is.
It is the only role that can write SQL.
Explanation
No.
Correct answer
It has the ability to manage all aspects of the Snowflake account including billing and security.
Explanation
Correct. The ultimate power in the account.
It is not needed for Enterprise edition.
Explanation
No.
Overall explanation
ACCOUNTADMIN should be used sparingly and protected with MFA due to its total control. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 93
Skipped
Which of the following is a 'metadata' operation that does NOT require a running warehouse? (Select 2)
Correct selection
SELECT count(*) FROM table (with no filters).
Explanation
Correct. Snowflake stores row counts in metadata.
Correct selection
SHOW TABLES.
Explanation
Correct. Metadata-only operation.
UPDATE table SET col = 1.
Explanation
Incorrect. Requires compute.
SELECT * FROM table LIMIT 10.
Explanation
Incorrect. Requires compute.
Overall explanation
The Cloud Services layer can answer many metadata queries without waking up the compute nodes. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 94
Skipped
Which of the following is TRUE about 'Inbound Shares'?
Inbound shares are only available in Business Critical edition.
Explanation
No.
Consumers can clone an inbound share into a permanent table.
Explanation
Incorrect. You cannot clone a shared database directly.
Correct answer
Inbound shares do NOT count against the consumer's storage billing.
Explanation
Correct. The provider pays for storage.
Consumers can edit the data in an inbound share.
Explanation
No, it is read-only.
Overall explanation
Data sharing is storage-free for the consumer; they only pay for the compute used to query it. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 95
Skipped
What is 'Vertical Scaling' in Snowflake?
Adding more clusters to a warehouse.
Explanation
No, that is Horizontal.
Correct answer
Resizing a warehouse to a larger size (e.g., Small to Medium).
Explanation
Correct. Provides more RAM and CPU per node.
Adding more columns to a table.
Explanation
No.
Moving data to a different cloud.
Explanation
No.
Overall explanation
Scale-up (Vertical) makes individual large queries run faster. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 96
Skipped
What is the function of the 'Object Tagging' feature?
To rename objects more easily.
Explanation
Incorrect.
Correct answer
To assign metadata to objects for data governance and classification.
Explanation
Correct. Allows tracking sensitive data.
To speed up data ingestion.
Explanation
Incorrect.
To share data with other accounts.
Explanation
Incorrect.
Overall explanation
Tags allow admins to track sensitive data (e.g., PII) and apply policies like masking. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 97
Skipped
What is the minimum amount of data Snowflake charges for storage?
1 GB.
Explanation
No.
1 MB.
Explanation
No.
Per query.
Explanation
No.
Correct answer
Per Average Monthly Byte.
Explanation
Correct. It is calculated as the average daily use over a month.
Overall explanation
Storage costs are based on the average daily amount of data stored in tables, stages, and fail-safe. Ref: https://docs.snowflake.com/en/user-guide/cost-understanding-storage
Domain
Account and Data Sharing
Question 98
Skipped
When creating an 'External Stage' for S3, which object is recommended for managing credentials securely?
Correct answer
Storage Integration.
Explanation
Correct. It avoids hardcoding AWS keys in SQL.
Network Policy.
Explanation
No.
Resource Monitor.
Explanation
No.
Security Integration.
Explanation
No.
Overall explanation
Storage Integrations delegate authentication to the cloud provider's IAM service. Ref: https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration
Domain
Security
Question 99
Skipped
True or False: Snowflake 'Shares' can be shared with other Shares (Nested Sharing).
Correct answer
FALSE
Explanation
Correct. You cannot share a database that was shared with you.
TRUE
Explanation
No.
Overall explanation
Snowflake prevents 're-sharing' to maintain control and clear ownership of data. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 100
Skipped
Which of the following are 'Actions' in Snowpark that trigger a query execution? (Select 3)
.filter()
Explanation
Incorrect. This is a transformation.
.select()
Explanation
Incorrect. This is a transformation.
Correct selection
.collect()
Explanation
Correct. Returns data to the client.
Correct selection
.show()
Explanation
Correct. Displays the data in the console.
Correct selection
.count()
Explanation
Correct. Returns the number of rows.
Overall explanation
Snowpark uses lazy evaluation; transformations are only executed when an action is called. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 101
Skipped
You are configuring Multi-Factor Authentication (MFA). Which statements correctly describe Snowflake's MFA? (Select 2)
Correct selection
Snowflake uses Duo Security for MFA.
Explanation
Correct. This is the native integration.
MFA is only available for the ACCOUNTADMIN role.
Explanation
Incorrect. It can be used by any user.
Correct selection
Users must self-enroll through the Snowflake web interface.
Explanation
Correct. Admins cannot enroll users; users must do it themselves.
MFA replaces the need for a password.
Explanation
Incorrect. It is a second factor of authentication.
Overall explanation
MFA provides a critical layer of security and is powered by Duo Security for all Snowflake users. Ref: https://docs.snowflake.com/en/user-guide/security-mfa
Domain
Security
Question 102
Skipped
A retail store wants to share data with a company that does NOT have a Snowflake account. What should they create?
A Secure View
Explanation
Requires a Snowflake account to query.
A Data Exchange
Explanation
Requires Snowflake accounts.
A Direct Share
Explanation
Requires a Snowflake account.
Correct answer
A Reader Account
Explanation
Correct. The provider pays for the consumer's compute.
Overall explanation
Reader accounts allow providers to share data with non-Snowflake customers at the provider's expense. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 103
Skipped
Which of the following describes 'Snowpipe'?
A tool for bulk loading data once a day.
Explanation
Incorrect.
A command-line tool for managing stages.
Explanation
Incorrect.
Correct answer
A service that allows for continuous, automated loading of data from stages.
Explanation
Correct. Uses serverless compute.
A data sharing protocol.
Explanation
Incorrect.
Overall explanation
Snowpipe is designed for 'near-real-time' ingestion as files arrive in cloud storage. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
Domain
Data Movement
Question 104
Skipped
A retail company wants to analyze geography data. Which data type should they use for latitude and longitude?
Correct answer
GEOGRAPHY
Explanation
Correct. Stores geospatial data as points, lines, or polygons.
VARIANT
Explanation
No.
VARCHAR
Explanation
No.
FLOAT
Explanation
Can work but doesn't support geospatial functions.
Overall explanation
The GEOGRAPHY data type is optimized for calculating distances and areas on the earth's surface. Ref: https://docs.snowflake.com/en/sql-reference/data-types-geospatial
Domain
Storage and Protection
Question 105
Skipped
Which protocol does Snowflake use for its native 'Single Sign-On' (SSO) integration?
OAuth 2.0
Explanation
Used for API access, not standard SSO.
Correct answer
SAML 2.0
Explanation
Correct. The standard for web-based federated identity.
LDAP
Explanation
Incorrect.
Kerberos
Explanation
Incorrect.
Overall explanation
SAML 2.0 is the industry standard used by Snowflake for integrating with Okta, Azure AD, etc. Ref: https://docs.snowflake.com/en/user-guide/admin-security-sso
Domain
Security
Question 106
Skipped
What does the 'ON_ERROR = ABORT_STATEMENT' parameter do in a COPY INTO statement?
Correct answer
Stops the entire load if a single error is found in a file.
Explanation
Correct. Ensures 'all or nothing' data integrity.
Deletes the table.
Explanation
No.
Skips the file with the error and loads others.
Explanation
No, that is 'CONTINUE'.
Ignores the error and continues.
Explanation
No.
Overall explanation
Aborting on error is used when data quality is critical and any error must be addressed. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 107
Skipped
Which of the following is a TRUE statement about 'Fail-safe'? (Select 2)
Correct selection
It is only available for Permanent tables.
Explanation
Correct. Transient and Temporary tables do not have Fail-safe.
It can be disabled by the ACCOUNTADMIN to save money.
Explanation
Incorrect. It is a mandatory feature for permanent tables.
Users can query Fail-safe data using the 'AT' keyword.
Explanation
Incorrect. Only Time Travel data can be queried.
Correct selection
It provides 7 days of data protection after Time Travel expires.
Explanation
Correct.
Overall explanation
Fail-safe is a non-configurable safety net for permanent data recovery. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 108
Skipped
Which of the following is TRUE about 'Dynamic Data Masking'?
It only works for the ACCOUNTADMIN role.
Explanation
Incorrect.
It is a free feature in Standard Edition.
Explanation
Incorrect. Enterprise+.
Correct answer
It applies masking logic at query time based on the user's role.
Explanation
Correct. Security-on-the-fly.
It changes the data stored on the disk.
Explanation
Incorrect. Data stays the same.
Overall explanation
Masking allows sensitive data to be stored securely while controlling visibility for different audiences. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 109
Skipped
A retail analyst needs to restore a table that was accidentally dropped 24 hours ago. Which feature allows this?
Zero-copy Cloning
Explanation
Only works if the table still exists.
Re-running the ETL
Explanation
Slow and costly.
Fail-safe
Explanation
Requires Snowflake support intervention.
Correct answer
UNDROP TABLE command
Explanation
Correct. Uses Time Travel to restore the object.
Overall explanation
UNDROP leverages Time Travel to recover dropped schemas, tables, or databases instantly. Ref: https://docs.snowflake.com/en/sql-reference/sql/undrop-table
Domain
Storage and Protection
Question 110
Skipped
Which methods can be used to authenticate to Snowflake via SnowSQL? (Select 3)
Correct selection
SSO via SAML 2.0.
Explanation
Correct. Federated authentication.
Anonymous access.
Explanation
Incorrect. Not supported.
Correct selection
Key Pair Authentication.
Explanation
Correct. Uses public/private keys.
Biometric authentication.
Explanation
Incorrect. Not natively supported by SnowSQL.
Correct selection
Username and Password.
Explanation
Correct. Basic authentication.
Overall explanation
SnowSQL supports various authentication methods including basic, federated (SSO), and key-pair for automated scripts. Ref: https://docs.snowflake.com/en/user-guide/snowsql-config
Domain
Security
Question 111
Skipped
A 'Resource Monitor' can be set at which levels? (Select 2)
User level.
Explanation
Incorrect.
Database level.
Explanation
Incorrect.
Correct selection
Account level.
Explanation
Correct. Controls total account spending.
Correct selection
Warehouse level.
Explanation
Correct. Controls specific warehouse spending.
Overall explanation
Resource monitors are used to manage credit consumption at both the global account level and for specific warehouses. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 112
Skipped
Which component of Snowflake architecture handles 'Metadata Management'?
Compute Layer.
Explanation
Executes calculations.
Storage Layer.
Explanation
Stores raw data.
Virtual Warehouse.
Explanation
Same as compute.
Correct answer
Cloud Services Layer.
Explanation
Correct. Stores info about partitions, stats, and security.
Overall explanation
Metadata management is a service provided by the Cloud Services layer, making it available even when warehouses are off. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 113
Skipped
Which component of the Snowflake architecture ensures that queries are 'ACID' compliant?
Storage Layer
Explanation
No.
Virtual Warehouse
Explanation
No.
SnowSQL
Explanation
No.
Correct answer
Cloud Services Layer
Explanation
Correct. Specifically the Transaction Manager.
Overall explanation
Snowflake's Cloud Services layer manages all transactions to ensure consistency across the platform. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 114
Skipped
Which function is used to convert a string to a VARIANT?
FLATTEN()
Explanation
Used to explode arrays.
Correct answer
PARSE_JSON()
Explanation
Correct. Validates and converts strings to semi-structured format.
CAST_AS_VARIANT()
Explanation
Incorrect.
TO_JSON()
Explanation
Incorrect.
Overall explanation
PARSE_JSON is the standard way to work with raw JSON strings in Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/functions/parse_json
Domain
Storage and Protection
Question 115
Skipped
What is the maximum 'Time Travel' period for a 'Transient' database?
Correct answer
1 day.
Explanation
Correct. Transient objects do not support extended Time Travel.
90 days.
Explanation
No.
7 days.
Explanation
No.
0 days.
Explanation
No.
Overall explanation
Transient objects are designed for data that is easily reproducible and don't need high protection levels. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 116
Skipped
In a retail database, which command is used to see the status of all 'Network Policies'?
LIST POLICIES.
Explanation
No.
Correct answer
SHOW NETWORK POLICIES.
Explanation
Correct. Lists all policies in the account.
DESCRIBE ACCOUNT.
Explanation
No.
SHOW POLICIES.
Explanation
No.
Overall explanation
Management of network security begins with visibility into the existing policies. Ref: https://docs.snowflake.com/en/sql-reference/sql/show-network-policies
Domain
Security
Question 117
Skipped
What is the purpose of 'Zero-copy Cloning' for a retail development team? (Select 2)
Correct selection
To quickly create a 'Dev' environment from 'Prod'.
Explanation
Correct. It is nearly instantaneous.
Correct selection
To create a sandbox for testing without duplicating storage costs.
Explanation
Correct. Only changed data is stored.
To improve query performance.
Explanation
Incorrect.
To back up data to a different cloud provider.
Explanation
Incorrect.
Overall explanation
Cloning is a primary feature for DevOps in Snowflake, allowing safe experimentation. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection