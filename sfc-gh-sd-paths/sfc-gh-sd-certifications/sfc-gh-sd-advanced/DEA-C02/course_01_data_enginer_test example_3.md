A Data Engineer has created table t1 with DATA_RETENTION_TIME_IN_DAYS set to 7. There is a default stream s1 on table t1.



The parameter MAX_DATA_EXTENSION_TIME_IN_DAYS is set to 10 for table t1.



Based on these parameters, at MINIMUM, how frequently do the contents of stream s1 need to be consumed so that the stream does not become stale?

Correct answer
Every 10 days

Every 7 days

Every 3 days

Every 30 days

Overall explanation
A few comments:

A stream becomes stale when it can no longer track changes in the source table because the required historical data has been purged due to data retention policies.

In this case, the MAX_DATA_EXTENSION_TIME_IN_DAYS is set to 10.

The MAX_DATA_EXTENSION_TIME_IN_DAYS parameter provides a buffer beyond the table's data retention period to prevent streams from becoming stale.

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
A Snowflake Data Engineer is investigating why a query is not re-using the persisted result cache.



The Data Engineer found the two relevant queries from the SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY view:





Why is the second query re-scanning micro-partitions instead of using the first query's persisted result cache?

The queries are executed with two different virtual warehouses.

The second query includes a CURRENT_DATE() function.

The queries are executed with two different roles.

Correct answer
The second query includes a CURRENT_TIMESTAMP() function.

Overall explanation
The inclusion of CURRENT_TIMESTAMP() introduces variability into the query because the value returned by this function is different every time it is executed (it includes date and time down to the second). This difference in the query's text prevents Snowflake from using the persisted result cache, as the cache is matched based on identical query text and results.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
A company would like to get data from a Snowflake Marketplace provider for data enrichment purposes. A Data Engineer needs to build a data pipeline that would blend existing data in the company's account with the provider's data, with some transformations. The provider's data is not available in the region where the company account resides.



How can the Data Engineer make the data available to the company for processing?

Create a new reader account in the region where the provider's data is available and set up a copy job to unload data into a stage. Set up a data copy job between this stage and the company's stage. Then ingest the data into the company's account to transform and blend it with any existing data.

Create a new reader account in the region where the provider's data is available and set up a transformation job to unload transformed data into a stage. Set up a copy job between this stage and the company's stage and then ingest data into the company's account to blend with any existing data.

Create a new account in the region where the provider's data is available. Get data from the Marketplace, and create a share to the company's account. Then build a data pipeline to blend and transform the data .

Correct answer
Create a new account in the region where the provider's data is available. Get data from the Marketplace and replicate the data to the company's account. Then build a data pipeline to blend and transform the data.

Overall explanation
Provider's data is not available in the region where the company account resides, so we have to use Replication after getting data from the Marketplace.

For more detailed information about FUNCTIONS view, refer to the official Snowflake documentation.

Question 4
Skipped
A CSV file, around 1 TB in size, is generated daily on an on-premise server. A corresponding table, internal stage, and file format have already been created in Snowflake to facilitate the data loading process.



How can the process of bringing the CSV file into Snowflake be automated using the LEAST amount of operational overhead?

Correct answer
On the on-premise server, schedule a SQL file to run using SnowSQL that executes a PUT to push a specific file to the internal stage. Create a task that executes once a day in Snowflake and runs a COPY INTO statement that references the internal stage. Schedule the task to start after the file lands in the internal stage.

Create a task in Snowflake that executes once a day and runs a COPY INTO statement that references the internal stage. The internal stage will read the files directly from the on-premise server and copy the newest file into the table from the on-premise server to the Snowflake table.

On the on-premise server, schedule a SQL file to run using SnowSQL that executes a PUT to push a specific file to the internal stage. Create a pipe that runs a COPY INTO statement that references the internal stage. Snowpipe auto-ingest will automatically load the file from the internal stage when the new file lands in the internal stage.

On the on-premise server, schedule a Python file that uses the Snowpark Python library. The Python script will read the CSV data into a DataFrame and generate an INSERT INTO statement that will directly load into the table. The script will bypass the need to move a file into an internal stage.

Overall explanation
A few comments:

CSV file is on-premise, Snowflake cannot directly access it, so the file must first be uploaded to an internal stage via PUT command.

Snowpipe auto ingest does not work with internal stages. Snowpipe auto-ingest is only for external stages (e.g., S3, Azure Blob, GCS). With internal, we should call Snowpipe REST endpoints.

Using Snowpark Python for direct INSERT INTO on a 1 TB file would be inefficient. Snowflake's COPY INTO is the way to go.

Question 5
Skipped
A company is migrating a solution from a previous architecture that required particular fields to be viewable by various roles in the company. The previous architecture included multiple views that selected from the same table with different fields, according to the allowed roles.



Which Snowflake solution should be implemented using the LEAST operational effort?

Correct answer
Use Dynamic Data Masking.

Use internal tokenization policies.

Use row access policies.

Use materialized views for each role.

Overall explanation
Dynamic Data Masking in Snowflake allows you to define masking policies on columns, which can dynamically show or hide data based on the role of the user accessing the data. This eliminates the need to create multiple views for each role and significantly reduces operational overhead.

With a single table and masking policies in place, Snowflake automatically controls what each role can see, applying masking logic at query runtime.

For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
A company is using Snowpipe to bring in millions of rows every day of Change Data Capture (CDC) into a Snowflake staging table on a real-time basis. The CDC needs to get processed and combined with other data in Snowflake and land in a final table as part of the full data pipeline.



How can a Data Engineer MOST efficiently process the incoming CDC on an ongoing basis?

Schedule a task that dynamically retrieves the last time the task was run from information_schema.task_history and use that timestamp to process the delta of the new rows since the last time the task was run.

Use a CREATE OR REPLACE TABLE AS statement that references the staging table and includes all the transformation SQL. Use a task to run the full CREATE OR REPLACE TABLE AS statement on a scheduled basis.

Correct answer
Create a stream on the staging table and schedule a task that transforms data from the stream, only when the stream has data.

Transform the data during the data load with Snowpipe by modifying the related COPY INTO statement to include transformation steps such as CASE statements and JOINS.

Overall explanation
A few comments:

Streams in Snowflake are specifically designed for capturing and tracking changes in tables. By creating a stream on the staging table, we can efficiently capture the new CDC data as it arrives in real-time.

Tasks in Snowflake allow to schedule and automate SQL statements. We can create a task that processes the data from the stream, applying the necessary transformations and combining it with other data as needed.

Snowflake provides the SYSTEM$STREAM_HAS_DATA function, which allows to check if a stream has new data. We can use this function to ensure that the task only runs when there is new CDC data to process. This avoids unnecessary task executions and optimizes resource usage.

For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
Which Snowflake feature facilitates access to external API services such as geocoders, data transformation, machine learning models, and other custom code?

Security integration

Java User-Defined Functions (UDFs)

External tables

Correct answer
External functions

Overall explanation
External functions in Snowflake allow us to call external APIs and services from within our SQL queries. We can leverage functionalities like geocoding, machine learning models, and other custom code hosted outside of Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
What kind of Snowflake integration is required when defining an external function Snowflake?

HTTP integration

Correct answer
API integration

Notification integration

Security integration

Overall explanation
Key components:

External Function

Remote Service

Proxy Service

API Integration

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
Which system role is recommended for a custom role hierarchy to be ultimately assigned to?

ACCOUNTADMIN

SECURITYADMIN

Correct answer
SYSADMIN

USERADMIN

Overall explanation
Snowflake recommends creating a hierarchy of custom roles, with the top-most custom role assigned to the system role SYSADMIN

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
A large table with 200 columns contains two years of historical data. When queried, the table is filtered on a single day. Below is the Query Profile.






Using a size 2XL virtual warehouse, this query took over an hour to complete.



What will improve the query performance the MOST?

Implement the search optimization service on the table.

Increase the number of clusters in the virtual warehouse.

Correct answer
Add a date column as a cluster key on the table.

Increase the size of the virtual warehouse.

Overall explanation
A few comments:

Key comment on the question: the table is filtered on a single day.

Clustering on a relevant column, such as a date column in this case, can significantly improve query performance by reducing the amount of data that needs to be read from disk.

"Partitions scanned" is very high compared to the "Partitions total", suggesting that the query is not effectively pruning partitions.

Since the table contains two years of historical data and the query likely filters on a specific date or date range, clustering on the date column will allow Snowflake to quickly locate and read only the relevant data from disk, significantly reducing the amount of "Remote Disk I/O" and improving query performance.

Question 11
Skipped
A Data Engineer needs to know the details regarding the micro-partition layout for a table named Invoice using a built-in function.



Which query will provide this information?

CALL $CLUSTERING_INFORMATION('Invoice');
CALL SYSTEM$CLUSTERING_INFORMATION('Invoice');
SELECT $CLUSTERING_INFORMATION('Invoice');
Correct answer
SELECT SYSTEM$CLUSTERING_INFORMATION('Invoice');
Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 12
Skipped
What is a required property in the Kafka configuration file for either distributed or standalone mode?

snowflake.metadata.topic

snowflake.topic2table.map

Correct answer
value.converter

buffer.flush.time

Overall explanation
The value.converter property is required in the Kafka configuration file for both distributed and standalone mode. This property specifies the converter that Kafka Connect should use to deserialize message values before processing.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
A Data Engineer set up a continuous data pipeline using Snowpipe to load data into a table MYTABLE.



Which query will return all of the errors that have occurred in the last hour?

select * from information_schema.copy_history
where table_name='MYTABLE' and
start_time > DATEADD(hours, -1, current_timestamp());
Correct answer
select * from table(information_schema.copy_history(table_name=>'MYTABLE',
start_time=> DATEADD(hours, -1, current_timestamp())));
select * from information_schema.load_history
where table_name='MYTABLE' and
last_load_time > DATEADD(hours, -1, current_timestamp());
select * from table(information_schema.load_history(table_name=>'MYTABLE',
start_time=> DATEADD(hours, -1, current_timestamp())));
Overall explanation
A few comments:

COPY_HISTORY is a table function from the INFORMATION_SCHEMA. Correct table function syntax includes: table_name => 'MYTABLE',

start_time => DATEADD(...)

The LOAD_HISTORY view shows data loaded into tables with the COPY INTO <table> command over the past 14 days (with a limit of 10K rows), but not data loaded using Snowpipe.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
Which callback function is required within a Tabular JavaScript User-Defined Function (UDTF) for it to execute successfully?

finalize()
initialize()
handler()
Correct answer
processRow()
Overall explanation
For the UDTF to be valid, the JavaScript code must define a single literal JavaScript object that includes a callback function named processRow().

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
How can a clustering key definition be used to reduce the number of distinct values in a column that has high cardinality?

Define the key by using the CONCAT function on the column.

Define the key by using the SCAN function on the column.

Correct answer
Define the key as an expression on the column.

Define the key by using the TRIM function on the column.

Overall explanation
If a column has many unique values (high cardinality) and you want to use it as a clustering key, Snowflake suggests creating the key from an expression on that column instead of directly using the column itself. This helps reduce the number of distinct values. The expression you use should maintain the original order of the column's values, so that the minimum and maximum values in each data block (partition) can still be used to quickly filter data.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
For troubleshooting data loading history without row limitations, which Snowflake object can be used?

LOAD_HISTORY view

STAGE_DIRECTORY_FILE_REGISTRATION_HISTORY view

SYSTEM$PIPE_STATUS function

Correct answer
COPY_HISTORY view

Overall explanation
Key comment: no rows limitation.

The COPY_HISTORY view in Snowflake allows us to see data loading history for the past year (365 days). It includes activity from both COPY INTO <table> commands and continuous loading with Snowpipe. This view is better than LOAD_HISTORY because it doesn't have a limit of 10,000 rows.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
What will be the impact on the AUTO_REFRESH parameter if the ownership of an external table is transferred to different role?

The parameter value will be set as = TRUE by default.

The parameter will need to be reset.

The parameter will be deleted, and only a user with the ACCOUNTADMIN role will be able to re-establish it.

Correct answer
The parameter value will be set as = FALSE by default.

Overall explanation
When transferring ownership of an external table or its parent database using GRANT OWNERSHIP, the table's AUTO_REFRESH setting automatically becomes FALSE. This stops the automatic updates of the table's metadata. To re-enable these automatic refreshes after the ownership transfer, you must set AUTO_REFRESH = TRUE again, using the ALTER EXTERNAL TABLE command.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
A Data Engineer runs a query to achieve the union of data sets coming from multiple data sources. The query takes much more time to run than expected.



Using the Query Profile, the Engineer realized that the query used a UNION clause when a UNION ALL clause would have been sufficient.



Which Query Profile metric led the Engineer to identify why the query was running slowly?

Join

Correct answer
Aggregate

Filter

Pruning

Overall explanation
In SQL, we can combine two datasets using either UNION or UNION ALL. The key difference is that UNION ALL just stacks the inputs, while UNION also removes duplicates. In Snowflake’s Query Profile, this shows up as a UnionAll operator followed by an Aggregate operator, which handles the duplicate removal.

For more detailed information about external functions rules, refer to the official Snowflake documentation.

Question 19
Skipped
What are characteristics of Snowpark Python packages? (Choose three.)

Python packages can access any external endpoints.

Python packages can only be loaded in a local environment.

Correct selection
Third-party supported Python packages are locked down to prevent hitting.

Correct selection
The SQL command DESCRIBE FUNCTION will list the imported Python packages of the Python User-Defined Function (UDF).

Third-party packages can be registered as a dependency to the Snowpark session using the session.import() method.

Correct selection
Querying information_schema.packages will provide a list of supported Python packages and versions.

Overall explanation
A few comments:

We can use the DESCRIBE FUNCTION command to list the packages and modules a UDF or UDTF is using. For Python UDFs, this command also returns installed packages, the function signature, and the return type.

To see all available packages and their versions, we can query the PACKAGES view in the Information Schema:

For local development and testing, Anaconda provides a Snowflake conda channel that mirrors supported packages for Python UDFs.

Some packages are restricted within Snowflake UDFs due to execution constraints because UDFs are executed within a restricted engine.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
A Data Engineer defines the following masking policy:



CREATE MASKING POLICY name_policy AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_ROLE() IN ('ADMIN') THEN val
    ELSE '*****'
  END;


The policy must be applied to the full_name column in the customer table:



CREATE TABLE customer (
  first_name VARCHAR,
  last_name VARCHAR,
  full_name VARCHAR AS CONCAT(first_name, ' ', last_name)
);


Which query will apply the masking policy on the full_name column?

ALTER TABLE customer MODIFY COLUMN full_name
SET MASKING POLICY name_policy;
ALTER TABLE customer MODIFY COLUMN full_name
ADD MASKING POLICY name_policy;
Correct answer
ALTER TABLE customer MODIFY COLUMN
first_name SET MASKING POLICY name_policy,
last_name SET MASKING POLICY name_policy;
ALTER TABLE customer MODIFY COLUMN
first_name ADD MASKING POLICY name_policy,
last_name SET MASKING POLICY name_policy;
Overall explanation
A few comments:

A virtual column is like a regular column in a table, but its value is calculated using an expression.

This expression is defined when the column is created. In the example you provided, the full_name column is a virtual column because its value is derived by concatenating the first_name and last_name columns using the CONCAT function.

Queries with SET command have incorrect syntax.

For more detailed information about syntax, refer to the official Snowflake documentation.

For more detailed information about Dynamic Data Masking error messages, refer to the official Snowflake documentation.

Question 21
Skipped
A Snowflake user runs a complex SQL query on a dedicated virtual warehouse that reads a large amount of data from micro-partitions. The same user wants to run another query that uses the same data set.



Which action would provide optimal performance for the second SQL query?

Use the RESULT_SCAN function to post-process the output of the first query.

Assign additional clusters to the virtual warehouse.

Increase the STATEMENT_TIMEOUT_IN_SECONDS parameter in the session.

Correct answer
Prevent the virtual warehouse from suspending between the running of the first and second queries.

Overall explanation
When a virtual warehouse in Snowflake runs a query, the data cache stores the results and data retrieved from the micro-partitions. If the virtual warehouse suspends between the first and second queries, the cache is cleared, and the second query must re-read the data from the micro-partitions. Preventing the warehouse from suspending ensures the cache remains active, providing optimal performance for the second query.

To prevent the warehouse from suspending, we can set the AUTO_SUSPEND parameter to a sufficiently high value or disable auto-suspend altogether by setting it to 0 (not recommended for cost-efficiency).

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
What Snowflake expenses may be incurred when using external functions? (Select TWO).

External function serverless compute

Correct selection
Data transfer

Data storage

Cloud services compute

Correct selection
Snowflake warehouse compute

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
A Data Engineer is building a pipeline to transform a 1 TB table by joining it with supplemental tables. The Engineer is applying filters and several aggregations leveraging Common Table Expressions (CTEs) using a size Medium virtual warehouse in a single query in Snowflake.



After checking the Query Profile, what is the recommended approach to MAXIMIZE performance of this query if the Profile shows data spillage?

Enable clustering on the table.

Rewrite the query to remove the CTEs.

Switch to a multi-cluster virtual warehouse.

Correct answer
Increase the warehouse size.

Overall explanation
A few comments:

Data spillage in Snowflake occurs when a query requires more memory than is available in the virtual warehouse. This forces Snowflake to use local disk space, which is significantly slower than memory.

Increasing the warehouse size directly increases the amount of memory available for query processing. This can alleviate data spillage by providing enough memory to handle the query's intermediate data and operations.

Clustering can improve performance by organizing data based on a chosen key. However, it is not a direct solution for data spillage although in certain queries (e.g. filters) spilling could be reduced by improving the prunning of micro-partitions.

Question 24
Skipped
A company has several sites in different regions from which the company wants to ingest data.



Which of the following will enable this type of data ingestion?

The company must replicate data between Snowflake accounts.

The company should provision a reader account to each site and ingest the data through the reader accounts.

The company must have a Snowflake account in each cloud region to be able to ingest data to that account.

Correct answer
The company should use a storage integration for the external stage.

Overall explanation
With storage integrations, we can ingest data from various regions into a single, centralized Snowflake account. This simplifies data management and avoids the need for multiple accounts or data replication. It allows users to avoid supplying credentials when creating stages.

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
Assuming a Data Engineer has all appropriate privileges and context, which statements would be used to assess whether the User-Defined Function (UDF), MYDATABASE.SALES.REVENUE_BY_REGION, exists and is secure? (Select TWO).

SELECT IS_SECURE FROM SNOWFLAKE.INFORMATION_SCHEMA.FUNCTIONS WHERE FUNCTION_SCHEMA = 'SALES' AND FUNCTION_NAME = 'REVENUE_BY_REGION';
SHOW SECURE FUNCTIONS LIKE 'REVENUE_BY_REGION' IN SCHEMA SALES;
Correct selection
SHOW USER FUNCTIONS LIKE 'REVENUE_BY_REGION' IN SCHEMA SALES;
Correct selection
SELECT IS_SECURE FROM INFORMATION_SCHEMA.FUNCTIONS WHERE FUNCTION_SCHEMA = 'SALES' AND FUNCTION_NAME = 'REVENUE_BY_REGION';
SHOW EXTERNAL FUNCTIONS LIKE 'REVENUE_BY_REGION' IN SCHEMA SALES;
Overall explanation
For more detailed information about SHOW USER FUNCTIONS, refer to the official Snowflake documentation.

For more detailed information about FUNCTIONS view, refer to the official Snowflake documentation.

Question 26
Skipped
The following code is executed in a Snowflake environment with the default settings:



drop table customer; 
 
begin transaction;
 
create or replace table customer (
  id integer,
  name varchar(100)
);
 
insert into customer values (1,'John');
 
rollback;
 
select $1 from customer;


What will be the result of the select statement?

John

1John

SQL compilation error: Object 'CUSTOMER' does not exist or is not authorized.

Correct answer
1

Overall explanation
DDL statements in Snowflake are always their own transactions and auto-commit. If you run a DDL statement while another transaction is active, that transaction will be committed automatically. You can't roll back DDL statements. Any DML statement after a DDL statement starts a new transaction. Rollback won't have any effect.

The best way to test the answer is to run the code:


For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
The Query Profile is showing better micro-partition pruning than the EXPLAIN plan predicted.



What is a reason for this difference?

The EXPLAIN plan ignores the predicates and shows the full scan area for the query.

The EXPLAIN plan uses predictive analytics and takes into consideration the historical performance of similar queries.

Correct answer
The EXPLAIN plan does not consider any JOIN pruning that are in the query.

The EXPLAIN plan does not take into account any data caching on the virtual warehouse.

Overall explanation
The values for partitions and bytes represent upper-limit estimates for query execution. However, runtime optimizations like join pruning can decrease the actual number of partitions and bytes scanned during execution.

EXPLAIN will take the metadata information (range & count) to determine the operations that snowflake would perform to execute the query.

For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
Which use case would be BEST suited for the search optimization service?

Data Engineers who create clustered tables with frequent reads against clustering keys.

Correct answer
Business users who need fast response times using highly selective filters.

Data Scientists who seek specific JOIN statements with large volumes of data.

Analysts who need to perform aggregates over high-cardinality columns.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
A Data Engineer is troubleshooting a query with poor performance using the QUERY_HISTORY function. The Architect observes that the COMPILATION_TIME is greater than the EXECUTION_TIME.



What is the reason for this?

The query is reading from remote storage.

The query is processing a very large dataset.

The query is queued for execution.

Correct answer
The query has overly complex logic.

Overall explanation
Compilation time is the duration it takes to parse, optimize, and generate the execution plan for a query. Execution time is the duration it takes to actually run the query and produce results.

If the compilation time is greater than the execution time, it indicates that Snowflake spent a significant amount of time optimizing the query before execution. This often occurs when the query contains complex logic.

For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
A company built a sales reporting system with Python, connecting to Snowflake using the Python Connector. Based on the user's selections, the system generates the SQL queries needed to fetch the data for the report. First it gets the customers that meet the given query parameters (on average 1000 customer records for each report run), and then it loops the customer records sequentially. Inside that loop it runs the generated SQL clause for the current customer to get the detailed data for that customer number from the sales data table.



When the Data Engineer tested the individual SQL clauses, they were fast enough (1 second to get the customers, 0.5 second to get the sales data for one customer), but the total runtime of the report is too long.



How can this situation be improved?

Increase the number of maximum clusters of the virtual warehouse.

Increase the size of the virtual warehouse.

Correct answer
Rewrite the report to eliminate the use of the loop construct.

Define a clustering key for the sales data table.

Overall explanation
A few comments:

The primary bottleneck in the current approach is the sequential processing of customer records within the loop. This means that the system fetches data for one customer at a time, leading to a significant increase in the overall runtime: each query takes a short time to execute but in global we are executing 1000 queries with its compile time, execution time etc.

The solution is to apply a single query to the batch of 1000 customer records. This way we will only compile and execute one query, obtaining a much lower overall runtime.

Question 31
Skipped
A Data Engineer is working to optimize the performance of end-users' queries about automobile shipment data for a portal web application that generates dashboards for different clients.



An internal team queries the information using order_date as a WHERE condition; the ingestion and natural clustering are performed in this column. However, the application recovers data using the client_id, warehouse, product_id, and destination_city. The Engineer needs to create materialized views with different cluster keys, and must choose two columns combined with client_id to optimize the first cluster key.



Which statements will provide all the information needed to select the MOST effective combination of columns to cluster? (Select TWO).

Correct selection
SELECT SYSTEMSCLUSTERING_DEPTH('shipments', '(client_id, destination_city, product_id));
SELECT SYSTEMSCLUSTERING_INFORMATION('shipments', 3);
SELECT SYSTEMSCLUSTERING_DEPTH('shipments');
SELECT SYSTEMSCLUSTERING_DEPTH('shipments', '(warehouse, product_id, destination_city)');
Correct selection
SELECT SYSTEMSCLUSTERING_DEPTH('shipments', '(client_id, warehouse, product_id));
Overall explanation
Key comment: The Engineer needs to create materialized views with different cluster keys, and must choose two columns combined with client_id.

A few comments:

SYSTEM$CLUSTERING_INFORMATION returns detailed clustering stats, but we can't set specific column sets

SYSTEM$CLUSTERING_DEPTH function evaluates how well data is physically organized (clustered) with respect to specific columns.

Correct options both include client_id (a key access pattern in the application) combined with different candidate columns (warehouse, product_id, destination_city)

Question 32
Skipped
A Data Engineer enables a result cache at the session level with the following command:



ALTER SESSION SET USE_CACHED_RESULT = TRUE;



The Engineer then runs the following SELECT query twice without delay:



SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
SAMPLE(10) SEED (99);


The underlying table does not change between executions.



What are the results of both runs?

The first and second run returned different results, because the query is evaluated each time it is run.

Correct answer
The first and second run returned the same results, because the specific SEED value was provided.

The first and second run returned different results, because the query uses * instead of an explicit column list.

The first and second run returned the same results, because SAMPLE is deterministic.

Overall explanation
The SAMPLE clause with a specific SEED value makes the sampling deterministic.  This means that given the same table and the same seed, the SAMPLE clause will always return the same subset of rows.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
When working with semi-structured data in a VARIANT column, which Snowflake functions will allow a user to write queries that extract values using a hierarchy name? (Select TWO).

PARSE_JSON()
TO_ARRAY()
LATERAL FLATTEN
Correct selection
GET()
Correct selection
GET_PATH()
Overall explanation
GET_PATH is like GET, but it's used with VARIANT, OBJECT, or ARRAY columns. You give it the column name first, then tell it the "path" to the specific field or element you want to extract.

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
A Data Engineer is building a set of reporting tables to analyze consumer requests by region for each of the Data Exchange offerings annually, as well as click-through rates for each listing.



Which view is needed as data source?

SNOWFLAKE.DATA_SHARING_USAGE.LISTING_EVENTS_DAILY

SNOWFLAKE.DATA_SHARING_USAGE.LISTING_CONSUMPTION_DAILY

SNOWFLAKE.ACCOUNT_USAGE.DATA_TRANSFER_HISTORY

Correct answer
SNOWFLAKE.DATA_SHARING_USAGE.LISTING_TELEMETRY_DAILY

Overall explanation
This view contains all the columns necessary to analyze the requirements of the question:

We can count the number of REQUESTS through the EVENT_TYPE and ACTION fields.

We have information of the consumer's region, through the REGION_GROUP field.

And we can calculate click-through rates for each listing: get_request_completed / NULLIFZERO(listing_clicks)

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
The s1 schema contains two permanent tables that were created as shown below:



CREATE TABLE table_a (c1 INT)
DATA_RETENTION_TIME_IN_DAYS = 10;
CREATE TABLE table_b (c1 INT);


What will be the impact of running this command?



ALTER SCHEMA s1 SET DATA_RETENTION_TIME_IN_DAYS = 20;

The retention time on both tables will be set to 20 days.

Correct answer
The retention time on table_a will not change; table_b will be set to 20 days.

An error will be generated; data retention time cannot be set on a schema.

The retention time will not change on either table.

Overall explanation
If a table has an explicit DATA_RETENTION_TIME_IN_DAYS set during creation (like table_a), it retains that setting even when the schema's default is changed.

Tables without an explicit setting (like table_b) will inherit the schema's default.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
After executing the following commands:



CREATE OR REPLACE DATABASE MY_DB DATA_RETENTION_TIME_IN_DAYS=30; 
CREATE SCHEMA S1; 
CREATE OR REPLACE TABLE T1 (ID NUMBER) DATA_RETENTION_TIME_IN_DAYS = 20; 
CREATE OR REPLACE TABLE T2 (ID NUMBER) DATA_RETENTION_TIME_IN_DAYS = 40; 


What will be the DATA_RETENTION_TIME_IN_DAYS for the Schema and the two tables?

1 day for schema S1 (default value for the account), 30 days for table T1, and 40 days for table T2.

30 days for schema S1, 30 days for table T1, and 40 days for table T2.

Correct answer
30 days for schema S1, 20 days for table T1, and 40 days for table T2.

1 day for schema S1 (default value for the account), 20 days for table T1, and 40 days for table T2.

Overall explanation
According to Snowflake's inheritance rules for Time Travel data retention:

Database MY_DB is created with DATA_RETENTION_TIME_IN_DAYS=30

Schema S1 inherits the database retention time since no explicit value was specified. The documentation states: "If a retention period is specified for a database or schema, the period is inherited by default for all objects created in the database/schema."

Table T1 explicitly sets DATA_RETENTION_TIME_IN_DAYS = 20, which overrides the inherited value

Table T2 explicitly sets DATA_RETENTION_TIME_IN_DAYS = 40, which overrides the inherited value

When objects are created without specifying the DATA_RETENTION_TIME_IN_DAYS parameter, they inherit the retention period from their parent container (database for schemas, schema for tables). When explicitly specified, the parameter overrides the inherited default.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
Assuming that the session parameter USE_CACHED_RESULT is set to false, what are characteristics of Snowflake virtual warehouses in terms of the use of Snowpark?

Creating a DataFrame from a staged file with the read() method will start a virtual warehouse.

Transforming a DataFrame with methods like replace() will start a virtual warehouse.

Correct answer
Calling a Snowpark stored procedure to query the database with session.call() will start a virtual warehouse.

Creating a DataFrame from a table will start a virtual warehouse.

Overall explanation
A few comments:

Snowpark DataFrames are lazy—they only trigger execution when an action method is called.

Simply creating a DataFrame from a Snowflake table does not start a warehouse until an action (e.g., collect(), show()) is performed.

Transformations (e.g., .replace(), .filter(), .withColumn()) are lazy operations and do not trigger execution or start a warehouse. A warehouse is only started when an action (like collect()) is performed.

Calling a Snowpark stored procedure with session.call() triggers execution because the stored procedure itself runs a query or computation.

Stored procedures run SQL queries, which means they require a virtual warehouse to process the request.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
Which operation is allowed within a view query when establishing a stream on a view?

Correct answer
NATURAL JOIN

LIMIT

QUALIFY

GROUP BY

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
A table has these columns defined:



last_name VARCHAR(20),
first_name VARCHAR(20),
salary NUMBER(8,2)


A Data Engineer runs a bulk load of CSV files, compressed with ZSTD, using this command.



COPY INTO my_table
FROM @%my_table
FILE_FORMAT = (TYPE = CSV);


When the command completes, no records have been loaded.



What could cause this to occur? (Select TWO).

The values for salary in the data files are integers.

Correct selection
A last name exceeded 20 characters in one of the data files.

The STAGE_FILE_FORMAT on the table is set to type JSON.

Correct selection
Each of the input files has a single header line with the column names.

The file format does not specify that the ZSTD compression algorithm is being used.

Overall explanation
A few comments:

The column is defined as VARCHAR(20), so any value longer than 20 characters will cause the row to be rejected if we use the ON_ERROR option or it will cause the ingest to fail if we do not use it.

If the file has a header and we do not use the SKIP HEADER, having columns defined as numeric will cause the ingest to fail when trying to enter the column name string.

Integers are valid for a NUMBER(8,2) column.

If the COMPRESSION parameter is not specified in the FILE FORMAT, the default value is AUTO.

If COMPRESSION = AUTO, the compression algorithm is automatically detected.

COPY INTO command explicitly sets the file format to CSV. When file or copy format options are set in multiple places, Snowflake uses this order of precedence: COPY INTO TABLE statement > Stage definition > Table definition.

For more detailed information about COPY INTO command, refer to the official Snowflake documentation.

For more detailed information about data loading, refer to the official Snowflake documentation.

Question 40
Skipped
Which query will identify the specific days and virtual warehouses that would benefit from a multi-cluster warehouse to improve the performance of a particular workload?

Correct answer
SELECT TO_DATE(START_TIME) AS DATE,
       WAREHOUSE_NAME,
       SUM(AVG_RUNNING) AS SUM_RUNNING,
       SUM(AVG_QUEUED_LOAD) AS SUM_QUEUED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."WAREHOUSE_LOAD_HISTORY"
GROUP BY 1,2
HAVING SUM(AVG_QUEUED_LOAD) > 0;
SELECT TO_DATE(START_TIME) AS DATE,
       WAREHOUSE_NAME,
       BYTES_SCANNED,
       BYTES_SPILLED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY"
HAVING BYTES_SPILLED>BYTES_SCANNED;
SELECT TO_DATE(START_TIME) AS DATE,
       WAREHOUSE_NAME,
       BYTES_SPILLED_TO_LOCAL_STORAGE,
       SUM(AVG_QUEUED_LOAD) AS SUM_QUEUED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY"
HAVING BYTES_SPILLED_TO_LOCAL_STORAGE > 0;
SELECT TO_DATE(START_TIME) AS DATE,
       WAREHOUSE_NAME,
       BYTES_SCANNED,
       BYTES_SPILLED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."WAREHOUSE_LOAD_HISTORY"
HAVING BYTES_SPILLED>BYTES_SCANNED;
Overall explanation
To identify the specific days and virtual warehouses that would benefit from a multi-cluster warehouse to improve the performance of a particular workload, we should find those virtual warehouses with a significant queued load.

About the options:

With BYTES_SPILLED metric we can identify whether data is spilling to storage. This can have a negative impact on query performance (especially if the query has to spill to remote storage). To alleviate this, Snowflake recommends using a larger warehouse (Scaling up, not what the question is asking)

AVG_QUEUED_LOAD shows the value for queries queued because the warehouse was overloaded, thus the query must contain this metric

By grouping the results and filtering with HAVING SUM(AVG_QUEUED_LOAD) > 0, it highlights the days and virtual warehouses where there is a significant queued load. This indicates that these warehouses may benefit from a multi-cluster configuration to improve performance by handling more concurrent queries and reducing queuing times.

For more detailed information about reducing queues, refer to the official Snowflake documentation.

For more detailed information about WAREHOUSE_LOAD_HISTORY, refer to the official Snowflake documentation.

Question 41
Skipped
A Data Engineer wants to centralize grant management to maximize security. A user needs ownership on a table in a new schema. However, this user should not have the ability to make grant decisions.



What is the correct way to do this?

Grant ownership to the user on the table.

Correct answer
Add the with managed access parameter on the schema.

Revoke grant decisions from the user on the schema.

Revoke grant decisions from the user on the table.

Overall explanation
When we create a schema with the WITH MANAGED ACCESS option, we are able to centralize grant management for that schema. This means that even if a user has ownership on a table within that schema, they won't be able to grant access to other users unless they also have the MANAGE GRANTS privilege on the schema itself.

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
A Data Engineer needs to create a stage that will be used to ingest files from a Customer Relationship Management (CRM) system.



These are the requirements for the stage:

Use of an internal named stage with different folders that will be the repositories for the files

The files must be encrypted by the cloud service hosting the Snowflake account when they arrive on the stage

The files will be queried later using pre-signed URLs.

Ability to query a metadata list of all the unstructured files on the stage



Which statement will meet these requirements?

CREATE or REPLACE STAGE crm_files
ENCRYPTION = (TYPE = 'SNOWFLAKE_FULL' )
DIRECTORY = ( ENABLE = FALSE)
FILE_FORMAT = (TYPE = JSON)
COMPRESSION = AUTO;
CREATE or REPLACE STAGE crm_files 
URL's3://load/crm/files/'
STORAGE INTEGRATION = crm_int
ENCRYPTION = (TYPE = 'AWS_SSE_S3')
DIRECTORY = ( ENABLE = TRUE REFRESH_ON_CREATE = TRUE AUTO_REFRESH = TRUE) 
FILE_FORMAT = (TYPE = CSV );
Correct answer
CREATE or REPLACE STAGE crm_files
ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
DIRECTORY = ( ENABLE = TRUE REFRESH_ON_CREATE = TRUE) 
FILE_FORMAT = (TYPE = JSON );
CREATE or REPLACE STAGE crm_files
ENCRYPTION = (TYPE = 'SNOWFLAKE_FULL' )
DIRECTORY = ( ENABLE = TRUE REFRESH_ON_CREATE = TRUE)
FILE_FORMAT = (TYPE = CSV);
Overall explanation
Key comment: The files must be encrypted by the cloud service hosting the Snowflake account when they arrive on the stage

A few comments:

ENCRYPTION Parameter: Defines the encryption type for all files on a stage; cannot be changed after stage creation.

SNOWFLAKE_FULL: Provides both client-side (during PUT operation, default 128-bit key, configurable to 256-bit) and automatic AES-256 server-side encryption. This type is required for Tri-Secret Secure compliance.

SNOWFLAKE_SSE: Offers server-side encryption only, applied by the cloud service upon file arrival. Use this if you plan to query pre-signed URLs for staged files.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
A Data Engineer wants to use the SYSTEM$CLUSTERING_DEPTH system function to compute the average clustering depth of a table.



Which statements describe characteristics of this function? (Select TWO).

The bigger the average depth of a table, the better clustered the table will be with regards to the specified columns.

The average depth of a table, no matter if it is empty or contains data, is always 1 or more.

Correct selection
The column(s) argument can be used to calculate the depth for any columns in the table, regardless of the clustering key defined for the table.

Correct selection
The smaller the average depth of a table, the better clustered the table will be with regards to the specified columns.

A clustering key must be defined on the table, or an error will be returned.

Overall explanation
A few comments:

The SYSTEM$CLUSTERING_DEPTH function calculates the average depth of a table based on specific columns or the defined clustering key.

A populated table always has a depth of 1 or more. One option is incorrect because it mentions “no matter if it is empty or contains data".

The lower the depth, the better clustered the table is for the given columns.

We can use this function to measure clustering on any columns, not just the ones in the clustering key.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
An organization's sales team leverages this Snowflake query a few times a day:



SELECT CUSTOMER_ID, CUSTOMER_NAME, ADDRESS, PHONE_NO
FROM CUSTOMERS
WHERE LAST_UPDATED BETWEEN TO_DATE(CURRENT_TIMESTAMP) AND (TO_DATE(CURRENT_TIMESTAMP) - 7);


What can the Snowflake Data Engineer do to optimize the use of persisted query results whenever possible?

Assign everyone on the sales team to the same security role.

Correct answer
Leverage the CURRENT_DATE function for date calculations.

Assign everyone on the sales team to the same virtual warehouse.

Wrap the query in a User-Defined Function (UDF) to match syntax execution.

Overall explanation
A few comments:

Snowflake's Query Result Caching allows the results of a query to be reused if the query syntax and results remain the same.

Using functions like CURRENT_TIMESTAMP in the query introduces variability because CURRENT_TIMESTAMP includes time information (hour, minute, second, etc.), which prevents the query from being identical on subsequent executions.

By replacing CURRENT_TIMESTAMP with CURRENT_DATE, the query will produce consistent syntax and results when executed on the same day, enabling Snowflake to leverage the query result cache.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
A Data Engineer is planning to run a set of Data Metric Functions (DMFS) against a table using this query:



select snowflake.core.max(
select c_name from snowflake_sample_data.tpch_sf1.customer
);


When the query is run, an error is returned.



What is causing the error?

The SNOWFLAKE.CORE.MAX() function is not a valid Snowflake DMF.

Correct answer
The SNOWFLAKE.CORE.MAX() function cannot accept VARCHAR arguments.

snowflake_sample_data.tpch_sf1.customer is in a data share, which is not a valid source for DMFs.

DMFS can only be defined on a table, they cannot be executed as a SQL statement.

Overall explanation
When using this DMF, the referenced column in the query must have one of the following data types: FLOAT or NUMBER

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Database XYZ has the data_retention_time_in_days parameter set to 7 days and table XYZ.public.ABC has the data_retention_time_in_days set to 10 days.



A Developer accidentally dropped the database containing this single table 8 days ago and just discovered the mistake.



How can the table be recovered?

create table abc_restore clone xyz.public.abc at (offset => -3600*24*8);
create table abc_restore as select * from xyz.public.abc at (offset => -60*60*24*8);
Correct answer
Create a Snowflake Support case to restore the database and table from Fail-safe.

undrop database xyz;
Overall explanation
Currently, Snowflake doesn't honor custom data retention periods for schemas or tables when their parent database or schema is dropped. To ensure specific retention times for these child objects, drop them individually before dropping the parent database or schema.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
A Snowflake Data Engineer has created a secure User-Defined Function (UDF) to be used in a data share to maintain the privacy and security.



What can be said about the roles and privileges for this UDF?

Correct answer
The role that owns the secure UDF can see the function definition with the GET_DDL utility function.

The owner of the database can see the secure UDF listed in the FUNCTIONS information schema view.

Any role can see the secure UDF listed when executing the SHOW FUNCTIONS command

The role that owns the secure UDF can see the details of the secure UDF in the Query Profile.

Overall explanation
A few comments:

Secure functions and procedures in Snowflake have restricted access. Unauthorized users cannot view their definitions using commands like SHOW FUNCTIONS, DESCRIBE FUNCTION, SHOW PROCEDURES, or DESCRIBE PROCEDURE, nor through Information Schema views or the Query Profile.

Even owners of secure functions in Snowflake can't see the function's code in the Query Profile to prevent unauthorized access, as others might be able to view the owner's Query Profile.

For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
A Data Engineer needs to monitor the quality of hr.tables.employee_dim using a Data Metric Function (DMF).



Which DMF will return the percent of NULL values for the passport column in table employee_dim?

SELECT SNOWFLAKE.CORE.NULL_COUNT (SELECT passport FROM hr.tables.employee_dim)/100;
SELECT SNOWFLAKE.CORE.AVG(SELECT passport FROM hr.tables.employee_dim);
SELECT SNOWFLAKE.CORE.BLANK_COUNT (SELECT passport FROM hr.tables.employee_dim);
Correct answer
SELECT SNOWFLAKE.CORE.NULL_PERCENT (SELECT passport FROM hr.tables.employee_dim);
Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
A company has loaded the following JSON data into the CAR_SALES table and needs assistance loading the data into a VEHICLE_DIM dimension.



'{
  "customer": [
    { "address": "San Francisco, CA", "name": "Joyce Ridgely", "phone": "16504378889" }
  ],
  "vehicle": [
    {"extras": ["ext warranty","paint protection"],"make": "Honda", "model": "Civic", "price": "20275", "year": "2017"}
  ]
}',
'{
  "customer": [
    {"address": "New York, NY", "name": "Bradley Greenbloom", "phone": "12127593751" }
  ],
  "vehicle": [
    {"extras": ["ext warranty","rust proofing","fabric protection"],"make": "Toyota", "model": "Camry","price": "23500","year": "2017"}
  ]
}'


CAR_SALES

Name              Type

SRT                  VARIANT



VEHICLE_DIM

Name               Type

Make               VARCHAR(16777216)

Model              VARCHAR(16777216)

Price                NUMBER(18,2)



Which query will load the data into a VEHICLE_DIM?

INSERT INTO VEHICLE_DIM
SELECT
value:make::string AS MAKE,
value:model::string AS MODEL,
value:price::number (18, 2) AS PRICE,
ve.value::string as "Extras Purchased"
FROM
car_sales ve;
INSERT INTO VEHICLE_DIM
SELECT
vm.value:make::string AS MAKE,
vm.value:model::string AS MODEL,
vm.value:price::number (18, 2) AS PRICE,
ve.value::string as "Extras Purchased"
FROM
car_sales,
lateral flatten(input => srt:vehicle) vm,
lateral flatten(input => vm.value:extras) ve;
Correct answer
INSERT INTO VEHICLE_DIM
SELECT
value:make::string AS MAKE,
value:model::string AS MODEL,
value:price::number (18, 2) AS PRICE
FROM
car_sales
, lateral flatten (input => srt: vehicle);
INSERT INTO VEHICLE_DIM
SELECT
value:make::string AS MAKE,
value:model::string AS MODEL,
value:price::number (18, 2) AS PRICE
FROM
lateral flatten (input => srt: vehicle);
Overall explanation
A few comments:

We need to use the lateral flatten function to extract the data from the vehicle array within the JSON data. This way we can create a separate row for each vehicle object in the array.

LATERAL FLATTEN(input => srt:vehicle) is used to extract data from the nested vehicle array within the SRT column.

value:make::string, value:model::string, and value:price::number(18,2) correctly extract and cast the required fields.

The syntax correctly selects from car_sales and applies lateral flattening on the vehicle field, ensuring that each JSON object is processed properly.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
A Data Engineer needs to replicate an internal stage that contains several files that exceed 5 GB. The replication includes a directory table used to ensure that the file metadata is correctly synchronized.



What steps should the Engineer take to ensure successful replication of both the files and the directory table?

Create a new stage without a directory table and move all files to the new stage, then replicate the stage.

Refresh the directory table on the primary stage to ensure metadata consistency and replicate all files, including those exceeding 5 GB.

Correct answer
Disable the directory table, move the large files to another stage without a directory table, then re-enable the directory table before replication.

Increase the size limit of the directory table to accommodate files larger than 5 GB and proceed with replication.

Overall explanation
A few comments:

Directory table refreshes fail for files larger than 5GB on internal stages; move such files to another stage as a workaround.

Note that directory tables cannot be disabled on stages already part of replication.

If planning replication, we must first disable the directory table on the primary stage, move any oversized files, and then re-enable the directory table before adding the database to a replication or failover group.

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
In which scenario will use of an external table simplify a data pipeline?

When accessing a Snowflake table from a relational database

Correct answer
When accessing a Snowflake table that references data files located in cloud storage

When continuously writing data from a Snowflake table to external storage

When accessing a Snowflake table from an external database within the same region

Overall explanation
A few comments:

External tables in Snowflake allow referencing data in cloud storage (e.g., Amazon S3, Azure Blob Storage, or Google Cloud Storage) without importing it. This is useful when:

Querying data directly from cloud storage is needed without ingestion or ETL.

Data is shared across multiple tools or platforms.

Real-time querying is more efficient than copying or moving the data.

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
A Data Engineer needs to share data from an orders table with a team. The Engineer must ensure that the team members cannot view any Personal Identifiable Information (PII), but they can access and analyze other metrics from the orders table. The Pll is disbursed across several columns and individual rows on the table.



How can this requirement be met?

Share the table data using individual secure views.

Apply an aggregation policy on the table using MIN_GROUP_SIZE.

Encrypt the order_id column before sharing the data.

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

Question 53
Skipped
A table, mytable, is created using the following command in a schema called raw.



create table mytable(col1 number, col2 date) data_retention_time_in_days=90;



The DATA_RETENTION_TIME_IN_DAYS is set to 30 days for the raw schema.



If the raw schema gets dropped today, for how many days will the data in mytable be accessible through Time Travel?

0 days

120 days

Correct answer
30 days

90 days

Overall explanation
Currently, Snowflake doesn't honor custom data retention periods for schemas or tables when their parent database or schema is dropped. To ensure specific retention times for these child objects, drop them individually before dropping the parent database or schema.

For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
While running an external function, the following error message is received:



Error: Function received the wrong number of rows



What is causing this to occur?

External functions do not support multiple rows.

Correct answer
The return message did not produce the same number of rows that it received.

The JSON returned by the remote service is not constructed correctly.

Nested arrays are not supported in the JSON response.

Overall explanation
The error message "Function received the wrong number of rows" in a Snowflake external function means that the external service didn't return the same number of rows that it received.  Even if your function is designed to work with single values (scalar), it might get multiple rows as input.  In that case, it needs to return the exact same number of rows.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
A company has deployed a data pipeline that streams customer transaction data from an on-premises PostgreSQL database to Snowflake for real-time analytics. A Data Engineer needs to configure a connector that will continuously and reliably transfer data to Snowflake.



Which connector configuration will meet these requirements, while providing MINIMAL latency, and OPTIMAL performance?

Deploy the Snowflake JDBC driver to connect the PostgreSQL database directly to Snowflake, setting up a continuous query on the PostgreSQL database to push data to Snowflake.

Install the Snowflake Connector for Python on the PostgreSQL server to stream data directly to Snowflake, using Python scripts to manage the data transfer.

Correct answer
Configure the Snowflake Connector for Kafka on a Kafka Connect cluster to stream data from the PostgreSQL database to Kafka topics, which will be ingested using the Kafka connector.

Configure the Snowflake Connector for Kafka to continuously stream data from the PostgreSQL database into Snowflake by configuring PostgreSQL as a Kafka producer.

Overall explanation
A few comments:

PostgreSQL can use a CDC tool like Debezium to publish changes to Kafka topics, and Kafka Connect with the Snowflake Kafka Connector ensures near real-time ingestion into Snowflake.

This option enables low-latency, high-throughput, and reliable streaming of data using a decoupled architecture.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
A Data Engineer is building a continuous data pipeline using Snowpipe. The pipeline needs to generate an event notification if there are any errors in the pipe.



Which Snowpipe configurations will generate event notifications when errors are encountered during data loading? (Select TWO).

Correct selection
CREATE PIPE mypipe AUTO_INGEST = TRUE ERROR_INTEGRATION = my_notification_int AS COPY INTO mydb.public.mytable FROM @mydb.public.mystage ON_ERROR='SKIP_FILE';
CREATE PIPE mypipe
AS COPY INTO mydb.public.mytable FROM @mydb.public.mystage
ON_ERROR='CONTINUE';
CREATE PIPE mypipe AUTO_INGEST = TRUE ERROR_INTEGRATION = my_notification_int AS COPY INTO mydb.public.mytable FROM @mydb.public.mystage ON_ERROR='CONTINUE';
Correct selection
CREATE PIPE mypipe AUTO_INGEST = FALSE ERROR_INTEGRATION = my_notification_int AS COPY INTO mydb.public.mytable FROM @mydb.public.mystage;
CREATE PIPE mypipe
AS COPY INTO mydb.public.mytable FROM @mydb.public.mystage
ON_ERROR='SKIP_FILE';
Overall explanation
A few comments:

To enable error notifications for a pipe, we need to set the ERROR_INTEGRATION parameter.

Keep in mind that Snowpipe only sends error notifications if the ON_ERROR copy option is set to SKIP_FILE (which is the default).

If we change ON_ERROR to CONTINUE, Snowpipe won’t trigger any error notifications.

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
What is a characteristic of the operations of streams in Snowflake?

Correct answer
When a stream is used to update a target table, the offset is advanced to the current time.

Each committed and uncommitted transaction on the source table automatically puts a change record in the stream.

Whenever a stream is queried, the offset is automatically advanced.

Querying a stream returns all change records and table rows from the current offset to the current time.

Overall explanation
A few comments:

A stream advances the offset only when it is used in a DML transaction (i.e UPDATE).

The stream offset advances when the stream is consumed (e.g., when changes are processed and applied to a target table).

Querying a stream does not automatically advance the offset. The offset only moves forward when the stream data is consumed.

A stream only returns new changes from the last offset, not all rows from the source table.

Streams only capture committed transactions.

For more detailed information, refer to the official Snowflake documentation.

Question 58
Skipped
A retailer would like to provide suppliers with sales figures for their products, but not for the other suppliers' products. The retailer's SALES table contains these columns: SALE_DATE, SKU, SUPPLIER, QTY, and PRICE.



What is the MOST-efficient way to share this data with the suppliers?

Each supplier should set up a Snowflake data consumer account. For each supplier, create a view:

CREATE SECURE VIEW SUPPLIER_NUMBER1_SALES
AS
SELECT SALE_DATE, SKU, QTY, ...
FROM SALES
WHERE ACCOUNT = 'Supplier Number 1';
Create a share for each supplier, and grant SELECT on this view to the share. Then add the supplier's account to the share.

Correct answer
Each supplier should set up a Snowflake data consumer account. Record each account in a table SUPPLIER_ACCOUNTS, that includes columns SUPPLIER and ACCOUNT. Then create a view:

CREATE SECURE VIEW SUPPLIER_SALES
AS
SELECT SALE_DATE, SKU, QTY, ...
FROM SALES JOIN SUPPLIER_ACCOUNTS USING (SUPPLIER)
WHERE SUPPLIER_ACCOUNTS.ACCOUNT = CURRENT_ACCOUNT();
Grant SELECT on this view to a share and add the supplier's account to the share.

Each supplier should run a Snowflake consumer account. Record each account in a table SUPPLIER_ACCOUNTS, that includes columns SUPPLIER and ROLE. Create a view:

CREATE SECURE VIEW SUPPLIER_SALES
AS
SELECT SALE_DATE, SKU, QTY, ...
FROM SALES JOIN SUPPLIER_ACCOUNTS USING (SUPPLIER)
WHERE SUPPLIER_ACCOUNTS.ROLE = CURRENT_ROLE();
Grant SELECT on this view to a share and then add the supplier's account to the share.

Create a view

CREATE SECURE VIEW SUPPLIER_SALES
AS
SELECT SALE_DATE, SKU, QTY, ...
FROM SALES
WHERE ACCOUNT = 'supplier_account';
Set up a schedule to periodically issue this command for each supplier:

SET supplier_account='Supplier Number 1';

Then export the supplier's sales figures to a separate cloud storage provider for data visualization.

Overall explanation
A few comments:

If we use context functions in SHARE, it is not necessary to create several views or to create a view and keep changing the definition of the account that has access. This is neither efficient nor scalable.

On the consumer account, Snowflake returns NULL for CURRENT_ROLE() and CURRENT_USER() when used in a masking or row access policy on a shared table or view.

Instead, use CURRENT_ACCOUNT() in the policy to distinguish between the consumer and provider accounts.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
When defining column-level security, using what built-in Snowflake function indicates whether the current role has inherited privileges of a specified role?

IS_ROLE_IN_HIERARCHY

Correct answer
IS_ROLE_IN_SESSION

IS_INVOKER_ROLE

INVOKER_ROLE

Overall explanation
A few comments:

IS_ROLE_IN_SESSION checks if a specific role is currently active in the user’s session—either as the primary role or one of the secondary roles.

If used with a column, it verifies whether the role stored in that column is part of the user's active role hierarchy for the session.

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
A Data Engineer is writing a Python script using the Snowflake Connector for Python. The Engineer will use the snowflake.connector.connect function to connect to Snowflake.



The requirements are:

Raise an exception if the specified database, schema, or warehouse does not exist

Improve download performance



Which parameters of the connect function should be used? (Choose two.)

arrow_number_to_decimal
authenticator
client_session_keep_alive
Correct selection
client_prefetch_threads
Correct selection
validate_default_parameters
Overall explanation
A few comments:

client_prefetch_threads: This controls how many threads are used to download the results of a query. The default is 4. Increasing this can make fetching results faster but will use more memory.

validate_default_parameters: If you turn this on, Snowflake will throw an error if the database, schema, or warehouse you specify in your connection doesn't exist. This helps catch mistakes early on.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
At what isolation level are Snowflake streams?

Correct answer
Repeatable read

Snapshot

Read committed

Read uncommitted

Overall explanation
Streams in Snowflake have a feature called "repeatable read". This means that if you have multiple queries within a single transaction that are all looking at the same stream, they will all see the same data.

For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
A Data Engineer created a task to process a stream. The task syntax was correct. However, Snowflake terminated the scheduled task after it began running.



Why was the task terminated and what actions will correct this from happening?

An underlying stream did not have data. An exception handler needs to be added to the stream to prevent a time-out.

The stream has too much source data. The stream input tables should be reorganized to process fewer rows.

Correct answer
The task exceeded the default time limit. The task default value needs to be increased, and the task should be resubmitted.

The task was not resumed after being modified. The task should be resumed to ensure it does not idle until time-out, and the task should be resubmitted.

Overall explanation
A few comments:

Key comment: “Snowflake terminated the scheduled task after it began running.” This implies the task was resumed and started, but then Snowflake itself terminated it.

Tasks in Snowflake have a default 60-minute execution limit to prevent non-terminating runs. If a task is canceled or exceeds its schedule, it’s often due to an undersized warehouse. We can either resize the warehouse or increase the timeout using ALTER TASK ... SET USER_TASK_TIMEOUT_MS.

Tasks don’t fail just because a stream has no data, they run successfully and do nothing.

Task resuming issues happen before a task runs. It doesn’t apply after it already began.

High volume in the stream doesn’t cause Snowflake to terminate a task unless it leads to a timeout. This could be a real reason why the execution of the task is terminated but the solution would not be to reorder the input tables of the stream.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
What are characteristics of the use of transactions in Snowflake? (Choose two.)

The AUTOCOMMIT setting can be changed inside a stored procedure.

Explicit transactions can contain DDL, DML, and query statements.

Correct selection
A transaction can be started explicitly by executing a BEGIN WORK statement and end explicitly by executing a COMMIT WORK statement.

A transaction can be started explicitly by executing a BEGIN TRANSACTION statement and end explicitly by executing an END TRANSACTION statement.

Correct selection
Explicit transactions should contain only DML statements and query statements. All DDL statements implicitly commit active transactions.

Overall explanation
A few comments:

An explicit transaction can be commenced by issuing a BEGIN statement. Snowflake also recognizes BEGIN WORK and BEGIN TRANSACTION as aliases, with BEGIN TRANSACTION being the favored option.

Transactions are explicitly terminated through the execution of COMMIT or ROLLBACK. Snowflake offers COMMIT WORK as an alternative to COMMIT, and ROLLBACK WORK as an alternative to ROLLBACK

Explicit transactions should contain only DML statements and query statements.

DDL statements implicitly commit active transactions.

An error message will be generated if the autocommit setting is altered within a stored procedure.

We can use BEGIN TRANSACTION to start an explicit transaction, but to end it we have to use COMMIT WORK/COMMIT or ROLLBACK WORK/ROLLBACK.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
A Data Engineer needs to analyze data and creates an external table that has row access policies and supports NULL values. The Engineer needs to troubleshoot a data failure that occurred three days ago. The Engineer's attempt to create a clone from Time Travel fails.



What could have caused the failure? (Select TWO).

External tables will only persist for 24 hours.

Snowflake enforces NOT NULL constraints on external tables.

Correct selection
Snowflake does not support cloning of an external table.

External tables do not support row access policies in Snowflake.

Correct selection
Time Travel is not supported for external tables.

Overall explanation
A few comments:

Time Travel in Snowflake operates on the historical metadata stored within Snowflake. For external tables, Snowflake only manages the metadata definition (like the file paths and format), not the actual data which resides in external storage.

Snowflake does not allow cloning of external tables.

Snowflake does support applying row access policies to external tables.

For more detailed information about external functions rules, refer to the official Snowflake documentation.