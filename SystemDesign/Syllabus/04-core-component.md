> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Syllabus Chapter
> Docs Index: [README.md](../../README.md)

# Core Components

This chapter introduces the building blocks commonly used in large-scale distributed systems.

## 1. Core Components

## 1. Core Components## Load Balancer
A Load Balancer acts as a reverse proxy and traffic cop sitting in front of your servers. It routes incoming client requests across all backend servers capable of fulfilling those requests in a manner that maximizes speed and capacity utilization while ensuring that no single server is overworked.
------------------------------
## Fundamentals
At its core, a load balancer solves availability, scalability, and reliability challenges by eliminating single points of failure. It acts as a single point of entry (Virtual IP) for the client, continuously tracking backend infrastructure health, abstracting server failures, and dynamically redistributing traffic based on predefined routing logic.
------------------------------
## Types
Load balancers operate at different layers of the Open Systems Interconnection (OSI) network model, determining how deeply they can inspect network packets to make routing decisions.

* Layer 4 (L4) Load Balancer
* Mechanism: Operates at the Transport layer managing raw TCP and UDP protocols. It makes routing decisions strictly using packet header data: Source IP, Source Port, Destination IP, and Destination Port.
   * Pros: Extremely fast, highly efficient, uses low memory/CPU resources because it never opens or reads the message contents (payload).
   * Cons: Lacks intelligence. It cannot route based on URLs, cookies, or HTTP methods, and it cannot inspect messages for malicious content.
* Layer 7 (L7) Load Balancer
* Mechanism: Operates at the Application layer handling protocols like HTTP, HTTPS, gRPC, and WebSocket. It acts as a full reverse proxy, opening the network packet to inspect the request payload, headers, cookies, and URI paths.
   * Pros: Highly intelligent. Can route traffic based on URL context (e.g., /api goes to one pool, /static goes to another), perform SSL/TLS termination, evaluate cookies for sticky routing, and run Web Application Firewalls (WAF).
   * Cons: Computationally intensive, higher latency, and demands significantly more CPU and memory due to the overhead of decrypting and parsing payloads.

------------------------------
## Algorithms
Algorithms dictate how traffic is divided among healthy upstream server nodes.

* Round Robin
* Logic: Requests are distributed sequentially down the list of servers in a cyclic order (e.g., Server 1, Server 2, Server 3, then back to Server 1).
   * Best Used For: Predictable environments where all backend servers have identical hardware specifications and all incoming requests take an equal amount of processing power.
* Least Connections
* Logic: Evaluates the current active connection count on every backend node in real-time and directs the next incoming request to the server currently handling the fewest concurrent sessions.
   * Best Used For: Workloads where request processing times vary significantly (e.g., a mix of fast SQL writes and long-running report generation).
* Weighted Round Robin
* Logic: Extends standard Round Robin by assigning a static numeric "weight" to each backend server based on its capacity. A server with a weight of 3 will receive three times as many sequential requests as a server with a weight of 1.
   * Best Used For: Heterogeneous server pools containing a mix of high-spec newer servers and lower-spec older machines.
* IP Hash
* Logic: Takes the client’s source IP address and processes it through a hashing algorithm to generate a unique numeric key. This key binds the client's IP to a specific backend server instance.
   * Best Used For: Basic session persistence where a client must consistently hit the exact same backend server for successive requests without using application-level cookies.

------------------------------
## Features
Modern load balancers offer capabilities that optimize application performance, reliability, and security at scale.

* Health Checks
* Logic: The load balancer continuously tests backend nodes by sending periodic probes (e.g., TCP handshakes or HTTP GET requests to a /healthz endpoint). If a server fails a set number of consecutive checks, it is dynamically pulled out of the active pool. When it passes the checks again, it is seamlessly reintroduced.
* Sticky Sessions (Session Affinity)
* Logic: Binds an end-user’s session to a specific backend server instance for the duration of their visit. This is typically achieved by injecting a unique tracking cookie into the client's browser or reading an existing session ID from the application header.
* SSL/TLS Termination
* Logic: The load balancer hosts your SSL certificates and decrypts incoming HTTPS traffic at the edge before passing clean, unencrypted HTTP traffic to the backend servers over a secure private network. This unburdens backend servers from resource-heavy cryptographic compute operations.

------------------------------
## Patterns
Architecture topologies define how load balancers are deployed for high availability and failover strategies.

* Active-Active
* Design: Two or more load balancers operate simultaneously, actively receiving, processing, and distributing traffic across the backend network. They synchronize state over a heartbeat connection. If one load balancer fails, the surviving instances scale to absorb the full volume of traffic.
* Active-Passive
* Design: A primary ("Active") load balancer handles 100% of the live incoming traffic while a secondary ("Passive") instance sits completely idle in standby mode. A continuous heartbeat connection tracks the primary's health. If the active instance fails, the passive instance immediately claims its Virtual IP address via a mechanism like VRRP (Virtual Router Redundancy Protocol) to assume the live workload.

------------------------------
## 🌐 Deep Dive: Global Server Load Balancing (GSLB)
While standard Layer 4 and Layer 7 load balancers distribute traffic across servers within a single data center, Global Server Load Balancing (GSLB) coordinates traffic distribution across multiple geographically separated data centers or cloud regions worldwide.

                       [ Global User Request ]
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │  GSLB (DNS-Based Routing) │ ◄── Evaluates geolocation, health,
                    └─────────────┬─────────────┘     and latency to choose a region
                                  │
         ┌────────────────────────┴────────────────────────┐
         ▼ (Route to US-East IP)                           ▼ (Route to EU-West IP)
┌─────────────────────────────────┐               ┌─────────────────────────────────┐
│ US-East Data Center             │               │ EU-West Data Center             │
│  [ Local L7 Load Balancer ]      │               │  [ Local L7 Load Balancer ]      │
│         │                       │               │         │                       │
│    ┌────┴────┐                  │               │    ┌────┴────┐                  │
│    ▼         ▼                  │               │    ▼         ▼                  │
│ [Pod A]   [Pod B]               │               │ [Pod A]   [Pod B]               │
└─────────────────────────────────┘               └─────────────────────────────────┘

## How GSLB Operates Under the Hood
GSLB relies heavily on the Domain Name System (DNS) to intercept the initial connection attempt.

   1. The Request: A user in Mumbai types ://company.com into their browser.
   2. The Interception: The DNS query hits the GSLB system, which acts as the authoritative nameserver for that domain.
   3. The Intelligent Decision: Instead of returning a static IP, the GSLB evaluates the request using multiple routing filters:
   * Geolocation: Where is the client? (India)
      * Network Latency: Which data center offers the shortest path? (e.g., Mumbai region vs. Europe region)
      * Data Center Health: Are the local data centers alive? If the Mumbai data center is down, the GSLB detects it via continuous health checking and redirects the user to Europe or Singapore instead.
   4. The Resolution: The GSLB responds to the user's browser with the specific public IP address of the local regional load balancer best suited to handle their traffic. The browser then establishes its direct TCP connection to that target region.

## Key GSLB Routing Strategies

* Geo-Proximity Routing: Directs clients to the absolute closest physical infrastructure to minimize network latency.
* Failover / Disaster Recovery: Seamlessly diverts 100% of global traffic away from a compromised, blacked-out data center to a secondary warm standby region within seconds.
* Weighted Ratio: Splitting global user pools across data centers based on cost, capacity boundaries, or compliance rules (e.g., routing European users exclusively to data centers within EU borders for GDPR enforcement).

Would you like to move on to the next component block in your list (such as API Gateways or Service Meshes), or would you prefer a practical look at configuration examples for Layer 7 routing?


    2. Reverse Proxy
        Fundamentals
        Internal Working
        Features
            Routing
            SSL Termination
            Compression
            URL Rewriting
       
        Patterns
            API Gateway
            Edge Proxy
            Sidecar Proxy

    3. CDN
        Fundamentals
        Internal Working
        Components
            Edge Server
            PoP
            Origin Server
        Cache Strategies
        Cache Invalidation
        Implementations
            Cloudflare
            CloudFront
            Azure CDN
            Fastly
        Patterns
            Edge Caching
            Geo Distribution
            Origin Shield

    4. Caching
        Fundamentals
        Internal Working
        Cache Types
        Eviction Algorithms
            LRU
            LFU
            FIFO
            TTL
        Cache Patterns
            Cache Aside
            Read Through
            Write Through
            Write Back
            Write Around
            Refresh Ahead
        Distributed Cache
        Implementations
            Redis
            Memcached

    5. Message Queue
        Fundamentals
        Internal Working
        Queue vs Pub/Sub
        Delivery Guarantees
        Ordering
        Retry
        Dead Letter Queue
        
        Patterns
            Event-Driven Architecture
            Producer-Consumer
            Fan-Out
            Event Sourcing


    6. Search Engine
        Fundamentals
        Internal Working
        Inverted Index
        Ranking
        Tokenization
        Stemming
        Fuzzy Search
       
        Implementations
            Elasticsearch
            OpenSearch
            Solr
        Patterns
            Full-Text Search
            Autocomplete
            Search Suggestions
        Real-world Examples
            Amazon Search
            Google Search
            LinkedIn Search

    8. Rate Limiter
        Fundamentals
        Algorithms
            Token Bucket
            Leaky Bucket
            Fixed Window
            Sliding Window
        Distributed Rate Limiting
        Implementations
            Redis
            NGINX
            Envoy
            API Gateway
        Patterns
            API Protection
            User Quotas
            DDoS Protection
        Real-world Examples
            Stripe
            GitHub API
        Interview Problems

    9. Scheduler
        Fundamentals
        Internal Working
        Scheduling Types
        Distributed Scheduling
        Retry
        Implementations
            Quartz
            Hangfire
            Kubernetes CronJob
            Airflow
        Patterns
            Batch Processing
            Periodic Jobs
            Delayed Jobs
 
    10. Notification System
        Fundamentals
        Internal Working
        Channels
            Push
            Email
            SMS
            Webhooks
        Retry Strategy
        Implementations
            Firebase FCM
            APNs
            SendGrid
            Twilio
        Patterns
            Fan-Out
            Pub/Sub
            Event-Driven
        Real-world Examples
            WhatsApp
            Instagram
            Gmail
        Interview Problems
