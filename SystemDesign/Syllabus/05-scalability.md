# Scalability, Availability & Reliability & Consistency

1. Scalability
    What is Scalability?
    Vertical Scaling (Scale Up)
    Horizontal Scaling (Scale Out)
    Stateless vs Stateful
    Elasticity
    Auto Scaling
    Scaling Strategies
        Compute Scaling
        Storage Scaling
        Read Scaling
        Write Scaling

2. Performance
    Latency
    Throughput
    Bandwidth
    Response Time
    RPS
    QPS
    Concurrent Users
    Performance Bottlenecks

3. Capacity Planning
    Traffic Estimation
    Read/Write Ratio
    Storage Estimation
    Bandwidth Estimation
    Peak Traffic Estimation
    Growth Estimation

4. Availability
    Availability
    Availability Percentage
    High Availability (HA)
    SLA
    SLO
    SLI

5. Reliability
    Reliability
    MTBF
    MTTR
    Durability
    Data Integrity

6. Consistency
    What is Consistency?
    Strong Consistency
    Weak Consistency
    Eventual Consistency
    Causal Consistency
    Read-Your-Writes
    Monotonic Reads
    Monotonic Writes
    Session Consistency
    Linearizability
    Sequential Consistency
    Quorum Reads
    Quorum Writes
    Read Repair
    Anti-Entropy

7. Single Point of Failure (SPOF)
    Identifying SPOFs
    Eliminating SPOFs
    Redundancy

8. Fault Tolerance
    Fault Detection
    Fault Isolation
    Fault Recovery
    Graceful Degradation
    Self-Healing

9. Failover
    Active-Active
    Active-Passive
    Automatic Failover
    Manual Failover
    Disaster Recovery

10. Data Distribution
    Partitioning
    Sharding
    Replication
    Read Replicas
    Leader-Follower Replication
    Multi-Leader Replication

11. Consistent Hashing
    Why Consistent Hashing?
    Hash Ring
    Virtual Nodes
    Data Distribution
    Node Addition
    Node Removal
    Rebalancing

12. CAP Theorem
    Consistency
    Availability
    Partition Tolerance
    CP Systems
    AP Systems
    CA Systems (Theoretical)
    Real-world Examples

13. Distributed System Trade-offs
    CAP vs PACELC
    Consistency vs Availability
    Latency vs Consistency
    Performance vs Reliability
    Cost vs Availability
    Scalability vs Complexity

14. Implementation Patterns
    Health Checks
    Heartbeats
    Leader Election
    Retry
    Timeout
    Exponential Backoff
    Idempotency

15. Design Patterns

    15.1 Scalability Patterns
        Stateless Services
        Horizontal Scaling
        Partitioning
        Sharding
        Consistent Hashing
        Read Replicas
        CQRS
        Event-Driven Architecture
        Asynchronous Processing
        Scatter-Gather

    15.2 Availability Patterns
        Active-Active
        Active-Passive
        Failover
        Redundancy
        Health Checks
        Heartbeats
        Leader Election
        Multi-Region Deployment
        Blue-Green Deployment
        Canary Deployment

    15.3 Reliability Patterns
        Retry
        Exponential Backoff
        Circuit Breaker
        Bulkhead
        Timeout
        Fallback
        Dead Letter Queue (DLQ)
        Idempotency
        Request Hedging
        Rate Limiting
        Backpressure

    15.4 Data Consistency Patterns
        Replication
        Quorum Reads/Writes
        Read Repair
        Anti-Entropy
        Saga Pattern
        Transactional Outbox
        Event Sourcing
        Change Data Capture (CDC)

    15.5 Resilience Patterns
        Graceful Degradation
        Load Shedding
        Throttling
        Self-Healing
        Disaster Recovery
        Checkpointing
