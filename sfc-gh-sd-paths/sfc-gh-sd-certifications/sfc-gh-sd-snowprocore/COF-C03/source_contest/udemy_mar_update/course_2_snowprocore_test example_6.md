Question 1
Correct
Which of the following is a benefit of 'External Tables'?
They support 90 days of Time Travel.
Explanation
No.
They automatically re-cluster the source data.
Explanation
No.
Your answer is correct
They allow querying data in S3/Azure without moving it into Snowflake.
Explanation
Correct.
They are faster than internal tables.
Explanation
No.
Overall explanation
External tables provide a cost-effective way to explore Data Lakes. Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro
Domain
Data Movement
Question 2
Skipped
A company needs to ensure that a specific set of queries always has sub-second response times, regardless of whether the underlying data has changed. Which feature is most appropriate?
Query Profile tuning.
Explanation
This is a tool, not a feature for response time.
Correct answer
Materialized Views.
Explanation
Correct. They pre-compute results and handle data changes background, though they are best for aggregations.
Search Optimization Service.
Explanation
Plausible, but this is for point lookups, not general query acceleration.
Result Cache.
Explanation
Plausible, but if data changes, the cache is invalidated.
Overall explanation
Materialized Views are the only object that physically stores a pre-computed result set to guarantee performance. Ref: https://docs.snowflake.com/en/user-guide/views-materialized
Domain
Performance and Warehouses
Question 3
Skipped
Which of the following is a 'Virtual Warehouse' size? (Select 2)
Correct selection
Large
Explanation
Correct.
Extreme
Explanation
No.
Correct selection
X-Small
Explanation
Correct.
Titan
Explanation
No.
Jumbo
Explanation
Plausible, but not a name.
Overall explanation
Snowflake uses T-shirt sizing (XS, S, M, L, XL, etc.). Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 4
Skipped
Which of the following is TRUE about 'Snowpark'?
Correct answer
It allows processing data using Python, Java, or Scala inside Snowflake.
Explanation
Correct.
It is only for admins.
Explanation
No.
It only supports SQL.
Explanation
No.
It requires a separate Spark cluster.
Explanation
No.
Overall explanation
Snowpark expands Snowflake's capabilities to non-SQL developers. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 5
Skipped
Which function is used to convert a JSON string into a VARIANT?
CAST_JSON().
Explanation
No.
Correct answer
PARSE_JSON().
Explanation
Correct.
STR_TO_JSON().
Explanation
No.
TO_VARIANT().
Explanation
Plausible, but PARSE_JSON is the standard.
Overall explanation
Parsing is the first step in making semi-structured data queryable. Ref: https://docs.snowflake.com/en/sql-reference/functions/parse_json
Domain
Storage and Protection
Question 6
Skipped
What is 'Clustering Depth'?
The depth of a JSON file.
Explanation
No.
Correct answer
A measure of how well a table's micro-partitions are organized.
Explanation
Correct. (Lower is better).
The number of columns in a table.
Explanation
No.
The size of a warehouse.
Explanation
No.
Overall explanation
Lower depth means fewer micro-partitions overlap, leading to better pruning. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions
Domain
Performance and Warehouses
Question 7
Skipped
True or False: A 'Task' can be scheduled using a 'Cron' expression.
FALSE
Explanation
Cron is fully supported.
Correct answer
TRUE
Explanation
Correct. This allows for complex scheduling (e.g. every Friday at midnight).
Overall explanation
Tasks offer two scheduling options: fixed intervals (minutes) or Cron expressions. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 8
Skipped
What is the function of 'Automatic Re-clustering'?
Correct answer
It re-organizes data in the background to improve pruning.
Explanation
Correct.
It deletes old data.
Explanation
No.
It creates backups.
Explanation
No.
It resizes warehouses.
Explanation
No.
Overall explanation
Re-clustering maintains table health as new data is loaded. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 9
Skipped
Which of the following is a benefit of 'Secure Views'?
They allow writing data back to the table.
Explanation
No.
Correct answer
They hide the view definition and underlying data structure from unauthorized users.
Explanation
Correct.
They automatically mask all columns.
Explanation
No.
They are faster.
Explanation
No.
Overall explanation
Secure views are the foundation for secure data sharing and privacy. Ref: https://docs.snowflake.com/en/user-guide/views-secure
Domain
Account and Data Sharing
Question 10
Skipped
Which of the following is the 'Provider' responsible for when sharing data via a 'Reader Account'?
The cost of storage only.
Explanation
Plausible, but provider pays for reader's compute too.
Only the Cloud Services costs.
Explanation
No.
Nothing, the consumer pays.
Explanation
Incorrect.
Correct answer
The cost of storage AND the credits used by the reader account's warehouses.
Explanation
Correct.
Overall explanation
Reader accounts are 'sub-accounts' billed directly to the provider. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 11
Skipped
Which function is used to convert a string like '2023-01-01' into a Date type?
CAST_AS_DATE().
Explanation
No.
DATE_PARSE().
Explanation
Plausible, but Snowflake uses TO_DATE.
STRING_TO_DATE().
Explanation
No.
Correct answer
TO_DATE().
Explanation
Correct.
Overall explanation
Data type conversion is a primary task in Snowflake ETL. Ref: https://docs.snowflake.com/en/sql-reference/functions/to_date
Domain
Account and Data Sharing
Question 12
Skipped
Which role can access the 'Organization' (ORGADMIN) features to manage multiple accounts?
Correct answer
ORGADMIN.
Explanation
Correct.
SECURITYADMIN.
Explanation
No.
ACCOUNTADMIN.
Explanation
Plausible, but ORGADMIN is a separate, higher role.
SYSADMIN.
Explanation
No.
Overall explanation
ORGADMIN is the role for multi-account management and global billing. Ref: https://docs.snowflake.com/en/user-guide/admin-user-management
Domain
Security
Question 13
Skipped
Which privilege is required to 'resume' a suspended warehouse?
USAGE.
Explanation
Plausible, but USAGE is to query.
MODIFY.
Explanation
Allows resizing, but OPERATE is for state.
Correct answer
OPERATE.
Explanation
Correct. Allows starting, stopping, and suspending.
MONITOR.
Explanation
Allows viewing usage, not changing state.
Overall explanation
OPERATE is the specific privilege for managing the lifecycle of a warehouse. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Security
Question 14
Skipped
Which account-level role has the 'MANAGE GRANTS' privilege by default, allowing it to modify any grant in the system?
SYSADMIN.
Explanation
No, SYSADMIN manages data objects.
PUBLIC.
Explanation
No.
Correct answer
SECURITYADMIN.
Explanation
Correct. This role (and ACCOUNTADMIN) are designed for security management.
USERADMIN.
Explanation
No, only for users/roles.
Overall explanation
SECURITYADMIN is explicitly for managing grants and security policies. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 15
Skipped
What is the primary role of 'Virtual Warehouses' in Snowflake?
Managing security.
Explanation
No.
Encrypting data.
Explanation
No.
Storing metadata.
Explanation
No.
Correct answer
Performing compute/processing for queries and DML.
Explanation
Correct.
Overall explanation
Warehouses are the 'muscle' that executes all SQL operations. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Snowflake Architecture
Question 16
Skipped
What is the primary benefit of 'External Tables'?
Correct answer
They allow querying data directly in a cloud Data Lake without ingestion.
Explanation
Correct.
They are the fastest way to query data.
Explanation
No.
They support Fail-safe.
Explanation
No.
They don't require a warehouse.
Explanation
No.
Overall explanation
External tables provide immediate access to large amounts of data without moving it. Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro
Domain
Data Movement
Question 17
Skipped
A company needs to store data that is only needed for 24 hours and doesn't require high protection. Which table type is most cost-effective?
Correct answer
Transient.
Explanation
Correct. No Fail-safe storage costs.
External.
Explanation
No.
Permanent.
Explanation
Most expensive due to Fail-safe.
Temporary.
Explanation
Plausible, but only exists for a session. Transient persists across sessions.
Overall explanation
Transient tables are the 'middle ground' for short-term persistence without extra overhead. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 18
Skipped
A table is dropped and then the 'Time Travel' period expires. The data is now in 'Fail-safe'. How can it be recovered?
Correct answer
Contacting Snowflake Support.
Explanation
Correct. Only Support can recover data from Fail-safe.
Using a Clone with the BEFORE clause.
Explanation
No.
It cannot be recovered.
Explanation
Plausible, but Support CAN do it within 7 days.
Using the UNDROP TABLE command.
Explanation
Plausible, but UNDROP only works during Time Travel.
Overall explanation
Fail-safe is not a self-service feature; it requires a support ticket. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 19
Skipped
Which scaling policy is best for 'Credit Saving' in a multi-cluster warehouse?
Static.
Explanation
No.
Standard.
Explanation
No (Performance).
Correct answer
Economy.
Explanation
Correct.
Balanced.
Explanation
No.
Overall explanation
Economy mode prioritizes cluster utilization over immediate response. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 20
Skipped
Which of the following is TRUE about 'Reader Accounts'?
Correct answer
They are limited to read-only data shared with them.
Explanation
Correct.
They can create their own shares.
Explanation
No.
They have a separate billing account.
Explanation
No. (Billed to provider).
They can load their own data into Snowflake.
Explanation
No.
Overall explanation
Reader accounts are strictly for consuming data provided by the parent account. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 21
Skipped
Which of the following is TRUE about 'Multi-factor Authentication' (MFA) in Snowflake?
It is a paid add-on.
Explanation
No, it's included.
It is only available for ACCOUNTADMINs.
Explanation
Plausible, but any user can enable it.
Correct answer
It is powered by Duo Security and is available for all users.
Explanation
Correct.
It must be configured via a Network Policy.
Explanation
No.
Overall explanation
Snowflake provides MFA via Duo for all editions at no extra cost. Ref: https://docs.snowflake.com/en/user-guide/security-mfa
Domain
Security
Question 22
Skipped
Which of the following describes 'Search Optimization Service' (SOS) pricing?
It is free for the first 100 queries.
Explanation
No.
Included in the warehouse cost.
Explanation
No.
Correct answer
Billed as a serverless service based on maintenance and storage.
Explanation
Correct.
It is a flat $100 monthly fee.
Explanation
No.
Overall explanation
Like clustering and materialized views, SOS uses serverless credits for background maintenance. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 23
Skipped
Which command is used to see the credit usage for 'Automatic Re-clustering'?
WAREHOUSE_METERING_HISTORY.
Explanation
No, that's for warehouses.
QUERY_HISTORY.
Explanation
No.
Correct answer
AUTOMATIC_CLUSTERING_HISTORY.
Explanation
Correct.
RECLUSTER_METERING.
Explanation
Plausible name, but incorrect.
Overall explanation
Serverless features have their own specialized history views. Ref: https://docs.snowflake.com/en/sql-reference/functions/automatic_clustering_history
Domain
Account and Data Sharing
Question 24
Skipped
What is the purpose of the 'COPY INTO <location>' command?
To move files between stages.
Explanation
No.
To copy a table.
Explanation
No.
Correct answer
To export data from a table to a stage.
Explanation
Correct. (Unloading).
To load data from a stage to a table.
Explanation
No (that's COPY INTO table).
Overall explanation
COPY INTO is the primary way to extract data from Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-location
Domain
Data Movement
Question 25
Skipped
Which of the following is TRUE about 'Internal Stages'? (Select 2)
Internal stages are only available in Business Critical edition.
Explanation
No.
Correct selection
Each table has a stage by default.
Explanation
Correct. (@%table).
Correct selection
Each user has a private stage by default.
Explanation
Correct. (@~).
Internal stages store data in the Cloud Services layer.
Explanation
No, they use the Storage layer.
Overall explanation
Snowflake provides built-in storage areas for every user and table. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 26
Skipped
Which of the following is a result of 'Horizontal Scaling' (Multi-cluster)?
Storage costs are reduced.
Explanation
No.
Correct answer
More queries can run simultaneously without queuing.
Explanation
Correct.
Encryption is improved.
Explanation
No.
A single query runs 4 times faster.
Explanation
Plausible, but that's Vertical scaling (S to XL).
Overall explanation
Horizontal scaling is about 'Concurrency' (more users), not 'Speed' (shorter query time). Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 27
Skipped
Which of the following are TRUE regarding 'Network Policies'? (Select 2)
Correct selection
They support CIDR notation for IP ranges.
Explanation
Correct.
They automatically enable MFA.
Explanation
No.
Correct selection
They can block specific IP addresses.
Explanation
Correct. (Allowed and Blocked lists).
They can be used to restrict access to a specific Database.
Explanation
Plausible, but they apply to Account or User levels only.
Overall explanation
Network policies are IP-based filters, not object-based permissions. Ref: https://docs.snowflake.com/en/user-guide/network-policies
Domain
Security
Question 28
Skipped
A company is using 'Managed Accounts' (Reader Accounts). Who is responsible for the 'Storage' costs of the data being shared?
The Consumer (Reader Account).
Explanation
No.
Both share the cost.
Explanation
No.
Correct answer
The Provider (Data Producer).
Explanation
Correct. Since the data stays in the provider's storage.
Snowflake covers it for free.
Explanation
No.
Overall explanation
In Snowflake sharing, the producer always pays for the data storage. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 29
Skipped
Which function is used to check the status and health of a 'Snowpipe'?
VALIDATE_PIPE().
Explanation
Plausible, but incorrect.
PIPE_HISTORY().
Explanation
Shows usage, not real-time status.
SHOW PIPES.
Explanation
Shows configuration, not health/errors.
Correct answer
SYSTEM$PIPE_STATUS('pipe_name').
Explanation
Correct.
Overall explanation
SYSTEM$PIPE_STATUS provides the 'execution state' and any current errors. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_pipe_status
Domain
Data Movement
Question 30
Skipped
If a 'Resource Monitor' is set to 'Suspend Immediate' at 100% of the budget, what happens to currently running queries?
They are paused and resumed next month.
Explanation
No.
Correct answer
They are cancelled immediately.
Explanation
Correct.
They are moved to a different warehouse.
Explanation
No.
They are allowed to finish.
Explanation
Plausible (this is Suspend), but Immediate kills them.
Overall explanation
Suspend Immediate is the 'hard stop' for credit consumption. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 31
Skipped
What is the minimum billing period for a warehouse after it starts?
Correct answer
1 minute.
Explanation
Correct. Then billed per second.
1 second.
Explanation
No (minimum is 60s).
15 minutes.
Explanation
No.
1 hour.
Explanation
No.
Overall explanation
Every time a warehouse starts, you are charged for at least 60 seconds of compute. Ref: https://docs.snowflake.com/en/user-guide/cost-understanding-compute
Domain
Performance and Warehouses
Question 32
Skipped
Which of the following are characteristics of 'Micro-partitions'? (Select 2)
They can be manually resized by the user.
Explanation
Plausible, but Snowflake manages this automatically.
Correct selection
They are physical files stored in the cloud provider.
Explanation
Correct.
They are stored in a row-based format for fast writes.
Explanation
Plausible, but Snowflake is columnar (OLAP).
Correct selection
They contain metadata such as Min/Max values for each column.
Explanation
Correct. This enables pruning.
Overall explanation
Micro-partitions are the unit of storage in Snowflake, enabling efficient I/O via metadata. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 33
Skipped
True or False: Snowflake provides 'Automatic' backup and disaster recovery across regions without any configuration.
Correct answer
FALSE
Explanation
Correct. You must explicitly configure Replication and Failover.
TRUE
Explanation
Plausible, but Replication requires manual setup and configuration.
Overall explanation
While Snowflake manages the storage, DR/Replication is an opt-in feature. Ref: https://docs.snowflake.com/en/user-guide/database-replication-intro
Domain
Storage and Protection
Question 34
Skipped
A query is queued in a warehouse for 5 minutes. What is the most likely reason?
The user doesn't have permissions.
Explanation
Permissions cause errors, not queuing.
The data is being encrypted.
Explanation
No.
Correct answer
The warehouse is currently at its maximum concurrency/capacity.
Explanation
Correct.
The cloud services layer is down.
Explanation
No.
Overall explanation
Queuing happens when there are more queries than the warehouse clusters can handle. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 35
Skipped
Which function is used to check if a specific 'User' exists in the system?
FIND USER.
Explanation
No.
DESCRIBE USER.
Explanation
No.
LIST USERS.
Explanation
No.
Correct answer
SHOW USERS LIKE 'name'.
Explanation
Correct.
Overall explanation
SHOW commands with LIKE filters are the standard discovery method. Ref: https://docs.snowflake.com/en/sql-reference/sql/show-users
Domain
Security
Question 36
Skipped
Which of the following are 'Semi-structured' file formats supported by Snowflake? (Select 3)
CSV
Explanation
Incorrect (Structured).
Correct selection
AVRO
Explanation
Correct.
Correct selection
PARQUET
Explanation
Correct.
Correct selection
JSON
Explanation
Correct.
XLSX
Explanation
Incorrect (Not natively supported).
MP4
Explanation
Incorrect.
Overall explanation
Snowflake's VARIANT type is optimized for these hierarchical formats. Ref: https://docs.snowflake.com/en/user-guide/data-load-prepare
Domain
Data Movement
Question 37
Skipped
In a 'Query Profile', what does a 'Table Scan' node representing 90% of the time indicate?
The data is not encrypted.
Explanation
No.
The metadata is corrupted.
Explanation
No.
Correct answer
Poor pruning (the query is reading too much data).
Explanation
Correct.
The warehouse is too small.
Explanation
Plausible, but scans are I/O bound.
Overall explanation
Large scans usually mean missing filters or poor clustering. Ref: https://docs.snowflake.com/en/user-guide/ui-query-profile
Domain
Performance and Warehouses
Question 38
Skipped
Which of the following is TRUE about 'Data Sharing'?
Consumers pay for the storage of shared data.
Explanation
No.
Correct answer
Consumers have read-only access to the shared data.
Explanation
Correct.
Shared data is physically copied to the consumer.
Explanation
Plausible, but no data is moved (Live access).
Consumers can modify the data.
Explanation
No.
Overall explanation
Snowflake sharing is built on multi-tenant metadata pointers, not data duplication. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 39
Skipped
Which component of Snowflake is responsible for 'Query Optimization'?
Correct answer
Cloud Services Layer.
Explanation
Correct.
Storage Layer.
Explanation
No.
Virtual Warehouse.
Explanation
No.
Compute Layer.
Explanation
No.
Overall explanation
The query optimizer lives in the 'brain' (Cloud Services) of Snowflake. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 40
Skipped
Which role can create 'Network Policies'?
SYSADMIN.
Explanation
No.
PUBLIC.
Explanation
No.
USERADMIN.
Explanation
No.
Correct answer
SECURITYADMIN or ACCOUNTADMIN.
Explanation
Correct.
Overall explanation
Network security is handled by the administrative roles. Ref: https://docs.snowflake.com/en/user-guide/network-policies
Domain
Security
Question 41
Skipped
Which of the following are characteristics of 'Multi-factor Authentication' (MFA)? (Select 2)
It is only for Enterprise Edition.
Explanation
Incorrect. (Available for all).
It is mandatory for all users.
Explanation
Incorrect. (Optional by default).
Correct selection
It is powered by Duo Security.
Explanation
Correct.
Correct selection
Users must enroll themselves.
Explanation
Correct.
Overall explanation
MFA provides an extra layer of security for all Snowflake accounts. Ref: https://docs.snowflake.com/en/user-guide/security-mfa
Domain
Security
Question 42
Skipped
True or False: Snowflake provides 'Automatic' data encryption at rest.
FALSE
Correct answer
TRUE
Explanation
Correct. (Mandatory and transparent).
Overall explanation
Encryption is always-on and cannot be disabled by the user. Ref: https://docs.snowflake.com/en/user-guide/security-encryption
Domain
Security
Question 43
Skipped
What is the maximum number of 'Tags' that can be associated with a single Snowflake object?
10.
Explanation
Plausible limit.
Correct answer
50.
Explanation
Correct.
Unlimited.
Explanation
No Snowflake object is unlimited.
100.
Explanation
No.
Overall explanation
While powerful, Snowflake enforces a limit of 50 tags per object for metadata performance. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 44
Skipped
Which of the following is TRUE about 'Materialized Views'?
They cannot be shared.
Explanation
No.
They only work with JSON.
Explanation
No.
Correct answer
They store a pre-computed result set for faster querying.
Explanation
Correct.
They are free to maintain.
Explanation
No.
Overall explanation
Materialized views trade storage and maintenance costs for extreme query speed. Ref: https://docs.snowflake.com/en/user-guide/views-materialized
Domain
Performance and Warehouses
Question 45
Skipped
What happens if a query is too large to fit into the 'Warehouse Memory' (RAM)?
Correct answer
The query spills to 'Local Disk' (SSD).
Explanation
Correct. First level of spill.
The query fails with an Out-of-Memory error.
Explanation
Plausible in other DBs, but Snowflake spills.
The query is queued until RAM becomes available.
Explanation
No.
The query automatically resizes the warehouse.
Explanation
No.
Overall explanation
Spilling to local disk is a performance warning, but the query still completes. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 46
Skipped
A query is running slowly because it is scanning 100% of a very large table. No filters are being applied to the query. Will 'Clustering' the table help?
Correct answer
No, clustering only improves performance when queries contain filters that match the clustering key.
Explanation
Correct. Without a filter, Snowflake must scan everything anyway.
Yes, it will automatically compress the data more.
Explanation
No.
No, only Search Optimization can help without filters.
Explanation
Incorrect.
Yes, it will organize the data better.
Explanation
Plausible, but clustering only helps if there are filters (WHERE clause).
Overall explanation
Clustering is a 'pruning' optimization. If the query doesn't allow for pruning, clustering adds no value. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 47
Skipped
Which command is used to remove all data from a table but keep the table structure?
DELETE FROM TABLE.
Explanation
Plausible, but TRUNCATE is faster and more efficient for clearing all.
Correct answer
TRUNCATE TABLE.
Explanation
Correct.
DROP TABLE.
Explanation
Removes structure too.
REMOVE TABLE.
Explanation
No.
Overall explanation
TRUNCATE is a DDL operation that instantly clears the data blocks. Ref: https://docs.snowflake.com/en/sql-reference/sql/truncate-table
Domain
Account and Data Sharing
Question 48
Skipped
A user wants to see the SQL definition of a View. Which command should they use?
SHOW VIEWS.
Explanation
Shows metadata, but SQL text might be truncated.
LIST VIEW.
Explanation
No.
DESCRIBE VIEW.
Explanation
Shows columns, not the SQL.
Correct answer
GET_DDL('VIEW', 'view_name').
Explanation
Correct. Returns the full CREATE statement.
Overall explanation
GET_DDL is the universal function to extract the 'source code' of any Snowflake object. Ref: https://docs.snowflake.com/en/sql-reference/functions/get_ddl
Domain
Account and Data Sharing
Question 49
Skipped
A user needs to see the status of a 'Replication' job. Which view or function should they use?
REPL_STATUS().
Explanation
No.
SHOW REPLICATIONS.
Explanation
Plausible, but incorrect.
REPLICATION_HISTORY.
Explanation
Plausible name, but the correct function is DATABASE_REPLICATION_USAGE_HISTORY.
Correct answer
DATABASE_REPLICATION_USAGE_HISTORY.
Explanation
Correct. Found in Account Usage.
Overall explanation
Replication monitoring is part of the Account Usage views. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/database_replication_usage_history
Domain
Account and Data Sharing
Question 50
Skipped
In the Snowflake 'Information Schema', which view provides the history of data loaded into tables for the last 14 days?
QUERY_HISTORY.
Explanation
Shows all queries, not just loads.
Correct answer
LOAD_HISTORY.
Explanation
Correct. (Available in Information Schema).
COPY_HISTORY.
Explanation
Plausible, but this is a table function in Account Usage/Information Schema.
TABLE_STORAGE_METRICS.
Explanation
Plausible, but for storage only.
Overall explanation
LOAD_HISTORY is the standard view for monitoring recent ingestion activity. Ref: https://docs.snowflake.com/en/sql-reference/info-schema/load_history
Domain
Data Movement
Question 51
Skipped
What is the primary benefit of using 'Storage Integrations' when working with External Stages?
It speeds up data loading.
Explanation
No.
Correct answer
It eliminates the need to pass secret credentials (like AWS Keys) in SQL text.
Explanation
Correct. Improves security.
It encrypts the S3 bucket.
Explanation
No.
It allows Snowflake to manage the S3 bucket's cost.
Explanation
No.
Overall explanation
Storage Integrations delegate authentication to the cloud provider's IAM roles. Ref: https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration
Domain
Security
Question 52
Skipped
Which of the following are 'Time Travel' actions? (Select 2)
Correct selection
Querying a table at a specific timestamp.
Explanation
Correct.
Increasing the Fail-safe period.
Explanation
No.
Recovering data from Fail-safe.
Explanation
No.
Correct selection
Undropping a database.
Explanation
Correct.
Overall explanation
Time Travel is about self-service historical access and restoration. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 53
Skipped
Which of the following is TRUE about 'Tasks' and 'Warehouses'?
Tasks are free to execute.
Explanation
No.
Tasks do not require a warehouse.
Explanation
Plausible (serverless tasks exist), but incorrect generally.
Correct answer
Tasks can use either a user-managed warehouse or Snowflake-managed (Serverless) compute.
Explanation
Correct.
Tasks always use the SYSADMIN warehouse.
Explanation
No.
Overall explanation
Flexibility in compute is a key feature of Snowflake Tasks. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 54
Skipped
An engineer wants to load data from a local folder using SnowSQL. Which command must be executed FIRST to move the file into Snowflake?
Correct answer
PUT file://... @stage.
Explanation
Correct. Moves the file from local to internal stage.
INSERT INTO table SELECT...
Explanation
No.
COPY INTO @stage.
Explanation
Plausible, but this loads from stage to table.
GET file://...
Explanation
No, this is for downloading.
Overall explanation
PUT is the essential first step for local file ingestion. Ref: https://docs.snowflake.com/en/sql-reference/sql/put
Domain
Data Movement
Question 55
Skipped
What is the default 'Time Travel' retention period for a new table in Snowflake 'Enterprise' Edition?
0 days.
Explanation
Plausible if it's transient, but default for permanent is 1.
7 days.
Explanation
No, that's Fail-safe.
90 days.
Explanation
Plausible, but this is the MAX, not the default.
Correct answer
1 day.
Explanation
Correct. Even in Enterprise, the default is 1 until manually increased.
Overall explanation
Users often confuse the default (1) with the maximum (90) available in higher editions. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 56
Skipped
A company wants to enable 'Multi-cluster Warehouses' but they only see the option for a single cluster. What is the most likely reason?
The warehouse is currently suspended.
Explanation
Plausible, but you can configure clusters while suspended.
They are using an X-Small warehouse.
Explanation
Plausible, but any size can be multi-cluster in the right edition.
They haven't enabled the 'Auto-scale' parameter in Cloud Services.
Explanation
Plausible name, but not a real parameter.
Correct answer
They are using the Standard Edition.
Explanation
Correct. Multi-cluster warehouses require Enterprise edition or higher.
Overall explanation
Edition-level restrictions are a common exam topic. Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Snowflake Architecture
Question 57
Skipped
What is the purpose of the 'VALIDATE_MODE' parameter in the COPY INTO command?
To check if the user has permissions.
Explanation
No.
Correct answer
To dry-run a load and identify errors without committing data.
Explanation
Correct.
To speed up the load.
Explanation
No.
To encrypt the files being loaded.
Explanation
No.
Overall explanation
VALIDATE_MODE is a critical tool for pre-ingestion testing. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 58
Skipped
When using Snowpipe with 'Auto-Ingest' enabled on AWS S3, what is the primary mechanism used to notify Snowflake of new files?
An AWS Lambda function that calls the Snowpipe REST API.
Explanation
Plausible, but that is the 'REST API' approach, not 'Auto-Ingest'.
Direct VPC Peering.
Explanation
No.
Correct answer
AWS SQS notifications sent to a Snowflake-managed SQS queue.
Explanation
Correct.
Snowflake periodically scans the S3 bucket every 5 minutes.
Explanation
Plausible (this is how manual pipes work), but Auto-Ingest uses events.
Overall explanation
Auto-Ingest relies on cloud native messaging services (SQS/SNS/Event Grid) for near real-time triggers. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3
Domain
Data Movement
Question 59
Skipped
Which of the following is TRUE about 'Fail-safe'?
It is part of Time Travel.
Explanation
No.
It is only for Transient tables.
Explanation
No.
Correct answer
It provides a 7-day safety net for data recovery.
Explanation
Correct.
It is configurable.
Explanation
No.
Overall explanation
Fail-safe is a non-negotiable 7-day period for all permanent tables. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 60
Skipped
What is the effect of setting the 'MIN_CLUSTER_COUNT' and 'MAX_CLUSTER_COUNT' to the same value in a Multi-cluster Warehouse?
The warehouse size (T-shirt size) becomes fixed.
Explanation
Incorrect, size and cluster count are different dimensions.
The warehouse is disabled.
Explanation
No.
Correct answer
The warehouse functions as a 'Static' multi-cluster warehouse with a fixed number of clusters.
Explanation
Correct. All clusters start and stop together.
The warehouse will automatically scale but stay within those bounds.
Explanation
Plausible, but if they are equal, there is no range to scale.
Overall explanation
Setting Min and Max to the same value effectively disables auto-scaling, providing constant high concurrency. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 61
Skipped
Which function is used to identify the current 'Namespace' (Database and Schema) of a session?
CURRENT_SCHEMA().
Explanation
Only schema.
CURRENT_DATABASE().
Explanation
Only database.
Correct answer
Both CURRENT_DATABASE() and CURRENT_SCHEMA().
Explanation
Correct.
CURRENT_NAMESPACE().
Explanation
Plausible, but doesn't exist.
Overall explanation
There is no single 'namespace' function; you use both session functions. Ref: https://docs.snowflake.com/en/sql-reference/functions/current_database
Domain
Account and Data Sharing
Question 62
Skipped
Which of the following is TRUE about 'Materialized Views'? (Select 2)
They can be created on top of other views.
Explanation
Plausible, but they must be on a base table.
Correct selection
They are automatically updated when the base table changes.
Explanation
Correct.
They do not require a warehouse for maintenance.
Explanation
Plausible, but they use serverless compute which costs credits.
Correct selection
They incur storage costs for the results they store.
Explanation
Correct.
Overall explanation
Materialized Views trade storage and background compute for query speed. Ref: https://docs.snowflake.com/en/user-guide/views-materialized
Domain
Performance and Warehouses
Question 63
Skipped
A user needs to load a CSV file where the strings are enclosed in single quotes (') instead of double quotes. Which file format option should they use?
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE.
Explanation
Unrelated.
TYPE = CSV.
Explanation
General type, not the specific option.
STRINGS_ENCLOSED_BY = 'SINGLE'.
Explanation
Plausible name, but incorrect syntax.
Correct answer
FIELD_OPTIONALLY_ENCLOSED_BY = '\''.
Explanation
Correct. Specifies the character used for quoting strings.
Overall explanation
File format options are granular to handle various legacy data formats. Ref: https://docs.snowflake.com/en/sql-reference/sql/create-file-format
Domain
Data Movement
Question 64
Skipped
Which of the following is TRUE about 'Fail-safe' storage?
It can be viewed using the SELECT * FROM table AT(...) syntax.
Explanation
No, that is Time Travel.
Correct answer
It is only accessible by Snowflake Support for disaster recovery.
Explanation
Correct. It is not a self-service feature.
It is only available in the Business Critical edition.
Explanation
Plausible, but it's available in all editions for Permanent tables.
It is stored in the Cloud Services layer.
Explanation
No, it is in the Storage layer.
Overall explanation
Fail-safe is a non-configurable 7-day safety net for permanent data. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 65
Skipped
What is the maximum 'Time Travel' retention for 'Transient' tables?
Correct answer
1 day.
Explanation
Correct. (0 or 1 only).
7 days.
Explanation
No (this is Fail-safe).
90 days.
Explanation
No.
0 days.
Explanation
Plausible, but can be 1.
Overall explanation
Transient tables are limited to 1 day of history to keep metadata light. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 66
Skipped
Which component of the Snowflake architecture handles 'Metadata'?
Storage Layer.
Explanation
No.
Network Layer.
Explanation
No.
Correct answer
Cloud Services Layer.
Explanation
Correct.
Compute Layer.
Explanation
No.
Overall explanation
Cloud Services is the centralized manager of all metadata. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 67
Skipped
What is the effect of 'Pruning' on query performance?
It encrypts the data.
Explanation
No.
It increases the amount of data scanned.
Explanation
No.
It compresses the data.
Explanation
No.
Correct answer
It decreases query time by skipping micro-partitions that don't match the filters.
Explanation
Correct.
Overall explanation
Pruning is why Snowflake can query Petabytes of data in seconds. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Performance and Warehouses
Question 68
Skipped
Which of the following are 'Object-level' privileges? (Select 2)
Correct selection
USAGE
Explanation
Correct. (on DBs/Schemas/Warehouses).
MANAGE GRANTS
Explanation
Incorrect. (Global).
CREATE USER
Explanation
Incorrect. (Account-level).
Correct selection
SELECT
Explanation
Correct. (on Tables/Views).
Overall explanation
Object-level privileges apply to specific data or compute containers. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Security
Question 69
Skipped
Which command is used to see the list of 'Files' currently residing in an internal stage?
SHOW FILES.
Explanation
Plausible, but incorrect syntax.
DESCRIBE STAGE.
Explanation
Shows properties, not files.
Correct answer
LIST @stage_name.
Explanation
Correct.
SELECT * FROM @stage_name.
Explanation
Plausible, but this queries the content, not the file names.
Overall explanation
The LIST command is the only way to inspect the file inventory of a stage. Ref: https://docs.snowflake.com/en/sql-reference/sql/list
Domain
Data Movement
Question 70
Skipped
What happens to a 'Stream' if the underlying source table is dropped?
Snowflake prevents dropping a table that has an active stream.
Explanation
Plausible, but you CAN drop it; it just breaks the stream.
The stream is converted into a table.
Explanation
No.
The stream is automatically moved to the Recycle Bin.
Explanation
No.
Correct answer
The stream becomes stale and unusable.
Explanation
Correct. It loses its reference point.
Overall explanation
Streams are dependent objects. Dropping the source table breaks the change tracking lineage. Ref: https://docs.snowflake.com/en/user-guide/streams-intro
Domain
Account and Data Sharing
Question 71
Skipped
A company is using a 'Small' warehouse. A query is spilling significantly to 'Remote Disk'. What is the most effective first step to solve this?
Re-cluster the table.
Explanation
Might help pruning, but doesn't fix memory issues for the join.
Correct answer
Increase the warehouse size to 'Medium' or 'Large'.
Explanation
Correct. Larger warehouses have more RAM/Local SSD per node, reducing spilling.
Add more clusters to the warehouse.
Explanation
Plausible, but that helps concurrency, not a single query's memory.
Enable Search Optimization Service.
Explanation
No, SOS is for lookups.
Overall explanation
Spilling to remote disk indicates the local resources (RAM/SSD) are exhausted; resizing up provides more local resources. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 72
Skipped
A user wants to change the warehouse size from 'Small' to 'Large' while a query is currently running. What happens to the running query?
The query is cancelled and must be restarted.
Explanation
Plausible, but Snowflake is more robust.
Correct answer
The query continues to run on the 'Small' warehouse until it finishes.
Explanation
Correct. The change only affects NEW queries.
The query speed doubles immediately.
Explanation
No.
The query is instantly moved to the 'Large' nodes.
Explanation
Plausible, but technically impossible to migrate live state.
Overall explanation
Resizing a warehouse is a metadata change that affects future workloads, not in-flight executions. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 73
Skipped
What is the primary role of 'Micro-partitions' in Snowflake?
Correct answer
To provide the physical storage unit for all table data.
Explanation
Correct.
To manage user sessions.
Explanation
No.
To store metadata only.
Explanation
No.
To encrypt the network.
Explanation
No.
Overall explanation
Every table in Snowflake is physically composed of these small files. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 74
Skipped
Which of the following is NOT an 'Internal Stage' type?
Named Stage.
Explanation
Valid.
Table Stage.
Explanation
Valid.
User Stage.
Explanation
Valid.
Correct answer
Account Stage.
Explanation
Correct. (Does not exist).
Overall explanation
There are User, Table, and Named internal stages. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 75
Skipped
Which command is used to 'Undrop' a schema?
RESTORE SCHEMA <name>.
Explanation
No.
UNDO SCHEMA <name>.
Explanation
No.
Correct answer
UNDROP SCHEMA <name>.
Explanation
Correct.
RECOVER SCHEMA <name>.
Explanation
No.
Overall explanation
UNDROP works for databases, schemas, and tables within the Time Travel period. Ref: https://docs.snowflake.com/en/sql-reference/sql/undrop-schema
Domain
Storage and Protection
Question 76
Skipped
Which of the following are 'Table-valued Functions' (TVFs) commonly used in Snowflake? (Select 2)
Correct selection
RESULT_SCAN
Explanation
Correct. Used to query previous query outputs.
TO_VARIANT
Explanation
This is a scalar function, not a TVF.
Correct selection
FLATTEN
Explanation
Correct. Used for semi-structured data.
VALIDATE
Explanation
Plausible, but it is a standalone function for COPY errors.
Overall explanation
TVFs return a set of rows and are usually used in the FROM clause with the TABLE() keyword. Ref: https://docs.snowflake.com/en/sql-reference/functions-table
Domain
Performance and Warehouses
Question 77
Skipped
Which command is used to see the list of 'Queries' executed by a specific user?
Correct answer
QUERY_HISTORY.
Explanation
Correct. (Available as a function or view).
DESCRIBE QUERIES.
Explanation
No.
LIST QUERIES.
Explanation
No.
SHOW QUERIES.
Explanation
Plausible, but the correct view is QUERY_HISTORY.
Overall explanation
QUERY_HISTORY is the primary audit trail for query execution. Ref: https://docs.snowflake.com/en/sql-reference/functions/query_history
Domain
Account and Data Sharing
Question 78
Skipped
Which privilege is needed to 'Modify' the size of a warehouse?
OPERATE.
Explanation
No. (Operate is start/stop).
MONITOR.
Explanation
No.
Correct answer
MODIFY.
Explanation
Correct.
USAGE.
Explanation
No.
Overall explanation
MODIFY is the specific privilege for changing configuration (size, auto-suspend). Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Security
Question 79
Skipped
Which of the following is NOT a Snowflake 'Cloud Provider'?
Correct answer
Oracle Cloud.
Explanation
Correct. (Not supported).
Google Cloud.
Explanation
Valid.
AWS.
Explanation
Valid.
Azure.
Explanation
Valid.
Overall explanation
Snowflake runs natively on the three major public clouds. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 80
Skipped
What is the maximum size of a 'VARIANT' column?
Correct answer
16 MB.
Explanation
Correct. (Compressed).
Unlimited.
Explanation
No.
1 MB.
Explanation
No.
1 GB.
Explanation
No.
Overall explanation
Every single VARIANT value must fit within the 16MB row limit. Ref: https://docs.snowflake.com/en/sql-reference/data-types-semistructured
Domain
Snowflake Architecture
Question 81
Skipped
Which role is best for creating 'Databases' and 'Warehouses'?
USERADMIN.
Explanation
No.
ACCOUNTADMIN.
Explanation
Plausible, but too high-level.
PUBLIC.
Explanation
No.
Correct answer
SYSADMIN.
Explanation
Correct. (Designed for resource management).
Overall explanation
SYSADMIN is the standard role for technical resource creation. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 82
Skipped
How can you improve the performance of 'Point Lookups' (queries looking for a single specific ID)?
Correct answer
Search Optimization Service (SOS).
Explanation
Correct.
Adding more RAM.
Explanation
No.
Creating a View.
Explanation
No.
Clustering.
Explanation
Plausible, but SOS is better for single values.
Overall explanation
SOS is designed specifically to optimize highly selective 'needle in a haystack' queries. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 83
Skipped
What is 'Automatic Suspend' designed to do?
Pause a query.
Explanation
No.
Correct answer
Shut down a warehouse after a period of inactivity to save credits.
Explanation
Correct.
Delete a warehouse.
Explanation
No.
Suspend a user.
Explanation
No.
Overall explanation
Auto-suspend is a critical feature for managing Snowflake costs. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 84
Skipped
True or False: Snowflake's 'Zero-copy Cloning' can be used to clone a single schema across two different databases.
FALSE
Correct answer
TRUE
Explanation
Correct. Cloning works at Database, Schema, and Table levels.
Overall explanation
Cloning is flexible and can be used to move/duplicate schemas between containers. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 85
Skipped
Which of the following is NOT a Snowflake 'Edition'?
Enterprise.
Explanation
Valid.
Correct answer
Professional.
Explanation
Correct. (Not a real edition).
Business Critical.
Explanation
Valid.
Standard.
Explanation
Valid.
Overall explanation
Knowing the editions is crucial for understanding feature availability (like Time Travel limits). Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Snowflake Architecture
Question 86
Skipped
Which command is used to see the list of 'Users' who have been granted a specific 'Role'?
Correct answer
SHOW GRANTS OF ROLE <name>.
Explanation
Correct.
LIST USERS.
Explanation
No.
SHOW USERS IN ROLE <name>.
Explanation
Plausible, but incorrect syntax.
DESCRIBE ROLE <name>.
Explanation
No.
Overall explanation
The SHOW GRANTS command is the primary way to audit the RBAC hierarchy. Ref: https://docs.snowflake.com/en/sql-reference/sql/show-grants
Domain
Security
Question 87
Skipped
Which function can be used to see the 'Min' and 'Max' values of a micro-partition without scanning the data?
SYSTEM$CLUSTERING_INFORMATION().
Explanation
Plausible, but for depth.
GET_METADATA().
Explanation
No.
SELECT MIN(col), MAX(col).
Explanation
Plausible, but this scans data.
Correct answer
This information is stored in the Metadata Cache (Cloud Services).
Explanation
Correct. Querying these doesn't require a warehouse.
Overall explanation
Metadata-only queries (like MIN/MAX/COUNT on whole tables) are handled by Cloud Services for free. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Snowflake Architecture
Question 88
Skipped
What is the 'Result Cache' retention time if the underlying data never changes?
7 days.
Explanation
No.
Unlimited.
Explanation
No.
Correct answer
24 hours.
Explanation
Correct. (But it resets if the query is run again).
1 hour.
Explanation
No.
Overall explanation
The 24-hour window is a fixed rule for result reuse. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 89
Skipped
Which of the following scenarios would prevent the 'Result Cache' from being reused? (Select 2)
Correct selection
The underlying data in the table has changed.
Explanation
Correct. Any DML invalidates the previous result.
The query is executed by a different user with the same role.
Explanation
Plausible, but same role can reuse the cache.
The warehouse size has been changed.
Explanation
Plausible, but the Result Cache is in the Cloud Services layer, independent of warehouse size.
Correct selection
The query includes a non-deterministic function like CURRENT_TIMESTAMP().
Explanation
Correct. Results that change every second cannot be cached.
Overall explanation
The Result Cache requires identical query text, identical base data, and deterministic functions. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 90
Skipped
A company wants to share data with 100 different customers. What is the most scalable way to manage this?
Use 100 Reader Accounts.
Explanation
Plausible, but doesn't solve the management of data logic.
Create 100 different databases.
Explanation
No.
Correct answer
Create a single Share and use 'Row Access Policies' to filter data for each customer.
Explanation
Correct.
Create 100 different shares.
Explanation
Plausible, but hard to manage.
Overall explanation
Dynamic security combined with Sharing is the standard for multi-tenant apps. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 91
Skipped
What is the function of the 'Object Tagging' feature?
To compress data.
Explanation
No.
To rename objects.
Explanation
No.
Correct answer
To categorize objects for governance and cost tracking.
Explanation
Correct.
To improve join performance.
Explanation
No.
Overall explanation
Tags provide logical grouping for non-structural attributes. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 92
Skipped
How does Snowflake charge for its 'Cloud Services' layer?
Correct answer
Only if cloud services usage exceeds 10% of daily warehouse credits.
Explanation
Correct. (The '10% rule').
It is always free.
Explanation
Plausible, but only up to a point.
It is a fixed monthly fee.
Explanation
No.
It is charged per query.
Explanation
No.
Overall explanation
Snowflake only bills for Cloud Services if they represent a significant portion of the account's activity. Ref: https://docs.snowflake.com/en/user-guide/cost-understanding-compute
Domain
Snowflake Architecture
Question 93
Skipped
Which role is required to execute the 'SYSTEM$ALLOWLIST()' function to troubleshoot network issues?
Correct answer
ANY ROLE.
Explanation
Correct. It is a utility function available to everyone.
SECURITYADMIN.
Explanation
No.
SYSADMIN.
Explanation
No.
ACCOUNTADMIN.
Explanation
Plausible, but too restrictive.
Overall explanation
Utility functions for connectivity are generally open to all users. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_allowlist
Domain
Security
Question 94
Skipped
What is the main purpose of a 'Storage Integration' object?
To increase storage speed.
Explanation
No.
To compress data on S3.
Explanation
No.
Correct answer
To provide a secure link between Snowflake and cloud storage without sharing credentials.
Explanation
Correct. Uses IAM roles/Service principles.
To move data from AWS to Azure.
Explanation
No.
Overall explanation
Storage Integrations are the security best practice for external stages. Ref: https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration
Domain
Security
Question 95
Skipped
Which of the following is a 'Semi-structured' data type in Snowflake?
Correct answer
VARIANT.
Explanation
Correct.
TIMESTAMP.
Explanation
Temporal.
GEOGRAPHY.
Explanation
Spatial.
VARCHAR.
Explanation
Structured.
Overall explanation
VARIANT is the core type that can store JSON, Parquet, or XML. Ref: https://docs.snowflake.com/en/sql-reference/data-types-semistructured
Domain
Storage and Protection
Question 96
Skipped
Which function returns the name of the current warehouse in use?
Correct answer
CURRENT_WAREHOUSE().
Explanation
Correct.
ACTIVE_WAREHOUSE().
Explanation
No.
WHICH_WAREHOUSE().
Explanation
No.
GET_WAREHOUSE().
Explanation
No.
Overall explanation
Session functions help contextualize queries and scripts. Ref: https://docs.snowflake.com/en/sql-reference/functions/current_warehouse
Domain
Performance and Warehouses
Question 97
Skipped
A company wants to prevent a specific warehouse from exceeding a budget of 100 credits per month. Which Resource Monitor action should they use to ensure no more credits are spent?
TERMINATE.
Explanation
Plausible, but the Snowflake term is Suspend.
NOTIFY.
Explanation
Only sends an alert.
SUSPEND.
Explanation
Correct. Prevents new queries but allows current ones to finish.
Correct answer
SUSPEND_IMMEDIATE.
Explanation
Correct. Cancels all running queries and suspends immediately to guarantee no more spend.
Overall explanation
SUSPEND_IMMEDIATE is the only way to strictly enforce a credit cap at the moment it is hit. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 98
Skipped
Which of the following is TRUE about 'Dynamic Data Masking'? (Select 2)
It requires Business Critical edition.
Explanation
Plausible, but Enterprise is enough.
It encrypts the data at rest on the disk.
Explanation
Plausible, but masking is just a display filter.
Correct selection
It can mask data based on the user's current role.
Explanation
Correct.
Correct selection
A single column can have different masking results for different roles.
Explanation
Correct.
Overall explanation
Masking policies are highly flexible and role-aware. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 99
Skipped
Which role is responsible for the overall management of 'Snowflake' credits and billing?
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
Correct.
Overall explanation
Only ACCOUNTADMIN has the holistic view and control over the account's wallet. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 100
Skipped
Which of the following is NOT a characteristic of 'Snowpipe'?
It can be triggered by cloud storage events.
Explanation
Characteristic.
It uses serverless compute.
Explanation
Characteristic.
It provides a REST API for programmatic ingestion.
Explanation
Characteristic.
Correct answer
It is designed for bulk loading of historical data.
Explanation
Correct. (Snowpipe is for continuous/micro-batching, not historical bulk).
Overall explanation
For historical bulk loads, COPY INTO with a warehouse is more efficient. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
Domain
Data Movement
Question 101
Skipped
What is the target size for 'Micro-partitions' (uncompressed) in Snowflake?
Correct answer
50 MB to 500 MB.
Explanation
Correct. Optimizes pruning and I/O.
1 MB to 10 MB.
Explanation
Too small.
100 GB.
Explanation
No.
1 GB to 5 GB.
Explanation
Too large.
Overall explanation
The 50-500MB range is the sweet spot for Snowflake's storage architecture. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 102
Skipped
Which of the following describes 'Account Usage' vs 'Information Schema' correctly?
Information Schema is in the SNOWFLAKE database.
Explanation
No, Account Usage is.
Correct answer
Account Usage includes dropped objects and up to 1 year of history.
Explanation
Correct.
Information Schema has 1 year of history.
Explanation
Plausible, but it has much less.
They are the same thing.
Explanation
No.
Overall explanation
Account Usage is the 'Auditor' (history), Information Schema is the 'Operator' (real-time). Ref: https://docs.snowflake.com/en/sql-reference/account-usage
Domain
Account and Data Sharing
Question 103
Skipped
What is the credit cost of a 'Stopped' warehouse?
1 credit per hour.
Explanation
No.
Correct answer
0 credits.
Explanation
Correct. (Though a minimum 1-minute charge applies when it starts).
Depends on the edition.
Explanation
No.
A flat monthly fee.
Explanation
No.
Overall explanation
Snowflake's per-second billing means you only pay for active compute time. Ref: https://docs.snowflake.com/en/user-guide/cost-understanding-compute
Domain
Performance and Warehouses
Question 104
Skipped
Which function is used to convert a VARIANT column containing a JSON array into a set of relational rows?
Correct answer
FLATTEN().
Explanation
Correct.
EXPLODE().
Explanation
Plausible (standard in Spark/Hive), but Snowflake uses FLATTEN.
UNNEST().
Explanation
Plausible (Standard SQL), but Snowflake uses FLATTEN.
SPLIT().
Explanation
No, this is for strings.
Overall explanation
FLATTEN is the table-valued function required to handle nested arrays in Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/functions/flatten
Domain
Storage and Protection
Question 105
Skipped
Which of the following are TRUE about 'Search Optimization Service' (SOS)? (Select 2)
Correct selection
It can be enabled for specific columns in a table.
Explanation
Correct.
It replaces the need for Clustering.
Explanation
Plausible, but they solve different problems (Point lookup vs Range).
It is available in the Standard edition.
Explanation
Incorrect. Requires Enterprise or higher.
Correct selection
It is a serverless service with its own credit costs.
Explanation
Correct.
Overall explanation
SOS is a background service that speeds up high-selectivity queries. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 106
Skipped
True or False: Snowflake 'Cloning' copies the 'Fail-safe' data of the original object.
TRUE
Explanation
Plausible, but Fail-safe is not cloned.
Correct answer
FALSE
Explanation
Correct. Cloning only involves the current metadata and Time Travel state.
Overall explanation
Cloning is about the 'active' and 'time travel' states, not the emergency recovery blocks. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 107
Skipped
Which of the following is TRUE about 'Dynamic Data Masking' (DDM)?
Masking changes the data stored in micro-partitions.
Explanation
No.
Correct answer
Masking is applied at execution time by the Cloud Services layer.
Explanation
Correct.
It requires the Business Critical edition.
Explanation
Plausible, but Enterprise is enough.
Masking only works for numeric data.
Explanation
No.
Overall explanation
DDM is a metadata-driven security layer that intercepts the query result. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 108
Skipped
A user wants to know how many credits a specific query consumed. Where is this information most easily found?
LOAD_HISTORY.
Explanation
No.
Correct answer
Query Profile or Query History.
Explanation
Correct.
Information Schema TABLES view.
Explanation
No.
Billing tab.
Explanation
Shows totals, not per-query credits.
Overall explanation
Query History provides per-query execution metrics, including compute time. Ref: https://docs.snowflake.com/en/user-guide/ui-query-history
Domain
Performance and Warehouses
Question 109
Skipped
A user wants to find out which files from an S3 bucket have been successfully loaded into a table. Which view should they query?
COPY_HISTORY.
Explanation
Plausible, but COPY_HISTORY is often a function for more detailed analysis.
Correct answer
LOAD_HISTORY.
Explanation
Correct. Tracks ingestion status and file names.
S3_HISTORY.
Explanation
No.
QUERY_HISTORY.
Explanation
No.
Overall explanation
LOAD_HISTORY provides the 'inventory' of loaded files and any errors encountered. Ref: https://docs.snowflake.com/en/sql-reference/info-schema/load_history
Domain
Data Movement
Question 110
Skipped
Which role can access the 'Organization' tab to manage multiple Snowflake accounts?
ACCOUNTADMIN.
Explanation
Plausible, but ORGADMIN is the specific role.
SYSADMIN.
Explanation
No.
SECURITYADMIN.
Explanation
No.
Correct answer
ORGADMIN.
Explanation
Correct.
Overall explanation
ORGADMIN is a specialized role for managing the entire organization's footprint. Ref: https://docs.snowflake.com/en/user-guide/admin-user-management
Domain
Security
Question 111
Skipped
What happens to 'Time Travel' when a table is renamed?
The history is deleted.
Explanation
No.
Time Travel is reset to 0.
Explanation
No.
Correct answer
The history is preserved and follows the new table name.
Explanation
Correct.
The history is moved to Fail-safe.
Explanation
No.
Overall explanation
Metadata changes (like renaming) do not affect the underlying micro-partition history. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 112
Skipped
Which of the following are 'Cloud Services' layer responsibilities? (Select 3)
Physical Data Storage.
Explanation
Plausible, but this is the Storage layer.
Correct selection
Authentication and Access Control.
Explanation
Correct.
Executing the Query.
Explanation
Incorrect. This is the Compute layer.
Data Encryption.
Explanation
Plausible, but it happens in the storage layer during write.
Correct selection
Infrastructure Management.
Explanation
Correct.
Correct selection
Query Parsing and Optimization.
Explanation
Correct.
Overall explanation
Cloud Services is the 'brain' that manages security, metadata, and optimization. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 113
Skipped
What is 'Vertical Scaling'?
Correct answer
Increasing the size of a warehouse (e.g. Small to Large).
Explanation
Correct.
Adding more users.
Explanation
No.
Adding more clusters.
Explanation
No (Horizontal).
Adding more storage.
Explanation
No.
Overall explanation
Vertical scaling improves the performance of individual, large queries. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 114
Skipped
What is the maximum number of 'Clusters' allowed in a single warehouse (default)?
Correct answer
10.
Explanation
Correct. (Can be increased via support).
100.
Explanation
No.
1.
Explanation
No.
Unlimited.
Explanation
No.
Overall explanation
The default max for a multi-cluster warehouse is 10. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 115
Skipped
In a 'Multi-cluster Warehouse' with 'Maximum Clusters = 5', how many clusters are running when the warehouse is in a 'SUSPENDED' state?
5.
Explanation
No.
Correct answer
0.
Explanation
Correct. Suspended means zero compute cost and zero nodes.
1.
Explanation
Plausible if you think the minimum is always 1, but suspended is 0.
Depends on the scaling policy.
Explanation
No.
Overall explanation
Suspension is the primary cost-saving mechanism in Snowflake. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 116
Skipped
Which of the following are valid 'Scaling Policies' for a Multi-cluster warehouse? (Select 2)
Balanced
Explanation
Plausible, but not a policy.
Performance
Explanation
Plausible, but not a policy.
Correct selection
Economy
Explanation
Correct.
High Efficiency
Explanation
No.
Correct selection
Standard
Explanation
Correct.
Overall explanation
There are only two policies: Standard (Performance) and Economy (Cost). Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 117
Skipped
What is the function of the 'Information Schema'?
To store user data.
Explanation
No.
To track security logs.
Explanation
No.
Correct answer
To provide SQL-based metadata views about the current database.
Explanation
Correct.
To manage billing.
Explanation
No.
Overall explanation
Each database contains an Information Schema for self-describing metadata. Ref: https://docs.snowflake.com/en/sql-reference/info-schema
Domain
Account and Data Sharing
Question 118
Skipped
Which of the following is a benefit of 'Micro-partitioning'?
Automatically creates indexes.
Explanation
No.
Eliminates the need for data types.
Explanation
No.
Correct answer
Allows for fine-grained pruning of data during queries.
Explanation
Correct.
Encrypts the data.
Explanation
No.
Overall explanation
Micro-partitions are the foundation of Snowflake's performance at scale. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 119
Skipped
What is the credit cost for 'Fail-safe' storage?
It is free.
Explanation
Plausible, but it's part of storage costs.
Correct answer
Same as regular storage (billed per TB/Month).
Explanation
Correct. Data in Fail-safe still consumes storage credits.
It is part of the Cloud Services 10% rule.
Explanation
No.
Double the regular storage cost.
Explanation
No.
Overall explanation
Fail-safe is data that occupies disk space, and thus is billed as storage. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 120
Skipped
Which of the following is TRUE about 'Secure Views'?
They are available in all editions.
Explanation
Plausible, but Enterprise is needed for some sharing features.
Correct answer
They prevent users from seeing the base tables and the query logic.
Explanation
Correct.
They are always faster than standard views.
Explanation
No.
They cannot be cloned.
Explanation
No.
Overall explanation
Secure views are the standard for privacy in shared environments. Ref: https://docs.snowflake.com/en/user-guide/views-secure
Domain
Account and Data Sharing