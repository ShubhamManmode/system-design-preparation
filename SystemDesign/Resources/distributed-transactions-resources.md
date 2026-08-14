# Distributed Transactions — Resources

Curated links, books, and tools to learn and implement distributed transactions.

Books
- Designing Data-Intensive Applications — Martin Kleppmann

Key articles and patterns
- Saga pattern (microservices.io): https://microservices.io/patterns/data/saga.html
- Transactional Outbox pattern: https://microservices.io/patterns/data/transactional-outbox.html
- Microsoft Azure Architecture — Saga pattern: https://learn.microsoft.com/en-us/azure/architecture/patterns/saga

Tools, frameworks, and docs
- Apache Kafka transactions: https://kafka.apache.org/documentation/#transactions
- Debezium (CDC): https://debezium.io/
- Temporal: https://docs.temporal.io/
- Dapr Workflows: https://docs.dapr.io/
- Camunda: https://camunda.com/
- RabbitMQ: https://www.rabbitmq.com/
- Azure Service Bus: https://learn.microsoft.com/azure/service-bus-messaging/

Implementations and examples
- Example Saga patterns and tutorials: https://microservices.io/
- Kafka exactly-once and transactions examples (search Kafka docs and examples)

Video tutorials
- Distributed Systems lectures (e.g., MIT, Stanford) — search YouTube for "distributed transactions" and "sagas" for classroom-style explanations.

Repos and code samples
- Temporal examples: https://github.com/temporalio/samples-go (also has Java/Python samples)
- Debezium examples: https://github.com/debezium/debezium-examples

Blogs and deep dives
- Martin Kleppmann blog and talks (event sourcing, distributed data)
- Research papers on 2PC/3PC and consensus (Paxos, Raft)

Search tips
- Look for terms: "Saga pattern", "Transactional Outbox", "TCC pattern", "Kafka transactions", "Change Data Capture", "Exactly-once semantics".
