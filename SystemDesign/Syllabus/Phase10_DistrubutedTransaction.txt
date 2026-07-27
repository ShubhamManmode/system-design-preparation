# Distributed Transactions

    1. Fundamentals
        What is a Distributed Transaction?
        Local vs Distributed Transaction
        ACID vs BASE
        Why Distributed Transactions are Hard

    2. Distributed Transaction Models
        Two-Phase Commit (2PC)
        Three-Phase Commit (3PC)
        Saga Pattern
            Choreography
            Orchestration
        Try-Confirm-Cancel (TCC)

    3. Consistency
        Strong Consistency
        Eventual Consistency
        Atomicity
        Isolation
        Compensation

    4. Reliability
        Retry
        Timeout
        Idempotency
        Deduplication
        Message Ordering

    5. Data Synchronization Patterns
        Transactional Outbox
        Inbox Pattern
        Change Data Capture (CDC)
        Event Sourcing
        CQRS

    6. Failure Handling
        Partial Failures
        Compensation Transactions
        Rollback
        Forward Recovery
        Dead Letter Queue (DLQ)

    7. Coordination
        Transaction Coordinator
        Participant Nodes
        Leader Election (Overview)
        Distributed Locks (Overview)

    8. Implementations
        Kafka Transactions
        NServiceBus
        MassTransit
        Dapr Workflow
        Azure Service Bus
        RabbitMQ
        Temporal
        Camunda

    9. Design Patterns
        Saga
        Transactional Outbox
        Inbox
        TCC
        Event Sourcing
        CQRS
        Choreography
        Orchestration

    10. Real-world Examples
        E-commerce Order Processing
        Banking Fund Transfer
        Payment Processing
        Flight Booking
        Inventory Management

    11. Trade-offs
        Consistency vs Availability
        Performance vs Consistency
        Complexity vs Reliability

    12. Interview Problems