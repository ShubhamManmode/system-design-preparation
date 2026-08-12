> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Syllabus Chapter
> Docs Index: [README.md](../../README.md)

# Database Scaling

Database scaling is the process of making a data layer handle more traffic, more data, and higher reliability without breaking application correctness.

When a system grows from a few users to millions of requests per day, the database becomes a critical bottleneck. Scaling is about designing how data is replicated, partitioned, routed, and recovered.

## Learning goals
By the end of this chapter, you should understand:

- vertical vs horizontal scaling
- replication and read/write distribution
- partitioning and sharding
- consistency trade-offs
- failover and high availability
- common scaling patterns used in real-world systems

---

## 1. Scaling fundamentals

### Why scale the database?
A database can become slow or unavailable because of:

- too many reads
- too many writes
- large data size
- hot partitions
- slow queries
- unbalanced traffic across regions

### Core concepts

#### Vertical scaling
Vertical scaling means increasing the resources of a single database instance.

```text
Before: 1 DB server -> 4 vCPU / 16 GB RAM
After:  1 DB server -> 16 vCPU / 64 GB RAM
```

Pros:
- simple to manage
- fast to implement

Cons:
- limited by hardware limits
- expensive
- single point of failure

#### Horizontal scaling
Horizontal scaling means adding more database nodes and distributing work across them.

```text
Single node:
DB

Distributed:
[DB-1] [DB-2] [DB-3] [DB-4]
```

Pros:
- better capacity growth
- more resilience
- supports large production systems

Cons:
- higher operational complexity
- harder consistency management

#### Read scaling vs write scaling
- Read scaling: add replicas or cache layers
- Write scaling: partition data, use queues, or shard writes

```text
Clients --> App --> DB Primary
                    |
                    +--> Read Replicas
```

---

## 2. Replication
Replication creates copies of data across nodes to improve availability and read capacity.

### Leader-follower replication
A primary node handles writes; replicas sync from it.

```text
Client Write --> Primary DB
                     |
                     +--> Replica 1
                     +--> Replica 2
                     +--> Replica 3
```

Use cases:
- read-heavy APIs
- failover support
- backup strategy

Benefits:
- better read throughput
- failover support

Problems:
- replication lag
- stale reads
- failover complexity

### Leaderless replication
Clients write to multiple nodes directly. A quorum of nodes must acknowledge the write.

```text
Write to N1, N2, N3
     |      |      |
     +------|------+
      Majority accepted
```

This is common in distributed databases such as Cassandra or Dynamo-like systems.

### Replication lag
Replication lag is the delay between a leader accepting a write and followers reflecting it.

This matters because a user may read stale data from a replica that has not yet caught up.

---

## 3. Partitioning
Partitioning divides a large dataset into smaller independent units.

### Horizontal partitioning
Rows are split across partitions.

```text
Users table
--------------------------------------
| user_id 1-100k | user_id 100001-200k |
--------------------------------------
```

This is the most common approach for scaling databases.

### Vertical partitioning
Different columns are split into separate tables or stores.

Example:
- user profile table
- billing data table
- audit logs table

### Partition pruning
A query should only scan relevant partitions, not the whole dataset.

Example:
- filter by `customer_id`
- filter by timestamp range

This reduces query cost and improves performance.

---

## 4. Sharding
Sharding is a special form of horizontal partitioning where data is distributed across shards based on a shard key.

### Common sharding strategies

#### Range sharding
Data is split by key ranges.

```text
1-100k -> shard-a
100001-200k -> shard-b
```

Pros:
- easy to understand

Cons:
- hotspot risk when one range receives more traffic

#### Hash sharding
A hash function determines the destination shard.

```text
hash(user_id) % N = shard_id
```

Pros:
- uniform distribution
- reduces hot spots

Cons:
- harder to do range scans

#### Directory sharding
A lookup map tells where a certain key lives.

Useful when:
- rebalancing is frequent
- partitions are dynamic

### Shard key selection
A bad shard key creates uneven traffic and uneven data distribution.

Good shard keys are:
- high cardinality
- evenly distributed
- stable over time

### Resharding
When a shard becomes overloaded or too large, data must be moved to a new shard layout.

This may be done via:
- consistent hashing
- virtual buckets
- background migration

---

## 5. Distributed data and hashing
Distributed systems need elegant ways to map keys to storage nodes.

### Consistent hashing
Consistent hashing reduces the amount of data moved when servers are added or removed.

```text
A ---- B ---- C ---- D
  \       |       /
   key mapping around ring
```

Benefits:
- minimal rebalancing
- better cache and storage distribution
- smooth node changes

---

## 6. Consistency
Consistency defines how up-to-date reads are after writes.

### Strong consistency
After a write succeeds, all later reads return the new value.

Use when:
- payments
- account balances
- inventory reservation

### Eventual consistency
After a write, replicas may be temporarily stale, but eventually converge.

Use when:
- feeds
- analytics
- social updates
- global systems with lower latency

### Quorum reads and writes
A quorum means majority agreement from participating nodes.

```text
3 nodes total
Write quorum = 2
Read quorum = 2
```

This helps maintain consistency in distributed systems.

---

## 7. Distributed transactions
Some workloads must atomically change multiple systems.

### Two-phase commit (2PC)
2PC has a prepare phase and a commit phase.

It guarantees coordination, but has downsides:
- blocking behavior on failures
- reduced availability
- complexity

### Saga pattern
A saga breaks a transaction into multiple local transactions with compensating actions.

```text
Order Service -> Payment Service -> Inventory Service -> Notification Service
```

This pattern is common in microservice systems.

### Transactional outbox
The application writes an event to an outbox table in the same local transaction as the state change, then dispatches it asynchronously.

This reduces the risk of lost events.

---

## 8. High availability and resilience
Availability is about staying operational even when components fail.

### Common techniques
- primary-replica failover
- auto failover
- geo-replication
- backup and restore
- disaster recovery drills

```text
Primary DB --> Replica 1
   |
   +--> Replica 2
```

If the primary fails, one replica can become the new primary.

---

## 9. Performance optimization
A well-scaled system also needs performance tuning.

### Techniques
- connection pooling
- read/write splitting
- index optimization
- query tuning
- materialized views
- batching writes

```text
App layer --> Connection Pool --> Database
```

Connection pooling reduces the overhead of creating and destroying database connections frequently.

---

## 10. Database patterns
Modern systems often combine multiple data patterns.

### CQRS
Split command and query responsibilities into separate models.

### Event sourcing
Store all state changes as append-only events.

### Polyglot persistence
Use different databases for different needs.

Example:
- PostgreSQL for transactional data
- Redis for cache
- Elasticsearch for search

### Database per service
In microservices, each service owns its own database.

This reduces coupling but increases operational complexity.

---

## 11. Cloud implementations
Many large systems use cloud-managed databases.

Examples:
- Azure SQL
- Azure Cosmos DB
- Amazon RDS
- Amazon Aurora
- Google Cloud SQL
- CockroachDB
- YugabyteDB

These systems offer
automatic scaling, backup, failover, replication, and monitoring.

---

## Interview strategy
When asked in interviews, a strong answer should include:

1. workload analysis
2. read vs write pattern
3. replication strategy
4. sharding or partitioning approach
5. consistency requirement
6. failover plan
7. monitoring and optimization

---

## Summary
Database scaling is not just about adding more machines. It is about designing the data layer to balance:

- capacity
- latency
- consistency
- availability
- cost

The most important scaling decisions involve:

- replication for availability and read capacity
- partitioning and sharding for data growth
- consistency trade-offs for correctness and latency
- failover mechanisms for resiliency
- performance tuning for high throughput

A good system design answer explains both the solution and the trade-offs behind it.

---

## Related topics
- [Database Fundamentals](Phase2_DatabaseFundamentals.md)
- [Storage Fundamentals](Phase6_StorageFundamentals.md)
- [Scalability](Phase4_Scalibility.md)
- [Resource Notes: Database Scaling](../Resources/database/database-scaling.md)
