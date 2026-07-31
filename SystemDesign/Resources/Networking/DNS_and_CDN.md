# DNS Resolution and CDN Flow

## Overview

When a user enters a website URL (for example, `www.myapp.com`), the browser cannot communicate using the domain name. It first needs to resolve the domain name into an IP address using the **Domain Name System (DNS)**.

Once the IP address is obtained, the browser establishes a network connection and sends the HTTP request.

If a **Content Delivery Network (CDN)** is configured, DNS returns the IP address of the nearest CDN edge server instead of the origin server.

---

# Complete Request Flow

```text
User
   │
   ▼
Browser
   │
   ▼
Browser DNS Cache
   │
   ├── Cache Hit → Return IP
   │
   └── Cache Miss
          │
          ▼
Operating System DNS Cache
          │
          ├── Cache Hit → Return IP
          │
          └── Cache Miss
                 │
                 ▼
Router Cache (Optional)
                 │
                 ├── Cache Hit → Return IP
                 │
                 └── Cache Miss
                        │
                        ▼
Configured Recursive Resolver
(Google DNS / Cloudflare DNS / ISP DNS)
                        │
                        ▼
Resolver Cache
                        │
                        ├── Cache Hit → Return IP
                        │
                        └── Cache Miss
                               │
                               ▼
Root DNS Server
                               │
                               ▼
TLD Name Server (.com)
                               │
                               ▼
Authoritative DNS Server
                               │
                               ▼
Returns IP Address
                               │
                               ▼
Resolver caches response
                               │
                               ▼
Operating System caches response
                               │
                               ▼
Browser caches response
                               │
                               ▼
TCP Connection
                               │
                               ▼
TLS Handshake (HTTPS)
                               │
                               ▼
HTTP Request
```

---

# Step-by-Step Explanation

## Step 1 – User Enters URL

Example:

```
www.myapp.com
```

The browser needs the IP address before it can establish a connection.

---

## Step 2 – Browser Cache

The browser checks whether it already knows the IP address.

If found:

* Return IP immediately.
* No DNS lookup is required.

---

## Step 3 – Operating System Cache

If the browser cache misses, the operating system checks its DNS cache.

If found:

* Return IP.

Otherwise:

* Continue to the next step.

---

## Step 4 – Router Cache (Optional)

Some home and enterprise routers cache DNS responses.

If the router has the record:

* Return IP.

Otherwise:

* Continue.

---

## Step 5 – Recursive DNS Resolver

The operating system sends the request to its configured DNS resolver.

Examples:

* Google DNS (8.8.8.8)
* Cloudflare DNS (1.1.1.1)
* ISP DNS

The resolver first checks its own cache.

---

## Step 6 – Root DNS Server

If the resolver cache misses:

The resolver asks a Root DNS Server.

Example:

```
Where is www.myapp.com?
```

The Root Server does **not** know the IP address.

It replies:

```
Ask the .com TLD Server.
```

---

## Step 7 – TLD Name Server

The resolver asks the `.com` Name Server.

Example:

```
Where is myapp.com?
```

The TLD server returns the authoritative nameservers.

Example:

```
alex.ns.cloudflare.com
mary.ns.cloudflare.com
```

Notice:

The TLD server still does **not** return the website IP.

---

## Step 8 – Authoritative DNS Server

The resolver contacts Cloudflare's authoritative nameserver.

Example:

```
What is the A record for www.myapp.com?
```

Cloudflare looks in its DNS zone.

Example:

```
www.myapp.com

↓

104.21.10.15
```

This is the final source of truth.

---

## Step 9 – Caching

The resolver caches the response based on the TTL.

Then returns it to:

* Operating System
* Browser

Future requests become much faster.

---

## Step 10 – Network Connection

After obtaining the IP address:

```
TCP 3-Way Handshake
        ↓
TLS Handshake
        ↓
HTTP Request
```

The web server can now process the request.

---

# Where CDN Fits

Without a CDN:

```
DNS

↓

Origin Server IP

↓

Browser

↓

Origin Server
```

Every user connects directly to the origin server.

---

With a CDN:

```
DNS

↓

Nearest CDN Edge IP

↓

Browser

↓

CDN Edge
```

The browser connects to the CDN instead of the origin.

---

# CDN Request Flow

```
User
   │
   ▼
Browser
   │
   ▼
Recursive Resolver
   │
   ▼
Root DNS
   │
   ▼
TLD
   │
   ▼
Cloudflare Authoritative DNS
   │
   ▼
Returns IP of Nearest Edge
   │
   ▼
Browser connects to CDN
   │
   ├── Cache Hit
   │       │
   │       ▼
   │   Return Content
   │
   └── Cache Miss
           │
           ▼
      Origin Server
           │
           ▼
      Fetch Content
           │
           ▼
      Store in CDN Cache
           │
           ▼
      Return Content
```

---

# How Does Cloudflare Choose the Nearest Edge?

Cloudflare's authoritative DNS receives the DNS query from the recursive resolver.

Using the resolver's location (and often **EDNS Client Subnet (ECS)** information), Cloudflare estimates the user's region.

Example:

```
User

↓

Pune

↓

Nearest Edge

↓

Mumbai
```

Cloudflare returns the IP address of the Mumbai edge server instead of the origin server.

---

# Recursive Resolver vs Authoritative DNS

| Recursive Resolver                                | Authoritative DNS                             |
| ------------------------------------------------- | --------------------------------------------- |
| Receives DNS requests from clients                | Stores DNS records for the domain             |
| Performs recursive lookup                         | Returns the final DNS record                  |
| Caches responses                                  | Source of truth                               |
| Examples: Google DNS, Cloudflare 1.1.1.1, ISP DNS | Examples: Cloudflare DNS, Route 53, Azure DNS |

---

# Cache Layers

```
Browser Cache
        ↓
Operating System Cache
        ↓
Router Cache
        ↓
Recursive Resolver Cache
```

Each cache reduces lookup time and DNS traffic.

---

# Why Use a CDN?

* Reduces latency by serving users from nearby edge locations.
* Decreases load on the origin server.
* Improves website performance.
* Increases availability.
* Protects against DDoS attacks.
* Scales globally.
* Caches static content close to users.

---

# Interview Questions

### Why doesn't the browser directly contact the Root DNS Server?

The browser always asks its configured recursive resolver. The recursive resolver performs the complete lookup.

---

### How does the recursive resolver know that Cloudflare manages the domain?

The TLD Name Server returns the domain's NS (Name Server) records, which point to Cloudflare's authoritative nameservers.

---

### Does the browser communicate directly with Cloudflare DNS?

No.

The browser communicates only with its configured recursive resolver.

The recursive resolver communicates with the Root, TLD, and Authoritative DNS servers.

---

### Does the CDN replace DNS?

No.

DNS resolves the domain and returns the IP address of the appropriate CDN edge server.

The CDN then serves the content.

---

# Key Takeaways

* DNS converts domain names into IP addresses.
* DNS resolution checks multiple cache layers before querying external DNS servers.
* The recursive resolver performs the lookup on behalf of the client.
* Root and TLD servers provide referrals, not website IP addresses.
* The authoritative DNS server returns the final DNS record.
* DNS completes before any TCP, TLS, or HTTP communication begins.
* When using a CDN, DNS returns the nearest CDN edge IP instead of the origin server.
* The browser connects to the CDN first; the origin server is contacted only on a cache miss.
