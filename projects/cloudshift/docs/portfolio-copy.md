# Portfolio / CV / LinkedIn Copy

## CV — Compact Version

**CloudShift — Cloud Migration & Troubleshooting Lab**

- Built and containerized a Python/FastAPI + PostgreSQL order-management platform and designed its migration architecture for Google Cloud Run, Cloud SQL, Firestore, Artifact Registry and Secret Manager.
- Created and resolved **7 production-style incidents** spanning configuration, downstream API latency, HTTP semantics, container networking, PostgreSQL performance, API authentication and database connection-pool saturation.
- Performed PostgreSQL `EXPLAIN ANALYZE` investigation on a 100K+ order dataset and implemented a composite index that reduced measured DB execution time by approximately **44%**.
- Added structured JSON logging, Prometheus metrics, Grafana dashboards and Firestore-emulator audit events, then revalidated all seven incidents using operational telemetry and before/after evidence.
- Executed repeatable load tests at 1,000 requests / 50 concurrency with 0% failures in both the baseline and Cloud Run-style validation environments.

## CV — Short Version

**CloudShift — Cloud Migration & Troubleshooting Lab**  
Python, FastAPI, PostgreSQL, Docker, Firestore, Prometheus, Grafana, Google Cloud architecture

Designed and validated a containerized cloud migration architecture for a legacy order-management workload; resolved 7 reproducible operational incidents covering API, container, database, configuration, authentication and capacity failures, with structured observability and measured remediation evidence.

## LinkedIn Project Description

CloudShift is a cloud migration and troubleshooting lab built around a fictional GCC distributor whose legacy order-management application can no longer reliably support increasing traffic.

The project includes a containerized FastAPI/PostgreSQL application, Google Cloud migration architecture, Firestore-style audit events, structured logging, Prometheus/Grafana observability, performance benchmarking, and seven reproducible operational incidents with broken/fixed evidence.

Key investigations include PostgreSQL query optimization on a 100K+ order dataset, downstream API timeout diagnosis, container listening failures, authentication problems, and database connection-pool saturation.

The project is designed to demonstrate the full Customer Engineer workflow: understand the workload, design the migration, prototype the architecture, observe system behavior, troubleshoot operational failures, and explain the root cause clearly.

## GitHub One-Liner

**CloudShift — containerized cloud migration and troubleshooting lab with FastAPI, PostgreSQL, Firestore audit events, Prometheus/Grafana observability, and 7 reproducible incidents.**

## Interview One-Liner

> I built a legacy application, designed its Google Cloud migration path, deliberately broke it seven different ways, and built the observability needed to prove exactly why each failure happened.
