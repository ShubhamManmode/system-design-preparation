> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: System Design Notes
> Docs Index: [README.md](README.md)
# Performance

> **Goal:** Understand the key performance metrics used in designing scalable and highly efficient distributed systems.

---

# Table of Contents

1. What is Performance?
2. Why Performance Matters?
3. Latency
4. Throughput
5. Bandwidth
6. Response Time
7. RPS (Requests Per Second)
8. QPS (Queries Per Second)
9. Concurrent Users
10. Performance Bottlenecks
11. Performance Optimization Techniques
12. Real-World Example
13. Interview Questions
14. Cheat Sheet

---

# What is Performance?

## Definition

Performance refers to how efficiently a system processes requests while maintaining low response time and high throughput.

A high-performance system should:

- Respond quickly
- Process many requests
- Efficiently utilize resources
- Scale under increasing load

Performance is one of the most important **Non-Functional Requirements (NFRs)** in System Design.

---

# Why Performance Matters?

Imagine an online shopping website during a festival sale.

Normal Day:

- 5,000 users
- 200 requests/sec

Festival Sale:

- 2 million users
- 100,000 requests/sec

Without good performance:

- Website becomes slow
- Checkout fails
- Customers leave
- Revenue is lost

Good performance ensures:

- Faster response
- Better user experience
- Higher customer retention
- Improved scalability

---

# Latency

## Definition

Latency is the time taken for a request to travel from the client to the server and back.

In simple words:

> **Latency is the delay before receiving the first byte of the response.**

---

## Example

You click the Login button.

```
Client
   |
   |------ Request ------>
   |
Server
   |
   |------ Response ------>
   |
Client
```

If the request takes

```
120 milliseconds
```

then

```
Latency = 120 ms
```

---

## Real-Life Example

Ordering food online.

- You place an order.
- Restaurant receives it after 2 seconds.

Those 2 seconds represent latency.

---

## Factors Affecting Latency

- Physical distance
- Slow database
- Network congestion
- DNS lookup
- SSL handshake
- Load balancer delay
- Disk I/O

---

## How to Reduce Latency

- Use CDN
- Cache frequently used data
- Optimize database queries
- Keep servers geographically closer
- Reduce network hops
- Use HTTP/2 or HTTP/3

---

# Throughput

## Definition

Throughput is the amount of work completed in a given period.

It measures the system's processing capacity.

---

## Formula

```
Throughput = Total Requests Processed / Time
```

---

## Example

A server processes

```
60,000 requests

in

60 seconds
```

```
Throughput = 1000 requests/sec
```

---

## Important

Latency and Throughput are different.

A system can have:

- Low latency but low throughput
- High throughput but high latency

The ideal system has:

- Low latency
- High throughput

---

## Example

Restaurant Analogy

Restaurant A

- Serves one customer every minute

Restaurant B

- Serves 100 customers every minute

Restaurant B has higher throughput.

---

# Bandwidth

## Definition

Bandwidth is the maximum amount of data that can be transferred over a network in a given time.

---

## Units

- Mbps
- Gbps
- TB/day

---

## Example

Internet connection

```
100 Mbps
```

This means

Maximum theoretical transfer speed is 100 Mbps.

---

## Important

Bandwidth is **capacity**, not speed.

High bandwidth does not guarantee low latency.

Example:

A highway has 12 lanes.

More cars can travel simultaneously.

That is bandwidth.

---

# Response Time

## Definition

Response Time is the total time taken from sending a request until receiving the complete response.

---

## Formula

```
Response Time

=

Network Latency

+

Server Processing Time

+

Database Time

+

Response Transmission Time
```

---

## Example

```
Network

20 ms

Server

35 ms

Database

40 ms

Response Transfer

10 ms

Total

105 ms
```

---

## Difference

Latency measures delay.

Response Time measures the complete request lifecycle.

---

# RPS (Requests Per Second)

## Definition

RPS is the number of HTTP requests handled by a server every second.

---

## Formula

```
RPS = Total Requests / Seconds
```

---

## Example

```
120,000 requests

in

60 seconds

RPS = 2,000
```

---

## Used In

- Web APIs
- Load Testing
- Capacity Planning
- Performance Benchmarking

---

# QPS (Queries Per Second)

## Definition

QPS measures how many database queries are executed every second.

---

## Example

A request performs

```
SELECT User

SELECT Orders

UPDATE Inventory
```

Total queries

```
3
```

If

```
1000 requests/sec
```

Then

```
QPS = 3000
```

---

## Difference Between RPS and QPS

Example

```
One API Request

â†“

5 Database Queries
```

```
RPS = 100

QPS = 500
```

QPS is usually greater than RPS because one request often executes multiple database queries.

---

# Concurrent Users

## Definition

Concurrent users are the number of users actively interacting with the application at the same time.

---

## Example

A website has

```
100,000 daily users
```

At 8 PM

```
8,000 users

are simultaneously active.
```

Concurrent Users

```
8,000
```

---

## Important

Daily users are not equal to concurrent users.

A website may have

```
5 million users/day

but only

30,000 concurrent users.
```

---

## Why It Matters

Concurrency determines

- Server count
- Database connections
- Memory usage
- Thread pools
- Queue size
- Load balancer capacity

---

# Performance Bottlenecks

## Definition

A bottleneck is the slowest component that limits the overall system performance.

---

## Common Bottlenecks

### CPU Bottleneck

Symptoms

- High CPU utilization
- Slow API processing

Solutions

- Horizontal scaling
- Efficient algorithms
- Async processing

---

### Memory Bottleneck

Symptoms

- Out Of Memory errors
- Frequent Garbage Collection

Solutions

- Increase RAM
- Optimize object allocation
- Caching

---

### Database Bottleneck

Symptoms

- Slow queries
- Connection pool exhaustion

Solutions

- Indexing
- Query optimization
- Read replicas
- Sharding

---

### Disk Bottleneck

Symptoms

- High disk I/O
- Slow writes

Solutions

- SSD
- Caching
- Async writes

---

### Network Bottleneck

Symptoms

- High latency
- Packet loss

Solutions

- CDN
- Compression
- Better routing

---

### Lock Contention

Symptoms

- Threads waiting
- Deadlocks

Solutions

- Reduce locking
- Optimistic concurrency
- Better synchronization

---

### External Service Bottleneck

Symptoms

- Third-party API delays

Solutions

- Retry
- Timeout
- Circuit Breaker
- Caching

---

# Performance Optimization Techniques

| Technique | Benefit |
|-----------|----------|
| Caching | Faster reads |
| CDN | Reduce latency |
| Compression | Reduce bandwidth |
| Database Indexing | Faster queries |
| Read Replica | Scale reads |
| Sharding | Scale writes |
| Load Balancer | Distribute traffic |
| Async Processing | Improve responsiveness |
| Connection Pooling | Reuse DB connections |
| Pagination | Reduce data transfer |

---

# Real-World Example

Suppose Netflix experiences slow video startup.

Engineers investigate:

- High latency between users and servers
- Slow database lookups
- Bandwidth limitations
- High concurrent traffic

Solutions:

- Deploy CDN near users
- Cache video metadata
- Use multiple streaming servers
- Auto-scale compute resources
- Optimize database queries

Result:

- Lower latency
- Higher throughput
- Faster video startup
- Better user experience

---

# Interview Questions

### Basic

- What is latency?
- What is throughput?
- Difference between latency and response time?
- Difference between bandwidth and throughput?
- What is RPS?

---

### Intermediate

- Difference between RPS and QPS?
- Why can QPS be higher than RPS?
- How do concurrent users affect system design?
- How would you improve API performance?

---

### Advanced

- Your API latency increased from 50 ms to 500 ms. How would you debug it?
- How would you identify a performance bottleneck in production?
- Which metrics would you monitor in a distributed system?
- How would you improve throughput without increasing latency?

---

# Cheat Sheet

| Metric | Measures | Unit |
|---------|----------|------|
| Latency | Delay before response | ms |
| Response Time | Total request completion time | ms |
| Throughput | Work completed over time | req/sec |
| Bandwidth | Maximum data transfer capacity | Mbps/Gbps |
| RPS | HTTP requests processed per second | req/sec |
| QPS | Database queries executed per second | queries/sec |
| Concurrent Users | Active users at the same time | Users |
| Bottleneck | Slowest component limiting performance | N/A |

---

# Key Takeaways

- **Latency** measures delay.
- **Response Time** is the total end-to-end time.
- **Throughput** measures how much work a system can handle.
- **Bandwidth** is the network's maximum data transfer capacity.
- **RPS** measures API traffic.
- **QPS** measures database workload.
- **Concurrent Users** determine infrastructure sizing.
- **Performance Bottlenecks** can occur in CPU, memory, database, disk, network, or external services and should be identified and optimized systematically.
