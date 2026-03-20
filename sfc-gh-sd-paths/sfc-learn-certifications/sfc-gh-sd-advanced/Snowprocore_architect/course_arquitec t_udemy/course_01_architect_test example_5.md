
Question 1
Incorrect
A Data Architect is using Time Travel to clone a table using this query:



CREATE TABLE MY_TABLE_CLONE CLONE MY_TABLE
AT (OFFSET => -60*30);
An error is returned.



What could be causing the error? (Select TWO).

The object has exceeded the maximum cloning limit.

Your selection is incorrect
Time Travel and cloning features cannot be run together.

Correct selection
The source object did not exist at the time specified in the AT | BEFORE parameter.

Your selection is incorrect
The object cannot be cloned because it has a row access policy attached to it.

Correct selection
The source object is an external table.

Overall explanation
A few comments:

When using Time Travel, External tables are not cloned.

If the timestamp or offset in the Time Travel clause references a point before the object was created or outside the retention period, cloning will fail with an error.

Time Travel and cloning can be used together.

Tables with row access policies can be cloned; the policy is cloned along with the table.

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
A Snowflake Architect is working with Data Modelers and Table Designers to draft an ELT framework specifically for data loading using Snowpipe. The Table Designers will add a timestamp column that inserts the current timestamp as the default value as records are loaded into a table. The intent is to capture the time when each record gets loaded into the table; however, when tested, the timestamps are earlier than the load_time column values returned by the copy_history function or the COPY_HISTORY view (Account Usage).



Why is this occurring?

The timestamps are different because there are parameter setup mismatches. The parameters need to be realigned.

Correct answer
The CURRENT_TIME is evaluated when the load operation is compiled in cloud services rather than when the record is inserted into the table.

The Table Designer team has not used the localtimestamp or systimestamp functions in the Snowflake copy statement.

The Snowflake timezone parameter is different from the cloud provider's parameters causing the mismatch.

Overall explanation
When a CURRENT_TIMESTAMP or CURRENT_TIME function is used as a default value in a table, it is evaluated at the start of the load operation in the cloud service, not at the exact moment each record is inserted into the table. This means that the timestamp might reflect the start of the load operation rather than the individual insertion times for each record.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
An Architect wants to integrate Snowflake with a Git repository which requires authentication. What is the correct sequence of steps to be followed?

Create a secret

Create a Snowflake Git repository stage

Create an API Integration

Create a Snowflake Git repository stage

Create an API Integration

Create a secret

Create an API Integration

Create a secret

Create a Snowflake Git repository stage

Correct answer
Create a secret

Create an API Integration

Create a Snowflake Git repository stage

Overall explanation
This question can be found in Drag&Drop or Multi-Select format. Knowing at a high level the features of Snowflake's GIT integration is important as an Architect.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
A company uses Snowflake to store and analyze their customer data. The company has a strict regulatory requirement to protect Personally Identifiable Information (PII).



What should an Architect do to meet this requirement?

Use row-level security to mask PII data.

Create secure views for the PII data and grant access to the views as needed.

Create separate tables for columns containing PII and those that do not; grant access as needed.

Correct answer
Use tag-based masking policies for columns that contain PII data.

Overall explanation
A few comments:

Tag-based masking policies are the recommended approach in Snowflake to manage and enforce column-level data protection, especially for PII.

By tagging columns as containing PII and associating masking policies, Snowflake can automatically enforce dynamic data masking based on user roles and privileges, ensuring compliance with data privacy regulations.

This method supports scalability, auditability, and centralized governance.

Row-level security controls access to rows, not suitable for masking specific columns.

Secure views help protect data but lack the dynamic masking and tag-based enforcement capabilities.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
A company has a source system that provides JSON records for various IoT operations. The JSON is loading directly into a persistent table with a variant field. The data is quickly growing to hundreds of millions of records and performance is becoming an issue. There is a generic access pattern that is used to filter on the create_date key within the variant field.



What can be done to improve performance?

Correct answer
Alter the target table to include additional fields pulled from the JSON records. This would include a create_date field with a datatype of date. When this field is used in the filter, partition pruning will occur.

Validate the size of the warehouse being used. If the record count is approaching hundreds of millions, size XL will be the minimum size required to process this amount of data.

Incorporate the use of multiple tables partitioned by date ranges. When a user or process needs to query a particular date range, ensure the appropriate base table is used.

Alter the target table to include additional fields pulled from the JSON records. This would include a create_date field with a datatype of varchar. When this field is used in the filter, partition pruning will occur.

Overall explanation
A few comments:

Using a varchar data type for dates would not be as efficient as using a date.

Increasing the warehouse size may improve performance temporarily but will incur higher costs without addressing the underlying issue of data organization.

The only thing we will achieve if we partition data across several tables based on date ranges is to increase complexity.

For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
Database DB1 has schema S1 which has one table, T1.



DB1 --> S1 --> T1



The retention period of DB1 is set to 10 days.

The retention period of S1 is set to 20 days.

The retention period of T1 is set to 30 days.



The user runs the following command:

Drop Database DB1;



What will the Time Travel retention period be for T1?

30 days

37 days

20 days

Correct answer
A. 10 days

Overall explanation
In this case:

DB1 retention period = 10 days

S1 retention period = 20 days (overridden by DB1 when DB1 is dropped)

T1 retention period = 30 days (overridden by DB1 when DB1 is dropped)

Currently, when a database is deleted in Snowflake, the data retention period set for child schemas or tables does not take effect if it differs from the retention period of the database itself. Instead, child schemas and tables are retained for the same duration as the database. This means that any specific retention settings applied to the child objects will be overridden by the database's retention policy. In this case, since the database DB1 has a retention period of 10 days, this will override the retention periods set at the schema (20 days) and table (30 days) levels.

For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
A table, t1, has a table stream defined, named s1. The data retention time on the table is set for 10 days. Stream s1 has not been consumed for 10 consecutive days.



What consideration needs to be made if an Architect wants to implement an ELT process on the stream?

An ETL process can access stream s1 after the 11th day because Snowflake automatically puts a temporary extension on the stream offset for 7 additional days.

Because of the data retention time setting on table t1, from the 11th day forward if any ETL process tries to access stream s1 the records from the stream will be inaccessible.

Correct answer
An ETL process can access stream s1 after the 11th day because Snowflake automatically puts a temporary extension on the stream offset for 14 additional days.

An ETL process can access the stream s1 after the 11th day because streams have no dependency on the table DATA_RETENTION_TIME_IN_DAYS parameter.

Overall explanation
If a table has a data retention period shorter than 14 days and its stream hasn't been used, Snowflake will temporarily extend the retention up to a 14-day maximum (by default) to prevent the stream from becoming outdated. This happens automatically, no matter your Snowflake edition.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
A table EMP_TBL has three records as shown:



create or replace TABLE EMP_TBL (
    ID NUMBER(38,0),
    NAME VARCHAR(16777216)
);


ID        NAME

1          Name1

2         Name2

3         Name3



The following variables are set for the session:



set tbl_ref = 'EMP_TBL';
set col_ref = 'NAME';
set (var1, var2, var3) = (select 'Name1', 'Name2', 'Name3');


Which SELECT statements will retrieve all three records? (Select TWO).

SELECT * FROM identifier($tbl_ref) WHERE ID IN (var1,'var2','var3');
SELECT * FROM $tbl_ref WHERE $col_ref IN ('Name1','Name2','Name3');
Correct selection
SELECT * FROM identifier($tbl_ref) WHERE NAME IN ($var1, $var2, $var3);
SELECT * FROM $tbl_ref WHERE $col_ref IN ($var1, $var2, $var3);
Correct selection
SELECT * FROM EMP_TBL WHERE identifier($col_ref) IN ('Name1','Name2','Name3');
Overall explanation
A few comments:

We can use identifier($tbl_ref) to dynamically refer to the table specified by tbl_ref

We can use identifier($col_ref) to dynamically refer to the column specified by the col_ref variable.

We can't refer variables with $ directly, as it's not valid syntax

The other incorrect option uses literal values instead of referencing $var variables.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
Which of the following are characteristics of Snowflake’s parameter hierarchy?

Session parameters override virtual warehouse parameters.

Virtual warehouse parameters override user parameters.

Table parameters override virtual warehouse parameters.

Correct answer
Schema parameters override account parameters.

Overall explanation
This is how object parameters can be overridden at each level:

Account Object parameters overridden by Warehouse parameters

Account Object parameters overriden by Database parameters overriden by Schema parameters overriden by Table, pipe, etc parameters

Account Object parameters overriden by User parameters

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
Where can a data file format be specified in Snowflake? (Select THREE)

Correct selection
As part of a COPY INTO command

As part of a CREATE STORAGE INTEGRATION command

As part of a CREATE WAREHOUSE command

Correct selection
As part of a CREATE STAGE command

Correct selection
As part of a CREATE TABLE command

As part of a CREATE SCHEMA command

Overall explanation
A few comments:

It's recommended to explicitly specify data loading options directly in the COPY INTO <table> statement.

Copy options can also be set in the table or named stage definitions, but this is not recommended due to potential conflicts and lack of clarity.

When options are specified in multiple locations, the COPY INTO <table> statement takes precedence, followed by the stage definition, and then the table definition.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
A Developer is having a performance issue with a Snowflake query. The query receives up to 10 different values for one parameter and then performs an aggregation over the majority of a fact table. It then joins against a smaller dimension table. This parameter value is selected by the different query users when they execute it during business hours. Both the fact and dimension tables are loaded with new data in an overnight import process.



On a Small or Medium-sized virtual warehouse, the query performs slowly. Performance is acceptable on a size Large or bigger warehouse. However, there is no budget to increase costs. The Developer needs a recommendation that does not increase compute costs to run this query.



What should the Architect recommend?

Create a dedicated size Large warehouse for this particular set of queries. Create a new role that has USAGE permission on this warehouse and has the appropriate read permissions over the fact and dimension tables. Have users switch to this role and use this warehouse when they want to access this data.

Create a task that will run the 10 different variations of the query corresponding to the 10 different parameters before the users come in to work. The task will be scheduled to align with the users' working hours in order to allow the warehouse cache to be used.

Enable the search optimization service on the table. When the users execute the query, the search optimization service will automatically adjust the query execution plan based on the frequently-used parameters.

Correct answer
Create a task that will run the 10 different variations of the query corresponding to the 10 different parameters before the users come in to work. The query results will then be cached and ready to respond quickly when the users re-issue the query.

Overall explanation
A few comments:

The Search Optimization Service is designed for fast point lookups, not large aggregations.

Since the query scans most of the fact table, search optimization will not significantly improve performance.

Create a dedicated size Large warehouse for this query will increase compute costs, which violates the problem constraint.

To keep the Warehouse cache active, we need to have the VWH up, which is not cost optimal as we can use the Query Cache for 24 hours.

Question 12
Skipped
What is the MOST efficient way to design an environment where data retention is not considered critical, and customization needs are to be kept to a minimum?

Use a transient schema.

Use a transient table.

Use a temporary table.

Correct answer
Use a transient database.

Overall explanation
A few comments:

Key: customization needs are to be kept to a minimum.

A transient database is the most efficient way to design an environment where data retention is not critical and cost is a factor (reduces storage costs by skipping Fail-Safe).

Setting the database as transient ensures that all tables created within it are also transient by default, minimizing the need for individual table or schema settings.

Question 13
Skipped
When using the STATEMENT_TIMEOUT_IN_SECONDS parameter to control costs, at what levels should this parameter be defined? (Select THREE)

Stage

Schema

Correct selection
User

Correct selection
Account

Correct selection
Session

Organization

Overall explanation
A few comments:

STATEMENT_TIMEOUT_IN_SECONDS specifies the maximum duration, in seconds, after which any active SQL statement (like a query, DDL, or DML command) will be automatically stopped by the system.

STATEMENT_TIMEOUT_IN_SECONDS can be set for Account » User » Session

It can also be set for individual warehouses.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
A Data Architect needs to share data from an orders table with a team. The Architect must ensure that the team members cannot view any Personal Identifiable Information (PII), but they can access and analyze other metrics from the orders table. The Pll is disbursed across several columns and individual rows on the table.



How can this requirement be met?

Share the table data using individual secure views.

Encrypt the order_id column before sharing the data.

Apply an aggregation policy on the table using MIN_GROUP_SIZE.

Correct answer
Apply Dynamic Data Masking on all the columns that contain PII.

Overall explanation
A few comments:

Dynamic Data Masking is specifically designed to protect sensitive data (like PII) by masking it at query runtime, based on the user's role or context.

Since PII is "disbursed across several columns and individual rows," DDM allows you to mask specific values within those columns/rows without affecting the non-PII data or requiring separate views for every scenario.

Encrypting only order_id isn't enough, as PII is in "several columns and individual rows.

Aggregation policies (like k-anonymity) are for preventing re-identification by grouping data, often by generalizing or summarizing. This would likely prevent the team from accessing and analyzing other metrics at a granular level, which the requirement specifies.

While secure views can hide columns or filter rows, managing PII "disbursed across several columns and individual rows" purely with secure views would be extremely complex and potentially lead to data leakage if not perfectly designed. Not the best option.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
A company is following the Data Mesh principles, including domain separation, and chose one Snowflake account for its data platform.



An Architect created two data domains to produce two data products. The Architect needs a third data domain that will use both of the data products to create an aggregate data product. The read access to the data products will be granted through a separate role.



Based on the Data Mesh principles, how should the third domain be configured to create the aggregate product if it has been granted the two read roles?

Correct answer
Use secondary roles for all users.

Request a technical ETL user with the sysadmin role.

Create a hierarchy between the two read roles.

Request that the two data domains share data using the Data Exchange.

Overall explanation
A few comments:

Creating a hierarchy of roles could introduce dependencies between domains, which goes against the principle of domain autonomy in Data Mesh.

Data Exchange is typically used for sharing data between different accounts. Within the same account, data access is best managed through roles.

Use sysadmin role would grant overly high privileges, which goes against the principle of least privilege and is unnecessary for a read-only access requirement.

Data Mesh principles can be applied by assigning specific read roles to each data domain.

The use of secondary roles for users allows the third data domain, which needs to access the data products of the other two domains, to have controlled access through secondary read roles.

Question 16
Skipped
A table contains 10 distinct values in one of the columns.



Assuming the table has 10 micro-partitions and each of the 10 values is stored exclusively on a different micro-partition, what is the clustering depth of the table for this column?

5

10

Correct answer
1

0

Overall explanation
A few comments:

Since each value is fully contained within one micro-partition, the clustering depth = 1 (only one micro-partition needs to be scanned per value).

Clustering depth would be 10 if every value was scattered across all 10 micro-partitions, but here, each value is contained in a single partition.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
A company has built a data pipeline using Snowpipe to ingest files from an Amazon S3 bucket. Snowpipe is configured to load data into staging database tables. Then a task runs to load the data from the staging database tables into the reporting database tables.



The company is satisfied with the availability of the data in the reporting database tables, but the reporting tables are not pruning effectively. Currently, a size 4X-Large virtual warehouse is being used to query all of the tables in the reporting database.



What step can be taken to improve the pruning of the reporting tables?

Increase the size of the virtual warehouse to a size 5X-Large.

Eliminate the use of Snowpipe and load the files into internal stages using PUT commands.

Correct answer
Use an ORDER BY <cluster_key (s)> command to load the reporting tables.

Create larger files for Snowpipe to ingest and ensure the staging frequency does not exceed 1 minute.

Overall explanation
A few comments:

By loading the reporting tables with an ORDER BY clause on specific cluster keys, we can improve data clustering by using manual sorting.

Optimizing data clustering and pruning is more effective and cheaper than merely increasing warehouse size.

Snowpipe’s data loading method does not directly impact how data is organized or queried in the reporting tables.

Larger files might reduce the number of load operations, but this does not improve data organization or pruning in the reporting tables.

Question 18
Skipped
An Architect has been asked to help with a performance issue related to one transformation in a data pipeline. The issue arose when the transformation logic for the sales table was changed by adding additional dimensions into aggregations (approximately 15 additional dimensions).



Nine new sales reports have been added, and the amount of data has doubled. The table currently processes 20 million records when it previously processed 10 million. The run time has increased from 5 minutes to more than 20. Warehouse scaling has been limited as a cost control measure.



How can the performance be improved? (Select TWO)

Decrease the number of parallel queries running in the warehouse

Correct selection
Increase the size of the virtual warehouse

Use the search optimization service

Correct selection
Split the data processing into several steps

Increase the value of the MAX_EXECUTION_TIME_IN_SECONDS parameter

Overall explanation
A few comments:

Since the data volume and complexity have significantly increased (more rows, more dimensions), a larger warehouse will provide more compute resources, reducing query and transformation time—especially since auto-scaling is restricted for cost control.

Breaking complex transformations (especially with many joins/aggregations) into intermediate steps or temp tables can improve query planning, intermediate caching, and parallelism, making execution more efficient.

Search optimization service is designed for filtering on selective columns.

MAX_EXECUTION_TIME_IN_SECONDS is not a correct parameter in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
An Architect is designing the security framework for an account to control user logins, authentication methods, and network rules.



In which order should the Architect evaluate the security policies?

1. Session Policies

2. Password Policies

3. Session Policies

4. Authentication Policies

1. Network Policies

2. Authentication Policies

3. Session Policies

4. Password Policies

Correct answer
1. Network Policies

2. Authentication Policies

3. Password Policies

4. Session Policies

1. Authentication Policies

2. Network Policies

3. Session Policies

4. Password Policies

Overall explanation
Security policies in Snowflake are evaluated in the following order:

Network policies – Control access by allowing or denying IP addresses, VPC IDs, and VPCE IDs.

Authentication policies – Manage client access, authentication methods, and security integrations.

Password policies (for local authentication) – Define password requirements such as length, complexity, expiration, retry limits, and lockout duration.

Session policies – Require users to re-authenticate after a period of inactivity.

For more detailed information, refer to the official Snowflake documentation.

Note:

In some occasions some questions we may find them in drag&drop (interactive) format instead of choosing the correct option among the 4 possible options.

Due to Udemy's limitation of not being able to include this type of questions, we put it this way.

Question 20
Skipped
How can a Snowflake Architect allow unauthorized users to perform JOINS on protected columns in a SQL query?

Use external tokenization

Use secure functions

Correct answer
Use secure views

Use a separate Identity and Access Management (IAM) role

Overall explanation
A few comments:

Secure views allow the exposure of protected or sensitive data in a controlled way by abstracting access behind a view.

Unauthorized users can query or join data via the secure view without direct access to the underlying protected columns, ensuring data masking and access control.

Secure functions are not suitable for DML operations on datasets.

External tokenization deals with data protection at ingestion, not with query-time joins.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
A Data Architect needs to monitor data usage patterns, performance metrics, and query efficiency to optimize the data workloads in a Snowflake account. The Architect needs insights into long-running queries, frequently accessed tables, and warehouse resource utilization while also tracking user activities and ensuring compliance with governance policies.



Which combination of views should the Architect use to meet these requirements? (Select THREE).

SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES view to track dependencies between objects.
Use the SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY view to analyze historical storage usage across databases.
Use the SNOWFLAKE.ACCOUNT_USAGE.SCHEMA_PRIVILEGES view to ensure compliance with data governance policies.
Correct selection
Use the SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY view to monitor warehouse resource consumption.
Correct selection
Use the SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY view to track access patterns.
Correct selection
Use the SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY view to analyze query performance.
Overall explanation
We will need the following views:

QUERY_HISTORY. This view provides detailed information about query performance, including duration, users, and resource usage — ideal for identifying long-running or inefficient queries.

ACCESS_HISTORY. This view tracks which users accessed which data, helping to identify frequently accessed tables and support compliance/governance auditing.

WAREHOUSE_METERING_HISTORY. This shows warehouse usage metrics like compute credits used, allowing analysis of resource utilization for workload optimization.

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
How can an Architect enable optimal clustering to enhance performance for different access paths on a given table?

Create multiple clustering keys for a table

Correct answer
Create multiple materialized views with different cluster keys

Create super projections that will automatically create clustering

Create a clustering key that contains all columns used in the access paths

Overall explanation
A few comments:

Snowflake only supports one clustering key per table, so you cannot optimize for multiple access patterns directly on the base table.

To support multiple access paths, the best practice is to create multiple materialized views, each clustered on a different key aligned with a specific query pattern.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
An Architect uses an ETL tool to transform data where intermediate results are unloaded into temporary internal stages. The Architect wants to apply the principle of least privilege with the fewest amount of operational overhead in their new solution to continue functioning.



Which action will meet these requirements?

Set PREVENT_UNLOAD_TO_INLINE_URL = FALSE at the session level

Set PREVENT_UNLOAD_TO_INTERNAL_STAGES = FALSE at the session level

Set PREVENT_UNLOAD_TO_INLINE_URL = FALSE at the user level

Correct answer
Set PREVENT_UNLOAD_TO_INTERNAL_STAGES = FALSE at the user level

Overall explanation
A few comments:

It is important to know these parameters to control the information that is extracted to Stages from Snowflake.

Both the PREVENT_UNLOAD_TO_INTERNAL_STAGES parameter and the PREVENT_UNLOAD_TO_INLINE_URL parameter exist, but one refers to the INTERNAL STAGE and the other to the EXTERNAL STAGE.

Both parameters can be defined at account and user level.

If we want to reduce the operational overhead, it is better to define it at user level.

For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
Which functions does the Data Build Tool (dbt) facilitate? (Select TWO)

Correct selection
Data testing

Correct selection
Data transformation

Data replication

Data visualization

Data loading

Overall explanation
This question is not directly related to Snowflake, but is about a relevant tool in the market with great synergy with Snowflake (besides being partners).

As architects, it is common that we know how to solve scenarios that go beyond Snowflake and this question is a clear example of that.

A few comments:

dbt's functionality revolves around transforming data in your data warehouse. It allows us to write SQL-based transformation code and manage dependencies between transformations.

dbt provides built-in testing capabilities. We can define tests to validate the quality and integrity of your transformed data. These tests can be run as part of your dbt pipeline.

dbt itself does not handle the initial loading of data into your data warehouse. It only focuses on the T of the ELT paradigm.

For more detailed information, refer to the official dbt documentation.

Question 25
Skipped
A company is implementing a machine learning use case on a very large data set which will require high volumes of memory and compute resources.



How should this Snowflake architecture be designed to meet these requirements?

Correct answer
Use a Snowpark-optimized virtual warehouse

Use a standard multi-cluster virtual warehouse in maximized mode

Use a standard virtual warehouse with the query acceleration service implemented

Use a standard virtual warehouse with the search optimization service implemented

Overall explanation
Snowpark-optimized warehouses are ideal for executing Snowpark workloads that demand significant memory or rely on a specific CPU architecture. Typical examples include machine learning (ML) model training within a stored procedure running on a single virtual warehouse node.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
A Snowflake Architect is setting up database replication to support a disaster recovery plan. The primary database has external tables.



How should the database be replicated?

Correct answer
Replicate the database, external tables will be skipped.

Share the primary database with an account in the same region that the database will be replicated to.

Replicate the database ensuring the replicated database is in the same region as the external tables.

Move the external tables to a database that is not replicated, then replicate the primary database.

Overall explanation
A few comments:

Customers can replicate across all regions within a region group.

External tables are not currently supported for replication.

Until early 2024, when replicating a database that contains an external table, the presence of the external table in the primary database would cause the replication to fail.

Since 2024 this behavior has changed and it is now possible to replicate databases containing external tables.

Replicating external tables is not possible right now.

If we try to replicate a database containing external tables, it will simply skip the tables of that type.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
A company is going to publish a personalized listing in the Snowflake Marketplace. The company will need to fulfill listing requests from customers whose data resides in other regions outside of the account region where the listing is located.



How should this be addressed?

Correct answer
Use Cross-Cloud Auto Fulfillment

Snowsight will automatically detect whether or not the target account is in a different region and enable auto-fulfillment

Use Secure Data Sharing with the customer for fulfillment

Set up replication of the data to the customer's region before fulfilling the request

Overall explanation
For personalized listings in the Snowflake Marketplace that need to fulfill requests from customers in different regions, Cross-Cloud Auto-Fulfillment is the recommended and proper solution.



Cross-Cloud Auto-Fulfillment automatically:

Synchronizes your data product across all required consumer regions.

Streamlines the provisioning and secure management of share areas.

Executes autonomous data replication to remote regions.

Enables consumers to access listings faster, eliminating manual setup or intervention.

For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
An Architect has designed a data pipeline that is receiving small CSV files from multiple sources. All of the files are landing in one location. Specific files are filtered for loading into Snowflake tables using the copy command. The loading performance is poor.



What changes can be made to improve the data loading performance?

Correct answer
Create a multi-cluster warehouse and merge smaller files to create bigger files.

Create a specific storage landing bucket to avoid file scanning.

Change the file format from CSV to JSON.

Increase the size of the virtual warehouse.

Overall explanation
A few comments:

Changing the file format doesn’t necessarily improve loading performance. CSV files are generally performant in Snowflake, and the issue is with file size rather than format.

Increasing the size of the warehouse doesn't solve the core problem of having many small files, although it will work better since we will have more threads in the warehouse to parallelize files.

Snowflake operates more efficiently with fewer, larger files, so relying solely on larger warehouse sizes won't address this inefficiency.

Question 29
Skipped
What Snowflake expenses may be incurred when using external functions? (Select TWO).

Cloud services compute

Correct selection
Data transfer

Data storage

External function serverless compute

Correct selection
Snowflake warehouse compute

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
An Architect is creating a new database role for a team of Data Analysts. The Architect is considering using the OR REPLACE keywords in the CREATE DATABASE ROLE command to ensure the role is created even if it already exists.



What should the Architect consider before using the OR REPLACE keywords?

The dropped database role cannot be recreated.

The database role can only be dropped by a user with a role that has the MANAGE GRANTS privilege.

The OR REPLACE keywords are unsupported when creating a database role.

Correct answer
Recreating a database role drops it from any shares that it is granted to.

Overall explanation
A few comments:

It is not recommended to use the OR REPLACE keywords when recreating a database role. This action first drops the role and then recreates it, which removes the role from any shares to which it was granted.

If a database role must be recreated, it must be granted to those shares again.

Data consumers who use a share that includes the database role should be notified. They will need to grant the database role to their own account roles again.

For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
A company is designing its serving layer for data that is in cloud storage. Multiple terabytes of the data will be used for reporting. Some data does not have a clear use case but could be useful for experimental analysis. This experimentation data changes frequently and is sometimes wiped out and replaced completely in a few days.



The company wants to centralize access control, provide a single point of connection for the end-users, and maintain data governance.



What solution meets these requirements while MINIMIZING costs, administrative effort, and development overhead?

Correct answer
Import the data used for reporting into a Snowflake schema with native tables. Then create views that have SELECT commands pointing to the cloud storage files for the experimentation data. Then create two different roles to match the different user personas, and grant these roles to the corresponding users.

Import all the data in cloud storage to be used for reporting into a Snowflake schema with native tables. Then create a role that has access to this schema and manage access to the data through that role.

Import all the data in cloud storage to be used for reporting into a Snowflake schema with native tables. Then create two different roles with grants to the different datasets to match the different user personas, and grant these roles to the corresponding users.

Import the data used for reporting into a Snowflake schema with native tables. Then create external tables pointing to the cloud storage folders used for the experimentation data. Then create two different roles with grants to the different datasets to match the different user personas, and grant these roles to the corresponding users.

Overall explanation
Key comments: multiple terabytes for reporting, some data for experimental analysis that changes frequently. Governance is required. Centralize access control.

A few comments:

We want to minimize costs and administrative effort.

Considering that there is a lot of data, to minimize the cost we would have to think about storing in Snowflake only the strictly necessary data.

Native tables will provide better performance than making queries from the External Stage. Native tables are ideal for reporting workloads: optimized for performance, governance, and frequent use.

SELECT queries can be pulled to an external stage. It will be cheaper than managing an external table with the partition, refresh or notification system.

Creating roles with appropriate grants satisfies the governance and centralized access control requirements.

Question 32
Skipped
A global company needs to securely share its sales and inventory data with a vendor using a Snowflake account.



The company has its Snowflake account in the AWS eu-west 2 Europe (London) region. The vendor's Snowflake account is on the Azure platform in the West Europe region. How should the company's Architect configure the data share?

Correct answer
1. Promote an existing database in the company's local account to primary.

2. Replicate the database to Snowflake on Azure in the West-Europe region.

3. Create a share and add objects to the share.

4. Add a consumer account to the share for the vendor to access.

1. Create a share.

2. Add objects to the share.

3. Add a consumer account to the share for the vendor to access.

1. Create a new role called db_share.

2. Grant the db_share role privileges to read data from the company database and schema.

3. Create a user for the vendor.

4. Grant the db_share role to the vendor's users.

1. Create a share.

2. Create a reader account for the vendor to use.

3. Add the reader account to the share.

Overall explanation
A few comments:

The vendor has a Snowflake account, so it is not necessary to use consumer accounts.

The vendor has an account in the same region but in a different cloud (Azure and AWS), so we will not be able to use Data Sharing directly.

Cross-cloud and cross-region data sharing cannot be achieved by simply creating a share and adding a consumer account. Data needs to be replicated to the vendor’s cloud and region first.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
A Data Architect is working to optimize the performance of end-users' queries about automobile shipment data for a portal web application that generates dashboards for different clients.



An internal team queries the information using order_date as a WHERE condition; the ingestion and natural clustering are performed in this column. However, the application recovers data using the client_id, warehouse, product_id, and destination_city. The Engineer needs to create materialized views with different cluster keys, and must choose two columns combined with client_id to optimize the first cluster key.



Which statements will provide all the information needed to select the MOST effective combination of columns to cluster? (Select TWO).

Correct selection
SELECT SYSTEMSCLUSTERING_DEPTH('shipments', '(client_id, warehouse, product_id));
SELECT SYSTEMSCLUSTERING_DEPTH('shipments', '(warehouse, product_id, destination_city)');
Correct selection
SELECT SYSTEMSCLUSTERING_DEPTH('shipments', '(client_id, destination_city, product_id));
SELECT SYSTEMSCLUSTERING_DEPTH('shipments');
SELECT SYSTEMSCLUSTERING_INFORMATION('shipments', 3);
Overall explanation
Key comment: The Architect needs to create materialized views with different cluster keys, and must choose two columns combined with client_id.

A few comments:

SYSTEM$CLUSTERING_INFORMATION returns detailed clustering stats, but we can't set specific column sets

SYSTEM$CLUSTERING_DEPTH function evaluates how well data is physically organized (clustered) with respect to specific columns.

Correct options both include client_id (a key access pattern in the application) combined with different candidate columns (warehouse, product_id, destination_city)

Question 34
Skipped
An Architect needs to improve the performance of reports that pull data from multiple Snowflake tables, join, and then aggregate the data. Users access the reports using several dashboards. There are performance issues on Monday mornings between 9:00am-11:00am when many users check the sales reports.



The size of the group has increased from 4 to 8 users. Waiting times to refresh the dashboards has increased significantly. Currently, this workload is being served by a virtual warehouse with the following parameters:



AUTO_RESUME = TRUE 
AUTO_SUSPEND = 60 
SIZE = Medium


What is the MOST cost-effective way to increase the availability of the reports?

Increase the warehouse to size Large and set auto_suspend = 600.

Use a multi-cluster warehouse in maximized mode with 2 size Medium clusters.

Correct answer
Use a multi-cluster warehouse in auto-scale mode with 1 size Medium cluster, and set min_cluster_count = 1 and max_cluster_count = 4.

Use materialized views and pre-calculate the data.

Overall explanation
A few comments:

Increasing the size of the warehouse would improve performance, but it’s less cost-effective because a larger warehouse would be more expensive than scaling out clusters temporarily.

Increasing auto_suspend to 600 seconds (10 minutes) could add extra cost even though it will improve the warehouse cache utilization.

Materialized views do not allow joins among other limitations.

Maximized mode runs all clusters simultaneously, which increases availability but lacks the flexibility of scaling down during off-peak hours. This approach would be more expensive than auto-scaling.

By setting different min_cluster_count and max_cluster_count, the system can scale up during high demand and scale down or even suspend when usage is low, which optimizes cost without sacrificing performance.

Question 35
Skipped
A company has implemented Snowflake replication between two Snowflake accounts, both of which are running on a Snowflake Enterprise edition. The replication is for the database APP_DB containing only one schema, APP_SCHEMA. The company's Time Travel retention policy is currently set for 30 days for both accounts. A Data Engineer has been asked to extend the Time Travel retention policy to 60 days on the secondary database only.



How can this requirement be met?

Set the data retention policy on the schemas in the secondary database to 60 days.

Correct answer
Set the data retention policy on the secondary database to 60 days.

Set the data retention policy on the primary database to 30 days and the schemas to 60 days.

Set the data retention policy on the primary database to 60 days.

Overall explanation
A few comments:

Time Travel and Fail-safe data in a secondary database are maintained separately and are not copied from the primary database.

Querying tables and views using Time Travel in a secondary database may yield different results than the same query in the primary database.

Additionally, explicitly set database-level parameters in a secondary database remain unchanged during replication. For instance, if DATA_RETENTION_TIME_IN_DAYS is set to 1 in the secondary database and 10 in the primary database, the secondary database retains its value of 1 after replication.

For more detailed information about Account Replication, refer to the official Snowflake documentation.

For more detailed information about database replication, refer to the official Snowflake documentation.

Question 36
Skipped
A Snowflake Architect anticipates that a table will contain several terabytes of data, and so defines a custom cluster key of three columns to optimize query performance. However, the table still takes a long time to query.



Why is this occurring?

Correct answer
The custom cluster key cardinality is too high.

The table needs to be manually re-clustered to partition the key.

The cluster key should not exceed two columns.

A multi-cluster virtual warehouse is not being used.

Overall explanation
A few comments:

The use of a MCW is not relevant when we want to use clustering.

The query indicates that the table has several terabytes and the cluster key is defined on 3 columns. This looks good.

From the available options, knowing that the conditions for clustering the table are good, we have to think that the cardinality of some of the columns we use in the cluster key is too high.

Question 37
Skipped
A retailer's enterprise data organization is exploring the use of Data Vault 2.0 to model its data lake solution. A Snowflake Architect has been asked to provide recommendations for using Data Vault 2.0 on Snowflake.



What should the Architect tell the data organization? (Select TWO).

Using the multi-table insert feature, multiple Point-in-Time (PIT) tables can be loaded sequentially from a single join query from the data vault.

Change data capture can be performed using the Data Vault 2.0 HASH_DELTA concept.

Correct selection
Using the multi-table insert feature in Snowflake, multiple Point-in-Time (PIT) tables can be loaded in parallel from a single join query from the data vault.

Correct selection
Change data capture can be performed using the Data Vault 2.0 HASH_DIFF concept.

There are performance challenges when using Snowflake to load multiple Point-in-Time (PIT) tables in parallel from a single join query from the data vault.

Overall explanation
In the Architect certification exams we can find some questions about modeling and in particular about Data Vault. It is not necessary to be an expert but it is recommended to be familiar with the main features of this modeling methodology.

A few comments:

Hashdiff represents the versions of a record. HDIFF is calculated by computing a hash value on all the meaningful columns in the table.

HASH_DELTA as a concept does not exist in DV.

Snowflake's SQL multi-table insert allows for you to insert data into multiple target tables in a single SQL statement in parallel from a single data source. It is very useful not only for loading PITs in parallel, but also for more DV entities.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
An Architect is investigating a performance issue with an existing architecture and found a query where the Query Profile indicates a high number of bytes spilled to remote storage. The query includes a WHERE clause that filters out a high percentage of records.



What actions can be taken to reduce the spillage to remote storage and improve the query performance? (Select TWO)

Increase the maximum number of clusters for the virtual warehouse

Decrease the data retention period for tables referenced by the query

Correct selection
Define a clustering key on columns used for selective filtering with a high clustering depth

Ensure primary keys and foreign keys are defined for large tables referenced by the query

Correct selection
Increase the size of the virtual warehouse

Overall explanation
A few comments:

A larger warehouse provides more memory, reducing the likelihood of spilling intermediate results to remote storage.

Define a clustering key on columns used for selective filtering with a high clustering depth will improve data pruning and efficiency, reducing the volume of data processed and cached in memory.

Other options do not directly impact memory usage or remote spilling during query execution.

Question 39
Skipped
A user is executing the following command sequentially within a timeframe of 10 minutes from start to finish:



use role sysadmin;
use warehouse compute_wh;
use schema sales.public;
create table t_sales (numeric integer) data_retention_time_in_days=1;
create or replace table t_sales_clone clone t_sales at (offset => -60*30);


What would be the output of this query?

Table T_SALES_CLONE successfully created.

Syntax error line 1 at position 58 unexpected 'at'.

Correct answer
Time Travel data is not available for table T_SALES.

The offset => is not a valid clause in the clone operation.

Overall explanation
A few comments:

The AT clause is valid in combination with offset when using Time Travel.

The use of => with offset is valid.

The statement will fail. Although we have defined a data_retention_time_in_days of 1, we are trying to retrieve the table with an offset of 60*30 (30 minutes). Assuming that the timeframe indicated by the query is 10 minutes, not enough time will have passed since its creation to retrieve that version. The requested time is either beyond the allowed time travel period or before the object creation time. The requested time is either beyond the allowed time travel period or before the object creation time.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
Which performance optimization techniques may impact storage costs? (Select TWO)

Correct selection
Using the search optimization service

Rewriting a query

Creating a multi-cluster virtual warehouse

Increasing the MIN_CLUSTER_COUNT in a multi-cluster virtual warehouse

Correct selection
Enabling Automatic Clustering

Overall explanation
A few comments:

Search Optimization Service, Query Acceleration Service and Clustering the Table have storage and compute costs.

For more detailed information, refer to the official Snowflake documentation.

Search optimization service creates additional data structures to accelerate selective query performance.

Clustering has an impact on storage by reordering micropartitions (also Time Travel cost).

Other options mainly affect compute performance or concurrency, not storage.

For more detailed information, refer to the official Snowflake documentation.

Question 41
Skipped
A company is trying to ingest 10 TB of CSV data into a Snowflake table as part of its migration from a legacy database platform. The records need to be ingested in the MOST performant and cost-effective way.



How can these requirements be met?

Use PURGE = FALSE in the copy into command.

Use on error = SKIP_FILE in the copy into command.

Correct answer
Use PURGE = TRUE in the copy into command.

Use ON_ERROR = continue in the copy into command.

Overall explanation
A few comments:

10TB would cost more than $200 in most Cloud storage systems, so the best option is to purge the files as they are ingested.

SKIP_FILE option is slower than either CONTINUE or ABORT_STATEMENT.

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
The company, myorg, has multiple Snowflake accounts. An Architect found one of the accounts, account1, does not have replication enabled.

Executing which query will enable replication on account1?DA. SELECT

SELECT SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER('myorg.account1', 'SYSTEM$DISABLE_DATABASE_REPLICATION', 'false');
Correct answer
SELECT SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER('myorg.account1', 'ENABLE_ACCOUNT_DATABASE_REPLICATION', 'true');
SYSTEM$DISABLE_DATABASE_REPLICATION('myorg.account1'), 'false';
SELECT SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER('myorg.account1', 'true');
Overall explanation
SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER enables replication and failover features for a specified account within an organization.

Once an organization administrator executes this function, the account gains access to the following features such as Replication and Client Redirect.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
Which combination of primary and secondary roles can a Snowflake user set in a session to access objects?

A session can have more than one active primary role at a time. Anyone with the active primary role can activate any number of secondary roles at the same time.

A session can have exactly one active primary role at a time. A secondary role cannot be activated anytime the primary role is active.

Correct answer
A session can have exactly one active primary role at any time. The user with the active primary role can activate any number of secondary roles at the same time.

A session can have more than one active primary role at a time. The user with the active primary role can activate exactly one secondary role at the same time.

Overall explanation
A few comments:

Only a single primary role can be active at a time in a user session.

A session can activate any number of secondary roles at the same time.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
Which Snowflake architecture recommendation needs multiple Snowflake accounts for implementation?

Enable zero-copy cloning among the development, test, and production environments.

Correct answer
Enable a disaster recovery strategy across multiple cloud providers.

Create external stages pointing to cloud providers and regions other than the region hosting the Snowflake account.

Enable separation of the development, test, and production environments.

Overall explanation
A few comments:

External stages can be set up to point to storage in other regions or providers without needing multiple Snowflake accounts.

Zero-copy cloning allows cloning within the same Snowflake account, enabling separation of environments without needing multiple accounts.

Separation of environments (development, test, production) can be achieved within a single Snowflake account by creating separate databases or schemas for each environment.

Implementing a disaster recovery (DR) strategy across multiple cloud providers requires setting up multiple Snowflake accounts because each Snowflake account is associated with a specific cloud provider and region.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
A global company wants to enable Snowflake access for region-specific groups of users based on the user's client IP addresses. The company needs to restrict or allow access to needed third-party outbound traffic from Snowflake to an external network destination.



How can an Architect accomplish this with the LEAST operational overhead?

1. Create a separate network rule for each group

2. Apply the network rule at the account level

1. Create a separate network policy for each group

2. Apply the network policy at the account level

Correct answer
1. Create a separate network rule for each group

2. Create a single network policy

3. Apply the network policy at the account level

1. Create a separate network policy for each user

2. Apply the network policy at the user level

Overall explanation
New questions about Network Rules and Policies are relevant. New network policies should use network rules instead of the ALLOWED_IP_LIST and BLOCKED_IP_LIST parameters to manage IP-based access. It is considered best practice not to combine both methods within a single policy.

The typical process for using network policies to manage inbound traffic involves:

Defining network rules according to their purpose and the type of network identifier.

Creating one or more network policies that incorporate these rules to specify which identifiers should be allowed or denied.

Activating the policy at the account, user, or security integration level — as network policies only take effect once they are enabled.

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Which command will create a schema without Fail-safe and will restrict object owners from passing on access to other users?

create schema EDW.ACCOUNTING WITH MANAGED ACCESS;
create TRANSIENT schema EDW.ACCOUNTING WITH MANAGED ACCESS DATA_RETENTION_TIME_IN_DAYS = 7;
create schema EDW.ACCOUNTING WITH MANAGED ACCESS DATA_RETENTION_TIME_IN_DAYS = 7;
Correct answer
create TRANSIENT schema EDW.ACCOUNTING WITH MANAGED ACCESS DATA_RETENTION_TIME_IN_DAYS = 1;
Overall explanation
A few comments:

The question asks us to create a schema that does not have Fail-Safe, so we discard queries that create permanent schemas.

To restrict the object owners to manage access, we have to create a schema WITH MANAGED ACCESS.

Transient schemas can only have a DATA_RETENTION_TIME_IN_DAYS of 0 or 1.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
A user has activated primary and secondary roles for a session.



What operation is the user prohibited from using as part of SQL actions in Snowflake using the secondary role?

Truncate

Correct answer
Create

Insert

Delete

Overall explanation
The authority to run CREATE <object> statements comes exclusively from the active primary role. When an object is created, ownership is assigned to that primary role. For all other SQL operations, permissions granted to either the active primary or any secondary roles can be used for authorization.

For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
A company needs to ensure that its analytics platform running on Snowflake can continue operating with minimal disruption in the event of a failure in the primary region. The solution should ensure real-time data availability across regions.



Which disaster recovery solution meets these requirements?

Use Time Travel to access historical data from another region when needed.

Schedule daily full backups of the database and restore them in another region in case of failure.

Correct answer
Implement database replication to replicate data across regions and configure automatic failover.

Use Cross-Cloud Auto Fulfillment to share data in real-time between regions.

Overall explanation
A few comments:

Database replication combined with automatic failover ensures data availability and minimal disruption during a regional failure. This approach allows a secondary region to take over seamlessly.

Cross-Cloud Auto Fulfillment is used for sharing listings.

Daily backups introduces significant recovery delays and is not real-time.

Time Travel is limited to the same region and is not a cross-region DR solution.

Question 49
Skipped
An Architect clones a database and all of its objects, including tasks. After the cloning, the tasks stop running.



Why is this occurring?

Correct answer
Cloned tasks are suspended by default and must be manually resumed.

Tasks cannot be cloned.

The Architect has insufficient privileges to alter tasks on the cloned database.

The objects that the tasks reference are not fully qualified.

Overall explanation
A few comments:

Cloned tasks are suspended by default when cloning a database or schema.

We have to manually resume them after cloning operation.

Tasks can be cloned.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
What are characteristics of Dynamic Data Masking? (Select TWO).

A masking policy that is currently set on a table can be dropped.

Correct selection
A masking policy can be applied to the VALUE column of an external table.

A single masking policy can be applied to columns with different data types.

Correct selection
A single masking policy can be applied to columns in different tables.

The role that creates the masking policy will always see unmasked data in query results.

Overall explanation
A few comments:

We can apply a masking policy to one or more table or view columns that have a matching data type.

When creating an external table with CREATE EXTERNAL TABLE, we cannot assign a masking policy to the VALUE column because it is automatically created by default. However, we can apply a masking policy to this column later using ALTER TABLE … ALTER COLUMN. The masking policy for the VALUE column must have a VARIANT data type.

Before dropping a policy, we need to unset it from the table or view column using ALTER TABLE … ALTER COLUMN or ALTER VIEW.

For more detailed information, refer to the official Snowflake documentation.