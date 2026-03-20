Question 1
Skipped
Which of the following describes the storage of data in Snowflake tables?
Flat CSV files
Explanation
Only used for staging.
Unstructured binary files
Explanation
Internal data is structured.
Correct answer
Columnar-based micro-partitions
Explanation
Snowflake stores data in proprietary columnar format.
Row-based storage
Explanation
Not used in Snowflake.
Overall explanation
Snowflake organizes data into micro-partitions. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Storage and Protection
Question 2
Skipped
An administrator wants to prevent a specific warehouse from exceeding a monthly budget. They set up a Resource Monitor with a hard limit of 1000 credits. What happens when the 'Hard Suspend' threshold is reached?
The warehouse suspends after all current queries finish.
Explanation
This is 'Suspend'.
The warehouse continues but no new queries are accepted.
Explanation
This is 'Suspend'.
Correct answer
The warehouse suspends immediately and all currently running queries are canceled.
Explanation
Correct behavior for Hard Suspend.
The warehouse size is automatically reduced.
Explanation
Snowflake does not auto-resize size down this way.
Overall explanation
Hard Suspend cancels all running queries and stops the warehouse immediately to stop credit burn. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Performance and Warehouses
Question 3
Skipped
A user wants to check the historical credit usage for the 'Search Optimization Service' and 'Automatic Clustering'. Which view provides this specific information?
AUTOMATIC_CLUSTERING_HISTORY
Explanation
Only shows clustering.
SERVERLESS_TASK_HISTORY
Explanation
Only shows Tasks.
Correct answer
METERING_DAILY_HISTORY
Explanation
Shows credits for all serverless features including Search Optimization and Clustering.
WAREHOUSE_METERING_HISTORY
Explanation
Only shows Virtual Warehouse credits.
Overall explanation
METERING_DAILY_HISTORY in Account Usage tracks credit consumption for all background serverless services. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/metering_daily_history
Domain
Account and Data Sharing
Question 4
Skipped
An Administrator wants to ensure that specific users can only access Snowflake from the corporate office IP range. Which object should be implemented?
Security Integration
Explanation
Used for SSO/OAUTH.
Virtual Private Snowflake
Explanation
This is an edition.
Correct answer
Network Policy
Explanation
Correct for IP whitelisting.
Resource Monitor
Explanation
Used for credit limits.
Overall explanation
Network policies allow you to restrict access based on IP address ranges. Ref: https://docs.snowflake.com/en/user-guide/network-policies
Domain
Security
Question 5
Skipped
An administrator needs to identify which queries are consuming the most credits from the last 45 minutes. Which view should they use for the most up-to-date information?
SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
Explanation
Latency of up to 45 mins - 3 hours.
SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
Explanation
Does not show individual queries.
INFORMATION_SCHEMA.WAREHOUSE_LOAD_HISTORY
Explanation
Shows load not specific query credits.
Correct answer
INFORMATION_SCHEMA.QUERY_HISTORY
Explanation
Correct. Information Schema provides real-time data for recent queries.
Overall explanation
Information Schema is the go-to for real-time monitoring of the last 7 days. Ref: https://docs.snowflake.com/en/sql-reference/info-schema/query_history
Domain
Performance and Warehouses
Question 6
Skipped
An organization wants to share a secure view with a consumer. They want to ensure the consumer cannot see the underlying SQL definition of the view. What must they use?
A Materialized View
A Standard View
A UDF
Correct answer
A Secure View
Overall explanation
Secure Views hide the DDL and optimization internals from the users who have access to them. Ref: https://docs.snowflake.com/en/user-guide/views-secure"
Domain
Account and Data Sharing
Question 7
Skipped
Which of the following conditions would prevent Snowflake from effectively using Query Pruning to optimize performance?
Correct answer
Applying a function to a filtered column in the WHERE clause (e.g. WHERE UPPER(column) = VALUE).
Explanation
Functions on columns often prevent the optimizer from using metadata for pruning.
Having more than 1000 micro-partitions.
Explanation
Pruning is designed for millions of partitions.
Using a very large Virtual Warehouse.
Explanation
Warehouse size does not affect pruning logic.
Using a WHERE clause on a clustered column.
Explanation
This helps pruning.
Overall explanation
Pruning relies on min/max metadata; applying functions to columns often breaks this optimization. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions
Domain
Performance and Warehouses
Question 8
Skipped
Which of the following are FALSE regarding Snowflake Micro-partitions? (Select all that apply)
Correct selection
They are stored in a row-based format.
Explanation
False. They are columnar.
Correct selection
Users must manually define them.
Explanation
False. Snowflake manages them automatically.
They are immutable.
Explanation
True. They cannot be changed once written.
They are approximately 50 MB to 500 MB of data.
Explanation
True size range.
Overall explanation
Snowflake automatically manages immutable columnar micro-partitions. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Storage and Protection
Question 9
Skipped
Which of the following describes the behavior of a 'Standard' Scaling Policy in a Multi-cluster Warehouse?
Correct answer
It starts new clusters immediately as soon as a query is queued.
Explanation
Correct. Prioritizes performance.
It prevents any queuing of queries.
Explanation
Queuing can still happen during startup.
It only scales up the size of the nodes.
Explanation
Multi-cluster scales out nodes.
It waits 6 minutes before starting a new cluster.
Explanation
This is Economy policy.
Overall explanation
The Standard policy is designed to minimize queuing by starting clusters as fast as possible. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 10
Skipped
Which command should be used to change the size of an existing Virtual Warehouse?
SET WAREHOUSE_SIZE
MODIFY WAREHOUSE
UPDATE WAREHOUSE
Correct answer
ALTER WAREHOUSE
Explanation
Correct.
Overall explanation
ALTER WAREHOUSE is used to change properties like size, auto-suspend and max_cluster_count. Ref: https://docs.snowflake.com/en/sql-reference/sql/alter-warehouse
Domain
Performance and Warehouses
Question 11
Skipped
Which of the following are required to create an External Table in Snowflake?
Correct selection
A Cloud Storage Integration
A Snowpipe
A Primary Key defined on the source files
A Virtual Warehouse
Correct selection
An External Stage
Overall explanation
External tables require a stage and proper cloud permissions (Integration). Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro
Domain
Data Movement
Question 12
Skipped
Which role is best suited for managing 'Network Policies' and 'Grants' but does not necessarily need access to data?
Correct answer
SECURITYADMIN
Explanation
Correct. Focused on security management.
ACCOUNTADMIN
USERADMIN
SYSADMIN
Overall explanation
SECURITYADMIN focuses on RBAC and security object management. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 13
Skipped
Which role should be used to monitor account-level credit usage and billing?
USERADMIN
Correct answer
ACCOUNTADMIN
SECURITYADMIN
SYSADMIN
Overall explanation
ACCOUNTADMIN is the primary role for financial and account-level oversight. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview"
Domain
Security
Question 14
Skipped
In a Snowflake account with Account Usage and Information Schema, which of the following is a key difference between them?
Account Usage only exists in the Standard Edition.
Explanation
Exists in all editions.
Information Schema retains data for 1 year.
Explanation
Retention is much shorter.
Information Schema contains deleted objects.
Explanation
Only Account Usage has dropped objects.
Correct answer
Account Usage latency can be up to 3 hours while Information Schema is real-time.
Explanation
Correct regarding data latency.
Overall explanation
Account Usage is for long-term auditing; Information Schema is for immediate metadata needs. Ref: https://docs.snowflake.com/en/sql-reference/account-usage
Domain
Account and Data Sharing
Question 15
Skipped
When using the 'Search Optimization Service' which type of queries benefit the most?
Large table scans with no filters.
Explanation
Benefits from pruning.
Analytical aggregations (SUM/AVG).
Explanation
Not the primary use case.
Joins between two small tables.
Explanation
Not needed.
Correct answer
Point lookups on high-cardinality columns (e.g. searching for a specific ID).
Explanation
Correct. Designed for equality searches.
Overall explanation
Search Optimization speeds up point lookups in large tables with millions of rows. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 16
Skipped
Which Snowflake feature allows for the automatic execution of SQL statements on a scheduled basis?
Snowpipe
Correct answer
Tasks
Stored Procedures
Resource Monitors
Overall explanation
Tasks are used to schedule SQL or Stored Procedures based on a cron or interval. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro"
Domain
Account and Data Sharing
Question 17
Skipped
Which command is used to unload data from a Snowflake table into a Stage?
PUT
Explanation
Used for uploading to stage.
Correct answer
COPY INTO
Explanation
Correct for both load/unload.
GET
Explanation
Used for downloading to local.
INSERT INTO
Explanation
For loading.
Overall explanation
The COPY INTO command is used to export data. Ref: https://docs.snowflake.com/en/user-guide/data-export-intro
Domain
Data Movement
Question 18
Skipped
In Snowflake, who is the owner of an object by default?
The person who paid for the account.
Explanation
No.
The SYSADMIN role.
Explanation
No.
Correct answer
The role that was used to create the object.
Explanation
Correct. RBAC principle.
The ACCOUNTADMIN role.
Explanation
No.
Overall explanation
Snowflake uses Role-Based Access Control where the creating role owns the object. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview"
Domain
Security
Question 19
Skipped
An organization wants to share data with a Consumer but needs to restrict specific rows based on the Consumer's region. Which feature should they use?
Dynamic Data Masking
Explanation
Masks columns not rows.
Correct answer
Row Access Policies
Explanation
Correct. Allows filtering rows based on attributes or roles.
Resource Monitors
Explanation
Controls credits.
Secure Views
Overall explanation
Row Access Policies are designed to implement fine-grained data security at the row level. Ref: https://docs.snowflake.com/en/user-guide/security-row
Domain
Security
Question 20
Skipped
Which command is used to see the description and data types of all columns in a specific table?
SELECT * FROM TABLE
Explanation
Shows data not structure.
LIST TABLE
Explanation
Used for files in stages.
SHOW TABLES
Explanation
Shows table metadata.
Correct answer
DESCRIBE TABLE
Explanation
Correct. Provides column-level details.
Overall explanation
DESCRIBE (or DESC) returns the definition of an object's columns and types. Ref: https://docs.snowflake.com/en/sql-reference/sql/desc-table
Domain
Account and Data Sharing
Question 21
Skipped
What is the main advantage of using 'External Tables'?
They are faster than internal tables.
Explanation
They are slower.
They provide 90 days of Time Travel.
Explanation
External tables have no Time Travel.
Correct answer
They allow you to query data without first importing it into Snowflake.
Explanation
Correct.
They do not require a Virtual Warehouse.
Explanation
They do require one for queries.
Overall explanation
External tables provide a way to access a data lake without ingestion. Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro"
Domain
Data Movement
Question 22
Skipped
Which of the following are types of caching available in Snowflake?
Correct selection
Metadata Cache
Explanation
Stores statistics about micro-partitions.
Correct selection
Result Cache
Explanation
Stores results of previous queries.
External Stage Cache
Explanation
Snowflake does not cache external stages.
Correct selection
Virtual Warehouse Cache
Explanation
Stores data locally on SSD.
Overall explanation
Snowflake utilizes Result Cache and Local Disk Cache. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 23
Skipped
Which metadata is stored for each column in a micro-partition to enable 'Pruning'?
The sum of all values.
Explanation
Not tracked for pruning.
Correct answer
The minimum and maximum values in that partition.
Explanation
Correct. Used by the optimizer to skip partitions.
The average value.
Explanation
Not tracked for pruning.
The number of null values.
Explanation
Tracked but doesn't drive pruning.
Overall explanation
The optimizer checks the min/max values of each partition against the query filters to skip irrelevant data. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Snowflake Architecture
Question 24
Skipped
Which of the following is NOT a type of 'Stage' in Snowflake?
User Stage
Correct answer
Warehouse Stage
Explanation
Correct. This does not exist.
Named Internal Stage
Table Stage
Overall explanation
Stages are categorized as User, Table or Named (Internal/External). Warehouses do not have stages. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage
Domain
Data Movement
Question 25
Skipped
True or False: Snowflake charges a separate fee for the Cloud Services layer if it exceeds 10% of the daily warehouse credit consumption.
FALSE
Explanation
There is a cost if it exceeds the 10% allowance.
Correct answer
TRUE
Explanation
Correct.
Overall explanation
Users only pay for Cloud Services if the credits used exceed 10% of their total daily warehouse usage. Ref: https://docs.snowflake.com/en/user-guide/cost-understanding-overall
Domain
Account and Data Sharing
Question 26
Skipped
A company has a multi-cluster warehouse set to Auto-scale mode with a minimum of 1 cluster and a maximum of 5. The scaling policy is set to Economy. What is the primary behavior of this configuration?
It scales up the size of the warehouse.
Explanation
Warehouses scale out (clusters) not up (size) automatically.
Correct answer
It prioritizes cost savings by only starting a new cluster if the system estimates there is enough load to keep it busy for 6 minutes.
Explanation
Correct behavior for Economy policy.
It starts a new cluster immediately when a query is queued.
Explanation
This describes the Standard policy.
It maintains all 5 clusters active during business hours.
Explanation
Minimum is set to 1.
Overall explanation
The Economy policy focuses on throughput and credit savings rather than immediate sub-second starts. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 27
Skipped
When data is 'Unloaded' from Snowflake to a Stage using COPY INTO, what is the default compression used?
snappy
None (uncompressed)
zip
Correct answer
gzip
Explanation
Correct.
Overall explanation
Snowflake defaults to gzip compression when unloading data to files in a stage. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-location
Domain
Data Movement
Question 28
Skipped
Which of the following statements are TRUE regarding Snowflake's Query Result Cache? (Select all that apply)
Correct selection
It is shared across all users in the account.
Explanation
Correct.
Correct selection
The cache is purged if the underlying data changes.
Explanation
Correct.
Correct selection
It is stored for 24 hours.
Explanation
Correct.
It requires an active Virtual Warehouse to be accessed.
Explanation
False. Results are in Cloud Services.
Overall explanation
The result cache is managed by the Cloud Services layer and lasts 24 hours unless data changes. Ref: https://docs.snowflake.com/en/user-guide/performance-query-caching
Domain
Performance and Warehouses
Question 29
Skipped
Which of the following is a FALSE statement regarding 'Fail-safe' in Snowflake?
It cannot be disabled or configured by the user.
Explanation
True statement.
It begins immediately after the Time Travel retention period ends.
Explanation
True statement.
Correct answer
It is available for both Permanent and Transient tables.
Explanation
False. Transient and Temporary tables have no Fail-safe.
It provides a 7-day period for data recovery by Snowflake Support.
Explanation
True statement.
Overall explanation
Transient and Temporary tables are specifically designed to save costs by excluding Fail-safe. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 30
Skipped
Which view in the ACCOUNT_USAGE schema would you query to find the credits consumed by the 'Cloud Services' layer specifically?
STORAGE_USAGE
WAREHOUSE_METERING_HISTORY
Correct answer
METERING_DAILY_HISTORY
Explanation
Correct. Tracks warehouse and serverless/cloud services credits.
QUERY_HISTORY
Overall explanation
METERING_DAILY_HISTORY provides a breakdown of all credit-consuming services in the account. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/metering_daily_history
Domain
Account and Data Sharing
Question 31
Skipped
An analyst needs to query a JSON file in an S3 bucket without loading it into a Snowflake table. What is the most efficient way?
Use the PUT command.
Explanation
Used for uploading files.
Convert JSON to CSV manually.
Explanation
Not efficient.
Correct answer
Create an External Table over the S3 stage.
Explanation
Allows querying data directly in place.
Load it into a VARIANT column first.
Explanation
Requires loading.
Overall explanation
External tables allow querying files in cloud storage using SQL without ingestion. Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro
Domain
Data Movement
Question 32
Skipped
A company is loading files from a stage where filenames include a 'load_date'. How can they include this date into a table column during the COPY INTO process?
By renaming the files to match the columns.
Explanation
Inefficient.
Correct answer
By using a SELECT statement with METADATA$FILENAME within the COPY command.
Explanation
Correct. Transformations are allowed during load.
It is impossible to get metadata during load.
Explanation
Metadata is accessible.
By using the VALIDATE function.
Explanation
Used for error checking.
Overall explanation
Snowflake allows querying metadata like filename and row number during the ingestion process. Ref: https://docs.snowflake.com/en/user-guide/querying-metadata"
Domain
Data Movement
Question 33
Skipped
A Consumer account is accessing a Share from a Provider. The Provider updates the underlying table data. When can the Consumer see the updated data?
Correct answer
Immediately.
Explanation
Correct. Shared data is live and real-time.
After the Provider refreshes the Share metadata.
Explanation
Updates are automatic.
Next business day.
Explanation
Updates are not batched.
After the Consumer's cache expires.
Explanation
Cache doesn't prevent seeing live updates.
Overall explanation
Data Sharing in Snowflake is live; there is no data movement or copying required to see updates. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 34
Skipped
Which features are ONLY available in the Enterprise Edition or higher? (Select all that apply)
Standard Time Travel (1 day)
Explanation
Available in all.
Correct selection
Multi-cluster Warehouses
Correct selection
Materialized Views
Data Sharing
Explanation
Available in all editions.
Correct selection
Up to 90 days of Time Travel
Correct selection
Search Optimization Service
Overall explanation
Standard edition is limited to 1-day time travel and lacks advanced performance features. Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Account and Data Sharing
Question 35
Skipped
Which statement is TRUE regarding Materialized Views in Snowflake?
They never incur storage costs.
Explanation
They incur both storage and compute costs.
Correct answer
They require a background service that consumes credits for maintenance.
Explanation
Correct. Snowflake automatically maintains them when base tables change.
They are available in the Standard edition.
Explanation
Enterprise and higher only.
They can be created on top of other Materialized Views.
Explanation
Not supported.
Overall explanation
Materialized Views are serverless objects that incur maintenance costs to stay synchronized. Ref: https://docs.snowflake.com/en/user-guide/views-materialized
Domain
Performance and Warehouses
Question 36
Skipped
A customer is using Snowpipe to load data. They notice files are not being loaded and use SYSTEM$PIPE_STATUS. The status is 'STALLED_COMPILATION'. What does this likely indicate?
The trial account has expired.
Explanation
Different error message.
The S3 bucket is empty.
Explanation
Status would be running/idle.
Correct answer
The SQL in the pipe definition is invalid or there is a schema mismatch.
Explanation
Indicates a failure in compiling the load instructions.
The warehouse is too small.
Explanation
Snowpipe is serverless.
Overall explanation
STALLED_COMPILATION usually points to an error in the COPY statement within the pipe. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_pipe_status
Domain
Data Movement
Question 37
Skipped
A Business Critical account user notices that data recovery is needed for a table dropped 10 days ago. The retention period was set to 1 day. What is the status of this data?
It is in the Cloud Services cache.
Explanation
Cache doesn't store dropped tables.
It is in Fail-safe and can only be recovered by Snowflake Support.
Explanation
Correct. Fail-safe lasts 7 days after Time Travel ends (1+7=8). Wait - 10 days is beyond both.
It is in Time Travel.
Explanation
Time Travel ended after 1 day.
Correct answer
The data is permanently lost.
Explanation
Correct. 1 day (TT) + 7 days (FS) = 8 days total protection. Day 10 is too late.
Overall explanation
Data is only recoverable for the sum of Time Travel plus Fail-safe days (max 97 days). Ref: https://docs.snowflake.com/en/user-guide/data-failsafe
Domain
Storage and Protection
Question 38
Skipped
Which role is recommended for creating and managing users and roles in a Snowflake account?
Correct answer
USERADMIN
Explanation
Correct for user/role management.
SYSADMIN
Explanation
Focused on objects.
PUBLIC
Explanation
Lowest privilege.
ORGADMIN
Explanation
Focused on organization level.
Overall explanation
USERADMIN is dedicated to creating and managing users and roles. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview
Domain
Security
Question 39
Skipped
Which function is used to flatten a VARIANT column that contains a list of objects?
EXTRACT()
Correct answer
FLATTEN()
Explanation
Correct.
EXPLODE()
SPLIT_PART()
Overall explanation
FLATTEN is the specific table function used for lateral joins to explode arrays. Ref: https://docs.snowflake.com/en/sql-reference/functions/flatten
Domain
Storage and Protection
Question 40
Skipped
Which of the following are benefits of using the Search Optimization Service? (Select all that apply)
Correct selection
Speeds up small point-lookup queries on large tables.
Explanation
Correct.
Automatically fixes disk spilling.
Explanation
False.
Improves the performance of large table scans.
Explanation
False. It is for point lookups.
Correct selection
Reduces the need for manual clustering.
Explanation
Correct.
Overall explanation
Search Optimization is an auxiliary data structure that improves point lookup performance. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 41
Skipped
When loading data using 'Snowpipe', how is the cost calculated?
Based on the size of the Virtual Warehouse.
Explanation
Snowpipe is serverless.
Based on the number of users in the account.
Explanation
Incorrect.
Based on a flat monthly fee.
Explanation
Usage-based.
Correct answer
Based on the number of files loaded and a per-second compute charge.
Explanation
Correct.
Overall explanation
Snowpipe charging is based on file processing and a small overhead for management. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-billing"
Domain
Data Movement
Question 42
Skipped
What is the maximum Time Travel retention period for a Permanent table in Snowflake Enterprise Edition?
Correct answer
90 days
Explanation
Maximum for Enterprise.
180 days
Explanation
Exceeds maximum.
7 days
Explanation
Incorrect duration.
1 day
Explanation
Default for Standard.
Overall explanation
Enterprise Edition allows up to 90 days of Time Travel. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 43
Skipped
A 'Standard' Multi-cluster Warehouse is set to Min Clusters: 2, Max Clusters: 2. What is this mode called?
Economy
Auto-scale
Correct answer
Maximized
Explanation
Correct. Both numbers are the same.
Standard
Overall explanation
Maximized mode starts all configured clusters immediately when the warehouse is started. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster
Domain
Performance and Warehouses
Question 44
Skipped
In Snowflake, 'Clustering Depth' of 1.0 means what?
The table is row-based.
Explanation
No.
Correct answer
The table is perfectly clustered.
Explanation
Correct. Indicates no overlapping micro-partitions for the key.
The table needs immediate re-clustering.
Explanation
No.
The table is empty.
Explanation
No.
Overall explanation
A clustering depth of 1 means that for any value of the clustering key, only one micro-partition needs to be scanned. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions
Domain
Performance and Warehouses
Question 45
Skipped
A user is executing a complex JOIN across three large tables and the Query Profile shows Local Disk Spilling. What is the most effective way to resolve this?
Correct answer
Increase the Virtual Warehouse size (e.g. Small to Large).
Explanation
Spilling occurs when RAM is insufficient; a larger WH provides more RAM/SSD.
Enable Search Optimization Service.
Explanation
Not for joins.
Reduce the Time Travel retention.
Explanation
Retention does not affect execution RAM.
Create a Cluster Key on all three tables.
Explanation
Might help but does not fix RAM limits.
Overall explanation
Disk spilling happens when data exceeds the Warehouse memory. Upsizing the WH is the standard solution. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 46
Skipped
What happens to the data in a 'Temporary Table' if the user's session is disconnected due to a network failure?
Correct answer
The table and all its data are dropped immediately.
Explanation
Correct. Temporary tables only exist for the duration of the session.
The data is moved to Fail-safe.
Explanation
Temporary tables have no Fail-safe.
The table is converted to a Transient table.
Explanation
Requires manual conversion.
The data is stored for 24 hours of Time Travel.
Explanation
Time Travel is possible only if the session is active.
Overall explanation
Temporary tables are non-persistent and are purged when the session ends. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient"
Domain
Storage and Protection
Question 47
Skipped
What is the maximum file size recommended for a single file when loading data into Snowflake for optimal performance?
10 MB - 20 MB
10 GB
1 GB - 2 GB
Correct answer
100 MB - 250 MB (compressed)
Overall explanation
Snowflake recommends splitting large files into the 100-250MB range for parallel processing. Ref: https://docs.snowflake.com/en/user-guide/data-load-considerations-prepare"
Domain
Data Movement
Question 48
Skipped
Which role is the only one capable of managing Snowflake's 'Organization' level features such as creating new accounts?
ACCOUNTADMIN
Explanation
Highest role in an account.
SYSADMIN
Explanation
Manages objects.
Correct answer
ORGADMIN
Explanation
Highest role in the organization.
SECURITYADMIN
Explanation
Manages users/grants.
Overall explanation
ORGADMIN is a special role for managing multiple Snowflake accounts and organization settings. Ref: https://docs.snowflake.com/en/user-guide/admin-user-management
Domain
Security
Question 49
Skipped
What is the impact of using 'ORDER BY' in a view definition on the underlying table's clustering?
It improves pruning for all queries.
Explanation
Only for queries using that view.
Correct answer
It has no impact on the underlying table's physical clustering.
Explanation
Correct. Clustering is a physical property; views are logical.
It speeds up the next load.
Explanation
No.
It re-clusters the table.
Explanation
No impact on storage.
Overall explanation
Views do not change how data is physically stored on disk. Ref: https://docs.snowflake.com/en/user-guide/views-introduction
Domain
Performance and Warehouses
Question 50
Skipped
Which background service is responsible for automatically rearranging data in micro-partitions to match a table's clustering key?
Snowpipe
Query Accelerator Service
Search Optimization Service
Correct answer
Automatic Clustering
Overall explanation
Automatic Clustering is a serverless service that manages the data layout based on defined keys. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions
Domain
Performance and Warehouses
Question 51
Skipped
A user executes: SELECT * FROM my_table AT(OFFSET => -60*5). What are they attempting to do?
Delete data older than 5 minutes.
Explanation
This is a SELECT.
Correct answer
Query the state of the table as it was 5 minutes ago using Time Travel.
Explanation
Correct. OFFSET calculates time backwards in seconds.
Check the clustering depth.
Explanation
Requires a function.
Create a clone of the table.
Explanation
Requires CLONE keyword.
Overall explanation
The AT clause allows Time Travel queries based on a specific timestamp or offset. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel
Domain
Storage and Protection
Question 52
Skipped
A company is migrating from a legacy system and has JSON files with nested arrays. They want to flatten this data into a relational format. Which SQL operator is required?
PARSE_JSON
Explanation
Used to convert string to variant.
Correct answer
FLATTEN
Explanation
Correct. Used to explode arrays into multiple rows.
UNPIVOT
Explanation
Used for columns to rows.
STRTOK_TO_ARRAY
Explanation
Used for string splitting.
Overall explanation
The FLATTEN function is used to convert semi-structured data (arrays/objects) into multiple rows. Ref: https://docs.snowflake.com/en/sql-reference/functions/flatten
Domain
Storage and Protection
Question 53
Skipped
What is the purpose of the 'VALIDATION_MODE' parameter in a COPY INTO statement?
To speed up the load process.
Explanation
It slows it down because it doesn't load.
Correct answer
To parse the files and check for errors without actually loading the data.
Explanation
Correct.
To encrypt the data.
Explanation
No.
To verify the checksum of the S3 bucket.
Explanation
No.
Overall explanation
Validation mode is used to test data quality before performing a bulk load. Ref: https://docs.snowflake.com/en/sql-reference/sql/copy-into-table
Domain
Data Movement
Question 54
Skipped
A company requires HIPAA compliance and PHI data encryption. Which is the minimum Snowflake edition they must subscribe to?
Enterprise
Explanation
Includes 90-day time travel but not HIPAA by default.
Standard
Explanation
Does not support Business Critical security.
Virtual Private Snowflake
Explanation
Higher than needed.
Correct answer
Business Critical
Explanation
Highest security tier for compliance like HIPAA/HITRUST.
Overall explanation
Business Critical edition is required for compliance standards like HIPAA and higher levels of encryption. Ref: https://docs.snowflake.com/en/user-guide/intro-editions
Domain
Account and Data Sharing
Question 55
Skipped
Which of the following describes 'Secondary Roles' in Snowflake?
Correct answer
Allows a user to use the aggregate permissions of multiple roles in a single session.
Explanation
Correct. Introduced to simplify permission management.
A role inherited by the PUBLIC role.
Explanation
Incorrect hierarchy.
A way to assign a user to a backup role.
Explanation
Incorrect.
A role that can only read data.
Explanation
This is a functional definition.
Overall explanation
Secondary roles allow users to perform actions without constantly switching their active primary role. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-overview"
Domain
Security
Question 56
Skipped
Which of the following describes 'Search Optimization'?
A replacement for clustering.
Explanation
No.
A tool for full-text search in PDF files.
Explanation
No.
Correct answer
A persistent data structure that acts like a secondary index to speed up point lookups.
Explanation
Correct.
A feature of the Standard edition.
Explanation
Enterprise and higher only.
Overall explanation
Search Optimization is a serverless feature for improving needle-in-a-haystack queries. Ref: https://docs.snowflake.com/en/user-guide/search-optimization-service
Domain
Performance and Warehouses
Question 57
Skipped
Which privilege allows a role to see the query profile and execution details of queries run by other users?
APPLY MASKING
MONITOR USAGE
Correct answer
MONITOR
OPERATE
Overall explanation
The MONITOR privilege on a warehouse allows a user to see all activity on that compute resource. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges
Domain
Security
Question 58
Skipped
A user wants to upload a file from their local laptop to an internal Snowflake stage. Which tool/command MUST they use?
The Web Interface (Import)
Snowpipe
Correct answer
SnowSQL (PUT command)
COPY INTO
Overall explanation
The PUT command is used to upload local files and requires a client like SnowSQL or a driver. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-upload"
Domain
Data Movement
Question 59
Skipped
Which privilege is required for a role to be able to use a Virtual Warehouse?
OPERATE
MODIFY
MONITOR
Correct answer
USAGE
Overall explanation
The USAGE privilege allows a role to submit queries to a warehouse. Ref: https://docs.snowflake.com/en/user-guide/security-access-control-privileges"
Domain
Performance and Warehouses
Question 60
Skipped
What is the maximum number of days the 'QUERY_HISTORY' view in the 'INFORMATION_SCHEMA' can return?
365 days
Correct answer
7 days
Explanation
Correct.
14 days
1 day
Overall explanation
Information Schema is limited to 7 days. Use Account Usage for longer periods. Ref: https://docs.snowflake.com/en/sql-reference/info-schema/query_history
Domain
Account and Data Sharing
Question 61
Skipped
Which component of the Cloud Services layer prevents two users from modifying the same data at the exact same millisecond?
Optimizer
Security Manager
Correct answer
Transaction Management
Metadata Manager
Overall explanation
Transaction Management ensures ACID compliance and handles locking and concurrency control. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts"
Domain
Snowflake Architecture
Question 62
Skipped
True or False: A 'Task' in Snowflake can be configured to run only if a specific 'Stream' contains new changed data.
Correct answer
TRUE
Explanation
Correct. Using the WHEN SYSTEM$STREAM_HAS_DATA function.
FALSE
Explanation
This is a common use case.
Overall explanation
Tasks can be conditionally executed based on the presence of data in a stream to save credits. Ref: https://docs.snowflake.com/en/user-guide/tasks-intro
Domain
Account and Data Sharing
Question 63
Skipped
Which function is used to convert a JSON string into a Snowflake VARIANT data type?
CAST_AS_JSON
TO_VARIANT
Correct answer
PARSE_JSON
STRTOK
Overall explanation
PARSE_JSON takes a string and turns it into a structured VARIANT object. Ref: https://docs.snowflake.com/en/sql-reference/functions/parse_json"
Domain
Storage and Protection
Question 64
Skipped
Which of the following metadata is NOT tracked by Snowflake for each micro-partition?
The range of values (min/max) for each column.
Explanation
Tracked.
Correct answer
The names of the users who queried the partition.
Explanation
Not tracked at partition level.
The total number of rows in the partition.
Explanation
Tracked.
The compression format used.
Explanation
Tracked.
Overall explanation
User query history is tracked in separate logs not in the storage metadata. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions"
Domain
Storage and Protection
Question 65
Skipped
What is the effect of the 'DATA_RETENTION_TIME_IN_DAYS' parameter being set to 0 for a Permanent table?
The table is dropped.
Explanation
No.
Correct answer
Time Travel is disabled for that table.
Explanation
Correct.
The table becomes a Temporary table.
Explanation
No.
Fail-safe is disabled.
Explanation
Fail-safe remains at 7 days.
Overall explanation
Setting retention to 0 effectively turns off the ability to use Time Travel for that object. Ref: https://docs.snowflake.com/en/user-guide/data-time-travel"
Domain
Storage and Protection
Question 66
Skipped
A query shows 'Remote Disk Spilling' in the Query Profile. Which action would be the most effective to improve performance?
Create a Cluster Key.
Explanation
Helps pruning but not memory overflow.
Correct answer
Increase the size of the Virtual Warehouse.
Explanation
Provides more local SSD and RAM to prevent remote spilling.
Enable the Search Optimization Service.
Explanation
Used for point lookups not joins/spilling.
Switch to a Multi-cluster warehouse.
Explanation
Adds concurrency but not more RAM per node.
Overall explanation
Remote disk spilling is the slowest overflow level. Increasing warehouse size adds memory and local SSD. Ref: https://docs.snowflake.com/en/user-guide/performance-query-warehouse-size
Domain
Performance and Warehouses
Question 67
Skipped
What is the primary impact of 'Overlapping Micro-partitions' on query performance?
Correct answer
It decreases the effectiveness of query pruning.
Explanation
Correct. High overlap means more partitions must be scanned.
It increases storage costs.
Explanation
No impact on storage size.
It prevents Zero-copy cloning.
Explanation
Unrelated.
It disables the Result Cache.
Explanation
Unrelated.
Overall explanation
When micro-partitions overlap significantly for a specific column. Snowflake cannot skip them effectively. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Performance and Warehouses
Question 68
Skipped
Which of the following are TRUE regarding 'Internal Stages' in Snowflake? (Select all that apply)
Correct selection
There are named stages created within Snowflake.
Explanation
Correct.
Correct selection
They use the same storage pricing as tables.
Explanation
Correct.
Correct selection
Users are charged for data storage in internal stages.
Explanation
Correct.
They are always public to the internet.
Explanation
False. They are secure and managed by Snowflake.
Overall explanation
Internal stages are managed by Snowflake and follow the same storage cost as data in tables. Ref: https://docs.snowflake.com/en/user-guide/data-load-local-file-system-create-stage"
Domain
Data Movement
Question 69
Skipped
A security requirement mandates that a Social Security Number column must be visible only to the HR_MANAGER role. Which feature should be used?
Access Control List (ACL)
Explanation
Snowflake uses RBAC.
Correct answer
Dynamic Data Masking
Explanation
Correct for column-level security based on roles.
Object Tagging
Explanation
Used for classification.
Row Access Policy
Explanation
Filters rows not columns.
Overall explanation
Masking policies allow selective visibility of sensitive data based on the active role. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 70
Skipped
A financial firm needs to share data with a partner who does NOT have a Snowflake account. What should the firm create?
Correct answer
A Reader Account
Explanation
Provides access for non-Snowflake customers.
An External Table
Explanation
Does not facilitate secure sharing.
A Data Exchange
Explanation
Used for many-to-many sharing.
A Direct Share
Explanation
Requires a Snowflake account.
Overall explanation
Reader accounts are managed by the provider for consumers without their own Snowflake instance. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 71
Skipped
If a transaction is left open and the session is terminated, what is the default behavior in Snowflake?
The transaction stays open for 24 hours.
Explanation
No.
The data is moved to a temporary table.
Explanation
No.
Correct answer
The transaction is rolled back.
Explanation
Correct. Snowflake ensures ACID compliance by rolling back uncommitted work.
The transaction is committed.
Explanation
No.
Overall explanation
Snowflake automatically rolls back transactions from disconnected or failed sessions. Ref: https://docs.snowflake.com/en/sql-reference/transactions
Domain
Snowflake Architecture
Question 72
Skipped
What is the 'Fail-safe' duration for a table in the Snowflake Standard Edition?
90 days
Correct answer
7 days
1 day
0 days
Overall explanation
Fail-safe is always 7 days for permanent tables regardless of the edition. Ref: https://docs.snowflake.com/en/user-guide/data-failsafe"
Domain
Storage and Protection
Question 73
Skipped
A Data Engineer notices that Snowpipe is not loading data but the files are present in the S3 bucket. Which Information Schema table function should be used to see if Snowflake even detected the files?
PIPE_REST_API_HISTORY
Explanation
Used for API call monitoring.
VALIDATE_PIPE_LOAD
Explanation
Not a standard function for detection.
Correct answer
COPY_HISTORY
Explanation
Shows historical loads but not detection of new files.
PIPE_USAGE_HISTORY
Explanation
Shows credit consumption.
Overall explanation
The COPY_HISTORY function (or view) shows the status of files loaded or failed in the last 14 days. Ref: https://docs.snowflake.com/en/sql-reference/functions/copy_history
Domain
Data Movement
Question 74
Skipped
Which of the following commands will remove all data from a table but keep the table structure?
DELETE FROM
REMOVE
Correct answer
TRUNCATE TABLE
DROP TABLE
Overall explanation
TRUNCATE TABLE removes all rows and is a DDL operation. Ref: https://docs.snowflake.com/en/sql-reference/sql/truncate-table"
Domain
Storage and Protection
Question 75
Skipped
Which of the following are TRUE regarding the differences between INFORMATION_SCHEMA and the ACCOUNT_USAGE share? (Select all that apply)
Correct selection
Account Usage has a data latency of 45 minutes to 3 hours.
Explanation
Correct. Information Schema is real-time.
Information Schema includes objects that have been dropped.
Explanation
False. Only Account Usage includes dropped objects.
Correct selection
Account Usage retention is typically 365 days.
Explanation
Correct.
Correct selection
Information Schema is a set of views provided for each database.
Explanation
Correct.
Overall explanation
Account Usage is for long-term auditing with latency while Information Schema is for real-time metadata. Ref: https://docs.snowflake.com/en/sql-reference/account-usage#differences-between-account-usage-and-information-schema
Domain
Account and Data Sharing
Question 76
Skipped
A company needs to audit all failed login attempts across their entire Snowflake account from the last 6 months. Which view should they query?
INFORMATION_SCHEMA.LOGIN_HISTORY
Explanation
Real-time but only retains up to 7 days.
INFORMATION_SCHEMA.SESSIONS
Explanation
Shows current active sessions only.
Correct answer
SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
Explanation
Correct. Retains data for up to 1 year and covers the entire account.
SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
Explanation
Shows queries not login attempts.
Overall explanation
Account Usage views retain historical data for 365 days while Information Schema is for recent data. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/login_history
Domain
Security
Question 77
Skipped
A user needs to load data continuously from an S3 bucket as soon as files arrive. Which feature should they use?
COPY INTO
Explanation
Requires manual trigger.
Correct answer
Snowpipe
Explanation
Correct for continuous loading.
Data Sharing
Explanation
Used for sharing not loading.
Task
Explanation
Used for scheduling SQL.
Overall explanation
Snowpipe uses a serverless compute model. Ref: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-intro
Domain
Data Movement
Question 78
Skipped
Which of the following describes the 'Clustering Depth' of a table in Snowflake?
The time it takes to re-cluster a table.
Explanation
This is a duration metric.
The total number of micro-partitions in a table.
Explanation
This is the partition count.
Correct answer
A measure of how well the table is partitioned; a smaller depth indicates better clustering.
Explanation
Correct. Low depth means fewer micro-partitions overlap for specific values.
The number of columns defined in a cluster key.
Explanation
Incorrect definition.
Overall explanation
Clustering depth helps determine if a table needs a cluster key or if current pruning is efficient. Ref: https://docs.snowflake.com/en/user-guide/tables-clustering-micro-partitions#clustering-depth
Domain
Performance and Warehouses
Question 79
Skipped
A Virtual Warehouse is running 100 queries simultaneously. The 'Queued Overload' metric is high. What is the best way to handle this 'Concurrency' issue?
Increase the size from Small to Large.
Explanation
Increases speed of single queries but not necessarily concurrency capacity.
Enable Search Optimization.
Explanation
Not related to concurrency.
Correct answer
Add more clusters to a Multi-cluster warehouse.
Explanation
Correct. Adding clusters handles more simultaneous queries (Scale-out).
Restart the warehouse.
Explanation
Clears cache and slows down queries.
Overall explanation
Scale-out (adding clusters) is the solution for concurrency; Scale-up (increasing size) is for complex slow queries. Ref: https://docs.snowflake.com/en/user-guide/warehouses-multicluster"
Domain
Performance and Warehouses
Question 80
Skipped
A provider wants to share data with multiple consumers via a 'Data Exchange'. Which of the following is TRUE?
Correct answer
It allows the provider to control who can join the exchange and see the data listings.
Explanation
Correct. It is a private marketplace.
Consumers are always charged for the storage of shared data.
Explanation
Provider pays for storage.
Data is copied to each consumer's account.
Explanation
Data Sharing is zero-copy.
It is only available for Business Critical accounts.
Explanation
Available for all account types.
Overall explanation
A Data Exchange is a private circle for sharing data securely with specific invited members. Ref: https://docs.snowflake.com/en/user-guide/data-exchange-intro
Domain
Account and Data Sharing
Question 81
Skipped
How many 'Reader Accounts' can a Snowflake Provider account create?
Only 1
Correct answer
There is no hard limit
Up to 20
Depends on the Snowflake Edition
Overall explanation
Providers can create as many reader accounts as needed to support their consumers. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create
Domain
Account and Data Sharing
Question 82
Skipped
Which of the following describes the 'Security' of data at rest in Snowflake?
Correct answer
All data is automatically encrypted using AES-256.
Explanation
Correct.
Users must manually encrypt their data.
Explanation
Automatic.
Encryption is only available for Business Critical.
Explanation
All editions.
Only Enterprise edition encrypts data at rest.
Explanation
All editions.
Overall explanation
Snowflake provides transparent data encryption for all customers at no extra cost. Ref: https://docs.snowflake.com/en/user-guide/security-encryption"
Domain
Security
Question 83
Skipped
True or False: A single Snowflake account can span across multiple Cloud Providers (e.g., AWS and Azure).
TRUE
Correct answer
FALSE
Explanation
Correct.
Overall explanation
An account is tied to a specific region and provider at creation. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts"
Domain
Snowflake Architecture
Question 84
Skipped
True or False: Snowflake's architecture allows for simultaneous 'Loading' and 'Querying' of the same table without contention.
FALSE
Explanation
Snowflake handles this via micro-partitions.
Correct answer
TRUE
Explanation
Correct. Due to multi-version concurrency control (MVCC).
Overall explanation
Snowflake's architecture ensures that readers do not block writers and vice versa. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 85
Skipped
A company wants to share data with a consumer via a Reader Account. Who pays for the compute credits used by that Reader Account?
The Consumer
Correct answer
The Provider
Snowflake (it is free)
Shared 50/50
Overall explanation
Reader accounts are paid for by the provider account that created them. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-reader-create"
Domain
Account and Data Sharing
Question 86
Skipped
A company wants to track the 'Data Lineage' to see which downstream views are affected by a table change. Which Account Usage view is most relevant?
ACCESS_HISTORY
DATA_TRANSFER_HISTORY
TABLE_STORAGE_METRICS
Correct answer
OBJECT_DEPENDENCIES
Explanation
Correct. Shows the relationship between tables and views.
Overall explanation
OBJECT_DEPENDENCIES tracks how one object (like a view) refers to another (like a table). Ref: https://docs.snowflake.com/en/user-guide/object-dependencies
Domain
Account and Data Sharing
Question 87
Skipped
Which command will show the amount of storage credits used by 'Fail-safe' data across the entire account?
Correct answer
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
Explanation
Correct. Contains columns for Fail-safe bytes.
DESCRIBE ACCOUNT
SHOW STORAGE
SHOW FAILSAFE
Overall explanation
TABLE_STORAGE_METRICS provides a detailed breakdown of Time Travel and Fail-safe storage usage. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/table_storage_metrics
Domain
Storage and Protection
Question 88
Skipped
A company has 50 TB of data and wants to implement 'Access History' to see which columns are most frequently queried for GDPR compliance. Which Snowflake edition is the minimum required?
Business Critical
Explanation
Account Usage Access History is an Enterprise feature (and above).
Enterprise
Explanation
Does not include Access History.
Correct answer
Enterprise Edition
Explanation
Correct. Access History is part of the Snowflake Governance package in Enterprise and higher.
Standard
Explanation
Basic features only.
Overall explanation
Access History is part of the advanced governance features available in Enterprise Edition and above. Ref: https://docs.snowflake.com/en/user-guide/access-history
Domain
Security
Question 89
Skipped
Which feature allows you to 'undo' a DROP TABLE command within the Time Travel period?
Correct answer
UNDROP TABLE
Explanation
Correct.
RECOVER TABLE
CLONE TABLE
RESTORE TABLE
Overall explanation
UNDROP restores the last version of a dropped object as long as it is within the Time Travel window. Ref: https://docs.snowflake.com/en/sql-reference/sql/undrop-table
Domain
Storage and Protection
Question 90
Skipped
Which type of table is most appropriate for storing large amounts of transient data that does not require Fail-safe protection but should persist across multiple sessions?
Temporary Table
Explanation
Purged after session ends.
External Table
Explanation
Stored outside Snowflake.
Correct answer
Transient Table
Explanation
Persists across sessions but lacks Fail-safe.
Permanent Table
Explanation
Has Fail-safe and higher costs.
Overall explanation
Transient tables are ideal for ETL work-stages to save on Fail-safe storage costs. Ref: https://docs.snowflake.com/en/user-guide/tables-temp-transient
Domain
Storage and Protection
Question 91
Skipped
Which of the following commands can be used to see the credit usage for a specific 'Task'?
MONITOR TASK
DESCRIBE TASK
Correct answer
SELECT * FROM TABLE(INFORMATION_SCHEMA.SERVERLESS_TASK_HISTORY())
Explanation
Correct.
SHOW TASKS
Overall explanation
Serverless features like Tasks have specific history functions to track their consumption. Ref: https://docs.snowflake.com/en/sql-reference/functions/serverless_task_history
Domain
Account and Data Sharing
Question 92
Skipped
What is the specific purpose of the System-defined Function SYSTEM$PIPE_STATUS?
Correct answer
To monitor the health and status of a Snowpipe.
Explanation
Correct for troubleshooting Snowpipe.
To check the syntax of a COPY INTO statement.
Explanation
Not for syntax.
To refresh an external stage manually.
Explanation
This is ALTER STAGE.
To see the credits consumed by a Warehouse.
Explanation
Used for billing.
Overall explanation
This function is critical for diagnosing data ingestion issues in continuous pipelines. Ref: https://docs.snowflake.com/en/sql-reference/functions/system_pipe_status
Domain
Data Movement
Question 93
Skipped
Which Snowflake object allows you to store and query files in a cloud location without ever moving the data into Snowflake storage?
Correct answer
External Table
Explanation
Correct. It maps metadata over external files.
Internal Stage
Materialized View
Transient Table
Overall explanation
External tables act as a schema-on-read layer over data lakes like S3 or Azure Blob. Ref: https://docs.snowflake.com/en/user-guide/tables-external-intro
Domain
Data Movement
Question 94
Skipped
Which function allows you to extract all the keys present in a VARIANT column containing a JSON object?
GET_KEYS()
FLATTEN()
Correct answer
OBJECT_KEYS()
Explanation
Correct.
JSON_EXTRACT_PATH_TEXT()
Overall explanation
OBJECT_KEYS returns an array of the top-level keys in a VARIANT object. Ref: https://docs.snowflake.com/en/sql-reference/functions/object_keys
Domain
Storage and Protection
Question 95
Skipped
Which background service is used to optimize the storage of semi-structured data by 'sub-columnarizing' VARIANT columns?
The Metadata Manager
Correct answer
The Cloud Services Layer
Explanation
Correct. This is handled automatically during ingestion.
The Optimizer
Automatic Clustering
Overall explanation
Snowflake automatically extracts common fields from JSON/VARIANT into a columnar format for faster access. Ref: https://docs.snowflake.com/en/user-guide/tables-micro-partitions
Domain
Storage and Protection
Question 96
Skipped
Which of the following are TRUE regarding 'Snowflake Managed Keys'? (Select all that apply)
Correct selection
They are used for transparent data encryption.
Explanation
Correct.
Correct selection
They are based on a hierarchical key model.
Explanation
Correct.
Users must manually create them before loading data.
Explanation
False. Snowflake manages them.
Correct selection
They are rotated every 30 days.
Explanation
Correct.
Overall explanation
Snowflake manages a multi-level hierarchy of keys that are automatically rotated. Ref: https://docs.snowflake.com/en/user-guide/security-encryption
Domain
Security
Question 97
Skipped
If a 'Resource Monitor' is set to 'Notify' at 80% and 'Suspend' at 100%, what happens if the usage reaches 85%?
Correct answer
An alert is sent but the warehouse continues to run.
Explanation
Correct.
The warehouse stops.
Explanation
No.
New queries are blocked.
Explanation
No.
The warehouse is resized down.
Explanation
No.
Overall explanation
A Notify action only triggers an alert to the designated administrators. Ref: https://docs.snowflake.com/en/user-guide/resource-monitors
Domain
Performance and Warehouses
Question 98
Skipped
Which type of Snowflake role is required to create a 'Share' object?
SECURITYADMIN
SYSADMIN
USERADMIN
Correct answer
ACCOUNTADMIN
Explanation
Correct (or role with specific global privilege).
Overall explanation
Creating a share is a high-level administrative task usually reserved for ACCOUNTADMIN. Ref: https://docs.snowflake.com/en/user-guide/data-sharing-intro
Domain
Account and Data Sharing
Question 99
Skipped
Which view would you use to find out which 'Network Policies' are currently assigned to the account?
LOGIN_HISTORY
NETWORK_POLICIES
Explanation
Shows existing policies but not their assignment.
Correct answer
POLICY_REFERENCES
Explanation
Correct. General view for all policy assignments.
ACCOUNT_PARAMETERS
Overall explanation
The POLICY_REFERENCES view shows which policies are active on which objects/account. Ref: https://docs.snowflake.com/en/sql-reference/account-usage/policy_references
Domain
Security
Question 100
Skipped
Which Snowflake layer is responsible for query optimization and transaction management?
Access Layer
Explanation
Not a formal layer name.
Correct answer
Cloud Services Layer
Explanation
Correct layer for metadata and optimization.
Storage Layer
Explanation
Handles data persistence.
Compute Layer
Explanation
Handles query execution.
Overall explanation
The Cloud Services layer is the brain of Snowflake. Ref: https://docs.snowflake.com/en/user-guide/intro-key-concepts
Domain
Snowflake Architecture
Question 101
Skipped
A DevOps engineer needs to clone a production database to a development environment. The production database has 10 TB of data. What is the impact on storage costs immediately after cloning?
Storage costs double immediately.
Explanation
Cloning is zero-copy.
Storage costs are waived for the first 24 hours.
Explanation
There is no such grace period.
Costs increase by 10% for the metadata overhead.
Explanation
Metadata storage is negligible.
Correct answer
No additional storage costs are incurred for the data until the cloned objects are modified.
Explanation
Correct. Initial cloning only creates metadata.
Overall explanation
Snowflake uses Zero-copy cloning which means data is shared between objects until changes occur. Ref: https://docs.snowflake.com/en/user-guide/tables-storage-considerations
Domain
Storage and Protection
Question 102
Skipped
When using 'Dynamic Data Masking', what happens if a role without privileges tries to query a masked column?
The column is hidden from the result set.
Explanation
Masking replaces values; it doesn't hide columns.
Correct answer
The user sees a masked value (e.g., ***** or NULL) based on the policy.
Explanation
Correct.
The query fails with an error.
Explanation
No.
The user sees the original data but a warning is logged.
Explanation
No.
Overall explanation
Masking policies intercept the data and replace it with a pre-defined mask for unauthorized roles. Ref: https://docs.snowflake.com/en/user-guide/security-column-ddm-intro
Domain
Security
Question 103
Skipped
Which type of data file format is NOT natively supported for data loading into Snowflake?
Parquet
ORC
Correct answer
HTML
XML
Overall explanation
Snowflake supports CSV, JSON, Parquet, Avro, ORC and XML. HTML is not a supported data load format. Ref: https://docs.snowflake.com/en/user-guide/data-load-formats"
Domain
Data Movement
Question 104
Skipped
Which SQL function is used to convert a VARIANT column containing a date-string into a proper DATE type?
Correct answer
TO_DATE(column::string)
CAST_AS_DATE(column)
DATE_CONVERT(column)
FLATTEN(column)
Overall explanation
You must first cast the variant to a string and then use a conversion function. Ref: https://docs.snowflake.com/en/user-guide/querying-semistructured"
Domain
Storage and Protection