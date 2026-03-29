uestion 1
Skipped
MY_TABLE is a table that has not been updated or modified for several days. On 01 January 2021 at 07:01, a user executed a query to update this table. The query ID is '8e5d0ca9-005e-44e6-b858-a8f5b37c5726'. It is now 07:30 on the same day.



Which queries will allow the user to view the historical data that was in the table before this query was executed? (Select THREE).

SELECT * FROM my table PRIOR TO STATEMENT '8e5d0ca9-005e-44e6-b858-a8f5b37c5726';
SELECT * FROM TIME_TRAVEL ('MY_TABLE', 2021-01-01 07:00:00);
Correct selection
SELECT * FROM my_table AT (OFFSET => -60*30);
SELECT * FROM my table WITH TIME_TRAVEL (OFFSET => -60*30);
Correct selection
SELECT * FROM my_table AT (TIMESTAMP => '2021-01-01 07:00:00' :: timestamp);
Correct selection
SELECT * FROM my_table BEFORE (STATEMENT => '8e5d0ca9-005e-44e6-b858-a8f5b37c5726');
Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
A Data Engineer is implementing a near real-time ingestion pipeline to load data into Snowflake using the Snowflake Kafka connector. There will be three Kafka topics created.



Which Snowflake objects are created automatically when the Kafka connector starts? (Choose three.)

External stages

Correct selection
Tables

Materialized views

Correct selection
Internal stages

Tasks

Correct selection
Pipes

Overall explanation
The connector creates specific objects for each topic to facilitate data management. It sets up an internal stage to temporarily store data files associated with the topic. Additionally, it establishes a pipe to handle the ingestion of data files for each partition within the topic.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
When does auto-suspend occur for a multi-cluster virtual warehouse?

Auto-suspend does not apply for multi-cluster warehouses.

After a specified period of time when an additional cluster has started on the maximum number of clusters specified for a warehouse.

Correct answer
When the minimum number of clusters is running and there is no activity for the specified period of time.

When there has been no activity on any cluster for the specified period of time.

Overall explanation
A few comments:

Auto-suspend and auto-resume apply only to the entire warehouse and not to individual clusters within the warehouse.

In a multi-cluster warehouse:

Auto-suspend occurs only when the minimum number of clusters is running and there is no activity for the specified time period. The minimum is typically 1 cluster, but it could be more.

Auto-resume applies only when the entire warehouse is suspended (i.e., no clusters are running).

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
A new CUSTOMER table is created by a data pipeline in a Snowflake schema where MANAGED ACCESS is enabled.



Which roles can grant access to the CUSTOMER table? (Choose three.)

Correct selection
The role that owns the schema

The role that owns the CUSTOMER table

Correct selection
The USERADMIN role with the MANAGE GRANTS privilege

The role that owns the database

Correct selection
The SECURITYADMIN role

The SYSADMIN role

Overall explanation
A few comments:

In a managed access schema, object owners cannot grant privileges. Only the schema owner (the role with the OWNERSHIP privilege on the schema) or a role with the MANAGE GRANTS privilege can manage permissions on objects within the schema, including future grants, ensuring centralized privilege control.

The security administrator (SECURITYADMIN system role) has the global MANAGE GRANTS privilege, allowing them to grant or revoke privileges on objects across the account.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
If the query matches the definition, will Snowflake always dynamically rewrite the query to use a materialized view?

Correct answer
No, because the optimizer might decide against it.

No, because the materialized view may not be up-to-date.

No, because joins are not supported by materialized views.

Yes, because materialized views are always faster.

Overall explanation
A few comments:

A materialized view can query only a single table. Joins, including self-joins, are not supported.

It is not necessary to explicitly reference a materialized view in a SQL statement for it to be utilized. The query optimizer can automatically transform queries targeting the base table or standard views to leverage the materialized view instead.

However, even when a materialized view could substitute the base table in a given query, the optimizer may opt not to use it. For instance, if the base table is clustered by a specific column, the optimizer might prefer scanning the base table directly, as it can efficiently prune partitions and achieve comparable performance.

For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
A Data Engineer is working on a continuous data pipeline which receives data from Amazon Kinesis Firehose and loads the data into a staging table which will later be used in the data transformation process. The average file size is 300-500 MB.



The Engineer needs to ensure that Snowpipe is performant while minimizing costs.



How can this be achieved?

Change the file compression size and increase the frequency of the Snowpipe loads.

Increase the size of the virtual warehouse used by Snowpipe.

Correct answer
Decrease the buffer size to trigger delivery of files sized between 100 to 250 MB in Kinesis Firehose.

Split the files before loading them and set the SIZE_LIMIT option to 250 MB.

Overall explanation
Amazon Firehose lets you set a buffer size for file size and a buffer interval for file delivery. If your application generates large files quickly (300-500 MB), reducing the buffer size can help produce smaller files within Snowflake’s optimal ingestion range of 100-250 MB for better parallel processing. Keeping the buffer interval at 60 seconds prevents excessive file creation and latency.

For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
A Data Engineer is investigating a query that is taking a long time to return. The Query Profile shows the following:




What step should the Engineer take to increase the query performance?

Rewrite the query using Common Table Expressions (CTEs).

Correct answer
Increase the size of the virtual warehouse.

Change the order of the joins and start with smaller tables first.

Add additional virtual warehouses.

Overall explanation
The Query Profile shows 37.59 GB of data spilled to local storage, indicating that the query is exceeding the memory allocated to the virtual warehouse.

Increasing the virtual warehouse size provides more memory, reducing or eliminating spilling, which improves performance.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
A Data Engineer needs to create a sample of the table LINEITEM. The sample should not be repeatable and the sampling function should take the data by blocks of rows.



What select command will generate a sample of 20% of the table?

select * from LINEITEM tablesample block (20 rows);
select * from LINEITEM sample bernoulli (20);
Correct answer
select * from LINEITEM sample system (20);
select * from LINEITEM tablesample system (20) seed (1);
Overall explanation
A few comments:

The SYSTEM sampling method selects data by blocks of rows (micro-partitions), making it non-repeatable because partitions may change.

(20) means 20% of the table is sampled. This meets both conditions: non-repeatable and block-based selection.

BERNOULLI sampling selects rows individually, not by blocks.

SEED (1) makes the sample repeatable, which contradicts the requirement that the sample should not be repeatable.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
A Data Engineer executes a complex query and wants to make use of Snowflake’s query results caching capabilities to reuse the results.



Which conditions must be met? (Choose three.)

The USED_CACHED_RESULT parameter must be included in the query.

The query must be executed using the same virtual warehouse.

The results must be reused within 72 hours.

Correct selection
The table structure contributing to the query result cannot have changed.

Correct selection
The micro-partitions cannot have changed due to changes to other data in the table.

Correct selection
The new query must have the same syntax as the previously executed query.

Overall explanation
A few comments:

For all persisted query results, the cache remains valid for up to 24 hours.

The cache is retained as long as the table data used in the query remains unchanged.

The previous query's persisted result remains accessible.

Micro-partitions of the table must remain unaltered (e.g., no reclustering or consolidation due to data modifications).

By default, result caching is enabled but can be controlled at the account, user, or session level using the USE_CACHED_RESULT session parameter.

Query caching is independent of the Virtual Warehouse.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
Company A wants to share some data with Company B whose account is in the same region. The data that Company A would like to share is from two different databases in their account.



Which of the following will allow Company A to share the data with Company B?

Create a secure materialized view that selects data from both tables and share the view.

Create a standard view that selects data from both tables and share the standard view.

Create a single share that includes both databases.

Correct answer
Create two shares, one for each database.

Overall explanation
A few coments:

Snowflake data providers can share data across databases using secure views, which can reference objects from multiple databases within the same account.

Snowflake does not allow multiple databases in one share.

Standard views are not supported in data sharing; only secure views can be shared.

When using (secure) materialized views, joins are not supported.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
A company has many users in the role ANALYST who routinely query Snowflake through a reporting tool. The Data Engineer has noticed that the ANALYST users keep two small clusters busy all of the time, and occasionally they need three or four clusters of that size.



Based on this scenario, how should the Data Engineer set up a virtual warehouse to MOST efficiently support this group of users?

Create four virtual warehouses (sized Small through XL) and set them to auto-suspend and auto-resume. Have users in the ANALYST role select the appropriate warehouse based on how many queries are being run.

Correct answer
Create a multi-cluster warehouse with MIN_CLUSTERS set to 2. Set the warehouse to auto-resume and auto-suspend, and give USAGE privileges to the ANALYST role. Allow the warehouse to auto-scale.

Create a standard X-Large warehouse, which is equivalent to four small clusters. Set the warehouse to auto-resume and auto-suspend, and give USAGE privileges to the ANALYST role.

Create a multi-cluster warehouse with MIN_CLUSTERS set to 1. Give MANAGE privileges to the ANALYST role so this group can start and stop the warehouse, and increase the number of clusters as needed.

Overall explanation
In this scenario, a multi-cluster warehouse is the most efficient setup because it allows Snowflake to automatically scale up or down based on demand. Setting MIN_CLUSTERS to 2 ensures that at least two clusters are available to handle the typical load, while allowing the warehouse to auto-scale enables additional clusters (up to the maximum limit) to be added during peak times when more resources are needed. Auto-resume and auto-suspend ensure that resources are only used when necessary, optimizing cost and performance.

Question 12
Skipped
A Data Engineer executes the below query and notices that the execution takes longer than expected.



select col1, col3 from table1 where col2 > 1000;



Which statement displays the number of scanned micro-partitions?

select parse_json (select system$clustering_information ('table1',  '(col1, col3)')) : "total_partition_count";
select parse_json (select system$clustering_information ('table1',  '(col2)')) : "total_partition_count";
Correct answer
select parse_json (select SYSTEM$EXPLAIN_PLAN_JSON (last_query_id())) : "GlobalStats": "partitionsAssigned";
select parse_json (select SYSTEM$EXPLAIN_PLAN_JSON (last_query_id())) : "GlobalStats": "partitionsTotal";
Overall explanation
A few comments:

SYSTEM$EXPLAIN_PLAN_JSON(last_query_id()) function returns a JSON execution plan of the last query.

partitionsAssigned represents the number of micro-partitions scanned during query execution. This helps diagnose performance issues related to inefficient partition pruning.

partitionsTotal shows total partitions in the table, not how many were scanned.

For more detailed information about SYSTEM$EXPLAIN_PLAN_JSON, refer to the official Snowflake documentation.

For more detailed information about EXPLAIN_JSON, refer to the official Snowflake documentation.

For more detailed information about EXPLAIN, refer to the official Snowflake documentation.

Question 13
Skipped
A Data Engineer is trying to load the following rows from a CSV file into a table in Snowflake with the following structure:



 
The engineer is using the following COPY INTO statement:

copy into stgCustomer from @csv_stage/address.csv.gz file_format = (type = CSV skip_header = 1);



However, the following error is received:

Number of columns in file (6) does not match that of the corresponding table (3), use file format option error_on_column_count_mismatch=false to ignore this error File 'address.csv.gz', line 3, character 1 Row 1 starts at line 2, column "STGCUSTOMER"[6] If you would like to continue loading when an error is encountered, use other values such as 'SKIP_FILE' or 'CONTINUE' for the ON_ERROR option.



Which file format option should be used to resolve the error and successfully load all the data into the table?

FIELD_DELIMITER = ','

Correct answer
FIELD_OPTIONALLY_ENCLOSED_BY = '"'

ESCAPE_UNENCLOSED FIELD = '\\'

ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE

Overall explanation
A few comments:

The error occurs because commas inside the ADDRESS field are being treated as column delimiters.

Snowflake's CSV parser sees six columns instead of three due to these extra commas.

The correct way to handle this is to specify that fields enclosed in double quotes ("") should be treated as a single column.

We can use FIELD_OPTIONALLY_ENCLOSED_BY = '"' in the file format to solve this issue.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
A Data Engineer loads data into a staging table every day. Once loaded, users from several different departments perform transformations on the data and load it into different production tables.



How should the staging table be created and used to MINIMIZE storage costs and MAXIMIZE performance?

Create it as an external table, which will not incur Time Travel costs.

Create it as a permanent table with a retention time of 0 days.

Create it as a temporary table with a retention time of 0 days.

Correct answer
Create it as a transient table with a retention time of 0 days.

Overall explanation
A transient table is ideal for staging data because:

It does not incur Fail-safe costs, unlike permanent tables, which makes it more cost-efficient.

It supports Time Travel, which can be helpful during transformations, but the retention period can be set to 0 days to further reduce costs if Time Travel is not needed.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
Which methods can be used to create a DataFrame object in Snowpark? (Choose three.)

DataFrame.write()

Correct selection
session.table()

Correct selection
session.read.json()

session.jdbc_connection()

Correct selection
session.sql()

session.builder()

Overall explanation
A few comments:

session.read.json() for creating DataFrames from data stored in a stage.

session.sql() for creating a DataFrame from an SQL query.

session.table() for creating a DataFrame from data in a table.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
How can a Data Engineer return all the errors encountered during a previous file upload that used the COPY command?

Query the VALIDATE information schema view.

Query the VALIDATE account usage schema view.

Correct answer
Call the VALIDATE table function.

Call the VALIDATE_PIPE_LOAD table function.

Overall explanation
A few comments:

The VALIDATE function in Snowflake checks files loaded by a previous COPY INTO <table> command. It gives you a list of all the errors found, not just the first one. This is helpful for troubleshooting data loading issues.

Views and table functions in Snowflake's Information Schema don't have any delay, meaning they show you the latest information immediately.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
A Data Engineer has written a stored procedure that will run with caller's rights. The Engineer has granted ROLEA the right to use this stored procedure.



What is a characteristic of the stored procedure being called using ROLEA?

ROLEA will not be able to see the source code for the stored procedure, even though the role has usage privileges on the stored procedure.

The stored procedure will run in the context (database and schema) where the owner created the stored procedure.

Correct answer
If the stored procedure accesses an object that ROLEA does not have access to, the stored procedure will fail.

The stored procedure must run with caller's rights; it cannot be converted later to run with owner's rights.

Overall explanation
A few comments:

The stored procedure runs with caller's rights, meaning it executes using the privileges of the role that calls.

If ROLEA lacks the necessary privileges on an object accessed within the procedure, the execution will fail due to insufficient permissions.

A caller’s rights stored procedure runs with the caller's role privileges. If the caller lacks permission for an action, the procedure cannot execute it. For example, if the ROLEA role cannot delete from table, a procedure it calls cannot delete from it either.

ROLEA can see the procedure's source code unless it's a SECURE procedure.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
A Data Engineer is working on a Snowflake deployment in AWS eu-west-1 (Ireland). The Engineer is planning to load data from staged files into target tables using the COPY INTO command.



Which sources are valid? (Choose three.)

Internal stage on GCP us-central1 (Iowa)

Correct selection
External stage in an Amazon S3 bucket on AWS eu-west-1 (Ireland)

Correct selection
External stage on GCP us-central1 (Iowa)

Internal stage on AWS eu-central-1 (Frankfurt)

Correct selection
External stage in an Amazon S3 bucket on AWS eu-central-1 (Frankfurt)

SSD attached to an Amazon EC2 instance on AWS eu-west-1 (Ireland)

Overall explanation
A few comments:

With internal stages, we can't specify any location information because they are managed by Snowflake and do not require any external credentials or URLs.

Internal stages are created and managed by Snowflake.

An external stage references data files stored outside Snowflake, supporting cloud storage services such as Amazon S3 buckets, Google Cloud Storage buckets, and Microsoft Azure containers.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
What access control policy will be put into place when future grants are assigned to both database and schema objects?

Database privileges will take precedence over schema privileges.

Correct answer
Schema privileges will take precedence over database privileges.

An access policy combining both the database object and the schema object will be used, with the most restrictive policy taking precedence.

An access policy combining both the database object and the schema object will be used, with the most permissive policy taking precedence.

Overall explanation
If future grants are set for the same object type at both the database and schema levels within a database, the schema-level grants override the database-level grants, rendering the latter ineffective. This applies regardless of whether the privileges on future objects are assigned to the same role or different roles.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
A Data Engineer needs to ingest invoice data in PDF format into Snowflake so that the data can be queried and used in a forecasting solution.



What is the recommended way to ingest this data?

Correct answer
Create a Java User-Defined Function (UDF) that leverages Java-based PDF parser libraries to parse PDF data into structured data.

Use Snowpipe to ingest the files that land in an external stage into a Snowflake table.

Create an external table on the PDF files that are stored in a stage and parse the data into structured data.

Use a COPY INTO command to ingest the PDF files in an external stage into a Snowflake table with a VARIANT column.

Overall explanation
A few comments:

PDF files are not inherently structured like CSV or JSON. They contain formatting, layout, and embedded elements that make direct ingestion into a relational table challenging.

Java UDFs for parsing: Java UDFs in Snowflake allow you to use external libraries, such as PDF parsers. This enables you to write custom logic to extract the relevant data from the PDF files and transform it into a structured format suitable for loading into a table.

While you can load PDF data into a VARIANT column, this doesn't make the data readily usable for analysis. You'd still need to parse the VARIANT data to extract the information you need.

Snowpipe is great for automated ingestion, but it doesn't solve the core problem of parsing the PDF data.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
A large table with 200 columns contains two years of historical data. When queried, the table is filtered on a single day. Below is the Query Profile:






Using a size 2XL virtual warehouse, this query took over an hour to complete.



What will improve the query performance the MOST?

Increase the number of clusters in the virtual warehouse.

Increase the size of the virtual warehouse.

Correct answer
Add a date column as a cluster key on the table.

Implement the search optimization service on the table.

Overall explanation
A few comments:

The query filters on a single day, but a significant number of partitions are scanned (2.1M out of 2.95M), indicating poor clustering.

Adding a date column as a clustering key would improve partition pruning, reducing the number of scanned partitions.

Increasing the warehouse size or clusters would help with processing power but wouldn't reduce the scanned data significantly.

Question 22
Skipped
Which columns can be included in an external table schema? (Choose three.)

METADATA$ISUPDATE

Correct selection
METADATA$FILE_ROW_NUMBER

Correct selection
VALUE

Correct selection
METADATA$FILENAME

METADATA$EXTERNAL_TABLE_PARTITION

METADATA$ROW_ID

Overall explanation
These columns can be included in an external table schema. METADATA$FILE_ROW_NUMBER tracks the row number in the file, VALUE stores the actual content of the external data, and METADATA$FILENAME records the name of the file from which the data is being read.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
Which output is provided by both the SYSTEM$CLUSTERING_DEPTH function and the SYSTEM$CLUSTERING_INFORMATION function?

notes

Correct answer
average_depth

average_overlaps

total_partition_count

Overall explanation
For more detailed information about SYSTEM$CLUSTERING_INFORMATION function, refer to the official Snowflake documentation.

For more detailed information about SYSTEM$CLUSTERING_DEPTH function, refer to the official Snowflake documentation.

Question 24
Skipped
A database contains a table and a stored procedure defined as:



CREATE OR REPLACE TABLE log_table(col1 VARCHAR);
 
CREATE OR REPLACE PROCEDURE insert_log(input VARCHAR)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
RETURNS NULL ON NULL INPUT
AS
$$
    var rs = snowflake.execute({sqlText: 'INSERT INTO log_table(col1) VALUES (?)', binds: [INPUT]});
    return 1;
$$;


The log_table is initially empty and a Data Engineer issues the following command:



CALL insert_log(NULL::VARCHAR);



No other operations are affecting the log_table.

What will be the outcome of the procedure call?

The log_table contains one record and the stored procedure returned NULL as a return value.

The log_table contains one record and the stored procedure returned 1 as a return value.

Correct answer
The log_table contains zero records and the stored procedure returned NULL as a return value.

The log_table contains zero records and the stored procedure returned 1 as a return value.

Overall explanation
A few comments:

The procedure insert_log is defined with RETURNS NULL ON NULL INPUT. This means that if the input is NULL, the procedure does not execute and directly returns NULL.

Since CALL insert_log(NULL::VARCHAR); passes a NULL value, the procedure does not run the INSERT statement.

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
A Data Engineer has developed a dashboard that will issue the same SQL select clause to Snowflake every 12 hours.



How long will Snowflake use the persisted query results from the result cache, provided that the underlying data has not changed?

24 hours

12 hours

14 days

Correct answer
31 days

Overall explanation
Each time a query's persisted result is reused, Snowflake resets its 24-hour retention period, extending it up to a maximum of 31 days from the query's initial execution. After 31 days, the result is purged, and a new result is generated upon the next query execution.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
A company has implemented Snowflake replication between two Snowflake accounts, both of which are running on a Snowflake Enterprise edition. The replication is for the database APP_DB containing only one schema, APP_SCHEMA. The company's Time Travel retention policy is currently set for 30 days for both accounts. A Data Engineer has been asked to extend the Time Travel retention policy to 60 days on the secondary database only.



How can this requirement be met?

Correct answer
Set the data retention policy on the secondary database to 60 days.

Set the data retention policy on the primary database to 30 days and the schemas to 60 days.

Set the data retention policy on the schemas in the secondary database to 60 days.

Set the data retention policy on the primary database to 60 days.

Overall explanation
A few comments:

Time Travel and Fail-safe data in a secondary database are maintained separately and are not copied from the primary database.

Querying tables and views using Time Travel in a secondary database may yield different results than the same query in the primary database.

Additionally, explicitly set database-level parameters in a secondary database remain unchanged during replication. For instance, if DATA_RETENTION_TIME_IN_DAYS is set to 1 in the secondary database and 10 in the primary database, the secondary database retains its value of 1 after replication.

For more detailed information about Account Replication, refer to the official Snowflake documentation.

For more detailed information about database replication, refer to the official Snowflake documentation.

Question 27
Skipped
An upstream application from Snowflake generates a JSON sales receipt document, containing a receipt header and multiple line items. Thousands of receipts are collected in a few hundred files daily on cloud storage. A Data Engineer would like to regularly ingest these files into Snowflake for querying.



How should the Engineer load and transform the data in Snowflake?

In the INGEST command, extract all attributes from the JSON records, flatten the JSON and store the results directly in a structured SALES table.

Correct answer
Use Snowpipe to continuously load the data in a VARIANT column in a table. Create views and/or another table to structurate the data for efficient querying.

Have the upstream application process and split the sales receipt into separate files and then load each file into a Snowflake table with a VARIANT column.

In the INGEST command, first flatten and load the SALES table and then flatten and load the LINEITEMS table.

Overall explanation
A few comments:

Snowpipe is ideal for automated and continuous data ingestion from cloud storage. It will automatically detect new files as they arrive and load them into Snowflake.

Loading the JSON data into a VARIANT column provides flexibility.

Snowflake does not have an INGEST command.

Extracting and flattening the JSON during ingestion can be inefficient because:

Splitting the receipt into smaller files would certainly give concurrency problems and would be less efficient, as we would be further away from the ideal file upload size range in Snowflake.

Question 28
Skipped
A Data Engineer would like to create a new empty table CURRENT_STUDENT_COPY_DATA that has the same structure as the table CURRENT_STUDENT.



Which statement should the Engineer run?

Correct answer
CREATE TABLE current_student_copy_data LIKE current_student;
CREATE TABLE current_student_copy_data COPY current_student;
CREATE TABLE current_student_copy_data CLONE current_student;
CREATE TABLE current_student_copy_data CLONE current_student COPY_DATA = false;
Overall explanation
LIKE clause in a CREATE TABLE statement creates a new table with the same columns, data types, and constraints as the source table, but without copying any data.

For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
The following chart represents the performance of a virtual warehouse over time:






A Data Engineer notices that the warehouse is queueing queries. The warehouse is size X-Small, the minimum and maximum cluster counts are set to 1, the scaling policy is set to standard, and auto-suspend is set to 10 minutes.



How can the performance be improved?

Change the scaling policy to economy.

Correct answer
Change the cluster settings.

Increase the size of the warehouse.

Change auto-suspend to a longer time frame.

Overall explanation
Looking at the VWH performance graph we can draw some conclusions:

There is some queuing of queries, but it only lasts for about a 5-minute strip every hour or so.

The queuing is punctual and of a single query, it is not something generalized during all the time that the VWH is up.

The VWH is up continuously, so increasing the auto-suspend from 10 minutes would have no impact on the performance shown in the graph.

The VWH is currently in single cluster configuration. In addition, queuing lasts for 5 minutes, so an 'economy' scaling policy does not make sense if the maximum number of clusters is not changed beforehand.

Increasing the VWH size would improve queueing as queries would execute faster, but it is not the best way to address the problem as queueing is not pervasive. We would be paying at least double the credits to solve a problem that we only have for 5 minutes every hour.

The main way to address a query queuing problem is to use a multicluster VWH configuration.

Question 30
Skipped
A Data Engineer wants to create a new development database (DEV) as a clone of the permanent production database (PROD) There is a requirement to disable Fail-safe for all tables.



Which command will meet these requirements?

CREATE DATABASE DEV
CLONE PROD
FAIL_SAFE = FALSE;
CREATE DATABASE DEV
CLONE PROD;
Correct answer
CREATE TRANSIENT DATABASE DEV
CLONE PROD;
CREATE DATABASE DEV
CLOSE PROD
DATA_RETENTION_TIME_IN_DAYS = 0;
Overall explanation
Fail-safe cannot be explicitly disabled, but using a transient database (CREATE TRANSIENT DATABASE) ensures that Fail-safe is not enabled for tables.

For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
Which masking policy will mask a column whenever it is queried through a view owned by a role named MASKED_VIEW_ROLE?

Correct answer
create or replace masking policy maskstring as (val string) returns string -> 
case 
    when invoker_role() in ('MASKED_VIEW_ROLE') then '**' 
    else val 
end;
create or replace masking policy maskstring as (val string) returns string -> 
case 
    when array_contains('MASKED_VIEW_ROLE'::variant, parse_json(current_available_roles())) then '**' 
    else val 
end;
create or replace masking policy maskstring as (val string) returns string -> 
case 
    when is_role_in_session('MASKED_VIEW_ROLE') then '**' 
    else val 
end;
create or replace masking policy maskstring as (val string) returns string -> 
case 
    when current_role() in ('MASKED_VIEW_ROLE') then '********' 
    else val 
end;
Overall explanation
The invoker_role() function evaluates the role currently executing the query. In the context of secure views, the invoker role is the role that "owns" the view and executes the query on behalf of the user. By using invoker_role(), the masking policy dynamically applies masking whenever the query is executed by the MASKED_VIEW_ROLE.

For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
When querying a stream to do Change Data Capture (CDC), how would a Data Engineer identify the different types of changes in the data? (Select TWO)

To identity updates



SELECT * FROM <Stream Name>
WHERE METADATA$ACTION = 'DELETE' AND METADATA$ISUPDATE = 'True';
To identity inserts



SELECT * FROM <Stream Name>
WHERE METADATA$ACTION = 'INSERT' AND MEDATA$ISUPDATE = 'True';
To identity all changes



SELECT * FROM <Stream Name>
WHERE SYSTEM$STREAM_HAS_DATA = 'True';
Correct selection
To identify deletes.



SELECT * FROM <Stream Name>
WHERE METADATA$ACTION = 'DELETE' AND METADATA$ISUPDATE = 'False';
Correct selection
To identify inserts



SELECT * FROM <Stream Name>
WHERE METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = 'False';
Overall explanation
These metadata columns help you understand changes happening in a Snowflake stream:

METADATA$ACTION: Tells you what kind of change happened (INSERT or DELETE).

METADATA$ISUPDATE: Specifically flags updates. When a row is updated, it shows up in the stream as a DELETE followed by an INSERT, both with METADATA$ISUPDATE set to TRUE. This helps you track updates accurately.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
Which stages support external tables?

External stages only; only on the same region and cloud provider as the Snowflake account

Correct answer
External stages only; from any region, and any cloud provider

Internal stages only; within a single Snowflake account

Internal stages only; from any Snowflake account in the organization

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
A Data Engineer is querying a table stream and notices that it takes 10 minutes to return a result.



What will allow the query to return a QUICKER result, without changing the design?

Use an append only stream.

Correct answer
Schedule more frequent DML to run against the stream.

Increase the concurrency of the query using a multi-cluster warehouse.

Use aggregation to precompute the grouping and reduce the amount of data returned in the stream result.

Overall explanation
A few comments:

Append-only streams track only row inserts, ignoring updates and deletes (including truncates). They offer better query performance than standard streams and are ideal for ELT and similar workflows that rely solely on new row inserts.

Standard streams compare inserted and deleted rows to identify updates and deletions, while append-only streams return only newly added rows, making them significantly more efficient.

Using append-only streams will improve the performance of the Stream but it implies a design change

Last option will reduce the offset of the stream, therefore the quantity of data queried from the stream will be smaller and the query will return a quicker result.

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
The JSON below is stored in a VARIANT column named V in a table named jCustRaw:






Which query will return one row per team member (stored in the teamMembers array) along with all of the attributes of each team member?

SELECT 
    t2.name AS memberName,
    t2.registered AS registeredDttm,
    t2.age AS age,
    t2.eyeColor AS eyeColor
FROM 
    jCustRaw t1,
    LATERAL FLATTEN(t1.v) t2;
SELECT 
    v:teamMembers[0].name::varchar AS memberName,
    v:teamMembers[0].registered::timestamp AS registeredDttm,
    v:teamMembers[0].age::number AS age,
    v:teamMembers[0].eyeColor::varchar AS eyeColor
FROM 
    jCustRaw;
SELECT 
    v:teamMembers.name::varchar AS memberName,
    v:teamMembers.registered::timestamp AS registeredDttm,
    v:teamMembers.age::number AS age,
    v:teamMembers.eyeColor::varchar AS eyeColor
FROM 
    jCustRaw;
Correct answer
SELECT 
    t2.value:name::varchar AS memberName,
    t2.value:registered::timestamp AS registeredDttm,
    t2.value:age::number AS age,
    t2.value:eyeColor::varchar AS eyeColor
FROM 
    jCustRaw t1,
    LATERAL FLATTEN(input => t1.v:teamMembers) t2;
Overall explanation
lateral flatten function is used to "flatten" or expand the teamMembers array within the JSON data. It creates a separate row for each element in the array.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
When would a Data Engineer use TABLE with the FLATTEN function instead of the LATERAL FLATTEN combination?

When TABLE with FLATTEN is acting like a sub-query executed for each returned row.

When the LATERAL FLATTEN combination requires no other source in the FROM clause to refer to.

Correct answer
When TABLE with FLATTEN requires no additional source in the FROM clause to refer to.

When TABLE with FLATTEN requires another source in the FROM clause to refer to.

Overall explanation
LATERAL FLATTEN is used when we need to flatten a nested data structure (like an array or JSON) within a row and then join the flattened results with other columns from the same row. The LATERAL keyword is essential for referencing columns from the "outer" query within the flattening operation.

In other words, LATERAL is an optional keyword used to reference columns defined to the left of the LATERAL keyword within the FROM clause. LATERAL enables cross-referencing between the preceding table expressions and the function.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
What is a characteristic of the use of binding variables in JavaScript stored procedures in Snowflake?

All Snowflake first-class objects can be bound.

Users are restricted from binding JavaScript variables because they create SQL injection attack vulnerabilities.

Correct answer
Only JavaScript variables of type number, string, and SfDate can be bound.

All types of JavaScript variables can be bound.

Overall explanation
Binding a variable to a SQL statement enables using its value within the query, including NULL values. The variable’s data type must match its intended use, and only JavaScript types number, string, and SfDate are supported for binding.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
A secure function returns data coming through an inbound share.



What will happen if a Data Engineer tries to assign USAGE privileges on this function to an outbound share?

An error will be returned because only views and secure stored procedures can be shared.

An error will be returned because only secure functions can be shared with inbound shares.

Correct answer
An error will be returned because the Engineer cannot share data that has already been shared.

The Engineer will be able to share the secure function with other accounts.

Overall explanation
Secure functions can be shared, but Snowflake does not allow resharing of data that comes from an inbound share.

For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
Which functions will compute a 'fingerprint' over an entire table, query result, or window to quickly detect changes to table contents or query results? (Choose two.)

HASH(*)

HASH_AGG_COMPARE(*)

Correct selection
HASH_AGG(<expr>, <expr>)

Correct selection
HASH_AGG(*)

HASH_COMPARE(*)

Overall explanation
HASH_AGG generates a 64-bit signed hash value that represents an aggregate fingerprint of an unordered set of input rows. It calculates a unique identifier for an entire table, query result, or window, where any modification to the input is highly likely to alter the output. This makes it useful for efficiently detecting changes in table data or query results.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
A Data Engineer is evaluating the performance of a query in a development environment.






Based on the Query Profile, what are some performance tuning options the Engineer can use? (Choose two.)

Use a multi-cluster virtual warehouse with the scaling policy set to standard

Create indexes to ensure sorted access to data

Correct selection
Add a LIMIT to the ORDER BY if possible

Correct selection
Move the query to a larger virtual warehouse

Increase the MAX_CLUSTER_COUNT

Overall explanation
In the advanced Data Engineer certification it is quite normal to find questions based on Query Profile analysis and performance scenarios.

A few comments:

Multi-cluster warehouses help with concurrency (many users), not single query performance.

Snowflake does not support traditional indexes. It relies on clustering and metadata pruning.

Adding a LIMIT reduces the amount of data that needs sorting, improving performance. The question tells us that we are working in DEV, so using the LIMIT clause is a good option.

A larger warehouse provides more compute resources, reducing query execution time.

Question 41
Skipped
Which statements accurately describe Snowflake data sharing? (Select TWO)

Correct selection
The database shared with the consumer can contain secure views referencing other databases in Snowflake.

During the reader account creation process, the data provider must specify the Snowflake edition.

The consumer of the reader account can perform DML on the shared database.

Correct selection
Resource monitors are used to limit the credits consumed by a reader account's virtual warehouse.

Reader accounts are billed separately for usage incurred by the consumer account.

Overall explanation
A few comments:

Snowflake data providers can use secure views to share data across multiple databases. These views can reference schemas, tables, and other views within databases that belong to the same account.

DML in shared database is not possible

It is not necessary to specify the Snowflake edition during creation process

The provider account creates, owns, and manages the reader account, covering all credit charges generated by its users.

Resource monitors limit the credits used by a reader account's virtual warehouse, ensuring fair usage and preventing excessive consumption.

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
Company A uses Snowflake to manage audio files of call recordings. Company A hired Company B, who also uses Snowflake, to transcribe the audio files for further analysis.



Company A's Data Engineer created a share.



What object should be added to the share to allow Company B access to the files?

A secure view with a column for file URLs.

A secure view with a column for METADATA$FILENAME.

Correct answer
A secure view with a column for pre-signed URLs.

A secure view with a column for the stage name and a column for the file path.

Overall explanation
First, we use the CREATE SECURE VIEW command to generate a secure view from unstructured data stored on a stage. This view enables us to access query results as if they were a table, ensuring data privacy through its secure designation.

We can grant data consumers access to either scoped or pre-signed URLs from the secure view. Scoped URLs offer enhanced security, while pre-signed URLs allow access without requiring authorization or authentication.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
Data from an event log application, generating heavily nested JSON, is streaming into Snowflake for security analytics.



What is best practice for optimizing performance on semi-structured workloads on Snowflake?

Specify the schema of the load during ingestion while storing the log import date in a VARIANT column.

Use external tables and execute queries directly on cloud storage without ingesting the data.

Correct answer
Extract and store the timestamp from the log into a separate column for better pruning, while storing the JSON log in a VARIANT column.

Put a structured view on top of the semi-structured table.

Overall explanation
For mostly regular data using native types, storage and query performance are similar between relational columns and VARIANT. However, for better pruning and reduced storage, it's recommended to extract OBJECT fields and key data into relational columns if the data includes dates, timestamps, numbers stored as strings or arrays.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
A stream called TRANSACTIONS_STM is created on top of a TRANSACTIONS table in a continuous pipeline running in Snowflake. After a couple of months, the TRANSACTIONS table is renamed TRANSACTIONS_RAW to comply with new naming standards.



What will happen to the TRANSACTIONS_STM object?

Reading from the TRANSACTIONS_STM stream will succeed for some time after the expected STALE_TIME.

TRANSACTIONS_STM will be stale and will need to be re-created.

Correct answer
TRANSACTIONS_STM will keep working as expected.

TRANSACTIONS_STM will be automatically renamed TRANSACTIONS_RAW_STM.

Overall explanation
Changing the name of a source object does not disrupt a stream or make it stale. Additionally, if a source object is deleted and a new one is created with the same name, any streams associated with the original object will not be connected to the new one.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
The following is returned from SYSTEM$CLUSTERING_INFORMATION() for a table named ORDERS with a DATE column named O_ORDERDATE:






What does the total_constant_partition_count value indicate about this table?

Correct answer
The table is clustered very well on O_ORDERDATE, as there are 493 micro-partitions that could not be significantly improved by reclustering.

The data in O_ORDERDATE has a very low cardinality, as there are 493 micro-partitions where there is only a single distinct value in that column for all rows in the micro-partition.

The data in O_ORDERDATE does not change very often, as there are 493 micro-partitions containing rows where that column has not been modified since the row was created.

The table is not clustered well on O_ORDERDATE, as there are 493 micro-partitions where the range of values in that column overlap with every other micro-partition in the table.

Overall explanation
A few comments:

Most of the micropartitions have an average_depth of 1, which means that the table is well clustered.

The total_constant_partition_count parameter indicates the total number of micro-partitions where the specified columns have reached a stable state, meaning reclustering will provide little benefit.

A higher number of constant micro-partitions improves query pruning, allowing more micro-partitions to be excluded from queries, which enhances performance.

It would be great if all the tables we came across offered such clean clustering and pruning opportunities :)

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Which query will show a list of the 20 most recent executions of a specified task, MYTASK, that have been scheduled within the last hour that have ended or are still running?

Correct answer
select * from table (information_schema.task_history(scheduled_time_range_start
=>dateadd('hour',-1,current_timestamp()), result_limit => 20,
task_name=>'MYTASK')) where query_id IS NOT NULL;
select * from table (information_schema.task_history(scheduled_time_range_end
=>dateadd('hour',-1,current_timestamp()), result_limit => 10,
task_name=>'MYTASK')) where STATE IN ('EXECUTING', 'SUCCEEDED')
select * from table (information_schema.task_history(scheduled_time_range_start
=>dateadd('hour',-1,current_timestamp()), result_limit => 20,
task_name=>'MYTASK')) where STATE IN ('EXECUTING', 'SUCCEEDED', 'FAILED')
select * from table (information_schema.task_history(scheduled_time_range_start
=>dateadd('hour',-1,current_timestamp()), result_limit => 20,
task_name=>'MYTASK'))
Overall explanation
To fetch only tasks that are either completed or currently running, the query should include a filter using WHERE query_id IS NOT NULL. However, this filter is applied after RESULT_LIMIT reduces the result set, meaning the query might return 9 tasks if 1 task was scheduled but hasn't started yet.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
A Data Engineer wants to check the status of a pipe named my_pipe. The pipe is inside a database named test and a schema named Extract (case-sensitive).



Which query will provide the status of the pipe?

SELECT SYSTEM$PIPE_STATUS("test.'extract'.my_pipe");
SELECT * FROM SYSTEM$PIPE_STATUS("test.'extract'.my_pipe");
Correct answer
SELECT SYSTEM$PIPE_STATUS('test."Extract".my_pipe');
SELECT * FROM SYSTEM$PIPE_STATUS('test."Extract".my_pipe');
Overall explanation
A few comments:

The SYSTEM$PIPE_STATUS function requires the fully qualified pipe name in single quotes.

Since Extract is case-sensitive, it must be enclosed in double quotes within the single-quoted string.

For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
A Data Engineer is evaluating a complex query using the EXPLAIN command. The GlobalStats operation indicates 500 partitionsAssigned.



The Data Engineer then runs the query to completion and opens the Query Profile. They notice that the partitions scanned value is 429.



Why might the actual partitions scanned be lower than the estimate from the EXPLAIN output?

Correct answer
Runtime optimizations such as join pruning can reduce the number of partitions and bytes scanned during query execution.

In-flight data compression will result in fewer micro-partitions being scanned at the virtual warehouse layer than were identified at the storage layer.

The GlobalStats partition assignment includes the micro-partitions that will be assigned for preservation of the query results.

The EXPLAIN results always include a 10-15% safety factor in order to provide conservative estimates.

Overall explanation
The values for partitions and bytes represent upper-limit estimates for query execution. However, runtime optimizations like join pruning can decrease the actual number of partitions and bytes scanned during execution.

EXPLAIN will take the metadata information (range & count) to determine the operations that snowflake would perform to execute the query.

For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
A Data Engineer ran a stored procedure containing various transactions. During the execution, the session abruptly disconnected, preventing one transaction from committing or rolling back. The transaction was left in a detached state and created a lock on resources.



What step must the Engineer take to immediately run a new transaction?

Correct answer
Call the system function SYSTEM$ABORT_TRANSACTION.

Set the LOCK_TIMEOUT to FALSE in the stored procedure.

Set the TRANSACTION_ABORT_ON_ERROR to TRUE in the stored procedure.

Call the system function SYSTEM$CANCEL_TRANSACTION.

Overall explanation
A few comments:

If a session disconnects abruptly while a transaction is running, the transaction remains in a detached state, along with any resource locks it holds.

To terminate a running transaction, the user who initiated it or an account administrator can use the SYSTEM$ABORT_TRANSACTION function.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
What is a characteristic of the use of external tokenization?

Secure data sharing can be used with external tokenization.

Correct answer
External tokenization allows the preservation of analytical values after de-identification.

Pre-loading of unmasked data is supported with external tokenization.

External tokenization cannot be used with database replication.

Overall explanation
External Tokenization allows accounts to replace sensitive data with tokens before loading it into Snowflake and restore the original data at query runtime.

For more detailed information about data loading with Snowpipe, refer to the official Snowflake documentation.

Question 51
Skipped
A row in a data file ends with the backslash (\) character.



What can be done to prevent this row and the next row from being loaded as a single row of data by the copy command?

Set the ESCAPE_UNENCLOSED_FIELD option to '\\'

Set the RECORD_DELIMITER option to NONE

Set the RECORD_DELIMITER option to '\'

Correct answer
Set the ESCAPE_UNENCLOSED_FIELD option to NONE.

Overall explanation
The default value of ESCAPE_UNENCLOSED_FIELD is set to '\\' and we can set this option to NONE to load the data with backslash into the Snowflake table.

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
A Data Engineer has created table t1 with one column c1 with datatype VARIANT: create or replace table t1 (c1 variant);



The Engineer has loaded the following JSON data set, which has information about 4 laptop models, into the table.






The Engineer now wants to query that data set so that results are shown as normal structured data. The result should be 4 rows and 4 columns, without the double quotes surrounding the data elements in the JSON data.



The result should be similar to the use case where the data was selected from a normal relational table t2, where t2 has string data type columns model_id, model, manufacturer, and model_name, and is queried with the SQL clause select * from t2;



Which select command will produce the correct results?

select value:model_id
     , value:model
     , value:manufacturer
     , value:model_name
from t1
   , lateral flatten(input => c1:device_model);
select model_id::string
     , model::string
     , manufacturer::string
     , model_name::string
from t1
   , lateral flatten(input => c1:device_model);
select value:model_id::string
     , value:model::string
     , value:manufacturer::string
     , value:model_name::string
from t1
   , lateral flatten(input => c1);
Correct answer
select value:model_id::string
     , value:model::string
     , value:manufacturer::string
     , value:model_name::string
from t1
   , lateral flatten(input => c1:device_model);
Overall explanation
A few comments:

One incorrect option applies lateral flatten to the entire JSON object (c1) instead of specifically targeting the device_model array, resulting in a NULL output.

Another incorrect option omits the value: keyword when accessing attributes within the flattened JSON objects, making the query invalid.

The final incorrect option does not cast the extracted attributes to the STRING data type, even though the question requires results without double quotes around the JSON data elements.

Question 53
Skipped
What is the purpose of the BUILD_STAGE_FILE_URL function in Snowflake?

It generates a staged URL for accessing a file in a stage.

Correct answer
It generates a permanent URL for accessing files in a stage.

It generates a temporary URL for accessing a file in a stage.

It generates an encrypted URL for accessing a file in a stage.

Overall explanation
Creates a Snowflake file URL for a staged file using the stage name and relative file path as inputs. This URL provides extended access to the file and does not expire.

For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
Which methods will trigger an action that will evaluate a DataFrame? (Choose two.)

DataFrame.random_split()

DataFrame.col()

Correct selection
DataFrame.show()

DataFrame.select()

Correct selection
DataFrame.collect()

Overall explanation
A DataFrame is lazily evaluated, meaning the SQL statement is not sent to the server until an action is performed. An action triggers the evaluation of the DataFrame and executes the corresponding SQL statement on the server.

For more detailed information about data loading with Snowpipe, refer to the official Snowflake documentation.

Question 55
Skipped
Which Snowflake objects does the Snowflake Kafka connector use? (Choose three.)

Storage integration

Correct selection
Internal table stage

Correct selection
Pipe

Serverless task

Internal user stage

Correct selection
Internal named stage

Overall explanation
The connector creates an internal stage for each topic to temporarily store data files, a pipe to ingest files for each topic partition, and a table to store the data for each topic. If a failure prevents data from loading, the connector moves the affected file to the table stage and generates an error message.

For more detailed information about data loading with Snowpipe, refer to the official Snowflake documentation.

For more detailed information about installing Kafka connector, refer to the official Snowflake documentation.

Question 56
Skipped
A retail store's application team needs to build a loyalty program for their customers. The customer table contains Personally Identificable Information (PII), and the application team's role is DEVELOPER.



CREATE TABLE customer_data ( 
customer_first_name string, 
customer_last_name string,
customer_address string, 
customer_email string,
... some other columns,
);


The application team would like to access the customer data, but the email field must be obfuscated



Which of the following will protect the sensitive information, while maintaining the usability of the data?

Use the CURRENT_ROLE and CURRENT_USER context functions to integrate with a secure view and filter the sensitive data.

Correct answer
Use the CURRENT_ROLE context function to integrate with a masking policy on the sensitive fields.

Create a view on the customer_data table to eliminate the email column by omitting it from the SELECT clause. Grant the role DEVELOPER access to the view.

Create a separate table for all the non-PIl columns and grant the role DEVELOPER accoss to the new table.

Overall explanation
A few comments:

By using the CURRENT_ROLE context function, the masking policy can be applied dynamically based on the role of the user accessing the data. The DEVELOPER role can be configured with a masking policy that obfuscates the email field, ensuring that the sensitive information remains protected. This approach allows the application team to access the customer data while preserving the usability of the remaining fields.

Removing the email column entirely from the view would restrict access to the field, making it inaccessible even if it is needed in a masked form. The goal is to obfuscate the email field, not eliminate it from access altogether.

Creating a separate table only for non-PII data is inefficient and complicates the data structure, as it would require additional joins to access the complete dataset. Additionally, it doesn't address the need to obfuscate the email field specifically while still providing access to other data.

Using CURRENT_USER along with a secure view doesn't specifically enforce a masking policy on the email field.

Question 57
Skipped
A table is loaded using Snowpipe and truncated afterwards. Later, a Data Engineer finds that the table needs to be reloaded, but the metadata of the pipe will not allow the same files to be loaded again.



How can this issue be solved using the LEAST amount of operational overhead?

Wait until the metadata expires and then reload the file using Snowpipe.

Set the FORCE=TRUE option in the Snowpipe COPY INTO command.

Modify the file by adding a blank row to the bottom and re-stage the file.

Correct answer
Recreate the pipe by using the CREATE OR REPLACE PIPE command.

Overall explanation
A few comments:

Enabling the FORCE = TRUE parameter ensures that all files are loaded, even if they were already loaded before and have not been modified since.

But FORCE is not a valid option for Snowpipe. This is a tricky question.

For more detailed information about creating pipes, refer to the official Snowflake documentation.

For more detailed information about data loading with Snowpipe, refer to the official Snowflake documentation.

Question 58
Skipped
A Data Engineer would like to define a file structure for loading and unloading data.



In which object can the file structure be defined?  (Select THREE)

COPY command

Correct selection
PIPE object

MERGE command

Correct selection
FILE FORMAT object

Correct selection
STAGE object

INSERT command

Overall explanation
To establish a file structure for loading and unloading data, we can use stages and file formats, which are named database objects that help simplify and optimize bulk data loading and unloading.

We can also use pipes to define a file structure, which are named database objects that define COPY statements for loading micro-batches of data using Snowpipe.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
A Data Engineer needs to load JSON output from some software into Snowflake using Snowpipe.



Which recommendations apply to this scenario? (Choose three.)

Load a single huge array containing multiple records into a single table row.

Correct selection
Ensure that data files are 100-250 MB (or larger) in size, compressed.

Correct selection
Extract semi-structured data elements containing null values into relational columns before loading.

Load large files (1 GB or larger).

Create data files that are less than 100 MB and stage them in cloud storage at a sequence greater than once each minute.

Correct selection
Verify each value of each unique element stores a single native data type (string or number).

Overall explanation
A few comments:

The number of parallel load operations cannot exceed the number of data files available for loading. To optimize parallel processing, it is recommended to generate compressed data files between 100 and 250 MB or larger.

Aggregating smaller files reduces processing overhead, while splitting larger files into multiple smaller ones helps distribute the workload efficiently across the compute resources of an active warehouse.

To minimize performance issues related to unextracted elements, extract semi-structured data containing "null" values into relational columns before loading. Additionally, ensure each unique element stores values using a single data type native to the format, such as strings or numbers in JSON.

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
A company has an extensive script in Scala that transforms data by leveraging DataFrames. A Data Engineer needs to move these transformations to Snowpark.



What characteristics of data transformations in Snowpark should be considered to meet this requirement? (Choose two.)

Correct selection
It is possible to join multiple tables using DataFrames.

User-Defined Functions (UDFs) are not pushed down to Snowflake.

Snowpark requires a separate cluster outside of Snowflake for computations.

Correct selection
Snowpark operations are executed lazily on the server.

Columns in different DataFrames with the same name should be referred to with squared brackets.

Overall explanation
A few comments:

When working with columns that share the same name in different DataFrame objects (e.g., during a join), we can use the DataFrame.col method to reference a specific column in each DataFrame.

To retrieve and manipulate data, we can use the DataFrame class. A DataFrame represents a relational dataset that is evaluated lazily, meaning execution occurs only when a specific action is triggered. Essentially, a DataFrame functions like a query that must be evaluated to access the data.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
When adding secure views to a share in Snowflake, which function is needed to authorize users from another account to access rows in a base table?

CURRENT_CLIENT

CURRENT_USER

CURRENT_ROLE

Correct answer
CURRENT_ACCOUNT

Overall explanation
When working with secure views in Secure Data Sharing, we can use the CURRENT_ACCOUNT function to restrict access, ensuring that only users from a specific account can  retrieve rows from the base table.

For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
An organization is interested in using the Kafka Connector for loading data into Snowflake. The team has the Kafka connector subscribed to a few Kafka topics, but the topics have not been mapped to Snowflake tables.



What is the expected Kafka connector behavior? (Select TWO)

The connector creates an external stage to temporarily store data files for each topic.

Correct selection
The connector creates a new table for each topic using the topic name.

Correct selection
The connector creates the columns RECORD_CONTENT and RECORD_METADATA in the target table.

The connector cannot load data until a Snowpipe is created for each partition.

The connector cannot load data until Kafka topics are mapped to the Snowflake tables.

Overall explanation
The connector creates specific objects for each topic to facilitate data management. It sets up an internal stage to temporarily store data files associated with the topic. Additionally, it establishes a pipe to handle the ingestion of data files for each partition within the topic.

For data storage, the connector ensures that each topic has a corresponding table. If the table does not exist, it is automatically created. If the table is already present, the connector adds the RECORD_CONTENT and RECORD_METADATA columns while verifying that all other columns are nullable. If any column is non-nullable, an error is triggered.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
Company A and Company B both have Snowflake accounts. Company A's account is hosted on a different cloud provider and region than Company B's account. Companies A and B are not in the same Snowflake organization.



How can Company A share data with Company B? (Choose two.)

Correct selection
Create a new account within Company A's organization in the same cloud provider and region as Company B's account. Use database replication to replicate Company A's data to the new account. Create a share within the new account, and add Company B's account as a recipient of that share.

Use database replication to replicate Company A's data into Company B's account. Create a share within Company B's account and grant users within Company B's account access to the share.

Correct selection
Create a share within Company A's account and add Company B's account as a recipient of that share through listing.

Create a share within Company A's account, and create a reader account that is a recipient of the share. Grant Company B access to the reader account.

Create a separate database within Company A's account to contain only those data sets they wish to share with Company B. Create a share within Company A's account and add all the objects within this separate database to the share. Add Company B's account as a recipient of the share.

Overall explanation
A few comments:

In order to use Direct Sharing with Company B, we need to enable Replication first as it is in another cloud and region.

Listings allow us to share data with users across different Snowflake regions and cloud providers without needing to handle manual replication.

A direct share enables data sharing with multiple accounts within the same Snowflake region.

For more detailed information about Data Sharing across regions, refer to the official Snowflake documentation.

For more detailed information about Listing, refer to the official Snowflake documentation.

Question 64
Skipped
A table is loaded using Snowflake Connector for Kafka



What will happen if the file cannot be loaded?

The Kafka Connector moves files it cannot load to the stage associated with the user loading the target table

The Kafka Connector deletes the files that cannot be loaded

The Kafka Connector loads the files to an error table with the columns RECORD_CONTENT and RECORD_METADATA

Correct answer
The Kafka Connector moves files it cannot load to the stage associated with the target table

Overall explanation
When a table is loaded using the Snowflake Connector for Kafka and the file cannot be loaded, the Kafka Connector will move those files to the stage that is associated with the target table, allowing for further investigation or reprocessing of the files.

For more detailed information about the Kafka connector, refer to the official Snowflake documentation.

Question 65
Skipped
A company’s Snowflake account has multiple roles. Each role should have access only to data that resides in the given role's specific region.



When creating a row access policy, which code snippet below will provide privileges to the role ALL_ACCESS_ROLE to see all rows regardless of region, while the other roles can only see rows for their own regions?

create or replace row access policy region policy as (region_value varchar) returns boolean -> 
exists ( 
    select 1 from entitlement_table 
    where role = current_role() 
    and region = region_value 
)
create or replace row access policy region policy as (region_value varchar) returns boolean -> 
'ALL_ACCESS_ROLE' = current_role() 
and exists ( 
    select 1 from entitlement_table 
    where role = current_role() 
    and region = region_value 
)
Correct answer
create or replace row access policy region policy as (region_value varchar) returns boolean -> 
'ALL_ACCESS_ROLE' = current_role() 
or exists ( 
    select 1 from entitlement_table 
    where role = current_role() 
    and region = region_value 
)
create or replace row access policy region policy as (region_value varchar) returns boolean -> 
'ALL ACCESS ROLE' = current_role() 
Overall explanation
This is a typical example of the use of entitlement tables.

This policy grants access to all rows to the ALL_ACCESS_ROLE by checking if the current role is ALL_ACCESS_ROLE. If it is, the condition evaluates to true, allowing that role to see all rows. For other roles, the policy checks if the current_role() matches a row in an entitlement_table where the role's allowed region matches region_value, ensuring that other roles can only see rows corresponding to their specific regions.

For more detailed information, refer to the official Snowflake documentation.