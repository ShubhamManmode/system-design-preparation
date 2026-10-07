# System Design — Complete Learning Roadmap

## 0. How to Study System Design

For every topic, learn:

1. What is it?
2. Why do we need it?
3. How does it work?
4. Where is it used?
5. What problem does it solve?
6. What are the alternatives?
7. What are the trade-offs?
8. How does it fail?
9. How does it scale?
10. How would you explain it in an interview?

Use this mental model:

`Purpose → Internals → Bottleneck → Scaling → Failure → Trade-offs`

---

# Part I — Foundations

## Phase 1 — Networking & Operating Systems

### Networking
- Client-server architecture
- Request-response model
- Packet switching
- Latency, throughput, bandwidth
- IPv4, IPv6, public/private IP, CIDR, NAT
- TCP vs UDP
- Three-way handshake
- Four-way termination
- Reliability, flow control, congestion control
- HTTP/1.1, HTTP/2, HTTP/3
- Keep-alive and idempotency
- HTTPS, TLS, certificates
- Symmetric vs asymmetric encryption
- TLS handshake
- DNS resolution, records, TTL and caching
- CDN basics
- Proxy vs reverse proxy
- OSI model
- Checksums

### Operating Systems
- Kernel, user space, kernel space, system calls
- Processes and threads
- Process/thread lifecycle
- Context switching
- Virtual memory and paging
- Stack vs heap
- Memory allocation and leaks
- Garbage collection
- Concurrency vs parallelism
- Race conditions
- Critical sections
- Deadlock, livelock, starvation
- Mutex, semaphore, read-write lock
- Atomic operations and CAS
- IPC: shared memory, pipes, queues, sockets
- Blocking vs non-blocking I/O
- Sync vs async I/O
- I/O multiplexing
- File systems and file descriptors
- CPU-bound vs I/O-bound workloads
- Thread pool
- Producer-consumer
- Reader-writer
- Event loop
- Reactor pattern

**Checkpoint:** Explain what happens from entering a URL until the response reaches the client.

---

# Part II — API and Data Foundations

## Phase 2 — API Fundamentals & API Design

### API fundamentals
- API architecture
- API lifecycle
- API-first design
- API design principles

### REST
- REST constraints
- Resources and representations
- URI design
- HTTP methods
- Safe vs idempotent methods
- HTTP status codes
- Headers

### Request/response
- Request and response bodies
- JSON vs XML
- Serialization/deserialization
- Validation
- Error response design

### Large-result APIs
- Pagination
- Offset pagination
- Cursor pagination
- Filtering
- Sorting
- Searching
- Field selection

### API evolution
- URI versioning
- Header versioning
- Query versioning
- Content negotiation
- Backward compatibility

### Authentication and authorization
- API keys
- Basic authentication
- JWT
- OAuth 2.0
- OpenID Connect
- RBAC
- ABAC
- Scopes
- Claims

### API reliability/security
- Rate limiting
- Idempotency keys
- Timeouts
- Retries
- CORS
- CSRF
- Input validation
- Secure headers

### API styles
- REST
- gRPC
- RPC
- GraphQL
- WebSockets
- Server-Sent Events

**Checkpoint:** Design a production-ready CRUD API with pagination, filtering, authentication, authorization, versioning and rate limiting.

---

## Phase 3 — Database Fundamentals

### Database fundamentals
- DBMS
- RDBMS
- NoSQL
- OLTP vs OLAP
- Database workloads

### Relational databases
- Tables, rows and columns
- Primary keys
- Foreign keys
- Constraints
- Relationships
- One-to-one, one-to-many, many-to-many

### Data modeling
- Normalization
- 1NF, 2NF, 3NF, BCNF
- Denormalization
- Data integrity

### SQL
- SELECT
- INSERT / UPDATE / DELETE
- JOINs
- GROUP BY / HAVING
- Subqueries
- CTEs
- Window functions

### Indexing
- Clustered index
- Non-clustered index
- Composite index
- Covering index
- B-tree
- Hash index
- Selectivity
- Index trade-offs

### Query performance
- Execution plans
- Table scans
- Index seek/scan
- Query optimization
- Statistics
- N+1 query problem

### Transactions
- ACID
- Commit/rollback
- Atomicity
- Consistency
- Isolation
- Durability

### Concurrency
- Read uncommitted
- Read committed
- Repeatable read
- Serializable
- Snapshot/MVCC
- Dirty read
- Non-repeatable read
- Phantom read
- Optimistic vs pessimistic concurrency

### NoSQL
- Key-value
- Document
- Wide-column
- Graph
- CAP theorem
- BASE
- SQL vs NoSQL selection

**Checkpoint:** Given a workload, justify your database choice.

---

# Part III — Core Distributed-System Building Blocks

## Phase 4 — Core Components

### Load balancing
- Why load balancers exist
- L4 vs L7
- Round robin
- Least connections
- Weighted routing
- Health checks
- Session affinity
- Failover

### Reverse proxy
- Forward vs reverse proxy
- TLS termination
- Routing
- Compression
- Caching

### API Gateway
- Routing
- Authentication
- Authorization
- Rate limiting
- Aggregation
- Version routing
- BFF

### CDN
- Edge locations
- Cache hit/miss
- TTL
- Cache invalidation
- Origin server
- Static vs dynamic content

### Caching
- Cache-aside
- Read-through
- Write-through
- Write-back
- TTL
- Eviction policies
- LRU/LFU
- Cache invalidation
- Cache stampede
- Hot keys

### Messaging
- Queue
- Topic
- Producer
- Consumer
- Consumer groups
- Acknowledgement
- Retry
- DLQ

### Search
- Inverted index
- Full-text search
- Search engine vs database

### Object storage
- Buckets
- Objects
- Metadata
- Multipart upload
- Presigned URLs
- Lifecycle policies

**Checkpoint:** Explain why CDN + load balancer + API gateway + cache + database + message queue may coexist in one system.

---

# Part IV — Storage and Scalability

## Phase 5 — Storage Fundamentals

**Source:** `Phase6_StorageFundamentals.md`

- Block, file and object storage
- Persistent vs ephemeral storage
- HDD, SSD, NVMe, RAM
- DAS, NAS, SAN, distributed storage
- Files, blocks, objects, pages, extents, metadata
- File systems, allocation, journaling, permissions
- Sequential vs random access
- IOPS, throughput, latency
- Read/write amplification
- Compression and deduplication
- Backups, snapshots, RAID, checksums
- Hot, warm, cold and archival storage
- Azure Blob, Azure Files, managed disks
- S3/EBS/EFS concepts
- Tiered, immutable and append-only storage
- Dropbox, Drive and media-storage examples

**Checkpoint:** Choose block, file or object storage for a system and justify it.

---

## Phase 6 — Scalability Fundamentals

**Source:** `05-scalability.md`

### Scaling
- Vertical scaling
- Horizontal scaling
- Stateless vs stateful services
- Capacity planning
- Load balancing
- Auto scaling

### Read scaling
- Caching
- Read replicas
- CDN
- Materialized views

### Write scaling
- Partitioning
- Sharding
- Queues
- Batching
- Async processing

### Hotspot management
- Hot keys
- Hot partitions
- Request distribution
- Request coalescing

### Capacity estimation
- Requests/second
- Peak QPS
- Read/write ratio
- Storage
- Bandwidth
- Capacity headroom

**Checkpoint:** Given users, requests/day and payload size, estimate QPS, storage and bandwidth.

---

## Phase 7 — Database Scaling

### Scaling
- Vertical vs horizontal scaling
- Read scaling
- Write scaling

### Replication
- Leader-follower
- Leaderless replication
- Replication lag
- Failover

### Partitioning and sharding
- Horizontal/vertical partitioning
- Partition pruning
- Range sharding
- Hash sharding
- Directory sharding
- Shard-key selection
- Resharding

### Distributed hashing
- Consistent hashing
- Virtual nodes
- Rebalancing

### Consistency
- Strong consistency
- Eventual consistency
- Quorum reads/writes
- Read repair
- Anti-entropy

### Resilience
- Backup/restore
- Geo-replication
- Failover
- Disaster recovery

### Advanced data patterns
- CQRS
- Event sourcing
- Polyglot persistence
- Database per service

**Checkpoint:** Design a database layer for high reads, high writes and millions/billions of records.

---

# Part V — Architecture and Communication

## Phase 8 — Architectural Patterns

Study in this order:

1. Layered / N-tier
2. Monolith
3. Modular monolith
4. Microservices
5. Event-driven architecture
6. SOA
7. Hexagonal / Ports & Adapters
8. Clean Architecture
9. Onion Architecture
10. CQRS
11. Event Sourcing
12. BFF
13. Serverless
14. Space-based architecture
15. Peer-to-peer

For each architecture understand:
- Structure
- Dependency direction
- Scaling model
- Deployment model
- Failure behavior
- Operational complexity
- When to use
- When not to use

### Key interview comparisons
- Monolith vs microservices
- Modular monolith vs microservices
- REST vs event-driven
- CQRS vs CRUD
- Event sourcing vs state storage
- Serverless vs containers

---

## Phase 9 — Microservices

### Fundamentals
- Benefits
- Challenges
- When to use/not use

### Decomposition
- DDD
- Bounded contexts
- Service boundaries
- Single responsibility
- Database per service
- Shared database anti-pattern

### Communication
- REST
- gRPC
- Message queues
- Event streaming
- Request-response
- Pub/sub

### Contracts
- API contracts
- Versioning
- Backward compatibility
- Consumer-driven contracts

### Service discovery
- Client-side discovery
- Server-side discovery
- Registry
- Health checks

### Gateway/BFF
- Routing
- Authentication
- Authorization
- Rate limiting
- Aggregation

### Resilience
- Retry
- Timeout
- Circuit breaker
- Bulkhead
- Fallback
- Idempotency
- DLQ

### Production
- Observability
- Security
- Scaling
- Deployment
- Distributed debugging

**Checkpoint:** Explain how to split a monolith without creating a distributed monolith.

---

## Phase 10 — Communication Patterns

### Models
- Synchronous
- Asynchronous
- Blocking
- Non-blocking

### Request-response
- HTTP
- REST
- RPC
- gRPC

### Messaging
- Fire-and-forget
- Queue
- Work queue
- Competing consumers

### Pub/Sub
- Publisher
- Subscriber
- Topics
- Event bus
- Fan-out
- Filtering

### Event-driven
- Domain events
- Integration events
- Event notification
- Event-carried state transfer
- Event streaming

### Real-time
- WebSockets
- SSE
- HTTP/2 streaming
- gRPC streaming

### Delivery guarantees
- At-most-once
- At-least-once
- Exactly-once

### Reliability
- Retry
- Timeout
- Exponential backoff
- Idempotency
- Ordering
- Duplicate handling
- DLQ
- Backpressure

### Messaging patterns
- Request-reply
- Pub/sub
- Point-to-point
- Fan-out
- Scatter-gather
- Pipes and filters
- Aggregator
- Claim check
- Routing slip

**Checkpoint:** Given a workflow, decide sync vs async and justify the trade-off.

---

# Part VI — Distributed Systems

## Phase 11 — Distributed Transactions & Consistency

- Local vs distributed transactions
- ACID vs BASE
- Why distributed transactions are hard
- Two-phase commit
- Three-phase commit
- Saga
  - Choreography
  - Orchestration
- TCC
- Strong vs eventual consistency
- Atomicity and compensation
- Retry, timeout, idempotency, deduplication
- Message ordering
- Transactional outbox
- Inbox pattern
- CDC
- Event sourcing
- CQRS
- Partial failures
- Rollback vs forward recovery
- DLQ
- Distributed locks
- Leader election

### Real-world exercises
- E-commerce order
- Payment processing
- Banking transfer
- Flight booking
- Inventory reservation

### Critical comparisons
- 2PC vs Saga
- Choreography vs orchestration
- Strong vs eventual consistency
- Outbox vs direct event publishing
- Rollback vs compensation

---

# Part VII — Data-Intensive Systems

## Phase 12 — Big Data & Distributed Processing

### Fundamentals
- Big data
- 5Vs
- Data pipeline architecture

### Ingestion
- Batch ingestion
- Stream ingestion
- CDC
- Log collection
- Data validation

### Processing
- Batch processing
- Stream processing
- Micro-batch
- Lambda architecture
- Kappa architecture

### Distributed processing
- Partitioning
- Data locality
- Parallel processing
- Task scheduling
- Shuffle
- Fault tolerance
- Checkpointing

### Stream processing
- Event time
- Processing time
- Watermarks
- Tumbling window
- Sliding window
- Session window
- Hopping window

### Data platforms
- Data lake
- Data warehouse
- Lakehouse
- OLTP vs OLAP

### Optimization
- Partition pruning
- Predicate pushdown
- Columnar storage
- Compression
- Caching

### Reliability
- At-most-once
- At-least-once
- Exactly-once
- Backpressure
- Checkpointing

### Technologies — learn concepts first
- Kafka
- Spark
- Flink
- Beam
- Databricks
- Synapse
- BigQuery

**Checkpoint:** Design a clickstream, fraud-detection or log-analytics pipeline and explain batch vs streaming.

---

# Part VIII — Production Readiness

## Phase 13 — Deployment Patterns

- Deployment, release and rollback strategies
- Recreate deployment
- Rolling deployment
- Blue-green
- Canary
- A/B deployment
- Shadow deployment
- Feature flags
- Dark launch
- Ring deployment
- Percentage rollout
- Traffic splitting
- Session affinity
- Health checks
- Automatic/manual rollback
- Expand-and-contract database migration
- Backward-compatible schema changes
- Online migration
- Docker
- Kubernetes
- StatefulSet
- DaemonSet
- CI/CD
- GitOps
- Liveness/readiness/startup probes
- Self-healing

**Checkpoint:** Explain a zero/minimal-downtime release and its rollback plan.

---

## Phase 14 — Observability

### Fundamentals
- Monitoring vs observability
- Three pillars

### Logging
- Structured logging
- Log levels
- Centralized logging
- Aggregation
- Correlation IDs

### Metrics
- Counter
- Gauge
- Histogram
- Summary
- Custom metrics

### Tracing
- Trace
- Span
- Context propagation
- Sampling

### Monitoring/alerting
- Infrastructure monitoring
- Application monitoring
- Database monitoring
- Kubernetes monitoring
- Alert rules
- Alert fatigue
- Incident management

### Reliability signals
- Latency
- Throughput
- Error rate
- Resource utilization
- SLI
- SLO
- SLA

### Tools
- OpenTelemetry
- Prometheus
- Grafana
- ELK
- Loki
- Jaeger
- Azure Monitor
- CloudWatch

**Checkpoint:** Given a production incident, explain how logs, metrics and traces lead to root cause.

---

## Phase 15 — Security

### Fundamentals
- CIA triad
- Authentication vs authorization
- Threat modeling
- Security principles

### Identity
- API keys
- JWT
- OAuth 2.0
- OpenID Connect
- SSO
- MFA
- IdP
- Federation
- SAML
- SCIM

### Authorization
- RBAC
- ABAC
- ACL
- Claims
- Least privilege

### Transport
- HTTPS
- TLS
- mTLS
- Certificate management

### Data security
- Encryption at rest
- Encryption in transit
- Hashing
- Salting
- Digital signatures
- Key rotation

### Application/API security
- CORS
- CSRF
- XSS
- SQL injection
- Input validation
- Output encoding
- Rate limiting

### Infrastructure/cloud
- Secrets management
- Key Vault/KMS
- Managed identity
- Firewall
- WAF
- DDoS protection
- Zero Trust
- Network policies
- Cloud IAM

### Container/Kubernetes security
- Image scanning
- Pod security
- Kubernetes RBAC
- Secrets

### Principles
- Defense in depth
- Least privilege
- Zero trust
- Secure by default

**Checkpoint:** Add authentication, authorization, encryption, secrets management and threat controls to any HLD.

---

# Part IX — Interview Design Skills

## Phase 16 — High-Level Design (HLD)

**Source:** `Phase16_HLD.md`

This phase combines everything learned so far.

### Standard HLD interview process

1. Clarify requirements
2. Define functional requirements
3. Define non-functional requirements
4. Estimate scale
5. Define APIs
6. Design data model
7. Select database
8. Draw high-level architecture
9. Explain data/request flow
10. Identify bottlenecks
11. Scale bottlenecks
12. Add reliability
13. Add security
14. Add observability
15. Discuss failures
16. Explain trade-offs
17. Handle follow-up questions

### Architecture templates
- Read-heavy
- Write-heavy
- Event-driven
- Real-time
- Batch
- Search
- Streaming

### Common building blocks
- DNS
- CDN
- Load balancer
- API gateway
- Reverse proxy
- Cache
- Queue
- Database
- Object storage
- Search engine
- Distributed cache

### Scalability
- Horizontal scaling
- Replication
- Sharding
- Partitioning
- Read replicas
- Auto scaling

### Reliability
- High availability
- Failover
- Circuit breaker
- Retry
- Timeout
- Idempotency
- Disaster recovery
- Graceful degradation

### Security
- Authentication
- Authorization
- Encryption
- Rate limiting
- Secrets management

### Observability
- Logging
- Metrics
- Tracing
- Alerting
- SLI/SLO/SLA

### Case studies — recommended order

#### Level 1: Foundations
1. URL Shortener
2. Pastebin
3. Rate Limiter
4. API Gateway

#### Level 2: Storage and caching
5. Distributed Cache
6. File Storage
7. Dropbox / Google Drive

#### Level 3: Messaging and real-time
8. Notification System
9. Chat System
10. WhatsApp / Messenger
11. Distributed Queue

#### Level 4: Social
12. News Feed
13. Twitter/X Timeline
14. Instagram

#### Level 5: Media
15. Video Streaming
16. YouTube
17. Netflix
18. Music Streaming / Spotify

#### Level 6: Transaction-heavy
19. E-commerce
20. Payment System
21. Banking System
22. Ticket Booking
23. Hotel Booking
24. Food Delivery
25. Ride Sharing

#### Level 7: Data-intensive
26. Search Engine
27. Web Crawler
28. Recommendation System
29. Advertisement System
30. Logging System
31. Metrics System
32. Kafka-like Messaging System
33. CDN
34. Distributed Scheduler
35. Kubernetes Control Plane overview

### Core trade-offs
- SQL vs NoSQL
- Cache vs database
- Sync vs async
- Strong vs eventual consistency
- Monolith vs microservices
- REST vs gRPC
- Queue vs stream
- Batch vs stream
- Availability vs consistency
- Latency vs throughput
- Cost vs reliability

**HLD mastery checkpoint:** Design an unfamiliar system by deriving the architecture from requirements rather than memorizing diagrams.

---

# Part X — Object-Oriented & Low-Level Design

## Phase 17 — Low-Level Design (LLD)

**Source:** `Phase17_LLD.md`

### Fundamentals
- HLD vs LLD
- OOP
- UML
- Design principles

### OOP
- Class/object
- Encapsulation
- Abstraction
- Inheritance
- Polymorphism
- Composition
- Association
- Aggregation

### SOLID
- SRP
- OCP
- LSP
- ISP
- DIP

### General principles
- DRY
- KISS
- YAGNI
- Separation of concerns
- High cohesion
- Low coupling
- Law of Demeter
- Tell Don't Ask
- Dependency Injection
- IoC

### UML
- Class
- Sequence
- Activity
- State
- Component
- Deployment diagrams

### Design patterns

**Creational**
- Singleton
- Factory Method
- Abstract Factory
- Builder
- Prototype

**Structural**
- Adapter
- Bridge
- Composite
- Decorator
- Facade
- Flyweight
- Proxy

**Behavioral**
- Chain of Responsibility
- Command
- Iterator
- Mediator
- Observer
- State
- Strategy
- Template Method
- Visitor
- Memento

### Concurrency
- Thread safety
- Immutability
- Locking
- Synchronization
- Producer-consumer
- Thread pools
- Concurrent collections

### Application/enterprise patterns
- DTO
- Entity
- Value Object
- Repository
- Service layer
- Controller layer
- Validation
- Exception handling
- Unit of Work
- Specification
- CQRS
- Domain events
- Dependency Injection

### DDD
- Entity
- Value Object
- Aggregate
- Aggregate Root
- Domain Service
- Application Service
- Repository
- Factory
- Bounded Context

### Exercises — recommended order
1. Vending Machine
2. Parking Lot
3. Library Management
4. ATM
5. Elevator
6. Hotel Management
7. Car Rental
8. Inventory Management
9. BookMyShow
10. Splitwise
11. Food Delivery
12. Ride Sharing
13. Chess
14. Cricbuzz

### LLD interview flow
1. Clarify requirements
2. Identify actors
3. Identify entities
4. Define relationships
5. Define responsibilities
6. Apply SOLID
7. Select patterns only where useful
8. Design interfaces
9. Handle concurrency
10. Discuss extensibility
11. Explain trade-offs

**LLD mastery checkpoint:** Extend the design when a new requirement is introduced without rewriting the entire model.

---

# Part XI — Integrated Practice

## Phase 18 — Full System Design Practice

For every case study, explicitly cover:

### Requirements
- Functional requirements
- Non-functional requirements
- Assumptions

### Capacity
- DAU/MAU
- QPS
- Peak QPS
- Read/write ratio
- Storage
- Bandwidth

### API
- Endpoints
- Request/response
- Authentication
- Idempotency
- Pagination

### Data
- Schema
- SQL/NoSQL choice
- Indexes
- Partition key
- Replication

### Architecture
- Client
- DNS/CDN
- Load balancer
- Gateway
- Services
- Cache
- Queue
- Database
- Object storage
- Search

### Scale
- Horizontal scaling
- Caching
- Replication
- Sharding
- Async processing
- Auto scaling

### Reliability
- Retry
- Timeout
- Circuit breaker
- Idempotency
- DLQ
- Failover
- Disaster recovery

### Security
- Authentication
- Authorization
- Encryption
- Secrets
- Rate limiting
- Threat model

### Observability
- Logs
- Metrics
- Traces
- Alerts
- SLI/SLO

### Trade-offs
Always answer:

> **Why this approach instead of the alternative?**

---

# Recommended Learning Order at a Glance

```text
1.  Networking + OS
        ↓
2.  API Fundamentals
        ↓
3.  Database Fundamentals
        ↓
4.  Core Components
        ↓
5.  Storage Fundamentals
        ↓
6.  Scalability Fundamentals
        ↓
7.  Database Scaling
        ↓
8.  Architectural Patterns
        ↓
9.  Microservices
        ↓
10. Communication Patterns
        ↓
11. Distributed Transactions
        ↓
12. Big Data / Distributed Processing
        ↓
13. Deployment Patterns
        ↓
14. Observability
        ↓
15. Security
        ↓
16. HLD
        ↓
17. LLD
        ↓
18. Integrated Case Studies + Mock Interviews
```

---

# Senior .NET / Product-Based Interview Priority

## Tier 1 — Must Know
- Networking
- HTTP/HTTPS
- REST API design
- SQL and indexing
- Transactions and isolation
- Caching
- Load balancing
- Message queues
- Database replication
- Partitioning/sharding
- Microservices
- REST vs gRPC
- Sync vs async
- Retry/timeout/circuit breaker
- Idempotency
- Saga
- Transactional outbox
- CAP and consistency
- HLD process
- Capacity estimation

## Tier 2 — Strong Senior-Level Knowledge
- Event-driven architecture
- CQRS
- Event sourcing
- Distributed locking
- Consistent hashing
- CDC
- Kafka concepts
- Kubernetes deployment
- Observability
- SLI/SLO/SLA
- Zero-downtime deployment
- Disaster recovery
- Security architecture

## Tier 3 — Advanced / Specialized
- Big data processing
- Lambda vs Kappa
- Stream-processing windows
- Distributed processing internals
- Space-based architecture
- P2P
- Advanced coordination algorithms

---

# Definition of Done

- [ ] Explain latency, throughput and bandwidth.
- [ ] Explain DNS, TCP, HTTP and TLS end-to-end.
- [ ] Design production-grade REST APIs.
- [ ] Choose SQL vs NoSQL using workload requirements.
- [ ] Explain indexes and query performance.
- [ ] Explain ACID and isolation levels.
- [ ] Design caching and handle cache failures.
- [ ] Explain load balancing and horizontal scaling.
- [ ] Design replication and sharding.
- [ ] Explain strong vs eventual consistency.
- [ ] Choose synchronous vs asynchronous communication.
- [ ] Design queues and event-driven workflows.
- [ ] Explain retry, timeout, circuit breaker and idempotency.
- [ ] Design Saga and transactional outbox workflows.
- [ ] Explain microservice boundaries.
- [ ] Design zero-downtime deployments.
- [ ] Add observability to a distributed system.
- [ ] Add security to an architecture.
- [ ] Estimate QPS, storage and bandwidth.
- [ ] Design an unfamiliar HLD problem in 35–45 minutes.
- [ ] Design common LLD problems using SOLID and appropriate patterns.
- [ ] Explain trade-offs instead of simply naming technologies.

---

# Final Mental Model

```text
Requirements
    ↓
Scale
    ↓
APIs
    ↓
Data Model
    ↓
Architecture
    ↓
Communication
    ↓
Cache
    ↓
Database Scaling
    ↓
Reliability
    ↓
Security
    ↓
Observability
    ↓
Deployment
    ↓
Trade-offs
    ↓
Failure Scenarios
```

> **Do not memorize architectures. Learn how to derive them from requirements, scale, constraints and trade-offs.**
