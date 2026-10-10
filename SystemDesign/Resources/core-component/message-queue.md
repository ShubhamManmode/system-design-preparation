Messaging Fundamentals
- [ ] What is messaging in distributed systems?
- [ ] Why do we need message brokers?
- [ ] Synchronous vs. asynchronous communication
- [ ] Request-response vs. event-driven communication
- [ ] Point-to-point vs. publish-subscribe messaging
- [ ] Message broker architecture and components
- [ ] Message lifecycle: creation to consumption
2. Queue
- [ ] What is a message queue?
- [ ] Queue architecture and working mechanism
- [ ] FIFO queues and ordering guarantees
- [ ] Competing consumers and workload distribution
- [ ] Queue depth and backlog management
- [ ] Message visibility timeout and message locking
- [ ] Queue scaling and throughput
- [ ] When to use queues in system design
3. Topic and Publish-Subscribe
- [ ] What is a topic?
- [ ] Queue vs. topic
- [ ] Publish-subscribe architecture
- [ ] Message subscriptions
- [ ] Multiple subscribers and independent delivery
- [ ] Topic filters and subscription rules
- [ ] Fan-out pattern
- [ ] Event broadcasting across microservices
4. Producer
- [ ] Producer responsibilities and architecture
- [ ] Sending messages to a broker
- [ ] Synchronous vs. asynchronous publishing
- [ ] Batching and message throughput
- [ ] Message serialization: JSON, Avro, Protobuf
- [ ] Message IDs and correlation IDs
- [ ] Producer retries and duplicate publishing
- [ ] Publisher confirms and broker acknowledgements
- [ ] Reliable message publishing
5. Consumer
- [ ] Consumer responsibilities and architecture
- [ ] Pull-based vs. push-based consumption
- [ ] Competing consumers
- [ ] Consumer concurrency and parallel processing
- [ ] Consumer scaling and load distribution
- [ ] Long-running message processing
- [ ] Graceful shutdown and in-flight messages
- [ ] Consumer idempotency
- [ ] Consumer lag and processing throughput
6. Consumer Groups
- [ ] What is a consumer group?
- [ ] Consumer group vs. individual consumer
- [ ] Consumer groups in Kafka vs. queue-based brokers
- [ ] Partition assignment and workload distribution
- [ ] Rebalancing and its impact
- [ ] Consumer scaling limits based on partitions
- [ ] Multiple consumer groups reading the same events
- [ ] Independent progress tracking and offsets
7. Acknowledgement and Delivery Semantics
- [ ] What is message acknowledgement?
- [ ] Automatic vs. manual acknowledgement
- [ ] Acknowledgement before vs. after processing
- [ ] Positive acknowledgement and negative acknowledgement
- [ ] Message deletion after acknowledgement
- [ ] At-most-once delivery
- [ ] At-least-once delivery
- [ ] At-most-once vs. at-least-once trade-offs
- [ ] Exactly-once processing: guarantees and limitations
- [ ] Duplicate delivery and idempotent processing
8. Retry Mechanisms
- [ ] Why message processing fails
- [ ] Transient vs. permanent failures
- [ ] Immediate retry vs. delayed retry
- [ ] Fixed delay vs. exponential backoff
- [ ] Exponential backoff with jitter
- [ ] Maximum retry attempts
- [ ] Retry policies and retry storms
- [ ] Retry queues and scheduled delivery
- [ ] Poison messages
- [ ] Idempotency during retries
9. Dead-Letter Queue (DLQ)
- [ ] What is a dead-letter queue?
- [ ] When messages are moved to a DLQ
- [ ] Maximum delivery count and failure handling
- [ ] DLQ vs. retry queue
- [ ] Inspecting and diagnosing dead-letter messages
- [ ] Reprocessing and replaying DLQ messages
- [ ] Safe DLQ redrive strategies
- [ ] Monitoring DLQ depth and alerts
- [ ] Handling poison messages without infinite retries
10. Message Ordering and Delivery Guarantees
- [ ] Global ordering vs. per-entity ordering
- [ ] FIFO processing challenges
- [ ] Partition-based ordering
- [ ] Sessions and message groups
- [ ] Parallel consumers and out-of-order completion
- [ ] Duplicate messages and deduplication
- [ ] Message durability and persistence
- [ ] Broker failure and message recovery
11. Reliability and Consistency Patterns
- [ ] Transactional Outbox Pattern
- [ ] Transactional Inbox Pattern
- [ ] Idempotent Consumer Pattern
- [ ] Saga Pattern with messaging
- [ ] Event-driven architecture
- [ ] Eventual consistency
- [ ] Compensating transactions
- [ ] Event replay and recovery
- [ ] Schema evolution and backward compatibility
12. Performance and Scalability
- [ ] Throughput vs. latency
- [ ] Batching and message size optimization
- [ ] Backpressure and flow control
- [ ] Consumer lag and backlog recovery
- [ ] Horizontal scaling of producers and consumers
- [ ] Partitioning and sharding
- [ ] Hot partitions and uneven workloads
- [ ] Rate limiting and throttling
- [ ] Load spikes and traffic buffering
- [ ] Capacity planning and broker sizing
13. Reliability, Security and Operations
- [ ] Durable vs. non-durable messaging
- [ ] High availability and broker clustering
- [ ] Replication and disaster recovery
- [ ] Message expiration and TTL
- [ ] Queue and subscription quotas
- [ ] Authentication and authorization
- [ ] Encryption in transit and at rest
- [ ] Metrics, logging and distributed tracing
- [ ] Monitoring queue depth, latency and failures
- [ ] Alerting and operational troubleshooting
14. Messaging Technologies
- [ ] RabbitMQ architecture and routing
- [ ] Apache Kafka architecture
- [ ] Azure Service Bus: queues, topics and subscriptions
- [ ] Azure Event Hubs vs. Azure Service Bus
- [ ] Amazon SQS and SNS
- [ ] Apache Kafka vs. RabbitMQ vs. Azure Service Bus
- [ ] Choosing a messaging technology for a given workload
