Repository: system-design-preparation
Topic: System Design Notes
Docs Index: README.md

6. Consistency

Consistency is a fundamental concept in distributed systems that defines what value a client should see when reading data after writes happen across multiple nodes.

In a distributed system, the same data may exist on multiple servers because of replication.

                 ┌───────────────┐
                 │    Client     │
                 └───────┬───────┘
                         │
                  Write: balance=100
                         │
                 ┌───────▼───────┐
                 │   Database    │
                 │    Primary    │
                 └───────┬───────┘
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
       ┌──────────────┐      ┌──────────────┐
       │  Replica 1   │      │  Replica 2   │
       │ balance=100  │      │ balance=90   │
       └──────────────┘      └──────────────┘

If a client reads from Replica 2 immediately after the write, it might see 90 instead of 100.

Consistency defines the guarantees around such situations.

⸻

1. What Is Consistency?

Consistency answers:

“After a write happens, what should other clients see when they read the data?”

Consider:

Initial balance = 100
Client A:
    UPDATE balance = 200
Client B:
    READ balance

Depending on the consistency model, Client B may see:

Strong Consistency:
    200
Eventual Consistency:
    100 or 200
    but eventually → 200

Consistency is especially important when data is:

* Replicated
* Distributed across multiple servers
* Geographically distributed
* Asynchronously updated

⸻

2. Strong Consistency

Strong consistency guarantees that once a write is acknowledged, subsequent reads return the latest value.

Write
  │
  ▼
Node A = 200
  │
  ├── Replica B = 200
  └── Replica C = 200
  │
  ▼
Read
  │
  ▼
200

Example

Initial:
balance = 100
Client A:
WRITE balance = 200
Client B:
READ balance
Result:
200

Client B should not see the old value 100 after the write has been committed.

Advantages

* Easy mental model
* Clients see predictable data
* Useful for financial transactions
* Useful when stale data is unacceptable

Disadvantages

* Higher latency
* More coordination between nodes
* Lower availability during network failures
* More expensive in geographically distributed systems

Common Use Cases

* Banking
* Payment systems
* Inventory
* Account balances
* Stock trading

⸻

3. Weak Consistency

Weak consistency does not guarantee that a read immediately after a write will return the latest value.

WRITE
  │
  ▼
Primary = 200
  │
  │ Replication delay
  ▼
Replica = 100
READ Replica
  │
  ▼
100

The system provides fewer guarantees in exchange for:

* Lower latency
* Higher availability
* Better performance

Example

A social media application:

User A posts:
"Hello"
User B refreshes immediately.
User B may temporarily not see the post.

The system doesn’t guarantee immediate visibility.

Good For

* Social feeds
* Analytics
* Metrics
* Recommendations
* Non-critical data

⸻

4. Eventual Consistency

Eventual consistency guarantees:

If no new updates occur, all replicas will eventually converge to the same value.

Example

Initial state:

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

The replicas are temporarily inconsistent but eventually become consistent.

Timeline

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

Advantages

* High availability
* Low latency
* Good scalability
* Works well across regions

Disadvantages

* Reads may return stale data
* Application must tolerate temporary inconsistency
* Conflict resolution may be required

Common Examples

* Social media likes
* View counts
* Product recommendations
* DNS
* Distributed caches

⸻

5. Causal Consistency

Causal consistency guarantees that causally related operations are observed in the same order by all nodes.

Consider:

User A:
Post "Hello"
Then:
User B:
Reply "Hi"

The reply depends on the original post.

Therefore:

Post "Hello"
      ↓
Reply "Hi"

A system with causal consistency should not show:

Reply "Hi"
before
Post "Hello"

Example

Operation 1:
User posts message
Operation 2:
Another user replies
Operation 2 depends on Operation 1.

Everyone should observe:

Post
  ↓
Reply

But operations that are independent do not necessarily need a global order.

For example:

User A:
Post A
User B:
Post B

These operations are independent.

The system could show:

A → B

or:

B → A

as long as causal relationships are preserved.

⸻

6. Read-Your-Writes Consistency

Read-your-writes consistency guarantees:

After a client successfully writes data, that same client will always be able to read its own latest write.

Example

User updates profile:
name = "Shubham"
Immediately:
User reads profile
Result:
name = "Shubham"

The user should not see:

name = "Old Name"

after successfully updating it.

Without Read-Your-Writes

Client
  │
  ├── WRITE name = Shubham
  │
  ▼
Primary
  │
  │
  ├── READ
  ▼
Replica
Result:
Old Name

This can happen because the replica hasn’t received the update yet.

Possible Solutions

The system can:

* Route the user’s reads to the primary
* Use session affinity
* Use replication tokens/version numbers
* Ensure the replica catches up before serving the read

⸻

7. Monotonic Reads

Monotonic reads guarantee:

Once a client has seen a particular version of data, it will never see an older version later.

Example

Valid:

Read 1 → Version 5
Read 2 → Version 6
Read 3 → Version 6

Invalid:

Read 1 → Version 5
Read 2 → Version 3

Problem Without Monotonic Reads

Request 1
   ↓
Replica A
   ↓
Version 10
Request 2
   ↓
Replica B
   ↓
Version 7

The user sees data moving backward.

Mental Model

Observed versions:
5 → 6 → 7 → 8
✓
5 → 7 → 6
✗

The version observed by a client should move forward or stay the same.

⸻

8. Monotonic Writes

Monotonic writes guarantee:

Writes from the same client are applied in the order they were issued.

Example

Write 1:
name = "A"
Write 2:
name = "B"

The system must process:

A
↓
B

not:

B
↓
A

Problem

Suppose two requests are sent to different servers:

Client
 ├── Write A ──→ Node 1
 │
 └── Write B ──→ Node 2

If Node 2 processes B before Node 1 processes A, ordering can be violated.

Possible Solutions

Systems can use:

* Sequence numbers
* Session ordering
* Leader-based writes
* Timestamps/version numbers

⸻

9. Session Consistency

Session consistency provides consistency guarantees within a user’s session.

A session can guarantee:

* Read-your-writes
* Monotonic reads
* Monotonic writes
* Writes-follow-reads

Example

User Session
     │
     ├── WRITE X
     │
     ├── READ X
     │
     ├── WRITE Y
     │
     └── READ Y

The system ensures the user’s experience remains consistent within that session.

Example: E-Commerce

User adds:
iPhone → Cart
Refresh cart
Expected:
iPhone is still there

Even if the underlying system uses eventual consistency, session guarantees can prevent the user from seeing confusing results.

⸻

10. Linearizability

Linearizability is one of the strongest consistency guarantees.

It guarantees that:

Every operation appears to happen atomically at some point between its invocation and completion, while respecting real-time ordering.

Think of it as:

“The distributed system behaves like a single copy of the data.”

Example

Client A:
WRITE X = 10
     │
     ▼
Completed
     │
     ▼
Client B:
READ X

Client B must see:

10

because the write completed before the read started.

Real-Time Ordering

WRITE 10
   │
   │ completed
   ▼
READ
   │
   ▼
10

The system cannot pretend that the read happened before the write.

Linearizability vs Strong Consistency

In many discussions, “strong consistency” is used broadly.

Linearizability is a precise formal consistency model.

Linearizability provides:

* Real-time ordering
* Atomic operations
* Latest-value semantics

⸻

11. Sequential Consistency

Sequential consistency guarantees:

The result is equivalent to some single sequential order of operations that preserves the order of operations from each individual client.

Unlike linearizability, real-time ordering across different clients does not necessarily have to be preserved.

Example

Two clients:

Client A:
Write X = 1
Write X = 2
Client B:
Read X

The system must preserve A’s order:

X = 1
  ↓
X = 2

But operations from different clients can be interleaved as long as there exists a valid global sequential ordering.

Linearizability vs Sequential Consistency

Linearizability:
    Preserves:
    1. Per-client ordering
    2. Real-time ordering
Sequential Consistency:
    Preserves:
    1. Per-client ordering
    Does NOT necessarily preserve:
    Real-time ordering across clients

⸻

12. Quorum Reads

Quorum reads are used in replicated databases to determine how many replicas should participate in a read.

Suppose we have:

N = 3 replicas

We might configure:

Read Quorum (R) = 2

A read must receive responses from at least 2 replicas.

             READ
               │
       ┌───────┼───────┐
       ▼       ▼       ▼
      R1      R2      R3
       ✓       ✓       ✗
Read quorum = 2

The read succeeds after receiving 2 responses.

Quorum Formula

For a system with:

N = Total replicas
W = Write quorum
R = Read quorum

A common strong-overlap condition is:

R + W > N

Example:

N = 3
W = 2
R = 2
R + W = 4
4 > 3 ✓

This means the read and write quorums must overlap in at least one replica.

Trade-Off

Larger quorum:

More consistency
Less availability
Higher latency

Smaller quorum:

Less consistency
Higher availability
Lower latency

⸻

13. Quorum Writes

A quorum write requires a write to be acknowledged by a minimum number of replicas.

Example:

N = 3
W = 2

Client sends:

WRITE X = 100
             WRITE
               │
       ┌───────┼───────┐
       ▼       ▼       ▼
      R1      R2      R3
       ✓       ✓       ✗
W = 2

Once two replicas acknowledge the write, the operation can be considered successful.

Example

N = 5
W = 3
R = 3

Then:

R + W > N
3 + 3 > 5
6 > 5 ✓

Therefore, read and write quorums overlap.

⸻

14. Read Repair

Read repair is a technique used to fix stale replicas during a read operation.

Suppose:

R1 = 100
R2 = 100
R3 = 90

Client performs a quorum read:

READ
R1 → 100
R2 → 100
R3 → 90

The system identifies:

Correct/latest value = 100
Stale replica = R3

It then repairs R3:

Before:
R1 = 100
R2 = 100
R3 = 90
        ↓ Read Repair
After:
R1 = 100
R2 = 100
R3 = 100

Purpose

Read repair gradually brings replicas back into synchronization.

Advantages

* Repairs stale data automatically
* Happens as part of normal reads

Disadvantages

* Adds work/latency to reads
* Rarely-read data may remain stale

⸻

15. Anti-Entropy

Anti-entropy is a background process used to synchronize replicas.

Unlike read repair, it does not require a client read to discover the inconsistency.

Example:

Replica A = 100
Replica B = 100
Replica C = 90

A background synchronization process compares replicas.

        Anti-Entropy
             │
       ┌─────┴─────┐
       ▼           ▼
      R1           R3
     100           90
             ↓
           R3 = 100

Common Technique: Merkle Trees

Distributed databases can use Merkle trees to efficiently determine which portions of data differ between replicas.

Instead of comparing every record:

10 million records

the system can compare hashes.

Replica A              Replica B
   Root Hash              Root Hash
       │                      │
    compare                 compare
       │                      │
    mismatch               mismatch
       │
       ▼
Find affected subtree

This makes synchronization much more efficient.

⸻

Read Repair vs Anti-Entropy

Feature	Read Repair	Anti-Entropy
Trigger	Read operation	Background process
Requires client read?	Yes	No
Repairs stale data	Yes	Yes
Works on rarely-read data	Not reliably	Yes
Impact on reads	Can add latency	Minimal
Typical mechanism	Compare read responses	Hash/Merkle tree comparison

⸻

Consistency Models Comparison

Model	Main Guarantee	Can Read Stale Data?
Weak	Minimal guarantees	Yes
Eventual	Eventually replicas converge	Yes
Causal	Preserves causal ordering	Yes, depending on system
Read-Your-Writes	Client sees its own writes	Not its own older version
Monotonic Reads	Reads never move backward	Limited
Monotonic Writes	Client writes preserve order	N/A
Session	Guarantees within session	Depends on guarantees
Sequential	Global sequential order exists	Depends
Linearizability	Latest value + real-time ordering	No after completed write

⸻

Quorum Concepts Together

For replicated storage:

             ┌───────────────┐
             │    Client     │
             └───────┬───────┘
                     │
             ┌───────▼───────┐
             │  Coordinator  │
             └───────┬───────┘
                     │
          ┌──────────┼──────────┐
          ▼          ▼          ▼
       Replica 1  Replica 2  Replica 3
          │          │          │
          └──────────┼──────────┘
                     │
              Quorum Decision

For:

N = 3
W = 2
R = 2

A write needs:

2 replicas

A read needs:

2 replicas

And:

R + W > N
2 + 2 > 3

Therefore, the read quorum and write quorum overlap.

⸻

How These Concepts Fit Together

A useful mental model is:

                    CONSISTENCY
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
       ▼                 ▼                 ▼
 Consistency       Client-Level       Replication
   Models           Guarantees         Mechanisms
       │                 │                 │
       ├── Strong        ├── Read-Your-Writes ├── Quorum Read
       ├── Weak          ├── Monotonic Reads  ├── Quorum Write
       ├── Eventual      ├── Monotonic Writes ├── Read Repair
       ├── Causal        └── Session          └── Anti-Entropy
       ├── Sequential
       └── Linearizable

⸻

Interview Mental Model

When asked about consistency in system design, think in this order:

1. Is the data replicated?
        ↓
2. Can replicas temporarily disagree?
        ↓
3. What should a read return?
        ↓
4. Do we need strong or eventual consistency?
        ↓
5. Do clients need session guarantees?
        ↓
6. How do we maintain replica consistency?
        ↓
7. Quorum?
        ↓
8. Read Repair?
        ↓
9. Anti-Entropy?

Simple Decision Guide

Financial transaction
        ↓
Strong / Linearizable
Consistency
Social media feed
        ↓
Eventual Consistency
Chat / comments
        ↓
Causal Consistency
User profile update
        ↓
Read-Your-Writes
Distributed replicated DB
        ↓
Quorum + Read Repair + Anti-Entropy

⸻

Key Takeaways

Strong Consistency

Write completed → Read sees latest value

Eventual Consistency

Replicas may temporarily differ
        ↓
Eventually converge

Causal Consistency

Cause → Effect
must be observed in that order

Read-Your-Writes

I wrote X
  ↓
I must read X

Monotonic Reads

Read version 5
  ↓
Read version 6
  ↓
Never go back to version 4

Monotonic Writes

Write A
  ↓
Write B
A must be applied before B

Linearizability

Acts like one up-to-date copy
and respects real-world ordering

Sequential Consistency

Operations appear in one valid
sequential order while preserving
each client's operation order

Quorum

R + W > N

creates overlap between read and write quorums.

Read Repair

Read discovers stale replica
        ↓
Repair it

Anti-Entropy

Background synchronization
        ↓
Find differences
        ↓
Repair replicas