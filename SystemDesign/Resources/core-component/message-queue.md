> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Resource Notes
> Docs Index: [README.md](../../../README.md)

# Message Queue (MQ)

> Message Queues enable asynchronous communication between services, improving scalability, reliability, and fault tolerance.

---

# 1. Fundamentals

## What is a Message Queue?

A Message Queue is middleware that stores messages sent by producers until consumers process them.

```
Producer â†’ Queue â†’ Consumer
```

Instead of direct communication, services exchange messages through a broker.

### Why use Message Queues?

- Asynchronous processing
- Loose coupling
- Reliability
- Traffic buffering
- Better scalability
- Fault tolerance

### Advantages

- Faster API responses
- Independent services
- Handles traffic spikes
- Retry support
- Horizontal scaling

### Disadvantages

- Eventual consistency
- Duplicate messages
- Ordering challenges
- Operational complexity

### Real-world Examples

- Order Processing
- Email Notifications
- Payment Processing
- Chat Applications
- Video Processing

---

# 2. Internal Working

## Architecture

```
Producer
    â”‚
    â–¼
Message Broker
    â”‚
    â–¼
 Queue Storage
    â”‚
    â–¼
Consumer
```

## Flow

1. Producer creates message.
2. Broker receives message.
3. Message stored in queue.
4. Consumer pulls message.
5. Consumer processes it.
6. Consumer sends ACK.
7. Broker removes message.

### If Consumer Crashes

```
Producer

   â”‚

Queue

   â”‚

Consumer âŒ

No ACK

â†“

Message stays in Queue

â†“

Retry
```

---

# 3. Queue vs Pub/Sub

## Queue

One message â†’ One consumer

```
Producer

   â”‚

 Queue

   â”‚

Consumer A
```

Best For

- Order Processing
- Background Jobs
- Image Processing

---

## Pub/Sub

One message â†’ Multiple consumers

```
           Email

Producer â†’ Topic â†’ SMS

           Analytics

           Inventory
```

Best For

- Notifications
- Event Driven Systems
- Logging

---

# Queue vs Pub/Sub

| Queue | Pub/Sub |
|--------|---------|
| One Consumer | Multiple Consumers |
| Load Balancing | Broadcasting |
| No Duplicate Processing | Multiple Copies |
| Job Processing | Notifications |

---

# 4. Delivery Guarantees

## At Most Once

```
Deliver

â†“

Delete Immediately
```

Pros

- Fast
- No duplicates

Cons

- Message loss possible

---

## At Least Once

```
Deliver

â†“

Wait ACK

â†“

Delete
```

Pros

- No data loss

Cons

- Duplicate messages

Most commonly used.

---

## Exactly Once

Message processed exactly one time.

Requires

- Transactions
- Idempotency
- Deduplication

Very difficult in distributed systems.

---

# Comparison

| Type | Data Loss | Duplicate |
|-------|-----------|-----------|
| At Most Once | Yes | No |
| At Least Once | No | Yes |
| Exactly Once | No | No |

---

# 5. Ordering

Ordering means messages are processed in the same sequence.

```
M1

â†“

M2

â†“

M3
```

### Problem

Multiple consumers break ordering.

### Solution

Partition using a key.

```
User1 â†’ Partition1

User2 â†’ Partition2
```

Ordering is guaranteed inside a partition.

Trade-off

Hot partitions may reduce throughput.

---

# 6. Retry

Consumers may fail temporarily.

```
Process

â†“

Fail

â†“

Retry
```

## Retry Strategies

### Immediate Retry

Retry instantly.

### Exponential Backoff

```
1s

â†“

2s

â†“

4s

â†“

8s
```

### Maximum Retry

```
Retry

â†“

Retry

â†“

Retry

â†“

DLQ
```

Best Practices

- Exponential Backoff
- Random Jitter
- Retry Limits

---

# 7. Dead Letter Queue (DLQ)

Messages that repeatedly fail are moved to DLQ.

```
Queue

â†“

Retry

â†“

Retry

â†“

Retry

â†“

DLQ
```

Reasons

- Invalid Data
- Corrupted Messages
- Business Validation Failure

Benefits

- Prevent queue blocking
- Easy debugging
- Manual replay

---

# Patterns

## Event Driven Architecture

```
Order Created

â†“

Event Bus

â”œâ”€â”€ Email

â”œâ”€â”€ Inventory

â”œâ”€â”€ Analytics

â””â”€â”€ Notification
```

### Pros

- Loose Coupling
- Independent Services
- Easy Scaling

### Cons

- Eventual Consistency
- Hard Debugging

---

## Producer Consumer

```
Producer

â†“

Queue

â†“

Worker Pool
```

Scale consumers horizontally.

---

## Fan-Out

One event triggers many services.

```
Payment Success

â†“

Topic

â”œâ”€â”€ Email

â”œâ”€â”€ Loyalty

â”œâ”€â”€ Analytics

â””â”€â”€ Invoice
```

Best for broadcasting.

---

## Event Sourcing

Instead of storing current state, store every event.

```
Account Created

â†“

Deposit 100

â†“

Withdraw 20

â†“

Deposit 50
```

Current state is rebuilt by replaying events.

Advantages

- Complete Audit History
- Replay Events
- Easy Debugging

Disadvantages

- Storage Growth
- Slow Replay

Solution

Use Snapshots.

---

# Popular Technologies

| Technology | Best For |
|------------|----------|
| Kafka | Event Streaming |
| RabbitMQ | Traditional Messaging |
| AWS SQS | Cloud Queue |
| Azure Service Bus | Enterprise Messaging |
| Apache Pulsar | Cloud Native Streaming |

---

# Common Bottlenecks

| Problem | Solution |
|----------|----------|
| Slow Consumers | Scale Consumers |
| Queue Growth | Auto Scaling |
| Duplicate Messages | Idempotency |
| Ordering Issues | Partition by Key |
| Large Messages | Store in Object Storage |
| Poison Messages | Dead Letter Queue |
| Retry Storm | Exponential Backoff |

---

# Trade-offs

| Choice | Benefit | Drawback |
|----------|----------|----------|
| Queue | Load Balancing | No Broadcast |
| Pub/Sub | Multiple Subscribers | More Storage |
| At Least Once | No Data Loss | Duplicates |
| Exactly Once | No Duplicates | Complex |
| Single Partition | Ordering | Low Throughput |
| Multiple Partitions | High Throughput | Ordering Challenges |

---

# Best Practices

- Keep messages small.
- Use idempotent consumers.
- Always configure DLQ.
- Monitor queue depth.
- Use retries with exponential backoff.
- Partition by business key.
- Version event schemas.
- Avoid large payloads.
- Track consumer lag.
- Design for eventual consistency.

---

# Interview Questions

### Why use Message Queue?

- Decoupling
- Async processing
- Reliability
- Scalability

### Queue vs Pub/Sub?

Queue â†’ One Consumer

Pub/Sub â†’ Multiple Consumers

### Why At Least Once?

Losing data is worse than processing duplicates.

### How to avoid duplicate processing?

- Idempotency
- Deduplication
- Unique Message IDs

### Why DLQ?

To isolate poison messages after retry limit.

### How to maintain ordering?

Partition by key.

### Kafka vs RabbitMQ?

Kafka â†’ High throughput event streaming.

RabbitMQ â†’ Traditional messaging and routing.

---

# Summary

```
Producer
     â”‚
     â–¼
Message Broker
     â”‚
 â”Œâ”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
 â–¼              â–¼
Queue         Topic
 â”‚              â”‚
 â–¼              â–¼
Consumer    Multiple Subscribers
 â”‚
 â–¼
ACK
 â”‚
 â–¼
Delete

Failure
 â”‚
 â–¼
Retry
 â”‚
 â–¼
Dead Letter Queue
```
