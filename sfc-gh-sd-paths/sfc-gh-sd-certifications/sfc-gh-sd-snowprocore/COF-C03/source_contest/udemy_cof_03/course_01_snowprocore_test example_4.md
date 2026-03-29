What is the MINIMUM Snowflake edition required to use the column-level security feature?

Correct answer
Enterprise

Business Critical

Virtual Private Snowflake (VPS)

Your answer is incorrect
Standard

Overall explanation
This security detail is very important to take into account when deciding the minimum edition for our Snowflake account.

For more detailed information, refer to the official Snowflake documentation.

Question 2
Skipped
When can a newly configured virtual warehouse start running SQL queries?

After the warehouse replication is completed

After 50% of the warehouse provisioning has completed

Correct answer
When the warehouse provisioning is completed

During the time slots defined by the ACCOUNTADMIN

Overall explanation
A newly configured virtual warehouse can start running SQL queries when the warehouse provisioning is completed. Once the provisioning is complete, the warehouse is ready to accept and execute queries.

For more detailed information, refer to the official Snowflake documentation.

Question 3
Skipped
Which Snowflake edition enables data sharing only through Snowflake Support?

Business Critical

Enterprise

Standard

Correct answer
Virtual Private Snowflake

Overall explanation
This edition provides an isolated environment where data sharing is enabled only through Snowflake Support, ensuring maximum privacy and security.

For more detailed information, refer to the official Snowflake documentation.

Question 4
Skipped
A JSON document is stored in the source_column of type VARIANT. The document has an array called elements. The array contains the name key that has a string value.

How can a Snowflake user extract the name from the first element?

Correct answer
source_column:elements[0].name

source_column:elements[1].name

source_column.elements[1]:name

source_column.elements[0]:name

Overall explanation
In Snowflake, arrays are zero-indexed, so to extract the name from the first element of the elements array in a JSON document stored in a VARIANT type, you would use source_column:elements[0].nameThis path navigates to the first element of the array and retrieves the name key​.

For more detailed information, refer to the official Snowflake documentation.

Question 5
Skipped
What is a responsibility of Snowflake’s virtual warehouses?

Query parsing and optimization

Infrastructure management

Metadata management

Correct answer
Query execution

Overall explanation
Snowflake's virtual warehouses are responsible for executing queries by providing the necessary compute resources to process and return results.

Question 6
Skipped
When cloning a schema, which Snowflake object will not be included in the clone by default?

An external stage

A task

A User-Defined Function (UDF)

Correct answer
A named internal stage

Overall explanation
By default, internal stages are not included in clones. To clone them along with the database or schema, we must explicitly add the INCLUDE INTERNAL STAGES clause during the cloning operation.

For more detailed information, refer to the official Snowflake documentation.

Question 7
Skipped
Which statements are true concerning Snowflake’s underlying cloud infrastructure? (Choose three.)

Correct selection
Snowflake uses the core compute and storage services of each cloud provider for its own compute and storage.

Correct selection
All three layers of Snowflake’s architecture (storage, compute, and cloud services) are deployed and managed entirely on a selected cloud platform.

Snowflake can be deployed in a customer’s private cloud using the customer’s own compute and storage resources for Snowflake compute and storage.

Snowflake data and services are deployed in a single availability zone within a cloud provider’s region.

Snowflake data and services are available in a single cloud provider and a single region; the use of multiple cloud providers is not supported.

Correct selection
Snowflake data and services are deployed in at least three availability zones within a cloud provider’s region.

Overall explanation
Snowflake uses the core compute and storage services of each cloud provider for its own compute and storage.

All three layers of Snowflake’s architecture are deployed and managed entirely on a selected cloud platform.

Snowflake data and services are deployed in at least three availability zones within a cloud provider’s region.

These statements highlight that Snowflake leverages the infrastructure of cloud providers, is fully integrated within a cloud platform, and ensures high availability through deployment across multiple availability zones.

For more detailed information, refer to the official Snowflake documentation.

Question 8
Skipped
Which Snowflake tool is recommended for data batch processing?

Snowsight

Correct answer
SnowSQL

The Snowflake API

SnowCD

Overall explanation
SnowSQL is a command-line tool used for interacting with Snowflake, and it is well-suited for batch processing tasks. It allows you to execute SQL queries, run scripts, and manage data loading and unloading in a batch-oriented manner.

For more detailed information, refer to the official Snowflake documentation.

Question 9
Skipped
Which items are considered schema objects in Snowflake? (Choose two.)

Correct selection
Pipe

Virtual warehouse

Storage integration

Correct selection
File format

Resource monitor

Overall explanation
Both pipes and file formats are considered schema objects. Pipes are used to define the data loading process for continuous ingestion through Snowpipe, while file formats specify the structure of data files (like CSV or JSON) used during data loading and unloading.

For more detailed information, refer to the official Snowflake documentation.

Question 10
Skipped
How can a Snowflake user sample 10 rows from a table named SNOWPRO? (Choose two.)

SELECT * FROM SNOWPRO TABLESAMPLE BLOCK (10 ROWS)

Correct selection
SELECT * FROM SNOWPRO TABLESAMPLE (10 ROWS)

SELECT * FROM SNOWPRO TABLESAMPLE BLOCK (10)

SELECT * FROM SNOWPRO SAMPLE SYSTEM (10)

Correct selection
SELECT * FROM SNOWPRO SAMPLE BERNOULLI (10 ROWS)

Overall explanation
The TABLESAMPLE method specifies the exact number of rows to retrieve, while SAMPLE BERNOULLI uses random row sampling with a specified number of rows.

For more detailed information, refer to the official Snowflake documentation.

Question 11
Skipped
Which ACCOUNT_USAGE schema database role provides visibility into policy-related information?

OBJECT_VIEWER

SECURITY_VIEWER

Correct answer
GOVERNANCE_VIEWER

USAGE_VIEWER

Overall explanation
The GOVERNANCE_VIEWER role in the ACCOUNT_USAGE schema provides visibility into policy-related information, such as access policies and governance-related metadata, ensuring compliance and data security monitoring.

For more detailed information, refer to the official Snowflake documentation.

Question 12
Skipped
Which command should be used to implement a masking policy that was already created in Snowflake?

Correct answer
SET MASKING POLICY

CREATE MASKING POLICY

ALTER MASKING POLICY

APPLY MASKING POLICY

Overall explanation
SET MASKING POLICY command applies an existing masking policy to a column in a table or view in Snowflake. You can use it within the ALTER TABLE or ALTER VIEW statement to assign the policy to the desired column​.

For more detailed information, refer to the official Snowflake documentation.

Question 13
Skipped
Which role in Snowflake allows a user to enable replication for multiple accounts?

Correct answer
ORGADMIN

ACCOUNTADMIN

SYSADMIN

SECURITYADMIN

Overall explanation
ORGADMIN role is designed to manage multiple accounts within an organization. It has the necessary privileges to enable and configure replication across different Snowflake accounts within the same organization. Roles like ACCOUNTADMIN, SECURITYADMIN, and SYSADMIN manage tasks within a single account.

For more detailed information, refer to the official Snowflake documentation.

Question 14
Skipped
When a transient table in Snowflake is dropped, what happens to the table?

The table can be recovered only with the assistance of Snowflake Support.

Correct answer
The table can be recovered for 1 day only and after that it is no longer available.

The table can be undropped using Fail-safe.

The table is no longer available for use.

Overall explanation
Transient tables support Time Travel for up to 1 day (if configured), allowing recovery within that window. However, they do not support Fail-safe, so after the Time Travel period ends, recovery is not possible.

For more detailed information, refer to the official Snowflake documentation.

Question 15
Skipped
What role has the privileges to create and manage data shares by default?

SECURITYADMIN

Correct answer
ACCOUNTADMIN

SYSADMIN

USERADMIN

Overall explanation
By default, the ACCOUNTADMIN role in Snowflake has the privileges to create and manage data shares. This role has full administrative rights over the Snowflake account, including tasks like creating and managing data sharing between accounts​.

For more detailed information, refer to the official Snowflake documentation.

Question 16
Skipped
What are the benefits of the replication feature in Snowflake? (Choose two.)

Data security

Fail-safe

Correct selection
Disaster recovery

Correct selection
Database failover and failback

Time Travel

Overall explanation
The replication feature in Snowflake enables disaster recovery by replicating data across regions or accounts and supports database failover and failback to ensure availability in case of failures.

For more detailed information, refer to the official Snowflake documentation.

Question 17
Skipped
Why should a Snowflake user configure a secure view? (Choose two.)

Correct selection
To hide the view definition from other users

To execute faster than a standard view

Correct selection
To protect hidden data from other users

To encrypt the data in transit

To improve the performance of a query

Overall explanation
A secure view in Snowflake is used to protect sensitive data by restricting access to specific data or columns, preventing unauthorized users from seeing hidden information. Additionally, secure views hide the underlying SQL definition from users who do not have the necessary privileges, adding an extra layer of security around the view's logic and structure​.

For more detailed information, refer to the official Snowflake documentation.

Question 18
Skipped
What tasks can be completed using the COPY command? (Choose two.)

Columns can be joined with an existing table.

Correct selection
Columns can be omitted.

Columns can be aggregated.

Correct selection
Columns can be reordered.

Data can be loaded without the need to spin up a virtual warehouse.

Overall explanation
The COPY command allows you to reorder columns and omit certain columns during the data loading process, providing flexibility in how data is loaded into a table.

For more detailed information, refer to the official Snowflake documentation.

Question 19
Skipped
The COPY INTO command can unload data from a table directly into which locations? (Choose two.)

Correct selection
A named internal stage

A Snowpipe REST endpoint

A network share on a client machine

A local directory or folder on a client machine

Correct selection
A named external stage that references an external cloud location

Overall explanation
The COPY INTO command in Snowflake allows unloading data from a table directly into either a named internal stage (within Snowflake) or a named external stage that references an external cloud storage location, such as Amazon S3, Google Cloud Storage, or Microsoft Azure Blob Storage. It cannot directly unload data to local directories or network shares.

For more detailed information, refer to the official Snowflake documentation.

Question 20
Skipped
What is the primary purpose of partitioning staged data files for regular data loads?

Correct answer
To improve the performance of data loads

To organize the data into subfolders for easy browsing

To compress the data for efficient storage

To encrypt the data for enhanced security

Overall explanation
Partitioning staged data files optimizes load performance by enabling parallel processing and reducing the volume of data processed in each load operation.

For more detailed information, refer to the official Snowflake documentation.

Question 21
Skipped
What actions will prevent leveraging of the ResultSet cache?

Stopping the virtual warehouse that the query is running against

Executing the RESULTS_SCAN() table function

If the result has not been reused within the last 12 hours

Correct answer
Removing a column from the query SELECT list

Overall explanation
Modifying the query, such as removing a column, changes the query structure and prevents leveraging of the ResultSet cache, as Snowflake treats it as a different query.

For more detailed information, refer to the official Snowflake documentation.

Question 22
Skipped
What do temporary and transient tables have in common in Snowflake? (Choose two.)

For both tables, the retention period ends when the tables are dropped.

Both tables are visible only to a single user session.

Correct selection
Both tables have no Fail-safe period.

For both tables, the retention period does not end when the session ends.

Correct selection
Both tables have data retention period maximums of one day.

Overall explanation
Temporary and transient tables in Snowflake both lack a Fail-safe period, meaning once they are dropped, the data is not recoverable. Additionally, both types of tables have a maximum data retention period of one day, which ensures minimal storage costs for short-term data​.



For more detailed information, refer to the official Snowflake documentation.

Question 23
Skipped
How can the ACCESS_HISTORY view in the ACCOUNT_USAGE schema be used to review the data governance settings for an account? (Choose two.)

Identify SQL statements that failed to run.

Correct selection
Identify queries run by a particular user.

Identify access to the roles given to a user.

Correct selection
Identify objects that were modified by a query.

Identify object dependencies.

Overall explanation
Access History in Snowflake tracks when a user query reads data and when a SQL statement performs data write operations, such as INSERT, UPDATE, DELETE, and variations of the COPY command, transferring data from source to target objects.

We can find the user access history by querying the ACCESS_HISTORY view in the ACCOUNT_USAGE and ORGANIZATION_USAGE schemas. These records help with regulatory compliance auditing and provide insights into frequently accessed tables and columns, as they link the user, the query, the table or view, the column, and the data directly.

For more detailed information, refer to the official Snowflake documentation.

Question 24
Skipped
A user needs to set up a virtual warehouse for the organization’s BI Team. The team has around 14 users running similar queries at the same time and queries often get queued.



Which virtual warehouse configuration should be assigned to the team to improve performance and concurrency?

X-Small single cluster warehouse

Correct answer
Medium multi-cluster warehouse

Large single cluster warehouse

Medium Snowpark-optimized warehouse

Overall explanation
Multi-cluster warehouses are built to address concurrency bottlenecks and query queuing caused by many simultaneous users.

They allow Snowflake to provision multiple compute clusters under a single warehouse. When concurrency increases and queries begin to queue, additional clusters can be allocated—either manually (fixed cluster count) or automatically (auto-scale mode). In auto-scale mode, clusters start and stop based on workload demand.

This architecture is particularly effective for BI environments where multiple users run similar dashboards or analytical queries at the same time. Scaling out with multiple clusters increases parallel query handling capacity, directly reducing queue time.

By contrast, a single-cluster warehouse—even if resized—primarily improves per-query performance, not concurrency capacity. Multi-cluster configuration is therefore the appropriate solution for sustained queuing under concurrent workloads.

For more detailed information, refer to the official Snowflake documentation.

Question 25
Skipped
What is used to limit the credit usage of a virtual warehouse within a Snowflake account?

Load monitor

Correct answer
Resource monitor

Stream

Query Profile

Overall explanation
A resource monitor is used to limit the credit usage of a virtual warehouse within a Snowflake account by tracking and managing resource consumption and applying thresholds.

For more detailed information, refer to the official Snowflake documentation.

Question 26
Skipped
What code will reference the results of a previously-run SQL cell, named my_cell, in another Python Snowflake Notebook cell?

my_cell.to_df()
SELECT {{my_cell}};
SELECT $my_cell;
Correct answer
my_df = my_cell
Overall explanation
A few comments:

A key feature of Snowflake Notebooks is the interoperability between SQL and Python. When we define a name for a SQL cell, the results of that query are automatically made available to subsequent Python cells as a Snowpark DataFrame variable with that same name. Therefore, in a Python cell, we can simply reference it by name, for example assigning it to a new variable: my_df = my_cell.

To reference a cell result in another SQL cell, you would use the Jinja2 syntax {{ ... }}, but the SQL statement needs to be syntactically correct. The correct syntax would be SELECT * FROM {{my_cell}}. The option SELECT {{my_cell}} is invalid because it attempts to select a table object without a FROM clause.

For more detailed information, refer to the official Snowflake documentation.

Question 27
Skipped
When unloading data to an external stage, which compression format can be used for Parquet files with the COPY INTO command?

GZIP

BROTLI

ZSTD

Correct answer
LZO

Overall explanation
When unloading data to an external stage, LZO is one of the supported compression format for Parquet files with the COPY INTO command in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 28
Skipped
Which of the following Snowflake capabilities are available in all Snowflake editions? (Choose two.)

Customer-managed encryption keys through Tri-Secret Secure

Correct selection
Object-level access control

Column-level security to apply data masking policies to tables and views

Correct selection
Automatic encryption of all data

Up to 90 days of data recovery through Time Travel

Overall explanation
Automatic encryption of all data, Object-level access control: These capabilities are available in all Snowflake editions, providing built-in security features and the ability to manage access to objects such as tables and databases.

For more detailed information, refer to the official Snowflake documentation.

Question 29
Skipped
Snowpark provides libraries for which programming languages? (Choose two.)

C++

R

Correct selection
Python

Correct selection
Scala

JavaScript

Overall explanation
Snowpark provide libs for: Java, Python, Scala.

For more detailed information, refer to the official Snowflake documentation.

Question 30
Skipped
The number of virtual warehouse users and the number of reports the users access has been increasing.

Which step should be taken to find out if the warehouse is overloaded?

Determine if there are queries that will benefit from the query acceleration service

Correct answer
Determine if any queries are being queued.

Check the number of running queries in the Query History.

Monitor the duration of running queries.

Overall explanation
Queued queries are the clearest signal that a warehouse is overloaded. A query enters the queued state when it must wait for compute resources to become available because the warehouse is already saturated.

Warehouse monitoring dashboards explicitly surface queued load as a distinct metric. Persistent or recurring queue patterns—especially during usage spikes—indicate that available compute capacity is insufficient for current concurrency demands.

Operational guidance links frequent queuing to actions such as resizing the warehouse, isolating workloads on dedicated warehouses, or enabling multi-cluster configuration to dynamically scale concurrency capacity.

Metrics like overall query duration or the raw number of running queries do not, by themselves, confirm resource saturation. Similarly, query acceleration targets specific execution patterns and is not a mechanism for detecting warehouse overload.

For more detailed information, refer to the official Snowflake documentation.
For additional technical details, see the official Snowflake documentation.

Question 31
Skipped
How does Snowflake describe its unique architecture?

A multi-cluster shared nothing architecture using a siloed data repository and symmetric multiprocessing (SMP)

A single-cluster shared nothing architecture using a siloed data repository and symmetric multiprocessing (SMP)

Correct answer
A multi-cluster shared data architecture using a central data repository and massively parallel processing (MPP)

A single-cluster shared data architecture using a central data repository and massively parallel processing (MPP)

Overall explanation
Snowflake utilizes a multi-cluster shared data architecture that relies on a central data repository. It leverages massively parallel processing (MPP), allowing multiple clusters to operate on the same dataset efficiently.

For more detailed information, refer to the official Snowflake documentation.

Question 32
Skipped
What happens to the shared objects for users in a consumer account from a share, once a database has been created in that account?

The shared objects are copied.

The shared objects are transferred.

Correct answer
The shared objects become accessible.

The shared objects can be re-shared.

Overall explanation
Once a database is created in the consumer account from a share, the shared objects are immediately accessible to users, allowing them to query and interact with the data.

For more detailed information, refer to the official Snowflake documentation.

Question 33
Skipped
What factors impact storage costs in Snowflake? (Choose two.)

Correct selection
The account type

The cloud platform being used for the external stage

The storage file format

Correct selection
The cloud region used by the account

The type of data being stored

Overall explanation
These factors directly impact storage costs in Snowflake, as the account type (Capacity or On Demand) and the region (e.g., US or EU) influence the flat rate charged per terabyte (TB).

For more detailed information, refer to the official Snowflake documentation.

Question 34
Skipped
What can be used to process unstructured data?

Snowpipe

The COPY INTO [table] command

External tables

Correct answer
External functions

Overall explanation
Snowflake lets you use External Functions to work with unstructured data. These are user-defined functions that run outside of Snowflake. This allows you to use libraries like Amazon Textract, Document AI, or Azure Computer Vision, which regular Snowflake UDFs can't access.

For more detailed information, refer to the official Snowflake documentation.

Question 35
Skipped
According to best practices, which table type should be used if the data can be recreated outside of Snowflake?

Temporary table

Correct answer
Transient table

Permanent table

Volatile table

Overall explanation
Transient tables are recommended for data that can be recreated outside of Snowflake, as they do not incur long-term storage costs and lack fail-safe protection.

For more detailed information, refer to the official Snowflake documentation.

Question 36
Skipped
Which of the following operations require the use of a running virtual warehouse? (Choose two.)

Correct selection
Executing a stored procedure

Altering a table

Downloading data from an internal stage

Correct selection
Querying data from a materialized view

Listing files in a stage

Overall explanation
Executing a stored procedure, Querying data from a materialized view: Both of these operations require the use of a running virtual warehouse since they involve computational resources for processing data or executing logic.

For more detailed information, refer to the official Snowflake documentation.

Question 37
Skipped
Which function should be used to insert JSON formatted string data into a VARIANT field?

FLATTEN

TO_VARIANT

Correct answer
PARSE_JSON

CHECK_JSON

Overall explanation
The PARSE_JSON function is used in Snowflake to convert a JSON-formatted string into a VARIANT data type. This function takes a valid JSON string as input and transforms it into a VARIANT object that can be stored and queried within Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 38
Skipped
For directory tables, what stage allows for automatic refreshing of metadata?

Correct answer
Named external stage

User stage

Table stage

Named internal stage

Overall explanation
For directory tables in Snowflake, a named external stage allows for the automatic refreshing of metadata. This feature is used when managing external data, and it ensures that Snowflake automatically detects changes in the underlying data files, keeping the metadata in sync without manual intervention.

For more detailed information, refer to the official Snowflake documentation.

Question 39
Skipped
Snowflake’s access control framework combines which models for securing data? (Choose two.)

Rule-based Access Control (RuBAC)

Access Control List (ACL)

Attribute-based Access Control (ABAC)

Correct selection
Role-based Access Control (RBAC)

Correct selection
Discretionary Access Control (DAC)

Overall explanation
Snowflake's access control framework combines DAC, which allows object owners to grant access to other users, and RBAC, where access permissions are assigned to roles rather than individual users, and roles can be assigned to other roles or users. These two models work together to offer flexible and secure data access management​

For more detailed information, refer to the official Snowflake documentation.

Question 40
Skipped
What optional properties can a Snowflake user set when creating a virtual warehouse? (Choose two.)

Default role

Correct selection
Auto-suspend

Storage size

Correct selection
Resource monitor

Cache size

Overall explanation
Auto-suspend, Resource monitor: When creating a virtual warehouse, users can set the auto-suspend property to automatically suspend the warehouse after a period of inactivity, saving costs. Additionally, a resource monitor can be assigned to manage and control the warehouse's usage based on defined thresholds.

For more detailed information, refer to the official Snowflake documentation.

Question 41
Skipped
What tasks can an account administrator perform in the Data Exchange? (Choose two.)

Transfer listing ownership.

Correct selection
Approve and deny listing approval requests.

Correct selection
Add and remove members.

Delete data categories.

Transfer ownership of a provider profile.

Overall explanation
By default, only a user with the ACCOUNTADMIN role within the Data Exchange administrator account has the ability to manage a Data Exchange. This includes tasks such as adding or removing members, approving or denying listing approval requests, and approving or denying provider profile approval requests.

For more detailed information, refer to the official Snowflake documentation.

Question 42
Skipped
Which programming languages are supported for Snowflake User-Defined Functions (UDFs)? (Choose two.)

Correct selection
Python

C#

PHP

TypeScript

Correct selection
JavaScript

Overall explanation
JavaScript, Python: These programming languages are supported for creating Snowflake User-Defined Functions (UDFs), allowing custom logic to be written and executed within Snowflake queries.

For more detailed information, refer to the official Snowflake documentation.

Question 43
Skipped
Which file function generates a Snowflake-hosted file URL to a staged file using the stage name and relative file path as inputs?

GET_ABSOLUTE_PATH

Correct answer
BUILD_STAGE_FILE_URL

GET_STAGE_LOCATION

GET_RELATIVE_PATH

Overall explanation
BUILD_STAGE_FILE_URL function generates a Snowflake-hosted file URL to a staged file using the stage name and relative file path as inputs.

For more detailed information, refer to the official Snowflake documentation.

Question 44
Skipped
For a multi-cluster virtual warehouse, which parameters are used to calculate the number of credits billed? (Choose two.)

Number of queries executed

Correct selection
Number of clusters

Volume of data processed

Cache size

Correct selection
Warehouse size

Overall explanation
Warehouse size, Number of clusters parameters are used to calculate the number of credits billed for a multi-cluster virtual warehouse. The warehouse size determines the compute power of each cluster, and the number of clusters affects the total credits consumed.

For more detailed information, refer to the official Snowflake documentation.

Question 45
Skipped
What compute resource is used when loading data using Snowpipe?

Snowpipe uses virtual warehouses provided by the user.

Correct answer
Snowpipe uses compute resources provided by Snowflake.

Snowpipe uses cloud platform compute resources provided by the user.

Snowpipe uses an Apache Kafka server for its compute resources.

Overall explanation
Snowflake is a serverless service.

For more detailed information, refer to the official Snowflake documentation.

Question 46
Skipped
When connecting to Snowflake using SnowSQL, what are ways to explicitly specify the password? (Choose two.)

Use public and private key pair authentication

Use an OAuth token

Run a web-based authorization flow

Correct selection
Enter through an interactive prompt

Correct selection
Specify using SNOWSQL_PWD environment variables

Overall explanation
For security, you can't pass passwords directly through connection parameters. Instead, you must specify them in one of three ways: by entering the password interactively when prompted in SnowSQL, by defining it in your SnowSQL configuration file, or by setting it as an environment variable using SNOWSQL_PWD.

For more detailed information, refer to the official Snowflake documentation.

Question 47
Skipped
What actions are supported by Snowflake resource monitors? (Choose two.)

Abort

Alert

Correct selection
Notify

Suspend immediately

Correct selection
Notify and suspend

Overall explanation
Snowflake resource monitors can send notifications when a credit usage threshold is reached and can also be configured to notify and suspend the virtual warehouse once the threshold is met, helping to manage resource usage efficiently.

For more detailed information, refer to the official Snowflake documentation.

Question 48
Skipped
Which commands support a multiple-statement request to access and update Snowflake data? (Choose two.)

CALL

GET

Correct selection
ROLLBACK

Correct selection
COMMIT

PUT

Overall explanation
A transaction can be explicitly initiated by executing a BEGIN statement. A transaction can be explicitly ended by executing COMMIT or ROLLBACK.

For more detailed information, refer to the official Snowflake documentation.

Question 49
Skipped
What happens when a suspended virtual warehouse is resized in Snowflake?

It will return a warning.

It will return an error.

The suspended warehouse is resumed and new compute resources are provisioned immediately.

Correct answer
The additional compute resources are provisioned when the warehouse is resumed.

Overall explanation
In Snowflake, when a suspended virtual warehouse is resized, the new compute resources are not provisioned immediately. Instead, the warehouse remains suspended, and the additional compute resources are allocated once the warehouse is resumed.

For more detailed information, refer to the official Snowflake documentation.

Question 50
Skipped
Which object consumes Snowflake credits for its maintenance?

Correct answer
Materialized view

View

Table

External table

Overall explanation
In Snowflake, materialized views impact your costs for both storage and compute.

Storage: They increase your monthly storage usage because they save query results.

Compute: Snowflake uses compute resources for automatic, background maintenance to keep the materialized views up-to-date whenever the base table changes.

For more detailed information, refer to the official Snowflake documentation.

Question 51
Skipped
In addition to performing all the standard steps to share data, which privilege must be granted on each database referenced by a secure view in order to be shared?

USAGE

REFERENCES

Correct answer
REFERENCE_USAGE

READ

Overall explanation
REFERENCE_USAGE privilege must be granted on each referenced database. This privilege allows the secure view to access the necessary metadata from the referenced databases without exposing the underlying data directly.

For more detailed information, refer to the official Snowflake documentation.

Question 52
Skipped
To add or remove search optimization for a table, a user must have which of the following privileges or roles? (Choose two.)

Correct selection
The OWNERSHIP privilege on the table

Correct selection
The ADD SEARCH OPTIMIZATION privilege on the schema that contains the table

A SECURITYADMIN role

The SELECT privilege on the table

The MODIFY privilege on the table

Overall explanation
These privileges are required to add or remove search optimization for a table. The OWNERSHIP privilege provides full control over the table, and the ADD SEARCH OPTIMIZATION privilege is necessary for managing search optimization within the schema.

For more detailed information, refer to the official Snowflake documentation.

Question 53
Skipped
If all virtual warehouse resources are maximized while processing a query workload, what will happen to new queries that are submitted to the warehouse?

All queries will terminate when the resources are maximized.

Correct answer
New queries will be queued and executed when capacity is available.

The warehouse will move to a suspended state.

The warehouse will scale out automatically

Overall explanation
If all virtual warehouse resources are maximized, new queries are queued until resources become available, ensuring they are processed without overloading the warehouse.

Question 54
Skipped
Which commands should be used to grant the privilege allowing a role to select data from all current tables and any tables that will be created later in a schema? (Choose two.)

Correct selection
grant SELECT on all tables in schema DB1.SCHEMA to role MYROLE;

Correct selection
grant SELECT on future tables in schema DB1.SCHEMA to role MYROLE;

grant SELECT on all tables in database DB1 to role MYROLE;

grant USAGE on future tables in schema DB1.SCHEMA to role MYROLE;

grant USAGE on all tables in schema DB1.SCHEMA to role MYROLE;

Overall explanation
grant SELECT on all tables in schema DB1.SCHEMA to role MYROLE: This command allows the role to select data from all current tables in the schema.

grant SELECT on future tables in schema DB1.SCHEMA to role MYROLE: This command grants the role the ability to select data from any tables that will be created later in the schema, ensuring ongoing access.

For more detailed information, refer to the official Snowflake documentation.

Question 55
Skipped
What is the impact on queries that are being executed when a resource monitor set to the “Notify & Suspend” threshold level is exceeded?

Correct answer
All statements being executed are completed.

All statements being executed are restarted.

All statements being executed are queued.

All statements being executed are cancelled.

Overall explanation
When a resource monitor in Snowflake reaches the "Notify & Suspend" threshold, it suspends the warehouse only after the currently executing queries are completed. This ensures that no running queries are canceled or restarted, allowing them to finish before the suspension takes effect​.

For more detailed information, refer to the official Snowflake documentation.

Question 56
Skipped
What action should be taken if a Snowflake user wants to share a newly created object in a database with consumers?

Recreate the object with a different name in the database before sharing.

Use the automatic sharing feature for seamless access.

Drop the object and then re-add it to the database to trigger sharing.

Correct answer
Use the GRANT privilege ... TO SHARE command to grant the necessary privileges.

Overall explanation
If a Snowflake user wants to share a newly created object in a database with consumers, they should use the GRANT privilege along with the TO SHARE command. This allows the necessary privileges to be granted on the object, making it available for sharing via Snowflake's data sharing functionality,

For more detailed information, refer to the official Snowflake documentation.

Question 57
Skipped
What is the recommended file sizing for data loading using Snowpipe?

A compressed file size greater than 1 GB, and up to 2 GB

A compressed file size greater than 100 GB, and up to 250 GB

Correct answer
A compressed file size greater than 100 MB, and up to 250 MB

A compressed file size greater than 1 MB, and up to 10 MB

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 58
Skipped
A size X-Small virtual warehouse ran for 90 seconds, and was shut down. The warehouse was then run for another 30 seconds before being shut down again.

120 seconds

90 seconds

180 seconds

Correct answer
150 seconds

Overall explanation
The first run of 90 seconds is billed fully, and the second run of 30 seconds is rounded up to 60 seconds. Total billed time is 90 + 60 = 150 seconds.

For more detailed information, refer to the official Snowflake documentation.

Question 59
Skipped
How can a user change which columns are referenced in a view?

Use the ALTER VIEW command to update the view

Modify the columns in the underlying table

Correct answer
Recreate the view with the required changes

Materialize the view to perform the changes

Overall explanation
In Snowflake, views are not directly updatable, so to change the columns referenced, the view must be dropped and recreated with the new definition.

For more detailed information, refer to the official Snowflake documentation.

Question 60
Skipped
What is the purpose of the STRIP_NULL_VALUES file format option when loading semi-structured data files into Snowflake?

It removes null values from all columns in the data.

It converts null values to empty strings during loading.

Correct answer
It removes object or array elements containing null values.

It skips rows with null values during the loading process.

Overall explanation
The STRIP_NULL_VALUES option is used to clean up semi-structured data by excluding elements with null values within objects or arrays, optimizing data storage and retrieval.

For more detailed information, refer to the official Snowflake documentation.

Question 61
Skipped
A team is developing a machine learning model by training on the latest Snowflake features. The training is taking much longer than expected to complete.



Which step will accelerate the model training?

Enable the query acceleration service.

Add additional clusters to the virtual warehouse.

Increase the size of the virtual warehouse.

Correct answer
Use a Snowpark-optimized virtual warehouse.

Overall explanation
Snowpark-optimized warehouses are recommended for running Snowpark workloads that have high memory or specific CPU requirements, such as machine learning training. While you can also use standard warehouses, other types of workloads may not benefit from the optimized version.

For more detailed information, refer to the official Snowflake documentation.

Question 62
Skipped
The following settings are configured:

The MIN_DATA_RETENTION_TIME_IN_DAYS is set to 5 at the account level.

The DATA_RETENTION_TIME_IN_DAYS is set to 2 at the object level.

For how many days will the data be retained at the object level?

3

7

2

Correct answer
5

Overall explanation
When the MIN_DATA_RETENTION_TIME_IN_DAYS is set at the account level, it overrides any lower retention periods set at the object level. Since the object-level setting is 2 days but the account-level minimum is 5 days, the data will be retained for 5 days at the object level. The retention period cannot be set lower than the account-level minimum​

For more detailed information, refer to the official Snowflake documentation.

Question 63
Skipped
Awarding a user which privileges on all virtual warehouses is equivalent to granting the user the global MANAGE WAREHOUSES privilege?

MANAGE LISTING AUTOFULFILLMENT and RESOLVE ALL privileges

OWNERSHIP and USAGE privileges

Correct answer
MODIFY, MONITOR and OPERATE privileges

APPLYBUDGET and AUDIT privileges

Overall explanation
Granting a user the MODIFY, MONITOR, and OPERATE privileges on all virtual warehouses is equivalent to giving them the global MANAGE WAREHOUSES privilege in Snowflake. These combined privileges allow the user to modify the configuration of warehouses, monitor their performance, and control their operation.

For more detailed information, refer to the official Snowflake documentation.

Question 64
Skipped
Which of the following describes how clustering keys work in Snowflake?

Clustering keys create a distributed, parallel data structure of pointers to a table's rows and columns.

Clustering keys update the micro-partitions in place with a full sort, and impact the DML operations.

Correct answer
Clustering keys sort the designated columns over time, without blocking DML operations.

Clustering keys establish a hashed key on each node of a virtual warehouse to optimize joins at run-time.

Overall explanation
In Snowflake, clustering keys organize the data within micro-partitions by sorting specified columns incrementally, without impacting DML operations like inserts, updates, or deletes.

For more detailed information, refer to the official Snowflake documentation.

Question 65
Skipped
What privilege is needed for a Snowflake user to see the definition of a secure view?

Correct answer
OWNERSHIP

MODIFY

USAGE

CREATE

Overall explanation
The definition of a secure view is only visible to users who have been granted the role that owns the view. However, users with the IMPORTED PRIVILEGES privilege on the SNOWFLAKE database or another shared database can access secure view definitions through the VIEWS Account Usage view. Additionally, users with the ACCOUNTADMIN role or the SNOWFLAKE.OBJECT_VIEWER database role can view secure view definitions via this view.

For more detailed information, refer to the official Snowflake documentation.

Question 66
Skipped
What are characteristics of Snowsight worksheets? (Choose two.)

Users are limited to running only one query on a worksheet.

Worksheets can be grouped under folders, and a folder of folders.

Correct selection
Each worksheet is a unique Snowflake session.

Correct selection
Users can import worksheets and share them with other users.

The Snowflake session ends when a user switches worksheets.

Overall explanation
Each worksheet operates in its own session, allowing isolated query execution, and Snowsight also supports importing and sharing worksheets, facilitating collaboration.

For more detailed information, refer to the official Snowflake documentation.

Question 67
Skipped
A Snowflake user has two tables that contain numeric values and is trying to find out which values are present in both tables.

Which set operator should be used?

MINUS

Correct answer
INTERSECT

MERGE

UNION

Overall explanation
INTERSECT: This set operator should be used to find the values that are present in both tables, as it returns only the common values between the two.

For more detailed information, refer to the official Snowflake documentation.

Question 68
Skipped
What is a best practice after creating a custom role?

Create the custom role using the SYSADMIN role.

Assign the custom role to the PUBLIC role.

Correct answer
Assign the custom role to the SYSADMIN role.

Add _CUSTOM to all custom role names.

Overall explanation
After creating a custom role, it is best practice to assign it to the SYSADMIN role to manage access to database objects and other roles, ensuring appropriate privileges are in place for administration.

For more detailed information, refer to the official Snowflake documentation.

Question 69
Skipped
Which feature or service should be used to identify data about a department that was responsible for a recent revenue shortfall?

AI_EXTRACT

Snowpark

Correct answer
ML Functions

Snowpipe

Overall explanation
ML Functions — specifically Contribution Explorer — are intended for root cause analysis of metric fluctuations.

Contribution Explorer evaluates changes in observed metrics (e.g., revenue, sales volume) and identifies which dimensions or data segments are driving the variation. This supports targeted investigation by highlighting contributing factors such as geography, customer segments, sales representatives, or industry categories.

It is designed to accelerate diagnostic analysis when performance deviates from expectations.

Other features serve different purposes:

Snowpark is a development framework for building data applications and transformations.

Snowpipe automates data ingestion workflows.

AI_EXTRACT focuses on extracting structured information from unstructured content.

Contribution Explorer is specifically aligned with metric shift analysis and insight generation.

For more detailed information, refer to the official Snowflake documentation.

Question 70
Skipped
A user executes the following SQL query:

create table SALES_BKP like SALES;

What are the cost implications for processing this query?

Processing costs will be generated based on how long the query takes.

Correct answer
No costs will be incurred as the query will use metadata.

The cost for running the virtual warehouse will be charged by the second.

Storage costs will be generated based on the size of the data.

Overall explanation
The CREATE TABLE ... LIKE command only creates a new table with the same structure as the original but does not copy any data, so no storage or processing costs are incurred since it operates at the metadata level.

For more detailed information, refer to the official Snowflake documentation.

Question 71
Skipped
What is the COPY INTO command option default for unloading data into multiple files?

SINGLE = TRUE

Correct answer
SINGLE = FALSE

SINGLE = 0

SINGLE = NULL

Overall explanation
The default option for the COPY INTO command when unloading data into multiple files is SINGLE = FALSE. When SINGLE is set to FALSE, the COPY INTO command will unload data into multiple files, allowing for better performance and parallel processing. If you set SINGLE = TRUE, the data will be unloaded into a single file instead.

For more detailed information, refer to the official Snowflake documentation.

Question 72
Skipped
What is the minimum Snowflake Edition that supports secure storage of Protected Health Information (PHI) data?

Virtual Private Snowflake Edition

Enterprise Edition

Correct answer
Business Critical Edition

Standard Edition

Overall explanation
Business Critical Edition is the minimum Snowflake edition that provides the necessary security features for storing Protected Health Information (PHI), including enhanced encryption and compliance with healthcare data regulations.

For more detailed information, refer to the official Snowflake documentation.

Question 73
Skipped
When data is loaded into Snowflake, what formats does Snowflake use internally to store the data in cloud storage? (Choose two.)

Key-value

Correct selection
Compressed

Document

Correct selection
Columnar

Graph

Overall explanation
When data is loaded into Snowflake, it is stored internally in Columnar and Compressed formats.

For more detailed information, refer to the official Snowflake documentation.

Question 74
Skipped
Which data type is recommended to store a true or false value in Snowflake?

INTEGER

NUMBER

Correct answer
BOOLEAN

BLOB

Overall explanation
A few comments:

The BOOLEAN data type is explicitly designed to store logical values: TRUE, FALSE, and NULL.

While some systems use 0 and 1 to represent false and true, Snowflake provides a native Boolean type which is semantically clearer and more efficient for logical operations

For more detailed information, refer to the official Snowflake documentation.

Question 75
Skipped
What is the purpose of enabling Federated Authentication on a Snowflake account?

Disables the ability to use key pair and basic authentication (e.g., username/password) when connecting

Forces users to connect through a secure network proxy

Correct answer
Allows users to connect using secure single sign-on (SSO) through an external identity provider

Allows dual Multi-Factor Authentication (MFA) when connecting to Snowflake

Overall explanation
Enabling Federated Authentication allows Snowflake users to authenticate via SSO, using an external identity provider for secure and streamlined access.

For more detailed information, refer to the official Snowflake documentation.

Question 76
Skipped
This statement is run:

SELECT { 'key' : { 'subkey': 'value' }} mycolumn;



What notations will retrieve the 'value' from the VARIANT column? (Choose three.)

mycolumn.key:subkey
Correct selection
mycolumn:key.subkey
Correct selection
mycolumn:key:subkey
mycolumn.key.subkey
Correct selection
mycolumn['key'].subkey
mycolumn.key.Subkey
Overall explanation
There are two ways to access JSON elements: dot notation and bracket notation. Column names are case-insensitive, but element names are case-sensitive.

For more detailed information, refer to the official Snowflake documentation.

Question 77
Skipped
How can a relational table be unloaded into a JSON file?

Use the PUT command with the file_format set as JSON.

Use the GET command with the file_format set as JSON.

Correct answer
Use the OBJECT_CONSTRUCT function in conjunction with the COPY INTO [location] command.

Use the COPY INTO [location] command with the file_format set as JSON.

Overall explanation
We can use the OBJECT_CONSTRUCT function combined with the COPY command to convert the rows in a relational table to a single VARIANT column and unload the rows into a JSON file.

Example:

COPY INTO @stage
FROM (SELECT OBJECT_CONSTRUCT('field1', field1, 'field2', field2) FROM table)
FILE_FORMAT = (TYPE = JSON);
For more detailed information, refer to the official Snowflake documentation.

Question 78
Skipped
Which function can be used with the COPY INTO statement to convert rows from a relational table to a single VARIANT column, and to unload rows into a JSON file?

TO_VARIANT

OBJECT_AS

FLATTEN

Correct answer
OBJECT_CONSTRUCT

Overall explanation
The OBJECT_CONSTRUCT function can be used with the COPY INTO statement to convert rows from a relational table into a single VARIANT column and unload the data into a JSON file. This function constructs an object from a list of key-value pairs, which is ideal for transforming relational data into JSON format when unloading data in Snowflake

For more detailed information, refer to the official Snowflake documentation.

Question 79
Skipped
What are potential impacts of storing non-native values like dates and timestamps in a VARIANT column in Snowflake?

Correct answer
Slower query performance and increased storage consumption

Slower query performance and decreased storage consumption

Faster query performance and decreased storage consumption

Faster query performance and increased storage consumption

Overall explanation
Storing non-native values like dates and timestamps in a VARIANT column in Snowflake can lead to slower query performance and increased storage consumption. This is because VARIANT columns store data in a semi-structured format, which requires additional processing to interpret the values during queries.

For more detailed information, refer to the official Snowflake documentation.

Question 80
Skipped
This command is executed:



CREATE TABLE new_table CLONE existing_table COPY GRANT;



What will happen to the privileges of any cloned objects?

Correct answer
The clone will inherit all privileges except OWNERSHIP from the source object.

The clone will not inherit any privileges from the source object.

The clone will only inherit SELECT privileges from the source object.

The clone will inherit all privileges, including OWNERSHIP, from the source object.

Overall explanation
When we use the COPY GRANTS parameter in a CREATE TABLE statement, Snowflake copies all privileges from the source table to the new one—except for OWNERSHIP. This also applies to other CREATE commands that support the COPY GRANTS clause.

For more detailed information, refer to the official Snowflake documentation.

Question 81
Skipped
What technique does Snowflake use to limit the number of micro-partitions scanned by each query?

Correct answer
Pruning

Indexing

Map reduce

B-tree

Overall explanation
Snowflake uses a technique called micro-partition pruning to limit the number of micro-partitions scanned by each query. This process helps optimize query performance by only scanning the micro-partitions that are relevant to the query.

For more detailed information, refer to the official Snowflake documentation.

Question 82
Skipped
Which table type is used in the file processing pipeline to process unstructured data in Snowflake?

Transient

Temporary

Standard

Correct answer
Directory

Overall explanation
A directory table is an implicit object on a stage that stores file-level metadata about data files, similar to an external table but without its own privileges. It’s supported on both internal and external stages and can be added when creating or altering a stage. Directory tables let you list all unstructured files on a stage, create views combining file metadata with other data, and build file processing pipelines using Snowpark or external functions.

For more detailed information, refer to the official Snowflake documentation.

Question 83
Skipped
What table functions in the Snowflake Information Schema can be queried to retrieve information about directory tables? (Choose two.)

EXTERNAL_TABLE_FILES

Correct selection
AUTO_REFRESH_REGISTRATION_HISTORY

EXTERNAL_TABLE_FILE_REGISTRATION_HISTORY

Correct selection
STAGE_DIRECTORY_FILE_REGISTRATION_HISTORY

MATERIALIZED_VIEW_REFRESH_HISTORY

Overall explanation
AUTO_REFRESH_REGISTRATION_HISTORY retrieves the details of data files that have been registered in the metadata of specified objects, along with the credits charged for these actions.

STAGE_DIRECTORY_FILE_REGISTRATION_HISTORY retrieves information regarding the metadata history for a directory table, including any errors encountered during the metadata refresh process.

For more detailed information, refer to the official Snowflake documentation.

Question 84
Skipped
How does the authorization associated with a pre-signed URL work for an unstructured file?

Only the users who have roles with sufficient privileges on the URL can access the referenced file.

Only the user who generates the URL can use the URL to access the referenced file.

Correct answer
Anyone who has the URL can access the referenced file for the life of the token.

The role specified in the GET REST API call must have sufficient privileges on the stage to access the referenced file using the URL.

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 85
Skipped
Which of the following SQL statements will list the version of the drivers currently being used?

Execute SELECT CURRENT_ODBC_CLIENT(); from the Web UI

Execute SELECT CURRENT_VERSION(); from the Python Connector

Execute SELECT CURRENT_JDBC_VERSION(); from SnowSQL

Correct answer
Execute SELECT CURRENT_CLIENT(); from an application

Overall explanation
Execute SELECT CURRENT_CLIENT(); command retrieves the version of the client or driver currently being used, helpful for identifying the connector details.

For more detailed information, refer to the official Snowflake documentation.

Question 86
Skipped
Masking policies can be applied to which of the following Snowflake objects? (Choose two.)

A stored procedure

Correct selection
A materialized view

A pipe

Correct selection
A table

A stream

Overall explanation
Masking policies can be applied to tables and materialized views in Snowflake to control access to sensitive data by masking the values based on specified conditions.

For more detailed information, refer to the official Snowflake documentation.

Question 87
Skipped
Which Snowflake partner category is represented at the top of this diagram (labeled 1)?



Security and Governance

Correct answer
Data Integration

Machine Learning and Data Science

Business Intelligence

Overall explanation
For more detailed information, refer to the official Snowflake documentation.

Question 88
Skipped
Which statement accurately describes a characteristic of a materialized view?

Querying a materialized view is slower than executing a query against the base table of the view.

Materialized view refreshes need to be maintained by the user.

Data accessed through materialized views can be stale.

Correct answer
A materialized view can query only a single table.

Overall explanation
A materialized view in Snowflake has the limitation of not supporting joins between multiple tables.

For more detailed information, refer to the official Snowflake documentation.

Question 89
Skipped
Which features make up Snowflake's column level security? (Choose two.)

Correct selection
Dynamic Data Masking

Key pair authentication

Row access policies

Continuous Data Protection (CDP)

Correct selection
External Tokenization

Overall explanation
The correct answer is Dynamic Data Masking and External Tokenization. These features enable column-level security in Snowflake by masking sensitive data dynamically and allowing for secure data tokenization externally.

For more detailed information, refer to the official Snowflake documentation.

Question 90
Skipped
Which DDL/DML operation is allowed on an inbound data share?

INSERT INTO

MERGE

ALTER TABLE

Correct answer
SELECT

Overall explanation
With inbound data shares in Snowflake, you can only read the shared data using SELECT. Operations like ALTER TABLE, INSERT INTO, and MERGE are not permitted because the data in a share is read-only for the consumer.

For more detailed information, refer to the official Snowflake documentation.

Question 91
Skipped
Which role allows a Snowflake user to view table-level storage utilization information from the TABLE_STORAGE_METRICS view by default?

USERADMIN

Correct answer
ACCOUNTADMIN

SECURITYADMIN

SYSADMIN

Overall explanation
To query this view, we must use the ACCOUNTADMIN role.

For more detailed information, refer to the official Snowflake documentation.

Question 92
Skipped
At what level is the ALLOW_CLIENT_MFA_CACHING parameter configurable in Snowflake?

User

Virtual warehouse

Correct answer
Account

Session

Overall explanation
ALLOW_CLIENT_MFA_CACHING parameter can only be set for Account.

For more detailed information, refer to the official Snowflake documentation.

Question 93
Skipped
What is the benefit of using the STRIP_OUTER_ARRAY parameter with the COPY INTO [table] command when loading data from a JSON file into a table?

Correct answer
It removes the outer array structure and loads separate rows of data.

It flattens multiple arrays into a single array.

It tokenizes each data string using the defined delimiters.

It transforms a pivoted table into an array.

Overall explanation
JSON datasets are usually just many documents joined together. Sometimes, though, you get one giant array with all the records inside. You don't need commas or line breaks between the documents (though they're allowed). If your data is bigger than the maximum allowed, use the STRIP_OUTER_ARRAY option with the COPY INTO <table> command. This will get rid of the big outer array and put each record into its own row in the table.

For more detailed information, refer to the official Snowflake documentation.

Question 94
Skipped
Which of the following are best practice recommendations that should be considered when loading data into Snowflake? (Choose two.)

Remove semi-structured data types.

Correct selection
Avoid using embedded characters such as commas for numeric data types.

Correct selection
Load files that are approximately 100-250 MB.

Remove all dates and timestamps.

Load files that are approximately 25 MB or smaller.

Overall explanation
100-250MB is the sweet spot and ensures optimal performance during the loading process, especially for bulk operations.

Avoiding using embedded characters helps to prevent errors during data parsing and loading, ensuring data consistency.

For more detailed information, refer to the official Snowflake documentation.

Question 95
Skipped
Which types of charts does Snowsight support? (Choose two.)

Correct selection
Scorecards

Area charts

Radar charts

Column charts

Correct selection
Bar charts

Overall explanation
Heat grids, Scorecards, Bar charts, Line charts, Scatterplots are chart types supported by Snowsight, allowing users to visualize data trends and relationships in their dashboards.

For more detailed information, refer to the official Snowflake documentation.

Question 96
Skipped
What should an account administrator do to help a user log into Snowflake, if the user cannot authenticate using Multi-Factor Authentication (MFA)?

Set ALLOW_CLIENT_MFA_CACHING to FALSE for the user.

Set ALLOW_ID_TOKEN to FALSE for the user.

Set MINS_TO_BYPASS_MFA equal to 0 for the user.

Correct answer
Set DISABLE_MFA to TRUE for the user.

Overall explanation
If a user cannot authenticate using Multi-Factor Authentication (MFA), the account administrator can disable MFA by setting DISABLE_MFA to TRUE, allowing the user to log in without it. This can be useful for troubleshooting or temporary access.

Setting MINS_TO_BYPASS_MFA equal to 0 for the user would allow bypassing MFA after a certain period of inactivity, but setting it to 0 would immediately disable the bypass feature.

ALLOW_CLIENT_MFA_CACHING option controls whether MFA caching is allowed on the client side.

For more detailed information, refer to the official Snowflake documentation.

Question 97
Skipped
A query containing a WHERE clause is running longer than expected. The Query Profile shows all micro-partitions being scanned.



How should this query be optimized?

Create a view on the table.

Add a Dynamic Data Masking policy to the table.

Correct answer
Add a clustering key to the table.

Add a LIMIT clause to the query.

Overall explanation
The keyword of the question is 'all micro-partitions'. This means that you are not effectively pruning micro-partitions in the query.

Clustering keys in Snowflake group similar rows together in micro-partitions. For big tables, this helps queries run faster because Snowflake can skip over micro-partitions that don't match the query's filters.

For more detailed information, refer to the official Snowflake documentation.

Question 98
Skipped
Which command should be used to assign a key to a Snowflake user who needs to connect using key pair authentication?

ALTER USER jsmith SET RSA_P8_KEY='MIIBIjANBgkqh...';
ALTER USER jsmith SET ENCRYPTED_KEY='MIIBIjANBgkqh...';
ALTER USER jsmith SET RSA_PRIVATE_KEY='MIIBIjANBgkqh...';
Correct answer
ALTER USER jsmith SET RSA_PUBLIC_KEY='MIIBIjANBgkqh...';
Overall explanation
Key pair authentication is a security method that uses a pair of cryptographic keys: a public key and a private key. The public key is shared with others, while the private key is kept secret. When a request is made, the private key is used to sign the data, and the recipient can verify the signature using the corresponding public key.

For more detailed information, refer to the official Snowflake documentation.

Question 99
Skipped
Which feature of Snowflake’s Continuous Data Protection (CDP) has associated costs?

Multi-Factor Authentication (MFA)

End-to-end encryption

Correct answer
Fail-safe

Network policies

Overall explanation
Explicación general

Fail-safe is a data recovery feature designed to protect against data loss after the Time Travel period ends, but it incurs additional storage costs during the 7-day Fail-safe period.

For more detailed information, refer to the official Snowflake documentation.

Question 100
Skipped
While using a COPY command with a Validation_mode parameter, which of the following statements will return an error?

Statements that insert a duplicate record during a load

Correct answer
Statements that transform data during a load

Statements that have duplicate file names

Statements that have a specific data type in the source

Overall explanation
When using the COPY command with the VALIDATION_MODE parameter, transformations are not allowed, and any attempt to perform data transformations during validation will result in an error.

For more detailed information, refer to the official Snowflake documentation.

Question 101
Skipped
What is a directory table in Snowflake?

A database object with grantable privileges for unstructured data tasks.

A Snowflake table specifically designed for storing unstructured files.

A separate database object that is used to store file-level metadata.

Correct answer
An object layered on a stage that is used to store file-level metadata.

Overall explanation
This table allows for the organization and management of file metadata, such as file names and other attributes, which can be useful for working with staged data in unstructured formats.

For more detailed information, refer to the official Snowflake documentation.

Question 102
Skipped
Which permission on a Snowflake virtual warehouse allows the role to resize the warehouse?

MONITOR

USAGE

Correct answer
MODIFY

ALTER

Overall explanation
MODIFY privilege is required to resize a virtual warehouse.

For more detailed information, refer to the official Snowflake documentation.

Question 103
Skipped
What is the default authenticator while using the JDBC driver connection in Snowflake?

Correct answer
snowflake

username_password_mfa

externalbrowser

snowflake_jwt

Overall explanation
The authenticator parameter specifies the method for verifying user login credentials, and can be set to snowflake to use the internal Snowflake authenticator for authentication.

For more detailed information, refer to the official Snowflake documentation.

Question 104
Skipped
According to Snowflake best practice recommendations, which role should be used to create databases?

ACCOUNTADMIN

USERADMIN

SECURITYADMIN

Correct answer
SYSADMIN

Overall explanation
According to Snowflake best practices, the SYSADMIN role should be used to create databases, as it is responsible for managing objects like databases, schemas, and tables.

For more detailed information, refer to the official Snowflake documentation.

Question 105
Skipped
Which of the following indicates that it may be appropriate to use a clustering key for a table? (Choose two.)

The table contains a column that has very low cardinality.

Correct selection
Queries on the table are running slower than expected.

DML statements that are being issued against the table are blocked.

Correct selection
The clustering depth for the table is large.

The table has a small number of micro-partitions.

Overall explanation
A large clustering depth and slow query performance indicate that the table's data is not well-organized, and a clustering key can help improve query performance by better organizing data within micro-partitions.

For more detailed information, refer to the official Snowflake documentation.

Question 106
Skipped
Which of the following are benefits of micro-partitioning? (Choose two.)

Correct selection
Micro-partitions are immutable objects that support the use of Time Travel.

Micro-partitions cannot overlap in their range of values.

Correct selection
Micro-partitions can reduce the amount of I/O from object storage to virtual warehouses.

Micro-partitions can be defined on a schema-by-schema basis.

Rows are automatically stored in sorted order within micro-partitions.

Overall explanation
Since micro-partitions are immutable, they work seamlessly with Snowflake's Time Travel feature, allowing users to access historical data.

By organizing data into micro-partitions, Snowflake can efficiently scan only the necessary partitions, reducing I/O and improving query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 107
Skipped
A user has 10 files in a stage containing new customer data. The ingest operation completes with no errors, using the following command:

COPY INTO my_table FROM @my_stage;

The next day the user adds 10 files to the stage so that now the stage contains a mixture of new customer data and updates to the previous data. The user did not remove the 10 original files.

If the user runs the same COPY INTO command what will happen?

Correct answer
All data from only the newly-added files will be appended to the table.

All data from all of the files on the stage will be appended to the table.

Only data about new customers from the new files will be appended to the table.

The operation will fail with the error UNCERTAIN FILES IN STAGE.

Overall explanation
Snowflake automatically tracks which files have already been loaded and skips them, ensuring that only the new files are ingested to prevent duplicates.

For more detailed information, refer to the official Snowflake documentation.

Question 108
Skipped
How can a Snowflake user access a JSON object, given the following table? (Choose two.)



src:salesPerson.Name

src:salesperson.name

Correct selection
SRC:salesPerson.name

SRC:salesPerson.Name

Correct selection
src:salesPerson.name

Overall explanation
It is important to remember what is case sensitive and what is case insensitive when making queries on semi-structured data.

For more detailed information, refer to the official Snowflake documentation.

Question 109
Skipped
Which cache type is used to cache data output from SQL queries?

Correct answer
Result cache

Metadata cache

Local file cache

Remote cache

Overall explanation
This cache type is used to store the data output from SQL queries, allowing Snowflake to return cached results for repeated queries without re-executing them, improving performance.

For more detailed information, refer to the official Snowflake documentation.

Question 110
Skipped
Which privilege is required on a virtual warehouse to abort any existing executing queries?

MONITOR

MODIFY

USAGE

Correct answer
OPERATE

Overall explanation
OPERATE privilege on a virtual warehouse is required to abort existing executing queries. This privilege allows a role to perform actions such as suspending or resuming the warehouse, as well as aborting queries running on it.

For more detailed information, refer to the official Snowflake documentation.

Question 111
Skipped
What is a key benefit of using organizations in Snowflake?

Ability to use zero-copy cloning across accounts

Correct answer
Ability to consolidate account management and billing

Ability to access new releases for testing and validation purposes

Ability to use ACCOUNT_USAGE views

Overall explanation
A key benefit of using organizations in Snowflake is the ability to consolidate account management and billing across multiple accounts. This allows for centralized control and easier tracking of usage, cost management, and governance across all accounts within an organization.

For more detailed information, refer to the official Snowflake documentation.

Question 112
Skipped
Which type of charts are supported by Snowsight? (Choose two.)

Gantt charts

Pie charts

Correct selection
Scatterplots

Correct selection
Line charts

Flowcharts

Overall explanation
Heat grids, Scorecards, Bar charts, Line charts, Scatterplots are chart types supported by Snowsight, allowing users to visualize data trends and relationships in their dashboards.

For more detailed information, refer to the official Snowflake documentation.

Question 113
Skipped
Which parameter can be used to instruct a COPY command to verify data files instead of loading them into a specified table?

STRIP_NULL_VALUES

SKIP_BYTE_ORDER_MARK

REPLACE_INVALID_CHARACTERS

Correct answer
VALIDATION_MODE

Overall explanation
VALIDATION_MODE parameter allows the COPY command to verify the data files' structure and content without actually loading them into the table, useful for error checking before ingestion.

Question 114
Skipped
Which is the MINIMUM required Snowflake edition that a user must have if they want to use AWS/Azure Privatelink or Google Cloud Private Service Connect?

Enterprise

Correct answer
Business Critical

Standard

Premium

Overall explanation
The minimum required Snowflake edition to use AWS/Azure PrivateLink or Google Cloud Private Service Connect is the Business Critical edition, which offers enhanced security features for private connectivity.

For more detailed information, refer to the official Snowflake documentation.

Question 115
Skipped
There are two Snowflake accounts in the same cloud provider region: one is production and the other is non-production.

How can data be easily transferred from the production account to the non-production account?

Create a reader account using the production account and link the reader account to the non-production account.

Clone the data from the production account to the non-production account.

Correct answer
Create a data share from the production account to the non-production account.

Create a subscription in the production account and have it publish to the non-production account.

Overall explanation
Typical Data Sharing use case. Creating a data share is the easiest way to transfer data between Snowflake accounts in the same cloud provider region. A data share allows the non-production account to access the data without copying or duplicating it.

For more detailed information, refer to the official Snowflake documentation.

Question 116
Skipped
A view is defined on a permanent table. A temporary table with the same name is created in the same schema as the referenced table.

What will the query from the view return?

The data from the permanent table.

An error stating that the referenced object could not be uniquely identified.

An error stating that the view could not be compiled.

Correct answer
The data from the temporary table.

Overall explanation
It's important to remember that temporary tables take priority over regular tables with the same name within a session. This can cause some unexpected behavior when performing DDL on both temporary and non-temporary tables.

For example, you can create a temporary table that shares a name with an existing regular table, effectively hiding the regular table. Or, you could create a regular table that has the same name as a temporary table; in this case, the temporary table would obscure the regular one. In either scenario, any queries or operations you run on that table name will only affect the temporary table within that session.

For more detailed information, refer to the official Snowflake documentation.

Question 117
Skipped
How should clustering be used to optimize the performance of queries that run on a very large table?

Use the column that is most-frequently used in query select clauses as the clustering key.

Manually re-cluster the table regularly.

Choose one high cardinality column as the clustering key.

Correct answer
Assess the average table depth to identify how clustering is impacting the query.

Overall explanation
By evaluating the average table depth, you can determine how effectively clustering is working. This metric helps assess whether data is optimally organized within micro-partitions to improve query performance on large tables.

This is a tricky question because there is an option that seems good but isn't: "Use the column that is most-frequently used in query select clauses as the clustering key." This option can be misleading, as one of the criteria for choosing clustering key columns is to select columns widely used in filters, but the option refers to columns that are frequently selected in queries, which is not the correct consideration for clustering.

Question 118
Skipped
Which role has the privileges to describe a share?

ORGADMIN

SYSADMIN

SECURITYADMIN

Correct answer
ACCOUNTADMIN

Overall explanation
Only the ACCOUNTADMIN role can successfully describe a share. Using any other role to run this command results in an error due to insufficient privileges.

For more detailed information, refer to the official Snowflake documentation.

Question 119
Skipped
A Snowflake user needs to share a data set and wants it to be available to any Snowflake account that resides in the same cloud region.

What is the recommended way to do this?

Correct answer
Use a public listing.

Use a direct share.

Use an external stage.

Use a Data Exchange.

Overall explanation
To distribute a dataset to any Snowflake account within the same cloud region, a public listing on the Snowflake Marketplace is the appropriate mechanism.

Public listings allow providers to:

Make data discoverable to any eligible Snowflake account (within the same or across regions).

Optionally publish the data publicly on the Marketplace.

Attach structured metadata to describe the data product.

Monitor consumer adoption and usage metrics.

In contrast, direct shares are limited to explicitly specified accounts and do not provide public discoverability. Data Exchanges are designed for curated or restricted communities, and external stages are storage constructs rather than governed sharing mechanisms.

For more detailed information, refer to the official Snowflake documentation.

Question 120
Skipped
A user unloaded a Snowflake table called mytable to an internal stage called mystage.

Which command can be used to view the list of files that has been uploaded to the stage?

Correct answer
list @mystage;

list @%mystage;

list @%mytable;

list @mytable;

Overall explanation
list @mystage;: This command is used to view the list of files that have been uploaded to the internal stage called mystage.

For more detailed information, refer to the official Snowflake documentation.

Question 121
Skipped
Which clause is used to define a function that may return different values for different rows?

RETURNS

Correct answer
VOLATILE

IMMUTABLE

COMMENT

Overall explanation
An IMMUTABLE User-Defined Function (UDF) is expected to always return the same result for the same input, while a VOLATILE UDF may return different results even with identical inputs.

For more detailed information, refer to the official Snowflake documentation.

Question 122
Skipped
What is a characteristic of the maintenance of a materialized view?

Materialized views cannot be refreshed automatically.

A materialized view can be set up with the auto-refresh feature using the SQL SET command.

An additional set of scripts is needed to refresh data in materialized views.

Correct answer
A materialized view is automatically refreshed by a Snowflake managed warehouse.

Overall explanation
A materialized view is automatically refreshed by a Snowflake managed warehouse. Snowflake automatically manages the refresh of materialized views in the background, ensuring the view stays up to date with the base table data without requiring manual intervention.

For more detailed information, refer to the official Snowflake documentation.

Question 123
Skipped
The Query Profile in the image is for a query executed in Snowsight. Four of the key nodes are highlighted in yellow.



Which highlighted node will be the MOST expensive?

Aggregate[1]

Join[5]

TableScan[2]

Correct answer
TableScan[3]

Overall explanation
TableScan[3] is the most expensive operation because it accounts for 53.4% of the total query cost. Scanning a large table often consumes more resources, especially when it involves many rows, making it the most resource-intensive step in this query.

For more detailed information, refer to the official Snowflake documentation.

Question 124
Skipped
What is the PRIMARY advantage of using a Snowflake Notebook instead of using a SQL Worksheet?

Notebooks automatically optimize SQL queries to optimize execution speed and performance.

Correct answer
Notebooks allow for seamless integration of SQL and Python within the same programming environment.

Notebooks offer stronger data security and access controls compared to SQL Worksheets.

Unlike SQL worksheets, Notebooks include clones of the stored data used to run queries.

Overall explanation
A few comments:

The main distinguishing feature of Snowflake Notebooks is the ability to mix SQL cells, Python cells (using Snowpark), and Markdown cells in a single interface. This allows developers to perform data engineering tasks where SQL handles the querying and Python handles complex logic or machine learning, passing variables seamlessly between the two languages.

Both Worksheets and Notebooks enforce the same Role-Based Access Control (RBAC) and security models. Neither is inherently "stronger" than the other.

Query optimization is handled by the Snowflake Cloud Services layer (specifically the Global Services layer's optimizer). The interface used to submit the query (Notebook vs. Worksheet) does not change how the engine optimizes the execution plan.

For more detailed information, refer to the official Snowflake documentation.

Question 125
Skipped
What should be used to show the status of partial data loads and loading errors?

The ACCESS_HISTORY view

Correct answer
The COPY_HISTORY function

The QUERY_HISTORY function

The WAREHOUSE_LOAD_HISTORY function

Overall explanation
COPY_HISTORY function provides information on the status of data loads, including details on partial loads and any errors encountered, helping users monitor and troubleshoot loading processes.

For more detailed information, refer to the official Snowflake documentation.

Question 126
Skipped
When does Snowflake automatically encrypt data that is loaded into Snowflake? (Choose two.)

Correct selection
After loading the data into an internal stage.

After loading data into an external stage.

Only when using an encrypted stage.

After the data is micro-partitioned.

Correct selection
After loading the data into a table.

Overall explanation
Snowflake automatically encrypts data in the following two situations: after loading the data into a table and after loading the data into an internal stage. This ensures that data is encrypted for security once it's in a table or an internal stage.

For more detailed information, refer to the official Snowflake documentation.

Question 127
Skipped
A user created a database and set the DATA_RETENTION_TIME_IN_DAYS to 30, but did not set the DATA_RETENTION_TIME_IN_DAYS in table T1. After 5 days, the user accidentally drops table T1.

What are the considerations for recovering table T1?

The user can recover the table T1 after 30 days.

The table cannot be recovered because the DATA_RETENTION_TIME_IN_DAYS was not set for table T1.

The table can only be recovered by contacting Snowflake Support to recover the table from Fail-safe.

Correct answer
The table can be recovered because the table retention period default is at the database level.

Overall explanation
Since the user set the DATA_RETENTION_TIME_IN_DAYS to 30 at the database level, this retention period applies to all tables within the database, including table T1. Even though the retention time was not set explicitly at the table level, the default from the database level will be applied. This means the table can be recovered within the 30-day retention window without contacting Snowflake Support.

For more detailed information, refer to the official Snowflake documentation.

Question 128
Skipped
A JSON file that contains lots of dates and arrays needs to be processed in Snowflake. The user wants to ensure optimal performance while querying the data.

How can this be achieved?

Store the data in a table with a VARIANT data type and include STRIP_NULL_VALUES while loading the table. Query the table.

Store the data in a table with a VARIANT data type. Query the table.

Correct answer
Flatten the data and store it in structured data types in a flattened table. Query the table.

Store the data in an external stage and create views on top of it. Query the views.

Overall explanation
Flattening the data and storing it in structured data types (e.g., DATE, ARRAY) ensures optimal performance when querying, as structured tables are more efficient for query execution in Snowflake compared to semi-structured data types like VARIANT.

For more detailed information, refer to the official Snowflake documentation.

Question 129
Skipped
What happens when the values for both an ALLOWED_IP_LIST and a BLOCKED_IP_LIST are used in a network policy?

Correct answer
Snowflake applies the BLOCKED_IP_LIST first.

Snowflake applies the ALLOWED_IP_LIST first.

Snowflake ignores the ALLOWED_IP_LIST first.

Snowflake ignores the BLOCKED_IP_LIST first.

Overall explanation
When both an ALLOWED_IP_LIST and a BLOCKED_IP_LIST are used in a network policy, Snowflake applies the BLOCKED_IP_LIST first, denying access to any IPs on that list regardless of whether they are also in the allowed list.

For more detailed information, refer to the official Snowflake documentation.

Question 130
Skipped
Which column is returned when the FLATTEN table function is executed?

LEVEL

OUTPUT

ROWNUM

Correct answer
VALUE

Overall explanation
A few comments:

The FLATTEN table function is used to convert semi-structured data (like JSON arrays or objects) into a relational set of rows. When executed, it returns a fixed set of columns, one of which is VALUE. This column contains the actual value of the element in the array or object being flattened.

The standard columns returned by FLATTEN are:

SEQ

KEY

PATH

INDEX

THIS

For more detailed information, refer to the official Snowflake documentation.

Question 131
Skipped
Which of the following query profiler variables will indicate that a virtual warehouse is not sized correctly for the query being executed?

Synchronization

Initialization

Bytes sent over the network

Correct answer
Remote spillage

Overall explanation
This query profiler variable indicates that a virtual warehouse is not sized correctly for the query being executed, as it shows that the query results are spilling over to remote storage due to insufficient memory or resources.

For more detailed information, refer to the official Snowflake documentation.

Question 132
Skipped
Which solution improves the performance of point lookup queries that return a small number of rows from large tables using highly selective filters?

Automatic clustering

Materialized views

Correct answer
Search optimization service

Query acceleration service

Overall explanation
Search Optimization Service in Snowflake is designed to enhance the performance of queries that use highly selective filters, such as point lookups. It helps speed up the retrieval of a small subset of rows from large tables by optimizing how data is accessed, without needing to scan the entire table, thus significantly improving query performance for this specific use case.

For more detailed information, refer to the official Snowflake documentation.

Question 133
Skipped
Which SQL command can be used to verify the privileges that are granted to a role?

SHOW GRANTS ON ROLE

Correct answer
SHOW GRANTS TO ROLE

SHOW GRANTS FOR ROLE

SHOW ROLES

Overall explanation
SHOW GRANTS TO ROLE: This SQL command is used to verify the privileges that are granted to a specific role in Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 134
Skipped
Which type of workload is recommended for Snowpark-optimized virtual warehouses?

Workloads with unpredictable data volumes for each query

Workloads that are queried with small table scans and selective filters

Workloads with ad hoc analytics

Correct answer
Workloads that have large memory requirements

Overall explanation
Snowpark workloads can use both standard and Snowpark-optimized warehouses, but the latter are best for things like large memory needs or specific CPU requirements (like Machine Learning training or stored procedures on a single node). Snowpark UDFs and UDTFs might also benefit.

For more detailed information, refer to the official Snowflake documentation.

Question 135
Skipped
Using variables in Snowflake is denoted by using which SQL character?

#

@

Correct answer
$

&

Overall explanation
In Snowflake, using variables is denoted by the character $. You can define a variable using the SET command and reference it with the $ character. For example:

For more detailed information, refer to the official Snowflake documentation.

Question 136
Skipped
What is the maximum length of time travel available in the Snowflake Standard Edition?

90 Days

Correct answer
1 Day

30 Days

7 Days

Overall explanation
In the Snowflake Standard Edition, the maximum length of Time Travel available is 1 day, allowing users to access historical data for up to 24 hours after changes are made.

For more detailed information, refer to the official Snowflake documentation.

Question 137
Skipped
What is it called when a customer managed key is combined with a Snowflake managed key to create a composite key for encryption?

Client-side encryption

Hierarchical key model

Key pair authentication

Correct answer
Tri-secret secure encryption

Overall explanation
Tri-secret secure encryption method uses both a customer-managed key and a Snowflake-managed key to create a composite key, adding an extra layer of security to data encryption.

For more detailed information, refer to the official Snowflake documentation.

Question 138
Skipped
A user with which privileges can create or manage other users in a Snowflake account? (Choose two.)

MODIFY

SELECT

GRANT

Correct selection
OWNERSHIP

Correct selection
CREATE USER

Overall explanation
In Snowflake, a user with the OWNERSHIP privilege on a user object has full control over that object, including managing and modifying users. Additionally, the CREATE USER privilege allows a user to create new users and manage their basic properties, making both privileges necessary for managing other users within the account.

For more detailed information, refer to the official Snowflake documentation.

Question 139
Skipped
A user needs to link a private GitHub repository to Snowflake for stored procedure version control. Their company enforces secure authentication.



Which authentication method should be configured in the Git integration object?

Multi-Factor Authentication (MFA)

Correct answer
Personal Access Token

OAuth token

Username and password

Overall explanation
To securely connect a private GitHub repository to Snowflake, a Personal Access Token (PAT) should be used within the Git integration configuration.

The setup involves creating a Snowflake secret object that stores the GitHub credentials:

TYPE = PASSWORD

USERNAME = <GitHub username>

PASSWORD = <Personal Access Token>

This secret is then referenced in the API integration through the ALLOWED_AUTHENTICATION_SECRETS parameter and associated with the Git repository clone configuration.

Although OAuth is supported, a PAT is commonly used for secure access to private repositories and aligns well with enterprise authentication practices. Direct username/password authentication without a token is not recommended, and MFA is managed at the identity layer rather than configured directly in the Git integration object.

For more detailed information, refer to the official Snowflake documentation.

For additional technical details, see the official Snowflake documentation.

Question 140
Skipped
The bulk data load history that is available upon completion of the COPY statement is stored where and for how long?

In the metadata of the pipe for 14 days

In the metadata of the target table for 14 days

In the metadata of the pipe for 64 days

Correct answer
In the metadata of the target table for 64 days

Overall explanation
The bulk data load history is stored in the metadata of the target table for 64 days, allowing users to review and track historical load operations for an extended period.

For more detailed information, refer to the official Snowflake documentation.

Question 141
Skipped
What happens when an external or an internal stage is dropped? (Choose two.)

When dropping an internal stage, the files are deleted with the stage and the files are recoverable.

Correct selection
When dropping an external stage, the files are not removed and only the stage is dropped.

Correct selection
When dropping an internal stage, the files are deleted with the stage and the files are not recoverable.

When dropping an external stage, both the stage and the files within the stage are removed.

When dropping an internal stage, only selected files are deleted with the stage and are not recoverable.

Overall explanation
When dropping an external stage, the files are not removed and only the stage is dropped: External stages reference external storage, so dropping the stage does not affect the files stored externally.

When dropping an internal stage, the files are deleted with the stage and the files are not recoverable: Internal stages store files within Snowflake, and dropping the stage permanently deletes the files without recovery.

For more detailed information, refer to the official Snowflake documentation.

Question 142
Skipped
Which Snowflake URL type is used by directory tables?

Pre-signed

Scoped

Virtual-hosted style

Correct answer
File

Overall explanation
Directory tables in Snowflake use File URLs to reference and access the files stored in external stages or cloud storage locations.

For more detailed information, refer to the official Snowflake documentation.

Question 143
Skipped
A PUT command can be used to stage local files from which Snowflake interface?

.NET driver

Snowflake classic web interface (UI)

Correct answer
SnowSQL

Snowsight

Overall explanation
The PUT command can be used to stage local files from the SnowSQL interface, allowing users to upload files to an internal or external stage.

For more detailed information, refer to the official Snowflake documentation.

Question 144
Skipped
Which operation can be performed on Snowflake external tables?

Correct answer
ALTER

RENAME

UPDATE

INSERT

Overall explanation
The ALTER operation can be performed on Snowflake external tables, as Snowflake allows certain DML operations like ALTER to modify metadata or configurations on external tables, but not data manipulation.

For more detailed information, refer to the official Snowflake documentation.

Question 145
Skipped
By default, which role has access to the SYSTEM$GLOBAL_ACCOUNT_SET_PARAMETER function?

SECURITYADMIN

SYSADMIN

ACCOUNTADMIN

Correct answer
ORGADMIN

Overall explanation
Only ORGADMIN can call this SQL function.

For more detailed information, refer to the official Snowflake documentation.

Question 146
Skipped
Which service or feature in Snowflake is used to improve the performance of certain types of lookup and analytical queries that use an extensive set of WHERE conditions?

Tagging

Correct answer
Search optimization service

Query acceleration service

Data classification

Overall explanation
Search optimization service feature improves the performance of lookup and analytical queries that use extensive WHERE conditions by enabling faster data retrieval through optimized search paths.

For more detailed information, refer to the official Snowflake documentation.

Question 147
Skipped
What are reasons for using the VALIDATE function in Snowflake after a COPY INTO command execution? (Choose two.)

To fix errors that were made during the execution of the COPY INTO command

Correct selection
To validate the files that have been loaded earlier using the COPY INTO command

To count the number of errors encountered during the execution of the COPY INTO command

To identify potential issues in the COPY INTO command before it is executed

Correct selection
To return errors encountered during the execution of the COPY INTO command

Overall explanation
Easy to confuse this with the VALIDATION_MODE option for COPY INTO. This question is about VALIDATE after the COPY INTO.

For more detailed information, refer to the official Snowflake documentation.

Question 148
Skipped
In a managed access schema, who can grant privileges on objects in the schema to other roles? (Choose two.)

The ORGADMIN system role

Correct selection
The role with the MANAGE GRANTS privilege

The role that owns the object in the schema

The USERADMIN system role

Correct selection
The schema owner role

Overall explanation
In a managed access schema in Snowflake, the schema owner has control over granting privileges on objects within the schema. Additionally, a role with the MANAGE GRANTS privilege can also grant privileges on objects in the schema to other roles.

For more detailed information, refer to the official Snowflake documentation.

Question 149
Skipped
Which command is used to unload data from a Snowflake table to an external stage?

COPY INTO followed by GET

GET

COPY INTO followed by PUT

Correct answer
COPY INTO

Overall explanation
COPY INTO command is used to unload data from a Snowflake table to an external stage, allowing the data to be exported to cloud storage or other external locations.

For more detailed information, refer to the official Snowflake documentation.

Question 150
Skipped
Who can activate and enforce a network policy for all users in a Snowflake account? (Choose two.)

A role that has the OWNERSHIP of the network policy

Correct selection
A role that has been granted the ATTACH POLICY privilege

Correct selection
A user with a SECURITYADMIN or higher role

A user with an USERADMIN or higher role

A role that has the NETWORK_POLICY account parameter set

Overall explanation
A network policy can be activated and enforced by a user with the SECURITYADMIN role or higher. Additionally, a role that has been granted the ATTACH POLICY privilege can enforce the network policy.

For more detailed information, refer to the official Snowflake documentation.

Question 151
Skipped
Which Snowflake object enables loading data from files as soon as they are available in a cloud storage location?

External stage

Stream

Task

Correct answer
Pipe

Overall explanation
A pipe in Snowflake enables loading data from files as soon as they are available in a cloud storage location, automating the data ingestion process when used with Snowpipe.



For more detailed information, refer to the official Snowflake documentation.

Question 152
Skipped
Which of the following roles are recommended to create and manage users and roles? (Choose two.)

ACCOUNTADMIN

Correct selection
USERADMIN

PUBLIC

Correct selection
SECURITYADMIN

SYSADMIN

Overall explanation
The recommended roles to create and manage users and roles in Snowflake are SECURITYADMIN and USERADMIN. These roles provide the necessary privileges for managing users and their associated roles effectively.



For more detailed information, refer to the official Snowflake documentation.

Question 153
Skipped
Which statement describes pruning?

The return of micro-partitions values that overlap with each other to reduce a query's runtime.

The ability to allow the result of a query to be accessed as if it were a table.

A service that is handled by the Snowflake Cloud Services layer to optimize caching.

Correct answer
The filtering or disregarding of micro-partitions that are not needed to return a query.

Overall explanation
Pruning refers to Snowflake's ability to skip unnecessary micro-partitions, thereby reducing the amount of data scanned and improving query performance.

For more detailed information, refer to the official Snowflake documentation.

Question 154
Skipped
Which command should be used to look into the validity of an XML object in Snowflake?

Correct answer
CHECK_XML

PARSE_XML

TO_XML

XMLGET

Overall explanation
CHECK_XML is the command used to verify the validity of an XML object in Snowflake, ensuring that the structure and content of the XML adhere to the expected format.

For more detailed information, refer to the official Snowflake documentation.

Question 155
Skipped
Which Snowflake table is an implicit object layered on a stage, where the stage can be either internal or external?

Transient table

Temporary table

A table with a materialized view

Correct answer
Directory table

Overall explanation
Directory table is an implicit object layered on a stage, either internal or external, which allows Snowflake users to query staged files as if they were tables.

For more detailed information, refer to the official Snowflake documentation.

Question 156
Skipped
What activities can be monitored by a user directly from Snowsight's Monitoring tab without using the Account_Usage views? (Choose two.)

Virtual warehouse metering history

Correct selection
Query history

Correct selection
Copy history

Login history

Event usage history

Overall explanation
Query history, Copy history: These activities can be monitored directly from Snowsight's Monitoring tab, allowing users to track query executions and data load/unload operations without needing to use the Account_Usage views.

For more detailed information, refer to the official Snowflake documentation.

Question 157
Skipped
Snowflake's approach to the management of system access combines which of the following models? (Choose two.)

Mandatory Access Control (MAC)

Security Assertion Markup Language (SAML)

Correct selection
Role-Based Access Control (RBAC)

Identity Access Management (AM)

Correct selection
Discretionary Access Control (DAC)

Overall explanation
Snowflake combines these models to manage system access. RBAC assigns permissions based on roles, while DAC allows users to grant access to objects they own.

For more detailed information, refer to the official Snowflake documentation.

Question 158
Skipped
Consider this SQL command:



SELECT
weather:station.element
FROM
weather_data;


What is the name of the column that data is being selected from?

element

weather_data

Correct answer
weather

station

Overall explanation
A few comments:

weather: The name of the column.

:: The operator used to traverse into a VARIANT column.

station: A key/path inside the JSON document stored in that column.

.element: A sub-field within the station object.

weather_data: The name of the table.

For more detailed information, refer to the official Snowflake documentation.

Question 159
Skipped
What is the name of the SnowSQL configuration file that is loaded last, allowing it to store connection information and override all other settings?

snowsql.pubkey

snowsql.cnf

history

Correct answer
config

Overall explanation
The config file in SnowSQL stores connection information, such as account details and other settings for establishing a connection to Snowflake.

For more detailed information, refer to the official Snowflake documentation.

Question 160
Skipped
How is the MANAGE GRANTS privilege applied?

At the database level

At the schema level

Correct answer
Globally

At the table level

Overall explanation
The MANAGE GRANTS privilege is applied globally, allowing the role with this privilege to manage grants across the entire Snowflake account, including the ability to grant or revoke privileges on any object.

For more detailed information, refer to the official Snowflake documentation.

Question 161
Skipped
When is the result set cache no longer available? (Choose two.)

When another warehouse is used to execute the query

Correct selection
When the underlying data has changed

When another user executes the query

When the warehouse used to execute the query is suspended

Correct selection
When it has been 24 hours since the last query

Overall explanation
The result set cache is no longer available if the underlying data has changed, or if 24 hours have passed since the last query was executed, as Snowflake automatically invalidates the cache in these cases.

For more detailed information, refer to the official Snowflake documentation.

Question 162
Skipped
Which task privilege does a Snowflake role need in order to suspend or resume a task? (Choose two.)

MODIFY

Correct selection
OPERATE

Correct selection
OWNERSHIP

USAGE

MONITOR

Overall explanation
To suspend or resume a task (using ALTER TASK … SUSPEND or ALTER TASK … RESUME) we need either the OPERATE or OWNERSHIP privilege on the task.

For more detailed information, refer to the official Snowflake documentation.

Question 163
Skipped
What general guideline does Snowflake recommend when setting the auto-suspension time limit?

Set query warehouses for suspension after 15 minutes.

Set query warehouses for suspension after 30 minutes.

Set tasks for immediate suspension.

Correct answer
Set tasks for suspension after 5 minutes.

Overall explanation
If you activate auto-suspend, it's advised to set it to a short interval (e.g., 5 or 10 minutes or less) since Snowflake uses per-second billing.

For more detailed information, refer to the official Snowflake documentation.

Question 164
Skipped
At which point is data encrypted when using a PUT command?

When it gets micro-partitioned

Correct answer
Before it is sent from the user's machine

After it reaches the internal stage

When it reaches the virtual warehouse

Overall explanation
Data is encrypted on the client side before being transmitted when using the PUT command in Snowflake, ensuring secure transfer to the internal stage.

For more detailed information, refer to the official Snowflake documentation.

Question 165
Skipped
What activities can a user with the ORGAMIN role perform? (Choose two.)

Correct selection
Create an account for an organization.

Select all the data in tables for all accounts in an organization.

Edit the account data for an organization.

Delete the account data for an organization.

Correct selection
View usage information for all accounts in an organization.

Overall explanation
A user with the ORGAMIN role in Snowflake can create accounts within the organization and has the ability to view usage information across all accounts within the organization. However, they do not have the privilege to edit or delete account data, nor do they have direct access to the data in tables for all accounts.

For more detailed information, refer to the official Snowflake documentation.

Question 166
Skipped
What happens when a Snowflake user changes the data retention period at the schema level? (Choose two)

Correct selection
All child objects that do not have an explicit retention period will automatically inherit the new retention period.

The schema-level retention period only applies to newly created objects.

All child objects will retain data for the new retention period.

All child objects with an explicit retention period will be overridden with the new retention period.

Correct selection
All explicit child object retention periods will remain unchanged.

Overall explanation
When a Snowflake user changes the data retention period at the schema level, all child objects (such as tables) that do not have their own explicitly set retention period will inherit the new retention period from the schema. However, any child objects that already have an explicit retention period will retain their own settings and will not be overridden by the schema-level change.

For more detailed information, refer to the official Snowflake documentation.

Question 167
Skipped
For non-materialized views, what column in Information Schema and Account Usage identifies whether a view is secure or not?

CHECK_OPTION

IS_UPDATEABLE

Correct answer
IS_SECURE

TABLE_NAME

Overall explanation
IS_SECURE column in the Information Schema and Account Usage views identifies whether a non-materialized view is secure or not, indicating if the view enforces additional security constraints.

For more detailed information, refer to the official Snowflake documentation.

Question 168
Skipped
What is the MINIMUM size requirement when creating a Snowpark-optimized virtual warehouse?

Small

Large

Medium

Correct answer
X-Small

Overall explanation
Formerly the minimum size to create a snowpark-optimized VWH was M, but the behavior has changed and it is now possible to create them with a minimum size XS.

For more detailed information, refer to the official Snowflake documentation.

Question 169
Skipped
Which account usage view in Snowflake can be used to identify the most-frequently accessed tables?

Correct answer
Access_History

Table_Storage_Metrics

Object_Dependencies

Tables

Overall explanation
Access_History view contains information about the historical access patterns for tables and views in your Snowflake account, including details on queries, users, and access frequency. By querying this view, you can analyze which tables are being accessed most frequently in your Snowflake environment.

For more detailed information, refer to the official Snowflake documentation.

Question 170
Skipped
What objects can be cloned within Snowflake? (Choose two.)

Correct selection
External named stages

Internal named stages

Correct selection
Schemas

External tables

Users

Overall explanation
You can clone external named stages (which point to cloud storage like buckets), but this only clones the stage definition in Snowflake, not the actual data in the cloud storage. Internal (Snowflake) named stages cannot be cloned.

For more detailed information, refer to the official Snowflake documentation.

Question 171
Skipped
What does the orange bar on an operator represent when reviewing the Query Profile?



A measure of progress of the operator's execution.

The fraction of data scanned from cache versus remote disk for the operator.

The cost of the operator in terms of the virtual warehouse CPU utilization.

Correct answer
The fraction of time that this operator consumed within the query step.

Overall explanation
The orange bar on an operator in the Query Profile represents the fraction of time that this operator consumed within the query step. It visually shows how much time the operator took compared to other operators in the execution process.

For more detailed information, refer to the official Snowflake documentation.

Question 172
Skipped
Any user with the appropriate privileges can view data storage for individual tables by using which queries? (Choose two.)

STORAGE_USAGE view in the ACCOUNT_USAGE schema

METERING_DAILY_HISTORY view in the ORGANIZATION_USAGE schema

Correct selection
TABLE_STORAGE_METRICS view in the INFORMATION_SCHEMA schema

Correct selection
TABLE_STORAGE_METRICS view in the ACCOUNT_USAGE schema

METERING_HISTORY view in the ACCOUNT_USAGE schema

Overall explanation
Both of these views provide detailed information on data storage at the table level. TABLE_STORAGE_METRICS in the ACCOUNT_USAGE schema gives insights across the account, while the same view in INFORMATION_SCHEMA provides table storage metrics within a specific database or schema.

For more detailed information, refer to the official Snowflake documentation.

Question 173
Skipped
Which data type can be used to store geospatial data in Snowflake?

Object

Correct answer
Geography

Geometry

Variant

Overall explanation
Geography data type is used to store geospatial data in Snowflake, allowing for the representation of geographic objects like points, lines, and polygons.

For more detailed information, refer to the official Snowflake documentation.

Question 174
Skipped
A Snowflake account has activated federated authentication.

What will occur when a user with a password that was defined by Snowflake attempts to log in to Snowflake?

Correct answer
The user will be able to log into Snowflake successfully.

After entering the username and password, the user will be redirected to an Identity Provider (IdP) login page.

The user will encounter an error, and will not be able to log in.

The user will be unable to enter a password.

Overall explanation
With federated authentication enabled for your account, Snowflake still permits the maintenance and use of Snowflake user credentials, such as login names and passwords. This means that account and security administrators can continue to create users with passwords managed in Snowflake. Additionally, users can log into Snowflake using their Snowflake credentials.

For more detailed information, refer to the official Snowflake documentation.

Question 175
Skipped
Which semi-structured file format is a compressed, efficient, columnar data representation?

Avro

Correct answer
Parquet

JSON

TSV

Overall explanation
Parquet is a compressed, efficient, columnar file format commonly used for storing and processing semi-structured data.



For more detailed information, refer to the official Snowflake documentation.