# Scalability

Goal: Understand how systems handle increasing traffic, users, and data while maintaining performance and availability.

---

## Table of Contents

1. [What is Scalability?](#what-is-scalability)
2. [Why Scalability Matters](#why-scalability-matters)
3. [Vertical Scaling (Scale Up)](#vertical-scaling-scale-up)
4. [Horizontal Scaling (Scale Out)](#horizontal-scaling-scale-out)
5. [Stateless vs Stateful Applications](#stateless-vs-stateful-applications)
6. [Elasticity](#elasticity)
7. [Auto Scaling](#auto-scaling)
8. [Scaling Strategies](#scaling-strategies)
   - Compute Scaling
   - Storage Scaling
   - Read Scaling
   - Write Scaling
9. [Real-World Architecture](#real-world-architecture)
10. [Interview Questions](#interview-questions)
11. [Cheat Sheet](#cheat-sheet)

---

## What is Scalability?

**Definition**

Scalability is the ability of a system to handle increasing workload without significantly affecting performance.

The workload may increase because of:

- More users
- More requests
- More data
- More transactions
- More services

A scalable system should continue to provide acceptable response times even as demand grows.

**Example**

Suppose an e-commerce website receives:

- Day 1 → 1,000 users/day
- Festival Sale → 2,000,000 users/day

If the application continues serving users without crashing or slowing down dramatically, it is considered scalable.

---

## Why Scalability Matters

Without scalability:

- High response times
- Server crashes
- Database overload
- Poor customer experience
- Revenue loss

With scalability:

- Better performance
- High availability
- Improved user experience
- Ability to handle traffic spikes
- Lower operational risk

---

## Vertical Scaling (Scale Up)

**Definition**

Vertical scaling means increasing the capacity of an existing server by adding more hardware resources.

Examples:

- More CPU
- More RAM
- Faster SSD
- Better network

**Architecture (conceptual)**

Before:
- Application on a server (4 CPU, 8 GB RAM)

After scale up:
- Application on a more powerful server (32 CPU, 128 GB RAM)

**How it works**

Instead of adding more machines, the same machine becomes more powerful. The application continues running on a single server.

**Advantages**

- Simple implementation
- No code changes
- No load balancer required
- Easier maintenance
- Suitable for monolithic applications

**Disadvantages**

- Hardware limits
- Expensive upgrades
- Single point of failure
- Downtime during upgrades (in many environments)

**Real example**

A startup launches with 2 CPU and 4 GB RAM. As traffic increases, the server is upgraded to 16 CPU and 64 GB RAM.

**Best use cases**

- Small applications
- Internal tools
- Development environments
- Early-stage startups

---

## Horizontal Scaling (Scale Out)

**Definition**

Horizontal scaling means adding more servers to distribute the workload. Instead of making one server larger, multiple servers work together.

**Architecture (conceptual)**

               Load Balancer
          /        |        \
      Server1   Server2   Server3
               |
            Database

**How it works**

Incoming requests first reach the load balancer, which distributes requests among available servers. Each server processes only a portion of the total traffic.

**Advantages**

- Almost unlimited growth
- High availability
- Fault tolerance
- Better reliability
- Zero-downtime deployments (possible)

**Disadvantages**

- More complex architecture
- Requires load balancing
- Data synchronization challenges
- Session management becomes more difficult

**Real examples**

- Netflix
- Amazon
- Google
- Facebook
- Uber

These companies run thousands of application servers instead of relying on a single giant machine.

---

## Vertical vs Horizontal Scaling

| Feature            | Vertical Scaling     | Horizontal Scaling        |
|--------------------|----------------------|---------------------------|
| Add resources      | CPU / RAM            | More servers              |
| Maximum limit      | Hardware limit       | Nearly unlimited          |
| Cost               | Expensive hardware   | Commodity servers         |
| Downtime           | Often required       | Usually not required      |
| Fault tolerance    | Low                  | High                      |
| Complexity         | Low                  | High                      |
| Best for           | Small apps           | Large distributed systems |

---

## Stateless vs Stateful Applications

### Stateless

A stateless application does not store user-specific information between requests. Each request contains everything needed to process it.

Advantages:

- Easy horizontal scaling
- Easy load balancing
- Better fault tolerance
- Simple deployments

Examples:

- REST APIs
- Public APIs
- Authentication using JWT
- Search services

### Stateful

A stateful application stores information between requests (e.g., login session, shopping cart in server memory, multiplayer game session).

Problems:

- If a request goes to another server, session can be lost
- User might be logged out or shopping cart might disappear

Solutions:

- Redis session store
- Sticky sessions
- Distributed cache
- Database-backed sessions

### Stateless vs Stateful (comparison)

| Feature           | Stateless | Stateful |
|-------------------|-----------|----------|
| Session           | No        | Yes      |
| Easy scaling      | Yes       | Difficult|
| Load balancer     | Simple    | Sticky sessions often needed |
| Failure recovery  | Easy      | Difficult|
| Cloud native      | Yes       | Limited  |

---

## Elasticity

**Definition**

Elasticity is the ability of a system to automatically increase or decrease resources based on current demand. Unlike scalability, elasticity focuses on automatic adaptation.

**Example**

- Morning: 10 servers
- Afternoon sale: 100 servers
- Midnight: 8 servers

Resources are added and removed automatically.

**Benefits**

- Reduced infrastructure cost
- Better resource utilization
- Handles unpredictable traffic
- Supports cloud-native applications

---

## Auto Scaling

**Definition**

Auto Scaling automatically adds or removes servers based on predefined metrics.

Common metrics include:

- CPU utilization
- Memory usage
- Number of requests
- Queue length
- Network traffic
- Custom business metrics

**Workflow (example)**

- CPU > 80% → monitoring detects threshold → launch new instance → register with load balancer → traffic distributed

**Scale in**

When traffic decreases:

- Low CPU → terminate extra servers → reduce cost

**Cloud services**

- AWS Auto Scaling
- Azure VM Scale Sets
- Google Managed Instance Groups
- Kubernetes Horizontal Pod Autoscaler (HPA)

---

## Scaling Strategies

### 1. Compute Scaling

Purpose: Increase processing capacity.

- Vertical: Increase CPU, RAM, faster processors
- Horizontal: Add more application servers behind a load balancer

Used for:

- APIs
- Web servers
- Background workers
- AI inference
- Batch jobs

### 2. Storage Scaling

Purpose: Handle increasing amounts of data.

- Vertical: Increase capacity of one database server (e.g., 1 TB → 8 TB SSD)
- Horizontal: Distribute data across multiple storage nodes using sharding, distributed file systems, object storage

Examples:

- Amazon S3
- Azure Blob Storage
- Google Cloud Storage
- HDFS

### 3. Read Scaling

Problem: Too many read requests overload the primary database.

Solution: Use read replicas.

            Primary Database
             /     |      \
      Replica1 Replica2 Replica3

Applications send:
- Writes → Primary
- Reads → Replicas

Benefits:

- Higher throughput
- Lower latency
- Reduced load on primary

Challenges:

- Replication lag
- Eventual consistency
- Read-after-write issues

### 4. Write Scaling

Problem: A single database becomes a bottleneck for write operations.

Techniques:

- Database sharding (e.g., shard users A–M → shard 1, N–Z → shard 2)
- Partitioning large tables into smaller partitions
- Event queue (Client → Kafka → Consumers → Database) to process writes asynchronously
- CQRS: separate read and write models for independent scaling

Challenges:

- Cross-shard joins
- Transactions and data consistency
- Operational complexity

---

## Real-World Architecture (evolution path)

Suppose an application grows from 1,000 users to 50 million users. Typical steps:

1. Upgrade server (vertical scaling)
2. Add a load balancer
3. Add multiple application servers (horizontal scaling)
4. Make APIs stateless
5. Store sessions in Redis
6. Enable auto scaling
7. Add database replicas for reads
8. Shard database for writes
9. Store images in object storage
10. Use distributed caching (Redis)
11. Introduce asynchronous messaging (Kafka / RabbitMQ)

This is a common evolution path for large-scale internet applications.

---

## Interview Questions

**Basic**

- What is scalability?
- Difference between scalability and elasticity?
- Vertical vs horizontal scaling?
- Why are stateless applications easier to scale?
- What is auto scaling?

**Intermediate**

- How would you scale an application from 10,000 to 10 million users?
- When would you choose vertical scaling over horizontal scaling?
- How do read replicas improve scalability?
- What is replication lag?

**Advanced**

- How do companies like Netflix scale globally?
- Explain write scaling in distributed databases.
- How would you eliminate a database bottleneck?
- How would you scale a stateful application?

---

## Cheat Sheet

| Topic           | Key Takeaway |
|-----------------|--------------|
| Scalability     | Ability to handle increased workload |
| Vertical Scaling| Add CPU / RAM to one server |
| Horizontal Scaling | Add more servers |
| Stateless       | No session stored on server; easy to scale |
| Stateful        | Session stored on server; harder to scale |
| Elasticity      | Automatically adjust resources |
| Auto Scaling    | Automatically add/remove instances |
| Compute Scaling | Increase processing power |
| Storage Scaling | Increase storage capacity |
| Read Scaling    | Use replicas to serve reads |
| Write Scaling   | Use sharding, partitioning, queues, CQRS |
