> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Resource Notes
> Docs Index: [README.md](../../../README.md)

# Reverse Proxy

## 1. Fundamentals & Internal Working

### Core Concept
A **Reverse Proxy** is an intermediary gateway sitting in front of one or more backend servers. It receives external client requests and forwards them to private upstream servers.

* **Forward Proxy:** Shields the **client** (hides client identity from the internet).
* **Reverse Proxy:** Shields the **server** (hides internal network topology from public clients).

### Internal Architecture & Event Loops
Modern enterprise reverse proxies (such as **NGINX** or **Envoy**) do **not** use traditional thread-per-connection OS models. Instead, they leverage an **asynchronous, non-blocking, event-driven architecture** powered by OS kernel primitives like `epoll` (Linux) or `kqueue` (BSD/macOS).

1. **Master/Worker Model:** A master process manages worker processes (typically tied 1:1 with CPU cores).
2. **Event Notification Loop:** A single worker handles thousands of concurrent socket connections without OS thread-switching overhead.
3. **Non-Blocking Upstream I/O:** Workers read incoming client headers, match routing rules, and stream chunks asynchronously to upstream servers via internal socket pools.

---

## 2. Key Features

### ðŸš¦ Advanced Routing
Directs incoming traffic dynamically based on Layer 7 HTTP metadata:
* **Path-Based Routing:**  
  * `/api/v1/users` $\rightarrow$ User Microservice
  * `/api/v1/billing` $\rightarrow$ Payment Microservice
* **Host-Based (Virtual Hosting):** Routes based on the HTTP `Host` header (e.g., `app.domain.com` vs. `admin.domain.com`).
* **Header/Cookie Injection:** Routes matching requests (e.g., `Cookie: beta_tester=true`) to internal canary or staging environments.

### ðŸ”’ SSL/TLS Termination & Offloading
* **Mechanism:** Handles the computationally expensive asymmetric TLS handshake with public clients at the edge proxy level.
* **Benefit:** Offloads crypto-processing CPU cycles from application nodes. Internal communication within the private VPC can use plain HTTP or lightweight internal mTLS.

### âš¡ Response Compression
* Automatically compresses HTTP response bodies using algorithms like **Gzip** or **Brotli** before sending data over the WAN, lowering network transfer sizes by up to 70%.

### ðŸ”„ URL Rewriting & Header Manipulation
* **URL Sanitization/Stripping:** Modifies URI paths (e.g., converts incoming public `/api/v1/orders/88` to private `/orders/88`).
* **Header Enrichment:** Attaches essential metadata like:
  * `X-Forwarded-For`: Tracks the true origin client IP.
  * `X-Request-ID`: Injects a unique UUID for end-to-end distributed tracing.

### ðŸ’¾ Edge Caching
* Serves static assets (images, JS, CSS) or cacheable REST endpoints directly from RAM/SSD without hitting upstream application servers.
* Leverages HTTP freshness headers (`ETag`, `Cache-Control`, `If-Modified-Since`) to handle cache validation.

---

## 3. Tool Implementation Comparison

| Tool | Core Engine | Primary Use Cases | Key Architectural Strengths |
| :--- | :--- | :--- | :--- |
| **NGINX** | C (Asynchronous Event Loop) | Edge Proxies, Web Servers, Ingress Controllers | Extremely lightweight RAM footprint, proven stability under massive connection spikes. |
| **Envoy** | C++11 (Thread-local event loops) | Cloud-Native Service Mesh Sidecars, Modern API Gateways | Dynamic configuration via gRPC xDS APIs (zero-downtime reloads), rich internal telemetry metrics. |
| **Traefik** | Go (Goroutines / Channels) | Container Ingress Controllers (Docker / Kubernetes) | Native auto-discovery via container labels and Kubernetes CRDs; automated Let's Encrypt TLS renewal. |
| **Apache** | C (Process / Thread Multi-Processing Modules) | Legacy Monoliths, Shared Web Hosting | Flexible per-directory configuration (`.htaccess`), mature ecosystem of dynamic modules. |

---

## 4. Architectural Patterns

### A. API Gateway
An enhanced reverse proxy providing higher-level application functionality:
* Authentication & Authorization validation (JWT/OAuth2 decoding)
* Global rate limiting & request throttling (e.g., Redis Token Bucket)
* Circuit breaking & fallback execution

### B. Edge Proxy
Positions at the perimeter of a region or data center. Handles boundary security including DDoS mitigation, Web Application Firewall (WAF) filtering, and edge CDN acceleration.

### C. Sidecar Proxy (Service Mesh)
Deployed alongside an application container within the same pod/host boundary, sharing the `localhost` network namespace.

[ North-South Public Traffic ]
                 â”‚
                 â–¼
       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
       â”‚    Edge Proxy    â”‚
       â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                â”‚


* **North-South Traffic:** External public user requests entering the infrastructure.
* **East-West Traffic:** Internal service-to-service communication managed transparently by sidecar proxies.

---

## ðŸ’¡ System Design Interview: Tips & Tricks

### ðŸŽ¯ Pro-Tip 1: Eliminating Single Points of Failure (SPOF)
Never place a standalone reverse proxy in a system design diagram without high availability (HA). Always pair reverse proxies behind:
* A Layer 4 Network Load Balancer (AWS NLB), OR
* A Virtual IP setup using **keepalived / VRRP** for active-passive or active-active proxy failover.

### ðŸŽ¯ Pro-Tip 2: Ephemeral Port Exhaustion
When a high-throughput proxy forwards millions of requests to a single backend IP, it can exhaust available outbound TCP ports (maximum ~65,535 ports per destination IP address).
* **Interview Fix:** Explicitly state that you will configure **HTTP Keep-Alive connection pooling** between the proxy and backend servers to reuse open TCP sockets instead of creating a new socket per request.

### ðŸŽ¯ Pro-Tip 3: `X-Forwarded-For` Security & Spoofing
Because any client can send a fake `X-Forwarded-For: 127.0.0.1` header, backend services must **never trust incoming client headers directly**. Mention that backend application tiers must strip or override this header using only values set by the trusted perimeter Edge Proxy.
