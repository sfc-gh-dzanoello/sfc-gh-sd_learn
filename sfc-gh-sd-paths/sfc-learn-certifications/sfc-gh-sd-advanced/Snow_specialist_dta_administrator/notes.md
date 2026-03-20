TABLE OF CONTENTS
SNOWPRO ADVANCED: ADMINISTRATOR STUDY GUIDE OVERVIEW 2
RECOMMENDATIONS FOR USING THE GUIDE 2
SNOWPRO ADVANCED: ADMINISTRATOR CERTIFICATION OVERVIEW 3
SNOWPRO ADVANCED: ADMINISTRATOR PREREQUISITE 4
STEPS TO SUCCESS 4
SNOWPRO ADVANCED: ADMINISTRATOR SUBJECT AREA BREAKDOWN 4
Domain 1.0: Snowflake Security, Role-Based Access Control (RBAC), and User
Administration 5
Domain 1.0 Study Resources 7
Domain 2.0: Account Management and Data Governance 8
Domain 2.0 Study Resources 9
Domain 3.0: Data and Object Management 10
Domain 3.0 Study Resources 11
Domain 4.0: Performance Monitoring and Tuning 12
Domain 4.0 Study Resources 14
Domain 5.0: Data Sharing and Snowflake Marketplace 15
Domain 5.0 Study Resources 16
Domain 6.0: Disaster Recovery, Backup, and Data Replication 17
Domain 6.0 Study Resources 17
SNOWPRO ADVANCED: ADMINISTRATOR SAMPLE QUESTIONS 18
NEXT STEPS 21
REGISTERING FOR YOUR EXAM 21
MAINTAINING YOUR CERTIFICATION 21
Page 1
SNOWPRO ADVANCED: ADMINISTRATOR STUDY GUIDE
OVERVIEW
This is a self-learning study guide that highlights concepts that may be covered on Snowflake’s
SnowPro Advanced: Administrator Certification exam.
This study guide does not guarantee certification success.
Holding the SnowPro Core certification in good standing is a prerequisite for taking the
Advanced: Data Administrator certification.
For an overview and more information on the SnowPro Core Certification exam or SnowPro
Advanced Certification series, please navigate here.
RECOMMENDATIONS FOR USING THE GUIDE
This guide will show the Snowflake topics and subtopics covered on the exam. Following the
topics will be additional resources consisting of videos, documentation, blogs, and/or exercises
to help you understand Administering on the Snowflake Data Cloud.
Estimated length of study guide: 10 – 13 hours
Some links may have more value than others, depending on your experience. The same
amount of time should not be spent on each link. Some links may appear in more than one
domain.
Page 2
SNOWPRO ADVANCED: ADMINISTRATOR CERTIFICATION
OVERVIEW
The SnowPro Advanced: Administrator exam tests advanced knowledge and skills used to apply
comprehensive data cloud administrative principles using Snowflake and its components. The
exam will assess skills through scenario-based questions and real-world examples.
This certification will test the ability to:
● Manage and administer Snowflake accounts, data security, and governance
● Manage and maintain database objects and virtual warehouses
● Perform database monitoring, tuning, and optimization
● Perform data sharing and use the Snowflake Marketplace
● Implement disaster recovery, perform backups, and replicate data
Target Audience:
2+ years of Snowflake Data Cloud Administrative experience, including practical, hands-on
experience using Snowflake. In addition, successful candidates may have:
● Fluency with ANSI and Snowflake extended SQL
This exam is designed for:
● Snowflake Administrators
● Snowflake Data Cloud Administrators
● Cloud Infrastructure Administrators
● Database Administrators
● Cloud Data Administrators
● Application Developers
Page 3
SNOWPRO ADVANCED: ADMINISTRATOR PREREQUISITE
Eligible individuals must hold an active SnowPro Core Certified credential. If you feel you need
more guidance on the fundamentals, please see the SnowPro Core Exam Study Guide.
STEPS TO SUCCESS
1. Review the Administrator Exam Guide
2. Attend Snowflake’s Instructor Led Administering Snowflake Training
3. And Attend Snowflake’s Instructor Led Administering Snowflake Training II
4. And Attend Snowflake’s Data Governance Training
5. Review and study applicable white papers and documentation
6. Get hands-on practical experience with relevant business requirements using Snowflake
7. Attend Snowflake Webinars
8. Complete Snowflake Virtual Hands-on Labs for more hands-on practical experience
9. Practice with sample questions here
10. Schedule your exam
11. Take your exam!
Additional Snowflake assets to check out for Advanced Administrator:
Snowflake for Dummies Guide Series Books
SNOWPRO ADVANCED: ADMINISTRATOR SUBJECT AREA
BREAKDOWN
This exam guide includes test domains, weightings, and objectives. It is not a comprehensive
listing of all the content that will be presented on this examination. The table below lists the main
content domains and their weightings.
Domain Domain Weightings
1.0 Snowflake Security, RBAC, and User Administration 31%
2.0 Account Management and Data Governance 18%
3.0 Data and Object Management 15%
4.0 Performance Monitoring and Tuning 20%
5.0 Data Sharing and Snowflake Marketplace 7%
6.0 Disaster Recovery, Backup, and Data Replication 9%
Page 4
Domain 1.0: Snowflake Security, Role-Based Access Control (RBAC), and
User Administration
1.1 Manage administrative roles
● Identify use cases and follow best
practices for ORGADMIN and
ACCOUNTADMIN roles (note:
ORGADMIN will be replaced with
GLOBARORGADMIN)
● Analyze the impact of
organizational-level changes on
account-level objects
1.2 Given a set of business requirements,
design access control framework
● Identify use cases for the different
frameworks
○ Discretionary Access Control
(DAC)
○ Role-Based Access Control
(RBAC)
○ User-based access Control
(UBAC)
● Determine the use cases for, and
hierarchy of, system-defined roles
● Determine the use cases for custom
security roles
● Analyze the implications of role
inheritance when granting or
revoking privileges
● Grant access to specific objects
within a database that require
privilege inheritance
1.3 Given a scenario, create and manage
access control.
● Identify and apply different
privileges available for each object
type
● Custom security roles and users
(SHOW command)
● Analyze and audit user and query
activity history using the
ACCOUNT_USAGE and
ORGANIZATION_USAGE schemas
1.4 Given a scenario, fine-tune access
controls.
● Secure the ACCOUNTADMIN role
● Use and manage database roles and
use cases
● Create custom roles
● Determine use cases for primary and
secondary roles
● Align usage of object access with
business functions
● Manage cloned objects and their
impact on granted privileges
● Create additional Administrators
● Monitor granted privileges to users
and roles, and on objects
● Implement and manage future grants
including restrictions
● Manage warehouse grants (for
example, USAGE, OPERATE,
MODIFY, MONITOR)
● Implement and manage managed
access schemas
● Provide access to non-account
Administrators to monitor billing and
usage information
● Manage account-level permissions
● Enable security and access control
for AI/ML models
Page 5
1.5 Set up and manage Snowflake
authentication.
● Establish federated authentication
and Single Sign-on (SSO) to
Snowflake
○ Configure an Identity
Provider (IdP) for Snowflake
○ Configure, use, and manage
federated authentication with
Snowflake
● Implement and manage passwords
and multi-factor authentication
(MFA)
○ Manage user types (PERSON,
NULL and SERVICE)
○ Manage passwords and
password policies
○ Manage user MFA
enrollment
○ Manage key-pair
authentication and rotation
○ Manage programmatic
authentication tokens and
rotation
○ Report on users who do not
have MFA enabled
○ Reset passwords and
temporarily disable MFA for
users
● Configure and use OAuth protocols
○ Use OAuth 2.0 in Snowflake
○ Compare Snowflake OAuth
to External OAuth
○ Configure Snowflake OAuth
for custom clients
○ Analyze how Snowflake
OAuth is impacted by
federated authentication,
network policies, and private
connectivity
1.6 Set up and manage network and
private connectivity.
● Establish network rules
○ Configure and manage
network rules
○ Analyze network policy
behavior when both
account-level and user-level
network rules exist
● Establish private connectivity to
Snowflake internal stages and the
Snowflake service
○ Implement and manage cloud
provider interfaces and private
endpoints for internal stages
○ Manage private connectivity
between cloud providers and
Snowflake
● Secure and Integrate the Snowflake
SQL API
1.7 Set up and manage security
administration and authorization.
● Use and monitor SCIM
○ Analyze SCIM and its use
cases as they relate to
Snowflake
○ Manage users and groups
with SCIM
○ Enable, configure, and
manage SCIM integration
● Prevent data exfiltration with
PREVENT_UNLOAD_TO_INLINE
_URL and
REQUIRE_STORAGE_INTEGRAT
ION _FOR_STAGE_CREATION
● Manage service accounts, API
integration, and automated
authentication (for example, key-pair
authentication)
● Manage access to AI features and
models
Page 6
Domain 1.0 Study Resources
Additional Assets
FAQ: Multi-Factored Authentication (MFA)
(community)
Using OAuth 20 with Snowflake
(community)
Snowflake Documentation Links
CREATE USER
Managing Accounts in Your Organization
Privileges for Listings
Configuring Access Control
Overview of Access Control
User Management
Organization Accounts
Granting Privileges on a Shared Database
Granting the IMPORTED PRIVILEGES
Privilege to Other Roles
System-Defined Roles
Comparing and Contrasting RBAC with UBAC
Enabling Secondary Roles for a Session
Custom Roles
Parameters
Virtual Warehouse Privileges
Accessing the Organization Usage Schema
Privileges Required to View Query History
GRANT <privileges> … TO ROLE
Centralizing Grant Management using Managed
Access Schemas
Access Control Privileges for Cloned Objects
Considerations When Using Future Grants
Using OAuth 2.0 with Snowflake
Multi-Factor Authentication (MFA)
About Authentication Policies
Inbound Private Connectivity
Outbound Private Connectivity
Strategies for Protecting Both Service and
Internal Stage
Disabling Public Access to the Snowflake
Service
Activating Network Policies for Users
SCIM Overview
CREATE ROLE
Configuring a Storage Integration to Access
Amazon S3
REST_EVENT_HISTORY Table Function
Opting Out of Snowflake AI Features
Programmatic Access Tokens
CREATE SECURITY INTEGRATION
Page 7
Domain 2.0: Account Management and Data Governance
2.1 Manage organizations and accounts.
● Evaluate the benefits and costs of
using a Snowflake Organization
● Perform organizational tasks
○ Create and name an
organization
○ Name various types of
organization accounts
○ Identify which regions are
available for a given
organization
● Perform account tasks
○ View, create, and list
accounts
○ Change account names
● Manage Tri-Secret Secure
● Manage encryption keys in
Snowflake
○ Describe how Snowflake
encrypts customer data
○ Describe encryption key
rotation and periodic
rekeying configuration
● Manage account-level parameters
and features
○ Enable Cortex AI features for
users
2.2 Implement and manage data
governance in Snowflake.
● Protect sensitive data with security
policies
○ Implement column-level
security using data masking
policies
○ Use external tokenization
○ Evaluate the use of data
masking versus external
tokenization based on
business requirements
○ Configure a row access
policy on an object
○ Compare row access policies
to secure views
○ Identify the impact of
attaching a row access policy
to an object
● Audit access history using the
ACCESS_HISTORY views
● Use tagging and classification in
Snowflake
○ Identify tagging use cases
○ Implement and manage
tagging
○ Implement tag-based
masking policies
○ Implement data classification
(EXTRACT_SEMANTIC_C
ATEGORIES,
ASSOCIATE_SEMANTIC_
CATEGORIES)
● Manage data governance through
Snowsight
○ Configuring and monitor tags
○ Implement and manage Trust
Center
● Manage Horizon Catalog, Universal
Search, and Data Lineage
2.3 Given a scenario, manage account
identifiers.
● Differentiate between account names
and account locators
● Identify when a given account
identifier needs to be used
● Use region IDs and region groups
Page 8
Domain 2.0 Study Resources
Additional Assets
5 Steps to Successful Data Governance
(e-book)
Design Patterns for Building Multi-Tenant
Applications on Snowflake (whitepaper
Snowflake Documentation Links
Managing Organizations
Organization Accounts: Premium Views
Hybrid Tables Dedicated Storage Mode for
TSS
Benefits of the Organization
Connect to Snowflake Intelligence
DROP ACCOUNT
Introduction to Row Access
PoliciesDynamic Data Masking (DDM)
Role Hierarchy and Privilege Inheritance
IS_ROLE_IN_SESSION
Visualizing Data Lineage
About Snowflake HorizonTag-Based
Masking Policies
Introduction to Data Quality
Use Cases for Dynamic Data Masking
Overview of Access Control
Access History
Limitations of Tag-Based Masking Policies
Common Use Cases for the Trust Center
What is Dynamic Data Masking?
IS_ROLE_IN_SESSION
Monitoring Cost in the Trust Center
Materialized Views and Column-Level
Security
Tag-Based Masking
Using Row Access Policies
Connecting to Snowflake
Introduction to Replication
Configuring Account Replication
General Connection Configuration
Specifying the Account Name when
Connecting to Snowflake
Region Support for Replication and Failover
CREATE CONNECTION
Page 9
Domain 3.0: Data and Object Management
3.1 Given business requirements, design,
manage, and maintain virtual
warehouses.
● Analyze the impact on data loading
and query processing based on
warehouse sizes and types
● Configure warehouse properties
(auto-suspend, auto-resume, max
clusters)
● Given a scenario, manage warehouse
usage in sessions, and size the
warehouse accordingly
● Given a scenario, manage a
multi-cluster warehouse
○ Determine use cases and benefits
○ Implement and maintain a
scaling policy
○ Monitor multi-cluster
warehouses
3.2 Given a scenario, manage databases,
tables, and views.
● Manage tables
○ Analyze table design
considerations
○ Implement Snowflake table
structures and types
○ Create and manage external
tables
○ Create and manage iceberg tables
● Implement and manage views,
secure views, and materialized views
● Identify use cases for cloning
databases and tables
3.3 Given a scenario, stage data in Snowflake.
● Create and manage Snowflake
storage integration
○ External stages
○ Data exfiltration
● Create and manage
EXTERNAL_VOLUME with
Iceberg tables
● Create and configure the Polaris Catalog
3.4 Given a scenario, manage tasks.
● Configure tasks
○ Manage and schedule tasks
○ Set permissions for creating
and executing tasks
○ Troubleshoot task historical runs
○ Identify use cases
● Differentiate between user-managed
and Snowflake-managed tasks and
identify use cases.
3.5 Perform queries in Snowflake.
● Use Snowflake sequences and
identify limitations
● Use persisted query results
● Cancel statements for single users or
multiple users
● Use query history filters including
client-generated queries and queries
executed by user tasks
● Visualize query results with
Snowsight
○ Use Snowsight dashboards to
monitor activity
○ Share worksheets and dashboards
○ Generate and share
Snowsight charts
○ Identify constraints with
sharing a Snowsight chart
○ Recover dropped dashboards
Page 10
Domain 3.0 Study Resources
Snowflake Documentation Links
Warehouse Cache
Warehouse Size
CREATE WAREHOUSE
Warehouse Considerations
Using the Query Acceleration Service
Multi-cluster Warehouses
SHOW DATABASES
CREATE SCHEMA
Secure Views
Snowflake Security Overview and Best
Practices
CREATE ICEBERG TABLE
Introduction to Iceberg Tables
Automatic Refresh for Iceberg Tables
How to Configure a Snowflake Account to
Prevent Data Exfiltration
Snowflake Open Catalog Integration
Configuring a Storage Integration to Access
Amazon S3
CREATE CATALOG INTEGRATION
External Volumes for Iceberg Tables
Data Loading Considerations
Task Ownership and Execution Privileges
Introduction to Tasks
Troubleshooting Task Timeouts
Querying Persisted Results
Sharing Dashboards
Page 11
Domain 4.0: Performance Monitoring and Tuning
4.1 Monitor and analyze Snowflake
performance.
● Evaluate and interpret Query Profiles
to improve performance
○ Analyze the components of
the Query Profile:
■ Steps
■ Operator tree
■ Operator nodes
■ Operator types
○ Compare compile versus
runtime optimizations
○ Identify and create efficient
queries
■ Articulate the
execution path
■ Use effective joining
conditions
■ Perform grouping,
sorting, and ordering
○ Troubleshoot common query
performance issues
○ Identify impact and solutions
for data spilling
○ Identify impact and solutions if
data pruning is not happening
○ Identify the various timeout
parameters
● Use an explain plan
● Compare and contrast different
caching techniques and the impact of
caching on performance
○ Result cache
○ Local disk (warehouse) cache
■ Explain the impact on
the local disc cache
when a warehouse is
suspended or resumed
○ Metadata cache
● Implement performance
improvements
○ Recommend the use of
materialized views
○ Use the search optimization service
○ Create external tables
○ Use data caching
○ Use the query acceleration service
4.2 Manage DML locking and concurrency in
Snowflake.
● Analyze DML concurrency
considerations
● Implement best practices for DML
locking and concurrency
● Monitor and manage transaction activity
4.3 Given a scenario, implement resource monitors.
● Create and manage resource monitors
based on use cases and business
requirements
● Set up a dashboard to monitor
Snowflake costs
4.4 Enable and manage logging and tracing.
● Manage event tables
○ Consider the use of default
system event tables compared
to custom tables
○ Configure event tables
○ Set levels for logs, metrics and
tracing
● Analyze event tables for system
health indicators
● Use log data to monitor user activity,
threat detection, and access control
○ Create alerts
● Use log trace data to perform root
cause analyses
● Use log trace data to optimize
performance
Page 12
4.5 Manage and optimize costs.
● Manage organization costs
○ Differentiate use cases for the
ACCOUNT_USAGE and
ORGANIZATION_USAGE views
○ Monitor accounts and usage
■ Use the
ORGANIZATION_US
AGE schema in the
SNOWFLAKE shared
database
○ Monitor and calculate data transfer
costs and replication costs
○ Calculate data storage usage
and credit consumption
○ Apply techniques for cost
optimization
● Evaluate use cases for the
ACCOUNT_USAGE and
INFORMATION_SCHEMA
○ Views available from the
INFORMATION_SCHEMA
○ Latency and data retention
considerations
○ Latency for historical views
● Manage costs for virtual warehouses
○ Determine when warehouses
should be suspended or resumed
based on cost and pricing
○ Calculate warehouse usage
and credit consumption
■ Demonstrate cost
saving strategies
■ Calculate and minimize
IDLE time cost
○ Use Budgets
○ Use WAREHOUSE_MONITORING to
optimize costs
○ Monitor and assess automatic
clustering usage
● Manage costs for serverless and AI
features
○ Analyze how Snowflake
credits are consumed by the
cloud services layer (such as
Snowpipe, materialized views,
and automatic clustering)
○ Monitor AI and ML function costs
○ Monitor Notebooks
consumption
○ Monitor AI usage and costs
Page 13
Domain 4.0 Study Resources
Additional Assets
10 Best Practices Every Snowflake Admin
Can Do to Optimize Resources (blog)
Best Practices for Optimizing Your dbt and
Snowflake Deployment (white paper)
Performance Impact from Local and Remote
Disk Spilling (community)
Your Statement was Aborted Because
Waiting for this Lock is Currently not
Allowed (community)
Definitive Guide to Managing Spend in
Snowflake (white paper)
Snowflake Documentation Links
Usage Notes for EXPLAIN
QUERY_HISTORY View (Account Usage)
WAREHOUSE_METERING_HISTORY
Clustering Keys for Tables
Using the Query Acceleration Service
JOIN
Using the Search Optimization
ServiceTransactions
Warehouse Max Concurrency
Understanding Lock Granularity in
Snowflake
LOCK_TIMEOUT Parameter
Transactions: Resource Locking
Warehouse Suspension and Resumption
CREATE RESOURCE MONITOR
Credit Quota for Resource Monitors
About Resource Monitors
CREATE VIEW
ALTER TABLE
ALTER VIEW
Monitoring and Logging for Event Tables
Telemetry Levels
About Object Tagging Propagation
ACCOUNT_USAGE Schema
Access History
Sessions View (Account Usage)
LOGIN_HISTORY View
Logging and Tracing Limitations
TABLE_STORAGE_METRICS View
ORGANIZATION_USAGE Schema
Cost Insights
Multi-cluster Warehouses
Understanding Data Storage Costs
Exploring Data Transfer Costs
Performance Query Options
Page 14
Domain 5.0: Data Sharing and Snowflake Marketplace
5.1 Implement and manage data sharing.
● Given a scenario, implement sharing
solutions
○ Evaluate different sharing
models (one to one, one to many,
private, public)
○ Share data among different
Snowflake editions
○ Configure cross-region and
cross-cloud data sharing
■ Explain the role of
replications
■ Use Cross-cloud auto
fulfillment for listings
■ Use Cross-cloud Data
Governance
○ Configure data sharing
programmatically
■ Share different types of
data objects including
secure functions
■ Determine the role of
context functions in data
sharing
● Manage data providers and consumers
○ Create and maintain outbound
data shares
○ Share objects securely in a data share
(for example, what type to use)
○ Identify use cases for views and
secure views
○ Share data with secure
User-defined Functions (UDFs)
○ Create and maintain reader
accounts
■ Create user and role for
access
■ Create resource monitors
■ Create objects
■ Determine if there is a
need to store data
(CREATE DATABASE)
○ Import and maintain inbound
data shares
● Configure and manage Snowflake Data
Clean Rooms
○ Install the clean room native app
○ Bring users into the clean room
○ Manage collaborators
5.2 Implement and manage the Snowflake
Marketplace
● Access the public and internal
Marketplace
● Determine use cases for internal versus
public data listings
● Manage the process of becoming a data
provider
○ Create, edit, or delete provider
profiles
● Create, submit, manage, and modify a
data listing
● Manage listings and listing requests
● Monitor data sharing usage
● Manage Native Apps
Page 15
Domain 5.0 Study Resources
Snowflake Documentation Links
CREATE SHARE
About Secure Data Sharing
Secure Data Sharing Across Regions and Platforms
Cross-Cloud Auto-Fulfillment
Installing and Managing Data Clean Rooms
Context Functions
Egress Cost Optimization
Privileges for Shared Data
LISTING_CONSUMPTION_DAILY View
Preparing Data for a Listing
Creating a Listing
Provider Pricing Models
Page 16
Domain 6.0: Disaster Recovery, Backup, and Data Replication
6.1 Manage data replication.
● Differentiate the use cases for
primary and secondary databases
● Replicate database objects
● Replicate account-level objects
● Analyze the impact of replication on
access controls
● Perform account replication
● Enable scheduled replication
● Differentiate between replication
Groups and failover groups
● Given a scenario, determine account
replication considerations with respect to
the different Snowflake editions
○ Replicate data to a lower
Snowflake edition
● Identify key-considerations for
account replications
● Analyze the impact of account
replication on:
○ Automatic clustering
○ Materialized views
○ External tables
○ Policies (masking and row
access) and tags
○ Streams and tasks
○ Stages, pipes, and clones objects
○ Historical usage data
○ Iceberg tables
● Analyze the impact of database
failover across multiple accounts
● Analyze the impact of database
failover and failback on schemas
● Redirect client connections in case of
a failover
● Design and implement disaster recovery
and business continuity plans
○ Identify the appropriate
failover or failback procedure
● Implement best practices for backups
in Snowflake
6.2 Given a scenario, manage Snowflake
Time Travel and Fail-safe.
● Establish data retention periods
● Query historical data
● Restore dropped objects
● Enable or disable Time Travel
○ Analyze Snowflake edition
implications for Time Travel
Domain 6.0 Study Resources
Additional Assets
Undrop Object Dropped or Replaced
Multiple Times (community)
Snowflake Documentation Links
Database Replication: Parameters
Introduction to Replication and Failover
Replication Group and Failover Group
Constraints
Replicating SAML2 Security Integrations
ALTER FAILOVER GROUP
Database Replication Considerations:
Automatic Clustering
Replication and Automatic Clustering
Replication: Skip event tables and hybrid
tables during refresh operation
MIN_DATA_RETENTION_TIME
_IN_DAYS Parameter
About Time Travel
Region Support for Replication and Failover
Page 17
SNOWPRO ADVANCED: ADMINISTRATOR SAMPLE QUESTIONS
1. An Administrator with the ACCOUNTADMIN role wants to modify a table in a database.
The table was created by another role, and the ACCOUNTADMIN does not own or have
privileges on the table.
Which should the Administrator keep in mind if they would like to modify this table?
A. The ACCOUNTADMIN can modify any object in the account without additional privileges.
B. The ACCOUNTADMIN can modify objects if a role in the hierarchy owns the object
or has been granted privileges.*
C. The ACCOUNTADMIN must grant itself privileges using the SECURITYADMIN role first.
D. The ACCOUNTADMIN can transfer ownership of all objects automatically without explicit
grants.
2. An administrator notices that ad-hoc reports has larger scans and are taking a long time to run.
 Which step should be taken to resolve this performance issue?
A. Enable the use of the result cache on the account.
B. Enable query acceleration service for the warehouse.*
C. Reduce the concurrency level in the warehouse.
D. Enable warehouse caching to keep data in the warehouse.
3. An Administrator notices that a task is repeatedly timing out after executing for one hour.
The query of the task takes a long time to run but runs fine in the same virtual warehouse
used by the task.
 How should this be resolved?
A. Change the USER_TASK_TIMEOUT_MS parameter in the task.*
B. Change the TASK_AUTO_RETRY_ATTEMPTS parameter in the task.
C. Change the MAX_CLUSTER_COUNT parameter in the warehouse.
D. Change the STATEMENT_TIMEOUT_IN_SECONDS parameter in the warehouse.
Page 18
4. These commands are run:
GRANT SELECT ON FUTURE TABLES IN DATABASE d1 TO ROLE r1;
GRANT INSERT, DELETE ON FUTURE TABLES IN SCHEMA d1.s1 TO ROLE r2;
A new table is created in schema d1.s1.
Which are the privileges granted on this new table?
A. Role r1 gets SELECT.
B. Role r2 gets INSERT and DELETE.*
C. Role r1 gets SELECT and role r2 gets INSERT and DELETE.
D. Roles r1 and r2 both get SELECT, INSERT and DELETE.
Page 19
5. An Administrator has set up Trust Center to monitor their account and report the costs
associated with their account for the year.
Which statements will help the Administrator monitor these costs? (Select TWO).
 *A. USE ROLE ACCOUNTADMIN;
SELECT * FROM
SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY WHERE
SERVICE_TYPE = 'TRUST_CENTER';
 B. USE ROLE ACCOUNTADMIN;
SELECT * FROM
SNOWFLAKE.ACCOUNT_USAGE.SERVERLESS_TASK_HISTORY WHERE
DATABASE_NAME = 'SNOWFLAKE' AND SCHEMA_NAME =
'TRUST_CENTER_STATE';
 C. USE ROLE ACCOUNTADMIN;
SELECT * FROM
SNOWFLAKE.ACCOUNT_USAGE.SERVERLESS_TASK_HISTORY WHERE
DATABASE_NAME = 'SNOWFLAKE' AND SCHEMA_NAME =
'TRUST_CENTER';
 D. USE ROLE ACCOUNTADMIN;
SELECT * FROM
SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY WHERE
SERVICE_TYPE = 'TRUST_CENTER_STATE';
 *E. USE ROLE ACCOUNTADMIN;
SELECT * FROM
SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY WHERE
SERVICE_TYPE = 'TRUST_CENTER_STATE';
Page 20
NEXT STEPS
REGISTERING FOR YOUR EXAM
When you are ready to register for the exam navigate here to get started. Select the exam you
want to take and click “Register Now”. This will take you to our Certification Management
system where you will register to take the exam.
MAINTAINING YOUR CERTIFICATION
All Snowflake Certifications expire two (2) years after your certification issue date.
SnowPro Certifications can now be recertified through the Snowflake Continuing Education
(CE) program which includes these options -
● Completion of eligible Snowflake Instructor Led (ILT) Training Courses
● Earning of an equivalent or higher-level SnowPro Certification
Note: You must have a valid Certification to participate in the Continuing Education (CE)
program.
The information provided in this study guide is provided for your purposes only and may not be
provided to third parties.
IN ADDITION, THIS STUDY GUIDE IS PROVIDED “AS IS”. NEITHER SNOWFLAKE
NOR ITS SUPPLIERS MAKES ANY OTHER WARRANTIES, EXPRESS OR IMPLIED,
STATUTORY OR OTHERWISE, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
MERCHANTABILITY, TITLE, FITNESS FOR A PARTICULAR PURPOSE OR
NONINFRINGEMENT.