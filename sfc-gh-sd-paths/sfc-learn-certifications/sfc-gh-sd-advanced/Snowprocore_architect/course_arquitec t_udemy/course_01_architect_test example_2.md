Question 1
Incorrect
Why does a conditional multi-table INSERT option support the Data Vault data model?

Correct answer
Data can be inserted in parallel to hubs and satellites using surrogate keys.

Your answer is incorrect
Data can be inserted in sequence to hubs and satellites using surrogate keys.

Data can be inserted in parallel to dimensions and facts using surrogate keys.

Data can be inserted in sequence to dimensions and facts using surrogate keys.

Overall explanation
A few comments:

Another question we may encounter about Data Vault in the Advanced Architect certification.

Although it is not strictly related to Snowflake, it is useful to have some basic notions about this type of modeling (both version 1.0 and 2.0) and how it fits within the Snowflake architecture.

It is important to know the advantages that Snowflake offers to manage some of the basic DV features.

DV is composed in its Raw Data Vault layer of Hubs, Links and Satellites of many types. The relationships between these entities are made by using hash keys, favoring the parallelism of the loads in this layer.

Snowflake helps us to manage this parallelism with the Multi-table INSERT feature.

Question 2
Skipped
Which of the following should a Data Architect consider when configuring an API integration to create external functions in Snowflake? (Choose two.)

Correct selection
Snowflake accounts can have multiple API integration objects for different cloud platform accounts.

Explanation
A few comments:

An API integration object is tied to a specific cloud platform account and role within that account.

Multiple external functions can use the same API integration object, and thus the same HTTPS proxy service.

Your Snowflake account can have multiple API integration objects, for example, for different cloud platform accounts.

Only the ACCOUNTADMIN role has this privilege by default.

For more detailed information, refer to the official Snowflake documentation.

The role SYSADMIN has granted the global CREATE INTEGRATION privilege to other roles for a decentralized API integration.

An API integration object can be used across different cloud platform accounts.

The Snowflake default roles ACCOUNTADMIN and SYSADMIN can execute CREATE API INTEGRATION statements.

Correct selection
Multiple external functions can use the same API integration object, so the same HTTPS proxy service could be used.

Question 3
Skipped
Which way to create a Snowpipe is correct if your data is hosted in AWS S3?

create pipe mypipe_s3
auto_ingest = true
aws_sns_topic = 'arn:aws:sns:westus2:000000000001:s3_mybucket'
as
copy into snowpipe_db.public.mytable
from @snowpipe_db.public.mystage
file_format = (type = 'JSON');
create pipe mypipe_s3
auto_ingest = true
integration = "MY_INTEGRATION"
as
copy into snowpipe_db.public.mytable
from @snowpipe_db.public.mystage
file_format = (type = 'JSON');
create pipe mypipe_azure
auto_ingest = true
aws_sns_topic = 'arn:aws:sns:westus2:000000000001:azure_mybucket'
as
copy into snowpipe_db.public.mytable
from @snowpipe_db.public.mystage
file_format = (type = 'JSON');
Correct answer
create pipe mypipe_s3
auto_ingest = true
aws_sns_topic = 'arn:aws:sns:us-west-2:000000000001:s3_mybucket'
as
copy into snowpipe_db.public.mytable
from @snowpipe_db.public.mystage
file_format = (type = 'JSON');
Overall explanation
A few comments:

For AWS S3, aws_sns_topic is required to enable auto-ingestion.

Storage integration (INTEGRATION = '...') is required only for Google Cloud Storage or Azure, not for AWS.

auto_ingest = true enables automatic loading when new files are added to S3.

file_format = (type = 'JSON') ensures that JSON files are correctly parsed.

One option is incorrect because it mentions Azure, while the question is about AWS S3.

Another option is incorrect because it uses an AWS region format, but "westus2" is an Azure region, not an AWS one.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
Which security feature is required to connect to Snowflake directly from an AWS VPC?

SSO

Correct answer
PrivateLink

SCIM

OAuth

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
An Architect runs the following SQL query:



How can this query be interpreted?

Correct answer
FILEROWS is a stage. FILE_ROW_NUMBER is line number in file.

FILEROWS is the file format location. FILE_ROW_NUMBER is a stage.

FILEROWS is a file. FILE_ROW_NUMBER is the file format location.

FILEROWS is the table. FILE_ROW_NUMBER is the line number in the table.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 6
Skipped
After creating a database and a schema using the following commands:

CREATE OR REPLACE DATABASE MY_DB 
DATA_RETENTION_TIME_IN_DAYS=30;
CREATE OR REPLACE SCHEMA S1 DATA_RETENTION_TIME_IN_DAYS=50;
How long will we be able to access the data from the schema using the Time Travel functionality if we drop the database?

50 days.

The default time of the account.

Correct answer
30 days.

90 days.

Overall explanation
We are removing the database, so the schema will be removed. When a database is dropped, the data retention period for child schemas or tables, if explicitly set to be different from the retention of the database, is not honored. The child schemas or tables are retained simultaneously as the database. It would be different if we just removed the schema, where we can access this data for the next 50 days using the Time Travel functionality, as we can see in the following diagram:



Question 7
Skipped
Which copy options are supported by the CREATE PIPE...AS COPY FROM command? (Select TWO).

Correct selection
SKIP_HEADER = <integer>

ON_ERROR = ABORT_STATEMENT

Correct selection
STRIP_OUTER_ARRAY = TRUE | FALSE

FILES = ( 'file_name1' [ , 'file_name2', ... ] )

PURGE = TRUE I FALSE

Overall explanation
For more detailed information about syntax, refer to the official Snowflake documentation.

Question 8
Skipped
Which of the following external function rules are valid? (Choose three.)

External functions are not represented as database objects in Snowflake

External functions can appear only in certain clauses of SQL statements

External functions do not impact overall performance.

Correct selection
The returned value of an external function can be a VARIANT.

Correct selection
External functions can accept parameters

Correct selection
External functions return a value

Overall explanation
A few comments:

External functions are designed to accept parameters to perform operations based on input data.

External functions in Snowflake can return complex data types like VARIANT, making them flexible for diverse use cases.

By definition, external functions must return a value, as they are expected to provide output based on input and external processing.

For more detailed information about external functions rules, refer to the official Snowflake documentation.

Question 9
Skipped
Consider the following COPY command which is loading data with CSV format into a Snowflake table from an internal stage through a data transformation query.



This command results in the following error:

SQL compilation error: invalid parameter 'validation_mode'

Assuming the syntax is correct, what is the cause of this error?

The value return_all_errors of the option VALIDATION_MODE is causing a compilation error.

Correct answer
The VALIDATION_MODE parameter does not support COPY statements that transform data during a load.

The VALIDATION_MODE parameter supports COPY statements that load data from external stages only.

The VALIDATION_MODE parameter does not support COPY statements with CSV file formats.

Overall explanation
In Snowflake, the VALIDATION_MODE option is not compatible with COPY commands that involve transformations during the loading process, which is why this command fails.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
A database shared_database is created in a consumer account.What operations can be performed on this shared database? (Choose two.).

The comments on the objects in the shared database can be edited.

A clone of the shared database can be created in the consumer account, with the clone being read-only.

Correct selection
An object in the shared database can be joined to objects referencing another database in the same consumer account.

The shared database created for the consumer account can be re-shared to other accounts.

Correct selection
Any number of users present in the consumer account can access the shared database and can query the data sets.

Overall explanation
Users in the consumer account can access and query the shared database. Additionally, they can join objects from the shared database with objects from other databases within the same consumer account.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
An Architect needs to design a data unloading strategy for Snowflake, that will be used the COPY INTO <location> command.

Which configuration is valid?

• Location of files: Azure ADLS

• File formats: JSON, XML, Avro, Parquet, ORC

• Compression: bzip2

• Encryption: User-supplied key

• Location of files: Amazon S3

• File formats: CSV, JSON

• File encoding: Latin-1 (ISO-8859)

• Encryption: 128-bit

• Location of files: Snowflake internal location

• File format: CSV, XML

• File encoding: UTF_8

• Encryption: 128-bit

Correct answer
• Location of files: Google Cloud Storage

• File formats: Parquet

• File encoding. UTF-8

• Compression: Snappy

Overall explanation
CSV, JSON, Parquet are allowed format files.

UTF 8 is the only encoding allowed.

For more detailed information, refer to the official Snowflake documentation.

Question 12
Skipped
Which vendors do support Snowflake natively for federated authentication and SSO? (Choose two.)

Correct selection
Okta

Onelogin

Correct selection
Microsoft ADFS

Google G Suite

Microsoft Azure Active Directory

Overall explanation
Okta and Microsoft ADFS provide native Snowflake support for federated authentication and SSO.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
The table contains five columns and it has millions of records. The cardinality distribution of the columns is shown below:



Column C4 and C5 are mostly used by SELECT queries in the GROUP BY and ORDER BY clauses. Whereas columns C1, C2 and C3 are heavily used in filter and join conditions of SELECT queries.

The Architect must design a clustering key for this table to improve the query performance.

Based on Snowflake recommendations, how should the clustering key columns be ordered while defining the multi-column clustering key?

C1, C3, C2

C3, C4, C5

Correct answer
C2, C1, C3

C5, C4, C2

Overall explanation
Columns with lower cardinality should come first, as they help reduce the search range more efficiently. In this case, column C2 has the lowest cardinality with only 108 distinct values, followed by C1 with 10,790, and then C3 with 302,605. This ordering improves query performance, especially for filtering and joining conditions, since lower cardinality columns make the search process more efficient.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
Which are the two limitations of the insertReport API of Snowpipe? (Choose two.)

Events are retained for a maximum of 24 hours.

Correct selection
The 10,000 most recent events are retained.

Events are retained for a maximum of 14 days.

The 100,000 most recent events are retained.

Correct selection
Events are retained for a maximum of 10 minutes.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
What is a valid object hierarchy when building a Snowflake environment?

Account --> Schema > Table --> Stage

Organization --> Account --> Stage --> Table --> View

Correct answer
Organization --> Account --> Database --> Schema --> Stage

Account --> Database --> Schema --> Warehouse

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
A Snowflake developer has created a masking policy with the following syntax:



create or replace masking policy mp
AS (val string) returns string ->
CASE
WHEN current_role() in('DEVROLE')
THEN val
ELSE '*********'
END;


Which statements are correct about this policy? (Choose two.)

SECURITYADMIN role can see the plain-text value as stored in the table

Anyone with any role can see the plain-text value as stored in the table

Correct selection
Everyone except DEVROLE role can see the plain-text value as '*********'

The owner of the table can see the plain-text value as stored in the table

Correct selection
Anyone with DEVROLE role can see the plain-text value as stored in the table

Overall explanation
You can return whatever you want. For example, if we specify in the else:

ELSE sha2(val)

It will return a hash value using SHA2, SHA2_HEX for unauthorized users

Question 17
Skipped
A company has several sites in different regions from which the company wants to ingest data.

Which of the following will enable this type of data ingestion?

The company should provision a reader account to each site and ingest the data through the reader accounts.

The company must have a Snowflake account in each cloud region to be able to ingest data to that account.

Correct answer
The company should use a storage integration for the external stage.

The company must replicate data between Snowflake accounts.

Overall explanation
The company should use a storage integration for the external stage. A storage integration allows Snowflake to connect to external cloud storage accounts such as Amazon S3, Microsoft Azure, and Google Cloud Storage. This means that the company can ingest data from multiple sites, regardless of the location, without having to create a Snowflake account in each region. Data is simply staged in the external cloud storage and then accessed by Snowflake through the storage integration.

Question 18
Skipped
What are three of the limitations of the Search Optimization Service? (Choose three.)

Tables that are accessible by different users at the same time

Single-column filtering only

Correct selection
External tables & Materialized views

Tables with more than 100GB

Correct selection
Casts on table columns (except for fixed-point numbers cast to strings)

Correct selection
Analytical expressions

Overall explanation
So, for example, the following predicate would not be supported because it uses a cast on values in the table column:

WHERE TO_DATE(varchar_column) = '2023-01-05';

For more detailed information about Search Optimization Service limitations, refer to the official Snowflake documentation.

Question 19
Skipped
What tables are we able to list using the command SHOW TABLES?

Only permanent tables.

Correct answer
Tables that we have access privileges.

All tables from a Snowflake account and the ones from the provider

All the tables from a Snowflake account

Overall explanation
This command returns the table metadata and properties from the tables that you have access privileges, including dropped tables that are still within the Time Travel retention period.

Question 20
Skipped
A department from our company will run complex aggregation queries to a small subset of data from a huge table that doesn’t change much. After running these queries, we realized that the queries take a lot of time because the table is not clustered on those columns.

What is the most optimal solution that we should implement?

Correct answer
Create a materialized view and cluster the view on those columns.

Create a temporary table to store the subset of data

Create a secure view and cluster the view on those columns.

Create a view and cluster the view on those columns.

Overall explanation
Key comments: small subset of data, complex aggregation, data that doesn’t change much. So it’s a perfect scenario to use materialized views.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
A company has a Snowflake account named ACCOUNTA in AWS us-east-1 region. The company stores its marketing data in a Snowflake database named MARKET_DB. One of the company’s business partners has an account named PARTNERB in Azure East US 2 region. For marketing purposes the company has agreed to share the database MARKET_DB with the partner account.

Which of the following steps MUST be performed for the account PARTNERB to consume data from the MARKET_DB database?

Create a new account (called AZABC123) in Azure East US 2 region. From account ACCOUNTA create a share of database MARKET_DB, create a new database out of this share locally in AWS us-east-1 region, and replicate this new database to AZABC123 account. Then set up data sharing to the PARTNERB account.

Create a share of database MARKET_DB, and create a new database out of this share locally in AWS us-east-1 region. Then replicate this database to the partner’s account PARTNERB.

From account ACCOUNTA create a share of database MARKET_DB, and create a new database out of this share locally in AWS us-east-1 region. Then make this database the provider and share it with the PARTNERB account.

Correct answer
Create a new account (called AZABC123) in Azure East US 2 region. From account ACCOUNTA replicate the database MARKET_DB to AZABC123 and from this account set up the data sharing to the PARTNERB account.

Overall explanation
To allow the account PARTNERB to consume data from the MARKET_DB database, the following steps should be performed:

Create a new Snowflake account called AZABC123 in Azure East US 2 region.

From the ACCOUNTA Snowflake account, replicate the MARKET_DB database to the AZABC123 account in Azure East US 2 region.

From the AZABC123 Snowflake account, set up data sharing to the PARTNERB account, granting appropriate privileges to access the shared objects.

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
A DevOps team has a requirement for recovery of staging tables used in a complex set of data pipelines. The staging tables are all located in the same staging schema. One of the requirements is to have online recovery of data on a rolling 7-day basis.

After setting up the DATA_RETENTION_TIME_IN_DAYS at the database level, certain tables remain unrecoverable past 1 day.

What would cause this to occur? (Choose two.)

Correct selection
The DATA_RETENTION_TIME_IN_DAYS for the staging schema has been set to 1 day.

The DevOps role should be granted ALLOW_RECOVERY privilege on the staging schema.

The tables exceed the 1 TB limit for data recovery.

Correct selection
The staging tables are of the TRANSIENT type.

The staging schema has not been setup for MANAGED ACCESS.

Overall explanation
A few comments:

If the retention period at the schema level is set to 1 day, it will override the database-level setting, causing data to be unrecoverable past 1 day.

Transient tables do not support data retention, which means they cannot be recovered beyond the specified period, even with retention settings in place.

For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
Which data transformations are supported for data loading using the COPY INTO command? (Choose three.).

Window functions

Correct selection
Data type conversions

Subqueries

Joining to other staged data

Correct selection
Loading a subset of the data

Correct selection
Column re-ordering

Overall explanation
Subqueries, window functions, and joining to other staged data are not supported directly in the COPY INTO command.

For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
A large join query takes around 3 hours to complete in an L warehouse. After increasing the warehouse size to XL one, the query's performance didn't improve. What can be the cause of it?

The query was still running before the new size of the warehouse was applied

Correct answer
One of the column's values is significantly more than the rest of the values in the column; that's why it produces a skew in your data.

The warehouse had auto-suspended before the query finished, and it had to re-start again

The warehouse doesn't have enough power still

Overall explanation
This is a difficult question requiring much understanding about Snowflake. Data skew primarily refers to a non-uniform distribution in a dataset. For example, in the following picture (left), we can see that most values are in the right part of the graph. In a Snowflake table, this is translated as most of the values are the same.

Because of the data skew, only one node may be processing the major portion of the data instead of distributing it along all the clusters. We can see this in the (right) part of the picture, where each square represents a warehouse cluster. So a bottleneck is produced, not improving even when we increase the warehouse size.



Question 25
Skipped
A healthcare company is deploying a Snowflake account that may include Personal Health Information (PHI). The company must ensure compliance with all relevant privacy standards.

Which best practice recommendations will meet data protection and compliance requirements? (Choose three.)

Use the Internal Tokenization feature to obfuscate sensitive data.

Correct selection
Use, at minimum, the Business Critical edition of Snowflake.

Rewrite SQL queries to eliminate projections of PHI data based on current_role().

Correct selection
Create Dynamic Data Masking policies and apply them to columns that contain PHI.

Avoid sharing data with partner organizations.

Correct selection
Use the External Tokenization feature to obfuscate sensitive data.

Overall explanation
A few comments:

Business Critical Edition offers support for PHI data (in accordance with HIPAA and HITRUST CSF regulations).

The other Snowflake features we have to leverage is Column-level Security (External tokenization and Dynamic Data Masking)

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
When would you usually consider to add clustering key to a table? (Choose two)

The number of users querying the table has increased.

The table has more than 20 columns.

Correct selection
It is a multi-terabyte size table.

Correct selection
The performance of the query has deteriorated over a period of time.

The data in the table is mostly static and does not change frequently.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
What does a successful response from the insertFiles Snowpipe endpoint mean?

The files have been validated for format and integrity.

The files have been ingested.

It Retrieves a report of files submitted via the insertFile endpoint.

Correct answer
Snowflake has recorded the list of files to add to the table.

Overall explanation
A 200 HTTP response from this endpoint means that Snowpipe added the files to the queue of files to ingest, but it doesn’t necessarily mean the files have been ingested.

Question 28
Skipped
What considerations should be taken into account when deciding which method to use to load data into Snowflake? (Choose three.)

Correct selection
The ELT method is more scalable than other methods as it uses Snowflake's virtual warehouses

The ELT method will not allow any type of data transformation on ingestion

With the ELT method, transformation may take longer to execute than other methods as they depend on the size of the data

The ETL method is typically faster than other methods, as it transforms data on ingestion

Correct selection
With the ETL method, users may need to reload the incoming data if there is an error in the process

Correct selection
The ELT method can separate the ingestion and transformation resources, making it the most flexible method

Overall explanation
A few comments:

The ETL method is typically faster than other methods, as it transforms data on ingestion -> If data transformation is performed during an ingestion it is slower.

With the ETL method, users may need to reload the incoming data if there is an error in the process -> If any process fails during the transformation, as the information is not loaded in the DB, it will need to be reloaded

The ELT method is more scalable than other methods as it uses Snowflake's virtual warehouses -> As all transformation occurs within Snowflake, we will take advantage of the benefits of virtual warehouses such as scalability among others.

The ELT method can separate the ingestion and transformation resources, making it the most flexible method -> L & T are separated making each process more flexible, for example you can assign a different size warehouse for each type of process.

The ELT method will not allow any type of data transformation on ingestion -> Some kind of transformations are allowed during ingestion

With the ELT method, transformation may take longer to execute than other methods as they depend on the size of the data -> In both paradigms the transformation depends, among other things, on the data size. With the ELT method, this can be adjusted by assigning a warehouse of the appropriate size for the transformation. Transformations will take longer in the ETL method.

Question 29
Skipped
An Architect entered the following commands in sequence:



USER1 cannot find the table.

Which of the following commands does the Architect need to run for USER1 to find the tables using the Principle of Least Privilege? (Choose two.)

GRANT ALL PRIVILEGES ON DATABASE SANDBOX TO ROLE INTERN;

Correct selection
GRANT USAGE ON DATABASE SANDBOX TO ROLE INTERN;

Correct selection
GRANT USAGE ON SCHEMA SANDBOX.PUBLIC TO ROLE INTERN;

GRANT ROLE PUBLIC TO ROLE INTERN;

GRANT OWNERSHIP ON DATABASE SANDBOX TO USER INTERN;

Overall explanation
Since each table belongs to a single schema, and the schema, in turn, belongs to a database, the table becomes the schema object, and to assign any schema object privileges, we need to first grant USAGE privilege on parent objects such as schema and database.

Question 30
Skipped
A company is storing large numbers of small JSON files (ranging from 1-4 bytes) that are received from IoT devices and sent to a cloud provider. 1,000 files are added to the cloud provider every hour.

What is the MOST cost-effective way to bring this data into a Snowflake table?

A stream

Correct answer
A pipe

An external table

A copy command at regular intervals

Overall explanation
A pipe is a Snowflake feature that enables real-time ingestion of data from various sources, such as files, streams, or external tables. It is designed to handle high volume and high velocity data, making it ideal for use cases like the one described in the question.

In this scenario, a pipe can be set up to automatically ingest the JSON files as they are added to the cloud provider. Pipes are highly scalable and cost-effective since they only incur charges when data is ingested, unlike other options like copying data at regular intervals or using external tables.

Note that none of the scenarios would be efficient, since we are working with small files. The COPY INTO would be running the VWH constantly, as it is billed for at least one minute even if the files are already loaded and Snowpipe would bill us quite a lot of management overhead due to the large number of files.

It will always be more efficient to work with a message queue manager and buffer size or to add a process prior to ingest that compacts the small files into files of a more optimal size plus Snowflake (around 100MB-250MB).

Question 31
Skipped
Company A wants to share some data with Company B whose account is in the same region. The data that Company A would like to share is from two different databases in their account.

Which of the following is the best option that will allow Company A to share data with Company B?

Create two shares, one for each database.

Create a standard view that selects data from both tables and share the standard view.

Correct answer
Create a secure view that selects data from both tables and share the view.

Create a single share that includes both databases.

Overall explanation
A few comments:

Snowflake data providers can share data located in different databases through the use of secure views.

A secure view has the capability to reference objects such as schemas, tables, and other views from multiple databases, provided that these databases are part of the same account.

For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
Which are the two limitations of the insertFiles API of Snowpipe? (Choose two.)

The post can contain at most 10000 files.

The post can contain at most 1000 files.

Correct selection
The post can contain at most 5000 files.

Correct selection
Each file path given must be <= 1024 bytes long when serialized as UTF-8.

Each file path given must be <= 512 bytes long when serialized as UTF-8.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
Which of the following grants are required for the role kafka_load_role_1 running the Snowflake Kafka Connector, with the intent of loading data to Snowflake? (Choose three.)

(Assume this role already exists and has usage access to the schema kafka_schema in database kafka_db, the target for data loading.)

grant create external table on schema kafka_schema to role kafka_load_role_1;

grant create task on schema kafka_schema to role kafka_load_role_1;

grant create stream on schema kafka_schema to role kafka_load_role_1;

Correct selection
grant create table on schema kafka_schema to role kafka_load_role_1;

Correct selection
grant create stage on schema kafka_schema to role kafka_load_role_1;

Correct selection
grant create pipe on schema kafka_schema to role kafka_load_role_1;

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
At what frequency does Snowflake rotate the object keys?

60 Days

Correct answer
30 Days

16 Days

1 Year

Overall explanation
Keys automatically get rotated every 30 days.

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
A company needs to share a Snowflake data table with data consumers who do not have Snowflake accounts.

What is the recommended way to to this?

Create users for the consumers that have the built-in role EXTERNAL and grant that role the select privilege on the table.

Create a share with the table and provide the consumers with the public URL for the share.

Correct answer
Create a share with the table and create a reader account with access to the share for the consumers.

Unload the table to a read-only cloud storage location and give consumers access to the table.

Overall explanation
As a data provider, you can share data with consumers who lack a Snowflake account or are not ready to become licensed customers by creating reader accounts. These accounts allow for quick and cost-effective data sharing without requiring consumers to become Snowflake customers. Each reader account is linked to the provider account that created it, and it can only access data from that specific provider account.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
Will this query cost compute credits considering that the previous query ran 5 minutes ago?

CREATE OR REPLACE TABLE MTBL AS
SELECT *
FROM TABLE
(RESULT_SCAN(LAST_QUERY_ID())
);
It will cost credits if auto-suspend time of the Warehouse is less than 5 minutes.

No, it will not compute credits because we are re-using from the cache.

We cannot know because we do not know the auto-suspend time of the Warehouse.

Correct answer
It will cost credits.

Overall explanation
This is a tricky question. The SELECT command doesn't cost compute credits because we are re-using from the cache.

Creating the table structure doesn't cost compute credits either, BUT inserting the rows in the table requires compute power, so we will have to pay compute credits.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
A table is loaded using Snowflake Connector for Kafka.

What will happen if the file cannot be loaded?

The Kafka Connector deletes the files that cannot be loaded

The Kafka Connector moves files it cannot load to the stage associated with the user loading the target table

Correct answer
The Kafka Connector moves files it cannot load to the stage associated with the target table

The Kafka Connector loads the files to an error table with the columns RECORD_CONTENT and RECORD_METADATA

Overall explanation
When a table is loaded using the Snowflake Connector for Kafka and the file cannot be loaded, the Kafka Connector will move those files to the stage that is associated with the target table, allowing for further investigation or reprocessing of the files.

For more detailed information about the Kafka connector, refer to the official Snowflake documentation.

Question 38
Skipped
Which statements are true about the Snowflake Spark connector's internal and external transfer modes? (Choose two.)

The external transfer mode uses a temporary location managed by Snowflake to facilitate the transfer of data between two systems

Correct selection
The internal transfer mode uses a temporary location managed by Snowflake to facilitate the transfer of data between two systems

The internal transfer mode uses a storage location created and managed by the user to facilitate the transfer of data between two systems

Both transfer modes require explicit management of storage locations by the user

Correct selection
The external transfer mode uses a storage location created and managed by the user to facilitate the transfer of data between two systems

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
What are purposes for creating a storage integration? (Choose three.)

Correct selection
Support multiple external stages using one single Snowflake object.

Manage credentials from multiple cloud providers in one single Snowflake object.

Correct selection
Avoid supplying credentials when creating a stage or when loading or unloading data.

Control access to Snowflake data using a master encryption key that is maintained in the cloud provider’s key management service.

Create private VPC endpoints that allow direct, secure connectivity between VPCs without traversing the public internet.

Correct selection
Store a generated identity and access management (IAM) entity for an external cloud provider regardless of the cloud provider that hosts the Snowflake account.

Overall explanation
A storage integration in Snowflake allows for the creation of an IAM entity for external cloud providers, supports multiple external stages using a single object, and removes the need to supply credentials repeatedly when creating stages or handling data loading/unloading operations, enhancing both security and efficiency.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
One query takes a lot of time, and you see in the query profiler the following information:



What might be the cause of this?

The query is only selecting a few columns

The query is too large to fit in memory.

There is inefficient pruning.

Correct answer
A "exploding join" issue might be the problem.

Overall explanation
A "exploding join" issue is produced when users join tables without providing a join condition (resulting in a "Cartesian product") or providing a condition where records from one table match multiple records from another table, producing more tuples than it consumes. As we can see, it's a case of exploding join because Snowflake has produced hundreds of thousands of records (235.8k) with an input of hundreds of records (772 & 816).

For more detailed information, refer to the official Snowflake documentation.

Question 41
Skipped
Which of the following statements are correct about the TASK_HISTORY function? (Choose three)

Correct selection
The function returns a maximum of 10,000 rows

Correct selection
You can query the history of task usage within a specified date range. It returns both the completed and running tasks.

You can query the history of task usage within a specified date range. It only returns the completed tasks.

The function returns a maximum of 100 rows

Correct selection
It returns the task activity within the last 7 days or the next scheduled execution within the next 8 days.

The function returns a maximum of 1000 rows

Overall explanation
By default, the function returns 100 rows. However, you can specify the number of rows that you want to return (until a maximum of 10.000) with the RESULT_LIMIT parameter. It returns tasks that are SCHEDULED, EXECUTING, SUCCEEDED, FAILED, FAILED_AND_AUTO_SUSPENDED, CANCELLED, or SKIPPED, and you can also return only the ones that failed or were canceled using the ERROR_ONLY parameter.

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
When does a stream become stale?

When the source table is truncated

When it’s consumed

Correct answer
When its offset is outside of the data retention period for its source table

When it’s dropped

Overall explanation
Stale means that the offset is outside the data retention period for the source table, and in this case, the historical data for the source table is no longer accessible. You should recreate the stream to track new changes. You should consume the stream records within a transaction during the retention period for the table. This does not apply to streams on external tables, as they don't have a data retention period.

Question 43
Skipped
When will a multi-cluster warehouse start a new cluster if it’s running with the economy scaling policy?

Correct answer
Only if the system estimates there’s enough query load to keep the cluster busy for at least 6 minutes.

Only if the system estimates there’s enough query load to keep the cluster busy for at least 2 minutes.

Only if the system estimates there’s enough query load to keep the cluster busy indefinitely.

Only if the system estimates there’s enough query load to keep the cluster busy for at least 15 minutes.

Overall explanation
You can see the differences between these scaling policies at the following table:



Question 44
Skipped
The following diagram shows the process flow for Snowpipe auto-ingest with Amazon SNS with the following three steps:

Step 1: Data files are loaded in a stage

Step 2: An Amazon S3 event notification published by SNS informs Snowpipe - by way of an SQS queue - that files are ready to load. Snowpipe copies the files into a queue.

Step 3: A Snowflake-provided virtual warehouse loads data from the queued files into the target table based on parameters defined in the specified pipe


If an AWS Administrator accidentally deletes the SQS subscription to the SNS topic in Step 2, what will happen to the pipe which references the topic to receive event messages from Amazon S3?

The pipe will continue to receive the messages as Snowflake will automatically restore the subscription to the same SNS topic and will recreate the pipe by specifying the same SNS topic name in the pipe definition.

The pipe will no longer be able to receive the messages and the user must wait for 24 hours from the time when the SNS topic subscription was deleted. Pipe recreation is not required as the pipe will reuse the same subscription to the existing SNS topic after 24 hours.

Correct answer
The pipe will no longer be able to receive the messages. To restore the system immediately, the user needs to manually create a new SNS topic with a different name and then recreate the pipe by specifying the new SNS topic name in the pipe definition.

The pipe will continue to receive the messages as Snowflake will automatically restore the subscription by creating a new SNS topic and will recreate the pipe by specifying the new SNS topic name in the pipe definition.

Overall explanation
When the SNS topic subscription or the SNS topic is deleted, any pipe that references the topic will no longer receive event messages from Amazon S3.

For more detailed information about resolving the issue, refer to the official Snowflake documentation.

Question 45
Skipped
You have a dashboard that connects to Snowflake via JDBC. The dashboard is refreshed hundreds of times per day. The data is very stable, only changing once or twice per day.

The query run by the dashboard connector user never changes. How will Snowflake manage changing and non-changing data? (Choose three.)

Correct selection
Snowflake will re-use data from the Results Cache as long as it is still the most up-to-date data available

Correct selection
Snowflake will spin up a warehouse only if the underlying data has changed

Snowflake will always show the same data regardless of changes in the underlying tables

Snowflake will spin up a warehouse each time the dashboard is refreshed

Correct selection
Snowflake will show the most up-to-date data each time the dashboard is refreshed

Snowflake will compile results cache data from all user results so no warehouse is needed

Overall explanation
Until, data has not changed and the query is the same - Snowflake reuses the data from cache.

Question 46
Skipped
An Architect has been asked to clone schema STAGING as it looked one week ago, Tuesday June 1st at 8:00 AM, to recover some objects.

The STAGING schema has 50 days of retention.

The Architect runs the following statement:

CREATE SCHEMA STAGING_CLONE CLONE STAGING at (timestamp => '2021-06-01 08:00:00');

The Architect receives the following error: Time travel data is not available for schema STAGING. The requested time is either beyond the allowed time travel period or before the object creation time.

The Architect then checks the schema history and sees the following:

CREATED_ON|NAME|DROPPED_ON -

2021-06-02 23:00:00 | STAGING | NULL

2021-05-01 10:00:00 | STAGING | 2021-06-02 23:00:00

How can cloning the STAGING schema be achieved?

Correct answer
Rename the STAGING schema and perform an UNDROP to retrieve the previous STAGING schema version, then run the CLONE statement.

Undrop the STAGING schema and then rerun the CLONE statement.

Modify the statement: CREATE SCHEMA STAGING_CLONE CLONE STAGING at (timestamp => '2021-05-01 10:00:00');

Cloning cannot be accomplished because the STAGING schema version was not active during the proposed Time Travel time period.

Overall explanation
The schema history indicates that the STAGING schema was dropped on June 2nd and was originally created on May 1st. By renaming the STAGING schema and using the UNDROP feature, the Architect can restore the previous version of the STAGING schema, which will then allow for a successful clone operation at the desired timestamp of June 1st. This way, the data is still within the 50-day retention period, making it accessible for cloning.

For more detailed information about time travel, refer to the official Snowflake documentation.

For more detailed information about retention period, refer to the official Snowflake documentation.

Question 47
Skipped
Which command will use warehouse credits?

SELECT MIN(ID)
FROM MYTABLE
SELECT MAX(ID)
FROM MYTABLE
Correct answer
SELECT MAX(ID)
FROM MYTABLE
GROUP BY ID
SELECT COUNT(*)
FROM MYTABLE
Overall explanation
You can test it by going to the query profile of each query. The first three queries use the metadata cache, whereas the last one doesn’t do it because of the GROUP BY.

Question 48
Skipped
After running the function SYSTEM$CLUSTERING_INFORMATION in a table, it returns the following information:



What parameters indicate that the table is not well-clustered? (Choose three.)

High total partition count value.

Correct selection
Most micro-partitions are grouped at the lower end of the histogram, with most micro-partitions having an overlap depth between 64 and 128.

Correct selection
High average of overlapping micro-partitions.

Correct selection
Zero (0) constant micro-partitions out of 1156 total micro-partitions.

Low average of overlap depth across micro-partitions.

Overall explanation
A high number in the average_depth and average_overlaps indicates the table is not well-clustered; the higher the number of constant micro-partitions is, the more micro-partitions can be pruned from queries executed on the table, and in this case, is 0. Even if it doesn’t appear in the question picture, the query also returns some advice to help you identify it.

For example, after running it in my Snowflake account:



Question 49
Skipped
An Architect has created a stage for an Amazon S3 bucket Which of the following requires an SNS TOPIC to auto_refresh the object? (Choose two.)

Correct selection
Pipe

Search optimization

Correct selection
External table

Materialized view

Secure view

Overall explanation
If we want to refresh automatically an External table, we will need to use Amazon Simple Notification Services (SNS)

For more detailed information, refer to the official Snowflake documentation.

Same for pipes.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
There are two databases in an account, named fin_db and hr_db which contain payroll and employee data, respectively. Accountants and Analysts in the company require different permissions on the objects in these databases to perform their jobs. Accountants need read-write access to fin_db but only require read-only access to hr_db because the database is maintained by human resources personnel.

An Architect needs to create a read-only role for certain employees working in the human resources department.

Which permission sets must be granted to this role?

Correct answer
USAGE on database hr_db, USAGE on all schemas in database hr_db, SELECT on all tables in database hr_db.

USAGE on database hr_db, USAGE on all schemas in database hr_db, REFERENCES on all tables in database hr_db.

USAGE on database hr_db, SELECT on all schemas in database hr_db, SELECT on all tables in database hr_db.

MODIFY on database hr_db, USAGE on all schemas in database hr_db, USAGE on all tables in database hr_db.

Overall explanation
This means the role has the privilege to access the database, all schemas in the database, and select data from all tables within the database. It also ensures that the role cannot modify or update any data within the hr_db database.

Question 51
Skipped
When is the parameter INTEGRATION from Snowpipe required?

Correct answer
Only when configuring AUTO_INGEST for Google Cloud Storage or Microsoft Azure stages.

Only when configuring AUTO_INGEST for Amazon S3 stages using SNS.

Only when configuring ERROR_INTEGRATION for Amazon S3 stages using SNS.

Only when configuring ERROR_INTEGRATION for Google Cloud Storage or Microsoft Azure stages.

Overall explanation
This parameter specifies the existing notification integration used to access the storage queue and is necessary for Google Cloud Storage and Azure Stages. For AWS, we will use the parameter AWS_SNS_TOPIC.

Question 52
Skipped
How can we add a clustering key to the existing table MYTABLE in the columns USER and CREATED_AT?

ALTER TABLE MYTABLE CREATE CLUSTER_KEY (USER, CREATED_AT)

Correct answer
ALTER TABLE MYTABLE CLUSTER BY (USER, CREATED_AT)

ALTER TABLE MYTABLE CLUSTER BY USER AND CLUSTER BY CREATED_AT

ALTER TABLE MYTABLE ADD CLUSTER_KEY (USER, CREATED_AT)

Overall explanation
The CLUSTER BY param specifies one or more columns or column expressions in the table as the clustering. By default, no clustering key is defined for the table, as clustering keys are not intended or recommended for all tables.

Question 53
Skipped
Which of the following are valid context functions? (Choose three.)

Correct selection
CURRENT_REGION( )

CURRENT_WORKSHEET( )

CURRENT_CLOUD_INFRASTRUCTURE()

Correct selection
CURRENT_SESSION( )

Correct selection
CURRENT_CLIENT( )

Overall explanation
CURRENT_WORKSHEET() and CURRENT_CLOUD_INFRASTRUCTURE() are not valid context functions.

Question 54
Skipped
What is the difference between clustering a table and using searching optimization only talking about costs?

Search optimization involves storage and compute costs, whereas clustering only involves storage costs.

Search optimization involves storage and compute costs, whereas clustering only involves compute costs.

Search optimization involves storage and compute costs, whereas clustering doesn’t cost anything.

Correct answer
Both solutions involve storage and compute costs, so there is no difference between them talking about costs.

Overall explanation
A few comments:

Both clustering and search optimization in Snowflake incur storage and compute costs.

Search Optimization Service: Storage & Compute Costs.

Materialized View: Storage & Compute Costs.

Clustering: Storage & Compute Costs.

Query Acceleration Service: Only Compute Cost.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
Select all the different ways that we can access to the USER_NAME field if we have a table called MYTABLE with a variant column called JSONTEXT with the following structure: (Choose two.)



{
"USER_NAME": "Bob",
"USER_AGE ": 40,
"TECHNOLOGY": "Snowflake"
}
Correct selection
SELECT JSONTEXT['USER_NAME']
FROM MYTABLE
Correct selection
SELECT jsontext:USER_NAME
FROM MYTABLE
SELECT JSONTEXT->user_name
FROM MYTABLE
SELECT JSONTEXT['user_name']
FROM MYTABLE
SELECT JSONTEXT:user_name
FROM MYTABLE
Overall explanation
There are two ways to access a variant column in Snowflake: the dot notation and the bracket notation. Regardless of your notation, the column name is case-insensitive, but element names are case-sensitive. For that reason, it doesn’t matter if we access the JSONTEXT column in uppercase or lowercase, but we should access the USER_NAME column always with uppercase.

Question 56
Skipped
An Architect is making performance improvements to Snowflake processes and adjusting the sizing of virtual warehouses.

What technique does Snowflake recommend for determining which virtual warehouse size to select?

Correct answer
Experiment by running the same queries against warehouses of different sizes

Always start with an X-Small and increase the size if the query does not complete in 2 minutes

Use the default size Snowflake chooses

Use X-Large or above for tables larger than 1 GB

Overall explanation
Snowflake recommends experimenting by running the same queries across virtual warehouses of various sizes. This approach helps identify the most appropriate size based on actual performance metrics and workload requirements, leading to better optimization of resources.

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
Which commands can we use to return the last 1000 tasks that failed or were canceled in the last seven days?

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
RESULT_LIMIT => 1000,
STATUS => 'ERROR'
))
ORDER BY SCHEDULED_TIME;
Correct answer
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
RESULT_LIMIT => 1000,
ERROR_ONLY => TRUE
))
ORDER BY SCHEDULED_TIME;
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
RESULT_LIMIT => 1000
))
WHERE STATUS = 'FAILED' OR STATUS = 'CANCELLED'
ORDER BY SCHEDULED_TIME;
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
ORDER BY SCHEDULED_TIME;
Overall explanation
A few comments:

ERROR_ONLY Parameter: When set to TRUE, this parameter specifically "returns only task runs that failed or were cancelled"

RESULT_LIMIT: Sets the maximum number of rows to 1000 as requested

Time Range: The TASK_HISTORY function by default "returns the history of task usage for your entire Snowflake account" and "can return all executions run in the past 7 days"

For more detailed information, refer to the official Snowflake documentation.

Question 58
Skipped
A company’s client application supports multiple authentication methods, and is using Okta.

What is the best practice recommendation for the order of priority when applications authenticate to Snowflake?

1. Password

2. Key Pair Authentication, mostly used for production environment users

3. Okta native authentication

4. OAuth (either Snowflake OAuth or External OAuth)

5. External browser, SSO

Correct answer
1. OAuth (either Snowflake OAuth or External OAuth)

2. External browser

3. Okta native authentication

4. Key Pair Authentication, mostly used for service account users

5. Password

1. Okta native authentication

2. Key Pair Authentication, mostly used for production environment users

3. Password

4. OAuth (either Snowflake OAuth or External OAuth)

5. External browser, SSO

1. External browser, SSO

2. Key Pair Authentication, mostly used for development environment users

3. Okta native authentication

4. OAuth (ether Snowflake OAuth or External OAuth)

5. Password

Overall explanation
According to the authentication best practices, this should be the priority order:

#1: OAuth (either Snowflake OAuth or External OAuth)

#2: External Browser

#3: Okta native authentication

#4: Key Pair Authentication

#5: Password, this should be the last option.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
A company has a table that has corrupted data, named Data. The company wants to recover the data as it was 5 minutes ago using cloning and Time Travel.

What command will accomplish this?

Correct answer
CREATE TABLE Recover_Data CLONE Data AT(OFFSET => -60*5);

CREATE TABLE Recover Data CLONE Data AT(TIME => -60*5);

CREATE CLONE Recover_Data FROM Data AT(OFFSET => -60*5);

CREATE CLONE TABLE Recover_Data FROM Data AT(OFFSET => -60*5);

Overall explanation
For more detailed information about the syntax, refer to the official Snowflake documentation.

Question 60
Skipped
What Snowflake features should be leveraged when modeling using Data Vault?

Scaling up the virtual warehouses will support parallel processing of new source loads

Data needs to be pre-partitioned to obtain a superior data access performance

Snowflake’s ability to hash keys so that hash key joins can run faster than integer joins

Correct answer
Snowflake’s support of multi-table inserts into the data model’s Data Vault tables

Overall explanation
Another cool feature in Snowflake is the ability to load multiple tables at the same time using a single data source. This is called multi-table insert (MTI).

This is very useful for loading the Raw Data Vault layer in Data Vault2 modeling, where Hubs, Links and Sats are loaded simultaneously.

Question 61
Skipped
Which privilege is required for a role to be able to resume a suspended warehouse if auto-resume is not enabled?

USAGE

Correct answer
OPERATE

MODIFY

MONITOR

Overall explanation
To resume a suspended warehouse when auto-resume is not enabled, a role requires the OPERATE privilege. This privilege allows the role to perform operations such as starting and stopping the warehouse.

For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
What is the best practice to follow when calling the Snowpipe loadHistoryScan endpoint?

Correct answer
Reading the last 10 minutes of history every 8 minutes

Read the last seven days of history every hour

Reading the last 30 minutes of history every 5 minutes

Read the last 24 hours of history every minute

Overall explanation
This endpoint is rate limited to avoid excessive calls. To help prevent exceeding the rate limit (error code 429), Snowflake recommends relying more heavily on insertReport than loadHistoryScan.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
A Snowflake Architect wants to unload data from a relational table sized 5 GB using CSV. The extract needs to be as performant as possible.

What should the Architect do?

Use Parquet as the unload file format, using Parquet's default compression feature.

Use a regular expression in the stage specification of the COPY command to restrict parsing time.

Increase the default MAX_FILE_SIZE to 5 GB and set SINGLE = true to produce a single file.

Correct answer
Leave the default MAX_FILE_SIZE to 16 MB to take advantage of parallel operations.

Overall explanation
Snowflake can perform the unload operation in parallel, which significantly increases the performance of extracting data. This allows for more efficient resource utilization and faster processing compared to using a single large file.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
While loading CSV data using the COPY INTO statement, a Data Architect encounters the following error.

Number of columns in file (15) does not match that of the corresponding table (14)

Which approach should the Data Architect take to solve this problem and load all the fields in the file into the table? (Choose two.)

Modify the file data to enclose fields with a delimiter. Leverage the FIELD_OPTIONALLY_ENCLOSED_BY option in the file format during the load process.

Set the copy option FORCE to true.

Modify the file data to use a different file format. Change the file format type in the file format options during the loading process.

Correct selection
Do not modify the file data. Change the ERROR_ON_COLUMN_COUNT_MISMATCH option in the file format to false during the loading process.

Correct selection
Make necessary changes in the table DDL to support all the columns in the file.

Overall explanation
A few comments:

Make necessary changes in the table DDL to support all the columns in the file: Adjusting the table schema to match the number of columns in the file ensures all data is loaded properly without errors.

Do not modify the file data. Change the ERROR_ON_COLUMN_COUNT_MISMATCH option in the file format to false during the loading process: This allows the data to load even if the file has more columns than the table, skipping the mismatch error during the process. ERROR_ON_COLUMN_COUNT_MISMATCH, if set to FALSE, an error is not generated and the load continues. If the file is successfully loaded:

Modifying the file data to use a different file format or modifying the file data to enclose fields with a delimiter will not fix the column mismatch.

Question 65
Skipped
A company is using a Snowflake account in Azure. The account has SAML SSO set up using ADFS as a SCIM identity provider. To validate Private Link connectivity, an Architect performed the following steps:

Confirmed Private Link URLs are working by logging in with a username/password account

Verified DNS resolution by running nslookups against Private Link URLs

Validated connectivity using SnowCD

Disabled public access using a network policy set to use the company’s IP address range

However, the following error message is received when using SSO to log into the company account:

IP XX.XXX.XX.XX is not allowed to access Snowflake. Contact your local security administrator.

What steps should the Architect take to resolve this error and ensure that the account is accessed using only Private Link? (Choose two.)

Generate a new SCIM access token using system$generate_scim_access_token and save it to Azure AD.

Open a case with Snowflake Support to authorize the Private Link URLs’ access to the account.

Correct selection
Update the configuration of the Azure AD SSO to use the Private Link URLs.

Update the Snowflake IDP metadata file to include Private Link URLs.

Correct selection
Alter the Azure security integration to use the Private Link URLs.

Overall explanation
A few comments:

The security integration defines how Snowflake communicates with Azure AD.

SSO should use Private Link, not public endpoints.

After modifying the private links, SSO will only work if we first update the security integration and then update the configuration at the Azure AD level.

If the SSO metadata URL in Azure AD still points to the public Snowflake endpoint, authentication will fail when public access is disabled.

SCIM is for user provisioning, not authentication. This does not impact SSO login failures.

For more detailed information, refer to the official Snowflake documentation.

https://community.snowflake.com/s/article/HOW-TO-Setup-SSO-with-Azure-AD-and-the-Snowflake-New-URL-Format-or-Privatelink