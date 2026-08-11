> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: System Design Notes
> Docs Index: [README.md](README.md)
# 6. Consistency

Consistency is a fundamental concept in **distributed systems** that defines **what value a client should see when reading data after writes happen across multiple nodes**.

In a distributed system, the same data may exist on multiple servers because of **replication**.

```text
                 â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                 â”‚   Client     â”‚
                 â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
                        â”‚
                  Write: balance=100
                        â”‚
                â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”
                â”‚   Database    â”‚
                â”‚   Primary     â”‚
                â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
                        â”‚
              â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
              â–¼                   â–¼
        â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
        â”‚ Replica 1 â”‚       â”‚ Replica 2 â”‚
        â”‚ balance=100â”‚      â”‚ balance=90 â”‚
        â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜       â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

If a client reads from Replica 2 immediately after the write, it might see `90` instead of `100`.

**Consistency defines the guarantees around such situations.**

---

# 1. What is Consistency?

Consistency answers:

> **"After a write happens, what should other clients see when they read the data?"**

Consider:

```text
Initial balance = 100

Client A:
    UPDATE balance = 200

Client B:
    READ balance
```

Depending on the consistency model, Client B may see:

```text
Strong Consistency:
    200

Eventual Consistency:
    100 or 200
    but eventually â†’ 200
```

Consistency is especially important when data is:

* replicated
* distributed across multiple servers
* geographically distributed
* asynchronously updated

---

# 2. Strong Consistency

Strong consistency guarantees that **once a write is acknowledged, subsequent reads return the latest value**.

```text
Write
  â”‚
  â–¼
Node A = 200
  â”‚
  â”œâ”€â”€ Replica B = 200
  â””â”€â”€ Replica C = 200
  â”‚
  â–¼
Read
  â”‚
  â–¼
200
```

### Example

```text
Initial:
balance = 100

Client A:
WRITE balance = 200

Client B:
READ balance

Result:
200
```

Client B should not see the old value `100` after the write has been committed.

### Advantages

* Easy mental model
* Clients see predictable data
* Useful for financial transactions
* Useful when stale data is unacceptable

### Disadvantages

* Higher latency
* More coordination between nodes
* Lower availability during network failures
* More expensive in geographically distributed systems

### Common use cases

* Banking
* Payment systems
* Inventory
* Account balances
* Stock trading

---

# 3. Weak Consistency

Weak consistency does **not guarantee that a read immediately after a write will return the latest value**.

```text
WRITE
  â”‚
  â–¼
Primary = 200
  â”‚
  â”‚ replication delay
  â–¼
Replica = 100

READ Replica
  â”‚
  â–¼
100
```

The system provides fewer guarantees in exchange for:

* lower latency
* higher availability
* better performance

### Example

A social media application:

```text
User A posts:
"Hello"

User B refreshes immediately.

User B may temporarily not see the post.
```

The system doesn't guarantee immediate visibility.

### Good for

* Social feeds
* Analytics
* Metrics
* Recommendations
* Non-critical data

---

# 4. Eventual Consistency

Eventual consistency guarantees:

> **If no new updates occur, all replicas will eventually converge to the same value.**

Example:

```text
Initial:

Node A = 100
Node B = 100
Node C = 100

Write:

Node A = 200

Immediately:

Node A = 200
Node B = 100
Node C = 100

After replication:

Node A = 200
Node B = 200
Node C = 200
```

The replicas are temporarily inconsistent but eventually become consistent.

### Timeline

```text
T0:
A = 100
B = 100
C = 100

T1:
WRITE A = 200

T2:
A = 200
B = 100
C = 100

T3:
A = 200
B = 200
C = 100

T4:
A = 200
B = 200
C = 200
```

### Advantages

* High availability
* Low latency
* Good scalability
* Works well across regions

### Disadvantages

* Reads may return stale data
* Application must tolerate temporary inconsistency
* Conflict resolution may be required

### Common examples

* Social media likes
* View counts
* Product recommendations
* DNS
* Distributed caches

---

# 5. Causal Consistency

Causal consistency guarantees that **causally related operations are observed in the same order by all nodes**.

Consider:

```text
User A:
Post "Hello"

Then:

User B:
Reply "Hi"
```

The reply depends on the original post.

Therefore:

```text
Post "Hello"
      â†“
Reply "Hi"
```

A system with causal consistency should not show:

```text
Reply "Hi"

before

Post "Hello"
```

### Example

```text
Operation 1:
User posts message

Operation 2:
Another user replies

Operation 2 depends on Operation 1.
```

Everyone should observe:

```text
Post
 â†“
Reply
```

But operations that are independent do not necessarily need a global order.

### Example

```text
User A:
Post A

User B:
Post B
```

These operations are independent.

The system could show:

```text
A â†’ B
```

or

```text
B â†’ A
```

as long as causal relationships are preserved.

---

# 6. Read-Your-Writes

Read-your-writes consistency guarantees:

> **After a client successfully writes data, that same client will always be able to read its own latest write.**

Example:

```text
User updates profile:

name = "Shubham"

Immediately:

User reads profile

Result:
name = "Shubham"
```

The user should not see:

```text
name = "Old Name"
```

after successfully updating it.

### Without Read-Your-Writes

```text
Client
  â”‚
  â”œâ”€â”€ WRITE name = Shubham
  â”‚
  â–¼
Primary

  â”‚
  â”œâ”€â”€ READ
  â–¼
Replica

Result:
Old Name
```

This can happen because the replica hasn't received the update yet.

### Solution

The system can:

* route the user's reads to the primary
* use session affinity
* use replication tokens/version numbers
* ensure replica catches up before serving the read

---

# 7. Monotonic Reads

Monotonic reads guarantee:

> **Once a client has seen a particular version of data, it will never see an older version later.**

Example:

```text
Read 1 â†’ Version 5

Read 2 â†’ Version 6

Read 3 â†’ Version 6
```

Valid.

But:

```text
Read 1 â†’ Version 5

Read 2 â†’ Version 3
```

is not allowed.

### Problem without monotonic reads

```text
Request 1
   â†“
Replica A
   â†“
Version 10

Request 2
   â†“
Replica B
   â†“
Version 7
```

The user sees data moving backward.

### Mental model

```text
Observed versions:

5 â†’ 6 â†’ 7 â†’ 8
âœ“

5 â†’ 7 â†’ 6
âœ—
```

The version observed by a client should move **forward or stay the same**.

---

# 8. Monotonic Writes

Monotonic writes guarantee:

> **Writes from the same client are applied in the order they were issued.**

Example:

```text
Write 1:
name = "A"

Write 2:
name = "B"
```

The system must process:

```text
A
â†“
B
```

not:

```text
B
â†“
A
```

### Problem

Suppose two requests are sent to different servers:

```text
Client
 â”œâ”€â”€ Write A â”€â”€â†’ Node 1
 â”‚
 â””â”€â”€ Write B â”€â”€â†’ Node 2
```

If Node 2 processes `B` before Node 1 processes `A`, ordering can be violated.

### Solution

Systems can use:

* sequence numbers
* session ordering
* leader-based writes
* timestamps/version numbers

---

# 9. Session Consistency

Session consistency provides consistency guarantees **within a user's session**.

A session can guarantee:

* Read-your-writes
* Monotonic reads
* Monotonic writes
* Writes-follow-reads

Example:

```text
User Session
     â”‚
     â”œâ”€â”€ WRITE X
     â”‚
     â”œâ”€â”€ READ X
     â”‚
     â”œâ”€â”€ WRITE Y
     â”‚
     â””â”€â”€ READ Y
```

The system ensures the user's experience remains consistent within that session.

### Example

An e-commerce website:

```text
User adds:

iPhone â†’ Cart

Refresh cart

Expected:
iPhone is still there
```

Even if the underlying system uses eventual consistency, session guarantees can prevent the user from seeing confusing results.

---

# 10. Linearizability

Linearizability is one of the strongest consistency guarantees.

It guarantees that:

> **Every operation appears to happen atomically at some point between its invocation and completion, while respecting real-time ordering.**

Think of it as:

> **"The distributed system behaves like a single copy of the data."**

Example:

```text
Client A:

WRITE X = 10
     â”‚
     â–¼
Completed
     â”‚
     â–¼
Client B:

READ X
```

Client B must see:

```text
10
```

because the write completed before the read started.

### Real-time ordering

```text
WRITE 10
   â”‚
   â”‚ completed
   â–¼
READ
   â”‚
   â–¼
10
```

The system cannot pretend that the read happened before the write.

### Linearizability vs Strong Consistency

In many discussions, "strong consistency" is used broadly.

**Linearizability is a precise formal consistency model.**

Linearizability provides:

* real-time ordering
* atomic operations
* latest-value semantics

---

# 11. Sequential Consistency

Sequential consistency guarantees:

> **The result is equivalent to some single sequential order of operations that preserves the order of operations from each individual client.**

Unlike linearizability, **real-time ordering across different clients does not necessarily have to be preserved**.

### Example

Two clients:

```text
Client A:
Write X = 1
Write X = 2

Client B:
Read X
```

The system must preserve A's order:

```text
X=1
 â†“
X=2
```

But operations from different clients can be interleaved as long as there exists a valid global sequential ordering.

### Linearizability vs Sequential Consistency

```text
Linearizability:
Preserves:
1. Per-client ordering
2. Real-time ordering

Sequential Consistency:
Preserves:
1. Per-client ordering

Does NOT necessarily preserve:
Real-time ordering across clients
```

---

# 12. Quorum Reads

Quorum reads are used in replicated databases to determine how many replicas should participate in a read.

Suppose we have:

```text
N = 3 replicas
```

We might configure:

```text
Read Quorum (R) = 2
```

A read must receive responses from at least 2 replicas.

```text
             READ
               â”‚
       â”Œâ”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”
       â–¼       â–¼       â–¼
      R1      R2      R3
       âœ“       âœ“       âœ—

Read quorum = 2
```

The read succeeds after receiving 2 responses.

### Quorum formula

For a system with:

```text
N = total replicas
W = write quorum
R = read quorum
```

A common strong-overlap condition is:

```text
R + W > N
```

Example:

```text
N = 3
W = 2
R = 2

R + W = 4

4 > 3 âœ“
```

This means the read and write quorums must overlap in at least one replica.

### Trade-off

Larger quorum:

```text
More consistency
Less availability
Higher latency
```

Smaller quorum:

```text
Less consistency
Higher availability
Lower latency
```

---

# 13. Quorum Writes

A quorum write requires a write to be acknowledged by a minimum number of replicas.

Example:

```text
N = 3
W = 2
```

Client sends:

```text
WRITE X = 100
```

```text
             WRITE
               â”‚
       â”Œâ”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”
       â–¼       â–¼       â–¼
      R1      R2      R3
       âœ“       âœ“       âœ—

W = 2
```

Once two replicas acknowledge the write, the operation can be considered successful.

### Example

```text
N = 5

W = 3
R = 3
```

Then:

```text
R + W > N

3 + 3 > 5
6 > 5 âœ“
```

Therefore, read and write quorums overlap.

---

# 14. Read Repair

Read repair is a technique used to fix stale replicas **during a read operation**.

Suppose:

```text
R1 = 100
R2 = 100
R3 = 90
```

Client performs a quorum read.

```text
READ

R1 â†’ 100
R2 â†’ 100
R3 â†’ 90
```

The system identifies:

```text
Correct/latest value = 100
Stale replica = R3
```

It then repairs R3:

```text
Before:

R1 = 100
R2 = 100
R3 = 90

        â†“ Read Repair

After:

R1 = 100
R2 = 100
R3 = 100
```

### Purpose

Read repair gradually brings replicas back into synchronization.

### Advantage

* Repairs stale data automatically
* Happens as part of normal reads

### Disadvantage

* Adds work/latency to reads
* Rarely-read data may remain stale

---

# 15. Anti-Entropy

Anti-entropy is a background process used to synchronize replicas.

Unlike read repair, it **does not require a client read to discover the inconsistency**.

Example:

```text
Replica A = 100
Replica B = 100
Replica C = 90
```

A background synchronization process compares replicas.

```text
        Anti-Entropy
             â”‚
       â”Œâ”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”
       â–¼           â–¼
      R1           R3
     100           90

             â†“

           R3 = 100
```

### Common technique: Merkle Trees

Distributed databases can use **Merkle trees** to efficiently determine which portions of data differ between replicas.

Instead of comparing every record:

```text
10 million records
```

the system can compare hashes.

```text
Replica A              Replica B

   Root Hash              Root Hash
       â”‚                      â”‚
    compare                 compare
       â”‚                      â”‚
    mismatch               mismatch
       â”‚
       â–¼
Find affected subtree
```

This makes synchronization much more efficient.

---

# Read Repair vs Anti-Entropy

| Feature                   | Read Repair            | Anti-Entropy                |
| ------------------------- | ---------------------- | --------------------------- |
| Trigger                   | Read operation         | Background process          |
| Requires client read?     | Yes                    | No                          |
| Repairs stale data        | Yes                    | Yes                         |
| Works on rarely-read data | Not reliably           | Yes                         |
| Impact on reads           | Can add latency        | Minimal                     |
| Typical mechanism         | Compare read responses | Hash/Merkle tree comparison |

---

# Consistency Models Comparison

| Model            | Main Guarantee                    | Can Read Stale Data?      |
| ---------------- | --------------------------------- | ------------------------- |
| Weak             | Minimal guarantees                | Yes                       |
| Eventual         | Eventually replicas converge      | Yes                       |
| Causal           | Preserves causal ordering         | Yes, depending on system  |
| Read-Your-Writes | Client sees its own writes        | Not its own older version |
| Monotonic Reads  | Reads never move backward         | Limited                   |
| Monotonic Writes | Client writes preserve order      | N/A                       |
| Session          | Guarantees within session         | Depends on guarantees     |
| Sequential       | Global sequential order exists    | Depends                   |
| Linearizability  | Latest value + real-time ordering | No after completed write  |

---

# Quorum Concepts Together

For replicated storage:

```text
             â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
             â”‚    Client     â”‚
             â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
                     â”‚
             â”Œâ”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”
             â”‚  Coordinator  â”‚
             â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
                     â”‚
          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
          â–¼          â–¼          â–¼
       Replica 1  Replica 2  Replica 3
          â”‚          â”‚          â”‚
          â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                     â”‚
              Quorum Decision
```

For:

```text
N = 3
W = 2
R = 2
```

A write needs:

```text
2 replicas
```

A read needs:

```text
2 replicas
```

And:

```text
R + W > N

2 + 2 > 3
```

Therefore, the read quorum and write quorum overlap.

---

# How These Concepts Fit Together

A useful mental model is:

```text
                    CONSISTENCY
                         â”‚
       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
       â”‚                 â”‚                  â”‚
       â–¼                 â–¼                  â–¼
  Consistency       Client-Level       Replication
    Models           Guarantees         Mechanisms
       â”‚                 â”‚                  â”‚
       â”œâ”€ Strong         â”œâ”€ Read-Your-Writes â”œâ”€ Quorum Read
       â”œâ”€ Weak           â”œâ”€ Monotonic Reads  â”œâ”€ Quorum Write
       â”œâ”€ Eventual       â”œâ”€ Monotonic Writes â”œâ”€ Read Repair
       â”œâ”€ Causal         â””â”€ Session          â””â”€ Anti-Entropy
       â”œâ”€ Sequential
       â””â”€ Linearizable
```

---

# Interview Mental Model

When asked about **consistency in system design**, think in this order:

```text
1. Is the data replicated?
        â†“
2. Can replicas temporarily disagree?
        â†“
3. What should a read return?
        â†“
4. Do we need strong or eventual consistency?
        â†“
5. Do clients need session guarantees?
        â†“
6. How do we maintain replica consistency?
        â†“
7. Quorum?
        â†“
8. Read Repair?
        â†“
9. Anti-Entropy?
```

### Simple decision guide

```text
Financial transaction
        â†“
Strong / Linearizable
Consistency


Social media feed
        â†“
Eventual Consistency


Chat / comments
        â†“
Causal Consistency


User profile update
        â†“
Read-Your-Writes


Distributed replicated DB
        â†“
Quorum + Read Repair + Anti-Entropy
```

---

# Key Takeaways

### Strong Consistency

```text
Write completed â†’ Read sees latest value
```

### Eventual Consistency

```text
Replicas may temporarily differ
        â†“
Eventually converge
```

### Causal Consistency

```text
Cause â†’ Effect
must be observed in that order
```

### Read-Your-Writes

```text
I wrote X
  â†“
I must read X
```

### Monotonic Reads

```text
Read version 5
  â†“
Read version 6
  â†“
Never go back to version 4
```

### Monotonic Writes

```text
Write A
  â†“
Write B

A must be applied before B
```

### Linearizability

```text
Acts like one up-to-date copy
and respects real-world ordering
```

### Sequential Consistency

```text
Operations appear in one valid
sequential order while preserving
each client's operation order
```

### Quorum

```text
R + W > N
```

creates overlap between read and write quorums.

### Read Repair

```text
Read discovers stale replica
        â†“
Repair it
```

### Anti-Entropy

```text
Background synchronization
        â†“
Find differences
        â†“
Repair replicas
```

