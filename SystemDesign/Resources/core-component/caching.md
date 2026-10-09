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

# Core Caching Patterns

Caching patterns define how an application reads data from a cache, writes data to the source of truth, and keeps both layers reasonably consistent.

The most common patterns are:

1. Cache-aside, also called lazy loading.
2. Read-through caching.
3. Write-through caching.
4. Write-behind or write-back caching.
5. Write-around caching.
6. Refresh-ahead caching.

There is no universally best pattern. The correct choice depends on read volume, write volume, consistency requirements, latency targets, data durability, and tolerance for stale data.

## Quick comparison

| Pattern | Read path | Write path | Main advantage | Main bottleneck or risk |
|---|---|---|---|---|
| Cache-aside | Application checks cache, then source on miss | Application updates source and cache or invalidates cache | Simple and flexible | Miss latency and invalidation complexity |
| Read-through | Application reads through cache; cache loads source on miss | Usually handled separately | Centralizes read logic | Cold misses and cache-to-source dependency |
| Write-through | Cache and source are updated synchronously | Both updated before success | Stronger freshness after writes | Higher write latency and extra write work |
| Write-behind | Cache first, source asynchronously later | Cache first, database later | Very fast writes and burst absorption | Data-loss and ordering risk |
| Write-around | Writes bypass cache and go to source | Source only | Avoids polluting cache | First read after write is a miss |
| Refresh-ahead | Cache refreshes popular data before expiry | Usually paired with another write strategy | Predictable read latency | Refreshing data nobody requests |

AWS describes lazy caching as populating the cache only when an object is requested, while write-through updates the cache when the database is updated. These approaches are often combined because they optimize different paths. [web:46][web:49]

## 1. Cache-aside pattern

Cache-aside is also called **lazy loading**. The application is responsible for checking the cache, reading from the source of truth on a miss, and populating the cache.

### Read flow

```text
1. Application checks the cache.
2. If the value exists, return it.
3. If the value is missing, read from the database.
4. Store the result in the cache.
5. Return the result.
```

```text
Application → Cache
                 ├── Hit  → Return value
                 └── Miss → Database → Store in cache → Return value
```

Example:

```python
def get_product(product_id):
    key = f"product:{product_id}"

    product = cache.get(key)
    if product is not None:
        return product

    product = database.get_product(product_id)
    cache.set(key, product, ttl=300)
    return product
```

### Write flow: invalidate on write

A common write strategy is to update the database first and then delete the cached value:

```python
def update_product(product_id, product):
    database.update_product(product_id, product)
    cache.delete(f"product:{product_id}")
```

The next read misses the cache and loads the current value from the database. Azure describes this as invalidating the affected cache entry after writing to the data store. [web:45][web:47]

### Pros

- Simple and widely applicable.
- The application controls cache keys, TTLs, and invalidation.
- Only requested data is placed in the cache.
- Infrequently accessed data does not consume cache space unnecessarily.
- Works with almost any database or cache technology.
- Easy to adopt incrementally.

### Cons

- The application contains extra cache-management logic.
- The first request after a miss is slower.
- Invalidation can be difficult when one record affects many cached results.
- A failed cache write can leave the cache empty, although the source remains correct.
- A failed invalidation can leave stale data in the cache.
- Concurrent misses can create a cache stampede.

### Bottlenecks

The primary bottlenecks are:

- Database latency during cache misses.
- Database overload during mass expiration.
- Cache stampedes for popular keys.
- Invalidation delays.
- Serialization and deserialization for large values.

### Best use cases

Cache-aside is a strong default for:

- Read-heavy applications.
- Product catalogs.
- User profiles.
- Public configuration.
- Search results.
- Data that tolerates short-lived staleness.

### Consistency behavior

Cache-aside usually provides **eventual consistency** unless the application carefully invalidates or updates every relevant cache entry after a write.

## 2. Read-through pattern

In read-through caching, the application reads from the cache, and the cache itself loads data from the database or source when a requested item is missing.

```text
Application → Cache
                 ├── Hit  → Return value
                 └── Miss → Cache loads database → Return value
```

The application does not directly implement the cache-miss loading logic. The cache or cache library owns that behavior. Azure describes read-through caching as reading through the cache, with the cache fetching from the data store when needed. [web:48]

### Example

```python
def get_product(product_id):
    return read_through_cache.get(
        key=f"product:{product_id}",
        loader=lambda: database.get_product(product_id),
        ttl=300
    )
```

### Pros

- Keeps cache-loading logic in one place.
- Simplifies application service code.
- Reduces duplicated cache-aside logic across teams.
- Can standardize TTLs, serialization, metrics, and error handling.
- Makes the cache look like a data-access layer.

### Cons

- The cache needs a configured connection to the underlying data source.
- The cache layer becomes more operationally important.
- Failure handling can be less visible to application developers.
- Cache misses still require a database call.
- Not every cache product natively supports read-through behavior.
- Complex authorization or user-specific loading logic may not fit easily.

### Bottlenecks

- Cache cold starts can send many requests to the database.
- Cache-to-database communication can become a central bottleneck.
- A slow loader can increase miss latency.
- A failure in the loader can affect every caller using the cache.

### Best use cases

Read-through is useful when:

- Many services need the same loading behavior.
- Cache access should be standardized.
- The source lookup is deterministic for a cache key.
- The cache layer can safely access the source of truth.
- The application benefits from a clean data-access abstraction.

### Read-through versus cache-aside

| Concern | Cache-aside | Read-through |
|---|---|---|
| Cache-miss logic | Application owns it | Cache layer owns it |
| Application code | More explicit | Simpler |
| Flexibility | Higher | Depends on cache abstraction |
| Operational ownership | Application team | Cache/data-access layer |
| Common failure | Stale or missed invalidation | Loader bottleneck or cache dependency |

Cache-aside and read-through have similar lazy-loading behavior. The main difference is which component is responsible for loading data after a miss.

## 3. Write-through pattern

In write-through caching, a write is sent to the cache, and the cache synchronously writes the change to the database before confirming success.

```text
Application → Cache → Database
                 └── Update cache and database synchronously
```

Another implementation updates the database and cache as part of the same application-controlled operation. The important property is that the write is not considered complete until both required layers have been updated. Azure describes write-through as updating the data store and cache as part of the same write operation. [web:47][web:48]

### Write flow

```text
1. Application sends an update.
2. Cache receives the new value.
3. Cache writes the value to the database.
4. Both operations succeed.
5. Application returns success.
```

Example:

```python
def update_product(product_id, product):
    cache.write_through(
        key=f"product:{product_id}",
        value=product,
        persist=lambda value: database.update_product(product_id, value)
    )
```

### Pros

- Cached data is updated immediately after a successful write.
- Later reads can avoid a stale cache entry.
- Reduces cache misses after application-controlled writes.
- Provides a clear write path for important read-heavy data.
- Can simplify read logic because the cache is populated during writes.

### Cons

- Every write has extra latency.
- Every write consumes cache resources, even if the item is never read.
- A cache failure may cause the write to fail or require fallback logic.
- Coordinating cache and database success is not automatically a full distributed transaction.
- Retry behavior can create duplicate or out-of-order updates.
- It is more complicated when multiple systems write to the database.

### Bottlenecks

- Cache network latency.
- Database write latency.
- Waiting for both systems before returning success.
- Increased write traffic to the cache.
- Locking or serialization under high concurrent writes.

### Best use cases

Write-through is appropriate when:

- Data is read frequently after being written.
- Clients need fresh values immediately after application-controlled writes.
- The workload is read-heavy.
- The application owns the write path.
- Extra write latency is acceptable.

Azure guidance recommends write-through for read-heavy paths where clients need fresh values immediately after application-controlled writes. [web:50]

### Important limitation

Write-through does not automatically handle writes performed outside the application. If another service or administrator updates the database directly, the cache may still contain an old value unless there is invalidation, change-data capture, or another synchronization mechanism.

## 4. Write-behind or write-back pattern

In write-behind caching, the application writes to the cache first. The cache acknowledges the write quickly and persists the change to the database asynchronously later.

```text
Application → Cache → Success returned quickly
                 ↓
          Asynchronous database write
```

### Write flow

```text
1. Application writes the value to the cache.
2. Cache returns success quickly.
3. A worker or queue sends the change to the database.
4. Database eventually becomes current.
```

Example:

```python
def update_counter(key, value):
    cache.set(key, value)
    write_queue.publish({"key": key, "value": value})
    return "accepted"
```

### Pros

- Very low write latency.
- Absorbs bursts of writes.
- Reduces synchronous database write pressure.
- Can combine multiple changes before persistence.
- Useful for counters, telemetry, analytics, and high-volume updates.

### Cons

- Data may be lost if the cache fails before persistence.
- The database is temporarily stale.
- The system must handle retries and failed writes.
- Updates can arrive out of order.
- Recovery after a cache failure is more complex.
- The cache becomes part of the durability path.
- A successful cache response may not mean durable storage succeeded.

### Bottlenecks

- Queue or write-behind worker capacity.
- Database write throughput during flushes.
- Backlog growth when the database is slower than incoming writes.
- Ordering and deduplication logic.
- Recovery and replay after failure.

### Best use cases

Write-behind can work well for:

- Metrics and telemetry.
- View counters.
- Activity streams.
- Session activity where temporary loss is acceptable.
- Shopping or gaming workloads with a separate durability strategy.
- High-volume updates that can tolerate eventual consistency.

### Poor use cases

Avoid write-behind as the only durability mechanism for:

- Payments.
- Account balances.
- Inventory reservations.
- Legal records.
- Financial transactions.
- Data that cannot be reconstructed after cache loss.

Write-behind should use durable queues, acknowledgments, retries, idempotent database writes, monitoring, and a clear recovery strategy when data cannot be lost.

## 5. Write-around pattern

In write-around caching, writes bypass the cache and go directly to the database. The cache is populated only when a later read misses.

```text
Write:
Application → Database

Read:
Application → Cache
                 ├── Hit  → Return value
                 └── Miss → Database → Store in cache
```

### Example

```python
def update_product(product_id, product):
    database.update_product(product_id, product)
    cache.delete(f"product:{product_id}")
```

The updated value is not placed in the cache during the write. If someone reads it later, the first read loads it into the cache.

### Pros

- Avoids caching data that may never be read.
- Keeps write logic simple.
- Reduces cache write traffic.
- Useful for write-heavy workloads with low read-after-write probability.
- Database remains the immediate source of truth.

### Cons

- The first read after a write is a cache miss.
- The first reader pays database latency.
- If an old cache entry is not invalidated, stale data may be returned.
- Frequently written and frequently read data can repeatedly miss.
- Read-after-write latency may be higher.

### Bottlenecks

- Database reads immediately following writes.
- Cache misses for newly written data.
- Invalidation failures for old cache entries.
- Bursts of reads after bulk updates.

### Best use cases

Write-around is useful when:

- Written data is rarely read again.
- The workload is write-heavy.
- Cache pollution is a concern.
- The database must receive writes directly.
- The application can tolerate a miss on the first read.

Examples include bulk imports, archival records, large event streams, and data that is written once but rarely viewed.

## 6. Refresh-ahead pattern

In refresh-ahead caching, the system refreshes an entry before its TTL expires, usually because the entry is popular or likely to be requested again.

```text
Popular cached item
        ↓
Near expiration
        ↓
Background refresh from source
        ↓
New value stored before expiry
```

### Example timeline

```text
TTL: 10 minutes
Refresh threshold: 8 minutes

0 min  → Store value
8 min  → Start background refresh
10 min → New value is already available
```

### Pros

- Reduces user-visible cache misses.
- Improves tail latency for hot keys.
- Avoids many simultaneous database requests at expiration time.
- Keeps frequently used entries warm.
- Works well for predictable access patterns.

### Cons

- May refresh data nobody requests.
- Requires background workers or scheduling.
- Refresh failures need fallback behavior.
- Can increase database read traffic.
- Requires careful coordination to avoid duplicate refreshes.
- The refreshed value may still become stale immediately after loading.

### Bottlenecks

- Background refresh worker capacity.
- Database load caused by refresh jobs.
- Lock contention for popular keys.
- Refresh queues during a large expiration wave.
- Incorrect popularity prediction.

### Best use cases

Refresh-ahead is useful for:

- Popular product pages.
- Frequently accessed configuration.
- Public content with predictable traffic.
- Expensive reports requested regularly.
- Data where predictable latency matters more than minimizing refresh work.

### Refresh-ahead and TTL

Refresh-ahead does not remove the need for TTL. TTL remains a safety mechanism in case refresh fails. A system may serve the old value briefly while a refresh is in progress, but it should define a maximum stale period.

## Combining patterns

Production systems often combine multiple patterns rather than choosing only one.

### Cache-aside plus invalidate-on-write

```text
Read:  Cache → miss → Database → Cache
Write: Database → Delete cache entry
```

This is a common default because it keeps the database as the source of truth and avoids caching values that are never read.

### Cache-aside plus write-through

```text
Read:  Cache → miss → Database → Cache
Write: Update database and cache synchronously
```

This reduces stale data after application-controlled writes but adds write latency.

### Read-through plus refresh-ahead

```text
Read:  Application → Cache
Miss:  Cache loads database
Hot key near expiry: background refresh
```

This can provide predictable read latency while keeping loading logic centralized.

### Write-around plus refresh-ahead

This can be useful when writes should not pollute the cache, but frequently accessed data should be loaded before users experience misses.

### Write-behind plus durable queue

```text
Application → Cache → Durable queue → Database
```

The durable queue reduces data-loss risk compared with relying only on volatile cache memory, but the system still provides eventual rather than immediate database consistency.

## Trade-off dimensions

### Latency

- Cache-aside: fast on hits, slower on misses.
- Read-through: fast on hits, slower on cold misses.
- Write-through: slower writes because both layers must complete.
- Write-behind: fastest writes, but persistence is delayed.
- Write-around: simple writes, but first read may be slow.
- Refresh-ahead: usually stable read latency for hot data.

### Consistency

- Write-through generally provides fresher cache data after controlled writes.
- Cache-aside with invalidation usually provides eventual consistency.
- Write-behind intentionally delays source-of-truth updates.
- Write-around keeps the database current but requires correct invalidation.
- Refresh-ahead improves freshness timing but does not guarantee strong consistency.

### Durability

- Database-first approaches protect data better when the cache fails.
- Write-behind can lose accepted writes unless it uses durable queues or persistence.
- A cache should not be the only durable copy of critical data unless its durability guarantees are explicitly sufficient.

### Cache utilization

- Cache-aside stores only data that has actually been requested.
- Write-through may cache every written item, including items never read.
- Write-around avoids write pollution.
- Refresh-ahead may spend resources refreshing data that is no longer popular.

### Operational complexity

- Cache-aside is easy to start but invalidation can grow complex.
- Read-through centralizes logic but increases cache-layer responsibility.
- Write-through requires coordination between cache and database.
- Write-behind needs queues, retries, ordering, monitoring, and recovery.
- Refresh-ahead needs scheduling and popularity decisions.

## Common bottlenecks and failure modes

### Cache stampede

Many requests miss the same popular key simultaneously and all query the database.

Mitigations:

- Request coalescing.
- Per-key locks.
- Randomized TTLs.
- Refresh-ahead.
- Stale-while-revalidate.
- Prewarming.

### Cache penetration

Requests repeatedly ask for keys that do not exist, causing repeated database queries.

Mitigations:

- Cache negative results for a short TTL.
- Validate input before lookup.
- Use a Bloom filter for large key spaces.
- Apply rate limiting.

### Cache avalanche

Many entries expire at approximately the same time, creating a large miss spike.

Mitigations:

- Add randomized TTL jitter.
- Refresh important keys early.
- Use multiple expiration windows.
- Limit concurrent reloads.

### Stale data

The cache returns an older value than the source of truth.

Mitigations:

- Shorter TTLs.
- Explicit invalidation.
- Versioned cache keys.
- Write-through updates.
- Event-driven invalidation.
- Stale-data bounds.

### Hot key

One cache key receives disproportionate traffic and overloads one cache node or database record.

Mitigations:

- Replicate hot values.
- Shard or split the key.
- Use local caching in front of the distributed cache.
- Apply request coalescing.
- Precompute and distribute the value.

## Choosing a pattern

Use **cache-aside** as the general-purpose default when the application can manage cache logic and short-lived staleness is acceptable.

Use **read-through** when you want the cache or data-access layer to own miss handling and provide a common loading abstraction.

Use **write-through** when application-controlled writes must be visible through the cache immediately and additional write latency is acceptable.

Use **write-behind** when write latency and burst absorption are more important than immediate durability, and the system has reliable persistence and recovery mechanisms.

Use **write-around** when most written data will not be read soon and cache pollution should be avoided.

Use **refresh-ahead** when hot data must have predictable read latency and the cost of refreshing unused items is acceptable.

## Practical decision table

| Requirement | Recommended pattern |
|---|---|
| Simple read caching | Cache-aside |
| Centralized cache-miss logic | Read-through |
| Fresh cache after application writes | Write-through |
| Extremely fast writes | Write-behind, with durable recovery |
| Avoid caching rarely read writes | Write-around |
| Avoid misses for popular keys | Refresh-ahead |
| Strong durability requirement | Database-first write-through or invalidate-on-write |
| Read-heavy, mildly stale data | Cache-aside with TTL |
| High-volume telemetry | Write-behind or batching |
| Critical financial state | Avoid volatile write-behind as the only write path |

## Recommended default design

For many web applications, a practical starting point is:

```text
Read:
  1. Check cache.
  2. On hit, return cached value.
  3. On miss, read database.
  4. Populate cache with a TTL.

Write:
  1. Update database first.
  2. Invalidate the affected cache key.
  3. Optionally publish an invalidation event to other instances.
```

This is cache-aside with database-first invalidation. It keeps the database as the source of truth, avoids caching unused data, and limits the durability risk of the cache.

For a read-heavy endpoint where users must see their own writes immediately, consider write-through or an explicit cache update after the database transaction succeeds. For critical data, do not choose write-behind without a durable queue, idempotent persistence, replay support, and clearly documented failure semantics.

## Final principle

> Choose the simplest caching pattern that meets the required latency, consistency, durability, and cache-efficiency goals.

Caching improves performance, but every pattern introduces a trade-off between speed, freshness, operational complexity, backend load, and failure behavior.


# Cache Invalidation

Cache invalidation is the process of making cached data unavailable or marking it as outdated when the original data changes.

The classic saying is:

> “There are only two hard things in Computer Science: cache invalidation and naming things.”

The difficulty is that a cache contains a copy of data, while the database or source system contains the source of truth. When the source changes, every cached copy must either be updated, deleted, or prevented from being used.

```text
Source of truth changes
        ↓
Cached copy may be stale
        ↓
Invalidate, update, expire, or bypass it
```

If invalidation fails, users may see old prices, incorrect permissions, outdated configuration, or deleted records that still appear to exist.

## Why invalidation is difficult

A production system may have cached copies in several places:

```text
Browser cache
      ↓
CDN cache
      ↓
API Gateway cache
      ↓
Application-local cache
      ↓
Distributed cache
      ↓
Database cache
```

Invalidating one layer does not necessarily invalidate the others. A database update may succeed while a browser, CDN, or application cache continues serving an old response.

Cache invalidation is difficult because:

- There may be multiple cache layers.
- Multiple services may write to the same data.
- One database row may appear in many cached lists or pages.
- Events may be delayed, duplicated, or lost.
- Requests may be in flight while invalidation occurs.
- Cache and database writes are usually not one atomic transaction.
- A cache failure can occur during a source-data update.
- Large-scale invalidation can create a cache-miss storm.

The goal is not always perfect immediate consistency. The goal is to define and enforce an acceptable **maximum staleness window**.

## Stale data example

Suppose a product price is cached:

```text
Database: product:101 → price = 100
Cache:    product:101 → price = 100
```

The product price changes:

```text
Database: product:101 → price = 120
Cache:    product:101 → price = 100  ← stale
```

Until the cache is invalidated, refreshed, or expired, readers may continue to see 100.

## 1. TTL-based expiration

TTL, or **time to live**, allows a cache entry to remain usable for a fixed period. When the TTL expires, the entry is removed or treated as stale, and the next request reloads it from the source.

```text
Store value with TTL
        ↓
Serve cached value while fresh
        ↓
TTL expires
        ↓
Next request reloads source
```

Example:

```python
cache.set("product:101", product, ttl=300)
```

The entry can be used for five minutes. After that, the application should fetch a fresh value.

### Pros

- Simple to implement.
- Provides an automatic safety net.
- Does not require every writer to know about the cache.
- Limits the maximum lifetime of stale data.
- Works well for data where approximate freshness is acceptable.
- Useful when cache entries have many unknown writers.

### Cons

- Data may remain stale until the TTL expires.
- A short TTL increases cache misses and source-system load.
- A long TTL improves hit ratio but increases staleness.
- Many entries expiring together can cause a cache avalanche.
- TTL alone does not provide immediate freshness after an update.

### Bottlenecks and failure modes

- Database overload after mass expiration.
- Thundering herd when many requests reload one expired key.
- Incorrect TTL choices.
- Expiration work consuming cache resources.
- Different cache layers using different TTLs.

### Best practices

Use TTL as a backstop even when using explicit or event-based invalidation. AWS recommends applying a TTL to cache keys in most cases, with exceptions such as values managed through write-through caching. [web:46]

Use TTL jitter to avoid synchronized expiration:

```python
base_ttl = 300
random_jitter = random.randint(0, 60)
cache.set(key, value, ttl=base_ttl + random_jitter)
```

A useful rule is:

```text
Maximum tolerated staleness → upper bound for TTL
```

## 2. Explicit invalidation

**Explicit invalidation** means the application deliberately removes or updates a cache entry when the source data changes.

```text
Update source
      ↓
Invalidate related cache key
      ↓
Next read reloads fresh data
```

Example:

```python
def update_product(product_id, product):
    database.update_product(product_id, product)
    cache.delete(f"product:{product_id}")
```

### Pros

- Can provide near-immediate freshness.
- Makes invalidation behavior visible in application code.
- Works with cache-aside systems.
- Avoids waiting for TTL expiration.
- Deletes data that should no longer be served.

### Cons

- Every write path must remember to invalidate.
- A new writer can accidentally bypass invalidation.
- Related keys may be difficult to discover.
- Distributed local caches require invalidation on every instance.
- The cache and database can diverge if one operation fails.

### Bottlenecks and failure modes

- Invalidation calls can add write latency.
- A cache outage may cause invalidation failures.
- Deleting one key may not remove list, search, or aggregate caches.
- A race can allow an old in-flight read to repopulate a deleted key.
- Large invalidation operations can create a cache-miss storm.

### Update versus delete

Updating the cached value directly may seem efficient:

```text
Update database
Update cache with new value
```

However, delete-on-write is often safer in cache-aside systems:

```text
Update database
Delete cache entry
Next read loads current value
```

Deleting avoids requiring the writer to reconstruct every representation of the data. It also reduces the risk of writing an incomplete or incorrectly formatted cached object.

## 3. Event-based invalidation

**Event-based invalidation** publishes an event when source data changes. Services and cache owners subscribe to the event and invalidate or refresh their local entries.

```text
Database update
      ↓
Publish ProductUpdated event
      ↓
Subscribers receive event
      ↓
Delete or refresh related cache keys
```

Example event:

```json
{
  "event": "ProductUpdated",
  "product_id": "101",
  "version": 8,
  "occurred_at": "2026-10-09T06:30:00Z"
}
```

Possible event sources include:

- Application domain events.
- Transactional outbox events.
- Change data capture.
- Database streams.
- Message queues.
- Pub/sub systems.

### Pros

- Works across multiple application instances and services.
- Decouples writers from all cache consumers.
- Supports local-cache invalidation in a distributed deployment.
- Can react quickly to changes.
- Can invalidate several representations of one entity.
- Supports auditability and replay when backed by a durable log.

### Cons

- More infrastructure and operational complexity.
- Events can be delayed.
- Events can arrive more than once.
- Events can be lost if publishing is not reliable.
- Subscribers must be idempotent.
- Ordering can be difficult across partitions or services.
- The system is eventually consistent while events are in flight.

### Bottlenecks and failure modes

- Message queue backlog.
- Slow subscribers.
- Duplicate invalidation events.
- Out-of-order updates.
- Poison messages that repeatedly fail.
- Event publication succeeding or failing separately from the database transaction.

### Reliable event publication

A common design is the **transactional outbox**:

```text
1. Update database row.
2. Insert invalidation event into an outbox table in the same transaction.
3. A publisher reads the outbox.
4. Publish event to the message system.
5. Mark the outbox event as published.
```

This reduces the dual-write problem where the database update succeeds but event publication fails.

### Event consumer requirements

Consumers should be:

- Idempotent: processing the same event twice is safe.
- Retryable: temporary failures can be retried.
- Observable: failures and lag are measurable.
- Version-aware: older events do not overwrite newer state.
- Able to rebuild: cache state can be reconstructed from the source.

Events may arrive late, so event-based invalidation should usually be paired with a TTL safety net. [web:60][web:64]

## 4. Version-based invalidation

**Version-based invalidation** changes the cache key or namespace when the source data changes. Instead of deleting every old entry, the system makes old entries unreachable.

Example:

```text
Before update:
product:101:v7

After update:
product:101:v8
```

The application now reads only version 8. Version 7 may remain in the cache until TTL expiration or eviction, but no new request uses it.

### Key-version example

```python
def get_product(product_id):
    version = metadata.get(f"product-version:{product_id}")
    key = f"product:{product_id}:v{version}"
    return cache.get(key)
```

On update:

```python
def update_product(product_id, product):
    database.update_product(product_id, product)
    metadata.increment(f"product-version:{product_id}")
```

### Namespace versioning

For a group of related values, use a namespace version:

```text
catalog:v12:product:101
catalog:v12:product:102
catalog:v12:category:books
```

When the catalog changes substantially:

```text
catalog:v13:product:101
```

All old `catalog:v12:*` keys become unreachable without requiring a large delete operation.

### Pros

- Avoids scanning and deleting many keys.
- Reduces deletion race conditions.
- Useful for bulk configuration or catalog changes.
- Makes old and new versions distinguishable.
- Old readers can finish using the old version safely.
- New readers use the new version immediately after the version change.

### Cons

- Old entries still consume memory until TTL or eviction.
- Requires version metadata to be read reliably.
- Version increments must be atomic.
- Cache keys become more complex.
- Multiple related versions require coordination.
- Version storage can become a bottleneck for extremely high-volume reads.

### Bottlenecks and failure modes

- Stale version metadata can point readers to an old namespace.
- A failed version update can leave the application using the old key.
- Large numbers of old versions can consume capacity.
- Version changes can trigger mass cache misses.
- Concurrent updates need monotonic or conflict-aware version handling.

Version-based invalidation makes stale keys unreachable rather than physically deleting them. [web:62]

## 5. Write-through invalidation

In a write-through design, the cache is updated as part of the write path, and the underlying data store is updated synchronously before the operation is considered complete.

```text
Application
    ↓
Cache write
    ↓
Database write
    ↓
Return success
```

In some systems, the database is updated first and the cache is synchronously refreshed. The important property is that the write path actively keeps the cached representation aligned with the source.

Example:

```python
def update_product(product_id, product):
    database.update_product(product_id, product)
    cache.set(f"product:{product_id}", product, ttl=3600)
```

### Pros

- The cache contains the new value immediately after a successful controlled write.
- Reduces stale reads after writes.
- Avoids a cache miss on the next read.
- Useful when the same data is read frequently after updates.
- Can provide predictable read performance.

### Cons

- Writes are slower because cache and database work are both required.
- The cache may be populated with data that is never read.
- The cache and database are not automatically one atomic transaction.
- A cache failure can complicate write success semantics.
- External database writers can bypass the cache update.
- Related cached lists and aggregates may remain stale.

### Bottlenecks and failure modes

- Synchronous cache network latency.
- Database write latency.
- Cache write failures after database success.
- Retry and duplicate-write behavior.
- Large values requiring expensive serialization.
- Multiple writers producing out-of-order updates.

### Handling partial failure

If the database update succeeds but the cache update fails, possible strategies include:

- Delete the cache key instead of leaving a potentially stale value.
- Retry the cache update asynchronously.
- Publish an invalidation event.
- Return success while recording repair work.
- Fail the operation only when cache consistency is a strict requirement.

For critical data, the database should remain the source of truth. The cache should be rebuildable.

## 6. Delete-on-write

**Delete-on-write** means the application updates the source of truth and then deletes the related cache entry.

```text
1. Update database.
2. Delete cache key.
3. Next read fetches the current value.
4. Store the current value in cache.
```

Example:

```python
def update_product(product_id, product):
    database.update_product(product_id, product)
    cache.delete(f"product:{product_id}")
```

This is one of the most common invalidation strategies for cache-aside systems.

### Why delete instead of update?

Deleting is often safer than updating the cached object because:

- The next read obtains the value from the source of truth.
- The writer does not need to build every cached representation.
- It avoids caching partially updated data.
- It handles serialization and transformation in one read path.
- It avoids keeping data cached if nobody reads it again.
- It can invalidate a value without knowing how it was constructed.

### Pros

- Simple and easy to understand.
- Keeps the database as the source of truth.
- Provides near-immediate invalidation.
- Avoids cache pollution after writes.
- Works well with cache-aside.
- Safer than update-on-write for many derived values.

### Cons

- The next read is slower because it must reload the value.
- If deletion fails, stale data can remain.
- Every writer must perform the deletion.
- Related list and aggregate keys may be missed.
- Multiple cache layers require multiple invalidation operations.
- A race can repopulate stale data after deletion.

### Critical race condition

Consider this sequence:

```text
T1: Reader reads old value from database
T2: Writer updates database with new value
T3: Writer deletes cache key
T4: Reader stores old value in cache
```

The cache now contains stale data again, even though the writer deleted it.

Possible solutions include:

- Use versioned keys.
- Use per-key locks.
- Read from the database after invalidation-sensitive writes.
- Store a version with the cached value.
- Use compare-and-set operations.
- Use event-based invalidation with version checks.
- Keep a TTL as a safety net.

## Delete-on-write versus update-on-write

| Concern | Delete-on-write | Update-on-write |
|---|---|---|
| Write complexity | Lower | Higher |
| Next-read latency | Usually higher on first read | Usually lower |
| Cache pollution | Lower | Higher |
| Derived/list values | Easier to invalidate | Harder to update correctly |
| Stale race risk | Possible | Possible if writes reorder |
| Source of truth | Database remains primary | Cache is actively synchronized |
| Common use | Cache-aside | Write-through or controlled read-heavy paths |

## Invalidation strategy comparison

| Strategy | Freshness | Complexity | Source load | Main risk |
|---|---:|---:|---:|---|
| TTL | Bounded by TTL | Low | Misses at expiry | Stale until expiry |
| Explicit invalidation | Near-immediate | Medium | Reload after delete | Missed invalidation |
| Event-based | Near-immediate after event | High | Controlled by subscribers | Delay, loss, duplicates |
| Version-based | Immediate for new reads | Medium to high | Misses after version change | Old entries consume memory |
| Write-through | Very fresh after controlled writes | High | Extra cache and DB writes | Partial failure and latency |
| Delete-on-write | Near-immediate if delete succeeds | Low to medium | One reload per later read | Delete/read race |

## Handling related cache entries

One database entity often appears in many cached objects:

```text
product:101
products:category:books:page:1
search:books:page:1
homepage:featured-products
recommendations:user:42
```

Updating `product:101` may make all of these stale. Invalidating only the direct object key is insufficient if the application also caches lists, search results, aggregates, or rendered pages.

Common solutions include:

- Maintain an explicit dependency map.
- Use cache tags or namespaces.
- Invalidate broad groups with a version number.
- Use event consumers that know affected keys.
- Use shorter TTLs for derived lists.
- Avoid caching highly mutable aggregates.
- Recompute materialized views asynchronously.

## Multi-layer invalidation

A system with browser, CDN, gateway, and application caches needs a clear invalidation plan:

```text
Database update
      ↓
Application cache invalidation
      ↓
API Gateway purge
      ↓
CDN purge or versioned URL
      ↓
Browser receives new URL or revalidates
```

Versioned URLs are especially useful for static assets:

```text
app.v1.js → app.v2.js
```

Instead of purging every browser and CDN copy, the application references a new URL. Old assets can expire naturally. AWS recommends short TTLs for entry documents such as `index.html` and long TTLs for immutable, versioned JavaScript and CSS assets. [web:58]

## Best practices

### Always use a safety TTL

Even with explicit, event-based, or write-through invalidation, a TTL prevents a missed invalidation from lasting forever. [web:62][web:66]

### Invalidate after source success

For delete-on-write:

```text
Update database successfully
        ↓
Delete cache entry
```

Do not delete the cache first unless the system is designed to tolerate a temporary empty or inconsistent state.

### Make invalidation idempotent

Deleting the same key twice should be safe. Processing the same event twice should produce the same result as processing it once.

### Include versions in events

An event should include an entity version or update timestamp:

```json
{
  "entity_id": "101",
  "version": 8
}
```

A consumer can ignore an older event that arrives after a newer one.

### Protect against stampedes

Use request coalescing, locks, refresh-ahead, TTL jitter, or stale-while-revalidate behavior for popular keys.

### Measure invalidation lag

Monitor:

- Time from database commit to cache invalidation.
- Event queue delay.
- Event processing failures.
- Number of stale reads.
- Cache miss spikes.
- Rebuild latency.
- Keys deleted, refreshed, or expired.
- Cache memory held by old versions.

### Document freshness guarantees

Define statements such as:

```text
Product prices are refreshed within 30 seconds.
Permission changes propagate within 5 seconds.
Analytics counters may be delayed by 60 seconds.
Payment state is read from the source of truth.
```

This is more useful than saying that a system is simply “eventually consistent.”

## Recommended production pattern

For many systems, a robust default is:

```text
1. Database remains the source of truth.
2. Read through cache using cache-aside.
3. On successful write, delete affected cache keys.
4. Publish an invalidation event for other cache owners.
5. Use TTL as a safety net.
6. Add versioning for large groups or bulk changes.
7. Protect hot keys from stampedes.
8. Monitor invalidation lag and stale-read behavior.
```

This layered approach combines:

- Delete-on-write for immediate local freshness.
- Event-based invalidation for multi-instance or multi-service consistency.
- TTL for recovery from missed events or bugs.
- Versioning for bulk invalidation and race avoidance.

## Final principle

> Cache invalidation is a consistency design problem, not merely a cache command.

Choose the invalidation method according to the data’s freshness, durability, and scale requirements:

- Use **TTL** when bounded staleness is acceptable.
- Use **explicit invalidation** when the writer knows which keys changed.
- Use **event-based invalidation** when multiple services or instances must react.
- Use **version-based invalidation** for bulk changes and large key groups.
- Use **write-through invalidation** when controlled writes must keep the cache fresh.
- Use **delete-on-write** as a simple and reliable cache-aside strategy.

For most production systems, combine explicit or event-based invalidation with a TTL backstop rather than relying on only one technique.



# Cache Eviction Policies

A **cache eviction policy** determines which cached entries should be removed when the cache reaches its memory or item limit.

Eviction is different from expiration:

- **Expiration:** An entry becomes invalid because its TTL has elapsed.
- **Eviction:** An entry is removed because the cache needs space or follows a configured policy.

```text
Cache reaches capacity
        ↓
Eviction policy selects entries
        ↓
Selected entries are removed
        ↓
New data can be stored
```

Redis describes eviction policies as the rules used when a database reaches its memory limit. Common choices include LRU, LFU, and TTL-based policies. [web:70][web:72]

## Why eviction is needed

Cache memory is limited. If applications continue adding keys without removing old ones, the cache eventually cannot accept new data.

Eviction helps the cache:

- Stay within its memory limit.
- Make room for new entries.
- Retain valuable hot data.
- Remove cold or low-value data.
- Prevent uncontrolled memory growth.
- Maintain predictable behavior under load.

Eviction is especially important when the working set is larger than the available cache capacity.

## Basic example

Assume a cache can hold only three entries:

```text
Cache capacity: 3 entries

product:1 → accessed frequently
product:2 → accessed recently
product:3 → not accessed recently
```

A new entry arrives:

```text
product:4 → new value
```

The cache must remove one existing entry. If it uses LRU and `product:3` is the least recently used, the result becomes:

```text
Evict product:3

product:1 → retained
product:2 → retained
product:4 → inserted
```

## Eviction versus TTL expiration

Consider a key with a 30-minute TTL:

```text
product:101 → TTL 30 minutes
```

Two different things can happen:

### Expiration

After 30 minutes, the key expires naturally because its allowed lifetime has ended.

### Eviction

After five minutes, the cache reaches its memory limit and removes `product:101` even though 25 minutes remain on its TTL.

Therefore:

> TTL controls validity over time, while eviction controls storage pressure.

A key can be evicted before its TTL expires, and a key can expire even if the cache has plenty of free memory.

## Main eviction policies

### 1. LRU: Least Recently Used

LRU removes the entry that has not been accessed for the longest time.

```text
Most recently used                         Least recently used
product:4 → product:2 → product:1 → product:3
                                           ↑ evict first
```

Example:

```text
Cache capacity: 3

Initial cache:
A, B, C

Access order:
A, B, A, C

Recency order:
C → A → B

New key D arrives:
Evict B
Store D
```

LRU assumes that recently accessed data is more likely to be accessed again soon.

#### Advantages

- Good general-purpose policy.
- Retains recently accessed data.
- Works well for workloads with temporal locality.
- Easy to understand.
- Suitable when recent access is a strong indicator of future access.

#### Disadvantages

- A single scan over many unique keys can evict valuable hot entries.
- It may retain data accessed once recently even if it is not truly popular.
- It does not directly measure frequency.
- Maintaining access metadata consumes resources.

#### Good use cases

- Web pages.
- API responses.
- User profiles.
- Frequently accessed objects.
- General-purpose application caches.

Redis provides `allkeys-lru` to evict the least recently used keys regardless of whether they have a TTL, and `volatile-lru` to apply LRU only to keys with expiration configured. [web:70][web:77]

### 2. LFU: Least Frequently Used

LFU removes entries that have been accessed the fewest times.

```text
Key       Access count
A         1      ← evict first
B         15
C         100
```

Example:

```text
Cache capacity: 3

A accessed 2 times
B accessed 20 times
C accessed 50 times

New key D arrives

LFU evicts A because it has the lowest access frequency.
```

LFU assumes that frequently accessed data is more likely to remain valuable in the future.

#### Advantages

- Protects consistently popular hot keys.
- Works well when popularity is stable.
- Less vulnerable than LRU to a single recent scan evicting hot data.
- Useful for skewed workloads where a small number of keys receive most requests.

#### Disadvantages

- A key that was popular in the past may remain protected after becoming cold.
- Requires frequency counters or approximations.
- More complex than simple FIFO or LRU.
- A newly inserted key has a low frequency and may be evicted quickly.
- Access counts may need aging so old popularity does not last forever.

#### Good use cases

- Product catalogs with stable popular products.
- Frequently used configuration.
- Popular API responses.
- Content with a highly skewed access distribution.

Redis provides `allkeys-lfu` for all keys and `volatile-lfu` for only keys with an expiration time. [web:70][web:78]

### 3. FIFO: First In, First Out

FIFO removes the oldest inserted entry, regardless of how recently or frequently it was accessed.

```text
Inserted first → A → B → C → D ← inserted last
                  ↑
                evict first
```

Example:

```text
Cache capacity: 3

Insert A, B, C
Insert D

Evict A
Cache becomes B, C, D
```

#### Advantages

- Simple to implement.
- Low metadata overhead.
- Predictable insertion-order behavior.
- Useful when data has a natural lifetime or queue-like behavior.

#### Disadvantages

- Can remove frequently accessed entries.
- Does not consider recency or frequency.
- A very old but still valuable key is evicted simply because of age.
- Usually less effective than LRU or LFU for general-purpose caching.

#### Good use cases

- Queue-like temporary data.
- Streaming windows.
- Write-once, read-once data.
- Workloads where insertion order closely matches usefulness.

## 4. Random eviction

Random eviction removes an arbitrary entry.

```text
Cache: A, B, C, D
New key E arrives
Randomly select C
Evict C and store E
```

#### Advantages

- Very simple.
- Low metadata overhead.
- Fast eviction decisions.
- Can be adequate when all entries have similar value.

#### Disadvantages

- May remove the most valuable hot key.
- Ignores usage patterns.
- Hit ratio can be worse for skewed workloads.
- Results are less predictable.

#### Good use cases

- Approximate caches.
- Workloads with uniform access patterns.
- Systems where eviction decision speed matters more than maximum hit ratio.
- Fallback behavior under severe memory pressure.

## 5. TTL-based eviction

TTL-based eviction prioritizes entries according to their remaining time to live.

A policy such as `volatile-ttl` removes the key with the shortest remaining TTL among keys that have an expiration set. [web:70][web:72]

Example:

```text
Key       Remaining TTL
A         600 seconds
B         30 seconds   ← evict first
C         300 seconds
```

When space is needed, `B` is selected because it is closest to expiration.

#### Advantages

- Removes entries that will soon become invalid anyway.
- Aligns eviction with data freshness.
- Useful when TTL represents data importance or validity.
- Reduces wasted work evicting long-lived values that remain valid.

#### Disadvantages

- Does not consider popularity.
- A highly popular key with a short TTL may be evicted.
- Requires expiration metadata.
- A short TTL may cause frequent reloads.
- Entries without TTL may not be eligible under volatile policies.

#### Good use cases

- Session data.
- Short-lived API responses.
- Temporary tokens.
- Time-sensitive content.
- Caches where all eligible entries have TTLs.

## 6. No-eviction policy

A **no-eviction** policy rejects new writes when the cache reaches its limit instead of removing existing entries.

```text
Cache is full
    ↓
New write arrives
    ↓
Write rejected
```

#### Advantages

- Existing entries are never removed automatically.
- Useful when eviction could corrupt or violate application behavior.
- Forces the application to manage capacity explicitly.
- Makes capacity exhaustion visible as an error.

#### Disadvantages

- New requests may fail.
- Applications must handle write errors.
- The cache cannot absorb sudden growth.
- It is unsuitable for most disposable read caches.

#### Good use cases

- Systems where automatic deletion is unsafe.
- Carefully managed coordination data.
- Applications that have explicit backpressure and cleanup logic.

For ordinary disposable caches, a controlled eviction policy is often preferable to rejecting all new cache writes.

## Redis policy families

Redis-style policies commonly use two prefixes:

- `allkeys`: Any key can be selected.
- `volatile`: Only keys with an expiration or TTL can be selected.

| Policy | Behavior |
|---|---|
| `allkeys-lru` | Evict least recently used keys from all keys |
| `allkeys-lfu` | Evict least frequently used keys from all keys |
| `volatile-lru` | Evict least recently used keys that have TTLs |
| `volatile-lfu` | Evict least frequently used keys that have TTLs |
| `volatile-ttl` | Evict keys with the shortest remaining TTL |
| `noeviction` | Reject writes when memory is full |

Redis documents these policies and their distinction between all keys and TTL-bearing keys. [web:70][web:71]

### Important volatile-policy warning

If a cache uses a `volatile-*` policy but some keys do not have TTLs, those keys may not be eligible for eviction. If all remaining keys lack expiration, new writes can fail even though the configured policy expects TTL-based candidates.

This is why TTL coverage should be intentional and monitored.

## LRU versus LFU

| Characteristic | LRU | LFU |
|---|---|---|
| Measures | Recent access time | Access frequency |
| Protects | Recently used items | Frequently used items |
| Best for | Changing or temporal workloads | Stable hot-key workloads |
| Handles one-time scans | Less effectively | Often better |
| Handles popularity changes | Usually better | May need aging |
| Complexity | Moderate | Higher |
| Typical choice | General-purpose default | Stable skewed access patterns |

### Example comparison

Cache capacity is two entries. Access sequence:

```text
A, A, A, B, C
```

At the end:

- A has high frequency but was not accessed recently.
- B was accessed more recently than A but only once.
- C is the newest entry.

An LRU policy may keep `B` and `C`, evicting `A`. An LFU policy may keep `A` and one of the newer keys, because `A` has the highest frequency.

Which is better depends on whether recent activity or long-term popularity predicts future requests.

## Example: choosing a policy

Assume a product API has the following workload:

```text
product:popular-1   → 100,000 requests/hour
product:popular-2   → 80,000 requests/hour
product:seasonal-1  → 2,000 requests/hour
product:random-999  → 1 request/hour
```

### LRU choice

LRU keeps items accessed recently. It works well if users browse products in sessions and recently viewed items are likely to be requested again.

### LFU choice

LFU protects the consistently popular products. It works well if `popular-1` and `popular-2` remain hot over time.

### TTL choice

TTL-based eviction is useful if seasonal or temporary product data should naturally disappear soon, but it does not know which product receives the most traffic.

### Practical choice

A common approach is:

```text
allkeys-lfu + TTL on every cache entry
```

This retains frequently accessed values under memory pressure while TTL provides a freshness and cleanup guarantee. The exact policy should be validated using real workload metrics.

## Eviction bottlenecks and failure modes

### Cache churn

Cache churn occurs when entries are repeatedly inserted and evicted before they can produce many hits.

```text
Insert A → Evict A → Insert A again → Evict A again
```

Symptoms include:

- Low hit ratio.
- High eviction rate.
- High database or origin load.
- Many cache misses.
- Memory constantly near its limit.

Possible causes:

- Cache is too small.
- Working set is larger than capacity.
- Poor eviction policy.
- Large values consume memory quickly.
- Many keys are accessed only once.

### Hot-key overload

An eviction policy may retain a very popular key, but that key can overload one cache node or backend record.

Mitigations include:

- Replicate hot keys.
- Add local caching in front of the distributed cache.
- Split the key into shards.
- Use request coalescing.
- Precompute and distribute the value.

### Eviction storm

A sudden traffic increase can cause continuous eviction and refilling.

Mitigations include:

- Increase cache capacity.
- Reduce object size.
- Tune TTLs.
- Add admission control.
- Use a better policy for the workload.
- Reduce cache pollution from low-value requests.

### Cache stampede after eviction

If a popular entry is evicted, many requests may miss simultaneously and query the database.

Mitigations include:

- Per-key locks.
- Request coalescing.
- Refresh-ahead.
- Stale-while-revalidate.
- Negative caching.
- TTL jitter.

## Eviction and cache admission

Eviction decides which existing item to remove. **Admission control** decides whether a new item should be admitted at all.

For example, an application might avoid caching a response that was accessed only once:

```text
First request → Read from database
Second request → Consider adding to cache
```

Admission control can reduce pollution caused by one-time requests, but it adds complexity and may delay useful entries from being cached.

## Best practices

### Choose a policy based on workload

Do not select LRU or LFU only because it is popular. Measure access patterns and compare hit ratio, miss ratio, eviction rate, and backend load.

### Use TTL with eviction

Eviction handles capacity pressure. TTL handles freshness and cleanup. They solve different problems and are commonly used together.

### Keep a memory safety margin

Do not plan to use every available byte. Reserve memory for:

- Cache metadata.
- Replication.
- Fragmentation.
- Connection buffers.
- Internal data structures.
- Traffic spikes.

### Monitor evictions

Important metrics include:

- Eviction count.
- Eviction rate.
- Hit ratio.
- Miss ratio.
- Memory utilization.
- Key count.
- Average object size.
- Backend requests caused by misses.
- Cache churn.

A high eviction rate is not automatically bad. It may be normal for a bounded cache, but it is concerning when accompanied by a falling hit ratio or increased backend load.

### Avoid caching very large objects blindly

A few large objects can displace many useful small objects. Consider:

- Maximum object size.
- Compression.
- Splitting objects.
- Separate caches for large and small values.
- Excluding rarely reused large responses.

### Do not use eviction as invalidation

Eviction is capacity-driven and unpredictable from a freshness perspective. Do not rely on an entry eventually being evicted to remove sensitive or stale data. Use explicit invalidation, versioning, or TTL as appropriate.

## Choosing the right policy

Use **LRU** when recent access is the best predictor of near-future access and the workload changes frequently.

Use **LFU** when a stable set of hot keys receives most traffic and long-term popularity matters more than recency.

Use **FIFO** when insertion order reflects usefulness or when a simple low-overhead policy is sufficient.

Use **random eviction** when all entries have approximately equal value and eviction decisions must be extremely cheap.

Use **TTL-based eviction** when entries closest to expiry should be removed first and all eligible entries have meaningful expiration times.

Use **no eviction** only when rejected writes are acceptable and the application deliberately manages capacity.

## Final example

Suppose an API cache has a 1 GB limit and stores product responses:

```text
Cache policy: allkeys-lfu
TTL: 10 minutes plus random jitter
Capacity: 1 GB
```

When the cache is full:

```text
1. Select a low-frequency key.
2. Evict it.
3. Insert the new response.
4. Continue serving hot keys from memory.
```

If a product response is not requested for ten minutes, its TTL expires. If memory becomes full before that, LFU may evict it earlier. If a popular key expires, request coalescing or refresh-ahead can prevent many requests from hitting the database at once.

The key principle is:

> Eviction decides what to remove under capacity pressure; TTL and invalidation decide how long data is allowed to remain valid.


# Cache Stampede, Penetration, and Avalanche

Caching improves performance, but poorly protected caches can create serious backend failures. Three important failure modes are:

1. **Cache stampede**, also called cache breakdown or thundering herd.
2. **Cache penetration**.
3. **Cache avalanche**.

These problems have different triggers and require different protections.

| Problem | Trigger | Main impact | Primary defense |
|---|---|---|---|
| Cache stampede | One popular key expires or is invalidated | Many identical requests hit the source together | Request coalescing, locks, stale-while-revalidate |
| Cache penetration | Requests target data that does not exist | Repeated invalid lookups bypass the cache | Validation, negative caching, Bloom filters |
| Cache avalanche | Many keys expire together or cache infrastructure fails | Broad wave of misses overloads backend systems | TTL jitter, gradual warming, high availability |

A cache stampede occurs when a frequently used cache entry expires and too many requests try to repopulate it simultaneously. Cache penetration occurs when requested data exists in neither the cache nor the database. Cache avalanche is a broader failure in which many entries expire together or a cache tier becomes unavailable. [web:85][web:87][web:97]

## 1. Cache stampede

A **cache stampede** occurs when one popular cache key expires or is removed, and many concurrent requests all discover the miss at approximately the same time.

It is also called:

- Cache breakdown.
- Thundering herd.
- Dogpile effect.

### Normal cache miss

Normally, one request misses and repopulates the cache:

```text
Request 1 → Cache miss → Database → Store value in cache
Request 2 → Cache hit
Request 3 → Cache hit
```

### Stampede scenario

Suppose a popular product page is stored under `product:101`:

```text
product:101 → cached product data
```

The entry expires at 12:00:00. At exactly that time, 10,000 users request the product:

```text
Request 1     ─┐
Request 2      ├── Cache miss ── Database
Request 3      ├── Cache miss ── Database
Request 4      ├── Cache miss ── Database
...            ├── Cache miss ── Database
Request 10,000─┘
```

All requests attempt to rebuild the same value. The cache was intended to protect the database, but the expiration event causes a sudden database spike.

### Example calculation

Assume:

```text
1 popular key
20,000 requests per second
Cache entry expires
Database query takes 50 ms
```

If every request independently queries the database during the rebuild window, thousands of duplicate queries may be in flight at once. Connection pools, CPU, locks, and database I/O can become saturated.

### Symptoms

- Sudden database CPU increase.
- Many simultaneous identical queries.
- Increased p95 and p99 latency.
- Cache miss spike for one key.
- Database connection-pool exhaustion.
- Timeouts and retries.
- Cascading failures in dependent services.

### Prevention: request coalescing

Allow only one request to rebuild a missing key. Other requests wait for the same result.

```python
def get_product(product_id):
    key = f"product:{product_id}"
    value = cache.get(key)

    if value is not None:
        return value

    with singleflight(key):
        value = cache.get(key)
        if value is not None:
            return value

        value = database.get_product(product_id)
        cache.set(key, value, ttl=300)
        return value
```

The second cache check inside the lock is important. Another request may have populated the cache while the current request was waiting.

### Prevention: distributed lock

For a distributed cache, use a per-key lock:

```text
1. Request A acquires lock for product:101.
2. Request A loads the database value.
3. Request A writes product:101 to the cache.
4. Request A releases the lock.
5. Requests B–N wait or read the newly cached value.
```

The lock should have:

- A short expiration.
- Ownership checking.
- Safe release behavior.
- Retry limits.
- Failure handling.

Do not use one global lock for every key. That serializes unrelated requests and becomes a bottleneck. Use a lock per hot key or a partitioned locking scheme.

### Prevention: stale-while-revalidate

Return a slightly stale value while one background task refreshes the cache.

```text
Cached value is logically expired
        ↓
Return old value temporarily
        ↓
One background refresh loads the new value
        ↓
Replace cached value
```

This reduces user-visible latency but requires an explicit maximum-stale policy. It should not be used for data that must be strongly consistent.

### Prevention: refresh-ahead

Refresh a hot entry before its TTL expires:

```text
TTL: 10 minutes
Refresh threshold: 8 minutes

At 8 minutes → background refresh starts
At 10 minutes → refreshed value is already available
```

Refresh-ahead is effective for popular, predictable keys but can waste database resources refreshing values that no one requests.

### Prevention: TTL jitter

Avoid giving many related keys exactly the same expiration time:

```python
actual_ttl = 300 + random.randint(0, 60)
cache.set(key, value, ttl=actual_ttl)
```

TTL jitter is more important for preventing an avalanche, but it can also reduce synchronized expiration of related hot keys.

### Stampede trade-offs

| Technique | Benefit | Cost or risk |
|---|---|---|
| Request coalescing | Only one rebuild per key | Waiting requests may experience latency |
| Distributed lock | Works across instances | Lock failure and timeout complexity |
| Stale-while-revalidate | Very low read latency | Temporarily stale data |
| Refresh-ahead | Avoids expiration misses | May refresh unused data |
| Permanent hot-key cache | Avoids expiration | Requires explicit update or invalidation |

## 2. Cache penetration

**Cache penetration** occurs when requests target data that does not exist in either the cache or the source database.

Because the value does not exist, the application cannot populate a normal positive cache entry. Every request repeats the same invalid lookup.

```text
Request for missing-id-999
        ↓
Cache miss
        ↓
Database lookup: not found
        ↓
Nothing useful stored
        ↓
Next request repeats the same process
```

### Example

An API receives requests for user IDs:

```text
GET /users/42       → User exists
GET /users/99999999 → User does not exist
```

An attacker or buggy client repeatedly requests random IDs:

```text
GET /users/abc123
GET /users/def456
GET /users/ghi789
GET /users/jkl012
```

Every request misses the cache and reaches the database. The attacker does not need to find valid data; they only need to create repeated misses.

### Symptoms

- High cache miss ratio.
- Large number of database queries returning empty results.
- Many unique or random cache keys.
- Database load increases without corresponding successful reads.
- Traffic may resemble scanning or abuse.
- Cache memory may be polluted with low-value keys if negative caching is not controlled.

### Prevention: input validation

Reject clearly invalid identifiers before checking the cache or database:

```python
if not is_valid_user_id(user_id):
    return 400, "Invalid user ID"
```

Examples of validation include:

- Correct identifier format.
- Valid length.
- Allowed character set.
- Numeric range.
- Valid tenant or partition.

Input validation is inexpensive and should be the first defense.

### Prevention: negative caching

Store a short-lived marker for a confirmed missing value.

```python
def get_user(user_id):
    key = f"user:{user_id}"
    value = cache.get(key)

    if value == "NOT_FOUND":
        return None

    if value is not None:
        return value

    user = database.get_user(user_id)

    if user is None:
        cache.set(key, "NOT_FOUND", ttl=30)
        return None

    cache.set(key, user, ttl=300)
    return user
```

Negative entries should usually have a shorter TTL than positive entries because a missing record may be created later.

```text
Existing user:  TTL 5 minutes
Missing user:   TTL 30 seconds
```

### Negative caching risks

- A record created shortly after a negative cache entry may remain hidden until the negative TTL expires.
- Attackers can generate many unique nonexistent keys.
- Negative entries can consume memory.
- A `NOT_FOUND` marker must not be confused with a valid stored value.

Use bounded negative caching, validation, rate limiting, and a suitable eviction policy together.

### Prevention: Bloom filter

A **Bloom filter** is a space-efficient probabilistic data structure that tests whether an item may exist in a known set.

```text
Request ID
    ↓
Bloom filter
    ├── Definitely not present → Reject or skip database
    └── Possibly present       → Check cache and database
```

Bloom filters can produce false positives but not false negatives under normal operation:

- “Definitely absent” means the item can safely be rejected.
- “Possibly present” means the application must continue checking.

Example:

```python
if not user_id_filter.might_contain(user_id):
    return None

return get_user_from_cache_or_database(user_id)
```

A Bloom filter must be updated when new records are created. Deletions require a counting Bloom filter or periodic rebuild if the data set changes significantly.

### Prevention: rate limiting

Limit requests by:

- IP address.
- User identity.
- API key.
- Tenant.
- Endpoint.
- Time window.

Rate limiting reduces the amount of invalid traffic that can reach the application and database.

### Prevention: authorization and existence checks

Do not let clients freely probe sensitive identifiers. Use authorization checks, opaque identifiers, and consistent error behavior where appropriate.

### Penetration trade-offs

| Technique | Benefit | Cost or risk |
|---|---|---|
| Input validation | Very cheap early rejection | Cannot detect all nonexistent but valid-format IDs |
| Negative caching | Prevents repeated misses | May hide newly created data briefly |
| Bloom filter | Avoids many impossible database lookups | Probabilistic structure requires maintenance |
| Rate limiting | Controls abusive traffic | Legitimate clients may be throttled |
| Opaque IDs | Makes enumeration harder | Does not replace validation or authorization |

## 3. Cache avalanche

A **cache avalanche** occurs when a large number of cache entries become unavailable at approximately the same time, causing a broad wave of requests to reach backend systems.

Common causes include:

- Many keys share the same TTL and expire together.
- A cache cluster restarts.
- A cache node fails.
- A mass invalidation deletes a large key group.
- A deployment flushes the cache.
- Network failures make the cache unreachable.

### Example: synchronized TTLs

Suppose a batch job loads one million entries at 12:00 with the same 24-hour TTL:

```text
12:00 on Monday → Load all entries
12:00 on Tuesday → All entries expire
```

At 12:00 Tuesday, many requests miss simultaneously:

```text
1,000,000 expired keys
        ↓
Large cache-miss wave
        ↓
Database receives unexpected read load
        ↓
Database slows or fails
        ↓
Requests retry
        ↓
Load increases further
```

### Example: cache outage

```text
Normal:
Application → Cache hit → Fast response

Cache cluster fails:
Application → Cache unavailable → Database for every request
```

Even entries that have not expired are effectively unavailable, so the origin receives traffic normally handled by the cache.

### Symptoms

- Cache miss rate rises across many keys.
- Backend request rate suddenly increases.
- Database CPU, I/O, or connection usage spikes.
- Many endpoints slow down at the same time.
- Cache errors or timeouts appear.
- Retries amplify the traffic.
- Multiple services fail together.

### Prevention: TTL jitter

Add a random offset to expiration times:

```python
base_ttl = 3600
jitter = random.randint(0, 600)
cache.set(key, value, ttl=base_ttl + jitter)
```

Instead of all keys expiring after exactly one hour, they expire across a ten-minute window.

### Prevention: gradual cache warming

After deployment, restart, or bulk invalidation, do not load every key at once. Warm the cache gradually:

```text
1. Load top 1% of hot keys.
2. Observe backend load.
3. Load the next group.
4. Continue until the cache is sufficiently warm.
```

Prioritize:

- Most requested keys.
- Public configuration.
- High-value pages.
- Known hot products.
- Data required for startup.

### Prevention: high availability

Use replication, failover, clustering, multi-zone deployment, and health checks where the cache is critical to system performance.

High availability does not eliminate all misses, but it reduces the chance that one cache-node failure turns into a full cache outage.

### Prevention: fallback behavior

If the cache is unavailable:

- Use a database fallback with strict rate limits.
- Serve stale data when safe.
- Use a local in-memory fallback for critical small values.
- Apply circuit breakers.
- Shed nonessential traffic.
- Return controlled errors instead of repeatedly retrying.

### Prevention: request throttling

Protect the origin during recovery:

```text
Cache miss wave
        ↓
Admission control / queue
        ↓
Limited database concurrency
        ↓
Gradual cache repopulation
```

This sacrifices some immediate requests to keep the database alive.

### Prevention: staggered invalidation

For a large group of keys, invalidate in batches instead of deleting everything at once. Versioned namespaces can also make a new group active while old entries expire naturally.

### Avalanche trade-offs

| Technique | Benefit | Cost or risk |
|---|---|---|
| TTL jitter | Spreads expiration load | Makes exact expiration timing less predictable |
| Gradual warming | Controls backend load | Cache takes longer to become fully warm |
| Replication and failover | Reduces outage blast radius | Adds infrastructure and cost |
| Stale fallback | Maintains availability | Serves older data |
| Circuit breaker | Protects database | Some requests fail fast |
| Batch invalidation | Avoids one large spike | Some stale entries may remain temporarily |

## Stampede versus avalanche

These terms are related but not identical.

### Stampede

The scope is usually one popular key:

```text
One key expires → Many requests rebuild the same key
```

Primary defenses:

- Per-key lock.
- Request coalescing.
- Stale-while-revalidate.
- Refresh-ahead.

### Avalanche

The scope is broad:

```text
Many keys expire or cache service fails → Many requests hit backend systems
```

Primary defenses:

- TTL jitter.
- Gradual warming.
- High availability.
- Circuit breakers.
- Load shedding.
- Staggered invalidation.

A stampede can be one component of a larger avalanche, but a single hot-key expiration is not necessarily an avalanche.

## Combined defense example

Consider a product API with a distributed cache:

```text
1. Validate product ID format.
2. Check Bloom filter for possible existence.
3. Check distributed cache.
4. On a positive hit, return immediately.
5. On a negative-cache hit, return not found.
6. On a miss, acquire a per-product lock.
7. Recheck the cache after acquiring the lock.
8. Query the database only if still missing.
9. Cache positive results with TTL plus jitter.
10. Cache confirmed missing results with a short TTL.
11. Release the lock.
12. Rate-limit fallback database traffic.
```

```python
def get_product(product_id):
    if not valid_product_id(product_id):
        return None

    if not product_filter.might_contain(product_id):
        return None

    key = f"product:{product_id}"
    value = cache.get(key)

    if value == "NOT_FOUND":
        return None
    if value is not None:
        return value

    with singleflight(key):
        value = cache.get(key)
        if value == "NOT_FOUND":
            return None
        if value is not None:
            return value

        product = database.get_product(product_id)

        if product is None:
            cache.set(key, "NOT_FOUND", ttl=30)
            return None

        ttl = 300 + random.randint(0, 60)
        cache.set(key, product, ttl=ttl)
        return product
```

This design addresses multiple failure modes:

- Validation reduces invalid traffic.
- Bloom filtering rejects impossible identifiers.
- Negative caching reduces repeated missing-key lookups.
- Singleflight prevents duplicate rebuilds for one key.
- TTL jitter spreads expiration times.
- A short TTL on negative entries limits stale “not found” results.

## Monitoring and diagnosis

### Metrics for stampede

Monitor:

- Misses for individual hot keys.
- Concurrent database queries per key.
- Lock wait time.
- Cache rebuild duration.
- p95 and p99 latency.
- Database query duplication.

### Metrics for penetration

Monitor:

- Database queries returning not found.
- Unique invalid key rate.
- Negative-cache hit rate.
- Bloom-filter rejection rate.
- Invalid-request rate.
- Requests by IP, user, tenant, or API key.

### Metrics for avalanche

Monitor:

- Overall cache hit ratio.
- Overall miss ratio.
- Eviction and expiration rate.
- Cache connection errors.
- Cache node health.
- Backend request rate.
- Database CPU and connection usage.
- Retry volume.
- Queue and circuit-breaker state.

## Best practices checklist

- Use a TTL for cached entries.
- Add random TTL jitter to avoid synchronized expiration.
- Protect popular keys with request coalescing or per-key locks.
- Consider stale-while-revalidate for data that tolerates bounded staleness.
- Cache confirmed negative results for a short period.
- Validate identifiers before cache and database lookup.
- Use Bloom filters for large, mostly stable key sets.
- Rate-limit suspicious or high-miss traffic.
- Warm critical keys gradually after a restart or deployment.
- Use cache replication and failover when the cache is operationally critical.
- Add circuit breakers and origin concurrency limits.
- Make cache rebuild operations idempotent.
- Treat cache data as rebuildable and keep the database as the source of truth.
- Monitor cache misses by key, not only as a global percentage.

## Final summary

```text
Cache stampede:
One hot key expires → many identical backend reads
Fix: lock, coalesce, refresh early, serve bounded stale data

Cache penetration:
Requested data does not exist → repeated misses hit backend
Fix: validate, negative-cache, Bloom filter, rate-limit

Cache avalanche:
Many keys expire or cache fails → broad backend traffic surge
Fix: TTL jitter, gradual warming, high availability, load shedding
```

The key principle is:

> A cache should reduce backend load not only during normal operation, but also during expiration, invalid traffic, cache restart, and failure recovery.



### 15. Cache Consistency ⭐⭐⭐
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


### 16. DB + Cache Update Strategies
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

### 17. Cache Serialization
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


### 18. Cache Key Design ⭐⭐
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

### 19. Cache Sharding ⭐⭐⭐
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
### 21. Multi-Level Cache ⭐⭐⭐
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


### 25. Cache Warming
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

### 26. Cache Observability ⭐⭐
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


### Recommended Learning Sequence
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
