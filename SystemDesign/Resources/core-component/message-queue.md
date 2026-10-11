Phase 1 — Messaging fundamentals
- [ ] 1. What is message-based communication?
- [ ] 2. Synchronous vs asynchronous communication
- [ ] 3. Request-response vs fire-and-forget
- [ ] 4. Tight coupling vs loose coupling
- [ ] 5. Why microservices use message queues
- [ ] 6. Queue vs topic vs event stream
- [ ] 7. Point-to-point vs publish-subscribe
- [ ] 8. Producer, broker, consumer
- [ ] 9. Message envelope, headers, payload, metadata
- [ ] 10. Message ID, correlation ID, causation ID
- [ ] 11. Commands vs events
- [ ] 12. Event notification vs event-carried state transfer
- [ ] 13. Competing consumers and fan-out
- [ ] 14. Queue-based load leveling
- [ ] 15. When not to use a message queue
Phase 2 — Core messaging concepts
- [ ] 16. Queue creation and lifecycle
- [ ] 17. Topic and subscription lifecycle
- [ ] 18. One-to-one message delivery
- [ ] 19. One-to-many message delivery
- [ ] 20. Message routing
- [ ] 21. Routing keys and filters
- [ ] 22. Message selectors and subscription rules
- [ ] 23. Message priority
- [ ] 24. Delayed and scheduled delivery
- [ ] 25. Message expiration and TTL
- [ ] 26. Message size limits
- [ ] 27. Durable vs non-durable messaging
- [ ] 28. Persistent vs transient messages
- [ ] 29. Queue depth and backlog
- [ ] 30. Message lifecycle from publishing to deletion
Phase 3 — Delivery semantics and acknowledgements
This is one of the most important interview sections.
- [ ] 31. Automatic vs manual acknowledgement
- [ ] 32. Producer acknowledgement vs consumer acknowledgement
- [ ] 33. At-most-once delivery
- [ ] 34. At-least-once delivery
- [ ] 35. Effectively-once processing
- [ ] 36. Exactly-once semantics and their limitations
- [ ] 37. Message redelivery
- [ ] 38. Negative acknowledgement (NACK)
- [ ] 39. Reject vs abandon vs defer
- [ ] 40. Peek-lock / visibility timeout
- [ ] 41. Lock duration and lock renewal
- [ ] 42. What happens if a consumer crashes after processing but before acknowledgement?
- [ ] 43. What happens if acknowledgement is lost?
- [ ] 44. Duplicate message scenarios
- [ ] 45. Safe acknowledgement sequencing
- [ ] 46. Delivery count and maximum delivery attempts
- [ ] 47. Poison messages
- [ ] 48. Message settlement and deletion semantics
Phase 4 — Retries, dead-letter queues and error handling
- [ ] 49. Immediate retry vs delayed retry
- [ ] 50. Fixed delay vs exponential backoff
- [ ] 51. Exponential backoff with jitter
- [ ] 52. Transient vs permanent failures
- [ ] 53. Retry storms and retry amplification
- [ ] 54. Dead-letter queue (DLQ) fundamentals
- [ ] 55. Reasons messages enter a DLQ
- [ ] 56. DLQ monitoring and alerting
- [ ] 57. Inspecting and diagnosing dead-letter messages
- [ ] 58. Replaying messages from a DLQ
- [ ] 59. Safe DLQ redrive strategies
- [ ] 60. Avoiding infinite retry loops
- [ ] 61. Poison-message isolation
- [ ] 62. Handling downstream database outages
- [ ] 63. Handling downstream API rate limits
- [ ] 64. Bulkhead and circuit-breaker integration
- [ ] 65. Error classification and retry policies
Phase 5 — Ordering and concurrency
- [ ] 66. FIFO vs best-effort ordering
- [ ] 67. Global ordering vs per-key ordering
- [ ] 68. Why parallel consumers break ordering
- [ ] 69. Message sessions and session IDs
- [ ] 70. Partition-key-based ordering
- [ ] 71. Ordering across multiple queues
- [ ] 72. Ordering with retries and redelivery
- [ ] 73. Concurrent message processing
- [ ] 74. Consumer thread pools
- [ ] 75. Sequential vs parallel processing
- [ ] 76. Per-message locking vs per-entity serialization
- [ ] 77. Race conditions between consumers
- [ ] 78. Duplicate concurrent processing
- [ ] 79. Idempotency keys
- [ ] 80. Inbox / processed-message table pattern
Phase 6 — Consumer groups, partitions and offsets
Especially important when studying Kafka and distributed event streaming.
- [ ] 81. What is a partition?
- [ ] 82. Why partitions enable parallelism
- [ ] 83. Partition key selection
- [ ] 84. Hash-based partition assignment
- [ ] 85. Hot partitions and key skew
- [ ] 86. Consumer groups
- [ ] 87. Consumer group membership
- [ ] 88. Partition assignment and rebalancing
- [ ] 89. What happens when a consumer joins or leaves?
- [ ] 90. Consumer lag
- [ ] 91. Offsets and offset management
- [ ] 92. Automatic vs manual offset commits
- [ ] 93. Offset commit before vs after processing
- [ ] 94. Replay from a previous offset
- [ ] 95. Consumer group scaling limits
- [ ] 96. Rebalancing pauses and duplicate processing
- [ ] 97. Partition count and throughput trade-offs
- [ ] 98. Adding partitions and ordering implications
Phase 7 — Internal architecture of a message broker
- [ ] 99. Broker architecture and responsibilities
- [ ] 100. In-memory queues vs disk-backed queues
- [ ] 101. Append-only logs
- [ ] 102. Sequential disk I/O
- [ ] 103. Message serialization and deserialization
- [ ] 104. Batching and compression
- [ ] 105. Producer buffers
- [ ] 106. Consumer fetch and polling
- [ ] 107. Push-based vs pull-based delivery
- [ ] 108. Long polling
- [ ] 109. Message indexing and metadata
- [ ] 110. Persistence and crash recovery
- [ ] 111. Message retention and cleanup
- [ ] 112. Log compaction vs time-based retention
- [ ] 113. Broker memory management
- [ ] 114. Zero-copy transfer and efficient I/O
- [ ] 115. Broker metadata and leader election
Phase 8 — High availability and replication
- [ ] 116. Single-broker failure
- [ ] 117. Broker clusters
- [ ] 118. Primary/replica and leader/follower models
- [ ] 119. Synchronous vs asynchronous replication
- [ ] 120. Replication factor
- [ ] 121. Quorum and replica acknowledgements
- [ ] 122. Leader election
- [ ] 123. Split-brain scenarios
- [ ] 124. Network partitions
- [ ] 125. Durability vs availability trade-offs
- [ ] 126. Data loss and recovery point objective (RPO)
- [ ] 127. Recovery time objective (RTO)
- [ ] 128. Broker failover
- [ ] 129. Replication lag
- [ ] 130. Disaster recovery across regions
- [ ] 131. Active-passive vs active-active deployments
- [ ] 132. Geo-replication and duplicate events
- [ ] 133. Disaster recovery testing
Phase 9 — Scaling and performance engineering
- [ ] 134. Throughput vs latency
- [ ] 135. Messages per second vs bytes per second
- [ ] 136. Horizontal vs vertical scaling
- [ ] 137. Scaling producers
- [ ] 138. Scaling consumers
- [ ] 139. Scaling broker clusters
- [ ] 140. Batch publishing and batch consumption
- [ ] 141. Compression algorithms and trade-offs
- [ ] 142. Consumer prefetch and in-flight messages
- [ ] 143. Backpressure
- [ ] 144. Load shedding and admission control
- [ ] 145. Queue backlog growth
- [ ] 146. Drain rate and backlog recovery
- [ ] 147. Burst traffic handling
- [ ] 148. Autoscaling based on queue depth and consumer lag
- [ ] 149. Scaling based on oldest-message age
- [ ] 150. Connection pooling and connection limits
- [ ] 151. Quotas and throttling
- [ ] 152. Load testing and capacity planning
- [ ] 153. Cost optimization
Phase 10 — Distributed systems patterns
These topics connect message queues to end-to-end system design.
- [ ] 154. Transactional outbox pattern
- [ ] 155. Change Data Capture (CDC)
- [ ] 156. Inbox pattern
- [ ] 157. Idempotent consumer pattern
- [ ] 158. Saga orchestration
- [ ] 159. Saga choreography
- [ ] 160. Compensating transactions
- [ ] 161. Event-driven architecture
- [ ] 162. Event sourcing
- [ ] 163. CQRS
- [ ] 164. Domain events vs integration events
- [ ] 165. Transactional messaging
- [ ] 166. Database transaction vs message publish dual-write problem
- [ ] 167. Exactly-once business effects
- [ ] 168. Deduplication windows and retention
- [ ] 169. Workflow orchestration vs message choreography
- [ ] 170. Event schema evolution
- [ ] 171. Schema registry and compatibility
- [ ] 172. Event versioning and backward compatibility
- [ ] 173. Distributed tracing and correlation propagation
Phase 11 — Security and operations
- [ ] 174. Authentication and authorization
- [ ] 175. RBAC and least privilege
- [ ] 176. Managed identities and service principals
- [ ] 177. Encryption in transit and at rest
- [ ] 178. Secrets and credential rotation
- [ ] 179. Tenant isolation
- [ ] 180. Message payload privacy and PII
- [ ] 181. Network isolation and private endpoints
- [ ] 182. Producer and consumer audit trails
- [ ] 183. Metrics, logs and distributed traces
- [ ] 184. Queue depth, age, throughput and failure rate
- [ ] 185. Consumer lag and processing latency
- [ ] 186. DLQ alerts and operational runbooks
- [ ] 187. Broker upgrades and schema migrations
- [ ] 188. Disaster recovery drills
Phase 12 — Technology deep dive
Learn the fundamentals first, then understand how each technology implements them.









A. Azure Service Bus
- [ ] Queues vs topics and subscriptions
- [ ] Peek-lock and receive-and-delete modes
- [ ] Complete, abandon, defer and dead-letter
- [ ] Duplicate detection
- [ ] Sessions and FIFO-like per-session ordering
- [ ] Scheduled delivery and TTL
- [ ] Premium messaging, capacity and isolation
- [ ] Throttling, quotas and scaling limits
- [ ] Azure Monitor and diagnostic logs
- [ ] SDK processing with ServiceBusProcessor in .NET












B. Apache Kafka
- [ ] Topics, partitions and replicas
- [ ] Producers, brokers and consumers
- [ ] Consumer groups and offsets
- [ ] Delivery semantics and transactions
- [ ] Retention and log compaction
- [ ] Rebalancing and lag
- [ ] Replication, ISR and leader election
- [ ] Kafka Streams and Connect
- [ ] Idempotent producer and transactional processing












C. RabbitMQ
- [ ] Exchanges and queues
- [ ] Direct, topic, fanout and headers exchanges
- [ ] Bindings and routing keys
- [ ] Publisher confirms and consumer acknowledgements
- [ ] Prefetch and fair dispatch
- [ ] Durable queues and persistent messages
- [ ] Quorum queues and high availability
- [ ] Dead-letter exchanges and retry patterns



Phase 13 — .NET implementation deep dive
- [ ] 189. Azure.Messaging.ServiceBus SDK architecture
- [ ] 190. Registering clients with dependency injection
- [ ] 191. ServiceBusClient lifetime and connection reuse
- [ ] 192. Sending a message using ServiceBusSender
- [ ] 193. Processing messages using ServiceBusProcessor
- [ ] 194. ProcessMessageAsync and ProcessErrorAsync
- [ ] 195. Completing and abandoning messages
- [ ] 196. Handling cancellation tokens and graceful shutdown
- [ ] 197. Configuring concurrency and prefetch
- [ ] 198. Configuring retries and lock renewal
- [ ] 199. Idempotency with SQL unique constraints
- [ ] 200. Transactional outbox with SQL Server
- [ ] 201. Hosted services and background consumers
- [ ] 202. Graceful scaling in AKS and Azure Functions
- [ ] 203. Integration testing with a real broker
- [ ] 204. Unit testing message handlers
- [ ] 205. Fault injection and duplicate-message testing
Phase 14 — System design interview exercises
Practice these from requirements through capacity estimates, architecture, failure handling and trade-offs.
- [ ] 206. Design an email and notification service
- [ ] 207. Design an order processing pipeline
- [ ] 208. Design a payment event processing system
- [ ] 209. Design a log ingestion platform
- [ ] 210. Design a real-time analytics pipeline
- [ ] 211. Design a background job processing platform
- [ ] 212. Design an image/video processing pipeline
- [ ] 213. Design an inventory reservation system
- [ ] 214. Design a reliable webhook delivery service
- [ ] 215. Design a multi-tenant event bus
- [ ] 216. Design a distributed task scheduler
- [ ] 217. Design a cross-region messaging system
Phase 15 — Advanced interview scenarios
- [ ] 218. A consumer processes the same payment event twice. How do you prevent duplicate charges?
- [ ] 219. A queue receives 100,000 messages/second but consumers process only 60,000. What happens?
- [ ] 220. A downstream API is unavailable for 30 minutes. How do you prevent a retry storm?
- [ ] 221. One partition is overloaded while others are idle. How do you fix it?
- [ ] 222. How do you preserve order while processing messages concurrently?
- [ ] 223. How do you safely replay 10 million dead-lettered messages?
- [ ] 224. How do you prevent data loss when the broker crashes?
- [ ] 225. How do you migrate from RabbitMQ to Kafka without losing events?
- [ ] 226. How do you scale consumers automatically without overwhelming SQL Server?
- [ ] 227. How do you handle a database commit succeeding while message acknowledgement fails?
- [ ] 228. How do you guarantee an order event is eventually published after a database commit?
- [ ] 229. How do you estimate broker storage and retention costs?
- [ ] 230. How do you design multi-region messaging with controlled duplication and ordering?

How to study every topic
For each syllabus item, answer these six questions:
1. What is it? Define the concept.
2. Why do we need it? Explain the problem it solves.
3. How does it work internally? Describe the flow and state changes.
4. What can fail? Cover crashes, timeouts, duplicates, and network failures.
5. How does it scale? Discuss partitioning, concurrency, throughput, and bottlenecks.
6. What are the trade-offs? Compare alternatives and explain when you would choose each.
