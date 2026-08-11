Consistent Hashing

1. What is Consistent Hashing?

Consistent Hashing is a hashing technique used in distributed systems to distribute data across multiple servers/nodes while minimizing the amount of data that needs to be moved when nodes are added or removed.

It is commonly useful in systems such as:

* Distributed caches
* Distributed databases
* Sharded databases
* CDNs
* Distributed storage systems
* Load balancing

Simple Example

Suppose we have 3 servers:

Node A
Node B
Node C

And we need to distribute these keys:

user:101
user:102
user:103
user:104

A simple approach could be:

hash(key) % numberOfNodes

For example:

serverIndex = hash(key) % 3

The problem is that when the number of nodes changes, the mapping of many keys changes.

Consistent hashing solves this problem by placing both keys and nodes on a hash ring.

⸻

2. Why Consistent Hashing?

Problem with Normal Hashing

A common approach to distribute data is:

Node = hash(key) % N

Where:

* key = data key
* hash(key) = hash value
* N = number of nodes

Suppose:

N = 3
hash("A") % 3 = 0 → Node 0
hash("B") % 3 = 1 → Node 1
hash("C") % 3 = 2 → Node 2

Now suppose we add another node:

N = 4

The calculation becomes:

hash("A") % 4
hash("B") % 4
hash("C") % 4

Many keys will now map to different nodes.

Example

Before:

A → Node 0
B → Node 1
C → Node 2
D → Node 0
E → Node 1

After adding Node 3:

A → Node 2
B → Node 0
C → Node 1
D → Node 3
E → Node 2

A large number of keys need to move.

This creates:

* Large data movement
* Cache misses
* Network traffic
* Increased latency
* Expensive rebalancing

⸻

3. How Consistent Hashing Solves This

Instead of calculating:

hash(key) % N

consistent hashing creates a hash ring.

Both:

Nodes

and

Keys

are hashed onto the same ring.

When a node is added or removed, only a relatively small portion of the keys need to move.

Main Idea

                 Node A
                   |
            ----------------
          /                  \
      Node C                  Node B
          \                  /
            ----------------

Each key is assigned to the next node clockwise on the ring.

⸻

4. Hash Ring

A hash ring is a circular representation of the hash space.

Suppose our hash function produces values between:

0 → 999

Instead of treating this as a straight line:

0 ---------------------------- 999

we connect the end back to the beginning:

                 250
                  |
                  |
        0 ---------------- 500
         \                /
          \              /
           \            /
              750

So:

999 → 0

are adjacent.

This creates a circular structure called a Hash Ring.

⸻

5. Placing Nodes on the Hash Ring

Suppose we have:

Node A
Node B
Node C

We calculate a hash for each node:

hash(Node A) = 100
hash(Node B) = 400
hash(Node C) = 700

The ring becomes:

                    100
                  Node A
                    |
                    |
         0 ------------------- 999
                    |
                    |
       700                     400
     Node C                   Node B

Now we hash our data keys.

For example:

hash(Key1) = 150
hash(Key2) = 450
hash(Key3) = 800

We move clockwise from each key until we find the first node.

Therefore:

Key1 → Node B
Key2 → Node C
Key3 → Node A

Why does Key3 go to Node A?

Because:

800 → 999 → 0 → 100

The ring wraps around.

⸻

6. Data Distribution

The basic rule is:

A key belongs to the first node encountered when moving clockwise from the key’s position on the hash ring.

Example:

Hash Ring
       Key1
        ↓
   150 --------→ Node B (400)
                    ↓
                  Node C

If:

hash(Key1) = 150
hash(Node B) = 400

then:

Key1 → Node B

Another Example

Node A = 100
Node B = 400
Node C = 700
Key1 = 50
Key2 = 200
Key3 = 500
Key4 = 800

Mapping:

Key1 = 50  → Node A
Key2 = 200 → Node B
Key3 = 500 → Node C
Key4 = 800 → Node A

Because:

50 → 100       → Node A
200 → 400      → Node B
500 → 700      → Node C
800 → 100 wrap → Node A

⸻

7. Node Addition

This is one of the biggest advantages of consistent hashing.

Suppose we have:

Node A = 100
Node B = 400
Node C = 700

Now we add:

Node D = 550

Before:

400 → Node B
700 → Node C

After adding Node D:

400 → Node B
550 → Node D
700 → Node C

Only the keys between:

Node B → Node D

need to move.

Before

Key1
Key2
Key3
   ↓
Node C

After

Key1
Key2
   ↓
Node D
Key3
   ↓
Node C

We do not need to redistribute all keys.

Key Point

Adding one node
        ↓
Only nearby keys are affected
        ↓
Small amount of data movement

This is the main reason consistent hashing is useful in distributed systems.

⸻

8. Node Removal

Suppose we have:

Node A = 100
Node B = 400
Node C = 700

Now:

Node B

fails or is removed.

Keys that were assigned to Node B need to move.

Because the next clockwise node after Node B is:

Node C

those keys are reassigned to Node C.

Before

Node A → keys
Node B → keys
Node C → keys

After removing Node B

Node A → same keys
Node C → Node C's old keys + Node B's keys

The important point is:

We don’t redistribute every key. Only the keys owned by the removed node need to move.

⸻

9. Rebalancing

Rebalancing means redistributing data when the cluster topology changes.

Topology can change because:

* A new node is added
* A node is removed
* A node fails
* A node is replaced
* Capacity needs to be increased

Normal Hashing

With:

hash(key) % N

changing N can cause many keys to move.

Before:
N = 3
Key → Node 0
Key → Node 1
Key → Node 2
After:
N = 4
Many keys → different nodes

This can cause significant rebalancing.

⸻

Consistent Hashing

With consistent hashing:

Add Node
   ↓
Only nearby hash-ring range changes
   ↓
Only those keys are moved

Therefore:

Less data movement
        ↓
Less network traffic
        ↓
Less cache invalidation
        ↓
Better scalability

⸻

10. Problem with Basic Consistent Hashing

There is still a problem.

Suppose we have only three nodes:

Node A = 100
Node B = 200
Node C = 900

The distribution may look like:

0 -------- 100 -------- 200 ---------------- 900
           A             B                    C

The ranges are very uneven.

For example:

900 → 100

is a large range.

While:

100 → 200

is a small range.

Therefore, Node A may receive much more data than Node B.

This is called uneven data distribution or hotspotting.

The solution is:

Virtual Nodes

⸻

11. Virtual Nodes

Instead of placing one physical node at one position on the hash ring, we create multiple positions for the same physical node.

These are called:

Virtual Nodes (vnodes)

For example:

Physical Node A
    ↓
A1
A2
A3
A4
A5

Each virtual node gets a different hash position.

Example:

A1 → 100
A2 → 350
A3 → 600
B1 → 200
B2 → 450
B3 → 800
C1 → 50
C2 → 300
C3 → 700

Now the ring looks much more evenly distributed.

⸻

12. Why Virtual Nodes?

Virtual nodes improve data distribution.

Without virtual nodes:

Node A
    |
    |--------------------------- Large range

With virtual nodes:

A1 ---- B1 ---- C1 ---- A2 ---- B2 ---- C2 ---- A3

The physical nodes are spread across the entire ring.

This reduces the possibility of one node receiving too much traffic or data.

⸻

13. Virtual Nodes and Node Addition

Suppose:

Node A
Node B
Node C

Each physical node has:

100 virtual nodes

Total:

300 virtual nodes

Now we add:

Node D

Node D also gets:

100 virtual nodes

Those virtual nodes are distributed across the ring.

Therefore, Node D receives small portions of data from many different parts of the ring.

Instead of taking one large continuous range, it takes many smaller ranges.

Without Virtual Nodes

Node D
   ↓
One large range

With Virtual Nodes

D1 → small range
D2 → small range
D3 → small range
D4 → small range
...
D100 → small range

This generally produces better balancing.

⸻

14. Node Removal with Virtual Nodes

Suppose:

Node B

has:

B1
B2
B3
...
B100

If Node B fails:

B1 → next physical node
B2 → next physical node
B3 → next physical node
...
B100 → next physical node

The data previously owned by B’s virtual nodes gets distributed across neighboring physical nodes.

Therefore, failure of one physical node does not necessarily overload only one other node.

⸻

15. Data Distribution

The quality of data distribution depends on:

* Hash function
* Number of physical nodes
* Number of virtual nodes
* Key distribution
* Hash ring size

A good hash function should distribute values uniformly.

Example:

                    A1
             C2           B1
        B3                     A2
        C1                     C3
             A3           B2
                    C4

Although there are only:

A
B
C

there are many virtual nodes:

A1 A2 A3
B1 B2 B3
C1 C2 C3 C4

This makes the distribution more uniform.

⸻

16. Complete Flow

When storing or retrieving data:

Client
   |
   | Key = "user:123"
   ↓
Hash(key)
   |
   ↓
Hash Ring
   |
   ↓
Find first virtual node clockwise
   |
   ↓
Virtual Node
   |
   ↓
Physical Node
   |
   ↓
Store / Read Data

For example:

"user:123"
     |
     ↓
Hash
     |
     ↓
Position = 450
     |
     ↓
Clockwise search
     |
     ↓
Virtual Node B7
     |
     ↓
Physical Node B
     |
     ↓
Redis / Database

⸻

17. Consistent Hashing vs Modulo Hashing

Feature	Modulo Hashing	Consistent Hashing
Formula	hash(key) % N	Hash ring
Adding node	Many keys may move	Only affected ranges move
Removing node	Many keys may move	Only affected ranges move
Rebalancing	Expensive	Relatively small
Distribution	Can be good	Improved with virtual nodes
Scalability	Poor when N changes frequently	Better
Complexity	Simple	More complex

⸻

18. Important Interview Question

What happens when a node is added?

Answer:

In consistent hashing, the new node is placed at one or more positions on the hash ring. Only the keys belonging to the ranges immediately preceding those new positions need to move to the new node. The remaining keys continue to stay on their existing nodes.

With virtual nodes, the new physical node gets multiple positions on the ring, so its data is taken from many smaller ranges.

⸻

19. What happens when a node is removed?

Answer:

When a node is removed, the keys mapped to that node’s hash-ring ranges are reassigned to the next available nodes in the clockwise direction. Only those affected keys need to move rather than the entire dataset.

⸻

20. Mental Model

Remember consistent hashing using this simple model:

              HASH RING
                  |
        ---------------------
       /                     \
      /                       \
   Node A                   Node B
      \                       /
       \                     /
        ------- Node C -------

Key

Key
 ↓
Hash
 ↓
Position on Ring
 ↓
Move Clockwise
 ↓
First Node
 ↓
Store / Read

Node Addition

Add Node
   ↓
New position(s) on ring
   ↓
Only nearby keys move

Node Removal

Remove Node
   ↓
Its keys move to next node(s)
   ↓
Other keys remain unchanged

Virtual Nodes

Physical Node
      ↓
Multiple virtual nodes
      ↓
Spread around ring
      ↓
Better distribution

⸻

21. Where is Consistent Hashing Used?

Consistent hashing is useful in distributed systems where nodes can dynamically join or leave.

Common examples include:

Distributed Caching

Examples:

* Redis clusters
* Memcached-based distributed caching

The goal is to avoid moving the entire cache when a cache server changes.

Distributed Databases

Some distributed databases use hashing/ring-like partitioning concepts to distribute data across nodes.

Examples include:

* Apache Cassandra
* Amazon Dynamo-style systems

Distributed Storage

Data can be distributed across multiple storage nodes using hash-based partitioning.

Load Distribution

Requests can be mapped consistently to nodes, especially when maintaining affinity is useful.

⸻

22. Key Takeaways

Consistent Hashing
        |
        +---- Hash Ring
        |
        +---- Keys mapped to ring
        |
        +---- Nodes mapped to ring
        |
        +---- Clockwise lookup
        |
        +---- Node Addition
        |         |
        |         +---- Only affected ranges move
        |
        +---- Node Removal
        |         |
        |         +---- Only affected ranges move
        |
        +---- Virtual Nodes
                  |
                  +---- Better distribution
                  +---- Reduce hotspots
                  +---- Better load balancing

One-line definition

Consistent hashing distributes keys across a changing set of nodes while minimizing data movement when nodes are added or removed.

Most important concepts to remember

Hash Ring
    ↓
Clockwise lookup
    ↓
Minimal data movement
    ↓
Virtual Nodes
    ↓
Better distribution