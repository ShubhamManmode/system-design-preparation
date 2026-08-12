> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Resource Notes
> Docs Index: [../../../README.md](../../../README.md)

# Database Scaling

Database scaling is the process of increasing a system's capacity to handle more traffic, larger datasets, and higher availability without losing correctness or performance.

In practical systems, scaling is usually not a single decision. It combines several techniques such as replication, sharding, partitioning, caching, and read/write splitting.

## Why scaling matters
A database may work fine for a small application but fail under production load because of:

- high read traffic
- write-heavy workloads
- unbounded data growth
- larger fan-out queries
- regional latency
- failover and availability requirements

The main goal is to keep latency low while preserving consistency and reliability.

## Core scaling concepts

### 1. Vertical scaling
Vertical scaling means increasing the resources of a single database node.

Examples:
- more CPU
- more RAM
- faster SSDs
- larger instance size

```text
Before: 1 DB server (4 vCPU, 16 GB RAM)
After:  1 DB server (16 vCPU, 64 GB RAM)
```

Pros:
- simpler to implement
- easier operationally

Cons:
- limited by hardware ceiling
- single point of failure
- expensive at large scale

### 2. Horizontal scaling
Horizontal scaling means distributing the database across multiple machines.

```text
Single node DB
    ↓
[DB-1] [DB-2] [DB-3] [DB-4]
```

Pros:
- better capacity growth
- better fault tolerance
- easier to support large-scale systems

Cons:
- more complex
- replication and consistency challenges
- shard management complexity

---

## Read scaling vs write scaling

### Read scaling
When many users read the same or similar data, we can use:

- read replicas
- caching
- CDN for static content
- materialized views

```text
Clients --> App Server --> Read Replica
                          |
                          +--> Primary DB
```

### Write scaling
When write load is high, we can use:

- partitioning
- sharding
- async queues
- batching
- write-optimized stores

```text
Writes --> Queue --> DB Shards
```

---

## Replication
Replication creates copies of data across multiple nodes to improve read capacity and availability.

### Types of replication

#### Leader-follower replication
One node acts as the leader and accepts writes. Followers replicate data and serve reads.

```text
Client Writes --> Primary DB
                  |
                  v
             Replica 1
             Replica 2
             Replica 3
```

Use cases:
- read-heavy workloads
- failover and disaster recovery

Challenges:
- replication lag
- stale reads
- failover complexity

#### Multi-leader replication
Multiple leaders accept writes, and they sync with each other.

Use cases:
- regional systems
- distributed deployments

Challenges:
- conflict resolution
- write conflicts
- complex coordination

#### Leaderless replication
Clients write to multiple nodes directly.

Example pattern:
- Cassandra / Dynamo-like systems
- quorum-based consistency

```text
Write to Node A, B, C
   |       |      |
   +-------+------+
      Majority acknowledged
```

### Replication lag
Replication lag is the delay between data being written to the leader and appearing in followers.

If reads hit a lagging replica, users may see stale data.

This is why systems often use:
- stale-tolerant reads
- read-after-write guarantees
- session affinity to a leader

---

## Partitioning
Partitioning splits a large dataset into smaller subsets.

### Horizontal partitioning
Each partition stores a subset of rows.

```text
Table users
---------------------------------
| user_id 1-100000 | user_id 100001-200000 |
---------------------------------
```

Good when:
- table size is large
- hot partitions are manageable

### Vertical partitioning
Different columns are stored in different tables or databases.

Good when:
- some columns are accessed less frequently
- large text/blob columns can be separated

### Partition pruning
Queries avoid scanning irrelevant partitions.

Example:
- filter by `region_id`
- filter by date range

This reduces cost and improves latency.

---

## Sharding
Sharding is a form of horizontal partitioning where data is split across multiple database nodes based on a shard key.

### Common sharding strategies

#### Range sharding
Rows are split by a key range.

Example:
- user IDs 1-100k -> shard 1
- 100001-200k -> shard 2

Pros:
- easy to reason about

Cons:
- hotspot risk if one key range is too busy

#### Hash sharding
Use a hash function on the shard key.

```text
hash(user_id) % N -> shard number
```

Pros:
- better distribution
- reduces hot spots

Cons:
- harder to do range queries

#### Directory sharding
Store a lookup map from key to shard.

Useful when:
- data placement is dynamic
- rebalancing is required

### Shard key selection
The shard key decides where data lives. A bad shard key can create:

- hot shards
- uneven load
- expensive cross-shard joins

Good shard keys are:
- high cardinality
- evenly distributed
- stable over time

### Resharding
Resharding moves data when:
- traffic grows
- a shard becomes too large
- storage distribution becomes uneven

This is often done using:
- consistent hashing
- virtual buckets
- background migration

---

## Consistent hashing
Consistent hashing helps when nodes are added or removed without reassigning all data.

```text
Nodes in ring
   A ---- B ---- C ---- D
   |         |         |
   data keys mapped around ring
```

Benefits:
- minimal remapping during node changes
- useful for caches and distributed systems
- good for distributed data stores

---

## Consistency models
Database systems do not all provide the same consistency guarantees.

### Strong consistency
After a write succeeds, all later reads return the updated value.

Use when:
- payments
- inventory
- bank balances
- critical business state

### Eventual consistency
After a write, replicas may temporarily return stale values, but they converge eventually.

Use when:
- social feeds
- analytics
- caches
- high-availability systems

### Quorum reads and writes
A quorum is a majority of nodes required to acknowledge a read or write.

```text
Write quorum = 2 of 3 nodes
Read quorum  = 2 of 3 nodes
```

This helps maintain consistency in distributed systems.

---

## Distributed transactions
A distributed transaction spans multiple databases or services.

### Two-phase commit (2PC)
2PC has two phases:
1. prepare
2. commit/rollback

It ensures coordination but can block when a node fails.

### Saga pattern
Instead of one big transaction, a saga breaks work into smaller local transactions with compensating actions.

```text
Order Service -> Payment Service -> Inventory Service -> Notification Service
```

This is common in microservices architectures.

### Transactional outbox
Write an event to an outbox table in the same transaction as the database update, then dispatch it asynchronously.

This avoids lost events during processing.

---

## High availability
High availability means the system stays online even when components fail.

### Common techniques
- failover
- automatic failover
- replication
- backups
- disaster recovery

```text
Primary DB --> replica 1
   |
   +--> replica 2
```

If primary fails, a replica can be promoted.

---

## Performance optimization
Databases can be tuned in multiple ways to improve throughput and reduce latency.

### Examples
- connection pooling
- read/write splitting
- statement caching
- index optimization
- materialized views
- batch inserts

```text
App Clients --> Connection Pool --> DB
```

A connection pool reduces the cost of creating new DB connections repeatedly.

---

## Database patterns
Modern systems often combine multiple patterns.

### CQRS
Command Query Responsibility Segregation separates read and write models.

### Event sourcing
Store events as the source of truth instead of only current state.

### Polyglot persistence
Use different databases for different needs.

Example:
- PostgreSQL for transactional data
- Redis for cache
- Elasticsearch for search

### Database per service
Each microservice owns its own persistence store, reducing coupling.

---

## Cloud database examples
Many cloud providers offer managed database systems.

Examples:
- Azure SQL
- Azure Cosmos DB
- Amazon RDS
- Amazon Aurora
- Google Cloud SQL
- CockroachDB
- YugabyteDB

These services provide managed scaling, backups, replication, and failover.

---

## Interview perspective
When asked about database scaling in an interview, the expected answer usually includes:

1. estimate read/write workload
2. decide between vertical and horizontal scaling
3. add replication for read capacity and availability
4. use partitioning/sharding for massive data growth
5. pick consistency model carefully
6. consider failover and disaster recovery
7. optimize indexes, queries, and connection pools

---

## Summary
Database scaling is about distributing load and keeping the data layer reliable as usage grows.

The core techniques are:
- vertical scaling for small scale improvements
- horizontal scaling for large-scale systems
- replication for availability and read distribution
- partitioning and sharding for large datasets
- consistency tuning for correctness trade-offs
- failover and backups for resiliency

A strong system design answer should explain not just the technique, but the trade-offs behind it.

---

## Related topics
- [Database Fundamentals](../Syllabus/Phase2_DatabaseFundamentals.md)
- [Storage Fundamentals](../Syllabus/Phase6_StorageFundamentals.md)
- [Scalability](../Syllabus/Phase4_Scalibility.md)
