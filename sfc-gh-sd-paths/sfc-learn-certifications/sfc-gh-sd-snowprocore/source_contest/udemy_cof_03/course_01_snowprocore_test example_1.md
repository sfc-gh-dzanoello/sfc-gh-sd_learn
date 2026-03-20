Question 1
Incorrect
Which Snowflake partner specializes in data catalog solutions?

DataRobot

Tableau

Correct answer
Alation

Your answer is incorrect
dbt

Overall explanation
The exam will include a question about a Snowflake ecosystem partner. It is not necessary to remember all of the tools, but at least the most relevant ones in each of the categories.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 2
Skipped
What is one of the benefits of using a multi-cluster virtual warehouse?

It will automatically increase the warehouse size as needed.

It will reduce the cost of running the warehouse.

Correct answer
It will automatically start and stop additional clusters as needed.

It will speed up data loading.

Overall explanation
One of the benefits of using a multi-cluster virtual warehouse is that it will automatically start and stop additional clusters as needed. This feature helps optimize performance and concurrency by dynamically scaling the number of clusters up or down based on the workload. This ensures that the virtual warehouse can handle high query volumes efficiently without manual intervention, while also saving costs by reducing the number of active clusters when demand decreases.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 3
Skipped
Which stream type can be used for tracking the records in external tables?

Append-only

Correct answer
Insert-only

External

Standard

Overall explanation
The insert-only streams are supported for Apache Iceberg™ or external tables. These streams track row inserts but do not record delete operations. For example, if a file is removed from cloud storage and replaced with a new one, the stream will only capture inserts from the new file and not the deleted rows from the previous file. The stream also does not capture changes between old and new file versions, and appending new files might not trigger an automatic refresh of the external table's metadata.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
Which system-defined Snowflake role has permission to rename an account and specify whether the original URL can be used to access the renamed account?

Correct answer
ORGADMIN

SECURITYADMIN

ACCOUNTADMIN

SYSADMIN

Overall explanation
This role manages organization-wide configurations, including account-level changes like renaming and setting up URL redirection for continuity.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
Query results are stored in the Result Cache for how long after they are last accessed, assuming no data changes have occurred?

3 Hours

Correct answer
24 Hours

1 Hour

12 Hours

Overall explanation
Query results are stored in the Result Cache for 24 hours after they are last accessed, assuming no data changes have occurred during that time. This helps in reusing the results to improve query performance without needing to recompute them if the same query is run again within this period.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 6
Skipped
What are key characteristics of virtual warehouses in Snowflake? (Choose two.)

Warehouses are billed on a per-minute usage basis.

Warehouses that are multi-cluster can have nodes of different sizes.

Warehouses can only be used for querying and cannot be used for data loading.

Correct selection
Warehouses can be resized at any time, even while running.

Correct selection
Warehouses can be started and stopped at any time.

Overall explanation
Key characteristics of virtual warehouses in Snowflake are: Warehouses can be started and stopped at any time, giving users control over resource usage and costs, and warehouses can be resized at any time, even while running, allowing users to scale resources up or down dynamically based on their current workload, ensuring efficiency and performance without disrupting operations.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 7
Skipped
What triggers the automated maintenance of a table's clustering key after it has been defined?

A time-based schedule set by the user.

A Snowflake determination based on the table size.

Correct answer
A Snowflake determination that the table will benefit from maintenance.

A scheduled task established by the ORGADMIN.

Overall explanation
Snowflake automatically decides when to recluster based on internal optimization logic. It considers whether reclustering will improve performance and only runs it when beneficial.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
What function can be used with the recursive argument to return a list of distinct key names in all nested elements in an object?

PARSE_JSON

GET_PATH

Correct answer
FLATTEN

CHECK_JSON

Overall explanation
The FLATTEN function, when used with the recursive argument, can return a list of distinct key names in all nested elements of an object. FLATTEN is designed to work with semi-structured data, such as JSON, and allows traversing through nested structures to extract and work with individual elements.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
Which of the following objects is not covered by Time Travel?

Schemas

Correct answer
Stages

Tables

Databases

Overall explanation
Time Travel in Snowflake covers objects like tables, schemas, and databases, allowing for recovery of data or structures within a defined period, but it does not apply to stages. Stages are used for file storage during loading, but they do not have the same data recovery capabilities.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 10
Skipped
Snowflake’s hierarchical key mode includes which keys? (Choose two.)

Database master keys

Correct selection
Account master keys

Secure view keys

Correct selection
File keys

Schema master keys

Overall explanation
Snowflake’s hierarchical key: Root key, Account master keys, Table master keys, File keys.



For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
A deterministic query is run at 8am, takes 5 minutes, and the results are cached. Which of the following statements are true? (Choose two.)

The exact query will ALWAYS return the precomputed result set for the RESULT_CACHE_ACTIVE = time period.

Correct selection
The 24-hour timer on the precomputed results gets renewed every time the exact query is executed.

Correct selection
The same exact query will return the precomputed results if the underlying data hasn't changed and the results were last accessed within previous 24 hour period.

The same exact query will return the precomputed results even if the underlying data has changed as long as the results were last accessed within the previous 24 hour period.

The 24-hour timer on the precomputed results is not extended even if the exact query is rerun.

Overall explanation
The same exact query will return the precomputed results if the underlying data hasn't changed and the results were last accessed within the previous 24-hour period, and the 24-hour timer on the precomputed results gets renewed every time the exact query is executed.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 12
Skipped
If auto-suspend is enabled for a Virtual Warehouse, the Warehouse is automatically suspended when:

All Snowflakes sessions using the Warehouse are terminated.

The last query using the Warehouse completes.

Correct answer
The Warehouse is inactive for a specified period of time.

There are no users logged into Snowflake.

Overall explanation
If auto-suspend is enabled for a Virtual Warehouse, the Warehouse is automatically suspended when it is inactive for a specified period of time. This feature helps to reduce costs by releasing compute resources when the warehouse is not actively processing queries.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 13
Skipped
Given the statement template below, which database objects can be added to a share? (Choose two.)

GRANT [privilege] ON [object] [object_name] TO SHARE [share_name];

Correct selection
Tables

Correct selection
Secure functions

Streams

Stored procedures

Tasks

Overall explanation
Tables and secure functions can be added to a share, allowing controlled access to data and specific secure operations within a shared environment.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
What commands can be used to see what files are stored in a stage? (Choose two.)

GET

Correct selection
LIST

SELECT

DESCRIBE

Correct selection
LS

Overall explanation
LIST command returns a list of files that have been staged, meaning they have been uploaded from a local file system or unloaded from a table. The LIST command can be abbreviated as LS.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
A Snowflake query took 40 minutes to run. The results indicate that ‘Bytes spilled to local storage’ was a large number.

What is the issue and how can it be resolved?

The warehouse consists of a single cluster. Use a multi-cluster warehouse to reduce the spillage.

Correct answer
The warehouse is too small. Increase the size of the warehouse to reduce the spillage.

The warehouse is too large. Decrease the size of the warehouse to reduce the spillage.

The Snowflake console has timed-out. Contact Snowflake Support.

Overall explanation
Increase the size of the warehouse to reduce the spillage. When bytes are spilled to local storage, it indicates that the query required more memory than the warehouse could provide, causing data to be temporarily stored on disk. By increasing the warehouse size, more memory will be available to handle the query, reducing the likelihood of spillage and improving performance.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 16
Skipped
Which statement best describes Snowflake tables?

Snowflake tables are owned by a user

Correct answer
Snowflake tables are logical representations of underlying physical data

Snowflake tables require that clustering keys be defined to perform optimally

Snowflake tables are the physical instantiation of data loaded into Snowflake

Overall explanation
Snowflake tables are logical representations of underlying physical data, meaning they abstract the physical storage and are managed by Snowflake automatically.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 17
Skipped
What activities can a user with the ORGADMIN role perform? (Choose two.)

Correct selection
Create an account for an organization.

Delete the account data for an organization.

Edit the account data for an organization

Correct selection
View usage information for all accounts in an organization.

Select all the data in tables for all accounts in an organization.

Overall explanation
The ORGADMIN role has the ability to manage organizational-level tasks, such as account creation, managing account usage, and monitoring across all accounts within the organization.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 18
Skipped
Which Snowflake table objects can be shared with other accounts? (Choose two.)

Event tables

Correct selection
External tables

User-Defined Table Functions (UDTFs)

Correct selection
Permanent tables

Temporary tables

Overall explanation
Permanent tables and external tables can be shared with other accounts in Snowflake, enabling secure data sharing while maintaining control over the shared objects. Temporary and event tables cannot be shared.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
Which is true of Snowflake network policies? A Snowflake network policy: (Choose two.)

Correct selection
Restricts or enables access to specific IP addresses

Is activated using an ALTER DATABASE command

Correct selection
Is available to all Snowflake Editions

Is only available to customers with Business Critical Edition

Is only available to customers with Virtual Private Snowflake (VPS) Edition

Overall explanation
Snowflake network policies are available across all Snowflake Editions, and they provide the ability to restrict or allow access to specific IP addresses, helping to secure access by defining which networks are permitted to connect to the Snowflake environment.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
What is used to denote a pre-computed data set derived from a SELECT query specification and stored for later use?

External table

Correct answer
Materialized view

Secure view

View

Overall explanation
A materialized view in Snowflake is a pre-computed data set derived from a SELECT query specification and stored for later use. Unlike regular views, materialized views store the results of the query, which improves performance by allowing future queries to access the pre-computed data rather than recomputing it each time. This is especially useful for frequently queried or complex data sets.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 21
Skipped
Files have been uploaded to a Snowflake internal stage. The files now need to be deleted.

Which SQL command should be used to delete the files?

PURGE

DELETE

Correct answer
REMOVE

MODIFY

Overall explanation
REMOVE SQL command should be used to delete files from a Snowflake internal stage. This command removes the specified files from the stage, clearing them out for future operations.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 22
Skipped
Which Snowflake object uses credits for maintenance?

Cached query result

Regular table

Regular view

Correct answer
Materialized view

Overall explanation
Materialized view uses credits for maintenance. Snowflake automatically updates materialized views to keep them in sync with the base table, which incurs credit usage during this maintenance process.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
Which file formats support unloading semi-structured data? (Choose two.)

XML

Correct selection
JSON

ORC

Avro

Correct selection
Parquet

Overall explanation
JSON and Parquet are file formats that support unloading semi-structured data in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
What is the purpose of using the OBJECT_CONSTRUCT function with the COPY INTO command?

Reorder the data columns according to a target table definition and then unload the rows into the table.

Reorder the rows in a relational table and then unload the rows into a file.

Convert the rows in a source file to a single VARIANT column and then load the rows from the file to a variant table.

Correct answer
Convert the rows in a relational table to a single VARIANT column and then unload the rows into a file.

Overall explanation
This command allows for the transformation of structured data into semi-structured JSON-like format, which can be stored or transferred in a more flexible format.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 25
Skipped
Which Snowflake object can be created to be temporary?

Correct answer
Stage

Role

User

Storage integration

Overall explanation
In Snowflake, a stage can be created as a temporary object. Temporary stages are session-based and automatically dropped when the session ends, making them ideal for storing intermediate data or files during temporary processes without affecting permanent storage.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 26
Skipped
How can a 5 GB table be downloaded into a single file MOST efficiently?

Use a regular expression in the stage specifications of the COPY command.

Keep the default MAX_FILE_SIZE to 16 MB.

Correct answer
Set the SINGLE parameter to TRUE.

Set the default MAX_FILE_SIZE to 5 GB.

Overall explanation
The COPY INTO <location> command allows us to use the SINGLE option to unload data into either a single file or multiple files. By default, SINGLE = FALSE, meaning the data is unloaded into multiple files.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
What is the maximum row size in Snowflake?

Correct answer
16MB

5000GB

8KB

50MB

Overall explanation
The maximum row size in Snowflake is 16MB.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 28
Skipped
Which of the following is true of Snowpipe via REST API? (Choose two.)

You can only use it on Internal Stages

Correct selection
Snowflake automatically manages the compute required to execute the Pipe's COPY INTO commands

You can only use it on External Stages

All COPY INTO options are available during pipe creation

Correct selection
Snowpipe keeps track of which files it has loaded

Overall explanation
These features help ensure efficient and automated data loading processes, while avoiding duplication of file loading.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 29
Skipped
Which Snowflake edition supports Protected Health Information (PHI) data (in accordance with HIPAA and HITRUST CSF regulations), and has a dedicated metadata store and pool of compute resources?

Correct answer
Virtual Private Snowflake (VPS)

Business Critical

Enterprise

Standard

Overall explanation
This Snowflake edition supports Protected Health Information (PHI) data in compliance with HIPAA and HITRUST CSF regulations. It provides a dedicated metadata store and a separate pool of compute resources, ensuring enhanced security, privacy, and isolation of sensitive data, ideal for organizations with stringent regulatory requirements.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 30
Skipped
Which command can be used to list all the file formats for which a user has access privileges?

ALTER FILE FORMAT

Correct answer
SHOW FILE FORMATS

LIST

DESCRIBE FILE FORMAT

Overall explanation
SHOW FILE FORMATS command can be used in Snowflake to list all the file formats for which a user has access privileges. It provides a detailed view of the file formats that are available within the account, helping users manage and view the formats they have permissions to use for data loading or unloading.

For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
Snowflake provides two mechanisms to reduce data storage costs for short-lived tables. These mechanisms are: (Choose two.)

Permanent Tables

Provisional Tables

Ephemeral Tables

Correct selection
Temporary Tables

Correct selection
Transient Tables

Overall explanation
Snowflake supports Temporary Tables and Transient Tables to manage data storage costs for short-lived tables. Temporary tables are session-based and deleted when the session ends, while transient tables are intended for data that needs to be kept beyond the session but without a Fail-safe period for recovery.



For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 32
Skipped
What is the Snowflake multi-clustering feature for virtual warehouses used for?

To improve data loading from very large data sets

To improve the data unloading process to the cloud

Correct answer
To improve concurrency for users and queries

To speed up slow or stalled queries

Overall explanation
Snowflake’s multi-clustering feature allows a virtual warehouse to automatically scale by adding or removing clusters to handle concurrent users and queries more efficiently. This helps in managing workloads without affecting performance during peak usage.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 33
Skipped
When should you consider disabling auto-suspend for a Virtual Warehouse? (Choose two.)

Correct selection
When managing a steady workload

Correct selection
When the compute must be available with no delay or lag time

When you do not want to have to manually turn on the Warehouse each time a user needs it

When using Warehouses with standard scaling policy

When users will be using compute at different times throughout a 24/7 period

Overall explanation
You should consider disabling auto-suspend for a Virtual Warehouse when the compute must be available with no delay or lag time, and when managing a steady workload. In these cases, keeping the warehouse active ensures immediate availability without the need for re-provisioning, which can introduce delays.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 34
Skipped
If a virtual warehouse runs for 61 seconds, shuts down, and then restarts and runs for 30 seconds, for how many seconds is it billed?

Correct answer
121

120

91

60

Overall explanation
First session (61 seconds) is billed as 61 seconds, because anything over 60 seconds is billed exactly as the elapsed time. Second session (30 seconds) is billed as 60 seconds (minimum).

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
Snowflake users can create a resource monitor at which levels? (Choose two.)

Cloud services level

Pipe level

User level

Correct selection
Virtual warehouse level

Correct selection
Account level

Overall explanation
Resource monitors can be defined at the account level to control overall credit usage or at the virtual warehouse level to track and limit specific compute resources. Other levels are not supported for this feature.

We can use the budgets capability to control the cost on other objects or levels in a complementary way.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
Which command is used to take away staged files from a Snowflake stage after a successful data ingestion?

Correct answer
REMOVE

DROP

TRUNCATE

DELETE

Overall explanation
REMOVE command is used to take away staged files from a Snowflake stage after a successful data ingestion.

For more detailed information, refer to the official Snowflake documentation.

For more detailed information about REMOVE command, refer to the official Snowflake documentation.

Question 37
Skipped
How can a user improve the performance of a single large complex query in Snowflake?

Enable economy warehouse scaling.

Enable standard warehouse scaling.

Correct answer
Scale up the virtual warehouse.

Scale out the virtual warehouse.

Overall explanation
To improve the performance of a single large complex query in Snowflake, scaling up the virtual warehouse increases the computational resources (CPU, memory, etc.), allowing the query to process more efficiently. This is ideal for workloads that require substantial compute power but do not benefit from parallelism, as would be the case in scaling out.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 38
Skipped
Which function can be used to convert semi-structured data into rows and columns?

TABLE

Correct answer
FLATTEN

JSON_EXTRACT_PATH_TEXT

PARSE_JSON

Overall explanation
FLATTEN converts semi-structured data (like VARIANTs, OBJECTs, and ARRAYs) into a table format. It creates a special view called a lateral view, which can refer back to other tables in your query. This helps you work with data that isn't already in rows and columns.

For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
Which function should be used to authorize users to access rows in a base table when using secure views with Secure Data Sharing?

CURRENT_USER()

CURRENT_SESSION()

CURRENT_ROLE()

Correct answer
CURRENT_ACCOUNT()

Overall explanation
CURRENT_ACCOUNT() function should be used to authorize users to access rows in a base table when using secure views with Secure Data Sharing. It helps restrict access based on the account that is querying the shared data, ensuring that only authorized accounts can view or interact with the data.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
How does Snowflake define its approach to Discretionary Access Control (DAC)?

An entity to which access can be granted.

A defined level of access to an object.

Access privileges are assigned to roles, which are in turn assigned to users.

Correct answer
Each object has an owner, who can in turn grant access to that object.

Overall explanation
In Snowflake’s approach to Discretionary Access Control (DAC), the ownership model allows object owners to control and grant access to their objects, providing flexibility in permissions management.

For more detailed information, refer to the official Snowflake documentation.

Question 41
Skipped
What is the MINIMUM role required to set the value for the parameter ENABLE_ACCOUNT_DATABASE_REPLICATION?

SECURITYADMIN

ACCOUNTADMIN

Correct answer
ORGADMIN

SYSADMIN

Overall explanation
This role has the necessary privileges to manage organization-level settings, including replication configurations across multiple Snowflake accounts within the same organization.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 42
Skipped
What is a feature of column-level security in Snowflake?

Correct answer
External tokenization

Internal tokenization

Network policies

Role access policies

Overall explanation
Snowflake's Column-level Security allows the application of a masking policy to a column within a table or view. It currently offers two features: Dynamic Data Masking and External Tokenization.

External Tokenization enables accounts to replace sensitive data with undecipherable tokens before loading it into Snowflake, and then revert it during query execution using masking policies integrated with external functions

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 43
Skipped
Which statistic displayed in a Query Profile is specific to external functions?

Correct answer
Total invocations

Bytes written

Bytes sent over the network

Partitions scanned

Overall explanation
This statistic in a Query Profile is specific to external functions, as it shows how many times the external function was called during query execution. It helps monitor the usage and performance of external functions in Snowflake.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 44
Skipped
Which table type has a Fail-safe period of 7 days?

Transient table

External table

Correct answer
Permanent table

Temporary table

Overall explanation
The permanent tables are differentiated from the rest by the 7-day fail safe and by the time travel of up to 90 days (according to Snowflake edition).

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
Which item in the Data Warehouse migration process does not apply in Snowflake?

Migrate Users

Build the Data Pipeline

Correct answer
Migrate Indexes

Migrate Schemas

Overall explanation
Migrate Indexes does not apply in Snowflake, as Snowflake automatically handles performance without traditional database indexes.

This question still refers to Snowflake before Hybrid tables existed (in Preview). Hybrid tables do allow the creation of indexes.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 46
Skipped
A Snowflake user wants to temporarily bypass a network policy by configuring the user object property MINS_TO_BYPASS_NETWORK_POLICY.

What should they do?

Use the SECURITYADMIN role.

Correct answer
Contact Snowflake Support.

Use the USERADMIN role.

Use the SYSADMIN role.

Overall explanation
You can temporarily bypass a network policy for a specified number of minutes by configuring the user object property MINS_TO_BYPASS_NETWORK_POLICY, which can be checked by running the DESCRIBE USER command. Only Snowflake has the ability to set the value for this property. To have it configured, please reach out to Snowflake Support.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 47
Skipped
Which common query problems can the Query Profile help a user identify and troubleshoot? (Choose two.)

Correct selection
When there is a UNION without ALL

When window functions are used incorrectly

When the SELECT DISTINCT command returns too many values

When there are Common Table Expressions (CTEs) without a final SELECT statement

Correct selection
When there are exploding joins

Overall explanation
The Query Profile in Snowflake can help identify and troubleshoot exploding joins, which occur when a query unintentionally multiplies rows due to poorly structured joins, and when there is a UNION without ALL, which may result in performance issues by causing Snowflake to eliminate duplicate rows. These common query problems can significantly impact query performance and are detectable through analysis of the query execution plan

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 48
Skipped
A virtual warehouse initially suffers from poor performance as a result of queries from multiple concurrent processes that are queuing. Over time, the problem resolved.

What action can be taken to prevent this from happening again?

Correct answer
Change the multi-cluster settings to add additional clusters.

Increase the size of the virtual warehouse.

Add a cluster key to the most used JOIN key.

Enable the search optimization service for the underlying tables.

Overall explanation
To prevent performance issues from multiple concurrent queries queuing, enabling multi-cluster mode allows Snowflake to automatically add additional clusters when demand increases. This helps distribute the workload across multiple clusters, reducing queuing and improving overall performance during high-concurrency periods.

For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
Which statement describes how Snowflake supports reader accounts?

A consumer needs to become a licensed Snowflake customer as data sharing is only supported between Snowflake accounts.

The users in a reader account can query data that has been shared with the reader account and can perform DML tasks.

Correct answer
The SHOW MANAGED ACCOUNTS command will view all the reader accounts that have been created for an account.

A reader account can consume data from the provider account that created it and combine it with its own data.

Overall explanation
SHOW MANAGED ACCOUNTS command allows providers to manage and track the reader accounts they have created by using the SHOW MANAGED ACCOUNTS command, ensuring visibility into all reader accounts associated with a provider. Reader account has no data of its own.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
How can a Snowflake user configure a virtual warehouse to support over 100 users if their company has Enterprise Edition?

Use a larger warehouse.

Correct answer
Use a multi-cluster warehouse.

Set the auto-scale to 100.

Add additional warehouses and configure them as a cluster.

Overall explanation
To support over 100 users, Snowflake's multi-cluster warehouse feature can be used. This feature allows a virtual warehouse to automatically scale up or down by adding or removing clusters based on the workload, ensuring better performance and concurrency for a large number of users.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 51
Skipped
A Snowflake user runs a query for 36 seconds on a size 2XL virtual warehouse.

What would be the credit consumption?

Snowflake will charge for 36 seconds at the rate of 32 credits per hour.

Snowflake will charge for 60 seconds at the rate of 64 credits per hour.

Correct answer
Snowflake will charge for 60 seconds at the rate of 32 credits per hour.

Snowflake will charge for 36 seconds at the rate of 64 credits per hour.

Overall explanation
Snowflake will charge for 60 seconds at the rate of 32 credits per hour. Even though the query ran for only 36 seconds, Snowflake rounds up to the nearest full minute. For a 2XL warehouse, which consumes 32 credits per hour, the charge is calculated based on a full minute of usage.



For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
What happens to the objects in a reader account when the DROP MANAGED ACCOUNT command is executed?

The objects enter the Fail-safe period.

The objects are immediately moved to the provider account.

Correct answer
The objects are dropped.

The objects enter the Time Travel period.

Overall explanation
When the DROP MANAGED ACCOUNT command is executed on a reader account, the objects in the reader account are dropped. This means that the data and objects associated with the reader account are permanently removed.

For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
Who can grant object privileges in a regular schema?

Schema owner

SYSADMIN

Database owner

Correct answer
Object owner

Overall explanation
In a regular schema, the object owner has the ability to grant object privileges. This role has the necessary permissions to manage access to specific database objects such as tables, views, or procedures within the schema.

For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
Who can create network policies within Snowflake? (Choose two.)

SYSADMIN only

A role with the CREATE SECURITY INTEGRATION privilege

Correct selection
A role with the CREATE NETWORK POLICY privilege

Correct selection
SECURITYADMIN or higher roles

ORGADMIN only

Overall explanation
SECURITYADMIN or higher roles and a role with the CREATE NETWORK POLICY privilege can create network policies within Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
A developer is granted ownership of a table that has a masking policy. The developer’s role is not able to see the masked data.

Will the developer be able to modify the table to read the masked data?

Yes, because masking policies only apply to cloned tables.

Correct answer
No, because ownership of a table does not include the ability to change masking policies.

Yes, because a table owner has full control and can unset masking policies.

No, because masking policies must always reference specific access roles.

Overall explanation
Masking policies in Snowflake are governed by specific roles, and table ownership alone does not grant the ability to unset or alter those policies. Only users with the correct roles tied to the masking policy can modify it or view the masked data.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 56
Skipped
What consideration should be made when loading data into Snowflake?

Correct answer
The number of data files that are processed in parallel is determined by the virtual warehouse.

The number of load operations that run in parallel can exceed the number of data files to be loaded.

Create large data files to maximize the processing overhead for each file.

Create small data files and stage them in cloud storage frequently.

Overall explanation
When loading data into Snowflake, the virtual warehouse size influences the degree of parallelism during the load process. Larger warehouses can process more files simultaneously, optimizing load performance. It's important to strike a balance between file size and the number of parallel load operations to maximize efficiency.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 57
Skipped
Which statement accurately describes how a virtual warehouse functions?

Correct answer
Each virtual warehouse is a compute cluster composed of multiple compute nodes allocated by Snowflake from a cloud provider.

All virtual warehouses share the same compute resources so performance degradation of one warehouse can significantly affect all the other warehouses.

Each virtual warehouse is an independent compute cluster that shares compute resources with other warehouses.

Increasing the size of a virtual warehouse will always improve data loading performance.

Overall explanation
Virtual warehouses operate independently, with their own compute resources, ensuring that the performance of one warehouse does not affect others. This design enables scalable and isolated performance for different workloads.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 58
Skipped
Which command can be used to delete staged files from a Snowflake stage when the files are no longer needed?

DELETE

Correct answer
REMOVE

TRUNCATE TABLE

DROP

Overall explanation
REMOVE command is used to delete staged files from a Snowflake stage when the files are no longer needed. It ensures that the specified files are removed from the stage, preventing unnecessary reprocessing during future data operations.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
A Snowflake user needs to import a JSON file larger than 16 MB.

What file format option could be used?

compression = auto

strip_outer_array = false

Correct answer
strip_outer_array = true

trim_space = true

Overall explanation
When importing a JSON file larger than 16 MB into Snowflake, setting strip_outer_array = true allows Snowflake to process each element of the outer array as a separate row. This helps overcome size limitations by breaking down large JSON arrays into smaller parts that Snowflake can efficiently load and process.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 60
Skipped
Which command is used to generate a zero-copy "snapshot" of any table, schema, or database?

Correct answer
CREATE ... CLONE

CREATE REPLICATION GROUP

ALTER

COPY INTO

Overall explanation
This command in Snowflake is used to generate a zero-copy "snapshot" of any table, schema, or database. The clone shares the underlying storage with the original object, meaning no additional storage is used until changes are made to either the original or the clone.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 61
Skipped
Which Snowflake features can be enabled by calling the SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER function by a user with the ORGADMIN role? (Choose two.)

Correct selection
Client redirect

Search optimization service

Correct selection
Account and database replication

Fail-safe

Clustering

Overall explanation
The Client redirect and Account and database replication features can be enabled by calling the SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER function by a user with the ORGADMIN role. These features are essential for managing cross-region availability and data replication across Snowflake accounts, ensuring higher availability and better data management.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 62
Skipped
Which security feature is used to connect or log in to a Snowflake account?

Correct answer
Key pair authentication

SCIM

Network policy

Role-Based Access Control (RBAC)

Overall explanation
Key pair authentication is a security feature that allows users to connect or log in to a Snowflake account by using a private key, enhancing security beyond traditional password methods.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
Which command should be used to generate a single file when unloading data from a Snowflake table into a file?

Correct answer
SINGLE = TRUE

MAX_FILE_SIZE = 0

OVERWRITE = TRUE

PARTITION BY [expr]

Overall explanation
By default, Snowflake unloads data into multiple files for better performance. This is particularly helpful for large datasets, as it allows for parallel downloading and faster processing. However, in situations where you require a single output file, such as when integrating with systems that cannot process multiple files, you can use the SINGLE = TRUE option.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
What is the recommended Snowflake data type to store semi-structured data like JSON?

Correct answer
VARIANT

RAW

VARCHAR

LOB

Overall explanation
The recommended Snowflake data type to store semi-structured data like JSON is VARIANT. This data type is specifically designed to handle JSON, XML, and other semi-structured formats efficiently.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 65
Skipped
What strategies can be used to optimize the performance of a virtual warehouse? (Choose two.)

Increase the MAX_CONCURRENCY_LEVEL parameter.

Correct selection
Reduce queuing.

Correct selection
Increase the warehouse size.

Suspend the warehouse frequently.

Allow memory spillage.

Overall explanation
Strategies to optimize the performance of a virtual warehouse include: reducing queuing, which minimizes wait times for queries by allocating more resources, and increasing the warehouse size, which provides additional compute power to handle larger workloads and improve query processing speed. Both strategies help improve overall performance and reduce delays in resource-intensive operations.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 66
Skipped
Which actions can be performed using a resource monitor in Snowflake? (Choose two.)

Monitor the performance of individual queries in real-time.

Correct selection
Suspend a virtual warehouse when its credit usage reaches a defined limit.

Automatically allocate more storage space to a virtual warehouse.

Modify the queries being executed within a virtual warehouse.

Correct selection
Trigger a notification to account administrators when credit usage reaches a specified threshold.

Overall explanation
Each resource monitor allows us to configure the following actions: one Suspend action, one Suspend Immediate action, up to five Notify actions.

For more detailed information, refer to the official Snowflake documentation.

Question 67
Skipped
What type of columns does Snowflake recommend to be used as clustering keys? (Choose two.)

Correct selection
A column that is most actively used in selective filters

A column with very low cardinality

A VARIANT column

A column with very high cardinality

Correct selection
A column that is most actively used in join predicates

Overall explanation
These are the recommended types of columns to use as clustering keys in Snowflake. Clustering keys on these columns help optimize performance by improving how data is stored and accessed, making query filtering and joins more efficient by allowing for better micro-partition pruning.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 68
Skipped
What happens to historical data when the retention period for an object ends?

The object containing the historical data is dropped.

The data is cloned into a historical object.

Correct answer
The data moves to Fail-safe

Time Travel on the historical data is dropped.

Overall explanation
When the retention period for an object ends, Snowflake removes access to historical versions of the data stored during that period. The data is no longer available through Time Travel, but it is still retained in Fail-safe for a limited time for recovery purposes.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 69
Skipped
Which Snowflake feature will allow small volumes of data to continuously load into Snowflake and will incrementally make the data available for analysis?

COPY INTO

Correct answer
CREATE PIPE

INSERT INTO

TABLE STREAM

Overall explanation
PIPE allows small volumes of data to be continuously loaded into Snowflake. It uses Snowpipe to automatically ingest and incrementally make data available for analysis as soon as it arrives, ensuring real-time or near-real-time data availability for queries.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 70
Skipped
Which clients does Snowflake support Multi-Factor Authentication (MFA) token caching for? (Choose two.)

Spark connector

Correct selection
ODBC driver

GO driver

Node.js driver

Correct selection
Python connector

Overall explanation
Snowflake supports Multi-Factor Authentication (MFA) token caching for the ODBC driver and the Python connector. This allows users to authenticate using MFA once and cache the token for subsequent sessions, improving user convenience without compromising security.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 71
Skipped
Which Snowflake object helps evaluate virtual warehouse performance impacted by query queuing?

Correct answer
Information_schema.warehouse_load_history

Resource monitor

Account_usage.query_history

Information_schema.warehouse_metering_history

Overall explanation
This Snowflake object helps evaluate virtual warehouse performance, specifically focusing on query queuing. It provides insights into the load and activity of a virtual warehouse, including queuing times, which can help identify performance bottlenecks related to resource availability and workload management.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 72
Skipped
Regardless of which notation is used, what are considerations for writing the column name and element names when traversing semi-structured data?

The column name and element names are both case-insensitive.

Correct answer
The column name is case-insensitive but element names are case-sensitive.

The column name and element names are both case-sensitive.

The column name is case-sensitive but element names are case-insensitive.

Overall explanation
Column names are treated as case-insensitive unless specifically quoted, while element names within semi-structured data like JSON are case-sensitive, requiring careful attention when writing queries that traverse this data.

For more detailed information, refer to the official Snowflake documentation.

Question 73
Skipped
Which file format will keep floating-point numbers from being truncated when data is unloaded?

Correct answer
Parquet

CSV

JSON

ORC

Overall explanation
Parquet is the file format that will keep floating-point numbers from being truncated when data is unloaded. Parquet is a columnar storage format that efficiently handles complex data types, including floating-point numbers, preserving their precision during data storage and retrieval.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 74
Skipped
Snowflake will return an error when a user attempts to share which object?

Tables

Secure materialized views

Correct answer
Standard views

Secure views

Overall explanation
Unlike secure views, standard views are not designed for secure data sharing, and Snowflake prevents them from being shared between accounts to protect data security. Secure views and secure materialized views, on the other hand, are specifically designed to be shared securely across different accounts, ensuring data confidentiality and access control.



For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 75
Skipped
Which Snowflake feature can be used to find sensitive data in a table or column?

External functions

Correct answer
Data classification

Masking policies

Row level policies

Overall explanation
Data classification helps find sensitive data in a table or column by automatically identifying and classifying data based on predefined or custom tags, such as personally identifiable information (PII). It allows for better management of sensitive data within the platform, facilitating compliance with data protection regulations.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 76
Skipped
What does an integration between Snowflake and Microsoft Private Link or AWS PrivateLink support?

Correct answer
A secure, direct connection to Snowflake that does not use the internet.

The isolation of data within a Snowflake account.

The use of Secure Data Sharing among Snowflake accounts.

A Virtual Private Network (VPN) between a user and Snowflake.

Overall explanation
Integration with AWS PrivateLink or Microsoft Private Link enables a private, secure connection between the customer's VPC and Snowflake, bypassing the public internet and reducing exposure to external threats.

For more detailed information, refer to the official Snowflake documentation.

Question 77
Skipped
What value provides information about disk usage for operations where intermediate results do not fit in memory in a Query Profile?

IO

Network

Correct answer
Spilling

Pruning

Overall explanation
"Spilling" value provides information about disk usage when intermediate query results do not fit in memory and must be written to disk. This can indicate memory limitations during query execution and may impact query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 78
Skipped
Which of the following are options when creating a Virtual Warehouse? (Choose two.)

Auto-drop

Correct selection
Auto-resume

Auto-resize

Auto-start

Correct selection
Auto-suspend

Overall explanation
When creating a Virtual Warehouse in Snowflake, the options Auto-resume and Auto-suspend are available. Auto-resume allows the warehouse to start automatically when a query is executed, and Auto-suspend allows the warehouse to stop after a period of inactivity, optimizing cost and resource.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 79
Skipped
Which Snowflake object can be used to record DML changes made to a table?

Task

Snowpipe

Stage

Correct answer
Stream

Overall explanation
A Snowflake stream object is used to track DML changes (inserts, updates, and deletes) made to a table. It allows users to query the change data and process it as needed, facilitating use cases such as change data capture (CDC).

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 80
Skipped
What is the purpose of the Snowflake SPLIT_TO_TABLE function?

To count the number of characters in a string

To split a string and flatten the results into columns

To split a string into an array of sub-strings

Correct answer
To split a string and flatten the results into rows

Overall explanation
This function takes a string, breaks it into substrings based on a specified delimiter, and returns each substring as a separate row in a table, making it easier to work with individual parts of a string in a relational context.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 81
Skipped
How are privileges inherited in a role hierarchy in Snowflake?

Privileges are only inherited by the direct parent role in the hierarchy.

Privileges are inherited by any roles at the same level in the hierarchy.

Correct answer
Privileges are inherited by any roles above that role in the hierarchy.

Privileges are only inherited by the direct child role in the hierarchy.

Overall explanation
In Snowflake's role-based access control, a child role's privileges are passed up the hierarchy to parent roles, allowing those parent roles to inherit all the access and permissions granted to their child roles. This helps in creating flexible and layered access management.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 82
Skipped
Who can activate and enforce a network policy for all users in a Snowflake account? (Choose two.)

A role that has the OWNERSHIP of the network policy

A user with an USERADMIN or higher role

A role that has the NETWORK_POLICY account parameter set

Correct selection
A user with a SECURITYADMIN or higher role

Correct selection
A role that has been granted the ATTACH POLICY privilege

Overall explanation
A user with a SECURITYADMIN or higher role and a role that has been granted the ATTACH POLICY privilege can activate and enforce a network policy for all users in a Snowflake account. These roles have the necessary permissions to manage and apply network policies.

For more detailed information, refer to the official Snowflake documentation.

Question 83
Skipped
Which command allows for continuous loading of data files as soon as they are available in a stage?

GET

Correct answer
CREATE PIPE

COPY INTO [table]

PUT

Overall explanation
The CREATE PIPE command enables continuous loading of data files as they become available in a stage by creating a Snowpipe, which automatically loads data into a table in near real-time.

For more detailed information, refer to the official Snowflake documentation.

Question 84
Skipped
An external stage, my_stage contains many directories, including one, app_files that contains CSV files.



How can all the CSV files from this directory be moved into table my_table without scanning files that are not needed?

Correct answer
COPY INTO my_table FROM @my_stage/app_files PATTERN='.*[.]csv';
COPY INTO my_table FROM @my_stage PATTERN='.*[.]csv';
COPY INTO my_table FROM @my_stage/app_files PATTERN='.*[.]txt';
COPY INTO my_table FROM @my_stage PATTERN='.*[.]txt';
Overall explanation
We can expect a few questions about ingesting files with COPY INTO. It is important to be familiar with the most important parameters of the syntax.

This option filters both by path and file type. It looks only inside the app_files folder and loads only .csv files, which avoids scanning irrelevant directories or files, improving performance.

For more detailed information, refer to the official Snowflake documentation.

Question 85
Skipped
What does Snowflake recommend when planning virtual warehouse usage for a data load?

Use several single-cluster warehouses.

Increase the size of the warehouse used.

Load the fewest possible number of large files.

Correct answer
Dedicate a separate warehouse for loading data.

Overall explanation
Snowflake recommends dedicating a separate warehouse for loading data when planning virtual warehouse usage for data loads. This helps optimize performance by isolating the data load processes from query workloads, ensuring that neither is impacted by the other. Using a dedicated warehouse also allows better control over resource allocation and helps maintain efficient data processing without interference.

For more detailed information, refer to the official Snowflake documentation.

Question 86
Skipped
Who can access a referenced file through a scoped URL?

Any role specified in the GET REST API call with sufficient privileges

Correct answer
Only the user who generates the URL

Any user specified in the GET REST API call with sufficient privileges

Only the ACCOUNTADMIN

Overall explanation
Only the user who created the scoped URL is permitted to use it to access the referenced file.

For more detailed information, refer to the official Snowflake documentation.

Question 87
Skipped
What does a Query Profile provide in Snowflake?

A multi-step query that displays each processing step in the same panel.

Correct answer
A graphical representation of the main components of the processing plan for a query.

A pre-computed data set derived from a query specification and stored for later use.

A collapsible panel in the operator tree pane that lists nodes by execution time in descending order for a query.

Overall explanation
The Query Profile in Snowflake provides a visual breakdown of the query execution plan, showing key elements such as data movement, aggregation, and other steps in the query. This helps users analyze and optimize query performance by understanding how the query is processed.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 88
Skipped
What are the key characteristics of ACСOUNT_USAGE views? (Choose two.)

The historical data is not retained.

The historical data can be retained from 7 days to 6 months.

Correct selection
Records for dropped objects are included in each view.

Correct selection
The data latency can vary from 45 minutes to 3 hours.

There is no data latency.

Overall explanation
ACCOUNT_USAGE views in Snowflake have a latency that typically ranges from 45 minutes to 3 hours, and they also include records for dropped objects, allowing users to track historical actions even after objects have been deleted.

For more detailed information, refer to the official Snowflake documentation.

Question 89
Skipped
What user setting can be configured to disable Multi-Factor Authentication (MFA) for a Snowflake user? (Choose two.)

Correct selection
MINS_TO_BYPASS_MFA

Correct selection
DISABLE_MFA

MUST_CHANGE_PASSWORD

PASSWORD

MINS_TO_UNLOCK

Overall explanation
MFA (Multi-Factor Authentication) is automatically turned on for all accounts and users. Users can easily set it up themselves.

However, the account administrator (the user with the ACCOUNTADMIN role) can turn off MFA for a user if needed, like if they lose their phone. The administrator can use these options with the ALTER USER command: MINS_TO_BYPASS_MFA (temporarily turns off MFA) and DISABLE_MFA (permanently turns off MFA).

For more detailed information, refer to the official Snowflake documentation.

Question 90
Skipped
A role is created and owns 2 tables. This role is then dropped. Who will now own the two tables?

The tables are now orphaned

The user that deleted the role

SYSADMIN

Correct answer
The assumed role that dropped the role

Overall explanation
The assumed role that dropped the role. When a role is dropped, Snowflake assigns the ownership of its tables to the role that executes the drop command, preventing them from becoming orphaned.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 91
Skipped
Which Snowflake table type is only visible to the user who creates it, can have the same name as permanent tables in the same schema, and is dropped at the end of the session?

Local

Transient

Correct answer
Temporary

User

Overall explanation
A temporary table in Snowflake is only visible to the user who creates it, can share the same name as permanent tables within the same schema, and is automatically dropped at the end of the user's session. Temporary tables are ideal for storing intermediate data during a session without affecting permanent database structures.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 92
Skipped
What actions can be performed by a consumer account on a shared database? (Choose two.)

Cloning a shared table

Modifying the data in a shared table

Correct selection
Joining the data from a shared table with another table

Using Time Travel on a shared table

Correct selection
Executing the SELECT statement on a shared table

Overall explanation
A consumer account can query (SELECT) data from a shared table and join it with other tables, but it cannot modify, clone, or use Time Travel on shared data.

For more detailed information, refer to the official Snowflake documentation.

Question 93
Skipped
Which Snowflake feature allows a user to track sensitive data for compliance, discovery, protection, and resource usage?

Correct answer
Tags

Row access policies

Internal tokenization

Comments

Overall explanation
Snowflake's tagging feature allows users to track sensitive data for compliance, discovery, protection, and resource usage. Tags can be applied to tables, columns, and other objects, enabling the classification of sensitive data such as personally identifiable information (PII) for better management and compliance with regulatory requirements.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 94
Skipped
A Snowflake user wants to optimize performance for a query that queries only a small number of rows in a table. The rows require significant processing. The data in the table does not change frequently.

What should the user do?

Add a clustering key to the table.

Add the search optimization service to the table.

Enable the query acceleration service for the virtual warehouse.

Correct answer
Create a materialized view based on the query.

Overall explanation
If a Snowflake user wants to optimize performance for a query that requires significant processing but queries only a small number of rows from a table that doesn't change frequently, creating a materialized view is the best approach. It allows pre-computation and storage of the results of the query, which speeds up future executions by reducing the need for repeated processing.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 95
Skipped
How should a virtual warehouse be configured if a user wants to ensure that additional multi-clusters are resumed with the shortest delay possible?

Configure the warehouse to a size larger than generally required

Use the economy warehouse scaling policy

Set the minimum and maximum clusters to autoscale

Correct answer
Use the standard warehouse scaling policy

Overall explanation
To ensure additional multi-clusters are resumed with the shortest delay possible, the standard scaling policy should be used. This policy prioritizes resuming clusters faster to handle increasing workloads efficiently, minimizing delay in adding resources.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 96
Skipped
Which Snowflake governance feature allows users to assign metadata labels to improve data governance and database access control?

Secure views

Correct answer
Object tagging

Secure functions

Row-level security

Overall explanation
Object tagging in Snowflake allows users to assign metadata labels (tags) to objects. This improves data governance by enabling better organization, tracking, and enforcement of access control policies based on metadata attributes.

For more detailed information, refer to the official Snowflake documentation.

Question 97
Skipped
How can data be shared between two users who have different Snowflake accounts?

Create a share with the same name as the original database.

Correct answer
Create a share and ensure the proper role is assigned to the share.

Ensure both users’ accounts are using the same cloud provider and region.

Use the PUT command to create a shared account.

Overall explanation
To share data between different Snowflake accounts, a provider creates a share and grants access to objects using roles. The consumer can then create a database from that share. Proper role assignment is essential for managing access.

For more detailed information, refer to the official Snowflake documentation.

Question 98
Skipped
How does a scoped URL expire?

When the data cache clears.

The length of time is specified in the expiration_time argument.

The encoded URL access is permanent.

Correct answer
When the persisted query result period ends.

Overall explanation
A scoped URL expires when the period for the persisted query result concludes.

For more detailed information, refer to the official Snowflake documentation.

Question 99
Skipped
Which of the following terms best describes Snowflake's database architecture?

Columnar shared nothing

Correct answer
Multi-cluster, shared data

Shared disk

Cloud-native shared memory

Overall explanation
Snowflake's database architecture is best described as multi-cluster, shared data. This architecture separates compute and storage, allowing multiple compute clusters to access the same data concurrently and scale independently.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 100
Skipped
Which MINIMUM set of privileges is required to temporarily bypass an active network policy by configuring the user object property MINS_TO_BYPASS_NETWORK_POLICY?

Only while in the ACCOUNTADMIN role

Only while in the SECURITYADMIN role

Only the role with the OWNERSHIP privilege on the network policy

Correct answer
Only Snowflake Support can set the value for this object property

Overall explanation
You can temporarily bypass a network policy for a specified number of minutes by configuring the user object property MINS_TO_BYPASS_NETWORK_POLICY, which can be checked by running the DESCRIBE USER command. Only Snowflake has the ability to set the value for this property. To have it configured, please reach out to Snowflake Support.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 101
Skipped
What action can a user take to address query concurrency issues?

Enable the query acceleration service.

Correct answer
Add additional clusters to the virtual warehouse.

Enable the search optimization service.

Resize the virtual warehouse to a larger instance size.

Overall explanation
To address query concurrency issues, adding more clusters to the virtual warehouse allows Snowflake to scale horizontally, enabling more queries to run simultaneously without waiting for resources. This improves concurrency by distributing the workload across multiple clusters.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 102
Skipped
Which Snowflake feature records changes made to a table so actions can be taken using that change data capture?

Correct answer
Stream

Materialized View

Pipe

Task

Overall explanation
Stream records changes made to a table, allowing users to capture data modifications (such as inserts, updates, and deletes) and take actions based on those changes. Streams are commonly used in change data capture (CDC) workflows to track incremental data changes and enable downstream processing or data replication tasks.

For more detailed information, refer to the official Snowflake documentation.

Question 103
Skipped
Why would a Snowflake user load JSON data into a VARIANT column instead of a string column?

Correct answer
A VARIANT column can be used to create a data hierarchy and a string column cannot.

A VARIANT column is more secure than a string column.

A VARIANT column compresses data and a string column does not.

A VARIANT column will have a better query performance than a string column.

Overall explanation
A few comments:

VARIANT is a semi-structured data type in Snowflake designed to store JSON, Avro, ORC, Parquet, and XML.

VARIANT preserves the original structure of the JSON, allowing hierarchical and nested queries using dot notation (column.key.subkey) and built-in JSON functions.

A STRING column would store JSON as plain text, making it harder to parse, query, and manipulate efficiently.

For more detailed information, refer to the official Snowflake documentation.

Question 104
Skipped
What are the available Snowflake scaling modes for configuring multi-cluster virtual warehouses? (Choose two.)

Correct selection
Maximized

Standard

Economy

Correct selection
Auto-Scale

Scale-Out

Overall explanation
Auto-Scale mode automatically adjusts the number of clusters up or down based on the workload, optimizing resource usage. Maximized mode, on the other hand, keeps all clusters running continuously, ensuring maximum compute availability for high-demand workloads.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 105
Skipped
Which loop type iterates until a condition is true?

WHILE

FOR

LOOP

Correct answer
REPEAT

Overall explanation
The REPEAT loop iterates until a specified condition is true. Unlike other loops, it executes the block of code at least once and checks the condition after each iteration. The loop continues until the condition becomes true, then it exits.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 106
Skipped
Increasing the maximum number of clusters in a Multi-Cluster Warehouse is an example of:

Scaling max

Correct answer
Scaling out

Scaling up

Scaling rhythmically

Overall explanation


Increasing the maximum number of clusters in a Multi-Cluster Warehouse is an example of scaling out, as it adds more clusters to handle increased workload.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 107
Skipped
What can the Snowflake SCIM API be used to manage? (Choose two.)

Integrations

Session policies

Network policies

Correct selection
Users

Correct selection
Roles

Overall explanation
The Snowflake SCIM API can be used to manage roles and users. This API is part of Snowflake’s identity management, enabling automated provisioning and management of users and roles to help with tasks like creating, updating, and deactivating users, as well as assigning roles for access control and compliance.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 108
Skipped
If a Small Warehouse is made up of 2 servers/cluster, how many servers/cluster make up a Medium Warehouse?

Correct answer
4

128

32

16

Overall explanation
Small: 2 clusters

Medium: 4 clusters

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 109
Skipped
When can a Virtual Warehouse start running queries?

After replication

Only during administrator defined time slots

Correct answer
When its provisioning is complete

12am-5am

Overall explanation
A Virtual Warehouse can start running queries when its provisioning is complete. Once the warehouse is fully provisioned and resources are allocated, it is ready to execute queries without further delay.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 110
Skipped
To run a Multi-Cluster Warehouse in auto-scale mode, a user would:

Set the Minimum Clusters and Maximum Clusters settings to the same value

Correct answer
Set the Minimum Clusters and Maximum Clusters settings to the different values

Configure the Maximum Clusters setting to Auto-scale

Set the Warehouse type to Auto

Overall explanation
To run a Multi-Cluster Warehouse in auto-scale mode, a user would set the Minimum Clusters and Maximum Clusters settings to different values. This allows Snowflake to scale the number of clusters up or down automatically based on the current workload.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 111
Skipped
Which columns are available in the output of a Snowflake directory table? (Choose two.)

CATALOG_NAME

STAGE_NAME

Correct selection
LAST_MODIFIED

Correct selection
RELATIVE_PATH

FILE_NAME

Overall explanation
These columns are available in the output of a Snowflake directory table, providing details about the file’s relative path in the stage and when it was last modified, which are crucial for tracking the location and status of files in a Snowflake stage.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 112
Skipped
What is the default access of a securable object until other access is granted?

Correct answer
No access

Write access

Read access

Full access

Overall explanation
By default, a securable object in Snowflake has no access until explicit permissions are granted. This ensures that only authorized roles or users can access the object, maintaining strict security and access control over data and resources.

For more detailed information, refer to the official Snowflake documentation.

Question 113
Skipped
Which stages are created by default, with no need to use the CREATE STAGE command? (Choose two.)

Correct selection
Table stage

External stage

Correct selection
User stage

Named stage

Internal stage

Overall explanation
Every table automatically has its own stage for loading and unloading data, and every user has a personal stage for storing files.

For more detailed information, refer to the official Snowflake documentation.

Question 114
Skipped
Why is a federated environment used for user authentication in Snowflake?

To enhance data security and privacy

Correct answer
To separate user authentication from user access

To enable direct integration with external databases

To provide real-time monitoring of user activities

Overall explanation
For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 115
Skipped
What are common issues found by using the Query Profile? (Choose two.)

Correct selection
Identifying inefficient micro-partition pruning

Locating queries that consume a high amount of credits

Identifying logical issues with the queries

Correct selection
Data spilling to a local or remote disk

Identifying queries that will likely run very slowly before executing them

Overall explanation
These are common issues found using the Query Profile in Snowflake. The Query Profile helps pinpoint inefficiencies, such as when queries don't properly leverage micro-partition pruning, which can slow down performance, and when data spills to disk due to memory constraints, impacting query speed and resource usage.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 116
Skipped
A Snowflake user wants to share data using my_share with account xy12345.

Which command should be used?

alter account xy12345 add share my_share;

grant usage on share my_share to account xy12345;

Correct answer
alter share my_share add accounts = xy12345;

grant select on share my_share to account xy12345;

Overall explanation
This command is used to add the specified account (xy12345) to the share (my_share) in Snowflake, allowing the account to access the shared data.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 117
Skipped
What is the Snowflake recommended Parquet file size when querying from external tables to optimize the number of parallel scanning operations?

16-128 MB

100-250 MB

1-16 MB

Correct answer
256-512 MB

Overall explanation
The recommended Parquet file size when querying from external tables in Snowflake is 256-512 MB. This file size optimizes the number of parallel scanning operations, improving query performance by balancing data processing efficiency and system resources.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 118
Skipped
What authentication method does the Kafka connector use within Snowflake?

Username and password

Multi-Factor Authentication (MFA)

Correct answer
Key pair authentication

OAuth

Overall explanation
The Kafka connector within Snowflake uses Key pair authentication for secure communication. This method ensures secure integration between Kafka and Snowflake by leveraging public and private key pairs, enhancing security for data streaming processes.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 119
Skipped
Which view in SNOWFLAKE.ACCOUNT_USAGE shows from which IP address a user connected to Snowflake?

SESSIONS

QUERY_HISTORY

ACCESS_HISTORY

Correct answer
LOGIN_HISTORY

Overall explanation
The LOGIN_HISTORY view in SNOWFLAKE.ACCOUNT_USAGE shows details about user logins, including the IP address from which a user connected to Snowflake, making it the correct source for tracking connection information.

For more detailed information, refer to the official Snowflake documentation.

Question 120
Skipped
How can network and private connectivity security be managed in Snowflake?

Correct answer
By setting up network policies with IPv4 IP addresses

By putting the Snowflake URL on the allowed list for get method responses

By manually setting up an Intrusion Prevention System (IPS) on each account

By manually setting up vulnerability patch management policies

Overall explanation
Network and private connectivity security in Snowflake can be managed by setting up network policies with IPv4 IP addresses. These network policies control access to Snowflake accounts by allowing or denying connections based on specified IP address ranges. Private connectivity can be configured using private endpoints or private link services to establish secure, direct connections between Snowflake and a customer’s network, bypassing the public internet for enhanced security.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 121
Skipped
Which Snowflake data governance feature can support auditing when a user query reads column data?

Correct answer
Access History

Column-level security

Data classification

Object dependencies

Overall explanation
Access History can support auditing when a user query reads column data. It provides detailed records of query activity, including which columns are accessed, helping monitor and audit data usage.

For more detailed information, refer to the official Snowflake documentation.

Question 122
Skipped
A Virtual Warehouse's auto-suspend and auto-resume settings apply to:

The primary cluster in the Virtual Warehouse

The database the Virtual Warehouse resides in

The queries currently being run by the Virtual Warehouse

Correct answer
The entire Virtual Warehouse

Overall explanation
The auto-suspend and auto-resume settings apply to the entire Virtual Warehouse, controlling when it pauses (suspends) due to inactivity and resumes when new queries are issued, optimizing resource usage and cost.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 123
Skipped
Which table function is used to perform additional processing on the results of a previously-run query?

QUERY_HISTORY_BY_SESSION

QUERY_HISTORY

DESCRIBE_RESULTS

Correct answer
RESULT_SCAN

Overall explanation
Retrieves the result set of a previous command as if it were a table, provided it was executed within the last 24 hours.

This is especially useful for processing output from a SHOW or DESC[RIBE] command or a query on metadata or account usage, such as the Snowflake Information Schema or Account Usage views.

Instead of using RESULT_SCAN, we can also call a stored procedure that returns tabular data within the FROM clause of a SELECT statement.

For more detailed information, refer to the official Snowflake documentation.

Question 124
Skipped
What information is included in the display in the Query Profile? (Choose two.)

Correct selection
Details and statistics for the overall query

Correct selection
Graphical representation of the query processing plan

Credit usage details

Clustering keys details

Index hints used in query

Overall explanation
The Query Profile in Snowflake provides comprehensive details, including statistics on query execution, and a graphical representation of the query processing plan. This visualization helps users understand the performance of their queries and identify any bottlenecks or inefficiencies in the execution process.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 125
Skipped
Which functions can be used to identify the data type stored in a VARIANT column? (Choose two.)

Correct selection
IS_DATE_VALUE

Correct selection
IS_NULL_VALUE

IS_XML

IS_GEOGRAPHY

IS_JSON

Overall explanation
These functions help determine the specific type of data stored in a VARIANT column. IS_DATE_VALUE checks if the value is a date, and IS_NULL_VALUE checks for nulls. IS_JSON, IS_XML, and IS_GEOGRAPHY are not valid VARIANT type-checking functions in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

For more detailed information, refer to the official Snowflake documentation.

Question 126
Skipped
Which Snowflake data governance feature supports resource usage monitoring?

Data classification

Correct answer
Object tagging

Access history

Column lineage

Overall explanation
Object tagging allows attaching metadata to Snowflake objects, which can then be used for tracking and monitoring resource usage, including cost attribution and governance reporting.

For more detailed information, refer to the official Snowflake documentation.

Question 127
Skipped
What type of function returns one value for each invocation?

Table

Correct answer
Scalar

Window

Aggregate

Overall explanation
A scalar function in Snowflake returns one value for each invocation. This type of function operates on individual inputs and produces a single output for each, making it suitable for tasks such as calculations, transformations, or manipulations of individual data points within a query.

For more detailed information, refer to the official Snowflake documentation.

Question 128
Skipped
How does Snowflake store a table's underlying data? (Choose two.)

Correct selection
Columnar file format

Text file format

Correct selection
Micro-partitions

Uncompressed

User-defined partitions

Overall explanation
Snowflake stores a table's underlying data in a columnar file format, which optimizes performance for analytical queries, and organizes the data into micro-partitions, which are automatically managed by Snowflake to improve query performance and reduce storage costs.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 129
Skipped
What is the advantage of using a reader account?

Correct answer
It can be used by a client that does not have a Snowflake account

It provides limited access to the data share and is therefore cheaper for the data provider.

It can be connected to a Snowflake account in a different region.

It is read-only and prevents the shared data from being updated by the provider.

Overall explanation
A reader account allows clients without a Snowflake account to access shared data, offering a way to share data without requiring the recipient to purchase a full Snowflake license. This makes it a convenient and cost-effective solution for data providers to share data with external organizations.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 130
Skipped
Which of the following statements is true of zero-copy cloning?

Zero-copy clones increase storage costs as cloning the table requires storing its data twice

Zero-copy cloning is licensed as an additional Snowflake feature

All zero-copy clone objects inherit the privileges of their original objects

Correct answer
At the instance/instant a clone is created, all micro-partitions in the original table and the clone are fully shared

Overall explanation
Zero-copy cloning allows for instant duplication of data without additional storage costs, as the clone shares the same underlying micro-partitions with the original table until changes are made.



Question 131
Skipped
A user wants to unload data from a relational table into a CSV file in an external stage. The table must be named exactly as specified by the user.



Which file format option MUST be used to do this?

escape

Correct answer
single

encoding

file_extension

Overall explanation
The SINGLE=TRUE option ensures that all the data is written into a single file instead of multiple files when unloading data using COPY INTO. This guarantees that the output file will have the exact name specified by the user.

The file_extension option must be used to specify the exact file extension (e.g., .csv) for the unloaded file. By default, if the SINGLE option in the COPY INTO command is set to TRUE, Snowflake unloads a single file without a file extension.

For more detailed information, refer to the official Snowflake documentation.

Question 132
Skipped
During periods of warehouse contention, which parameter controls the maximum length of time a warehouse will hold a query for processing?

Correct answer
STATEMENT_QUEUED_TIMEOUT_IN_SECONDS

MAX_CONCURRENCY_LEVEL

QUERY_TIMEOUT_IN_SECONDS

STATEMENT_TIMEOUT_IN_SECONDS

Overall explanation
This parameter controls the maximum length of time a query can remain in a queued state when there is contention for warehouse resources before being canceled. It helps manage the load during high-demand periods by setting limits on how long a query will wait to be processed.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 133
Skipped
Which Snowflake privilege is required on a pipe object to pause or resume pipes?

USAGE

SELECT

Correct answer
OPERATE

READ

Overall explanation
OPERATE is required on a pipe object to pause or resume pipes. This privilege allows specific control actions on the pipe, such as pausing and resuming its execution.

For more detailed information, refer to the official Snowflake documentation.

Question 134
Skipped
How does Snowflake allow a data provider with an Azure account in central Canada to share data with a data consumer on AWS in Australia?

The data provider uses the GET DATA workflow in the Snowflake Data Marketplace to create a share between Azure Central Canada and AWS Asia Pacific.

The data consumer and data provider can form a Data Exchange within the same organization to create a share from Azure Central Canada to AWS Asia Pacific.

The data provider in Azure Central Canada can create a direct share to AWS Asia Pacific, if they are both in the same organization.

Correct answer
The data provider must replicate the database to a secondary account in AWS Asia Pacific within the same organization then create a share to the data consumer's account

Overall explanation
Snowflake requires replication of the database to a region compatible with the data consumer's cloud platform and region for cross-cloud and cross-region data sharing. This ensures data access between different clouds (Azure and AWS) across different regions.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 135
Skipped
Which of the following Snowflake features provide continuous data protection automatically? (Choose two.)

Incremental backups

Internal stages

Zero-copy clones

Correct selection
Fail-safe

Correct selection
Time Travel

Overall explanation
Time Travel allows you to access historical versions of your data for a defined period, enabling recovery from accidental changes. Fail-safe is a seven-day period after the Time Travel window where Snowflake can recover data offering additional protection.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 136
Skipped
Which of the following commands are not blocking operations? (Choose two.)

Correct selection
COPY

Correct selection
INSERT

MERGE

UPDATE

DELETE

Overall explanation
These commands are generally not blocking operations in Snowflake, meaning they can execute concurrently without locking resources for long periods. Other commands like UPDATE, MERGE, and DELETE involve more complex data modifications and may result in locks or blocking behavior during execution.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 137
Skipped
Which commands can a Snowflake user execute to specify a cluster key for a table? (Choose two.)

SET

UPDATE

SHOW

Correct selection
CREATE

Correct selection
ALTER

Overall explanation
CREATE command allows setting a cluster key when initially creating the table, while ALTER enables modifying an existing table to add or change its cluster key.

For more detailed information, refer to the official Snowflake documentation.

Question 138
Skipped
What role should be used when creating a new user?

SECURITYADMIN

SYSADMIN

ORGADMIN

Correct answer
USERADMIN

Overall explanation
The USERADMIN role is specifically designed for managing users and roles. It has the necessary privileges to create, alter, and drop users securely.

For more detailed information, refer to the official Snowflake documentation.

Question 139
Skipped
A company’s security audit requires generating a report listing all Snowflake logins (e.g., date and user) within the last 90 days.

Which of the following statements will return the required information?

Correct answer
SELECT EVENT_TIMESTAMP, USER_NAME
FROM ACCOUNT_USAGE.LOGIN_HISTORY;
SELECT EVENT_TIMESTAMP, USER_NAME
FROM ACCOUNT_USAGE.ACCESS_HISTORY;
SELECT LAST_SUCCESS_LOGIN, LOGIN_NAME
FROM ACCOUNT_USAGE.USERS;
SELECT EVENT_TIMESTAMP, USER_NAME
FROM table(information_schema.login_history_by_user())
Overall explanation
This query provides the required information, retrieving the login events, including the timestamp and username, from the ACCOUNT_USAGE.LOGIN_HISTORY view, which is specifically designed to track login activities in Snowflake for security audits.

For more detailed information, refer to the official Snowflake documentation.

Question 140
Skipped
By default, which Snowflake role is required to create a share?

ORGADMIN

SHAREADMIN

Correct answer
ACCOUNTADMIN

SECURITYADMIN

Overall explanation
By default, the ACCOUNTADMIN role is required to create a share in Snowflake. This role has full administrative privileges, including the ability to manage data sharing with other Snowflake accounts through shares.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 141
Skipped
What is the purpose of collecting statistics on data in Snowflake?

Correct answer
To enable efficient pruning based on query filters

To identify data storage order correlations

To optimize query performance by reading all data in a table

To reduce the total number of micro-partitions in a table

Overall explanation
The purpose of collecting statistics on data in Snowflake is to enable efficient pruning based on query filters. This helps optimize query performance by reducing the number of micro-partitions that need to be scanned during a query, thereby improving the overall speed and efficiency of query execution without needing to read all the data in the table.

For more detailed information, refer to the official Snowflake documentation.

Question 142
Skipped
What are characteristics of directory tables when used with unstructured data? (Choose two.)

Each directory table has grantable privileges of its own.

Correct selection
Directory tables store a catalog of staged files in cloud storage.

Only cloud storage stages support directory tables.

Correct selection
A directory table can be added explicitly to a stage when the stage is created.

A directory table is a separate database object that can be layered explicitly on a stage.

Overall explanation
They catalog files stored in cloud storage and can be explicitly added to a stage during its creation, providing a structured way to manage unstructured data in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 143
Skipped
What columns are returned when performing a FLATTEN command on semi-structured data? (Choose two.)

NODE

LEVEL

Correct selection
KEY

Correct selection
VALUE

ROOT

Overall explanation
When performing a FLATTEN command on semi-structured data in Snowflake, the resulting columns typically include KEY, which represents the name of the attribute, and VALUE, which represents the corresponding data. These are essential for working with hierarchical or nested data structures like JSON.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 144
Skipped
What feature of Snowflake Continuous Data Protection can be used for maintenance of historical data?

Correct answer
Time Travel

Network policies

Access control

Fail-safe

Overall explanation
The Time Travel feature of Snowflake Continuous Data Protection can be used for the maintenance of historical data. Time Travel allows users to access historical versions of data, enabling recovery of accidentally changed or deleted data within a specified retention period.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 145
Skipped
Which pages are included in the Monitoring area of Snowsight? (Choose two.)

Contacts

Sharing settings

Correct selection
Copy History

Automatic Clustering History

Correct selection
Query History

Overall explanation
The Monitoring area of Snowsight includes both the Copy History, which tracks the data loading activities, and the Query History, which provides detailed information about past queries executed in Snowflake, helping users monitor system performance and usage.

For more detailed information, refer to the official Snowflake documentation.

Question 146
Skipped
Which Snowflake object does not consume any storage costs?

Materialized view

Temporary table

Correct answer
Secure view

Transient table

Overall explanation
A secure view in Snowflake does not consume any storage costs. Unlike materialized views or tables, secure views are logical representations of the underlying data and do not store physical data, meaning they do not incur additional storage expenses.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 147
Skipped
What is the purpose of a Query Profile?

To profile which queries are running in each warehouse and identify proper warehouse utilization and sizing for better performance and cost balancing.

To profile the user and/or executing role of a query and all privileges and policies applied on the objects within the query.

Correct answer
To profile a particular query to understand the mechanics of the query, its behavior, and performance.

To profile how many times a particular query was executed and analyze its usage statistics over time.

Overall explanation
The Query Profile provides insights into how a query executes, identifying potential bottlenecks and optimization opportunities for improved performance.

For more detailed information, refer to the official Snowflake documentation.

Question 148
Skipped
The VALIDATE table function has which parameter as an input argument for a Snowflake user?

Correct answer
JOB_ID

LAST_QUERY_ID

UUID_STRING

CURRENT_STATEMENT

Overall explanation
JOB_ID is the input argument for the VALIDATE table function in Snowflake. This parameter is used to validate the status of a specific task or job, helping users check the integrity and success of data loading or other processes by referencing the job ID associated with a particular operation.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 149
Skipped
What does the client redirect feature in Snowflake enable?

A redirect of client connections to Snowflake accounts in different regions for data replication.

A redirect of client connections to Snowflake accounts in the same regions for business continuity.

Correct answer
A redirect of client connections to Snowflake accounts in different regions for business continuity.

A redirect of client connections to Snowflake accounts in the same regions for data replication.

Overall explanation
This feature ensures that users can maintain access to their Snowflake accounts in the event of regional outages by redirecting client traffic to a different region where the account is available, supporting high availability and disaster recovery.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 150
Skipped
What is the recommended approach for unloading data to a cloud storage location from Snowflake?

Unload the data to a user stage, then upload the data to cloud storage

Unload the data to a local file system, then upload it to cloud storage.

Use a third-party tool to unload the data to cloud storage.

Correct answer
Unload the data directly to the cloud storage location.

Overall explanation
Snowflake's COPY INTO command allows you to unload data directly from a Snowflake table to cloud storage (e.g., Amazon S3, Azure Blob Storage, or Google Cloud Storage), simplifying the process and ensuring efficient data transfer without intermediate steps.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 151
Skipped
Which type of URL provides access to files in cloud storage for a limited time specified by the expiration_time argument?

Correct answer
Pre-signed URL

File URL

Account URL

Scoped URL

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 152
Skipped
What aspect of an executed query is represented by the remote disk I/O statistic of the Query Profile in Snowflake?

Time spent reading and writing data from and to remote storage when the data being accessed does not fit into the executing virtual warehouse node memory

Time spent caching the data to remote storage in order to buffer the data being extracted and exported

Correct answer
Time spent reading and writing data from and to remote storage when the data being accessed does not fit into either the virtual warehouse memory or the local disk

Time spent scanning the table partitions to filter data based on the predicate

Overall explanation
The remote disk I/O statistic in Snowflake's Query Profile represents the time spent accessing remote storage due to insufficient memory or local disk space in the virtual warehouse, typically leading to slower query performance.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 153
Skipped
Snowflake recommends, as a minimum, that all users with the following role(s) should be enrolled in Multi-Factor Authentication (MFA):

SECURITYADMIN, ACCOUNTADMIN

ACCOUNTADMIN

SECURITYADMIN, ACCOUNTADMIN, PUBLIC, SYSADMIN

Correct answer
SECURITYADMIN, ACCOUNTADMIN, SYSADMIN

Overall explanation
Since 1 June 2024: At a minimum, Snowflake strongly recommends that all users with the following system-defined roles enable MFA: ACCOUNTADMIN. SECURITYADMIN. SYSADMIN.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 154
Skipped
How is table data compressed in Snowflake?

Correct answer
Each column is compressed as it is stored in a micro-partition.

The micro-partitions are stored in compressed cloud storage and the cloud storage handles compression.

The text data in a micro-partition is compressed with GZIP but other types are not compressed.

Each micro-partition is compressed as it is written into cloud storage using GZIP.

Overall explanation
Snowflake compresses table data at the column level within each micro-partition using an efficient compression algorithm. This allows for high compression rates, improving both storage efficiency and query performance, particularly for analytical queries where columnar data formats are advantageous.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 155
Skipped
The first user assigned to a new account, ACCOUNTADMIN, should create at least one additional user with which administrative privilege?

ORGADMIN

PUBLIC

SYSADMIN

Correct answer
USERADMIN

Overall explanation
The first user assigned to the new Snowflake account (ACCOUNTADMIN) should create at least one additional user with the USERADMIN privilege to manage user creation, roles, and access control across the account. This helps delegate administrative tasks related to user management.

For more detailed information on query optimization, refer to the official Snowflake documentation.

Question 156
Skipped
Which Snowflake object will consume credits during automatic background maintenance?

Correct answer
Materialized view

View

Table

External table

Overall explanation
Only materialized views require automatic background maintenance to stay updated with base table changes. This process consumes compute resources and therefore Snowflake credits. Non-materialized views will only consume credits when we access them.

For more detailed information, refer to the official Snowflake documentation.

Question 157
Skipped
Which common query issues can be identified by the Query Profile? (Choose two.)

Correct selection
Inefficient query pruning

Insufficient credit quota

Excessive query pruning

Correct selection
Exploding joins

Credit usage that exceeds a set threshold

Overall explanation
Query Profile helps identify issues like inefficient query pruning, which can lead to unnecessary data scanning, and exploding joins, which increase resource usage and query time due to large intermediate results.

For more detailed information, refer to the official Snowflake documentation.

Question 158
Skipped
What issues can be identified and troubleshooted using the Query Profile? (Choose two.)

Virtual warehouse credit consumption

Correct selection
Cartesian products

Insufficient privileges

Correct selection
Queries too large to fit in memory

Full index scans

Overall explanation
Using the Query Profile, issues such as Cartesian products (which can result in large, inefficient joins) and queries too large to fit in memory (which cause spilling to disk and degrade performance) can be identified and troubleshooted.

For more detailed information, refer to the official Snowflake documentation.

Question 159
Skipped
How does Snowflake enable OAuth?

By using SnowSQL to enable an external OAuth using the Snowflake protocol

By establishing IP allowed lists and IP blocked lists

Correct answer
By configuring a security integration

By creating an external integration

Overall explanation
Snowflake uses integrations to allow clients to use OAuth. An integration is a way for Snowflake to talk to other services.

Administrators set up OAuth with a Security integration. This lets clients redirect users to a login page and get access tokens (and sometimes refresh tokens) to use Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 160
Skipped
What is the MOST performant file format for loading data in Snowflake?

ORC

CSV (Unzipped)

Correct answer
CSV (Gzipped)

Parquet

Overall explanation
Gzipped format compresses the data, reducing both the time and resources required to transfer and load large datasets into Snowflake. While Parquet and ORC are also efficient, Gzipped CSV files balance compression with wide compatibility and are often faster to load due to their smaller size compared to uncompressed formats like regular CSV.

For more detailed information on query optimization, refer to the official Snowflake documentation.