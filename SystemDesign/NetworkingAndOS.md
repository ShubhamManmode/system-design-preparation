Why Networking
Networking is how different machines (clients, servers, databases, caches, external services) talk to each other over the internet or inside a data center. It turns a single-machine program into a distributed system that can serve millions of users.

For system design, you need networking to:

Connect users’ devices (mobile/web clients) to your backend systems.

Connect multiple backend services to each other (microservices, databases, caches, queues).

Scale horizontally by adding more servers and still keep them working together.

In an architecture diagram, networking is the “lines” between boxes:

text
User Device (Client)  --internet-->  API Gateway / Load Balancer  -->  App Servers  -->  DB / Cache
Key decisions that depend on networking basics:

How many layers you add (API gateway, load balancer, service mesh).

How you handle failures and timeouts between services.

How you design APIs (sync vs async, REST vs gRPC, etc.).

Client-Server Architecture
Client-server is the basic model for almost all modern systems. The client is what the user interacts with (browser, mobile app). The server is where the core logic and data live.

Simple view:

text
[Client]  --> sends request -->  [Server]
[Client]  <-- gets response <--  [Server]
Where it fits in system architecture:

Frontend (web/mobile) = client.

Backend services (API servers, microservices) = servers.

Between them: internet, load balancers, gateways, auth, etc.

Why a system designer must know this:

Every system design question (URL shortener, Instagram, WhatsApp, etc.) is basically “how will clients talk to servers?”

It guides where you put logic: UI on client, business logic on server, data in DB.

It affects scaling: add more servers, or move some work to clients.

Typical decisions:

How “thin” or “thick” the client should be (more logic client-side vs server-side).

How to scale servers (horizontal scaling, load balancing).

How to separate responsibilities (API layer vs business logic vs DB layer).

Request-Response Model
The request-response model is the basic communication pattern: client sends a request, server processes it, then sends back a response.

Example (HTTP web request):

Browser sends GET /user/123.

Server reads user 123 from DB.

Server sends JSON or HTML back.

Browser shows it to the user.

Simple diagram:

text
Client:  Request --------------> Server
Client:         <-------------- Response : Server
Where it fits:

Every REST API, HTTP call, gRPC, standard web service uses this model.

It defines how services expose functionality to other services or clients.

Why system designers need it:

To reason about latency: request must travel, be processed, and return.

To handle failures: what if the server doesn’t respond? Retries? Timeouts?

To design APIs: resources, methods, status codes, contracts.

Decisions that depend on this:

Synchronous vs asynchronous calls (await a response vs use queues).

Timeouts, retries, and circuit breakers between services.

API granularity (coarse-grained vs fine-grained endpoints).

Packet Switching
Packet switching is how data actually travels over the network: large messages are broken into small packets, sent independently, and reassembled at the destination.

You don’t need low-level details, but conceptually:

text
Big message (e.g., JSON)
   ↓ split
Packet 1  Packet 2  Packet 3  ...
   ↓ over network
Packets may take different paths
   ↓ reassemble
Original message at destination
Where it fits in system architecture:

Between any two machines: client ↔ server, server ↔ server, server ↔ DB (over network).

It’s why networks are resilient (packets can route around failures) and imperfect (packets can be delayed, dropped, arrive out of order).

Why system designers should know this:

Explains why networks are unreliable and variable in speed.

Helps understand why you need idempotency, retries, and robustness to partial failures.

Justifies using protocols like TCP (reliable stream) vs UDP (fast but best-effort).

Decisions that depend on this:

Whether your service can tolerate packet loss (e.g., streaming video vs financial transactions).

How aggressive your retry and timeout policies should be.

How you design idempotent APIs (safe to retry when some packets were lost).

Latency
Latency is how long it takes for a request to travel from client to server, be processed, and return. Think of it as “delay” or “response time,” usually measured in milliseconds.

High-level view:

text
Total latency ≈
Network travel time (client ↔ server)
+ Server processing time
+ Time in queues / load balancers / other services
Where it fits:

Every user-facing feature: page loads, API calls, search queries.

Internal service-to-service calls: a slow dependency increases overall latency.

Why it matters for system design:

Directly affects user experience (slow responses → bad UX).

Controls how many services you can chain in one request.

Drives decisions like caching, replication, and geographical distribution.

Typical decisions:

Put caches close to users (CDN) and close to services (Redis/memcached).

Use regional data centers to reduce physical distance (network latency).

Break long operations into async workflows (queues, background jobs).

Throughput
Throughput is how many requests your system can handle per unit time (e.g., requests per second). It measures capacity.

Example:

“This API handles 10,000 requests per second” → throughput = 10k RPS.

Where it fits:

Load balancers: how many requests they can distribute.

App servers: how many requests they can handle concurrently.

Databases: how many read/write operations they support.

Why system designers need it:

Interviews often ask: “Can your design handle X million users/day?”

Throughput defines how many servers you need and how to scale.

Helps choose between designs (e.g., heavy computation per request vs pre-computation).

Decisions that depend on throughput:

Horizontal scaling (more instances) vs vertical scaling (bigger machines).

Sharding or partitioning data to spread load.

Rate limiting to protect backend from overload.

Bandwidth
Bandwidth is how much data per second your network can carry (e.g., Mbps, Gbps). Think of it as “pipe size” for data.

Example:

A 100 Mbps link can (roughly) transfer up to 100 megabits per second.

Where it fits:

Between users and your servers (mobile data, home internet).

Between services inside your data center or cloud region.

Between regions (cross-region replication, backup, streaming).

Why it matters in system design:

Affects how fast you can send large responses (images, video, big JSON).

Limits your ability to replicate large datasets in real time.

Influences decisions about compression, batching, and streaming.

Decisions that depend on bandwidth:

Use CDNs to serve heavy static content closer to users.

Compress responses (gzip, Brotli) to reduce data size.

Use streaming APIs (send data in chunks) for large payloads.