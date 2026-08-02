# TCP vs UDP – Complete Beginner-Friendly Notes

## Introduction

Whenever two devices communicate over a network, they need a protocol that defines **how data should be sent and received**.

The two most common transport layer protocols are:

* **TCP (Transmission Control Protocol)**
* **UDP (User Datagram Protocol)**

Both belong to the **Transport Layer (Layer 4)** of the OSI Model and sit on top of IP.

```
Application (HTTP, DNS, FTP, SMTP)
            │
Transport (TCP / UDP)
            │
Internet (IP)
            │
Network (Ethernet / Wi-Fi)
```

Think of **IP** as finding the destination address, while **TCP/UDP** decides how the data actually travels.

---

# Why Do We Need TCP or UDP?

Imagine you want to send a book to your friend.

You have two options.

### Option 1: Reliable Delivery

* Number every page.
* Package them carefully.
* Track the shipment.
* Ask your friend to confirm delivery.
* Resend missing pages.

This is **TCP**.

---

### Option 2: Fast Delivery

Throw every page into the mailbox as quickly as possible.

If some pages are lost, you don't care because speed matters more.

This is **UDP**.

---

# What is TCP?

**TCP (Transmission Control Protocol)** is a **connection-oriented** protocol.

Before sending any data, both devices establish a connection.

It guarantees:

* Data arrives.
* Data arrives in order.
* No duplicate packets.
* Corrupted packets are retransmitted.

TCP prioritizes **reliability over speed**.

---

## Real-Life Example

Imagine ordering a laptop online.

You expect:

* Correct product
* Complete package
* No missing parts
* Delivery confirmation

Even if delivery takes longer, accuracy matters.

That's TCP.

---

# TCP Communication Flow

```
Client                      Server

Connect -------------------->

<------------------- Accept

Send Packet 1 ------------->

<------------------- ACK

Send Packet 2 ------------->

<------------------- ACK

Send Packet 3 ------------->

<------------------- ACK

Close Connection
```

Every important packet is acknowledged.

---

# Three-Way Handshake

Before sending data, TCP establishes a connection.

```
Client                    Server

SYN ---------------------->

<-------------------- SYN + ACK

ACK ----------------------->
```

### Step 1

Client says:

> "Can we communicate?"

This is the **SYN** packet.

---

### Step 2

Server replies:

> "Yes, I can. Can you hear me too?"

This is **SYN + ACK**.

---

### Step 3

Client confirms:

> "Yes."

This is **ACK**.

Now the connection is established.

---

# Why Three-Way Handshake?

It ensures:

* Both devices are alive.
* Both can send.
* Both can receive.
* Initial sequence numbers are exchanged.

Without this process, communication could begin with one side not actually ready.

---

# Sequence Numbers

Every TCP packet has a sequence number.

Example:

```
Packet 1 → Seq = 1

Packet 2 → Seq = 2

Packet 3 → Seq = 3
```

The receiver knows the correct order.

If packet 2 arrives after packet 3, TCP still delivers the data in the proper sequence.

---

# Acknowledgements (ACK)

After receiving data, the receiver responds with an acknowledgement.

```
Client

Packet 1 ------------->

Server

ACK 2 <---------------
```

ACK 2 means:

> "I received packet 1. Please send packet 2."

---

# Retransmission

Suppose Packet 2 is lost.

```
Packet 1 ✔

Packet 2 ❌ Lost

Packet 3 ✔
```

The receiver notices packet 2 is missing and asks the sender to resend it.

TCP automatically retransmits lost packets.

---

# Flow Control

Imagine:

Your friend can only read one page every minute.

If you send 100 pages at once, they'll be overwhelmed.

TCP prevents this using a **Receive Window**.

```
Sender

Send only 5 packets.

Receiver

I can handle only 5.
```

The sender waits before sending more.

---

# Congestion Control

Sometimes the internet itself becomes crowded.

Too many packets travel through the same routers.

TCP detects congestion and slows down transmission.

Popular algorithms include:

* Slow Start
* Congestion Avoidance
* Fast Recovery

The goal is to avoid overwhelming the network.

---

# Four-Way Connection Termination

When communication is complete:

```
Client

FIN ---------------------->

Server

<---------------------- ACK

Server

FIN ---------------------->

Client

<---------------------- ACK
```

Both devices close the connection gracefully.

---

# Advantages of TCP

* Reliable delivery
* Ordered packets
* Error checking
* Flow control
* Congestion control
* Widely supported

---

# Disadvantages of TCP

* Slower than UDP
* Higher latency
* Extra handshake
* More CPU and memory usage

---

# What is UDP?

**UDP (User Datagram Protocol)** is a **connectionless** protocol.

It sends packets immediately without creating a connection.

No handshake.

No acknowledgement.

No retransmission.

No ordering.

UDP prioritizes **speed over reliability**.

---

# Real-Life Example

Watching a live football match.

If one video frame is lost, you don't want the stream to pause while waiting for it.

Instead, the next frame is displayed immediately.

This is UDP.

---

# UDP Communication

```
Client

Packet 1 ------------->

Packet 2 ------------->

Packet 3 ------------->

Packet 4 ------------->

Done.
```

No acknowledgements.

No waiting.

Very fast.

---

# Why is UDP Faster?

Because it skips:

* Connection establishment
* Acknowledgements
* Retransmissions
* Packet ordering
* Congestion recovery mechanisms

Less work means lower latency.

---

# Advantages of UDP

* Extremely fast
* Low latency
* Small packet overhead
* Ideal for real-time communication

---

# Disadvantages of UDP

* Packets may be lost.
* Packets may arrive out of order.
* No retransmission.
* No delivery guarantee.

Applications must handle reliability if they need it.

---

# TCP vs UDP

| Feature            | TCP                    | UDP                     |
| ------------------ | ---------------------- | ----------------------- |
| Connection         | Yes                    | No                      |
| Reliable           | Yes                    | No                      |
| Packet Order       | Guaranteed             | Not Guaranteed          |
| Retransmission     | Yes                    | No                      |
| Acknowledgement    | Yes                    | No                      |
| Flow Control       | Yes                    | No                      |
| Congestion Control | Yes                    | No                      |
| Speed              | Slower                 | Faster                  |
| Header Size        | 20 bytes (minimum)     | 8 bytes                 |
| Best For           | Reliable communication | Real-time communication |

---

# Common Use Cases

## TCP

* HTTP / HTTPS
* File downloads
* Email (SMTP, IMAP, POP3)
* Database connections
* Banking systems
* Payment gateways
* REST APIs
* SSH

Reliability is essential here.

---

## UDP

* Online games
* Live video streaming
* Voice calls (VoIP)
* Video conferencing
* DNS queries
* DHCP
* IoT sensors

Speed is more important than perfect reliability.

---

# Why Games Use UDP

Imagine an online racing game.

Player A sends their position every 20 milliseconds.

```
Position 1

Position 2

Position 3

Position 4
```

If Position 2 is lost, waiting for it would freeze the game.

Instead, the game continues using Position 3 and Position 4.

Players prefer smooth gameplay over perfect packet delivery.

---

# Why Video Calls Use UDP

During a video call:

```
Frame 1 ✔

Frame 2 ✔

Frame 3 ❌ Lost

Frame 4 ✔
```

If Frame 3 disappears, you may notice a tiny glitch, but the conversation continues.

Waiting for retransmission would create an obvious pause.

---

# Why Banking Uses TCP

Suppose you're transferring ₹10,000.

The transfer request **must** reach the bank.

Duplicate requests must be prevented.

The response must be complete and correct.

Reliability is critical, so TCP is used.

---

# Interview Questions

### Why is TCP slower?

Because it performs:

* Three-way handshake
* Acknowledgements
* Retransmissions
* Flow control
* Congestion control
* Ordered delivery

---

### Why is UDP faster?

Because it avoids:

* Connection setup
* ACKs
* Retransmissions
* Ordering
* Congestion recovery

---

### Does UDP guarantee delivery?

No.

---

### Does TCP guarantee delivery?

Yes, as long as the connection remains active and errors can be recovered through retransmission.

---

### Can UDP become reliable?

Yes.

Applications can implement their own acknowledgements, sequencing, retries, and error recovery if needed.

Examples include:

* QUIC (used by HTTP/3)
* Some multiplayer game networking protocols

---

# TCP vs UDP in System Design

When designing a system, first ask:

> **"Is reliability more important, or is low latency more important?"**

Choose **TCP** when:

* Every message matters.
* Data must arrive in order.
* Accuracy is critical.

Choose **UDP** when:

* Real-time updates matter more than perfect delivery.
* A small amount of data loss is acceptable.
* Low latency is the priority.

---

# Quick Revision

## Choose TCP if:

* Reliability is required.
* Ordered delivery is required.
* File transfer.
* Banking.
* APIs.
* Databases.
* Email.
* Secure communication.

---

## Choose UDP if:

* Speed is the priority.
* Live streaming.
* Online gaming.
* Voice calls.
* Video calls.
* DNS lookups.
* IoT telemetry.

---

# Key Takeaway

Think of it this way:

* **TCP** is like sending an important legal document by registered courier. You track it, require a signature, and resend it if necessary.
* **UDP** is like speaking during a live conversation. If you miss one word, you continue talking instead of repeating the entire sentence.

Understanding this trade-off—**reliability versus latency**—is the foundation for choosing the right transport protocol in networking and system design.
