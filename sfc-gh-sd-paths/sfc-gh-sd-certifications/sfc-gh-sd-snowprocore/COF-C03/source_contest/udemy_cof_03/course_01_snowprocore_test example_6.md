Question 1
Correct
How does conditional data masking work in Snowflake?

It selectively masks plain text data

Your answer is correct
It selectively masks a column value based on another column

It masks all values in a given column

It selectively masks multiple columns

Overall explanation
Conditional data masking in Snowflake allows column values to be masked based on conditions involving other columns, providing flexibility to enforce masking rules dynamically based on specific criteria or context.

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
How does Snowflake handle the bulk unloading of data into single or multiple files?

It uses COPY INTO for bulk unloading where the default option is SINGLE = TRUE.

It uses COPY INTO to copy the data from a table into one or more files in an external stage only.

It uses the PUT command to download the data by default.

Correct answer
It assigns each unloaded data file a unique name.

Overall explanation
When Snowflake handles the bulk unloading of data, it uses the COPY INTO command, and each unloaded file is assigned a unique name to avoid overwriting and ensure proper organization of the output files.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
What statistical information in a Query Profile indicates that the query is too large to fit in memory? (Choose two.)

Bytes spilled to remote metastore.

Bytes spilled to remote cache.

Correct selection
Bytes spilled to remote storage.

Correct selection
Bytes spilled to local storage.

Bytes spilled to local cache.

Overall explanation
When data spills to local or remote storage, it means that the system has had to offload data to handle the query execution, which can negatively impact performance.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
Which use case will always cause an exploding join in Snowflake?

A query that is using a UNION without an ALL.

Correct answer
A query that has not specified join criteria for tables.

A query that has more than 10 left outer joins.

A query that has requested too many columns of data.

Overall explanation
This scenario will cause an exploding join, as the absence of join criteria results in a Cartesian product, where every row from one table is combined with every row from the other table, leading to exponential growth in the result set.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
Which default warehouse configuration has the highest precedence whenever a new session is created by a user?

Default warehouse for the user

Correct answer
Default warehouse specified on a CLI or in drivers/connectors parameters

Default warehouse in the configuration file of the client utilities

Default warehouse of the role assigned to the user

Overall explanation
The default warehouse for a Snowflake session is determined by a hierarchy: the user's default is overridden by a client configuration file, which is then overridden by a command-line or driver parameter.

It is important to know the order of precedence of parameters, warehouses, etc.

For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
What actions does the use of the PUT command do automatically? (Choose two.)

It creates a file format object.

It uses the last stage created.

Correct selection
It compresses all files using GZIP.

It creates an empty target table.

Correct selection
It encrypts the file data in transit.

Overall explanation
The PUT command automatically compresses files using GZIP by default and ensures that the file data is encrypted while in transit to the stage.

For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
What is SnowSQL?

Snowflake's new user interface where users can visualize data into charts and dashboards.

Snowflake's library that provides a programming interface for processing data on Snowflake without moving it to the system where the application code runs.

Correct answer
Snowflake's command line client built on the Python connector which is used to connect to Snowflake and execute SQL.

Snowflake's proprietary extension of the ANSI SQL standard, including built-in keywords and system functions.

Overall explanation
SnowSQL is Snowflake's command line interface (CLI) that allows users to connect to Snowflake, run SQL queries, and perform various tasks such as data loading and management directly from the terminal.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
Where can a Snowflake user find the query history in Snowsight?

Admin

Correct answer
Monitoring

Data

Dashboards

Overall explanation
In Snowsight, a Snowflake user can find the query history under the "Monitoring" section, which provides insights into query performance and activity.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
The CUSTOMER table in the T1 database is accidentally dropped.



Which privileges are required to restore this table? (Choose two.)

Correct selection
OWNERSHIP privilege on the CUSTOMER table

SELECT privilege on the CUSTOMER table

Correct selection
CREATE TABLE privilege on the T1 database

All privileges on the CUSTOMER table

All privileges on the T1 database

Overall explanation
To restore a dropped object, we must have OWNERSHIP privileges on it, and also need CREATE privileges on the object type in the target database or schema.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
When should a stored procedure be created with caller's rights?

Correct answer
When the stored procedure needs to run with the privileges of the role that called the stored procedure

When the caller needs to be prevented from viewing the source code of the stored procedure

When the stored procedure needs to operate on objects that the caller does not have privileges on

When the caller needs to run a statement that could not execute outside of the stored procedure

Overall explanation
A stored procedure should be created with caller's rights when it needs to execute with the privileges of the role that invoked it, ensuring that the caller's permissions determine what actions the procedure can perform.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
Which operation will produce an error in Snowflake?

Correct answer
Inserting a NULL into a column with a NOT NULL constraint

Inserting duplicate values into a PRIMARY KEY column

Inserting duplicate values into a column with a UNIQUE constraint

Inserting a value to FOREIGN KEY column that does not match a value in the column referenced

Overall explanation
This operation will produce an error in Snowflake, as the NOT NULL constraint is enforced. Other constraints like PRIMARY KEY, UNIQUE, and FOREIGN KEY are not enforced in Snowflake, so those operations would not generate errors.

For more detailed information, refer to the official Snowflake documentation.

Question 12
Skipped
Which table type is no longer available after the close of the session and therefore has no Fail-safe or Time Travel recovery option?

Permanent

Correct answer
Temporary

Transient

External

Overall explanation
Temporary tables are designed for short-term data storage within a single session. After the session ends, the tables are not available by any means. Temporary and Transient tables are never protected by Fail-Safe.

During the session in which they are created, Temporary tables by default have one day of time travel, an that is the maximum available for temporary tables. Depending on account, schema and database level settings, newly created temporary tables may have 0 days of time travel; in any case temporary tables never have anything but 0 or 1 days of time travel.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
How is the hierarchy of database objects organized in Snowflake?

A schema consists of one or more databases. A database contains tables, views, and warehouses.

A schema consists of one or more databases. A database contains tables and views.

A database consists of one of more schemas and warehouses. A schema contains tables and views.

Correct answer
A database consists of one or more schemas. A schema contains tables and views.

Overall explanation
A schema contains tables and views: In Snowflake, the hierarchy of database objects is organized such that a database can have multiple schemas, and within each schema, you can find tables and views.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
A custom role owns multiple tables. If this role is dropped from the system, who becomes the owner of these tables?

ACCOUNTADMIN

Tables will be standalone or orphaned.

SYSADMIN

Correct answer
The role that dropped the custom role.

Overall explanation
When a custom role that owns objects is dropped, the ownership of those objects is transferred to the role that executed the DROP command.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
How should a Snowflake user access a third-party SaaS service to process unstructured data?

Correct answer
Use external functions.

Use internal functions.

Use an API gateway.

Use process functions.

Overall explanation
External functions allow Snowflake to call out to third-party services (such as SaaS APIs) to process data, including unstructured data, by integrating with external endpoints securely and efficiently.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
Which ACCOUNT_USAGE view can be used to identify the masking policy assigned to an object?

OBJECT_DEPENDENCIES

ACCESS_HISTORY

Correct answer
POLICY_REFERENCES

TAG_REFERENCES

Overall explanation
POLICY_REFERENCES view shows which masking or row access policies were assigned to objects like tables or columns.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
Which function produces a lateral view of a VARIANT column?

Correct answer
FLATTEN

OBJECT_CONSTRUCT

PARSE_JSON

LISTAGG

Overall explanation
The FLATTEN function produces a lateral view of a VARIANT column by breaking down semi-structured data (like arrays or objects) into individual rows, making it easier to query and analyze.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
What are characteristics of reader accounts in Snowflake? (Choose two.)

Reader account users can share data to other reader accounts.

A single reader account can consume data from multiple provider accounts.

Correct selection
Reader account users cannot add new data to the account.

Data consumers are responsible for reader account setup and data usage costs.

Correct selection
Reader accounts enable data consumers to access and query data shared by the provider.

Overall explanation
Reader accounts are set up by data providers to give data consumers access to shared data. These users cannot modify or add data but can query the data provided.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
Which object-level parameters can be set to help control query processing and concurrency? (Choose two).

Correct selection
STATEMENT_TIMEOUT_IN_SECONDS

MAX_CONCURRENCY_LEVEL

MIN_DATA_RETENTION_TIME_IN_DAYS

Correct selection
STATEMENT_QUEUED_TIMEOUT_IN_SECONDS

DATA_RETENTION_TIME_IN_DAYS

Overall explanation
STATEMENT_TIMEOUT_IN_SECONDS defines the maximum duration a query can run, while STATEMENT_QUEUED_TIMEOUT_IN_SECONDS controls how long a query can remain in the queue before being canceled, managing concurrency effectively.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
How are micro-partitions enabled on Snowflake tables?

Micro-partitioning is defined by the user when a table is created.

Micro-partitioning requires the use of the search optimization service.

Correct answer
Micro-partitioning is automatically performed on a table.

Micro-partitioning requires a cluster key on a table.

Overall explanation
In Snowflake, micro-partitioning is an automatic feature. Snowflake organizes data into micro-partitions without requiring user intervention, optimizing data storage and query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
Which kind of Snowflake table stores file-level metadata for each file in a stage?

External

Temporary

Transient

Correct answer
Directory

Overall explanation
A directory table in Snowflake stores file-level metadata for each file in a stage.

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
A Snowflake account administrator has set the resource monitors as shown in the diagram, with actions defined for each resource monitor as “Notify & Suspend Immediately”.







What is the MAXIMUM limit of credits that Warehouse 2 can consume?

3500

0

Correct answer
5000

1500

Overall explanation
A few comments:

The credit quota for the entire account is 5000 for the interval (month, week, etc.), as controlled by Resource Monitor 1; if this quota is reached within the interval, the actions defined for the resource monitor (Suspend, Suspend Immediate, etc. ) are enforced for all five warehouses.

Warehouse 3 can consume a maximum of 1000 credits within the interval.

Warehouse 4 and 5 can consume a maximum combined total of 2500 credits within the interval.

The actual credits consumed by Warehouses 3, 4, and 5 may be less than their quotas if the quota for the account is reached first.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
A stream object will advance its offset when it is used in which statement? (Choose two.)

DROP

Correct selection
INSERT

SELECT

CREATE

Correct selection
COPY INTO [location]

Overall explanation
A stream advances its offset only when it is used in a DML transaction. This includes a CREATE TABLE AS SELECT (CTAS) transaction or a COPY INTO <location> transaction, and this behavior applies to both explicit and autocommit transactions.

For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
What common query issues can be identified using the Query Profile? (Choose two.)

Correct selection
Inefficient pruning

Data classification

Unions

Correct selection
Exploding joins

Data masking

Overall explanation
Exploding joins occur when join criteria are missing or incorrect, causing excessive data combinations, while inefficient pruning happens when too many partitions or rows are scanned unnecessarily.

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
How can a Snowflake user share data with another user who does not have a Snowflake account?

Correct answer
Create a reader account and create a share of the data

Move the Snowflake account to a region where data sharing is enabled

Share the data by implementing User-Defined Functions (UDFs)

Grant the READER privilege to the database that is going to be shared

Overall explanation
A Snowflake user can share data with another user who does not have a Snowflake account by creating a reader account. This allows the external user to access the shared data through the reader account without needing a full Snowflake account.



For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
A complex SQL query involving eight tables with joins is taking a while to execute. The Query Profile shows that all partitions are being scanned.

What is causing the query performance issue?

Incorrect joins are being used, leading to scanning and pulling too many records.

The columns in the micro-partitions need granular ordering based on the dataset.

Correct answer
Pruning is not being performed efficiently.

A huge volume of data is being fetched, with many joins applied.

Overall explanation
The fact that all partitions are being scanned indicates that efficient pruning is not taking place.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
Which constraint type is enforced in Snowflake from the ANSI SQL standard?

Correct answer
NOT NULL

PRIMARY KEY

FOREIGN KEY

UNIQUE

Overall explanation
NOT NULL constraint is enforced from the ANSI SQL standard, ensuring that columns cannot contain NULL values. Other constraints like UNIQUE, PRIMARY KEY, and FOREIGN KEY are not enforced but can be defined for documentation purposes.

For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
Which type of query would benefit from enabling the query acceleration service on the virtual warehouse?

Correct answer
Queries that use more resources than the typical query

Queries with no filters or aggregation

Queries that contain a high cardinality GROUP BY expression

Queries that are queued in the warehouse

Overall explanation
A few comments:

The Query Acceleration Service (QAS) is a feature for Snowflake warehouses that boosts performance by speeding up "outlier queries"—those that use more resources than usual.

It improves efficiency by offloading a part of the query processing to shared compute resources.

This service is particularly useful for ad hoc analytics and workloads with unpredictable data volumes.

It excels at accelerating queries with large scans and selective filters, as it can perform this work in parallel to reduce processing time.

For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
What is the uncompressed size limit for semi-structured data loaded into a VARIANT data type using the COPY command?

Correct answer
128 MB

64 MB

8 MB

16 MB

Overall explanation
Important: the size limit for each field in a row has changed significantly in 2025.

Based on the official Snowflake documentation, the uncompressed size limit for semi-structured data loaded into a VARIANT data type using the COPY command is 128 MB.

For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
Masking policies are created at what level in Snowflake?

Table

Table

Correct answer
Schema

Database

Overall explanation
Snowflake's masking policies, which are managed at the schema level, help protect sensitive data. They allow authorized users to see the real data during queries, while preventing unauthorized access.

For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
The use of which technique or tool will improve Snowflake query performance on very large tables?

Materialized views

Correct answer
Clustering keys

Indexing

Multi-clustering

Overall explanation
The use of clustering keys will improve Snowflake query performance on very large tables by organizing the data within the table, which helps optimize the data retrieval process and reduces the amount of data that needs to be scanned during queries.

For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
Which statement describes when a virtual warehouse can be resized?

A resize can only be completed when the warehouse is in an auto-resume status.

A resize must be completed when the warehouse is suspended.

Correct answer
A resize can be completed at any time.

A resize will affect running, queued, and new queries.

Overall explanation
Snowflake allows you to resize a virtual warehouse at any time, and the resize affects only new queries, not those currently running or queued.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
As a best practice, all custom roles should be granted to which system-defined role?

Correct answer
SYSADMIN

ACCOUNTADMIN

ORGADMIN

SECURITYADMIN

Overall explanation
Best practice is to grant all custom roles to the SYSADMIN role.

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
Which data types are valid in Snowflake? (Choose two.)

CLOB

BLOB

Correct selection
Geography

Correct selection
Variant

JSON

Overall explanation
The Geography data type is used for geospatial data, while Variant is a flexible data type used for semi-structured data such as JSON.

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
For the ALLOWED_VALUES tag property, what is the MAXIMUM number of possible string values for a single tag?

10

Correct answer
5000

50

500

Overall explanation
The maximum number of possible string values for a single tag in Snowflake is 5000.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
Which command should a Snowflake user execute to load data into a table?

copy into mytable file_format = (format_name);

Correct answer
copy into mytable from @my_int_stage;

copy into mytable purge_mode = TRUE;

copy into mytable validation = ‘RETURN_ERRORS’;

Overall explanation
The command specifies the source of the data, which is the stage @my_int_stage.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
What is the MINIMUM size of a table for which Snowflake recommends considering adding a clustering key?

1 Megabyte (MB)

1 Gigabyte (GB)

Correct answer
1 Terabyte (TB)

1 Kilobyte (KB)

Overall explanation
Snowflake recommends considering adding a clustering key for tables that are at TB scale of size.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
Which function returns the URL of a stage using the stage name as the input?

GET_PRESIGNED_URL

BUILD_STAGE_FILE_URL

BUILD_SCOPED_FILE_URL

Correct answer
GET_STAGE_LOCATION

Overall explanation
GET_STAGE_LOCATION function returns the URL of a stage using the stage name as the input, allowing users to retrieve the location of the stage in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
When working with table MY_TABLE that contains 10 rows, which sampling query will always return exactly 5 rows?

SELECT * FROM MY_TABLE SAMPLE SYSTEM (1) SEED (5);
SELECT * FROM MY_TABLE SAMPLE SYSTEM (5);
SELECT * FROM MY_TABLE SAMPLE BERNOULLI (5);
Correct answer
SELECT * FROM MY_TABLE SAMPLE (5 ROWS);
Overall explanation
It’s important to understand how to use the SAMPLE or TABLESAMPLE function in Snowflake to retrieve a subset of rows from a table. When working with sampling, several keywords can be used interchangeably, including SAMPLE and TABLESAMPLE, BERNOULLI and ROW, SYSTEM and BLOCK, as well as REPEATABLE and SEED.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
How are micro-partitions typically generated in Snowflake?

PARTITION BY <>;

GROUP BY <>;

ORDER BY <>;

Correct answer
Automatically

Overall explanation
In Snowflake, micro-partitions are generated automatically as data is loaded into a table.

For more detailed information, refer to the official Snowflake documentation.

Question 41
Skipped
Which of the following languages can be used to implement Snowflake User Defined Functions (UDFs)? (Choose two.)

PERL

Correct selection
Javascript

C#

Correct selection
SQL

Ruby

Overall explanation
Snowflake supports both Javascript and SQL (and Java, Python, Scala) for implementing User Defined Functions (UDFs).

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
Which virtual warehouse privilege is required to view a load-monitoring chart?

USAGE

OPERATE

MODIFY

Correct answer
MONITOR

Overall explanation
The MONITOR privilege is required to view a load-monitoring chart in Snowflake, allowing users to monitor the activity and performance of a virtual warehouse.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
Which semi-structured data formats can be loaded into Snowflake with a COPY command? (Choose two.)

Correct selection
ORC

CSV

Correct selection
XML

EDI

HTML

Overall explanation
Snowflake supports various semi-structured formats like ORC, XML, JSON, and Avro for efficient data loading and querying.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
Which statements reflect valid commands when using secondary roles? (Choose two.)

Correct selection
USE SECONDARY ROLES ALL

USE SECONDARY ROLES RESUME

Correct selection
USE SECONDARY ROLES NONE

USE SECONDARY ROLES ADD

USE SECONDARY ROLES SUSPEND

Overall explanation
USE SECONDARY ROLES ALL and USE SECONDARY ROLES NONE are valid commands for managing secondary roles in Snowflake. "ALL" enables all secondary roles, while "NONE" disables them.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
What happens when a database is cloned?

It replicates all granted privileges on the corresponding source objects.

It does not retain any privileges granted on the source object.

It replicates all granted privileges on the corresponding child schema objects.

Correct answer
It replicates all granted privileges on the corresponding child objects.

Overall explanation
When the source object is a database or schema, the clone inherits all granted privileges for the clones of any child objects contained within the source object.

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
What column type does the Kafka connector use to store formatted data in a single column?

VARCHAR

ARRAY

Correct answer
VARIANT

OBJECT

Overall explanation
The Kafka connector stores formatted information in a VARIANT column, as it allows flexible storage of semi-structured data, accommodating various formats such as JSON or XML.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
A network policy applied at the user level takes precedence over a network policy applied to what Snowflake object?

Correct answer
An account

A database

An organization

A role

Overall explanation
We can apply a network policy to an account, a security integration, or a user. If multiple network policies are applied, the most specific one takes precedence over more general policies.

Network policies applied to a user are the most specific and will override both account and security integration policies.

For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
Which command is used to remove files from either external cloud storage or an internal stage?

Correct answer
REMOVE

DROP

DELETE

TRUNCATE

Overall explanation
You can delete files from a Snowflake stage (user, table, or named) either during a successful data load (using the PURGE option with COPY INTO <table>) or after the load is finished (using the REMOVE command).

For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
How can a user validate if a micro-partition is pruning efficiently?

By inspecting the query details output in Snowsight

By querying the INFORMATION_SCHEMA.TABLES view

By using the SYSTEM$CLUSTERING_INFORMATION() function

Correct answer
By inspecting the statistics pane in the Query Profile

Overall explanation
Micro-partition pruning effectiveness can be assessed directly in the Query Profile, specifically within the Statistics section.

Two key indicators are displayed:

Partitions scanned – micro-partitions actually read during execution.

Partitions total – total micro-partitions that make up the table.

Pruning efficiency is determined by comparing these values. A low proportion of scanned partitions relative to the total indicates effective pruning. Conversely, when most partitions are scanned, it typically signals weak data clustering or poor data locality.

An optimal scenario is when the fraction of partitions scanned closely aligns with the fraction of rows ultimately selected by the query.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
What are characteristics of transient tables in Snowflake? (Choose two.)

Correct selection
Transient tables persist until they are explicitly dropped.

Transient tables can be cloned to permanent tables.

Transient tables can be altered to make them permanent tables.

Transient tables have a Fail-safe period of 7 days.

Correct selection
Transient tables have Time Travel retention periods of 0 or 1 day.

Overall explanation
Transient tables are designed for temporary data storage and have limited retention for Time Travel, making them suitable for scenarios where data does not need long-term retention.



For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
A Snowflake table that is loaded using a Kafka connector has a schema consisting of which two VARIANT columns? (Choose two.)

RECORD_KEY

RECORD_TIMESTAMP

RECORD_SESSION

Correct selection
RECORD_CONTENT

Correct selection
RECORD_METADATA

Overall explanation
RECORD_CONTENT: Holds the actual Kafka message payload.

RECORD_METADATA: Contains details about the message, such as the topic it was consumed from and other related metadata.

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
Which Snowflake object can be accessed in the FROM clause of a query, returning a set of rows having one or more columns?

A Scalar User Defined Function (UDF)

A stored procedure

A task

Correct answer
A User-Defined Table Function (UDTF)

Overall explanation
A UDTF can be accessed in the FROM clause of a query, returning a set of rows with one or more columns, allowing more complex data processing and manipulation within a query.

For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
What type of function can be used to estimate the approximate number of distinct values from a table that has trillions of rows?

Correct answer
HyperLogLog (HLL)

MD5

Window

External

Overall explanation
HyperLogLog type of function can be used to estimate the approximate number of distinct values from a table with trillions of rows efficiently, as it provides a probabilistic method for estimating cardinality with minimal memory usage.

For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
Which Snowflake objects track DML changes made to tables, like inserts, updates, and deletes?

Procedures

Pipes

Tasks

Correct answer
Streams

Overall explanation
Streams are used to track DML changes (inserts, updates, and deletes) made to tables, allowing users to query or consume these changes efficiently.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
What type of NULL values are supported in semi-structured data? (Choose two.)

Parquet

Avro

ORC

Correct selection
SQL

Correct selection
JSON

Overall explanation
JSON supports NULL values as part of its structure, and SQL also recognizes NULL as a standard representation of missing or undefined data.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
What ensures that a user with the role SECURITYADMIN can activate a network policy for an individual user?

Ownership privilege on only the role that created the network policy

A role that has been granted the global ATTACH POLICY privilege

Correct answer
Ownership privilege on both the user and the network policy

A role that has been granted the EXECUTE TASK privilege

Overall explanation
To ensure that a user with the SECURITYADMIN role can activate a network policy for an individual user, they must have ownership privilege on both the user and the network policy itself.

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
What does it mean when the sample function uses the Bernoulli sampling method?

The data is based on sampling blocks of the source data.

The data is based on sampling 10% of the source data.

Correct answer
The data is based on sampling every row.

The data is based on sampling 1000 rows of the source data.

Overall explanation
When the sample function uses the Bernoulli sampling method, it means that each row has a specific probability of being included in the sample, which could be as low as a very small percentage or as high as 100%. This method allows for random sampling of rows from the dataset.

For more detailed information, refer to the official Snowflake documentation.

Question 58
Skipped
Which parameter prevents streams on tables from becoming stale?

Correct answer
MAX_DATA_EXTENSION_TIME_IN_DAYS

STALE_AFTER

MIN_DATA_RETENSION_TIME_IN_DAYS

LOCK_TIMEOUT

Overall explanation
MAX_DATA_EXTENSION_TIME_IN_DAYS parameter prevents streams on tables from becoming stale by extending the period during which changes are retained, ensuring the stream can track data modifications for a longer time before becoming stale.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
What action should be taken if a large number of concurrent queries are queued in a virtual warehouse?

Enable auto-resume on the warehouse.

Disable auto-suspend on the warehouse.

Scale-up by resizing the warehouse.

Correct answer
Scale-out with a multi-cluster warehouse.

Overall explanation
Multi-cluster warehouses allow us to scale compute resources to meet our changing user and query concurrency needs, such as during peak and off hours. With multi-cluster warehouses, we can allocate additional clusters either statically or dynamically, expanding the pool of available compute resources.

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
Several users are using the same virtual warehouse. The users report that the queries are running slowly, and that many queries are being queued.

What is the recommended way to resolve this issue?

Correct answer
Increase the warehouse MAX_CLUSTER_COUNT parameter.

Reduce the warehouse STATEMENT_QUEUED_TIMEOUT_IN SECONDS parameter.

Reduce the warehouse AUTO_SUSPEND parameter.

Increase the warehouse MAX_CONCURRENCY_LIMIT parameter.

Overall explanation
The recommended way to resolve the issue of queries running slowly and being queued is to increase the MAX_CLUSTER_COUNT parameter. This allows the virtual warehouse to scale out by adding more clusters to handle the additional query load, reducing queuing and improving performance.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
What is the default compression type when unloading data from Snowflake?

Correct answer
gzip

Zstandard

Brotli

bzip2

Overall explanation
All data files that are unloaded are compressed using gzip, unless compression is specifically turned off or another supported compression method is explicitly chosen.

For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
Which view will return users who have queried a table?

SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES

Correct answer
SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY

SNOWFLAKE.ACCOUNT_USAGE.COLUMNS

SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_EVENT_HISTORY

Question 63
Skipped
A Snowflake user has been granted the CREATE DATA EXCHANGE LISTING privilege with their role.

Which tasks can this user now perform on the Data Exchange? (Choose two.)

Delete provider profiles

Correct selection
Modify listings properties

Correct selection
Submit listings for approval/publishing

Rename listings

Modify incoming listing access requests

Overall explanation
A Snowflake user with the CREATE DATA EXCHANGE LISTING privilege can modify the properties of listings and submit them for approval or publishing on the Data Exchange.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
When using the ALLOW_CLIENT_MFA_CACHING parameter, how long is a cached Multi-Factor Authentication (MFA) token valid for?

8 hours

2 hours

1 hour

Correct answer
4 hours

Overall explanation
When using the ALLOW_CLIENT_MFA_CACHING parameter, a cached Multi-Factor Authentication (MFA) token is valid for 4 hours by default, allowing users to re-authenticate without repeatedly providing MFA credentials within that time frame

For more detailed information, refer to the official Snowflake documentation.

Question 65
Skipped
When unloading data, which file format preserves the data values for floating-point number columns?

CSV

Avro

JSON

Correct answer
Parquet

Overall explanation
When unloading data, the Parquet file format preserves the data values for floating-point number columns, ensuring accurate representation of numerical precision.

For more detailed information, refer to the official Snowflake documentation.

Question 66
Skipped
What does a Notify & Suspend action for a resource monitor do?

Send an alert notification to all account users who have notifications enabled.

Correct answer
Send a notification to all account administrators who have notifications enabled, and suspend all assigned warehouses after all statements being executed by the warehouses have completed.

Send an alert notification to all virtual warehouse users when thresholds over 100% have been met.

Send a notification to all account administrators who have notifications enabled, and suspend all assigned warehouses immediately, canceling any statements being executed by the warehouses.

Overall explanation
The "Notify & Suspend" action for a resource monitor sends a notification to account administrators (if they have notifications enabled) and immediately suspends all assigned warehouses, canceling any statements that are currently being executed. This action is triggered when the resource monitor's thresholds are exceeded.

For more detailed information, refer to the official Snowflake documentation.

Question 67
Skipped
Which Data Definition Language (DDL) commands are supported by Snowflake to manage tags? (Choose two.)

DESCRIBE TAG

Correct selection
DROP TAG

GRANT ... TO TAG

GRANT TAG

Correct selection
ALTER TAG

Overall explanation
ALTER TAG is used to modify a tag, while DROP TAG is used to remove a tag from the system.

For more detailed information, refer to the official Snowflake documentation.

Question 68
Skipped
What metrics will the SHOW TABLES command in Snowsight provide?

Retained for clone bytes

Correct answer
Active bytes

Fail-safe bytes

Time Travel bytes

Overall explanation
The SHOW TABLES command in Snowsight provides metrics related to the active bytes, which represent the actual data that will be scanned if the entire table is scanned in a query. Snowflake breaks down storage bytes into two categories:

Active bytes: Represent data in the table that can be queried.

Deleted bytes: Represent data that has been deleted but is still accruing storage charges because it hasn't been purged from the system yet (Time Travel, Fail-safe, Clone)

For more detailed information, refer to the official Snowflake documentation.

Question 69
Skipped
Which element in the Query Profile interface shows the relationship between the nodes in the execution of a query?

Steps

Correct answer
Operator Tree

Overview

Node List

Overall explanation
The Operator Tree in the Query Profile interface shows the relationship between the nodes in the execution of a query, providing a visual representation of how operations are performed and data flows through the query execution plan.

For more detailed information, refer to the official Snowflake documentation.

Question 70
Skipped
When executing a COPY INTO command, performance can be negatively affected by using which optional parameter on a large number of files?

FILES

FILE_FORMAT

VALIDATION_MODE

Correct answer
PATTERN

Overall explanation
To achieve optimal performance, it's advisable to avoid using patterns that filter across a large number of files.

For more detailed information, refer to the official Snowflake documentation.

Question 71
Skipped
Other than ownership what privileges does a user need to view and modify resource monitors in Snowflake? (Choose two.)

Correct selection
MODIFY

CREATE

ALTER

DROP

Correct selection
MONITOR

Overall explanation
To view and modify resource monitors in Snowflake, a user needs the MONITOR privilege to view the resource monitor's details and the MODIFY privilege to make changes to it.

For more detailed information, refer to the official Snowflake documentation.

Question 72
Skipped
How long is a query visible in the Query History page in the Snowflake Web Interface (Snowsight)?

Correct answer
14 days

30 days

60 minutes

24 hours

Overall explanation
Queries are visible in the Query History page for 14 days.

For more detailed information, refer to the official Snowflake documentation.

Question 73
Skipped
Which result shows efficient pruning?

Partitions scanned is greater than partitions total.

Correct answer
Partitions scanned is less than partitions total.

Partitions scanned is greater than or equal to the partitions total.

Partitions scanned is equal to the partitions total.

Overall explanation
Efficient pruning occurs when fewer partitions are scanned than the total available, indicating that only the necessary partitions for the query are being accessed, improving query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 74
Skipped
Which Snowflake multi-cluster virtual warehouse scaling policy or mode will MINIMIZE query queuing by prioritizing the startup of additional clusters?

Economy policy

Auto-scale mode

Maximized mode

Correct answer
Standard policy

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 75
Skipped
What metadata does Snowflake store concerning all rows stored in a micro-partition? (Choose two.)

A count of the number of total values in the micro-partition

Correct selection
The number of distinct values for each column in the micro-partition

The range of values for each partition in the micro-partition

Correct selection
The range of values for each of the columns in the micro-partition

The range of values for each of the rows in the micro-partition

Overall explanation
The range of values for each of the columns in the micro-partition and The number of distinct values for each column in the micro-partition: Snowflake stores this metadata to optimize query performance and improve data retrieval efficiency within micro-partitions.

For more detailed information, refer to the official Snowflake documentation.

Question 76
Skipped
What is to be expected when sharing worksheets in Snowsight?

Snowsight offers different sharing permissions at the worksheet, folder, and dashboard level.

Worksheets can be shared with users that are internal or external to any organization.

Snowsight allows users to view and refresh results but not to edit shared worksheets.

Correct answer
To run a shared worksheet, a user must be granted the role used for the worksheet session context.

Overall explanation
In Snowsight, a user can only execute a shared worksheet if they have been granted the appropriate role that was used in the session context of the worksheet, ensuring proper access control for data and queries.

For more detailed information, refer to the official Snowflake documentation.

Question 77
Skipped
User A cloned a schema and overwrote a schema that User B was working on. User B no longer has access to their version of the tables. However, this all occurred within the Time Travel retention period defined at the database level.

How should the missing tables be restored?

Use an UNDROP TABLE statement.

Correct answer
Rename the cloned schema and use an UNDROP SCHEMA statement.

Use a CREATE TABLE AS SELECT statement.

Contact Snowflake Support to retrieve the data from Fail-safe.

Overall explanation
By renaming the cloned schema, you can free up the original schema name and then use the UNDROP SCHEMA statement to restore the original schema, as it is still within the Time Travel retention period.

For more detailed information, refer to the official Snowflake documentation.

Question 78
Skipped
What mechanisms can be used to inform Snowpipe that there are staged files available to load into a Snowflake table? (Choose two.)

Correct selection
REST endpoints

Correct selection
Cloud messaging

Email integrations

Snowsight interactions

Error notifications

Overall explanation
Snowpipe can be notified of available staged files through cloud messaging services like AWS SNS or Azure Event Grid, which automate the loading process. Additionally, Snowpipe can use REST endpoints for manual or programmatic notifications to trigger the loading of staged files into a Snowflake table.

For more detailed information, refer to the official Snowflake documentation.

Question 79
Skipped
Which user object property requires contacting Snowflake Support in order to set a value for it?

MINS_TO_BYPASS_MFA

Correct answer
MINS_TO_BYPASS_NETWORK_POLICY

DISABLED

MINS_TO_UNLOCK

Overall explanation
Setting a value for MINS_TO_BYPASS_NETWORK_POLICY requires contacting Snowflake Support to set a value, as it involves bypassing network policies, which could have significant security implications.

For more detailed information, refer to the official Snowflake documentation.

Question 80
Skipped
How can a Snowflake user validate data that is unloaded using the COPY INTO command?

Correct answer
Use the VALIDATION_MODE = RETURN_ROWS statement.

Use the VALIDATION_MODE = SQL statement.

Load the data into a CSV file.

Load the data into a relational table.

Overall explanation
VALIDATION_MODE = RETURN_ROWS option allows a Snowflake user to validate data that is unloaded using the COPY INTO command without actually unloading the data, by returning rows that indicate any errors or issues during the validation process.

For more detailed information, refer to the official Snowflake documentation.

Question 81
Skipped
A user wants to upload a file to an internal Snowflake stage using a PUT command.

Which tools and/or connectors could be used to execute this command? (Choose two.)

SQL API

Snowsight worksheets

Correct selection
SnowSQL

SnowCD

Correct selection
Python connector

Overall explanation
Both SnowSQL and the Python connector can be used to execute the PUT command to upload a file to an internal Snowflake stage. SnowSQL is a command-line interface, while the Python connector allows for programmatic interactions with Snowflake.

About SQL API, For more detailed information, refer to the official Snowflake documentation.

Question 82
Skipped
What does Snowflake recommend regarding database object ownership? (Choose two.)

Create objects with ACCOUNTADMIN and do not reassign ownership.

Create objects with SECURITYADMIN to ease granting of privileges later.

Correct selection
Create objects with a custom role and grant this role to SYSADMIN.

Use only managed access schemas for objects owned by ACCOUNTADMIN.

Correct selection
Create objects with SYSADMIN.

Overall explanation
Snowflake recommends creating objects with the SYSADMIN role or a custom role that is then granted to SYSADMIN to maintain proper object management. This approach aligns with best practices for access control and delegation of privileges.

For more detailed information, refer to the official Snowflake documentation.

Question 83
Skipped
What does Snowflake's search optimization service support?

Materialized views

Correct answer
Tables that are protected by row access policies

External tables

Casts on table columns (except for fixed-point numbers cast to strings)

Overall explanation
The search optimization service is completely compatible with tables that implement masking policies and row access policies.

For more detailed information, refer to the official Snowflake documentation.

Question 84
Skipped
How does Snowflake recommend defining a clustering key on a high-cardinality column that includes a 15 digit ID numbered column, ID_NUMBER?

ID_NUMBER*100
TRUNC(ID_NUMBER, 5)
TO_CHAR(ID_NUMBER)
Correct answer
TRUNC(ID_NUMBER, -6)
Overall explanation
Clustering on columns with lots of unique values (high cardinality) can be costly. Clustering on a unique key might even cost more than it helps, especially if you're not mainly doing simple lookups on that table. If you must use a high-cardinality column, Snowflake suggests creating a clustering key expression based on that column instead of using the column directly. This reduces the number of unique values. Make sure the expression keeps the original order so Snowflake can still efficiently skip partitions. For example, you could use TRUNC with a negative scale to reduce the significant digits of a number.

For more detailed information, refer to the official Snowflake documentation.

Question 85
Skipped
What are Snowflake best practices when assigning the ACCOUNTADMIN role to users? (Choose two.)

Correct selection
All users assigned the ACCOUNTADMIN role should use Multi-Factor Authentication (MFA).

Correct selection
The ACCOUNTADMIN role should be assigned to at least two users.

The ACCOUNTADMIN role should be given to any user who needs a high level of authority.

The ACCOUNTADMIN role should be used for running automated scripts.

The ACCOUNTADMIN role should be used to create Snowflake objects.

Overall explanation
The ACCOUNTADMIN role should be assigned to at least two users and All users assigned the ACCOUNTADMIN role should use Multi-Factor Authentication (MFA): These best practices help ensure that there is redundancy in administrative access while enhancing security through MFA for users with high-level privileges.

For more detailed information, refer to the official Snowflake documentation.

Question 86
Skipped
Why would a Snowflake user choose to use a transient table?

Correct answer
To store transitory data that needs to be maintained beyond the session

To create a permanent table for ongoing use in ELT

To store data for long-term analysis

To store large data files that are used frequently

Overall explanation
A transient table is ideal for temporary data that doesn't require fail-safe protection but needs to persist beyond the session, offering a cost-effective solution for intermediate or temporary data storage.

For more detailed information, refer to the official Snowflake documentation.

Question 87
Skipped
Snowflake Partner Connect is limited to users with a verified email address and which role?

Correct answer
ACCOUNTADMIN

SYSADMIN

SECURITYADMIN

USERADMIN

Overall explanation
Snowflake Partner Connect is limited to users with a verified email address and the ACCOUNTADMIN role, as this role has the necessary privileges to manage integrations and account-level settings.

For more detailed information, refer to the official Snowflake documentation.

Question 88
Skipped
What are valid sub-clauses to the OVER clause for a window function? (Choose two.)

GROUP BY

Correct selection
ORDER BY

Correct selection
PARTITION BY

UNION ALL

LIMIT

Overall explanation
PARTITION BY divides the result set into partitions, and ORDER BY specifies the order of rows within each partition for applying the window function.

For more detailed information, refer to the official Snowflake documentation.

Question 89
Skipped
Which command will list all of the dropped accounts in an organization that have not been deleted?

Correct answer
SHOW ACCOUNTS;
SHOW DROPPED ACCOUNTS;
SHOW ORGANIZATION ACCOUNTS LIKE 'myaccounts%';
SHOW MANAGED ACCOUNTS;
Overall explanation
The SHOW ACCOUNTS command can be used with the HISTORY parameter to optionally include dropped accounts that have not yet been permanently deleted.

For more detailed information, refer to the official Snowflake documentation.

Question 90
Skipped
Which feature is included in column-level security in Snowflake?

Data classification

Correct answer
External tokenization

Tag-based masking policies

Object tagging

Overall explanation
Column-level Security in Snowflake allows us to apply a masking policy to a column within a table or view. It currently includes two features: Dynamic Data Masking and External Tokenization.

External Tokenization enables us to tokenize data before loading it into Snowflake and detokenize it at query runtime.

A tag-based masking policy is related to column-level security but is not the exact concept being asked about. It combines the object tagging and masking policy features, allowing a masking policy to be set on a tag using an ALTER TAG command.

For more detailed information, refer to the official Snowflake documentation.

Question 91
Skipped
When initially creating an account in Snowflake, which settings are required to be specified? (Choose two.)

Region

Correct selection
Snowflake edition

Account locator

Correct selection
Account name

Organization name

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 92
Skipped
A Snowflake user wants to unload data from a relational table sized 5 GB using CSV. The extract needs to be as performant as possible.

What should the user do?

Increase the default MAX_FILE_SIZE to 5 GB and set SINGLE = true to produce a single file.

Use Parquet as the unload file format, using Parquet's default compression feature.

Correct answer
Leave the default MAX_FILE_SIZE to 16 MB to take advantage of parallel operations.

Use a regular expression in the stage specification of the COPY command to restrict parsing time.

Overall explanation
By keeping the default MAX_FILE_SIZE at 16 MB, the user can leverage Snowflake's ability to perform parallel operations during the unload process, which enhances performance when extracting data from a large relational table.

For more detailed information, refer to the official Snowflake documentation.

Question 93
Skipped
What MINIMUM privilege is required on the external stage for any role in the GET REST API to access unstructured data files using a file URL?

WRITE

OWNERSHIP

Correct answer
USAGE

READ

Overall explanation
The correct minimum privilege for accessing unstructured data files in an external stage via the GET REST API is USAGE.

For more detailed information, refer to the official Snowflake documentation.

Question 94
Skipped
A user wants to add additional privileges to the system-defined roles for their virtual warehouse.

How does Snowflake recommend they accomplish this?

Grant the additional privileges to the SYSADMIN role.

Correct answer
Grant the additional privileges to a custom role.

Grant the additional privileges to the ACCOUNTADMIN role.

Grant the additional privileges to the ORGADMIN role.

Overall explanation
Snowflake recommends creating a custom role and granting additional privileges to that role, rather than modifying system-defined roles. This allows for better role management and adherence to the principle of least privilege.

For more detailed information, refer to the official Snowflake documentation.

Question 95
Skipped
Which features could be used to improve the performance of queries that return a small subset of rows from a large table? (Choose two.)

Row access policies

Secure views

Correct selection
Search optimization service

Multi-cluster virtual warehouses

Correct selection
Automatic clustering

Overall explanation
The search optimization service accelerates equality searches by indexing relevant columns, while automatic clustering helps organize data more efficiently, enhancing query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 96
Skipped
What function, combined with the copy command, should be used to unload data from a relational table into a JSON file?

FLATTEN

Correct answer
OBJECT_CONSTRUCT

CAST

LATERAL

Overall explanation
The OBJECT_CONSTRUCT function, when combined with the COPY command, is used to convert rows from a relational table into JSON format, making it suitable for unloading data into a JSON file.

For more detailed information, refer to the official Snowflake documentation.

Question 97
Skipped
How can a Snowflake administrator determine which user has accessed a database object that contains sensitive information?

Correct answer
Query the ACCESS HISTORY view in the ACCOUNT_USAGE schema.

Query the REPLICATION_USAGE_HISTORY view in the ORGANIZATION_USAGE schema.

Review the row access policy for the database object.

Review the granted privileges to the database object.

Overall explanation
The ACCESS HISTORY view in the ACCOUNT_USAGE schema provides detailed logs of user activity on database objects, allowing administrators to track which users accessed specific objects containing sensitive information for auditing and compliance purposes.

For more detailed information, refer to the official Snowflake documentation.

Question 98
Skipped
Which function should be used to find the query ID of the second query executed in a current session?

Select LAST_QUERY_ID(-2)

Select LAST_QUERY_ID(-1)

Select LAST_QUERY_ID(1)

Correct answer
Select LAST_QUERY_ID(2)

Overall explanation
LAST_QUERY_ID(1) returns the first query.

LAST_QUERY_ID(2) returns the second query.

LAST_QUERY_ID(-2) returns the second most recently executed query.

For more detailed information, refer to the official Snowflake documentation.

Question 99
Skipped
What is the primary purpose of a directory table in Snowflake?

Correct answer
To store file-level metadata about data files in a stage

To manage user privileges and access control

To automatically expire file URLs for security

To store actual data from external stages

Overall explanation
The primary purpose of a directory table in Snowflake is to hold metadata about files in an external stage, such as file names, sizes, and modification times, facilitating file tracking and management.

For more detailed information, refer to the official Snowflake documentation.

Question 100
Skipped
A JSON object is loaded into a column named data using a Snowflake variant datatype. The root node of the object is BIKE. The child attribute for this root node is BIKEID.

Which statement will allow the user to access BIKEID?

Correct answer
select data:BIKE.BIKEID

select data:BIKEID

select data:BIKE:BIKEID

select data.BIKE.BIKEID

Overall explanation
This statement will allow the user to access the BIKEID attribute of the root node BIKE in a JSON object stored in a column with the Snowflake variant datatype.

For more detailed information, refer to the official Snowflake documentation.

Question 101
Skipped
A Query Profile shows a UnionAll operator with an extra Aggregate operator on top.

What does this signify?

Correct answer
UNION without ALL

Queries that are too large to fit in memory

Exploding joins

Inefficient pruning

Overall explanation
The presence of an extra Aggregate operator on top of a UnionAll operator in a Query Profile indicates that the query is using a UNION without the ALL keyword. This results in an additional aggregation step to remove duplicate rows, which wouldn't be necessary with a UNION ALL.

For more detailed information, refer to the official Snowflake documentation.

Question 102
Skipped
Two users share a virtual warehouse named WH_DEV_01. When one of the users loads data, the other one experiences performance issues while querying data.

How does Snowflake recommend resolving this issue?

Scale up the existing warehouse

Create separate warehouses for each user

Correct answer
Create separate warehouses for each workload

Stop loading and querying data at the same time

Overall explanation
Snowflake recommends creating separate virtual warehouses for different workloads, such as data loading and querying, to avoid resource contention and ensure optimal performance for each user and task.

For more detailed information, refer to the official Snowflake documentation.

Question 103
Skipped
A Snowflake user wants to share data with someone who does not have a Snowflake account.

How can the Snowflake user share the data?

Use the Snowflake Marketplace.

Correct answer
Create a reader account.

Use a Snowflake share.

Create a consumer account.

Overall explanation
To share data with someone who does not have a Snowflake account, the Snowflake user can create a reader account. This allows the external user to access the shared data without needing their own full Snowflake account.

For more detailed information, refer to the official Snowflake documentation.

Question 104
Skipped
How many network policies can be assigned to an account or specific user at a time?

3

Unlimited

2

Correct answer
1

Overall explanation
Only one network policy can be assigned to an account or a specific user at a time in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 105
Skipped
Which Snowflake storage object can be used to store data beyond a single session and will not incur Fail-safe costs?

Permanent table

Temporary table

External table

Correct answer
Transient table

Overall explanation
Snowflake allows us to create transient tables, which persist until explicitly dropped and are accessible to all users with the appropriate privileges. Transient tables are similar to permanent tables, but they do not have a Fail-safe period. This makes them ideal for storing temporary data that needs to persist beyond each session (unlike temporary tables), but doesn't require the same level of data protection and recovery offered by permanent tables.

For more detailed information, refer to the official Snowflake documentation.

Question 106
Skipped
What is the MOST efficient method to share a subset of data from a table with a consumer account?

Correct answer
Create a secure view.

Use a dynamic table.

Create an external table.

Create a secure User-Defined Function (UDF).

Overall explanation
A secure view is the recommended mechanism for exposing only a controlled portion of a table to a consumer account.

It enables selective data sharing by:

Restricting rows through WHERE filters.

Limiting visible columns.

Applying logic (including account-based conditions) to tailor results per consumer.

This approach ensures the underlying table remains protected while only the required subset is shared.

Other objects serve different purposes: dynamic tables support pipeline transformations, external tables reference data stored outside Snowflake, and secure UDFs encapsulate reusable logic rather than governing row- and column-level data exposure.

For more detailed information, refer to the official Snowflake documentation.

Question 107
Skipped
Why do Snowflake’s virtual warehouses have scaling policies?

To help save extra storage costs

Correct answer
To help control the credits consumed by a multi-cluster warehouse running in auto-scale mode

To help increase the performance of serverless computing features

To help control the credits consumed by a multi-cluster warehouse running in maximized mode

Overall explanation
Snowflake’s virtual warehouses have scaling policies to control the credits consumed by multi-cluster warehouses, particularly in auto-scale mode, ensuring efficient resource usage.

For more detailed information, refer to the official Snowflake documentation.

Question 108
Skipped
How can an administrator check for updates (for example, SCIM API requests) sent to Snowflake by the identity provider?

QUERY_HISTORY

Correct answer
REST_EVENT_HISTORY

LOAD_HISTORY

ACCESS_HISTORY

Overall explanation
An administrator can check for updates, such as SCIM API requests sent to Snowflake by the identity provider, by querying the REST_EVENT_HISTORY view, which tracks API requests and other REST-based interactions.

For more detailed information, refer to the official Snowflake documentation.

Question 109
Skipped
Which view can be used to determine if a table has frequent row updates or deletes?

STORAGE_USAGE

STORAGE_DAILY_HISTORY

TABLES

Correct answer
TABLE_STORAGE_METRICS

Overall explanation
The TABLE_STORAGE_METRICS view can be used to detect high-churn dimension tables by calculating the ratio of FAILSAFE_BYTES to ACTIVE_BYTES. A table with a high ratio indicates frequent modifications, making it a high-churn table. This helps identify tables that undergo frequent updates or changes.

For more detailed information, refer to the official Snowflake documentation.

Question 110
Skipped
What are type predicates used for?

Casting a value in a VARIANT column to a particular data type

Manipulating objects and arrays in a VARIANT column

Extracting data from a VARIANT column

Correct answer
Determining if a value in a VARIANT column is a particular data type

Overall explanation
The IS_<object_type> functions are used to check the data type of a value stored in a VARIANT column. They return true or false depending on the data type.

For more detailed information, refer to the official Snowflake documentation.

Question 111
Skipped
Which are key characteristics of the Query Processing layer? (Select TWO).

Correct selection
The size of virtual warehouses can be changed dynamically

Up to 10% of daily usage of compute is free

Compute costs are calculated per hour of virtual warehouse runtime

Correct selection
Virtual warehouse start and stop operations can be automated

Storage is tied to the number of compute clusters

Overall explanation
Virtual warehouses (the Query Processing layer) have two key characteristics:

They can be resized while running. You can scale a warehouse up or down to adjust available compute. The new capacity is used by newly submitted queries and any queries waiting in the queue once provisioning completes.

They support automatic start/stop behavior. With auto-suspend, the warehouse stops after a configured period of inactivity; with auto-resume, it restarts automatically when a query is submitted. Both are enabled by default.

Why the other statements are incorrect:

The “10% free” rule applies to Cloud Services usage relative to daily warehouse usage, not to warehouse compute.

Snowflake’s architecture separates storage from compute, so storage is not tied to warehouse clusters.

Compute is billed per-second (with a minimum charge when resuming), not per hour.

For more detailed information, refer to the official Snowflakedocumentation.

Question 112
Skipped
How do managed access schemas help with data governance?

They require the use of masking and row access policies across every table and view in the schema.

They enforce identical privileges across all tables and views in a schema.

Correct answer
They provide centralized privilege management with the schema owner.

They log all operations and enable fine-grained auditing.

Overall explanation
Managed access schemas help with data governance by allowing centralized control of privileges, meaning that the schema owner can manage access rights for all objects within the schema, facilitating better governance and security practices.

For more detailed information, refer to the official Snowflake documentation.

Question 113
Skipped
If a source table is updated while cloning is in progress, what data will be included in the cloned table?

All data from the timestamp when the user runs the query.

All data from the timestamp when the clone statement was completed.

Correct answer
All data from the timestamp when the clone statement was initiated.

All data from the timestamp when the user session was created.

Overall explanation
Cloning operations take time, especially for large tables. During this time, DML transactions can modify the source table's data. As a result, Snowflake attempts to clone the table's data as it was when the operation started.

For more detailed information, refer to the official Snowflake documentation.

Question 114
Skipped
A Snowflake user is writing a User-Defined Function (UDF) with some unqualified object names.

How will those object names be resolved during execution?

Snowflake will resolve them according to the SEARCH_PATH parameter.

Snowflake will first check the current schema, and then the PUBLIC schema of the current database.

Snowflake will first check the current schema, and then the schema the previous query used.

Correct answer
Snowflake will only check the schema the UDF belongs to.

Overall explanation
In queries, unqualified object names are resolved using a search path. However, the SEARCH_PATH is not applicable within views or when writing User-Defined Functions (UDFs). Any unqualified objects referenced in a view or UDF definition will be resolved exclusively within the schema of that view or UDF.

For more detailed information, refer to the official Snowflake documentation.

Question 115
Skipped
What does a masking policy consist of in Snowflake?

Correct answer
A single data type, with one or more conditions, and one or more masking functions

Multiple data types, with only one condition, and one or more masking functions

Multiple data types, with one or more conditions, and one or more masking functions

A single data type, with only one condition, and only one masking function

Overall explanation
A masking policy in Snowflake is defined for a specific data type and includes conditions and masking functions that dictate how data is masked based on specified criteria.

For more detailed information, refer to the official Snowflake documentation.

Question 116
Skipped
What happens when the size of a virtual warehouse is changed?

Correct answer
Queries that are running on the current warehouse configuration are not impacted.

Queries that are running on the current warehouse configuration are aborted and have to be resubmitted by the user.

Queries that are running on the current warehouse configuration are aborted and are automatically resubmitted.

Queries that are running on the current warehouse configuration are moved to the new configuration and finished there.

Overall explanation
When the size of a virtual warehouse is changed in Snowflake, the change only affects new queries. Queries already running continue to run on the original configuration without being interrupted.

For more detailed information, refer to the official Snowflake documentation.

Question 117
Skipped
What JavaScript delimiters are available in Snowflake stored procedures? (Choose two.)

Correct selection
Double dollar sign ($$)

Double quotes (“)

Correct selection
Single quote (’)

Double forward slash (//)

Double backslash (\\)

Overall explanation
In Snowflake stored procedures, single quotes are used to define string literals, and double dollar signs are used as delimiters for JavaScript code blocks.

For more detailed information, refer to the official Snowflake documentation.

Question 118
Skipped
What Snowflake function should be used to unload relational data to JSON?

PARSE_JSON()

Correct answer
OBJECT_CONSTRUCT()

TO_VARIANT()

BUILD_STAGE_FILE_URL()

Overall explanation
OBJECT_CONSTRUCT() function should be used to unload relational data to JSON in Snowflake, as it converts the relational data into a JSON-like object format, suitable for exporting or further processing.

For more detailed information, refer to the official Snowflake documentation.

Question 119
Skipped
How often are encryption keys automatically rotated by Snowflake?

365 Days

90 Days

60 Days

Correct answer
30 Days

Overall explanation
Snowflake keys are automatically rotated by Snowflake once they exceed 30 days in age.

For more detailed information, refer to the official Snowflake documentation.

Question 120
Skipped
Which chart type does Snowsight support to visualize worksheet data?

Bubble chart

Pie chart

Correct answer
Scatterplot

Box plot

Overall explanation
Snowsight allows these of charts: bar charts, line charts, scatterplots, heat grids, scorecards.

For more detailed information, refer to the official Snowflake documentation.

Question 121
Skipped
How does Snowflake recommend handling the bulk loading of data batches from files already available in cloud storage?

Use Snowpipe.

Use an external table.

Correct answer
Use the COPY command.

Use the INSERT command.

Overall explanation
Snowflake recommends using the COPY command for bulk loading data from files already available in cloud storage.

For more detailed information, refer to the official Snowflake documentation.

Question 122
Skipped
Which Query Profile operator is considered a DML operator?

Flatten

Sort

ExternalScan

Correct answer
Merge

Overall explanation
MERGE lets you add, change, and delete data in a table based on data in another table or query. This is handy when the second table tracks changes, showing new rows to add, existing rows to update, and rows to delete from the first table.

For more detailed information, refer to the official Snowflake documentation.

Question 123
Skipped
How can a Snowflake user post-process the result of SHOW FILE FORMATS?

Assign the command to RESULTSET.

Correct answer
Use the RESULT_SCAN function.

Put it in the FROM clause in brackets.

Create a CURSOR for the command.

Overall explanation
RESULT_SCAN function allows users to access and post-process the results of the SHOW FILE FORMATS command by referencing the query ID of the SHOW command’s result.

For more detailed information, refer to the official Snowflake documentation.

Question 124
Skipped
What is used to extract the content of PDF files stored in Snowflake stages?

HyperLogLog (HLL) function

FLATTEN function

Correct answer
Java User-Defined Function (UDF)

Window function

Overall explanation
Java UDFs can be used to extract the content of PDF files stored in Snowflake stages, allowing for custom processing and extraction of data from non-standard formats like PDFs.

For more detailed information, refer to the official Snowflake documentation.

Question 125
Skipped
What type of policy states that each object within Snowflake has a unique owner who can grant access to that object?

Mandatory Access Control (MAC)

Correct answer
Discretionary Access Control (DAC)

Rule-Based Access Control (RuBAC)

Role-Based Access Control (RBAC)

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 126
Skipped
Which queries can be executed in parallel using the query acceleration service? (Select TWO).

Small scans that read and write rows very slowly

Queries with complex joins on small tables

Large scans that delete many rows and columns

Correct selection
Large scans that use an aggregation or selective filter

Correct selection
Large scans that insert many new rows

Overall explanation
Snowflake’s Query Acceleration Service (QAS) applies to queries whose execution plans contain segments that can be parallelized using additional compute resources. In practice, this typically includes:

Large table scans combined with aggregations or highly selective filters.

Large-scale scans that insert or copy substantial volumes of data (e.g., bulk INSERT or COPY operations).

QAS improves performance by distributing scan and filter workloads across extra compute, reducing overall wall-clock execution time.

Workloads such as DELETE statements, joins on small datasets, or queries involving only minor scans generally do not benefit, as QAS is optimized specifically for high-volume scan patterns.

For more detailed information, refer to the official Snowflake documentation.

Question 127
Skipped
What is the default STATEMENT_TIMEOUT_IN_SECONDS before a long-running SQL query will be cancelled by the system?

360 seconds (6 minutes)

Correct answer
172800 seconds (2 days)

60 seconds (1 minute)

604800 seconds (7 days)

Overall explanation
Values from 0 to 604800 (7 days) — a value of 0 specifies that the maximum timeout value is enforced.

For more detailed information, refer to the official Snowflake documentation.

Question 128
Skipped
By default, which role has privileges to create tables and views in an account?

SECURITYADMIN

PUBLIC

USERADMIN

Correct answer
SYSADMIN

Overall explanation
By default, the SYSADMIN role has privileges to create tables and views in a Snowflake account. This role is responsible for managing database objects like tables, views, and schemas. SYSADMIN should be the father of all custom roles as well.

For more detailed information, refer to the official Snowflake documentation.

Question 129
Skipped
What unit of storage supports efficient query processing in Snowflake?

Blobs

JSON

Block storage

Correct answer
Micro-partitions

Overall explanation
Snowflake uses micro-partitions as the unit of storage to support efficient query processing. These are small, contiguous units of storage that enable fast data retrieval and optimization of queries by minimizing the amount of data scanned.

For more detailed information, refer to the official Snowflake documentation.

Question 130
Skipped
How does a Snowflake user execute an anonymous block of code?

The SUBMIT command must run immediately after the block is defined.

The user must run the CALL command to execute the block.

The block must be saved to a worksheet and executed using a connector.

Correct answer
The statements that define the block must also execute the block.

Overall explanation
An anonymous block is executed as soon as it is defined, meaning the statements within the block are run immediately after the block is defined without needing any additional commands like CALL or SUBMIT.

For more detailed information, refer to the official Snowflake documentation.

Question 131
Skipped
What is the default length for columns of type BINARY column in Snowflake?

32 MB

Correct answer
64 MB

128 MB

16 MB

Overall explanation
Important: the size limit for each field in a row has changed significantly in 2025.

Based on the official Snowflake documentation, with the current behavior changes in effect as of 2025, the default length for BINARY columns in Snowflake is 64MB.

According to BCR-2118, when this behavior change bundle is enabled, "the default size for binary data types is 64 MB". This represents a significant increase from the previous default of 8 MB.

For more detailed information, refer to the official Snowflake documentation.

Question 132
Skipped
Which function will return a row for each for each object in a VARIANT, OBJECT, or ARRAY column?

GET

Correct answer
FLATTEN

CAST

PARSE_JSON

Overall explanation
FLATTEN function will return a row for each object in a VARIANT, OBJECT, or ARRAY column, allowing users to convert nested data structures into a flat format for easier querying and analysis.

For more detailed information, refer to the official Snowflake documentation.

Question 133
Skipped
Which role can execute the SHOW ORGANIZATION ACCOUNTS command successfully?

SECURITYADMIN

USERADMIN

Correct answer
ORGADMIN

ACCOUNTADMIN

Overall explanation
ORGADMIN role can execute the SHOW ORGANIZATION ACCOUNTS command successfully in Snowflake, as this command is specifically designed for managing and viewing organizational accounts.

For more detailed information, refer to the official Snowflake documentation.

Question 134
Skipped
Which Snowflake feature can be used to identify tables, views, and columns that contain sensitive information by assigning and querying metadata?

Correct answer
Tags

External Tokens

Row access policies

Tag-based masking policies

Overall explanation
Tags are Snowflake’s metadata mechanism for labeling tables, views, and columns—particularly to flag sensitive information.

Because tags can be attached at multiple object levels, they enable centralized discovery: once applied, administrators can query tag metadata to identify all database objects containing classified data. During automated classification, Snowflake may recommend or automatically assign system-defined or custom tags to columns that store sensitive values, allowing ongoing monitoring through metadata queries and tag-related functions.

Other features serve different roles: row access policies and masking policies enforce protection controls, and external tokens relate to authentication. Tags themselves are designed for identification, categorization, and tracking of sensitive data across objects.

For more detailed information, refer to the official Snowflake documentation.

Question 135
Skipped
Which command would return an empty sample?

select * from testtable sample (null);

Correct answer
select * from testtable sample (0);

select * from testtable sample (none);

select * from testtable sample ();

Overall explanation
This command would return an empty sample, as specifying 0 means no rows will be selected from the table.

For more detailed information, refer to the official Snowflake documentation.

Question 136
Skipped
Which role has the ability to create a share from a database by default?

ORGADMIN

SYSADMIN

SECURITYADMIN

Correct answer
ACCOUNTADMIN

Overall explanation
The ACCOUNTADMIN role has the highest level of access in Snowflake and by default, it has the ability to create a share from a database, as it controls account-level operations and resource management.

For more detailed information, refer to the official Snowflake documentation.

Question 137
Skipped
How does the Snowflake search optimization service improve query performance?

It improves the performance of range searches.

It improves the performance of all queries running against a given table.

Correct answer
It improves the performance of equality searches.

It defines different clustering keys on the same source table.

Overall explanation
The Snowflake search optimization service enhances query performance by indexing specific columns to accelerate equality searches, reducing the time needed to locate the requested data.

For more detailed information, refer to the official Snowflake documentation.

Question 138
Skipped
How are URLs that access unstructured data in external stages retrieved?

By using the INFORMATION_USAGE schema

Correct answer
By querying a directory table

From the Snowsight navigation menu

By creating an external function

Overall explanation
URLs that access unstructured data in external stages are retrieved by querying a directory table, which provides metadata and access details for files stored in external stages.

For more detailed information, refer to the official Snowflake documentation.

Question 139
Skipped
What is a characteristic of the Snowflake query profiler?

Correct answer
It provides a graphic representation of the main components of the query processing.

It can be used by third-party software using the query profiler API.

It provides detailed statistics about which queries are using the greatest number of compute resources.

It can provide statistics on a maximum number of 100 queries per week.

Overall explanation
The Snowflake query profiler visually represents the different stages of query processing, helping users understand how their query is being executed and where performance optimizations might be needed.

For more detailed information, refer to the official Snowflake documentation.

Question 140
Skipped
What are the main differences between the account usage views and the information schema views? (Choose two.)

No active warehouse is needed to query account usage views but one is needed to query information schema views.

Correct selection
Data retention for account usage views is 1 year but is 7 days to 6 months for information schema views, depending on the view.

Correct selection
Account usage views contain dropped objects but information schema views do not.

Account usage views do not contain data about tables but information schema views do.

Information schema views are read-only but account usage views are not

Overall explanation
Some account usage views offer historical usage metrics with a retention period of one year (365 days). In comparison, the related views and table functions in the Snowflake Information Schema have significantly shorter retention durations, which can range from 7 days to 6 months, depending on the specific view.

For more detailed information, refer to the official Snowflake documentation.

Question 141
Skipped
What is the difference between a stored procedure and a User-Defined Function (UDF)?

Values returned by a stored procedure can be used directly in a SQL statement while the values returned by a UDF cannot.

Returning a value is required in a stored procedure while returning values in a UDF is optional.

Multiple stored procedures can be called as part of a single executable statement while a single SQL statement can only call one UDF at a time.

Correct answer
Stored procedures can execute database operations while UDFs cannot.

Overall explanation
This is the key difference. Stored procedures can perform complex operations, such as inserting, updating, and deleting data, while UDFs are primarily used to compute and return a value without modifying the database. UDFs are designed to be used within SQL statements, whereas stored procedures are executed independently.

For more detailed information, refer to the official Snowflake documentation.

Question 142
Skipped
What technique does Snowflake recommend for determining which virtual warehouse size to select?

Use the default size Snowflake chooses

Use X-Large or above for tables larger than 1 GB

Always start with an X-Small and increase the size if the query does not complete in 2 minutes



Correct answer
Experiment by running the same queries against warehouses of different sizes

Overall explanation
Snowflake recommends testing queries on different warehouse sizes to determine the optimal performance for your workloads. This allows you to balance query performance and cost efficiency based on actual usage patterns.

For more detailed information, refer to the official Snowflake documentation.

Question 143
Skipped
Which object type is granted permissions for reading a table?

Attribute

Schema

User

Correct answer
Role

Overall explanation
In Snowflake, permissions for reading a table are granted to roles, which are then assigned to users. RBAC model.

For more detailed information, refer to the official Snowflake documentation.

Question 144
Skipped
The following SQL statements have been executed:



What will the output be of the last select statement?

8

4

Correct answer
7

3

Overall explanation
The sequence starts at 1 and increments by 2.

The first SELECT seq_01.nextval will return 1.

The second SELECT seq_01.nextval will return 3.

When inserting into the table using seq_01.nextval, it will return 5.

The final SELECT seq_01.nextval will return 7.

For more detailed information, refer to the official Snowflake documentation.

Question 145
Skipped
Which metadata table will store the storage utilization information even for dropped tables?

DATABASE_STORAGE_USAGE_HISTORY

STORAGE_DAILY_HISTORY

Correct answer
TABLE_STORAGE_METRICS

STAGE_STORAGE_USAGE_HISTORY

Overall explanation
This view provides table-level storage utilization information, which is used to calculate the storage billing for each table in the account, including those that have been dropped but are still incurring storage costs.

The view shows the number of storage bytes billed for each table. Snowflake breaks down these bytes into the following categories: active bytes (data in the table that can be queried) and deleted bytes (data that has been deleted but are still accruing storage charges because they have not yet been purged from the system).

For more detailed information, refer to the official Snowflake documentation.

Question 146
Skipped
A user needs to MINIMIZE the cost of large tables that are used to store transitory data. The data does not need to be protected against failures, because the data can be reconstructed outside of Snowflake.

What table type should be used?

Correct answer
Transient

External

Permanent

Temporary

Overall explanation
A transient table should be used to minimize the cost of large tables that store transitory data. Transient tables do not incur costs for data retention, as they do not have fail-safe protection, making them suitable for data that can be easily reconstructed.

For more detailed information, refer to the official Snowflake documentation.

Question 147
Skipped
How long can a data consumer who has a pre-signed URL access data files using Snowflake?

Until the result_cache expires

Indefinitely

Until the retention_time is met

Correct answer
Until the expiration_time is exceeded

Overall explanation
A pre-signed URL allows a data consumer to access data files only until the expiration_time set for that URL is exceeded. After that, the URL becomes invalid, ensuring limited and controlled access to the data.

For more detailed information, refer to the official Snowflake documentation.

Question 148
Skipped
Which file function provides a URL with access to a file on a stage without the need for authentication and authorization?

BUILD_STAGE_FILE_URL

BUILD_SCOPED_FILE_URL

Correct answer
GET_PRESIGNED_URL

GET_RELATIVE_PATH

Overall explanation
GET_PRESIGNED_URL function provides a URL with access to a file on a stage without the need for additional authentication and authorization, allowing temporary, secure access to the file.

For more detailed information, refer to the official Snowflake documentation.

Question 149
Skipped
If file format options are specified in multiple locations, the load operation selects which option FIRST to apply in order of precedence?

Correct answer
COPY INTO TABLE statement

Session level

Table definition

Stage definition

Overall explanation
If file format options are specified in multiple locations, the load operation applies the options defined in the COPY INTO TABLE statement first, overriding any other settings from the table definition, stage definition, or session level.

For more detailed information, refer to the official Snowflake documentation.

Question 150
Skipped
Which function is used to profile warehouse credit usage?

AUTOMATIC_CLUSTERING_HISTORY

WAREHOUSE_LOAD_HISTORY

Correct answer
WAREHOUSE_METERING_HISTORY

MATERIALIZED_VIEW_REFRESH_HISTORY

Overall explanation
WAREHOUSE_METERING_HISTORY function is used to profile and track warehouse credit usage in Snowflake, providing detailed insights into how credits are consumed over time.

For more detailed information, refer to the official Snowflake documentation.

Question 151
Skipped
Which clustering indicator will show if a large table in Snowflake will benefit from explicitly defining a clustering key?

Ratio

Correct answer
Depth

Total partition count

Percentage

Overall explanation
The clustering depth indicator shows how well-ordered the data is within a large table. A high depth value suggests that the table may benefit from explicitly defining a clustering key to optimize query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 152
Skipped
Which features are included in Snowsight? (Choose three.)

Changing the Snowflake edition

Correct selection
Exploring the Snowflake Marketplace

Changing the Snowflake account cloud provider

Referencing SnowSQL

Correct selection
Downloading query result data larger than 100 MB

Correct selection
Worksheet sharing

Overall explanation
Snowsight allows users to share worksheets easily, enabling collaboration within teams by sharing queries and results directly. Additionally, it provides access to the Snowflake Marketplace, where users can explore and acquire third-party datasets or services to enhance their data projects.

For more detailed information, refer to the official Snowflake documentation.

Question 153
Skipped
What are characteristics of Snowflake directory fables? (Choose two.)

Directory tables can only be used with an external stage.

Directory tables contain copies of staged files in binary format.

Correct selection
Directory tables store file-level metadata about the data files in a stage.

Directory tables are separate database objects.

Correct selection
A directory table can be added to a stage when the stage is created, or later.

Overall explanation
These characteristics indicate that directory tables are designed to hold metadata related to files in a stage, providing flexibility in how they are associated with stages.

For more detailed information, refer to the official Snowflake documentation.

Question 154
Skipped
Which statistics can be used to identify queries that have inefficient pruning? (Choose two.)

Bytes scanned

Percentage scanned from cache

Correct selection
Partitions total

Bytes written to result

Correct selection
Partitions scanned

Overall explanation
The efficiency of pruning can be assessed by comparing the Partitions scanned and Partitions total statistics in the TableScan operators. If the Partitions scanned is a small fraction of the Partitions total, it indicates that pruning is efficient. If the ratio is high or the difference is small, it suggests that pruning was not effective, meaning that many partitions were still scanned despite the pruning attempt.

For more detailed information, refer to the official Snowflake documentation.

Question 155
Skipped
How many resource monitors can be applied to a single virtual warehouse?

Correct answer
One

Eight

Unlimited

Zero

Overall explanation
Snowflake allows only one resource monitor to be applied to a single virtual warehouse but a resource monitor can be set to monitor multiple warehouses.

For more detailed information, refer to the official Snowflake documentation.

Question 156
Skipped
A Snowflake user wants to share transactional data with retail suppliers. However, some of the suppliers do not use Snowflake.

According to best practice, what should the Snowflake user do? (Choose two.)

Correct selection
Provide each non-Snowflake supplier with their own reader account.

Extract the shared transactional data to an external stage and use cloud storage utilities to reload the suppliers' regions.

Deploy a single reader account to be shared by all of the non-Snowflake suppliers.

Create an ETL pipeline that uses select and inserts statements from the source to the target supplier accounts.

Correct selection
Use a data share for suppliers in the same cloud region and a replicated proxy share for other cloud deployments.

Overall explanation
Best practices suggest providing non-Snowflake users with their own reader accounts for secure and isolated access to shared data. Additionally, using data shares and replicated proxy shares ensures efficient and secure data sharing across different regions and cloud environments.

For more detailed information, refer to the official Snowflake documentation.

Question 157
Skipped
Which table function will return the output of a previously-run command?

TASK_HISTORY

Correct answer
RESULT_SCAN

QUERY_HISTORY

FLATTEN

Overall explanation
RESULT_SCAN allows you to treat the output of a recently run command or query as a table, making it easy to process that data further. It's especially useful for working with results from SHOW commands, metadata queries, and stored procedures, saving you from re-running the original query. The results are available for 24 hours.

For more detailed information, refer to the official Snowflake documentation.

Question 158
Skipped
What is the recommended way to obtain a cloned table with the same grants as the source table?

Clone the schema then drop the unwanted tables.

Use an ALTER TABLE command to copy the grants.

Create a script to extract grants and apply them to the cloned table.

Correct answer
Clone the table with the COPY GRANTS command.

Overall explanation
This is the recommended way to obtain a cloned table with the same grants as the source table, as the COPY GRANTS command ensures that the original privileges are transferred to the cloned table automatically

For more detailed information, refer to the official Snowflake documentation.

Question 159
Skipped
Which command should be used when loading many flat files into a single table?

MERGE

Correct answer
COPY INTO

INSERT

PUT

Overall explanation
The COPY INTO command should be used when loading many flat files into a single table in Snowflake, as it is optimized for bulk data loading from staged files.

For more detailed information, refer to the official Snowflake documentation.

Question 160
Skipped
What is the default period of time the Warehouse Activity section provides a graph of Snowsight activity?

1 week

1 month

Correct answer
2 weeks

2 hours

Overall explanation
From 1 hour to 2 weeks (default value).

For more detailed information, refer to the official Snowflake documentation.

Question 161
Skipped
What does SnowCD help Snowflake users to do?

Manage different databases and schemas.

Copy data into files.

Correct answer
Troubleshoot network connections to Snowflake.

Write SELECT queries to retrieve data from external tables.

Overall explanation
SnowCD helps users diagnose and troubleshoot their network connection to Snowflake. This tool assists in identifying network-related issues that might affect connectivity and performance when accessing Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 162
Skipped
Which activities are managed by Snowflake’s Cloud Services layer? (Choose two.)

Data compression

Correct selection
Authentication

Data pruning

Access delegation

Correct selection
Query parsing and optimization

Overall explanation
Snowflake's Cloud Services layer handles authentication for secure access, and it is responsible for query parsing and optimization to ensure efficient query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 163
Skipped
A Snowflake user has a query that is running for a long time. When the user opens the query profiler, it indicates that a lot of data is spilling to disk.

What is causing this to happen?

The cloud storage staging area is not sufficient to hold the data results.

Clustering has not been applied to the table so the table is not optimized.

Correct answer
The warehouse memory is not sufficient to hold the intermediate query results.

The result cache is almost full and is unable to hold the results.

Overall explanation
Spilling to disk occurs when the virtual warehouse does not have enough memory to process the intermediate query results, forcing Snowflake to temporarily store data on disk, which can slow down query performance.

For more detailed information, refer to the official Snowflake documentation.

Local disk space is located on the compute nodes that are used to execute Snowflake queries and remote disk is the permanent storage location for all Snowflake data.

Question 164
Skipped
What is a characteristic of a role in Snowflake?

Correct answer
Privileges on securable objects can be granted and revoked to a role.

Roles cannot be granted to other roles.

Privileges granted to system roles by Snowflake can be revoked.

System-defined roles can be dropped.

Overall explanation
In Snowflake, roles are used to manage access control, allowing privileges on securable objects (like tables, views, etc.) to be granted or revoked as needed. This enables flexible and secure management of user permissions.

For more detailed information, refer to the official Snowflake documentation.

Question 165
Skipped
Which authentication method requires access to a secure file that is only stored on the user's local device?

Correct answer
Key-pair authentication

Federated authentication

Multi-Factor Authentication (MFA)

Password authentication

Overall explanation
Key-pair method uses a private key file stored securely on the user's local device. It is matched against a public key stored in Snowflake, providing secure, password-less authentication.

For more detailed information, refer to the official Snowflake documentation.

Question 166
Skipped
What is the MAXIMUM number of clusters that can be provisioned with a multi-cluster virtual warehouse?

100

1

6

Correct answer
10

Overall explanation
Maximum number of clusters that can be provisioned with a multi-cluster virtual warehouse in Snowflake is 10.

For more detailed information, refer to the official Snowflake documentation.

Question 167
Skipped
Why should a user select the economy scaling policy for a multi-cluster warehouse?

To increase performance of the clusters

To reduce queuing concurrent user queries

Correct answer
To conserve credits by keeping running clusters fully loaded

To prevent/minimize query queuing

Overall explanation
The economy scaling policy in Snowflake ensures that running clusters are fully utilized before additional clusters are started, helping to conserve credits and reduce costs while still handling workloads efficiently.



For more detailed information, refer to the official Snowflake documentation.

Question 168
Skipped
If a virtual warehouse runs for 30 seconds after it is provisioned, how many seconds will the customer be billed for?

30 seconds

1 hour

121 seconds

Correct answer
60 seconds

Overall explanation
Snowflake bills virtual warehouses in 60-second increments. Even though the warehouse ran for only 30 seconds, the customer will be billed for the first minute.

For more detailed information, refer to the official Snowflake documentation.

Question 169
Skipped
Which table type is supported by Open Catalog to provide centralized, read and write access to a table?

Event

Dynamic

Hybrid

Correct answer
Iceberg

Overall explanation
Open Catalog enables centralized governance for Apache Iceberg™ tables while allowing external query engines to perform read and write operations.

With an internal catalog configuration, the Iceberg table is registered in Open Catalog, but the actual data and metadata remain in external cloud storage. Query engines interact directly with the table, using Open Catalog as the Iceberg catalog layer.

Both third-party engines and Snowflake itself can read from and write to these tables. Open Catalog also provides credential vending to securely manage access for these operations.

For more detailed information, refer to the official Snowflake documentation.

Question 170
Skipped
The INFORMATION_SCHEMA included in each database contains which objects? (Choose two.)

Views for historical and usage data across the Snowflake account

Correct selection
Views for all the objects contained in the database

Table functions for account-level objects, such as roles, virtual warehouses, and databases

Correct selection
Table functions for historical and usage data across the Snowflake account

Views for all the objects contained in the Snowflake account

Overall explanation
The INFORMATION_SCHEMA in each database provides metadata views for all objects within that specific database, as well as table functions for managing account-level objects.

For more detailed information, refer to the official Snowflake documentation.