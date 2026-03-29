Question 1
Incorrect
A user has activated primary and secondary roles for a session.



What operation is the user prohibited from using as part of SQL actions in Snowflake using the secondary role?

Correct answer
Create

Truncate

Insert

Your answer is incorrect
Delete

Overall explanation
Secondary roles can be used to grant additional access for viewing or modifying data, but DDL (Data Definition Language) operations like CREATE are restricted to the primary role.

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
Which are the two VARIANT columns each schema has in every Snowflake table loaded by the Kafka connector? (Choose two.)

RECORD_PRIVILEGES

Correct selection
RECORD_METADATA

RECORD_ISCORRECT

Correct selection
RECORD_CONTENT

RECORD_SUMMARY

Overall explanation
Each schema in a Snowflake table loaded by the Kafka connector includes the VARIANT columns RECORD_METADATA, which stores metadata related to the Kafka message, and RECORD_CONTENT, which holds the actual content of the Kafka message. These columns are essential for handling and interpreting the data ingested from Kafka.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
An Architect uses COPY INTO with the ON_ERROR=SKIP_FILE option to bulk load CSV files into a table called TABLEA, using its table stage. One file named file5.csv fails to load. The Architect fixes the file and re-loads it to the stage with the exact same file name it had previously.

Which commands should the Architect use to load only file5.csv file from the stage? (Choose two.)

COPY INTO tablea FROM @%tablea FORCE = TRUE;

Correct selection
COPY INTO tablea FROM @%tablea;

COPY INTO tablea FROM @%tablea NEW_FILES_ONLY = TRUE;

COPY INTO tablea FROM @%tablea MERGE = TRUE;

Correct selection
COPY INTO tablea FROM @%tablea FILES = ('file5.csv');

COPY INTO tablea FROM @%tablea RETURN_FAILED_ONLY = TRUE;

Overall explanation
We want to load the file so we have to point it explicitly - this is FILES = ('file5.csv'); option

Or load all unloaded files (with file5.csv) FROM @%tablea;.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
The following commands are run in sequence:







If an Architect creates a new table in the schema PROD_DB.PUBLIC, what would be the value of the table's DATA_RETENTION_TIME_IN_DAYS parameter?

10

60

Correct answer
20

30

Overall explanation
A few comments:

When a new table is created in the schema PROD_DB.PUBLIC, the DATA_RETENTION_TIME_IN_DAYS parameter will inherit the value from the schema unless explicitly set otherwise.

Since the schema PROD_DB.PUBLIC has its DATA_RETENTION_TIME_IN_DAYS set to 20 days, any new table created in this schema will have the same retention time.

The value of the table's DATA_RETENTION_TIME_IN_DAYS parameter will be 20 days.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
A company wants to integrate its main enterprise identity provider with federated authentication with Snowflake.



The authentication integration has been configured and roles have been created in Snowflake. However, the users are not automatically appearing in Snowflake when created and their group membership is not reflected in their assigned roles.



How can the missing functionality be enabled with the LEAST amount of operational overhead?

OAuth must be configured between the identity provider and Snowflake. Then the authorization server must be configured with the right mapping of users and roles.

SCIM must be enabled between the identity provider and Snowflake. Once both are synchronized through SCIM, their groups will get created as group accounts in Snowflake and the proper roles can be granted.

OAuth must be configured between the identity provider and Snowflake. Then the authorization server must be configured with the right mapping of users, and the resource server must be configured with the right mapping of role assignment.

Correct answer
SCIM must be enabled between the identity provider and Snowflake. Once both are synchronized through SCIM, users will automatically get created and their group membership will be reflected as roles in Snowflake.

Overall explanation
A few comments:

OAuth is primarily focused on access tokens and does not handle the automatic creation or role assignment for users in Snowflake.

Groups are synchronized as role assignments in Snowflake, not as separate "group accounts."

Enabling SCIM between Snowflake and the identity provider allows users to be created automatically in Snowflake based on their identity provider settings, and their group memberships are mapped to roles.

For more detailed information about OAuth, refer to the official Snowflake documentation.

For more detailed information about SCIM, refer to the official Snowflake documentation.

Question 6
Skipped
Which command can we use to drop pipes from the Kafka connector?

DELETE PIPE <kafkaPipe>

Correct answer
DROP PIPE <kafkaPipe>

DROP KAFKA_PIPE <kafkaPipe>

DELETE KAFKA_PIPE <kafkaPipe>

Overall explanation
To drop a pipe, including those associated with the Kafka connector, the command is DROP PIPE <pipe_name>.

For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
How can an Architect enable optimal clustering to enhance performance for different access paths on a given table?

Create super projections that will automatically create clustering.

Correct answer
Create multiple materialized views with different cluster keys.

Create a clustering key that contains all columns used in the access paths.

Create multiple clustering keys for a table.

Overall explanation
The solution to the problem lies with two new features in Snowflake: materialized views and auto-clustering.

To enable optimal clustering for various access paths on a given table, we should create multiple materialized views, each with different clustering keys. This approach allows for tailored data organization based on specific query patterns, improving query performance across diverse access paths.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
Which statements are true about database replication? (Select THREE).

Correct selection
The secondary database can be on a different cloud provider from the primary database provider.

Correct selection
The secondary database can be in a different region from the primary database.

Each transaction on the primary database is automatically transmitted in real time to the secondary database.

Correct selection
The secondary database is read-only

The secondary database cannot be on a different cloud provider than the primary database provider.

Data transfer charges will be incurred on the account hosting the primary database.

Overall explanation
A few comments:

All objects in a target account are read-only. DML/DDL operations occur on the primary database.

Database replication is supported across regions and cloud platforms.

Each read-only secondary database can be refreshed periodically with a snapshot of the primary database.

For more detailed information about Database replication, refer to the official Snowflake documentation.

For more detailed information about Account replication, refer to the official Snowflake documentation.

Question 9
Skipped
A large manufacturing company runs a dozen individual Snowflake accounts across its business divisions. The company wants to increase the level of data sharing to support supply chain optimizations and increase its purchasing leverage with multiple vendors.

The company’s Snowflake Architects need to design a solution that would allow the business divisions to decide what to share, while minimizing the level of effort spent on configuration and management. Most of the company divisions use Snowflake accounts in the same cloud deployments with a few exceptions for European-based divisions.

According to Snowflake recommended best practice, how should these requirements be met?

Correct answer
Deploy a Private Data Exchange and use replication to allow European data shares in the Exchange.

Migrate the European accounts in the global region and manage shares in a connected graph architecture. Deploy a Data Exchange.

Deploy a Private Data Exchange in combination with data shares for the European accounts.

Deploy to the Snowflake Marketplace making sure that invoker_share() is used in all secure views.

Overall explanation
The key is this: Most of the company divisions use Snowflake accounts in the same cloud deployments with a few exceptions for European-based divisions.

This makes it necessary to use database replication as the solution needs to integrate data from different clouds.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
What does a response error code of 429 from the insertFiles, insertReport, or loadHistoryScan API of Snowpipe mean?

Correct answer
Failure. Request rate limit exceeded

Failure. Invalid request due to an invalid format or limit exceeded

Failure. PipeName not recognized

Failure. Internal server error

Overall explanation
A response error code of 429 from the insertFiles, insertReport, or loadHistoryScan API of Snowpipe indicates that the request rate limit has been exceeded. This means that too many requests have been sent in a short period, and the system is unable to process them at that time.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
An Architect is designing a data lake with Snowflake. The company has structured, semi-structured, and unstructured data. The company wants to save the data inside the data lake within the Snowflake system. The company is planning on sharing data among its corporate branches using Snowflake data sharing.



What should be considered when sharing the unstructured data within Snowflake?

Correct answer
A scoped URL should be used to save the unstructured data into Snowflake in order to share data over secure views, with a 24-hour time limit for the URL.

A file URL should be used to save the unstructured data into Snowflake in order to share data over secure views, with a 7-day time limit for the URL.

A pre-signed URL should be used to save the unstructured data into Snowflake in order to share data over secure views, with no time limit for the URL.

A file URL should be used to save the unstructured data into Snowflake in order to share data over secure views, with the "expiration_time" argument defined for the URL time limit.

Overall explanation
A few comments:

To use sharing on unstructured data, we will need to create a secure view.

The secure view will allow retrieving the scoped URL or the pre-signed URL of the files stored on the stage (no file URL).

Pre-Signed URL is the least secure option of all. To generate it, we have to use the GET_PRESIGNED_URL file funciton. This function supports a maximum expiration time of 7 days, so the first option is valid.

To generate a scoped URL, we will use the file funciton BUILD_SCOPED_FILE_URL, which currently has a limit of 24 hours.

For more detailed information about unstructured data sharing, refer to the official Snowflake documentation.

For more detailed information about presigned url, refer to the official Snowflake documentation.

For more detailed information about scoped file url, refer to the official Snowflake documentation.

Question 12
Skipped
Company A would like to share data in Snowflake with Company B. Company B is not on the same cloud platform as Company A.

What is required to allow data sharing between these two companies?

Company A and Company B must agree to use a single cloud platform: Data sharing is only possible if the companies share the same cloud provider.

Correct answer
Setup data replication to the region and cloud platform where the consumer resides.

Ensure that all views are persisted, as views cannot be shared across cloud platforms.

Create a pipeline to write shared data to a cloud storage location in the target cloud provider.

Overall explanation
This is a common case of data replication. To enable data sharing between Company A and Company B when they are on different cloud platforms, setting up data replication to the appropriate region and cloud platform where the consumer (Company B) is located is essential. This process allows data to be transferred and accessed seamlessly across different cloud environments.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
An Architect has a VPN_ACCESS_LOGS table in the SECURITY_LOGS schema containing timestamps of the connection and disconnection, username of the user, and summary statistics.

What should the Architect do to enable the Snowflake search optimization service on this table?

Correct answer
Assume role with OWNERSHIP on VPN_ACCESS_LOGS and ADD SEARCH OPTIMIZATION in the SECURITY_LOGS schema.

Assume role with ALL PRIVILEGES including ADD SEARCH OPTIMIZATION on the SECURITY LOGS schema.

Assume role with ALL PRIVILEGES on VPN_ACCESS_LOGS and ADD SEARCH OPTIMIZATION in the SECURITY_LOGS schema.

Assume role with OWNERSHIP on future tables and ADD SEARCH OPTIMIZATION on the SECURITY_LOGS schema.

Overall explanation
We need a role with OWNERSHIP privileges on that specific table and then apply the ADD SEARCH OPTIMIZATION option in the SECURITY_LOGS schema.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
An Architect needs to set up a Data Exchange to allow a selected group of invited members to participate in a secure data collaboration.

Who can set up the Data Exchange?

A user with the ORGADMIN role

A user with the SECURITYADMIN role

The Snowflake Support team

Correct answer
A user with the ACCOUNTADMIN role

Overall explanation
Only users with the ACCOUNTADMIN role can set up a Data Exchange in Snowflake. This role has the necessary privileges to create and manage Data Exchanges, including inviting members and configuring data sharing settings.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
At which object type level can the APPLY MASKING POLICY, APPLY ROW ACCESS POLICY and APPLY SESSION POLICY privileges be granted?

Table

Correct answer
Global

Schema

Database

Overall explanation
These are global privileges to grant.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
To which entity do we grant privileges?

Account

Correct answer
Roles

Groups

Users

Overall explanation
RBAC approach. Privileges in Snowflake are granted to roles. Roles serve as a mechanism for managing permissions and access controls, allowing users and groups to inherit the privileges associated with those roles.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
What is the meaning of “Percentage scanned from cache” in the query profiler menu when running a query?

The percentage of data scanned from the query cache.

The percentage of data scanned from the metadata cache.

Correct answer
The percentage of data scanned from the local disk cache.

The percentage of data that is cached and not scanned.

Overall explanation
This metric helps assess the efficiency of data retrieval, as higher percentages suggest that more data was accessed quickly from cache rather than being read from the underlying storage.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
An Architect needs to design a Snowflake account and database strategy to store and analyze large amounts of structured and semi-structured data. There are many business units and departments within the company. The requirements are scalability, security, and cost efficiency.



What design should be used?

Correct answer
Use a centralized Snowflake database for core business data, and use separate databases for departmental or project-specific data.

Set up separate Snowflake accounts and databases for each department or business unit, to ensure data isolation and security.

Use Snowflake's data lake functionality to store and analyze all data in a central location, without the need for structured schemas or indexes.

Create a single Snowflake account and database for all data storage and analysis needs, regardless of data volume or complexity.

Overall explanation
Requirements are: scalability, security and cost efficiency. How hard it is to be an Architect at Snowflake, they are always demanding difficult things from us! :)

A few comments:

The scenario is that there are many different business units and departments, so creating a single account and database to store all the data does not seem to be the best strategy for a robust security solution.

An Account per tenant (APT) strategy would allow us to isolate the data and improve security, but it would not be the most cost-effective solution.

Using a single account would allow us to use interesting features such as Zero Copy Clone.

In this scenario there are large amounts of structured information, so using only external table/directory table capabilities is not an efficient or scalable strategy.

Using a single account but splitting the data into different databases in Snowflake by project and/or department is a strategy that can help control security while looking for cost efficiency.

Question 19
Skipped
The following DDL command was used to create a task based on a stream:



Assuming MY_WH is set to auto_suspend – 60 and used exclusively for this task, which statement is true?

The warehouse MY_WH will never suspend.

Correct answer
The warehouse MY_WH will only be active when there are results in the stream.

The warehouse MY_WH will be made active every five minutes to check the stream.

The warehouse MY_WH will automatically resize to accommodate the size of the stream.

Overall explanation
A few comments:

The SYSTEM$STREAM_HAS_DATA function is the only function supported for evaluation in the SQL expression. This function determines whether a specified stream contains change tracking data. A task evaluates this function before starting its current run; if the result is FALSE, the task will not execute.

It's important to note that while this function is designed to minimize false negatives (i.e., it will not return a false value if the stream contains change data), it does not guarantee the avoidance of false positives (i.e., it may return true even if the stream has no change data).

Furthermore, validating the conditions of the WHEN expression does not consume compute resources, as this validation is processed within the cloud services layer.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
What actions are permitted when using the Snowflake SQL REST API? (Select TWO).

The use of a CALL command to a stored procedure which returns a table

The use of a PUT command

Correct selection
The use of a ROLLBACK command

The use of a GET command

Correct selection
Submitting multiple SQL statements in a single call

Overall explanation
A few comments:

Submitting a request containing multiple statements to the Snowflake SQL API is possible.

Commands that perform explicit transactions (i.e. ROLLBACK) are supported only within a request that specifies multiple statements.

The PUT command is not supported

The GET command is not supported

While you can call stored procedures through the SQL REST API, Snowflake stored procedures do not return tables directly

For more detailed information about SQL API Rest limitations, refer to the official Snowflake documentation.

For more detailed information about statements submitting, refer to the official Snowflake documentation.

Question 21
Skipped
A user has the appropriate privilege to see unmasked data in a column.

If the user loads this column data into another column that does not have a masking policy, what will occur?

Unmasked data will be loaded into the new column but only users with the appropriate privileges will be able to see the unmasked data.

Correct answer
Unmasked data will be loaded in the new column.

Unmasked data will be loaded into the new column and no users will be able to see the unmasked data.

Masked data will be loaded into the new column.

Overall explanation
When a user with the appropriate privileges loads data from a column that has an unmasked value into another column that does not have a masking policy, the unmasked data will be loaded into the new column. The lack of a masking policy on the new column means that it will reflect the original unmasked data.

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
What is a characteristic of loading data into Snowflake using the Snowflake Connector for Kafka?

The Connector only works in Snowflake regions that use Azure infrastructure.

The Connector works with all file formats, including text, JSON, Avro, Ore, Parquet, and XML.

Correct answer
The Connector creates and manages its own stage, table, and pipe objects.

Loads using the Connector will ingest data in real time.

Overall explanation
For each topic, the connector establishes the following objects: one table for each topic, a pipe that ingests the data files for every partition of the topic and an internal stage designated for temporarily storing data files related to the topic.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
When creating a table using the command:



CREATE TABLE MY_TABLE
(NAME STRING(100));


What would the command "DESC TABLE MY_TABLE;" display as the column type?

String

Correct answer
Varchar

Char

Text

Overall explanation
Varchar has different synonyms, like STRING , TEXT , NVARCHAR , CHAR , CHARACTER…, but in the end, they are all VARCHAR type when describing the table. Take a look at the following example, where all the column types are VARCHAR



Question 24
Skipped
One query takes a lot of time, and you see in the query profiler the following information:



What might be the cause of this?

The power of the cloud provider bucket performance is not enough; that's why the performance of the query is degraded.

Correct answer
The amount of memory available for the memory and the local disk of a warehouse node might not be sufficient to hold intermediate results, making Snowflake use the remote storage, thus degrading the performance.

The size of the AWS S3 bucket is not sufficient.

The query itself is poorly written.

Overall explanation
When Snowflake warehouse cannot fit an operation in memory, it starts spilling (storing) data first to the local disk of a warehouse node and then to remote storage. As this means extra IO operations, any query requiring spilling will take longer than a similar query running on similar data capable of fitting the operations in memory.

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
How does Snowflake charge for the compute resources of the cloud services layer?

Correct answer
The typical utilization of the cloud services layer (up to 10% of daily compute credits) is included for free. You pay the excess after this 10%.

It’s included in the storage cost

The typical utilization of the cloud services layer (up to 10% of daily compute credits) is included for free. You pay the excess after this 20%.

It’s included in the computing cost

Overall explanation
The cloud services layer within Snowflake's architecture utilizes credits for essential background operations, including authentication, metadata management, and access control. Users are charged for this layer only when the daily usage of cloud services resources surpasses 10% of the daily warehouse consumption.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
What are some of the characteristics of result set caches? (Choose three.)

Correct selection
Each time persisted results for a query are used, a 24-hour retention period is reset.

Correct selection
Snowflake persists the data results for 24 hours.

The result set cache is not shared between warehouses.

The data stored in the result cache will contribute to storage costs.

Time Travel queries can be executed against the result set cache.

Correct selection
The retention period can be reset for a maximum of 31 days.

Overall explanation
Some of the characteristics of result set caches are:

The retention period can be reset for a maximum of 31 days.

Each time persisted results for a query are used, a 24-hour retention period is reset.

Snowflake persists the data results for 24 hours.

These characteristics highlight how result set caches function in Snowflake, particularly regarding their retention and management.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
What is the best option to clone a table called MYTABLE?

CREATE TABLE MYTABLE_2 AS INSERT INTO MYTABLE VALUES (SELECT * FROM MYTABLE);

CREATE TABLE MYTABLE_2 AS SELECT * FROM MYTABLE;

Correct answer
CREATE TABLE MYTABLE_2 CLONE MYTABLE;

CREATE TABLE MYTABLE_2 AS CLONE MYTABLE;

Overall explanation
Using the zero-copy cloning functionality from Snowflake will always be the best way of cloning objects as it doesn’t duplicate the data, it duplicates the metadata of the micro-partitions, saving us storage costs.

You can see this behavior in the following diagram:



Question 28
Skipped
An Architect is using SnowCD to investigate a connectivity issue.



Which system function will provide a list of endpoints that the network must be able to access to use a specific Snowflake account, leveraging private connectivity?

SYSTEM$ALLOWLIST()

SYSTEM$AUTHORIZE_PRIVATELINK

SYSTEM$GET_PRIVATELINK

Correct answer
SYSTEM$ALLOWLIST_PRIVATELINK()

Overall explanation
SYSTEM$ALLOWLIST_PRIVATELINK() function provides a list of endpoints that need to be accessible to establish private connectivity for a specific Snowflake account. This is useful for troubleshooting and verifying network connectivity in setups using PrivateLink.

For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
What built-in Snowflake features make use of the change tracking metadata for a table? (Choose two.)

Correct selection
A STREAM object

The CHANGE_DATA_CAPTURE command

The MERGE command

Correct selection
The CHANGES clause

The UPSERT command

Overall explanation
Both a STREAM object and the CHANGES clause in Snowflake use change tracking metadata to capture and track modifications made to a table. STREAM objects track row-level changes, while the CHANGES clause allows querying for data changes directly.

Question 30
Skipped
By default, what is the MAXIMUM timeout value that is enforced before a SQL statement that is running is canceled by the system?

43200 seconds (0.5 days)

Correct answer
172800 seconds (2 days)

216000 seconds (2.5 days)

86400 seconds (1 day)

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
What is the meaning of “Processing” in the query profiler menu when running a query?

The total execution time of the query.

Correct answer
The time spent on data processing by the CPU.

The time when the processing was waiting for the network data transfer.

The time when the processing was blocked by local disk access.

Overall explanation
In the query profiler menu, "Processing" refers to the time spent by the CPU on actual data processing tasks during query execution, indicating how much of the query's runtime was dedicated to computational work.

For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
Which of the following features is not supported by Snowpipe for data loading?

Detection of duplication of files while loading

Correct answer
PURGE copy (after loading)

Column Reordering

Semi-structured data loading

Overall explanation
Pipe objects do not support the PURGE copy option, meaning that Snowpipe cannot automatically delete staged files once the data has been successfully loaded into tables. To eliminate staged files that are no longer needed, Snowflake recommends periodically executing the REMOVE command to clean up these files.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
When are materialized views NOT recommended?

Correct answer
The view’s base table changes frequently

Query results contain results that require significant processing

The view’s base table does not change frequently.

The query is on an external table

Overall explanation
Materialized views are particularly beneficial in the following scenarios:

When the query results consist of a small number of rows and/or columns compared to the base table (the table on which the view is defined).

When the query results require significant processing, including:

Analysis of semi-structured data.

Aggregates that take a considerable amount of time to compute.

When the query is performed on an external table (i.e., datasets stored in files in an external stage), which may exhibit slower performance compared to querying native database tables.

When the base table of the view does not change frequently.

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
The IT Security team has identified that there is an ongoing credential stuffing attack on many of their organization’s system.

What is the BEST way to find recent and ongoing login attempts to Snowflake?

Query the LOGIN_HISTORY view in the ACCOUNT_USAGE schema in the SNOWFLAKE database.

Correct answer
Call the LOGIN_HISTORY Information Schema table function.

View the Users section in the Account tab in the Snowflake UI and review the last login column.

View the History tab in the Snowflake UI and set up a filter for SQL text that contains the text "LOGIN".

Overall explanation
The word recent in the question is key. Remember that the ACCOUNT_USAGE has a latency of 2 or 3 hours but the Information Schema is instantaneous.

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
When using the Snowflake Connector for Kafka, what data formats are supported for the messages? (Choose two.)

Correct selection
AVRO

Correct selection
JSON

XML

Parquet

CSV

Overall explanation
The Snowflake Connector for Kafka supports JSON and Avro data formats for messages. However, Snowflake does not support CSV, XML, or Parquet data formats for Kafka messages.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
A company security requirement states that encryption keys used for encrypting files in Snowflake need to be re-encrypted using new keys every 12 months. The company is using an Enterprise edition of Snowflake.

How can this requirement be met?

Upgrade to a Business Critical edition of Snowflake.

Create a task to run the rekeying function on a 12-month schedule.

Correct answer
Set the periodic_data_rekeying parameter to true.

Contact Snowflake Support to enable periodic rekeying.

Overall explanation
A few comments:

This requirement can be met using periodic rekeying.

Periodic rekeying requires Enterprise Edition (or higher).

If periodic rekeying is enabled, Snowflake creates a new encryption key automatically when the retired key for a table is older than one year.

The new key is used to re-encrypt all data previously protected by the retired key.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
A new table and streams are created with the following commands:

CREATE OR REPLACE TABLE LETTERS (ID INT, LETTER STRING);
CREATE OR REPLACE STREAM STREAM_1 ON TABLE LETTERS;
CREATE OR REPLACE STREAM STREAM_2 ON TABLE LETTERS APPEND_ONLY = TRUE;


The following operations are processed on the newly created table:

INSERT INTO LETTERS VALUES (1, 'A');
INSERT INTO LETTERS VALUES (2, 'B');
INSERT INTO LETTERS VALUES (3, 'C');
TRUNCATE TABLE LETTERS;
INSERT INTO LETTERS VALUES (4, 'D');
INSERT INTO LETTERS VALUES (5, 'E');
INSERT INTO LETTERS VALUES (6, 'F');
DELETE FROM LETTERS WHERE ID = 6;


What would be the output of the following SQL commands, in order?

SELECT COUNT (*) FROM STREAM_1;
SELECT COUNT (*) FROM STREAM_2;
Correct answer
2 & 6

2 & 3

4 & 6

4 & 3

Overall explanation
A few comments:

STREAM_1 (with default settings) tracks all DML changes (inserts, deletes, and updates).

Insertions of (4, 'D') and (5, 'E').

STREAM_2 (with APPEND_ONLY = TRUE) tracks only insert operations and ignores any updates or deletes.

Insertions of (1, 'A'), (2, 'B'), (3, 'C') (initial inserts), and (4, 'D'), (5, 'E'), (6, 'F') (inserts after the truncate).

For more detailed information about streams, refer to the official Snowflake documentation.

Question 38
Skipped
What integration object should be used to place restrictions on where data may be exported?

Security integration

API integration

Stage integration

Correct answer
Storage integration

Overall explanation
A storage integration is an object that contains a generated identity and access management (IAM) entity for your external cloud storage, along with an optional set of allowed or blocked storage locations (such as AWS S3, GCS, or Microsoft Azure). Cloud provider administrators in the organization grant permissions for these storage locations to the generated entity.

This setup enables users to avoid supplying credentials when creating stages or loading and unloading data, streamlining the process and enhancing security.

For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
Which role can view account-level Credit and Storage Usage? (Choose two.)

USAGEADMIN

Correct selection
A role that has been granted the MONITOR USAGE global privilege

STORAGEADMIN

Correct selection
ACCOUNTADMIN

SYSADMIN

Overall explanation
The ACCOUNTADMIN role has full visibility into account-level credit and storage usage. Additionally, any role that has been granted the MONITOR USAGE global privilege can also view this information, ensuring proper access control for monitoring purposes.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
An Architect is designing a data model and needs to decide how to generate and store primary keys with hashed values for a large amount of data.

Which hash function in Snowflake will MINIMIZE the likelihood of collisions?

Correct answer
SHA2 with digest_size set to 512

MD5

MD5_NUMBER_LOWER64

SHA2

Overall explanation
A few comments:

This question is not 100% related to Snowflake but they are cryptographic functions available in Snowflake.

The topic of collisions will sound familiar if you are used to modeling in the Data Vault 2.0 paradigm.

SHA2 with digest_size set to 512 is the best choice to minimize the likelihood of collisions. The increased digest size provides a larger range of possible hash values, which drastically reduces the chances of two different inputs resulting in the same hash output (a collision).

This makes it ideal for scenarios where maintaining uniqueness is critical and a large amount of data is involved such as defining business keys in Data Vault 2.0.

Question 41
Skipped
A company is designing a process for importing a large amount of IoT JSON data from cloud storage into Snowflake. New sets of IoT data get generated and uploaded approximately every 5 minutes.



Once the IoT data is in Snowflake, the company needs up-to-date information from an external vendor to join to the data. This data is then presented to users through a dashboard that shows different levels of aggregation. The external vendor is a Snowflake customer.



What solution will MINIMIZE complexity and MAXIMIZE performance?

1. Create a Snowpipe to bring the JSON data into Snowflake.

2. Use streams and tasks to trigger a transformation procedure when new JSON data arrives.

3. Ask the vendor to expose an API so an external function call can be made to join the vendor's data back to the IoT data in a transformation procedure.

4. Create materialized views over the larger dataset to perform the aggregations required by the dashboard.

5. Give the materialized views access to the dashboard tool.

1. Create an external table over the JSON data in cloud storage.

2. Create a task that runs every 5 minutes to run a transformation procedure on new data based on a saved timestamp.

3. Ask the vendor to create a data share with the required data that can be imported into the company's Snowflake account.

4. Join the vendor's data back to the IoT data using a transformation procedure.

5. Create views over the larger dataset to perform the aggregations required by the dashboard.

6. Give the views access to the dashboard tool.

Correct answer
1. Create a Snowpipe to bring the JSON data into Snowflake.

2. Use streams and tasks to trigger a transformation procedure when new JSON data arrives.

3. Ask the vendor to create a data share with the required data that is then imported into the Snowflake account.

4. Join the vendor's data back to the IoT data in a transformation procedure.

5. Create materialized views over the larger dataset to perform the aggregations required by the dashboard.

1. Create an external table over the JSON data in cloud storage.

2. Create a task that runs every 5 minutes to run a transformation procedure on new data, based on a saved timestamp.

3. Ask the vendor to expose an API so an external function can be used to generate a call to join the data back to the IoT data in the transformation procedure.

4. Give the transformed table access to the dashboard tool.

5. Perform the aggregations on the dashboard tool.

Overall explanation
These scenario questions seem more complicated than they really are if you look closely at the differences between the various scenarios for choosing 'the right path'. Let's take a look!

A few comments:

Using an API to access vendor data adds unnecessary complexity and potential latency.

Performing aggregations directly in the dashboard tool can reduce performance compared to using materialized views within Snowflake.

Standard views are less performant than materialized views for large datasets with frequent aggregation needs.

Data sharing is a simple and performant way to access the vendor’s data without managing API integrations.

Snowpipe provides an efficient, automated way to load data every 5 minutes as files arrive, keeping data up-to-date without complex ingestion processes.

Streams and tasks allow Snowflake to detect new data and automatically trigger the transformation procedure, ensuring fresh data is ready for joining with vendor data.

Question 42
Skipped
A Data Architect is cloning a database for a new development environment.

Which of the following should the Architect take into consideration with the cloning process? (Choose two.)

Pipes that reference an external stage will not be cloned

Database tables will be locked during the cloning process.

Correct selection
Tasks will be suspended by default when created.

Correct selection
Unconsumed records in the streams will be inaccessible.

The cloned database will retain any granted privileges from the source database.

Overall explanation
A few comments:

It’s possible to clone pipes that reference an external stage.

The tasks in the clone are suspended by default when the schema that contains them is cloned.

Cloning a database or schema that includes source tables and streams results in any unconsumed records in the streams (in the clone) being inaccessible.

During long cloning operations, DML transactions can modify data in the source table.

For more detailed information, refer to the official Snowflake documentation.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
Which scaling policies does Snowflake support for multi-cluster warehouses? (Choose two.)

Auto-scale

Minimized

Correct selection
Economy

Maximized

Correct selection
Standard (default)

Overall explanation
Snowflake supports the Standard (default) scaling policy, which balances performance and cost by scaling clusters according to the workload, and the Economy policy, which prioritizes minimizing costs by scaling down more aggressively during low demand periods.The scaling policy for a multi-cluster warehouse applies whether it's running in Auto-scale mode or not.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
A stream stores data with the same columns as the source data but with additional columns. What are those additional columns? (Choose two.)

METADATA$DELETE

Correct selection
METADATA$ISUPDATE

Correct selection
METADATA$ACTION

METADATA$INSERT

METADATA$ROW_NUM

Overall explanation
Streams in Snowflake store additional metadata columns such as METADATA$ACTION, which indicates the type of DML operation (INSERT, DELETE, etc.), and METADATA$ISUPDATE, which identifies whether the record is part of an update operation. These columns help track changes in the data.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
A user, analyst_user has been granted the analyst_role, and is deploying a SnowSQL script to run as a background service to extract data from Snowflake.



What steps should be taken to allow the IP addresses to be accessed? (Select TWO).

USE ROLE USERADMIN;
CREATE OR REPLACE NETWORK POLICY ANALYST_POLICY ALLOWED_IP_LIST = ('10.1.1.20');
ALTER ROLE ANALYST_ROLE SET NETWORK_POLICY='ANALYST_POLICY';
ALTER USER ANALYST_USER SET NETWORK_POLICY='10.1.1.20';
Correct selection
ALTER USER ANALYST_USER SET NETWORK_POLICY='ANALYST_POLICY';
Correct selection
USE ROLE SECURITYADMIN;
CREATE OR REPLACE NETWORK POLICY ANALYST_POLICY ALLOWED_IP_LIST = ('10.1.1.20');
Overall explanation
A few comments:

To restrict or allow access to Snowflake from specific IP addresses, a network policy must be set for the user, allowing only the IP addresses specified in the policy to access Snowflake.

Network policies in Snowflake are managed by the SECURITYADMIN role. Once the policy is created, it can then be applied to the user.

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Which organization-related tasks can be performed by the ORGADMIN role? (Choose three.)

Correct selection
Creating an account

Dropping all the accounts in the organization

Changing the edition of organization accounts

Correct selection
Enabling the replication for an account

Correct selection
Viewing a list of organization accounts

Changing the name of the organization

Overall explanation
A few comments:

Although it is possible to delete the organization's accounts, to delete the last one and therefore the organization, you have to contact Snowflake support.

To change the name, please contact Snowflake support.

To change the edition of the accounts, contact Snowflake support.

Creating accounts, viewing the list, enabling replication, deleting accounts, renaming them, managing their URL, etc. is possible with the ORGADMIN role.

For more detailed information about ORGADMIN capabilities, refer to the official Snowflake documentation.

For more detailed information about Organizations, refer to the official Snowflake documentation.

Question 47
Skipped
Which command will fail if you have a table created with the following DDL query?



CREATE TABLE MYTABLE
(ID INTEGER, NAME VARCHAR)
SELECT * FROM Mytable

SELECT * FROM “MYTABLE”

SELECT * FROM MYTABLE

Correct answer
SELECT * FROM “Mytable”

Overall explanation
Snowflake is case-sensitive when double quotes are used. Since the table was created as MYTABLE (uppercase), the query SELECT * FROM “Mytable” (with mixed case and double quotes) will fail because it treats the table name as case-sensitive and different from MYTABLE.

Question 48
Skipped
A company wants to deploy its Snowflake accounts inside its corporate network with no visibility on the internet. The company is using a VPN infrastructure and Virtual Desktop Infrastructure (VDI) for its Snowflake users. The company also wants to re-use the login credentials set up for the VDI to eliminate redundancy when managing logins.

What Snowflake functionality should be used to meet these requirements? (Choose two.)

Set up replication to allow users to connect from outside the company VPN.

Correct selection
Use private connectivity from a cloud provider.

Use a proxy Snowflake account outside the VPN, enabling client redirect for user logins.

Correct selection
Set up SSO for federated authentication.

Provision a unique company Tri-Secret Secure key.

Overall explanation
Use private connectivity from a cloud provider: Private connectivity enables a secure, dedicated network connection between Snowflake and the company’s on-premises infrastructure over a VPN. This approach can provide the required network isolation and security while maintaining high performance and low latency.

Set up SSO for federated authentication: Setting up SSO with a supported identity provider (IdP) allows the company to use its existing user accounts and credentials for authenticating and authorizing user access to Snowflake. This can help reduce the burden of managing multiple sets of credentials and improve the overall user experience.

Question 49
Skipped
An Architect has a design where files arrive every 10 minutes and are loaded into a primary database table using Snowpipe. A secondary database is refreshed every hour with the latest data from the primary database.



Based on this scenario, what Time Travel query options are available on the secondary database?

Using Time Travel, secondary database users can query every iterative version within each hour (the individual Snowpipe loads) and outside the retention window.

Using Time Travel, secondary database users can query every iterative version within each hour (the individual Snowpipe loads) in the retention window.

A query using Time Travel in the secondary database is available for every hourly table version within and outside the retention window.

Correct answer
A query using Time Travel in the secondary database is available for every hourly table version within the retention window.

Overall explanation
A few comments:

Each individual load from Snowpipe in the primary database is not available as separate versions in the secondary database; only the hourly refreshed versions are accessible for Time Travel.

Time Travel only allows access within the defined retention window. Data versions outside this window are purged and are not available.

Only hourly refreshes are stored in the secondary database, not each individual Snowpipe load from the primary database.

Question 50
Skipped
What are the supported values for the VALIDATION_MODE parameter while using the COPY INTO <TABLE> command? (Choose three.)

EXCLUDE_ERRORS

Correct selection
RETURN_ERRORS

IGNORE_ERRORS

RETURN_LAST_ERROR

Correct selection
RETURN_ALL_ERRORS

Correct selection
RETURN_<N>_ROWS

Overall explanation
The VALIDATION_MODE parameter instructs the COPY command to validate data files rather than loading them into the specified table. The three modes accepted for this parameter include RETURN_ALL_ERRORS, RETURN_ERRORS, and RETURN_<N>_ROWS.

When using VALIDATION_MODE, transformations cannot be applied to the data, as the focus is solely on validating the integrity and correctness of the files.

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
Which command will create a schema without Fail-safe and will restrict object owners from passing on access to other users?

Correct answer
create TRANSIENT schema EDW.ACCOUNTING WITH MANAGED ACCESS DATA_RETENTION_TIME_IN_DAYS = 1;
create schema EDW.ACCOUNTING WITH MANAGED ACCESS;
create schema EDW.ACCOUNTING WITH MANAGED ACCESS DATA_RETENTION_TIME_IN_DAYS = 7;
create TRANSIENT schema EDW.ACCOUNTING WITH MANAGED ACCESS DATA_RETENTION_TIME_IN_DAYS = 7;
Overall explanation
A few comments:

Transient schemas do not support Fail-safe, which is intended for data that doesn’t require long-term retention.

With WITH MANAGED ACCESS clause, only administrators can grant or revoke privileges on the objects within the schema, restricting object owners from passing on access to other users.

Setting DATA_RETENTION_TIME_IN_DAYS = 1 specifies minimal Time Travel retention, further reducing storage requirements.

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
What command can we use to delete a share from the Snowflake account?

DELETE SHARE <myShare>

Correct answer
DROP SHARE <myShare>

ALTER SHARE <myShare> SET REMOVED = True

REMOVE SHARE <myShare>

Overall explanation
DROP SHARE <name>

Deletes the designated share from the system and instantly revokes access for all consumers (i.e., accounts that have created a database from the share).

For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
What is the purpose of external functions in Snowflake?

Execute SQL queries directly against external databases.

Connect to a repository of functions outside Snowflake.

Download executable code maintained outside Snowflake.

Correct answer
Call executable code developed, maintained, stored, and executed outside Snowflake.

Overall explanation
In external functions, the code is executed outside Snowflake, also known as Remote Service, which acts like a function, and the information sent is usually relayed through a proxy service. Snowflake stores security-related external function information in an API integration.



For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
A healthcare company wants to share data with a medical institute. The institute is running a Standard edition of Snowflake; the healthcare company is running a Business Critical edition.

How can this data be shared?

The healthcare company will need to change the institute’s Snowflake edition in the accounts panel.

By default, sharing is supported from a Business Critical Snowflake edition to a Standard edition.

Correct answer
Set the share_restriction parameter on the shared object to false.

Contact Snowflake and they will execute the share request for the healthcare company.

Overall explanation
Data sharing from a higher edition to a lower edition is not supported by default. To enable this kind of data sharing, we have to set the share_restriction parameter on the shared object to false.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
Which command can we use to refresh a materialized view?

ALTER MATERIALIZED_VIEW <view> REFRESH=TRUE

Correct answer
Materialized views are automatically refreshed by Snowflake

RESTART MATERIALIZED_VIEW <view>

REFRESH MATERIALIZED VIEW <view>

Overall explanation
Snowflake automatically maintains materialized views. To see the last time that Snowflake refreshed a materialized view, check the REFRESHED_ON and BEHIND_BY columns in the output of the command SHOW MATERIALIZED VIEWS.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
An Architect needs to automate the daily import of two files from an external stage into Snowflake. One file has Parquet-formatted data, the other has CSV-formatted data.



How should the data be joined and aggregated to produce a final result set?

Create a materialized view to read, join, and aggregate the data directly from the external stage, and use the view to produce the final result set.

Create a JavaScript stored procedure to read, join, and aggregate the data directly from the external stage, and then store the results in a table.

Use Snowpipe to ingest the two files, then create a materialized view to produce the final result set.

Correct answer
Create a task using Snowflake scripting that will import the files, and then call a Tabular User-Defined Function (UDTF) to produce the final result set.

Overall explanation
A few comments:

It is not possible to use materialized views on a join, so we discard two options.

A Snowflake task can be scheduled to import the Parquet and CSV files from the external stage into staging tables.

A UDTF can be used to handle the join and aggregation logic needed for the final result set.

Snowflake procedures are designed to operate on data within tables rather than directly accessing files in stages.

For more detailed information about materialized views limitations, refer to the official Snowflake documentation.

For more detailed information about UDTF join examples, refer to the official Snowflake documentation.

Question 57
Skipped
An Architect creates a view to fetch data which is aggregated on SALES_DATE and LOCATION, using the following command:



CREATE OR REPLACE VIEW VW_FETCHAGGREGATEDDATA (SALES_DATE, LOCATION, SUM_REVENUE)
AS
SELECT SALES_DATE, LOCATION, SUM (REVENUE) AS SUM_REVENUE FROM SALES
GROUP BY SALES_DATE, LOCATION;


The view results are slow to process as millions of records are retrieved.

How could the Architect use cluster keys to address this latency?

Correct answer
Recreate this view to be a materialized view then execute the command ALTER MATERIALIZED VIEW VW_FETCHAGGREGATEDDATA CLUSTER BY (SALES_DATE, LOCATION);

Use the command ALTER VIEW VW_FETCHAGGREGATEDDATA RECLUSTER;

Use the command ALTER VIEW VW_FETCHAGGREGATEDDATA CLUSTER BY (SALES_DATE, LOCATION);

Cluster the columns from this view that are most actively used in selective filters.

Overall explanation
A few comments:

The options for CLUSTER operations on non-materialized views are invalid, so we can discard them.

Clustering is generally recommended for columns used in filters or joins. However, in this case, while the filter option is technically feasible, the view does not include any filters—only aggregation.

By converting the view to a materialized view and clustering it on the most frequently used columns (SALES_DATE and LOCATION), the Architect can enhance performance.

For more detailed information, refer to the official Snowflake documentation.

For more detailed information about clustering and materialized views, refer to the official Snowflake documentation.

Question 58
Skipped
How do Snowflake databases that are created from shares differ from standard databases that are not created from shares? (Choose three.)

Correct selection
Shared databases will not have the PUBLIC or INFORMATION_SCHEMA schemas without explicitly granting these schemas to the share.

Correct selection
Shared databases are not supported by Time Travel.

Correct selection
Shared databases are read-only.

Shared databases must be refreshed in order for new data to be visible.

Shared databases can also be created as transient databases.

Shared databases can be cloned.

Overall explanation
Shared databases are read-only.

Users in a consumer account can view/query data, but cannot insert or update data, or create any objects in the database.

The following actions are not supported:

Creating a clone of a shared database or any schemas/tables in the database.

Time Travel for a shared database or any schemas/tables in the database.

Editing the comments for a shared database.

Databases created from shares differ from standard databases in the following ways:

They do not have the PUBLIC or INFORMATION_SCHEMA schemas unless these schemas were explicitly granted to the share.

They cannot be cloned.

Properties, such as TRANSIENT and DATA_RETENTION_TIME_IN_DAYS, do not apply.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
An Architect with the ORGADMIN role wants to change a Snowflake account from an Enterprise edition to a Business Critical edition.



How should this be accomplished?

Correct answer
Contact Snowflake Support and request that the account's edition be changed.

Use the account's ACCOUNTADMIN role to change the edition.

Run an ALTER ACCOUNT command and create a tag of EDITION and set the tag to Business Critical.

Failover to a new account in the same region and specify the new account's edition upon creation.

Overall explanation
Changing the account edition (e.g., from Enterprise to Business Critical) cannot be done directly through SQL commands or account role actions. Snowflake editions represent different service levels with distinct security and compliance features, and only Snowflake Support can make this change at the account level upon request. The Architect with the ORGADMIN role must reach out to Snowflake Support to initiate this process.

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
Which security, governance, and data protection features require, at a MINIMUM, the Business Critical edition of Snowflake? (Choose two.)

Correct selection
AWS, Azure, or Google Cloud private connectivity to Snowflake

Federated authentication and SSO

Extended Time Travel (up to 90 days)

Correct selection
Customer-managed encryption keys through Tri-Secret Secure

Periodic rekeying of encrypted data

Overall explanation
The security, governance, and data protection features that require, at a minimum, the Business Critical edition of Snowflake are:

Customer-managed encryption keys through Tri-Secret Secure

AWS, Azure, or Google Cloud private connectivity to Snowflake

These features are essential for enhanced security and data management in the Business Critical edition.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
Which of these commands require a running warehouse?

SELECT MAX(AGE) FROM USERS_TABLE;

SELECT COUNT(*) FROM USERS_TABLE;

Correct answer
SELECT * FROM USERS_TABLE WHERE email=’test@test.com’;

EXPLAIN USING TABULAR SELECT * FROM USERS_TABLE WHERE email=’test@test.com’;

Overall explanation
The first query will use compute power, whereas the others don’t need a warehouse running. This is an excellent example to see the use of the EXPLAIN command, which returns the logical execution plan for the specified SQL statement. An explained plan shows the operations (for example, table scans and joins) that Snowflake would perform to execute the query.

For example, running the previous command in my Snowflake account, I generated this result in 101ms:



Although EXPLAIN does not consume any compute credits, the compilation of the query does consume Cloud Service credits, just as other metadata operations do. The output is the same as the output of the command EXPLAIN_JSON.

Question 62
Skipped
An Architect is using the Snowflake table function INFER_SCHEMA to automatically detect the file metadata schema in a set of staged data files. The files contain semi-structured data, and the function automatically retrieves the column definitions.

Which statement will successfully create a table using the INFER_SCHEMA function?

A.

B.

C.

D.

C

Correct answer
D

A

B

Overall explanation
The option with USING TEMPLATE is the correct one.

For more detailed information about syntax, refer to the official Snowflake documentation.

Question 63
Skipped
A Data Architect is determining how to cluster the following table, which is used to record orders from a food delivery service application



CREATE TABLE orders_dashboard (
id NUMBER,
driver_id NUMBER,
customer_id NUMBER,
restaurant_ id NUMBER,
ordered_at TIMESTAMP,
item_count INTEGER,
total_cost NUMBER,
order_location_state CHAR (2),
order_comments TEXT);


The purpose of this table is to provide metrics for regional sales managers to understand how deliveries in each region are performing over various timeframes

Given that queries will be run against this table, what would be the MOST efficient clustering statement for this table?

alter table orders_dashboard cluster by (order_location_state, ordered_at);

Correct answer
alter table orders_dashboard cluster by (order_location_state, DATE (ordered_at));

alter table orders_dashboard cluster by (DATE (ordered_at), order_location_state);

alter table orders_dashboard cluster by (ordered_at, order_location_state);

Overall explanation
A few comments:

Snowflake recommends ordering the columns from lowest cardinality to highest cardinality for better effectiveness.

Cardinality of states is lower than DATE of the timestamp, so it has to be the first field in the CLUSTER BY clause.

ordered_at has high cardinality due to the inclusion of time, clustering by DATE(ordered_at) reduces the granularity, making it more efficient.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
Which of the following objects are NOT securable objects?

Correct answer
PRIVILEGES

ROLES

USERS

VIEWS

Overall explanation
PRIVILEGES are not securable objects because they are permissions granted to roles to control access to securable objects like tables and views. Users and roles are entities that can be assigned these privileges, but privileges themselves cannot be secured.

For more detailed information, refer to the official Snowflake documentation.

Question 65
Skipped
A data platform team creates two multi-cluster virtual warehouses with the AUTO_SUSPEND value set to NULL on one, and '0' on the other. What would be the execution behavior of these virtual warehouses?

Setting a '0' or NULL value means the warehouses will suspend immediately.

Correct answer
Setting a '0' or NULL value means the warehouses will never suspend.

Setting a '0' value means the warehouses will suspend immediately, and NULL means the warehouses will never suspend.

Setting a '0' or NULL value means the warehouses will suspend after the default of 600 seconds.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.