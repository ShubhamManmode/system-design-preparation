# Load Balancer

A **Load Balancer (LB)** is a networking component that distributes incoming client requests across multiple backend servers. Its primary goal is to improve **performance**, **availability**, **reliability**, and **scalability** by ensuring that no single server is overwhelmed with traffic.

Instead of clients connecting directly to application servers, every request first reaches the load balancer, which decides which backend server should handle it.

---

# Table of Contents

- Fundamentals
- Types
  - Layer 4 Load Balancer
  - Layer 7 Load Balancer
- Algorithms
  - Round Robin
  - Least Connections
  - Weighted Round Robin
  - IP Hash
- Features
  - Health Checks
  - Sticky Sessions
  - SSL Termination

---

# Fundamentals

## What is a Load Balancer?

A Load Balancer acts as the **entry point** for client requests. It sits between clients and backend servers and distributes incoming traffic according to predefined routing rules or algorithms.

```text
                    Client
                       │
                       ▼
             +------------------+
             |  Load Balancer   |
             +------------------+
               │      │      │
               ▼      ▼      ▼
          +-------+ +-------+ +-------+
          | App 1 | | App 2 | | App 3 |
          +-------+ +-------+ +-------+
```

The client does not know which backend server processes the request. It only communicates with the load balancer.

---

## Why Do We Need a Load Balancer?

Consider an application running on a single server.

```text
        Users
          │
          ▼
    +------------+
    |  Server A  |
    +------------+
```

As traffic increases:

- CPU usage increases.
- Memory usage increases.
- Response time becomes slower.
- The server may eventually crash.
- The application has a **Single Point of Failure (SPOF)**.

Instead of upgrading one powerful server (**Vertical Scaling**), modern applications add multiple servers (**Horizontal Scaling**).

A load balancer distributes requests among all available servers.

```text
                    Users
                      │
                      ▼
             +------------------+
             |  Load Balancer   |
             +------------------+
               │      │      │
               ▼      ▼      ▼
          +-------+ +-------+ +-------+
          | App 1 | | App 2 | | App 3 |
          +-------+ +-------+ +-------+
```

---

## Request Flow

```text
Client
   │
   ▼
Load Balancer
   │
   ├────────► Server 1
   ├────────► Server 2
   └────────► Server 3
```

The flow is simple:

1. Client sends a request.
2. Load Balancer receives the request.
3. It selects an appropriate backend server.
4. The selected server processes the request.
5. The response is returned to the client.

---

## Benefits

### High Availability

If one backend server fails, the load balancer automatically routes traffic to healthy servers.

```text
            Load Balancer
                 │
        ┌────────┴────────┐
        ▼                 ▼
   Server A ❌       Server B ✅
                     Server C ✅
```

Users continue using the application without interruption.

---

### Scalability

As traffic grows, new servers can be added without changing the client application.

Before:

```text
Load Balancer

├── Server 1
└── Server 2
```

After:

```text
Load Balancer

├── Server 1
├── Server 2
├── Server 3
└── Server 4
```

---

### Better Performance

Instead of one server handling every request,

```text
10,000 Requests

↓

Server 1
```

traffic is distributed.

```text
10,000 Requests

↓

Load Balancer

↓

Server 1
Server 2
Server 3
Server 4
```

Each server handles fewer requests, improving response time.

---

### Fault Tolerance

If one server crashes, traffic is automatically redirected to healthy servers.

This ensures minimal downtime.

---

# Types

## Layer 4 Load Balancer

Layer 4 Load Balancers operate at the **Transport Layer** of the OSI model.

They route traffic based on:

- Source IP Address
- Destination IP Address
- TCP Port
- UDP Port

They do **not** inspect HTTP requests.

```text
Client

↓

TCP/UDP Request

↓

Layer 4 Load Balancer

↓

Backend Server
```

### Advantages

- Very fast
- Low latency
- Ideal for TCP and UDP applications
- Lower processing overhead

### Limitations

- Cannot inspect URLs
- Cannot route based on HTTP headers
- Cannot perform content-based routing

---

## Layer 7 Load Balancer

Layer 7 Load Balancers operate at the **Application Layer**.

Unlike Layer 4, they understand HTTP requests.

They can inspect:

- URL
- HTTP Method
- Cookies
- Headers
- Query Parameters

Example:

```text
/api/users

↓

User Service

------------------

/api/orders

↓

Order Service

------------------

/images

↓

Image Server
```

This is called **Content-Based Routing**.

### Advantages

- Intelligent routing
- URL-based routing
- API Gateway functionality
- Header-based routing
- Cookie-based routing

### Limitations

- Slightly slower than Layer 4
- More CPU intensive

---

## Layer 4 vs Layer 7

| Feature | Layer 4 | Layer 7 |
|----------|----------|----------|
| OSI Layer | Transport | Application |
| Protocols | TCP, UDP | HTTP, HTTPS |
| Decision Based On | IP & Port | URL, Header, Cookie |
| Speed | Faster | Slightly Slower |
| Content Awareness | No | Yes |
| Use Case | Database, Gaming, TCP Services | Web Applications, REST APIs |

---

# Algorithms

A Load Balancer uses algorithms to decide which backend server should receive the next request.

---

## Round Robin

The simplest algorithm.

Requests are distributed sequentially.

```text
Request 1 → Server 1

Request 2 → Server 2

Request 3 → Server 3

Request 4 → Server 1

Request 5 → Server 2
```

### Best For

- Identical servers
- Equal workloads

### Advantages

- Very simple
- Easy to implement
- Fair distribution

### Limitations

- Doesn't consider server load.

---

## Least Connections

The next request is sent to the server with the fewest active connections.

Example:

```text
Server 1 : 50 Connections

Server 2 : 12 Connections

Server 3 : 35 Connections
```

Next request →

```text
Server 2
```

### Best For

Applications with long-running requests.

### Advantages

- Better load distribution
- Handles uneven workloads

### Limitations

- Requires continuous connection tracking.

---

## Weighted Round Robin

Not all servers have equal hardware.

Each server is assigned a weight.

```text
Server A Weight = 5

Server B Weight = 2

Server C Weight = 1
```

Traffic becomes

```text
A
A
A
A
A
B
B
C
```

Powerful servers receive more traffic.

### Best For

Servers with different CPU and memory capacities.

---

## IP Hash

The client's IP address is hashed to determine the destination server.

```text
Client IP

↓

Hash Function

↓

Server 2
```

The same client usually reaches the same server.

### Best For

- Session persistence
- Legacy applications

### Limitation

If a server is removed, many clients may be remapped unless consistent hashing is used.

---

# Features

## Health Checks

A load balancer continuously verifies whether backend servers are healthy.

Typical endpoint:

```http
GET /health
```

Healthy response:

```http
HTTP/1.1 200 OK
```

If a server repeatedly returns errors or stops responding, it is removed from the routing pool.

```text
Server 1 ✅

Server 2 ❌

Server 3 ✅
```

Only healthy servers continue receiving requests.

### Types of Health Checks

**Passive Health Checks**

- Detect failures while serving real traffic.
- No separate health-check requests are sent.

**Active Health Checks**

- Periodically send requests to a health endpoint.
- Remove unhealthy servers before users experience failures.

---

## Sticky Sessions

Normally, each request can be routed to any backend server.

```text
Request 1 → Server A

Request 2 → Server B

Request 3 → Server C
```

Some applications store user session data in server memory.

Example:

- Shopping Cart
- Login Session

If the next request reaches another server, the user may lose session information.

Sticky Sessions ensure the same client is consistently routed to the same backend server.

```text
Client A

↓

Load Balancer

↓

Server B

↓

Future Requests

↓

Server B
```

### Advantages

- Easy session management
- Supports legacy applications

### Disadvantages

- Uneven traffic distribution
- Difficult to scale
- Server failure results in session loss

### Modern Approach

Modern applications avoid sticky sessions by storing session data in shared storage such as:

- Redis
- Distributed Cache
- Database

This allows any backend server to process any request.

---

## SSL Termination

Normally, every backend server performs TLS encryption and decryption.

```text
Client

↓

HTTPS

↓

Application Server
```

With SSL Termination, encryption is handled by the load balancer.

```text
Client

↓

HTTPS

↓

Load Balancer

↓

HTTP (or HTTPS)

↓

Application Servers
```

### Advantages

- Reduces CPU usage on backend servers
- Centralized certificate management
- Simplifies certificate renewal
- Improves application performance

### Security Consideration

If traffic between the load balancer and backend servers crosses an untrusted network, backend communication should also use HTTPS.

---

# Summary

- A Load Balancer distributes requests across multiple backend servers.
- It improves availability, scalability, reliability, and performance.
- Layer 4 operates using TCP/UDP and routes using IP addresses and ports.
- Layer 7 understands HTTP and can route using URLs, headers, cookies, and query parameters.
- Common algorithms include Round Robin, Least Connections, Weighted Round Robin, and IP Hash.
- Health checks ensure only healthy servers receive traffic.
- Sticky sessions keep a client connected to the same backend server when required.
- SSL Termination offloads TLS processing from backend servers and centralizes certificate management.