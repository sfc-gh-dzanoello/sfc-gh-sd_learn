Question 1
Incorrect
How can a Snowflake user traverse semi-structured data?

Your answer is incorrect
Insert a double colon (::) between the VARIANT column name and any first-level element.

Correct answer
Insert a colon (:) between the VARIANT column name and any first-level element.

Insert a double colon (::) between the VARIANT column name and any second-level element.

Insert a colon (:) between the VARIANT column name and any second-level element.

Overall explanation
This syntax allows access to elements within a VARIANT type column that stores semi-structured data like JSON, XML, or Avro. For deeper nested elements, users can continue adding colons to access additional levels of the structure.

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
For which use cases is running a virtual warehouse required? (Choose two.)

When creating a table

When executing a SHOW command

Correct selection
When unloading data from a table

Correct selection
When loading data into a table

When executing a LIST command

Overall explanation
Running a virtual warehouse is required when loading data into a table and when unloading data from a table. Both processes involve data manipulation, which requires compute resources provided by the virtual warehouse to process the data efficiently. Other operations, such as creating a table or running metadata commands, do not require a virtual warehouse.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
What is the default behavior of internal stages in Snowflake?

Correct answer
Each user and table are automatically allocated an internal stage.

Named internal stages are created by default.

Data files are automatically staged to a default location.

Users must manually create their own internal stages.

Overall explanation
The default behavior of internal stages in Snowflake is that each user and table are automatically allocated an internal stage. These internal stages are available for users to easily store and load data without needing to create named stages manually. They provide a default storage location for files when performing data loading or unloading operations.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
When loading data into Snowflake via Snowpipe what is the compressed file size recommendation?

300-500 MB

Correct answer
100-250 MB

10-50 MB

1000-1500 MB

Overall explanation
Common question in the exams. The recommended compressed file size for loading data into Snowflake via Snowpipe is 100-250 MB.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
Which objects together comprise a namespace in Snowflake? (Choose two.)

Table

Account

Correct selection
Database

Virtual warehouse

Correct selection
Schema

Overall explanation
The objects that together comprise a namespace in Snowflake are a Database and a Schema. A namespace is a logical structure used to organize and manage data within the Snowflake environment, and it is defined by the combination of a database and a schema, which together hold tables, views, and other objects.

For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
Which configuration of the function PARSE_JSON([expr]) will retrieve a valid SQL NULL value?

SELECT parse_json('{"a": null}'):a
Correct answer
SELECT parse_json(NULL)
SELECT parse_json('[ null ]')
SELECT parse_json('null')
Overall explanation
It's important to differentiate between SQL NULL and JSON's null value when using PARSE_JSON. A direct SQL NULL as input will simply return a SQL NULL. In contrast, when the function receives the string literal 'null', it correctly interprets it as a valid JSON null and returns a VARIANT value that represents this JSON value, rather than a SQL NULL.

For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
What does a table with a clustering depth of 1 mean in Snowflake?

The table has only 1 micro-partition.

Correct answer
The table has no overlapping micro-partitions.

The table has no micro-partitions.

The table has 1 overlapping micro-partition.

Overall explanation
A clustering depth of 1 indicates optimal clustering, meaning each micro-partition is well-organized without overlap, resulting in efficient data retrieval.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
How does the ACCESS_HISTORY view enhance overall data governance pertaining to read and write operations? (Choose two.)

Protects sensitive data from unauthorized access while allowing authorized users to access it at query runtime

Correct selection
Shows how the accessed data was moved from the source to the target objects

Identifies columns with personal information and tags them so masking policies can be applied to protect sensitive data

Determines whether a given row in a table can be accessed by the user by filtering the data based on a given policy

Correct selection
Provides a unified picture of what data was accessed and when it was accessed

Overall explanation
The ACCESS_HISTORY view enhances overall data governance by providing a unified picture of what data was accessed and when it was accessed, allowing for better tracking and auditing of data access activities. Additionally, it shows how the accessed data was moved from the source to the target objects, helping to maintain transparency over data flow and ensuring better control over read and write operations. These features strengthen data governance and monitoring in Snowflake environments.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
Will data cached in a warehouse be lost when the warehouse is resized?

No, because the size of the cache is independent from the warehouse size.

Correct answer
Possibly, if the warehouse is resized to a smaller size and the cache no longer fits.

Yes, because the new compute resource will no longer have access to the cache encryption key.

Yes, because the compute resource is replaced in its entirety with a new compute resource.

Overall explanation
When a virtual warehouse is resized, particularly if it's resized down, there is a possibility that the cached data may no longer fit in the new, smaller cache. This can result in the loss of cached data, as the available memory is reduced.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
Which ACCOUNT_USAGE view will identify long-running queries?

Correct answer
QUERY_HISTORY

METERING_DAILY_HISTORY

DATA_TRANSFER_HISTORY

TASK_HISTORY

Overall explanation
We can use the QUERY_HISTORY table function to query Snowflake query history along various dimensions, including duration. We can filter it to find long-running queries by comparing start and end times.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
Which of the following is a data tokenization integration partner?

DBeaver

Tableau

Correct answer
Protegrity

SAP

Overall explanation
Protegrity is a data tokenization integration partner with Snowflake. Protegrity helps provide advanced data security solutions, including tokenization, which is essential for protecting sensitive information like personally identifiable information (PII) within the Snowflake platform.

For more detailed information, refer to the official Snowflake documentation.

Question 12
Skipped
How can a user optimize the performance of a COPY INTO <table> query that is being run on a very large file?

Correct answer
Split the file into smaller files.

Increase the virtual warehouse size.

Set the COMPRESSION = AUTO option in the file format.

Set the SIZE_LIMIT option to be larger than the file size.

Overall explanation
To optimize COPY INTO performance, Snowflake advises dividing very large data files into multiple smaller files. Parallelism during loading is tied to the compute capacity of the warehouse, and multiple appropriately sized files allow the engine to distribute work across nodes more effectively.

Best practice is to split files along logical record boundaries (e.g., by line for CSV data) to avoid corrupting rows. When files are properly sized, load throughput scales more efficiently because processing can occur in parallel.

Simply increasing warehouse size may add compute resources but can raise credit consumption without proportional gains if file sizing is suboptimal. Other parameters such as SIZE_LIMIT or COMPRESSION = AUTO address data volume limits and compression handling, respectively, but do not resolve parallelization constraints caused by oversized files.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
What object does Snowflake recommend using when planning to unload similarly-formatted data on a regular basis?

Correct answer
Named file format

Stream

Task

Storage integration

Overall explanation
Key: unload similarly-formatted. While not required, named file formats are recommended for efficiently unloading data with a consistent format on a regular basis.

The question mentions ‘regular basis’ so tasks could be an option to consider, but in this case the question is asking for the direct recommendation of the format mentioned in the documentation.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
Which of the following describes external functions in Snowflake?

They call code that is stored inside of Snowflake.

They can return multiple rows for each row received.

They contain their own SQL code.

Correct answer
They are a type of User-defined Function (UDF).

Overall explanation
External functions in Snowflake are a type of user-defined function (UDF) that call code stored outside of Snowflake, typically in external services like AWS Lambda or Azure Functions. These functions allow Snowflake to interact with external services and can return a single result per input. They are often used for integrating external APIs or services into Snowflake workflows.



For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
What step does Snowflake recommend when loading data from a stage?

Use REMOVE when using the COPY INTO command.

Use the LOAD HISTORY function to view the status of loaded files.

Correct answer
Use PURGE when using the COPY INTO command.

Use the COPY HISTORY function to update the status of loaded files.

Overall explanation
Staged files can be deleted from a Snowflake stage (user, table, or named) in two ways: You can delete them during a successful load by using the PURGE option with the COPY INTO <table> command. Alternatively, you can delete them after the load is finished using the REMOVE command.

Deleting these files is a good practice. It prevents accidentally loading the same data again and also improves the performance of future loads by reducing the number of files Snowflake needs to check.

The REMOVE option could be valid, but it is not used together with the COPY INTO command as it is used with PURGE.

The COPY HISTORY is automatically updated.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
How can a user get the MOST detailed information about individual table storage details in Snowflake?

Correct answer
TABLE_STORAGE_METRICS view

TABLES view

SHOW EXTERNAL TABLES command

SHOW TABLES command

Overall explanation
The most detailed information about individual table storage details in Snowflake can be obtained using the TABLE_STORAGE_METRICS view. This view provides granular insights into table storage, including the amount of space used by the table, the number of micro-partitions, and more. It offers a detailed breakdown that helps with understanding the storage and optimizing table performance.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
A running virtual warehouse is suspended.

What is the MINIMUM amount of time that the warehouse will incur charges for when it is restarted?

Correct answer
60 seconds

5 minutes

60 minutes

1 second

Overall explanation
The minimum amount of time that a virtual warehouse will incur charges for when it is restarted is 60 seconds. Snowflake charges for compute resources in one-minute increments, so even if the warehouse runs for less than a minute, it will be billed for a full 60 seconds.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
What is the MINIMUM permission needed to access a file URL from an external stage?

READ

MODIFY

SELECT

Correct answer
USAGE

Overall explanation
The minimum permission needed to access a file URL from an external stage is USAGE, which allows a user to retrieve data from the stage without modifying it.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
A tabular User-Defined Function (UDF) is defined by specifying a return clause that contains which keyword?

VALUES

TABULAR

Correct answer
TABLE

ROW_NUMBER

Overall explanation
A tabular User-Defined Function (UDF) in Snowflake is defined by specifying a return clause that contains the TABLE keyword. This keyword is used to define that the UDF will return a set of rows, similar to how a table behaves in SQL.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
What type of query benefits the MOST from search optimization?

A query that includes analytical expressions

Correct answer
A query that uses equality predicates or predicates that use IN

A query that filters on semi-structured data types

A query that uses only disjunction (i.e., OR) predicates

Overall explanation
A query that benefits the most from search optimization is a query that uses equality predicates or predicates that use IN. These types of queries often filter on specific values, and search optimization can improve performance by enabling faster access to the relevant rows without scanning the entire dataset, especially when indexing is optimized for such queries.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
How is enhanced authentication achieved in Snowflake? (Choose two.)

Snowflake-managed keys

Data encryption

Correct selection
Multi-Factor Authentication (MFA)

Correct selection
Federated authentication and Single Sign-On (SSO)

Object level access control

Overall explanation
MFA adds an additional layer of security by requiring a second form of verification beyond the password. Federated authentication and SSO allow users to log in to Snowflake using external identity providers, streamlining access management and ensuring secure, centralized authentication. Both methods enhance security by minimizing risks associated with compromised credentials.

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
What are the correct settings for column and element names, regardless of which notation is used while accessing elements in a JSON object?

Both the column name and the element name are case-sensitive.

Both the column name and the element name are case-insensitive.

Correct answer
The column name is case-insensitive and the element name is case-sensitive.

The column name is case-sensitive and the element names are case-insensitive.

Overall explanation
The correct settings are that the column name is case-insensitive and the element name is case-sensitive. In Snowflake, column names are treated as case-insensitive unless explicitly quoted, while element names within JSON or semi-structured data are case-sensitive, meaning you need to match their case exactly when accessing them.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
A user has unloaded data from Snowflake to a stage.

Which SQL command should be used to validate which data was loaded into the stage?

show @file_stage

verify @file_stage

Correct answer
list @file_stage

view @file_stage

Overall explanation
The correct SQL command to validate which data was loaded into the stage is:

LIST @file_stage

For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
Which data types in Snowflake are synonymous for FLOAT? (Choose two.)

DECIMAL

NUMBER

NUMERIC

Correct selection
DOUBLE

Correct selection
REAL

Overall explanation
The data types synonymous with FLOAT in Snowflake are DOUBLE and REAL. These types represent approximate numeric values and are commonly used for floating-point numbers in various precision levels.

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
Data storage for individual tables can be monitored using which commands and/or objects? (Choose two.)

SHOW STORAGE BY TABLE;

Information Schema -> TABLE_HISTORY

Information Schema -> TABLE_FUNCTION

Correct selection
SHOW TABLES;

Correct selection
Information Schema -> TABLE_STORAGE_METRICS

Overall explanation
Data storage for individual tables in Snowflake can be monitored using the SHOW TABLES command, which lists the tables and provides metadata, and the Information Schema -> TABLE_STORAGE_METRICS view, which gives detailed metrics on storage consumption by each table. Both methods allow users to track how much storage space is being utilized by their tables, helping with management and optimization of storage resources

For more detailed information about SHOW TABLES command, refer to the official Snowflake documentation.

For more detailed information about TABLE_STORAGE_METRICS, refer to the official Snowflake documentation.

Question 26
Skipped
What step must be taken to ensure that a user can only access Snowsight from a specific location, or when working from home?

Use Single Sign-On (SSO).

Use Multi-Factor Authentication (MFA).

Use a company Virtual Private Network (VPN) connection.

Correct answer
Add the user's IP address to the network policy allowed list.

Overall explanation
This restricts access to Snowsight from specific IP addresses, ensuring the user can only access it from designated locations, like a home network or a VPN.

If we add an IP address to the allowed list, all other IPv4 addresses will be blocked.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
What is the only supported character set for loading and unloading data from all supported file formats?

UTF-16

WINDOWS-1253

Correct answer
UTF-8

ISO-8859-1

Overall explanation
The only supported character set for loading and unloading data from all supported file formats in Snowflake is UTF-8. This ensures compatibility across various file formats and platforms, as UTF-8 is widely used for encoding characters and supports a broad range of symbols and languages.

For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
What Snowflake recommendation is designed to ensure that staged data is only loaded once?

Partitioning staged data files

Loading only the most recently-staged data files

Correct answer
Removing data files after loading

Identifying and removing duplicates after each data load

Overall explanation
Removing files prevents unintentional reloading and enhances load performance by reducing the number of files the COPY command needs to scan to check for previously loaded data.

For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
From what stage can a Snowflake user omit the FROM clause while loading data into a table?

The user stage

The external named stage

The internal named stage

Correct answer
The table stage

Overall explanation
A Snowflake user can omit the FROM clause while loading data into a table from the table stage. The table stage is automatically associated with the table being loaded, so specifying the stage is unnecessary in the COPY INTO command, streamlining the data loading process.

For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
How are network policies defined in Snowflake?

They are a set of rules that dictate how Snowflake accounts can be used between multiple users.

They are a set of rules that define how data can be transferred between different Snowflake accounts within an organization.

They are a set of rules that define the network routes within Snowflake.

Correct answer
They are a set of rules that control access to Snowflake accounts by specifying the IP addresses or ranges of IP addresses that are allowed to connect to Snowflake.

Overall explanation
Network policies in Snowflake are a set of rules that control access to Snowflake accounts by specifying the IP addresses or ranges of IP addresses that are allowed to connect to Snowflake. These policies help ensure that only connections from trusted networks can access Snowflake resources, enhancing security by restricting access based on network location.

For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
How would a user execute a series of SQL statements using a task?

A stored procedure can have only one DML statement per stored procedure invocation and therefore the user should sequence stored procedure calls in the task definition CREATE TASK mytask .... AS call stored_proc1(); call stored_proc2();

Correct answer
Use a stored procedure executing multiple SQL statements and invoke the stored procedure from the task. CREATE TASK mytask .... AS call stored_proc_multiple_statements_inside();

Create a task for each SQL statement (e.g. resulting in task1, task2, etc.) and string the series of SQL statements by having a control task calling task1, task2, etc. sequentially.

Include the SQL statements in the body of the task CREATE TASK mytask .. AS INSERT INTO target1 SELECT .. FROM stream_s1 WHERE .. INSERT INTO target2 SELECT .. FROM stream_s1 WHERE ..

Overall explanation
In Snowflake, tasks can execute a stored procedure that contains multiple SQL statements, allowing for more complex workflows. This method ensures that all statements are executed in sequence within the stored procedure, and the task can manage the scheduling and triggering of the procedure. The correct command is: CREATE TASK mytask .... AS call stored_proc_multiple_statements_inside();.

For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
If a virtual warehouse is suspended, what happens to the warehouse cache?

The cache is maintained for the auto_suspend duration and can be restored if the warehouse is restarted within this limit.

The warehouse cache persists for as long as the warehouse exists, regardless of its suspension status.

Correct answer
The cache is dropped when the warehouse is suspended and is no longer available upon restart.

The cache is maintained for up to two hours and can be restored if the warehouse is restarted within this limit.

Overall explanation
The correct behavior when a virtual warehouse is suspended is that the cache is dropped when the warehouse is suspended and is no longer available upon restart. This means that when the warehouse is resumed, it must reload or recompute the necessary data, as the cached results are not preserved across suspension and resumption events.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
How does Snowflake reorganize data when it is loaded? (Choose two.)

Zipped format

Correct selection
Compressed format

Raw format

Binary format

Correct selection
Columnar format

Overall explanation
Snowflake reorganizes data when it is loaded by storing it in a columnar format and a compressed format. The columnar format optimizes data for analytics by organizing similar data together, improving query performance. The compressed format helps reduce storage costs by minimizing the amount of space required for data storage while maintaining performance during queries.

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
What parameter controls if the Virtual Warehouse starts immediately after the CREATE WAREHOUSE statement?

START_AFTER_CREATE = TRUE/FALSE

Correct answer
INITIALLY_SUSPENDED = TRUE/FALSE

START_TIME = CURRENT_DATE()

START_THE = 60 // (seconds from now)

Overall explanation
The parameter that controls whether the Virtual Warehouse starts immediately after the CREATE WAREHOUSE statement is INITIALLY_SUSPENDED = TRUE/FALSE. When set to FALSE, the warehouse starts immediately; when set to TRUE, the warehouse is created in a suspended state and does not start until manually resumed.

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
Which of the following are characteristics of Snowflake virtual warehouses? (Choose two.)

A user cannot specify a default warehouse when using the ODBC driver.

Correct selection
The default virtual warehouse size can be changed at any time.

Auto-resume applies only to the last warehouse that was started in a multi-cluster warehouse.

The ability to auto-suspend a warehouse is only available in the Enterprise edition or above.

Correct selection
SnowSQL supports both a configuration file and a command line option for specifying a default warehouse.

Overall explanation
Snowflake virtual warehouses have the following characteristics: SnowSQL supports both a configuration file and a command line option for specifying a default warehouse, allowing flexibility in setting warehouse preferences. Additionally, the default virtual warehouse size can be changed at any time, enabling users to resize warehouses dynamically to meet performance needs and manage costs efficiently. These features provide adaptability and ease of use in managing warehouse resources and configurations.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
When a database is cloned, which objects in the clone inherit all granted privileges from the source object? (Choose two.)

Database

Internal named stages

Correct selection
Schemas

Account

Correct selection
Tables

Overall explanation
When a database is cloned in Snowflake, schemas and tables within the clone inherit all granted privileges from the source object. This ensures that the cloned objects maintain the same access control settings as the original, allowing seamless continuity in user permissions.



For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
To use the OVERWRITE option on INSERT, which privilege must be granted to the role?

SELECT

UPDATE

TRUNCATE

Correct answer
DELETE

Overall explanation
The DELETE privilege is required to use the OVERWRITE option on INSERT, as it allows the role to remove existing rows from the table before inserting new data.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
How long is the Fail-safe period for temporary and transient tables?

30 days

7 days

Correct answer
There is no Fail-safe period for these tables.

1 day

Overall explanation
There is no Fail-safe period for temporary and transient tables in Snowflake. These types of tables do not have the additional Fail-safe protection, meaning that once they are dropped or their retention period expires, they cannot be recovered. Temporary tables are session-based, and transient tables lack the Fail-safe period available to standard tables.



For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
Which privilege grants the ability to set a column-level security masking policy on a table or view column?

Correct answer
APPLY

CREATE

MODIFY

SET

Overall explanation
CREATE: Allows us to create a new masking policy within a schema.

APPLY: Grants permission to set or unset a masking policy on a column.

OWNERSHIP: Provides full control over a masking policy, including modifying most of its properties. Only one role can hold this privilege for a specific masking policy at a time.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
What does Snowflake recommend when configuring the auto-suspend parameter for a virtual warehouse?

Disable auto-suspend to ensure continuous availability of the warehouse.

Set auto-suspend to the maximum possible duration for optimal resource utilization.

Correct answer
Enable auto-suspend to a low value to minimize credit consumption during inactivity.

Enable auto-suspend to a high value to maximize warehouse availability.

Overall explanation
There are some scenarios where disabling auto-suspend and keeping the data cache active can be useful—especially when we have a steady or high-volume workload, or when we need the warehouse to be immediately available without delay. While warehouse provisioning is typically fast (1 to 2 seconds), it may take longer depending on the size of the warehouse and the availability of compute resources.

However, we should approach this carefully, as keeping a warehouse running continuously in order to preserve the data cache can significantly increase costs. In most use cases, we should keep auto-suspend enabled with a low timeout value. This helps control costs effectively while still benefiting from Snowflake’s fast provisioning and performance.

Question 41
Skipped
Which privilege is required to view the definition of a secure view?

USAGE

IMPORT SHARE

Correct answer
OWNERSHIP

REFERENCES

Overall explanation
The definition of a secure view is accessible only to authorized users, specifically those who have been granted the role that owns the view.

This is a key security feature of secure views - while users can query the view with appropriate SELECT privileges, only those with ownership rights can see the underlying view definition, protecting the internal structural details and underlying table information from unauthorized exposure.

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
Which Snowflake data types can be used to build nested hierarchical data? (Choose two)

LIST

VARCHAR

INTEGER

Correct selection
OBJECT

Correct selection
VARIANT

Overall explanation
The Snowflake data types that can be used to build nested hierarchical data are OBJECT and VARIANT. These data types are designed to store semi-structured data like JSON, XML, or Avro, and they support complex nested structures, making them ideal for hierarchical data representation.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
How should the SPLIT_TO_TABLE([string], [delimiter]) function be called?

SELECT SPLIT_TO_TABLE(COL1, '.') FROM DUAL;
SELECT * FROM SPLIT_TO_TABLE('a.b.c', '.');
SELECT SPLIT_TO_TABLE('a.b.c', '.');
Correct answer
SELECT * FROM TABLE(SPLIT_TO_TABLE('a.b.c', '.'));
Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
How does the search optimization service help Snowflake users improve query performance?

It scans the local disk cache to avoid scans on the tables used in the query.

Correct answer
It maintains a persistent data structure that keeps track of the values of the table’s columns in each of its micro-partitions.

It scans the micro-partitions based on the joins used in the queries and scans only join columns.

It keeps track of running queries and their results and saves those extra scans on the table.

Overall explanation
The search optimization service enhances query performance by creating a persistent data structure that records the values of a table's columns within its micro-partitions. This allows for faster lookups and more efficient scans.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
What type of account can be used to share data with a consumer who does not have a Snowflake account?

Organization

Data consumer

Correct answer
Reader

Data provider

Overall explanation
A Reader account can be used to share data with a consumer who does not have a Snowflake account. This type of account allows data providers to share data securely, enabling consumers to access the data without requiring them to be full Snowflake customers. The provider manages the Reader account, and the consumer can query the shared data directly.



For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Which functions can be used to share unstructured data through a secure view? (Choose two.)

GET_ABSOLUTE_PATH

Correct selection
BUILD_SCOPED_FILE_URL

BUILD_STAGE_FILE_URL

GET_RELATIVE_PATH

Correct selection
GET_PRESIGNED_URL

Overall explanation
These functions generate URLs that allow secure access to staged files, supporting the sharing of unstructured data like documents, images, or other files via Snowflake's secure data sharing capabilities.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
Which table type should be used with an insert-only stream?

Correct answer
External

Temporary

Transient

Hybrid

Overall explanation
Insert-only streams are supported for specific table types, including dynamic tables, Iceberg tables, and external tables.

For external tables in particular, insert-only streams are appropriate because Snowflake does not maintain historical file state in external cloud storage. As a result, these streams capture newly inserted rows but do not track deletions from previously registered files.

This behavior differs from standard streams used on regular, temporary, hybrid, or transient tables, where both inserts and deletes can be recorded.

Insert-only streams are therefore designed to accommodate storage systems where full change tracking is not feasible.

For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
Which property needs to be added to the ALTER WAREHOUSE command to verify the additional compute resources for a virtual warehouse have been fully provisioned?

QUERY_ACCELERATION_MAX_SCALE_FACTOR

RESOURCE_MONITOR

SCALING_POLICY

Correct answer
WAIT_FOR_COMPLETION

Overall explanation
WAIT_FOR_COMPLETION. This property ensures that the command waits until the scaling operation is complete before returning, providing confirmation that the additional resources have been fully provisioned.

For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
At what level can the ALLOW_CLIENT_MFA_CACHING parameter be set?

Role

User

Correct answer
Account

Session

Overall explanation
The ALLOW_CLIENT_MFA_CACHING parameter in Snowflake can be set at the account level. This parameter controls whether Multi-Factor Authentication (MFA) tokens can be cached for Snowflake clients, allowing for easier re-authentication without requiring MFA on every connection attempt.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
Which types of subqueries does Snowflake support? (Choose two.)

EXISTS, ANY / ALL, and IN subqueries in WHERE clauses: these subqueries can be correlated only

Correct selection
Uncorrelated scalar subqueries in any place that a value expression can be used

Correct selection
EXISTS, ANY / ALL, and IN subqueries in WHERE clauses: these subqueries can be correlated or uncorrelated

EXISTS, ANY / ALL, and IN subqueries in WHERE clauses: these subqueries can be uncorrelated only

Uncorrelated scalar subqueries in WHERE clauses

Overall explanation
Snowflake supports uncorrelated scalar subqueries in any place that a value expression can be used, meaning these subqueries can return a single value and appear in SELECT, WHERE, or HAVING clauses. Additionally, EXISTS, ANY / ALL, and IN subqueries in WHERE clauses can be either correlated or uncorrelated, allowing flexibility for complex conditions and relationships between multiple tables or queries. These types of subqueries enable dynamic and powerful querying capabilities within Snowflake's SQL framework.

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
A user has a standard multi-cluster warehouse auto-scaling policy in place.

Which condition will trigger a cluster to shut-down?

Correct answer
When after 2-3 consecutive checks the system determines that the load on the least-loaded cluster could be redistributed.

When after 5-6 consecutive checks the system determines that the load on the most-loaded cluster could be redistributed.

When after 2-3 consecutive checks the system determines that the load on the most-loaded cluster could be redistributed.

When after 5-6 consecutive checks the system determines that the load on the least-loaded cluster could be redistributed.

Overall explanation
This helps optimize resource usage by scaling down clusters when their workload is low, while ensuring that other active clusters can still handle the load efficiently.

For more detailed information, refer to the official Snowflake documentation.





Question 52
Skipped
Why would a Snowflake user decide to use a materialized view instead of a regular view?

The results of the view change often.

The query results are not used frequently.

The query is not resource intensive.

Correct answer
The base tables do not change frequently.

Overall explanation
A Snowflake user would choose to use a materialized view instead of a regular view when the base tables do not change frequently and the results of the query need to be accessed quickly. Materialized views store the precomputed results of the query, which improves performance by avoiding the need to re-execute the query each time, making them ideal for scenarios with infrequent changes but frequent access to the results.

For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
Which Snowflake feature is used for both querying and restoring data?

Fail-safe

Cloning

Correct answer
Time Travel

Cluster keys

Overall explanation
Time Travel is the Snowflake feature used for both querying and restoring data. It allows users to access historical data versions within a specified retention period, enabling recovery of accidentally modified or deleted data as well as querying past states of the data for auditing or analysis purposes.

For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
How can the Query Profile be used to troubleshoot a problematic query?

Correct answer
It will indicate if a virtual warehouse memory is too small to run the query.

It will indicate if a virtual warehouse is in auto-scale mode.

It will indicate if a user lacks the privileges needed to run the query.

It will indicate if the user has enough Snowflake credits to run the query.

Overall explanation
If a virtual warehouse memory is too small, the Query Profile may show spilling to remote storage, which slows performance.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
Which governance feature is supported by all Snowflake editions? (Choose two.)

Row access policies

Sensitive data classification

Correct selection
Object tags

Correct selection
OBJECT_DEPENDENCIES view

Masking policies

Overall explanation
The governance feature supported by all Snowflake editions are:

OBJECT_DEPENDENCIES view. This view is part of Account Usage, which is available in all editions. This feature provides insight into the relationships between database objects, helping users understand how changes to one object might affect others.

Object tags. In recent months this feature has become available for all editions. Previously, it was only available from Enterprise.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
How many tasks can a tree of tasks have?

Unlimited

10

100

Correct answer
1000

Overall explanation
Users can define a simple tree-like structure of tasks that starts with a root task and is linked together by task dependencies. A tree of tasks can have a maximum of 1000 tasks, including the root one. Also, each task can have a maximum of 100 children.

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
What is used during the FIRST execution of SELECT COUNT(*) FROM ORDER?

Virtual warehouse cache

Cache result

Remote disk cache

Correct answer
Metadata-based result

Overall explanation
During the first execution of SELECT COUNT(*) FROM ORDER, Snowflake will use a metadata-based result. Snowflake’s query optimizer uses metadata to quickly return results for simple aggregate functions like COUNT() by leveraging metadata about the table’s structure, rather than scanning the actual data, improving query performance.

Question 58
Skipped
Which command line flags can be used to log into a Snowflake account using SnowSQL? (Choose two.)

Correct selection
-c

-o

-d

-e

Correct selection
-a

Overall explanation
A few comments:

-a (--accountname): Specifies your account identifier, which is required to connect to Snowflake

-c (--connection): Specifies a named connection to use, where the string is the name of a connection defined in the SnowSQL configuration file

-d: Specifies database to use (not required for login)

-o: Defines configuration options (not for login)

-e: Not a valid SnowSQL parameter

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
Which privilege is required to use the search optimization service in Snowflake?

GRANT SEARCH OPTIMIZATION ON DATABASE TO ROLE

Correct answer
GRANT ADD SEARCH OPTIMIZATION ON SCHEMA TO ROLE

GRANT ADD SEARCH OPTIMIZATION ON DATABASE TO ROLE

GRANT SEARCH OPTIMIZATION ON SCHEMA TO ROLE

Overall explanation
This command allows a role to enable and manage search optimization on specific schemas within the database, improving query performance for selective filters by optimizing how data is indexed.

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
In Snowflake, the use of federated authentication enables which Single Sign-On (SSO) workflow activities? (Choose two.)

Performing role authentication

Correct selection
Logging out of Snowflake

Initiating user sessions

Authorizing users

Correct selection
Logging into Snowflake

Overall explanation
In Snowflake, federated authentication enables the following Single Sign-On (SSO) workflow activities: logging into Snowflake using SSO provider credentials, simplifying the user login process, and logging out of Snowflake through the SSO workflow, ensuring secure session management. These features improve both security and user convenience by centralizing authentication and session control through an external identity provider.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
Which categories are included in the execution time summary in a Query Profile? (Choose two.)

Percentage of data read from cache

Spilling

Correct selection
Initialization

Pruning

Correct selection
Local Disk I/O

Overall explanation
Initialization reflects the setup time for query execution, while Local Disk I/O tracks the storage operations, both impacting overall query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
When unloading the data for file format type specified (TYPE = 'CSV'), SQL NULL can be converted to string ‘null’ using which file format option?

Correct answer
NULL_IF

SKIP_BYTE_ORDER_MARK

ESCAPE_UNENCLOSED_FIELD

EMPTY_FIELD_AS_NULL

Overall explanation
When unloading data for the file format type specified as TYPE = 'CSV', SQL NULL can be converted to the string 'null' using the NULL_IF file format option. This option allows you to specify how NULL values in the table should be represented when unloading data, such as converting them to a particular string like 'null'.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
Which function will provide the proxy information needed to protect Snowsight?

SYSTEM$GET_TAG

SYSTEM$GET_PRIVATELINK

SYSTEM$AUTHORIZE_PRIVATELINK

Correct answer
SYSTEM$ALLOWLIST

Overall explanation
SYSTEM$ALLOWLIST function retrieves the allowlist details that can be used to ensure secure access and configurations for Snowflake resources, including Snowsight, within a protected network environment.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
A user wants to create objects within a schema but wants to restrict other users’ ability to grant privileges on these objects.



What configuration should be used to create the schema?

Correct answer
Use a managed access schema.

Use a regular (non-managed) schema.

Set the Default_DDL_Collation parameter.

Use a transient schema.

Overall explanation
A managed access schema centralizes privilege management, ensuring that only the schema owner or administrators can grant privileges on objects within the schema, thus restricting other users' ability to grant permissions.

For more detailed information, refer to the official Snowflake documentation.

Question 65
Skipped
While clustering a table, columns with which data types can be used as clustering keys? (Choose two.)

Correct selection
GEOMETRY

VARIANT

Correct selection
BINARY

OBJECT

GEOGRAPHY

Overall explanation
Not allowed data types for clustering keys: GEOGRAPHY, VARIANT, OBJECT, ARRAY.

For more detailed information, refer to the official Snowflake documentation.

Question 66
Skipped
Which of the following roles is recommended to be used to create and manage users and roles?

PUBLIC

SYSADMIN

ACCOUNTADMIN

Correct answer
SECURITYADMIN

Overall explanation
Best role for this purpose is USERADMIN. SECURITYADMIN is the parent of USERADMIN.

For more detailed information, refer to the official Snowflake documentation.

Question 67
Skipped
What Snowflake feature provides a data hub for secure data collaboration, with a selected group of invited members?

Snowflake Marketplace

Data Replication

Secure Data Sharing

Correct answer
Data Exchange

Overall explanation
Data Exchange allows organizations to securely share and collaborate on data with trusted partners, enabling seamless data discovery and sharing while maintaining control over access and usage.

For more detailed information, refer to the official Snowflake documentation.

Question 68
Skipped
In which layer of its architecture does Snowflake store its metadata statistics?

Compute Layer

Storage Layer

Correct answer
Cloud Service Layer

Database Layer

Overall explanation
Cloud Service Layer provides the necessary features and security measures required to handle sensitive data in accordance with various regulatory standards.

For more detailed information, refer to the official Snowflake documentation.

Question 69
Skipped
What is the MINIMUM Snowflake edition that supports database replication?

Business Critical

Virtual Private Snowflake (VPS)

Enterprise

Correct answer
Standard

Overall explanation
Database replication is supported on all editions. We have to keep in mind that there are certain security limitations when we want to replicate data from a Business Critical edition to a simpler one.

For more detailed information, refer to the official Snowflake documentation.

Question 70
Skipped
Which of the following commands are valid options for the VALIDATION_MODE parameter within the Snowflake COPY_INTO command? (Choose two.)

Correct selection
RETURN_ALL_ERRORS

RETURN_FIRST_n_ERRORS

Correct selection
RETURN_n_ROWS

RETURN_ERROR_SUM

TRUE

Overall explanation
VALIDATION_MODE accepts following values: RETURN_n_ROWS | RETURN_ERRORS | RETURN_ALL_ERRORS

For more detailed information, refer to the official Snowflake documentation.

Question 71
Skipped
Which common query issues can be identified by the Query Profile? (Choose two.)

Credit usage that exceeds a set threshold

Insufficient credit quota

Correct selection
Inefficient query pruning

Excessive query pruning

Correct selection
Exploding joins

Overall explanation
The Query Profile helps identify inefficient query pruning, which results in unnecessary data scans, and exploding joins, which occur when a join operation produces an unexpectedly large number of rows, negatively impacting query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 72
Skipped
Which type of loop requires a BREAK statement to stop executing?

FOR

REPEAT

Correct answer
LOOP

WHILE

Overall explanation
LOOP requires a BREAK statement to stop executing. Unlike other loop types, it doesn’t have a natural stopping condition, so a BREAK is needed to exit the loop based on a specific condition.

For more detailed information, refer to the official Snowflake documentation.

Question 73
Skipped
When floating-point number columns are unloaded to CSV or JSON files, Snowflake truncates the values to approximately what?

(14,8)

(10,4)

Correct answer
(15,9)

(12,2)

Overall explanation
When floating-point number columns are unloaded to CSV or JSON files in Snowflake, the values are truncated to approximately (15,9), meaning 15 digits of precision and 9 digits after the decimal point. This ensures accuracy while managing file size and performance.

For more detailed information, refer to the official Snowflake documentation.

Question 74
Skipped
What are the responsibilities of Snowflake's Cloud Service layer? (Choose three.)

Correct selection
Resource management

Correct selection
Query parsing and optimization

Physical storage of micro-partitions

Virtual warehouse caching

Correct selection
Authentication

Query execution

Overall explanation
The responsibilities of Snowflake's Cloud Service layer include authentication, which handles user access and security; resource management, which oversees virtual warehouse provisioning and scaling; and query parsing and optimization, which ensures that SQL queries are interpreted and optimized before execution. These processes are key to maintaining efficient performance, security, and operational control in the Snowflake environment.

For more detailed information, refer to the official Snowflake documentation.

Question 75
Skipped
What transformations are supported in a CREATE PIPE ... AS COPY `¦ FROM (`¦) statement? (Choose two.)

Data can be filtered by an optional WHERE clause.

Correct selection
Columns can be reordered.

Correct selection
Columns can be omitted.

Row level access can be defined.

Incoming data can be joined with other tables.

Overall explanation
In a CREATE PIPE ... AS COPY statement, the supported transformations include the ability to reorder columns, allowing flexibility in how data is structured during ingestion, and the option to omit columns, letting you exclude specific columns from the data being loaded. These transformations enable efficient management of the data format while ingesting it into Snowflake, making the process more adaptable to specific use cases or schema requirements.

For more detailed information, refer to the official Snowflake documentation.

Question 76
Skipped
Which of the following accurately represents how a table fits into Snowflake's logical container hierarchy?

Account -> Schema -> Database -> Table

Correct answer
Account -> Database -> Schema -> Table

Database -> Table -> Schema -> Account

Database -> Schema -> Table -> Account

Overall explanation
The correct hierarchy in Snowflake is Account -> Database -> Schema -> Table. This logical structure ensures that each table resides within a schema, which is part of a database, and all databases are associated with a Snowflake account.

For more detailed information, refer to the official Snowflake documentation.

Question 77
Skipped
What are supported file formats for unloading data from Snowflake? (Choose three.)

Correct selection
Parquet

ORC

AVRO

XML

Correct selection
JSON

Correct selection
CSV

Overall explanation
Supported file formats for unloading data from Snowflake include JSON, Parquet, and CSV.

For more detailed information, refer to the official Snowflake documentation.

Question 78
Skipped
Which views are included in the DATA_SHARING_USAGE schema? (Choose two.)

DATA_TRANSFER_HISTORY

Correct selection
MONETIZED_USAGE_DAILY

WAREHOUSE_METERING_HISTORY

Correct selection
LISTING_TELEMETRY_DAILY

ACCESS_HISTORY

Overall explanation
These views in the DATA_SHARING_USAGE schema provide insights into shared data monetization and telemetry data, supporting data sharing and usage tracking.

For more detailed information, refer to the official Snowflake documentation.

Question 79
Skipped
When sharing data in Snowflake, what privileges does a Provider need to grant along with a share? (Choose two.)

MODIFY on the specific tables in the database.

OPERATE on the database and the schema containing the tables to share.

Correct selection
USAGE on the database and the schema containing the tables to share.

Correct selection
SELECT on the specific tables in the database.

USAGE on the specific tables in the database.

Overall explanation
When sharing data in Snowflake, the Provider (the account sharing the data) must grant the following privileges:

SELECT on the specific tables in the database

USAGE on the database and schema

For more detailed information, refer to the official Snowflake documentation.

Question 80
Skipped
Which function is used to convert rows in a relational table to a single VARIANT column?

ARRAY_CONSTRUCT

OBJECT_AGG

Correct answer
OBJECT_CONSTRUCT

ARRAY_AGG

Overall explanation
The function used to convert rows in a relational table to a single VARIANT column in Snowflake is OBJECT_CONSTRUCT. This function allows you to create a single VARIANT object by combining multiple key-value pairs, where each column in the row can be transformed into a key-value pair stored as a VARIANT, enabling flexible storage of semi-structured data.

For more detailed information, refer to the official Snowflake documentation.

Question 81
Skipped
What is the SNOWFLAKE.ACCOUNT_USAGE view that contains information about which objects were read by queries within the last 365 days (1 year)?

VIEWS_HISTORY

OBJECT_HISTORY

LOGIN_HISTORY

Correct answer
ACCESS_HISTORY

Overall explanation
The ACCESS_HISTORY view in the SNOWFLAKE.ACCOUNT_USAGE schema contains information about which objects were accessed by queries within the last 365 days (1 year). This view helps track object-level access details, such as which tables or views were read during query execution, providing valuable insights for auditing and monitoring purposes.

For more detailed information, refer to the official Snowflake documentation.

Question 82
Skipped
Which view can be used to track the read and write operations that have been performed on a table?

COPY_HISTORY

Correct answer
ACCESS_HISTORY

QUERY_HISTORY

TASK_HISTORY

Overall explanation
Snowflake's Access History feature tracks all user data read and write operations. This information is stored in the ACCESS_HISTORY view within the ACCOUNT_USAGE and ORGANIZATION_USAGE schemas. Each row in the view represents a single SQL statement, providing a direct link between the user, the query, and the data objects (tables, views, and columns) that were accessed. This feature is crucial for regulatory compliance audits and for gaining insights into the most popular and frequently used data.

For more detailed information, refer to the official Snowflake documentation.

Question 83
Skipped
Which task is supported by the use of Access History in Snowflake?

Data backups

Correct answer
Compliance auditing

Cost monitoring

Performance optimization

Overall explanation
Access History in Snowflake is used for compliance auditing by providing detailed records of data access, helping organizations track who accessed what data and when.

For more detailed information, refer to the official Snowflake documentation.

Question 84
Skipped
Which command should be used to load data from a file, located in an external stage, into a table in Snowflake?

INSERT

Correct answer
COPY

GET

PUT

Overall explanation
The command used to load data from a file located in an external stage into a table in Snowflake is COPY. This command is designed for bulk loading data efficiently from external stages (such as cloud storage) into Snowflake tables.

For more detailed information, refer to the official Snowflake documentation.

Question 85
Skipped
What is an advantage of using database roles instead of granting privileges on objects directly to a share in Snowflake?

Reduction in the number of shares required for different objects in the same database

Easier management of cross-region data sharing

Greater flexibility in including objects from multiple databases

Correct answer
More control over object-level access for different user groups

Overall explanation
Using database roles allows for more granular control of object-level access by assigning privileges to roles instead of directly to the share. This enables easier management and customization of access for different user groups while maintaining flexibility and security.

For more detailed information, refer to the official Snowflake documentation.

Question 86
Skipped
The use of which Snowflake table type will reduce costs when working with ETL workflows?

Transient

Permanent

External

Correct answer
Temporary

Overall explanation
Snowflake allows the creation of temporary tables to store non-permanent, short-term data (such as ETL data or session-specific information). These tables exist solely within the session where they are created and remain available only for the duration of that session.

For more detailed information, refer to the official Snowflake documentation.

Question 87
Skipped
Which type of workload traditionally benefits from the use of the query acceleration service?

Queries that do not have filters or aggregation

Correct answer
Workloads that include on-demand analytics

Queries with small scans and non-selective filters

Workloads with a predictable data volume for each query

Overall explanation
The Query Acceleration Service (QAS) can speed up some queries in a warehouse. Turning it on can make the whole warehouse run better by lessening the impact of unusual, resource-heavy queries.

QAS does this by moving parts of the query work to shared computer resources. This is helpful for things like ad hoc analytics, workloads with changing data volumes, and queries with large scans and selective filters.

For more detailed information, refer to the official Snowflake documentation.

Question 88
Skipped
How does Snowflake Fail-safe protect data in a permanent table?

Fail-safe makes data available up to 1 day, recoverable by user operations.

Fail-safe makes data available up to 1 day, recoverable only by Snowflake Support.

Correct answer
Fail-safe makes data available for 7 days, recoverable only by Snowflake Support.

Fail-safe makes data available for 7 days, recoverable by user operations.

Overall explanation
The Fail-safe period is designed as a last-resort recovery option after the Time Travel period has ended. During this 7-day period, only Snowflake Support can assist in recovering the data, ensuring an additional layer of protection for permanent tables in case of emergency data loss.

For more detailed information, refer to the official Snowflake documentation.

Question 89
Skipped
Which command should be used to download files from a Snowflake stage to a local folder on a client's machine?

COPY

Correct answer
GET

PUT

SELECT

Overall explanation
The command used to download files from a Snowflake stage to a local folder on a client's machine is GET. This command retrieves files from a Snowflake stage and saves them to the specified local directory on the user's machine.

For more detailed information, refer to the official Snowflake documentation.

Question 90
Skipped
Snowflake best practice recommends that which role be used to enforce a network policy on a Snowflake account?

ACCOUNTADMIN

Correct answer
SECURITYADMIN

SYSADMIN

USERADMIN

Overall explanation
Snowflake best practice recommends that the SECURITYADMIN role be used to enforce a network policy on a Snowflake account. The SECURITYADMIN role is responsible for managing security-related configurations, including network policies that control access to the Snowflake account based on IP address ranges.



For more detailed information, refer to the official Snowflake documentation.

Question 91
Skipped
How do Snowflake data providers share data that resides in different databases?

User-Defined Functions (UDFs)

Correct answer
Secure views

External tables

Materialized views

Overall explanation
Secure views allow providers to share data without exposing the underlying raw data, ensuring data privacy and security. This enables the data consumer to access and query the shared data across different databases while keeping the original data structure hidden.

For more detailed information, refer to the official Snowflake documentation.

Question 92
Skipped
Which query contains a Snowflake hosted file URL in a directory table for a stage named bronzestage?

list @bronzestage;

Correct answer
select * from directory(@bronzestage);

select * from table(information_schema.stage_directory_file_registration_history( stage_name=>'bronzestage'));

select metadata$filename from @bronzestage;

Overall explanation
This query accesses the directory table for the specified stage and lists the relevant metadata, including file URLs.

For more detailed information, refer to the official Snowflake documentation.

Question 93
Skipped
How can Snowsight be used to monitor the performance of a virtual warehouse?

Use the DESCRIBE WAREHOUSE command.

Use the SHOW WAREHOUSES command.

Correct answer
Use the QUERY_HISTORY view.

Use the LOAD_HISTORY view.

Overall explanation
A few comments:

In Snowsight, the Query History interface (and the underlying QUERY_HISTORY view) is the primary tool for analyzing performance. It allows us to see every query executed by a specific warehouse, how long it took to run, how long it spent queuing (waiting for resources), and if there was any "spilling" to remote storage (which indicates memory pressure). This data is essential for understanding if a warehouse is sized correctly or performing well.

LOAD_HISTORY view tracks the history of data files loaded into tables using the COPY INTO command. It is used for verifying data ingestion, not warehouse compute performance.

For more detailed information, refer to the official Snowflake documentation.

Question 94
Skipped
Which SQL statement will require a virtual warehouse to run?

Correct answer
INSERT INTO TBL_EMPLOYEE(EMP_ID, EMP_NAME, EMP_SALARY, DEPT) VALUES(1, 'Adam', 20000, 'Finance’); 
SELECT COUNT(*) FROM TBL_EMPLOYEE;
ALTER TABLE TBL_EMPLOYEE ADD COLUMN EMP_REGION VARCHAR(20);

CREATE OR REPLACE TABLE TBL_EMPLOYEE
(
EMP_ID NUMBER,
EMP_NAME VARCHAR(30),
EMP_SALARY NUMBER,
DEPT VARCHAR(20)
);
Overall explanation
INSERT INTO requires a virtual warehouse for processing. DDL statements like ALTER TABLE and CREATE TABLE do not require a virtual warehouse as they are metadata operations.

Question 95
Skipped
What syntax will enable the use of a Python string variable named myvar, in a SQL cell within a Snowflake Notebook?

Correct answer
{{myvar}}
'myvar'
$myvar
"myvar"
Overall explanation
A few comments:

Snowflake Notebooks allow us to reference variables defined in Python cells directly within your SQL cells. To do this, Snowflake uses the Jinja2 templating syntax, which wraps the variable name in double curly braces (e.g., SELECT * FROM {{my_table_name}}).

$ is often used for Snowflake Scripting variables or SnowSQL session variables, but not for bridging Python and SQL in the notebook environment.

For more detailed information, refer to the official Snowflake documentation.

Question 96
Skipped
In Snowflake, what allows users to perform recursive queries?

LATERAL

PIVOT

QUALIFY

Correct answer
CONNECT BY

Overall explanation
The CONNECT BY clause in Snowflake allows users to perform recursive queries, enabling hierarchical data traversal, such as exploring parent-child relationships in a dataset.

For more detailed information, refer to the official Snowflake documentation.

Question 97
Skipped
What happens to foreign key constraints when a table is cloned to another database?

All referenced tables will be cloned.

Correct answer
The cloned table will reference the primary key in the source table.

The cloned table will lose all references to the primary key.

The cloned table will lose all references to the foreign and primary keys.

Overall explanation
When we clone a table with a foreign key constraint referencing a primary key, the behavior depends on whether the tables are in the same or different databases or schemas.

If the database or schema containing both tables is cloned, the cloned table will reference the primary key in the other cloned table. However, if the tables are in separate databases or schemas, the cloned table will reference the primary key in the source table.

For more detailed information, refer to the official Snowflake documentation.

Question 98
Skipped
What is generally the FASTEST way to bulk load data files from a stage?

Using the Snowpipe REST API

Loading by path (internal stages) / prefix

Using pattern matching to identify specific files by pattern

Correct answer
Specifying a list of specific files to load

Overall explanation
Of the three options for identifying/specifying data files to load from a stage, providing a discrete list of files is generally the fastest; however, the FILES parameter supports a maximum of 1,000 files, meaning a COPY command executed with the FILES parameter can only load up to 1,000 files.

For more detailed information, refer to the official Snowflake documentation.

Question 99
Skipped
Which command can be used to determine if data from a file has been previously loaded?

Correct answer
COPY_HISTORY

WAREHOUSE_LOAD_HISTORY

STAGE_STORAGE_USAGE_HISTORY

DATA_TRANSFER_HISTORY

Overall explanation
The COPY_HISTORY command shows the history of data loads using the COPY INTO command, including file names and timestamps.

For more detailed information, refer to the official Snowflake documentation.

Question 100
Skipped
What storage cost is completely eliminated when a Snowflake table is defined as transient?

Time Travel

Staged

Correct answer
Fail-safe

Active

Overall explanation
When a Snowflake table is defined as transient, the storage cost for Fail-safe is completely eliminated. Transient tables do not have a Fail-safe period, meaning they are not recoverable once deleted beyond the Time Travel retention window, thus reducing storage costs associated with long-term data protection.



For more detailed information, refer to the official Snowflake documentation.

Question 101
Skipped
What are the primary authentication methods that Snowflake supports for securing REST API interactions? (Choose two.)

Multi-Factor Authentication (MFA)

Correct selection
OAuth

Correct selection
Key pair authentication

Federated authentication

Username and password authentication

Overall explanation
OAuth provides token-based authentication for secure access to the API, while key pair authentication uses public-private key pairs to ensure secure and authenticated communication. Both methods are designed to enhance the security of interactions with Snowflake’s REST APIs.

For more detailed information, refer to the official Snowflake documentation.

Question 102
Skipped
What does the average_overlaps in the output of SYSTEM$CLUSTERING_INFORMATION refer to?

The average number of micro-partitions in the table associated with cloned objects.

Correct answer
The average number of micro-partitions which contain overlapping value ranges.

The average number of partitions physically stored in the same location.

The average number of micro-partitions stored in Time Travel.

Overall explanation
The average_overlaps in the output of SYSTEM$CLUSTERING_INFORMATION refers to the average number of micro-partitions that contain overlapping value ranges. This metric helps evaluate the effectiveness of clustering by showing how much data overlaps across micro-partitions, which can impact query performance, particularly in large tables. Lower overlap indicates more efficient data clustering.

For more detailed information, refer to the official Snowflake documentation.

Question 103
Skipped
Which validation option is the only one that supports the COPY INTO (location) command?

RETURN_ALL_ERRORS

Correct answer
RETURN_ROWS

RETURN_n_ROWS

RETURN_ERRORS

Overall explanation
The validation option that supports the COPY INTO (location) command in Snowflake is RETURN_ROWS. This option helps verify the data before it is unloaded to an external location by validating the rows and returning a sample of them for inspection.

For more detailed information, refer to the official Snowflake documentation.

Question 104
Skipped
Which feature is only available in the Enterprise or higher editions of Snowflake?

Multi-factor Authentication (MFA)

Correct answer
Column-level security

SOC 2 type II certification

Object-level access control

Overall explanation
Column-level security is a feature available only in the Enterprise or higher editions of Snowflake. It allows for fine-grained access control at the column level, enabling organizations to apply security policies that protect sensitive data like personally identifiable information (PII) within specific columns, ensuring compliance with data privacy regulations.

For more detailed information, refer to the official Snowflake documentation.

Question 105
Skipped
When should a multi-cluster virtual warehouse be used in Snowflake?

When there is significant disk spilling shown on the Query Profile

When dynamic vertical scaling is being used in the warehouse

When there are no concurrent queries running on the warehouse

Correct answer
When queuing is delaying query execution on the warehouse

Overall explanation
A multi-cluster virtual warehouse should be used in Snowflake when queuing is delaying query execution on the warehouse. This feature enables Snowflake to automatically scale out by adding more clusters to handle high concurrency and workload demands, reducing queuing times and improving overall query performance. Multi-cluster mode is ideal for scenarios where multiple queries are running concurrently.

For more detailed information, refer to the official Snowflake documentation.

Question 106
Skipped
Which of the following statements describes a benefit of Snowflake’s separation of compute and storage? (Choose two.)

Use of storage avoids disk spilling.

Compute and storage can be scaled together.

Correct selection
Compute can be scaled up or down without the requirement to add more storage.

Growth of storage and compute are tightly coupled.

Correct selection
Storage expands without the requirement to add more compute.

Overall explanation
The benefits of Snowflake’s separation of compute and storage include: storage expands without the requirement to add more compute, allowing for independent scaling of data storage; and compute can be scaled up or down without the requirement to add more storage, enabling flexible resource allocation to optimize performance without unnecessary costs. This separation ensures efficient use of both compute and storage resources.

Question 107
Skipped
According to Snowflake best practice recommendations, which system-defined roles should be used to create custom roles? (Choose two.)

ACCOUNTADMIN

Correct selection
USERADMIN

ORGADMIN

Correct selection
SECURITYADMIN

SYSADMIN

Overall explanation
SECURITYADMIN and USERADMIN should be used to create custom roles. SECURITYADMIN manages the creation and assignment of roles and privileges related to security, while USERADMIN is responsible for managing users and their roles.

For more detailed information, refer to the official Snowflake documentation.

Question 108
Skipped
Why would a customer size a Virtual Warehouse from an X-Small to a Medium?

To accommodate fluctuations in workload

To accommodate more queries

To accommodate more users

Correct answer
To accommodate a more complex workload

Overall explanation
Sizing a Virtual Warehouse from an X-Small to a Medium is typically done to manage fluctuations in workload.

For more detailed information, refer to the official Snowflake documentation.

Question 109
Skipped
Which use case does the search optimization service support?

LIKE/ILIKE/RLIKE join predicates

Correct answer
Conjunctions (AND) of multiple equality predicates

Disjuncts (OR) in join predicates

Join predicates on VARIANT columns

Overall explanation
Search optimization can enhance the performance of the following query types:

Equality or IN predicates

Substrings and regular expressions (LIKE, ILIKE, RLIKE, CONTAINS, etc.)

Fields within VARIANT columns

Geospatial functions

Conjunctions of supported predicates (AND)

Disjunctions of supported predicates (OR)

Some limitations apply to the search optimization service and join queries:

Disjuncts (OR) in join predicates currently aren’t supported.

LIKE, ILIKE, and RLIKE join predicates currently aren’t supported.

Join predicates on VARIANT columns currently aren’t supported.



For more detailed information, refer to the official Snowflake documentation.

Question 110
Skipped
Authorization to execute CREATE [object] statements comes only from which role?

Correct answer
Primary role

Secondary role

Application role

Database role

Overall explanation
Authorization to execute CREATE [object] statements comes only from the Primary role. The primary role is the active role that a user has been granted and is responsible for determining what objects or operations the user is authorized to create within the Snowflake environment.

For more detailed information, refer to the official Snowflake documentation.

Question 111
Skipped
Which of the following are best practices for loading data into Snowflake? (Choose three.)

Partition the staged data into large folders with random paths, allowing Snowflake to determine the best way to load each file.

When planning which warehouse(s) to use for data loading, start with the largest warehouse possible.

Correct selection
Aim to produce data files that are between 100 MB and 250 MB in size, compressed.

Load data from files in a cloud storage service in a different region or cloud platform from the service or region containing the Snowflake account, to save on cost.

Correct selection
Enclose fields that contain delimiter characters in single or double quotes.

Correct selection
Split large files into a greater number of smaller files to distribute the load among the compute resources in an active warehouse.

Overall explanation
Data files ranging in size from 100 MB to 250 MB optimize load performance and enable more effective parallel processing.

Enclosing fields that contain delimiter characters within single or double quotes ensures accurate parsing of the data during loading.

Splitting large files into smaller, more manageable sizes helps distribute the workload across the compute resources in the warehouse, thereby enhancing processing efficiency.

For more detailed information, refer to the official Snowflake documentation.

Question 112
Skipped
What does Snowflake recommend a user do if they need to connect to Snowflake with a tool or technology that is not listed in Snowflake’s partner ecosystem?

Use Snowflake’s native API.

Contact Snowflake Support for a new driver.

Correct answer
Connect through Snowflake’s JDBC or ODBC drivers.

Use a custom-built connector.

Overall explanation
Snowflake recommends that users connect through Snowflake’s JDBC or ODBC drivers if they need to connect to Snowflake with a tool or technology that is not listed in Snowflake’s partner ecosystem. These drivers offer broad compatibility and can be used with a wide range of tools, ensuring stable and secure connections to Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 113
Skipped
What information does the Query Profile provide?

Correct answer
Statistics for each component of the processing plan

Real-time monitoring of the database operations

Graphical representation of the data model

Detailed information about the database schema

Overall explanation
The Query Profile in Snowflake provides statistics for each component of the processing plan, including details such as query execution steps, time spent on each step, memory usage, and data movement.

For more detailed information, refer to the official Snowflake documentation.

Question 114
Skipped
What does Snowflake attempt to do if any of the compute resources for a virtual warehouse fail to provision during start-up?

Queue the failed resources.

Restart the failed resources.

Correct answer
Repair the failed resources.

Provision the failed resources.

Overall explanation
Snowflake will not start executing SQL statements submitted to a warehouse until all compute resources for the warehouse are successfully provisioned, unless some resources fail to provision.

If any compute resources fail to provision during startup, Snowflake will attempt to fix the issues with those resources. While the repair is in progress, the warehouse will begin processing SQL statements as soon as 50% or more of the requested compute resources have been successfully provisioned.

For more detailed information, refer to the official Snowflake documentation.

Question 115
Skipped
Which view will show the MOST recent information about table-level storage utilization?

Correct answer
The TABLE_STORAGE_METRICS view in the INFORMATION_SCHEMA

The TABLE_STORAGE_METRICS view in a Snowflake data share

The STORAGE_USAGE_HISTORY view in the INFORMATION_SCHEMA

The TABLE_STORAGE_METRICS view in the ACCOUNT_USAGE schema

Overall explanation
Key comment: MOST recent information. INFORMATION_SCHEMA should be used because ACCOUNT_USAGE has latency.

For more detailed information, refer to the official Snowflake documentation.

Question 116
Skipped
Which types of worksheets can be created in Snowsight? (Select TWO).

Javascript

Correct selection
SQL

Java

Correct selection
Python

Scala

Overall explanation
A few comments:

The standard worksheet in Snowsight is the SQL Worksheet, used to write and execute SQL queries, DDL, and DML commands.

Snowflake introduced Python Worksheets, which allow developers to write and run Snowpark Python code directly in the Snowsight web interface without needing to set up a local development environment.

While Snowflake supports Java, JavaScript, and Scala for things like Stored Procedures and UDFs (User Defined Functions), there are no dedicated "Worksheet" types for these languages in the Snowsight UI like there are for SQL and Python.

For more detailed information, refer to the official Snowflake documentation.

Question 117
Skipped
When reviewing a query profile, what is a symptom that a query is too large to fit into the memory?

Partitions scanned is equal to partitions total

Correct answer
The query is spilling to remote storage

A single join node uses more than 50% of the query time

An AggregateOperator node is present

Overall explanation
This indicates that the data being processed exceeds the memory available in the virtual warehouse, leading to the use of disk storage, which can significantly impact query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 118
Skipped
A Snowflake user is trying to load a 125 GB file using SnowSQL. The file continues to load for almost an entire day.

What will happen at the 24-hour mark?

Correct answer
The file loading could be aborted without any portion of the file being committed.

The file’s number of allowable hours to load can be programmatically controlled to load easily into Snowflake.

The file will continue to load until all contents are loaded.

The file will stop loading and all data up to that point will be committed.

Overall explanation
If a Snowflake user is trying to load a large file (such as 125 GB) using SnowSQL, and the process exceeds the 24-hour mark, the file loading could be aborted without any portion of the file being committed. Snowflake's system limits file loading operations to a 24-hour window, and if this limit is exceeded, the operation is aborted, and no partial data is committed to the target table. To prevent this, it's recommended to split large files into smaller chunks before loading.

For more detailed information, refer to the official Snowflake documentation.

Question 119
Skipped
Which Snowflake object is supported by both database replication and replication groups?

Stages

Pipes

Users

Correct answer
Materialized views

Overall explanation
When you replicate a primary database, a copy of its objects and data goes to the secondary database. However, not everything is copied. Specifically, pipes and stages are only replicated with replication and failover groups, not with regular database replication. Users are only replicated with account replication.

For more detailed information, refer to the official Snowflake documentation.

Question 120
Skipped
By default, the COPY INTO statement will separate table data into a set of output files to take advantage of which Snowflake feature?

Query plan caching

Time Travel

Query acceleration

Correct answer
Parallel processing

Overall explanation
By default, the COPY INTO statement in Snowflake separates table data into a set of output files to take advantage of parallel processing. This feature enables Snowflake to process multiple files concurrently, improving data load and unload performance by distributing the workload across available resources.

For more detailed information, refer to the official Snowflake documentation.

Question 121
Skipped
What is the minimum Snowflake Edition that supports secure storage of Protected Health Information (PHI) data?

Standard Edition

Virtual Private Snowflake Edition

Correct answer
Business Critical Edition

Enterprise Edition

Overall explanation
The Business Critical Edition is the minimum Snowflake edition that supports the secure storage of Protected Health Information (PHI) data. This edition provides enhanced security features, such as stronger encryption, compliance with healthcare regulations like HIPAA, and stricter data handling protocols.

For more detailed information, refer to the official Snowflake documentation.

Question 122
Skipped
What can be done to reduce queueing on a virtual warehouse?

Increase the warehouse size.

Lower the MAX_CONCURRENCY_LEVEL setting for the warehouse.

Correct answer
Change the warehouse to a multi-cluster warehouse.

Increase the AUTO_SUSPEND setting for the warehouse.

Overall explanation
Switching to a multi-cluster warehouse allows Snowflake to handle a higher volume of concurrent queries by automatically adding or removing clusters based on workload demand.

For more detailed information, refer to the official Snowflake documentation.

Question 123
Skipped
Which data types can be used in a Snowflake table that holds semi-structured data? (Choose two.)

VARCHAR

BINARY

Correct selection
VARIANT

TEXT

Correct selection
ARRAY

Overall explanation
The data types that can be used in a Snowflake table to hold semi-structured data are ARRAY and VARIANT. These data types are specifically designed to store semi-structured data, such as JSON, Avro, or XML, allowing flexible querying and processing of nested or complex data structures within Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 124
Skipped
In the Data Exchange, who can get or request data from the listings? (Choose two.)

Users with SYSADMIN role

Correct selection
Users with IMPORT SHARE privilege

Users with ORGADMIN role

Correct selection
Users with ACCOUNTADMIN role

Users with MANAGE GRANTS privilege

Overall explanation
Users with the ACCOUNTADMIN role or the IMPORT SHARE privilege can request or access data from listings, as these roles and privileges enable data sharing and import permissions.

For more detailed information, refer to the official Snowflake documentation.

Question 125
Skipped
Which statement best describes 'clustering'?

The database administrator must define the clustering methodology for each Snowflake table

Clustering can be disabled within a Snowflake account

Correct answer
Clustering represents the way data is grouped together and stored within Snowflake's micro-partitions

The clustering key must be included on the COPY command when loading data into Snowflake

Overall explanation
Data clustering in Snowflake refers to the organization and storage of data within micro-partitions to improve query performance and optimize data retrieval.

For more detailed information, refer to the official Snowflake documentation.

Question 126
Skipped
What versions of Snowflake should be used to manage compliance with Personal Identifiable Information (PII) requirements? (Choose two.)

Correct selection
Business Critical Edition

Standard Edition

Correct selection
Virtual Private Snowflake

Enterprise Edition

Custom Edition

Overall explanation
The versions of Snowflake that should be used to manage compliance with Personal Identifiable Information (PII) requirements are Virtual Private Snowflake and Business Critical Edition. These editions offer enhanced security features, such as encryption, data masking, and compliance with regulations like HIPAA and GDPR, which are essential for handling sensitive data like PII.

For more detailed information, refer to the official Snowflake documentation.

Question 127
Skipped
What information is stored in the ACCESS_HISTORY view?

Correct answer
Query details such as the objects included and the user who executed the query

History of the files that have been loaded into Snowflake

Names and owners of the roles that are currently enabled in the session

Details around the privileges that have been granted for all objects in an account

Overall explanation
This view helps track and monitor how different database objects (e.g., tables, views) are being used, providing valuable insights into query patterns and user activity for auditing and security purposes.

For more detailed information, refer to the official Snowflake documentation.

Question 128
Skipped
Which SQL command will download all the data files from an internal table stage named TBL_EMPLOYEE to a local window directory or folder on a client machine in a folder named folder with space within the C drive?

GET @%TBL_EMPLOYEE 'file://C:\folder with space\';

PUT 'file://C:\folder with space\*' @%TBL_EMPLOYEE;

PUT 'file://C:/folder with space/*' @%TBL_EMPLOYEE;

Correct answer
GET @%TBL_EMPLOYEE 'file://C:/folder with space/';

Overall explanation
The pre-signed URL type allows users or applications to download or access files directly from a Snowflake stage without authentication. This URL is generated with a specified expiration time and provides secure, temporary access to the staged files, making it useful for sharing files externally without requiring Snowflake account access.

For more detailed information, refer to the official Snowflake documentation.

Question 129
Skipped
Which of the following view types are available in Snowflake? (Choose two.)

External view

Embedded view

Correct selection
Secure view

Layered view

Correct selection
Materialized view

Overall explanation
The available view types in Snowflake are Secure view and Materialized view. Secure views provide an extra layer of security by ensuring that the view's query logic is hidden from unauthorized users, while materialized views store precomputed query results to improve performance for frequently executed or resource-intensive queries. Both types are used to enhance data management and security in different scenarios.



For more detailed information, refer to the official Snowflake documentation.

Question 130
Skipped
Which VALIDATION_MODE value will return the errors across the files specified in a COPY command, including files that were partially loaded during an earlier load?

RETURN_ERRORS

Correct answer
RETURN_ALL_ERRORS

RETURN_n_ROWS

RETURN_-1_ROWS

Overall explanation
The VALIDATION_MODE value that will return the errors across the files specified in a COPY command, including files that were partially loaded during an earlier load, is RETURN_ALL_ERRORS. This option ensures that all errors, including those from files that were partially processed, are returned, providing comprehensive feedback on the issues encountered during the data load.

For more detailed information, refer to the official Snowflake documentation.

Question 131
Skipped
What is one of the characteristics of data shares?

Data shares support full DML operations.

Data shares work by copying data to consumer accounts.

Data shares are cloud agnostic and can cross regions by default.

Correct answer
Data shares utilize secure views for sharing view objects.

Overall explanation
One of the characteristics of data shares in Snowflake is that data shares utilize secure views for sharing view objects. Data shares allow secure, real-time data sharing between accounts without copying the data, ensuring that consumers can access up-to-date data while maintaining security and access control.

For more detailed information, refer to the official Snowflake documentation.

Question 132
Skipped
What is the order of precedence (highest to lowest) of network policies when applied at the account, user, and security integrations layers?

Account, user, security integration

User, security integration, account

User, account, security integration

Correct answer
Security integration, user, account

Overall explanation
When interpreting "highest to lowest precedence" in terms of which policy actually takes effect (enforcement priority), the order is:

Security Integration - Highest precedence (most specific), overrides both user and account policies

User - Middle precedence, overrides account policies but is overridden by security integration policies

Account - Lowest precedence (most general), overridden by both user and security integration policies1

Key principle: The most specific network policy overrides more general network policies. Security integration policies are most specific, while account policies are most general.

For more detailed information, refer to the official Snowflake documentation.

Question 133
Skipped
What is the purpose of the Start button in the toolbar of Snowflake Notebooks?

Begins the top-down cell-by-cell execution of the notebook.

Executes a SQL statement.

Initiates the capture of logging and tracing information.

Correct answer
Initiates a notebook session and sets its label to active when ready.

Overall explanation
In Snowflake Notebooks (and Python Worksheets), the Start button is used to initialize the compute environment. Clicking it provisions the session on the selected Virtual Warehouse and prepares the environment (loading necessary packages). Once the initialization is complete, the session status indicator changes to Active, allowing you to execute cells.

For more detailed information, refer to the official Snowflake documentation.

Question 134
Skipped
What should be used when creating a CSV file format where the columns are wrapped by single quotes or double quotes?

ESCAPE_UNENCLOSED_FIELD

Correct answer
FIELD_OPTIONALLY_ENCLOSED_BY

BINARY_FORMAT

SKIP_BYTE_ORDER_MARK

Overall explanation
The FIELD_OPTIONALLY_ENCLOSED_BY setting allows for fields to be optionally enclosed by the specified character, ensuring proper handling of quoted fields in the CSV format.

For more detailed information, refer to the official Snowflake documentation.

Question 135
Skipped
What setting in Snowsight determines the databases, tables, and other objects that can be seen and the actions that can be performed on them?

Column-level security

Correct answer
Active role

Masking policy

Multi-Factor Authentication (MFA)

Overall explanation
The setting in Snowsight that determines which databases, tables, and other objects can be seen and what actions can be performed on them is the Active role. The active role defines the permissions and privileges of a user, controlling access to objects and governing what operations can be executed on those objects.

For more detailed information, refer to the official Snowflake documentation.

Question 136
Skipped
What SQL command would be used to view all roles that were granted to USER1?

show grants user USER1;

describe user USER1;

show grants on user USER1;

Correct answer
show grants to user USER1;

Overall explanation
This command will display the roles and privileges that have been assigned to USER1 in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 137
Skipped
Which query type is supported for implementing the search optimization service?

Correct answer
Geography value column searches using geospatial functions

String searches on columns using the COLLATE function

Substring search queries on external tables

Queries with column concatenation

Overall explanation
This feature improves the performance of queries involving geospatial data, allowing for efficient searching and filtering of geography-related values. It enhances query execution speed for specific types of queries, such as those dealing with geographical data points, making it ideal for geospatial use cases.

For more detailed information, refer to the official Snowflake documentation.

Question 138
Skipped
Which role must be used to create resource monitors?

Correct answer
ACCOUNTADMIN

ORGADMIN

SYSADMIN

SECURITYADMIN

Overall explanation
Resource monitors help you manage costs and prevent surprise charges from running warehouses. Warehouses use Snowflake credits when they're running, and resource monitors track this credit use, including the cloud services they need.

Only the ACCOUNTADMIN can create a resource monitor, but they can give others permission to view and change them.

For more detailed information, refer to the official Snowflake documentation.

Question 139
Skipped
The Snowflake Cloud Data Platform is described as having which of the following architectures?

Shared-disk

Serverless query engine

Shared-nothing

Correct answer
Multi-cluster shared data

Overall explanation
The Snowflake Cloud Data Platform is described as having a multi-cluster shared data architecture. This architecture separates compute and storage, allowing multiple compute clusters to access the same data without duplication.



For more detailed information, refer to the official Snowflake documentation.

Question 140
Skipped
How many resource monitors can be assigned at the account level?

Correct answer
1

3

4

2

Overall explanation
In Snowflake, only one resource monitor can be assigned at the account level to track and manage the credit usage across the account.

For more detailed information, refer to the official Snowflake documentation.

Question 141
Skipped
Which REST API can be used with unstructured data?

insertReport

Correct answer
GET /api/files/

insertFiles

loadHistoryScan

Overall explanation
This API endpoint allows for managing and accessing unstructured data stored in Snowflake stages, enabling users to retrieve and interact with files stored in external or internal stages.

For more detailed information, refer to the official Snowflake documentation.

Question 142
Skipped
What will happen if a Snowflake user increases the size of a suspended virtual warehouse?

The warehouse will remain suspended but new resources will be added to the query acceleration service.

Correct answer
The provisioning of additional compute resources will be in effect when the warehouse is next resumed.

The warehouse will resume immediately and start to share the compute load with other running virtual warehouses.

The provisioning of new compute resources for the warehouse will begin immediately.

Overall explanation
When a user increases the size of a suspended virtual warehouse, the new size takes effect only when the warehouse is resumed. The change does not trigger immediate resource provisioning while the warehouse remains suspended.

For more detailed information, refer to the official Snowflake documentation.

Question 143
Skipped
What is the maximum total Continuous Data Protection (CDP) charges incurred for a temporary table?

7 days

Correct answer
24 hours

48 hours

30 days

Overall explanation
Temporary tables are not subject to Time Travel beyond this period, and they do not incur Fail-safe charges since they are automatically dropped at the end of a session.

For more detailed information, refer to the official Snowflake documentation.

Question 144
Skipped
Which element in the Query Profile interface shows the relationship between the nodes in the execution of a query?

Steps

Overview

Correct answer
Operator Tree

Node List

Overall explanation
The element in the Query Profile interface that shows the relationship between the nodes in the execution of a query is the Operator Tree. This tree visually represents the flow and execution steps of a query, illustrating how different operations are connected and how data moves through the process.

For more detailed information, refer to the official Snowflake documentation.

Question 145
Skipped
What Snowflake features are recommended to restrict unauthorized users from accessing Personal Identifiable Information (PII)? (Choose two.)

Correct selection
Secure views

Correct selection
Dynamic Data Masking

Transient tables

Data encryption

Multi-Factor Authentication (MFA)

Overall explanation
Dynamic Data Masking automatically obfuscates sensitive data (such as PII) when accessed by users without the proper privileges, ensuring that only authorized users can view the actual data.

Secure views protect sensitive data by ensuring that users can only access rows of tables that meet specific filtering criteria set by the view. This prevents unauthorized exposure to restricted data.

Other options are related to Snowflake CDP (Continuous Data Protection) but not directly related to PII data management.

For more detailed information about Secure Views, refer to the official Snowflake documentation.

For more detailed information about Dynamic Data Masking, refer to the official Snowflake documentation.

Question 146
Skipped
A user has semi-structured data to load into Snowflake but is not sure what types of operations will need to be performed on the data.

Based on this situation, what type of column does Snowflake recommend be used?

ARRAY

Correct answer
VARIANT

OBJECT

TEXT

Overall explanation
VARIANT is designed to store semi-structured data like JSON, Avro, Parquet, and XML, and it provides flexibility by allowing the user to perform operations on the data without knowing in advance what those operations will be. It efficiently stores and processes complex, nested structures.

For more detailed information, refer to the official Snowflake documentation.

Question 147
Skipped
How can a data provider share their Snowflake data? (Choose two.)

Snowpark API

External table

Correct selection
Snowflake Marketplace listing

Correct selection
Direct share

External function

Overall explanation
A data provider can share their Snowflake data using Direct share and Snowflake Marketplace listing. Direct share allows providers to share data securely and in real-time with consumers, without data replication. The Snowflake Marketplace listing enables providers to make their data available to a wider audience, allowing consumers to discover and access shared datasets easily.

For more detailed information, refer to the official Snowflake documentation.

Question 148
Skipped
Users with the ACCOUNTADMIN role can execute which of the following commands on existing users?

Can DEFINE users, DESCRIBE a given user, or ALTER or DELETE a user

Can SHOW users, DEFINE a given user or ALTER, DROP, or MODIFY a user

Can SHOW users, INDEX a given user, or ALTER or DELETE a user

Correct answer
Can SHOW users DESCRIBE a given user, or ALTER or DROP a user

Overall explanation
The ACCOUNTADMIN role has full administrative privileges, allowing it to manage user accounts, modify user attributes, and delete users as needed within the Snowflake account.

For more detailed information, refer to the official Snowflake documentation.

Question 149
Skipped
Which process does Snowflake follow when a stored procedure with owner's rights is called within a session?

The procedure will be run with the privileges of the caller.

The owner can view the caller's session variables.

The owner can set the caller's session variables.

Correct answer
The owner will inherit the caller's current virtual warehouse.

Overall explanation
Owner's rights stored procedures operate with the privileges of the owner, not the user who calls the procedure. This is the main difference from caller's rights procedures, which inherit the caller's privileges.

These procedures use the database and schema where they were created and inherit the caller's current warehouse. However, they are restricted from accessing or modifying most of the caller's session-specific information, such as session variables or certain INFORMATION_SCHEMA functions that depend on the current user.

For more detailed information, refer to the official Snowflake documentation.

Question 150
Skipped
Which data formats are supported by Snowflake when unloading semi-structured data? (Choose two.)

Correct selection
Binary file in Parquet

Binary file in Avro

Correct selection
Newline Delimited JSON

Plain text file containing XML elements

Comma-separated JSON

Overall explanation
These formats are commonly used for efficiently handling and storing semi-structured data, providing flexibility and compatibility with various external systems while maintaining efficient data storage and retrieval in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 151
Skipped
The property MINS_TO_BYPASS_NETWORK_POLICY is set at which level?

Correct answer
User

Organization

Role

Account

Overall explanation
The MINS_TO_BYPASS_NETWORK_POLICY property is set at the user level in Snowflake. This property allows temporary bypassing of an active network policy for a specified number of minutes, granting the user access even if their IP does not comply with the current network policy restrictions.

To enable this property, we should contact Snowflake Support.

For more detailed information, refer to the official Snowflake documentation.

Question 152
Skipped
How does clustering depth impact query performance?

Low clustering depth indicates that there are a large number of overlapping micro-partitions and that the query pruning is efficient.

High clustering depth indicates that too many users are scanning the same micro-partitions, slowing down query performance.

High clustering depth indicates that queries are taking advantage of caching and that the queries are running efficiently.

Correct answer
Low clustering depth indicates that there are few overlapping micro-partitions and that the query pruning is efficient.

Overall explanation
Clustering depth quantifies how much micro-partitions overlap for the specified clustering columns in a table. It represents the average number of overlapping partitions (minimum value of 1).

A lower average depth indicates minimal overlap, which reflects better physical data organization. Reduced overlap improves partition pruning efficiency, as fewer micro-partitions need to be scanned for queries filtering on those columns.

Conversely, a high clustering depth signals excessive overlap and suboptimal clustering, leading to less effective pruning and increased data scanning.

Clustering depth is strictly a storage organization metric. It does not relate to caching behavior or query concurrency, but rather to how well table data is structured to support pruning.

For more detailed information, refer to the official Snowflake documentation.

Question 153
Skipped
Which semi-structured file formats are supported when unloading data from a table? (Choose two.)

XML

ORC

Avro

Correct selection
Parquet

Correct selection
JSON

Overall explanation
The semi-structured file formats supported when unloading data from a table in Snowflake are Parquet and JSON. These formats are ideal for handling complex and nested data structures, making them efficient for storing and querying semi-structured data.

For more detailed information, refer to the official Snowflake documentation.

Question 154
Skipped
How does Snowflake handle the data retention period for a table if a stream has not been consumed?

The data retention period is not affected by the stream consumption.

The data retention period s reduced to a minimum of 14 days.

The data retention period is permanently extended for the table.

Correct answer
The data retention period is temporarily extended to the stream’s offset.

Overall explanation
Snowflake maintains data changes as long as a stream’s offset has not been fully consumed, extending the retention period to ensure the stream can capture all necessary changes.

For more detailed information, refer to the official Snowflake documentation.

Question 155
Skipped
Which Snowflake URL type allows users or applications to download or access files directly from Snowflake stage without authentication?

Directory

File

Correct answer
Pre-signed

Scoped

Overall explanation
Pre-signed allows users or applications to download or access files directly from Snowflake stage without authentication.

For more detailed information, refer to the official Snowflake documentation.

Question 156
Skipped
What entity is responsible for hosting and sharing data in Snowflake?

Correct answer
Data provider

Managed account

Data consumer

Reader account

Overall explanation
A data provider can share data with others using secure data sharing features, allowing external organizations or Snowflake accounts to access the data without physically copying it, ensuring real-time access to shared datasets.

For more detailed information, refer to the official Snowflake documentation.

Question 157
Skipped
A Snowflake user needs to share unstructured data from an internal stage to a reporting tool that does not have Snowflake access.

Which file function should be used?

BUILD_STAGE_FILE_URL

Correct answer
GET_PRESIGNED_URL

GET_STAGE_LOCATION

BUILD_SCOPED_FILE_URL

Overall explanation
The function GET_PRESIGNED_URL should be used. This function generates a temporary, signed URL that can be shared with external tools or users who do not have direct Snowflake access, allowing them to retrieve files from an internal stage securely.

For more detailed information, refer to the official Snowflake documentation.

Question 158
Skipped
The MAXIMUM size for a serverless task run is equivalent to what size virtual warehouse?

Large

Correct answer
2X-Large

4X-Large

Medium

Overall explanation
The maximum size for a serverless task run in Snowflake is equivalent to a 2X-Large virtual warehouse.

For more detailed information, refer to the official Snowflake documentation.

Question 159
Skipped
What is the MINIMUM configurable idle timeout value for a session policy in Snowflake?

10 minutes

2 minutes

Correct answer
5 minutes

15 minutes

Overall explanation
The minimum configurable idle timeout value for a session policy in Snowflake is 5 minutes. This setting determines the amount of idle time before a session is automatically terminated to help manage session lifecycles and enhance security.

For more detailed information, refer to the official Snowflake documentation.

Question 160
Skipped
Which file format option should be used when unloading data into a stage to create a CSV or a JSON file?

TRIM_SPACE

PARSE_HEADER

SKIP_HEADER

Correct answer
FILE_EXTENSION

Overall explanation
FILE_EXTENSION sets the file extension for unloaded files. It accepts any string, and it's the user's responsibility to choose a valid extension compatible with the target software or service.

If not specified (default: null), the extension is automatically based on the file format type (e.g., .csv) and may include an additional extension based on the compression method (if COMPRESSION is set).

For more detailed information, refer to the official Snowflake documentation.

Question 161
Skipped
What tasks can be performed using Snowflake Cortex AI? (Select TWO).

Share data through the Snowflake Marketplace.

Enhanced data security.

Correct selection
Extract and classify text.

Correct selection
Simplify unstructured data workflows.

Load semi-structured data.

Overall explanation
A few comments:

Snowflake Cortex provides access to Large Language Models (LLMs) and specific ML functions (such as SNOWFLAKE.CORTEX.CLASSIFY_TEXT and SNOWFLAKE.CORTEX.EXTRACT_ANSWER). These functions allow users to perform Natural Language Processing (NLP) tasks like determining the category of a text string or extracting specific values from a document directly within SQL.

Cortex AI is designed to unlock value from unstructured data (like PDFs, emails, and raw text) without moving it out of Snowflake.

Loading semi-structured data is handled by the core storage engine and COPY INTO commands, not Cortex AI.

Sharing data is handled by the Snowflake Secure Data Sharing and Marketplace features.

For more detailed information, refer to the official Snowflake documentation.

Question 162
Skipped
Which feature allows users to audit how sensitive data is being accessed over time?

Column-level security

Tag-based masking policy

Correct answer
Object tagging

Row-level security

Overall explanation
Object tagging provides a metadata-based mechanism to identify and monitor sensitive data across Snowflake objects over time.

When classification processes detect sensitive content, Snowflake can assign system-defined or custom tags to the relevant columns. Once applied, these tags can be queried to discover where sensitive data resides and to monitor how it is referenced, supporting compliance and audit requirements.

By tagging objects and querying tag metadata, organizations gain visibility into sensitive data distribution across tables and columns, enabling structured governance and oversight.

Other features serve enforcement purposes—such as row-level security, column-level controls, or masking policies—but tagging itself is the mechanism used for identification, tracking, and audit visibility.

For more detailed information, refer to the official Snowflake documentation.

Question 163
Skipped
What is a characteristic of materialized views in Snowflake?

Clones of materialized views can be created directly by the user.

Aggregate functions can be used as window functions in materialized views.

Multiple tables can be joined in the underlying query of a materialized view.

Correct answer
Materialized views do not allow joins.

Overall explanation
In Snowflake, materialized views are limited in functionality compared to regular views. They cannot contain joins or other complex operations, as they are designed to store precomputed results for simple queries to optimize query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 164
Skipped
A user is loading JSON documents composed of a huge array containing multiple records into Snowflake. The user enables the STRIP_OUTER_ARRAY file format option.

What does the STRIP_OUTER_ARRAY file format do?

It removes the trailing spaces in the last element of the outer array and loads the records into separate table columns.

It removes the last element of the outer array.

Correct answer
It removes the outer array structure and loads the records into separate table rows.

It removes the NULL elements from the JSON object eliminating invalid data and enables the ability to load the records.

Overall explanation
The STRIP_OUTER_ARRAY file format option in Snowflake removes the outer array structure and loads the records into separate table rows. This allows Snowflake to handle each element of the array as an individual row in the table, making it easier to load and query large JSON arrays that contain multiple records.

For more detailed information, refer to the official Snowflake documentation.

Question 165
Skipped
A user executed a SELECT query in Snowsight which returned a 1 GB result set. The user then downloads the files.



What will occur?

The download will result in an error because the filters of the SELECT query need to be changed so that Snowsight returns a smaller result set.

Correct answer
The result set will be successfully downloaded from Snowsight.

The result set will be automatically compressed and the data will be downloaded as individual files.

The download will fail because the result set needs to be broken up into files no greater than 50 MB before downloading.

Overall explanation
Snowsight addresses a key limitation of the deprecated Classic Web Interface: query result download limits. While the Classic Web Interface only allowed users to download the first 100 MB of a query result as a CSV, Snowsight enables users to download the full result of their queries as an uncompressed CSV file.

Question 166
Skipped
Account-level storage usage can be monitored via:

Correct answer
The Snowflake Web Interface (Snowsight) in the Admin-> Cost Management

The Account Usage Schema -> ACCOUNT_USAGE_METRICS View

The Snowflake Web Interface (Snowsight) in the Databases section

The Information Schema -> ACCOUNT_USAGE_HISTORY View

Overall explanation
Account-level storage usage can be monitored through the Snowflake Web Interface (Snowsight) under the Admin section, specifically in the Cost Management area. This provides insights into storage costs and usage across the account, helping users manage resources effectively.

For more detailed information, refer to the official Snowflake documentation.

Question 167
Skipped
Which privileges are required for a user to restore an object? (Choose two.)

Correct selection
OWNERSHIP

UPDATE

MODIFY

Correct selection
CREATE

UNDROP

Overall explanation
The privileges required for a user to restore an object in Snowflake are OWNERSHIP and CREATE. The OWNERSHIP privilege allows full control over the object, and the CREATE privilege is necessary to recreate or restore the object using Snowflake’s Time Travel feature.

For more detailed information, refer to the official Snowflake documentation.

Question 168
Skipped
When unloading data, which combination of parameters should be used to differentiate between empty strings and NULL values? (Choose two.)

ESCAPE_UNENCLOSED_FIELD

Correct selection
EMPTY_FIELD_AS_NULL

Correct selection
FIELD_OPTIONALLY_ENCLOSED_BY

REPLACE_INVALID_CHARACTERS

SKIP_BLANK_LINES

Overall explanation
An empty string has no characters, while a NULL value means there's no data at all. In CSV files, NULL is often shown by two commas together (,,), but you can also use words like "null". An empty string is usually shown as two quotes together ('').

The FIELD_OPTIONALLY_ENCLOSED_BY and EMPTY_FIELD_AS_NULL file format options help you tell the difference between empty strings and NULL values when moving data in or out of files.

For more detailed information, refer to the official Snowflake documentation.

Question 169
Skipped
Which of the following objects can be shared through secure data sharing?

Task

Correct answer
External table

Masking policy

Stored procedure

Overall explanation
Among the listed objects, only external tables can be shared through Snowflake's secure data sharing feature. Secure data sharing allows external tables, as well as regular tables, views, and secure views, to be shared with other Snowflake accounts or reader accounts without moving or copying the data.

For more detailed information, refer to the official Snowflake documentation.

Question 170
Skipped
What is used to diagnose and troubleshoot network connections to Snowflake?

SnowSQL

Correct answer
SnowCD

Snowsight

Snowpark

Overall explanation
SnowCD is a tool designed to help with identifying and resolving network connectivity issues between a client and the Snowflake service, providing diagnostics for troubleshooting.

For more detailed information, refer to the official Snowflake documentation.

Question 171
Skipped
How does a Snowflake user extract the URL of a directory table on an external stage for further transformation?

Use the SHOW STAGES command.

Use the GET_ABSOLUTE_PATH function.

Correct answer
Use the GET_STAGE_LOCATION function.

Use the DESCRIBE STAGE command.

Overall explanation
To extract the URL of a directory table on an external stage for further transformation, a Snowflake user should use the GET_STAGE_LOCATION function. This function returns the location of the stage, including the full URL, which can then be used for further operations or transformations.

For more detailed information, refer to the official Snowflake documentation.

Question 172
Skipped
Which copy option is used to include column headers when unloading data to Parquet files?

SKIP_HEADER = <integer>

HEADER = ('<header_1>' = '<value_1>')

Correct answer
HEADER = TRUE

PARSE_HEADER = TRUE

Overall explanation
To preserve column names when unloading data to Parquet, the HEADER = TRUE option must be specified in the COPY INTO command.

When enabled, the resulting Parquet files retain the original table column names. If HEADER = FALSE, generic column labels (such as col1, col2, etc.) are written instead.

Options like PARSE_HEADER and SKIP_HEADER apply to data loading scenarios, not unloading. Proper syntax requires defining the file format and explicitly setting the HEADER parameter within the COPY INTO statement.

For more detailed information, refer to the official Snowflake documentation.

Question 173
Skipped
In a SPLIT_PART function, what will the returned value be if the partNumber is out of range?

An error

Correct answer
An empty string

−1

The full string

Overall explanation
If the partNumber in the SPLIT_PART function is out of range (i.e., there are fewer parts than specified), Snowflake will return an empty string instead of throwing an error.

For more detailed information, refer to the official Snowflake documentation.

Question 174
Skipped
What privilege does a user need in order to receive or request data from the Snowflake Marketplace?

IMPORTED PRIVILEGES

CREATE DATA EXCHANGE LISTING

Correct answer
IMPORT SHARE

CREATE SHARE

Overall explanation
IMPORT SHARE. This privilege allows the user to import shared data from another account, which is necessary when accessing data shared through the Snowflake Marketplace.

For more detailed information, refer to the official Snowflake documentation.

Question 175
Skipped
What is a characteristic of data micro-partitioning in Snowflake?

Micro-partitioning can be disabled within a Snowflake account

Correct answer
Micro-partitioning happens when the data is loaded

Micro-partitioning requires the definition of a partitioning schema

Micro-partitioning may introduce data skew