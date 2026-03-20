Question 1
Correct
Which of the following describes 'Object Tagging'?
A way to rename tables.
Explanation
No.
A type of data sharing.
Explanation
No.
Your answer is correct
A feature for data governance that allows you to label objects (like sensitive columns) for tracking.
Explanation
Correct. Used for data classification.
A way to speed up queries.
Explanation
No.
Overall explanation
Object tagging is a key component of Snowflake's data governance framework. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 2
Skipped
In a retail scenario, you need to search for a specific 'Transaction ID' in a table with billions of rows. Which feature would most effectively speed up this specific 'point lookup'?
Automatic Clustering
Explanation
Helps, but SOS is faster for point lookups.
Query Acceleration Service
Explanation
Better for large scans.
Materialized Views
Explanation
Better for aggregations.
Correct answer
Search Optimization Service (SOS)
Explanation
Correct. It acts like an index for equality searches in large tables.
Overall explanation
Search Optimization Service significantly reduces the time to find single rows in massive datasets. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 3
Skipped
Which function is used to convert a JSON-formatted string into a VARIANT type?
CAST_JSON().
Explanation
No.
TO_VARIANT().
Explanation
Generic.
Correct answer
PARSE_JSON().
Explanation
Correct. Specifically validates and parses JSON strings.
STRTOK_TO_ARRAY().
Explanation
No.
Overall explanation
PARSE_JSON is the standard way to ingest semi-structured strings into a Snowflake-native format. Ref: https://docs.snowflake.com/en/sql-reference/functions/parse_json
Domain
Storage and Protection
Question 4
Skipped
A security admin wants to enforce MFA for all users in the account. Which statement is TRUE regarding Snowflake's MFA support?
Correct answer
MFA is powered by Duo Security and users must self-enroll via the Snowflake web interface.
Explanation
Correct behavior.
MFA is only available in the Business Critical edition.
Explanation
Available in all editions.
Snowflake manages its own MFA app.
Explanation
Snowflake uses Duo Security.
MFA replaces the need for a password.
Explanation
It is a second factor.
Overall explanation
Snowflake integrates with Duo Security to provide MFA across all editions at no extra cost. Ref: https://docs.snowflake.com/en/user-guide/security-mfa
Domain
Security
Question 5
Skipped
What is the 'Purge' option in the 'COPY INTO' command used for?
To clear the metadata cache.
Explanation
No.
To drop the table if the load fails.
Explanation
No.
Correct answer
To delete the source files from the stage after they have been successfully loaded.
Explanation
Correct. Helps manage stage storage costs.
To delete data from the table after loading.
Explanation
No.
Overall explanation
Using PURGE=TRUE is a best practice for keeping internal stages clean after data ingestion. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 6
Skipped
Which of the following can be used as a 'source' for a 'Stream' in Snowflake?
Correct selection
External Table
Explanation
Correct.
Correct selection
View
Explanation
Correct (if underlying tables support it).
Correct selection
Directory Table
Explanation
Correct.
Correct selection
Table
Explanation
Correct.
Overall explanation
Streams can track changes on tables, directory tables, and even views. Ref: https://docs.snowflake.com/en/user-guide/streams-intro
Domain
Account and Data Sharing
Question 7
Skipped
Which command is used to grant a role to a user?
ASSIGN ROLE ... TO USER
Explanation
No.
Correct answer
GRANT ROLE ... TO USER
Explanation
Correct.
GIVE ROLE ... TO USER
Explanation
No.
SET ROLE ... FOR USER
Explanation
No.
Overall explanation
GRANT is the standard SQL command for managing permissions and role assignments in Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/sql/grant-role
Domain
Security
Question 8
Skipped
Which function is used to flatten a VARIANT that contains a 'Nested' object (not an array)?
EXPLODE().
Explanation
No.
UNNEST().
Explanation
No.
Correct answer
FLATTEN().
Explanation
Correct. (FLATTEN works for both arrays and objects).
STRIP_OUTER().
Explanation
No.
Overall explanation
FLATTEN is the versatile tool for all semi-structured expansion needs. Ref: https://docs.snowflake.com/en/sql-reference/functions/flatten
Domain
Data Movement
Question 9
Skipped
Which feature should be used to provide a specific, masked version of data to a user based on their role?
Row Access Policy
Explanation
Filters rows.
Network Policy
Explanation
No.
Correct answer
Dynamic Data Masking
Explanation
Correct. Masks specific columns at query time.
Tri-Secret Secure
Explanation
No.
Overall explanation
Dynamic Data Masking ensures sensitive data like SSNs are only seen by authorized roles. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 10
Skipped
Which of the following are benefits of 'Micro-partitions'? (Select all that apply)
Correct selection
They are automatically managed by Snowflake.
Explanation
Correct.
Correct selection
They allow for extremely efficient pruning.
Explanation
Correct.
Correct selection
They are immutable (cannot be changed).
Explanation
Correct.
They store data in a row-based format.
Explanation
No. They are columnar.
Overall explanation
Snowflake's columnar storage in micro-partitions is the key to its performance. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 11
Skipped
What is the 'Query Profile' tool used for?
To manage network policies.
Explanation
No.
To change user passwords.
Explanation
No.
Correct answer
To analyze the execution plan and identify bottlenecks in a query.
Explanation
Correct.
To create new tables.
Explanation
No.
Overall explanation
The Query Profile provides a visual breakdown of where time and resources were spent during a query. Ref: https://docs.snowflake.com/en/user-guide/ui-query-profile
Domain
Performance and Warehouses
Question 12
Skipped
Which component of Snowflake manages 'Transactional Integrity' (ACID compliance)?
Storage Layer.
Explanation
No.
Correct answer
Cloud Services Layer.
Explanation
Correct. This layer manages all metadata and transactions.
Query Profiler.
Explanation
No.
Compute Layer.
Explanation
No.
Overall explanation
The Cloud Services layer acts as the coordinator, ensuring that all data changes are atomic and consistent. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 13
Skipped
Which component of the Snowflake architecture ensures that a query from User A does not see uncommitted changes from User B?
Virtual Warehouse
Explanation
This is compute.
Storage Layer
Explanation
Stores data.
Compute Layer
Explanation
Executes queries.
Correct answer
Cloud Services Layer (Transaction Management)
Explanation
Correct. Handles ACID compliance and MVCC.
Overall explanation
Transaction management in the Cloud Services layer handles concurrency and state. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 14
Skipped
A user needs to access a file in a stage that must be valid for the duration of their specific session only. Which URL should be generated?
Correct answer
Scoped URL
Explanation
Correct. It is temporary and tied to the specific Snowflake session.
Pre-signed URL
Explanation
Can last longer than a session and is public.
Internal URL
Explanation
Not a standard term.
File URL
Explanation
This is a permanent URL.
Overall explanation
Scoped URLs are ideal for internal applications where access should expire with the user session. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-files
Domain
Data Movement
Question 15
Skipped
True or False: Snowflake supports 'Snowpark' code execution in Python, Java, and Scala.
FALSE
Explanation
These three languages are supported.
Correct answer
TRUE
Explanation
Correct.
Overall explanation
Snowpark provides a DataFrame API for these languages, allowing developers to build complex pipelines. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 16
Skipped
Which of the following is TRUE about 'Micro-partitions'?
They are row-based.
Explanation
No.
They are stored in the Cloud Services layer.
Explanation
No.
They are 1GB in size.
Explanation
No.
Correct answer
They are immutable (cannot be changed).
Explanation
Correct. (Updates create NEW micro-partitions).
Overall explanation
Immutability is key to how Time Travel and Cloning work without data corruption. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 17
Skipped
Which of the following is TRUE about 'Network Policies' and 'Public IP' addresses?
Network policies are only for the Snowflake UI.
Explanation
No, they affect all drivers/APIs.
Network policies can only allow single IPs, not ranges.
Explanation
No.
Snowflake only supports Private Link.
Explanation
No.
Correct answer
Network policies allow or block access based on the source IP of the request.
Explanation
Correct.
Overall explanation
Network policies provide the first line of defense at the network perimeter. Ref: https://docs.snowflake.com/en/user-guide/network-policies
Domain
Security
Question 18
Skipped
Which characteristic is unique to 'Transient' tables compared to 'Temporary' tables?
They have no Fail-safe.
Explanation
Both have no Fail-safe.
They are stored in the Cloud Services layer.
Explanation
No.
They support 90 days of Time Travel.
Explanation
Neither supports more than 1 day.
Correct answer
They persist across different sessions and can be seen by other users.
Explanation
Correct. (Temporary tables are session-bound).
Overall explanation
Transient tables are for 'permanent but low-protection' data, whereas temporary are 'volatile'. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 19
Skipped
A user wants to clone a table that has 'Time Travel' data. Does the clone include the historical data of the original table?
Yes, but only if it's a 'Deep Clone'.
Explanation
Plausible (standard in other DBs), but Snowflake only has Zero-copy cloning.
Correct answer
No, the clone only contains the data from the point in time it was created.
Explanation
Correct. The clone starts its own new history.
Yes, the clone includes all historical data for the full retention period.
Explanation
Plausible, but cloning only copies the metadata of the current state.
No, unless the CLONE_HISTORY parameter is TRUE.
Explanation
No.
Overall explanation
Cloning creates a new object; while it shares the base micro-partitions, its Time Travel lineage begins at creation. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 20
Skipped
You are a Data Engineer at a retail company. During a massive sales event, the Marketing team reports that dashboards are slow. The Query Profile shows 'Queued Overload'. What is the most cost-effective solution?
Enable Search Optimization Service.
Explanation
This is for point-lookups, not concurrency.
Create a Materialized View.
Explanation
This helps with aggregations, not overall warehouse queuing.
Correct answer
Add more clusters to a Multi-cluster warehouse (Scale-out).
Explanation
Correct. Adding clusters handles more concurrent queries simultaneously.
Increase the Warehouse size from Small to Large.
Explanation
This improves performance for complex queries but not concurrency.
Overall explanation
Scale-out (multi-cluster) is the standard solution for high concurrency issues. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 21
Skipped
Which component of the 'Cloud Services' layer is responsible for choosing the most efficient way to execute a query (e.g., join order)?
Correct answer
Optimizer
Explanation
Correct. Uses metadata to plan query execution.
Metadata Manager
Explanation
Stores statistics.
Warehouse Manager
Explanation
Manages compute.
Access Control
Explanation
Handles security.
Overall explanation
The Snowflake Optimizer is cost-based and leverages micro-partition metadata to plan queries. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 22
Skipped
A user wants to move a file from an Internal Stage back to their local laptop. Which command should they use?
DOWNLOAD.
Explanation
Plausible, but GET is the SQL command.
Correct answer
GET.
Explanation
Correct.
EXTRACT.
Explanation
No.
PUT.
Explanation
No, that's for upload.
Overall explanation
GET is the inverse of PUT and is executed via SnowSQL. Ref: https://docs.snowflake.com/en/sql-reference/sql/get
Domain
Data Movement
Question 23
Skipped
Which command is used to download files from an internal stage to your local computer?
PUT
Explanation
Used for uploading.
DOWNLOAD
Explanation
Not a command.
COPY INTO
Explanation
Used for tables.
Correct answer
GET
Explanation
Correct.
Overall explanation
GET is the counterpart to PUT and is used for data export to local systems. Ref: https://docs.snowflake.com/en/sql-reference/sql/get
Domain
Data Movement
Question 24
Skipped
Which component of the Snowflake architecture is responsible for 'Query Optimization' and 'Access Control'?
Correct answer
Cloud Services Layer
Explanation
Correct. This is the brain of Snowflake.
Compute Layer
Explanation
Executes queries.
Storage Layer
Explanation
Stores data.
Virtual Warehouse
Explanation
This is compute.
Overall explanation
The Cloud Services layer manages the entire system, including security, metadata, and optimization. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 25
Skipped
What is the default behavior of Snowflake when a 'Data Loading' error occurs and no error handling parameter is specified?
The load continues and ignores the error.
Explanation
No.
The error is fixed automatically.
Explanation
No.
The data is moved to a 'DLQ' table.
Explanation
No.
Correct answer
The load fails and rolls back the entire operation.
Explanation
Correct. Default is ABORT_STATEMENT.
Overall explanation
By default, Snowflake is strict and will stop the entire load if a single error is found. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 26
Skipped
Which of the following is TRUE about the 'Result Cache'?
It lasts for 30 days.
Explanation
It lasts for 24 hours.
Correct answer
It is shared among all users in the account.
Explanation
Correct. If two users run the same query, both can benefit.
It is stored in the Virtual Warehouse.
Explanation
Stored in Cloud Services.
It is lost when the Warehouse is suspended.
Explanation
No. It persists beyond suspension.
Overall explanation
Result caching is global and helps reduce costs for repetitive queries across an entire organization. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 27
Skipped
What happens to a 'Temporary Table' when the Snowflake session is closed?
It is moved to Fail-safe.
Explanation
Temporary tables have no Fail-safe.
It remains for 24 hours of Time Travel.
Explanation
Access is lost immediately when the session ends.
It is converted to a Permanent table.
Explanation
No.
Correct answer
It is automatically dropped and the storage is purged.
Explanation
Correct. Its lifecycle is tied to the session.
Overall explanation
Temporary tables are perfect for session-specific ETL work that does not need to persist. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 28
Skipped
You are a Data Engineer and a load fails with the error 'Numeric value not recognized'. Which tool or function would you use to find the exact line in the CSV that caused the error?
QUERY_HISTORY.
Explanation
Shows the SQL but not the specific data error.
SYSTEM$PIPE_STATUS.
Explanation
Used for Snowpipe health.
DESCRIBE TABLE.
Explanation
Shows the structure, not the data.
Correct answer
VALIDATE table function.
Explanation
Correct. It returns details of errors from the last load.
Overall explanation
The VALIDATE function is the primary way to debug data quality issues during bulk loading. Ref: https://docs.snowflake.com/en/sql-reference/functions/validate
Domain
Data Movement
Question 29
Skipped
A company wants to share data with a consumer in a different Cloud Region (e.g., AWS US-East to AWS EU-West). What is required first?
Correct answer
Database Replication to the target region.
Explanation
Correct. You can only share data that exists in the same region as the consumer.
A Direct Shared Link.
Explanation
No.
VPC Peering.
Explanation
No.
A Cross-Region Warehouse.
Explanation
No.
Overall explanation
Snowflake Data Sharing is region-bound. Replication is the prerequisite for cross-region sharing. Ref: https://docs.snowflake.com/en/user-guide/database-replication-intro
Domain
Account and Data Sharing
Question 30
Skipped
Which role is required to 'Create' a 'Share' for Data Sharing?
DATAADMIN.
Explanation
No.
SECURITYADMIN.
Explanation
No.
SYSADMIN.
Explanation
No.
Correct answer
ACCOUNTADMIN.
Explanation
Correct. (Sharing is an account-level responsibility).
Overall explanation
Sharing involves account-to-account trust, so it is limited to the top role. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 31
Skipped
A retail company needs to allow a third-party vendor to download product images from a Snowflake internal stage without giving them a Snowflake login. Which URL type should be used?
Stage URL
Explanation
Not a standard URL type.
Correct answer
Pre-signed URL
Explanation
Correct. It includes an access token and allows external access for a limited time.
File URL
Explanation
Requires a Snowflake session.
Scoped URL
Explanation
Expires when the session ends.
Overall explanation
Pre-signed URLs are designed for sharing files with non-Snowflake users temporarily. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-files
Domain
Data Movement
Question 32
Skipped
True or False: A 'Transient Table' can be converted into a 'Permanent Table' using an ALTER TABLE command.
TRUE
Explanation
No.
Correct answer
FALSE
Explanation
Correct. The table type is set at creation and cannot be changed.
Overall explanation
To change a table type, you must create a new table (e.g., using CREATE TABLE ... AS SELECT). Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 33
Skipped
True or False: Snowflake allows you to use 'External Functions' to call code running in an AWS Lambda or Azure Function.
FALSE
Explanation
External functions allow for extensibility.
Correct answer
TRUE
Explanation
Correct.
Overall explanation
External functions allow Snowflake to interact with external services for processing or data enrichment. Ref: https://docs.snowflake.com/en/user-guide/external-functions-intro
Domain
Account and Data Sharing
Question 34
Skipped
A user runs: SELECT COUNT(*) FROM large_table (with no filters). Why does this query return instantly without a warehouse?
Because of the Result Cache
Explanation
Result cache requires a previous execution.
Because the table is small
Explanation
Query applies to large tables too.
Correct answer
Because the Metadata Manager in Cloud Services stores the row count for every table.
Explanation
Correct. Simple aggregates like COUNT, MIN, and MAX on the table level are stored in metadata.
Because of Search Optimization
Explanation
Search optimization is for point lookups.
Overall explanation
The Metadata Manager tracks statistics for micro-partitions and tables, allowing certain queries to run 'warehouse-less'. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 35
Skipped
What is the primary purpose of 'SnowSQL'?
Correct answer
A command-line client for executing SQL and managing files (PUT/GET).
Explanation
Correct.
A graphical user interface for Snowflake.
Explanation
No.
A tool for data visualization.
Explanation
No.
A search engine for documentation.
Explanation
No.
Overall explanation
SnowSQL is the powerful CLI tool used for automation and local file management. Ref: https://docs.snowflake.com/en/user-guide/snowsql
Domain
Data Movement
Question 36
Skipped
Which role is responsible for creating and managing 'Organization-wide' accounts and billing?
SYSADMIN
Explanation
Manages compute and databases.
ACCOUNTADMIN
Explanation
Limited to a single account.
Correct answer
ORGADMIN
Explanation
Correct. This role manages all accounts in a Snowflake organization.
USERADMIN
Explanation
Manages users and roles.
Overall explanation
The ORGADMIN role allows for the creation of accounts across different cloud providers and regions. Ref: https://docs.snowflake.com/en/user-guide/admin-user-management
Domain
Account and Data Sharing
Question 37
Skipped
Which of the following is a key difference between 'Information Schema' and 'Account Usage'?
Correct answer
Account Usage includes data for dropped objects.
Explanation
Correct. Information Schema only shows current objects.
Information Schema has more latency.
Explanation
No. Information Schema is real-time.
Information Schema has longer retention.
Explanation
No. Account Usage has 1 year.
Account Usage is only for SYSADMIN.
Explanation
No.
Overall explanation
Account Usage is an audit-focused share with 365 days of history. Ref: https://docs.snowflake.com/en/sql-reference/account-usage
Domain
Account and Data Sharing
Question 38
Skipped
Which of the following is a supported 'Semi-structured' data type in Snowflake?
MAP
Explanation
Not a separate type in Snowflake.
Correct selection
OBJECT
Explanation
Correct.
Correct selection
ARRAY
Explanation
Correct.
Correct selection
VARIANT
Explanation
Correct.
Overall explanation
Snowflake uses ARRAY, OBJECT, and the 'catch-all' VARIANT type for semi-structured data. Ref: https://docs.snowflake.com/en/sql-reference/data-types-semistructured
Domain
Storage and Protection
Question 39
Skipped
What is the default 'Minimum' billing time for a Virtual Warehouse when it is started?
1 hour.
Explanation
No.
5 minutes.
Explanation
No.
Correct answer
60 seconds.
Explanation
Correct. After the first minute, it is per-second.
1 second.
Explanation
No.
Overall explanation
Snowflake has a 60-second minimum charge to discourage frequent start/stop cycles that don't add value. Ref: https://docs.snowflake.com/en/user-guide/cost-understanding-compute
Domain
Performance and Warehouses
Question 40
Skipped
Which command is used to assign a specific role to a user in Snowflake?
ALTER USER ... SET ROLE
Explanation
No.
ADD ROLE <role_name> TO <user_name>
Explanation
No.
SET ROLE <role_name> FOR <user_name>
Explanation
No.
Correct answer
GRANT ROLE <role_name> TO USER <user_name>
Explanation
Correct.
Overall explanation
Snowflake follows standard SQL syntax for granting roles to users. Ref: https://docs.snowflake.com/en/sql-reference/sql/grant-role
Domain
Security
Question 41
Skipped
You notice 'Local Disk Spilling' in a Query Profile for a retail inventory report. What is the immediate recommendation?
Correct answer
Increase the size of the Virtual Warehouse.
Explanation
Correct. Spilling means the warehouse RAM/SSD is full; a larger size provides more memory.
Create a Cluster Key.
Explanation
This helps with pruning but not with memory overflow.
Decrease the size of the Virtual Warehouse.
Explanation
This would make spilling worse.
Turn on the Query Acceleration Service.
Explanation
QAS helps with scans, not typically with join/agg spilling.
Overall explanation
Increasing warehouse size provides more local resources (RAM and SSD) to prevent data spilling to disk. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 42
Skipped
A company needs to load data from Azure Blob Storage. Which 'Stage' type must they use?
Correct answer
External Stage.
Explanation
Correct.
User Stage.
Explanation
No.
Table Stage.
Explanation
No.
Internal Stage.
Explanation
No.
Overall explanation
External stages are the bridge to cloud-native storage. Ref: https://docs.snowflake.com/en/user-guide/data-load-azure
Domain
Data Movement
Question 43
Skipped
Which of the following is TRUE about Snowpark's DataFrame API?
It is always evaluated immediately (Eager evaluation).
Explanation
It uses Lazy evaluation.
Correct answer
It translates Python/Java/Scala code into SQL for execution.
Explanation
Correct. It pushes the work to the warehouse.
It cannot handle semi-structured data.
Explanation
It is excellent for JSON/Variant data.
It requires a Medium warehouse or larger.
Explanation
Works on any warehouse size.
Overall explanation
Snowpark DataFrames are evaluated lazily, meaning the query is only sent to Snowflake when an action is requested. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 44
Skipped
Which of the following is NOT a supported language for writing Snowflake Stored Procedures?
JavaScript
Explanation
Supported.
SQL
Explanation
Supported.
Python
Explanation
Supported.
Correct answer
C++
Explanation
Not supported.
Overall explanation
Snowflake supports SQL, JavaScript, Python, Java, and Scala for stored procedures. Ref: https://docs.snowflake.com/en/sql-reference/stored-procedures-usage
Domain
Account and Data Sharing
Question 45
Skipped
Which scaling policy should be used if a company wants to minimize the number of clusters used, even if it means some queries have to wait?
Batch.
Explanation
Plausible name, but not a policy.
Conservative.
Explanation
No.
Standard.
Explanation
No (Performance first).
Correct answer
Economy.
Explanation
Correct. (Prioritizes cluster load).
Overall explanation
Economy mode optimizes for cost by avoiding spinning up new clusters for short bursts. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 46
Skipped
Which of the following describes 'Search Optimization Service' (SOS) behavior regarding DML?
Correct answer
Snowflake automatically manages and bills for background maintenance of search access paths.
Explanation
Correct.
SOS prevents any further DML until the index is updated.
Explanation
No, it's asynchronous.
SOS only works on static tables.
Explanation
No.
SOS must be manually refreshed after every INSERT.
Explanation
No, it's automatic.
Overall explanation
SOS is a serverless service that maintains its own internal data structures without user intervention. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 47
Skipped
In Snowpark, what does 'Lazy Evaluation' mean?
Correct answer
The query is only executed when an 'Action' (like collect or show) is called.
Explanation
Correct. Improves efficiency by optimizing the plan first.
Users don't have to write code.
Explanation
No.
The code runs very slowly.
Explanation
No.
The warehouse stays suspended until the user wakes it up manually.
Explanation
No.
Overall explanation
Lazy evaluation allows Snowpark to combine multiple operations into a single optimized SQL query. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 48
Skipped
Which authentication method is specifically required for users to log in via SnowSQL using a private key file instead of a password?
Correct answer
Key Pair Authentication
Explanation
Correct. Requires generating a public/private key pair and assigning the public key to the user.
SAML 2.0 SSO
Explanation
Used for browser-based login.
OAuth 2.0
Explanation
Used for third-party integrations.
MFA with Duo
Explanation
MFA is an extra layer, not a replacement for the key.
Overall explanation
Key pair authentication provides enhanced security for automated scripts and CLI tools. Ref: https://docs.snowflake.com/en/user-guide/key-pair-auth
Domain
Security
Question 49
Skipped
Which privilege is needed for a role to see the 'Query Profile' of a query executed by another user?
OPERATE on the Warehouse.
Explanation
Allows starting/stopping.
USAGE on the Warehouse.
Explanation
Only allows running queries.
Correct answer
MONITOR on the Warehouse.
Explanation
Correct. Provides visibility into all queries on that WH.
SELECT on the Table.
Explanation
No.
Overall explanation
The MONITOR privilege is key for performance tuning and troubleshooting other users' queries. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Performance and Warehouses
Question 50
Skipped
Which role has the power to 'Set' or 'Unset' parameters at the Account level?
SYSADMIN.
Explanation
No.
SECURITYADMIN.
Explanation
No.
Correct answer
ACCOUNTADMIN.
Explanation
Correct.
USERADMIN.
Explanation
No.
Overall explanation
Global configuration is a privilege of the Account Administrator. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 51
Skipped
Which Snowflake feature provides a 64-bit identifier that remains persistent and allows users to access a file in a stage for a specific period without expiring?
Correct answer
File URL
Explanation
Correct. This is a permanent URL that doesn't expire but requires a valid session to access.
Scoped URL
Explanation
This URL expires when the session ends.
Pre-signed URL
Explanation
This URL has an expiration time (default 24h) but allows access without a session.
Internal URL
Explanation
Not a standard Snowflake URL type.
Overall explanation
File URLs are permanent and require Snowflake authentication to access the data. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-files
Domain
Data Movement
Question 52
Skipped
Which view shows the history of 'Login' attempts to the Snowflake account?
USER_LOGINS.
Explanation
No.
Correct answer
LOGIN_HISTORY.
Explanation
Correct.
SESSION_HISTORY.
Explanation
No.
ACCESS_LOGS.
Explanation
No.
Overall explanation
LOGIN_HISTORY is critical for security auditing and tracking failed attempts. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/login_history
Domain
Security
Question 53
Skipped
True or False: You can use 'Snowpipe' to load data from an Internal Stage.
FALSE
Explanation
Snowpipe supports both internal and external stages.
Correct answer
TRUE
Explanation
Correct.
Overall explanation
While most commonly used with S3/Azure/GCP, Snowpipe can also monitor internal stages. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
Domain
Data Movement
Question 54
Skipped
Which of the following describes 'Zero-copy Cloning' storage billing?
Correct answer
You only pay for the unique data modified in the clone.
Explanation
Correct. Shared data is only billed once.
Cloning is free for 30 days.
Explanation
No.
You pay 50% for the clone.
Explanation
No.
You pay for two full copies of the data.
Explanation
No.
Overall explanation
Zero-copy cloning is extremely cost-effective as it only stores the delta between the original and the clone. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 55
Skipped
What is the maximum number of days for the 'Fail-safe' period in a Permanent table?
365 days
Explanation
No.
90 days
Explanation
Time Travel max.
1 day
Explanation
No.
Correct answer
7 days
Explanation
Correct. Fixed period.
Overall explanation
Fail-safe is a non-configurable 7-day period provided for disaster recovery. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 56
Skipped
What is the credit cost of 'Cloud Services' if my warehouses consumed 100 credits today and Cloud Services used 5 credits?
105 credits.
Explanation
No.
Correct answer
100 credits.
Explanation
Correct. (5 is less than 10% of 100, so it is not billed).
100.5 credits.
Explanation
No.
110 credits.
Explanation
No.
Overall explanation
The 10% free tier for Cloud Services covers most standard accounts. Ref: https://docs.snowflake.com/en/user-guide/cost-understanding-compute
Domain
Snowflake Architecture
Question 57
Skipped
A user wants to upload files to a stage using a Python script. Which driver/connector would they typically use?
JDBC Driver
Explanation
Used for Java apps.
Correct answer
Snowflake Connector for Python
Explanation
Correct. Supports all Snowflake operations including PUT.
ODBC Driver
Explanation
Generic database access.
Snowpipe API
Explanation
Used for loading, not uploading files.
Overall explanation
The Python connector is the standard way to automate Snowflake tasks using Python. Ref: https://docs.snowflake.com/en/developer-guide/python-connector/python-connector
Domain
Data Movement
Question 58
Skipped
Which function is used to convert a string that looks like a JSON object into a VARIANT type?
CAST_AS_JSON()
Explanation
Not a standard function.
Correct answer
PARSE_JSON()
Explanation
Correct. Specifically parses strings into structured VARIANT.
TO_VARIANT()
Explanation
Generic conversion.
STRTOK()
Explanation
Used for splitting.
Overall explanation
PARSE_JSON is essential for working with semi-structured data strings. Ref: https://docs.snowflake.com/en/sql-reference/functions/parse_json
Domain
Storage and Protection
Question 59
Skipped
Which of the following commands is used to upload a file from a local Windows machine to a Snowflake stage using SnowSQL?
Correct answer
PUT
Explanation
Correct. Used for uploading local files.
INSERT
Explanation
No.
GET
Explanation
Used for downloading.
COPY INTO
Explanation
Used for loading from stage to table.
Overall explanation
The PUT command is the primary way to move data from a local environment into Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/sql/put
Domain
Data Movement
Question 60
Skipped
Which function is used to check if a specific 'IP address' is being blocked by a network policy?
Correct answer
There is no function; you must check the LOGIN_HISTORY.
Explanation
Correct. (Login history shows the source IP and the reason for failure).
SYSTEM$WHITELIST().
Explanation
No.
SYSTEM$NETWORK_QUERY().
Explanation
Plausible, but incorrect.
SYSTEM$CHECK_IP().
Explanation
No.
Overall explanation
Auditing access attempts is the only way to troubleshoot network policy blocks. Ref: https://docs.snowflake.com/en/user-guide/network-policies
Domain
Security
Question 61
Skipped
A developer wants to use Snowpark Python to process data. Where does the Python code actually execute?
Correct answer
Within the Snowflake Virtual Warehouse
Explanation
Correct. Snowpark code is pushed down and executed inside the warehouse nodes.
On the user's local machine
Explanation
Code is pushed to Snowflake.
On a separate Python-only server
Explanation
Snowpark is integrated into the warehouse.
In the Cloud Services layer
Explanation
Metadata only.
Overall explanation
Snowpark uses a push-down model where the Python/Java/Scala logic runs directly on the warehouse compute nodes. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 62
Skipped
Which command is used to add a new 'Clustering Key' to an existing table?
Correct answer
ALTER TABLE ... CLUSTER BY
Explanation
Correct. This starts the background re-clustering process.
SET CLUSTERING = TRUE
Explanation
No.
UPDATE TABLE ... CLUSTER BY
Explanation
No.
CREATE CLUSTER ON TABLE
Explanation
No.
Overall explanation
Clustering keys help improve pruning on very large tables when the natural order is not efficient. Ref: https://docs.snowflake.com/en/sql-reference/sql/alter-table
Domain
Performance and Warehouses
Question 63
Skipped
Which Snowflake edition is the minimum required to use 'Database Failover and Failback' for business continuity across different regions?
Virtual Private Snowflake
Explanation
This is a higher-tier edition.
Correct answer
Business Critical
Explanation
Correct. Failover/Failback and higher security are hallmarks of this edition.
Enterprise
Explanation
Incorrect.
Standard
Explanation
Does not support advanced failover.
Overall explanation
Business Critical (and above) provides the necessary features for cross-region disaster recovery. Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Account and Data Sharing
Question 64
Skipped
What is the purpose of 'Object Tagging' in relation to 'Resource Monitors'?
Correct answer
To group warehouses by cost center (tag) for reporting in the usage views.
Explanation
Correct.
To encrypt tagged objects.
Explanation
No.
To automatically suspend warehouses with a specific tag.
Explanation
Plausible, but Resource Monitors handle suspension, not tags.
To limit the credits used by a specific tag.
Explanation
No.
Overall explanation
Tags provide the metadata layer for chargeback and showback reporting. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Account and Data Sharing
Question 65
Skipped
What is the function of the 'Directory Table' in a Snowflake Stage?
It is another name for an External Table.
Explanation
No.
Correct answer
It provides a built-in table that catalogs the files in a stage, allowing them to be queried with SQL.
Explanation
Correct. It makes stage metadata searchable.
It lists all the users who have accessed the stage.
Explanation
No.
It stores the folder structure for the Warehouse.
Explanation
No.
Overall explanation
Directory tables allow you to use SQL to find files by size, name, or last modified date within a stage. Ref: https://docs.snowflake.com/en/user-guide/data-load-dirtables-intro
Domain
Data Movement
Question 66
Skipped
Which view would you query to see the total credit usage for 'Automatic Clustering' in your account?
LOAD_HISTORY
Explanation
No.
WAREHOUSE_METERING_HISTORY
Explanation
Shows WH credits.
QUERY_HISTORY
Explanation
No.
Correct answer
AUTOMATIC_CLUSTERING_HISTORY (in ACCOUNT_USAGE)
Explanation
Correct. Tracks the serverless costs of clustering.
Overall explanation
Serverless services like clustering have their own dedicated metering views. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/automatic_clustering_history
Domain
Account and Data Sharing
Question 67
Skipped
Which of the following describes the 'Tri-Secret Secure' feature?
MFA combined with SSO.
Explanation
No.
A secret password shared by 3 admins.
Explanation
No.
Correct answer
A combination of a Snowflake-managed key and a Customer-managed key to encrypt data.
Explanation
Correct. It gives customers more control over their data encryption.
Encryption for 3 different cloud providers.
Explanation
No.
Overall explanation
Tri-Secret Secure is part of the Business Critical edition and provides a higher level of data protection. Ref: https://docs.snowflake.com/en/user-guide/security-encryption-kms
Domain
Security
Question 68
Skipped
When creating a 'Security Integration' for SSO, which protocol is most commonly used by Snowflake?
FTP
Explanation
Not a security protocol.
Correct answer
SAML 2.0
Explanation
Correct. The standard for browser-based Single Sign-On.
OAuth 2.0
Explanation
Used for API/App access.
Kerberos
Explanation
Not natively used for SSO in Snowflake.
Overall explanation
SAML 2.0 is the industry standard used by Snowflake for integrating with Identity Providers like Okta or Azure AD. Ref: https://docs.snowflake.com/en/user-guide/admin-security-sso
Domain
Security
Question 69
Skipped
A retail company wants to track 'Data Lineage' to see which views are built on top of which tables. Which view helps with this?
Correct answer
OBJECT_DEPENDENCIES
Explanation
Correct. Shows the parent-child relationships between objects.
LOGIN_HISTORY
Explanation
No.
TABLE_STORAGE_METRICS
Explanation
Shows storage.
ACCESS_HISTORY
Explanation
Shows who accessed what.
Overall explanation
The OBJECT_DEPENDENCIES view is vital for impact analysis before dropping or changing tables. Ref: https://docs.snowflake.com/en/user-guide/object-dependencies
Domain
Account and Data Sharing
Question 70
Skipped
When a 'Time Travel' period ends for a Permanent table, where does the data go before being permanently deleted?
It is deleted immediately.
Explanation
No.
It is moved to a backup S3 bucket.
Explanation
No.
It is compressed into a VARIANT column.
Explanation
No.
Correct answer
It moves to Fail-safe for 7 days.
Explanation
Correct. A non-configurable safety period.
Overall explanation
Fail-safe is only accessible by Snowflake Support and is for disaster recovery only. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 71
Skipped
When a Warehouse is suspended, which type of cache is completely lost?
Metadata Cache
Explanation
Stored in Cloud Services.
Correct answer
Local Disk (SSD) Cache
Explanation
Correct. This cache is local to the compute nodes and is cleared when they are released.
All of them
Explanation
Only Local Disk is lost.
Result Cache
Explanation
Stored in Cloud Services.
Overall explanation
The local cache must be rebuilt (warmed up) every time a warehouse starts from a suspended state. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 72
Skipped
What is the function of the 'VALIDATE_PIPE' function?
Correct answer
To review errors encountered by Snowpipe in the last 14 days.
Explanation
Correct.
To check if the Snowpipe syntax is correct.
Explanation
No.
To resume a paused pipe.
Explanation
No.
To grant permissions on a pipe.
Explanation
No.
Overall explanation
VALIDATE_PIPE is used to troubleshoot files that failed to ingest via Snowpipe. Ref: https://docs.snowflake.com/en/sql-reference/functions/validate_pipe
Domain
Data Movement
Question 73
Skipped
How can you recover a 'Database' that was accidentally dropped 20 minutes ago?
Correct answer
UNDROP DATABASE <name>;
Explanation
Correct.
It cannot be recovered.
Explanation
No.
Contact Snowflake Support.
Explanation
Plausible, but UNDROP is self-service.
Restore from a backup tape.
Explanation
No.
Overall explanation
UNDROP is the first line of defense against accidental deletions. Ref: https://docs.snowflake.com/en/sql-reference/sql/undrop-database
Domain
Storage and Protection
Question 74
Skipped
What is the maximum 'Time Travel' retention period for a 'Transient' table?
90 days
Explanation
Only for Permanent tables in Enterprise.
7 days
Explanation
This is Fail-safe length.
Correct answer
1 day
Explanation
Correct. 1 day is the maximum for Transient tables.
0 days
Explanation
This is the default.
Overall explanation
Transient tables are meant for temporary data and have very limited protection periods. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 75
Skipped
Which service is used to automatically scale out a warehouse by adding clusters when it becomes overloaded?
Query Acceleration Service
Explanation
Adds serverless compute to a single cluster.
Correct answer
Multi-cluster Warehouse
Explanation
Correct. It adds clusters of the same size to increase concurrency.
Search Optimization Service
Explanation
No.
Auto-increment
Explanation
No.
Overall explanation
Multi-cluster warehouses solve the problem of queuing by scaling horizontally. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 76
Skipped
In the context of 'Snowpark', what is a 'DataFrame'?
A type of Virtual Warehouse.
Explanation
No.
A security policy for files.
Explanation
No.
Correct answer
A logical representation of a data set that evaluates lazily.
Explanation
Correct. It represents a SQL query that only runs when an action is called.
A physical table in the database.
Explanation
No.
Overall explanation
Snowpark DataFrames allow for functional programming styles that translate directly into Snowflake SQL. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 77
Skipped
True or False: A 'Consumer' of a Data Share can 'Clone' the shared database into their own account to make it editable.
TRUE
Explanation
No.
Correct answer
FALSE
Explanation
Correct. Shared databases are read-only and cannot be cloned by the consumer.
Overall explanation
To edit shared data, the consumer must create a new table and use INSERT INTO ... SELECT from the share. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 78
Skipped
Which of the following is a characteristic of 'Secure Views'?
They can only be used in the Business Critical edition.
Explanation
Available in all editions.
They don't require a warehouse.
Explanation
No.
Correct answer
They prevent users from seeing the underlying SQL query using SHOW VIEWS.
Explanation
Correct. Hides DDL for security.
They are faster than standard views.
Explanation
No. They can be slightly slower due to restricted optimizations.
Overall explanation
Secure views are essential when sharing data with third parties to hide intellectual property. Ref: https://docs.snowflake.com/en/user-guide/views-secure
Domain
Account and Data Sharing
Question 79
Skipped
When developing a Snowpark application in Python, where does the actual data processing happen when you call an action like .collect()?
Correct answer
Inside the Snowflake Virtual Warehouse.
Explanation
Correct. Snowpark pushes the logic down to the Snowflake compute nodes.
On a separate Anaconda server.
Explanation
Anaconda provides the packages, but the warehouse executes the code.
On the local developer's laptop.
Explanation
Processing happens in the warehouse.
In the Cloud Services layer.
Explanation
This layer only optimizes and manages.
Overall explanation
Snowpark uses push-down logic to ensure data is processed where it resides. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 80
Skipped
What is the purpose of 'Snowflake Scripting'?
To script the installation of SnowSQL.
Explanation
No.
Correct answer
To write procedural code (loops, variables, branches) directly in Snowflake SQL.
Explanation
Correct.
To write JavaScript UDFs.
Explanation
No.
To automate the creation of AWS accounts.
Explanation
No.
Overall explanation
Snowflake Scripting allows for complex logic within blocks and stored procedures using SQL. Ref: https://docs.snowflake.com/en/developer-guide/snowflake-scripting/index
Domain
Account and Data Sharing
Question 81
Skipped
Which of the following is NOT a type of 'Virtual Warehouse' scaling?
Correct answer
Scaling Deep (Memory only)
Explanation
This is not a Snowflake term.
Scaling Out (Multi-cluster)
Explanation
Adding clusters.
Scaling Up (Resizing)
Explanation
Increasing size.
Scaling Down (Automatic)
Explanation
Reducing size/clusters when idle.
Overall explanation
Snowflake focuses on Scale Up/Down (Vertical) and Scale Out/In (Horizontal). Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 82
Skipped
A retail analyst wants to query a table 'at' a specific point in time from 2 hours ago. Which feature allows this?
Data Sharing.
Explanation
No.
Correct answer
Time Travel.
Explanation
Correct. Using the AT or BEFORE clause.
Zero-copy Cloning.
Explanation
Creates a new object but isn't the query mechanism.
Fail-safe.
Explanation
Support only.
Overall explanation
Time Travel allows for querying data, restoring tables, or cloning from a historical state. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 83
Skipped
Which analytical function is used to return the value of a column from a row that is 'N' rows before the current row?
FIRST_VALUE()
Explanation
Returns the first row.
Correct answer
LAG()
Explanation
Correct. Returns a previous row.
RANK()
Explanation
Returns ranking.
LEAD()
Explanation
Returns a following row.
Overall explanation
LAG and LEAD are window functions used for time-series and comparative analysis. Ref: https://docs.snowflake.com/en/sql-reference/functions/lag
Domain
Performance and Warehouses
Question 84
Skipped
Which of the following is a key feature of 'Business Critical' edition over 'Enterprise' edition?
Correct answer
Enhanced security for HIPAA compliance and 'Tri-Secret Secure' support.
Explanation
Correct. Highest security tier.
Materialized Views
Explanation
Both have it.
Up to 90 days of Time Travel
Explanation
Both have it.
Multi-cluster Warehouses
Explanation
Both have it.
Overall explanation
Business Critical is required for highly regulated industries like Healthcare and Finance. Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Account and Data Sharing
Question 85
Skipped
Which role is required to see the 'Organization' usage and manage accounts across different regions?
SYSADMIN
Explanation
Object management only.
ACCOUNTADMIN
Explanation
Limited to one account.
Correct answer
ORGADMIN
Explanation
Correct. The organization-level role.
SECURITYADMIN
Explanation
User management only.
Overall explanation
ORGADMIN can create new accounts and see usage across the entire Snowflake deployment. Ref: https://docs.snowflake.com/en/user-guide/admin-user-management
Domain
Account and Data Sharing
Question 86
Skipped
Which Snowflake feature allows you to restrict access based on a user's IP address?
Security Integration
Explanation
Used for SSO/OAuth.
Correct answer
Network Policy
Explanation
Correct. Can allow or block specific IP ranges at account or user level.
Access Control List (ACL)
Explanation
Snowflake uses RBAC.
Resource Monitor
Explanation
Used for billing.
Overall explanation
Network policies are a fundamental security layer for restricting where users can log in from. Ref: https://docs.snowflake.com/en/user-guide/network-policies
Domain
Security
Question 87
Skipped
Which security feature in Snowflake provides a second layer of authentication using Duo Security?
Single Sign-On (SSO)
Explanation
Used for identity provider integration.
Correct answer
Multi-Factor Authentication (MFA)
Explanation
Correct. Snowflake integrates natively with Duo for MFA.
Key Pair Authentication
Explanation
Used for CLI/Service accounts.
Network Policy
Explanation
Used for IP whitelisting.
Overall explanation
MFA via Duo Security is available for all Snowflake users in all editions. Ref: https://docs.snowflake.com/en/user-guide/security-mfa
Domain
Security
Question 88
Skipped
Which 'Cloud Services' layer function is responsible for determining which micro-partitions to scan?
The Transaction Manager.
Explanation
No.
The Security Manager.
Explanation
No.
The Parser.
Explanation
No.
Correct answer
The Optimizer (using the Metadata Store).
Explanation
Correct. (Pruning decision).
Overall explanation
The optimizer uses the min/max values in the metadata store to perform pruning. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 89
Skipped
Which of the following can be used to monitor credit consumption in real-time to avoid overspending?
Information Schema.
Explanation
Is real-time but doesn't have alerting/blocking.
Correct answer
Resource Monitor.
Explanation
Correct. Can be set to notify or suspend when limits are reached.
Account Usage.
Explanation
Has latency.
Network Policy.
Explanation
Security only.
Overall explanation
Resource monitors are the primary tool for cost control in a Snowflake account. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 90
Skipped
Which type of Snowflake URL is best suited for sharing a file with an external partner who does NOT have a Snowflake account?
Scoped URL
Explanation
Requires a session.
Correct answer
Pre-signed URL
Explanation
Correct. It contains an access token and can be downloaded via a standard browser without a login.
File URL
Explanation
Requires a session.
Stage URL
Explanation
Not a standard term.
Overall explanation
Pre-signed URLs are time-limited and do not require the user to be a Snowflake user to download the file. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-rest-files
Domain
Data Movement
Question 91
Skipped
Which view would you check to see the 'Average Storage' used by your account for the current month?
LOAD_HISTORY
Explanation
No.
Correct answer
DATABASE_STORAGE_USAGE_HISTORY
Explanation
Correct. Shows daily historical storage usage.
TABLE_STORAGE_METRICS
Explanation
Current state.
QUERY_HISTORY
Explanation
No.
Overall explanation
This view is essential for tracking storage costs over time at the database level. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/database_storage_usage_history
Domain
Account and Data Sharing
Question 92
Skipped
True or False: A 'Task' can be configured to run only if a specific 'Stream' has data.
FALSE
Correct answer
TRUE
Explanation
Correct. Using the 'WHEN SYSTEM$STREAM_HAS_DATA('stream_name')' clause.
Overall explanation
This is the best practice for building efficient ELT pipelines. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 93
Skipped
Which type of URL is generated with the function GET_PRESIGNED_URL()?
File URL
Explanation
No.
Permanent URL
Explanation
No.
Scoped URL
Explanation
No.
Correct answer
Pre-signed URL
Explanation
Correct.
Overall explanation
This function creates a time-limited URL for external access to a staged file. Ref: https://docs.snowflake.com/en/sql-reference/functions/get_presigned_url
Domain
Data Movement
Question 94
Skipped
What is the main benefit of 'Zero-copy Cloning' for a Dev/Test environment?
It moves data to a cheaper cloud provider.
Explanation
No.
Correct answer
It allows creating full environments in seconds without incurring extra storage costs initially.
Explanation
Correct.
It makes queries run faster.
Explanation
No.
It automatically masks the data.
Explanation
No.
Overall explanation
Cloning only copies metadata, making it nearly instantaneous and cost-free until data diverges. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 95
Skipped
Which component of Snowflake handles 'Access Control' (RBAC)?
Cloud Provider IAM.
Explanation
No.
Correct answer
Cloud Services.
Explanation
Correct.
Storage.
Explanation
No.
Compute.
Explanation
No.
Overall explanation
Cloud Services is the gatekeeper for all security and permissions. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 96
Skipped
Which command is used to permanently remove a 'Resource Monitor'?
DELETE RESOURCE MONITOR.
Explanation
No.
SUSPEND RESOURCE MONITOR.
Explanation
No (that just pauses it).
Correct answer
DROP RESOURCE MONITOR.
Explanation
Correct.
REMOVE RESOURCE MONITOR.
Explanation
No.
Overall explanation
Resource Monitors are account-level objects managed with DDL. Ref: https://docs.snowflake.com/en/sql-reference/sql/drop-resource-monitor
Domain
Account and Data Sharing
Question 97
Skipped
A retail company wants to use a Kafka connector to stream data into Snowflake. Where does the Kafka connector run?
Correct answer
In the customer's Kafka environment (Confluent or self-hosted).
Explanation
Correct. It is a plugin for Kafka Connect.
On a Virtual Warehouse.
Explanation
It doesn't use a warehouse for the ingestion itself.
In an S3 bucket.
Explanation
No.
Inside the Snowflake Cloud Services layer.
Explanation
No.
Overall explanation
The Snowflake Kafka Connector is a standard Kafka Connect plugin that pushes data into Snowflake stages. Ref: https://docs.snowflake.com/en/user-guide/kafka-connector
Domain
Data Movement
Question 98
Skipped
A user needs to load data where some records might have more columns than defined in the table. Which COPY INTO option prevents the load from failing?
Correct answer
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE.
Explanation
Correct. Allows loading even if the file has extra columns.
STRIP_OUTER_ARRAY = TRUE.
Explanation
Only for JSON.
IGNORE_CASE = TRUE.
Explanation
No.
ON_ERROR = CONTINUE.
Explanation
Fails the specific row, but the parameter for column count is specific.
Overall explanation
Fine-tuning ingestion requires knowing specific file format options like column mismatch handling. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 99
Skipped
In a 'Snowflake Organization', how are credits billed if you have accounts in both AWS and Azure?
You get a discount for using multiple providers.
Explanation
No.
Correct answer
Credits are aggregated at the Organization level.
Explanation
Correct. You purchase a pool of credits for the whole organization.
Separate bills for each provider.
Explanation
No.
Billing is handled by the Cloud Provider, not Snowflake.
Explanation
No.
Overall explanation
Organization-level billing simplifies financial management across different clouds and regions. Ref: https://docs.snowflake.com/en/user-guide/admin-user-management
Domain
Account and Data Sharing
Question 100
Skipped
Which of the following describes the 'Query Acceleration Service' (QAS)?
It automatically resizes the warehouse.
Explanation
No, it adds serverless resources.
It is a feature of the Standard edition.
Explanation
Enterprise and higher.
Correct answer
It offloads parts of a massive scan query to shared serverless compute resources to speed up execution.
Explanation
Correct. It helps when a warehouse is too small for a specific massive scan.
It is only for INSERT statements.
Explanation
For SELECT scans.
Overall explanation
QAS acts like a "burst" capacity for large scans without needing to resize the whole warehouse. Ref: https://docs.snowflake.com/en/user-guide/query-acceleration-service
Domain
Performance and Warehouses
Question 101
Skipped
True or False: Snowflake automatically compresses all data stored in tables.
FALSE
Explanation
Compression is a core part of the storage optimization.
Correct answer
TRUE
Explanation
Correct. Users cannot turn this off.
Overall explanation
Snowflake's automatic compression reduces storage costs and improves I/O performance. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 102
Skipped
Which role is primarily responsible for creating and managing 'Virtual Warehouses'?
PUBLIC
Explanation
No permissions.
Correct answer
SYSADMIN
Explanation
Correct. In the default hierarchy, SYSADMIN handles compute resources.
SECURITYADMIN
Explanation
Handles grants.
USERADMIN
Explanation
Handles users/roles.
Overall explanation
While ACCOUNTADMIN can also do it, SYSADMIN is the recommended role for resource management. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Performance and Warehouses
Question 103
Skipped
Which view in the Account Usage schema tracks the use of 'Dynamic Data Masking' and 'Row Access Policies'?
MASKING_HISTORY.
Explanation
Plausible name, but doesn't exist.
SECURITY_AUDIT_LOG.
Explanation
No.
ACCESS_HISTORY.
Explanation
Tracks access to data, not the application of policies.
Correct answer
POLICY_USAGE.
Explanation
Correct.
Overall explanation
POLICY_USAGE is the centralized view for monitoring data governance object application. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/policy_usage
Domain
Security
Question 104
Skipped
Which of the following statements about 'Account Usage' views is FALSE?
Correct answer
They are available only in the Business Critical edition.
Explanation
False. Available in all editions.
They reside in the SNOWFLAKE database.
Explanation
True.
They include data for objects that have been deleted.
Explanation
True.
They have a latency of 45 minutes to 3 hours.
Explanation
True.
Overall explanation
All Snowflake editions have access to the Account Usage share for auditing and monitoring. Ref: https://docs.snowflake.com/en/sql-reference/account-usage
Domain
Account and Data Sharing
Question 105
Skipped
What is the function of the 'Snowflake Connector for Python'?
To manage Snowflake billing.
Explanation
No.
Correct answer
To allow Python applications to connect to Snowflake and execute SQL.
Explanation
Correct.
To write Python code inside the Snowflake UI.
Explanation
No.
To replace Snowpark.
Explanation
They work together.
Overall explanation
The Python connector is the bridge for Python-based ETL and data science tools to talk to Snowflake. Ref: https://docs.snowflake.com/en/developer-guide/python-connector/python-connector
Domain
Data Movement
Question 106
Skipped
Which of the following is TRUE about 'Streams' on 'Views'?
The view must be a 'Secure View' to have a stream.
Explanation
No.
Streams can only be created on base tables.
Explanation
Plausible, but Snowflake supports streams on views.
Correct answer
The underlying tables of the view must have Change Tracking enabled.
Explanation
Correct.
Streams on views only track DELETEs.
Explanation
No.
Overall explanation
For a stream to work on a view, the base tables must be able to provide the change data. Ref: https://docs.snowflake.com/en/user-guide/streams-intro
Domain
Account and Data Sharing
Question 107
Skipped
A company needs to connect their on-premises network to Snowflake without going over the public internet. Which feature should they use?
SnowSQL
Explanation
This is a CLI tool.
Direct Share
Explanation
Used for data sharing.
Network Policies
Explanation
Used for whitelisting IPs.
Correct answer
Private Link (AWS/Azure/GCP)
Explanation
Correct. Provides a private endpoint within the customer's VPC.
Overall explanation
Private Link ensures that traffic stays within the cloud provider's backbone network for security and compliance. Ref: https://docs.snowflake.com/en/user-guide/admin-security-privatelink
Domain
Security
Question 108
Skipped
What happens if you run a query that is identical to one run 10 minutes ago, but by a DIFFERENT user in the same role?
Correct answer
It uses the Result Cache.
Explanation
Correct. (Results are shared across users with the same role).
It fails with a 'Cache Conflict'.
Explanation
No.
It re-runs from scratch.
Explanation
No.
It uses the Metadata Cache only.
Explanation
No.
Overall explanation
The Result Cache is designed for reuse across the account for identical queries. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 109
Skipped
When using 'Multi-cluster Warehouses', what does the 'Economy' scaling policy prioritize?
High availability.
Explanation
No.
Correct answer
Credit savings (throughput).
Explanation
Correct. It waits to ensure clusters are fully utilized.
Low latency.
Explanation
No. That is the Standard policy.
Maximum performance.
Explanation
No.
Overall explanation
Economy policy avoids starting new clusters unless there is a sustained load for at least 6 minutes. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 110
Skipped
Which background service automatically manages the 'Clustering' of a table to maintain performance?
Search Optimization Service
Explanation
No.
Query Acceleration Service
Explanation
No.
Metadata Manager
Explanation
No.
Correct answer
Automatic Clustering
Explanation
Correct. A serverless service that reclusters data as needed.
Overall explanation
Automatic Clustering replaces the need for manual re-sorting of data. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions
Domain
Performance and Warehouses
Question 111
Skipped
Which function allows a developer to check if a specific 'Stream' has any new change data before starting a 'Task' to save credits?
STREAM_COUNT()
Explanation
Incorrect.
SYSTEM$PIPE_STATUS()
Explanation
Used for Snowpipe.
Correct answer
SYSTEM$STREAM_HAS_DATA()
Explanation
Correct. Returns True if the stream has offsets.
VALIDATE_STREAM()
Explanation
Not a valid function.
Overall explanation
Using this function in a Task's WHEN clause prevents the warehouse from starting if there is no work to do. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_stream_has_data
Domain
Account and Data Sharing
Question 112
Skipped
Which of the following describes 'Object Tagging' in Snowflake?
Adding a comment to a table.
Explanation
Tags are different from comments.
Renaming an object for better clarity.
Explanation
No.
Assigning a physical location to a table.
Explanation
No.
Correct answer
Assigning metadata tags to objects to help with data governance and tracking.
Explanation
Correct. Used for classification (e.g., Tagging a column as 'Sensitive').
Overall explanation
Tags allow for better auditing and policy enforcement (like masking) based on object classification. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 113
Skipped
True or False: You can query a JSON file located in an External Stage without actually loading it into a table.
Correct answer
TRUE
Explanation
Correct. Using the SELECT $1 notation.
FALSE
Explanation
Snowflake supports schema-on-read.
Overall explanation
You can query staged files directly, which is useful for quick data exploration. Ref: https://docs.snowflake.com/en/user-guide/querying-metadata
Domain
Data Movement
Question 114
Skipped
Which Snowflake object is used to group 'Users' and 'Roles' for the purpose of granting permissions?
Correct answer
Role
Explanation
Correct. Permissions are granted to roles, which are assigned to users.
Policy
Explanation
Security policies are different.
Profile
Explanation
Not a Snowflake object.
Group
Explanation
Snowflake does not use groups.
Overall explanation
Snowflake uses Role-Based Access Control (RBAC). Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 115
Skipped
Which 'Task' parameter defines the time interval between executions in a non-cron format?
Correct answer
SCHEDULE = '5 MINUTE'
Explanation
Correct.
INTERVAL = 300
Explanation
No.
FREQ = DAILY
Explanation
No.
CRON = '* * * * *'
Explanation
This is the cron format.
Overall explanation
The SCHEDULE parameter supports both simple intervals and complex cron expressions. Ref: https://docs.snowflake.com/en/sql-reference/sql/create-task
Domain
Account and Data Sharing
Question 116
Skipped
What is the impact of setting the 'MIN_CLUSTER_COUNT' and 'MAX_CLUSTER_COUNT' to the same value in a Multi-cluster Warehouse?
It limits the warehouse to only one user.
Explanation
No.
Correct answer
It creates a 'Maximized' warehouse.
Explanation
Correct behavior.
It reduces the credit cost by 50%.
Explanation
It likely increases cost as all clusters run.
It enables Auto-scaling.
Explanation
No, scaling is disabled.
Overall explanation
Maximized warehouses are used when predictable high performance is more important than cost savings. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 117
Skipped
In Snowflake, which role is the 'Parent' of all other system-defined roles?
Correct answer
ACCOUNTADMIN.
Explanation
Correct. It sits at the top of the hierarchy.
SYSADMIN.
Explanation
No.
SECURITYADMIN.
Explanation
No.
USERADMIN.
Explanation
No.
Overall explanation
ACCOUNTADMIN inherits all privileges from SYSADMIN and SECURITYADMIN. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 118
Skipped
Which type of data does Snowflake store in a 'VARIANT' column?
Only plain text.
Explanation
No.
Only binary data.
Explanation
No.
Correct answer
Semi-structured data (JSON, Avro, Parquet, XML, ORC).
Explanation
Correct.
Only JSON.
Explanation
Supports others too.
Overall explanation
The VARIANT type is Snowflake's powerful 'catch-all' for nested and semi-structured formats. Ref: https://docs.snowflake.com/en/sql-reference/data-types-semistructured
Domain
Storage and Protection
Question 119
Skipped
An administrator wants to automate SnowSQL logins for a nightly ETL job without using passwords. Which authentication method is best?
Correct answer
Key Pair Authentication
Explanation
Correct. Using a public/private key pair is the standard for automated CLI tasks.
SAML 2.0
Explanation
Requires browser interaction.
OAuth 2.0
Explanation
Usually used for third-party applications.
MFA
Explanation
Requires manual approval on a mobile device.
Overall explanation
Key pair authentication is the preferred method for secure, non-interactive service account access. Ref: https://docs.snowflake.com/en/user-guide/key-pair-auth
Domain
Security
Question 120
Skipped
What is the maximum number of days a 'Query Result' is stored in the cache?
90 days
Explanation
No.
7 days
Explanation
No.
31 days
Explanation
No.
Correct answer
1 day (24 hours)
Explanation
Correct.
Overall explanation
Results are purged after 24 hours, but the timer resets if the same query is run again (and data hasn't changed). Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 121
Skipped
What is the purpose of 'SCIM' (System for Cross-domain Identity Management) in Snowflake?
To manage virtual warehouses.
Explanation
No.
Correct answer
To automate the provisioning of users and roles from an external identity provider like Okta.
Explanation
Correct.
To encrypt data at rest.
Explanation
No.
To share data between accounts.
Explanation
No.
Overall explanation
SCIM makes managing thousands of users easier by syncing them from your corporate directory. Ref: https://docs.snowflake.com/en/user-guide/scim-okta
Domain
Security