 # Distributed Transactions — Explanations

This file expands on the points listed in `Phase10_DistrubutedTransaction.md` with concise explanations and implementation notes.

1. Fundamentals
- What is a Distributed Transaction?
  A distributed transaction is a single logical unit of work that spans multiple networked services or databases. It must ensure the desired outcome across all participants despite failures and network issues.
- Local vs Distributed Transaction
  Local transactions operate within a single database/process and are managed by that system's ACID guarantees. Distributed transactions coordinate multiple autonomous systems and require cross-service protocols for atomicity and consistency.
- ACID vs BASE
  ACID: strong guarantees (Atomicity, Consistency, Isolation, Durability) typical in single-node RDBMS. BASE: trade-offs for availability and partition tolerance — Basically Available, Soft state, Eventual consistency.
- Why Distributed Transactions are Hard
  Challenges include network partitions, partial failures, clock skew, heterogeneous systems, long-running operations, and the cost of coordination which impacts latency and availability.

2. Distributed Transaction Models
- Two-Phase Commit (2PC)
  Coordinator asks participants to prepare, then to commit. Ensures atomic commit but blocks during coordinator failure and requires participants to hold locks.
- Three-Phase Commit (3PC)
  Adds a pre-commit phase to avoid blocking; reduces some failure modes of 2PC but is more complex and still has challenges in asynchronous networks.
- Saga Pattern
  Sequence of local transactions with compensating actions on failure. Suited for long-running business processes where distributed consensus is expensive.
  - Choreography: participants publish/subscribe to events and react autonomously; simple but harder to observe and reason about.
  - Orchestration: a central orchestrator directs participants; easier to manage and observe but introduces a single coordination point.
- Try-Confirm-Cancel (TCC)
  Each participant implements Try (reserve), Confirm (commit), and Cancel (rollback). Provides strong control but requires explicit implementation for each service and can be complex.

3. Consistency
- Strong Consistency
  Immediate visibility of writes to all readers; often requires synchronous coordination (e.g., distributed locking, consensus).
- Eventual Consistency
  Guarantees convergence over time; useful for availability and performance when immediate consistency is not required.
- Atomicity
  All-or-nothing semantics across the logical transaction boundary. In distributed systems achieved via coordination or compensations.
- Isolation
  Degree to which concurrent transactions do not interfere; in distributed systems, isolation levels map to different implementation trade-offs.
- Compensation
  Instead of rollback across services, apply compensating actions to undo previously completed steps (key for Sagas).

4. Reliability
- Retry
  Retry transient failures with exponential backoff and jitter to avoid thundering herds.
- Timeout
  Fail fast for hung operations; design timeouts carefully to balance false positives vs long waits.
- Idempotency
  Ensure repeated operations have the same effect, enabling safe retries — use idempotency keys or dedup IDs.
- Deduplication
  Remove duplicate messages or operations at the consumer side using stable identifiers.
- Message Ordering
  Preserve order where required, or design operations to be order-independent where possible.

5. Data Synchronization Patterns
- Transactional Outbox
  Write events to an outbox table in the same local transaction as the business write, then publish those events reliably to the message broker.
- Inbox Pattern
  Consumers track processed message IDs in an inbox to ensure processing is idempotent and non-duplicative.
- Change Data Capture (CDC)
  Capture database changes (e.g., via binlog) and stream them to downstream services; often used to keep read models or other stores in sync.
- Event Sourcing
  Persist state changes as a sequence of events; rebuilding state by replaying events supports strong auditability and compensation, but increases complexity.
- CQRS
  Separate read and write models: writes produce events/commands; reads are optimized via denormalized projections.

6. Failure Handling
- Partial Failures
  Design for scenarios where some participants succeed and others fail; use compensation or retry strategies.
- Compensation Transactions
  Implement actions that semantically undo a previous step (business-aware rollback).
- Rollback
  Synchronous rollback is possible in local transactions; in distributed flows, rollback often means executing compensating transactions.
- Forward Recovery
  Continue processing and use corrective actions later to reach a consistent state.
- Dead Letter Queue (DLQ)
  Route messages that repeatedly fail processing to a DLQ for manual inspection or special handling.

7. Coordination
- Transaction Coordinator
  Component that drives commit/rollback protocols (e.g., 2PC coordinator or Saga orchestrator).
- Participant Nodes
  Services or databases that make local changes and respond to coordinator commands.
- Leader Election (Overview)
  Mechanisms (Raft, Zookeeper) to elect a leader for coordination tasks; helps with high-availability coordinators.
- Distributed Locks (Overview)
  Use consensus-backed locks (e.g., via ZooKeeper, etcd, Redis with caution) to serialize access where necessary.

8. Implementations
- Kafka Transactions
  Producer-side transactions allow atomic writes to multiple partitions/topics and coordinate consumer offsets for exactly-once semantics.
- NServiceBus / MassTransit
  Higher-level frameworks for building reliable message-driven systems with features for retries and sagas.
- Dapr Workflow
  Portable building blocks for orchestrating distributed workflows across services.
- Azure Service Bus / RabbitMQ
  Message brokers with features for transactions, dead-lettering, and delivery guarantees.
- Temporal / Camunda
  Workflow engines that manage state, retries, and long-running orchestrations with visibility and durability.

9. Design Patterns
- Saga, Transactional Outbox, Inbox, TCC, Event Sourcing, CQRS, Choreography, Orchestration
  Each pattern solves a slice of distributed transaction complexity — choose based on requirements for consistency, latency, operational complexity, and ease of reasoning.

10. Real-world Examples
- E-commerce Order Processing
  Multi-step flows (order, payment, inventory, shipping) often implemented as Sagas with compensations for failures.
- Banking Fund Transfer
  Requires strong correctness; patterns include idempotency, two-phase commit in constrained contexts, or dedicated ledgers with eventual reconciliation.
- Payment Processing
  Integrations with external gateways make compensation and retries essential — often use orchestration for visibility.
- Flight Booking
  Coordinate seat holds, payments, third-party confirmations — classic use-case for distributed coordination.
- Inventory Management
  Keep inventory counts consistent across microservices using events, outbox, and reconcilers.

11. Trade-offs
- Consistency vs Availability
  The CAP theorem trade-offs: sometimes accept eventual consistency to remain available under partitions.
- Performance vs Consistency
  Synchronous coordination increases latency; async patterns improve throughput at the cost of immediate consistency.
- Complexity vs Reliability
  Strong guarantees add complexity; weigh business requirements against operational burden.

12. Interview Problems
- Prepare to explain and compare 2PC vs Saga, design an order-processing flow, reason about idempotency and deduplication strategies, and sketch failure-recovery paths.
