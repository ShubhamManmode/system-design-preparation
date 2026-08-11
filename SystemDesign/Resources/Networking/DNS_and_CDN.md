> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Resource Notes
> Docs Index: [README.md](README.md)
> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Resource Notes
> Docs Index: [README.md](../../../README.md)

# DNS Resolution and CDN Flow

## Overview

When a user enters a website URL (for example, `www.myapp.com`), the browser cannot communicate using the domain name. It first needs to resolve the domain name into an IP address using the **Domain Name System (DNS)**.

Once the IP address is obtained, the browser establishes a network connection and sends the HTTP request.

If a **Content Delivery Network (CDN)** is configured, DNS returns the IP address of the nearest CDN edge server instead of the origin server.

---

# Complete Request Flow

```text
User
   â”‚
   â–¼
Browser
   â”‚
   â–¼
Browser DNS Cache
   â”‚
   â”œâ”€â”€ Cache Hit â†’ Return IP
   â”‚
   â””â”€â”€ Cache Miss
          â”‚
          â–¼
Operating System DNS Cache
          â”‚
          â”œâ”€â”€ Cache Hit â†’ Return IP
          â”‚
          â””â”€â”€ Cache Miss
                 â”‚
                 â–¼
Router Cache (Optional)
                 â”‚
                 â”œâ”€â”€ Cache Hit â†’ Return IP
                 â”‚
                 â””â”€â”€ Cache Miss
                        â”‚
                        â–¼
Configured Recursive Resolver
(Google DNS / Cloudflare DNS / ISP DNS)
                        â”‚
                        â–¼
Resolver Cache
                        â”‚
                        â”œâ”€â”€ Cache Hit â†’ Return IP
                        â”‚
                        â””â”€â”€ Cache Miss
                               â”‚
                               â–¼
Root DNS Server
                               â”‚
                               â–¼
TLD Name Server (.com)
                               â”‚
                               â–¼
Authoritative DNS Server
                               â”‚
                               â–¼
Returns IP Address
                               â”‚
                               â–¼
Resolver caches response
                               â”‚
                               â–¼
Operating System caches response
                               â”‚
                               â–¼
Browser caches response
                               â”‚
                               â–¼
TCP Connection
                               â”‚
                               â–¼
TLS Handshake (HTTPS)
                               â”‚
                               â–¼
HTTP Request
```

---

# Step-by-Step Explanation

## Step 1 â€“ User Enters URL

Example:

```
www.myapp.com
```

The browser needs the IP address before it can establish a connection.

---

## Step 2 â€“ Browser Cache

The browser checks whether it already knows the IP address.

If found:

* Return IP immediately.
* No DNS lookup is required.

---

## Step 3 â€“ Operating System Cache

If the browser cache misses, the operating system checks its DNS cache.

If found:

* Return IP.

Otherwise:

* Continue to the next step.

---

## Step 4 â€“ Router Cache (Optional)

Some home and enterprise routers cache DNS responses.

If the router has the record:

* Return IP.

Otherwise:

* Continue.

---

## Step 5 â€“ Recursive DNS Resolver

The operating system sends the request to its configured DNS resolver.

Examples:

* Google DNS (8.8.8.8)
* Cloudflare DNS (1.1.1.1)
* ISP DNS

The resolver first checks its own cache.

---

## Step 6 â€“ Root DNS Server

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

## Step 7 â€“ TLD Name Server

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

## Step 8 â€“ Authoritative DNS Server

The resolver contacts Cloudflare's authoritative nameserver.

Example:

```
What is the A record for www.myapp.com?
```

Cloudflare looks in its DNS zone.

Example:

```
www.myapp.com

â†“

104.21.10.15
```

This is the final source of truth.

---

## Step 9 â€“ Caching

The resolver caches the response based on the TTL.

Then returns it to:

* Operating System
* Browser

Future requests become much faster.

---

## Step 10 â€“ Network Connection

After obtaining the IP address:

```
TCP 3-Way Handshake
        â†“
TLS Handshake
        â†“
HTTP Request
```

The web server can now process the request.

---

# Where CDN Fits

Without a CDN:

```
DNS

â†“

Origin Server IP

â†“

Browser

â†“

Origin Server
```

Every user connects directly to the origin server.

---

With a CDN:

```
DNS

â†“

Nearest CDN Edge IP

â†“

Browser

â†“

CDN Edge
```

The browser connects to the CDN instead of the origin.

---

# CDN Request Flow

```
User
   â”‚
   â–¼
Browser
   â”‚
   â–¼
Recursive Resolver
   â”‚
   â–¼
Root DNS
   â”‚
   â–¼
TLD
   â”‚
   â–¼
Cloudflare Authoritative DNS
   â”‚
   â–¼
Returns IP of Nearest Edge
   â”‚
   â–¼
Browser connects to CDN
   â”‚
   â”œâ”€â”€ Cache Hit
   â”‚       â”‚
   â”‚       â–¼
   â”‚   Return Content
   â”‚
   â””â”€â”€ Cache Miss
           â”‚
           â–¼
      Origin Server
           â”‚
           â–¼
      Fetch Content
           â”‚
           â–¼
      Store in CDN Cache
           â”‚
           â–¼
      Return Content
```

---

# How Does Cloudflare Choose the Nearest Edge?

Cloudflare's authoritative DNS receives the DNS query from the recursive resolver.

Using the resolver's location (and often **EDNS Client Subnet (ECS)** information), Cloudflare estimates the user's region.

Example:

```
User

â†“

Pune

â†“

Nearest Edge

â†“

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
        â†“
Operating System Cache
        â†“
Router Cache
        â†“
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

