Question 1
Incorrect
What happens to the data in a 'Stage' after it is successfully loaded using 'PURGE = TRUE'?
Your answer is incorrect
The data is archived.
Explanation
No.
Correct answer
The files are deleted from the stage.
Explanation
Correct. Helps manage storage and costs.
The data is moved to a backup table.
Explanation
No.
The data is encrypted.
Explanation
No.
Overall explanation
PURGE is a common practice to clean up landing zones automatically. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 2
Skipped
Which of the following are components of the 'Compute Layer'? (Select 2)
Micro-partitions.
Explanation
Incorrect (Storage layer).
Correct selection
CPU and RAM.
Explanation
Correct. Resources used for processing.
Metadata Manager.
Explanation
Incorrect (Cloud Services).
Correct selection
Virtual Warehouses.
Explanation
Correct.
Overall explanation
The compute layer is where the 'work' happens in Snowflake. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 3
Skipped
Which function is used to convert a JSON string into a Snowflake VARIANT?
FORMAT_JSON().
Explanation
No.
TO_VARIANT().
Explanation
No.
Correct answer
PARSE_JSON().
Explanation
Correct.
CAST_JSON().
Explanation
No.
Overall explanation
PARSE_JSON is the foundation for semi-structured data ingestion. Ref: https://docs.snowflake.com/en/sql-reference/functions/parse_json
Domain
Storage and Protection
Question 4
Skipped
Which of the following is TRUE about 'Fail-safe'? (Select 2)
Correct selection
It is only for permanent tables.
Explanation
Correct.
Correct selection
Users cannot manually recover data from it.
Explanation
Correct. Snowflake Support must be contacted.
It is configurable.
Explanation
Incorrect (Fixed at 7 days).
It replaces Time Travel.
Explanation
Incorrect.
Overall explanation
Fail-safe is the last line of defense in the Snowflake data lifecycle. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 5
Skipped
Which of the following are TRUE about 'Network Policies'? (Select 2)
They automatically encrypt data in transit.
Explanation
Incorrect. They restrict IP access.
Correct selection
They can be applied at the User level.
Explanation
Correct. Overrides the account-level policy for that specific user.
They can be applied at the Database level.
Explanation
Incorrect. Only Account and User levels.
Correct selection
They can be applied at the Account level.
Explanation
Correct. Affects all users in the account.
Overall explanation
Network policies provide a layer of security by restricting access to specific CIDR IP ranges. Ref: https://docs.snowflake.com/en/user-guide/network-policies
Domain
Security
Question 6
Skipped
What is the 'Default' warehouse size when creating a warehouse without specifying one?
Medium.
Explanation
No.
Small.
Explanation
No.
Correct answer
X-Small.
Explanation
Correct. Starts with the smallest footprint.
Large.
Explanation
No.
Overall explanation
Snowflake defaults to the most cost-conservative size. Ref: https://docs.snowflake.com/en/sql-reference/sql/create-warehouse
Domain
Performance and Warehouses
Question 7
Skipped
What is the purpose of 'Resource Monitors'?
To speed up queries.
Explanation
No.
To manage storage.
Explanation
No.
To monitor network traffic.
Explanation
No.
Correct answer
To track and control credit consumption of warehouses.
Explanation
Correct.
Overall explanation
Resource Monitors help prevent budget overruns by alerting or suspending warehouses. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 8
Skipped
What is the function of the 'Metadata Manager' in Cloud Services?
To store user passwords.
Explanation
No.
To compress data.
Explanation
No.
Correct answer
To keep track of micro-partition locations and statistics.
Explanation
Correct.
To manage the physical hardware.
Explanation
No.
Overall explanation
Metadata management is what makes 'zero-management' storage possible. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 9
Skipped
Which of the following can be shared using 'Snowflake Data Sharing'? (Select 3)
Correct selection
Secure UDFs.
Explanation
Correct.
Correct selection
Tables.
Explanation
Correct.
Warehouses.
Explanation
No.
Users.
Explanation
No.
Internal Stages.
Explanation
No.
Correct selection
Secure Views.
Explanation
Correct.
Overall explanation
Sharing is restricted to read-only data objects. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 10
Skipped
Which function is used to convert a string into a date?
STR_TO_DATE().
Explanation
No.
PARSE_DATE().
Explanation
No.
Correct answer
TO_DATE().
Explanation
Correct.
MAKE_DATE().
Explanation
No.
Overall explanation
Data conversion functions are essential for ETL tasks. Ref: https://docs.snowflake.com/en/sql-reference/functions/to_date
Domain
Account and Data Sharing
Question 11
Skipped
Which of the following are types of 'Caches' in Snowflake? (Select 3)
Correct selection
Warehouse Cache (Local Disk).
Explanation
Correct. Stores data blocks on the compute nodes.
External Cache.
Explanation
Incorrect.
Correct selection
Result Cache.
Explanation
Correct. Stores results for 24h.
Memory Cache.
Explanation
Incorrect (though RAM is used, it is not a named cache type in this context).
Correct selection
Metadata Cache.
Explanation
Correct. Stores statistics about micro-partitions.
Overall explanation
Snowflake's 3-tier caching architecture dramatically improves query speed. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 12
Skipped
Which of the following is TRUE about 'Stages'? (Select 2)
Correct selection
External stages point to cloud storage like S3.
Explanation
Correct.
Correct selection
Internal stages are managed by Snowflake.
Explanation
Correct.
Stages store data in tables.
Explanation
No.
Stages are used for backups.
Explanation
No.
Overall explanation
Stages are intermediate locations for files before they are loaded or after they are exported. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 13
Skipped
Which role can create 'Shares' by default?
SYSADMIN.
Explanation
No.
USERADMIN.
Explanation
No.
PUBLIC.
Explanation
No.
Correct answer
ACCOUNTADMIN.
Explanation
Correct.
Overall explanation
ACCOUNTADMIN is the only role with the initial privilege to manage shares. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 14
Skipped
Which role is required to execute the 'SYSTEM$ALLOWLIST()' function?
ACCOUNTADMIN only.
Explanation
No.
Correct answer
ANY ROLE.
Explanation
Correct. It is a utility function for connectivity.
SECURITYADMIN only.
Explanation
No.
SYSADMIN only.
Explanation
No.
Overall explanation
This function helps users identify hostnames and ports required for connectivity. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_allowlist
Domain
Security
Question 15
Skipped
Which of the following describes 'Zero-copy Cloning' correctly? (Select 2)
It duplicates all data on disk.
Explanation
Incorrect.
Correct selection
It allows for cost-effective dev/test environments.
Explanation
Correct.
It is only for tables.
Explanation
Incorrect.
Correct selection
It is near-instant.
Explanation
Correct. Only metadata is copied.
Overall explanation
Cloning is a metadata operation that doesn't consume extra storage until changes are made. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 16
Skipped
What is the 'Fail-safe' duration for 'Transient' tables?
1 day.
Explanation
No.
90 days.
Explanation
No.
Correct answer
0 days.
Explanation
Correct. (Transient tables do NOT have Fail-safe).
7 days.
Explanation
No.
Overall explanation
Transient tables are cheaper because they skip the 7-day Fail-safe storage cost. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 17
Skipped
What does 'Horizontal Scaling' mean in Snowflake?
Adding more users.
Explanation
No.
Adding more CPU to a warehouse.
Explanation
No (Vertical).
Correct answer
Adding more clusters to a Multi-cluster warehouse.
Explanation
Correct. Handles concurrency.
Adding more storage.
Explanation
No.
Overall explanation
Horizontal scaling allows more queries to run at the same time. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 18
Skipped
What is the maximum number of 'Fail-safe' days for a 'Temporary' table?
1 day.
Explanation
No.
7 days.
Explanation
No.
90 days.
Explanation
No.
Correct answer
0 days.
Explanation
Correct. Temporary tables have NO Fail-safe.
Overall explanation
Like Transient tables, Temporary tables save on storage costs by omitting Fail-safe. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 19
Skipped
Which component of the Snowflake architecture stores metadata?
Storage Layer.
Explanation
No.
Compute Layer.
Explanation
No.
Correct answer
Cloud Services Layer.
Explanation
Correct.
Virtual Warehouse.
Explanation
No.
Overall explanation
Cloud Services manages the metadata that makes pruning and optimization possible. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 20
Skipped
What is the main benefit of 'Multi-cluster Warehouses'?
Improving the speed of a single complex query.
Explanation
No (Vertical scaling does this).
Correct answer
Handling high concurrency from many simultaneous users.
Explanation
Correct.
Automating backups.
Explanation
No.
Reducing storage costs.
Explanation
No.
Overall explanation
Multi-cluster warehouses solve the 'queuing' problem during peak times. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 21
Skipped
Which of the following describes 'Object Tagging'?
Correct answer
It allows for data classification (e.g., PII, Cost Center).
Explanation
Correct.
It speeds up queries.
Explanation
No.
It is a clustering method.
Explanation
No.
It only works on databases.
Explanation
No.
Overall explanation
Tags help with governance and organizational visibility. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 22
Skipped
Which of the following are components of the 'Cloud Services' layer? (Select 3)
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
Correct selection
Security Manager.
Explanation
Correct.
Compute Nodes.
Explanation
Incorrect.
Overall explanation
Cloud Services is the 'Always-on' management layer. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 23
Skipped
What does 'Zero-copy' mean in cloning?
There is no metadata.
Explanation
No.
Correct answer
The data is not duplicated.
Explanation
Correct. Both objects point to the same partitions.
The query cost is zero.
Explanation
No.
The storage cost is zero.
Explanation
No, but it is initially zero until changes happen.
Overall explanation
Zero-copy cloning makes Snowflake very cost-effective for dev/test environments. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 24
Skipped
What is the maximum file size Snowflake recommends for a single file being loaded?
10 MB.
Explanation
Too small (causes overhead).
5 GB.
Explanation
No.
Correct answer
100 - 250 MB (compressed).
Explanation
Correct. For optimal warehouse parallelization.
1 GB.
Explanation
No.
Overall explanation
Optimizing file size is a core part of the 'Data Movement' domain in the exam. Ref: https://docs.snowflake.com/en/user-guide/data-load-considerations-prepare
Domain
Data Movement
Question 25
Skipped
Which of the following is NOT a valid 'Scaling Policy'?
Correct answer
Performance.
Explanation
Correct. (Not a policy name).
None.
Explanation
No.
Standard.
Explanation
Valid.
Economy.
Explanation
Valid.
Overall explanation
There are only two policies: Standard and Economy. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 26
Skipped
What is 'Horizontal Scaling' in a warehouse?
Changing size from S to M.
Explanation
No (Vertical).
Adding more users.
Explanation
No.
Correct answer
Adding or removing clusters to handle concurrency.
Explanation
Correct.
Adding more storage.
Explanation
No.
Overall explanation
Horizontal scaling is the job of Multi-cluster warehouses. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 27
Skipped
Which function is used to convert a VARIANT value into a numeric format?
TO_NUMBER().
Explanation
Incorrect.
GET_NUMBER().
Explanation
No.
Correct answer
CAST(col:key AS NUMBER).
Explanation
Correct. Or using the :: syntax.
PARSE_NUMBER().
Explanation
No.
Overall explanation
Casting is required when moving from semi-structured VARIANT to structured numeric types. Ref: https://docs.snowflake.com/en/user-guide/querying-semistructured
Domain
Storage and Protection
Question 28
Skipped
Which of the following describes 'Zero-copy Cloning' correctly?
It only works for tables.
Explanation
No.
It requires a running warehouse.
Explanation
No.
Correct answer
It creates a new set of metadata pointing to the same micro-partitions.
Explanation
Correct. Instant and cost-free initially.
It copies data to a new storage location.
Explanation
No.
Overall explanation
Cloning is efficient because it shares the underlying data blocks. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 29
Skipped
What is 'Fail-safe' primarily used for?
Regular queries.
Explanation
No.
Improving performance.
Explanation
No.
Storing logs.
Explanation
No.
Correct answer
Emergency data recovery by Snowflake Support.
Explanation
Correct.
Overall explanation
Fail-safe is a last resort after Time Travel has expired. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 30
Skipped
What is the function of the 'QUERY_HISTORY' view?
To manage users.
Explanation
No.
To delete queries.
Explanation
No.
To see current table sizes.
Explanation
No.
Correct answer
To audit and monitor all queries executed in the last 45 minutes to 1 year (depending on view).
Explanation
Correct.
Overall explanation
Query History is vital for auditing, debugging, and cost management. Ref: https://docs.snowflake.com/en/sql-reference/functions/query_history
Domain
Account and Data Sharing
Question 31
Skipped
Which of the following is TRUE about 'Secure UDFs'?
They are only for admins.
Explanation
No.
Correct answer
They protect the internal code from being viewed by unauthorized users.
Explanation
Correct.
They are always faster.
Explanation
No.
They can only be used in SQL.
Explanation
No.
Overall explanation
Secure UDFs are essential for sharing business logic safely. Ref: https://docs.snowflake.com/en/user-guide/views-secure
Domain
Account and Data Sharing
Question 32
Skipped
Which of the following is TRUE about 'Clustering Keys'?
They should be used on all tables.
Explanation
No.
Correct answer
They are most effective on tables in the multi-terabyte range.
Explanation
Correct. Helps with massive data pruning.
They prevent data from being compressed.
Explanation
No.
They are free to maintain.
Explanation
No, they use serverless credits.
Overall explanation
Clustering should be used selectively for performance issues on very large tables. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 33
Skipped
What is the maximum number of columns allowed in a single Snowflake table?
5,000
Explanation
No.
1,000
Explanation
No.
Correct answer
No hard limit.
Explanation
Correct. Snowflake doesn't enforce a hard column count limit beyond the row size.
10,000
Explanation
No.
Overall explanation
While there is no fixed limit on columns, the total data in a single row cannot exceed 16MB. Ref: https://docs.snowflake.com/en/sql-reference/data-types-numeric
Domain
Snowflake Architecture
Question 34
Skipped
Which of the following is NOT a type of 'Internal Stage'?
Table Stage.
Explanation
Is an internal stage.
Correct answer
External Stage.
Explanation
Correct. This points to external cloud storage.
Named Stage.
Explanation
Is an internal stage.
User Stage.
Explanation
Is an internal stage.
Overall explanation
External stages are just pointers; Snowflake doesn't 'own' the storage. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 35
Skipped
A company needs to load 500 small JSON files every minute. Which ingestion method is the most cost-effective?
Correct answer
Snowpipe (Auto-Ingest).
Explanation
Correct. Designed for continuous loading of small files with serverless compute.
Cloning a stage.
Explanation
Cloning is not an ingestion method.
External Tables.
Explanation
External tables provide access but are slower than ingestion.
Bulk loading using COPY INTO every minute.
Explanation
Inefficient for small frequent files due to warehouse overhead.
Overall explanation
Snowpipe is the recommended tool for 'micro-batching' and near real-time ingestion. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
Domain
Data Movement
Question 36
Skipped
What is 'Clustering Depth' used to measure?
Correct answer
The effectiveness of a table's clustering.
Explanation
Correct. (Lower is better).
How many rows are in a table.
Explanation
No.
The size of a warehouse.
Explanation
No.
The depth of a JSON file.
Explanation
No.
Overall explanation
A well-clustered table has low depth, meaning filters can skip more data. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions
Domain
Performance and Warehouses
Question 37
Skipped
Which function is used to combine multiple strings into one?
JOIN().
Explanation
No.
MERGE().
Explanation
No.
COMBINE().
Explanation
No.
Correct answer
CONCAT().
Explanation
Correct.
Overall explanation
CONCAT (or the || operator) is used for string manipulation. Ref: https://docs.snowflake.com/en/sql-reference/functions/concat
Domain
Account and Data Sharing
Question 38
Skipped
Which command is used to upload a file from a local computer to a Snowflake stage?
UPLOAD.
Explanation
No.
GET.
Explanation
Downloads.
COPY INTO.
Explanation
No (that's stage to table).
Correct answer
PUT.
Explanation
Correct. Requires SnowSQL or a driver.
Overall explanation
PUT is the client-side command for data movement into Snowflake. Ref: https://docs.snowflake.com/en/sql-reference/sql/put
Domain
Data Movement
Question 39
Skipped
Which of the following is TRUE about 'Clustering Keys'? (Select 2)
Correct selection
They incur costs for background maintenance.
Explanation
Correct. Serverless cost.
They replace the need for micro-partitions.
Explanation
No.
They are recommended for all tables.
Explanation
No, only very large ones.
Correct selection
They significantly improve pruning on filtered columns.
Explanation
Correct.
Overall explanation
Clustering should be used when the natural load order doesn't provide enough performance. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 40
Skipped
What is 'Pruning' in Snowflake?
Masking data.
Explanation
No.
Correct answer
Process of skipping micro-partitions that do not match the query filters.
Explanation
Correct. Essential for performance.
Deleting old data.
Explanation
No.
Resizing a warehouse.
Explanation
No.
Overall explanation
Pruning reduces the I/O needed to answer a query. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Performance and Warehouses
Question 41
Skipped
Which scaling policy waits for 6 minutes before scaling up?
Correct answer
Economy.
Explanation
Correct. Prioritizes saving credits.
Balanced.
Explanation
No.
Aggressive.
Explanation
No.
Standard.
Explanation
No.
Overall explanation
Economy mode is cost-efficient but might lead to small wait times. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 42
Skipped
Which function can be used to see if a 'Stream' has new data?
CHECK_STREAM().
Explanation
No.
Correct answer
SYSTEM$STREAM_HAS_DATA().
Explanation
Correct. Commonly used in Task definitions.
STREAM_HAS_DATA().
Explanation
No.
HAS_CHANGES().
Explanation
No.
Overall explanation
This function prevents tasks from running (and wasting credits) if there's no new data. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_stream_has_data
Domain
Account and Data Sharing
Question 43
Skipped
A user needs to find out why a query was slow. Which tool provides a visual representation of the query execution steps?
Correct answer
Query Profile.
Explanation
Correct. Shows bottlenecks like 'spilling' or 'scans'.
Query History.
Explanation
Shows the list of queries.
Account Usage.
Explanation
No.
Table History.
Explanation
No.
Overall explanation
The Query Profile is the primary tool for performance troubleshooting. Ref: https://docs.snowflake.com/en/user-guide/ui-query-profile
Domain
Performance and Warehouses
Question 44
Skipped
In a 'Multi-cluster Warehouse', what happens in 'Economy' mode?
Correct answer
Snowflake waits until there is enough load to keep a cluster busy for 6 minutes.
Explanation
Correct. Saves credits by delaying scale-out.
Clusters start immediately.
Explanation
No, that's Standard.
It uses cheaper hardware.
Explanation
No.
It only allows 1 user at a time.
Explanation
No.
Overall explanation
Economy mode is best for batch processing where slight delays (queuing) are acceptable. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 45
Skipped
Which role is the 'Owner' of a table by default?
SYSADMIN.
Explanation
No.
ACCOUNTADMIN.
Explanation
No.
The USER who created it.
Explanation
No, roles own objects.
Correct answer
The ROLE that created it.
Explanation
Correct.
Overall explanation
Snowflake RBAC is built on roles, not individual users. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 46
Skipped
What does the 'ON_ERROR = CONTINUE' option do in a COPY INTO command?
Deletes the table if an error occurs.
Explanation
No.
Corrects the errors automatically.
Explanation
No.
Stops the load at the first error.
Explanation
No, that's ON_ERROR = ABORT_STATEMENT.
Correct answer
Skips the rows with errors and continues loading the rest of the file.
Explanation
Correct.
Overall explanation
ON_ERROR settings allow for flexible handling of 'dirty' data during ingestion. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 47
Skipped
What is the maximum retention for 'Time Travel' in a 'Permanent' table (Enterprise Edition)?
7 days.
Explanation
No (this is Fail-safe).
Correct answer
90 days.
Explanation
Correct.
1 day.
Explanation
Default, but not maximum.
365 days.
Explanation
No.
Overall explanation
Enterprise Edition provides extended history for data auditing and recovery. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 48
Skipped
What is the credit cost for 'Storage' in Snowflake?
Correct answer
Monthly fee based on average daily TB used.
Explanation
Correct. Billed as a pass-through cost.
1 credit per GB.
Explanation
No.
Storage is free.
Explanation
No.
Billed per query.
Explanation
No.
Overall explanation
Storage is calculated based on daily averages after compression. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 49
Skipped
Which of the following is NOT an 'Account-level' object?
Role.
Explanation
Is Account-level.
User.
Explanation
Is Account-level.
Warehouse.
Explanation
Is Account-level.
Correct answer
Schema.
Explanation
Correct. It is a Database-level object.
Overall explanation
Schemas and Tables are 'children' of a Database. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Account and Data Sharing
Question 50
Skipped
Which of the following are valid 'Privileges' that can be granted on a Database? (Select 2)
Correct selection
CREATE SCHEMA
Explanation
Correct. Allows creating new schemas within the database.
CREATE TABLE
Explanation
Incorrect. This is a schema-level privilege.
Correct selection
USAGE
Explanation
Correct. Allows seeing the database and its schemas.
SELECT
Explanation
Incorrect. This is a table-level privilege.
Overall explanation
Database privileges focus on organization and access, not on individual data rows. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Security
Question 51
Skipped
Which of the following describes 'Account Usage' vs 'Information Schema'?
They are identical.
Explanation
No.
Correct answer
Account Usage contains dropped objects and 1 year of history.
Explanation
Correct. Information Schema excludes dropped and has shorter history.
Information Schema has 1 year of history.
Explanation
No.
Account Usage has real-time data.
Explanation
No, Information Schema does.
Overall explanation
Account Usage (SNOWFLAKE DB) is better for historical auditing. Ref: https://docs.snowflake.com/en/sql-reference/account-usage
Domain
Account and Data Sharing
Question 52
Skipped
Which of the following are 'Semi-structured' formats? (Select 3)
CSV.
Explanation
Incorrect (Structured).
Correct selection
Avro.
Explanation
Correct.
Correct selection
Parquet.
Explanation
Correct.
MP3.
Explanation
Incorrect.
TXT.
Explanation
Incorrect.
Correct selection
JSON.
Explanation
Correct.
Overall explanation
Snowflake treats JSON, Avro, Parquet, ORC, and XML as semi-structured. Ref: https://docs.snowflake.com/en/user-guide/data-load-prepare
Domain
Data Movement
Question 53
Skipped
Which of the following are characteristics of 'Multi-cluster Warehouses'? (Select 3)
Correct selection
They scale horizontally to handle concurrency.
Explanation
Correct. Adds clusters as users increase.
Correct selection
They automatically shut down the least-used cluster first.
Explanation
Correct. Based on the scaling policy.
They scale vertically to handle complex queries.
Explanation
Incorrect. That is resizing (Scale-up).
They eliminate the need for micro-partitions.
Explanation
Incorrect.
Correct selection
They can be configured with a Maximum and Minimum number of clusters.
Explanation
Correct. This defines the scaling boundaries.
They are available in the Standard Edition.
Explanation
Incorrect. Requires Enterprise or higher.
Overall explanation
Multi-cluster warehouses are specifically designed to eliminate queuing during high user concurrency. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 54
Skipped
What is the maximum size of a single VARIANT column?
Unlimited.
Explanation
No.
1 MB.
Explanation
No.
Correct answer
16 MB (compressed).
Explanation
Correct. This is the row size limit.
1 GB.
Explanation
No.
Overall explanation
Semi-structured data in VARIANT type is subject to the row size limit. Ref: https://docs.snowflake.com/en/sql-reference/data-types-semistructured
Domain
Storage and Protection
Question 55
Skipped
What is the purpose of 'Row Access Policies'?
To cluster rows.
Explanation
No.
To mask columns.
Explanation
No (Dynamic Masking).
To delete rows.
Explanation
No.
Correct answer
To restrict which rows are returned to a user based on their role.
Explanation
Correct. Row-level security.
Overall explanation
Row Access Policies act as an automatic filter for data security. Ref: https://docs.snowflake.com/en/user-guide/security-row-intro
Domain
Security
Question 56
Skipped
Which of the following describes 'Search Optimization Service' best?
It speeds up joins.
Explanation
No.
Correct answer
It improves performance for 'point lookups' (selective filters) on large tables.
Explanation
Correct.
It is only for JSON.
Explanation
No.
It replaces the warehouse.
Explanation
No.
Overall explanation
SOS is like a 'super-index' for specific, highly selective queries. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 57
Skipped
True or False: A user can belong to multiple 'Roles' simultaneously in Snowflake.
FALSE
Explanation
Only one is 'active' at a time, but they can have many.
Correct answer
TRUE
Explanation
Correct. A user can be granted many roles.
Overall explanation
Snowflake's RBAC allows for complex permission structures by assigning multiple roles to users. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 58
Skipped
Which role is best for creating new users and roles?
Correct answer
USERADMIN.
Explanation
Correct. Defined for this specific purpose.
SYSADMIN.
Explanation
No.
ACCOUNTADMIN.
Explanation
Can do it, but USERADMIN is more restricted.
PUBLIC.
Explanation
No.
Overall explanation
USERADMIN follows the principle of least privilege for identity management. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 59
Skipped
Which command allows you to switch to a different role in a session?
SWITCH ROLE.
Explanation
No.
SET ROLE.
Explanation
No.
Correct answer
USE ROLE <name>.
Explanation
Correct.
CHANGE ROLE.
Explanation
No.
Overall explanation
USE ROLE is the standard session-level command for role switching. Ref: https://docs.snowflake.com/en/sql-reference/sql/use-role
Domain
Security
Question 60
Skipped
Which of the following is TRUE about 'Object Tagging'? (Select 2)
Tags are used to speed up queries.
Explanation
Incorrect.
Correct selection
Tags can be used for cost center attribution.
Explanation
Correct.
Tags replace the need for roles.
Explanation
Incorrect.
Correct selection
Tags can be used to track PII data.
Explanation
Correct.
Overall explanation
Tags provide metadata that fuels governance and financial reporting. Ref: https://docs.snowflake.com/en/user-guide/object-tagging
Domain
Security
Question 61
Skipped
Which function returns the current active role?
GET_ROLE().
Explanation
No.
CURRENT_USER().
Explanation
No.
WHICH_ROLE().
Explanation
No.
Correct answer
CURRENT_ROLE().
Explanation
Correct.
Overall explanation
Essential for auditing and dynamic security policies. Ref: https://docs.snowflake.com/en/sql-reference/functions/current_role
Domain
Security
Question 62
Skipped
Which of the following are 'Serverless' features in Snowflake? (Select 3)
Virtual Warehouse queries.
Explanation
Incorrect. User-managed.
Correct selection
Snowpipe.
Explanation
Correct.
External Tables.
Explanation
Incorrect.
Correct selection
Automatic Re-clustering.
Explanation
Correct.
Correct selection
Materialized View Maintenance.
Explanation
Correct.
Overall explanation
Serverless features are managed by Snowflake and billed separately from virtual warehouses. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 63
Skipped
What is the maximum retention for 'Time Travel' in 'Transient' tables?
0 days.
Explanation
No (but can be set to 0).
7 days.
Explanation
No.
90 days.
Explanation
No.
Correct answer
1 day.
Explanation
Correct. Transient tables are 0 or 1 day.
Overall explanation
Transient tables are for data that doesn't need long-term history or Fail-safe. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 64
Skipped
What is the best practice for file sizing when loading data into Snowflake?
Files should be 1 KB each.
Explanation
No, this causes 'file overhead' and slowness.
File size does not matter in Snowflake.
Explanation
Incorrect. It matters for performance.
Correct answer
Files should be between 100-250 MB compressed.
Explanation
Correct. This allows optimal distribution across warehouse nodes.
Files should be as large as possible (e.g. 5GB+).
Explanation
No, this limits parallelism.
Overall explanation
Sizing files correctly ensures that all threads in a warehouse can work in parallel. Ref: https://docs.snowflake.com/en/user-guide/data-load-considerations-prepare
Domain
Data Movement
Question 65
Skipped
Which of the following is TRUE regarding 'Replication'? (Select 2)
Correct selection
It requires a Business Critical edition for failover.
Explanation
Correct. Basic replication is Enterprise, but Failover is BC.
It is only for databases.
Explanation
Incorrect.
Correct selection
It allows for data to be available in different regions.
Explanation
Correct.
It is free.
Explanation
No, involves data egress and compute costs.
Overall explanation
Replication is the core of Snowflake's disaster recovery strategy. Ref: https://docs.snowflake.com/en/user-guide/database-replication-intro
Domain
Account and Data Sharing
Question 66
Skipped
A company detects a 'Remote Disk Spilling' issue in a large join query. What is the most likely cause?
The table has too many micro-partitions.
Explanation
No.
The network is slow.
Explanation
No.
Correct answer
The working set of data for the join does not fit in RAM or local SSD.
Explanation
Correct. It had to spill all the way to cloud storage.
The local SSD on the warehouse nodes is full.
Explanation
No, that would be local spilling.
Overall explanation
Remote spilling is the slowest type of execution because it involves writing temporary data to cloud storage. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 67
Skipped
What happens to a 'Temporary' table when the session ends?
It is moved to Fail-safe.
Explanation
No.
It is moved to Time Travel.
Explanation
No.
Correct answer
It is automatically dropped and deleted.
Explanation
Correct. Only exists for the session.
It is saved as a Permanent table.
Explanation
No.
Overall explanation
Temporary tables are non-persistent and only visible within the current session. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 68
Skipped
Which role is required to see the 'Billing' tab in the Snowflake UI?
SYSADMIN.
Explanation
No.
USERADMIN.
Explanation
No.
Correct answer
ACCOUNTADMIN.
Explanation
Correct. High-level financial access.
SECURITYADMIN.
Explanation
No.
Overall explanation
The ACCOUNTADMIN role is the ultimate authority for billing and account settings. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Account and Data Sharing
Question 69
Skipped
What is 'Automatic Re-clustering'?
A data sharing feature.
Explanation
No.
Correct answer
A serverless service that keeps tables optimized.
Explanation
Correct.
A way to resize warehouses.
Explanation
No.
A manual command.
Explanation
No.
Overall explanation
Snowflake manages the background maintenance of clustered tables. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-keys
Domain
Performance and Warehouses
Question 70
Skipped
A company wants to share data with a 'Consumer' who does NOT have a Snowflake account. What should the 'Provider' create?
Correct answer
A Reader Account.
Explanation
Correct. The provider pays for the reader's compute.
A Direct Share.
Explanation
Only for Snowflake users.
An API Integration.
Explanation
No.
A Secure View.
Explanation
Insufficient on its own.
Overall explanation
Reader Accounts allow providers to share data with anyone, regardless of their Snowflake status. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 71
Skipped
Which of the following is TRUE about 'SnowSQL'?
Correct answer
It is a command-line interface for Snowflake.
Explanation
Correct.
It is a web-based UI.
Explanation
No.
It is a Python library.
Explanation
No.
It is only for admins.
Explanation
No.
Overall explanation
SnowSQL is the preferred tool for scripting and local file operations. Ref: https://docs.snowflake.com/en/user-guide/snowsql
Domain
Account and Data Sharing
Question 72
Skipped
A query profile shows 'Local Disk Spilling'. What does this mean?
The warehouse is resizing.
Explanation
No.
The query failed.
Explanation
No.
Data is being written to S3 because RAM is full.
Explanation
No, that's remote spilling.
Correct answer
Data is being written to the warehouse SSD because RAM is full.
Explanation
Correct.
Overall explanation
Local spilling is faster than remote but slower than in-memory execution. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 73
Skipped
Which role is the best for creating and managing custom roles?
Correct answer
USERADMIN.
Explanation
Correct. This role is dedicated to identity and role management.
SYSADMIN.
Explanation
No.
ACCOUNTADMIN.
Explanation
Can do it, but not the specific purpose.
PUBLIC.
Explanation
No.
Overall explanation
USERADMIN helps separate security administration from system/compute administration. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 74
Skipped
What is the purpose of the 'VALIDATE' function in Snowflake?
To check if a user is logged in.
Explanation
No.
Correct answer
To view the errors from a previous COPY INTO command.
Explanation
Correct. Useful for troubleshooting loads.
To check warehouse status.
Explanation
No.
To encrypt a table.
Explanation
No.
Overall explanation
VALIDATE allows engineers to see exactly which rows failed in a past ingestion job. Ref: https://docs.snowflake.com/en/sql-reference/functions/validate
Domain
Data Movement
Question 75
Skipped
Which of the following are the three distinct layers of Snowflake Architecture? (Select 3)
Correct selection
Virtual Warehouses (Compute)
Explanation
Correct. The muscle/processing engine.
Correct selection
Cloud Services
Explanation
Correct. The brain of Snowflake.
Correct selection
Storage Layer
Explanation
Correct. Where data is stored in micro-partitions.
Data Lake Layer
Explanation
Incorrect.
Network Layer
Explanation
Incorrect. Part of Cloud Services/Cloud provider.
Security Layer
Explanation
Incorrect. Integrated across all layers.
Overall explanation
Snowflake's unique architecture separates storage, compute, and services. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 76
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
Question 77
Skipped
Which of the following is TRUE about 'Tasks'?
They are free.
Explanation
No.
They can only run SQL every hour.
Explanation
No, they can use Cron or minutes.
They don't need a warehouse.
Explanation
No (they use either serverless or a warehouse).
Correct answer
They can be chained together into a DAG.
Explanation
Correct.
Overall explanation
Tasks allow for sophisticated workflow automation. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 78
Skipped
What is the function of 'Snowpipe'?
Querying data lakes.
Explanation
No.
Correct answer
Continuous loading from cloud stages.
Explanation
Correct.
Exporting data.
Explanation
No.
Bulk loading from CLI.
Explanation
No.
Overall explanation
Snowpipe provides automated, near real-time ingestion. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
Domain
Data Movement
Question 79
Skipped
A user runs a query that takes 10 minutes. They run it again 5 minutes later with no changes. Why is the second run nearly instantaneous?
Because of the Warehouse Cache.
Explanation
Possible, but Result Cache is faster.
Correct answer
Because of the Result Cache.
Explanation
Correct. The result is returned from the Cloud Services layer without compute.
Because the data was clustered.
Explanation
No.
Because the warehouse was resized.
Explanation
No.
Overall explanation
The Result Cache is used when the query, underlying data, and role are identical. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 80
Skipped
What is 'Result Scanning' (RESULT_SCAN)?
A virus scanner.
Explanation
No.
A way to scan files in a stage.
Explanation
No.
Correct answer
A way to query the output of a previous query.
Explanation
Correct. Uses the Query ID.
A way to check for duplicates.
Explanation
No.
Overall explanation
RESULT_SCAN is useful for processing results from SHOW commands or stored procedures. Ref: https://docs.snowflake.com/en/sql-reference/functions/result_scan
Domain
Performance and Warehouses
Question 81
Skipped
What is the maximum number of days for 'Time Travel' in 'Standard' edition?
7.
Explanation
No.
90.
Explanation
No.
0.
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
Question 82
Skipped
How many years of history is stored in the 'Account Usage' (SNOWFLAKE DB) views?
7 years.
Explanation
No.
Correct answer
1 year (365 days).
Explanation
Correct. Essential for long-term auditing.
90 days.
Explanation
No.
14 days.
Explanation
No, that's Information Schema.
Overall explanation
Account Usage is the primary source for historical analysis of credit and storage usage. Ref: https://docs.snowflake.com/en/sql-reference/account-usage
Domain
Account and Data Sharing
Question 83
Skipped
Which command is used to add a column to an existing table?
MODIFY TABLE.
Explanation
No.
Correct answer
ALTER TABLE <name> ADD COLUMN <col>.
Explanation
Correct.
CHANGE TABLE.
Explanation
No.
UPDATE TABLE.
Explanation
No.
Overall explanation
Standard DDL commands are used to modify Snowflake objects. Ref: https://docs.snowflake.com/en/sql-reference/sql/alter-table
Domain
Snowflake Architecture
Question 84
Skipped
True or False: Snowflake can be deployed on AWS, Azure, and Google Cloud.
Correct answer
TRUE
Explanation
Correct. Snowflake is multi-cloud.
FALSE
Explanation
It is available on all three major providers.
Overall explanation
Snowflake's cross-cloud capability is a major selling point. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 85
Skipped
Which of the following is TRUE about 'Tasks'? (Select 2)
They can only run once.
Explanation
Incorrect.
They require a dedicated warehouse.
Explanation
Incorrect (can be serverless).
Correct selection
They can execute SQL statements.
Explanation
Correct.
Correct selection
They can execute Stored Procedures.
Explanation
Correct.
Overall explanation
Tasks allow for the automation of routine data engineering workflows. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 86
Skipped
What happens to a 'Stream' after it is consumed in a DML statement (like an INSERT INTO)?
The data in the stream is deleted.
Explanation
No.
The table is dropped.
Explanation
No.
The stream is suspended.
Explanation
No.
Correct answer
The stream's offset is advanced, and the changes are considered 'consumed'.
Explanation
Correct. The stream now looks for new changes.
Overall explanation
Streams follow a 'read-and-advance' logic for Change Data Capture (CDC). Ref: https://docs.snowflake.com/en/user-guide/streams-intro
Domain
Account and Data Sharing
Question 87
Skipped
Which of the following are valid 'Snowpark' languages? (Select 3)
Correct selection
Java.
Explanation
Correct.
C++.
Explanation
No.
Ruby.
Explanation
No.
Correct selection
Scala.
Explanation
Correct.
Correct selection
Python.
Explanation
Correct.
JavaScript.
Explanation
No.
Overall explanation
Snowpark allows developers to query data using non-SQL code. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 88
Skipped
Which of the following is NOT a Snowflake 'Object'?
Stage.
Explanation
Is an object.
Correct answer
S3 Bucket.
Explanation
Correct. This is an external cloud object.
Schema.
Explanation
Is an object.
Table.
Explanation
Is an object.
Overall explanation
Snowflake objects are managed within the account; buckets are managed by the cloud provider. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Snowflake Architecture
Question 89
Skipped
Which tool is required to use the 'PUT' command?
Any Browser.
Explanation
No.
Snowpipe.
Explanation
No.
Snowflake Web UI.
Explanation
No.
Correct answer
SnowSQL or supported drivers.
Explanation
Correct. PUT is a client-side command.
Overall explanation
Client-side tools are needed to move data from local systems to Snowflake stages. Ref: https://docs.snowflake.com/en/sql-reference/sql/put
Domain
Data Movement
Question 90
Skipped
How many days of 'Time Travel' are included by default for all tables?
7 days.
Explanation
No.
30 days.
Explanation
No.
Correct answer
1 day.
Explanation
Correct. Can be increased to 90 for Enterprise.
0 days.
Explanation
No.
Overall explanation
All accounts start with 1 day of Time Travel at no extra cost. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 91
Skipped
Which of the following is a 'Virtual Warehouse' state? (Select 3)
WAITING.
Explanation
Incorrect.
DELETED.
Explanation
Incorrect (this is an action, not a state of a live object).
Correct selection
RUNNING.
Explanation
Correct.
Correct selection
SUSPENDED.
Explanation
Correct.
SLEEPING.
Explanation
Incorrect.
Correct selection
STARTING.
Explanation
Correct.
Overall explanation
Warehouses transition through these states as they manage compute resources. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 92
Skipped
Which of the following is TRUE about 'Snowpark'?
It is used for billing.
Explanation
No.
It only supports SQL.
Explanation
No.
Correct answer
It allows users to write Python/Java/Scala code that executes inside Snowflake.
Explanation
Correct.
It requires a separate server.
Explanation
No.
Overall explanation
Snowpark brings the processing logic to the data. Ref: https://docs.snowflake.com/en/developer-guide/snowpark/index
Domain
Performance and Warehouses
Question 93
Skipped
Which of the following is NOT a characteristic of a 'Micro-partition'?
It is immutable.
Explanation
Characteristic.
It is between 50MB and 500MB in size (uncompressed).
Explanation
Characteristic.
It is managed automatically by Snowflake.
Explanation
Characteristic.
Correct answer
It stores data in a row-based format.
Explanation
Correct. This is FALSE; it stores data in a columnar format.
Overall explanation
Snowflake's columnar storage within micro-partitions is what enables efficient analytical querying. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 94
Skipped
Which scaling policy is the 'Standard' policy for warehouses?
Economy.
Explanation
No.
High Performance.
Explanation
No.
Balanced.
Explanation
No.
Correct answer
Standard.
Explanation
Correct. Default policy.
Overall explanation
The Standard policy starts clusters immediately to prevent queuing. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 95
Skipped
True or False: A 'Masking Policy' can be applied to a column within a 'Secure View'.
FALSE
Explanation
They are compatible.
Correct answer
TRUE
Explanation
Correct. They can be layered for maximum security.
Overall explanation
Snowflake's security features like masking and secure views are designed to work together. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 96
Skipped
Which command is used to see all the users in a Snowflake account?
LIST USERS.
Explanation
No.
Correct answer
SHOW USERS.
Explanation
Correct.
DESCRIBE USERS.
Explanation
No.
SELECT * FROM USERS.
Explanation
No.
Overall explanation
SHOW USERS provides metadata about every user identity. Ref: https://docs.snowflake.com/en/sql-reference/sql/show-users
Domain
Security
Question 97
Skipped
What is the primary difference between 'Transient' and 'Permanent' tables?
Correct answer
Transient tables have no Fail-safe period.
Explanation
Correct. This reduces storage costs but increases risk.
Permanent tables are faster.
Explanation
No.
Transient tables are stored in RAM.
Explanation
No.
Transient tables have no Time Travel.
Explanation
No, they can have up to 1 day.
Overall explanation
Transient tables are designed for data that is easily reproducible but needs to persist beyond a session. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 98
Skipped
What is 'Vertical Scaling' (Scale-up) in Snowflake?
Adding more clusters to a warehouse.
Explanation
No, that is Horizontal scaling.
Correct answer
Increasing the size of a Virtual Warehouse (e.g., from Small to Large).
Explanation
Correct.
Adding more storage.
Explanation
No.
Adding more users.
Explanation
No.
Overall explanation
Scaling up provides more memory and CPU per node to handle more complex queries. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 99
Skipped
Which command is used to recover a schema that was dropped 10 minutes ago?
GET SCHEMA.
Explanation
No.
RESTORE SCHEMA.
Explanation
No.
Correct answer
UNDROP SCHEMA.
Explanation
Correct. Works if within the Time Travel period.
RECOVER SCHEMA.
Explanation
No.
Overall explanation
UNDROP is available for Databases, Schemas, and Tables. Ref: https://docs.snowflake.com/en/sql-reference/sql/undrop-schema
Domain
Storage and Protection
Question 100
Skipped
What is 'Micro-partition' metadata used for?
To store the actual data.
Explanation
No.
Storing passwords.
Explanation
No.
Correct answer
Pruning and Query Optimization.
Explanation
Correct. Contains Min/Max values of columns.
To manage billing.
Explanation
No.
Overall explanation
Metadata is what makes Snowflake's query engine so efficient at skipping data. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 101
Skipped
Which of the following describes a 'Standard' Scaling Policy in a Multi-cluster Warehouse?
It is only available in Standard edition.
Explanation
No.
It starts clusters only when there is high queuing.
Explanation
No, that's Economy.
It resizes the warehouse to a larger T-shirt size.
Explanation
No, that's vertical scaling.
Correct answer
It starts additional clusters immediately when a query is queued.
Explanation
Correct. Prioritizes performance.
Overall explanation
Standard policy is aggressive to ensure users don't wait for resources. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 102
Skipped
Which function is used to extract a specific key from a VARIANT column?
Correct answer
The colon operator (:).
Explanation
Correct. e.g. col:key.
The hash operator (#).
Explanation
No.
The plus operator (+).
Explanation
No.
The slash operator (/).
Explanation
No.
Overall explanation
Snowflake uses colon and dot notation for easy JSON navigation. Ref: https://docs.snowflake.com/en/user-guide/querying-semistructured
Domain
Storage and Protection
Question 103
Skipped
Which command is used to see the metadata (columns, types, etc.) of a table?
SELECT * FROM table.
Explanation
Shows data, not just metadata.
LIST TABLE.
Explanation
No.
SHOW TABLES.
Explanation
Shows names and owners, not columns.
Correct answer
DESCRIBE TABLE.
Explanation
Correct. Lists columns, data types, and nullability.
Overall explanation
DESCRIBE (or DESC) is the standard way to inspect the structure of an object. Ref: https://docs.snowflake.com/en/sql-reference/sql/desc-table
Domain
Snowflake Architecture
Question 104
Skipped
Which command is used to load data from a stage into a table?
PUT.
Explanation
No.
LOAD.
Explanation
No.
INSERT INTO.
Explanation
Can be used but COPY is the bulk load command.
Correct answer
COPY INTO.
Explanation
Correct.
Overall explanation
COPY INTO is the primary command for efficient bulk data ingestion. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 105
Skipped
What is the maximum number of days for 'Fail-safe'?
30 days.
Explanation
No.
Correct answer
7 days.
Explanation
Correct. Fixed.
90 days.
Explanation
No.
1 day.
Explanation
No.
Overall explanation
Every permanent table has 7 days of Fail-safe after its Time Travel period ends. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 106
Skipped
Which privilege is needed to 'Use' a warehouse?
OPERATE.
Explanation
Allows starting/stopping, not always needed for basic use.
MONITOR.
Explanation
No.
SELECT.
Explanation
No.
Correct answer
USAGE.
Explanation
Correct. Necessary to execute queries on that warehouse.
Overall explanation
The USAGE privilege is the most common permission granted to users for compute. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Security
Question 107
Skipped
What is a 'Materialized View' useful for?
Correct answer
Queries that frequently aggregate data from large tables.
Explanation
Correct.
Real-time data.
Explanation
No.
Data sharing only.
Explanation
No.
Storing small tables.
Explanation
No.
Overall explanation
Materialized views store the pre-computed results of a query for faster access. Ref: https://docs.snowflake.com/en/user-guide/views-materialized
Domain
Performance and Warehouses
Question 108
Skipped
What is the size of a 'Micro-partition' in Snowflake?
Correct answer
50 MB to 500 MB (uncompressed).
Explanation
Correct. This is the target size.
1 KB.
Explanation
No.
10 GB.
Explanation
No.
1 TB.
Explanation
No.
Overall explanation
Small, granular partitions are key to Snowflake's high-speed pruning. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 109
Skipped
Which of the following are TRUE about 'Snowflake-managed' encryption? (Select 2)
Users must provide their own keys in Standard edition.
Explanation
Incorrect. Snowflake manages them by default.
Correct selection
Snowflake automatically rotates keys.
Explanation
Correct. A key security feature.
Correct selection
Snowflake uses a hierarchical key model.
Explanation
Correct. Keys are wrapped in a hierarchy.
Encryption can be turned off to save costs.
Explanation
Incorrect. Encryption is always-on.
Overall explanation
Encryption is transparent and mandatory in Snowflake, ensuring data is always secure at rest. Ref: https://docs.snowflake.com/en/user-guide/security-encryption
Domain
Security
Question 110
Skipped
True or False: Snowflake allows the creation of 'Secondary' indexes on tables.
TRUE
Explanation
Incorrect. Snowflake does not use traditional indexes.
Correct answer
FALSE
Explanation
Correct. Snowflake uses micro-partitions and pruning instead.
Overall explanation
Snowflake's performance is based on metadata and micro-partitioning, eliminating the need for manual index management. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Performance and Warehouses
Question 111
Skipped
Which of the following are 'Fail-safe' benefits?
It speeds up queries.
Explanation
No.
It is free.
Explanation
No.
It provides a 7-day period for self-service recovery.
Explanation
No, only Snowflake Support can access Fail-safe.
Correct answer
It provides a 7-day period for Snowflake Support to recover data.
Explanation
Correct.
Overall explanation
Fail-safe is the ultimate safety net for catastrophic data loss. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 112
Skipped
Which role is required to manage 'Account-level' Network Policies?
Correct answer
SECURITYADMIN or ACCOUNTADMIN.
Explanation
Correct. Only security-focused roles can manage these.
USERADMIN.
Explanation
No.
PUBLIC.
Explanation
No.
SYSADMIN.
Explanation
No.
Overall explanation
Network policies are a critical security boundary managed by high-level admins. Ref: https://docs.snowflake.com/en/user-guide/network-policies
Domain
Security
Question 113
Skipped
Which of the following are 'Time Travel' actions? (Select 2)
Deleting Fail-safe data.
Explanation
No.
Correct selection
Cloning data at a point in time.
Explanation
Correct.
Updating historical data.
Explanation
No, Time Travel is read-only.
Correct selection
Querying data at a point in time.
Explanation
Correct.
Overall explanation
Time Travel allows you to 'go back in time' for querying or object restoration. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 114
Skipped
What is the 'Query ID'?
The user ID.
Explanation
No.
A password.
Explanation
No.
The table ID.
Explanation
No.
Correct answer
A unique identifier for every executed query.
Explanation
Correct.
Overall explanation
Query IDs are necessary for functions like RESULT_SCAN or for troubleshooting. Ref: https://docs.snowflake.com/en/sql-reference/functions/last_query_id
Domain
Performance and Warehouses
Question 115
Skipped
Which function converts a VARIANT value into a string?
CAST_TO_STRING().
Explanation
No.
GET().
Explanation
No.
Correct answer
TO_VARCHAR().
Explanation
Correct.
PARSE_JSON().
Explanation
No.
Overall explanation
Casting is necessary to use VARIANT data in standard string functions. Ref: https://docs.snowflake.com/en/sql-reference/functions/to_char
Domain
Storage and Protection
Question 116
Skipped
What is 'Automatic Suspend' in a warehouse?
Correct answer
It turns off the warehouse after a period of inactivity to save credits.
Explanation
Correct.
It deletes the warehouse.
Explanation
No.
It resizes the warehouse.
Explanation
No.
It stops a query.
Explanation
No.
Overall explanation
Auto-suspend is a key cost-control feature in Snowflake. Ref: https://docs.snowflake.com/en/user-guide/warehouses-overview
Domain
Performance and Warehouses
Question 117
Skipped
Which of the following is TRUE about 'Resource Monitors' at the Account level?
They are free to use.
Explanation
No.
They are only for storage.
Explanation
No.
They can only monitor one warehouse.
Explanation
No.
Correct answer
They can monitor the credit usage of the entire account.
Explanation
Correct.
Overall explanation
Account-level monitors help set global 'kill switches' for credit usage. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Account and Data Sharing
Question 118
Skipped
Which of the following describes 'Snowpipe' correctly?
Correct answer
A continuous, near real-time ingestion service.
Explanation
Correct.
A bulk loading tool.
Explanation
No.
A way to share data.
Explanation
No.
A monitoring tool.
Explanation
No.
Overall explanation
Snowpipe is serverless and automates file ingestion as they arrive in a stage. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
Domain
Data Movement
Question 119
Skipped
What is the default compression format for Snowflake data?
Correct answer
Proprietary Columnar Compression.
Explanation
Correct. Snowflake optimizes storage automatically.
ZIP.
Explanation
No.
GZIP.
Explanation
No.
BZIP2.
Explanation
No.
Overall explanation
Users do not need to manage compression; Snowflake handles it for all data. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 120
Skipped
What is the benefit of 'Secure Views'?
Correct answer
Hides the underlying SQL and data from unauthorized users.
Explanation
Correct.
Faster performance.
Explanation
No.
Encrypts the table.
Explanation
No.
Allows writing data.
Explanation
No.
Overall explanation
Secure views are critical for multi-tenant environments and data sharing. Ref: https://docs.snowflake.com/en/user-guide/views-secure
Domain
Account and Data Sharing
Question 121
Skipped
Which scaling policy prioritize performance over cost?
Balanced.
Explanation
No.
Correct answer
Standard.
Explanation
Correct. Starts new clusters immediately.
Static.
Explanation
No.
Economy.
Explanation
No.
Overall explanation
Standard scaling policy is the default and aims to minimize queuing. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 122
Skipped
Which role can view the 'Query History' of other users?
PUBLIC.
Explanation
No.
Only the user who ran the query.
Explanation
No.
ANY user.
Explanation
No.
Correct answer
ACCOUNTADMIN or anyone with the MONITOR privilege.
Explanation
Correct.
Overall explanation
Monitoring privileges are required to see cross-user activity. Ref: https://docs.snowflake.com/en/user-guide/ui-query-history
Domain
Account and Data Sharing
Question 123
Skipped
Which command would you use to see all the 'Stages' in your current schema?
GET STAGES.
Explanation
No.
LIST STAGES.
Explanation
No.
DESCRIBE STAGES.
Explanation
No.
Correct answer
SHOW STAGES.
Explanation
Correct.
Overall explanation
SHOW commands are used for object discovery. Ref: https://docs.snowflake.com/en/sql-reference/sql/show-stages
Domain
Data Movement
Question 124
Skipped
Which of the following is TRUE about 'Dynamic Data Masking'? (Select 2)
Correct selection
It masks data at query time.
Explanation
Correct.
It alters the data on disk.
Explanation
Incorrect. Physical data remains unchanged.
Correct selection
The same column can show different values to different roles.
Explanation
Correct. A powerful governance feature.
It is available in all editions.
Explanation
Incorrect. Requires Enterprise or higher.
Overall explanation
Masking allows for 'Role-Based' data visibility without duplicating data. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 125
Skipped
Which scaling policy in a Multi-cluster Warehouse will 'Shut down clusters as soon as possible' to save credits?
Standard
Explanation
Incorrect.
Correct answer
Economy
Explanation
Correct. Prioritizes credit saving by consolidating load.
Balanced
Explanation
Not a policy.
Aggressive
Explanation
Not a policy.
Overall explanation
Economy mode is designed to keep clusters as full as possible and spin them down quickly. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 126
Skipped
Which of the following are TRUE about 'External Stages'? (Select 2)
They are managed entirely by Snowflake storage.
Explanation
Incorrect. They point to external locations.
Correct selection
They require a Storage Integration for secure access.
Explanation
Correct. The recommended security method.
Correct selection
They point to cloud storage like AWS S3 or Azure Blob.
Explanation
Correct.
They are free to use.
Explanation
No, cloud provider costs apply.
Overall explanation
External stages bridge the gap between Snowflake and your existing Data Lake. Ref: https://docs.snowflake.com/en/user-guide/data-load-s3-create-stage
Domain
Data Movement
Question 127
Skipped
Which role is the highest level in a Snowflake account?
SYSADMIN.
Explanation
No.
SECURITYADMIN.
Explanation
No.
ORGADMIN.
Explanation
No (this is for multi-account management).
Correct answer
ACCOUNTADMIN.
Explanation
Correct. Has full control over the account.
Overall explanation
ACCOUNTADMIN should be used sparingly for administrative tasks only. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 128
Skipped
What is the main purpose of the 'Information Schema'?
To manage users.
Explanation
No.
Correct answer
To provide real-time metadata about objects in a database.
Explanation
Correct.
To store raw data.
Explanation
No.
To track billing only.
Explanation
No.
Overall explanation
Information Schema allows users to query metadata like table names or view definitions. Ref: https://docs.snowflake.com/en/sql-reference/info-schema
Domain
Account and Data Sharing
Question 129
Skipped
Which command is used to download a file from a stage to your computer?
Correct answer
GET.
Explanation
Correct.
DOWNLOAD.
Explanation
No.
COPY OUT.
Explanation
No.
PUT.
Explanation
Uploads.
Overall explanation
GET is the reverse of PUT and is used for data export. Ref: https://docs.snowflake.com/en/sql-reference/sql/get
Domain
Data Movement