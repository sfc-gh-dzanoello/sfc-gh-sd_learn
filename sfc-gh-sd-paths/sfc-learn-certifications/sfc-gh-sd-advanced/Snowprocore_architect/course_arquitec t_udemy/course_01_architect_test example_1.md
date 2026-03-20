uestion 1
Incorrect
A retail company has 2000+ stores spread across the country. Store Managers report that they are having trouble running key reports related to inventory management, sales targets, payroll, and staffing during business hours. The Managers report that performance is poor and time-outs occur frequently.

Currently all reports share the same Snowflake virtual warehouse.

How should this situation be addressed? (Choose two.)

Your selection is incorrect
Use a Business Intelligence tool for in-memory computation to improve performance.

Your selection is correct
Configure the virtual warehouse to be multi-clustered.

Correct selection
Configure a dedicated virtual warehouse for the Store Manager team.

Configure the virtual warehouse to size 4-XL.

Advise the Store Manager team to defer report execution to off-business hours.

Overall explanation
2000+ stores involve many managers accessing reports at the same time during business hours. The performance problems have to do with concurrency issues.

The VWH multicluster is well suited to handle this type of situation, scaling out the number of clusters and supporting more users using reports in parallel.

About other options:

Recommending Store Managers to use the reports after hours is not a very good recommendation.

Scaling up the size of the virtual warehouse to 4-XL can improve performance but can be cost-inefficient and does not solve the underlying issue of concurrent workload management. This approach to handle concurrency is not recommended by Snowflake

Key comment: "CUrrently all reports share the same Snowflake VWH". Configuring a dedicated virtual warehouse for the Store Manager team ensures that their reports do not compete for resources with other workloads. This separation can significantly improve performance by isolating their queries from those of other users.

Using a Business Intelligence tool for in-memory computation might help with some performance improvements but does not address the root cause of resource contention in Snowflake.

For more detailed information about VWH and performance, refer to the official Snowflake documentation.

Question 2
Incorrect
How does Snowflake store security-related information for an external function that calls code that is executed outside of Snowflake?

Secure storage

Correct answer
API integration

Your answer is incorrect
Access control

Restricted access

Overall explanation
Snowflake uses API integration to securely store and manage security-related information for an external function that calls code executed outside of Snowflake. This ensures secure communication and handling of credentials or tokens needed for external services.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Correct
A company is using Snowflake in Azure in the Netherlands. The company analyst team also has data in JSON format that is stored in an Amazon S3 bucket in the AWS Singapore region that the team wants to analyze.

The Architect has been given the following requirements:

1. Provide access to frequently changing data

2. Keep egress costs to a minimum

3. Maintain low latency

How can these requirements be met with the LEAST amount of operational overhead?

Use AWS Transfer Family to replicate data between the S3 bucket in AWS Singapore and an Azure Netherlands Blob storage, then use an external table against the Blob storage.

Copy the data between providers from S3 to Azure Blob storage to collocate, then use Snowpipe for data ingestion.

Use an external table against the S3 bucket in AWS Singapore and copy the data into transient tables.

Your answer is correct
Use a materialized view on top of an external table against the S3 bucket in AWS Singapore.

Overall explanation
A few comments:

Materialized views can be created on top of external tables to ensure that the solution addresses the requirement of low latency.

By using an external table, the data remains in AWS and does not need to be stored in the Azure blob container, making the AWS cloud provider more cost efficient. The data is queried directly from its source location in S3. Using the other alternatives may have more egress cost and more cost of using third party tools.

About other options:

Copying the data from S3 to Azure Blob Storage would incur significant egress costs due to transferring data between cloud providers.

Copying data into transient tables increases operational overhead and may increase the latency.

For more detailed information about external tables and materialized views, refer to the official Snowflake documentation.

Question 4
Incorrect
A Snowflake Architect created a new data share and would like to verify that only specific records in secure views are visible within the data share by the consumers.

What is the recommended way to validate data accessibility by the consumers?

Correct answer
Set the session parameter called SIMULATED_DATA_SHARING_CONSUMER as shown below in order to impersonate the consumer accounts.

alter session set simulated_data_sharing_consumer = 'Consumer Acct1'

Create reader accounts as shown below and impersonate the consumers by logging in with their credentials.

create managed account reader_acct1 admin_name = user1 , admin_password = 'Sdfed43da!44' , type = reader;

Alter the share settings as shown below, in order to impersonate a specific consumer account.

alter share sales_share set accounts = 'Consumer1' share_restrictions = true

Your answer is incorrect
Create a row access policy as shown below and assign it to the data share.

create or replace row access policy rap_acct as (acct_id varchar) returns boolean -> case when 'acct1_role' = current_role() then true else false end;

Overall explanation
When defining a secure object for sharing with consumer accounts, an important additional step is to validate that the object is correctly configured to display only the data intended for sharing. This is especially crucial if you want to restrict data access based on the consumer account.

To assist with this validation, Snowflake offers the SIMULATED_DATA_SHARING_CONSUMER session parameter. This parameter is specifically designed for use with secure views and secure materialized views, but it does not support secure UDFs. By setting this parameter in a session, you can simulate querying a secure view as a user from any of the consumer accounts you intend to share the view with.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Incorrect
Which data models can be used when modeling tables in a Snowflake environment? (Choose three.)

Your selection is incorrect
Bayesian hierarchical model

Your selection is correct
Dimensional/Kimball

Graph model

Your selection is incorrect
Data lake

Correct selection
Inmon/3NF

Correct selection
Data vault

Overall explanation
Actually this is not a Snowflake related question, it is quite simple to answer with basic data modeling knowledge.

About the options:

Dimensional/Kimball, widely known type of modeling introduced by the father of the DWH, Kimball. It organizes data into fact and dimension tables, facilitating fast retrieval for analytical queries.

Inmon/3NF, Inmon's approach focuses on creating a normalized data model (3NF) to ensure data integrity and minimize redundancy.

Data Vault, Lindsted's approach is designed for long-term historical storage of data from multiple operational systems. It provides a highly scalable way to manage and track historical data, focusing on auditability and resilience.

Question 6
Incorrect
Why might a Snowflake Architect use a star schema model rather than a 3NF model when designing a data architecture to run in Snowflake? (Choose two.)

Snowflake cannot handle the joins implied in a 3NF data model.

Your selection is correct
The Architect wants to present a simple flattened single view of the data to a particular group of end users.

The Architect wants to remove data duplication from the data stored in Snowflake.

Your selection is correct
The BI tool needs a data model that allows users to summarize facts across different dimensions, or to drill down from the summaries.

Your selection is incorrect
The Architect is designing a landing zone to receive raw data into Snowflake.

Overall explanation
About the options:

Snowflake can handle the joins implied in a 3NF data model. Databricks (based on Spark) does not recommend highly normalized models, but this is not the case with Snowflake.

Star schemas are designed to facilitate efficient querying. They are particularly well-suited for BI tools that need to summarize facts across various dimensions and allow users to drill down into detailed data. This structure supports fast aggregation and query performance, which is crucial for reporting and analytics.

A star schema presents data in a denormalized, flattened structure, which simplifies data access and querying. This is beneficial for end users who need quick access to data without understanding complex joins and relationships typical in a 3NF model.

3NF is chosen to avoid duplicates in different entities, just the opposite of Star Schema.

Question 7
Correct
A Snowflake Architect is designing a multi-tenant application strategy for an organization in the Snowflake Data Cloud and is considering using an Account Per Tenant strategy.

Which requirements will be addressed with this approach? (Choose two.)

Your selection is correct
Tenant data shape may be unique per tenant.

Your selection is correct
Security and Role-Based Access Control (RBAC) policies must be simple to configure.

There needs to be fewer objects per tenant.

Compute costs must be optimized.

Storage costs must be optimized.

Overall explanation
About other options:

APT approach may result in more objects, as each tenant has its own isolated account with its own set of objects

APT can increase costs because you lose the ability to pool compute across tenants. Each tenant's account may require separate compute resources.

APT approach does not inherently optimize storage costs. Instead, tenants may have separate storage costs.

For more detailed information about multi tenant patterns, refer to the official Snowflake documentation.

Question 8
Correct
A user named USER_01 needs access to create a materialized view on a schema EDW.STG_SCHEMA. How can this access be provided?

Your answer is correct
GRANT ROLE NEW_ROLE TO USER USER_01;

GRANT CREATE MATERIALIZED VIEW ON SCHEMA EDW.STG_SCHEMA TO NEW_ROLE;

GRANT CREATE MATERIALIZED VIEW ON SCHEMA EDW.STG_SCHEMA TO USER USER_01;

GRANT ROLE NEW_ROLE TO USER_01;

GRANT CREATE MATERIALIZED VIEW ON EDW.STG_SCHEMA TO NEW_ROLE;

GRANT CREATE MATERIALIZED VIEW ON DATABASE EDW TO USER USER_01;

Overall explanation
In Snowflake, privileges are typically granted to roles rather than directly to users.

About other options:

Snowflake is a technology that relies on Role Based Access Control for privilege management, we discard options that directly grant privileges to users.

One of the options is almost correct, but the syntax is incomplete. It should explicitly mention ON SCHEMA.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Correct
Which query will identify the specific days and virtual warehouses that would benefit from a multi-cluster warehouse to improve the performance of a particular workload?

SELECT TO_DATE(START_TIME) AS DATE,
WAREHOUSE_NAME,
BYTES_SCANNED,
BYTES_SPILLED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY"
HAVING BYTES_SPILLED>BYTES_SCANNED;
SELECT TO_DATE(START_TIME) AS DATE,
WAREHOUSE_NAME,
BYTES_SCANNED,
BYTES_SPILLED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."WAREHOUSE_LOAD_HISTORY"
HAVING BYTES_SPILLED>BYTES_SCANNED;
Your answer is correct
SELECT TO_DATE(START_TIME) AS DATE,
WAREHOUSE_NAME,
SUM(AVG_RUNNING) AS SUM_RUNNING,
SUM(AVG_QUEUED_LOAD) AS SUM_QUEUED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."WAREHOUSE_LOAD_HISTORY"
GROUP BY 1,2
HAVING SUM(AVG_QUEUED_LOAD) > 0;
SELECT TO_DATE(START_TIME) AS DATE,
WAREHOUSE_NAME,
BYTES_SPILLED_TO_LOCAL_STORAGE,
SUM(AVG_QUEUED_LOAD) AS SUM_QUEUED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY"
HAVING BYTES_SPILLED_TO_LOCAL_STORAGE > 0;
Overall explanation
To identify the specific days and virtual warehouses that would benefit from a multi-cluster warehouse to improve the performance of a particular workload, we should find those virtual warehouses with a significant queued load.

About the options:

With BYTES_SPILLED metric we can identify whether data is spilling to storage. This can have a negative impact on query performance (especially if the query has to spill to remote storage). To alleviate this, Snowflake recommends using a larger warehouse (Scaling up, not what the question is asking)

AVG_QUEUED_LOAD shows the value for queries queued because the warehouse was overloaded, thus the query must contain this metric

By grouping the results and filtering with HAVING SUM(AVG_QUEUED_LOAD) > 0, it highlights the days and virtual warehouses where there is a significant queued load. This indicates that these warehouses may benefit from a multi-cluster configuration to improve performance by handling more concurrent queries and reducing queuing times.

For more detailed information about reducing queues, refer to the official Snowflake documentation.

For more detailed information about WAREHOUSE_LOAD_HISTORY, refer to the official Snowflake documentation.

Question 10
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

Correct answer
Anyone with the PI_ANALYTICS role will see the last 4 characters of the CREDITCARDNO column data in clear text.

The sysadmin can see the CREDITCARDNO column data in clear text.

Anyone with the PI_ANALYTICS role will see the CREDITCARDNO column as ***MASKED***.

The owner of the table will see the CREDITCARDNO column data in clear text.

Overall explanation
A few comments:

The masking policy explicitly allows users with the PI_ANALYTICS role to see the last four characters.

Being the owner of the table does not grant exemption from the masking policy.

Since the question specifies that no additional roles are granted to system roles, only users with the PI_ANALYTICS role will be able to see the last four characters of CREDITCARDNO in clear text.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
Which Snowflake objects can be used in a data share? (Choose two.)

Stored procedure

Correct selection
External table

Standard view

Correct selection
Secure view

Stream

Overall explanation
Secure Data Sharing enables you to share specific objects from a database within your account with other Snowflake accounts. The types of Snowflake objects that can be shared include databases, tables, dynamic tables, external tables, Iceberg tables, secure views, secure materialized views, and secure user-defined functions (UDFs).

For more detailed information, refer to the official Snowflake documentation.

Question 12
Skipped
A company's Architect needs to find an efficient way to get data from an external partner, who is also a Snowflake user. The current solution is based on daily JSON extracts that are placed on an FTP server and uploaded to Snowflake manually. The files are changed several times each month, and the ingestion process needs to be adapted to accommodate these changes.

What would be the MOST efficient solution?

Keep the current structure but request that the partner stop changing files, instead only appending new files.

Ask the partner to set up a Snowflake reader account and use that account to get the data for ingestion.

Ask the partner to use the data lake export feature and place the data into cloud storage where Snowflake can natively ingest it (schema-on-read).

Correct answer
Ask the partner to create a share and add the company's account.

Overall explanation
Key comments:

External partner is also a Snowflake user.

JSONs are already uploaded to Snowflake manually.

This is a typical use case for Snowflake Secure Data Sharing. Data Sharing allows one Snowflake account to securely share data with another Snowflake account without needing to copy or move the data. It provides real-time access to the shared data and eliminates the need for manual file transfers and ingestion processes

About other options:

While placing data into cloud storage for schema-on-read ingestion is possible, it still involves data movement and does not provide the same level of efficiency and real-time access as secure data sharing.

Asking the partner to stop changing files is impractical and does not address the need for an efficient and automated solution.

Since both users have Snowflake accounts, creating a reader account makes no sense.

Question 13
Skipped
A company is designing high availability and disaster recovery plans and needs to maximize redundancy and minimize recovery time objectives for their critical application processes.

Cost is not a concern as long as the solution is the best available.



The plan so far consists of the following steps:

1. Deployment of Snowflake accounts on two different cloud providers.

2. Selection of cloud provider regions that are geographically far apart.

3. The Snowflake deployment will replicate the databases and account data between both cloud provider accounts.

4. Implementation of Snowflake client redirect.



What is the MOST cost-effective way to provide the HIGHEST uptime and LEAST application disruption if there is a service event?

Correct answer
Connect the applications using the - URL.

Use the Business Critical Snowflake edition.

Connect the applications using the - URL.

Use the Virtual Private Snowflake (VPS) edition.

Connect the applications using the - URL.

Use the Standard Snowflake edition.

Connect the applications using the - URL.

Use the Enterprise Snowflake edition.

Overall explanation
The Business Critical Snowflake edition includes:

Advanced data protection and security measures.

Options for redirecting client connections across Snowflake accounts to maintain business continuity and facilitate disaster recovery.

Failover and failback functionalities between Snowflake accounts to support ongoing operations during unforeseen events.

It is cheaper than the VPS edition.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
An Architect is designing a file ingestion recovery solution. The project will use an internal named stage for file storage. Currently, in the case of an ingestion failure, the Operations team must manually download the failed file and check for errors.

Which downloading method should the Architect recommend that requires the LEAST amount of operational overhead?

Use the GET command in Snowsight to retrieve the file.

Use the Snowflake Connector for Python, connect to remote storage and download the file.

Use the Snowflake API endpoint and download the file.

Correct answer
Use the GET command in SnowSQL to retrieve the file.

Overall explanation
GET command in SnowSQL can be executed directly in SnowSQL, Snowflake's CLI client. It is simple and doesn't require additional development or configuration (only basic connection configuration), making it the least operationally intensive.

GET command downloads data files from one of the following internal stage types to a local directory or folder on a client machine

About other options:

The Snowflake Connector for Python allows for process automation but requires additional setup and scripting, which can lead to increased operational overhead.

Additionally, the GET command in Snowsight cannot be executed from the Worksheets page in the Snowflake web interface. Instead, users should utilize the SnowSQL client to download data files or refer to the documentation for the specific Snowflake client to confirm support for this command.

Snowflake API endpoint necessitates further setup for authentication, scripting, and potentially managing API rate limits and other configurations, contributing to more operational overhead.

For more detailed information about SnowSQL, refer to the official Snowflake documentation.

For more detailed information about GET command, refer to the official Snowflake documentation.

Question 15
Skipped
The following table exists in the production database:



A regulatory requirement states that the company must mask the username for events that are older than six months based on the current date when the data is queried.

How can the requirement be met without duplicating the event data and making sure it is applied when creating views using the table or cloning the table?

Correct answer
Use a masking policy on the username column with event_timestamp as a conditional column.

Use a masking policy on the username column using an entitlement table with valid dates.

Use a row level policy on the user_events table using an entitlement table with valid dates.

Use a secure view on the user_events table using a case statement on the username column.

Overall explanation
A masking policy can be applied to the username column to enable conditional data masking based on the event_timestamp. This guarantees that usernames associated with events older than six months are hidden in queries, while data from the most recent six months remains accessible.

About other options:

Utilizing an entitlement table introduces unnecessary complexity, as masking policies are specifically designed to efficiently address such requirements.

A row-level policy is not needed in this case, since the issue pertains to column-specific masking rather than row-specific access.

Implementing a masking policy will dynamically enforce this requirement across all queries and views. Importantly, masking policies defined on the table will remain intact even when cloning to a different database.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
What considerations need to be taken when using database cloning as a tool for data lifecycle management in a development environment? (Choose two.)

Any pipes in the source referring to external stages are not cloned.

Correct selection
The clone inherits all granted privileges of all child objects in the source object, excluding the database.

Correct selection
Any pipes in the source referring to internal stages are not cloned.

The clone inherits all granted privileges of all child objects in the source object, including the database.

Any pipes in the source are not cloned.

Overall explanation
A few comments:

Only pipes that reference external stages are cloned. When a database or schema is cloned, any pipes within the source container that refer to an internal (i.e., Snowflake) stage will not be included in the clone.

Note that the clone of the container itself (database or schema) does not inherit the privileges granted on the source container.

A clone inherits all grants for child objects but not for the database itself. If the source object is a database or schema, the clone will inherit all granted privileges on the clones of any child objects contained within the source object.

For databases, these child objects include schemas, tables, views, and more. For schemas, the contained objects consist of tables and views. It’s important to note that the clone of the container itself (whether it be a database or schema) does not inherit the privileges granted on the original container.

For more detailed information about Cloning Pipes, refer to the official Snowflake documentation.

For more detailed information about cloning objects, refer to the official Snowflake documentation.

Question 17
Skipped
When activating Tri-Secret Secure in a hierarchical encryption model in a Snowflake account, at what level is the customer-managed key used?



At the table level (TMK)

At the micro-partition level

Correct answer
At the account level (AMK)

At the root level (HSM)

Overall explanation
A few comments:

When activating Tri-Secret Secure in a hierarchical encryption model in a Snowflake account, the customer-managed key is used at at the account level (AMK)

Tri-Secret Secure combines a Snowflake-maintained key with a customer-managed key from the cloud provider platform hosting your Snowflake account to form a composite master key for protecting your Snowflake data.

This composite master key functions as an account master key (AMK) and wraps all the keys within the hierarchy.

For more detailed information about key management in Snowflake, refer to the official Snowflake documentation.

For more detailed information about Tri-Secret Secure, refer to the official Snowflake documentation.

Question 18
Skipped
A table for IOT devices that measures water usage is created. The table quickly becomes large and contains more than 2 billion rows.





The general query patterns for the table are:

1. Deviceld, IOT_timestamp and Customerld are frequently used in the filter predicate for the select statement

2. The columns City and DeviceManufacturer are often retrieved

3. There is often a count on Uniqueld



Which field(s) should be used for the clustering key?

IOT_timestamp

UniqueId

Correct answer
DeviceId and CustomerId

City and DeviceManufacturer

Overall explanation
Based on the provided information about the table water_iot and the general query patterns, the best field(s) to use for the clustering key are those that are frequently used in filter predicates. This will help to optimize query performance by clustering data that is commonly queried together.

Given this information about general query patterns, the optimal clustering key would be DeviceId and CustomerId.

About the options:

DeviceId and CustomerId are frequently used in filter predicates, clustering the data based on these fields will improve query performance for common queries. But, what about IOT_timestamp?

IOT_timestamp is also frequently used in filters, combining it with DeviceId and CustomerId may not be as beneficial as DeviceId and CustomerId together but timestamp fields have high cardinality. A column with very high cardinality is also typically not a good candidate to use as a clustering key directly. For example, a column that contains nanosecond timestamp values would not make a good clustering key.

City and DeviceManufacturer are often retrieved but are not primarily used in filter predicates.

UniqueId is often used for counting, but it doesn't help with filtering and clustering related data together.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
A company has a Snowflake environment running in AWS us-west-2 (Oregon). The company needs to share data privately with a customer who is running their Snowflake environment in Azure East US 2 (Virginia).

What is the recommended sequence of operations that must be followed to meet this requirement?

1. Create a reader account in Azure East US 2 (Virginia)

2. Create a share and add the database privileges to the share

3. Add the reader account to the share

4. Share the reader account's URL and credentials with the customer

1. Ask the customer to create a new Snowflake account in Azure EAST US 2 (Virginia)

2. Create a share and add the database privileges to the share

3. Alter the share and add the customer's Snowflake account to the share

1. Create a share and add the database privileges to the share

2. Create a new listing on the Snowflake Marketplace

3. Alter the listing and add the share

4. Instruct the customer to subscribe to the listing on the Snowflake Marketplace

Correct answer
1. Create a new Snowflake account in Azure East US 2 (Virginia)

2. Set up replication between AWS us-west-2 (Oregon) and Azure East US 2 (Virginia) for the database objects to be shared

3. Create a share and add the database privileges to the share

4. Alter the share and add the customer's Snowflake account to the share

Overall explanation
Use replication to allow data providers to securely share data with data consumers across different regions and cloud platforms. This sequence ensures that data can be privately shared across cloud platforms by first replicating the required database objects to the new Snowflake account in the Azure region and then configuring the appropriate shares for the customer.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
Which performance optimization techniques in Snowflake have storage costs associated with them? (Select THREE).

Correct selection
Clustering a table

Using the query acceleration service

Rekeying

Using a muiti-cluster virtual warehouse

Correct selection
Using a matenalized view

Correct selection
Using the search optimization service

Overall explanation
These performance optimization techniques in Snowflake come with additional storage costs. The search optimization service and materialized views store extra metadata to enhance query performance, while clustering a table creates additional storage structures to improve query efficiency based on how the data is organized.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
What is a characteristic of Role-Based Access Control (RBAC) as used in Snowflake?

A user can use a "super-user" access along with SECURITYADMIN to bypass authorization checks and access all databases, schemas, and underlying objects.

A user can create managed access schemas to support current and future grants and ensure only object owners can grant privileges to other roles.

Privileges can be granted at the database level and can be inherited by all underlying objects.

Correct answer
A user can create managed access schemas to support future grants and ensure only schema owners can grant privileges to other roles.

Overall explanation
A few comments:

In Snowflake, there is no notion of a "super-user" or "super-role" that can circumvent authorization checks. Within managed access schemas, object owners forfeit their ability to make grant decisions.

Only the schema owner or a role with the MANAGE GRANTS privilege has the authority to grant privileges on objects within the schema, which helps centralize the management of permissions.

For more detailed information about object cloning, refer to the official Snowflake documentation.

Question 22
Skipped
When using Multi-Factor Authentication (MFA) with the following command:

--mfa-passcode-in-password
The following password prompt is forced:
$ snowsql ... -P ...
What will the password be if the MFA token is 123456 and the password is SNOWFLAKE?

123456-SNOWFLAKE

Correct answer
SNOWFLAKE123456

123456SNOWFLAKE

SNOWFLAKE-123456

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
The Business Intelligence team reports that when some team members run queries for their dashboards in parallel with others, the query response time is getting significantly slower.

What can a Snowflake Architect do to identify what is occurring and troubleshoot this issue?

Use larger warehouses to speed up the queries running in parallel. Identify the queries running in parallel using this query:

SELECT QUERY_ID,
USER_NAME,
WAREHOUSE_NAME,
WAREHOUSE_SIZE,
BYTES_SCANNED,
BYTES_SPILLED_TO_REMOTE_STORAGE,
BYTES_SPILLED_TO_REMOTE_STORAGE / BYTES_SCANNED AS SPILLING_READ_RATIO
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY"
WHERE BYTES_SPILLED_TO_REMOTE_STORAGE > BYTES_SCANNED * 5
ORDER BY SPILLING_READ_RATIO DESC;
Identify which queries are spilled to remote storage and change the warehouse parameters to address this issue. Identify the issue by running this query:

SELECT QUERY_ID,
SUBSTR(QUERY_TEXT, 1, 50) PARTIAL_QUERY_TEXT,
USER_NAME,
WAREHOUSE_NAME,
WAREHOUSE_SIZE,
BYTES_SCANNED,
BYTES_SPILLED_TO_REMOTE_STORAGE,
START_TIME, END_TIME,
TOTAL_ELAPSED_TIME/1000 TOTAL_ELAPSED_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE BYTES_SPILLED_TO_REMOTE_STORAGE > 0
AND START_TIME > DATEADD('days', -45, CURRENT_DATE)
ORDER BY BYTES_SPILLED_TO_REMOTE_STORAGE DESC LIMIT 10;
Correct answer
Introduce multi-cluster warehouses to help with concurrent queries. Identify the concurrent queries by running this query:

SELECT TO_DATE(START_TIME) AS DATE,
WAREHOUSE_NAME,
SUM(AVG_RUNNING) AS SUM_RUNNING,
SUM(AVG_QUEUED_LOAD) AS SUM_QUEUED
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."WAREHOUSE_LOAD_HISTORY"
WHERE TO_DATE(START_TIME) >= DATEADD(month, -1, CURRENT_TIMESTAMP())
GROUP BY 1,2 HAVING SUM(AVG_QUEUED_LOAD) > 0;
Increase the size of the warehouse cache to speed up concurrent queries. Identify the concurrent queries using this query:

SELECT WAREHOUSE_NAME, COUNT(*) AS QUERY_COUNT, SUM(BYTES_SCANNED) AS BYTES_SCANNED,
SUM(BYTES_SCANNED*PERCENTAGE_SCANNED_FROM_CACHE) AS BYTES_SCANNED_FROM_CACHE,
SUM(BYTES_SCANNED*PERCENTAGE_SCANNED_FROM_CACHE) / SUM(BYTES_SCANNED) AS PERCENT_SCANNED_FROM_CACHE
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY"
WHERE START_TIME >= DATEADD(month, -1, current_timestamp()) AND BYTES_SCANNED > 0
GROUP BY 1 ORDER BY 5;
Overall explanation
The query response time is noticeably slower when multiple users execute queries simultaneously. This indicates a queuing and concurrency issue, which can be addressed through Multi-cluster Warehouses and scaling out. Multi-cluster warehouses are specifically engineered to manage queuing and performance challenges associated with a high volume of concurrent users and queries. Additionally, they can automate resource allocation if the number of users or queries varies significantly.

For more detailed information about reducing queues, refer to the official Snowflake documentation.

For more detailed information about managing concurrency, refer to the official Snowflake documentation.

Question 24
Skipped
A Snowflake Architect is designing a multiple-account design strategy.

This strategy will be MOST cost-effective with which scenarios?

The company must use a specific network policy for certain users to allow and block given IP addresses.

The company needs to support different role-based access control features for the development, test, and production environments.

The company security policy mandates the use of different identity provider instances for the development, test, and production environments.

Correct answer
The company needs to share data between two databases, where one must support Payment Card Industry Data Security Standard (PCI DSS) compliance but the other one does not.

Overall explanation
When one database must support PCI DSS compliance and another does not, separating them into different Snowflake accounts is cost-effective. The account needing PCI DSS compliance can be set up with the Business Critical Edition, which includes advanced security features necessary for compliance. The other account can use a lower-cost edition, avoiding unnecessary expenses for compliance features that aren't needed.

About other options:

Managing role-based access control (RBAC) within a single Snowflake account is more cost-effective than creating multiple accounts. Snowflake's RBAC system is designed to handle different environments (development, test, production) within the same account using roles and privileges, avoiding the overhead of managing multiple accounts.

While network policies are applied at the account level, managing specific policies for certain users does not always justify multiple accounts.

It is possible to configure Snowflake so different users authenticate using different identity providers.

For more detailed information about network policies, refer to the official Snowflake documentation.

For more detailed information about multiple IdP instances, refer to the official Snowflake documentation.

For more detailed information about Snowflake editions and security features, refer to the official Snowflake documentation.

Question 25
Skipped
An Architect is troubleshooting a query with poor performance using the QUERY_HISTORY function. The Architect observes that the COMPILATION_TIME is greater than the EXECUTION_TIME.

What is the reason for this?

The query is reading from remote storage.

Correct answer
The query has overly complex logic.

The query is queued for execution.

The query is processing a very large dataset.

Overall explanation
Compilation time is the duration it takes to parse, optimize, and generate the execution plan for a query. Execution time is the duration it takes to actually run the query and produce results.

If the compilation time is greater than the execution time, it indicates that Snowflake spent a significant amount of time optimizing the query before execution. This often occurs when the query contains complex logic.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
An Architect is integrating an application that needs to read and write data to Snowflake without installing any additional software on the application server.

How can this requirement be met?

Use the Snowpipe REST API.

Correct answer
Use the Snowflake SQL REST API.Use the Snowflake SQL REST API.

Use the Snowflake ODBC driver.

Use SnowSQL.

Overall explanation
About the options:

SnowSQL is a command-line interface (CLI) for interacting with Snowflake. It requires installation on the server where it will be used, which does not meet the requirement of not installing additional software.

The Snowpipe REST API is specifically designed for continuous data ingestion into Snowflake and is not intended for general-purpose reading and writing of data.

The ODBC driver also requires installation on the application server, which does not meet the requirement.

Snowflake SQL REST API allows to interact with Snowflake (peform queries, management, etc.) over HTTP without requiring any additional software installation.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
Based on the architecture in the image, how can the data from DB1 be copied into TBL2? (Choose two.)





C

D

Correct selection
E

B

Correct selection
A

Overall explanation
A & E are the only ones with qualified names that will work.

For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
What is a characteristic of Role Based Access Control (RBAC) as used in Snowflake?

A user can use a "super-user" access along with SECURITYADMIN to bypass authorization checks an access all databases, schemas, and underlying objects.

A user can create managed access schemas to support current and future grants and ensure only object owners can grant privileges to other roles.

Correct answer
A user can create managed access schemas to support future grants and ensure only schema owners can grant privileges to other roles.

Privileges can be granted at the database level and can be inherited by all underlying objects.

Overall explanation
With managed access schemas, object owners forfeit their ability to make grant decisions.

Only the schema owner, defined as the role with the OWNERSHIP privilege on the schema, or a role with the MANAGE GRANTS privilege has the authority to grant privileges on the objects within the schema.

For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
Which SQL ALTER command will MAXIMIZE memory and compute resources for a Snowpark stored procedure when executed on the snowpark_opt_wh warehouse?

Correct answer
alter warehouse snowpark_opt_wh set max_concurrency_level = 1;

alter warehouse snowpark_opt_wh set max_concurrency_level = 8;

alter warehouse snowpark_opt_wh set max_concurrency_level = 2;

alter warehouse snowpark_opt_wh set max_concurrency_level = 16;

Overall explanation
Setting the max_concurrency_level to 1 ensures that the Snowpark stored procedure will have access to the maximum memory and compute resources available to the warehouse, as only one query will be executed at a time, allocating all resources to that single query.

For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
A group of Data Analysts have been granted the role ANALYST_ROLE. They need a Snowflake database where they can create and modify tables, views, and other objects to load with their own data. The Analysts should not have the ability to give other Snowflake users outside of their role access to this data.

How should these requirements be met?

Correct answer
Make every schema in the database a MANAGED ACCESS schema, owned by SYSADMIN, and grant create privileges on each schema to the ANALYST_ROLE for each type of object that needs to be created.

Grant SYSADMIN OWNERSHIP of the database, but grant the create schema privilege on the database to the ANALYST_ROLE.

Grant ANALYST_ROLE OWNERSHIP on the database, but grant the OWNERSHIP ON FUTURE [object types] in database privilege to SYSADMIN.

Grant ANALYST_ROLE OWNERSHIP on the database, but make sure that ANALYST_ROLE does not have the MANAGE GRANTS privilege on the account.

Overall explanation
Managed access schemas ensure that only the role that owns the schema (SYSADMIN in this case) can manage access to the schema and its objects. The ANALYST_ROLE would have the ability to create and modify objects within these schemas, but they would not be able to change access controls or grant permissions to these objects.

For more detailed information, refer to the official Snowflake documentation.

Question 31
Skipped
Is it possible for a data provider account with a Snowflake Business Critical edition to share data with an Enterprise edition data consumer account?

If a user in the provider account with role authority to CREATE or ALTER SHARE adds an Enterprise account as a consumer, it can import the share.

A Business Critical account cannot be a data sharing provider to an Enterprise consumer. Any consumer accounts must also be Business Critical.

Correct answer
If a user in the provider account with a share owning role which also has OVERRIDE SHARE RESTRICTIONS privilege SHARE_RESTRICTIONS set to False when adding an Enterprise consumer account, it can import the share.

If a user in the provider account with a share owning role sets SHARE_RESTRICTIONS to False when adding an Enterprise consumer account, it can import the share.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
An Architect needs to design a solution for building environments for development, test, and pre-production, all located in a single Snowflake account. The environments should be based on production data.

Which solution would be MOST cost-effective and performant?

Use zero-copy cloning into permanent tables.

Use CREATE TABLE ... AS SELECT (CTAS) statements.

Correct answer
Use zero-copy cloning into transient tables.

Use a Snowflake task to trigger a stored procedure to copy data.

Overall explanation
Using zero-copy cloning with transient tables offers the best balance of cost and performance for creating development, test, and pre-production environments based on production data.

About other options:

Permanent tables retain Time Travel history, which increases storage costs. For non-production environments, transient tables provide a more cost-efficient solution.

CTAS creates a full physical copy of the data, which incurs significant storage costs and is slower compared to zero-copy cloning. This method is less efficient for frequent environment refreshes.

While automation can be beneficial, physically copying data is more expensive and slower than zero-copy cloning, making this solution less cost-effective and performant.

Question 33
Skipped
Company A has recently acquired company B. The Snowflake deployment for company B is located in the Azure West Europe region.

As part of the integration process, an Architect has been asked to consolidate company B's sales data into company A’s Snowflake account which is located in the AWS us-east-1 region.

How can this requirement be met?

Migrate company B's Snowflake deployment to the same region as company A's Snowflake deployment, ensuring data locality. Then perform a direct database-to-database merge of the sales data.

Build a custom data pipeline using Azure Data Factory or a similar tool to extract the sales data from company B's Snowflake account. Transform the data, then load it into company A's Snowflake account.

Correct answer
Replicate the sales data from Company B's original account using cross-region data replication within Snowflake. Company B should create a new Snowflake account in Company A's region. Configure a direct share from company B's account to company A's account.

Export the sales data from company B's Snowflake account as CSV files, and transfer the files to company A's Snowflake account. Import the data using Snowflake's data loading capabilities.

Overall explanation
To consolidate company B's sales data into company A’s Snowflake account, we have to take advantage of the data replication and data sharing tools offered by Snowflake.

Snowflake supports cross-region and cross-cloud data replication. This feature allows you to replicate databases from one Snowflake account to another, even if they are hosted in different regions and on different cloud platforms (Azure to AWS in this case). This ensures that the data is kept in sync and up-to-date across different locations. After setting up replication, you can use Snowflake’s Secure Data Sharing feature to share the replicated data.

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
A Snowflake Architect is defining a clustering strategy that needs to optimize the performance of queries against a large table, while minimizing re-clustering costs. The Architect wants to leverage the output of the SYSTEM$CLUSTERING_INFORMATION function for the analysis

What will be true about the data output?

The average_overlaps field in the output will indicate how many partitions, on average, a partition's minimum values overlap.

Correct answer
The total_partition_count field in the ouput will indicate the current total count of partitions, not the partitions needed for Time Travel.

The output of the function will provide statistics related to only what the current clustering state is, not the "what-if" state if clustered on a different key.

The output of the function will provide a stand-alone measure of whether a clustering key strategy is working.

Overall explanation
average_overlaps metric represents the average number of overlapping micro-partitions for each micro-partition in the table. A high value suggests that the table is not well-clustered, indicating potential inefficiencies in data retrieval.



About other options:

You can use this argument to return clustering information for any columns in the table, regardless of whether a clustering key is defined for the table. In other words, you can use this to help you decide what clustering to use in the future.

Average number of overlapping micro-partitions for each micro-partition in the table. A high number indicates the table is not well-clustered (not overlap of partition's minimum values)

The output of SYSTEM$CLUSTERING_INFORMATION provides useful metrics like overlapping micro-partitions and partition depth, but it does not independently determine clustering efficiency. It requires interpretation alongside query patterns and performance metrics to evaluate clustering strategy.



For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
A new user user_01 is created within Snowflake. The following two commands are executed:

Command 1 --> show grants to user user_01;

Command 2 --> show grants on user user_01;

What inferences can be made about these commands?

Command 1 defines which role owns user_01

Command 2 defines all the grants which have been given to user_01

Correct answer
Command 1 defines all the grants which are given to user_01

Command 2 defines which role owns user_01

Command 1 defines all the grants which are given to user_01

Command 2 defines which user owns user_01

Command 1 defines which user owns user_01

Command 2 defines all the grants which have been given to user_01

Overall explanation
Users do not own other users.

SHOW GRANTS TO USER lists all the roles granted to the user.

SHOW GRANTS ON lists all the privileges granted on the user, including ownership.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
You are a Snowflake architect in an organization. The business team came to deploy a use case which requires you to load some data which they can visualize through Tableau. Everyday new data comes in and the old data is no longer required.



What type of table will you use in this case to optimize cost?

PERMANENT

TEMPORARY

EXTERNAL

Correct answer
TRANSIENT

Overall explanation
A few comments:

Transient table allows you to store the data temporarily without incurring the additional costs associated with permanent tables.

Temporary tables only exist within the session that creates them and are dropped automatically when the session ends. They are not suitable for data that needs to be available beyond a single session, such as daily loads accessed by Tableau.

Permanent tables incur Fail-safe storage costs, which is unnecessary for data that doesn’t require long-term retention.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
Which columns can be included in an external table schema? (Choose three.)

Correct selection
VALUE

Correct selection
METADATA$FILE_ROW_NUMBER

Correct selection
METADATA$FILENAME

METADATA$EXTERNAL_TABLE_PARTITION

METADATA$ROW_ID

METADATA$ISUPDATE

Overall explanation
These columns can be included in an external table schema. METADATA$FILE_ROW_NUMBER tracks the row number in the file, VALUE stores the actual content of the external data, and METADATA$FILENAME records the name of the file from which the data is being read.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
An Architect is implementing a CI/CD process. When attempting to clone a table from a production to a development environment, the cloning operation fails.

What could be causing this to happen?

Correct answer
The retention time for the table is set to zero.

The table is transient.

Tables cannot be cloned from a higher environment to a lower environment.

The table has a masking policy.

Overall explanation
Cloning operations take time to finish, especially with large tables. During this timeframe, DML transactions can modify the data in the source table. As a result, Snowflake tries to clone the table data as it was when the operation started. However, if DML transactions result in data being purged during the cloning process (due to the table's retention time being set to 0), the necessary data becomes unavailable to complete the operation, leading to an error.

About other options:

Transient tables can still be cloned, as Snowflake supports cloning transient tables. However, they do not retain dropped data for Time Travel, but this does not prevent cloning itself.

A masking policy would not prevent the cloning of the table. The policy remains attached to the cloned table, and cloning with policies is a supported operation.

Snowflake does not impose a restriction based on environment hierarchy (production vs. development). Cloning operations are allowed between environments as long as the user has the necessary permissions.



For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
What are characteristics of the use of transactions in Snowflake? (Choose two.)

Explicit transactions can contain DDL, DML, and query statements.

The AUTOCOMMIT setting can be changed inside a stored procedure.

Correct selection
Explicit transactions should contain only DML statements and query statements. All DDL statements implicitly commit active transactions.

Correct selection
A transaction can be started explicitly by executing a BEGIN WORK statement and end explicitly by executing a COMMIT WORK statement.

A transaction can be started explicitly by executing a BEGIN TRANSACTION statement and end explicitly by executing an END TRANSACTION statement.

Overall explanation
A few comments:

An explicit transaction can be commenced by issuing a BEGIN statement. Snowflake also recognizes BEGIN WORK and BEGIN TRANSACTION as aliases, with BEGIN TRANSACTION being the favored option.

Transactions are explicitly terminated through the execution of COMMIT or ROLLBACK. Snowflake offers COMMIT WORK as an alternative to COMMIT, and ROLLBACK WORK as an alternative to ROLLBACK

Explicit transactions should contain only DML statements and query statements.

DDL statements implicitly commit active transactions.

An error message will be generated if the autocommit setting is altered within a stored procedure.

We can use BEGIN TRANSACTION to start an explicit transaction, but to end it we have to use COMMIT WORK/COMMIT or ROLLBACK WORK/ROLLBACK.

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
An Architect for a multi-national transportation company has a system that is used to check the weather conditions along vehicle routes. The data is provided to drivers.

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

What can the Architect do to deliver the statistics to the drivers faster?

Create an additional table in the schema for longitude and latitude. Determine a regular task to fill this information by extracting it from the JSON dataset.

Divide the table into several tables for each location by using the location address information from the JSON dataset in order to process the queries in parallel.

Divide the table into several tables for each year by using the timeframe information from the JSON dataset in order to process the queries in parallel.

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

Question 41
Skipped
When a user connects to Snowflake and starts a session, Snowflake determines the active warehouse for the session based on which hierarchy?

1. Default warehouse declared in the configuration file for the driver/connector used to connect to Snowflake

- overriden by -

2. Default warehouse for the user

- overriden by -

3. Warehouse specified on the client command line

1. Default warehouse for the user

- overridden by -

2. Warehouse specified on the client command line

- overridden by -

3. Default warehouse declared in the configuration file for the driver/connector used to connect to Snowflake

1. Warehouse specified on the client command line

- overridden by -

2. Default warehouse declared in the configuration file for the driver/connector used to connect to Snowflake

- overridden by -

3. Default warehouse for the user

Correct answer
1. Default warehouse for the user

- overridden by -

2. Default warehouse declared in the configuration file for the driver/connector used to connect to Snowflake

- overridden by -

3. Warehouse specified on the client command line

Overall explanation
For more detailed information about precedence for warehouse defaults, refer to the official Snowflake documentation.

Question 42
Skipped
Which technique will efficiently ingest and consume semi-structured data for Snowflake data lake workloads?

Schema-on-write

Correct answer
Schema-on-read

Information schema

IDEF1X

Overall explanation
Schema-on-Read gained popularity among software developers primarily because it reduced the time required to deliver functional applications. This approach enables applications to store data in semi-structured formats like JavaScript Object Notation (JSON), allowing for rapid iterations without disrupting the underlying database used by the applications.

About other options:

IDEF1X is a data modeling method used for designing relational databases and is not relevant for ingesting or consuming semi-structured data.

Information schema is the systema metadata catalog

Schema on Write is more flexibile and efficient por structured and relational data.

For more detailed information about JSON modeling, refer to the official Snowflake documentation.

For more detailed information about Schema-on-read and Schema-on-write, refer to the following article.

Question 43
Skipped
What step will improve the performance of queries executed against an external table?

Convert the source files' character encoding to UTF-8.

Shorten the names of the source files.

Use an internal stage instead of an external stage to store the source files.

Correct answer
Partition the external table.

Overall explanation
Partitioning the external table improves query performance by allowing Snowflake to process only the relevant partitions of data instead of scanning the entire dataset, significantly reducing query execution time when dealing with large amounts of external data.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
What is a key consideration when setting up search optimization service for a table?

Search optimization service can help to optimize storage usage by compressing the data into a GZIP format.

The table must be clustered with a key having multiple columns for effective search optimization.

Correct answer
Search optimization service works best with a column that has a minimum of 100 K distinct values.

Search optimization service can significantly improve query performance on partitioned external tables.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
What is a characteristic of event notifications in Snowpipe?

Snowflake can process all older notifications when a paused pipe Is resumed.

Correct answer
When a pipe Is paused, event messages received for the pipe enter a limited retention period.

The load history is stored In the metadata of the target table.

Notifications identify the cloud storage event and the actual data in the files.

Overall explanation
When a Snowpipe is paused, the event messages received for that pipe enter a limited retention period, which is 14 days by default. If the pipe remains paused for longer than 14 days, it becomes stale, meaning the messages older than 14 days are no longer available for processing, and any unprocessed data might need to be re-sent to the pipe once it is resumed.

About other options:

Snowpipe's load history is stored separately from the metadata of the target table and can be accessed using Snowflake’s metadata functions. This separation allows tracking and auditing of the load operations independently of the table’s metadata.

Additionally, event notifications used by Snowpipe only signal that new files are available for loading. These notifications do not contain the actual data but merely trigger the process to load the files into Snowflake from the external stage.

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
Which of the following ingestion methods can be used to auto-ingest near real-time data by using the messaging services provided by a cloud provider?

Snowflake streams

Spark

Correct answer
Snowpipe

Snowflake Connector for Kafka

Overall explanation
Snowpipe enables continuous data ingestion into Snowflake by automatically loading data as it becomes available in cloud storage. Snowpipe can be integrated with messaging services provided by cloud providers (SQS, Pub/Sub, etc) to trigger data loading events.

About other options:

Snowflake streams are used for change data capture within Snowflake but are not designed for direct integration with external messaging services.

Kafka can be used for near real-time data ingestion, but different purposes and use cases. It ideal for scenarios where the data pipeline involves Kafka as the primary message broker or for Snowpipe Streaming.

Spark can be used for stream processing, but it is not directly tied to cloud messaging services and would require additional components for integration.

About Snowpipe, refer to the official Snowflake documentation.

About auto loading data using cloud messaging, refer to the official Snowflake documentation.

About Snowpipe and Amazon SQS, refer to the official Snowflake documentation.

About Snowpipe and GCP Pub/Sub, refer to the official Snowflake documentation.

About Snowpipe and Azure Eveng Grid, refer to the official Snowflake documentation.

Question 47
Skipped
An Architect configured single sign-on (SSO) using Okta with Muiti-Factor Authentication (MFA) on a Snowflake deployment. The Data Analyst team uses DBeaver to query data in Snowflake. The Analysts frequently get prompted to enter their credentials to the point where it impacts productivity.

What change needs to be made to address this issue?

Configure ALLOW_CLIENT_MFA_CACHING at the session level in the JDBC connect string to Snowflake from DBeaver.

Configure the CLIENT_SESSION_KEEP_ALIVE parameter at the session level in the JDBC connect string to Snowflake from DBeaver.

Correct answer
Configure ALLOW_CLIENT_MFA_CACHING at the account level.

Configure the CLIENT_SESSION_KEEP_ALIVE parameter at the account level.

Overall explanation
To address the frequent credential prompts experienced by the Data Analyst team while using DBeaver to query data in Snowflake, configuring ALLOW_CLIENT_MFA_CACHING at the account level will help. This setting allows the client to cache MFA tokens, reducing the need for repeated credential entries and improving overall productivity.

Setting this parameter to true, users do not receive prompts for further MFA verification.

For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
An Architect needs to meet a company requirement to ingest files from the company’s AWS storage accounts into the company's Snowflake Google Cloud Platform (GCP) account.

How can the ingestion of these files into the company's Snowflake account be initiated? (Choose two.)

Configure the client application to call the Snowpipe REST endpoint when new files have arrived in Amazon S3 Glacier storage.

Correct selection
Configure the client application to call the Snowpipe REST endpoint when new files have arrived in Amazon S3 storage.

Correct selection
Create an AWS Lambda function to call the Snowpipe REST endpoint when new files have arrived in Amazon S3 storage.

Configure AWS Simple Notification Service (SNS) to notify Snowpipe when new files have arrived in Amazon S3 storage.

Configure the client application to issue a COPY INTO command to Snowflake when new files have arrived in Amazon S3 Glacier storage.

Overall explanation
A few comments:

Snowpipe is Snowflake's continuous data ingestion service that can be triggered by calling its REST endpoint. This allows Snowflake to automatically load data as soon as it arrives in S3.

Lambda can be triggered by an S3 event, then call the Snowpipe REST API to begin ingesting the new data. Lambda is often paired with SNS or directly with S3 event triggers.

About other options:

While S3 can trigger SNS, SNS alone cannot directly trigger Snowpipe. You would need an intermediary like SQS queues or AWS Lambda to invoke Snowpipe based on those SNS notifications.

You cannot access data held in archival cloud storage classes that requires restoration before it can be retrieved. These archival storage classes include, for example, the Amazon S3 Glacier Flexible Retrieval or Glacier Deep Archive storage class, or Microsoft Azure Archive Storage.

For more detailed information about Snowpipe and S3, refer to the official Snowflake documentation.

For more detailed information about archival and external stages, refer to the official Snowflake documentation.

Question 49
Skipped
A company has an external vendor who puts data into Google Cloud Storage. The company's Snowflake account is set up in Azure.

What would be the MOST efficient way to load data from the vendor into Snowflake?

Copy the data from Google Cloud Storage to Azure Blob storage using external tools and load data from Blob storage to Snowflake.

Create a Snowflake Account in the Google Cloud Platform (GCP), ingest data into this account and use data replication to move the data from GCP to Azure.

Ask the vendor to create a Snowflake account, load the data into Snowflake and create a data share.

Correct answer
Create an external stage on Google Cloud Storage and use the external table to load the data into Snowflake.

Overall explanation
Snowflake can use external stages to directly read data from external cloud storage (in this case, Google Cloud Storage) without needing to move the data physically to Azure.

About other options:

Asking the vendor to create a separate Snowflake account adds unnecessary complexity and overhead.

Setting up a separate Snowflake account in GCP and using replication introduces even more complexity and higher costs, as it requires managing two Snowflake accounts and paying for data replication across different cloud regions.

Question 50
Skipped
The data share exists between a data provider account and a data consumer account. Five tables from the provider account are being shared with the consumer account. The consumer role has been granted the imported privileges privilege.

What will happen to the consumer account if a new table (table_6) is added to the provider schema?

The consumer role will automatically see the new table and no additional grants are needed.

Correct answer
The consumer role will see the table only after this grant is given on the provider side:

use role accountadmin;
grant select on table EDW.ACCOUNTING.table_6 to share PSHARE_EDW_4TEST;
The consumer role will see the table only after this grant is given on the consumer side:

grant imported privileges on database PSHARE_EDW_4TEST_DB to DEV_ROLE;

The consumer role will see the table only after this grant is given on the provider side:

use role accountadmin;
grant usage on database EDW to share PSHARE_EDW_4TEST ;
grant usage on schema EDW.ACCOUNTING to share PSHARE_EDW_4TEST ;
grant select on table EDW.ACCOUNTING.Table_6 to database PSHARE_EDW_4TEST_DB ;
Overall explanation
About other options:

Snowflake does not automatically grant privileges for new tables added to a shared schema. The provider must manually grant access to the new table.

One of the options refers to the consumer granting imported privileges, but the initial step requires the provider to grant access to the new table.

USAGE on database and schema are unnecessary grants since five tables from the provider account are being shared and these privileges are already granted. Only the SELECT privilege on the new table is needed. In addition, to add grants to a shared database you have to specify in the 'TO SHARE' statement

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
An Architect clones a database and all of its objects, including tasks. After the cloning, the tasks stop running.

Why is this occurring?

Correct answer
Cloned tasks are suspended by default and must be manually resumed.

The Architect has insufficient privileges to alter tasks on the cloned database.

The objects that the tasks reference are not fully qualified.

Tasks cannot be cloned.

Overall explanation
When a database or schema containing tasks is cloned, the tasks in the clone are suspended by default.

These tasks can be resumed individually by using the ALTER TASK … RESUME command.

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
Based on the Snowflake object hierarchy, what securable objects belong directly to a Snowflake account? ( three.)

Schema

Stage

Correct selection
Warehouse

Correct selection
Role

Table

Correct selection
Database

Overall explanation
This question has a difficulty more typical of Core certification than Advanced, but there are always some easy ones in the exam, although few.

For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
How can the Snowflake context functions be used to help determine whether a user is authorized to see data that has column-level security enforced? (Choose two.)

Correct selection
Set masking policy conditions using INVOKER_ROLE targeting the executing role in a SQL statement.

Correct selection
Set masking policy conditions using CURRENT_ROLE targeting the role in use for the current session.

Determine if there are OWNERSHIP privileges on the masking policy that would allow the use of any function.

Set masking policy conditions using IS_ROLE_IN_SESSION targeting the role in use for the current account.

Assign the ACCOUNTADMIN role to the user who is executing the object.

Overall explanation
A few comments:

Applying masking policies supported by context functions is a common way to apply Dynamic Data Masking on a table.

Column-level Security supports using Context Functions in the conditions of the masking policy body to enforce whether a user has authorization to see data.

The context functions CURRENT_SESSION, INVOKER_ROLE and IS_ROLE_IN_SESSION support the implementation of masking policies.

Of these 3 options, the option that would be discarded in this question is IS_ROLE_IN_SESSION because it refers to current account when it actually returns TRUE/FALSE if the current role matches at session level.

For more detailed information, refer to the official Snowflake documentation.

Question 54
Skipped
Data is being imported and stored as JSON in a VARIANT column. Query performance was fine, but most recently, poor query performance has been reported.

What could be causing this?

The order of the keys in the JSON was changed.

The recent data imports contained fewer fields than usual.

Correct answer
There were JSON nulls in the recent data imports.

There were variations in string lengths for the JSON values in the recent data imports.

Overall explanation
JSON with a ‘null’ value can negatively affect query performance. It’s important to note that JSON NULL differs from SQL NULL; in JSON, a null value represents an element that has the string 'null', which prevents the extraction of those elements, while SQL NULL signifies an empty value. Consequently, having JSON with a ‘null’ value can lead to performance issues during queries.

For more detailed information about query performance on JSON, refer to the official Snowflake documentation.

Snowflake recommends some strategies to avoid the performance impact for elements that were not extracted, refer to the official Snowflake documentation.

Question 55
Skipped
What transformations are supported in the below SQL statement? (Choose three.)

CREATE PIPE ... AS COPY ... FROM (...)

Correct selection
Type casts are supported.

Incoming data can be joined with other tables.

Correct selection
Columns can be reordered.

Data can be filtered by an optional WHERE clause.

The ON_ERROR - ABORT_STATEMENT command can be used.

Correct selection
Columns can be omitted.

Overall explanation
COPY command supports:

Column reordering, omission, and casting through a SELECT statement, allowing flexibility in how data is loaded into the target table. This means that the data files do not need to match the number or order of columns in the target table.

The ENFORCE_LENGTH | TRUNCATECOLUMNS option, which enables the truncation of text strings that exceed the length of the target column, ensuring data integrity within specified limits.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
How can the Snowpipe REST API be used to keep a log of data load history?

Correct answer
Call insertReport every 8 minutes for a 10-minute time range.

Call loadHistoryScan every 10 minutes for a 15-minute time range.

Call loadHistoryScan every minute for the maximum time range.

Call insertReport every 20 minutes, fetching the last 10,000 entries.

Overall explanation
A few comments:

The Snowpipe API offers REST endpoints specifically for retrieving load reports, providing flexibility in data management.

The insertReport endpoint is useful for obtaining reports on files submitted via insertFiles, highlighting that it reflects the most recent ingestion into a table. However, it’s important to note that only part of large files may be reported.

The loadHistoryScan endpoint fetches reports on ingested files and allows users to view historical data between two specific points in time, which is beneficial for tracking changes.

The loadHistoryScan endpoint has a maximum return of 10,000 items, but it's helpful to know that multiple requests can be made to cover broader time ranges.

The rate limiting on this endpoint is crucial to prevent excessive API calls, and it's wise to monitor usage to avoid hitting error code 429.

To optimize performance, it’s recommended to focus on insertReport over loadHistoryScan and to specify narrow time ranges when using loadHistoryScan, such as querying the last 10 minutes rather than attempting broader intervals.

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
A company needs to share its product catalog data with one of its partners. The product catalog data is stored in two database tables: PRODUCT_CATEGORY, and PRODUCT_DETAILS. Both tables can be joined by the PRODUCT_ID column. Data access should be governed, and only the partner should have access to the records.

The partner is not a Snowflake customer. The partner uses Amazon S3 for cloud storage.

Which design will be the MOST cost-effective and secure, while using the required Snowflake features?

Use Secure Data Sharing with an S3 bucket as a destination.

Correct answer
Create a reader account for the partner and share the data sets as secure views.

Publish PRODUCT_CATEGORY and PRODUCT_DETAILS data sets on the Snowflake Marketplace.

Create a database user for the partner and give them access to the required data sets.

Overall explanation
A few comments:

The partner uses Amazon S3 for cloud storage: Snowflake's Secure Data Sharing does not allow data to be directly shared into an S3 bucket.

We want to share two tables that can be joined by the same id: we could create a view to join both tables

Data access should be governed: security is a must in this business case

Partner is not a Snowflake customer: in the case of choosing Data Sharing this would force us to use a reader account.

Non-secure views are not compatible with Data Sharing.

Statement is asking for the MOST cost-effective solution: Marketplace is more oriented towards monetization and broader data distribution, not secure one-to-one sharing.

Question 58
Skipped
For which Snowflake object type is it possible to copy permissions when cloning the object?

Stages

Correct answer
Tables

Materialized views

Pipes

Overall explanation
When cloning a table in Snowflake, it is possible to copy the permissions from the original table to the cloned table. This ensures that the same access controls are applied to the new table without needing to manually reassign them.

A few comments:

CLONE statements for most objects do not transfer grants from the source object to the cloned object. However, certain CREATE <object> commands, like CREATE TABLE and CREATE VIEW, support the COPY GRANTS clause, allowing you to optionally replicate grants to the object clones.

In particular, the CREATE TABLE … CLONE syntax includes the COPY GRANTS keywords, facilitating the copying of grants during the cloning process.

For more detailed information about object cloning, refer to the official Snowflake documentation.

https://docs.snowflake.com/en/user-guide/object-clone

For more detailed information about the Create table process, refer to the official Snowflake documentation.

Question 59
Skipped
Assuming all Snowflake accounts are using an Enterprise edition or higher, in which development and testing scenarios would copying of data be required, and zero-copy cloning not be suitable? (Choose two.)

Correct selection
Production and development run in different databases in the same account, and Developers need to see production-like data but with specific columns masked.

Developers create their own copies of a standard test database previously created for them in the development account, for their initial development and unit testing.

The release process requires pre-production testing of changes with data of production scale and complexity. For security reasons, pre-production also runs in the production account.

Correct selection
Data is in a production Snowflake account that needs to be provided to Developers in a separate development/testing Snowflake account in the same cloud region.

Developers create their own datasets to work against transformed versions of the data.

Overall explanation
Important: question refers to scenarios where zero copy cloning is not feasible.

A few comments:

The phrase "with specific columns masked" indicates developers need custom or different masking policies than what exists in production. While zero-copy cloning can inherit existing masking policies, applying new or modified masking rules requires data copying operations where custom masking can be applied during the transformation process to meet specific development security requirements.

When data needs to be moved from a production account to a separate development/testing account, zero-copy cloning is not feasible across different accounts. In this case, copying the data with Secure Data Sharing from the production account to the development account is necessary to provide developers with the required datasets.

Zero-copy clone is suitable for scenarios where developers are creating transformed versions of data within the same account.

Creating their own copies within the same development account can typically be handled with zero-copy cloning.

Pre-production testing within the same account, especially if the requirement is to use production-scale data without modifying it, is well-suited for zero-copy cloning.

Snowflake’s zero-copy cloning feature provides a convenient way to quickly take a “snapshot” of any table, schema, or database and create a derived copy of that object which initially shares the underlying storage (it is a metadata operation)

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
When using the COPY INTO [table] command with the CSV file format, how does the MATCH_BY_COLUMN_NAME parameter behave?

The command will return an error stating that the file has unmatched columns.

Correct answer
It expects a header to be present in the CSV file, which is matched to a case-sensitive table column name.

The command will return an error.

The parameter will be ignored.

Overall explanation
MATCH_BY_COLUMN_NAME can be set to CASE_SENSITIVE, CASE_INSENSITIVE, or NONE.

This parameter is a string that indicates whether to load semi-structured data into the target table's columns that correspond to the columns in the data.

MATCH_BY_COLUMN_NAME is compatible with CSV and other data types such as JSON, Avro, Parquet, and ORC, ensuring that it won't be ignored or cause an error.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
A Data Architect is designing a near real-time ingestion pipeline for a retail company to ingest event logs into Snowflake to derive insights. A Snowflake Architect is asked to define security best practices to configure access control privileges for the data load for auto-ingest to Snowpipe.

What are the MINIMUM object privileges required for the Snowpipe user to execute Snowpipe?

CREATE on the named pipe, USAGE and READ on the named stage, USAGE on the target database and schema, and INSERT end SELECT on the target table

USAGE on the named pipe, named stage, target database, and schema, and INSERT and SELECT on the target table

Correct answer
OWNERSHIP on the named pipe, USAGE on the named stage, target database, and schema, and INSERT and SELECT on the target table

OWNERSHIP on the named pipe, USAGE and READ on the named stage, USAGE on the target database and schema, and INSERT and SELECT on the target table

Overall explanation
A few comments:

To view the details of a pipe, you need to utilize a role that possesses either the MONITOR or OWNERSHIP privilege on the pipe, along with the USAGE privilege on both the database and schema containing the pipe.

Pipe itself does not have a USAGE privilege, and the external stage associated with it does not need a READ privilege.

For more detailed information about Snowpipe management, refer to the official Snowflake documentation.

For more detailed information about configuring security for auto-ingest in Snowpipe, refer to the official Snowflake documentation.

Question 62
Skipped
A Snowflake Architect of a company that currently uses the Standard edition of Snowflake implements external tables to reference data in a cloud storage data lake. Users report that accessing the external tables is slow.

How can performance be improved?

Implement materialized views over the external tables.

Add search optimization service to the external tables.

Correct answer
Partition by an optimized folder structure on the external tables.

Refresh the external tables.

Overall explanation
Materialized views and Search optimization services are discarded because require Enterprise Edition (or higher).

Partitioning the external table improves query performance by allowing Snowflake to process only the relevant partitions of data instead of scanning the entire dataset, significantly reducing query execution time when dealing with large amounts of external data.

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
During the investigation of a slow query, how can an Architect obtain detailed statistics about each step in the query?

Use an EXPLAIN Command.

Use the clustering information.

Use the QUERY_HISTORY command.

Correct answer
Use the Query Profile.

Overall explanation
To obtain detailed statistics about each step in a slow query, an Architect should use the Query Profile. This tool provides insights into the execution of the query, including the time taken for each step, the resources used, and any potential bottlenecks, which can help in diagnosing performance issues.

The EXPLAIN command provides the logical execution plan for the specified SQL statement.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
If the query matches the definition, will Snowflake always dynamically rewrite the query to use a materialized view?

Yes, because materialized views are always faster.

No, because the materialized view may not be up-to-date.

No, because joins are not supported by materialized views.

Correct answer
No, because the optimizer might decide against it.

Overall explanation
A few comments:

A materialized view can query only a single table. Joins, including self-joins, are not supported.

It is not necessary to explicitly reference a materialized view in a SQL statement for it to be utilized. The query optimizer can automatically transform queries targeting the base table or standard views to leverage the materialized view instead.

However, even when a materialized view could substitute the base table in a given query, the optimizer may opt not to use it. For instance, if the base table is clustered by a specific column, the optimizer might prefer scanning the base table directly, as it can efficiently prune partitions and achieve comparable performance.

For more detailed information, refer to the official Snowflake documentation.

Question 65
Skipped
What does a Snowflake Architect need to consider when implementing a Snowflake Connector for Kafka?

The Kafka connector will create one table and one pipe to ingest data for each topic. If the connector cannot create the table or the pipe it will result in an exception.

The default retention time for Kafka topics is 14 days.

The Kafka connector supports key pair authentication, OAUTH, and basic authentication (for example, username and password).

Correct answer
Every Kafka message is in JSON or Avro format.

Overall explanation
A few comments:

Each Kafka message is transmitted to Snowflake in either JSON or Avro format, which is stored as a single VARIANT column. This means the data remains unparsed and is not distributed across multiple columns in the Snowflake table.

The Kafka connector utilizes key pair authentication instead of basic authentication methods, such as using a username and password, enhancing security.

For each topic, the connector establishes an internal stage to temporarily hold data files, a pipe for ingesting files for each topic partition, and a table dedicated to that topic.

If the designated table for a topic doesn't exist, the connector will create it. If it does exist, it will add the RECORD_CONTENT and RECORD_METADATA columns, ensuring that the other columns are nullable; an error will be generated if they are not.

Kafka Topics can be set up with limits on storage space or retention time, with the default retention period being 7 days.

For more detailed information, refer to the official Snowflake documentation.