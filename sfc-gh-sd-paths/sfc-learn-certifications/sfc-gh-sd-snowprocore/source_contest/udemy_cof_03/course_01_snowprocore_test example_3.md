Question 1
Incorrect
How does the PARTITION BY option affect an expression for a COPY INTO command?

Correct answer
The unload operation partitions table rows into separate files unloaded to the specified stage.

A single file will be loaded with a user-defined partition key and the user can use this partition key for clustering.

A single file will be loaded with a Snowflake-defined partition key and Snowflake will use this key for pruning.

Your answer is incorrect
The unload operation partitions table rows into separate files unloaded to the specified table.

Overall explanation
The PARTITION BY option in a COPY INTO command divides the table rows into multiple files based on the partitioning expression, which are then unloaded to the specified stage.

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
At what level is the MIN_DATA_RETENTION_TIME_IN_DAYS parameter set?

Schema

Database

Table

Correct answer
Account

Overall explanation
The MIN_DATA_RETENTION_TIME_IN_DAYS parameter is set at the account level, allowing an account-wide default for the minimum data retention period across all tables within the account.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
Which sequence (order) of object privileges should be used to grant a custom role read-only access on a table?



A.



B.



C.



D.




D

B

A

Correct answer
C

Overall explanation
The sequence is: Usage on the database, Usage on the schema, Select on the table

This is the correct order because the role needs access to the database and schema before it can query the table. The SELECT privilege grants the read-only access required for the table. When defining Custom roles, it’s important to follow the principle of least privilege.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
In Snowflake's data security framework, how does column-level security contribute to the protection of sensitive information? (Choose two.)

Correct selection
Column-level security allows the application of a masking policy to a column within a table or view.

Column-level security ensures that only the table owner can access the data.

Correct selection
Column-level security limits access to specific columns within a table based on user privileges.

Column-level security supports encryption of the entire database.

Implementation of column-level security will optimize query performance.

Overall explanation
Column-level security allows you to grant or deny access to individual columns, ensuring that users only see the data they are authorized to view.

Snowflake uses masking policies (which are schema-level objects) to protect sensitive data. Authorized users can still see the real data when they run queries. Importantly, the data in the tables isn't changed (no static masking). Instead, the masking policy decides what unauthorized users see when they query the data – masked, partially masked, fake, or tokenized data.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
What does the TableScan operator represent in the Query Profile?

Correct answer
The access to a single table

The records generated using the TABLE(GENERATOR(..)) construct

The list of values provided with the VALUES clause

The access to data stored in stage objects

Overall explanation
The TableScan operator represents the operation that accesses data from a single table. This operator is responsible for retrieving records from the specified table, indicating how the query interacts with that data source during execution.

For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
Which Snowflake object contains all the information required to share a database?

Private listing

Secure view

Correct answer
Share

Sequence

Overall explanation
A share object includes the necessary permissions and configurations to allow access to a database, making it easy to manage data sharing with other Snowflake accounts.

For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
What is the purpose of an External Function?

Correct answer
To call code that executes outside of Snowflake

To run a function in another Snowflake database

To share data in Snowflake with external parties

To ingest data from on-premises data sources

Overall explanation
The purpose of an External Function in Snowflake is to call code that executes outside of Snowflake. This allows Snowflake to interact with external services, such as AWS Lambda or Azure Functions, to extend the functionality of queries by running custom code or accessing external systems.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
Which of the following features, associated with Continuous Data Protection (CDP), require additional Snowflake-provided data storage? (Choose two.)

Tri-Secret Secure

Data encryption

Correct selection
Time Travel

External stages

Correct selection
Fail-safe

Overall explanation
Time Travel retains historical data for a configurable period, allowing users to access and restore previous versions of data, while Fail-safe provides an additional 7-day recovery period after Time Travel, though only accessible by Snowflake Support. Both features consume additional storage for maintaining historical data.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
Which Query Profile operator provides information on pruning efficiency?

InternalObject

Generator

ExternalScan

Correct answer
TableScan

Overall explanation
Snowflake's pruning feature optimizes queries by skipping unnecessary data based on filters, but it only works if the data's storage order is correlated with the query's filter attributes. You can check the efficiency of pruning by comparing the "Partitions scanned" and "Partitions total" values in a query's TableScan operators; a small ratio indicates efficient pruning, while a high ratio means it had little effect.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
Which term is used to describe information about disk usage for operations where intermediate results cannot be accommodated in a Snowflake virtual warehouse memory?

Correct answer
Spilling

Queue overloading

Join explosion

Pruning

Overall explanation
Spilling occurs when there is insufficient memory in the virtual warehouse to handle all the intermediate data, and Snowflake temporarily stores the data on disk, which can impact query performance.

The Query Profile provides insights such as the overall query execution time, helping users assess performance and troubleshoot issues related to query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
Which statement is true about running tasks in Snowflake?

Correct answer
A task allows a user to execute a single SQL statement/command using a predefined schedule.

A task can be called using a CALL statement to run a set of predefined SQL commands.

A task allows a user to execute a set of SQL commands on a predefined schedule.

A task can be executed using a SELECT statement to run a predefined SQL command.

Overall explanation
In Snowflake, tasks are designed to execute a single SQL statement or command (e.g., queries or DML statements) on a predefined schedule, automating routine operations.

For more detailed information, refer to the official Snowflake documentation.

Question 12
Skipped
How does Snowflake utilize clustering information to improve query performance?

It automatically allocates additional resources to improve query execution.

Correct answer
It prunes unnecessary micro-partitions based on clustering metadata.

It compresses the data within micro-partitions for faster querying.

It organizes clustering information to speed-up data retrieval from storage.

Overall explanation
Snowflake uses clustering information (which tracks the order of data within micro-partitions) to efficiently eliminate micro-partitions that don't contain the data relevant to a query. This "pruning" significantly reduces the amount of data that needs to be scanned, leading to faster, cheaper and more efficient query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
When a Snowflake user loads CSV data from a stage, which COPY INTO [table] command guideline should they follow?

The CSV field delimiter must be a comma character (‘,’).

The data file must have the same number of columns as the target table.

The data file in the stage must be in a compressed format.

Correct answer
The number of columns in each row should be consistent.

Overall explanation
Inconsistent column numbers in CSV rows can cause errors during loading, so it’s essential to maintain a consistent structure across all rows for successful data ingestion.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
How can a Snowflake user load duplicate files with a COPY INTO command?

Correct answer
The COPY INTO options should be set to FORCE = TRUE

The COPY INTO options should be set to ON_ERROR = CONTINUE

The COPY INTO options should be set to RETURN_FAILED_ONLY = FALSE

The COPY INTO options should be set to PURGE = FALSE

Overall explanation
FORCE = TRUE. This option forces Snowflake to load the files again, even if they have already been loaded before. Without this setting, Snowflake will skip files that it recognizes as already loaded to avoid duplicates. By setting FORCE = TRUE, you override this behavior and allow the loading of duplicate files.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
What is the MINIMUM edition of Snowflake that is required to use a SCIM security integration?

Correct answer
Standard Edition

Business Critical Edition

Enterprise Edition

Virtual Private Snowflake (VPS)

Overall explanation
The Standard Edition of Snowflake is the minimum edition required to use SCIM (System for Cross-domain Identity Management) security integration. This allows for automated user provisioning and management through supported identity providers, streamlining identity governance and security management within the platform.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
A sales table FCT_SALES has 100 million records.

The following query was executed:

SELECT COUNT (1) FROM FCT_SALES;

How did Snowflake fulfill this query?

Query against the result set cache

Query against the most-recently created micro-partition

Query against a virtual warehouse cache

Correct answer
Query against the metadata cache

Overall explanation
The query SELECT COUNT(1) FROM FCT_SALES in Snowflake is most likely fulfilled against the metadata cache. For simple aggregation functions like COUNT, Snowflake can use metadata that tracks the number of rows in each micro-partition without scanning the actual data, which significantly speeds up query execution.

Question 17
Skipped
Which command is used to unload data from a table or move a query result to a stage?

Correct answer
COPY INTO

GET

PUT

MERGE

Overall explanation
The command used to unload data from a table or move a query result to a stage in Snowflake is COPY INTO. This command allows you to export data from a table or query result into a stage, whether internal or external, in formats such as CSV, JSON, or Parquet.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
What is the expiration period for a file URL used to access unstructured data in cloud storage?

Correct answer
An unlimited amount of time

The length of time specified in the expiration_time argument

The same length of time as the expiration period for the query results cache

The remainder of the session

Overall explanation
The file URL can remain permanently.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
What kind of value does a User-Defined Function (UDF) return? (Choose two.)

Dictionary

Correct selection
Tabular

Correct selection
Scalar

List

Object

Overall explanation
A UDF in Snowflake can return a single value (scalar), such as a string or number, or a set of rows and columns (tabular) when defined as a table function.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
The following JSON is stored in a VARIANT column called src of the CAR_SALES table:



A user needs to extract the dealership information from the JSON.

How can this be accomplished?

select dealership from car_sales;

select src:Dealership from car_sales;

select src.dealership from car_sales;

Correct answer
select src:dealership from car_sales;

Overall explanation
The syntax uses the colon : to access the dealership key within the JSON structure stored in the src column.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
Which URL type should be used for custom applications that need to access unstructured data files?

Scoped URL

Relative URL

Correct answer
File URL

Pre-signed URL

Overall explanation
File URL is a permanent URL to a file on a stage used to access or download the file via REST API with an authorization token. Ideal for custom applications needing access to unstructured data files.

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
When working with a managed access schema, who has the OWNERSHIP privilege of any tables added to the schema?

The object owner

The database owner

The Snowflake user's role

Correct answer
The schema owner

Overall explanation
In a managed access schema, the schema owner retains the OWNERSHIP privilege of all objects, including tables added to the schema, centralizing privilege management within the schema.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
What is the minimum Snowflake edition required to use Dynamic Data Masking?

Correct answer
Enterprise

Business Critical

Standard

Virtual Private Snowflake (VPC)

Overall explanation
The minimum Snowflake edition required to use Dynamic Data Masking is Enterprise. This feature allows users to mask sensitive data dynamically based on roles and access policies, providing more granular security controls.



For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
How can a user MINIMIZE Continuous Data Protection costs when using large, high-churn, dimension tables?

Create regular tables with default Time Travel and Fail-safe settings.

Create temporary tables and periodically copy them to permanent tables.

Create regular tables with extended Time Travel and Fail-safe settings.

Correct answer
Create transient tables and periodically copy them to permanent tables.

Overall explanation
Big, frequently-changing dimension tables can lead to high CDP (Continuous Data Protection) costs. A solution is to make these tables transient with no Time Travel (set DATA_RETENTION_TIME_IN_DAYS to 0). Then, periodically copy these transient tables into a permanent table. This creates a full backup. Since each backup is protected by CDP, older backups can be deleted when a new one is made.

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
What is a machine learning and data science partner within the Snowflake Partner Ecosystem?

Informatica

Power BI

Adobe

Correct answer
Data Robot

Overall explanation
DataRobot provides advanced machine learning and AI capabilities that integrate with Snowflake to help organizations build, deploy, and scale predictive models efficiently.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
Which command is used to start configuring Snowflake for Single Sign-On (SSO)?

CREATE PASSWORD POLICY

CREATE SESSION POLICY

CREATE NETWORK RULE

Correct answer
CREATE SECURITY INTEGRATION

Overall explanation
CREATE SECURITY INTEGRATION command is used to start configuring Snowflake for Single Sign-On (SSO), allowing integration with external identity providers for authentication.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
Bulk data is being loaded from an external stage every day, using this command:

COPY INTO source_table
FROM s3://source/data/files
STORAGE_INTEGRATION = s3_source_int
FILE_FORMAT = (FORMAT_NAME = source_format)
PATTERN='sales.*[.]csv';


How will the data be loaded?

The source_table will be truncated and all files will be loaded.

Correct answer
Only new files will be loaded, previously-loaded files will be skipped.

All s3://source/data/files/*.csv files will be loaded from a stage.

All files that match the specified format will be appended

Overall explanation
The COPY INTO command maintains per-table load metadata that tracks each processed file. This metadata includes attributes such as file name, size, ETag, number of parsed rows, and the timestamp of the last successful load.

Using this information, Snowflake automatically determines whether a file has already been ingested and skips it by default, thereby preventing duplicate data loads. The load history is retained for 64 days, enabling the system to evaluate prior ingestion status within that window.

COPY does not blindly append every matching file; it only processes files that have not been previously loaded (unless explicitly overridden). File selection can also be restricted via a PATTERN clause, and the command appends data rather than truncating the target table.

For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
Which Snowflake command can be used to unload the result of a query to a single file?

Correct answer
Use COPY INTO with SINGLE = TRUE followed by a GET command to download the file.

Use COPY INTO with SINGLE = TRUE followed by a PUT command to download the file.

Use COPY INTO followed by a GET command to download the file.

Use COPY INTO followed by a PUT command to download the file.

Overall explanation
The COPY INTO command with SINGLE = TRUE ensures the result of a query is unloaded into a single file, and the GET command is used to download that file from the stage.

For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
Which statistics are displayed in a Query Profile that indicate that intermediate results do not fit in memory? (Choose two.)

Partitions scanned

Bytes scanned

Percentage scanned from cache

Correct selection
Bytes spilled to local storage

Correct selection
Bytes spilled to remote storage

Overall explanation
Bytes spilled to local storage, Bytes spilled to remote storage: These statistics in a Query Profile indicate that intermediate results do not fit in memory and have been spilled to either local or remote storage during query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
Which statement describes Snowflake tables?

Snowflake tables require that clustering keys be defined to perform optimally.

Snowflake tables are owned by a user.

Correct answer
Snowflake tables are logical representations of underlying physical data.

Snowflake tables are the physical instantiation of data loaded into Snowflake.

Overall explanation
Tables provide an abstraction layer for the physical data, allowing users to interact with and query the data without needing to manage the underlying physical storage directly. Snowflake handles the storage and optimization behind the scenes, making the tables appear as logical representations to users.

For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
The effects of query pruning can be observed by evaluating which statistics? (Choose two.)

Bytes read from result

Bytes scanned

Correct selection
Partitions scanned

Bytes written

Correct selection
Partitions total

Overall explanation
Partitions scanned, Partitions total: these statistics help evaluate query pruning by showing how many partitions were scanned versus the total available. Effective pruning reduces the number of partitions scanned, optimizing query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
The Snowflake Search Optimization Services supports improved performance of which kind of query?

Queries against large tables where frequent DML occurs

Queries against tables larger than 1 TB

Correct answer
Selective point lookup queries

Queries against a subset of columns in a table

Overall explanation
The Snowflake Search Optimization Service supports improved performance for selective point lookup queries. This service is especially useful for queries that involve filtering on specific values or conditions, as it helps Snowflake quickly locate the relevant data without having to scan the entire table, thus optimizing performance for large datasets.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
What is a core benefit of clustering?

To improve performance by creating a separate file for point lookups

To guarantee uniquely identifiable records in the database

Correct answer
To increase scan efficiency in queries by improving pruning

To provide data redundancy by duplicating micro-partitions

Overall explanation
A core benefit of clustering in Snowflake is to increase scan efficiency in queries by improving pruning. By organizing data within micro-partitions based on the clustering key, Snowflake can more effectively prune unneeded data during query execution, reducing the amount of data scanned and improving query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
In which Snowflake layer does Snowflake reorganize data into its internal optimized, compressed, columnar format?

Cloud Services

Query Processing

Metadata Management

Correct answer
Database Storage

Overall explanation
Snowflake reorganizes data into its internal optimized, compressed, columnar format in the Database Storage layer. This layer is responsible for efficiently storing and compressing data, enabling fast access and retrieval for queries while minimizing storage costs. The data is automatically reorganized in this layer when loaded into Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
When using SnowSQL, which configuration options are required when unloading data from a SQL query run on a local machine? (Choose two.)

Correct selection
output_file

echo

Correct selection
output_format

force_put_overwrite

quiet

Overall explanation
When using SnowSQL to unload data from a SQL query on a local machine, the required configuration options are output_file, which specifies the file where the data will be saved, and output_format, which defines the format (e.g., CSV, JSON) for the data being unloaded. These settings ensure that the data is saved correctly in the desired format on the local machine.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
Why would this SQL command be used in Snowflake?

INSERT INTO table_name VALUES (...), (...), (...)

To update existing column names of the table

Correct answer
To add multiple rows of data into the table

To update existing rows in the table

To add multiple columns to the table

Overall explanation
The INSERT INTO command is a standard Data Manipulation Language (DML) statement used to create new records in a table. When you provide multiple sets of values separated by commas—like VALUES (1, 'a'), (2, 'b'), (3, 'c')—Snowflake inserts each set as a separate row in a single operation.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
Which command removes a role from another role or a user in Snowflake?

ALTER ROLE

USE SECONDARY ROLES

Correct answer
REVOKE ROLE

USE ROLE

Overall explanation
REVOKE ROLE command is used to remove a role from another role or a user in Snowflake, effectively revoking the permissions that the role grants.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
When an object is created in Snowflake, who owns the object?

Correct answer
The current active primary role

The owner of the parent schema

The public role

The user's default role

Overall explanation
In Snowflake, the role that is active at the time of object creation becomes the owner. Ownership privilege grants the ability to drop, alter, and grant or revoke access to an object.

For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
At what levels can a resource monitor be configured? (Choose two.)

Schema

Organization

Database

Correct selection
Virtual warehouse

Correct selection
Account

Overall explanation
Resource Monitor is important topic, you can expect few questions in the exam. A resource monitor in Snowflake can be configured at the Account and Virtual warehouse levels. Resource monitors help track and control credit usage, enabling administrators to monitor and set limits on resource consumption for the entire account or individual warehouses, ensuring efficient use of compute resources.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
A user is unloading data to a stage using this command:

copy into @message from (select object_construct('id', 1, 'first_name', 'Snowflake', 'last_name', 'User', 'city', 'Bozeman')) file_format = (type = json)

What will the output file in the stage be?

Multiple compressed JSON files with a single VARIANT column

A single uncompressed JSON file with multiple VARIANT columns

Multiple uncompressed JSON files with multiple VARIANT columns

Correct answer
A single compressed JSON file with a single VARIANT column

Overall explanation
The output file in the stage will be a single compressed JSON file with a single VARIANT column.

A few comments:

The command uses object_construct, which creates a JSON object, and since the COPY INTO command specifies the file_format = (type = json), the output will be in JSON format.

When unloading data from Snowflake, unloaded data files are compressed using gzip by default, unless compression is explicitly disabled.

We are selecting only one row so the object will be stored as a single row in a VARIANT column in the JSON file.

For more detailed information, refer to the official Snowflake documentation.

Question 41
Skipped
A user has enabled the STRIP_OUTER_ARRAY file format option for the COPY INTO {table} command to remove the outer array structure.

What else will this format option and command do?

Unload the records from separate table rows.

Export data files in smaller chunks.

Correct answer
Load the records into separate table rows.

Ensure each unique element stores values of a single native data type.

Overall explanation
The STRIP_OUTER_ARRAY file format option removes the outer array structure, allowing each record in the array to be loaded into separate rows in the target table.

Question 42
Skipped
Which command can be added to the COPY command to make it load all files, whether or not the load status of the files is known?

LOAD_UNCERTAIN_FILES = TRUE

Correct answer
FORCE = TRUE

FORCE = FALSE

LOAD_UNCERTAIN_FILES = FALSE

Overall explanation
FORCE = TRUE. This option forces Snowflake to load all specified files, even if the files were previously loaded or their load status is unknown, ensuring all data is processed.



For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
Based on Snowflake recommendations, when creating a hierarchy of custom roles, the top-most custom role should be assigned to which role?

ACCOUNTADMIN

USERADMIN

Correct answer
SYSADMIN

SECURITYADMIN

Overall explanation
Snowflake recommends assigning the top-most custom role to the SYSADMIN role, as it is responsible for managing objects such as databases, schemas, and tables, which aligns with the role hierarchy for managing data resources.



For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
Which SQL commands should be used to write a recursive query if the number of levels is unknown? (Choose two.)

Correct selection
WITH

MATCH RECOGNIZE

LISTAGG

QUALIFY

Correct selection
CONNECT BY

Overall explanation
The WITH clause allows you to define a recursive CTE, which can reference itself to iterate through levels of data. CONNECT BY is used for hierarchical queries to traverse parent-child relationships recursively.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
When can user session variables be accessed in a Snowflake scripting procedure?

When the procedure is defined with an argument that has the same name and type as the session variable.

Correct answer
When the procedure is defined to execute as CALLER.

When the procedure is defined as STRICT.

When the procedure is defined to execute as OWNER.

Overall explanation
User session variables can be accessed in a Snowflake scripting procedure when the procedure is defined to execute as CALLER. This allows the procedure to inherit the session context, including variables, from the user who invoked it, enabling access to session-specific data during execution.

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Which table function is used to view all errors encountered during a previous data load?

INFER_SCHEMA

Correct answer
VALIDATE

GENERATOR

QUERY_HISTORY

Overall explanation
The VALIDATE table function in Snowflake is used to view all errors encountered during a previous data load, allowing users to identify issues with data files or formats.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
What can be used to view warehouse usage over time? (Choose two.)

The LOAD HISTORY view

The query history view

The SHOW WAREHOUSES command

Correct selection
The WAREHOUSE_METERING_HISTORY view

Correct selection
The billing and usage tab in the Snowflake web UI

Overall explanation
To view warehouse usage over time, the WAREHOUSE_METERING_HISTORY view can be used to get detailed metrics on warehouse resource consumption, and the billing and usage tab in the Snowflake web UI provides a graphical interface for tracking and visualizing warehouse usage and costs over time. These tools help users monitor resource utilization and optimize performance and cost.

About Snowsight, For more detailed information, refer to the official Snowflake documentation.

About WAREHOUSE_METERING_HISTORY, For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
How does a Snowflake stored procedure compare to a User-Defined Function (UDF)?

A single executable statement can call only two stored procedures. In contrast, a single SQL statement can call multiple UDFs.

Correct answer
A single executable statement can call only one stored procedure. In contrast, a single SQL statement can call multiple UDFs.

A single executable statement can call multiple stored procedures. In contrast, multiple SQL statements can call the same UDFs.

Multiple executable statements can call more than one stored procedure. In contrast, a single SQL statement can call multiple UDFs.

Overall explanation
Stored procedures in Snowflake are used to execute procedural logic and allow for multiple SQL statements, whereas UDFs are designed for simple, reusable logic that can be embedded within queries. UDFs are often used for row-level operations, and multiple UDFs can be called in a single query. Stored procedures are generally used for more complex, multi-step processes.

For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
While preparing to unload data in Snowflake, the file format option can be specified in which commands? (Choose two.)

Correct selection
CREATE STAGE

CREATE SCHEMA

GET

Correct selection
COPY INTO [location]

PUT

Overall explanation
You can specify individual file format options in a few different places within Snowflake: either directly in a table's definition, as part of a named stage's definition, or by including them in a COPY INTO <location> command when unloading data.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
What can a Snowflake user do with the information included in the details section of a Query Profile?

Determine the source system that the queried table is from.

Determine if the query was on structured or semi-structured data.

Correct answer
Determine the total duration of the query.

Determine the role of the user who ran the query.

Overall explanation
The Query Profile provides insights such as the overall query execution time, helping users assess performance and troubleshoot issues related to query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
What does the worksheet and database explorer feature in Snowsight allow users to do?

Correct answer
Move a worksheet to a folder or a dashboard.

Add or remove users from a worksheet.

Combine multiple worksheets into a single worksheet.

Tag frequently accessed worksheets for ease of access.

Overall explanation
The worksheet and database explorer feature in Snowsight allows users to organize their worksheets by moving them into folders or dashboards for better management and accessibility.

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
What is a recommended approach for optimizing query performance in Snowflake?

Use subqueries whenever possible.

Correct answer
Use a smaller number of larger tables rather than a larger number of smaller tables.

Use a large number of joins to combine data from multiple tables.

Select all columns from tables, even if they are not needed in the query.

Overall explanation
Lesser the number of joins between several tables = better performance in general. Additionally, you should avoid querying unnecessary columns and ensure that you are filtering data efficiently. This strategy, combined with other techniques such as clustering and using materialized views, helps improve performance and manage resource usage.

Question 53
Skipped
Which Snowflake edition offers the highest level of security for organizations that have the strictest requirements?

Business Critical

Correct answer
Virtual Private Snowflake (VPS)

Standard

Enterprise

Overall explanation
VPS provides enhanced security features, including a dedicated metadata store and a private cloud environment, making it ideal for organizations that need the most stringent data protection and compliance measures.

For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
When reviewing the load for a warehouse using the load monitoring chart, the chart indicates that a high volume of queries is always queuing in the warehouse.

According to recommended best practice, what should be done to reduce the queue volume? (Choose two.)

Correct selection
Use multi-clustered warehousing to scale out warehouse capacity.

Limit user access to the warehouse so fewer queries are run against it.

Correct selection
Migrate some queries to a new warehouse to reduce load.

Stop and start the warehouse to clear the queued queries.

Scale up the warehouse size to allow queries to execute faster.

Overall explanation
Multi-cluster warehouses are designed to handle high concurrency. When query demand increases, additional clusters can be started to process more queries in parallel, reducing queue times.
Creating another warehouse and routing some queries to it distributes the workload across multiple compute resources, reducing contention and queuing on the original warehouse.

Why the other options are not appropriate:

Scaling up warehouse size increases compute power for individual queries but does not solve concurrency bottlenecks, which are the root cause of queuing.

Stopping and restarting the warehouse interrupts running workloads and does not address the underlying concurrency issue.

Restricting user access is not aligned with Snowflake’s architecture, which is designed to support high concurrency through proper warehouse scaling and workload distribution.

For more detailed information, refer to the official Snowflake documentation.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
What persistent data structures are used by the search optimization service to improve the performance of point lookups?

Correct answer
Search access paths

Clustering keys

Micro-partitions

Equality searches

Overall explanation
Search access paths: These persistent data structures are used by the search optimization service to improve the performance of point lookups by optimizing data access and retrieval.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
What identifiers are supported when creating a Snowflake account identifier? (Choose two.)

Snowflake domain

Account cloud platform

Cloud region

Correct selection
Organization

Correct selection
Account name

Overall explanation
The recommended account identifier format includes the organization name followed by the account name (organization123-account123). Although it's still possible to use the older Snowflake-assigned locator, this legacy format is not advised.

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
What is the CLASSIFY_TEXT Snowflake Cortex LLM function used for?

To extract text from documents

To return a sentiment score

Correct answer
To categorize data based on predefined labels

To generate text completions

Overall explanation
The SNOWFLAKE.CORTEX.CLASSIFY_TEXT function uses a Large Language Model (LLM) to classify a given text string into one of several categories that you provide. You pass in the text and the list of potential labels (categories), and the model returns the best matching label.

For more detailed information, refer to the official Snowflake documentation.

Question 58
Skipped
Which Snowflake tool would be BEST to troubleshoot network connectivity?

SnowSQL

SnowCLI

SnowUI

Correct answer
SnowCD

Overall explanation
SnowCD is specifically designed to help diagnose and troubleshoot network-related issues by providing diagnostic information about network connections between a client and the Snowflake service.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
Which of the following accurately describes shares?

Access to a share cannot be revoked once granted

Data consumers can clone a new table from a share

Correct answer
Tables, secure views, and secure UDFs can be shared

Shares can be shared

Overall explanation
The correct description of shares is that tables, secure views, and secure UDFs can be shared. Shares allow data providers to share these objects securely with consumers. However, shares themselves cannot be shared further, data consumers cannot clone tables from a share, and access to a share can be revoked at any time.

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
What is the MINIMUM Snowflake edition that supports the periodic rekeying of encrypted data?

Standard

Correct answer
Enterprise

Business Critical

Virtual Private Snowflake (VPS)

Overall explanation
In all editions except Standard.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
Which languages require that User-Defined Function (UDF) handlers be written inline? (Choose two.)

Java

Scala

Correct selection
SQL

Correct selection
Javascript

Python

Overall explanation
User-Defined Function (UDF) handlers for Javascript and SQL must be written inline as part of the UDF definition.

For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
What is the MAXIMUM number of days that Snowflake resets the 24-hour retention period for a query result every time the result is used?

1 day

Correct answer
31 days

10 days

60 days

Overall explanation
The maximum number of days that Snowflake resets the 24-hour retention period for a query result every time the result is used is 31 days. This allows query results to be reused without re-executing the query, provided the data and the underlying table structure have not changed.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
How many credits will consume a medium-size warehouse with 2 clusters running in auto-scaled mode for 3 hours, considering that the first cluster runs continuously and the second one runs for 30 minutes in the second hour?

7

24

28

Correct answer
14

Overall explanation
Credit consumption per hour for a medium-size warehouse: 4 credits.

First Cluster: 12 credits.

Second Cluster: 2 credits.

14 credits.



For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
Which Snowflake feature allows administrators to identify unused data that may be archived or deleted?

Data classification

Object tagging

Dynamic Data Masking

Correct answer
Access history

Overall explanation
Access History. This feature provides detailed information on when data was last accessed, helping administrators determine whether certain datasets are no longer actively in use and can be considered for archiving or deletion to optimize storage and performance.

For more detailed information, refer to the official Snowflake documentation.

Question 65
Skipped
A Snowflake user is actively logged into Snowflake when a user-level network policy is assigned to that user.



What will Snowflake do if the user's IP address does not match the user-level network policy rules?

Deactivate the network policy.

Allow the user to continue until the session or login token expires.

Correct answer
Prevent the user from executing additional queries.

Log the user out.

Overall explanation
Once a network policy is applied to your account, Snowflake restricts access based on allowed and blocked lists. Users logging in from blocked networks are denied access, and currently logged-in restricted users are blocked from running queries.

For more detailed information, refer to the official Snowflake documentation.

Question 66
Skipped
What will happen if a Snowflake user suspends the updates to a materialized view?

The queries on that view will return the last stored data.

The queries on that view will return the data with a warning message.

Correct answer
The queries on that view will generate an error message.

The queries on that view will return the data using Time Travel.

Overall explanation
If updates to a materialized view are suspended, queries attempting to use that view will generate an erro

For more detailed information, refer to the official Snowflake documentation.

Question 67
Skipped
Which Snowflake view is used to support compliance auditing?

Correct answer
ACCESS_HISTORY

COPY_HISTORY

QUERY_HISTORY

ROW_ACCESS_POLICIES

Overall explanation
The Snowflake view used to support compliance auditing is ACCESS_HISTORY. This view provides detailed information about who accessed what data, when, and how. It includes information about the objects queried, the users involved, and the roles used, which is essential for monitoring and auditing data access for compliance purposes.

For more detailed information, refer to the official Snowflake documentation.

Question 68
Skipped
What actions can be performed by consumers of shared databases? (Choose two.)

Query Time Travel data on the database.

Edit the comments for the database.

Create a clone of the database.

Correct selection
Query data from the objects in the database.

Correct selection
Create streams on objects in the database.

Overall explanation
Shared databases are read-only. Users can query data but cannot modify it or create objects. Cloning, Time Travel, editing comments, re-sharing, and replication are all unsupported for imported databases and their objects.

For more detailed information, refer to the official Snowflake documentation.

Question 69
Skipped
Which Snowflake virtual warehouse configuration enables horizontal scaling?

Increasing the MIN_CLUSTER_COUNT.

Increasing the MAX_CONCURRENCY_LEVEL.

Correct answer
Increasing the MAX_CLUSTER_COUNT.

Increasing the WAREHOUSE_SIZE.

Overall explanation
MAX_CLUSTER_COUNT parameter to automatically add more compute clusters as the number of concurrent queries increases. This approach allows a warehouse to dynamically manage a fluctuating workload by adding or removing resources as needed, a key difference from vertical scaling, which only increases the size of a single cluster. This setup is particularly effective for environments with unpredictable query loads.

You can operate a multi-cluster warehouse in one of two modes. Maximized mode is configured by setting the minimum and maximum cluster counts to the same value, causing all clusters to start immediately. This is best for large, stable, and consistently high-concurrency workloads. Alternatively, Auto-scale mode is enabled by setting different minimum and maximum values, allowing Snowflake to automatically scale clusters up or down based on the actual demand, which is a more cost-effective solution for dynamic workloads.

For more detailed information, refer to the official Snowflake documentation.

Question 70
Skipped
What criteria does Snowflake use to determine the current role when initiating a session? (Choose two.)

Correct selection
If no role was specified as part of the connection and a default role has been defined for the Snowflake user, that role becomes the current role.

If a role was specified as part of the connection and that role has not been granted to the Snowflake user, it will be ignored and the default role will become the current role.

If no role was specified as part of the connection and a default role has not been set for the Snowflake user, the session will not be initiated and the log in will fail.

Correct selection
If a role was specified as part of the connection and that role has been granted to the Snowflake user, the specified role becomes the current role.

If a role was specified as part of the connection and that role has not been granted to the Snowflake user, the role is automatically granted and it becomes the current role.

Overall explanation
The criteria Snowflake uses to determine the current role when initiating a session are: if a role was specified as part of the connection and that role has been granted to the Snowflake user, the specified role becomes the current role, and if no role was specified as part of the connection and a default role has been defined for the Snowflake user, that role becomes the current role. These rules ensure that the appropriate role is assigned when starting a session based on connection details and user settings.

For more detailed information, refer to the official Snowflake documentation.

Question 71
Skipped
What is the PRIMARY factor that determines the cost of using a virtual warehouse in Snowflake?

The number of tables or databases queried

The type of SQL statements executed

Correct answer
The length of time the compute resources in each cluster run

The amount of data stored in the warehouse

Overall explanation
Virtual warehouse costs are primarily based on how long the compute resources are active, as charges accrue based on usage time rather than data storage or query complexity.

For more detailed information, refer to the official Snowflake documentation.

Question 72
Skipped
How can a Snowsight user change a Standard virtual warehouse to a Snowpark-optimized virtual warehouse?

Use the ALTER WAREHOUSE command on a suspended Snowpark-optimized warehouse.

Correct answer
Use the ALTER WAREHOUSE command on a suspended Standard virtual warehouse.

Use the ALTER WAREHOUSE command on an active Snowpark-optimized warehouse.

Use the ALTER WAREHOUSE command on an active Standard virtual warehouse.

Overall explanation
To change a Standard virtual warehouse to a Snowpark-optimized one, the warehouse must be in a suspended state before using the ALTER WAREHOUSE command for the modification.

For more detailed information, refer to the official Snowflake documentation.

Question 73
Skipped
A user needs to ingest 1 GB of data that is available in an external stage using a COPY INTO command.

How can this be done with MAXIMUM performance and the LEAST cost?

Ingest the data in an uncompressed format as a single file.

Ingest the data in a compressed format as a single file.

Split the file into smaller files of 100-250 MB each and ingest each of the smaller files in an uncompressed format.

Correct answer
Split the file into smaller files of 100-250 MB each, compress and ingest each of the smaller files.

Overall explanation
Common question. Best option is to split the file into smaller files of 100-250 MB each, compress them, and ingest each of the smaller files. This approach optimizes performance by allowing Snowflake to process the data in parallel and reduces costs by minimizing the amount of data scanned and processed, especially when using compressed formats.

For more detailed information, refer to the official Snowflake documentation.

Question 74
Skipped
What are the least privileges needed to view and modify resource monitors? (Choose two.)

USAGE

Correct selection
MONITOR

SELECT

Correct selection
MODIFY

OWNERSHIP

Overall explanation
Resource monitors are, by default, limited to creation by account administrators. Consequently, only these administrators can view and manage them.

Nonetheless, roles that possess the necessary privileges on specific resource monitors are able to view and adjust these monitors as needed through SQL commands. The required privileges include MONITOR and MODIFY.

For more detailed information, refer to the official Snowflake documentation.

Question 75
Skipped
Which function returns an integer between 0 and 100 when used to calculate the similarity of two strings?

APPROXIMATE_JACCARD_INDEX

MINHASH_COMBINE

APPROXIMATE_SIMILARITY

Correct answer
JAROWINKLER_SIMILARITY

Overall explanation
JAROWINKLER_SIMILARITY function returns an integer between 0 and 100 when calculating the similarity between two strings, with higher values indicating greater similarity.

For more detailed information, refer to the official Snowflake documentation.

Question 76
Skipped
What SQL command can be used to list the contents of a named stage called my_table?

LIST @%my_table;
Correct answer
LIST @my_table;
LIST %my_table;
LIST @~my_table;
Overall explanation
A few comments:

In Snowflake, the LIST command (or its alias LS) is used to view files in a stage. To reference a Named Stage (a standalone stage object created with CREATE STAGE), you simply prefix the stage name with the @ symbol.

@% syntax refers to a Table Stage. A table stage is a stage automatically allocated to a specific table for loading data, not a general "named stage."

@~ syntax refers to the User Stage, which is a personal storage area for the current user. It does not accept a name after the tilde in this way.

For more detailed information, refer to the official Snowflake documentation.

Question 77
Skipped
Which Snowflake feature provides increased login security for users connecting to Snowflake that is powered by Duo Security service?

Okta

OAuth

Correct answer
Multi-Factor Authentication (MFA)

Single Sign-On (SSO)

Overall explanation
Snowflake has integrated Duo Security to provide MFA, which requires users to verify their identity using a second factor (like a code from a mobile app or a push notification) in addition to their password. This significantly enhances login security.

For more detailed information, refer to the official Snowflake documentation.

Question 78
Skipped
What is the purpose of a resource monitor in Snowflake?

To monitor the query performance of virtual warehouses

To create and suspend virtual warehouses automatically

Correct answer
To control costs and credit usage by virtual warehouses

To manage cloud services needed for virtual warehouses

Overall explanation
A resource monitor in Snowflake is used to track and limit the consumption of credits by virtual warehouses, helping to manage costs and prevent excessive usage.

For more detailed information, refer to the official Snowflake documentation.

Question 79
Skipped
When cloning a database containing stored procedures and regular views, that have fully qualified table references, which of the following will occur?

An error will occur, as stored objects cannot be cloned.

The cloned views and the stored procedures will reference the cloned tables in the cloned database.

An error will occur, as views with qualified references cannot be cloned.

Correct answer
The stored procedures and views will refer to tables in the source database.

Overall explanation
When cloning a database containing stored procedures and regular views with fully qualified table references, the stored procedures and views will refer to tables in the source database. Fully qualified references maintain links to the original source objects rather than the cloned versions unless manually updated to reference the cloned database. This ensures that the cloned objects function as they did in the source database, without automatically pointing to the cloned tables.

For more detailed information, refer to the official Snowflake documentation.

Question 80
Skipped
What information is found within the Statistic output in the Query Profile Overview?

Correct answer
Table pruning

Nodes by execution time

Operator tree

Most expensive nodes

Overall explanation
The Statistic output in the Query Profile Overview provides information on table pruning, which indicates how effectively Snowflake has eliminated unnecessary micro-partitions during query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 81
Skipped
What should be considered when deciding to use a Secure View? (Choose two.)

The view definition of a secure view is still visible to users by way of the information schema.

Correct selection
No details of the query execution plan will be available in the query profiler.

It is not possible to create secure materialized views.

Once created there is no way to determine if a view is secure or not.

Correct selection
Secure views do not take advantage of the same internal optimizations as standard views.

Overall explanation
When deciding to use a Secure View in Snowflake, consider that no details of the query execution plan will be available in the query profiler, which hides the query logic and execution details for security purposes. Additionally, secure views do not take advantage of the same internal optimizations as standard views, which can lead to performance trade-offs. These factors ensure enhanced security but may impact the performance and transparency of query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 82
Skipped
Which services does the Snowflake Cloud Services layer manage? (Choose two.)

Compute resources

Data storage

Correct selection
Metadata

Query execution

Correct selection
Authentication

Overall explanation
Authentication ensures secure access to the platform, while metadata management handles query optimization, transaction control, and other key services that ensure efficient data operations.

For more detailed information, refer to the official Snowflake documentation.

Question 83
Skipped
When unloading data with the COPY INTO command, what is the purpose of the PARTITION BY parameter option?

To delimit the records in the output file using the specified expression.

To sort the contents of the output file by the specified expression.

To include a new column in the output using the specified window function expression.

Correct answer
To split the output into multiple files, one for each distinct value of the specified expression.

Overall explanation
The PARTITION BY parameter in the COPY INTO command is used to divide the data into multiple output files based on distinct values of the specified expression.

For more detailed information, refer to the official Snowflake documentation.

Question 84
Skipped
Which statements are correct concerning the leveraging of third-party data from the Snowflake Data Marketplace? (Choose two.)

Data is not available for copying or moving to an individual Snowflake account.

Data needs to be loaded into a cloud provider as a consumer account.

Data transformations are required when combining Data Marketplace datasets with existing data in Snowflake.

Correct selection
Data is available without copying or moving.

Correct selection
Data is live, ready-to-query, and can be personalized.

Overall explanation
Data is live, ready-to-query, and can be personalized, allowing users to access and analyze it immediately. Additionally, data is available without copying or moving, meaning users can query the data directly without needing to import it into their own Snowflake accounts, which simplifies access and reduces overhead.

For more detailed information, refer to the official Snowflake documentation.

Question 85
Skipped
Which Query Profile result indicates that a warehouse is sized too small?

Correct answer
Bytes are spilling to external storage.

The number of processed rows is very high.

The number of partitions scanned is the same as partitions total.

There are a lot of filter nodes.

Overall explanation
Bytes are spilling to external storage indicates that a warehouse is sized too small. This happens when the warehouse doesn't have enough memory to handle the query's workload, forcing data to be stored externally, which impacts performance.

For more detailed information, refer to the official Snowflake documentation.

Question 86
Skipped
Where can a user find and review the failed logins of a specific user for the past 30 days?

Correct answer
The LOGIN_HISTORY view in ACCOUNT_USAGE

The SESSIONS view in ACCOUNT_USAGE

The ACCESS_HISTORY view in ACCOUNT_USAGE

The USERS view in ACCOUNT_USAGE

Overall explanation
LOGIN_HISTORY view in the ACCOUNT_USAGE schema. This view provides detailed information about login attempts, including both successful and failed logins, allowing users to track and audit access attempts for specific accounts.

For more detailed information, refer to the official Snowflake documentation.

Question 87
Skipped
A single user of a virtual warehouse has set the warehouse to auto-resume and auto-suspend after 10 minutes. The warehouse is currently suspended and the user performs the following actions:

1. Runs a query that takes 3 minutes to complete

2. Leaves for 15 minutes

3. Returns and runs a query that takes 10 seconds to complete

4. Manually suspends the warehouse as soon as the last query was completed

When the user returns, how much billable compute time will have been consumed?

10 minutes

Correct answer
14 minutes

4 minutes

24 minutes

Overall explanation
3 Minutes for running first time (starting the WH and first execution)

Leave for 15 minutes. WH will be iddle after 10 mins. ==> 10 + 3

New execution = Minimum 1 minute billed.

--------------------

10+3+1 = 14

For more detailed information, refer to the official Snowflake documentation.

Question 88
Skipped
A user has created a dashboard in Snowflake and wants to share it with colleagues.



How can the dashboard be shared?

Correct answer
By using the share option within Snowsight

By using a Direct Share with another account

By creating a private Data Exchange

By creating a listing on Snowflake Marketplace

Overall explanation
Dashboards created in Snowsight can be shared with your colleagues by using the built-in share option, which allows for collaboration within the same account or across accounts, depending on the permissions.

For more detailed information, refer to the official Snowflake documentation.

Question 89
Skipped
How does Snowflake improve the performance of queries that are designed to filter out a significant amount of data?

Correct answer
The use of pruning

By increasing the number of partitions scanned

The use of TableScan

The use of indexing

Overall explanation
Snowflake improves query performance by pruning, which skips over micro-partitions that are not needed for the query, reducing the amount of data scanned and speeding up the query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 90
Skipped
Which of the following objects can be directly restored using the UNDROP command? (Choose two.)

Internal stage

Correct selection
Schema

Correct selection
Table

View

User

Overall explanation
The objects that can be directly restored using the UNDROP command in Snowflake are Schema and Table. These objects can be recovered after being dropped, provided they are within the Time Travel retention period, allowing users to revert accidental deletions of important data and structures.



For more detailed information, refer to the official Snowflake documentation.

Question 91
Skipped
When does a materialized view get suspended in Snowflake?

When a column is added to the base table

Correct answer
When a column is dropped from the base table

When a DML operation is run on the base table

When the base table is reclustered

Overall explanation
Changes that significantly affect the structure of the base table, like dropping columns, can invalidate the materialized view, making it temporarily unavailable. Other operations, such as adding columns or running DML operations on the base table, do not cause the materialized view to suspend but may trigger a refresh instead.

For more detailed information, refer to the official Snowflake documentation.

Question 92
Skipped
What is true about sharing data in Snowflake? (Choose two.)

The Data Consumer pays for data storage as well as for data computing.

Correct selection
The Data Consumer pays only for compute resources to query the shared data.

The Provider is charged for compute resources used by the Data Consumer to query the shared data.

Correct selection
A Snowflake account can both provide and consume shared data.

The shared data is copied into the Data Consumer account, so the Consumer can modify it without impacting the base data of the Provider.

Overall explanation
In Snowflake, a Snowflake account can both provide and consume shared data, enabling seamless data collaboration between accounts. Additionally, the Data Consumer pays only for compute resources to query the shared data, while the Provider retains control over the data and is not charged for the Consumer's compute usage. The shared data is not copied into the Consumer's account, ensuring that the original data remains untouched.

For more detailed information, refer to the official Snowflake documentation.

Question 93
Skipped
A user created a transient table and made several changes to it over the course of several days. Three days after the table was created, the user would like to go back to the first version of the table.

How can this be accomplished?

Use the FAIL_SAFE parameter for Time Travel to retrieve the data from Fail-safe storage.

Use Time Travel, as long as DATA_RETENTION_TIME_IN_DAYS was set to at least 3 days.

Contact Snowflake Support to have the data retrieved from Fail-safe storage.

Correct answer
The transient table version cannot be retrieved after 24 hours.

Overall explanation
Transient tables do not have Fail-safe, and their Time Travel retention period is limited to a maximum of 24 hours, meaning changes older than that cannot be recovered.



For more detailed information, refer to the official Snowflake documentation.

Question 94
Skipped
Which applications can use key pair authentication? (Choose two).

Snowflake Marketplace

SnowCD

Correct selection
SnowSQL

Snowsight

Correct selection
Snowflake connector for Python

Overall explanation
SnowSQL, Snowflake connector for Python: Both applications support key pair authentication, which provides an additional layer of security by allowing users to authenticate without using passwords. This method utilizes a public-private key pair to establish secure connections, making it ideal for automated processes and secure client-server communication.

For more detailed information, refer to the official Snowflake documentation.

Question 95
Skipped
Which feature is integrated to support Multi-Factor Authentication (MFA) at Snowflake?

Authy

RSA SecurID Access

Correct answer
Duo Security

One Login

Overall explanation
Snowflake integrates with Duo to provide enhanced security by requiring users to verify their identity through a second authentication factor, helping to protect against unauthorized access.

For more detailed information, refer to the official Snowflake documentation.

Question 96
Skipped
How can staged files be removed during data loading once the files have loaded successfully?

Correct answer
Use the PURGE copy option.

Use the LOAD_UNCERTAIN_FILES copy option.

Use the DROP command.

Use the FORCE = TRUE parameter.

Overall explanation
Files in a Snowflake stage (user, table, or named) can be deleted either during a successful load (using the PURGE option in the COPY INTO <table> command) or after the load is complete (using the REMOVE command).

For more detailed information, refer to the official Snowflake documentation.

Question 97
Skipped
By default, which role allows a user to manage a Snowflake Data Exchange share?

SECURITYADMIN

USERADMIN

Correct answer
ACCOUNTADMIN

SYSADMIN

Overall explanation
By default, the ACCOUNTADMIN role allows a user to manage a Snowflake Data Exchange share, as it has the highest level of permissions for managing account-level objects and resources.

For more detailed information, refer to the official Snowflake documentation.

Question 98
Skipped
A company needs to allow some users to see Personally Identifiable Information (PII) while limiting other users from seeing the full value of the PII.

Which Snowflake feature will support this?

Role based access control

Row access policies

Data encryption

Correct answer
Data masking policies

Overall explanation
Data masking policies dynamically mask sensitive data based on the user’s role, ensuring that only authorized users can view the full values, while others see obfuscated or masked data, protecting sensitive information.



For more detailed information, refer to the official Snowflake documentation.

Question 99
Skipped
How does a Snowflake user reference a directory table created on stage mystage in a SQL query?

SELECT * FROM @mystage::DIRECTORY

SELECT * FROM TO_TABLE (DIRECTORY @mystage)

SELECT * FROM TABLE (@mystage DIRECTORY)

Correct answer
SELECT * FROM DIRECTORY (@mystage)

Overall explanation
This query accesses the directory table associated with the specified stage, allowing the user to retrieve the relevant file information stored in the stage.

For more detailed information, refer to the official Snowflake documentation.

Question 100
Skipped
Which database objects can be shared with Secure Data Sharing? (Choose two.)

Views

Correct selection
External tables

External stages

Correct selection
Dynamic tables

Materialized views

Overall explanation
In the SnowPro Core certification exams it is normal to have questions related to Data Sharing and some of its particularities. For example, which objects can be cloned and which cannot.

For more detailed information, refer to the official Snowflake documentation.

Question 101
Skipped
What step can reduce data spilling in Snowflake?

Increasing the amount of remote storage for the virtual warehouse

Using a Common Table Expression (CTE) instead of a temporary table

Increasing the virtual warehouse maximum timeout limit

Correct answer
Using a larger virtual warehouse

Overall explanation
Increasing the size of the virtual warehouse can provide more memory and computational resources, reducing the likelihood of data spilling, which occurs when there is insufficient memory to handle the data during query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 102
Skipped
What Snowflake features allow virtual warehouses to handle high concurrency workloads? (Choose two.)

The use of warehouse indexing

Correct selection
Use of multi-clustered warehouses

The ability to resize warehouses

Correct selection
The use of warehouse auto scaling

The ability to scale up warehouses

Overall explanation
Auto scaling adjusts warehouse number of clusters based on workload demands, while multi-clustered warehouses automatically add additional clusters to manage increased concurrency, ensuring optimal performance under heavy query loads.

For more detailed information, refer to the official Snowflake documentation.

Question 103
Skipped
In an auto-scaling multi-cluster virtual warehouse with the setting SCALING_POLICY = ECONOMY enabled, when is another cluster started?

When the system has enough load for 8 minutes

Correct answer
When the system has enough load for 6 minutes

When the system has enough load for 10 minutes

When the system has enough load for 2 minutes

Overall explanation
In an auto-scaling multi-cluster virtual warehouse with SCALING_POLICY = ECONOMY enabled, another cluster is started when the system has enough load for 6 minutes.

For more detailed information, refer to the official Snowflake documentation.



Question 104
Skipped
Which action can be performed by the SYSADMIN role without requiring elevated privileges from the ACCOUNTADMIN or SECURITYADMIN role?

Granting privileges

Correct answer
Managing virtual warehouses

Creating a new user

Viewing billing and usage information

Overall explanation
The SYSADMIN role has built-in privileges to create and manage core account objects, including virtual warehouses. By default, it can create warehouses without requiring privileges from ACCOUNTADMIN or SECURITYADMIN.

Its scope covers infrastructure-level object management such as databases, schemas, tables, and warehouses.

Other administrative functions are delegated to separate roles:

Granting or revoking privileges is associated with SECURITYADMIN, which holds the global MANAGE GRANTS capability.

Creating users falls under USERADMIN or roles explicitly granted CREATE USER.

Accessing billing or usage details is reserved for ACCOUNTADMIN.

SYSADMIN is therefore specifically positioned to manage compute resources like virtual warehouses independently.

For more detailed information, refer to the official Snowflake documentation.

Question 105
Skipped
When would Snowsight automatically detect if a target account is in a different region and enable cross-cloud auto-fulfillment?

When using a paid listing on the Snowflake Marktetplace

When using a Direct Share with another account

Correct answer
When using a private listing on the Snowflake Marketplace

When using a personalized listing on the Snowflake Marketplace

Overall explanation
For all listings shared with specific consumer accounts, Snowsight automatically detects if the target account is in a different region and enables auto-fulfillment. It is not possible to manually replicate private listings to other regions.

For more detailed information, refer to the official Snowflake documentation.

Question 106
Skipped
In order to access Snowflake Marketplace listings, who needs to accept the Snowflake Consumer Terms of Service?

ACCOUNTADMIN

SYSADMIN

SECURITYADMIN

Correct answer
ORGADMIN

Overall explanation
The ORGADMIN role is responsible for accepting the Snowflake Consumer Terms of Service, as this role manages organization-wide settings and agreements, including access to the Snowflake Marketplace.

For more detailed information, refer to the official Snowflake documentation.

Question 107
Skipped
Which COPY INTO command outputs the data into one file?

MULTIPLE=FALSE

MAX_FILE_NUMBER=1

Correct answer
SINGLE=TRUE

FILE_NUMBER=1

Overall explanation
SINGLE=TRUE. This option ensures that the data is written to a single file when unloading data from Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 108
Skipped
Which is the minimum Fail-safe retention time period for transient tables?

Correct answer
0 days

12 hours

1 day

7 days

Overall explanation
The minimum Fail-safe retention time period for transient tables in Snowflake is 0 days. Transient tables do not have a Fail-safe period, meaning they are not protected by the Fail-safe feature once dropped or after their Time Travel retention period expires.



For more detailed information, refer to the official Snowflake documentation.

Question 109
Skipped
Which database objects can be shared with the Snowflake secure data sharing feature? (Choose two.)

Correct selection
Secure User-Defined Functions (UDFs)

Sequences

Correct selection
External tables

Streams

Files

Overall explanation
The database objects that can be shared using Snowflake's secure data sharing feature are External tables and Secure User-Defined Functions (UDFs). These objects can be securely shared with other Snowflake accounts without replicating the data, ensuring efficient data collaboration and management.

For more detailed information, refer to the official Snowflake documentation.

Question 110
Skipped
What are ways to create and manage data shares in Snowflake? (Choose two.)

Using the CREATE SHARE AS SELECT * FROM TABLE command

Correct selection
Through the Snowflake web interface (UI)

Correct selection
Through SQL commands

Through the ENABLE_SHARE=TRUE parameter

Through the DATA_SHARE=TRUE parameter

Overall explanation
The two ways to create and manage data shares in Snowflake are through the Snowflake web interface (UI), which provides a graphical interface for ease of use, and through SQL commands, allowing users to programmatically create and manage shares using commands like CREATE SHARE. These methods offer flexibility for both manual and automated data sharing management within Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 111
Skipped
How can a dropped internal stage be restored?

Clone the dropped stage.

Enable Time Travel.

Correct answer
Recreate the dropped stage.

Execute the UNDROP command.

Overall explanation
Internal stages cannot be restored using Time Travel or the UNDROP command, so the only option is to manually recreate the dropped stage. It’s possible to undrop DB, SCHEMA, TABLE, also ACCOUNT and TAG.

For more detailed information, refer to the official Snowflake documentation.

Question 112
Skipped
What is a limitation of a Materialized View?

A Materialized View cannot support any aggregate functions

A Materialized View cannot be joined with other tables

Correct answer
A Materialized View cannot be defined with a JOIN

A Materialized View can only reference up to two tables

Overall explanation
While Materialized Views can significantly improve query performance by precomputing and storing the results of queries, they do not support complex queries involving joins across multiple tables.

For more detailed information, refer to the official Snowflake documentation.

Question 113
Skipped
Which user preferences can be set for a user profile in Snowsight? (Choose two.)

Default database

Correct selection
Notifications

Username

Default schema

Correct selection
Multi-Factor Authentication (MFA)

Overall explanation
Multi-Factor Authentication (MFA), Notifications preferences can be set in a Snowsight user profile, allowing users to manage security settings like MFA and control notifications for various events.

For more detailed information, refer to the official Snowflake documentation.

Question 114
Skipped
What does the LATERAL modifier for the FLATTEN function do?

Casts the values of the flattened data

Correct answer
Joins information outside the object with the flattened data

Retrieves a single instance of a repeating element in the flattened data

Extracts the path of the flattened data

Overall explanation
The LATERAL modifier for the FLATTEN function in Snowflake allows the query to join the output of the FLATTEN function with information outside the object being flattened. This enables more complex queries where elements within a semi-structured data set can be combined with other data, creating more dynamic and powerful query results.

For more detailed information, refer to the official Snowflake documentation.

Question 115
Skipped
How is data protected in Snowflake throughout its lifecycle? (Choose two.)

Users are responsible for encrypting data before uploading to Snowflake.

Correct selection
Snowflake automatically encrypts data locally before copying the data to the cloud over an encrypted connection.

Correct selection
Snowflake automatically rotates keys pairs regularly, using a hierarchical key model stored in a hardware security module.

Users are responsible for uploading and configuring key pair rotation schedules and key sizes to encrypt stored data.

Snowflake automatically tags and masks Personal Identifiable Information (PII).

Overall explanation
Data in Snowflake's internal stages is automatically encrypted on the server side using AES-256. Additionally, Snowflake provides an extra layer of client-side encryption, with a default key size of 128-bit that can be configured to 256-bit.

This documentation article is essential to understand one of the main features of Snowflake CDP (Continuous Data Protection).

For more detailed information, refer to the official Snowflake documentation.

Question 116
Skipped
Why would a Snowflake user create a secure view instead of a standard view?

Secure views support additional functionality that is not supported for standard views, such as column masking and row level access policies.

With a secure view, the underlying data is replicated to a separate storage layer with enhanced encryption.

The secure view is only available to end users with the corresponding SECURE_ACCESS property.

Correct answer
End users are unable to see the view definition, and internal optimizations differ with a secure view.

Overall explanation
Secure views protect the underlying query logic, preventing users from accessing or altering it, and are optimized for enhanced security and privacy, ensuring sensitive data is protected from unauthorized access.

For more detailed information, refer to the official Snowflake documentation.

Question 117
Skipped
What kind of authentication do Snowpipe REST endpoints use?

Single Sign-On (SSO)

OAuth

Correct answer
Key-pair

Username and password

Overall explanation
Key pair authentication uses a public key to encrypt data and a private key to sign it. The recipient can verify the signature using the public key. This ensures secure and trusted communication, as seen in Snowpipe with JWTs.

For more detailed information, refer to the official Snowflake documentation.

Question 118
Skipped
What COPY INTO SQL command should be used to unload data into multiple files?

MULTIPLE=FALSE

SINGLE=TRUE

Correct answer
SINGLE=FALSE

MULTIPLE=TRUE

Overall explanation
SINGLE=FALSE option ensures that the data is distributed across multiple output files rather than being written into a single file, optimizing performance for large datasets and parallel processing.

For more detailed information, refer to the official Snowflake documentation.

Question 119
Skipped
Which Snowsight feature can be used to perform data manipulations and transformations using a programming language?

Dashboards

Correct answer
Python worksheets

SnowSQL

Provider Studio

Overall explanation
Python worksheets allow you to use Snowpark Python within Snowsight to perform data manipulations and transformations. You can utilize third-party packages available in the Snowflake Anaconda channel or import your own Python files from stages to use in your scripts. This flexibility enables custom processing and the integration of external libraries directly within your Snowflake environment.

For more detailed information, refer to the official Snowflake documentation.

Question 120
Skipped
What impacts the credit consumption of maintaining a materialized view? (Choose two.)

How often the underlying base table is queried

Correct selection
How often the base table changes

Correct selection
Whether the materialized view has a cluster key defined

Whether or not it is also a secure view

How often the materialized view is queried

Overall explanation
The credit consumption of maintaining a materialized view in Snowflake is impacted by how often the base table changes, as changes in the base table require the materialized view to be updated, and whether the materialized view has a cluster key defined, because clustering adds additional computational overhead for maintaining the view's performance and efficiency.

For more detailed information, refer to the official Snowflake documentation.

Question 121
Skipped
Which data protection feature should only be used when all other data recovery options have been attempted?

Cloning

Time Travel

Correct answer
Fail-safe

Replication

Overall explanation
Fail-safe provides a fixed 7-day window, starting right after the Time Travel period ends, during which Snowflake may recover historical data if necessary. This period cannot be configured or shortened.

For more detailed information, refer to the official Snowflake documentation.

Question 122
Skipped
What takes the highest precedence in Snowflake file format options, when specified in multiple locations during data loading?

The use of a COPY INTO [location] statement

Correct answer
The use of a COPY INTO [table] statement

The stage definition

The table definition

Overall explanation
If we specify file format or copy options in multiple places, the load operation follows this order of precedence:

COPY INTO TABLE statement

Stage definition

Table definition

We have to take into account that file format options are not cumulative; the options we set higher in the precedence order override those set lower.
For more detailed information, refer to the official Snowflake documentation.

Question 123
Skipped
What Snowflake objects can contain custom application logic written in JavaScript? (Choose two.)

Correct selection
User-Defined Functions (UDFs)

Tasks

Stages

Views

Correct selection
Stored procedures

Overall explanation
We can extend the SQL you use in Snowflake by writing user-defined functions (UDFs) and stored procedures that can be called from SQL. When writing a UDF or procedure, we define its logic in one of the supported handler languages, such as JavaScript, and then create it using SQL.

For more detailed information, refer to the official Snowflake documentation.

Question 124
Skipped
How can the Query Profile be used to identify the costliest operator of a query?

Select any node in the operator tree and look at the number of micro-partitions scanned.

Correct answer
Find the operator node with the highest fraction of time or percentage of total time.

Look at the number of rows between operator nodes across the operator tree.

Select the TableScan operator node and look at the percentage scanned from cache.

Overall explanation
In the Query Profile, the costliest operator is typically identified by the one that consumes the highest percentage of the total query time. This helps pinpoint where the most resources are being used during query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 125
Skipped
Which virtual warehouse consideration can help lower compute resource credit consumption?

Resizing the virtual warehouse to a larger size

Increasing the maximum cluster count parameter for a multi-cluster virtual warehouse

Correct answer
Automating the virtual warehouse suspension and resumption settings

Setting up a multi-cluster virtual warehouse

Overall explanation
Automating the virtual warehouse suspension and resumption settings will help lower compute resource credit consumption by ensuring that the virtual warehouse is only active when needed and is automatically suspended during idle periods to avoid unnecessary credit usage.

For more detailed information, refer to the official Snowflake documentation.

Question 126
Skipped
Which of the following significantly improves the performance of selective point lookup queries on a table?

Correct answer
Search Optimization Service

Zero-copy Cloning

Clustering

Materialized Views

Overall explanation
Search Optimization Service allows Snowflake to enhance query performance by optimizing access to specific rows or data points in large tables without requiring full table scans, making point lookups much faster.

For more detailed information, refer to the official Snowflake documentation.

Question 127
Skipped
Which command can be used to list all network policies available in an account?

DESCRIBE NETWORK POLICY

DESCRIBE SESSION POLICY

SHOW SESSION POLICIES

Correct answer
SHOW NETWORK POLICIES

Overall explanation
SHOW NETWORK POLICIES command lists all network policies available in a Snowflake account.

For more detailed information, refer to the official Snowflake documentation.

Question 128
Skipped
What happens when a virtual warehouse is resized?

Users who are trying to use the warehouse will receive an error message until the resizing is complete.

When increasing the size of an active warehouse the compute resource for all running and queued queries on the warehouse are affected.

Correct answer
When reducing the size of a warehouse the compute resources are removed only when they are no longer being used to execute any current statements.

The warehouse will be suspended while the new compute resource is provisioned and will resume automatically once provisioning is complete.

Overall explanation
Snowflake ensures that resizing a warehouse does not disrupt running queries, and it allows the system to dynamically manage resources while maintaining query performance. Additionally, resizing does not suspend the warehouse or generate errors for users during the process.

For more detailed information, refer to the official Snowflake documentation.

Question 129
Skipped
What are characteristics of table streams?

Only one stream can be created for each table.

Correct answer
Dropping tables will make any stream on the table stale.

Streams can be created to track changes on views, external tables, and external stages.

Renaming tables will make any stream on the table stale.

Overall explanation
Using CREATE OR REPLACE TABLE effectively drops and recreates the object. When this occurs, the table’s historical metadata is removed, which causes any associated stream to become stale. The same effect applies if a view’s underlying table is dropped or recreated—streams defined on that view will also become stale.

By contrast:

Multiple streams can be defined on the same source table.

Renaming a source object does not invalidate or stale an existing stream.

Streams are supported on specific object types (e.g., standard tables, views—including secure views—directory tables, dynamic tables, Iceberg tables, event tables, and external tables). External stages are not supported stream sources.

Recreating an object is therefore the operation that directly invalidates dependent streams due to loss of historical tracking metadata.

For more detailed information, refer to the official Snowflake documentation.

Question 130
Skipped
A Snowflake user is using the QUERY_HISTORY view in the ACCOUNT_USAGE schema to gather information about two queries that ran in the past 10 minutes, but the expected data is missing.



What would cause this to occur?

The user does not have privileges to access the QUERY_HISTORY view.

The queries were able to take advantage of the results cache.

Correct answer
The ACCOUNT_USAGE schema does not provide real-time results.

The queries were run on a multi-cluster virtual warehouse.

Overall explanation
The ACCOUNT_USAGE.QUERY_HISTORY view is not real-time. It can exhibit a latency of up to approximately 45 minutes, meaning recently executed queries (e.g., within the last 10 minutes) may not yet appear.

This behavior is expected: ACCOUNT_USAGE views are intended for historical reporting and governance analysis rather than operational monitoring.

For near real-time visibility, INFORMATION_SCHEMA.QUERY_HISTORY should be used instead. It provides more immediate results, though with a shorter data retention window.

Warehouse configuration, result caching, or cluster scaling do not prevent queries from being recorded in history. Additionally, insufficient privileges would trigger an authorization error rather than silently omitting records.

For more detailed information, refer to the official Snowflakedocumentation.

Question 131
Skipped
Which Snowflake function is maintained separately from the data and helps to support features such as Time Travel, Secure Data Sharing, and pruning?

Data clustering

Micro-partitioning

Column compression

Correct answer
Metadata management

Overall explanation
Metadata management is maintained separately from the data and supports features like Time Travel, Secure Data Sharing, and pruning by storing information about data locations, versions, and access, enabling efficient data management and retrieval.

For more detailed information, refer to the official Snowflake documentation.

Question 132
Skipped
When unloading data from Snowflake to AWS, what permissions are required? (Choose two.)

s3:GetBucketLocation

Correct selection
s3:DeleteObject

s3:GetBucketAcl

Correct selection
s3:PutObject

s3:CopyObject

Overall explanation
s3:PutObject allows Snowflake to upload data to the S3 bucket, and s3:DeleteObject is needed to manage or remove objects from the bucket if necessary.

For more detailed information, refer to the official Snowflake documentation.

Question 133
Skipped
Which of the following statements apply to Snowflake in terms of security? (Choose two.)

Correct selection
All data in Snowflake is encrypted.

All data in Snowflake is compressed.

Snowflake requires a user to configure an IAM user to connect to the database.

Snowflake can run within a user's own Virtual Private Cloud (VPC).

Correct selection
Snowflake leverages a Role-Based Access Control (RBAC) model.

Overall explanation
In terms of security, Snowflake leverages a Role-Based Access Control (RBAC) model, which allows precise control over user access and privileges, and all data in Snowflake is encrypted, ensuring data protection both in transit and at rest. These security measures are core features of Snowflake, providing robust access control and encryption to safeguard data.

For more detailed information, refer to the official Snowflake documentation.

Question 134
Skipped
What is the MOST cost-effective way to resolve memory spillage in a virtual warehouse?

Enable the search optimization service.

Correct answer
Convert to a Snowpark-optimized warehouse.

Enable automatic clustering.

Use materialized views.

Overall explanation
Snowflake recommends using larger warehouse sizes to avoid spilling, as this provides more memory and local resources for operations. However, since this option is not available in this question, the most suitable solution is to convert to a Snowpark-optimized warehouse, as these warehouses offer more memory resources than standard ones, which can help reduce or eliminate spilling.

For more detailed information, refer to the official Snowflake documentation.

Question 135
Skipped
Which URL identifies the database, schema, stage, and file path to a set of files for accessing the unstructured data files in Snowflake?

Scoped URL

Correct answer
File URL

Pre-signed URL

HTTPS URL

Overall explanation
File URL specifies the database, schema, stage, and file path where a set of files is located. Any role with the appropriate permissions on the stage can access these files.

For more detailed information, refer to the official Snowflake documentation.

Question 136
Skipped
A clustering key was defined on a table, but it is no longer needed.

How can the key be removed?

ALTER TABLE [TABLE NAME] PURGE CLUSTERING KEY

ALTER TABLE [TABLE NAME] REMOVE CLUSTERING KEY

ALTER TABLE [TABLE NAME] DELETE CLUSTERING KEY

Correct answer
ALTER TABLE [TABLE NAME] DROP CLUSTERING KEY

Overall explanation
DROP CLUSTERING KEY will effectively remove the clustering key and stop Snowflake from clustering data based on that key.

For more detailed information, refer to the official Snowflake documentation.

Question 137
Skipped
What operations can be performed while loading a simple CSV file into a Snowflake table using the COPY INTO command? (Choose two.)

Correct selection
Converting the datatypes

Grouping by operations

Selecting the first few rows

Correct selection
Reordering the columns

Performing aggregate calculations

Overall explanation
You can reorder the columns to match the table structure and convert the datatypes during the load process to align with the table's requirements. These operations ensure that the data is correctly formatted and integrated into the Snowflake table.

For more detailed information, refer to the official Snowflake documentation.

Question 138
Skipped
When using a direct share, what privileges does a role need to control access to the objects that are in a share that is using database roles? (Choose two.)

CREATE STREAM

CREATE PIPE

Correct selection
CREATE DATABASE ROLE

CREATE TASK

Correct selection
CREATE SHARE

Overall explanation
If database roles are being used, the minimum privileges required for share creation and management in a data provider or consumer account depend on the specific operation performed: CREATE SHARE or CREATE DATABASE ROLE.

For more detailed information, refer to the official Snowflake documentation.

Question 139
Skipped
Which objects will incur storage costs associated with Fail-safe?

Correct answer
Permanent tables

Data files available in external stages

External tables

Data files available in internal stages

Overall explanation
Storage costs associated with Fail-safe apply to permanent tables, as Snowflake retains historical data for recovery purposes during the Fail-safe period.

For more detailed information, refer to the official Snowflake documentation.

Question 140
Skipped
What cell types are available in Snowflake Notebooks? (Select THREE).

Correct selection
Markdown

Correct selection
Python

Correct selection
SQL

R

Java

Scala

Overall explanation
Snowflake Notebooks are designed to be an interactive, cell-based environment where you can combine data logic and documentation. The three specific cell types provided in the interface are:

SQL Cells: For executing standard SQL queries against your data.

Python Cells: For writing Python code (using Snowpark) to perform data engineering, machine learning, or complex transformations.

Markdown Cells: For adding formatted text, headers, lists, and descriptions to document your analysis.

For more detailed information, refer to the official Snowflake documentation.

Question 141
Skipped
What is the minimum Snowflake edition required for row level security?

Business Critical

Correct answer
Enterprise

Virtual Private Snowflake

Standard

Overall explanation
The minimum Snowflake edition required for row-level security is Enterprise. Row-level security, including features like row access policies, allows more granular control over which rows of data a user can see, ensuring secure and customized access to sensitive information.

For more detailed information, refer to the official Snowflake documentation.

Question 142
Skipped
In the Snowflake access control model, which entity owns an object by default?

The user who created the object

The SYSADMIN role

Ownership depends on the type of object

Correct answer
The role used to create the object

Overall explanation
In the Snowflake access control model, the role used to create the object owns the object by default. This means that ownership is assigned to the active role in the session when the object is created, and the owner has full control over the object, including managing privileges and making changes.

For more detailed information, refer to the official Snowflake documentation.

Question 143
Skipped
Which chart type is supported in Snowsight for Snowflake users to visualize data with dashboards?

Area chart

Pie chart

Box plot

Correct answer
Heat grid

Overall explanation
Snowsight supports heat grids, which allow users to visualize data density or intensity across two dimensions in dashboards.

For more detailed information, refer to the official Snowflake documentation.

Question 144
Skipped
A user creates a stage using the following command:

CREATE STAGE mystage -
DIRECTORY = (ENABLE = TRUE)
FILE_FORMAT = myformat;
What will be the outcome?

The command will fail to run because the name of the directory table is not specified.

An error will be received stating that the storage location for the stage must be identified when creating a stage with a directory table.

A stage with a directory table set to automatically refresh will be created.

Correct answer
A stage with a directory table that has metadata that must be manually refreshed will be created.

Overall explanation
Directory tables on internal stages need manual metadata refreshes.

For more detailed information, refer to the official Snowflake documentation.

Question 145
Skipped
Increasing the size of a virtual warehouse from an X-Small to an X-Large is an example of which of the following?

Scaling out

Concurrent sizing

Correct answer
Scaling up

Right sizing

Overall explanation
Increasing the size of a virtual warehouse from an X-Small to an X-Large is an example of scaling up. Scaling up refers to increasing the computational power of a single warehouse by moving to a larger instance size, which provides more resources (CPU, memory) for handling larger workloads or improving performance.

For more detailed information, refer to the official Snowflake documentation.

Question 146
Skipped
A tag object has been assigned to a table (TABLE_A) in a schema within a Snowflake database.

Which CREATE object statement will automatically assign the TABLE_A tag to a target object?

Correct answer
CREATE TABLE LIKE TABLE_A;

CREATE TABLE AS SELECT * FROM TABLE_A;

CREATE VIEW AS SELECT * FROM TABLE_A;

CREATE MATERIALIZED VIEW AS SELECT * FROM TABLE_A;

Overall explanation
The CREATE TABLE LIKE statement automatically assigns the tags from TABLE_A to the new table, as it duplicates both the structure and any assigned tags of the original table.

For more detailed information, refer to the official Snowflake documentation.

Question 147
Skipped
Which data types does Snowflake support when querying semi-structured data? (Choose two.)

Correct selection
ARRAY

BLOB

VARCHAR

XML

Correct selection
VARIANT

Overall explanation
When querying semi-structured data, Snowflake supports the VARIANT and ARRAY data types. VARIANT is used to store flexible, semi-structured data like JSON, Avro, and XML, while ARRAY can handle ordered collections of elements, making both ideal for managing and querying complex, nested data structures.

For more detailed information, refer to the official Snowflake documentation.

Question 148
Skipped
User1, who has the SYSADMIN role, executed a query on Snowsight. User2, who is in the same Snowflake account, wants to view the result set of the query executed by User1 using the Snowsight query history.

What will happen if User2 tries to access the query history?

If User2 has the ACCOUNTADMIN role they will be able to see the results.

If User2 has the SYSADMIN role they will be able to see the results.

Correct answer
User2 will be unable to view the result set of the query executed by User1.

If User2 has the SECURITYADMIN role they will be able to see the results.

Overall explanation
Query results are session-specific and cannot be viewed by another user, regardless of their role, unless the results are explicitly shared or stored.

For more detailed information, refer to the official Snowflake documentation.

Question 149
Skipped
In which hierarchy is tag inheritance possible?

Account » User » Schema

Database » View » Column

Organization » Account » Role

Correct answer
Schema » Table » Column

Overall explanation
Schema » Table » Column: In this hierarchy, tag inheritance is possible, allowing tags applied at a higher level (like a schema or table) to be inherited by objects at lower levels, such as columns.

For more detailed information, refer to the official Snowflake documentation.

Question 150
Skipped
What Snowflake database object is derived from a query specification, stored for later use, and can speed up expensive aggregation on large data sets?

Temporary table

Correct answer
Materialized view

External table

Secure view

Overall explanation
A materialized view is derived from a query specification, stored for later use, and can speed up expensive aggregations on large data sets by precomputing and storing the results.

For more detailed information, refer to the official Snowflake documentation.

Question 151
Skipped
What objects in Snowflake are supported by Dynamic Data Masking? (Choose two.)

Future grants

Correct selection
Tables

External tables

Virtual columns

Correct selection
Views

Overall explanation
Dynamic Data Masking in Snowflake is supported for both tables and views, allowing sensitive data in these objects to be masked dynamically based on access policies. Other objects like external tables are not supported for this feature. Masking policy cannot be attached to a virtual column.

For more detailed information, refer to the official Snowflake documentation.

Question 152
Skipped
There are 300 concurrent users on a production Snowflake account using a single cluster virtual warehouse. The queries are small, but the response time is very slow.

What is causing this to occur?

The application is not using the latest native ODBC driver which is causing latency.

The warehouse parameter STATEMENT_QUEUED_TIMEOUT_IN_SECONDS is set too low.

The queries are not taking advantage of the data cache.

Correct answer
The warehouse is queuing the queries, increasing the overall query execution time.

Overall explanation
With 300 concurrent users on a single-cluster virtual warehouse, the system may not have enough compute resources to handle all queries simultaneously, leading to delays. To resolve this, you can scale the warehouse by either increasing its size or enabling multi-cluster mode to distribute the load more efficiently.

For more detailed information, refer to the official Snowflake documentation.

Question 153
Skipped
What happens to the privileges granted to Snowflake system-defined roles?

The privileges can be revoked by any user-defined role with appropriate privileges.

Correct answer
The privileges cannot be revoked.

The privileges can be revoked by an ACCOUNTADMIN.

The privileges can be revoked by an ORGADMIN.

Overall explanation
Snowflake system-defined roles have fixed privileges that cannot be revoked, ensuring the roles maintain their essential functions for managing the system.

For more detailed information, refer to the official Snowflake documentation.

Question 154
Skipped
Which data sharing option allows a Snowflake user to set up and manage a group of accounts and offer a share to that group?

Paid listing

Direct share

Free listing

Correct answer
Data Exchange

Overall explanation
Data Exchange is a secure data hub for collaborating with selected members. As providers, we can publish data that consumers in the exchange can discover and use. It allows us to share data efficiently with a specific group, such as internal departments, vendors, suppliers, or external business partners.

For more detailed information, refer to the official Snowflake documentation.

Question 155
Skipped
What are the possible values within a METADATA$ACTION column in a Snowflake stream? (Choose two.)

UPDATE

Correct selection
INSERT

UPSERT

TRUNCATE

Correct selection
DELETE

Overall explanation
The METADATA$ACTION column in a Snowflake stream tracks the type of changes made to the data, including INSERT for new records and DELETE for removed records.

For more detailed information, refer to the official Snowflake documentation.

Question 156
Skipped
Which commands can only be executed using SnowSQL? (Choose two.)

Correct selection
PUT

REMOVE

Correct selection
GET

COPY INTO

LIST

Overall explanation
The PUT command uploads files to a stage, and the GET command downloads files from a stage.

About PUT command, For more detailed information, refer to the official Snowflake documentation.

About GET command, For more detailed information, refer to the official Snowflake documentation.

Question 157
Skipped
Which commands only use Cloud Services resources? (Select TWO).

CREATE OR REPLACE TABLE_A SELECT * FROM TABLE_B
SELECT * FROM ORDERS LIMIT 10
DELETE FROM CUSTOMER WHERE ID = 134526
Correct selection
LS @my_stage/
Correct selection
CREATE OR REPLACE TABLE TABLE_B CLONE TABLE_C
Overall explanation
The following operations rely solely on Cloud Services compute and do not consume virtual warehouse resources:

LS @stage_path – Listing files in an internal or external stage is a metadata-level operation. It interacts with storage services to enumerate files and does not execute data processing workloads.

CREATE OR REPLACE TABLE ... CLONE ... – Cloning is implemented as a metadata operation. No physical data is copied at execution time, so warehouse compute is not required.

By contrast, operations that process or scan data require warehouse resources:

CREATE TABLE AS SELECT executes a query.

DELETE statements modify table data.

SELECT queries (even with LIMIT) must scan and retrieve data.

Cloud Services handles metadata and control-plane tasks, whereas data processing operations consume warehouse compute.

For more detailed information, refer to the official Snowflake documentation.

Question 158
Skipped
Which type of role can be granted to a share?

Custom role

Secondary role

Correct answer
Database role

Account role

Overall explanation
Only database roles can be granted to a share, allowing specific permissions on shared objects within a database to be extended to other accounts.

For more detailed information, refer to the official Snowflake documentation.

Question 159
Skipped
What privileges are necessary for a consumer in the Data Exchange to make a request and receive data? (Choose two.)

REFERENCE_USAGE

Correct selection
CREATE DATABASE

USAGE

OWNERSHIP

Correct selection
IMPORT SHARE

Overall explanation
The necessary privileges for a consumer in the Data Exchange to make a request and receive data are CREATE DATABASE and IMPORT SHARE. These privileges allow the consumer to create a database from the shared data and import the data share into their environment for use.

For more detailed information, refer to the official Snowflake documentation.

Question 160
Skipped
A permanent table and temporary table have the same name, TBL1, in a schema.

What will happen if a user executes select * from TBL1;?

The permanent table will take precedence over the temporary table.

Correct answer
The temporary table will take precedence over the permanent table.

The table that was created most recently will take precedence over the older table.

An error will say there cannot be two tables with the same name in a schema.

Overall explanation
When a permanent and temporary table have the same name, Snowflake gives precedence to the temporary table in queries executed within the session.

For more detailed information, refer to the official Snowflake documentation.

Question 161
Skipped
Which table function should be used to view details on a Directed Acyclic Graph (DAG) run that is presently scheduled or is executing?

TASK_HISTORY

TASK_DEPENDENTS

Correct answer
CURRENT_TASK_GRAPHS

COMPLETE_TASK_GRAPHS

Overall explanation
CURRENT_TASK_GRAPHS: This table function should be used to view details on a Directed Acyclic Graph (DAG) run that is presently scheduled or executing, as it provides information on active task graphs.

For more detailed information, refer to the official Snowflake documentation.

Question 162
Skipped
What computer language can be selected when creating User-Defined Functions (UDFs) using the Snowpark API?

Swift

JavaScript

SQL

Correct answer
Python

Overall explanation
Snowflake offers Snowpark libraries for three programming languages: Python, Java and Scala.

For more detailed information, refer to the official Snowflake documentation.

Question 163
Skipped
Which tasks are performed in the Snowflake Cloud Services layer? (Choose two.)

Computing the data

Maintaining Availability Zones

Correct selection
Management of metadata

Correct selection
Parsing and optimizing queries

Infrastructure security

Overall explanation
The tasks performed in the Snowflake Cloud Services layer include management of metadata, which handles metadata for query optimization and data governance, and parsing and optimizing queries, responsible for query parsing and execution planning to ensure efficient processing.

For more detailed information, refer to the official Snowflake documentation.

Question 164
Skipped
What is the default Time Travel retention period?

7 days

Correct answer
1 day

90 days

45 days

Overall explanation
​The default Time Travel retention period in Snowflake is 1 day (24 hours). This standard retention period is automatically enabled for all Snowflake accounts. For Snowflake Enterprise Edition and higher, the retention period can be configured to any value from 0 up to 90 days, depending on the object's type and edition.

For more detailed information, refer to the official Snowflake documentation.

Question 165
Skipped
Which statement is true about Multi-Factor Authentication (MFA) in Snowflake?

MFA can be enforced or applied for a given role.

Correct answer
MFA is an integrated Snowflake feature.

Users enroll in MFA by submitting a request to Snowflake Support.

Snowflake users are automatically enrolled in MFA.

Overall explanation
It is built directly into Snowflake's security architecture, allowing administrators to enforce MFA for added security. Users can enroll in MFA via their settings, and it can be enforced at the account or user level, but not for specific roles.

For more detailed information, refer to the official Snowflake documentation.

Question 166
Skipped
Query compilation occurs in which architecture layer of the Snowflake Cloud Data Platform?

Cloud infrastructure layer

Correct answer
Cloud services layer

Storage layer

Compute layer

Overall explanation
Cloud services layer. This layer is responsible for various critical services such as query optimization, compilation, transaction management, and metadata management, ensuring efficient execution of queries. The compute and storage layers handle processing and data storage but rely on the cloud services layer to orchestrate and optimize query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 167
Skipped
Which Snowflake function will parse a JSON-null into a SQL-null?

Correct answer
STRIP_NULL_VALUE

TO_VARCHAR

TO_CHAR

TO_VARIANT

Overall explanation
STRIP_NULL_VALUE function will parse a JSON-null into a SQL-null, converting null values in JSON data into corresponding SQL nulls during the parsing process.

For more detailed information, refer to the official Snowflake documentation.

Question 168
Skipped
What is a characteristic of a tag associated with a masking policy?

A tag can have multiple masking policies with varying data types.

A tag can be dropped after a masking policy is assigned.

A tag can have multiple masking policies for each data type.

Correct answer
A tag can have only one masking policy for each data type.

Overall explanation
A tag can have only one masking policy for each data type. For instance, there can be one policy for the STRING data type, another for the NUMBER data type, and so forth.

For more detailed information, refer to the official Snowflake documentation.

Question 169
Skipped
Which Snowflake Notebook cell status color indicates that the cell ran in a previous session?

Red

Correct answer
Gray

Blue

Green

Overall explanation
Cell Execution Status:

Gray: Displays results from a previous session; the cell has not been run in the current session.

Blue dot: Indicates the cell has been modified but not yet executed.

Red: The cell encountered an error during execution in the current session.

Green: The cell executed successfully in the current session.

Animated Green: The cell is currently processing.

For more detailed information, refer to the official Snowflake documentation.

Question 170
Skipped
What are best practice recommendations for using the ACCOUNTADMIN system-defined role in Snowflake? (Choose two.)

All users granted ACCOUNTADMIN role must be owned by the ACCOUNTADMIN role.

Correct selection
Ensure all ACCOUNTADMIN roles use Multi-factor Authentication (MFA).

The ACCOUNTADMIN role must be granted to only one user.

All users granted ACCOUNTADMIN role must also be granted SECURITYADMIN role.

Correct selection
Assign the ACCOUNTADMIN role to at least two users, but as few as possible.

Overall explanation
Best practice recommendations for using the ACCOUNTADMIN system-defined role in Snowflake include ensuring all ACCOUNTADMIN roles use Multi-factor Authentication (MFA) to enhance security and assigning the ACCOUNTADMIN role to at least two users, but as few as possible to provide redundancy while maintaining strict control over access. These practices help secure the account and ensure only trusted users have full account management privileges.

For more detailed information, refer to the official Snowflake documentation.

Question 171
Skipped
What causes objects in a data share to become unavailable to a consumer account?

The consumer account acquires the data share through a private data exchange.

The DATA_RETENTION_IT parameter in the consumer account is set to 0.

Correct answer
The objects in the data share are being deleted and the grant pattern is not re-applied systematically.

The consumer account runs the GRANT INPORTED PRIVILEGES command on the data share every 24 hours.

Overall explanation
If the provider removes or modifies shared objects (e.g., dropping a table or view), the consumer loses access to those objects unless the sharing setup is refreshed or re-applied properly. This ensures that only valid objects remain in the data share for the consumer account.

For more detailed information, refer to the official Snowflake documentation.

Question 172
Skipped
What are benefits of using Snowpark with Snowflake? (Choose two.)

Snowpark allows users to run existing Spark code on virtual warehouses without the need to reconfigure the code.

Snowpark uses a Spark engine to generate optimized SQL query plans

Correct selection
Snowpark executes as much work as possible in the source databases for all operations including User-Defined Functions (UDFs).

Snowpark automatically sets up Spark within Snowflake virtual warehouses.

Correct selection
Snowpark does not require that a separate cluster be running outside of Snowflake.

Overall explanation
The benefits of using Snowpark with Snowflake include: Snowpark does not require that a separate cluster be running outside of Snowflake, enabling seamless in-database processing, and Snowpark executes as much work as possible in the source databases for all operations, including User-Defined Functions (UDFs), optimizing performance by minimizing data movement and utilizing Snowflake’s compute resources for efficient execution. These features make Snowpark ideal for advanced data engineering and data science tasks within Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 173
Skipped
What is the abbreviated form to get all the files in the stage for the current user?

LIST @~;

LS @usr;

Correct answer
LS @~;

SHOW @%;

Overall explanation
LS command lists all files in the user's default stage.

For more detailed information, refer to the official Snowflake documentation.

Question 174
Skipped
What data type should be used to store JSON data natively in Snowflake?

Correct answer
VARIANT

Object

JSON

String

Overall explanation
VARIANT data type is designed to handle semi-structured data, such as JSON, Avro, and XML, allowing for flexible storage and querying of complex data structures within Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 175
Skipped
What happens when a network policy includes values that appear in both the allowed and blocked IP address lists?

Snowflake issues an alert message and adds the duplicate IP address values to both the allowed and blocked IP address lists.

Snowflake issues an error message and adds the duplicate IP address values to both the allowed and blocked IP address lists.

Those IP addresses are allowed access to the Snowflake account as Snowflake applies the allowed IP address list first.

Correct answer
Those IP addresses are denied access to the Snowflake account as Snowflake applies the blocked IP address list first.