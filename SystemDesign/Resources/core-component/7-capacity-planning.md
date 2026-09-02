> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: System Design Notes
> Docs Index: [README.md](README.md)
3. Capacity Planning

What is Capacity Planning?

Capacity planning is the process of estimating how much infrastructure a system will need to handle its expected workload.

It helps answer:

How much CPU, memory, database capacity, storage, network bandwidth, and infrastructure do we need today and in the future?

Typical capacity-planning questions:

How many requests will we receive?
How many reads vs writes?
How much data will we store?
How much network bandwidth do we need?
What is our peak traffic?
How fast will the system grow?
How many servers do we need?

â¸»

3.1 Capacity Planning Process

A common approach is:

              Requirements
                   |
                   v
            Traffic Estimation
                   |
                   v
            Read/Write Ratio
                   |
                   v
           Storage Estimation
                   |
                   v
          Bandwidth Estimation
                   |
                   v
           Peak Traffic
                   |
                   v
           Growth Estimation
                   |
                   v
          Infrastructure Size

The important point is:

Donâ€™t start by choosing servers. First estimate the workload.

â¸»

3.2 Traffic Estimation

Traffic estimation determines how many requests the system needs to handle.

Usually we calculate:

Average RPS
Peak RPS
Read RPS
Write RPS

â¸»

Daily Active Users

Suppose an application has:

Total Users = 10 million
Daily Active Users = 2 million

This means approximately:

DAU = 2 million

If each active user performs:

20 requests/day

then:

Daily Requests
= 2,000,000 Ã— 20
= 40,000,000 requests/day

â¸»

Average RPS

There are:

24 Ã— 60 Ã— 60
= 86,400 seconds/day

Therefore:

Average RPS
= Daily Requests / 86,400

For 40 million requests:

Average RPS
= 40,000,000 / 86,400
â‰ˆ 463 RPS

So the system needs to handle approximately:

463 requests/sec

on average.

â¸»

Why Average RPS Is Not Enough

Traffic is not uniformly distributed throughout the day.

For example:

00:00 â”€â”€â”€â”€â”€ Low Traffic
08:00 â”€â”€â”€â”€â”€ Increasing
12:00 â”€â”€â”€â”€â”€ High
18:00 â”€â”€â”€â”€â”€ Very High
21:00 â”€â”€â”€â”€â”€ Peak
23:59 â”€â”€â”€â”€â”€ Low

Therefore we need to estimate:

Average RPS
Peak RPS

â¸»

3.3 Read/Write Ratio

Many systems perform significantly more reads than writes.

For example:

Read : Write = 10 : 1

This means:

10 reads
for every
1 write

Suppose total traffic is:

11,000 RPS

With a:

10 : 1

ratio:

Read RPS
= 10,000
Write RPS
= 1,000

Because:

10,000 + 1,000
= 11,000 RPS

â¸»

Read/Write Calculation

If:

Total RPS = 10,000
Read : Write = 8 : 2

Total ratio parts:

8 + 2 = 10

Read percentage:

8 / 10 = 80%

Write percentage:

2 / 10 = 20%

Therefore:

Read RPS
= 10,000 Ã— 80%
= 8,000 RPS
Write RPS
= 10,000 Ã— 20%
= 2,000 RPS

â¸»

Why Read/Write Ratio Matters

Read-heavy and write-heavy systems require different architectures.

Read-heavy system

Example:

100,000 Read RPS
10,000 Write RPS

Possible optimizations:

Cache
CDN
Read Replicas
Database Indexes
Denormalization

Architecture:

                 Load Balancer
                      |
          +-----------+-----------+
          |                       |
       API Server              API Server
          |                       |
          +-----------+-----------+
                      |
                    Redis
                      |
              +-------+-------+
              |               |
          Read Replica    Primary DB

â¸»

Write-heavy system

Example:

10,000 Read RPS
100,000 Write RPS

Possible techniques:

Message Queue
Batch Processing
Partitioning
Sharding
Write Optimization
Async Processing

Example:

Client
  |
  v
API
  |
  v
Message Queue
  |
  +---- Consumer 1
  +---- Consumer 2
  +---- Consumer 3
  |
  v
Database

â¸»

3.4 Storage Estimation

Storage estimation determines how much data the system will store.

We need to estimate:

Records created
Ã—
Average record size
Ã—
Retention period

Also consider:

Indexes
Replication
Backups
Metadata
Logs
Temporary data

â¸»

Basic Storage Formula

Daily Storage
=
Daily New Records
Ã—
Average Record Size

Example:

New records/day = 1 million
Average record size = 1 KB

Then:

Daily Storage
= 1,000,000 Ã— 1 KB
= 1 GB/day

Monthly:

1 GB Ã— 30
= 30 GB/month

Yearly:

1 GB Ã— 365
= 365 GB/year

â¸»

3.5 Storage With Metadata

Real database records usually have more than just the main payload.

Suppose:

Application data = 1 KB
Metadata          = 0.2 KB
Indexes            = 0.3 KB

Approximate storage per record:

1 + 0.2 + 0.3
= 1.5 KB

For 1 million records:

1,000,000 Ã— 1.5 KB
â‰ˆ 1.5 GB

This is more realistic than calculating only the raw payload.

â¸»

3.6 Storage With Replication

Suppose:

Primary storage = 10 TB
Replication factor = 3

Then physical storage requirement is approximately:

10 TB Ã— 3
= 30 TB

For example:

               Primary
              10 TB
                |
       +--------+--------+
       |                 |
   Replica 1          Replica 2
     10 TB               10 TB

Total:

30 TB

â¸»

3.7 Storage Growth

Suppose:

Daily data = 5 GB

Then:

Monthly â‰ˆ 5 Ã— 30
        = 150 GB
Yearly â‰ˆ 5 Ã— 365
       = 1.825 TB

If replication factor is 3:

Physical storage
â‰ˆ 1.825 Ã— 3
â‰ˆ 5.475 TB/year

Before accounting for additional overhead such as indexes and backups.

â¸»

3.8 Bandwidth Estimation

Bandwidth estimation determines how much network capacity is required.

We need to know:

Requests/sec
Average request size
Average response size

â¸»

Incoming Bandwidth

Suppose:

RPS = 1,000
Average request size = 10 KB

Then:

Incoming bandwidth
= 1,000 Ã— 10 KB
= 10,000 KB/sec
â‰ˆ 10 MB/sec

Convert to bits:

10 MB/sec Ã— 8
â‰ˆ 80 Mbps

Therefore incoming bandwidth is approximately:

80 Mbps

â¸»

Outgoing Bandwidth

Suppose:

RPS = 1,000
Average response = 100 KB

Then:

Outgoing bandwidth
= 1,000 Ã— 100 KB
= 100 MB/sec

In bits:

100 Ã— 8
= 800 Mbps

Therefore:

Outgoing bandwidth â‰ˆ 800 Mbps

â¸»

3.9 Total Bandwidth

If:

Incoming = 80 Mbps
Outgoing = 800 Mbps

then approximately:

Total
= 80 + 800
= 880 Mbps

In real systems, provision additional capacity for:

Protocol overhead
Traffic bursts
Retries
Replication
Monitoring
Service-to-service communication

â¸»

3.10 Peak Traffic Estimation

Peak traffic is one of the most important parts of capacity planning.

Suppose:

Average RPS = 5,000

and historical data shows:

Peak / Average = 4x

Then:

Peak RPS
= 5,000 Ã— 4
= 20,000 RPS

Infrastructure should be designed around the expected peak or an appropriate capacity target, rather than simply the average.

â¸»

Peak Traffic Factor

A common simplified model:

Peak RPS
=
Average RPS Ã— Peak Factor

Example:

Average RPS = 2,000
Peak Factor = 5
Peak RPS = 2,000 Ã— 5
         = 10,000 RPS

â¸»

3.11 Peak Traffic Is Not Always a Fixed Multiplier

In real system design, a better approach is to use historical traffic data.

Example:

Normal day
Peak = 3x average
Black Friday
Peak = 8x average
Festival sale
Peak = 12x average

Therefore:

Normal Capacity
â‰ 
Event Capacity

You may need:

Auto Scaling
Pre-scaling
Queueing
Rate Limiting
Load Shedding
Caching

for predictable traffic spikes.

â¸»

3.12 Growth Estimation

Capacity planning must consider future growth.

Suppose:

Current users = 10 million
Annual growth = 20%

After one year:

10M Ã— 1.20
= 12M

After two years:

12M Ã— 1.20
= 14.4M

After three years:

14.4M Ã— 1.20
= 17.28M

This is compound growth.

â¸»

Growth Formula

Future Value
=
Current Value Ã— (1 + Growth Rate)^Years

For example:

Current traffic = 10,000 RPS
Growth = 30%
Years = 3

Then:

Future RPS
= 10,000 Ã— (1.30)^3
â‰ˆ 21,970 RPS

So after three years:

â‰ˆ 22K RPS

â¸»

3.13 CAGR-Style Growth Estimation

Sometimes you know the current and future values and want to calculate the required annual growth rate.

Formula:

Growth Rate
=
(Future / Current)^(1 / Years) - 1

Example:

Current users = 10M
Future users = 30M
Years = 5

Approximate annual growth:

(30 / 10)^(1/5) - 1
â‰ˆ 24.6%

So the system needs to accommodate approximately:

25% annual growth

â¸»

3.14 Complete Capacity Planning Example

Letâ€™s design capacity for a social-media application.

Assumptions:

Daily Active Users = 10 million
Requests per user per day = 20
Read : Write = 10 : 1
Average request size = 5 KB
Average response size = 50 KB
New records/day = 2 million
Average record size = 1 KB
Replication factor = 3
Peak factor = 5x
Expected annual growth = 25%

â¸»

Step 1 â€” Daily Requests

Daily Requests
=
10M Ã— 20
= 200M requests/day

â¸»

Step 2 â€” Average RPS

Average RPS
=
200M / 86,400
â‰ˆ 2,315 RPS

â¸»

Step 3 â€” Peak RPS

Peak factor:

5x

Therefore:

Peak RPS
=
2,315 Ã— 5
â‰ˆ 11,575 RPS

Round this for planning:

â‰ˆ 12K RPS

â¸»

Step 4 â€” Read/Write Traffic

Read/write:

10 : 1

Total parts:

10 + 1 = 11

Read traffic:

12,000 Ã— 10/11
â‰ˆ 10,909 RPS

Write traffic:

12,000 Ã— 1/11
â‰ˆ 1,091 RPS

Therefore:

Peak Read RPS  â‰ˆ 10.9K
Peak Write RPS â‰ˆ 1.1K

â¸»

Step 5 â€” Storage

New records:

2M records/day

Record size:

1 KB

Daily storage:

2M Ã— 1 KB
= 2 GB/day

Yearly:

2 Ã— 365
= 730 GB/year

With replication factor 3:

730 Ã— 3
= 2.19 TB/year

This still excludes additional storage overhead such as indexes and backups.

â¸»

Step 6 â€” Incoming Bandwidth

Peak RPS:

12,000

Request size:

5 KB

Therefore:

Incoming
=
12,000 Ã— 5 KB
= 60,000 KB/sec
â‰ˆ 60 MB/sec

Convert to bits:

60 Ã— 8
â‰ˆ 480 Mbps

â¸»

Step 7 â€” Outgoing Bandwidth

Response size:

50 KB

Therefore:

Outgoing
=
12,000 Ã— 50 KB
= 600,000 KB/sec
â‰ˆ 600 MB/sec

Convert to bits:

600 Ã— 8
â‰ˆ 4.8 Gbps

So approximately:

Incoming = 480 Mbps
Outgoing = 4.8 Gbps

â¸»

3.15 Growth Projection

Current peak traffic:

12,000 RPS

Annual growth:

25%

Year 1

12,000 Ã— 1.25
= 15,000 RPS

Year 2

15,000 Ã— 1.25
= 18,750 RPS

Year 3

18,750 Ã— 1.25
= 23,438 RPS

Capacity target after 3 years:

â‰ˆ 23.5K peak RPS

â¸»

3.16 Capacity Planning Cheat Sheet

Requirement	Formula
Daily Requests	DAU Ã— Requests/User/Day
Average RPS	Daily Requests / 86,400
Peak RPS	Average RPS Ã— Peak Factor
Read RPS	Total RPS Ã— Read %
Write RPS	Total RPS Ã— Write %
Daily Storage	Records/Day Ã— Record Size
Yearly Storage	Daily Storage Ã— 365
Replicated Storage	Raw Storage Ã— Replication Factor
Incoming Bandwidth	RPS Ã— Request Size
Outgoing Bandwidth	RPS Ã— Response Size
Future Traffic	Current Ã— (1 + Growth)^Years

â¸»

3.17 Important Assumptions

In an interview, state your assumptions before calculating.

For example:

Let's assume:
DAU = 10M
20 requests/user/day
Read/Write = 10:1
Peak factor = 5x
Average request = 5 KB
Average response = 50 KB
Annual growth = 25%

Then calculate step by step.

This is much better than immediately saying:

We need 20 servers.

The interviewer wants to see how you arrived at the number.

â¸»

3.18 Capacity Planning Mental Model

Remember:

                 CAPACITY PLANNING
                        |
          +-------------+-------------+
          |             |             |
       TRAFFIC       STORAGE       NETWORK
          |             |             |
       Avg RPS       Records       Request Size
       Peak RPS      Record Size   Response Size
          |             |             |
          v             v             v
       RPS/QPS       GB/TB          Mbps/Gbps
          |
          v
    READ / WRITE
       RATIO
          |
          v
    INFRASTRUCTURE
          |
    +-----+-----+
    |     |     |
   CPU  Memory  DB
          |
          v
       GROWTH
          |
          v
    FUTURE CAPACITY

â¸»

3.19 Interview Mental Model

When an interviewer gives you a system-design problem, think in this order:

1. How many users?
        â†“
2. How many are active?
        â†“
3. How many requests per user?
        â†“
4. What is average RPS?
        â†“
5. What is peak RPS?
        â†“
6. What is read/write ratio?
        â†“
7. How much data is created?
        â†“
8. How much storage is required?
        â†“
9. How much bandwidth is required?
        â†“
10. How fast will it grow?
        â†“
11. What infrastructure can handle it?

The Golden Rule

Capacity planning converts business requirements into infrastructure requirements.

For example:

10M DAU
   â†“
200M requests/day
   â†“
2.3K average RPS
   â†“
12K peak RPS
   â†“
11K read + 1K write RPS
   â†“
Storage + Bandwidth calculation
   â†“
Database + Cache + API capacity
   â†“
Future growth capacity

This is the core mental model you should use in system-design interviews.
