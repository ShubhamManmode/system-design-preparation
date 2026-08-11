> Repository: [system-design-preparation](https://github.com/ShubhamManmode/system-design-preparation)
> Topic: Syllabus Chapter
> Docs Index: [README.md](../../README.md)

# Database Fundamentals

This chapter covers the fundamentals of databases, storage models, and query basics relevant to system design.

## 1. Database Fundamentals

This document serves as a structured study guide for database fundamentals in system design preparation.

## Table of Contents

1. [Database Fundamentals](#1-database-fundamentals)
2. [Relational Database](#2-relational-database)
3. [SQL](#3-sql)
4. [Indexing](#4-indexing)
5. [Query Optimization](#5-query-optimization)
6. [Transactions](#6-transactions)
7. [Isolation Levels](#7-isolation-levels)
8. [Concurrency Control](#8-concurrency-control)
9. [NoSQL](#9-nosql)
10. [Implementations](#10-implementations)
11. [Interview Problems](#11-interview-problems)

## 1. Database Fundamentals

- What is a Database?
- DBMS vs RDBMS vs NoSQL
    # DBMS vs RDBMS vs NoSQL

Databases are used to store, organize, retrieve, and manage data efficiently. Depending on the application's requirements, different types of database systems are available. The three most common categories are **DBMS**, **RDBMS**, and **NoSQL**.

---

# 1. DBMS (Database Management System)

A **Database Management System (DBMS)** is software that allows users to create, store, retrieve, update, and delete data. It acts as an interface between the application and the stored data, making data management easier and more organized.

### Key Characteristics

* Stores and manages data.
* Supports basic CRUD (Create, Read, Update, Delete) operations.
* Suitable for small to medium-sized applications.
* May not enforce relationships between different data sets.
* Generally designed for single-user or low-concurrency environments.

### Advantages

* Easy to use.
* Reduces data redundancy compared to file systems.
* Provides data security and backup features.

### Examples

* Microsoft Access
* FoxPro
* dBase

---

# 2. RDBMS (Relational Database Management System)

An **RDBMS** is an advanced type of DBMS that stores data in **tables (relations)**. Each table consists of rows and columns, and tables can be connected using **Primary Keys** and **Foreign Keys** to establish relationships.

For example, a customer's information can be stored in one table while their orders are stored in another. Both tables are linked using a common key, allowing the database to retrieve related data through SQL joins.

### Key Characteristics

* Stores data in tables.
* Supports relationships between tables.
* Uses **Structured Query Language (SQL)**.
* Enforces data integrity through constraints.
* Supports ACID transactions to ensure reliable data processing.
* Well suited for applications where data consistency is critical.

### Advantages

* High data integrity.
* Eliminates data duplication using normalization.
* Supports complex queries using JOIN operations.
* Reliable transaction management.
* Strong security and access control.

### Common Use Cases

* Banking Systems
* E-commerce Applications
* Hospital Management Systems
* ERP Systems
* Financial Applications

### Examples

* Microsoft SQL Server
* MySQL
* PostgreSQL
* Oracle Database

---

# 3. NoSQL Database

**NoSQL (Not Only SQL)** databases are designed to handle large volumes of data, high traffic, and flexible data structures. Unlike RDBMS, NoSQL databases do not require data to be stored in fixed tables with predefined schemas.

Instead, data can be stored in various formats:

* Document
* Key-Value
* Wide-Column
* Graph

This flexibility makes NoSQL databases ideal for rapidly changing applications and distributed systems.

### Key Characteristics

* Schema is flexible and can evolve over time.
* Supports horizontal scaling across multiple servers.
* Optimized for high performance and large datasets.
* Different NoSQL databases provide different consistency and transaction guarantees.
* Well suited for distributed architectures.

### Advantages

* Handles massive amounts of data efficiently.
* High read and write performance.
* Easy to scale horizontally.
* Flexible data model.
* Suitable for cloud-native and microservices-based applications.

### Common Use Cases

* Social Media Platforms
* Chat Applications
* Real-time Analytics
* IoT Applications
* Recommendation Systems
* Caching Systems

### Examples

* MongoDB (Document Database)
* Redis (Key-Value Database)
* Apache Cassandra (Wide-Column Database)
* Amazon DynamoDB (Key-Value/Document Database)

---

# Comparison: DBMS vs RDBMS vs NoSQL

| Feature            | DBMS                        | RDBMS                                  | NoSQL                                                         |
| ------------------ | --------------------------- | -------------------------------------- | ------------------------------------------------------------- |
| Full Form          | Database Management System  | Relational Database Management System  | Not Only SQL                                                  |
| Data Storage       | Files or simple tables      | Relational tables                      | Documents, Key-Value, Graph, Wide-Column                      |
| Data Relationships | Limited                     | Supported using Primary & Foreign Keys | Typically denormalized; relationships are handled differently |
| Schema             | Fixed                       | Fixed                                  | Flexible                                                      |
| Query Language     | Basic queries               | SQL                                    | Database-specific APIs or query languages                     |
| JOIN Operations    | Limited                     | Fully supported                        | Usually avoided                                               |
| Transactions       | Basic                       | Full ACID support                      | Varies by database                                            |
| Scalability        | Limited                     | Mostly Vertical Scaling                | Horizontal Scaling                                            |
| Performance        | Good for small applications | Excellent for structured data          | Excellent for large-scale distributed systems                 |
| Best For           | Small applications          | Enterprise applications                | Big data, distributed systems, high scalability               |

---

# When to Use Each

### Choose DBMS when:

* Building a small application.
* Relationships between data are minimal.
* The system has few concurrent users.

### Choose RDBMS when:

* Data consistency is critical.
* Multiple related entities exist.
* Complex SQL queries are required.
* Transactions must be reliable.

### Choose NoSQL when:

* Working with massive datasets.
* Schema changes frequently.
* High scalability is required.
* The application is distributed across multiple servers.

---

# Summary

* **DBMS** is the foundation for managing data and provides basic storage and retrieval capabilities.
* **RDBMS** extends DBMS by organizing data into related tables, enforcing relationships, and ensuring data consistency through SQL and ACID transactions.
* **NoSQL** databases provide flexible schemas and horizontal scalability, making them ideal for modern, distributed, and high-performance applications.

Choosing the right database depends on your application's requirements, including data structure, scalability, consistency, and performance needs.

- OLTP vs OLAP
      # OLTP vs OLAP

Organizations use databases for different purposes. Some databases are designed to **process day-to-day business transactions**, while others are optimized to **analyze large amounts of historical data**. These two approaches are known as **OLTP (Online Transaction Processing)** and **OLAP (Online Analytical Processing)**.

---

# 1. OLTP (Online Transaction Processing)

**OLTP** systems are designed to manage **real-time business transactions**. Their primary goal is to process a large number of small, fast, and concurrent operations such as inserting, updating, deleting, and retrieving records.

Examples of transactions include:

* Placing an online order
* Withdrawing money from an ATM
* Booking a flight ticket
* Making an online payment

These systems prioritize **speed, accuracy, and data consistency**.

## Key Characteristics

* Handles day-to-day business operations.
* Supports thousands or millions of concurrent users.
* Performs frequent **INSERT**, **UPDATE**, and **DELETE** operations.
* Stores the most recent operational data.
* Optimized for fast response times.
* Uses normalized tables to reduce data redundancy.
* Supports ACID transactions to ensure data integrity.

## Advantages

* Very fast transaction processing.
* High data consistency.
* Reliable transaction management.
* Supports multiple users simultaneously.
* Prevents duplicate or inconsistent data.

## Common Use Cases

* Banking Systems
* E-commerce Websites
* Airline Reservation Systems
* Hospital Management Systems
* Payment Gateways

---

# 2. OLAP (Online Analytical Processing)

**OLAP** systems are designed for **data analysis and business intelligence**. Instead of processing daily transactions, they analyze large volumes of historical data to help organizations make strategic decisions.

Typical analytical questions include:

* Which product generated the highest revenue last year?
* What were monthly sales trends?
* Which region has the highest customer growth?
* What is the average order value over the past five years?

OLAP systems prioritize **query performance for large datasets** rather than transaction speed.

## Key Characteristics

* Optimized for complex analytical queries.
* Stores historical data collected over time.
* Mostly performs **SELECT** operations.
* Supports aggregation, reporting, and trend analysis.
* Often uses denormalized schemas (Star Schema or Snowflake Schema).
* Data is usually refreshed through ETL (Extract, Transform, Load) processes.

## Advantages

* Fast analytical queries.
* Excellent for reporting and dashboards.
* Helps identify trends and business insights.
* Supports decision-making.
* Efficiently processes large datasets.

## Common Use Cases

* Business Intelligence (BI)
* Sales Reporting
* Financial Analysis
* Data Warehousing
* Executive Dashboards
* Forecasting and Trend Analysis

---

# Example

Imagine an **E-commerce Platform**.

### OLTP Example

Every time a customer:

* Places an order
* Updates their profile
* Makes a payment
* Cancels an order

The database immediately records the transaction.

Example SQL:

```sql
INSERT INTO Orders(CustomerId, ProductId, Quantity)
VALUES (101, 15, 2);
```

The goal is to complete the transaction quickly and accurately.

---

### OLAP Example

The company wants answers to questions like:

* Total sales by month
* Best-selling products
* Revenue by country
* Customer purchasing trends

Example SQL:

```sql
SELECT ProductName,
       SUM(TotalAmount) AS Revenue
FROM Sales
GROUP BY ProductName
ORDER BY Revenue DESC;
```

These queries scan and analyze large amounts of historical data.

---

# OLTP vs OLAP Comparison

| Feature         | OLTP                                | OLAP                                         |
| --------------- | ----------------------------------- | -------------------------------------------- |
| Full Form       | Online Transaction Processing       | Online Analytical Processing                 |
| Purpose         | Process daily business transactions | Analyze historical business data             |
| Operations      | INSERT, UPDATE, DELETE, SELECT      | Mostly SELECT with aggregations              |
| Data            | Current operational data            | Historical and aggregated data               |
| Query Type      | Simple and short                    | Complex and long-running                     |
| Database Design | Highly normalized                   | Often denormalized (Star/Snowflake Schema)   |
| Response Time   | Milliseconds                        | Seconds to minutes (depending on query size) |
| Users           | Customers, employees, applications  | Business analysts, managers, executives      |
| Concurrency     | Very High                           | Moderate                                     |
| Data Volume     | Current records                     | Large historical datasets                    |
| Primary Goal    | Fast and reliable transactions      | Fast reporting and analysis                  |
| Examples        | Banking, Shopping, Booking Systems  | BI Reports, Dashboards, Data Warehouses      |

---

# Real-World Analogy

Imagine a supermarket.

### OLTP

Every customer purchase at the checkout counter is an **OLTP transaction**.

* Scan product
* Calculate total
* Accept payment
* Print receipt

The system must respond instantly for every customer.

---

### OLAP

At the end of the month, the store manager wants to know:

* Which product sold the most?
* Which branch generated the highest revenue?
* Which day had the highest sales?
* What are the sales trends over the past year?

These reports are generated using an **OLAP system**.

---

# When to Use OLTP

Choose OLTP when your application needs:

* Fast transaction processing
* High concurrency
* Data consistency
* Real-time updates
* Reliable ACID transactions

Examples:

* Banking applications
* Online shopping
* Ticket booking
* Payment processing

---

# When to Use OLAP

Choose OLAP when your application needs:

* Business reporting
* Data analysis
* Historical trends
* Dashboards
* Decision support
* Forecasting

Examples:

* Power BI dashboards
* Sales reports
* Financial analysis
* Executive reporting

---

# Summary

* **OLTP** systems are built for **processing day-to-day business transactions** quickly and reliably. They handle frequent inserts, updates, and deletes while ensuring data consistency.
* **OLAP** systems are built for **analyzing historical data**. They execute complex queries on large datasets to generate reports, dashboards, and business insights.

In modern architectures, organizations often use **both**:

* **OLTP** databases power the live application.
* Data from the OLTP system is periodically moved to an **OLAP** system (Data Warehouse) for reporting and analytics.

## 2. Relational Database

# 2. Relational Database

A **Relational Database (RDB)** stores data in **tables** (also called relations). Each table represents a specific entity, such as **Customers**, **Orders**, or **Products**. Data is organized into **rows** and **columns**, and relationships between tables are established using **Primary Keys** and **Foreign Keys**.

Relational databases use **Structured Query Language (SQL)** to perform operations such as inserting, updating, deleting, and retrieving data. They are widely used in applications where **data consistency, integrity, and relationships** are important.

# Primary Key

A **Primary Key (PK)** is a column (or combination of columns) that **uniquely identifies each row** in a table.

### Example

| CustomerId (PK) | Name    |
| --------------- | ------- |
| 1               | Shubham |
| 2               | Rahul   |

Here, **CustomerId** is the Primary Key because each value is unique.

### Rules

* Must contain unique values.
* Cannot contain NULL values.
* A table can have only **one Primary Key**.
* The Primary Key may consist of one or multiple columns (Composite Primary Key).

### Why is it Needed?

Without a Primary Key, multiple rows could look identical, making it difficult to uniquely identify or update a specific record.

---

# Foreign Key

A **Foreign Key (FK)** is a column that creates a relationship between two tables by referencing the Primary Key of another table.

### Example

#### Customers Table

| CustomerId (PK) | Name    |
| --------------- | ------- |
| 1               | Shubham |
| 2               | Rahul   |

#### Orders Table

| OrderId | CustomerId (FK) | Product |
| ------- | --------------- | ------- |
| 101     | 1               | Laptop  |
| 102     | 1               | Mouse   |
| 103     | 2               | Phone   |

Here, **CustomerId** in the **Orders** table is a Foreign Key that references **CustomerId** in the **Customers** table.

### Why is it Needed?

* Maintains relationships between tables.
* Prevents invalid or orphan records.
* Enforces referential integrity.

---

# Constraints

**Constraints** are rules applied to table columns to ensure the accuracy and integrity of the data.

### Common Constraints

| Constraint  | Purpose                                     |
| ----------- | ------------------------------------------- |
| PRIMARY KEY | Uniquely identifies each row                |
| FOREIGN KEY | Maintains relationships between tables      |
| NOT NULL    | Prevents NULL values                        |
| UNIQUE      | Prevents duplicate values                   |
| CHECK       | Restricts values based on a condition       |
| DEFAULT     | Assigns a default value if none is provided |

### Example

```sql
CREATE TABLE Employees (
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Age INT CHECK (Age >= 18),
    Country VARCHAR(50) DEFAULT 'India'
);
```

### Benefits

* Prevents invalid data.
* Maintains data integrity.
* Reduces application-level validation.
* Improves database reliability.

---

# Normalization

**Normalization** is the process of organizing data into multiple related tables to **reduce data redundancy** and **improve data integrity**.

Instead of storing the same information repeatedly, data is divided into logical tables connected through relationships.

### Example (Before Normalization)

| OrderId | CustomerName | CustomerCity | Product |
| ------- | ------------ | ------------ | ------- |
| 101     | Shubham      | Pune         | Laptop  |
| 102     | Shubham      | Pune         | Mouse   |

Here, the customer's information is repeated in every order.

### Example (After Normalization)

#### Customers

| CustomerId | Name    | City |
| ---------- | ------- | ---- |
| 1          | Shubham | Pune |

#### Orders

| OrderId | CustomerId | Product |
| ------- | ---------- | ------- |
| 101     | 1          | Laptop  |
| 102     | 1          | Mouse   |

Now, customer information is stored only once.

### Advantages

* Reduces duplicate data.
* Improves data consistency.
* Saves storage space.
* Makes updates easier.
* Prevents insertion, update, and deletion anomalies.

### Common Normal Forms

* **1NF (First Normal Form):** Eliminate repeating groups and ensure atomic values.
* **2NF (Second Normal Form):** Remove partial dependencies.
* **3NF (Third Normal Form):** Remove transitive dependencies.
* **BCNF (Boyce-Codd Normal Form):** A stricter version of 3NF that handles certain dependency anomalies.

---

# Denormalization

**Denormalization** is the process of combining related data into fewer tables by intentionally introducing some data redundancy to improve **read performance**.

It is commonly used in reporting systems, data warehouses, and applications where read operations are much more frequent than writes.

### Example

Instead of joining **Customers** and **Orders** every time, the Orders table may also store the customer's name.

| OrderId | CustomerId | CustomerName | Product |
| ------- | ---------- | ------------ | ------- |
| 101     | 1          | Shubham      | Laptop  |
| 102     | 1          | Shubham      | Mouse   |

Now, reports can be generated without performing a JOIN.

### Advantages

* Faster read performance.
* Fewer JOIN operations.
* Better performance for reporting and analytics.
* Simpler queries for frequently accessed data.

### Disadvantages

* Increases data redundancy.
* Consumes more storage.
* Updates become more complex because duplicated data must remain consistent.
* Higher risk of data inconsistency if not managed carefully.

---

# Normalization vs Denormalization

| Feature           | Normalization      | Denormalization                    |
| ----------------- | ------------------ | ---------------------------------- |
| Goal              | Reduce redundancy  | Improve read performance           |
| Data Redundancy   | Minimal            | Increased                          |
| Number of Tables  | More               | Fewer                              |
| JOIN Operations   | More frequent      | Fewer                              |
| Storage Usage     | Lower              | Higher                             |
| Read Performance  | Moderate           | Faster                             |
| Write Performance | Better consistency | Updates may be more expensive      |
| Best Use Case     | OLTP systems       | OLAP systems, reporting, analytics |

---

## 3. SQL

- CRUD
- Joins
- Aggregations
- Group By
- Having
- Subqueries
- CTE
- Window Functions

## 4. Indexing

# 4. Indexing

An **index** is a database object that improves the speed of data retrieval. Instead of scanning every row in a table, the database uses an index to quickly locate the required data.

Think of an index in a book. Instead of reading every page to find a topic, you look it up in the index, which tells you exactly where to find it. Database indexes work in a similar way.

> **Note:** While indexes significantly improve **read performance**, they also add some overhead to **INSERT**, **UPDATE**, and **DELETE** operations because the index must be updated whenever the data changes.

---

# Why Indexes?

Without an index, the database performs a **Table Scan (Full Table Scan)**, meaning it checks every row until it finds the required data.

With an index, the database can directly locate the matching rows, making queries much faster.

### Example

Suppose the **Customers** table contains **10 million records**.

```sql
SELECT * FROM Customers
WHERE Email = 'john@example.com';
```

### Without an Index

* Database scans all 10 million rows.
* Slower query execution.
* Higher CPU and disk usage.

### With an Index on Email

```sql
CREATE INDEX IX_Customers_Email
ON Customers(Email);
```

The database uses the index to locate the matching record quickly without scanning the entire table.

### Benefits of Indexing

* Faster data retrieval.
* Reduces disk I/O.
* Improves query performance.
* Speeds up JOIN, WHERE, ORDER BY, and GROUP BY operations.

---

# Clustered Index

A **Clustered Index** determines the **physical order** in which data is stored on disk.

Since data can only be stored in one physical order, **a table can have only one clustered index**.

### Example

Suppose a table has a clustered index on **CustomerId**.

```text
CustomerId

1
2
3
4
5
6
7
```

The rows are physically stored in ascending order of **CustomerId**.

### Characteristics

* Determines the physical storage order.
* Only one clustered index per table.
* Very fast for range searches.
* Usually created on the Primary Key.

### Best Use Cases

* Primary Key columns.
* Range queries.
* Frequently sorted data.

---

# Non-Clustered Index

A **Non-Clustered Index** stores the indexed column values separately from the table data.

Instead of changing the physical order of rows, it contains:

* Indexed column value
* Pointer (Row Locator) to the actual row

### Example

Suppose an index exists on **Email**.

```text
Email                    Pointer

abc@test.com   -------> Row 15
john@test.com  -------> Row 92
xyz@test.com   -------> Row 230
```

The database first searches the index, then follows the pointer to retrieve the complete row.

### Characteristics

* Does not change the physical order of the table.
* Multiple non-clustered indexes can exist on a table.
* Excellent for searching specific values.

### Best Use Cases

* Search columns.
* Frequently filtered columns.
* Lookup operations.

---

# Composite Index

A **Composite Index** is an index created on **multiple columns**.

The order of columns is important because the database uses the **leftmost prefix** of the index.

### Example

```sql
CREATE INDEX IX_Employee_Name_Department
ON Employees(LastName, DepartmentId);
```

This index is useful for queries such as:

```sql
SELECT *
FROM Employees
WHERE LastName = 'Smith';
```

or

```sql
SELECT *
FROM Employees
WHERE LastName = 'Smith'
AND DepartmentId = 5;
```

However, it is generally **not** efficient for:

```sql
SELECT *
FROM Employees
WHERE DepartmentId = 5;
```

because the first indexed column (**LastName**) is not used.

### Best Use Cases

* Queries filtering on multiple columns.
* Frequently used WHERE clauses.
* Multi-column sorting.

---

# Covering Index

A **Covering Index** contains **all the columns required by a query**, allowing the database to return the result directly from the index without reading the actual table.

### Example

Suppose the query is:

```sql
SELECT Name, Email
FROM Customers
WHERE Email = 'john@test.com';
```

Create an index:

```sql
CREATE INDEX IX_Email
ON Customers(Email)
INCLUDE(Name);
```

Now the database can satisfy the query using only the index.

### Benefits

* Eliminates extra table lookups.
* Faster query execution.
* Reduces disk I/O.

### Best Use Cases

* Frequently executed queries.
* Reporting queries.
* Read-heavy applications.

---

# Unique Index

A **Unique Index** ensures that all indexed values are unique.

Duplicate values are not allowed.

### Example

```sql
CREATE UNIQUE INDEX IX_Email
ON Customers(Email);
```

If someone tries to insert another customer with the same email, the database rejects the operation.

### Benefits

* Prevents duplicate values.
* Improves search performance.
* Enforces business rules.

### Common Examples

* Email Address
* Aadhaar Number
* Passport Number
* Employee Code

---

# Full-Text Index

A **Full-Text Index** is designed for searching large amounts of text efficiently.

Unlike a normal index, it supports searching for:

* Words
* Phrases
* Partial matches
* Linguistic variations (depending on the database)

### Example

Suppose the **Products** table contains descriptions.

| Product | Description                            |
| ------- | -------------------------------------- |
| Laptop  | High-performance gaming laptop         |
| Phone   | Android smartphone with AMOLED display |

Instead of:

```sql
WHERE Description LIKE '%gaming%'
```

you can use a full-text search (syntax varies by database) for much faster text searching.

### Best Use Cases

* Product search
* Document search
* Article search
* Search engines
* Knowledge bases

---

# Index Selectivity

**Index Selectivity** measures how unique the values in a column are.

It helps determine whether creating an index on a column is beneficial.

### High Selectivity

Most values are unique.

Example:

| Email                           |
| ------------------------------- |
| [a@test.com](mailto:a@test.com) |
| [b@test.com](mailto:b@test.com) |
| [c@test.com](mailto:c@test.com) |

Almost every row has a different value.

An index on this column is very effective.

---

### Low Selectivity

Many rows have the same value.

| Gender |
| ------ |
| Male   |
| Male   |
| Male   |
| Female |

Only a few distinct values exist.

An index on this column may not improve performance significantly because many rows still need to be read.

### General Rule

* **High Selectivity â†’ Excellent candidate for indexing**
* **Low Selectivity â†’ Usually a poor candidate for indexing**, unless combined with other columns in a composite index or used in specific query patterns.

---

# Best Practices

* Create indexes on columns frequently used in **WHERE**, **JOIN**, **ORDER BY**, and **GROUP BY** clauses.
* Avoid creating indexes on columns with very low selectivity unless there is a specific performance benefit.
* Do not create unnecessary indexes, as they increase storage usage and slow down **INSERT**, **UPDATE**, and **DELETE** operations.
* Consider **composite indexes** when queries frequently filter by multiple columns.
* Review and remove unused indexes periodically to reduce maintenance overhead.



## 5. Query Optimization

- Execution Plan
- Cost-Based Optimizer
- Index Scan
- Index Seek
- Table Scan
- Query Tuning

## 6. Transactions

- ACID
- Transaction Lifecycle
- Commit
- Rollback
- Savepoints

## 7. Isolation Levels

- Read Uncommitted
- Read Committed
- Repeatable Read
- Serializable
- Snapshot Isolation

## 8. Concurrency Control

- Pessimistic Locking
- Optimistic Locking
- MVCC
- Deadlocks

## 9. NoSQL

- Key-Value
- Document
- Column Family
- Graph Database
- Time-Series Database

## 10. Implementations

- SQL Server
- PostgreSQL
- MySQL
- MongoDB
- Cassandra
- Redis
- Neo4j

## 11. Interview Problems

- Prepare common interview questions on database design, SQL, indexing, transactions, and scaling.

