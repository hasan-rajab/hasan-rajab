# CloudShift Interview Guide

## 30-Second Version

CloudShift is a cloud migration and troubleshooting lab I built around a fictional GCC distributor. I created the original FastAPI/PostgreSQL order-management application, containerized it, measured its performance, designed its Google Cloud migration architecture, added Firestore-style audit storage and observability, and then built seven production-style incidents covering configuration, API latency, HTTP semantics, containers, SQL, authentication, and database connection saturation. Each case has root-cause evidence and a verified fix.

## 2-Minute Walkthrough

The customer problem was a legacy internal order-management application running on infrastructure that could no longer reliably support growing traffic.

I started by building the original system in Python with FastAPI and PostgreSQL, then containerized the frontend, API, and database with Docker Compose.

Before changing the architecture, I established a measurable baseline using 1,000 requests at concurrency 50. The system handled all 1,000 requests successfully.

I then generated more than 100,000 orders to investigate database scaling. `EXPLAIN ANALYZE` showed a sequential scan for customer order history. I created a composite index on customer ID and descending creation time, which reduced PostgreSQL execution time by roughly 44%.

For the migration architecture, I designed the API for Cloud Run, PostgreSQL for Cloud SQL, audit events for Firestore, images for Artifact Registry, and credentials for Secret Manager. Because I kept the project strictly zero-cost, I validated Cloud Run-style runtime behavior locally rather than claiming a live deployment.

The strongest part of the project is troubleshooting. I created seven reproducible incidents and later reran them through a full observability stack using structured JSON logs, Prometheus, Grafana, and Firestore audit events.

So the project demonstrates not just that I can design a cloud architecture, but that I can diagnose what happens when configuration, dependencies, containers, APIs, databases, or capacity fail.

## Strong Interview Questions

### Why didn't you move all data to Firestore?

Orders and order items are relational and transactional. PostgreSQL is a stronger fit for the system of record. Firestore is used for append-oriented operational events where a document model is natural.

### Why use a composite index?

The order-history query filters on `customer_id` and sorts by newest first. `(customer_id, created_at DESC)` supports both the lookup and ordering pattern.

### Why didn't you just increase the API timeout?

That would hide the downstream degradation and consume request capacity for longer. The correct diagnosis was that the dependency itself was slow.

### What did Scenario 04 teach you about Cloud Run?

A running process is not equivalent to a reachable service. Containerized applications must listen on the correct interface and runtime port.

### What is the risk when Cloud Run scales against Cloud SQL?

Application instances can scale faster than database connection capacity. Connection-pool limits, concurrency, and maximum instance count must be designed together.

### Why structured logging?

Structured fields make logs searchable by request ID, endpoint, severity, dependency, status, order ID, and latency rather than relying on unstructured string matching.

### What would you do before a real production migration?

- dependency inventory
- data migration strategy
- IAM design
- secrets
- network/security requirements
- backup/rollback plan
- performance and availability SLOs
- staging deployment
- production cutover plan
- post-cutover monitoring
- rollback criteria

## Project Weakness / Honest Limitation

The main limitation is that the Google Cloud deployment is architecture-ready but not live because the project was deliberately kept zero-cost.

That is not something to hide. The project still validates Cloud Run runtime compatibility, Cloud SQL connectivity design, Firestore usage, secret-management design, observability, troubleshooting, and migration procedures.
