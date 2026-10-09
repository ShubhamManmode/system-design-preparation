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



2. Where Can We Cache?
Understand caching at every layer.
Client
   ↓
Browser Cache
   ↓
CDN / Edge Cache
   ↓
Load Balancer
   ↓
API Gateway
   ↓
Application
   ↓
Distributed Cache
   ↓
Database

Study:
- Browser caching
- HTTP caching
- CDN caching
- API Gateway caching
- Application-level caching
- Distributed caching
- Database caching
- DNS caching
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
