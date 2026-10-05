# API Fundamentals

This chapter focuses on API design principles, REST concepts, and communication patterns used in distributed systems.

> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Syllabus Chapter
> Docs Index: [README.md](../../README.md)

## 1. API Fundamentals

- What is an API?
- API Architecture
- API Lifecycle
- API First Design
- API Design Principles

## 2. REST API

### 2.1 REST Principles

Representational State Transfer (REST) is an architectural style designed for distributed hypermedia systems. Originally defined by Roy Fielding in his 2000 doctoral dissertation, a system is considered RESTful when it follows a set of constrained design principles.

- Statelessness: Every request from a client must contain all the information necessary to understand and process the request. The server must not store any session context about the client.
- Client-Server Architecture: Separates the user interface concerns (client) from the data storage concerns (server). This improves user interface portability across multiple platforms and enhances scalability.
- Cacheability: Responses must implicitly or explicitly define themselves as cacheable or non-cacheable. This prevents clients from reusing stale or inappropriate data while heavily reducing server overhead.
- Uniform Interface: This is the core differentiator of REST. It mandates a standardized way to interact with the server regardless of the device type. It relies on four sub-constraints:
  1. Identification of resources (typically via URIs).
  2. Manipulation of resources through representations (for example, JSON or XML payloads).
  3. Self-descriptive messages (each message includes enough information to describe how to process it, such as `Content-Type`).
  4. HATEOAS (Hypermedia As The Engine Of Application State): The client should discover all available actions dynamically through hyperlinks provided in the server responses.
- Layered System: The client cannot ordinarily tell whether it is connected directly to the end server or to an intermediary such as a load balancer, proxy, or CDN.
- Code on Demand (Optional): Servers can temporarily extend or customize client functionality by transferring executable code such as JavaScript scripts.

### 2.2 Resources

In REST, a resource is any abstract or concrete entity that can be named, digitized, and managed by the system. If a piece of information can be targeted by a unique identifier, it is a resource.

- Examples: A user profile, a financial transaction, a physical device telemetry point, a collection of invoices, or a specific image file.
- Representations: A resource is not the database row itself. Instead, it is exposed via a representation. The same resource could be represented as a JSON object, an XML file, or an HTML page depending on the client and media type.

### 2.3 URI Design

A Uniform Resource Identifier (URI) is the unique string of characters used to identify a specific resource on the network. Good URI design requires clean, predictable formatting.

- Rule 1: Use nouns, not verbs. URIs point to things, not actions.
  - Wrong: `https://example.com/createUser`
  - Right: `https://example.com/users`
- Rule 2: Use plural nouns for collections. Keeping collections plural ensures uniform naming conventions across the architecture.
  - Use `/users` instead of `/user`
  - Use `/orders/{id}/items` to represent nested sub-resources.
- Rule 3: Use kebab-case for readability. Separate words in URIs with hyphens (`-`) instead of underscores (`_`) or camelCase.
  - Example: `/user-profiles` not `/userProfiles`
- Rule 4: Use lowercase characters only. URIs are case-sensitive according to RFC 3986. Avoid mixed casing to prevent 404 mapping bugs.

### 2.4 HTTP Methods

HTTP methods specify the exact intent of the request against the targeted resource.

| HTTP Method | Target | Operational Intent | Safe? | Idempotent? |
| --- | --- | --- | --- | --- |
| GET | `/invoices/10` | Retrieves the representation of invoice #10. | Yes | Yes |
| POST | `/invoices` | Creates a new invoice. Server auto-assigns the ID. | No | No |
| PUT | `/invoices/10` | Completely replaces invoice #10 or creates it if absent. | No | Yes |
| PATCH | `/invoices/10` | Modifies only the specific fields provided for invoice #10. | No | No |
| DELETE | `/invoices/10` | Destroys invoice #10 permanently. | No | Yes |

- Safe Methods: Operations that do not modify resource state on the server. A client can call a safe method repeatedly without side effects.
- Idempotent Methods: Operations where making multiple identical requests has the same structural effect on the server as a single request. For example, deleting an item five times still leaves the item deleted after the first request.

### 2.5 HTTP Status Codes

Status codes are standardized 3-digit numerical tokens issued by the server to communicate the exact structural outcome of a client's request.

- 2xx Success (Everything worked as expected)
  - `200 OK`: Request succeeded. Standard response for successful `GET`, `PUT`, or `PATCH`.
  - `201 Created`: Request succeeded and a new resource was built. Standard response for `POST`.
  - `204 No Content`: Request succeeded, but there is no payload to return (common for `DELETE`).
- 3xx Redirection (Further action required)
  - `304 Not Modified`: The resource has not changed since the client last cached it. Saves bandwidth.
- 4xx Client Errors (The client sent something invalid)
  - `400 Bad Request`: Universal error for poorly formatted payload parsing, missing fields, or failed validations.
  - `401 Unauthorized`: The client lacks valid authentication credentials.
  - `403 Forbidden`: The client is authenticated but lacks operational permissions to access this resource.
  - `404 Not Found`: The targeted URI resource path does not exist.
  - `429 Too Many Requests`: The client has exceeded rate limits.
- 5xx Server Errors (The server broke or crashed)
  - `500 Internal Server Error`: A generic error indicating unhandled exceptions or fatal application crashes on the server side.
  - `503 Service Unavailable`: The server is down for maintenance or overwhelmed by traffic spikes.

### 2.6 Headers

HTTP headers are key-value pairs passed in the background of requests and responses to communicate operational metadata, security policies, and payload parameters.

- Request Headers (Sent by Client)
  - `Authorization`: Carries credentials (for example, `Bearer <JWT_TOKEN>`) to authenticate the caller.
  - `Accept`: Informs the server what media format the client can parse (for example, `application/json`).
  - `User-Agent`: Identifies the client software or browser configuration initiating the call.
- Response Headers (Sent by Server)
  - `Content-Type`: Tells the client the media format of the response payload (for example, `application/json; charset=utf-8`).
  - `Cache-Control`: Directives specifying who can cache the response and for how long (for example, `max-age=3600`).
  - `Location`: Used during a `201 Created` or `3xx` redirect to provide the exact URI path of the new resource.

### 2.7 Path Parameters vs Query Parameters

Both parameters dynamically inject variable criteria into an API route, but they serve fundamentally different functions.

```text
Path Parameter (Identifies Resource)
        │
        ▼
https://example.com/resource/{id}?status=active&sort=date_desc
        ▲                ▲
        └──────────────┴──── Query Parameters (Filter / Sort / Paginate)
```

#### Path Parameters

Path parameters are embedded directly into the structural path hierarchy of a URI. They are mandatory structural identifiers used to locate a specific resource or resource context.

- Syntax indicator: `/users/{userId}` or `/invoices/:id`
- Core purpose: Scope down to an exact, distinct entity instance.
- Example: In `/products/electronics/headphones/sony-wh1000xm4`, the model string acts as a path parameter to isolate a specific product SKU.

#### Query Parameters

Query parameters appear at the end of a URI, separated from the path by `?`. Multiple parameters are linked using `&`. They are optional configuration modifiers for filtering, sorting, pagination, or slight variations in representation.

- Syntax indicator: `?key=value&key2=value2`
- Core purpose: Modify the formatting, visibility, or sorting order of a resource collection without changing the core resource route.
- Example: `/orders?status=pending&sort=date_desc&limit=25` filters pending orders, sorts by newest first, and limits results to 25.

### Practical Applications

If you want to apply these concepts practically, here are some useful next steps:

- Map out a complete OpenAPI / Swagger specification template demonstrating these principles.
- Build an architectural code example (such as Express.js, FastAPI, or Spring Boot) showing how path and query parameters are extracted securely.

---

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

---

This document is intended as a quick syllabus-style reference for system design interviews and backend API fundamentals.
