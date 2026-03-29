Which command is used to unload data from a Snowflake table into a file in a stage?

EXTRACT INTO

Correct answer
COPY INTO

Your answer is incorrect
GET

WRITE

Overall explanation
The COPY INTO command is used to export data from a Snowflake table into a file stored in a stage (either internal or external).

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
How are serverless features billed?

Per second multiplied by the size, as determined by the SERVERLESS_FEATURES_SIZE account parameter

Serverless features are not billed, unless the total cost for the month exceeds 10% of the warehouse credits, on the account

Correct answer
Per second multiplied by an automatic sizing for the job

Per minute multiplied by an automatic sizing for the job, with a minimum of one minute

Overall explanation
Snowflake bills serverless features (such as Snowpipe or serverless tasks) based on the actual compute time used, measured in seconds, and automatically determines the appropriate size of the compute resources required for the job. This approach ensures that you only pay for the compute resources consumed during execution, optimizing cost efficiency.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
A Snowflake user executed a query and received the results. Another user executed the same query 4 hours later. The data had not changed.

What will occur?

The default virtual warehouse will be used to read all data.

The virtual warehouse that is defined at the session level will be used to read all data.

No virtual warehouse will be used, data will be read from the local disk cache.

Correct answer
No virtual warehouse will be used, data will be read from the result cache.

Overall explanation
Snowflake stores the results of queries in a result cache for 24 hours if the underlying data has not changed. When the same query is executed within this period by another user with the necessary permissions, Snowflake retrieves the results from the result cache without using a virtual warehouse, which saves on compute resources.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
Using which copy option when unloading data allows users to include a Universally Unique Identifier (UUID) in the names of unloaded files?

SINGLE

Correct answer
INCLUDE_QUERY_ID

VALIDATION_MODE

HEADER

Overall explanation
To prevent files from being accidentally overwritten by concurrent COPY INTO statements, setting INCLUDE_QUERY_ID = TRUE adds a unique ID to the filenames of unloaded data files.

It's also important to be familiar with some of the other key configurations supported by COPY INTO.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
Which ACCOUNT_USAGE views are used to evaluate the details of dynamic data masking? (Choose two.)

ACCESS_HISTORY

QUERY_HISTORY

ROLES

Correct selection
MASKING_POLICIES

Correct selection
POLICY_REFERENCES

Overall explanation
The ACCOUNT_USAGE views used to evaluate the details of dynamic data masking are POLICY_REFERENCES and MASKING_POLICIES. POLICY_REFERENCES provides information on how masking policies are applied to specific objects and columns, while MASKING_POLICIES lists the defined masking policies, including their definitions and associated roles.

For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
Which Snowflake objects use storage? (Choose two.)

Correct selection
Regular table

Cached query result

External table

Correct selection
Materialized view

Regular view

Overall explanation
Please review the table in the following Snowflake documentation article, it is quite useful!



For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
If a multi-cluster warehouse is using an economy scaling policy, how long will queries wait in the queue before another cluster is started?

1 minute

8 minutes

Correct answer
6 minutes

2 minutes

Overall explanation
With the economy scaling policy, a multi-cluster warehouse will wait 6 minutes before starting an additional cluster, optimizing resource use and cost efficiency.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
What is the minimum Snowflake edition required to create a materialized view?

Standard Edition

Virtual Private Snowflake Edition

Business Critical Edition

Correct answer
Enterprise Edition

Overall explanation
Materialized views are supported starting from the Enterprise Edition of Snowflake. This feature allows Snowflake to store the results of a query physically, enabling faster retrieval of frequently queried data. Higher editions like Business Critical and Virtual Private Snowflake include materialized views along with additional security and compliance features.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
Which statement MOST accurately describes clustering in Snowflake?

The database ACCOUNTADMIN must define the clustering methodology for each Snowflake table.

Correct answer
Clustering is the way data is grouped together and stored within Snowflake micro-partitions.

Clustering can be disabled within a Snowflake account.

The clustering key must be included in the COPY command when loading data into Snowflake.

Overall explanation
Clustering in Snowflake refers to how data is organized and grouped within micro-partitions. Snowflake automatically organizes data during loading, but you can define a clustering key to optimize query performance for specific columns. Clustering is not something that can be disabled.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
Which command can be executed from a reader account?

Correct answer
COPY INTO [location]

SHOW PROCEDURES

INSERT

CREATE SHARE

Overall explanation
A reader account is designed primarily for querying data shared by the account provider. For example, we can work with data by creating materialized views.

However, in a reader account, we cannot set a data metric function on objects or upload new data. But we can use the COPY INTO <location> command with your connection credentials to unload data into a cloud storage location.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
What is the MINIMUM Snowflake edition required to use the periodic rekeying of micro-partitions?

Virtual Private Snowflake

Business Critical

Correct answer
Enterprise

Standard

Overall explanation
Periodic rekeying requires Enterprise Edition (or higher).

For more detailed information, refer to the official Snowflake documentation.

Question 12
Skipped
Which snowflake objects will incur both storage and cloud compute charges? (Choose two.)

Secure view

Correct selection
Clustered table

Sequence

Transient table

Correct selection
Materialized view

Overall explanation
Materialized views incur storage charges because the results are physically stored and compute charges during refreshes. Clustered tables incur storage charges for the data and compute charges for automatic or manual clustering operations.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
What Snowflake role must be granted for a user to create and manage accounts?

SYSADMIN

SECURITYADMIN

Correct answer
ORGADMIN

ACCOUNTADMIN

Overall explanation
The question is for 'account' , not creating a role or user. The ORGADMIN role is specifically designed for managing multiple accounts within an organization. It provides the necessary privileges to create, manage, and configure Snowflake accounts.



For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
Which of the following Snowflake objects can be shared using a secure share? (Choose two.)

Correct selection
Tables

Correct selection
Secure User Defined Functions (UDFs)

Materialized views

Procedures

Sequences

Overall explanation
These Snowflake objects can be shared: tables, external tables, secure views, secure materialized views, secure UDFs.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
What is the MINIMUM Snowflake edition that must be used in order to see the ACCESS_HISTORY view?

Virtual Private Snowflake (VPS)

Standard

Correct answer
Enterprise

Business Critical

Overall explanation
You need Enterprise Edition (or higher) to use Access History. This Account Usage view lets you see who accessed Snowflake objects (like tables, views, and columns) in the last year.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
How can a user access information about a query execution plan without consuming virtual warehouse compute resources?

Use the Snowsight dashboard.

Review the Query Profile metrics.

Correct answer
Use the EXPLAIN function.

Review the data in the Account_Usage view.

Overall explanation
An explain plan outlines the various steps Snowflake would take to run a query, such as scanning tables and performing joins.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
What can be used to identify the database, schema, stage, and file path to a set of files, and to allow a role that has sufficient privileges on the stage to access the files?

A directory table

A scoped URL

Correct answer
A file URL

A pre-signed URL

Overall explanation
A file URL points to your files, specifying the database, schema, stage, and file location. Anyone with the right permissions on the stage can access those files.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
A column named Data contains VARIANT data and stores values as follows:







How will Snowflake extract the employee’s name from the column data?

DATA:employee.name

data:employee.name

Data:employee.name

Correct answer
data:Employee.name

Overall explanation
The : operator is used to navigate the hierarchy within the VARIANT column. Since JSON keys are case-sensitive, the key Employee must match exactly as written in the JSON structure, and name retrieves the value "John".

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
A data provider wants to share data with a consumer who does not have a Snowflake account. The provider creates a reader account for the consumer following these steps:

1. Created a user called "CONSUMER"

2. Created a database to hold the share and an extra-small warehouse to query the data

3. Granted the role PUBLIC the following privileges: Usage on the warehouse, database, and schema, and SELECT on all the objects in the share

Based on this configuration what is true of the reader account?

The reader account will automatically use the Standard edition of Snowflake.

Correct answer
The reader account compute will be billed to the provider account.

The reader account can clone data the provider has shared, but cannot re-share it.

The reader account can create a copy of the shared data using CREATE TABLE AS...

Overall explanation
In Snowflake, reader accounts are created and managed by the data provider, and any compute resources used by the reader account (such as virtual warehouses) are billed to the provider. The reader account itself cannot incur separate billing.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
Which privilege must be granted by one role to another role, and cannot be revoked?

ALL

Correct answer
OWNERSHIP

MONITOR

OPERATE

Overall explanation
The OWNERSHIP privilege must be granted by one role to another role and cannot be revoked. Transferring ownership changes the owner of an object, and the new owner gains full control, including the ability to manage all privileges.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
How long is Snowpipe data load history retained?

64 days

Until the pipe is dropped

Correct answer
14 days

As configured in the CREATE PIPE settings

Overall explanation
Snowflake retains Snowpipe data load history for 14 days, allowing users to monitor and troubleshoot data loading activities within that timeframe. (64 days for COPY)

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
Which role has the ability to create and manage users and roles?

SYSADMIN

SYSADMIN

ORGADMIN

Correct answer
USERADMIN

Overall explanation
The USERADMIN role includes the privileges to create and manage users and roles, provided that ownership of those roles or users has not been transferred to another role.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
What service is provided as an integrated Snowflake feature to enhance Multi-Factor Authentication (MFA) support?

Single Sign-On (SSO)

Okta

OAuth

Correct answer
Duo Security

Overall explanation
Snowflake does not enable MFA for individual users by default. To activate it, you need to enroll via Snowsight. This process involves having a smartphone with a valid phone number and the Duo Mobile app installed to complete the setup.

For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
What does the 128 MB size limit apply to when using the Snowflake VARIANT data type?

Individual columns

Correct answer
Individual rows

All columns

All rows

Overall explanation
This limit applies to each individual VARIANT value stored in a column, not to entire rows or all columns collectively.

The 128 MB limit is per VARIANT column value, meaning each individual cell containing VARIANT data can hold up to 128 MB of uncompressed semi-structured data (JSON, XML, Avro, etc.).

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
Which of the following activities consume virtual warehouse credits in the Snowflake environment? (Choose two.)

Caching query results

Cloning a database

Correct selection
Running COPY commands

Running EXPLAIN and SHOW commands

Correct selection
Running a custom query

Overall explanation
Custom queries consume virtual warehouse compute resources, and therefore credits, as they require processing power to retrieve and manipulate data.

COPY operations, used for loading or unloading data, also utilize the virtual warehouse, consuming credits based on the compute resources required.

Caching and metadata operations typically use the cloud services layer, which does not consume warehouse credits.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
Which function determines the kind of value stored in a VARIANT column?

IS_JSON

IS_ARRAY

CHECK_JSON

Correct answer
TYPEOF

Overall explanation
The TYPEOF function is used to determine the type of value stored in a VARIANT column in Snowflake. It returns a string representing the type of the value, such as "ARRAY", "OBJECT", "STRING", etc., which helps in understanding and handling semi-structured data stored in VARIANT columns​.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
A user is trying to share a new secure view that references an object in a different database.
Which privileges should be granted to the share so that the secure view can be shared?

The USAGE privilege on the database and schema along with the REFERENCE_USAGE privilege on the source database and USAGE on the secure view.

Correct answer
The USAGE privilege on the database and schema along with the REFERENCE_USAGE privilege on the source database and SELECT on the secure view.

The SELECT privilege on future views in the schema.

The SELECT privilege on the database and schema along with the USAGE privilege on the source database and SELECT on the secure view.

Overall explanation
To share a secure view that references objects in another database, privileges must support both namespace visibility and cross-database dependency resolution.

Required grants:

USAGE on the database and schema containing the secure view
This allows the share to access the namespace where the view is defined.

REFERENCE_USAGE on each source database referenced by the view
When the secure view depends on objects located in other databases, this privilege enables dependency resolution without granting direct access to those underlying objects.

SELECT on the secure view itself
This is the object actually exposed to consumers. Granting SELECT allows them to query the view while maintaining the security boundaries enforced by the secure view definition.

This combination ensures consumers can query the view while preserving encapsulation of the underlying data sources.

For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
A user needs to automatically retrieve the Iceberg column definitions using the INFER_SCHEMA function for semi-structured files stored on a stage.

Which file format configuration will help them achieve this?

CREATE FILE FORMAT MY_FF TYPE = ORC;
CREATE FILE FORMAT MY_FF TYPE = AVRO;
CREATE FILE FORMAT MY_FF TYPE = PARQUET USE_VECTORIZED_SCANNER = FALSE;
Correct answer
CREATE FILE FORMAT MY_FF TYPE = PARQUET USE_VECTORIZED_SCANNER = TRUE;
Overall explanation
To automatically derive Iceberg table column definitions using INFER_SCHEMA, the staged data must be in Parquet format and processed with a file format that has USE_VECTORIZED_SCANNER = TRUE.

The vectorized scanner is required so Snowflake can correctly interpret Parquet metadata and generate column definitions compatible with Iceberg.

The typical workflow is:

Create or modify a Parquet file format with USE_VECTORIZED_SCANNER = TRUE.

Call INFER_SCHEMA referencing that file format.

Set KIND => 'ICEBERG' to instruct Snowflake to return Iceberg-compatible column metadata.

Although INFER_SCHEMA supports multiple file formats (e.g., Parquet, Avro, ORC, JSON, CSV), automatic Iceberg schema extraction specifically requires Parquet with the vectorized scanner enabled.

For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
What metadata does Snowflake store for rows in micro-partitions? (Choose two.)

Correct selection
Distinct values

Sorted values

Correct selection
Range of values

Index values

Null values

Overall explanation
Snowflake stores metadata for micro-partitions, including the range of values for each column, which helps optimize query performance by enabling partition pruning. It also tracks distinct values, count, etc.

For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
How can the performance of queries run on external tables be optimized?

Enable the search optimization service

Correct answer
Create materialized views on the tables

Cluster the tables

Use the metadata cache

Overall explanation
Materialized views on external tables can offer significantly better performance than running the same queries directly on the external tables, especially for complex or frequently executed queries.

For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
Which SQL commands, when committed, will consume a stream and advance the stream offset? (Choose two.)

SELECT FROM STREAM

ALTER TABLE AS SELECT FROM STREAM

Correct selection
UPDATE TABLE FROM STREAM

BEGIN COMMIT

Correct selection
INSERT INTO TABLE SELECT FROM STREAM

Overall explanation
DMLs advance Stream.

For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
Which Snowflake function will interpret an input string as a JSON document, and produce a VARIANT value?

json_extract_path_text()

Correct answer
parse_json()

flatten

object_construct()

Overall explanation
The parse_json() function takes a string as input and interprets it as a JSON document, converting it into Snowflake's VARIANT data type. This allows you to work with the JSON data using Snowflake's semi-structured data functions.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
What operation can be performed using Time Travel?

Disabling Time Travel for a specific object by setting DATA_RETENTION_TIME_IN_DAYS to NULL

Correct answer
Creating a clone of an entire table at a specific point in the past from a permanent table

Restoring tables that have been dropped from a data share

Extending a permanent table’s retention duration from 90 to 100 days

Overall explanation
Time Travel allows users to create a clone of a table, schema, or database at a specific point in the past. This feature is useful for recovering previous versions of data without restoring or duplicating the original data. Time Travel also enables the recovery of dropped tables, but it is not available for data shares.

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
Which system function can be used to manage access to the data in a share and display certain data only to paying customers?

SYSTEM$ALLOWLIST

SYSTEM$ALLOWLIST_PRIVATELINK

SYSTEM$AUTHORIZE_PRIVATELINK

Correct answer
SYSTEM$IS_LISTING_PURCHASED

Overall explanation
SYSTEM$IS_LISTING_PURCHASED function enables access control by checking if a customer has purchased the data listing, allowing data to be displayed only to paying customers.

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
How many days is load history for Snowpipe retained?

64 days

Correct answer
14 days

7 days

1 day

Overall explanation
Snowflake retains Snowpipe load history for 14 days, allowing users to view details about data loading operations and monitor the status of files ingested during that period. This includes information such as file load status, time of ingestion, and any errors encountered during the process.

Copy -> 64 days.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
Which query will return a sample of a table with 1000 rows named testtable, in which each row has a 10% probability of being included in the sample?

select * from testtable sample (0.1 rows);

Correct answer
select * from testtable sample (10);

select * from testtable sample (10 rows);

select * from testtable sample (0.1);

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
Which parameter can be set at the account level to set the minimum number of days for which Snowflake retains historical data in Time Travel?

MAX_CONCURRENCY_LEVEL

Correct answer
MIN_DATA_RETENTION_TIME_IN_DAYS

DATA_RETENTION_TIME_IN_DAYS

MAX_DATA_EXTENSION_TIME_IN_DAYS

Overall explanation
The minimum number of days for which Snowflake retains historical data for performing Time Travel actions (such as SELECT, CLONE, or UNDROP) on an object is determined by the MIN_DATA_RETENTION_TIME_IN_DAYS setting. If a minimum retention period is set at the account level, the data retention period for an object is determined by the greater of MAX(DATA_RETENTION_TIME_IN_DAYS) and MIN_DATA_RETENTION_TIME_IN_DAYS.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
In which Snowsight section can a user switch roles, modify their profile, and access documentation?

The worksheets page

The monitoring page

The content pane

Correct answer
The user menu

Overall explanation
In Snowsight, users can switch roles, modify their profile, and access documentation through the user menu. This menu typically contains options for managing user settings and accessing help resources.

For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
When referring to User-Defined Function (UDF) names in Snowflake, what does the term overloading mean?

There are multiple SQL UDFs with different names but the same number of arguments or argument types.

Correct answer
There are multiple SQL UDFs with the same names but with a different number of arguments or argument types.

There are multiple SQL UDFs with the same names and the same number of arguments.

There are multiple SQL UDFs with the same names and the same number of argument types.

Overall explanation
Overloading procedures and functions

In Snowflake, overloading refers to the ability to define multiple user-defined functions (UDFs) with the same name but different numbers of arguments or argument types. This allows the same function name to handle different input types or different numbers of inputs, making it flexible for various use cases while keeping the function name consisten.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
Which of the following is the Snowflake ACCOUNT_USAGE.METERING_HISTORY view used for?

Correct answer
Gathering the hourly credit usage for an account

Summarizing the throughput of Snowpipe costs for an account

Compiling an account's average cloud services cost over the previous month

Calculating the funds left on an account's contract

Overall explanation
The METERING_HISTORY view in Snowflake's ACCOUNT_USAGE schema provides detailed information about the hourly credit consumption of an account. It allows you to monitor credit usage across virtual warehouses, cloud services, and other resources over time.

For more detailed information, refer to the official Snowflake documentation.

Question 41
Skipped
Which methods can be used to delete staged files from a Snowflake stage? (Choose two.)

Specify the TEMPORARY option when creating the file format.

Correct selection
Specify the PURGE copy option in the COPY INTO command.

Use the DROP command after the load completes.

Use the DELETE LOAD HISTORY command after the load completes.

Correct selection
Use the REMOVE command after the load completes.

Overall explanation
The methods that can be used to delete staged files from a Snowflake stage are specify the PURGE copy option in the COPY INTO command and use the REMOVE command after the load completes. These methods ensure that files are deleted automatically or manually after they have been processed.

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
Which of the following are valid methods for authenticating users for access into Snowflake? (Choose three.)

SCIM

Correct selection
Federated authentication

Correct selection
OAuth

TLS 1.2

Correct selection
Key-pair authentication

OCSP authentication

Overall explanation
Federated authentication allows users to log in via an external identity provider (IdP) using SSO. Key-pair authentication uses public/private keys for authentication, often for service accounts. OAuth is an authentication framework that enables secure access through third-party providers.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
What are the correct parameters for time travel and fail-safe in the Snowflake Enterprise Edition?

Correct answer
Default Time Travel Retention is set to 1 day. Maximum Time Travel Retention is 90 days. Fail Safe retention time is 7 days.

Default Time Travel Retention is set to 0 days. Maximum Time Travel Retention is 30 days. Fail Safe retention time is 1 day.

Default Time Travel Retention is set to 1 day. Maximum Time Travel Retention is 365 days. Fail Safe retention time is 7 days.

Default Time Travel Retention is set to 0 days. Maximum Time Travel Retention is 90 days. Fail Safe retention time is 7 days.

Overall explanation
Default Time Travel Retention is set to 1 day, Maximum Time Travel Retention is 90 days, and Fail Safe retention time is 7 days. Time Travel allows accessing historical data, while Fail-safe provides an additional 7-day recovery period after the Time Travel period ends.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
Which role is responsible for managing the billing and credit data within Snowflake?

SYSADMIN

ORGADMIN

Correct answer
ACCOUNTADMIN

SECURITYADMIN

Overall explanation
The ACCOUNTADMIN role has the privileges necessary to manage account-level operations, including billing and credit information.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
What is the recommended way to change the existing file format type in my_format from CSV to JSON?

ALTER FILE FORMAT my_format SWAP TYPE WITH JSON;

ALTER FILE FORMAT my_format SET TYPE=JSON;

REPLACE FILE FORMAT my_format TYPE=JSON;

Correct answer
CREATE OR REPLACE FILE FORMAT my_format TYPE=JSON;

Overall explanation
This command will replace the existing file format with a new one set to JSON, ensuring that any previous configurations are updated accordingly.

ALTER FILE FORMAT changes the settings of a file format object. You can currently rename the file format, modify its type-specific options, or add/update a comment. For all other changes, the file format must be deleted and recreated.

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Which of the following compute resources or features are managed by Snowflake? (Choose two.)

Execute a COPY command

Scaling up a warehouse

Correct selection
AUTOMATIC_CLUSTERING

Correct selection
Snowpipe

Updating data

Overall explanation
Snowpipe is a managed service provided by Snowflake that automatically loads data as it arrives in a stage.

AUTOMATIC_CLUSTERING: Snowflake automatically handles the reorganization of data within micro-partitions based on a clustering key without user intervention.

Scaling up a Warehouse, when using warehouses in non-serverless processes will always be a manual process that will not be managed by Snowflake. Roles with sufficient privileges (MANAGE WAREHOUSE, MODIFY) will be able to resize the Warehouse.

On the other hand, the addition or reduction of clusters in the case of Scale OUT is a process managed autonomously by Snowflake, depending on the load of the current Virtual Warehouse clusters and the configuration to prioritize queuing or resource savings.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
Which of the following statements describe features of Snowflake data caching?

A user can only access their own queries from the query result cache.

When a virtual warehouse is suspended, the data cache is saved on the remote storage layer.

When the data cache is full, the least-recently used data will be cleared to make room.

Correct answer
The RESULT_SCAN table function can access and filter the contents of the query result cache.

Overall explanation
The query using RESULT_SCAN can include clauses like filters and ORDER BY, which may not have been in the original query. This allows for refining or altering the result set.

For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
Which access control entity in Snowflake can be created as part of a hierarchy within an account?

Correct answer
Role

Privilege

Securable object

User

Overall explanation
RBAC approach. A role is something you give permissions to. Then, you give the roles to users. Roles can also be given to other roles, creating a hierarchy.

For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
What is the minimum Snowflake edition needed for database failover and fail-back between Snowflake accounts for business continuity and disaster recovery?

Enterprise

Correct answer
Business Critical

Standard

Virtual Private Snowflake

Overall explanation
Replication of additional account objects and failover/failback functionality require the Business Critical Edition or VPS (higher).

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
A table needs to be loaded. The input data is in JSON format and is a concatenation of multiple JSON documents. The file size is 3 GB. A warehouse size S is being used. The following COPY INTO command was executed:

COPY INTO SAMPLE FROM @~/SAMPLE.JSON (TYPE=JSON)

The load failed with this error:

Max LOB size (134217728) exceeded, actual size of parsed column is <actual_size>

How can this issue be resolved?

Use a larger-sized warehouse.

Correct answer
Set STRIP_OUTER_ARRAY=TRUE in the COPY INTO command.

Compress the file and load the compressed file.

Split the file into multiple files in the recommended size range (100 MB - 250 MB).

Overall explanation
The error Max LOB size (134217728) exceeded indicates that Snowflake is trying to parse the entire 3 GB file as a single JSON object, which exceeds the 128 MB (134,217,728 bytes) limit for VARIANT data types.

Since the file contains "a concatenation of multiple JSON documents," Snowflake supports loading such files when they are in NDJSON (newline delimited JSON) or comma-separated JSON format.

STRIP_OUTER_ARRAY=TRUE instructs the JSON parser to remove outer brackets [ ]. This allows Snowflake to treat each JSON document in the concatenated file as a separate row instead of trying to parse the entire file as one massive JSON object

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
When loading data into Snowflake, the COPY command supports which of the following?

Correct answer
Column reordering

Filters

Joins

Aggregates

Overall explanation
Column reordering is one of the transformations allowed during the COPY process. (Column omitting too)

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
What happens when a multi-cluster virtual warehouse is resized?

The minimum and maximum number of clusters is automatically adjusted.

The scaling policy of the warehouse is updated.

The auto-suspend feature is automatically enabled for inactive clusters.

Correct answer
The new size applies to all clusters within that warehouse configuration.

Overall explanation
When you resize a multi-cluster warehouse, the new size is applied to all clusters, both those currently running and any new ones that start up.

For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
On which of the following cloud platforms can a Snowflake account be hosted? (Choose three.)

Correct selection
Google Cloud Platform

Private Virtual Cloud

Alibaba Cloud

Correct selection
Microsoft Azure Cloud

Oracle Cloud

Correct selection
Amazon Web Services

Overall explanation
We like easy questions in the exam!

Amazon Web Services, Microsoft Azure Cloud, and Google Cloud Platform.

For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
What are advantages clones have over tables created with CREATE TABLE AS SELECT statement? (Choose two.)

The clone has better query performance.

The clone will have time travel history from the original table.

Correct selection
The clone saves space by not duplicating storage.

Correct selection
The clone is created almost instantly.

The clone always stays in sync with the original table.

Overall explanation
Clones are created quickly because they don’t physically copy the data, and they share the same underlying data as the original table, so additional storage is only used when changes are made.

Question 55
Skipped
Assume there is a table consisting of five micro-partitions with values ranging from A to Z.

Which diagram indicates a well-clustered table?

A.



B.



C.



D.





Correct answer
A

D

C

B

Overall explanation
A well-clustered table in Snowflake has data that is ordered and organized efficiently within the micro-partitions. In diagram A, the data ranges (A-Z) are evenly distributed across the five micro-partitions, which helps with efficient querying. The ranges are compact and ordered, which is characteristic of good clustering.

Other diagrams show more scattered or overlapping data distributions, indicating less efficient clustering.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
Which of the following objects are contained within a schema? (Choose two.)

Share

Correct selection
External table

Correct selection
Stream

Warehouse

User

Overall explanation
The objects contained within a schema are Stream and External table. A Stream tracks changes to a table or view, while an External table references data stored outside Snowflake. Both are part of a schema, unlike objects such as Warehouse, User, and Share, which are not tied to schemas.

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
What is a fundamental characteristic of Snowflake micro-partitions?

They serve as an index for Snowflake tables.

They are sized based on Time Travel requirements.

They can be read directly as files.

Correct answer
Once established, they cannot be changed.

Overall explanation
Micro-partions are immutable.

For more detailed information, refer to the official Snowflake documentation.

Question 58
Skipped
Which privilege is required for a role to be able to resume a suspended warehouse if auto-resume is not enabled?

USAGE

MONITOR

Correct answer
OPERATE

MODIFY

Overall explanation
The OPERATE privilege allows a role to start, stop, suspend, and resume a virtual warehouse. Without this privilege, the role cannot manually resume a suspended warehouse.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
When an object is created in Snowflake, who owns the object?

The owner of the parent schema

The public role

Correct answer
The current active primary role

The user's default role

Overall explanation
When you create an object in Snowflake, the current role that is active in your session (specifically, your primary role if you have multiple roles active) becomes the owner of that object.

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
Which TABLE function helps to convert semi-structured data to a relational representation?

Correct answer
FLATTEN

PARSE_JSON

CHECK_JSON

TO_JSON

Overall explanation
The FLATTEN function in Snowflake is used to convert semi-structured data (such as JSON, Avro, or Parquet) into a relational format. It breaks down nested data into individual rows, allowing easier querying and integration into relational tables.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
What internal stages are available in Snowflake? (Choose three.)

Stream stage

Correct selection
Table stage

Correct selection
Named stage

Database stage

Correct selection
User stage

Schema stage

Overall explanation
Named stage, User stage, and Table stage.



For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
A virtual warehouse is created using the following command:

Create warehouse my_WH with -
warehouse_size = MEDIUM
min_cluster_count = 1
max_cluster_count = 1
auto_suspend = 60
auto_resume = true;
The image below is a graphical representation of the warehouse utilization across two days.



What action should be taken to address this situation?

Correct answer
Configure the warehouse to a multi-cluster warehouse.

Increase the value for the parameter MAX_CONCURRENCY_LEVEL.

Lower the value of the parameter STATEMENT_QUEUED_TIMEOUT_IN_SECONDS.

Increase the warehouse size from Medium to 2XL.

Overall explanation
The graph shows that there are times when queries are queued (orange bars), indicating that the warehouse is under-provisioned for the demand. Since the current setup has both min_cluster_count = 1 and max_cluster_count = 1, this means that the warehouse is not scaling to meet demand.

By configuring the warehouse as a multi-cluster warehouse, you can allow the system to automatically scale up the number of clusters to handle increased load (by increasing the max_cluster_count), reducing queuing during peak times. Increasing warehouse size or concurrency levels could help.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
Which of the following can be used when unloading data from Snowflake? (Choose two.)

Use the PARSE_JSON function to ensure structured data will be unloaded into the VARIANT data type.

Use the ENCODING file format option to change the encoding from the default UTF-8.

Correct selection
The OBJECT_CONSTRUCT function can be used to convert relational data to semi-structured data.

Correct selection
By using the SINGLE = TRUE parameter, a single file up to 5 GB in size can be exported to the storage layer.

When unloading semi-structured data, it is recommended that the STRIP_OUTER_ARRAY option be used.

Overall explanation
OBJECT_CONSTRUCT: This function allows you to convert relational data into semi-structured data, such as JSON, which is useful when unloading data from Snowflake.

SINGLE = TRUE: This parameter ensures that the data is unloaded into a single file, with a maximum size of 5 GB, when exporting to an external storage layer.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
Which activities are included in the Cloud Services layer? (Choose two.)

Query computation

Data storage

Correct selection
Security

Data visualization

Correct selection
Metadata management

Overall explanation
In Snowflake, the Cloud Services layer is responsible for key activities such as security, which includes access control, authentication, and encryption, and metadata management, which handles tracking data structures, query history, and managing the result cache.

For more detailed information, refer to the official Snowflake documentation.

Question 65
Skipped
A user has an application that writes a new file to a cloud storage location every 5 minutes.

What would be the MOST efficient way to get the files into Snowflake?

Create a task that PUTS the files in an internal stage and automate the data loading wizard.

Correct answer
Set up cloud provider notifications on the file location and use Snowpipe with auto-ingest.

Create a task that runs a COPY INTO operation from an external stage every 5 minutes.

Create a task that runs a GET operation to intermittently check for new files.

Overall explanation
Snowpipe with auto-ingest allows for real-time or near real-time loading of data as new files are added to a cloud storage location. By setting up cloud provider notifications, Snowflake can automatically trigger Snowpipe to load the data as soon as new files arrive, making the process seamless and efficient. This approach avoids the need for scheduling or manual intervention, optimizing the data loading process for frequent file uploads.

For more detailed information, refer to the official Snowflake documentation.

Question 66
Skipped
Which command line parameter value can be pre-specified as an environment variable in SnowSQL?

OPTION

Correct answer
HOST

MFA-PASSCODE

VARIABLE

Overall explanation
Currently, environment variables can only be used to pre-set certain command line parameters, such as password, host, and database. They are not available for SnowSQL variable substitution unless explicitly specified using either the -D or --variable connection parameter.

For more detailed information, refer to the official Snowflake documentation.

Question 67
Skipped
What is the impact of selecting one Snowflake edition over another? (Choose two.)

The edition will set a limit on the number of compute credits that can be consumed.

The edition will impact the total allowed storage space.

Correct selection
The edition will determine the unit costs for the compute credits.

Correct selection
The edition will impact the unit costs for storage.

The edition will impact which regions can be accessed by the accounts.

Overall explanation
The Snowflake Edition chosen by our organization determines the unit costs for credits and data storage. Other factors that influence these costs include the region of your Snowflake account and whether it is an On Demand or Capacity account.

For more detailed information, refer to the official Snowflake documentation.

Question 68
Skipped
What is the purpose of multi-cluster virtual warehouses?

Correct answer
To eliminate or reduce queuing of concurrent queries

To allow users the ability to choose the type of compute nodes that make up a virtual warehouse cluster

To create separate data warehouses to increase query optimization

To allow the warehouse to resize automatically

Overall explanation
Multi-cluster virtual warehouses in Snowflake automatically add or remove compute clusters based on the workload. This helps handle high levels of concurrent queries by distributing them across multiple clusters, reducing queuing and improving performance. The warehouse scales dynamically to meet demand and can also shrink when the workload decreases.

For more detailed information, refer to the official Snowflake documentation.

Question 69
Skipped
A marketing co-worker has requested the ability to change a warehouse size on their medium virtual warehouse called MKTG_WH.

Which of the following statements will accommodate this request?

GRANT OPERATE ON WAREHOUSE MKTG_WH TO ROLE MARKET;

ALLOW RESIZE ON WAREHOUSE MKTG_WH TO USER MKTG_LEAD;

Correct answer
GRANT MODIFY ON WAREHOUSE MKTG_WH TO ROLE MARKETING;

GRANT MODIFY ON WAREHOUSE MKTG_WH TO USER MKTG_LEAD;

Overall explanation
The MODIFY privilege allows a user to alter the properties of a warehouse, including resizing it. Privileges are granted to roles.

For more detailed information, refer to the official Snowflake documentation.

Question 70
Skipped
What can be shared when the SECURE_OBJECTS_ONLY property is set to = FALSE?

Storage integration access

Correct answer
A view

A User-Defined Function (UDF)

A stored procedure

Overall explanation
By default, a share can include only secure objects. This restriction applies particularly to views, which must normally be defined as SECURE to be added to a share.

If a share is created or modified with SECURE_OBJECTS_ONLY = FALSE, it becomes eligible to include non-secure (regular) views. This setting must be explicitly defined at share creation time or applied through a replacement operation. Shares that retain the default configuration cannot include non-secure views.

This parameter affects view eligibility only. Stored procedures and user-defined functions must still be created as secure objects to be shared. The setting does not apply to storage integrations or other external access constructs, which are not governed by the share object configuration.

For more detailed information, refer to the official Snowflake documentation.

Question 71
Skipped
Which of the following conditions must be met in order to return results from the results cache? (Choose two.)

The new query is run using the same virtual warehouse as the previous query.

The query includes a User Defined Function (UDF).

Correct selection
The query has been run within 24 hours of the previously-run query.

Micro-partitions have been reclustered since the query was last run.

Correct selection
The user has the appropriate privileges on the objects associated with the query.

Overall explanation
To access cached results, the user must have the necessary privileges on the tables or objects involved in the query. Snowflake’s results cache is valid for 24 hours, so the query must be run within this time frame to return cached results.

For more detailed information, refer to the official Snowflake documentation.

Question 72
Skipped
What feature can be used to reorganize a very large table on one or more columns?

Clustered partitions

Key partitions

Correct answer
Clustering keys

Micro-partitions

Overall explanation
Clustering keys in Snowflake are used to optimize the physical layout of data in large tables. By specifying one or more columns as clustering keys, Snowflake reorganizes the data within micro-partitions based on these columns. This improves query performance by making data retrieval more efficient, particularly for large tables where filtering or sorting on the clustered columns is common.

For more detailed information, refer to the official Snowflake documentation.

Question 73
Skipped
Which transformation is supported by a COPY INTO [table] command?

Order using an ORDER BY Clause

Correct answer
Cast using a SELECT statement

Filter using a LIMIT keyword

Filter using a WHERE clause

Overall explanation
The COPY INTO [table] command supports transformations using a SELECT statement with casting, allowing data types to be adjusted during the load process.

For more detailed information, refer to the official Snowflake documentation.

Question 74
Skipped
What happens when a Data Provider revokes privileges to a share on an object in their source database?

The Data Consumers stop seeing data updates and become responsible for storage charges for the object.

A static copy of the object at the time the privilege was revoked is created in the Data Consumers account.

Any additional data arriving after this point in time will not be visible to Data Consumers.

Correct answer
The object immediately becomes unavailable for all Data Consumers.

Overall explanation
Revoking privileges on a shared object means that Data Consumers lose access to the shared data immediately. The Data Consumers no longer see the shared data or receive updates from it, and no static copy is made. The data is controlled by the Data Provider, and once access is revoked, it is no longer visible to the consumers.

For more detailed information, refer to the official Snowflake documentation.

Question 75
Skipped
What is a key difference between the Snowflake CLI and SnowSQL?

Snowflake CLI only supports query execution, while SnowSQL manages Python packages.

Correct answer
Snowflake CLI is primarily used for managing workloads and applications, while SnowSQL is used for executing operations.

SnowSQL supports only Data Definition Language (DDL) operations, while Snowflake CLI supports only Data Manipulation Language (DML) operations.

SnowSQL is used for managing workloads and applications, while Snowflake CLI executes queries.

Overall explanation
SnowSQL and the Snowflake CLI address different layers of interaction within the Snowflake platform.

SnowSQL is a SQL-centric command-line client. It is used for executing queries, running DDL/DML statements, managing database objects, and performing data load/unload operations. Its scope is primarily operational and database-oriented, supporting traditional SQL workflows.

The Snowflake CLI, by contrast, is designed for developer workflows. It focuses on building, packaging, deploying, and managing Snowflake-integrated applications and services. Typical use cases include working with Streamlit in Snowflake, the Native App Framework, Snowpark projects, and Snowpark Container Services. Its emphasis is on application lifecycle management rather than routine SQL execution.

In summary, SnowSQL targets database administration and SQL interaction, while the Snowflake CLI supports development and deployment of Snowflake-based applications.

For more detailed information, refer to the official Snowflake documentation.

Question 76
Skipped
User INQUISITIVE_PERSON has been granted the role DATA_SCIENCE. The role DATA_SCIENCE has privileges OWNERSHIP on the schema MARKETING of the database ANALYTICS_DW.

Which command will show all privileges granted to that schema?

SHOW GRANTS TO USER INQUISITIVE_PERSON

Correct answer
SHOW GRANTS ON SCHEMA ANALYTICS_DW.MARKETING

SHOW GRANTS ON ROLE DATA_SCIENCE

SHOW GRANTS OF ROLE DATA_SCIENCE

Overall explanation
This command will display all the privileges that have been granted on the specified schema.

For more detailed information, refer to the official Snowflake documentation.

Question 77
Skipped
Which roles can make grant decisions to objects within a managed access schema? (Choose two.)

Correct selection
ACCOUNTADMIN

Correct selection
SECURITYADMIN

SYSADMIN

USERADMIN

ORGADMIN

Overall explanation
In a managed access schema, the ACCOUNTADMIN and SECURITYADMIN roles have the authority to make grant decisions, as they have elevated privileges for managing access across objects within the schema.

For more detailed information, refer to the official Snowflake documentation.

Question 78
Skipped
Which strings will be converted to TRUE using the TO_BOOLEAN() or CAST() functions when unloading data? (Choose two.)

Correct selection
on

0

no

Correct selection
yes

n

Overall explanation
The TO_BOOLEAN() and CAST() functions interpret certain string values as TRUE, including "on" and "yes" (case-insensitive). Other values like "0", "n", and "no" are interpreted as FALSE or result in NULL.

For more detailed information, refer to the official Snowflake documentation.

Question 79
Skipped
A materialized view should be created when which of the following occurs? (Choose two.)

Correct selection
The query consumes many compute resources every time it runs.

Correct selection
The results of the query do not change often and are used frequently.

The query is highly optimized and does not consume many compute resources.

The base table gets updated frequently.

There is minimal cost associated with running the query.

Overall explanation
A materialized view is beneficial when a query is resource-intensive and repeatedly run. Storing the results in a materialized view avoids re-executing the query each time, saving compute resources.

If the query results are relatively static (don't change often) and are accessed frequently, a materialized view can improve performance by providing precomputed results, reducing the need to rerun complex queries.

Frequent updates to the base table can increase the maintenance cost of the materialized view, making it less efficient in such scenarios.

For more detailed information, refer to the official Snowflake documentation.

Question 80
Skipped
Which of the following are considerations when using a directory table when working with unstructured data? (Choose two.)

Correct selection
Directory tables do not have their own grantable privileges.

Correct selection
Directory tables store data file metadata.

A directory table will be automatically added to a stage.

A directory table is a separate database object.

Directory table data can not be refreshed manually.

Overall explanation
Directory tables store metadata about files, such as file paths, and they inherit privileges from the associated stage rather than having their own specific privileges.

For more detailed information, refer to the official Snowflake documentation.

Question 81
Skipped
If a Snowflake user decides a table should be clustered, what should be used as the cluster key?

The columns with many different values.

The columns that are queried in the select clause.

Correct answer
The columns most actively used in the select filters.

The columns with very high cardinality.

Overall explanation
The cluster key should be chosen based on the columns that are frequently used in the WHERE clause or as filters in queries, order or joins.

For more detailed information, refer to the official Snowflake documentation.

Question 82
Skipped
How long does Snowflake retain information in the ACCESS_HISTORY view?

7 days

Correct answer
365 days

28 days

14 days

Overall explanation
The ACCESS_HISTORY view in the ACCOUNT_USAGE schema retains information for 365 days (1 year).

For more detailed information, refer to the official Snowflake documentation.

Question 83
Skipped
Credit charges for Snowflake virtual warehouses are calculated based on which of the following considerations? (Choose two.)

The number of queries executed

The number of active users assigned to the warehouse

Correct selection
The size of the virtual warehouse

The duration of the queries that are executed

Correct selection
The length of time the warehouse is running

Overall explanation
Credit charges for Snowflake virtual warehouses are calculated based on the size of the virtual warehouse and the length of time the warehouse is running. Larger warehouses consume more credits due to their higher compute resource allocation, and charges are based on how long the warehouse is active, with billing done per second of usage.

For more detailed information, refer to the official Snowflake documentation.

Question 84
Skipped
What is a feature of a stored procedure in Snowflake?

They can be created as secure and hide the underlying metadata from all users.

They can access tables from a single database.

Correct answer
They can be created to run with a caller's rights or an owner's rights.

They can only contain a single SQL statement.

Overall explanation
Snowflake stored procedures can be configured to execute with either the permissions of the caller (the user executing the procedure) or the owner (the creator or definer of the procedure). This provides flexibility in controlling access to underlying resources. Other options, like accessing tables from multiple databases or containing multiple SQL statements, are possible with stored procedures, but the ability to define execution rights is a distinct feature.

For more detailed information, refer to the official Snowflake documentation.

Question 85
Skipped
What effect does WAIT_FOR_COMPLETION = TRUE have when running an ALTER WAREHOUSE command and changing the warehouse size?

The warehouse size does not change until all queries currently running in the warehouse have completed.

The warehouse size does not change until all queries currently in the warehouse queue have completed.

Correct answer
It does not return from the command until the warehouse has finished changing its size.

The warehouse size does not change until the warehouse is suspended and restarted.

Overall explanation
When WAIT_FOR_COMPLETION = TRUE is set, the command will wait and not return until the process of resizing the warehouse is fully completed. This ensures that any subsequent queries will be executed after the warehouse has been resized. It does not require the warehouse to suspend or wait for queries to complete before resizing.

For more detailed information, refer to the official Snowflake documentation.

Question 86
Skipped
If a query is being used to unload a 1 TB table into a stage, which DML operator will be shown in the Query Profile?

Correct answer
COPY

UNLOAD

UPDATE

INSERT

Overall explanation
The COPY INTO <location> command is used in Snowflake for unloading data from a table into a stage.

For more detailed information, refer to the official Snowflake documentation.

Question 87
Skipped
While attempting to avoid data duplication, which COPY INTO option should be used to load files with expired load metadata?

FORCE

LAST_MODIFIED

Correct answer
LOAD_UNCERTAIN_FILES

VALIDATION_MODE

Overall explanation
The LOAD_UNCERTAIN_FILES option in the COPY INTO command is used when loading files with expired load metadata. It helps avoid data duplication by allowing the loading of files even if their metadata is no longer tracked.

For more detailed information, refer to the official Snowflake documentation.

Question 88
Skipped
When unloading Snowflake relational data to a Parquet file format, why should the PARTITION BY clause be used?

It will provide a mechanism to encrypt each micro-partition with a unique key.

It will increase storage efficiency by automatically compressing data based on access patterns.

It will guarantee data integrity by splitting the data into smaller, manageable chunks.

Correct answer
It will optimize query performance by filtering relevant partitions without scanning the entire dataset.

Overall explanation
When unloading Snowflake relational data to a Parquet file format, the PARTITION BY clause should be used because it will optimize query performance by filtering relevant partitions without scanning the entire dataset.

This is achieved through the physical organization of the unloaded files in the external stage (e.g., S3). When data is unloaded with PARTITION BY, it creates a directory structure where data is grouped into subfolders based on the values of the partitioning columns.

For more detailed information, refer to the official Snowflake documentation.

Question 89
Skipped
A size 3X-Large multi-cluster warehouse runs one cluster for one full hour and then runs two clusters for the next full hour.

What would be the total number of credits billed?

128

Correct answer
192

149

64

Overall explanation
64 + 128



For more detailed information, refer to the official Snowflake documentation.

Question 90
Skipped
When will Snowflake charge credits for the use of the Cloud Services layer?

Correct answer
Credits will be charged when the daily consumption of cloud services resources exceeds 10% of the daily warehouse usage.

Credits will be charged only when running a Snowflake-provisioned compute warehouse COMPUTE_WH.

Credits will be charged whenever the Cloud Services layer is used.

Credits will be charged only when a virtual warehouse consumes serverless compute services.

Overall explanation
Cloud services usage is only charged when it exceeds 10% of the daily virtual warehouse usage, with the calculation done daily in UTC to ensure the 10% adjustment is applied accurately at that day's credit price.

For more detailed information, refer to the official Snowflake documentation.

Question 91
Skipped
Which of the following practices are recommended when creating a user in Snowflake? (Choose two.)

Configure the user to be initially disabled.

Set the number of minutes to unlock to 15 minutes.

Correct selection
Force an immediate password change.

Correct selection
Set a default role for the user.

Set the user's access to expire within a specified timeframe.

Overall explanation
Forcing a password change ensures the user sets a secure, private password on their first login, and assigning a default role automatically applies the appropriate permissions, simplifying access control.

For more detailed information, refer to the official Snowflake documentation.

Question 92
Skipped
How is role hierarchy established in Snowflake?

By default when a role is created

By transferring ownership of one role to another role

By assigning users to roles

Correct answer
By granting one role to another role

Overall explanation
In Snowflake, role hierarchy is established by granting one role to another, allowing the higher-level role to inherit the privileges of the granted role, creating a layered access structure.

For more detailed information, refer to the official Snowflake documentation.

Question 93
Skipped
Which encryption type will enable client-side encryption for a directory table?

AWS_CSE

AES

Correct answer
SNOWFLAKE_FULL

SNOWFLAKE_SSE

Overall explanation
SNOWFLAKE_FULL, both client-side and server-side encryption are utilized. Files are encrypted on the client side when they are uploaded to the internal stage via the PUT command. Additionally, server-side encryption is applied, providing an extra layer of security during file storage.

For more detailed information, refer to the official Snowflake documentation.

Question 94
Skipped
What is the default character set used when loading CSV files into Snowflake?

ANSI_X3.4

ISO 8859-1

Correct answer
UTF-8

UTF-16

Overall explanation
Snowflake uses UTF-8 as the default encoding for loading data, including CSV files. This encoding is widely supported and can handle a broad range of characters, making it ideal for data ingestion.

For more detailed information, refer to the official Snowflake documentation.

Question 95
Skipped
What file formats does Snowflake support for loading semi-structured data? (Choose three.)

TSV

Correct selection
Parquet

JPEG

Correct selection
JSON

Correct selection
Avro

PDF

Overall explanation
Common question. JSON, Avro, and Parquet.



For more detailed information, refer to the official Snowflake documentation.

Question 96
Skipped
Which function generates a Snowflake hosted file URL to a staged file using the stage name and relative file path as inputs?

GET_ABSOLUTE_PATH

Correct answer
BUILD_STAGE_FILE_URL

GET_RELATIVE_PATH

GET_STAGE_LOCATION

Overall explanation
BUILD_STAGE_FILE_URL function generates a Snowflake-hosted file URL to a staged file by using the stage name and the relative file path as inputs.

For more detailed information, refer to the official Snowflake documentation.

Question 97
Skipped
Which key governance feature in Snowflake allows users to identify automatically data objects that contain sensitive data and their related objects?

Column-level security

Row access policy

Correct answer
Data classification

Object tagging

Overall explanation
Data classification is the key governance feature that allows users to automatically identify data objects that contain sensitive information and their related objects. This feature helps classify data based on its sensitivity and supports compliance with data privacy regulations. It allows for better management and governance of sensitive data across the platform​

For more detailed information, refer to the official Snowflake documentation.

Question 98
Skipped
What is the effect of configuring a virtual warehouse auto-suspend value to ‘0’?

Correct answer
The warehouse will never suspend.

All clusters in the multi-cluster warehouse will resume immediately.

The warehouse will suspend immediately upon work completion.

The warehouse will not resume automatically.

Overall explanation
Configuring a virtual warehouse auto-suspend value to 0 in Snowflake means the warehouse will never automatically suspend. This setting disables the auto-suspend feature, keeping the warehouse running indefinitely unless it is manually suspended, which can lead to higher costs.

For more detailed information, refer to the official Snowflake documentation.

Question 99
Skipped
What is the default file size when unloading data from Snowflake using the COPY command?

5 MB

8 GB

32 MB

Correct answer
16 MB

Overall explanation
COPY INTO location statements split table data into multiple output files to leverage parallel processing. The maximum size of each file can be controlled using the MAX_FILE_SIZE copy option. The default size is 16 MB (16777216 bytes), but this value can be increased to support larger file sizes if needed.

For more detailed information, refer to the official Snowflake documentation.

Question 100
Skipped
What happens to the underlying table data when a CLUSTER BY clause is added to a Snowflake table?

Smaller micro-partitions are created for common data values to allow for more parallelism

Data is hashed by the cluster key to facilitate fast searches for common data values

Larger micro-partitions are created for common data values to reduce the number of partitions that must be scanned

Correct answer
Data may be collocated by the cluster key within the micro-partitions to improve pruning performance

Overall explanation
The CLUSTER BY clause in Snowflake reorganizes the table data based on the specified cluster key(s). This helps Snowflake to improve pruning, meaning it can more efficiently eliminate micro-partitions that don’t need to be scanned when executing queries, thus improving performance.

For more detailed information, refer to the official Snowflake documentation.

Question 101
Skipped
What features that are part of the Continuous Data Protection (CDP) feature set in Snowflake do not require additional configuration? (Choose two.)

Data masking policies

External tokenization

Row level access policies

Correct selection
Data encryption

Correct selection
Time Travel

Overall explanation
Data encryption is automatically applied by Snowflake for all data stored within the platform, providing protection without the need for manual setup. Time Travel is also enabled by default, allowing users to access historical data for a certain period without needing additional configuration (only data retention days).

For more detailed information, refer to the official Snowflake documentation.

Question 102
Skipped
A user is preparing to load data from an external stage.

Which practice will provide the MOST efficient loading performance?

Use pattern matching for regular expression execution

Correct answer
Organize files into logical paths

Store the files on the external stage to ensure caching is maintained

Load the data in one large file

Overall explanation
Organizing files into logical paths helps Snowflake process data more efficiently, especially when dealing with large datasets. It allows Snowflake to parallelize loading operations by splitting the data into multiple smaller files, which can then be processed concurrently. Loading data from one large file can slow down the process, as Snowflake's architecture is optimized for handling multiple files.

For more detailed information, refer to the official Snowflake documentation.

Question 103
Skipped
Which SQL command can be used to see the CREATE definition of a masking policy?

LIST MASKING POLICIES

DESCRIBE MASKING POLICY

Correct answer
GET_DDL

SHOW MASKING POLICIES

Overall explanation
GET_DDL function in Snowflake can be used to retrieve the DDL (Data Definition Language) statement for an object, including masking policies. You can use it to get the exact CREATE definition of a masking policy.

For more detailed information, refer to the official Snowflake documentation.

Question 104
Skipped
A Snowflake Administrator needs to ensure that sensitive corporate data in Snowflake tables is not visible to end users, but is partially visible to functional managers.

How can this requirement be met?

Use secure materialized views.

Use data encryption.

Revoke all roles for functional managers and end users.

Correct answer
Use dynamic data masking.

Overall explanation
Dynamic data masking allows Snowflake to mask sensitive data at query time based on the user's role or privileges. This way, sensitive corporate data can be hidden from end users while being partially visible to functional managers based on their roles. This feature ensures that only authorized users see the unmasked data, while others see either partially or fully masked data.



For more detailed information, refer to the official Snowflake documentation.

Question 105
Skipped
Which of the following statements describes a schema in Snowflake?

A named Snowflake object that includes all the information required to share a database

A uniquely identified Snowflake account within a business entity

A logical grouping of objects that belongs to multiple databases

Correct answer
A logical grouping of objects that belongs to a single database

Overall explanation
We like easy questions. A schema is a container within a database that organizes and groups related objects such as tables, views, and functions.

For more detailed information, refer to the official Snowflake documentation.

Question 106
Skipped
Which of the following statements about data sharing are true? (Choose two.)

All database objects can be included in a shared database.

Correct selection
Reader Accounts are created by Data Providers.

New objects created by a Data Provider are automatically shared with existing Data Consumers and Reader Accounts.

Correct selection
Shared databases are read-only.

Reader Accounts are charged for warehouse usage.

Overall explanation
Data Providers create Reader Accounts for consumers without Snowflake accounts, allowing them to access shared data. Additionally, shared databases are read-only.

For more detailed information, refer to the official Snowflake documentation.

Question 107
Skipped
Which stage type can be altered and dropped?

Table stage

Database stage

Correct answer
External stage

User stage

Overall explanation
External stage is a named stage created explicitly to reference external cloud storage, such as AWS S3, Azure Blob Storage, or Google Cloud Storage. Since it is explicitly created, it can also be altered and dropped.

For more detailed information, refer to the official Snowflake documentation.

Question 108
Skipped
What are the default Time Travel and Fail-safe retention periods for transient tables?

Time Travel - 1 day, Fail-safe - 1 day

Transient tables are retained in neither Fail-safe nor Time Travel.

Time Travel - 0 days, Fail-safe - 1 day

Correct answer
Time Travel - 1 day, Failsafe - 0 days

Overall explanation
Transient tables in Snowflake have a default Time Travel retention period of 1 day, but they are not protected by Fail-safe (0 days).



For more detailed information, refer to the official Snowflake documentation.

Question 109
Skipped
What is the recommended compressed file size range for continuous data loads using Snowpipe?

Correct answer
100-250 MB

10-99 MB

16-24 MB

8-16 MB

Overall explanation
Snowflake recommends using compressed file sizes in the range of 100-250 MB for optimal performance when using Snowpipe. This file size range ensures that Snowpipe can efficiently handle the loading process by leveraging parallelism and minimizing overhead (overhead costs are important when managing a lot of smaller files).

For more detailed information, refer to the official Snowflake documentation.

Question 110
Skipped
How would a user run a multi-cluster warehouse in maximized mode?

Set the minimum clusters and maximum clusters settings to different values.

Correct answer
Set the minimum Clusters and maximum Clusters settings to the same value.

Turn on the additional clusters manually after starting the warehouse.

Configure the maximum clusters setting to "Maximum."

Overall explanation
When the minimum and maximum clusters are set to the same value, the warehouse will always run with the maximum number of clusters, ensuring it operates in maximized mode.

For more detailed information, refer to the official Snowflake documentation.

Question 111
Skipped
What does the Monitoring area of Snowsight allow users to do? (Choose two.)

Create and manage user roles and permissions.

Access Snowflake Marketplace to find and integrate datasets.

Correct selection
Explore each step of an executed query.

Schedule automated data backups.

Correct selection
Monitor queries executed by users in an account.

Overall explanation
The Monitoring area of Snowsight enables users to delve into the details of each step of an executed query, providing insights into its performance and execution plan. Additionally, it allows users to monitor the queries executed by users across the account, helping in performance tracking and auditing.

For more detailed information, refer to the official Snowflake documentation.

Question 112
Skipped
Which statement about billing applies to Snowflake credits?

Credits are billed per-minute with a 60-minute minimum.

Credits are consumed based on the number of credits billed for each hour that a warehouse runs.

Credits are used to pay for cloud data storage usage.

Correct answer
Credits are consumed based on the warehouse size and the time the warehouse is running.

Overall explanation
Snowflake credits are consumed based on the size of the virtual warehouse (compute resources) and the amount of time the warehouse is active. Snowflake uses per-second billing, so you only pay for the exact time the warehouse runs (1 minute minimum billing), and larger warehouses consume more credits per unit of time than smaller ones.

For more detailed information, refer to the official Snowflake documentation.

Question 113
Skipped
Which commands are restricted in owner's rights stored procedures? (Choose two.)

INSERT

MERGE

Correct selection
DESCRIBE

Correct selection
SHOW

DELETE

Overall explanation
In owner's rights stored procedures, commands like SHOW and DESCRIBE are restricted due to their ability to reveal metadata, which may require additional privileges not granted to the procedure owner.

For more detailed information, refer to the official Snowflake documentation.

Question 114
Skipped
What does the “percentage scanned from cache” represent in the Query Profile?

The percentage of data scanned from the remote disk cache

Correct answer
The percentage of data scanned from the local disk cache

The percentage of data scanned from the query cache

The percentage of data scanned from the result cache

Overall explanation
The "percentage scanned from cache" represents the portion of data that was read from the local disk cache on the virtual warehouse rather than from remote storage or freshly loaded into memory.

For more detailed information, refer to the official Snowflake documentation.

Question 115
Skipped
Which of the following is an example of an operation that can be completed without requiring compute, assuming no queries have been executed previously?

SELECT ORDER_AMT * ORDER_QTY FROM SALES;

SELECT SUM (ORDER_AMT) FROM SALES;

Correct answer
SELECT MIN(ORDER_AMT) FROM SALES;

SELECT AVG(ORDER_QTY) FROM SALES;

Overall explanation
Average and Sum functions will need compute while min function can execute from cloud services layer (metadata operations)

Question 116
Skipped
A Snowflake user wants to design a series of transformations that need to be executed in a specific order, on a given schedule.



What Snowflake objects should be used?

Correct answer
Tasks

Sequences

Pipes

Streams

Overall explanation
A task object executes a SQL statement, which can include calls to stored procedures. Tasks can be scheduled or triggered based on events you define, such as the arrival of data. We can chain tasks together using task graphs, defining DAGs.

For more detailed information, refer to the official Snowflake documentation.

Question 117
Skipped
Which minimum Snowflake edition allows for a dedicated metadata store?

Standard

Business Critical

Correct answer
Virtual Private Snowflake

Enterprise

Overall explanation
Dedicated metadata store and pool of compute resources (used in virtual warehouses) is offered through VPS.

For more detailed information, refer to the official Snowflake documentation.

Question 118
Skipped
A user needs to create a materialized view in the schema MYDB.MYSCHEMA.

Which statements will provide this access?

GRANT ROLE MYROLE TO USER USER1;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA MYDB.MYSCHEMA TO USER USER1;
GRANT ROLE MYROLE TO USER USER1;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA MYDB.MYSCHEMA ON ROLE MYROLE;
GRANT ROLE MYROLE TO USER USER1;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA MYDB.MYSCHEMA TO USER1;
Correct answer
GRANT ROLE MYROLE TO USER USER1;
GRANT CREATE MATERIALIZED VIEW ON SCHEMA MYDB.MYSCHEMA TO ROLE MYROLE;
Overall explanation
Key: privileges must be granted to roles. We grant a role to a user, and then grant privileges to the role.

To grant a user the ability to create a materialized view in a specific schema, the following steps are required: First, the MYROLE role is assigned to the USER1 user using the statement GRANT ROLE MYROLE TO USER USER1;. Then, the CREATE MATERIALIZED VIEW privilege on the MYDB.MYSCHEMA schema is granted to the MYROLE role with the statement GRANT CREATE MATERIALIZED VIEW ON SCHEMA MYDB.MYSCHEMA TO ROLE MYROLE;. This way, USER1 inherits the permissions of the MYROLE role and can create materialized views in the designated schema.

For more detailed information, refer to the official Snowflake documentation.

Question 119
Skipped
Network policies can be set at which Snowflake levels? (Choose two.)

Database

Schema

Correct selection
Account

Correct selection
User

Role

Overall explanation
Network policies can be set at the User and Account levels in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 120
Skipped
Which query profile statistics help determine if efficient pruning is occurring? (Choose two.)

Correct selection
Partitions scanned

Bytes spilled to local storage

Correct selection
Partitions total

Bytes sent over network

Percentage scanned from cache

Overall explanation
Partitions total shows the total number of micro-partitions that could be scanned, and Partitions scanned indicates how many of those were actually scanned during the query. Efficient pruning occurs when the number of partitions scanned is significantly lower than the total available, minimizing the amount of data processed.

For more detailed information, refer to the official Snowflake documentation.

Question 121
Skipped
Which metrics in the QUERY_HISTORY Account _Usage View can be used to assess the pruning efficiency of a query? (Choose two.)

Correct selection
PARTITIONS_SCANNED

COMPILATION_TIME

TOTAL_ELAPSED_TIME

Correct selection
PARTITIONS_TOTAL

EXECUTION_TIME

Overall explanation
partitions_scanned: number of micro-partitions scanned.

partitions_total: Total micro-partitions of all tables included in this query.

Pruning efficiency is high when PARTITIONS_SCANNED is significantly lower than PARTITIONS_TOTAL, meaning the query engine was able to eliminate many unnecessary micro-partitions from being scanned.

For more detailed information, refer to the official Snowflake documentation.

Question 122
Skipped
A network policy set at which level will override all other network policies?

Security integration

Account

Correct answer
User

Database

Overall explanation
We can apply a network policy to an account, a security integration, or a user. When multiple policies are in place, the most specific one—usually the one applied directly to the user—overrides the more general ones set at the account or integration level.

The most specific network policies are the ones we apply directly to a user; these take precedence over policies set at the account or security integration level.

For more detailed information, refer to the official Snowflake documentation.

Question 123
Skipped
Which of the following are handled by the cloud services layer of the Snowflake architecture? (Choose two.)

Data loading

Correct selection
Authentication and access control

Query execution

Time Travel data

Correct selection
Security

Overall explanation
The cloud services layer of the Snowflake architecture handles Security and Authentication and access control among others.

For more detailed information, refer to the official Snowflake documentation.

Question 124
Skipped
How should a data provider securely share Snowflake objects with a data consumer who does not have a Snowflake account?

Give the consumer owner's rights on the provider's Snowflake account.

Unload the data into the consumer's cloud storage.

Correct answer
Create a reader account for the consumer.

Create and replicate a share, then give the consumer access to the replication.

Overall explanation
A Snowflake reader account allows data providers to share data with consumers who don't have their own Snowflake accounts. This enables those consumers to query and analyze the data without needing to set up a full Snowflake account. It's a cost-effective and convenient way to share data with external users.

For more detailed information, refer to the official Snowflake documentation.

Question 125
Skipped
Which statements reflect key functionalities of a Snowflake Data Exchange? (Choose two.)

Data Exchange functionality is available by default in accounts using the Enterprise edition or higher.

If an account is enrolled with a Data Exchange, it will lose its access to the Snowflake Marketplace.

A Data Exchange allows accounts to share data with third, non-Snowflake parties.

Correct selection
The sharing of data in a Data Exchange is bidirectional. An account can be a provider for some datasets and a consumer for others.

Correct selection
A Data Exchange allows groups of accounts to share data privately among the accounts.

Overall explanation
A Snowflake Data Exchange enables groups of Snowflake accounts to share data privately with one another, fostering collaboration within a trusted group.

In a Data Exchange, an account can act as both a data provider and a data consumer, meaning it can share its datasets while also consuming data from others within the exchange.

For more detailed information, refer to the official Snowflake documentation.

Question 126
Skipped
Which of the following commands cannot be used within a reader account?

Correct answer
CREATE SHARE

ALTER WAREHOUSE

SHOW SCHEMAS

DROP ROLE

Overall explanation
A reader account is a special type of Snowflake account created by data providers to allow consumers without their own Snowflake accounts to access shared data. Reader accounts are limited in terms of functionality, and CREATE SHARE is not allowed because reader accounts cannot create or manage shares.

For more detailed information, refer to the official Snowflake documentation.

Question 127
Skipped
A table named car_sales contains a single VARIANT column named src.



Below is the output of the query SELECT * FROM car_sales;







Which queries will return the element "phone number" from the data? (Choose two.)

Correct selection
SELECT src:customer."phone number" FROM car_sales;
Correct selection
SELECT SRC:customer."phone number" FROM car_sales;
SELECT SRC:customer.phone number FROM car_sales;
SELECT src:customer.’phone number’ FROM car_sales;
SELECT SRC:CUSTOMER."phone number" FROM car_sales;
Overall explanation
The correct syntax for accessing the "phone number" element in a VARIANT column is by referencing the exact field name with double quotes due to the space in the name. Both of these queries correctly access the "phone number" field.

For more detailed information, refer to the official Snowflake documentation.

Question 128
Skipped
Which columns are part of the result set of the Snowflake LATERAL FLATTEN command? (Choose two.)

CONTENT

Correct selection
INDEX

DATATYPE

BYTE_SIZE

Correct selection
PATH

Overall explanation
PATH column shows the path to the element within the input object or array that has been flattened.

INDEX column indicates the index position of the element within the flattened array.

For more detailed information, refer to the official Snowflake documentation.

Question 129
Skipped
Why does Snowflake recommend file sizes of 100-250 MB compressed when loading data?

Allows a user to import the files in a sequential order

Increases the latency staging and accuracy when loading the data

Optimizes the virtual warehouse size and multi-cluster setting to economy mode

Correct answer
Allows optimization of parallel operations

Overall explanation
Smaller file sizes can result in underutilization of resources, while much larger files may not benefit from parallel processing as effectively.

For more detailed information, refer to the official Snowflake documentation.

Question 130
Skipped
Which statements are true of micro-partitions? (Choose two.)

Correct selection
They are immutable

They are stored compressed only if COMPRESS=TRUE on Table

Correct selection
They are approximately 50-500MB size uncompressed

They are only encrypted in the Enterprise edition and above

They are only encrypted in the Business Critical edition and above

Overall explanation
Micro-partitions in Snowflake are immutable, meaning once created, they cannot be modified. They are also approximately 50-500MB in size uncompressed, optimized for performance and efficient storage. Micro-partitions are always encrypted, regardless of the Snowflake edition, making the encryption-related options incorrect.

For more detailed information, refer to the official Snowflake documentation.

Question 131
Skipped
How do secure views compare to non-secure views in Snowflake?

Correct answer
Secure views execute more slowly compared to non-secure views.

Secure views are similar to materialized views in that they are the most performant.

Non-secure views are preferred over secure views when sharing data.

There are no performance differences between secure and non-secure views.

Overall explanation
Secure views are not suitable for views created solely for query convenience, like those designed to simplify queries where users do not need to comprehend the underlying data structure. Secure views may run more slowly than non-secure views.

For more detailed information, refer to the official Snowflake documentation.

Question 132
Skipped
Why should a Snowflake user implement a secure view? (Choose two.)

Correct selection
To limit access to sensitive data

To store unstructured data

To increase query performance

To optimize query concurrency and queuing

Correct selection
To hide view definition and details from unauthorized users

Overall explanation
A Snowflake user should implement a secure view to limit access to sensitive data, ensuring that only authorized users can see the results of the view without exposing the underlying data. Additionally, secure views hide the view definition and details from unauthorized users, preventing them from seeing the logic behind the query.

For more detailed information, refer to the official Snowflake documentation.

Question 133
Skipped
A company needs to read multiple terabytes of data for an initial load as part of a Snowflake migration. The company can control the number and size of CSV extract files.

How does Snowflake recommend maximizing the load performance?

Use auto-ingest Snowpipes to load large files in a serverless model.

Correct answer
Produce a larger number of smaller files and process the ingestion with size Small virtual warehouses.

Use an external tool to issue batched row-by-row inserts within BEGIN TRANSACTION and COMMIT commands.

Produce the largest files possible, reducing the overall number of files to process.

Overall explanation
For optimal performance during data loads, Snowflake suggests using multiple small to medium-sized files (typically around 100-250 MB compressed). This allows Snowflake to take advantage of parallel processing across multiple files, speeding up the load. Larger files can result in slower loads, as Snowflake’s architecture is designed to process many files concurrently.

For more detailed information, refer to the official Snowflake documentation.

Question 134
Skipped
What affects whether the query results cache can be used?

Correct answer
If the referenced data in the table has changed

If the virtual warehouse has been suspended

If multiple users are using the same virtual warehouse

If the query contains a deterministic function

Overall explanation
If the data in a table referenced by the query has been modified, Snowflake will invalidate the cached results to ensure that any subsequent queries reflect the most up-to-date data.

For more detailed information, refer to the official Snowflake documentation.

Question 135
Skipped
A Snowflake user wants to share unstructured data through the use of secure views.

Which URL types can be used? (Choose two.)

Correct selection
Pre-signed URL

Correct selection
Scoped URL

HTTPS URL

File URL

Cloud storage URL

Overall explanation
Scoped URL and Pre-signed URL.

For more detailed information, refer to the official Snowflake documentation.

Question 136
Skipped
Which type of join will list all rows in the specified table, even if those rows have no match in the other table?

Correct answer
Outer join

Inner join

Cross join

Natural join

Overall explanation
An outer join will return all rows from the specified table, even if there are no matching rows in the other table. It ensures that unmatched rows are included, typically filling in NULL values for columns from the other table where no match is found.

For more detailed information, refer to the official Snowflake documentation.

Question 137
Skipped
Where would a Snowflake user find information about query activity from 90 days ago?

Correct answer
account_usage.query_history view

account_usage.query_history_archive view

information_schema.query_history_by_session view

information_schema.query_history view

Overall explanation
The account_usage.query_history view retains query activity information for up to 1 year (365 days), making it the best option for retrieving query details from 90 days ago.

For more detailed information, refer to the official Snowflake documentation.

Question 138
Skipped
A size Medium standard virtual warehouse is being used to continuously load data. The data will be consumed using reports.

Which step will optimize costs?

Enable the query acceleration service.

Change to a multi-cluster warehouse.

Correct answer
Create separate warehouses for each workload.

Resize the warehouse to size Small.

Overall explanation
Snowflake recommends using separate virtual warehouses for data loading and query workloads.

Loading operations—especially large or continuous ingestions—can consume significant compute resources and impact concurrent query performance. Isolating these workloads ensures that reporting and analytical queries are not degraded by ingestion activity.

This separation improves both performance and cost control because:

Loading and reporting have different concurrency and compute profiles.

Each warehouse can be sized independently according to workload characteristics.

Resource contention between ingestion and analytics is eliminated.

For data loading specifically, smaller warehouse sizes (e.g., Small, Medium, Large) are often sufficient. Increasing to larger sizes does not necessarily improve load performance proportionally and may simply increase credit consumption.

For more detailed information, refer to the official Snowflake documentation.

Question 139
Skipped
Which feature allows a user the ability to control the organization of data in a micro-partition?

Search Optimization Service

Range Partitioning

Horizontal Partitioning

Correct answer
Automatic Clustering

Overall explanation
Automatic Clustering in Snowflake automatically manages the physical organization of data in micro-partitions based on a defined clustering key. This ensures that data is organized and optimized for query performance without requiring manual intervention.

For more detailed information, refer to the official Snowflake documentation.

Question 140
Skipped
What features does Snowflake Time Travel enable?

Analyzing data usage/manipulation over all periods of time

Conducting point-in-time analysis for BI reporting

Correct answer
Restoring data-related objects that have been deleted within the past 90 days

Querying data-related objects that were created within the past 365 days

Overall explanation
Time Travel allows you to restore tables, schemas, or databases that were dropped within a specified retention period (up to 90 days in the Enterprise edition).

For more detailed information, refer to the official Snowflake documentation.

Question 141
Skipped
Which URL type allows users to access unstructured data without authenticating into Snowflake or passing an authorization token?

File URL

Signed URL

Scoped URL

Correct answer
Pre-signed URL

Overall explanation
A pre-signed URL is a temporary URL that grants time-limited access to specific resources, such as files in external cloud storage, without requiring authentication or an authorization token.

For more detailed information, refer to the official Snowflake documentation.

Question 142
Skipped
Query parsing and compilation occurs in which architecture layer of the Snowflake Cloud Data Platform?

Storage layer

Cloud agnostic layer

Compute layer

Correct answer
Cloud services layer

Overall explanation
The Cloud services layer is responsible for critical tasks such as query optimization, parsing, compilation, metadata management, security, and governance. This layer determines how queries are processed and executed.

For more detailed information, refer to the official Snowflake documentation.

Question 143
Skipped
Which data types are supported by Snowflake when using semi-structured data? (Choose two.)

Correct selection
ARRAY

XML

BLOB

VARCHAR

Correct selection
VARIANT

Overall explanation
The data types supported by Snowflake when using semi-structured data are VARIANT and ARRAY. These types are designed for handling semi-structured data formats like JSON, Avro, Parquet, or XML, making them ideal for storing and querying semi-structured data in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 144
Skipped
Which Snowflake architectural layer is responsible for a query execution plan?

Correct answer
Cloud services

Cloud provider

Data storage

Compute

Overall explanation
The Cloud services layer in Snowflake manages the metadata, query optimization, and execution planning. It determines the most efficient way to execute a query by creating a query execution plan. This layer also handles other tasks such as authentication, access control, and infrastructure management.

For more detailed information, refer to the official Snowflake documentation.

Question 145
Skipped
Users are responsible for data storage costs until what occurs?

Correct answer
Data expires from Fail-safe

Data is deleted from a table

Data is truncated from a table

Data expires from Time Travel

Overall explanation
In Snowflake, users incur storage costs for data that is retained in the system. Even after data is deleted or truncated, it remains in Time Travel and then Fail-safe. During the Fail-safe period (7 days after Time Travel expires), users are still responsible for storage costs. Once the data expires from Fail-safe, the data is permanently removed, and storage costs cease.

Question 146
Skipped
Which Snowflake layer is always used when accessing a query from the result cache?

Metadata

Compute

Correct answer
Cloud Services

Data Storage

Overall explanation
When accessing a query from the result cache in Snowflake, the Cloud Services layer is always used. This layer handles metadata management and query optimization, including managing the result cache.

Question 147
Skipped
Which SQL command will list the files in a named stage?

Correct answer
list @my_stage;

get @my_stage;

get @%mytable;

list @~;

Overall explanation
The LIST command in Snowflake is used to display the files stored in a named stage. In this case, using list @my_stage; will show all files currently in the stage named my_stage.

For more detailed information, refer to the official Snowflake documentation.

Question 148
Skipped
Which of the following describes how multiple Snowflake accounts in a single organization relate to various cloud providers?

Each Snowflake account must be hosted in a different cloud vendor and region.

All Snowflake accounts must be hosted in the same cloud vendor and region.

Each Snowflake account can be hosted in a different cloud vendor, but must be in the same region.

Correct answer
Each Snowflake account can be hosted in a different cloud vendor and region.

Overall explanation
Snowflake allows organizations to have multiple accounts, and each of these accounts can be hosted on different cloud providers (e.g., AWS, Azure, Google Cloud) and in different regions. This flexibility enables organizations to deploy their Snowflake accounts across various cloud environments based on their specific needs.

For more detailed information, refer to the official Snowflake documentation.

Question 149
Skipped
Which of the following are characteristics of security in Snowflake?

Correct answer
Periodic rekeying of encrypted data is available with the Snowflake Enterprise edition and higher.

Account and user authentication is only available with the Snowflake Business Critical edition.

Support for HIPAA and GDPR compliance is available for UI Snowflake editions.

Private communication to internal stages is allowed in the Snowflake Enterprise edition and higher.

Overall explanation
In Snowflake's Enterprise edition and higher, there is support for periodic rekeying of encrypted data, which enhances data security by regularly rotating encryption keys.

For more detailed information, refer to the official Snowflake documentation.

Question 150
Skipped
Which command can be used to load data into an internal stage from a local file system?

Correct answer
PUT

LOAD

GET

COPY

Overall explanation
PUT command uploads (loads) data files from a local file system to an internal stage in Snowflake. Once the files are staged, they can be loaded into a table using the COPY INTO command.

For more detailed information, refer to the official Snowflake documentation.

Question 151
Skipped
Which types of URLs are provided by Snowflake to access unstructured data files? (Choose two).

Relative URL

Correct selection
File URL

Correct selection
Scoped URL

Dynamic URL

Absolute URL

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 152
Skipped
In which use case does Snowflake apply egress charges?

Data sharing within a specific region

Loading data into Snowflake

Correct answer
Database replication

Query result retrieval

Overall explanation
Snowflake applies a per-byte fee for data egress when users move data from a Snowflake account to a different region on the same cloud platform or to another cloud platform entirely. However, data transfers within the same region are free of charge.

For more detailed information, refer to the official Snowflake documentation.

Question 153
Skipped
Which of the following features are available with the Snowflake Enterprise edition? (Choose two.)

Correct selection
Extended time travel

Automated index management

Database replication and failover

Customer managed keys (Tri-secret secure)

Correct selection
Native support for geospatial data

Overall explanation
Tri-secret secure, Database replication /failover are Business critical and higher features.

For more detailed information, refer to the official Snowflake documentation.

Question 154
Skipped
Which privileges apply to stored procedures? (Choose two.)

MODIFY

Correct selection
OWNERSHIP

OPERATE

MONITOR

Correct selection
USAGE

Overall explanation
In Snowflake, the OWNERSHIP privilege allows the owner of a stored procedure to control it fully, including modifying, transferring ownership, or dropping it. The USAGE privilege is required for a role to execute a stored procedure.

For more detailed information, refer to the official Snowflake documentation.

Question 155
Skipped
When unloading data to an external stage, what is the MAXIMUM file size supported?

1 GB

Correct answer
5 GB

16 GB

10 GB

Overall explanation
While the default value is set to 16 MB (16777216 bytes), this can be adjusted to handle larger files. The largest file size supported for Amazon S3, Google Cloud Storage, or Microsoft Azure stages is 5 GB.

For more detailed information, refer to the official Snowflake documentation.

Question 156
Skipped
What is an advantage of using an explain plan instead of the query profiler to evaluate the performance of a query?

Correct answer
An explain plan can be used to conduct performance analysis without executing a query.

An explain plan's output will display automatic data skew optimization information.

The explain plan output is available graphically.

An explain plan will handle queries with temporary tables and the query profiler will not.

Overall explanation
EXPLAIN compiles the SQL statement without executing it, meaning it does not require an active warehouse. While EXPLAIN does not use compute credits, the query compilation does consume Cloud Service credits, similar to other metadata operations.

For more detailed information, refer to the official Snowflake documentation.

Question 157
Skipped
Which of the following can be executed/called with Snowpipe?

A User Defined Function (UDF)

A stored procedure

Correct answer
A single COPY_INTO statement

A single INSERT_INTO statement

Overall explanation
Snowpipe is designed to load data automatically and continuously from a stage into a table by using a COPY INTO statement. It monitors the stage for new files and triggers the loading process.

For more detailed information, refer to the official Snowflake documentation.

Question 158
Skipped
What are the recommended steps to address poor SQL query performance due to data spilling? (Choose two.)

Fetch required attributes only.

Correct selection
Use a larger virtual warehouse.

Add another cluster in the virtual warehouse.

Correct selection
Process the data in smaller batches.

Clone the base table.

Overall explanation
Increasing the virtual warehouse size provides more compute resources to handle memory-intensive queries, reducing spilling. Processing data in smaller batches minimizes the workload per query, which can also help prevent spilling.

For more detailed information, refer to the official Snowflake documentation.

Question 159
Skipped
What can a reader account user do when accessing shared data? (Choose two.)

Correct selection
Execute secure User-Defined Functions (UDFs).

Insert new data using the COPY INTO [location] command.

Correct selection
Select data from secure views.

Modify records using the UPDATE and MERGE commands.

Remove records using the DELETE command.

Overall explanation
A reader account is designed for a single purpose: to query data that's been shared with you by a data provider. While you can create objects like materialized views to work with the data, these accounts are highly restricted. You are not allowed to load new data, modify existing data, or use storage integrations to unload data.

For more detailed information, refer to the official Snowflake documentation.

Question 160
Skipped
Which command is used to determine the file name of each row of data from a staged file?

Correct answer
SELECT METADATA$FILENAME

SELECT METADATA$FILE_ROW_NUMBER

SHOW FILE FORMATS

SELECT METADATA$FILE_CONTENT_KEY

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 161
Skipped
When unloading to a stage, which of the following is a recommended practice or approach?

Set SINGLE = TRUE for larger files.

Use OBJECT_CONSTRUCT(*) when using Parquet.

Avoid the use of the CAST function.

Correct answer
Define an individual file format.

Overall explanation
Defining a specific file format when unloading data ensures that the data is correctly formatted based on the needs of the destination system. This practice gives you control over how the data is structured, making it easier to work with different data formats (e.g., CSV, Parquet, JSON).

For more detailed information, refer to the official Snowflake documentation.

Question 162
Skipped
How can performance be optimized for a query that returns a small amount of data from a very large base table?

Use clustering keys

Use the query acceleration service

Create materialized views

Correct answer
Use the search optimization service

Overall explanation
The search optimization service is designed to optimize performance for queries that return a small amount of data from a very large base table. It enables Snowflake to efficiently locate and retrieve specific rows without scanning the entire table, significantly improving query performance for selective queries.

For more detailed information, refer to the official Snowflake documentation.

Question 163
Skipped
Which of the following is a valid source for an external stage when the Snowflake account is located on Microsoft Azure?

An FTP server with TLS encryption

A Windows server file share on Azure

An HTTPS server with WebDAV

Correct answer
A Google Cloud storage bucket

Overall explanation
Google Cloud storage is the only supported option for an external stage.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 164
Skipped
What type of query will benefit from the query acceleration service?

Queries of tables that have search optimization service enabled

Queries where the GROUP BY has high cardinality

Queries without filters or aggregation

Correct answer
Queries with large scans and selective filters

Overall explanation
Workloads that could gain from the query acceleration service include ad hoc analytics, which often involve complex operations on varying datasets. Workloads characterized by unpredictable data volumes per query can benefit, as the acceleration service optimizes performance despite fluctuations. Queries that involve large scans coupled with selective filters see significant improvements, as the service enhances execution speed by minimizing the amount of data processed.

For more detailed information, refer to the official Snowflake documentation.

Question 165
Skipped
How often are the Account and Table master keys automatically rotated by Snowflake?

60 Days

Correct answer
30 Days

90 Days

365 Days

Overall explanation
Snowflake implements automatic key rotation every 30 days to enhance security, ensuring that encryption keys are regularly updated to protect stored data effectively.

For more detailed information, refer to the official Snowflake documentation.

Question 166
Skipped
Which privilege must be granted to a share to allow secure views the ability to reference data in multiple databases?

SHARE on databases and schemas

SELECT on tables used by the secure view

Correct answer
REFERENCE_USAGE on databases

CREATE_SHARE on the account

Overall explanation
The REFERENCE_USAGE privilege allows secure views within a share to access objects (like tables or views) in other databases without granting full SELECT privileges on those databases. This privilege is necessary when a secure view needs to reference data across multiple databases, ensuring secure and controlled access to the underlying data.

For more detailed information, refer to the official Snowflake documentation.

Question 167
Skipped
What is the relationship between a Query Profile and a virtual warehouse?

A Query Profile automatically scales the virtual warehouse based on the query complexity.

Correct answer
A Query Profile can help users right-size virtual warehouses.

A Query Profile defines the hardware specifications of the virtual warehouse.

A Query Profile can help determine the number of virtual warehouses available.

Overall explanation
The Query Profile provides insights into resource usage and performance, allowing users to adjust the size of virtual warehouses to better match workload requirements and optimize efficiency.

By analyzing factors such as memory usage, processing time, and potential bottlenecks, users can determine whether to scale up or down the warehouse size to improve efficiency and manage costs effectively.

Question 168
Skipped
Where is Snowflake metadata stored?

In the virtual warehouse layer

Correct answer
In the cloud services layer

Within the data files

In the remote storage layer

Overall explanation
Snowflake stores its metadata in the cloud services layer. This layer handles tasks like metadata management, query optimization, and access control, independent of the virtual warehouse and storage layers.

For more detailed information, refer to the official Snowflake documentation.

Question 169
Skipped
Which semi-structured data function interprets an input string as a JSON document that produces a VARIANT value?

CHECK_JSON

JSON_EXTRACT_PATH_TEXT

Correct answer
PARSE_JSON

PARSE_XML

Overall explanation
The PARSE_JSON function interprets an input string as a JSON document and converts it into a VARIANT value, enabling Snowflake to work with semi-structured JSON data.

For more detailed information, refer to the official Snowflake documentation.

Question 170
Skipped
A company strongly encourages all Snowflake users to self-enroll in Snowflake's default Multi-Factor Authentication (MFA) service to provide increased login security for users connecting to Snowflake.

Which application will the Snowflake users need to install on their devices in order to connect with MFA?

Google Authenticator

Correct answer
Duo Mobile

Microsoft Authenticator

Okta Verify

Overall explanation
Snowflake's default Multi-Factor Authentication (MFA) service can be used with Duo Mobile, which supports the Time-based One-Time Password (TOTP) protocol.

For more detailed information, refer to the official Snowflake documentation.