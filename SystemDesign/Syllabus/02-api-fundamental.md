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

## 1. Request & Response Body (The Packages)
When a client and a server talk, they send data packages back and forth.

* Request Body: The data the client sends to the server (e.g., a user typing their new username and password into a sign-up form).
* Response Body: The data the server sends back to the client (e.g., a message saying "User created successfully" along with the new user profile details).

------------------------------
## 2. JSON vs. XML (The Languages)
These are the two most common formats used to structure the data inside those request/response bodies.

| Format | What it looks like | The Vibe |
|---|---|---|
| JSON (JavaScript Object Notation) | {"name": "Alex", "age": 28} | The Modern Choice. Lightweight, super easy for humans to read, and fast for computers to parse. The universal standard for web APIs today. |
| XML (eXtensible Markup Language) | <user><name>Alex</name><age>28</age></user> | The Old Guard. Bulky, heavy on syntax, and harder to read. Mostly used in legacy enterprise systems or financial software. |

------------------------------
## 3. Serialization (The Translator)
Code objects in your server's memory (like a Python dict or a Java class) cannot travel across the internet as-is. They need to be converted.

* Serialization: Turning a live code object in your server's memory into a raw string of text (like JSON) so it can travel over the internet.
* Deserialization: The reverse process. Taking that raw text string received from the internet and turning it back into a live code object your program can actually use.

------------------------------
## 4. Validation (The Bouncer)
You should never trust what a user sends to your API. Validation is the process of inspecting the incoming request body before processing it.

* What it catches: If an endpoint expects an email address, validation blocks it if there's no @ symbol. If it expects a product price, it blocks it if the user types "free".
* Why it matters: It stops broken data from entering your database and crashing your application.

------------------------------
## 5. Managing Big Data (Pagination, Filtering, Sorting, Searching)
If your database has 1 million products, you can't return all of them at once when someone hits /products. Your server would crash. You use these four techniques to let clients slice and dice the data:

* Pagination (The Pages): Splitting a huge list into manageable chunks.
* Example: /products?page=2&limit=20 (Give me items 21 through 40).
* Filtering (The Funnel): Narrowing down the list based on specific criteria.
* Example: /products?category=shoes&color=red (Only show me red shoes).
* Sorting (The Lineup): Arranging the order of the results.
* Example: /products?sort=price_asc (Show cheapest items first) or sort=date_desc (newest first).
* Searching (The Scanner): Looking through text fields for a specific keyword.
* Example: /products?q=wireless+headphones (Scan the database for titles matching that phrase).

Want to see what this looks like in practice? Let me know:

* What backend language or framework are you using (like Node.js/Express, Python/FastAPI, etc.)?
* Do you want a quick code example showing how to set up pagination or validation for your specific framework?




## 4. API Versioning

When you build an API, people start using it. But what happens when you need to change how it works—like deleting an old field or changing a resource path? If you just change it instantly, you will break everyone's app.
API Versioning is your way of saying, "Hey, I updated the code, but you can keep using the old version until you are ready to switch."
Here are the 4 main ways to handle it, explained simply.
------------------------------
## 1. URI Versioning (The Clear Path)
You stick the version number directly into the web address (URL). This is the most common approach on the internet.

* What it looks like:
* https://example.com
   * https://example.com
* The Vibe: Completely obvious. Anyone looking at the URL instantly knows which version they are hitting. It makes routing the traffic behind the scenes very easy for developers.

## 2. Header Versioning (The Hidden Agent)
Instead of changing the URL, the URL stays exactly the same. The client passes the version number inside a custom HTTP Header behind the scenes.

* What it looks like:
* URL: https://example.com
   * Header: X-API-Version: 2 (or Accept-Version: 2.0)
* The Vibe: Keeps your URLs completely clean. However, it is a bit harder to test in a regular web browser since you can't just click the link; you have to manually inject headers using code or tools like Postman.

## 3. Query Versioning (The Add-On)
You append the version as a query parameter at the absolute end of the URL using a question mark.

* What it looks like:
* https://example.com
   * https://example.com
* The Vibe: Very easy to implement and test. The downside? Query parameters are usually meant for filtering data (like ?color=blue), so mixing API versions in there can make your URLs look messy over time.

## 4. Content Negotiation / Media Type Versioning (The Fancy Way)
The ultimate "purist" REST approach. You use the standard Accept header (which usually just asks for JSON or XML) to request a highly specific version of the data format.

* What it looks like:
* URL: https://example.com
   * Header: Accept: application/vnd.myapi.v2+json
* The Vibe: Highly professional and flexible, but it can be massive overkill for simple projects. It requires complex routing logic on your server to parse out those specific strings.

------------------------------
## Direct Trade-Off Overview

| Versioning Method | URL Cleanliness | Ease of Testing | Developer Adoption |
|---|---|---|---|
| URI (/v1/) | ❌ Messy | Easiest (Just click it) | Highest (Industry standard) |
| Header | Perfect | ❌ Harder (Needs tools) | Medium |
| Query (?v=2) | ❌ Messy | Easy | Low |
| Content Negotiation | Perfect | ❌ Hardest | Low (Used by enterprise) |

Which style feels best for your current setup? If you want, I can show you a quick code snippet of how to implement URI versioning or Header versioning in your specific backend framework! Let me know what you're using.



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

## 1. HTTPS (Hypertext Transfer Protocol Secure)
HTTPS encrypts all data transmitted between the client's browser and the API server, ensuring complete confidentiality and data integrity over the wire. It layers the standard HTTP protocol on top of TLS (Transport Layer Security).

┌──────────┐      Encrypted TLS Tunnel (HTTPS)      ┌──────────┐
│  Client  │ ═════════════════════════════════════► │  Server  │
└──────────┘  Man-in-the-Middle cannot read data   └──────────┘


* How it Protects: Without HTTPS, any network intermediary (routers, ISPs, malicious attackers on public Wi-Fi) can execute a Man-in-the-Middle (MitM) attack to read or alter raw text payloads, including plain-text authentication tokens, passwords, and sensitive API data.
* API Implementation:
* Enforce TLS 1.2 or TLS 1.3 exclusively; deprecate older SSL/TLS versions.
   * Implement HSTS (HTTP Strict Transport Security) response headers to force browsers to interact with the API only via secure HTTPS connections.
   * Never expose HTTP endpoints; immediately redirect http:// traffic to https://.

------------------------------
## 2. CORS (Cross-Origin Resource Sharing)
CORS is a browser-enforced security mechanism that allows a server to explicitly declare which web origins (domains) are permitted to read its responses. By default, web browsers block frontend scripts (like fetch or Axios) from reading API responses from a different domain due to the Same-Origin Policy (SOP).

* How it Works: When a browser detects a cross-origin request, it transparently sends a Preflight Request using the HTTP OPTIONS method before firing the real request. The server must respond with specific headers authorizing the interaction:
* Access-Control-Allow-Origin: Explicitly lists permitted domains (e.g., https://example.com).
   * Access-Control-Allow-Methods: Lists permitted operations (e.g., GET, POST, DELETE).
* API Security Rule: Never use Access-Control-Allow-Origin: * for authenticated endpoints. Wildcards allow any malicious website running in a user's browser to read sensitive data returned from your API.

------------------------------
## 3. CSRF (Cross-Site Request Forgery)
CSRF forces an authenticated user's browser to execute unauthorized actions on a trusted web application where the user is currently logged in.

* The Exploit: If your API relies strictly on browser Cookies for session authentication, the browser automatically attaches those cookies to every single request sent to that API domain—even if the request was initiated by an invisible form or script running on a completely separate, malicious website.
* API Mitigations:
* Token-Based Authentication: Transition your API to use Authorization: Bearer <JWT> tokens passed via request headers. Browsers do not automatically attach custom headers to cross-origin requests, rendering CSRF impossible.
   * SameSite Cookie Attributes: If cookies are mandatory, configure them with the SameSite=Strict or SameSite=Lax attribute to prevent the browser from appending them to cross-site requests.
   * Anti-CSRF Tokens: Include a cryptographically secure, unpredictable token generated by the server that the frontend must explicitly echo back in an custom header field.

------------------------------
## 4. XSS (Cross-Site Scripting)
XSS occurs when an application inadvertently injects executable malicious code (usually JavaScript) into a trusted webpage, which is then executed within the victim’s browser sandbox.

* The Threat Vector: While XSS is primarily a client-side vulnerability, APIs act as the primary delivery vehicle. If an API accepts unvalidated input (e.g., a comment body containing <script>stealCookies()</script>) and saves it directly to a database, it will serve that exact malicious payload to every other client requesting that resource.
* API Mitigations:
* Context-Aware Output Encoding: Ensure frontend applications treat API data strictly as text properties rather than raw HTML.
   * Content Security Policy (CSP): Configure strong CSP headers on web apps to restrict where scripts can be fetched from and block inline script executions.

------------------------------
## 5. SQL Injection (SQLi)
SQL Injection allows attackers to manipulate database queries by passing malicious SQL fragments through input fields, parameters, or payloads that the database interpreter incorrectly executes as code.

* The Exploit: If an API constructs a database query via string concatenation:

-- ❌ Vulnerable String ConcatenationSELECT * FROM users WHERE email = '` + req.body.email + `';

An attacker can input admin@example.com' OR '1'='1, changing the logic to completely bypass password checks and expose table records.
* API Mitigations:
* Parameterized Queries (Prepared Statements): Always use prepared statements or Object-Relational Mappers (ORMs). Parameters are treated strictly as isolated literal data values, never executable query code.
   * Principle of Least Privilege: Ensure the database user account utilized by your API microservice only possesses permissions essential to its scope, blocking administrative commands like DROP TABLE.

------------------------------
## 6. Input Validation
Input Validation enforces a strict structural perimeter around your API, ensuring that incoming request data matches defined formatting constraints before hitting any internal business logic or storage engines.

* Implementation Strategy: Enforce input verification through both structural layout testing and business logic processing:
* Syntactic Validation (Syntax): Enforce strict JSON/XML structure checks. Reject anomalies using predefined type validation rules (e.g., ensuring age is always a positive integer, or email matches an exact RFC-compliant regular expression).
   * Semantic Validation (Business Meaning): Check if the parameters make logical sense within the system state (e.g., ensuring a transaction delivery_date occurs after the order_date).
* The Gold Standard: Allow-listing (White-listing). Define explicitly what characters, ranges, and formats are acceptable, and discard anything else. Do not use deny-lists (black-listing) to block individual symbols, as clever bypass techniques will inevitably slip through.

------------------------------
## 7. Rate Limiting
Rate Limiting restricts the volume of requests a specific client, IP address, or API token can execute within a designated time window.

Incoming Traffic ──► [ Rate Limiter ] ──► Allowed (200 OK)
                     └──► Exceeded Enforced Limit ──► Throttled (429 Too Many Requests)


* Why it Matters: Protects backend services against Denial of Service (DoS/DDoS) attacks, brute-force authentication cracking attempts, resource-intensive scraping bots, and poorly optimized client code loops.
* API Implementation:
* HTTP 429: When a consumer exceeds their budget, halt execution immediately and return an HTTP 429 Too Many Requests status code.
   * Standard Informational Headers: Pass operational metadata headers with every response to keep clients updated on their budget:
   * X-RateLimit-Limit: Maximum requests permitted per window.
      * X-RateLimit-Remaining: Remaining request allocations left within the active window.
      * Retry-After: The exact duration in seconds the client must wait before making another attempt.
   * Common Algorithms: Leverage highly efficient memory stores like Redis to implement algorithms such as Token Bucket, Leaky Bucket, or Fixed Window Counters to enforce policies globally across distributed microservices.

If you want to look at code implementations, let me know:

* What language/framework (e.g., Node.js/Express, Python/FastAPI, Go, or Java/Spring Boot) are you using?
* Which specific security risk above do you want to see a secure code solution for?

I can provide practical middleware setups or schema configurations to secure your endpoint.


## 8. API Communication

- [REST](https://restfulapi.net/)
- [GraphQL](https://graphql.org/learn/)
- [gRPC](https://grpc.io/docs/what-is-grpc/)
- [WebSockets](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events)
- [Webhooks](https://www.twilio.com/en-us/blog/what-are-webhooks-and-how-do-they-work)

This document is intended as a quick syllabus-style reference for system design interviews and backend API fundamentals.
