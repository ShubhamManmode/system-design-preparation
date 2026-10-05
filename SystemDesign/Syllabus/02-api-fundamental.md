
> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Syllabus Chapter
> Docs Index: [README.md](../../README.md)

# API Fundamentals

This chapter focuses on API design principles, REST concepts, and communication patterns used in distributed systems.

## 1. API Fundamentals

- What is an API?
- API Architecture
- API Lifecycle
- API First Design
- API Design Principles

## 2. REST API

- REST Principles
  > 1. REST Principles
Representational State Transfer (REST) is an architectural style designed for distributed hypermedia systems. Originally defined by Roy Fielding in his 2000 doctoral dissertation, a system is considered truly "RESTful" only if it strictly satisfies six architectural constraints:
• Statelessness: Every request from a client must contain all the information necessary to understand and process the request. The server must not store any session context about the client.
• Client-Server Architecture: Separates the user interface concerns (client) from the data storage concerns (server). This improves user interface portability across multiple platforms and enhances server scalability.
• Cacheability: Responses must implicitly or explicitly define themselves as cacheable or non-cacheable. This prevents clients from reusing stale or inappropriate data while heavily reducing server overhead.
• Uniform Interface: This is the core differentiator of REST. It mandates a standardized way to interact with the server regardless of the device type. It relies on four sub-constraints:
	1. Identification of resources (typically via URIs).
	2. Manipulation of resources through representations (e.g., JSON or XML payloads).
	3. Self-descriptive messages (each message includes enough info to describe how to process it, like Content-Type).
	4. HATEOAS (Hypermedia As The Engine Of Application State): The client should discover all available actions dynamically through hyperlinks provided in the server responses.
• Layered System: The client cannot ordinarily tell whether it is connected directly to the end server or to an intermediary (like a load balancer, proxy, or CDN).
• Code on Demand (Optional): Servers can temporarily extend or customize client functionality by transferring executable code (e.g., JavaScript scripts).
- Resources
- URI Design
- HTTP Methods
- HTTP Status Codes
- Headers
- Query Parameters
- Path Parameters

## 3. Request & Response Design

- Request Body
- Response Body
- JSON
- XML
- Serialization
- Validation
- Pagination
- Filtering
- Sorting
- Searching

## 4. API Versioning

- URI Versioning
- Header Versioning
- Query Versioning
- Content Negotiation

## 5. Authentication

- API Keys
- Basic Authentication
- JWT
- OAuth 2.0
- OpenID Connect

## 6. Authorization

- RBAC
- ABAC
- Scopes
- Claims

## 7. API Security

- HTTPS
- CORS — Cross-Origin Resource Sharing
- CSRF
- XSS
- SQL Injection
- Input Validation
- Rate Limiting

## 8. API Communication

- [REST](https://restfulapi.net/)
- [GraphQL](https://graphql.org/learn/)
- [gRPC](https://grpc.io/docs/what-is-grpc/)
- [WebSockets](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [Webhooks](https://www.twilio.com/en-us/blog/what-are-webhooks-and-how-do-they-work)

## 9. Reliability

- Idempotency
- Retry
- Timeout
- Circuit Breaker
- Correlation ID
- Request Tracing

## 10. Patterns

- Backend for Frontend (BFF)
- API Gateway
- Aggregator
- Facade
- Strangler Fig
- Request-Reply
- Async Request-Response

## 11. Real-world Examples

- GitHub API
- Stripe API
- Google Maps API
- Microsoft Graph API

## 12. Interview Problems
