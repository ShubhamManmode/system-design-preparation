> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: System Design Notes
> Docs Index: [README.md](README.md)
Scalability

Goal: Understand how systems handle increasing traffic, users, and data while maintaining performance and availability.

â¸»

Table of Contents

1. What is Scalability?
2. Why Scalability is Important
3. Vertical Scaling (Scale Up)
4. Horizontal Scaling (Scale Out)
5. Stateless vs Stateful Applications
6. Elasticity
7. Auto Scaling
8. Scaling Strategies
    * Compute Scaling
    * Storage Scaling
    * Read Scaling
    * Write Scaling
9. Real-World Architecture
10. Interview Questions
11. Cheat Sheet

â¸»

What is Scalability?

Definition

Scalability is the ability of a system to handle increasing workload without significantly affecting performance.

The workload may increase because of:

* More users
* More requests
* More data
* More transactions
* More services

A scalable system should continue to provide acceptable response times even as demand grows.

â¸»

Example

Suppose an e-commerce website receives:

* Day 1 â†’ 1,000 users/day
* Festival Sale â†’ 2 million users/day

If the application continues serving users without crashing or slowing down dramatically, it is considered scalable.

â¸»

Why Scalability Matters

Without scalability:

* High response times
* Server crashes
* Database overload
* Poor customer experience
* Revenue loss

With scalability:

* Better performance
* High availability
* Improved user experience
* Ability to handle traffic spikes
* Lower operational risk

â¸»

Vertical Scaling (Scale Up)

Definition

Vertical scaling means increasing the capacity of an existing server by adding more hardware resources.

Examples:

* More CPU
* More RAM
* Faster SSD
* Better Network

â¸»

Architecture

Before
Application
4 CPU
8 GB RAM
â†“
After Scale Up
Application
32 CPU
128 GB RAM

â¸»

How It Works

Instead of adding more machines, the same machine becomes more powerful.

The application continues running on a single server.

â¸»

Advantages

* Simple implementation
* No code changes
* No load balancer required
* Easier maintenance
* Suitable for monolithic applications

â¸»

Disadvantages

* Hardware limit
* Expensive upgrades
* Single point of failure
* Downtime during upgrades (in many environments)

â¸»

Real Example

A startup launches with:

* 2 CPU
* 4 GB RAM

Traffic increases.

Instead of changing architecture, the server is upgraded to:

* 16 CPU
* 64 GB RAM

â¸»

Best Use Cases

* Small applications
* Internal tools
* Development environments
* Early-stage startups

â¸»

Horizontal Scaling (Scale Out)

Definition

Horizontal scaling means adding more servers to distribute the workload.

Instead of making one server larger, multiple servers work together.

â¸»

Architecture

               Load Balancer
          /        |        \
      Server1   Server2   Server3
               |
            Database

â¸»

How It Works

Incoming requests first reach the load balancer.

The load balancer distributes requests among available servers.

Each server processes only a portion of the total traffic.

â¸»

Advantages

* Almost unlimited growth
* High availability
* Fault tolerance
* Better reliability
* Zero-downtime deployments

â¸»

Disadvantages

* More complex architecture
* Requires load balancing
* Data synchronization challenges
* Session management becomes difficult

â¸»

Real Examples

* Netflix
* Amazon
* Google
* Facebook
* Uber

These companies run thousands of application servers instead of one giant machine.

â¸»

Vertical vs Horizontal Scaling

Feature	Vertical Scaling	Horizontal Scaling
Add Resources	CPU/RAM	More Servers
Maximum Limit	Hardware Limit	Nearly Unlimited
Cost	Expensive Hardware	Commodity Servers
Downtime	Often Required	Usually Not Required
Fault Tolerance	Low	High
Complexity	Low	High
Best For	Small Apps	Large Distributed Systems

â¸»

Stateless vs Stateful Applications

â¸»

Stateless

A stateless application does not store user-specific information between requests.

Each request contains everything needed to process it.

User
â†“
Server
â†“
Response
(Server forgets everything)

Advantages

* Easy horizontal scaling
* Easy load balancing
* Better fault tolerance
* Simple deployments

â¸»

Examples

* REST APIs
* Public APIs
* Authentication using JWT
* Search services

â¸»

Stateful

A stateful application stores information between requests.

Examples include:

* Login session
* Shopping cart in server memory
* Multiplayer game session

User
â†“
Server
(Session Stored)
â†“
Next Request
â†“
Same Server Required

â¸»

Problems

If the request goes to another server:

* Session lost
* User logged out
* Shopping cart disappears

â¸»

Solutions

* Redis Session Store
* Sticky Sessions
* Distributed Cache
* Database-backed sessions

â¸»

Stateless vs Stateful

Feature	Stateless	Stateful
Session	No	Yes
Easy Scaling	Yes	Difficult
Load Balancer	Simple	Sticky Sessions Needed
Failure Recovery	Easy	Difficult
Cloud Native	Yes	Limited

â¸»

Elasticity

Definition

Elasticity is the ability of a system to automatically increase or decrease resources based on current demand.

Unlike scalability, elasticity focuses on automatic adaptation.

â¸»

Example

Morning:

10 Servers

Afternoon Sale:

100 Servers

Midnight:

8 Servers

Resources are added and removed automatically.

â¸»

Benefits

* Reduced infrastructure cost
* Better resource utilization
* Handles unpredictable traffic
* Supports cloud-native applications

â¸»

Auto Scaling

Definition

Auto Scaling automatically adds or removes servers based on predefined metrics.

Common metrics include:

* CPU utilization
* Memory usage
* Number of requests
* Queue length
* Network traffic
* Custom business metrics

â¸»

Workflow

CPU > 80%
â†“
Monitoring detects threshold
â†“
Launch New Instance
â†“
Register with Load Balancer
â†“
Traffic Distributed

â¸»

Scale In

When traffic decreases:

Low CPU
â†“
Terminate Extra Servers
â†“
Reduce Cost

â¸»

Cloud Services

* AWS Auto Scaling
* Azure VM Scale Sets
* Google Managed Instance Groups
* Kubernetes Horizontal Pod Autoscaler (HPA)

â¸»

Scaling Strategies

â¸»

1. Compute Scaling

Purpose

Increase processing capacity.

â¸»

Vertical

Increase:

* CPU
* RAM
* Faster processors

â¸»

Horizontal

Add more application servers.

Load Balancer
â†“
10 Application Servers

â¸»

Used For

* APIs
* Web Servers
* Background Workers
* AI Inference
* Batch Jobs

â¸»

2. Storage Scaling

Purpose

Handle increasing amounts of data.

â¸»

Vertical

Increase storage capacity of one database server.

Example:

1 TB â†’ 8 TB SSD

â¸»

Horizontal

Distribute data across multiple storage nodes.

Techniques:

* Sharding
* Distributed File Systems
* Object Storage

â¸»

Examples

* Amazon S3
* Azure Blob Storage
* Google Cloud Storage
* HDFS

â¸»

3. Read Scaling

Problem

Too many read requests overload the primary database.

â¸»

Solution

Use Read Replicas.

            Primary Database
             /     |      \
      Replica1 Replica2 Replica3

Applications send:

* Writes â†’ Primary
* Reads â†’ Replicas

â¸»

Benefits

* Higher throughput
* Lower latency
* Reduced load on primary

â¸»

Challenges

* Replication lag
* Eventual consistency
* Read-after-write issues

â¸»

4. Write Scaling

Problem

A single database eventually becomes a bottleneck for write operations.

â¸»

Techniques

Database Sharding

User A-M
â†“
Shard 1
User N-Z
â†“
Shard 2

â¸»

Partitioning

Split large tables into smaller partitions.

â¸»

Event Queue

Client
â†“
Kafka
â†“
Consumers
â†“
Database

Writes are processed asynchronously.

â¸»

CQRS

Separate read and write models.

* Optimized writes
* Optimized reads
* Independent scaling

â¸»

Challenges

* Cross-shard joins
* Transactions
* Data consistency
* Operational complexity

â¸»

Real-World Example

Suppose an application grows from 1,000 users to 50 million users.

1. Upgrade server (Vertical Scaling)
2. Add Load Balancer
3. Add multiple application servers (Horizontal Scaling)
4. Make APIs stateless
5. Store sessions in Redis
6. Enable Auto Scaling
7. Add database replicas for reads
8. Shard database for writes
9. Store images in object storage
10. Use distributed caching (Redis)
11. Introduce asynchronous messaging (Kafka/RabbitMQ)

This is a common evolution path for large-scale internet applications.

â¸»

Interview Questions

Basic

* What is scalability?
* Difference between scalability and elasticity?
* Vertical vs horizontal scaling?
* Why are stateless applications easier to scale?
* What is auto scaling?

â¸»

Intermediate

* How would you scale an application from 10,000 to 10 million users?
* When would you choose vertical scaling over horizontal scaling?
* How do read replicas improve scalability?
* What is replication lag?

â¸»

Advanced

* How do companies like Netflix scale globally?
* Explain write scaling in distributed databases.
* How would you eliminate a database bottleneck?
* How would you scale a stateful application?

â¸»

Cheat Sheet

Topic	Key Takeaway
Scalability	Ability to handle increased workload
Vertical Scaling	Add CPU/RAM to one server
Horizontal Scaling	Add more servers
Stateless	No session stored on server; easy to scale
Stateful	Session stored on server; harder to scale
Elasticity	Automatically adjust resources
Auto Scaling	Automatically add/remove instances
Compute Scaling	Increase processing power
Storage Scaling	Increase storage capacity
Read Scaling	Use replicas to serve reads
Write Scaling	Use sharding, partitioning, queues, CQRS
