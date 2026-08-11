> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: System Design Notes
> Docs Index: [README.md](README.md)
4. Availability

What is Availability?

Availability is the percentage of time a system is operational and accessible when users need it.

In simple terms:

Availability = How often is the system up and usable?

For example:

System is available for 99.9% of the time

This means the system can be unavailable for approximately 0.1% of the measurement period.

â¸»

4.1 Availability Percentage

Availability is commonly expressed as a percentage.

The basic formula is:

Availability
=
(Uptime / Total Time) Ã— 100

Another equivalent form:

Availability
=
((Total Time - Downtime) / Total Time) Ã— 100

Example:

Total time = 30 days
Downtime   = 43.2 minutes

Then:

Availability
â‰ˆ 99.9%

â¸»

Availability Table

Common availability targets:

Availability	Approx. Downtime / Year
99%	3.65 days
99.9%	8.76 hours
99.95%	4.38 hours
99.99%	52.56 minutes
99.999%	5.26 minutes
99.9999%	31.5 seconds

These values assume a 365-day year.

Important Interview Point

Moving from:

99.9%

to:

99.99%

looks like a small percentage improvement.

But downtime changes from approximately:

8.76 hours

to:

52.56 minutes

Thatâ€™s a significant engineering difference.

â¸»

4.2 Availability Example

Suppose an API runs for:

Total Time = 720 hours

and experiences:

Downtime = 30 minutes

Convert downtime:

30 minutes = 0.5 hours

Uptime:

720 - 0.5
= 719.5 hours

Availability:

719.5 / 720 Ã— 100
â‰ˆ 99.93%

Therefore:

Availability â‰ˆ 99.93%

â¸»

4.3 High Availability (HA)

What is High Availability?

High Availability means designing a system so that it remains operational even when individual components fail.

The key idea is:

Avoid a single component becoming a single point of failure.

Instead of:

              Client
                |
                v
           API Server
                |
                v
             Database

we can introduce redundancy:

                  Client
                    |
                    v
               Load Balancer
                 /       \
                /         \
               v           v
          API Server 1  API Server 2
                \         /
                 \       /
                  v     v
                 Database

If API Server 1 fails:

API Server 1 âŒ
API Server 2 âœ…

The load balancer sends traffic to Server 2.

The system continues operating.

â¸»

4.4 High Availability Techniques

Common HA techniques include:

1. Redundancy

Run multiple instances:

Server 1
Server 2
Server 3

Instead of:

Single Server

â¸»

2. Load Balancing

Distribute requests across multiple servers.

                 Load Balancer
                /      |      \
               v       v       v
              API1    API2    API3

If one server fails:

API1 âŒ
API2 âœ…
API3 âœ…

Traffic continues through the healthy instances.

â¸»

3. Database Replication

Maintain multiple copies of database data.

              Primary DB
              /        \
             v          v
        Replica 1    Replica 2

If the primary fails, another database can potentially take over depending on the database architecture.

â¸»

4. Multi-AZ Deployment

Deploy components across multiple availability zones.

Region
 |
 +-- AZ1
 |    |
 |   API
 |
 +-- AZ2
 |    |
 |   API
 |
 +-- AZ3
      |
     API

If one availability zone fails:

AZ1 âŒ
AZ2 âœ…
AZ3 âœ…

the application can continue serving traffic.

â¸»

5. Multi-Region Deployment

For stronger resilience:

              Global DNS / Load Balancer
                    /          \
                   v            v
               Region A      Region B
                  |              |
                APIs           APIs
                  |              |
                 DB             DB

If an entire region becomes unavailable, traffic can potentially be redirected to another region.

â¸»

4.5 Availability vs Scalability

These are different concepts.

Scalability

Can the system handle increasing load?

Example:

10K RPS
   â†“
20K RPS
   â†“
50K RPS

Availability

Does the system remain operational when components fail?

Example:

Server 1 âŒ
Server 2 âœ…
Server 3 âœ…
System remains available.

A system can be:

Highly scalable but not highly available

or:

Highly available but not highly scalable

â¸»

4.6 SLA

What is SLA?

SLA = Service Level Agreement

An SLA is a formal agreement between a service provider and customer that defines expected service levels.

It may specify:

Availability
Response time
Support response
Recovery time
Service credits

Example:

SLA = 99.9% monthly availability

The provider commits to meeting that availability target under the agreement.

â¸»

SLA Example

Suppose a cloud provider offers:

99.99% availability SLA

This means the contractual service target allows approximately:

52.56 minutes

of downtime per year, assuming a 365-day year.

If the provider violates the SLA, the contract may define:

Service credits
Refunds
Compensation

depending on the agreement.

â¸»

4.7 SLO

What is SLO?

SLO = Service Level Objective

An SLO is an internal or operational target for a service.

Example:

SLO:
99.95% availability

or:

SLO:
99% of API requests complete within 300 ms

SLOs are measurable objectives used to guide engineering decisions.

â¸»

4.8 SLI

What is SLI?

SLI = Service Level Indicator

An SLI is the actual metric used to measure service performance.

Examples:

Availability %
Latency
Error Rate
Throughput
Successful Requests

Example:

SLI:
99.97% successful requests

The SLI tells us what actually happened.

â¸»

4.9 SLA vs SLO vs SLI

This is an important interview topic.

Think:

SLI = Measurement
SLO = Target
SLA = Contract

Example:

SLI:
Actual availability = 99.96%
SLO:
Target availability = 99.95%
SLA:
Contractual availability = 99.9%

Therefore:

              SLA
           Contract
              |
              v
             SLO
           Target
              |
              v
             SLI
          Measurement

Easy Memory Trick

SLI tells you what happened.
SLO tells you what you want.
SLA tells you what you promised.

â¸»

4.10 Error Budget

Error budget is closely related to SLO.

Suppose:

SLO = 99.9%

Then allowed failure/downtime:

100% - 99.9%
= 0.1%

That 0.1% is the approximate error budget.

If your SLO is:

99.9%

you have some tolerance for:

Failures
Downtime
Errors

This doesnâ€™t mean you should intentionally use the entire budget. It provides a practical reliability target and helps balance reliability work against feature development.

â¸»

4.11 Availability Mental Model

                    AVAILABILITY
                         |
          +--------------+--------------+
          |              |              |
       Uptime          HA             SLA
          |              |              |
       Percentage    Redundancy       Contract
                         |
              +----------+----------+
              |          |          |
           Failover   Replication  Multi-AZ

â¸»

5. Reliability

What is Reliability?

Reliability is the ability of a system to perform its intended function correctly and consistently over a period of time.

In simple terms:

Reliability = Does the system continue to work correctly without failing?

Availability asks:

Is the system available?

Reliability asks:

Does the system work correctly and consistently?

â¸»

5.1 Availability vs Reliability

These concepts are related but different.

Imagine a system that crashes frequently but restarts in one second.

System fails
     â†“
Restarts quickly
     â†“
Available again

It may have high availability because downtime is very short.

But it has poor reliability because it fails frequently.

Example:

System A
Failures = 100
Each failure = 1 second

versus:

System B
Failures = 1
Downtime = 10 minutes

System A may have better availability while being less reliable.

â¸»

Simple Comparison

Concept	Question
Availability	Is the system available?
Reliability	Does it work correctly and consistently?
Durability	Will stored data survive?
Data Integrity	Is the data correct and uncorrupted?

â¸»

5.2 Reliability Example

Consider a payment system.

A reliable payment system should:

Accept valid payments
Reject invalid payments
Avoid duplicate charges
Persist transactions correctly
Recover from failures
Maintain correct balances

Simply being reachable isnâ€™t enough.

An API that returns:

HTTP 200 OK

but charges a customer twice is not reliable.

â¸»

5.3 MTBF

What is MTBF?

MTBF = Mean Time Between Failures

It measures the average operating time between failures.

Formula:

MTBF
=
Total Operating Time / Number of Failures

Example:

Total operating time = 1,000 hours
Failures = 10

Then:

MTBF
= 1,000 / 10
= 100 hours

Meaning:

Average time between failures = 100 hours

â¸»

5.4 MTBF Interpretation

Higher MTBF generally means:

Fewer failures

Example:

System A â†’ MTBF = 100 hours
System B â†’ MTBF = 1,000 hours

System B fails less frequently.

Therefore:

Higher MTBF
      â†“
Less frequent failures
      â†“
Better reliability

â¸»

5.5 MTTR

What is MTTR?

MTTR = Mean Time To Repair/Recover

It represents the average time required to restore a system after a failure.

Example:

Failure 1 â†’ Recovery = 10 min
Failure 2 â†’ Recovery = 20 min
Failure 3 â†’ Recovery = 15 min

Then:

MTTR
= (10 + 20 + 15) / 3
= 15 minutes

â¸»

5.6 MTBF vs MTTR

Remember:

MTBF â†’ How frequently do we fail?
MTTR â†’ How quickly do we recover?

Therefore:

             Reliability
                  |
         +--------+--------+
         |                 |
       MTBF              MTTR
         |                 |
    Failure Frequency   Recovery Speed

Ideal system:

High MTBF
+
Low MTTR

â¸»

5.7 Availability and MTBF/MTTR

A commonly used simplified relationship is:

Availability
â‰ˆ
MTBF / (MTBF + MTTR)

Example:

MTBF = 1,000 hours
MTTR = 1 hour

Then:

Availability
= 1000 / (1000 + 1)
â‰ˆ 99.90%

This shows an important relationship:

Increase MTBF
        â†“
Availability â†‘
Decrease MTTR
        â†“
Availability â†‘

â¸»

5.8 How to Improve MTBF

To increase MTBF, reduce the frequency of failures.

Techniques include:

Better testing
Fault isolation
Redundancy
Health checks
Monitoring
Capacity planning
Preventive maintenance
Better software design
Dependency management

Example:

Instead of:

Single Database

use:

Primary DB
    |
    +-- Replica
    |
    +-- Backup

This can reduce the impact of certain failures.

â¸»

5.9 How to Improve MTTR

To reduce recovery time:

Automated deployments
Automated rollback
Monitoring
Alerting
Health checks
Runbooks
Failover
Auto scaling
Infrastructure as Code
Disaster recovery procedures

Example:

Without automation:

Failure
  â†“
Engineer notices
  â†“
Investigates
  â†“
Manually starts server
  â†“
Configures server
  â†“
Deploys application

With automation:

Failure
  â†“
Health check detects failure
  â†“
Orchestrator replaces instance
  â†“
Traffic redirected
  â†“
Service restored

This reduces MTTR.

â¸»

5.10 Durability

What is Durability?

Durability means that once data has been successfully stored, it remains available and is not lost even after failures.

Durability is one of the ACID properties of database transactions.

For example:

User makes payment
       â†“
Transaction committed
       â†“
Database crashes
       â†“
Database restarts
       â†“
Payment still exists

That demonstrates durability.

â¸»

5.11 Availability vs Durability

These are different.

Availability

Can I access the data right now?

Durability

Will my data still exist after a failure?

Example:

Database temporarily unavailable
       â†“
Data is still safely stored

Availability is temporarily bad.

Durability can still be excellent.

â¸»

5.12 How to Improve Durability

Common techniques:

Replication

Primary
  |
  +-- Replica 1
  |
  +-- Replica 2

Backups

Database
   |
   v
Backup Storage

Multi-Region Replication

Region A
   |
   v
Region B
   |
   v
Region C

Write-Ahead Logging

Database changes can be recorded in a log before the final data pages are persisted.

Object Storage Replication

Important files can be replicated across multiple failure domains.

â¸»

5.13 Data Integrity

What is Data Integrity?

Data integrity means that data remains:

Correct
Accurate
Consistent
Complete
Uncorrupted

throughout its lifecycle.

Example:

A banking system has:

Account A = â‚¹10,000
Account B = â‚¹5,000

A transfer of:

â‚¹2,000

should result in:

Account A = â‚¹8,000
Account B = â‚¹7,000

If the system deducts â‚¹2,000 from A but fails to credit B, data integrity has been violated.

â¸»

5.14 Types of Data Integrity

1. Entity Integrity

Every record should have a valid identity.

Example:

UserId = Primary Key

A user shouldnâ€™t have two records with the same primary key.

â¸»

2. Referential Integrity

Relationships between records should remain valid.

Example:

Orders.CustomerId
        |
        v
Customers.Id

An order shouldnâ€™t reference a customer that doesnâ€™t exist.

â¸»

3. Domain Integrity

Values should follow defined rules.

Example:

Age >= 0
Quantity > 0
Email must have valid format

â¸»

4. Transaction Integrity

A transaction should preserve correctness.

Example:

Transfer â‚¹100
Account A: -â‚¹100
Account B: +â‚¹100

Both operations should succeed together or fail together.

This is where ACID transactions are important.

â¸»

5.15 Reliability Techniques

To build reliable systems:

                 RELIABILITY
                      |
       +--------------+--------------+
       |              |              |
     Prevent        Detect         Recover
     Failures       Failures       Quickly
       |              |              |
    Testing        Monitoring     Failover
    Redundancy     Health Check   Retry
    Validation     Alerting       Rollback
       |              |              |
       +--------------+--------------+
                      |
                 Correct Data
                      |
             +--------+--------+
             |                 |
          Durability       Integrity

â¸»

5.16 Reliability vs Availability vs Durability

Property	Main Question
Availability	Is the system accessible?
Reliability	Does it work correctly and consistently?
Durability	Will stored data survive failures?
Data Integrity	Is the data correct and uncorrupted?

Example:

Database server crashes

Availability

Can users access the database?

Reliability

Does the database recover and behave correctly?

Durability

Was committed data preserved?

Data Integrity

Is the recovered data correct?

â¸»

5.17 Complete Example: Payment System

Consider:

Client
  |
  v
Payment API
  |
  v
Payment Service
  |
  +--------+
  |        |
  v        v
Database  Payment Gateway

A reliable payment system needs:

Availability

Multiple API instances:

API 1
API 2
API 3

Reliability

Prevent duplicate payments:

Idempotency Key

Durability

Persist successful transactions safely:

Database
+
Replication
+
Backups

Data Integrity

Maintain correct account/payment state:

Atomic Transactions
Constraints
Validation
Consistency Checks

Low MTTR

Automatically recover failed instances:

Health Check
     â†“
Failure Detected
     â†“
Instance Replaced
     â†“
Traffic Redirected

â¸»

5.18 Interview Cheat Sheet

What is Availability?

Availability is the percentage of time a system is operational and accessible.

What is High Availability?

High availability is the ability of a system to remain operational despite failures through redundancy, failover, and fault-tolerant architecture.

What is SLA?

SLA is a contractual agreement defining the service level a provider promises to its customers.

What is SLO?

SLO is the target reliability or performance level that a service aims to achieve.

What is SLI?

SLI is the actual metric used to measure service performance or reliability.

SLA vs SLO vs SLI?

SLI = What happened?
SLO = What do we target?
SLA = What do we promise?

What is Reliability?

Reliability is the ability of a system to perform its intended function correctly and consistently over time.

What is MTBF?

Mean Time Between Failures â€” average operating time between failures.

What is MTTR?

Mean Time To Repair/Recover â€” average time required to restore a service after failure.

What is Durability?

Durability means successfully committed data survives failures.

What is Data Integrity?

Data integrity means data remains accurate, consistent, complete, and uncorrupted.

â¸»

5.19 Final Mental Model

                    SYSTEM QUALITY
                         |
       +-----------------+------------------+
       |                 |                  |
  AVAILABILITY       RELIABILITY        DURABILITY
       |                 |                  |
   "Is it up?"      "Does it work?"    "Is data safe?"
       |                 |                  |
       v                 v                  v
   Uptime %            MTBF              Replication
   HA                   MTTR              Backups
   Failover             Recovery           WAL
       |                 |                  |
       +-----------------+------------------+
                         |
                         v
                    DATA INTEGRITY
                         |
              "Is the data correct?"
                         |
              +----------+----------+
              |          |          |
           Atomicity  Constraints Validation
              |
              v
             ACID

One-Line Memory Trick

Availability â†’ Is it available?
Reliability  â†’ Does it work correctly?
Durability   â†’ Will the data survive?
Integrity    â†’ Is the data correct?
MTBF         â†’ How often does it fail?
MTTR         â†’ How fast can we recover?
SLI          â†’ What do we measure?
SLO          â†’ What do we target?
SLA          â†’ What do we promise?

A highly available system is not automatically reliable, and a reliable system is not automatically durable. Good system design addresses all of them.
