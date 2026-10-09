Caching — Complete Topic & Pattern Roadmap

# Caching Fundamentals

Caching stores a copy of data in a faster storage layer so that future requests can be served without repeatedly accessing the slower original source, such as a database, disk, remote API, or expensive computation.

A cache is usually placed between an application and its data source:

```text
Client → Application → Cache → Database / API
                         ↑
                    Fast copy of data
```

## Why caching?

Caching is mainly used to improve performance and reduce pressure on backend systems.

- **Reduce latency:** Memory-based cache lookups are usually much faster than database queries or network calls.
- **Reduce database load:** Repeated reads can be served from the cache instead of reaching the database.
- **Increase throughput:** Because each request consumes fewer backend resources, the system can handle more requests.
- **Reduce expensive computation:** Results of costly calculations, API calls, or page rendering can be reused.
- **Improve resilience:** A cache may continue serving recently cached data during temporary backend slowness, depending on the design.
- **Reduce network traffic:** Frequently requested data does not need to travel repeatedly from a remote service.

Caching is most effective for data that is read frequently, changes relatively infrequently, and can tolerate some staleness.

## Cache hit and cache miss

A **cache hit** occurs when the requested item is already present and usable in the cache.

```text
Request → Cache → Found
                    ↓
                 Return value
```

A **cache miss** occurs when the requested item is absent, expired, or otherwise unusable. The application must retrieve it from the original data source and may then store it in the cache.

Typical cache-aside flow:

```text
1. Application checks the cache.
2. If found: return the cached value.
3. If not found: read from the database.
4. Store the result in the cache.
5. Return the result to the client.
```

Example:

```python
user = cache.get("user:42")

if user is None:              # Cache miss
    user = database.get_user(42)
    cache.set("user:42", user, ttl=300)

return user                    # Cache hit on later requests
```

A miss is slower because it often involves the database and an additional cache write. A high miss rate can also overload the database, especially when many requests miss at the same time.

## Hit ratio and miss ratio

The **hit ratio**, also called the hit rate, measures how often requests are successfully served by the cache:

$$
\\text{Hit ratio} =
\\frac{\\text{cache hits}}
{\\text{cache hits} + \\text{cache misses}}
$$

The **miss ratio** is:

$$
\\text{Miss ratio} =
\\frac{\\text{cache misses}}
{\\text{cache hits} + \\text{cache misses}}
$$

They are complements:

$$
\\text{Miss ratio} = 1 - \\text{Hit ratio}
$$

For example, if a cache handles 10,000 requests with 9,500 hits and 500 misses:

- Hit ratio = 9,500 / 10,000 = **95%**
- Miss ratio = 500 / 10,000 = **5%**

A high hit ratio is useful, but it is not the only metric that matters. A cache could have a high hit ratio while returning stale data, consuming too much memory, or adding significant latency.

## Cache latency

**Cache latency** is the time required to retrieve a value from the cache.

It commonly includes:

- Time to serialize the request.
- Network time between the application and cache.
- Cache lookup time.
- Time to deserialize the response.

An in-process cache, located inside the application process, usually has lower latency than a remote cache. A remote distributed cache may still be much faster than a database query, but network overhead must be considered.

A useful way to estimate average read latency is:

$$
L_{\\text{average}} =
H \\times L_{\\text{hit}} +
(1-H) \\times L_{\\text{miss}}
$$

where:

- $H$ is the hit ratio.
- $L_{\\text{hit}}$ is cache-hit latency.
- $L_{\\text{miss}}$ is latency when the cache misses and the application accesses the database.

Example:

- Hit ratio: 95%
- Cache-hit latency: 2 ms
- Cache-miss latency: 100 ms

$$
L_{\\text{average}} = 0.95(2) + 0.05(100) = 6.9\\text{ ms}
$$

The average is much lower than 100 ms, but the 5% of requests that miss may still experience high latency. Therefore, tail latency, such as p95 and p99 latency, should also be monitored.

## Cache capacity

**Cache capacity** is the amount of data a cache can store. It is constrained by:

- Available memory or disk.
- Number of keys.
- Average item size.
- Key and metadata overhead.
- Replication requirements.
- Serialization format.
- Reserved memory for the cache system.

A cache does not usually need to store the entire database. It should store the **working set**: the subset of data requested frequently enough to benefit from caching.

If the working set does not fit in memory, the cache must remove entries according to an eviction policy.

Capacity planning should account for overhead:

```text
Required capacity
≈ cached data size
+ keys and metadata
+ replication overhead
+ safety margin
```

A cache that is too small may constantly evict and reload the same data. This is called **cache churn**, and it can produce a low hit ratio while increasing database load.

## TTL

**TTL**, or **time to live**, specifies how long an item may remain valid in the cache.

For example:

```text
cache.set("product:123", product, TTL = 300 seconds)
```

After five minutes, the entry expires and is no longer considered usable. The next request usually causes a cache miss and reloads the value from the database.

TTL helps control staleness:

- Short TTL: fresher data, more cache misses.
- Long TTL: better hit ratio, greater risk of stale data.
- No TTL: data may remain indefinitely unless explicitly invalidated or evicted.

TTL expiration and eviction are different:

- **Expiration:** The item becomes invalid because its TTL has elapsed.
- **Eviction:** The cache removes an item because it needs space or follows a configured removal policy.

## Eviction

**Eviction** is the removal of cached data, usually because the cache has reached its capacity limit.

Common eviction policies include:

| Policy | Meaning | Typical use |
|---|---|---|
| LRU | Remove the least recently used item | General-purpose caches |
| LFU | Remove the least frequently used item | Workloads with stable hot keys |
| FIFO | Remove the oldest inserted item | Simple queue-like behavior |
| Random | Remove a random item | Low-overhead fallback |
| TTL-based | Prefer items closest to expiration | Time-sensitive data |
| No eviction | Reject new writes when full | Systems requiring explicit capacity handling |

**LRU**, or least recently used, is one of the most common policies. It assumes that recently accessed data is more likely to be accessed again.

Eviction can happen even when an item has not expired. For example, an entry with a one-hour TTL might be removed after ten minutes because the cache needs room for another entry.

## Cacheable and non-cacheable data

### Cacheable data

Data is generally a good candidate for caching when it is:

- Read frequently.
- Relatively expensive to retrieve or compute.
- Shared across many users or requests.
- Stable for a meaningful period.
- Acceptable to serve slightly stale.
- Deterministic for a given key.

Examples include:

- Product catalog information.
- Public configuration.
- Exchange rates with an appropriate freshness period.
- Search results.
- User profile data with controlled invalidation.
- Expensive report results.
- Authentication metadata.
- Frequently accessed API responses.

### Non-cacheable or risky data

Caching may be inappropriate when data is:

- Highly personal or confidential without strict isolation.
- Extremely fast to retrieve directly.
- Updated constantly.
- Required to be strongly consistent.
- Dependent on rapidly changing permissions.
- Unique to a single request.
- Large and rarely reused.
- Unsafe to serve after expiration.

Examples include:

- Current account balances in a strongly consistent transaction flow.
- One-time authentication codes.
- Real-time inventory during a high-volume sale.
- Payment authorization results unless carefully designed.
- Private responses accidentally shared across users.
- Data whose permissions change frequently.

The key question is not simply “Can this data be cached?” but:

> Can this data be reused safely for this key, for this period, under these consistency and privacy requirements?

Cache keys must include every input that affects the result. For example, a localized product page may need a key such as:

```text
product-page:123:en-IN:mobile
```

rather than only:

```text
product-page:123
```

## Hot data and cold data

**Hot data** is requested frequently. It is usually the most valuable data to keep in the cache.

Examples:

- A popular product page.
- A frequently viewed user profile.
- A trending news article.
- A common configuration value.

**Cold data** is requested rarely. Storing it may waste capacity unless retrieving it is exceptionally expensive.

A cache works best when it captures the hot portion of the workload. Eviction policies try to keep hot data and remove cold data, although their effectiveness depends on the access pattern.

A common access pattern is **skewed access**, where a small percentage of keys receives most requests. This is favorable for caching because a relatively small cache can serve a large share of traffic.

## Read-heavy and write-heavy workloads

### Read-heavy workloads

A **read-heavy workload** performs many more reads than writes.

Example:

```text
100,000 reads
1,000 writes
```

Caching is usually highly effective because many requests can reuse the same values. Cache-aside is a common pattern: the application reads from the cache first, loads on a miss, and invalidates or updates the cache after writes.

### Write-heavy workloads

A **write-heavy workload** performs frequent updates.

Caching can be more difficult because every update introduces a consistency problem:

- Should the cache be updated immediately?
- Should the entry be deleted?
- Can readers temporarily see stale data?
- What happens if the database update succeeds but the cache update fails?
- What happens if updates arrive out of order?

Common strategies include:

- **Write-through:** Write to the cache, and the cache synchronously writes to the database.
- **Write-back or write-behind:** Write to the cache first, then persist asynchronously.
- **Write-around:** Write directly to the database and do not populate the cache until a later read.
- **Invalidate-on-write:** Update the database and remove the corresponding cache entry.

For frequently changing data, direct database reads or a carefully designed write-through/event-driven approach may be safer than a simple cache-aside design.

## Important design trade-off

Caching trades **freshness and consistency** for **speed and reduced backend work**.

A practical cache design defines:

- What data is cached.
- The cache key format.
- The TTL.
- The invalidation strategy.
- The maximum cache size.
- The eviction policy.
- Behavior during cache failure.
- Protection against cache stampedes.
- Privacy and authorization boundaries.
- Metrics such as hit ratio, miss ratio, latency, memory use, expirations, and evictions.

The most important foundational rule is:

> Cache data that is expensive to obtain, frequently reused, and safe to serve within a defined freshness window.



# Types of Caching

Caching can be implemented at several layers of a system. Each layer stores data closer to the component that needs it, reducing latency, network traffic, backend load, or repeated computation.

```text
User
  ↓
Browser cache
  ↓
DNS cache
  ↓
CDN / edge cache
  ↓
API Gateway cache
  ↓
Application cache
  ↓
Distributed cache
  ↓
Database cache
  ↓
Storage
```

A single request may pass through several of these caching layers.

## Browser caching

**Browser caching** stores web resources locally on the user’s device. Browsers commonly cache:

- HTML documents.
- CSS stylesheets.
- JavaScript files.
- Images.
- Fonts.
- Video fragments.
- API responses, when permitted.

When the user requests the same resource again, the browser may reuse its local copy instead of downloading it again. This reduces page-load time, bandwidth usage, and server requests. Browsers use HTTP response headers such as `Cache-Control`, `Expires`, `ETag`, and `Last-Modified` to decide whether a resource can be reused or must be validated.

Example:

```http
Cache-Control: public, max-age=86400
```

This tells the browser and permitted shared caches that the response may be considered fresh for 86,400 seconds, or one day.

### Browser validation

A browser may have a cached copy but still ask the server whether it is current:

```http
If-None-Match: "resource-version-123"
```

If the resource has not changed, the server can return:

```http
HTTP/1.1 304 Not Modified
```

The browser then uses its existing copy instead of downloading the full response. `ETag` identifies a particular version of a resource and helps caches avoid transferring unchanged content.

### Advantages

- Very low latency.
- Reduces bandwidth usage.
- Reduces requests to the application.
- Works without a separate cache server.

### Risks

- Old content may remain visible until expiration.
- Private data may be stored on a shared device.
- Incorrect cache headers can cause users to receive stale or user-specific content.

For versioned static files, a common strategy is:

```text
app.abc123.js
styles.def456.css
```

When the content changes, the filename changes, so the browser can safely cache the old version for a long time.

## HTTP caching

**HTTP caching** is the general mechanism that allows browsers, proxies, CDNs, and other intermediaries to reuse HTTP responses.

HTTP caching is controlled primarily through headers:

| Header | Purpose |
|---|---|
| `Cache-Control` | Defines caching rules and freshness duration |
| `Expires` | Legacy expiration timestamp |
| `ETag` | Identifies a specific resource version |
| `Last-Modified` | Indicates when the resource was last changed |
| `Vary` | Specifies request headers that affect the response |
| `Age` | Indicates how long a shared cache has stored a response |

`Cache-Control` can be used in both requests and responses to control browser and shared-cache behavior.

Common directives:

```http
Cache-Control: public, max-age=3600
```

The response can be cached by shared caches and is fresh for one hour.

```http
Cache-Control: private, max-age=600
```

The response may be cached by a private client such as a browser, but should not be stored by a shared proxy.

```http
Cache-Control: no-store
```

The response should not be stored.

```http
Cache-Control: no-cache
```

The response may be stored, but it must be revalidated before reuse. Despite its name, `no-cache` does not necessarily mean “do not store.”

### HTTP cache key

An HTTP cache usually identifies an object using the request URL and sometimes other request properties. The `Vary` header tells a cache that response variants depend on specific request headers.

For example:

```http
Vary: Accept-Encoding, Accept-Language
```

This indicates that compressed and uncompressed responses, or different language versions, may need separate cache entries.

### HTTP caching example

```text
Client requests /logo.png
        ↓
HTTP cache has a fresh copy?
        ├── Yes → Return cached image
        └── No  → Request image from origin
                    ↓
                Store response
                    ↓
                Return image
```

## CDN caching

A **Content Delivery Network**, or CDN, is a globally distributed network of edge servers. CDN caching stores copies of content at locations near users.

Typical CDN-cached content includes:

- Images.
- JavaScript and CSS files.
- Videos.
- Downloadable files.
- Web pages.
- Public API responses.
- Software packages.

A CDN serves a cached object from an edge location instead of forwarding every request to the origin server. This reduces round-trip latency and decreases origin traffic.

### CDN request flow

```text
User in India
    ↓
Nearby CDN edge
    ├── Cache hit → Return cached response
    └── Cache miss
            ↓
        Fetch from origin
            ↓
        Store at edge
            ↓
        Return to user
```

The first request at an edge may be a miss. Later requests can be hits until the object expires or is invalidated.

### CDN cache controls

CDNs commonly use:

- Origin `Cache-Control` headers.
- CDN-specific TTL settings.
- URL-based cache keys.
- Query-string rules.
- Header-based variation.
- Manual invalidation or purge.
- Geographic or device-specific variants.

Example:

```http
Cache-Control: public, max-age=31536000, immutable
```

This is appropriate for a versioned static asset that will not change at the same URL.

### CDN benefits

- Reduces latency for geographically distributed users.
- Protects the origin from repeated requests.
- Absorbs traffic spikes.
- Reduces bandwidth costs at the origin.
- Can improve availability during temporary origin problems.

### CDN risks

- Stale content may remain at many edge locations.
- Cache invalidation can be complex.
- Incorrect cache keys can expose one user’s response to another.
- Personalized or authorization-dependent responses require careful configuration.

Public content is usually a better CDN candidate than user-specific content.

## API Gateway caching

**API Gateway caching** stores responses produced by backend API endpoints. The gateway checks its cache before forwarding a request to the application or service.

```text
Client → API Gateway
             ├── Cached response → Return immediately
             └── Cache miss → Call backend → Cache response
```

API Gateway caching can reduce calls to backend services and improve API latency. For example, Amazon API Gateway supports stage-level caching and response TTLs.

### API cache key

The cache key must include every request attribute that changes the response.

Possible key components include:

- HTTP method.
- Request path.
- Path parameters.
- Query parameters.
- Selected headers.
- Tenant or user identity, when applicable.
- Locale or requested representation.

For example:

```text
GET /products?category=books&page=2
```

should not share a cache entry with:

```text
GET /products?category=electronics&page=2
```

If a response depends on the authenticated user, a shared cache must not return one user’s response to another user. The user or tenant identity may need to be included in the key, or the endpoint may need to bypass shared caching.

### Good API caching candidates

- Public product lists.
- Exchange-rate data with an acceptable freshness window.
- Search suggestions.
- Read-only reference data.
- Public configuration.
- Expensive reports.
- Frequently requested metadata.

### Poor API caching candidates

- Payment operations.
- One-time operations.
- Real-time account balances.
- Highly personalized responses.
- Frequently changing inventory.
- Endpoints with side effects.

API Gateway caches are most effective when many requests repeat the same inputs and the response can safely be reused.

## Application-level caching

**Application-level caching** is caching implemented and controlled by application code.

The application decides:

- What to cache.
- How to construct keys.
- How long values remain valid.
- When to invalidate entries.
- How to handle misses and failures.
- Whether cached data is local or shared.

Example:

```python
def get_product(product_id):
    key = f"product:{product_id}"

    product = cache.get(key)
    if product is not None:
        return product

    product = database.fetch_product(product_id)
    cache.set(key, product, ttl=600)
    return product
```

This is the cache-aside pattern.

### Common application cache contents

- Database query results.
- Computed objects.
- Rendered HTML fragments.
- Permission checks.
- Feature flags.
- Session-related metadata.
- External API responses.
- Expensive aggregations.

### Local application cache

A local cache exists inside the application process.

```text
Application server A → Local memory
Application server B → Local memory
Application server C → Local memory
```

Advantages:

- Extremely low latency.
- No network call to retrieve cached data.
- Simple to implement.

Disadvantages:

- Each server has a separate copy.
- Memory is limited to one process.
- Values may become inconsistent across servers.
- Restarting the process can remove the cache.
- Cache warming may need to happen separately on every server.

Local caching is useful for small, stable, read-mostly data such as configuration or compiled templates.

## Distributed caching

**Distributed caching** stores cached data in a cache system shared by multiple application instances.

```text
Application server A ─┐
Application server B ─┼──→ Shared distributed cache
Application server C ─┘
```

Common distributed cache technologies include Redis, Memcached, and managed cloud cache services.

A distributed cache allows multiple application servers to reuse the same entries. In a distributed environment, cached data may span multiple cache servers and be shared by consumers across the application fleet.

### Advantages

- Shared cache across application instances.
- More available memory than a single process.
- Better consistency than independent local caches.
- Supports horizontal scaling.
- Can provide replication and failover.
- Useful for shared sessions and rate limits.

### Costs and risks

- Network latency is higher than local memory access.
- The cache becomes an infrastructure dependency.
- Distributed failures and partitions must be handled.
- Serialization and deserialization add overhead.
- Hot keys can overload one cache node.
- Invalidation becomes more important.

### Common distributed-cache uses

- User sessions.
- Product and catalog data.
- Rate-limiting counters.
- Distributed locks.
- Frequently executed database queries.
- API response caching.
- Shared feature flags.
- Short-lived tokens or metadata.

### Cache stampede

A **cache stampede** occurs when a popular item expires and many requests try to rebuild it at the same time.

Possible protections include:

- Request coalescing.
- Locks around cache population.
- Early refresh.
- Randomized TTL values.
- Serving stale data temporarily.
- Prewarming important keys.

For example, instead of giving 10,000 requests permission to query the database after one key expires, the system can allow one request to refresh the key while the others wait or use a stale copy.

## Database caching

**Database caching** stores frequently accessed database data in faster memory or a cache layer.

Database caching can exist at multiple levels:

- Database buffer pool.
- Query-result cache.
- Index pages in memory.
- Operating-system file cache.
- Application-managed query cache.
- External key-value cache.

A database buffer pool keeps frequently accessed table and index pages in memory, reducing physical disk reads.

### Database buffer caching

```text
SQL query
   ↓
Database buffer pool
   ├── Page found → Read from memory
   └── Page absent → Read from disk, then cache page
```

This is generally transparent to the application. The database decides which pages to keep and evict.

### Application query caching

An application may cache the result of an expensive query:

```python
key = "top-products:2026-10-09"

result = cache.get(key)

if result is None:
    result = database.query_top_products()
    cache.set(key, result, ttl=300)
```

This can be highly effective for repeated read queries, but invalidation is difficult when the underlying tables change.

### Database caching considerations

Caching query results is safer when:

- The query is expensive.
- The same query is repeated frequently.
- Data changes relatively infrequently.
- A small amount of staleness is acceptable.
- Cache keys include all query parameters.
- Updates can trigger invalidation.

It is risky when:

- Strong consistency is required.
- Queries depend on the current user.
- Permissions change frequently.
- Results are highly unique.
- Write volume is high.
- The query is already inexpensive.

Database caching should not be used as a substitute for proper indexes, query optimization, partitioning, or capacity planning. If the query itself is inefficient, caching may hide the problem temporarily without fixing it.

## DNS caching

**DNS caching** stores domain-name-to-IP-address mappings.

When a client requests:

```text
api.example.com
```

DNS resolution may return an IP address from a nearby or previously queried cache instead of contacting the authoritative DNS server every time.

```text
Client
  ↓
Operating-system DNS cache
  ↓
Browser DNS cache
  ↓
Recursive resolver cache
  ↓
Authoritative DNS server
```

DNS caching reduces:

- DNS lookup latency.
- Queries to authoritative DNS servers.
- Network traffic.
- Load on DNS infrastructure.

### DNS TTL

DNS records include a TTL that specifies how long a resolver may cache the record.

Example:

```text
api.example.com → 203.0.113.10
TTL: 300 seconds
```

A short TTL allows changes to propagate more quickly but causes more DNS lookups. A long TTL reduces DNS traffic and lookup latency but means changes may take longer to reach users.

### DNS cache limitations

- DNS changes are not always visible immediately.
- Different resolvers may refresh at different times.
- A low TTL does not guarantee instant propagation.
- Cached DNS data may direct clients to an old server.
- DNS caching does not cache the HTTP response itself.

DNS caching only caches the result of name resolution. CDN or HTTP caching handles the actual web content.

## How the layers work together

Suppose a user requests a public product page:

```text
1. Browser checks its local cache.
2. DNS cache resolves the application hostname.
3. CDN checks its edge cache.
4. API Gateway checks its response cache.
5. Application checks its local or distributed cache.
6. Database checks its buffer pool.
7. Storage is accessed only if necessary.
```

The request may be served at any layer:

```text
Browser hit     → fastest for that user
DNS hit         → avoids repeated name resolution
CDN hit         → avoids origin network and processing
Gateway hit     → avoids backend API execution
App-cache hit   → avoids database access
DB-cache hit    → avoids disk access
Storage access  → slowest path
```

Each layer has a separate cache key, TTL, invalidation mechanism, and consistency model. A stale value at an outer layer can prevent newer data from being observed even if inner layers have already been updated.

## Comparison of caching layers

| Cache type | Location | Main benefit | Typical data | Main concern |
|---|---|---|---|---|
| Browser cache | User device | Lowest latency for repeat visits | Static assets and permitted responses | Stale or private data |
| HTTP cache | Browser, proxy, or shared intermediary | Standard response reuse | HTTP resources | Correct headers and validators |
| CDN cache | Global edge servers | Lower geographic latency | Static and public content | Invalidation and cache-key safety |
| API Gateway cache | API entry point | Fewer backend API calls | Read-only API responses | Personalized responses |
| Application cache | Application process or service | Flexible business-aware caching | Computed objects and query results | Invalidation logic |
| Distributed cache | Shared cache cluster | Reuse across application servers | Sessions, objects, counters | Network failures and hot keys |
| Database cache | Database memory layer | Fewer disk reads | Pages, indexes, query data | Memory pressure and query behavior |
| DNS cache | Client and DNS resolvers | Faster hostname resolution | Domain-to-IP mappings | Delayed DNS changes |

## Choosing the right layer

Use **browser or HTTP caching** for public static resources that can be reused by the client.

Use a **CDN** for content requested by users in different geographic regions, especially large or public assets.

Use **API Gateway caching** for repeated, read-only API calls with predictable keys and controlled freshness.

Use **application caching** when the application understands the business rules and needs to cache computed or domain-specific results.

Use a **distributed cache** when several application instances need a shared, low-latency data layer.

Use **database caching** to reduce repeated disk access or repeated expensive query execution, but continue optimizing queries and indexes.

Use **DNS caching** to reduce repeated domain-name resolution; it should not be treated as a replacement for HTTP or application caching.

The central design rule is:

> Cache each piece of data at the closest safe layer where it can be reused, while defining its TTL, invalidation behavior, privacy boundaries, and acceptable staleness.


 
3. Cache Types
Local / In-Memory Cache
Application Instance
       ↓
   Local Memory

Examples:
- .NET IMemoryCache
- Java Caffeine
- Guava Cache
Advantages:
- Extremely fast
- No network call
Problems:
- Each instance has different cache
- Limited memory
- Cache lost when instance restarts
Distributed Cache
App 1 ──┐
App 2 ──┼──> Redis
App 3 ──┘

Examples:
- Redis
- Memcached
Advantages:
- Shared cache
- Works across multiple application instances
- Larger capacity
Problems:
- Network latency
- Cache cluster failure
- Serialization/deserialization
4. Core Caching Patterns ⭐⭐⭐
These are must-know interview topics.
4.1 Cache-Aside / Lazy Loading ⭐⭐⭐
Most important pattern.
Application
     |
     v
Check Cache
   /    \
 HIT    MISS
  |       |
Return   DB
          |
          v
       Cache
          |
          v
        Return

Pseudo-flow:
GET user/123

1. Check Redis
2. If found → return
3. If not found:
      query DB
      put result in Redis
      return result

Pros
- Simple
- Application controls caching
- Only requested data gets cached
Cons
- First request is slow
- Cache miss causes DB load
- Potential cache stampede
Default choice in system design interviews.
5. Read-Through Cache
Application talks to cache.
Cache talks to database.
Application
     |
     v
   Cache
     |
     v
    DB

Application doesn't explicitly handle cache misses.
Useful when the caching infrastructure supports database loading.
Compare:
Cache Aside:

Application → Cache
Application → DB


Read Through:

Application → Cache → DB

6. Write-Through Cache
Every write updates cache and DB.
Application
     |
     v
   Cache
     |
     v
    DB

Example:
UPDATE user

Cache updated
      ↓
DB updated

Benefit
Cache stays relatively fresh.
Cost
Every write has cache overhead.
Good when:
- Read-heavy workload
- Strong cache consistency is desirable
7. Write-Behind / Write-Back Cache
Application writes to cache first.
Database update happens asynchronously.
Application
     |
     v
   Cache
     |
     | async
     v
    DB

Example:
1000 writes/sec

Application
     ↓
Redis
     ↓
Queue
     ↓
Database

Advantage
Very high write throughput.
Risk
If cache fails before persistence:
Data can be lost

Use carefully.
8. Refresh-Ahead Cache
Refresh cache before it expires.
TTL = 10 minutes

At 9 minutes:
    refresh from DB

Useful for:
- Popular products
- Configuration
- Frequently accessed data
- Trending content
Goal:
Avoid cache miss for hot data

9. Cache Invalidation ⭐⭐⭐
One of the most important system-design topics.
"There are only two hard things in Computer Science: cache invalidation and naming things."

Understand:
- TTL-based expiration
- Explicit invalidation
- Event-based invalidation
- Version-based invalidation
- Write-through invalidation
- Delete-on-write
Example:
User updated
    ↓
DB updated
    ↓
Delete Redis key

Next request:
Redis MISS
    ↓
DB
    ↓
Redis updated

This is often safer than trying to update cached objects perfectly.
10. Cache Eviction Policies ⭐⭐⭐
What happens when cache is full?
LRU
Least Recently Used
A B C D

A hasn't been used recently
→ remove A

Very common.
LFU
Least Frequently Used
Remove data accessed least often.
Useful for identifying truly popular data.
FIFO
First item inserted gets removed first.
Random
Random key is removed.
TTL expiration
Remove expired keys.
Understand:
LRU vs LFU

This is a common interview question.
11. Cache Stampede / Thundering Herd ⭐⭐⭐
Very important.
Suppose:
Product 123
TTL = 10 min

At exactly 10 minutes:
10,000 requests
      ↓
Cache MISS
      ↓
10,000 DB queries

Database gets overloaded.
Solutions
Locking
Only one request loads DB.
Request 1 → DB
Request 2 → wait
Request 3 → wait
Request 4 → wait

Then:
DB result → Redis

All requests → Redis

Request coalescing
Combine identical requests.
Probabilistic early expiration
Refresh before expiration randomly.
Background refresh
Refresh hot keys asynchronously.
12. Cache Penetration ⭐⭐⭐
Request repeatedly asks for data that doesn't exist.
GET user/999999

Redis MISS
 ↓
DB
 ↓
NOT FOUND

Attack:
1 million fake IDs

Database gets hammered.
Solution: Negative caching
Store:
user:999999 → NULL
TTL = 30 sec

Then:
Request
 ↓
Redis
 ↓
NULL

No DB request.
13. Cache Breakdown / Hot Key Problem ⭐⭐⭐
One extremely popular key.
Example:
Taylor Swift concert

or
Product ID = 123

Millions of requests:
         ┌── Request
         ├── Request
         ├── Request
         ├── Request
         ↓
     SAME CACHE KEY

This creates a hot key.
Solutions:
- Replicate hot key
- Local cache
- Key replication
- Request coalescing
- Sharding
- CDN
- Refresh-ahead
14. Cache Avalanche ⭐⭐⭐
Large numbers of keys expire simultaneously.
10:00 AM

Key A → expire
Key B → expire
Key C → expire
Key D → expire
...

Suddenly:
Cache ↓↓↓

DB ↑↑↑

Solutions
Randomized TTL
Instead of:
TTL = 60 min

Use:
TTL = 60 min + random(0–10 min)

Staggered expiration
Refresh-ahead
Multiple cache layers
15. Cache Consistency ⭐⭐⭐
Critical system-design topic.
Consider:
DB:
User balance = ₹1000

Redis:
User balance = ₹1000

Update:
DB → ₹1200

but Redis still:
₹1000

Now stale data is served.
Study:
- Strong consistency
- Eventual consistency
- Stale-while-revalidate
- Cache invalidation
- Cache update ordering
16. DB + Cache Update Strategies
Strategy 1
DB update
 ↓
Cache delete

Common choice.
Strategy 2
Cache update
 ↓
DB update

Risky if DB fails.
Strategy 3
DB update
 ↓
Publish event
 ↓
Consumer
 ↓
Cache invalidation

Good for distributed systems.
Strategy 4
DB
 ↓
CDC / Event
 ↓
Kafka
 ↓
Cache updater

Useful at very large scale.
17. Cache Serialization
Understand how objects are stored.
.NET Object
    ↓
JSON
    ↓
Redis

Options:
- JSON
- MessagePack
- Protobuf
Trade-offs:
Format	Size	Speed	Readability
JSON	High	Medium	Excellent
Protobuf	Low	High	Low
MessagePack	Low	High	Low


18. Cache Key Design ⭐⭐
Very important in Redis.
Bad:
123

Better:
user:123

For complex objects:
user:123:profile
product:123:details
order:123:summary

Think about:
- Naming
- Namespaces
- Versioning
- Tenant isolation
- Key size
- Collision
- Bulk deletion
Example:
v2:tenant:123:user:456

19. Cache Sharding ⭐⭐⭐
One Redis server isn't enough.
             Redis Cluster
          /       |       \
       Node 1   Node 2   Node 3

Study:
- Horizontal scaling
- Consistent hashing
- Redis Cluster
- Hash slots
- Data distribution
- Rebalancing
- Hot partitions
20. Redis Architecture ⭐⭐⭐
For system design, learn:
Redis
 ├── Strings
 ├── Hashes
 ├── Lists
 ├── Sets
 ├── Sorted Sets
 ├── Streams
 └── Pub/Sub

Important concepts:
- TTL
- Persistence
- RDB
- AOF
- Replication
- Sentinel
- Cluster
- Sharding
- Failover
- Memory management
- Eviction
- Transactions
- Lua scripts
- Distributed locks
21. Multi-Level Cache ⭐⭐⭐
Very useful architecture.
             Request
                ↓
          L1 Local Cache
             /     \
           HIT     MISS
                    ↓
             L2 Redis
               /    \
             HIT    MISS
                    ↓
                   DB

Example:
L1 → .NET IMemoryCache
L2 → Redis
L3 → Database

Benefits:
- Extremely low latency
- Reduced Redis traffic
- Reduced DB load
Challenge:
Consistency between L1 and L2.
22. CDN Caching ⭐⭐⭐
For static or geographically distributed content.
User
 ↓
Nearest CDN
 ↓
Origin Server

Study:
- Edge caching
- Cache-Control
- max-age
- s-maxage
- ETag
- Last-Modified
- Cache purge
- Cache invalidation
- Origin shield
23. HTTP Caching
Learn:
Cache-Control
ETag
Last-Modified
Expires
If-None-Match
If-Modified-Since

Example:
Cache-Control: public, max-age=3600

Browser can serve the response without hitting your server.
24. Distributed Cache Failure ⭐⭐⭐
What if Redis goes down?
Don't let:
Redis DOWN
    ↓
Every request
    ↓
Database
    ↓
DB DOWN

This is a cascading failure.
Study:
- Fail-open
- Fail-closed
- Local fallback
- Circuit breaker
- Rate limiting
- Cache warm-up
- Redis replication
- Redis Sentinel
- Redis Cluster
25. Cache Warming
After deployment:
Application starts
       ↓
Cache empty
       ↓
Huge traffic
       ↓
DB overloaded

Solution:
Application starts
       ↓
Preload popular data
       ↓
Traffic

Useful after:
- Deployment
- Redis restart
- Disaster recovery
- Cache flush
26. Cache Observability ⭐⭐
Monitor:
Cache hit ratio
Cache miss ratio
Latency
Eviction rate
Memory usage
Hot keys
Expired keys
Redis CPU
Redis connections
Network throughput
DB fallback rate

Very good interview statement:
"I would monitor cache hit ratio and DB fallback rate because a cache can appear healthy while silently losing effectiveness."

27. Advanced Patterns
After the above, study:
Stale-While-Revalidate
Serve stale data
       ↓
Background refresh

Cache-Aside + Event Invalidation
DB
 ↓
Event
 ↓
Kafka
 ↓
Cache invalidation

Two-Level Cache
L1 → Local
L2 → Redis
L3 → DB

Distributed Lock
Prevent multiple instances from rebuilding the same cache key.
Bloom Filter
Useful for cache/database penetration.
Request
 ↓
Bloom Filter
 ↓
Definitely doesn't exist → reject
Maybe exists → Cache/DB

28. The 3 Problems You Must Know
For interviews, memorize this mental model:
             CACHE PROBLEMS
                   |
       ┌───────────┼───────────┐
       ↓           ↓           ↓
   Stampede    Penetration   Avalanche
       |           |           |
 Same key       Fake keys    Many keys
 expires        repeatedly   expire
       |           |           |
   Lock         Negative     Random TTL
   Coalesce     caching      Refresh
   Refresh      Bloom        Ahead

And separately:
Hot Key / Cache Breakdown
        ↓
One key receives massive traffic

Recommended Learning Sequence
For your system-design preparation, I'd put caching in this exact order:
01. What is caching?
02. Cache hit / miss / hit ratio
03. Local vs distributed cache
04. Redis fundamentals
05. Cache-Aside ⭐
06. Read-Through
07. Write-Through
08. Write-Behind
09. Refresh-Ahead
10. Cache invalidation ⭐⭐⭐
11. TTL
12. Eviction: LRU / LFU
13. Cache consistency
14. Cache Stampede ⭐⭐⭐
15. Cache Penetration ⭐⭐⭐
16. Cache Avalanche ⭐⭐⭐
17. Hot Keys ⭐⭐⭐
18. Cache Warming
19. Cache Sharding
20. Redis Cluster / Replication
21. Multi-Level Cache
22. CDN Cache
23. HTTP Cache
24. Cache failure & fallback
25. Distributed locking
26. Bloom Filter
27. Cache observability
28. Real-world system designs

Then practice these 6 designs
1. URL Shortener → Redis + cache-aside
2. Product Catalog → cache invalidation + CDN
3. News Feed → hot keys + caching
4. Rate Limiter → Redis
5. Ticket/Seat Booking → cache consistency + locking
6. Transaction History → multi-level cache + Redis + DB
For your 1M requests/sec transaction-history design, caching is especially important because you have a read-heavy workload. The architecture I'd expect you to reason through is roughly:
                 Users
                   ↓
              CDN / LB
                   ↓
              API Gateway
                   ↓
            Order/Transaction API
                   ↓
              L1 Local Cache
                   ↓ miss
                Redis
                   ↓ miss
            Transaction DB
                   ↓
            Redis population
                   ↓
            Response
