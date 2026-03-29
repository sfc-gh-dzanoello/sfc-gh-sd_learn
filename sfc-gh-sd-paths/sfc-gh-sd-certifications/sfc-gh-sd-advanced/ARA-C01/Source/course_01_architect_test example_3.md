Question 1
Correct
An Architect needs to grant a group of ORDER_ADMIN users the ability to clean old data in an ORDERS table (deleting all records older than 5 years), without granting any privileges on the table. The group’s manager (ORDER_MANAGER) has full DELETE privileges on the table.

How can the ORDER_ADMIN role be enabled to perform this data cleanup, without needing the DELETE privilege held by the ORDER_MANAGER role?

Your answer is correct
Create a stored procedure that runs with owner’s rights, including the appropriate "> 5 years" business logic, and grant USAGE on this procedure to ORDER_ADMIN. The ORDER_MANAGER role owns the procedure.

Create a stored procedure that can be run using both caller’s and owner’s rights (allowing the user to specify which rights are used during execution), and grant USAGE on this procedure to ORDER_ADMIN. The ORDER_MANAGER role owns the procedure.

This scenario would actually not be possible in Snowflake – any user performing a DELETE on a table requires the DELETE privilege to be granted to the role they are using.

Create a stored procedure that runs with caller’s rights, including the appropriate "> 5 years" business logic, and grant USAGE on this procedure to ORDER_ADMIN. The ORDER_MANAGER role owns the procedure.

Overall explanation
A few comments:

The stored procedure should run with the owner's rights so that it can perform the DELETE operation on the table, and USAGE on the procedure should be granted to the ORDER_ADMIN role to allow them to execute the procedure without granting them any privileges on the table. The ORDER_MANAGER role should own the procedure to ensure proper access control.

A stored procedure runs with either the caller’s rights or the owner’s rights. It cannot run with both at the same time. This topic describes the differences between a caller’s rights stored procedure and an owner’s rights stored procedure.

The primary advantage of an owner’s rights stored procedure is that the owner can delegate specific administrative tasks, such as cleaning up old data, to another role without granting that role more general privileges, such as privileges to delete all data from a specific table.

For more detailed information, refer to the Snowflake documentation.

Question 2
Skipped
An Architect would like to save quarter-end financial results for the previous six years.

Which Snowflake feature can the Architect use to accomplish this?

Materialized view

Time Travel

Correct answer
Zero-copy cloning

Secure views

Overall explanation
Zero Copy Clone in Snowflake not only avoids duplicating the physical data but also works at the metadata layer. When a clone is created, Snowflake duplicates the metadata of the original object (database, schema, or table). This metadata contains pointers to the underlying storage, allowing the clone to reference the same data blocks as the original object.



Question 3
Skipped
An Architect on a new project has been asked to design an architecture that meets Snowflake security, compliance, and governance requirements as follows:

1. Use Tri-Secret Secure in Snowflake

2. Share some information stored in a view with another Snowflake customer

3. Hide portions of sensitive information from some columns

4. Use zero-copy cloning to refresh the non-production environment from the production environment

To meet these requirements, which design elements must be implemented? (Choose three.)

Correct selection
Create a secure view.

Use the Enterprise edition of Snowflake.

Create a materialized view.

Correct selection
Use the Business Critical edition of Snowflake.

Correct selection
Use Dynamic Data Masking.

Define row access policies.

Overall explanation
A few comments:

Tri Secret Secure requires Business Critical Edition (or higher)

A secure view can be used to share a subset of data with another Snowflake customer while masking sensitive information. This helps meet the security and compliance requirements.

Dynamic Data Masking can be used to hide portions of sensitive information from some columns in order to meet security and compliance requirements.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
When data is transferred from a Snowflake primary account to another target account using database replication, which account is billed for the data transfer and compute charges?

The primary account is charged for the compute charges and the target account is charged for the data transfer charges.

Correct answer
The target account is charged for both the data transfer and compute charges.

The primary account is charged for both the data transfer and compute charges.

The primary account is charged for the data transfer charges and the target account is charged for the compute charges.

Overall explanation
For more detailed information, refer to the Snowflake documentation.

Question 5
Skipped
A Data Engineer is designing a near real-time ingestion pipeline for a retail company to ingest event logs from Amazon S3 into Snowflake to derive insights. A Snowflake Architect is asked to define security best practices to configure access control privileges for the data load for auto-ingest to Snowpipe.

What are the MINIMUM object privileges required for the Snowpipe user to execute Snowpipe?

OWNERSHIP on the named pipe, USAGE and READ on the named stage, USAGE on the target database and schema, and INSERT and SELECT on the target table.

USAGE on the named pipe, named stage, target database, and schema, and INSERT and SELECT on the target table.

Correct answer
OWNERSHIP on the named pipe, USAGE on the named stage, target database, and schema, and INSERT and SELECT on the target table.

CREATE on the named pipe, USAGE and READ on the named stage, USAGE on the target database and schema, and INSERT end SELECT on the target table.

Overall explanation
A few comments:

To access details about the pipe, you need to use a role that has the MONITOR or OWNERSHIP privilege on the pipe, along with the USAGE privilege on both the database and schema containing the pipe.

The question asks about the minimum privileges.

In this case, it also indicates that auto-ingest is used with Snowpipe, so we have to imply the use of Snowpipe on an external stage.

For external stage, the necessary privilege on the stage is USAGE.

If we add the READ privilege it would obviously work, but we would not be responding with the minimum privileges.

For more detailed information about Snowpipe management, refer to the documentation.

For more detailed information about ALTER PIPE command, refer to the Snowflake documentation.

Question 6
Skipped
Which of the following are characteristics of how row access policies can be applied to external tables? (Choose three.)

Correct selection
A row access policy can be applied to the VALUE column of an existing external table.

A row access policy cannot be applied to a view created on top of an external table.

While cloning a database, both the row access policy and the external table will be cloned.

Correct selection
A row access policy cannot be directly added to a virtual column of an external table.

Correct selection
An external table can be created with a row access policy, and the policy can be applied to the VALUE column.

External tables are supported as mapping tables in a row access policy.

Overall explanation
A few comments:

Row access policies can be used to restrict access to specific rows based on the VALUE column.

Row access policies are not applied directly to virtual columns, as they are designed for real columns like VALUE.

When creating an external table, a row access policy can be applied directly to control access.

While cloning a database, Snowflake clones the row access policy, but not the external table.

For more detailed information, refer to the Snowflake documentation.

For more detailed information about External tables cloning considerations, refer to the Snowflake documentation.

Question 7
Skipped
The Data Engineering team at a large manufacturing company needs to engineer data coming from many sources to support a wide variety of use cases and data consumer requirements which include:

1. Finance and Vendor Management team members who require reporting and visualization

2. Data Science team members who require access to raw data for ML model development

3. Sales team members who require engineered and protected data for data monetization

What Snowflake data modeling approaches will meet these requirements? (Choose two.)

Create a raw database for landing and persisting raw data entering the data pipelines.

Create a single star schema in a single database to support all consumers’ requirements.

Consolidate data in the company’s data lake and use EXTERNAL TABLES.

Correct selection
Create a Data Vault as the sole data pipeline endpoint and have all consumers directly access the Vault.

Correct selection
Create a set of profile-specific databases that aligns data with usage patterns.

Overall explanation
A few comments:

Data Vault modeling is characterized by its flexibility and scalability when integrating new use cases from different sources and tenants. By using Hubs, Links, Satellites and other Derived objects it is possible to make a single Vault where all these sources can be integrated in the same model, covering the needs of the different use cases.

On the other hand, we can define an architecture where we have one database per data source, being able to align the modeling to the needs of each use case.

These modeling functionalities would not be possible through a single star schema.

The other options do not talk about modeling types so they are discarded as not correct.

Question 8
Skipped
What Snowflake object executes code outside Snowflake, known as remote service?

External Function Integration

External Script

External Job

Correct answer
External Function

Overall explanation
For more detailed information, refer to the Snowflake documentation.



Question 9
Skipped
Which system functions does Snowflake provide to monitor clustering information within a table (Choose two.)

Correct selection
SYSTEM$CLUSTERING_DEPTH

SYSTEM$CLUSTERING_PERCENT

SYSTEM$CLUSTERING_USAGE

Correct selection
SYSTEM$CLUSTERING_INFORMATION

SYSTEM$CLUSTERING_KEYS

Overall explanation
SYSTEM$CLUSTERING_INFORMATION: This system function provides detailed information about how well a table is clustered based on the defined clustering key.

SYSTEM$CLUSTERING_DEPTH: This function provides insights into the depth of the clustering in a table, helping to evaluate the efficiency of the clustering structure over time.

For more detailed information, refer to the Snowflake documentation.

Question 10
Skipped
Which of the below commands will use warehouse credits?

Correct answer
SELECT COUNT(FLAKE_ID) FROM SNOWFLAKE GROUP BY FLAKE_ID;
SELECT MAX(FLAKE_ID) FROM SNOWFLAKE;
SELECT COUNT(*) FROM SNOWFLAKE;
SHOW TABLES LIKE 'SNOWFL%';
Overall explanation
A few comments:

Metadata operations do not require a compute warehouse and therefore do not consume warehouse credits.

Metadata about each column for the micro-partition is stored by Snowflake in its metadata cache in the cloud services layer. This metadata is used to provide extremely fast results for basic analytical queries such as count(*) and max(column).

SHOW TABLES is a metadata query that retrieves information about tables in Snowflake.

Question 11
Skipped
Person1 is using the role SECURITYADMIN. Person 1 creates a role named DBA_ROLE that will manage the warehouses in the Snowflake account. Person1 now needs to switch to that role.

What command(s) need to be executed to switch the context of this worksheet?

Correct answer
GRANT ROLE DBA_ROLE TO USER PERSON1;

USE ROLE DBA_ROLE;

The SECURITYADMIN role is not allowed to GRANT permissions to a role.

GRANT ROLE DBA_ROLE TO ROLE SECURITYADMIN;

USE ROLE DBA_ROLE;

Overall explanation
For more detailed information, refer to the Snowflake documentation.

Question 12
Skipped
Two tables have been created in the same schema with the same information. One is a Secure View; the second one is a standard View. When executing a query, the profiler doesn’t show the same information. How is this possible?

The user role doesn’t have access to the view

The underlying table definition has changed

Correct answer
Secure views do not expose the underlying tables or internal structural details for a view

The underlying table is corrupted

Overall explanation
In Snowflake, secure views are designed to protect sensitive information by hiding the underlying table details and query execution plan. This ensures that users querying the secure view cannot access metadata or structural details of the underlying data, which explains the difference in the profiler information compared to a standard view.



Question 13
Skipped
What types of objects does Snowflake return when we execute the function GET_OBJECT_REFERENCES? (Choose two)

Correct selection
Tables

UDFs

Streams

Correct selection
Views (including secure views)

Materialized views

Overall explanation
Only views (including secure views) and tables are returned when getting the object references. Materialized views are not returned at this moment.



Question 14
Skipped
A company needs to have the following features available in its Snowflake account:

1. Support for Multi-Factor Authentication (MFA)

2. A minimum of 2 months of Time Travel availability

3. Database replication in between different regions

4. Native support for JDBC and ODBC

5. Customer-managed encryption keys using Tri-Secret Secure

6. Support for Payment Card Industry Data Security Standards (PCI DSS)

In order to provide all the listed services, what is the MINIMUM Snowflake edition that should be selected during account creation?

Enterprise

Virtual Private Snowflake (VPS)

Standard

Correct answer
Business Critical

Overall explanation
The Business Critical and VPS editions of Snowflake include all the features specified in the question, but the question is asking for the MINIMUM, so we choose Business Critical.

For more detailed information, refer to the Snowflake documentation.

Question 15
Skipped
A copy command is executed to load a file.

After the file has loaded and the metadata has expired, what options can be used to reload the file? (Select TWO).

Correct selection
Set the LOAD_UNCERTAIN_FILES option to TRUE.

Set the PRESERVE_SPACE option to TRUE.

Set the ALLOW_DUPLICATE option to TRUE.

Correct selection
Set the FORCE option to TRUE.

Set the DISABLE_SNOWFLAKE_DATA option to TRUE.

Overall explanation
For more detailed information about syntax, refer to the Snowflake documentation.

Question 16
Skipped
After creating the table MY_TABLE, we execute the following commands:

CREATE STREAM MYSTREAM ON TABLE MYTABLE;
INSERT INTO MYTABLE VALUES (15);
What will be the output of executing the following command?

SELECT SYSTEM$STREAM_HAS_DATA('MYSTREAM');

It will return “False”

It will return “15”

It will return “Null”

Correct answer
It will return “True”

Overall explanation
The SYSTEM$STREAM_HAS_DATA indicates whether a specified stream contains change data capture (CDC) records and they haven't been consumed. In this case, it will return True. This function is intended to be used in the "WHEN" expression in the definition of tasks; if the stream has data, then you execute the task. Otherwise, the task can skip the current run.

Question 17
Skipped
Which statements describe characteristics of the use of materialized views in Snowflake? (Choose two.)

They can include ORDER BY clauses.

Correct selection
They can support MIN and MAX aggregates.

Correct selection
They cannot include nested subqueries.

They can include context functions, such as CURRENT_TIME().

They can support inner joins, but not outer joins.

Overall explanation
A few comments:

Materialized views have certain limitations, including the inability to support joins or nested subqueries, which restricts the complexity of the queries that can be materialized.

Materialized views in Snowflake can include aggregate functions like MIN and MAX, which allow for efficient querying of summary data.

Using context functions like CURRENT_TIME or CURRENT_TIMESTAMP is not permitted.

For more detailed information, refer to the Snowflake documentation.

Question 18
Skipped
A Snowflake Architect set up a COPY INTO command to continuously load data from an external stage. The destination Snowflake table has much more data than expected.

Why is this occurring?

The ON_ERROR copy option is set to CONTINUE, which is causing duplicate file loading.

LOAD_UNCERTAIN_FILES is set to FALSE.

The PURGE option is set to FALSE, and files are not being deleted from the stage after loading.

Correct answer
The FORCE copy option is set to TRUE, and staged files are being loaded even if they have been loaded already.

Overall explanation
When the FORCE option is set to TRUE in the COPY INTO command, Snowflake reloads files from the stage even if they have already been processed, which can lead to duplicate data being loaded into the destination table.

For more detailed information, refer to the Snowflake documentation.

Question 19
Skipped
What is the MINIMUM Snowflake edition needed to integrate a tokenization provider with Snowflake External Tokenization?

Business Critical

Correct answer
Enterprise

Standard

Virtual Private Snowflake (VPS)

Overall explanation
You can utilize external functions with a tokenization provider with Standard Edition. However, to integrate your tokenization provider with Snowflake External Tokenization, an upgrade to the Enterprise Edition or higher is required.

For more detailed information, refer to the Snowflake documentation.

Question 20
Skipped
What are the limitations about external functions? (Choose two.)

The maximum response size per batch is 16MB.

Correct selection
We can only write functions, not stored procedures.

Future grants of privileges on external functions are supported.

External functions can return multiple values for each input row

Correct selection
External functions must be scalar, so it returns a single value for each input row.

Overall explanation
For more detailed information, refer to the Snowflake documentation.

Question 21
Skipped
Which command can we use to list all the object references of a view?

LIST_OBJECT_REFERENCES

GET_VIEW_REFERENCES

Correct answer
GET_OBJECT_REFERENCES

GET_REFERENCES

Overall explanation
Just as an example, if I wanted to know all the references of the view MY_VIEW, we would execute this command:



select *
from table(get_object_references(
database_name=>'MY_DB',
schema_name=>'MY_SCHEMA',
object_name=>’MY_VIEW’)
);
Question 22
Skipped
A SYSADMIN created a number of database objects and granted the ownership privilege to a custom role.

What will happen if the custom role is not assigned to SYSADMIN or SECURITYADMIN through a role hierarchy? (Choose two.)

Correct selection
The SYSADMIN role will not be able to manage the objects created by the role.

As the database objects are created by the SYSADMIN, the custom role will be able to manage the objects.

Correct selection
The SECURITYADMN role can grant themselves access to the objects and modify their access grants.

The SECURITYADMIN role cannot view the objects or modify their access grants.

The objects can be viewed by both the SECURITYADMIN and USERADMIN roles.

Overall explanation
A few comments:

Since ownership of the objects has been transferred to the custom role, SYSADMIN will no longer have the ability to manage those objects unless it has been granted the necessary privileges.

The SECURITYADMIN role has the ability to grant itself access to objects, allowing it to modify access grants, even if it was not initially part of the role hierarchy.

For more detailed information, refer to the Snowflake documentation.

Question 23
Skipped
What will happen to ALTER a column setting it to NOT NULL if it contains NULL values?

NULL values are changed to an empty string " "

NULL values are changed to 0

Correct answer
Snowflake returns an error

Snowflake deletes the rows with NULL values

Overall explanation
When setting a column to NOT NULL, if the column contains NULL values, an error is returned and no changes are applied to the column. This restriction prevents inconsistency between values in rows inserted before the column was added and rows inserted after the column was added.

Question 24
Skipped
After how many days does the load activity of the COPY INTO command and Snowpipe of Information Schema expire?

64 days for both.

64 days for the COPY INTO command, 14 days for Snowpipe.

Correct answer
14 days for both.

14 days for the COPY INTO command, 64 days for Snowpipe.

Overall explanation
The COPY_HISTORY command retains the loading history for both the COPY into command and Snowpipe for the last 14 days.

You can execute it by running: select * from table(information_schema.copy_history( and check the result in your Snowflake account.

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
Which command can we use to convert JSON NULL values to SQL NULL values?

JSON_TO_SQL

Correct answer
STRIP_NULL_VALUE

TRANSCRIPT_NULL

CONVERT_NULL_VALUE

Overall explanation
STRIP_NULL_VALUE converts a JSON null value to a SQL NULL value, while all other VARIANT values remain unchanged. This function helps align the JSON data format with SQL NULL handling during processing.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
A Snowflake Architect is designing an application and tenancy strategy for an organization where strong legal isolation rules as well as multi-tenancy are requirements.

Which approach will meet these requirements if Role-Based Access Policies (RBAC) is a viable option for isolating tenants?

Create a multi-tenant table strategy if row level security is not viable for isolating tenants.

Correct answer
Create an object for each tenant strategy if row level security is not viable for isolating tenants.

Create an object for each tenant strategy if row level security is viable for isolating tenants.

Create accounts for each tenant in the Snowflake organization.

Overall explanation
Security can factor into the decision to use an OPT design pattern. Some customers prefer the OPT model because they don’t want to manage an entitlement table, secure views, or row-level security with strong processes behind them.

For more detailed information, refer to the Snowflake documentation.

Question 27
Skipped
What type of authentication does the Kafka connector use?

Username/password requiring a password with numbers and letters

Key pair Authentication, which requires a 1024-bit (minimum) RSA key pair

Correct answer
Key pair Authentication, which requires a 2048-bit (minimum) RSA key pair

Username/password requiring a password with numbers, letters, and symbols

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
Which pipes are cloned when cloning a database or schema?

Both

Pipes that reference internal stages

Pipes that reference Snowflake streams

Correct answer
Pipes that reference external stages

Overall explanation
When a database or schema is cloned, any pipes in the source container that reference an internal (that is, Snowflake) stage are not cloned.

For more detailed information, refer to the Snowflake documentation.

Question 29
Skipped
The table STUDENT_DETAIL has the following information:



Which query will give the following output on this table?



{
"enrollmentId": "1000000000000000",
"packageCode : null,
"registrationCode" :"AK00000854"
}
SELECT
  OBJECT_CONSTRUCT
  (
    'enrollmentId', ctrid,
    'packageCode', packagecode,
    'registrationCode', REGISTRATIONCODE
  )
FROM STUDENT_DETAIL ;
SELECT
  ARRAY_CONSTRUCT
  (
    'enrollmentId', ctrid,
    'registrationCode', REGISTRATIONCODE,
    'packageCode', PACKAGECODE
  )
FROM STUDENT_DETAIL ;
SELECT
  OBJECT_AGG
  (
    'enrollmentId', ctrid,
    'packageCode', packagecode,
    'registrationCode', REGISTRATIONCODE
  )
FROM STUDENT_DETAIL ;
Correct answer
SELECT
  OBJECT_CONSTRUCT_KEEP_NULL
  (
    'enrollmentId', ctrid,
    'packageCode', REGISTRATIONCODE,
    'registrationCode', PACKAGECODE
  )
FROM STUDENT_DETAIL ;
Overall explanation
The query needs to return a JSON object where the "packageCode" is explicitly set to null. To achieve this, the function OBJECT_CONSTRUCT_KEEP_NULL should be used. This function ensures that null values are retained in the resulting object, unlike OBJECT_CONSTRUCT, which omits them. In this case, "packageCode" should appear as null in the output, and only OBJECT_CONSTRUCT_KEEP_NULL can produce this result.

Question 30
Skipped
What of these metrics is not a metric that appears in the Execution Time screen of the Query Profiler?

Correct answer
Bytes scanned

Initialization

Synchronization

Remote Disk IO

Overall explanation
“Bytes scanned” metric belongs to the statistics screen, as we can see in the following picture:



Question 31
Skipped
How is the change of local time due to daylight savings time handled in Snowflake tasks? (Choose two.)

A task will move to a suspended state during the daylight savings time change.

Task schedules can be designed to follow specified or local time zones to accommodate the time changes.

Correct selection
A task scheduled in a UTC-based schedule will have no issues with the time changes.

Correct selection
A task schedule will follow only the specified time and will fail to handle lost or duplicated hours.

A frequent task execution schedule like minutes may not cause a problem, but will affect the task history.

Overall explanation
A few comments:

Tasks that follow a UTC-based schedule are not affected by daylight savings time changes, as UTC remains constant regardless of local time adjustments.

Tasks scheduled in local time zones can encounter issues during daylight savings transitions, such as skipping or repeating execution due to the loss or gain of an hour, leading to potential scheduling inconsistencies.

For more detailed information, refer to the Snowflake documentation.

Question 32
Skipped
What does the average_overlaps in the output of SYSTEM$CLUSTERING_INFORMATION refer to?

The average number of partitions physically stored in the same location.

The average number of micro-partitions stored in Time Travel.

Correct answer
The average number of micro-partitions which contain overlapping value ranges.

The average number of micro-partitions in the table associated with cloned objects.

Overall explanation
average_overlaps refers to the average number of micro-partitions that have overlapping value ranges. A higher number of overlaps indicates that the table may not be well-clustered, which can affect query performance.

For more detailed information, refer to the Snowflake documentation.

Question 33
Skipped
An Architect needs to allow a user to create a database from an inbound share.

To meet this requirement, the user’s role must have which privileges? (Choose two.)

CREATE SHARE;

Correct selection
CREATE DATABASE;

Correct selection
IMPORT SHARE;

IMPORT DATABASE;

IMPORT PRIVILEGES;

Overall explanation
IMPORT SHARE allows the user to import a shared database from an inbound share into their account.

CREATE DATABASE privilege is needed to create a database from the imported share. Both privileges together enable the necessary actions to complete the task.

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
A company’s daily Snowflake workload consists of a huge number of concurrent queries triggered between 9pm and 11pm. At the individual level, these queries are smaller statements that get completed within a short time period.

What configuration can the company’s Architect implement to enhance the performance of this workload? (Choose two.)

Set the connection timeout to a higher value than its default.

Correct selection
Enable a multi-clustered virtual warehouse in maximized mode during the workload duration.

Increase the size of the virtual warehouse to size X-Large.

Correct selection
Set the MAX_CONCURRENCY_LEVEL to a higher value than its default value of 8 at the virtual warehouse level.

Reduce the amount of data that is being processed through this workload.

Overall explanation
A few comments:

Enabling a multi-clustered virtual warehouse in maximized mode during the workload duration will provide better query performance as it automatically and dynamically scales the number of clusters and the processing power based on the workload requirements.

Setting the MAX_CONCURRENCY_LEVEL to a higher value than its default value of 8 will allow more queries to run concurrently, which can improve overall query performance.

Question 35
Skipped
Which of the following statements are the best practices for the ACCOUNTADMIN role? (Choose three)

Correct selection
Assign this role only to a select/limited number of people in your organization.

Correct selection
All users assigned the ACCOUNTADMIN role should also be required to use multi-factor authentication (MFA) for login.

The ACCOUNTADMIN role should be used for all routine administrative tasks.

Assign this role to only one user.

Correct selection
Assign this role to at least two users.

All users assigned the ACCOUNTADMIN role should be allowed to bypass security protocols.

Overall explanation
The first two statements are obvious. Regarding the last one, Snowflake follows strict security procedures for resetting a forgotten or lost password for users with the ACCOUNTADMIN role. These procedures can take up to two business days, and to avoid them, we should assign this role to two users at least, as the users can reset each other’s passwords.

Question 36
Skipped
An Architect ran a query that completed in 30 minutes. The Architect wants to tune the query - noting a compilation time of 24 minutes.

What steps can be taken to address this situation without increasing the size of the virtual warehouse? (Choose three.).

Enable the search optimization service on the tables.

Correct selection
Materialize some of the resource-intensive operations in the query.

Enable clustering on all the tables in the query.

Correct selection
Check the query definition to identify if there are high-complexity nested views.

Increase the number of multi-clusters.

Correct selection
Rewrite the query to reduce or eliminate high compute, resource-intensive functions.

Overall explanation
A few comments:

Increasing number of multicluster will help only concurrency issues, not this case.

The timing problem is caused with the compilation, not with performance, so we discarded options oriented to improve performance: search optimization service, clustering, etc.

Long compilation times are caused by query complexity and the number of tables and columns involved in the query. It is important to understand that increasing the virtual warehouse size does not always improve query performance. Therefore, it is essential to optimize the query complexity and the schema of the tables involved in the query to reduce the compilation time and improve query performance.

The top time-consuming activity during the compilation process is query complexity. The complexity is measured based on the number of lines, functions, joins, filters, group by, order by, and union statements. The more complex the query, the longer it takes for the optimizer to create the query plan. As a result, the compilation time can be longer than the execution time.

The number of tables and columns in the query also affects the compilation time. The optimizer needs to analyze the schema and the statistics of the tables to create an optimized query plan. Therefore, the more tables and columns involved in the query, the longer it takes for the optimizer to create the plan.

Question 37
Skipped
Which steps are recommended best practices for prioritizing cluster keys in Snowflake? (Choose two.)

Correct selection
Choose cluster columns that are most actively used in selective filters.

Choose cluster columns that are actively used in the GROUP BY clauses.

Choose lower cardinality columns to support clustering keys and cost effectiveness.

Correct selection
Choose columns that are frequently used in join predicates.

Choose TIMESTAMP columns with nanoseconds for the highest number of unique rows.

Overall explanation
A few comments:

When designing cluster keys, it's important to prioritize columns that are frequently involved in queries with selective filters (such as WHERE clauses). This helps Snowflake reduce the amount of data it needs to scan, which can significantly improve query performance by targeting the most relevant data more efficiently.

Clustering on columns that are commonly used in join operations ensures that related data is physically stored closer together. This optimizes the performance of join queries, as Snowflake can retrieve and process matching rows more quickly, reducing the overall compute resources and time required for query execution.

For more detailed information, refer to the Snowflake documentation.

Question 38
Skipped
Which command can we use to restore a dropped share?

UNDROP SHARE <myShare>

Correct answer
We cannot restore a dropped SHARE; we must create it again.

RESTORE SHARE <myShare>

RECOVER SHARE <myShare>

Overall explanation
A dropped share can not be restored. The share must be created again.

For more detailed information, refer to the Snowflake documentation.

Question 39
Skipped
Which feature provides the capability to define an alternate cluster key for a table with an existing cluster key?

Correct answer
Materialized view

Search optimization

External table

Result cache

Overall explanation
If you cluster both the materialized view(s) and the base table on which the materialized view(s) are defined, you can cluster the materialized view(s) on different columns from the columns used to cluster the base table.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
Which Snowflake data modeling approach is designed for BI queries?

Correct answer
Star schema

Snowflake schema

3 NF

Data Vault

Overall explanation
Star schema allows faster cube processing.

Question 41
Skipped
Files arrive in an external stage every 10 seconds from a proprietary system. The files range in size from 500 K to 3 MB. The data must be accessible by dashboards as soon as it arrives.

How can a Snowflake Architect meet this requirement with the LEAST amount of coding? (Choose two.)

Use the COPY INTO command.

Use a combination of a task and a stream.

Use a materialized view on an external table.

Correct selection
Use Snowpipe with auto-ingest.

Correct selection
Use a COPY command with a task.

Overall explanation
A few comments:

To meet the requirement of accessing data as soon as it arrives in the external stage with the least amount of coding, Snowpipe with auto-ingest and COPY command with a task can be used.

Snowpipe with auto-ingest automatically ingests data as soon as it arrives in the external stage, while COPY command with a task can be used to automate the process of copying data from external stage to internal tables.

Option External table + Materialized view would require even more coding and would not be as near real-time.

The other options do not meet the requirements of ingestion and automation.

Question 42
Skipped
A company that is in one region wants to share data with two different consumers who are both based in a second region

How can this be accomplished with the MINIMUM duplication of data?

Replicate two copies of the data to the second region and share each one respectively with the two consumers

Correct answer
Replicate one copy of the data to the second region, and share it with the two data consumers

Create a direct share from the first region to the second region, and provide access to both data consumers

Replicate two copies of the data to the second region, but only share one of the copies with the two data consumers

Overall explanation
This is a typical case of database replication. As the consumers are in a different region it is necessary to enable the database replication functionality. The LESS way to duplicate data is to do a replication and from there a share to the two consumers.

Question 43
Skipped
Which ALTER commands will impact a column's availability in Time Travel?

Correct answer
ALTER TABLE … SET DATA TYPE …

ALTER TABLE … RENAME COLUMN …

ALTER TABLE … SET NOT NULL …

ALTER TABLE … DROP COLUMN …

Overall explanation
Decreasing the precision of a number column can impact Time Travel, for example, converting from NUMBER(20,2) to NUMBER(10,2). SET DATA TYPE is the command that can make that.

Question 44
Skipped
Will this query cost compute credits considering that the previous query ran 5 minutes ago?



SELECT *
FROM TABLE(
RESULT_SCAN(LAST_QUERY_ID())
);
Correct answer
No, it will not compute credits because we are re-using from the cache.

It will cost credits.

It will cost credits if auto-suspend time of the Warehouse is less than 5 minutes.

We cannot know because we do not know the auto-suspend time of the Warehouse.

Overall explanation
A few comments:

The RESULT_SCAN function returns the result set of a previous command (within 24 hours of when you executed the query) as if the result was a table.

As we are using the cache, it doesn't cost compute credits.

For more detailed information, refer to the Snowflake documentation.

Question 45
Skipped
A Data Architect is importing JSON data from an external stage into a table with a VARIANT column using the COPY INTO command. During testing, the Architect discovers that the import sometimes fails, with parsing errors, due to malformed JSON values. The Architect decides to set the VARIANT column to NULL when a parsing error is encountered.

Which function should be used to meet this requirement?

Correct answer
TRY_PARSE_JSON

PARSE_JSON

VALIDATE

TO_JSON

Overall explanation
TRY_PARSE_JSON function attempts to parse JSON data and returns NULL if the parsing fails, allowing the Architect to handle malformed JSON values without causing errors during the import process.

For more detailed information, refer to the Snowflake documentation.

Question 46
Skipped
What is the meaning of “Local Disk IO” in the query profiler menu when running a query?

Correct answer
The time when the processing was blocked by local disk access.

The time when the processing was waiting for the network data transfer.

The time when the query was being optimized by the query planner.

The time spent on data processing by the CPU.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
Which of the following options is not a compression technique for AVRO file formats?

Correct answer
BZ2

ZSTD

GZIP

AUTO

Overall explanation
AVRO compression techniques are very similar to XML, JSON, and CSV; the only difference is that it doesn’t accept BZ2 compression. You can see the different compression types for each file format in the following table:



Question 48
Skipped
What is the function of Resource Monitors regarding data pipelines?

Make data not being replicated twice in the same pipeline

Correct answer
It helps you monitor and control the costs of your pipelines

Limit the number of concurrent queries in data pipelines

It performs backups for your pipelines every 5 minutes

Overall explanation
A Resource Monitor can, among other things, notify the user, notify and suspend the warehouse, etc. It will allow us to establish limits on our account.

For more detailed information, refer to the Snowflake documentation.

Question 49
Skipped
What two requirements are necessary for the remote service to be called by the Snowflake external function? (Choose two.)

Use only HTTP endpoints without encryption.

Correct selection
Expose an HTTPS endpoint.

Be part of the AWS suite exclusively, as Azure and GCP are not supported yet.

Correct selection
Accept JSON inputs and return JSON outputs.

The remote service must return XML outputs.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
An Architect is designing a pipeline to stream event data into Snowflake using the Snowflake Kafka connector. The Architect’s highest priority is to configure the connector to stream data in the MOST cost-effective manner.

Which of the following is recommended for optimizing the cost associated with the Snowflake Kafka connector?

Utilize a lower Buffer.flush.time in the connector configuration.

Utilize a lower Buffer.size.bytes in the connector configuration.

Utilize a lower Buffer.count.records in the connector configuration.

Correct answer
Utilize a higher Buffer.flush.time in the connector configuration.

Overall explanation
A few comments:

buffer.flush.time defines the interval (in seconds) between buffer flushes, triggering insert operations for buffered records. After each flush, the Kafka connector calls the Snowpipe Streaming API once.

For higher data flow rates, reducing this value improves latency.

If cost is a priority over latency, increasing the buffer flush time may be preferable.

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
What other parameter does Snowflake recommend adding when organizing files into logical paths?

The city where the stage is located

The size of the data files

The day of the week when the data was written

Correct answer
The date when the data was written

Overall explanation
For example, imagine we are storing data for a European company with locations in different countries. The logical paths could be:

Spain/Madrid/2023/01/10/05/

Spain/Barcelona/2023/01/03/05/

Germany/Berlin/2023/01/07/04/

Question 52
Skipped
How many files can the COPY INTO operation load as the maximum when providing a discrete list of files?

100

Correct answer
1000

There is no limit.

10000

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
An organization is interested in using the Kafka Connector for loading data into Snowflake. The team has the Kafka connector subscribed to a few Kafka topics, but the topics have not been mapped to Snowflake tables.

What is the expected Kafka connector behavior? (Choose two.)

The connector cannot load data until a Snowpipe is created for each partition.

The connector cannot load data until Kafka topics are mapped to the Snowflake tables.

Correct selection
The connector creates the columns RECORD_CONTENT and RECORD_METADATA in the target table.

Correct selection
The connector creates a new table for each topic using the topic name.

The connector creates an external stage to temporarily store data files for each topic.

Overall explanation
The connector establishes several objects for each topic, including an internal stage to temporarily hold data files and a pipe to ingest the data files associated with each topic partition. Additionally, it creates a table for each topic. If the specified table does not already exist, the connector will create it. If the table exists, the connector will add the RECORD_CONTENT and RECORD_METADATA columns.

For more detailed information, refer to the Snowflake documentation.

Question 54
Skipped
Which of these Snowflake components/objects is NOT typically used in building continuous ELT pipelines?

Streams

Snowflake Connector for Kafka

Correct answer
Data Exchange

Snowpipe

Overall explanation
Data Exchange is your own data hub for securely collaborating around data between a selected group of members you invite. It enables providers to publish data that consumers can then discover.

For more detailed information, refer to the Snowflake documentation.

Question 55
Skipped
Why does the REMOVE command from a stage improve the COPY INTO command the next time it’s executed?

Because it will have fewer files to copy

Because it will compress files more easily

Because it will avoid duplication of data

Correct answer
Because it will scan fewer files

Overall explanation
Removing files from a stage using the REMOVE command improves the performance when loading data because it reduces the number of files that the COPY INTO <table> command must scan to verify whether existing files in a stage were loaded already.

Question 56
Skipped
We want to generate a JSON object with the data from a table called users_table, composed of two columns (AGE and NAME), ordered by the name column. How can we do it?

SELECT to_object(*) as users_object
FROM users_table
order by users_object[‘NAME’];
Correct answer
SELECT object_construct(*) as users_object
FROM users_table
order by users_object[‘NAME’];
SELECT to_json_object(*) as users_object
FROM users_table
order by users_object[‘NAME’];
SELECT object_deconstruct(*) as users_object
FROM users_table
order by users_object[‘NAME’];
Overall explanation
The OBJECT_CONSTRUCT command returns an OBJECT constructed from the arguments. In the following example (left), the arguments come from the table, whereas in the second (right), we send the arguments to the function.



Question 57
Skipped
When loading data into a table that captures the load time in a column with a default value of either CURRENT_TIME() or CURRENT_TIMESTAMP() what will occur?

Any rows loaded using a specific COPY statement will have varying timestamps based on when the rows were read from the source.

Any rows loaded using a specific COPY statement will have varying timestamps based on when the rows were created in the source.

All rows loaded using a specific COPY statement will have varying timestamps based on when the rows were inserted.

Correct answer
All rows loaded using a specific COPY statement will have the same timestamp value.

Overall explanation
When loading data into a table that captures the load time in a column with a default value of either CURRENT_TIME() or CURRENT_TIMESTAMP(), all rows loaded using a specific COPY statement have the same timestamp value. It stores the time that the COPY statement began, not when the record is inserted, and it applies both to the CURRENT_TIME() and the CURRENT_TIMESTAMP() functions.





Question 58
Skipped
How does a standard virtual warehouse policy work in Snowflake?

It conserves credits by keeping running clusters fully loaded rather than starting additional clusters.

Correct answer
It prevents or minimizes queuing by starting additional clusters instead of conserving credits.

It starts only if the system estimates that there is a query load that will keep the cluster busy for at least 2 minutes.

It starts only if the system estimates that there is a query load that will keep the cluster busy for at least 6 minutes.

Overall explanation
A few comments:

Standard (default): Prevents/minimizes queuing by favoring starting additional clusters over conserving credits.

The first cluster starts immediately when either a query is queued or the system detects that there’s one more query than the currently-running clusters can execute.

Each successive cluster waits to start 20 seconds

For more detailed information, refer to the Snowflake documentation.



Question 59
Skipped
A Data Architect has set up continuous data ingestion using Snowpipe. After a few days of successful data ingestion, the Architect must modify the pipe definition of the referenced external stage.

What are the recommended steps the Architect should take?

• Pause the pipe using the SET_PIPE statement and make sure the pending file count is 1

• Recreate the pipe to change the COPY statement

• Review the configuration steps for the cloud message service to ensure settings are accurate

• Resume the pipe using the START_PIPE statement and verify pipe execution status is running

Correct answer
• Pause the pipe using an ALTER_PIPE statement, confirm the pending file count is 0

• Recreate the pipe to change the COPY statement and pause the pipe

• Review the configuration steps for the cloud message service to ensure settings are accurate

• Resume the pipe and verify the pipe execution status is running

• Create the pipe using the CREATE_PIPE statement, confirm the pending file count is 1

• Recreate the pipe to change the COPY statement and pause the pipe

• Review configuration steps for the cloud message service to ensure settings are accurate

• Resume the pipe using the SET_PIPE statement and verty pipe execution status is running

• Pause the pipe using an ALTER_PIPE statement, confirm the pending file count is 0

• Recreate the pipe to change the COPY statement

• Review the configuration steps for the cloud message service to ensure settings are accurate

• Resume the pipe and verify pipe execution status is running

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
Why does Snowflake recommend using the insertReport endpoint instead of the loadHistoryScan when using Snowpipe?

Correct answer
Because an excessive usage of the loadHistoryScan tends to lead to API throttling (and it returns the error code 429).

Because the loadHistoryScan endpoint is deprecated, it will no longer be updated by Snowflake.

Because the reports give more information

Because the loadHistoryScan is faster and more efficient.

Overall explanation
Reading the last 24 hours of history every minute will result in 429 errors indicating a rate limit has been reached. To help avoid it, Snowflake recommends relying more heavily on insertReport than loadHistoryScan.

For more detailed information, refer to the Snowflake documentation.

Question 61
Skipped
After adding the Search Optimization service in a Snowflake table called MY_TABLE, we forgot to add it in two columns, so we ran the same command in the other two columns, as we can see in the following code:



ALTER TABLE MY_TABLE ADD SEARCH OPTIMIZATION ON EQUALITY(col1, col2);
ALTER TABLE MY_TABLE ADD SEARCH OPTIMIZATION ON EQUALITY(col3, col4);


What is going to be the result?

Correct answer
It will work as each subsequent command adds the existing configuration to the table.

It will fail as you can only add the Search Optimization Service once. You should drop it first.

It will only apply to col3 and col4, ignoring col1 and col2.

It will drop the Search Optimization Service from col1 and col2, but it will work for columns col3 and col4.

Overall explanation
You can add the Search Optimization service to a table by running the command “ALTER TABLE <table_name> ADD SEARCH OPTIMIZATION. Also, running the two previous queries is the same as running the following command:



ALTER TABLE MY_TABLE ADD SEARCH OPTIMIZATION ON EQUALITY(col1, col2, col3, col4);

Question 62
Skipped
A user can change object parameters using which of the following roles?

SYSADMIN, SECURITYADMIN

SECURITYADMIN, USER with PRIVILEGE

ACCOUNTADMIN, SECURITYADMIN

Correct answer
ACCOUNTADMIN, USER with PRIVILEGE

Overall explanation
The ACCOUNTADMIN role has full privileges to modify object parameters, and any user with the necessary specific privilege can also perform these changes, provided they have been granted the appropriate permissions.

For more detailed information, refer to the Snowflake documentation.

Question 63
Skipped
After performing the following query:



SELECT *
FROM MYTABLE
WHERE email=’test@test.com’
you see in the query profiler the following information:



Can you spot the issue?

Union without ALL

The query is too large to fit in memory.

A "exploding join" issue might be the problem.

Correct answer
There is inefficient pruning

Overall explanation
All the previous answers are the most common query problems you can identify in the Query Profile (essential to know). The pruning efficiency can be observed by comparing Partitions scanned and Partitions total statistics in the TableScan operators.

Pruning is efficient if the former is a small fraction of the latter. If not, the pruning did not have an effect. In this case, Snowflake scans all the partitions to get the rows with the value test@test.com in the email. This means this column is not well clustered, as it shouldn't scan so many partitions. We should create a cluster key on the EMAIL column.

Question 64
Skipped
A media company needs a data pipeline that will ingest customer review data into a Snowflake table, and apply some transformations. The company also needs to use Amazon Comprehend to do sentiment analysis and make the de-identified final data set available publicly for advertising companies who use different cloud providers in different regions.

The data pipeline needs to run continuously and efficiently as new records arrive in the object storage leveraging event notifications. Also, the operational complexity, maintenance of the infrastructure, including platform upgrades and security, and the development effort should be minimal.

Which design will meet these requirements?

Ingest the data using Snowpipe and use streams and tasks to orchestrate transformations. Export the data into Amazon S3 to do model inference with Amazon Comprehend and ingest the data back into a Snowflake table. Then create a listing in the Snowflake Marketplace to make the data available to other companies.

Ingest the data using COPY INTO and use streams and tasks to orchestrate transformations. Export the data into Amazon S3 to do model inference with Amazon Comprehend and ingest the data back into a Snowflake table. Then create a listing in the Snowflake Marketplace to make the data available to other companies.

Ingest the data into Snowflake using Amazon EMR and PySpark using the Snowflake Spark connector. Apply transformations using another Spark job. Develop a python program to do model inference by leveraging the Amazon Comprehend text analysis API. Then write the results to a Snowflake table and create a listing in the Snowflake Marketplace to make the data available to other companies.

Correct answer
Ingest the data using Snowpipe and use streams and tasks to orchestrate transformations. Create an external function to do model inference with Amazon Comprehend and write the final records to a Snowflake table. Then create a listing in the Snowflake Marketplace to make the data available to other companies.

Overall explanation
For more detailed information, refer to the documentation.

Question 65
Skipped
Which data modeling concepts can be used in Snowflake (Choose two.)

Distribution Key

Non-Unique Index

Correct selection
Foreign Key

Unique Index

Correct selection
Primary Key

Overall explanation
For more detailed information, refer to the official Snowflake documentation.