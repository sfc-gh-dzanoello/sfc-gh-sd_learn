Question 1
Incorrect
Which statement will query the row level metadata columns for each record, stored in CSV files, on a stage?

select $filename, $file_row_number, t.$1, t.$2, t.$3 from @mystage (file_format => mycsvformat) t;
select t.$0, t.$1, t.$2, t.$3 from @mystage (file_format => mycsvformat) t;
Your answer is incorrect
select * from @mystage (file_format =› mycsvformat) t;
Correct answer
select metadata$filename, metadata$file_row_number, t.$1, t.$2, t.$3 from @mystage (file_format => mycsvformat) t;
Overall explanation
A few comments:

metadata$filename and metadata$file_row_number: These are the correct metadata columns that provide information about the source file and the row number within that file.

t.$1, t.$2, t.$3: This represents accessing the actual data columns from the CSV file. The $1, $2, $3 notation refers to the positional columns in the file.

This example shows how to stage multiple CSV data files that use the same format in Snowflake. It also shows how to query both the metadata columns (extra information about the files) and the regular data columns within those files.

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
Which of the following are valid SQL statements to execute stored procedures? (Select TWO)

Correct selection
call stproc1 (2 * 5.14::float);

Correct selection
call stproc1 (SELECT COUNT (*) FROM stproc_test_ table1);

call proc1 (1) + proc1 (2);

select * from (call proc1 (1));

call proc1 (1), proc2 (2);

Overall explanation
A few comments:

You can only call a single stored procedure within a single CALL statement.

Each argument to a stored procedure can be a general expression. It passes the result of the expression 2 * 5.14 (which will be implicitly converted to a float due to the ::float cast) as an argument to the procedure.

When calling a stored procedure, you can use a subquery as an argument.

It is not possible to use a stored procedure CALL as part of an expression.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
A stored procedure is defined as below:



create or replace procedure proc1(a float)
returns float 
language javascript
EXECUTE AS CALLER
as
$$
var stmt = snowflake.createStatement (
{sqlText: "set var1 = 100"}
);
var rs = stmt.execute();
stmt = snowflake.createStatement (
{sqlText: "select $var1"}
);
rs = stmt.execute();
rs.next();
var output = rs.getColumnValue(1);
return output;
$$
;


Which of the following is the result of the below code?

set var1=50;
call proc1($var1);
The result is "$var1".

Correct answer
The result is 100.

The result is 50.

The result is an error

Overall explanation
A few comments:

Caller’s rights stored procedures can both read and modify session variables, allowing values to persist before, during, and after execution. In contrast, owner’s rights stored procedures fail to access or set session variables, even when the caller is the owner. This distinction affects how session data is handled within stored procedures.

set var1 = 100; creates a new, local variable within the stored procedure, also named var1, and assigns it the value 100. This overrides the passed-in value within the procedure's scope.

We can simulate this scenario to test it with code:





For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
A company is reporting performance issues when querying an ORDER fact table in Snowflake that gets updated every hour. The query is complex with mutiple JOINS and GROUP BY statements. The fact table is 2 TB, and the Company is using a single cluster with a medium sized warehouse.



Which of the following is the FIRST action to take to improve the performance of the query?

Correct answer
Re-cluster the ORDER fact table using appropriate filters.

Create a materialized view on top of the ORDER fact table.

Change the virtual warehouse confIguration to multi-cluster.

Increase the size of the virtual wirehouse.

Overall explanation
A few comments:

Queries benefit from clustering when they filter or sort based on the table’s clustering key. This is especially useful for ORDER BY, GROUP BY, and certain JOIN operations.

Table is on the TeraByte scale, so it is a size that may be good to consider clustering.

Materialized views can optimize queries but may not be ideal for frequently updated tables.

The question gives us no hint of spilling, so it is not clear that we should address the problem directly by increasing the size of the VWH.

Multi-cluster warehouses help with concurrency but do not improve the performance of a single complex query.

Presumably there will be spilling problems using this size of VWH with this size of table, but those spilling problems could be solved by first doing a good pruning of the micropartitions.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
A data platform team creates two multi-cluster virtual warehouses with the AUTO_SUSPEND value set to NULL on one, and '0' on the other. What would be the execution behavior of these virtual warehouses?

Setting a '0' or NULL value means the warehouses will suspend after the default of 600 seconds.

Setting a '0' value means the warehouses will suspend immediately, and NULL means the warehouses will never suspend.

Correct answer
Setting a '0' or NULL value means the warehouses will never suspend.

Setting a '0' or NULL value means the warehouses will suspend immediately.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
Consider the below pseudocode:



CREATE PROCEDURE p1() ....
$$
INSERT INTO test_table VALUES ('1');
INSERT INTO test_table VALUES ('2');
$$;
 
CREATE PROCEDURE p2() ....
$$
INSERT INTO test_table VALUES ('3');
BEGIN TRANSACTION;
INSERT INTO test_table VALUES ('4');
CALL p1();
COMMIT WORK;
INSERT INTO test_table VALUES ('5');
$$;
 
INSERT INTO test_table VALUES ('6');
ALTER SESSION SET AUTOCOMMIT = FALSE;
BEGIN TRANSACTION;
INSERT INTO test_table VALUES ('7');
CALL p2();
INSERT INTO test_table VALUES ('8');
ROLLBACK;


What additional values will be added to test_table after this code is executed?

1, 2, 4, 6

6, 7, 3, 4, 1, 2

Correct answer
6, 4, 1, 2

6

Overall explanation
You can expect a few transaction questions on the Data Engineer certification exam. It is key to be familiar with how commit, rollback, call, etc. work in order to be able to follow the code of a transaction.

A few comments:

ROLLBACK rolls back the outer transaction, which removes '7', '3', and '8'.

Does not affect '4', '1', and '2' because they were already committed inside p2().

The best way to test the answer is to run the code.



For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
A Data Engineer for a multi-national transportation company has a system that is used to check the weather conditions along vehicle routes. The data is provided to drivers.



The weather information is delivered regularly by a third-party company and this information is generated as JSON structure. Then the data is loaded into Snowflake in a column with a VARIANT data type. This table is directly queried to deliver the statistics to the drivers with minimum time lapse.



A single entry includes (but is not limited to):



- Weather condition: cloudy, sunny, rainy, etc.

- Degree

- Longitude and latitude

- Timeframe

- Location address

- Wind



The table holds more than 10 years' worth of data in order to deliver the statistics from different years and locations. The amount of data on the table increases every day.



The drivers report that they are not receiving the weather statistics for their locations in time.



What can the Data Engineer do to deliver the statistics to the drivers faster?

Divide the table into several tables for each location by using the location address information from the JSON dataset in order to process the queries in parallel.

Divide the table into several tables for each year by using the timeframe information from the JSON dataset in order to process the queries in parallel.

Create an additional table in the schema for longitude and latitude. Determine a regular task to fill this information by extracting it from the JSON dataset.

Correct answer
Add search optimization service on the variant column for longitude and latitude in order to query the information by using specific metadata.

Overall explanation
This is a use case for the use of search optimization service. Search optimization service can significantly improve the performance of certain types of lookup and analytical queries. An extensive set of filtering predicates are supported.

The search optimization service is designed to enhance the performance of specific query types on tables, such as:

Point lookup queries that retrieve a single row or a small set of distinct rows.

Business users requiring quick response times for key dashboards with highly specific filters.

Queries on semi-structured columns like VARIANT, OBJECT, and ARRAY that use equality conditions.



About other options:

Dividing the table by year or location adds complexity to data management and does not guarantee better performance

Creating an additional table for longitude and latitude adds complexity and increases data duplication. It also introduces overhead in maintaining data synchronization between the tables.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
While loading CSV data using the COPY INTO statement, a Data Engineer encounters the following error.



Number of columns in file (15) does not match that of the corresponding table (14)



Which approach should the Data Engineer take to solve this problem and load the file into the table? (Select TWO)

Set the copy option FORCE to true.

Correct selection
Do not modify the file data. Change the ERROR_ON_COLUMN_COUNT_MISMATCH option in the file format to false during the loading process.

Modity the file data to enclose fields with a delimiter. Leverage the FIELD_OPTIONALLY_ENCLOSED_BY option in the file format during the load process.

Correct selection
Make necessary changes in the table DDL to support all the columns in the file.

Modify the file data to use a different file format. Change the file format type in the file format options during the loading process.

Overall explanation
A few comments:

Make necessary changes in the table DDL to support all the columns in the file: Adjusting the table schema to match the number of columns in the file ensures all data is loaded properly without errors.

Do not modify the file data. Change the ERROR_ON_COLUMN_COUNT_MISMATCH option in the file format to false during the loading process: This allows the data to load even if the file has more columns than the table, skipping the mismatch error during the process. ERROR_ON_COLUMN_COUNT_MISMATCH, if set to FALSE, an error is not generated and the load continues. If the file is successfully loaded:

Modifying the file data to use a different file format or modifying the file data to enclose fields with a delimiter will not fix the column mismatch.

Question 9
Skipped
How is Snowflake's query result data cache used?

It is used for SHOW commands.

It is used to store statistics when data is loaded.

Correct answer
It is used to persist query results when the underlying data has not changed.

It is used to minimize how much data needs to be read from cloud storage.

Overall explanation
When a Snowflake warehouse is running, it keeps a copy of some of the table data it uses. Queries running on that warehouse can access this cached data. This makes those queries faster because they don't have to read the data directly from the tables.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
What will occur if a User-Defined Function (UDF) executes a MERGE INTO command?

The command would fail because only updates or inserts can be performed

Privileges would need to be applied to the function owner to access the tables

Correct answer
The command would not qualify as a scalar or table function

The command would run as expected

Overall explanation
A few comments:

UDFs in Snowflake can be written in Java, JavaScript, Python, or SQL.

UDFs in Snowflake are meant for computations and cannot perform DML operations like MERGE INTO, which modifies data.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
Which of the following statements accurately describe SQL User-Defined Functions (UDFs)?

SQL UDFs can be set to run with caller's rights.

SQL UDFs can contain multiple SQL statements.

SQL UDFs can run updated DML statements.

Correct answer
SQL UDFs can use SQL variables inside.

Overall explanation
A few comments:

A UDF can only contain one query expression, but that expression can include UNION [ALL] to combine multiple SELECT statements.

While we can use a full SELECT statement inside a UDF, we can't use other types of DML statements, like INSERT, UPDATE, or DELETE. We also can't use DDL statements.

We can use variables within a SQL UDF.

The user calling the UDF only needs permission to use the function itself, not necessarily access to the underlying objects (tables, views, etc.)

For more detailed information about Scalar Functions, refer to the official Snowflake documentation.

For more detailed information about UDF, refer to the official Snowflake documentation.

Question 12
Skipped
Which object should be queried when monitoring files loaded into Snowflake through Snowpipe?

Correct answer
Table function copy_history in information_schema and account_usage schemas

View data_transfer_history in information_schema and account_usage schemas

Table function load_history in information_ schema and account_usage schemas

View snowpipe_history in information_schema and account_usage schemas

Overall explanation
The COPY_HISTORY function provides metadata about files loaded into Snowflake, including those processed by Snowpipe, making it the correct choice for monitoring file ingestion.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
Given the named stage:

create or replace stage my_stage file_format = my_file_format;



Which COPY command can be used to load files into the table mytable?

copy into mytable from @my_stage 
file_format = (type = my_file_format);
copy into mytable from my_stage 
file_format = (type = csv);
copy into mytable from @my_stage 
file_format = my_file_format;
Correct answer
copy into mytable from @my_stage 
file_format = (format_name = my_file_format);
Overall explanation
A few comments:

When using a named stage (prefixed with @), the COPY INTO command must also reference the stage with @.

The file_format option should use format_name to specify the pre-defined file format associated with the stage, ensuring proper parsing of the data files.

2 of the options incorrectly omit or misuse format_name, and other option incorrectly omits the @ and assumes a CSV format.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
A user is executing the following command sequentially within a timeframe of 10 minutes from start to finish:



use role sysadmin;
use warehouse compute_wh;
use schema sales.public;
create table t_sales (numeric integer) data_retention_time_in_days=1;
create or replace table t_sales_clone clone t_sales at (offset => -60*30);


What would be the output of this query?

Correct answer
Time Travel data is not available for table T_SALES.

The offset => is not a valid clause in the clone operation.

Table T_SALES_CLONE successfully created.

Syntax error line 1 at position 58 unexpected 'at'.

Overall explanation
A few comments:

The AT clause is valid in combination with offset when using Time Travel.

The use of => with offset is valid.

The statement will fail. Although we have defined a data_retention_time_in_days of 1, we are trying to retrieve the table with an offset of 60*30 (30 minutes). Assuming that the timeframe indicated by the query is 10 minutes, not enough time will have passed since its creation to retrieve that version. The requested time is either beyond the allowed time travel period or before the object creation time. The requested time is either beyond the allowed time travel period or before the object creation time.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
A Data Engineer is building a data pipeline to ingest incremental data from a data source using streams and tasks in Snowflake. A stream is created on a CUSTOMER_RAW table to track the new records and merge them into a CUSTOMER master table by way of a task that runs every hour.



Which of the following is expected if the CUSTOMER_RAW table gets renamed to CUSTOMER_BASE after the task runs for three days?

The DESCRIBE STREAM for the stream will show the value of the STALE column as FALSE.

The DESCRIBE STREAM for the stream will show the value of the STALE column as TRUE.

Correct answer
Renaming will not cause any disruption to the existing data pipeline.

The TASK_HISTORY for the subsequent run will show an error after the renaming operation.

Overall explanation
Changing the name of a source object does not disrupt a stream or make it stale. Additionally, if a source object is deleted and a new one is created with the same name, any streams associated with the original object will not be connected to the new one.

We can simulate this scenario to test it with code:


For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
A Data Engineer needs to process data using the below stored procedure:



create or replace procedure sp_test(p1 FLOAT, p2 FLOAT)
returns string 
language javascript
strict
as
$$
return P1 * P2;
$$
;


Which method will execute this stored procedure, considering the input parameters will be 5.16 and 10?

Correct answer
call sp_test (5.16::FLOAT, 10::FLOAT);

select sp_test ('5.16':: FLOAT, '10'::FLOAT) ;

select * from (call sp_test (5.16:: FLOAT, 10::FLOAT));

exec sp_test ('5.16':: FLOAT '10'::FLOAT);

Overall explanation
A few comments:

CALL is the correct command in Snowflake to execute a stored procedure.

The parameters are passed directly within the parentheses.

Snowflake will implicitly convert the numeric literals 5.16 and 10 to FLOAT as needed, since the procedure parameters are defined as FLOAT.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
Which statements accurately describe the relationship between JavaScript stored procedures and transactions? (Select TWO)

Correct selection
A transaction can be inside a stored procedure.

Correct selection
A stored procedure can be inside a transaction.

Transactions can be started in one stored procedure and finished in another stored procedure.

Stored procedures do not support transactions.

Only one transaction can be executed inside a stored procedure.

Overall explanation
A few comments:

A transaction can be inside a stored procedure.

A stored procedure can be inside a transaction.

A transaction cannot be partly inside and partly outside a stored procedure,

A transaction cannot be started in one stored procedure and finished in a different stored procedure.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
A company called IOT Corporation has subsidiary companies in Germany and Japan.

- The German subsidiary has a Snowflake account called IOTGER in AWS region EU (Frankfurt (Region ID: eu-central-1).

- The Japanese subsidiary has a Snowflake account called IOTJPN in Azure region Japan East (Tokyo) (Region ID: japaneast).

The subsidiaries are totally independent of one another, and their Snowflake accounts belong to different Snowflake organizations.

A Data Engineer needs to share data in a database called IOT_PROD from the German account to the Japanese account.

What steps need to be taken by the German subsidiary so that the Japanese subsidiary can use the shared data?

Replicate database IOT_PROD from IOTGER to IOTJPN with the same database name. Create share S1 into lOTJPN, add the objects to be shared from lOT_PROD in IOTJPN to the share S1, and add account IOTJPN to the share S1

Create a clone of the database IOT_PROD into IOTJPN. Create secure views into the cloned database that read data from the objects to be shared. Create share S1 into IOTJPN. Add the secure views to the share S1, and add account IOTJPN to the share S1.

Create share S1 into lOTGER. Add the objects to be shared from IOT_PROD in IOTGER to the share S1, then add account IOTJPN to the share S1

Correct answer
Create an additional Snowflake account IOTGER2 into region japaneast. Replicate database IOT_PROD from IOTGER to IOTGER2 with the same database name. Create share S1 into IOTGER2, and add the objects to be shared from IOT_PROD in IOTGER2 to the share S1. Then add account IOTJPN to the share S1

Overall explanation
A few comments:

Snowflake Direct Data Sharing does not work directly between independent organizations across different cloud providers.

Database replication is necessary because we need to move data from one cloud and region to another so two of the options are not correct (only propose to use Sharing).

The German subsidiary must replicate the data to a Snowflake account in the same cloud region as IOTJPN (Azure Japan East) and then create a share from that replicated account.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
A Data Engineer is importing JSON data from an external stage into a table with a VARIANT column using the COPY INTO command. During testing, the Engineer discovers that the import sometimes fails, with parsing errors, due to malformed JSON values. The Engineer decides to set the VARIANT column to NULL when a parsing error is encountered.



Which function should be used to meet this requirement?

TO_JSON

Correct answer
TRY_PARSE_JSON

VALIDATE

PARSE_JSON

Overall explanation
TRY_PARSE_JSON is like PARSE_JSON, but instead of throwing an error if the JSON can't be parsed, it just returns NULL.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
Which of the following external function rules are valid? (Select THREE)

External functions are not represented as database objects in Snowfiake

Correct selection
External functions can accept parameters

Correct selection
The returned value of an external function can be a VARIANT

Correct selection
External functions return a value

External functions can appear only in certain clauses of SQL statements

External functions do not impact overall performance.

Overall explanation
A few comments:

External functions are designed to accept parameters to perform operations based on input data.

External functions in Snowflake can return complex data types like VARIANT, making them flexible for diverse use cases.

By definition, external functions must return a value, as they are expected to provide output based on input and external processing.

For more detailed information about external functions rules, refer to the official Snowflake documentation.

Question 21
Skipped
A Data Engineer has set up Snowpipe to auto load from an external stage. The files are being uploaded to the stage. Running the below statement shows that messages are reaching the pipe, but data is not being written to the table.



SELECT SYSTEM$PIPE_STATUS ('(your_pipe_name_here)');



Where should the Engineer check NEXT to determine the issue?

(NOTE: Assume the Engineer has appropriate privileges to get the necessary information)

Check the SNOWFLAKE.ACCOUNT_USAGE.PIPE_USAGE_HISTORY table to see what errors the files encountered in the COPY command.

Correct answer
Check the SNOWFLAKE.INFORMATION_SCHEMA.COPY_HISTORY table function to see what errors the files are encountering in the COPY command.

Check the stored procedure log to confirm the error code.

Check the SNOWFLAKE.INFORMATION_SCHEMA.PIPE_USAGE_HISTORY table to see what errors the files encountered in the COPY command.

Overall explanation
A few comments:

The COPY_HISTORY table function in Snowflake lets you look at the history of data loading over the past 14 days. It shows information about both COPY INTO <table> statements and continuous data loading with Snowpipe.

The COPY_HISTORY function in Snowflake only shows COPY INTO commands that finished, whether they were successful or had errors. It doesn't include commands that were interrupted or didn't finish.

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
Which of the following describes the Snowflake behavior given the below RBAC statement?



USE ROLE SECURITYADMIN;
SELECT * FROM "SQUIRREL_DB"."PUBLIC"."DATA_COST"; --Throws authorization Error
GRANT SELECT ON "SQUIRREL_DB"."PUBLIC"."DATA_COST" TO ROLE PUBLIC;-- Executes successfully
The ACCOUNTADMIN revoked certain privileges for the SECURITYADMIN.

The SECURITYADMIN is a secondary owner of the object with the SYSADMIN as the primary owner. The SECURITYADMIN can grant privileges without having the SELECT privilege.

All databases, tables, and virtual warehouses are owned by the role SECURITYADMIN. The SECURITYADMIN can grant privileges on objects without having the USAGE privilege.

Correct answer
The SECURITYADMIN manages GRANT privileges and can grant privileges to other users without having privileges on the object.

Overall explanation
The SECURITYADMIN role in Snowflake has the MANAGE GRANTS privilege, which allows them to grant or revoke privileges on any object in the account. This makes them a powerful role for managing access control in Snowflake. This explains why the GRANT statement executes successfully, even though the SELECT statement fails due to missing access.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
A fact table has 700 GB of data, but the overall storage for the table is larger than 100 TB. Time Travel is set to 30 days. The table has the column BUSINESS_DATE as a cluster key.



What are reasons for this excess storage? (Select TWO)

Correct selection
The table is subjected to daily CREATE OR REPLACE table functions, which means Time Travel is maintained for every table version.

Multiple materialized views have been built on top of this table and each view requires storage.

Correct selection
The table is subjected to frequent large updates and has many micro-partition versions.

The table has multiple streams created against it and each stream is accumulating a large amount of storage.

The table is loaded daily from files placed on an external stage. Each file contains data from a single business date.

Overall explanation
Time Travel in Snowflake works by maintaining previous versions of micro-partitions. Frequent large updates, especially those that affect many rows within a micro-partition, can lead to a significant increase in the number of micro-partition versions stored.

For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
Which of the following actions will improve performance when querying a fixed number of columns in an external table? (Select TWO)

Decrease the number of columns returned in a SELECT statement.

Correct selection
Build a materialized view on the external table and perform queries on the view.

Issue an ALTER EXTERNAL TABLE ... REFRESH statement to boost performance.

Set AUTO_REFRESH to faise.

Correct selection
Add partitioning to the external table definition and leverage partition elimination during querying.

Overall explanation
A few comments:

Materialized views on top of external tables can often be faster than querying the external tables directly.

Partitioning also helps with query performance. By dividing the external data into smaller chunks, queries can run faster because they only need to process the relevant parts instead of scanning everything.

For more detailed information about materialized views over external tables, refer to the official Snowflake documentation.

For more detailed information about external tables partitioning, refer to the official Snowflake documentation.

Question 25
Skipped
How can the following relational data be transformed into semi-structured data using the LEAST amount of operational overhead?



create table provinces (province varchar, created_ date date):




Use the PARSE_ JSON function to produce a VARIANT value.

Correct answer
Use the OBJECT_CONSTRUCT function to return a Snowflake object.

Use the TO_VARIANT function to convert each of the relational columns to VARIANT.

Use the TO_JSON function.

Overall explanation
A few comments:

TO_JSON turns a VARIANT value into a JSON-formatted string.

TO_VARIANT turns any value into a VARIANT value.

PARSE_JSON takes a JSON-formatted string and turns it into a VARIANT value.

OBJECT_CONSTRUCT efficiently converts relational data into a semi-structured JSON-like format with minimal overhead, preserving key-value relationships without requiring additional parsing or conversion.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
Given the following Query Profile:




Which is true about the TableScan task?

The local spilling on this task is 2% of the data.

The task reads 760 Mb of data divided in 100 thousand rows.

There is 99.79% of data coming from the result cache.

Correct answer
The code executed is not offering any partition pruning opportunities.

Overall explanation
A few comments:

The query profile shows that all partitions (1,024) are scanned, meaning no pruning was applied, leading to a full table scan and increased query cost.

The profile states 760 MB of data is read, but the task reads 100 million rows

99.79% of data is conming from local disk (cache), meaning the result cache was not used.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
A Data Engineer has set up a continuous data pipeline using Snowpipe to load data into a table MYTABLE.



To see all errors that have occurred in the last hour, which of the following queries would need to be executed?

select * from
information_schema.copy_history
where table_name= 'MYTABLE' and 
start_time > DATEADD (hours, -1, current_timestamp ()) ;
select * from 
table (information_schema.load_history (table_name=> 'MYTABLE' ,
start_time=> DATEADD (hours, -1, current_timestamp())));
Correct answer
select * from
table (information_schema.copy_history (table_name=> 'MYTABLE',
start_time=> DATEADD(hours, -1, current_timestamp()))) ;
select * from
information_schema.load_history 
where table_ name= 'MYTABLE' and
last_load_time > DATEADD (hours, -1, current_timestamp()) ;
Overall explanation
A few comments:

In the last hour means that we have to see errors on Information Schema table functions due to the higher latency on ACCOUNT USAGE.

COPY_HISTORY table function can be used to query Snowflake data loading history along various dimensions within the last 14 days. The function returns load activity for both COPY INTO <table> statements and continuous data loading using Snowpipe.

For more detailed information about UDF, refer to the official Snowflake documentation.

Question 28
Skipped
Assume the below table exists:



create table foo ( 
name STRING, 
entered_at TIMESTAMP);


Consider the following Stored Procedure:



create procedure sp1()
returns varchar 
language javascript
AS
$$ 
snowflake.execute (
{ sqlText: "insert into foo values ( 'Bob', CURRENT_TIMESTAMP)" }
);
snowflake.execute (
{ sqlText: "begin transaction" }
);
snowflake.execute (
{ sqlText: "insert into foo values ( 'Jane', CURRENT_TIMESTAMP)" }
);
snowflake.execute (
{ sqlText: "CALL sp2()" }
);
snowflake.execute (
{ sqlText: "rollback" }
);
snowflake.execute (
{ sqlText: "insert into foo values ( 'Frank', CURRENT_TIMESTAMP)" }
);
return "";
$$;
 
create procedure sp2()
returns varchar
language javascript
AS
$$
snowflake.execute (
{ sqlText: "begin transaction" }
);
snowflake.execute (
{ sqlText: "insert into foo values ( 'Zach', CURRENT_TIMESTAMP)" }
);
snowflake.execute (
{ sqlText: "commit" }
);
return "";
$$;


Assuming auto commit is set to TRUE, the below commands are issued, in order:



TRUNCATE FOO;
INSERT INTO FOO VALUES ('Mary', CURRENT_TIMESTAMP);
CALL SP1();
SELECT name FROM FOO ORDER BY entered_at;


What names will be returned by the final SELECT statement?

Mary, Bob, Jane, Frank

Mary, Bob, Jane, Zach, Frank

Correct answer
Mary, Bob, Zach, Frank

Mary, Bob, Frank

Overall explanation
You can expect a few transaction questions on the Data Engineer certification exam. It is key to be familiar with how commit, rollback, call, etc. work in order to be able to follow the code of a transaction.

A few comments:

TRUNCATE FOO;: Empties the foo table.

CALL SP1();: Executes the stored procedure sp1.

begin transaction: Starts a transaction.1  

CALL sp2(): Calls stored procedure sp2.

begin transaction: Starts a new transaction within sp2.

commit: Commits the transaction in sp2.

rollback: Rolls back the transaction in sp1.

SELECT name FROM FOO ORDER BY entered_at;: Retrieves the names ordered by timestamp.

The best way to test the answer is to run the code.





For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
Consider the following DDL statement:



create or replace table STAGING_T (
RAW variant,
INGEST_TS timestamp,
INGEST_FILENAME varchar (255)
);
 
create or replace pipe event_pipe
auto ingest = true
integration = 'NOTIFICATION INTEGRATION'
as
copy into STAGING_T from (select $1, current_timestamp(), 
metadata$filename from @EXT_NAMED_STAGE)
file_format = (format_name => "JSON_FORMAT');


Assuming the pipe is functional, and files are being ingested, which of the following statements MOST accurately describes the expected values of INGEST_TS?

INGEST_TS values can be slightly after the values in the LAST_LOAD_TIME column of the COPY_HISTORY view for identical filenames.

INGEST_TS values will be the same values as the LAST_LOAD_TIME column of the COPY_HISTORY view for identical filenames.

Correct answer
INGEST_TS values can be slightly before the values in the LAST_LOAD_TIME column of the COPY_HISTORY view for identical filenames.

INGEST_TS values will always be after the values in the LAST_LOAD_TIME column of the COPY_HISTORY view for identical filenames.

Overall explanation
A few comments:

We can add a timestamp column with the default value set to the current timestamp as records are loaded. This captures the time when each record is loaded. However, the timestamps may be earlier than the LOAD_TIME values returned by the COPY_HISTORY function or view. This is because CURRENT_TIMESTAMP is evaluated when the load operation is compiled in cloud services, not when the record is actually inserted.

LAST_LOAD_TIME column shows date and time of when the file finished loading.

CURRENT_TIMESTAMP() when the load operation is compiled.

For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
A Data Engineer is cloning a database for a new development environment.



Which of the following should the Engineer take into consideration with the cloning process? (Select TWO)

The cloned database will retain any granted privileges from the source database.

Database tables will be locked during the cloning process.

Correct selection
Tasks will be suspended by default when created.

Pipes that reference an external stage will not be cloned.

Correct selection
Unconsumed records in the streams will be inaccessible.

Overall explanation
A few comments:

It’s possible to clone pipes that reference an external stage.

The tasks in the clone are suspended by default when the schema that contains them is cloned.

Cloning a database or schema that includes source tables and streams results in any unconsumed records in the streams (in the clone) being inaccessible.

During long cloning operations, DML transactions can modify data in the source table.

For more detailed information, refer to the official Snowflake documentation.

For more detailed information about cloning considerations, refer to the official Snowflake documentation.

Question 31
Skipped
Which of the below commands will use warehouse credits?

Correct answer
SELECT COUNT(FLAKE_ID) FROM SNOWFLAKE GROUP BY FLAKE_ID;
SHOW TABLES LIKE 'SNOWFL%';
SELECT COUNT(*) FROM SNOWFLAKE;
SELECT MAX(FLAKE_ID) FROM SNOWFLAKE;
Overall explanation
A few comments:

Metadata operations do not require a compute warehouse and therefore do not consume warehouse credits.

Metadata about each column for the micro-partition is stored by Snowflake in its metadata cache in the cloud services layer. This metadata is used to provide extremely fast results for basic analytical queries such as count(*) and max(column).

SHOW TABLES is a metadata query that retrieves information about tables in Snowflake.

Question 32
Skipped
A Data Engineer is creating a User-Defined Function (UDF) to catch null values and convert them into a string.



Which of the following functions would replicate the desired behavior?

CREATE OR REPLACE FUNCTION Null_to_String (s string)
RETURNS string
LANGUAGE JAVASCRIPT
AS '
if (S === unknown) {
return "string was null";
} else
{
return S;
}
';
CREATE OR REPLACE FUNCTION Null_to_String (s string)
RETURNS string
LANGUAGE JAVASCRIPT
AS '
if (S === null) {
return "string was null";
} else
{
return S;
}
';
CREATE OR REPLACE FUNCTION Null_to_String (s string)
RETURNS string
LANGUAGE JAVASCRIPT
AS '
if (S = null) {
return "string was null";
} else
{
return S;
}
';
Correct answer
CREATE OR REPLACE FUNCTION Null_to_String (s string)
RETURNS string
LANGUAGE JAVASCRIPT
AS '
if (S === undefined) {
return "string was null";
} else
{
return S;
}
';
Overall explanation
A few comments:

When you use a SQL NULL value in a JavaScript UDF (User-Defined Function) in Snowflake, it becomes undefined inside the JavaScript code. Similarly, if your JavaScript code returns undefined, Snowflake converts it back to NULL in SQL. This applies to all data types, even VARIANT. For regular data types (not VARIANT), returning null from JavaScript will also result in a SQL NULL.

The UDF checks if the input S is undefined. If it is, it returns the string "string was null".

Otherwise, it returns the original value of S.

S = null is an assignment operation, not a comparison. It would assign null to S and always evaluate to true, leading to incorrect behavior.

S === null would only be true if the input was explicitly null in JavaScript, which is not how Snowflake handles SQL NULL values in this context.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
What actions are permitted when using the Snowflake SQL REST API? (Select TWO).

The use of a CALL command to a stored procedure which returns a table

The use of a GET command

Correct selection
The use of a ROLLBACK command

Correct selection
Submitting multiple SQL statements in a single call

The use of a PUT command

Overall explanation
A few comments:

Submitting a request containing multiple statements to the Snowflake SQL API is possible.

Commands that perform explicit transactions (i.e. ROLLBACK) are supported only within a request that specifies multiple statements.

The PUT command is not supported

The GET command is not supported

While you can call stored procedures through the SQL REST API, Snowflake stored procedures do not return tables directly

For more detailed information about SQL API Rest limitations, refer to the official Snowflake documentation.

Question 34
Skipped
What is the output of the below statement?



alter account set DATA_RETENTION_TIME_IN_DAYS = 0;
create database customer_db;
drop database customer_db;
undrop database customer_db;
The undrop fails. Error. UNDROP DATABASE is not a valid command

Correct answer
The undrop fails. Error: Database CUSTOMER_DB did not exist or was purged

The commands run successfully restoring the CUSTOMER_DB database

The ALTER statement fails. Error: DATA RETENTION_TIME_IN_DAYS cannot be set at the account level.

Overall explanation
A few comments:

Setting this parameter to 0 for an account means there is no data retention for any objects within the account. As soon as something is dropped, it's permanently deleted and cannot be recovered.

Think carefully before setting DATA_RETENTION_TIME_IN_DAYS to 0 for an object in Snowflake. This disables Time Travel, which means you won't be able to recover the object if it's accidentally deleted.

For more detailed information about DATA_RETENTION_TIME_IN_DAYS parameter, refer to the official Snowflake documentation.

For more detailed information about Time Travel, refer to the official Snowflake documentation.

For more detailed information about this specific behavior, refer to the official Snowflake documentation.

Question 35
Skipped
You are a Snowflake Data Engineer in an organization. The business team came to deploy a use case which requires you to load some data which they can visualize through Tableau. Everyday new data comes in and the old data is no longer required.



What type of table will you use in this case to optimize cost?

TEMPORARY

Correct answer
TRANSIENT

EXTERNAL

PERMANENT

Overall explanation
A few comments:

Transient table allows you to store the data temporarily without incurring the additional costs associated with permanent tables.

Temporary tables only exist within the session that creates them and are dropped automatically when the session ends. They are not suitable for data that needs to be available beyond a single session, such as daily loads accessed by Tableau.

Permanent tables incur Fail-safe storage costs, which is unnecessary for data that doesn’t require long-term retention.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
A Data Engineer is determining how to cluster the following table, which is used to record orders from a food delivery service application



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
alter table orders_dashboard cluster by (ordered_at, order_location_state);
Correct answer
alter table orders_dashboard cluster by (order_location_state, DATE (ordered_at));
alter table orders_dashboard cluster by (DATE (ordered_at), order_location_state);
Overall explanation
A few comments:

Snowflake recommends ordering the columns from lowest cardinality to highest cardinality for better effectiveness.

Cardinality of states is lower than DATE of the timestamp, so it has to be the first field in the CLUSTER BY clause.

ordered_at has high cardinality due to the inclusion of time, clustering by DATE(ordered_at) reduces the granularity, making it more efficient.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
A company is building a dashboard for thousands of analyst. The dashboard presents the results of a few summary queries on tables that are regularly updated. The query conditions vary by topic according to what data each analyst needs. Responsiveness of the dashboard queries is a top priority, and the data cache shoud be preserved.



How should the Data Engineer configure the compute resources to support this dashboard?

Correct answer
Assign all queries to a multi-cluster virtual warehouse set to maximized mode. Monitor to determine the smallest suitable number of clusters.

Assign queries to a multi-cluster virtual warehouse with economy auto-scaling. Allow the system to automatically start and stop clusters according to demand.

Create a size XL virtual warehouse to support all the dashboard queries. Monitor query runtimes to determine whether the virtual warehouse should be resized.

Create a virtual warehouse for every 250 analysts. Monitor to determine how many of these virtual warehouses are being utilized at capacity.

Overall explanation
A few comments:

The dashboard serves thousands of analysts, meaning high concurrency. To handle high concurrency scenarios, we have to use MCW.

Maximized mode ensures low query latency by keeping all clusters running.

Maximized mode ensures data caches remain persisted, improving responsiveness.

By monitoring the performance and query workload, the Data Engineer can determine the smallest suitable number of clusters needed to meet the performance requirements. This helps optimize resource allocation and minimize costs while maintaining responsiveness.

A single XL warehouse may not efficiently handle thousands of users, leading to performance bottlenecks.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
A Snowflake Data Engineer created an external function to retrieve credit score values for customer IDs from an external remote service. While testing the service, after several successful retrievals, the results are no longer returned due to a temporary network transport error. However, after waiting for a while, the results are returned, but there are gaps in returned IDs.



What is the MOST likely cause of the gaps in the sequence of the returned IDs?

Correct answer
Snowflake retried the call to the remote service.

The remote service failed with a 4XX status error code.

The total retry timeout was reached before the network transport error was resolved.

The remote service failed with a 5XX status error code.

Overall explanation
If a network issue prevents Snowflake from receiving a remote service’s response, it may retry the request, causing the service to process the same row multiple times. This can lead to unintended effects, such as gaps in sequential unique IDs.

For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
Which of the following should a Data Engineer consider when configuring an API integration to create external functions in Snowflake? (Select TWO)

Correct selection
Snowflake accounts can have multiple API integration objects for different cloud platform accounts.

The role SYSADMIN has granted the global CREATE INTEGRATION privilege to other roles for a decentralized API integration.

Correct selection
Multiple external functions can use the same API integration object, so the same HTTPS proxy service could be used.

An API integration object can be used across different cloud platform accounts.

The Snowfiake default roles ACCOUNTADMIN and SYSADMIN can execute CREATE API INTEGRATION statements.

Overall explanation
A few comments:

An API integration object is tied to a specific cloud platform account and role within that account.

Multiple external functions can use the same API integration object, and thus the same HTTPS proxy service.

Your Snowflake account can have multiple API integration objects, for example, for different cloud platform accounts.

Only the ACCOUNTADMIN role has this privilege by default.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
A team of analysts needs the ability to create their own tables but should not have permission to grant access to those tables to other roles.



How should a Data Engineer handle this?

Create a new schema with MANAGED ACCESS and grant OWNERSHIP of the schema to the analyst role.

Create a new schema and grant CREATE TABLE In the schema to the analyst role.

Grant the analyst role the CREATE SCHEMA privilege, have the analyst role create the schema, and then remove manage grants from the new schema.

Correct answer
Create a new schema with MANAGED ACCESS and grant CREATE TABLE in the schema to the analyst role.

Overall explanation
A few comments:

When a schema has managed access, the schema owner (or someone with the MANAGE GRANTS privilege on the schema) controls who can grant privileges on objects within that schema.

Even if an analyst creates a table, they won't automatically be able to grant access to it unless they also have the MANAGE GRANTS privilege on the schema.

For more detailed information, refer to the official Snowflake documentation.

Question 41
Skipped
A Data Engineer is investigating the performance of a slow query that includes joins. The following information is found in Query Profile.



Spilling

Bytes spilled to local storage            41.55 GB

Bytes spilled to remote storage         8.16 GB



What will improve the query performance? (Select TWO)

Correct selection
Increase the virtual warehouse size.

Run the query as a materialized view.

Increase the maximum multi-clustering parameter for the virtual warehouse.

Correct selection
Reduce the amount of data being scanned.

Pass a database hint.

Overall explanation
A few comments:

Spilling occurs when Snowflake runs out of memory and must write intermediate data to local or remote storage.

41.55 GB spilled to local storage and 8.16 GB to remote storage indicate that the query exceeds available memory, slowing performance.

Larger warehouses have more compute resources and memory, reducing the need to spill data.

Less data scanned = fewer resources needed = less spilling.

When using materialized views, joins are not supported.

Increasing multi-cluster helps with concurrent queries, not single-query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
Consider the following scenario where a masking policy is applied on the CREDITCARDNO column of the CREDITCARDINFO table. The masking policy definition is as follows:



create or replace masking policy creditcardno_mask as (val string) returns string ->
case
    when is_role_in_session('PI_ANALYTICS') then
        right(val, 4)
    else
        '***MASKED***'
end;


Sample data for the CREDITCARDINFO table is as follows:



NAME                EXPIRYDATE        CREDITCARDNO

JOHN DOE        2022-07-23        4321 5678 9012 1234



If the Snowflake system roles have not been granted any additional roles, what will be the result?

Anyone with the PI_ANALYTICS role will see the CREDITCARDNO column as ***MASKED***.

Correct answer
Anyone with the PI_ANALYTICS role will see the last 4 characters of the CREDITCARDNO column data in clear text.

The owner of the table will see the CREDITCARDNO column data in clear text.

The sysadmin can see the CREDITCARDNO column data in clear text.

Overall explanation
A few comments:

The masking policy explicitly allows users with the PI_ANALYTICS role to see the last four characters.

Being the owner of the table does not grant exemption from the masking policy.

Since the question specifies that no additional roles are granted to system roles, only users with the PI_ANALYTICS role will be able to see the last four characters of CREDITCARDNO in clear text.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
Within a Snowflake account, permissions have been defined with custom roles and role hierarchies.



To set up column-level masking using a role in the hierarchy of the current user, what command would be used?

Correct answer
IS_ROLE_IN_SESSION

IS_GRANTED_TO_INVOKER_ROLE

INVOKER_ROLE

CURRENT_ROLE

Overall explanation
When checking if a user has a certain role within a policy's conditions, and that role is part of a hierarchy, it's best to use the IS_ROLE_IN_SESSION function.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
Which of the following grants are required for the role kafka_load_role_1 running the Snowflake Kafka Connector, with the intent of loading data to Snowflake? (Select THREE)

(Assume this role already exists and has usage access to the schema kafka_schema in database kafka_db, the target for data loading.)

Correct selection
grant create pipe on schema kafka_schema to role kafka_load_role_1;
grant create external table on schema kafka_schema to role kafka_load_role_1;
Correct selection
grant create table on schema kafka_schema to role kafka_load_role_1;
grant create task on schema kafka_schema to role kafka_load_role_1;
grant create stream on schema kafka_schema to role kafka_load_role_1;
Correct selection
grant create stage on schema kafka_schema to role kafka_load_role_1;
Overall explanation
The Kafka Connector requires a pipe to ingest streaming data, a stage to store incoming data before loading, and a table as the final destination for structured storage. These grants allow the role to set up and manage the necessary Snowflake objects for loading data.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
A development environment is configured with the below settings:

DATA_ENGINEER role does not have privileges to delete rows from the sys_logs table

OPS role has privileges to delete rows from the sys_logs table

OPS role creates an owner's rights to the stored procedures that deletes rows from the sys_Logs table

OPS role grants appropriate privileges on the stored procedure to the DATA_ENGINEER role



If a user with the role DATA_ENGINEER calls the stored procedure, which of the following statements is true?

Correct answer
The procedure will run with the privileges of OPS and not the privileges of DATA_ENGINEER.

The procedure will error when deleting rows from the sys_ logs table.

The procedure will inherit the current virtual warehouse of the OPS role.

The procedure will run with the privileges of DATA_ENGINEER and not the privileges of OPS.

Overall explanation
A few comments:

The stored procedure was created with the owner's rights of the OPS role, which grants the necessary privileges to delete rows from the sys_logs table.

When the procedure is executed, it will run with the privileges of the owner role (OPS), allowing it to perform the delete operation on the sys_logs table. The privileges of the DATA_ENGINEER role do not come into play in this scenario.

Stored procedures in Snowflake can be set up to run with the owner's permissions. This is useful because it lets the owner give others the ability to do specific tasks, like cleaning up old data, without giving them broader permissions that could be risky.

When you create a stored procedure, you choose whether it runs with the owner's or the caller's permissions.  By default, it runs with the owner's permissions.

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Which of the following is the correct method of querying a User Defined Table Function (UDTF) that returns two columns (col1, col2)?

SELECT my_udtf (col1, col2)
SELECT TABLE (my_udtf(col1, col2))
Correct answer
SELECT $1, $2 FROM TABLE (my_udtf())
SELECT $1, $2 FROM my_udtf()
Overall explanation
When we use a UDTF (User-Defined Table Function) in a query, we put it in the FROM clause. To do this, we write TABLE, followed by the UDTF's name and any input values in parentheses.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
An Data Engineer needs to automate the daily import of two files from an external stage into Snowflake. One file has Parquet-formatted data, the other has CSV-formatted data.



How should the data be joined and aggregated to produce a final result set?

Create a JavaScript stored procedure to read, join, and aggregate the data directly from the external stage, and then store the results in a table.

Create a materialized view to read, join, and aggregate the data directly from the external stage, and use the view to produce the final result set.

Use Snowpipe to ingest the two files, then create a materialized view to produce the final result set.

Correct answer
Create a task using Snowflake scripting that will import the files, and then call a User-Defined Function (UDF) to produce the final result set.

Overall explanation
A few comments:

It is not possible to use materialized views on a join, so we discard two options.

A Snowflake task can be scheduled to import the Parquet and CSV files from the external stage into staging tables.

A UDTF can be used to handle the join and aggregation logic needed for the final result set.

Snowflake procedures are designed to operate on data within tables rather than directly accessing files in stages.

For more detailed information about materialized views limitations, refer to the official Snowflake documentation.

For more detailed information about UDTF join examples, refer to the official Snowflake documentation.

Question 48
Skipped
A Snowflake Data Engineer is working with Data Modelers and Table Designers to draft an ELT framework specifically for data loading using Snowpipe. The Table Designers will add a timestamp column that inserts the current timestamp as the default value as records are loaded into a table. The intent is to capture the time when each record gets loaded into the table; however, when tested, the timestamps are earlier than the load_time column values returned by the copy_history function or the COPY_HISTORY view (Account Usage).



Why is this occurring?

Correct answer
The CURRENT_TIME is evaluated when the load operation is compiled in cloud services rather than when the record is inserted into the table.

The timestamps are different because there are parameter setup mismatches. The parameters need to be realigned.

The Snowflake timezone parameter is different from the cloud provider's parameters causing the mismatch.

The Table Designer team has not used the localtimestamp or systimestamp functions in the Snowflake copy statement.

Overall explanation
When a CURRENT_TIMESTAMP or CURRENT_TIME function is used as a default value in a table, it is evaluated at the start of the load operation in the cloud service, not at the exact moment each record is inserted into the table. This means that the timestamp might reflect the start of the load operation rather than the individual insertion times for each record.

For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
A Data Engineer is implementing a CI/CD process. When attempting to clone a table from a production to a development environment, the cloning operation fails.



What could be causing this to happen?

Tables cannot be cloned from a higher environment to a lower environment.

Correct answer
The retention time for the table is set to zero.

The table has a masking policy.

The table is transient.

Overall explanation
Cloning operations take time to finish, especially with large tables. During this timeframe, DML transactions can modify the data in the source table. As a result, Snowflake tries to clone the table data as it was when the operation started. However, if DML transactions result in data being purged during the cloning process (due to the table's retention time being set to 0), the necessary data becomes unavailable to complete the operation, leading to an error.

About other options:

Transient tables can still be cloned, as Snowflake supports cloning transient tables. However, they do not retain dropped data for Time Travel, but this does not prevent cloning itself.

A masking policy would not prevent the cloning of the table. The policy remains attached to the cloned table, and cloning with policies is a supported operation.

Snowflake does not impose a restriction based on environment hierarchy (production vs. development). Cloning operations are allowed between environments as long as the user has the necessary permissions.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
A Data Engineer enables a result cache at the session level with the following command:



ALTER SESSION SET USE_CACHED_RESULT = TRUE;



The Engineer then runs the following SELECT query twice without delay:



SELECT *
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
SAMPLE (10) SEED (99);


The underlying table does not change between executions.

What are the results of both runs?

The first and second run returned different results, because the query is evaluated each time it is run.

The first and second run returned the same results, because SAMPLE is deterministic.

Correct answer
The first and second run returned the same results, because the specific SEED value was provided.

The first and second run returned different results, because the query uses * instead of an explicit column list.

Overall explanation
A few comments:

SAMPLE clause with a specific SEED value makes the sampling deterministic. This means that given the same table and the same seed, the SAMPLE clause will always return the same subset of rows.

Because the USE_CACHED_RESULT parameter is set to TRUE, Snowflake will store the results of the first query execution in the result cache.

When the same query is executed the second time, Snowflake will recognize that it's identical to the first query (due to the deterministic SAMPLE with the same SEED). It will retrieve the results directly from the result cache instead of re-executing the query.

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
Which of the following is a characteristic of Snowflake external functions?

They must be written in JavaScript or SQL.

They do not require a virtual warehouse or a schema.

Correct answer
They incur costs through virtual warehouse usage and data transfer.

They must be processed through a HTTP proxy service with a GET request.

Overall explanation
A few comments:

Unlike regular UDFs, External Functions can be written in languages like Go and C#.

External Functions can be designed for asynchronous processing. This means Snowflake can send requests to the remote service and continue working while waiting for a response. Snowflake will keep checking for the result until the function times out or returns a result (or an error).

Using External Functions involves the usual costs for using a Snowflake warehouse and transferring data. You might also have to pay extra charges to the provider of the remote service, depending on their pricing.

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
Which of the following will be the output of the below code?



CREATE OR REPLACE TABLE stringdata (str string);
INSERT INTO stringdata VALUES (null), ('somedata');
 
CREATE OR REPLACE FUNCTION nullcheck (s string)
RETURNS string
LANGUAGE JAVASCRIPT
AS '
if (S === undefined) {
return "string was undefined";
 } else if (S === null) {
return "string was null";
} else
{
return "string was not null";
}
';
 
SELECT nullcheck (str)
FROM stringdata
ORDER BY 1;
string was not null

string was not null

Correct answer
string was not null

string was undefined

string was not null

string was null

reference error

reference error

Overall explanation
The Data Engineer certification exam may ask some questions about functions and stored procedures. It is highly recommended to be familiar with the code in order to understand the result of a function.

A few comments:

When you use a SQL NULL value in a JavaScript UDF (User-Defined Function) in Snowflake, it becomes undefined inside the JavaScript code. Similarly, if your JavaScript code returns undefined, Snowflake converts it back to NULL in SQL. This applies to all data types, even VARIANT. For regular data types (not VARIANT), returning null from JavaScript will also result in a SQL NULL.

If S is undefined, return "string was undefined".

If S is null, return "string was null".

Otherwise, return "string was not null".

The best way to test the answer is to run the code:





For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
A Data Engineer ran a relatively complex query on a 2XL virtual warehouse. The Engineer remembered that Snowflake has a RESULT_SCAN table function that allows for the result set to be returned multiple times without having to reprocess the complex query repeatedly.



Which of the following are characteristics of this function? (Select THREE)

The RESULT_SCAN function will only return rows in the same order as the original query.

Correct selection
Snowflake stores the query result for 24-hours if the underlying data has not changed.

Snowflake creates a materialized view to store the result set for each subsequent retrieval.

Correct selection
Each time persisted results for the query are used the 24-hour retention period is reset.

Correct selection
The RESULT_SCAN function can be queried with additional ORDER BY clauses.

Snowflake stores the query result for 7 days if the underlying data has not changed.

Overall explanation
A few comments:

RESULT_SCAN lets you work with the results of an old query (from the last 24 hours) as if it were a table. Snowflake keeps these results for 24 hours, and this function only works on queries run within that time.

Keep in mind that these result sets are different from tables. They don't have the extra information (metadata) that tables do, so working with large results might be slower.

The cool thing is that you can use filters and sorting (ORDER BY) with RESULT_SCAN, even if the original query didn't have them. This helps you narrow down or change the results.

Also, the order of rows returned by RESULT_SCAN might be different from the original query. If you need a specific order, use ORDER BY.

Every time you use RESULT_SCAN with a query result, Snowflake gives it another 24 hours to live, up to a maximum of 31 days from when the query was first run. After 31 days, the result is deleted, and a new one is created the next time you run the query.

For more detailed information about RESULT_SCAN, refer to the official Snowflake documentation.

For more detailed information about querying persisted results, refer to the official Snowflake documentation.

Question 54
Skipped
A table EMP_TBL has three records as shown:



create or replace TABLE EMP_TBL (
    ID NUMBER(38,0),
    NAME VARCHAR(16777216)
);


ID        NAME

1         Name1

2        Name2

3        Name3



The following variables are set for the session:



set tbl_ref = 'EMP_TBL';
set col_ref = 'NAME';
set (var1, var2, var3) = (select 'Name1', 'Name2', 'Name3');


Which SELECT statements will retrieve all three records? (Select TWO).

Correct selection
SELECT * FROM EMP_TBL WHERE identifier($col_ref) IN ('Name1','Name2','Name3');
Correct selection
SELECT * FROM identifier($tbl_ref) WHERE NAME IN ($var1, $var2, $var3);
SELECT * FROM $tbl_ref WHERE $col_ref IN ('Name1','Name2','Name3');
SELECT * FROM $tbl_ref WHERE $col_ref IN ($var1, $var2, $var3);
SELECT * FROM identifier($tbl_ref) WHERE ID IN (var1,'var2','var3');
Overall explanation
A few comments:

We can use identifier($tbl_ref) to dynamically refer to the table specified by tbl_ref

We can use identifier($col_ref) to dynamically refer to the column specified by the col_ref variable.

We can't refer variables with $ directly, as it's not valid syntax

The other incorrect option uses literal values instead of referencing $var variables.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
A table for IOT devices that measures water usage is created. The table quickly becomes large and contains more than 2 billion rows.




The general query patterns for the table are:



DeviceId, IOT_timestamp and CustomerId are frequently used in the filter predicate for the select statement

The columns City and DeviceManufacturer are often retrieved

There is often a count on UniqueId



Which field(s) should be used for the clustering key?

UniqueId

Correct answer
DeviceId and CustomerId

City and DeviceManufacturer

IOT_timestamp

Overall explanation
Based on the provided information about the table water_iot and the general query patterns, the best field(s) to use for the clustering key are those that are frequently used in filter predicates. This will help to optimize query performance by clustering data that is commonly queried together.

Given this information about general query patterns, the optimal clustering key would be DeviceId and CustomerId.

About the options:

DeviceId and CustomerId are frequently used in filter predicates, clustering the data based on these fields will improve query performance for common queries. But, what about IOT_timestamp?

IOT_timestamp is also frequently used in filters, combining it with DeviceId and CustomerId may not be as beneficial as DeviceId and CustomerId together but timestamp fields have high cardinality. A column with very high cardinality is also typically not a good candidate to use as a clustering key directly. For example, a column that contains nanosecond timestamp values would not make a good clustering key.

City and DeviceManufacturer are often retrieved but are not primarily used in filter predicates.

UniqueId is often used for counting, but it doesn't help with filtering and clustering related data together.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
A Data Engineer has a table named CAR_PARTS. The Engineer runs the following commands:



DROP TABLE CAR_PARTS;
CREATE TABLE CAR_PARTS (MAKE VARCHAR, MODEL VARCHAR, YEAR NUMBER);


Which statement would restore the original table and its data?

UNDROP TABLE CAR_PARTS;
Correct answer
ALTER TABLE CAR_PARTS RENAME TO CAR_PARTS_UPDATED; UNDROP TABLE CAR_PARTS; 
UNDROP TABLE CAR_PARTS RENAME TO CAR_PARTS_RESTORE;
DROP TABLE CAR_PARTS; UNDROP TABLE CAR_PARTS at (offset => -60) ;
Overall explanation
A few comments:

We can use Time Travel feature to recover the table. The AT clause with an offset goes back in time. If the table was dropped within the data retention period (which is the case if it was just dropped), we can clone the table as it existed at a point before it was dropped.  This effectively restores the table and its data to that earlier state.

The UNDROP command in Snowflake lets you recover a dropped object (like a table or view). However, if something else already exists with the same name, UNDROP won't work.  To fix this, you need to rename the existing object, then you can use UNDROP to get the old one back.

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
Given the table SALES which has a clustering key of column CLOSED_DATE, which of the following table functions will return only the average clustering depth for the SALES_REPRESENTATIVE column for the North American region?

select system$clustering_information('Sales', 'sales_representative', 'region = ''North America''');
select system$clustering_depth('Sales', 'sales_representative') where region = 'North America';
select system$clustering_information('Sales', 'sales_representative') where region = 'North America';
Correct answer
select system$clustering_depth('Sales', 'sales_representative', 'region = ''North America''');
Overall explanation
A few comments:

The SYSTEM$CLUSTERING_DEPTH function in Snowflake helps you analyze how well your data is clustered. You can add a filter to it to focus on specific values in the columns you're checking.

When we add a filter, we can not use the WHERE keyword.

If we filter a string, we need to put it in single quotes and escape any single quotes within the string by adding another single quote.

Here's an example:

SELECT SYSTEM$CLUSTERING_DEPTH('testtable', '(testcolumn)', 'testcolumn= "test"');

For more detailed information, refer to the official Snowflake documentation.

Question 58
Skipped
A Data Engineer has set up continuous data ingestion using Snowpipe. After a few days of successful data ingestion, the Engineer must modify the pipe definition of the referenced external stage.



What are the recommended steps the Engineer should take?

• Create the pipe using the CREATE_PIPE statement, confirm the pending file count is 1

• Recreate the pipe to change the COPY statement and pause the pipe

• Review configuration steps for the cloud message service to ensure settings are accurate

• Resume the pipe using the SET_PIPE statement and verty pipe execution status is running

• Pause the pipe using an ALTER_PIPE statement, confirm the pending file count is 0

• Recreate the pipe to change the COPY statement

• Review the configuration steps for the cloud message service to ensure settings are accurate

• Resume the pipe and verify pipe execution status is running

• Pause the pipe using the SET_PIPE statement and make sure the pending file count is 1

• Recreate the pipe to change the COPY statement

• Review the configuration steps for the cloud message service to ensure settings are accurate

• Resume the pipe using the START_PIPE statement and verify pipe execution status is running

Correct answer
• Pause the pipe using an ALTER_PIPE statement, confirm the pending file count is 0

• Recreate the pipe to change the COPY statement and pause the pipe

• Review the configuration steps for the cloud message service to ensure settings are accurate

• Resume the pipe and verify the pipe execution status is running

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
What Snowflake system functions are used to view and/or monitor the clustering metadata for a table? (Select TWO).

SYSTEM$CLUSTERING

Correct selection
SYSTEM$CLUSTERING_DEPTH

SYSTEM$TABLE_CLUSTERING

SYSTEM$CLUSTERING_RATIO

Correct selection
SYSTEM$CLUSTERING_INFORMATION

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 60
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
4 & 3

4 & 6

2 & 3

Correct answer
2 & 6

Overall explanation
STREAM_1 (with default settings) tracks all DML changes (inserts, deletes, and updates).

Insertions of (4, 'D') and (5, 'E').

STREAM_2 (with APPEND_ONLY = TRUE) tracks only insert operations and ignores any updates or deletes.

Insertions of (1, 'A'), (2, 'B'), (3, 'C') (initial inserts), and (4, 'D'), (5, 'E'), (6, 'F') (inserts after the truncate).

For more detailed information about streams, refer to the official Snowflake documentation.

Question 61
Skipped
A Data Engineer has built an ELT pipeline that has been running successfully for the past three months. Today, the pipeline is failing to load the data into Snowflake.



Which command would allow the Engineer to see the output of the failed records?

COPY INTO (table) FROM stage VALIDATION_MODE = TRUE;
and see all errors in the result set output
COPY INTO (table) FROM stage VALIDATION_MODE = 'RETURN_ERRORS'; 
and read the results from information_schema.COPY_HISTORY
COPY INTO (table) FROM stage VALIDATION MODE = TRUE;
and read the results from COPY_HISTORY
Correct answer
COPY INTO (table) FROM stage VALIDATION_MODE = 'RETURN_ERRORS'; 
and see all errors in the result set output
Overall explanation
Using the RETURN_ERRORS constant with VALIDATION_MODE in COPY INTO allows retrieving all errors (parsing, conversion, etc.) across all files specified in the COPY statement.

For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
A Data Engineer creates a stream object on a transaction source table to capture new records in the source table and insert the records into a dimension table. The source table gets updated daily. An INSERT statement is configured to run a task on a schedule of once a week, every Sunday at 8:05 PM EST, using CRON syntax:



5 20 * * 0



After 10 days of creating the stream and task objects, the Engineer realized that the task never ran because the task was not resumed after creation.



If the data retention period for the source table is set to 1 day, how many days of records since the creation of the source table will be read from the stream object once the task is resumed?

(NOTE: MAX_DATA_EXTENSION_TIME_IN_DAYS parameter is set to 14 days.)

Correct answer
The last 10 days of records

The last 14 days of records

The last 7 days of records

The last 1 day of records

Overall explanation
A few comments:

If a table's data retention period is less than 14 days and a stream on that table hasn't been used, Snowflake temporarily keeps the data for longer to prevent the stream from becoming stale. This extension lasts up to a maximum of 14 days by default, no matter what Snowflake edition you have. We can customize this extension period using the MAX_DATA_EXTENSION_TIME_IN_DAYS parameter.

In this case we know that we have been receiving records for 10 days, so we will be able to read 10 days of records although we could store a maximum of 14 if the stream is not consumed for 2 weeks.

Once the stream is used, the data retention period goes back to the table's original setting.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
Given the following table and data masking policy:



create table mytable (custkey number default null,
name varchar (100) default null, 
email varchar (100) default null
);
 
create or replace masking policy email_mask as (val string) returns string ->
case
when current role() in ('ANALYST') then val
else '***********'
end;


What would be the required code to apply the masking policy to the table mytable?

Correct answer
alter table if exists mytable modify column email set masking policy email_mask;
alter table if exists mytable alter column email set masking policy email_mask;
alter table mytable modify column email apply policy masking policy email_mask;
alter table mytable alter column email apply masking policy masking policy email_mask;
Overall explanation
This is the syntax we have to use when we want to apply a masking policy on a column.

| ALTER | MODIFY COLUMN <col1_name> SET MASKING POLICY <policy_name> [ USING ( <col1_name> , cond_col_1 , ... ) ] [ FORCE ]

For more detailed information about syntax, refer to the official Snowflake documentation.

For more detailed information about applying a masking policy, refer to the official Snowflake documentation.

Question 64
Skipped
Can a System Administrator enable Snowflake Multi-Factor Authentication (MFA) for another user?

Yes, this can be selected when a user account is created

No, to enable MFA users would need to create a support ticket

Yes. the SECURITYADMIN role can enable it through the ALTER USER command

Correct answer
No, to enable MFA users would have to enroll themselves

Overall explanation
A few comments:

This property is set when a user enrolls in MFA.

It is unset when MFA is disabled.

To enable MFA, users must enroll themselves.

For more detailed information, refer to the official Snowflake documentation.

Question 65
Skipped
Two queries are run on the customer_address table:



create or replace TABLE CUSTOMER_ADDRESS (
    CA_ADDRESS_SK NUMBER(38,0),
    CA_ADDRESS_ID VARCHAR(16),
    CA_STREET_NUMBER VARCHAR(10),
    CA_STREET_NAME VARCHAR(60),
    CA_STREET_TYPE VARCHAR(15),
    CA_SUITE_NUMBER VARCHAR(10),
    CA_CITY VARCHAR(60),
    CA_COUNTY VARCHAR(30),
    CA_STATE VARCHAR(2),
    CA_ZIP VARCHAR(10),
    CA_COUNTRY VARCHAR(20),
    CA_GMT_OFFSET NUMBER(5,2),
    CA_LOCATION_TYPE VARCHAR(20)
);
 
ALTER TABLE DEMO_DB.DEMO_SCH.CUSTOMER_ADDRESS 
ADD SEARCH OPTIMIZATION ON SUBSTRING(CA_ADDRESS_ID);


Which query will benefit from the use of the search optimization service?

select * from DEMO_DB.DEMO_SCH.CUSTOMER_ADDRESS Where CA_ADDRESS_ID NOT LIKE '%AAAAAAAAPHPPL%';
select * from DEMO_DB.DEMO_SCH.CUSTOMER_ADDRESS Where substring(CA_ADDRESS_ID,1,8)=substring('AAAAAAAAPHPPLBAAASKDJHASKLDJHASKJD',1,8);
select * from DEMO_DB.DEMO_SCH.CUSTOMER_ADDRESS Where CA_ADDRESS_ID LIKE '%PHPP%';
Correct answer
select * from DEMO_DB.DEMO_SCH.CUSTOMER_ADDRESS Where CA_ADDRESS_ID=substring('AAAAAAAAPHPPLBAAASKDJHASKLDJHASKJD',1,16);
Overall explanation
A few comments:

The field is a VARCHAR, we have to think about the types of queries where Search Optimization Service achieves a substantial performance improvement.

It is recommended to use search optimization service on highly selective filters that return 1 or few rows. Substring(1,8) for such a long string is not a very selective filter.

We could use search optimization service on semi-structured fields, for some types of queries and filters, but it does not apply here.

It is recommended to use in regular expressions and substring searches with LIKE/NOT LIKE operators and here we have several examples.

Of the other options we have with searches on substrings, the ones that would have the biggest performance improvement would be those with the most restrictive search.

For more detailed information, refer to the official Snowflake documentation.