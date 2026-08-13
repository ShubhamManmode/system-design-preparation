# Observability

Observability is the ability to understand the **internal state and behavior of a system by analyzing the data it produces**, primarily logs, metrics, and traces.

It helps answer questions such as:

* Is the system healthy?
* Why is an API slow?
* Which service is failing?
* Which database query is causing latency?
* How many users are affected?
* When did the problem start?
* What changed before the problem occurred?


# 1. Fundamentals

## What is Observability?

Observability tells us **why a system is behaving the way it is**, not just whether it is working.

For example:

```text
User
  |
  v
API Gateway
  |
  v
Order Service
  |
  +----> Payment Service
  |
  +----> Inventory Service
  |
  v
Database
```

Suppose an order API takes 8 seconds.

Monitoring may tell us:

```text
Order API latency = 8 seconds
```

Observability helps us determine:

```text
Order API
   |
   +--> Inventory Service = 100 ms
   |
   +--> Payment Service = 200 ms
   |
   +--> Database Query = 7.5 seconds  <-- Problem
```

### Three questions Observability should answer

1. **What happened?**
2. **Where did it happen?**
3. **Why did it happen?**

---

## Monitoring vs Observability

| Monitoring                      | Observability                                                      |
| ------------------------------- | ------------------------------------------------------------------ |
| Tells you what is happening     | Helps explain why it is happening                                  |
| Usually dashboard/alert focused | Investigation focused                                              |
| Known failure conditions        | Unknown/unexpected problems                                        |
| Uses predefined metrics         | Combines logs, metrics and traces                                  |
| "CPU is 95%"                    | "CPU increased because this service started processing 5x traffic" |

### Simple example

Monitoring:

```text
CPU > 90%
ALERT!
```

Observability:

```text
CPU > 90%
    |
    +--> Traffic increased
    |
    +--> Request rate increased
    |
    +--> Service started creating more threads
    |
    +--> Database connection pool exhausted
```

Monitoring is therefore often considered a **subset/use case of observability**.

---

# Three Pillars of Observability

The traditional three pillars are:

```text
             Observability
                  |
       +----------+----------+
       |          |          |
     Logs      Metrics     Traces
       |          |          |
     Events     Numbers    Requests
```

## 1. Logs

Logs describe **individual events**.

Example:

```text
2026-08-13 10:30:22
OrderId=123
Payment failed
Reason=InsufficientFunds
```

Good for:

* Errors
* Debugging
* Business events
* Security events
* Detailed context

---

## 2. Metrics

Metrics are numerical measurements collected over time.

Example:

```text
http_requests_total = 1,250,000
http_request_duration = 250ms
cpu_usage = 72%
```

Good for:

* Trends
* Dashboards
* Alerting
* Capacity planning
* SLOs

---

## 3. Traces

Traces follow a request across multiple services.

Example:

```text
Trace
 |
 +-- API Gateway        20 ms
 |
 +-- Order Service      50 ms
 |
 +-- Payment Service   300 ms
 |
 +-- Database         1500 ms
```

Good for:

* Distributed systems
* Microservices
* Dependency analysis
* Finding latency bottlenecks

---

# 2. Logging

## Structured Logging

Structured logging stores logs as structured data, usually JSON.

### Unstructured logging

```text
Order 123 payment failed for customer 456
```

Difficult to search reliably.

### Structured logging

```json
{
  "timestamp": "2026-08-13T10:30:00Z",
  "level": "Error",
  "service": "PaymentService",
  "orderId": 123,
  "customerId": 456,
  "errorCode": "PAYMENT_FAILED",
  "message": "Payment failed"
}
```

Now we can search:

```text
service = PaymentService
orderId = 123
level = Error
```

### Advantages

* Easy searching
* Easy filtering
* Machine-readable
* Better correlation
* Better analytics
* Easier integration with log platforms

---

# Log Levels

Common log levels:

```text
Trace
Debug
Information
Warning
Error
Critical
```

## Trace

Very detailed diagnostic information.

Usually disabled in production because it can generate huge volumes.

---

## Debug

Information useful for developers while troubleshooting.

Example:

```text
Fetching customer with ID 123
```

---

## Information

Normal application events.

Example:

```text
Order 123 created successfully
```

---

## Warning

Something unexpected happened but the application can continue.

Example:

```text
Payment retry attempt 2
```

---

## Error

An operation failed.

Example:

```text
Payment processing failed
```

---

## Critical

Severe failure affecting the application/system.

Example:

```text
Database connection unavailable
```

---

# Centralized Logging

In distributed systems, every service may generate logs.

```text
Service A ---> Logs
Service B ---> Logs
Service C ---> Logs
Service D ---> Logs
```

Instead of storing logs only on individual servers, send them to a centralized logging system.

```text
Service A ----\
Service B -----\
Service C ------> Log Collector ---> Central Log Store
Service D -----/
```

Examples of centralized logging technologies:

* Elasticsearch
* OpenSearch
* Splunk
* Azure Monitor / Log Analytics
* AWS CloudWatch
* Grafana Loki

### Why centralized logging?

Without centralized logging:

```text
Server 1 -> SSH
Server 2 -> SSH
Server 3 -> SSH
Server 4 -> SSH
```

Troubleshooting becomes difficult.

With centralized logging:

```text
Search:
traceId = abc123
```

and find logs across services.

---

# Log Aggregation

Log aggregation means collecting logs from multiple sources into a centralized location.

Example:

```text
Application Logs
       |
Container Logs
       |
Kubernetes Logs
       |
Infrastructure Logs
       |
       v
 Log Collector
       |
       v
Centralized Storage
```

Typical pipeline:

```text
Application
    |
    v
Log Agent
    |
    v
Log Collector
    |
    v
Storage
    |
    v
Dashboard/Search
```

---

# Log Correlation

Log correlation means connecting logs belonging to the same request or business operation.

Example:

```text
Request
TraceId = abc123
```

API Gateway:

```text
traceId=abc123
Request received
```

Order Service:

```text
traceId=abc123
Order created
```

Payment Service:

```text
traceId=abc123
Payment failed
```

Now we can search:

```text
traceId = abc123
```

and see the complete request journey.

---

# 3. Metrics

Metrics are numerical measurements collected over time.

Example:

```text
CPU = 75%
Memory = 60%
Requests/sec = 1,500
Error rate = 2%
Latency = 250ms
```

---

# Counter

A counter is a value that **only increases**, except when reset.

Examples:

```text
Total requests
Total errors
Total orders
Total payments
```

Example:

```text
http_requests_total = 1,000

After 10 requests:

http_requests_total = 1,010
```

Counter is useful for calculating rates.

Example:

```text
requests per second
errors per minute
orders per hour
```

---

# Gauge

A gauge represents a value that can increase or decrease.

Examples:

```text
CPU usage
Memory usage
Active users
Queue length
Active connections
```

Example:

```text
Queue length:

100
  |
  80
  |
  50
  |
  75
```

Unlike a counter, a gauge can move in both directions.

---

# Histogram

A histogram measures the **distribution of values**.

Very useful for latency.

Example:

```text
Request latency

0-100ms     -> 500 requests
100-200ms   -> 300 requests
200-500ms   -> 150 requests
500-1000ms  -> 40 requests
>1000ms     -> 10 requests
```

Histograms help answer:

```text
How many requests took more than 500ms?
```

They are commonly used for:

* Request latency
* Response size
* Database query duration
* Processing time

---

# Summary

A summary calculates statistical information such as quantiles over observations.

Example:

```text
P50 = 100ms
P90 = 250ms
P95 = 400ms
P99 = 800ms
```

### Histogram vs Summary

| Histogram                        | Summary                                    |
| -------------------------------- | ------------------------------------------ |
| Uses buckets                     | Calculates quantiles                       |
| Aggregation-friendly             | Quantiles generally calculated client-side |
| Good for distributed aggregation | Can be harder to aggregate                 |
| Common choice for latency        | Useful for specific quantile measurements  |

In modern distributed systems, **histograms are often preferred when you need aggregation across instances**.

---

# Custom Metrics

Custom metrics are application-specific metrics.

Examples:

```text
orders_created_total
payment_failures_total
cart_items_added_total
checkout_duration
inventory_reservation_failures
```

These are different from infrastructure metrics such as:

```text
CPU
Memory
Disk
Network
```

Custom metrics help connect technical behavior with business behavior.

Example:

```text
payment_failure_rate
```

can be more meaningful to the business than simply:

```text
CPU = 70%
```

---

# 4. Distributed Tracing

Distributed tracing tracks a request as it travels through multiple services.

Example:

```text
Client
  |
  v
API Gateway
  |
  v
Order Service
  |
  +------> Inventory Service
  |
  +------> Payment Service
  |
  v
Database
```

A trace provides the complete journey.

---

# Trace

A trace represents the **entire journey of one request**.

Example:

```text
Trace ID = abc123

Request:
POST /orders

Total duration = 850ms
```

The trace contains multiple spans.

---

# Span

A span represents one operation within a trace.

Example:

```text
Trace: abc123

+--------------------------------------+
| Order API                            |
| 0ms --------------------------- 850ms|
|                                      |
| +-- Validate Order       20ms        |
| +-- Inventory Call       100ms       |
| +-- Payment Call         500ms       |
| +-- Database Query       200ms       |
+--------------------------------------+
```

Each span may contain:

* Span ID
* Trace ID
* Parent Span ID
* Start time
* End time
* Duration
* Service name
* Operation name
* Attributes
* Events
* Status

---

# Context Propagation

Context propagation means passing tracing information from one service to another.

Example:

```text
Service A
TraceId = abc123
SpanId  = span001
      |
      | HTTP request
      v
Service B
TraceId = abc123
SpanId  = span002
Parent = span001
```

The trace context travels with the request.

Common propagation mechanism:

```text
HTTP Headers
```

For example, W3C Trace Context uses headers such as:

```text
traceparent
```

This allows different services to connect their spans to the same trace.

---

# Correlation ID

A correlation ID is an identifier used to correlate related operations/logs.

Example:

```text
CorrelationId = request-123
```

Every service logs it:

```text
Gateway       request-123
Order Service request-123
Payment       request-123
Inventory     request-123
```

### Correlation ID vs Trace ID

They are related but not necessarily identical.

```text
Correlation ID
    |
    +--> Application-level request correlation

Trace ID
    |
    +--> Distributed tracing system
```

In modern observability systems, the **Trace ID often provides the primary cross-service correlation mechanism**.

---

# Trace Sampling

Tracing every request can become expensive at high scale.

Suppose:

```text
10 million requests/day
```

Recording every trace can generate significant:

* Storage
* Network
* CPU
* Processing cost

Therefore sampling can be used.

## Head-based sampling

Decision is made at the beginning of the trace.

Example:

```text
Sample 10%

1000 requests
    |
    +--> 100 traces stored
```

---

## Tail-based sampling

The system decides after observing the trace.

This allows us to keep interesting traces.

For example:

```text
Keep:
- Errors
- Slow requests
- High-value transactions

Drop:
- Normal successful requests
```

Tail sampling is useful because a slow/error trace can be retained even if it would not have been selected by random head sampling.

---

# 5. Monitoring

## Infrastructure Monitoring

Monitors infrastructure resources.

Typical metrics:

```text
CPU
Memory
Disk
Network
Load
Processes
Connections
```

Example:

```text
CPU > 90%
Memory > 85%
Disk > 80%
```

Infrastructure monitoring helps identify resource bottlenecks.

---

# Application Monitoring

Application monitoring focuses on application behavior.

Important metrics:

```text
Request rate
Latency
Error rate
Exception count
Throughput
Dependency failures
```

Example:

```text
GET /orders
Requests/sec = 2000
P95 latency = 350ms
Error rate = 1.2%
```

Application Performance Monitoring (APM) platforms often combine:

```text
Metrics
+
Logs
+
Traces
+
Exceptions
```

---

# Database Monitoring

Database monitoring tracks database health and performance.

Important metrics include:

```text
CPU
Memory
Connections
Query latency
Slow queries
Lock waits
Deadlocks
Transactions
IOPS
Storage
Buffer/cache hit ratio
Connection pool usage
```

For SQL databases, monitor:

```text
Long-running queries
Missing indexes
Blocking
Deadlocks
Execution plans
Connection exhaustion
```

Example:

```text
API latency = 3 seconds

Tracing:
Order Service = 3 seconds
Database span = 2.8 seconds

Database monitoring:
Query X = 2.7 seconds
```

Now the bottleneck becomes easier to identify.

---

# Kubernetes Monitoring

For Kubernetes, monitor multiple layers.

```text
Cluster
   |
   +-- Nodes
   |
   +-- Pods
   |
   +-- Containers
   |
   +-- Services
   |
   +-- Deployments
```

Important metrics:

### Node

```text
CPU
Memory
Disk
Network
```

### Pod

```text
CPU
Memory
Restarts
Status
```

### Container

```text
CPU limits
Memory limits
OOMKilled
Restart count
```

### Kubernetes objects

```text
Deployment replicas
Pod availability
Pending pods
Failed pods
CrashLoopBackOff
```

---

# 6. Alerting

Alerting automatically notifies engineers when predefined conditions are met.

Example:

```text
IF error_rate > 5%
FOR 5 minutes

THEN trigger alert
```

---

# Alert Rules

An alert rule generally contains:

```text
Metric
+
Condition
+
Duration
+
Severity
+
Notification
```

Example:

```text
Metric:
API error rate

Condition:
> 5%

Duration:
5 minutes

Severity:
Critical

Action:
Notify on-call engineer
```

### Good alert

```text
Payment failure rate > 10%
for 5 minutes
```

### Bad alert

```text
CPU = 80%
```

A single CPU spike may not indicate an actual incident.

---

# Alert Fatigue

Alert fatigue occurs when engineers receive too many alerts, especially alerts that are not actionable.

Example:

```text
100 alerts/day

90 = harmless
8  = low priority
2  = real incidents
```

Engineers may start ignoring alerts.

### How to reduce alert fatigue

* Alert only on actionable conditions
* Use appropriate thresholds
* Add duration windows
* Use severity levels
* Deduplicate alerts
* Group related alerts
* Use SLO-based alerts
* Automatically resolve recovered alerts

---

# SLO-based Alerts

Instead of alerting on infrastructure symptoms, alert based on service objectives.

Example:

```text
SLO:
99.9% successful requests
```

If the error budget is being consumed too quickly, trigger an alert.

This focuses alerts on **user impact** rather than just infrastructure metrics.

---

# Incident Management

When a serious alert occurs:

```text
Detection
   |
   v
Alert
   |
   v
Triage
   |
   v
Investigation
   |
   v
Mitigation
   |
   v
Recovery
   |
   v
Postmortem
```

Typical incident-management concepts:

* Incident severity
* On-call engineer
* Escalation
* Incident commander
* Communication
* Root cause analysis
* Postmortem
* Corrective actions

---

# 8. Health Monitoring

Health monitoring tells infrastructure/orchestrators whether an application is functioning correctly.

---

# Liveness Probe

Liveness answers:

> "Is the application still alive?"

If liveness fails, Kubernetes may restart the container.

Example:

```text
GET /health/live
```

Response:

```text
200 OK
```

If the application is deadlocked:

```text
Liveness = FAILED
```

Kubernetes can restart it.

### Important

Liveness should usually be lightweight.

Do not make liveness depend on every external service.

Bad:

```text
Liveness
   |
   +--> Database
   +--> Redis
   +--> Payment API
```

If the database is temporarily down, you don't necessarily want Kubernetes restarting every application instance.

---

# Readiness Probe

Readiness answers:

> "Can this application instance receive traffic?"

Example:

```text
GET /health/ready
```

If readiness fails:

```text
Pod remains running
but
traffic is removed from the pod
```

Example:

```text
Load Balancer
      |
      +--> Pod A READY
      |
      +--> Pod B NOT READY
      |
      +--> Pod C READY
```

Traffic goes only to healthy/ready pods.

---

# Liveness vs Readiness

| Liveness                       | Readiness                            |
| ------------------------------ | ------------------------------------ |
| Is application alive?          | Can it serve traffic?                |
| Failure may cause restart      | Failure removes traffic              |
| Detects dead/stuck application | Detects temporary inability to serve |
| Used for recovery              | Used for traffic routing             |

---

# Startup Probe

Startup probe answers:

> "Has the application finished starting?"

Useful for applications with long startup times.

Example:

```text
Application starts
     |
     | 60 seconds
     v
Application ready
```

Without startup protection, liveness may fail during startup and repeatedly restart the application.

Startup probe allows the application sufficient time to initialize.

Typical flow:

```text
Startup Probe
      |
      v
Application started?
      |
      +---- No ---> Keep waiting
      |
      +---- Yes --> Liveness/Readiness take over
```

---

# Heartbeats

A heartbeat is a periodic signal indicating that a service/component is alive.

Example:

```text
Worker
  |
  | heartbeat every 10 sec
  v
Monitoring System
```

If heartbeats stop:

```text
No heartbeat for 30 sec
        |
        v
Worker may be unhealthy
```

Heartbeats are commonly used in:

* Distributed workers
* Background jobs
* Service coordination
* Cluster membership
* Long-running processes

---

# 9. Performance Monitoring

Performance monitoring measures how efficiently a system handles workload.

The major indicators are:

```text
Latency
Throughput
Error Rate
Resource Utilization
```

---

# Latency

Latency is the time required to complete an operation.

Example:

```text
Request sent
     |
     |------ 250ms ------|
     v
Response received
```

Common latency measurements:

```text
Average
P50
P90
P95
P99
P99.9
```

### Why percentiles matter

Suppose:

```text
99 requests = 100ms
1 request  = 10 seconds
```

Average can hide the bad experience.

P99 reveals the slow request.

For user-facing APIs, P95/P99 is often more useful than average latency.

---

# Throughput

Throughput is the amount of work completed per unit of time.

Examples:

```text
Requests/sec
Transactions/sec
Messages/sec
Orders/minute
```

Example:

```text
API handles:

5,000 requests/sec
```

Higher throughput generally means the system can process more workload.

---

# Error Rate

Error rate measures the percentage of requests that fail.

Formula:

```text
Error Rate =
Failed Requests / Total Requests × 100
```

Example:

```text
Total requests = 100,000
Failed requests = 1,000

Error Rate =
1000 / 100000 × 100

= 1%
```

Important error types:

```text
4xx
5xx
Timeouts
Exceptions
Database failures
Dependency failures
```

---

# Resource Utilization

Resource utilization shows how much infrastructure capacity is being consumed.

Examples:

```text
CPU = 75%
Memory = 80%
Disk = 60%
Network = 70%
Database connections = 90%
```

High utilization is not automatically a problem.

For example:

```text
CPU = 90%
Latency = 50ms
Error rate = 0.01%
```

The system may be performing perfectly.

But:

```text
CPU = 90%
Latency = 3 seconds
Error rate = 8%
```

indicates a likely performance problem.

Therefore, **resource utilization should be correlated with application-level metrics**.

---

# Putting Everything Together

A production observability architecture can look like:

```text
                    Users
                      |
                      v
                Load Balancer
                      |
                      v
                API / Services
                      |
          +-----------+-----------+
          |           |           |
          v           v           v
       Database     Redis      Message Queue
          |
          |
          v
   -------------------------
   |   Observability       |
   -------------------------
       |       |       |
       v       v       v
     Logs   Metrics   Traces
       |       |       |
       +-------+-------+
               |
               v
        Observability
           Platform
               |
       +-------+-------+
       |       |       |
       v       v       v
   Dashboard Alerts Investigation
```

---

# Observability Investigation Example

Suppose users report:

```text
Checkout is very slow.
```

## Step 1 — Check metrics

```text
Checkout P95 latency = 5 seconds
```

We know the problem exists.

---

## Step 2 — Check error rate

```text
Error rate = 0.5%
```

Errors are not the main issue.

---

## Step 3 — Check trace

```text
Checkout
   |
   +-- Cart Service       50ms
   +-- Inventory Service  100ms
   +-- Payment Service    200ms
   +-- Database          4.5s  <-- Bottleneck
```

---

## Step 4 — Check database monitoring

```text
Slow query detected
Query duration = 4.3 seconds
```

---

## Step 5 — Check logs

Search:

```text
traceId = abc123
```

Find:

```text
Query timeout warning
Missing index suspected
```

---

## Step 6 — Fix

Potential fixes:

```text
Add appropriate index
Optimize query
Reduce returned data
Improve connection pooling
Cache suitable data
Scale database
```

---

# Observability vs Monitoring — Interview Answer

A strong interview answer:

> **Monitoring tells us whether the system is healthy by tracking predefined signals such as CPU, latency, error rate, and throughput. Observability goes further by helping us understand why the system is behaving in a particular way. It uses logs, metrics, and distributed traces to investigate unknown problems, especially in distributed systems.**

---

# Three Pillars — Interview Answer

```text
Logs   -> What happened?
Metrics -> How much/how often?
Traces -> Where did the request go and where was time spent?
```

Example:

```text
Metric:
API P99 latency = 3 seconds

Trace:
Database call = 2.8 seconds

Logs:
Database timeout/index issue
```

Together they provide a much clearer picture of the incident.

---

# Key Interview Questions

## 1. What is observability?

The ability to understand the internal state of a system from its external outputs, primarily logs, metrics, and traces.

## 2. Monitoring vs observability?

Monitoring tells us **what is wrong** based on known conditions. Observability helps us investigate **why it is wrong**, including unexpected failures.

## 3. What are the three pillars?

```text
Logs
Metrics
Traces
```

## 4. Counter vs Gauge?

```text
Counter -> increases
Gauge   -> increases/decreases
```

## 5. Why use histograms?

To measure distributions such as request latency and calculate useful percentiles.

## 6. What is a trace?

The complete journey of a request across a distributed system.

## 7. What is a span?

One operation within a trace.

## 8. What is context propagation?

Passing tracing context such as Trace ID and Span ID between services.

## 9. Liveness vs readiness?

```text
Liveness  -> Should this application be restarted?
Readiness -> Should this application receive traffic?
```

## 10. Why is P99 latency important?

Because averages can hide slow requests. P99 shows the latency experienced by the slowest 1% of requests.

## 11. What is alert fatigue?

When engineers receive too many alerts, especially non-actionable ones, causing important alerts to be ignored.

## 12. What is centralized logging?

Collecting logs from multiple applications/servers into a central system so they can be searched, correlated, and analyzed.

---

# Golden Mental Model

When debugging a production issue, think:

```text
             INCIDENT
                |
        +-------+-------+
        |       |       |
        v       v       v
     Metrics   Logs   Traces
        |       |       |
        |       |       |
        +-------+-------+
                |
                v
          Find Bottleneck
                |
                v
          Find Root Cause
                |
                v
              Fix
                |
                v
          Verify Metrics
```

The most important mindset is:

```text
Metrics tell you that something is wrong.
Traces tell you where it is wrong.
Logs help explain why it is wrong.
```

And in a production system:

```text
Observability
     |
     +-- Detect
     +-- Investigate
     +-- Diagnose
     +-- Fix
     +-- Verify
     +-- Prevent
```
