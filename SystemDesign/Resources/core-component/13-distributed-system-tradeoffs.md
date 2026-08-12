# 13. Distributed System Trade-offs

Distributed systems are built by making **trade-offs**. Improving one property can negatively affect another.

For example:

```text
Stronger Consistency
        ↓
More coordination
        ↓
Higher Latency
        ↓
Potentially Lower Availability
        ↓
Higher Cost / Complexity
```

The goal of system design is **not to maximize every property**. The goal is to choose the right balance based on business requirements.

---

## 1. CAP vs PACELC

### CAP Theorem

CAP states that a distributed system cannot guarantee all three properties simultaneously **when a network partition occurs**.

CAP stands for:

- **C — Consistency**
- **A — Availability**
- **P — Partition Tolerance**

### Consistency

Every read gets the latest successful write or an error.

```text
Client
   ↓
Node A → Write = ₹100
   ↓
Node B → Read = ₹100
```

The system does not return stale data.

### Availability

Every request receives a response, even if the response may contain stale data.

```text
Node A → DOWN

Client
   ↓
Node B
   ↓
Response
```

The system continues serving requests.

### Partition Tolerance

The system continues operating even when nodes cannot communicate.

```text
Node A  X  Node B
        ↑
 Network Partition
```

Network partitions are unavoidable in distributed systems, so practical distributed systems generally have to tolerate them.

Therefore, during a partition, the major choice becomes:

```text
        Network Partition
               |
        +------+------+
        |             |
        ↓             ↓
       CP            AP
       |              |
Consistency      Availability
```

### CP System

CP means:

```text
Consistency + Partition Tolerance
```

When a partition happens, the system may reject or delay requests rather than return potentially inconsistent data.

```text
Node A  X  Node B

Write
  ↓
Cannot safely coordinate
  ↓
Reject / Wait
```

#### Use Cases

- Banking
- Payments
- Inventory
- Distributed locking
- Financial transactions

The priority is:

```text
Correct data > Always responding
```

### AP System

AP means:

```text
Availability + Partition Tolerance
```

During a partition, the system continues responding even if different nodes temporarily have different values.

```text
Node A  X  Node B

Node A → value = 100
Node B → value = 90

        ↓

Eventually synchronize
```

#### Use Cases

- Social media
- Likes/views
- Product catalogs
- Recommendations
- Some distributed key-value systems

The priority is:

```text
Always responding > Immediately consistent data
```

---

## PACELC

CAP mainly describes the trade-off **when a partition happens**.

PACELC extends CAP.

```text
P = Partition
A = Availability
C = Consistency

E = Else
L = Latency
C = Consistency
```

PACELC can be expressed as:

```text
If Partition:
    Choose Availability or Consistency

Else:
    Choose Latency or Consistency
```

Or:

```text
             Partition?
                 |
          +------+------+
          |             |
         YES            NO
          |             |
        A or C        L or C
```

### Why PACELC Matters

Even when there is **no failure**, you still have a trade-off.

Consider:

```text
Client
   ↓
Node A
   ↓
Node B
   ↓
Node C
   ↓
ACK
```

If we require multiple replicas to confirm a write, we get stronger consistency but additional network latency.

Alternatively:

```text
Client
   ↓
Node A
   ↓
ACK

Replication happens asynchronously
```

This provides lower latency but potentially weaker consistency.

### CAP vs PACELC

| CAP | PACELC |
|---|---|
| Focuses on partition scenarios | Covers partition + normal operation |
| P → A or C | P → A or C, Else → L or C |
| Simpler model | More comprehensive model |
| Mainly failure-oriented | Includes everyday latency/consistency decisions |

### Interview Answer

> CAP explains the trade-off during a network partition, while PACELC additionally explains that even without a partition, systems often trade latency against consistency.

---

# 2. Consistency vs Availability

This is one of the most important distributed-system trade-offs.

## Strong Consistency

After a successful write, every subsequent read sees the latest value.

```text
Write
  ↓
Primary
  ↓
Replicas synchronized
  ↓
Read
  ↓
Latest value
```

### Advantages

- Correct data
- Easier reasoning
- Suitable for critical transactions

### Disadvantages

- Higher latency
- More coordination
- Potentially lower availability during failures

---

## Eventual Consistency

Replicas may temporarily have different values, but eventually converge.

```text
Time T1

Node A = 100
Node B = 90

       ↓ Replication

Time T2

Node A = 100
Node B = 100
```

### Advantages

- High availability
- Lower latency
- Better scalability

### Disadvantages

- Stale reads
- Conflict resolution may be required
- More complicated application behavior

---

## Example: Banking

Balance:

```text
₹10,000
```

User withdraws:

```text
₹5,000
```

Another request immediately reading:

```text
₹10,000
```

would be dangerous.

Therefore:

```text
Banking
→ Strong Consistency
```

---

## Example: Social Media Likes

Suppose:

```text
Post likes = 10,000
```

One user sees:

```text
9,998
```

Another sees:

```text
10,001
```

for a short period.

Usually this is acceptable.

Therefore:

```text
Social Media
→ Eventual Consistency
```

### Key Rule

```text
If stale data is unacceptable
        ↓
Strong Consistency

If stale data is acceptable
        ↓
Eventual Consistency
```

---

# 3. Latency vs Consistency

Stronger consistency often requires more communication between distributed nodes.

## Strong Consistency

```text
Client
   ↓
Node A
   ↓
Node B
   ↓
Node C
   ↓
Confirm
   ↓
Client
```

More coordination:

```text
More network calls
        ↓
Higher latency
```

---

## Eventual Consistency

```text
Client
   ↓
Node A
   ↓
ACK

Replication happens asynchronously
```

Result:

```text
Lower latency
+
Potentially stale data
```

---

## Example: Global Application

Suppose the application has:

```text
India
  ↓
India DB

US
  ↓
US DB
```

If a write in India must synchronously reach the US:

```text
India
  ↓
US
  ↓
India
  ↓
ACK
```

The geographical network distance increases latency.

Instead:

```text
India
  ↓
Local Write
  ↓
ACK

       ↓ Async Replication

      US
```

This gives:

```text
Lower latency
+
Eventual consistency
```

### Choose Strong Consistency When

- Financial transactions
- Inventory
- Account balances
- Distributed locks
- Critical business state

### Choose Eventual Consistency When

- Social feeds
- Likes
- View counters
- Recommendations
- Analytics
- Search indexes

---

# 4. Performance vs Reliability

### Performance

Performance is about how efficiently and quickly the system processes requests.

Important metrics include:

- Latency
- Throughput
- CPU utilization
- Memory usage
- I/O

### Reliability

Reliability is about the system continuing to work correctly over time despite failures.

---

## Example: Database Replication

Without replication:

```text
Application
     ↓
Primary DB
```

If the database fails:

```text
Application
     ↓
     X
   DB DOWN
```

With replication:

```text
              Primary
             /       \
            ↓         ↓
        Replica 1  Replica 2
```

Reliability increases.

But we now have:

- Replication overhead
- Network traffic
- Storage cost
- More operational complexity

Therefore:

```text
Reliability ↑
      ↓
Redundancy ↑
      ↓
Cost ↑
Complexity ↑
Potential latency ↑
```

---

## Synchronous Replication

```text
Application
     ↓
Primary
     ↓
Replica
     ↓
ACK
```

The application waits for replication confirmation.

### Benefits

- Stronger durability
- Lower chance of losing recently written data

### Cost

- Higher write latency

---

## Asynchronous Replication

```text
Application
     ↓
Primary
     ↓
ACK

       ↓
   Async Replication
       ↓
    Replica
```

### Benefits

- Lower write latency
- Better performance

### Risk

If the primary fails before replication:

```text
Primary
  ↓
Write

X CRASH

Replica never received write
```

Some recently written data may be lost.

### Trade-off

```text
Synchronous
→ Reliability ↑
→ Latency ↑

Asynchronous
→ Performance ↑
→ Potential data-loss window ↑
```

---

# 5. Cost vs Availability

Higher availability usually requires more infrastructure.

## Single Server

```text
Client
  ↓
Server
```

If it fails:

```text
System DOWN
```

---

## Multiple Servers

```text
             Load Balancer
              /        \
             ↓          ↓
         Server A    Server B
```

If Server A fails:

```text
Server B
   ↓
Continues serving
```

Availability increases.

But additional infrastructure is required.

### Additional Cost

- More servers
- Load balancer
- Replicas
- Monitoring
- Failover systems
- Backup infrastructure
- Operations
- Storage

Therefore:

```text
Availability ↑
      ↓
Infrastructure ↑
      ↓
Cost ↑
```

---

## Availability "Nines"

Approximate annual downtime:

| Availability | Downtime/year |
|---|---:|
| 99% | 3.65 days |
| 99.9% | 8.76 hours |
| 99.99% | 52.6 minutes |
| 99.999% | 5.26 minutes |

The higher the availability target, the more engineering and infrastructure investment is generally required.

### Important

Do not automatically design every application for 99.999% availability.

Ask:

```text
What does the business actually require?
```

For example:

```text
Internal reporting tool
→ 99.9% may be sufficient

Payment system
→ Much higher availability may be justified
```

---

# 6. Scalability vs Complexity

Scalability means the system can handle increasing workload by adding resources or improving capacity.

## Simple Architecture

```text
Client
  ↓
Application
  ↓
Database
```

Very easy to understand.

But eventually:

```text
Traffic ↑
Users ↑
Data ↑
```

The single application/database may become a bottleneck.

---

## Horizontal Scaling

Instead of one server:

```text
Server
```

use multiple servers:

```text
             Load Balancer
           /       |       \
          ↓        ↓        ↓
       Server 1 Server 2 Server 3
```

Scalability increases.

But now we need:

- Load balancing
- Health checks
- Service discovery
- Distributed logging
- Distributed tracing
- Session management
- Deployment management

Therefore:

```text
Scalability ↑
      ↓
Architecture complexity ↑
```

---

# Microservices Example

## Monolith

```text
             Application
          /       |       \
       User     Order    Payment
                     |
                    DB
```

Advantages:

- Simple deployment
- Simple debugging
- Easier transactions
- Less network communication

But scaling can be inefficient.

Suppose:

```text
User → Low traffic
Order → Very high traffic
Payment → Medium traffic
```

With a monolith:

```text
Entire application
        ↓
Scale everything
```

---

## Microservices

```text
User Service
     ↓
Order Service
     ↓
Payment Service
     ↓
Inventory Service
```

Now each service can scale independently:

```text
User Service       → 2 instances
Order Service      → 10 instances
Payment Service    → 5 instances
Inventory Service  → 4 instances
```

This improves scalability.

But complexity increases:

- Network communication
- Service discovery
- API contracts
- Distributed transactions
- Retry mechanisms
- Circuit breakers
- Message queues
- Distributed tracing
- Centralized logging
- Deployment complexity
- Monitoring
- Failure handling

Therefore:

```text
More scalability
       ↓
More distributed components
       ↓
More failure scenarios
       ↓
More operational complexity
```

---

# Overall Trade-off Diagram

```text
                    Distributed System
                           |
          +----------------+----------------+
          |                |                |
          ↓                ↓                ↓
    Consistency       Availability      Performance
          |                |                |
          +----------------+----------------+
                           |
                       Trade-offs
                           |
          +----------------+----------------+
          |                |                |
          ↓                ↓                ↓
         Cost          Reliability     Complexity
                           |
                      Scalability
```

---

# Trade-off Summary

| Trade-off | Option 1 | Option 2 |
|---|---|---|
| **CAP** | Consistency | Availability |
| **PACELC during partition** | Consistency | Availability |
| **PACELC normally** | Consistency | Latency |
| **Consistency vs Availability** | Strong/fresh data | Always responding |
| **Latency vs Consistency** | Lower latency | Stronger synchronization |
| **Performance vs Reliability** | Faster/less overhead | More redundancy/durability |
| **Cost vs Availability** | Lower infrastructure cost | Higher fault tolerance |
| **Scalability vs Complexity** | Simpler system | Handles larger scale |

---

# How to Explain Trade-offs in a System Design Interview

Never just say:

> "I will use Kafka, Redis, replicas, CDN and microservices."

Instead explain the **reason and trade-off**.

Use this framework:

```text
1. Identify the business requirement
              ↓
2. Identify the failure scenarios
              ↓
3. Decide which property is more important
              ↓
4. Choose the architecture
              ↓
5. Explain the trade-off
```

## Example: Payment System

Requirement:

```text
Correctness is more important than latency
```

Design:

```text
Strong consistency
+
Durable writes
+
Replication
+
Idempotency
+
Reliable transaction processing
```

Trade-off:

```text
Higher latency
+
Higher infrastructure cost
+
More complexity
```

---

## Example: Social Media Feed

Requirement:

```text
Low latency + high availability
```

Design:

```text
Caching
+
CDN
+
Asynchronous processing
+
Eventual consistency
```

Trade-off:

```text
Temporary stale data
```

---

# Interview Cheat Sheet

```text
CAP
→ During network partition:
   Consistency OR Availability

PACELC
→ During partition:
   Availability OR Consistency

→ When there is no partition:
   Latency OR Consistency

Consistency vs Availability
→ Fresh/correct data vs always responding

Latency vs Consistency
→ Faster response vs stronger synchronization

Performance vs Reliability
→ Speed vs redundancy/durability

Cost vs Availability
→ Lower cost vs higher fault tolerance

Scalability vs Complexity
→ Handle more load vs simpler architecture
```

---

# Golden Rule

> **Good distributed-system design is not about eliminating trade-offs. It is about identifying the trade-offs, choosing the appropriate side based on business requirements, and clearly explaining why.**
