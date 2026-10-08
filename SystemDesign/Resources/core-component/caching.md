Caching — Complete Topic & Pattern Roadmap
1. Caching Fundamentals
- What is caching?
- Why caching?
  - Reduce latency
  - Reduce database load
  - Increase throughput
  - Reduce expensive computation
- Cache hit vs cache miss
- Hit ratio / miss ratio
- Cache latency
- Cache capacity
- TTL
- Eviction
- Cacheable vs non-cacheable data
- Hot data vs cold data
- Read-heavy vs write-heavy workloads
Important formula
Cache Hit Ratio = Cache Hits / Total Requests

Example:
1,000,000 requests
900,000 cache hits
100,000 cache misses

Hit ratio = 90%

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
