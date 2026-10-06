# Engineering Defense — CloudShift

CloudShift should be used to prove customer engineering, debugging discipline and cloud/infrastructure judgment.

## 30-second pitch

CloudShift simulates a GCC distributor whose legacy order system is becoming unreliable as traffic grows. I built the FastAPI/PostgreSQL workload, containerized it, established performance baselines, designed a Google Cloud migration path, added observability, and then reproduced seven operational failures covering configuration, downstream timeouts, HTTP semantics, container networking, SQL indexing, authentication and connection-pool saturation. Every scenario follows symptom → evidence → hypothesis → root cause → remediation → verification.

## Adversarial engineering questions

### Why is this a forward-deployed project rather than a cloud tutorial?
The unit of work is a customer outcome: restore reliability and create a migration path. The cloud services are implementation choices. The repository starts from symptoms and operational constraints, then uses measurement and failure reproduction to decide what to change.

### Why Cloud Run rather than Kubernetes?
The workload is a stateless HTTP application and does not demonstrate a requirement for cluster-level control. Cloud Run reduces operational surface area. I would choose GKE only if workload constraints—custom networking, sidecars, specialized scheduling, long-running processes or platform standardization—justify the extra complexity.

### Why PostgreSQL plus Firestore?
Orders, products and inventory have relational/transactional semantics, so PostgreSQL remains the source of truth. Audit events are append-oriented and accessed differently, which makes a document/event store a reasonable separate concern. The design is intentionally polyglot only where the access pattern differs.

### How did you diagnose the slow order query?
I reproduced the symptom on 100k+ orders, used `EXPLAIN ANALYZE`, observed a sequential scan and rows removed by filter, identified that the query filters by customer and orders by creation time, then added a composite `(customer_id, created_at DESC)` index and re-ran both database and application benchmarks.

### Why is a 44% database execution improvement not the whole story?
Because the endpoint can still return 25,000 rows. Indexing fixes access-path cost, not unbounded response size. Pagination/limits and customer usage requirements are the next layer; otherwise network serialization and application memory become dominant.

### What happens when the shipping service is slow?
The API has a bounded downstream timeout, records dependency outcome/latency metrics, emits structured logs/audit events, and returns a 504 for timeouts. A production version would also consider retry policy only for safe/idempotent requests, circuit breaking, bulkheads and an explicit customer-facing degradation strategy.

### How do you avoid retry storms?
The current demo does not implement automatic retries. That is intentional: retries without idempotency/backoff/budgeting can amplify an outage. I would add exponential backoff with jitter and a retry budget only for failure classes known to be transient and safe to repeat.

### Is order creation concurrency-safe?
Not fully at production scale. Input validation now rejects duplicate product IDs inside a single order, but the portfolio implementation does not claim globally correct inventory reservation under concurrent writers. In PostgreSQL I would lock inventory rows in deterministic product-ID order with `SELECT ... FOR UPDATE`, or use an atomic conditional update/reservation model, and add concurrent oversell tests. This is an explicit next hardening item, not a hidden claim.

### Why structured logs plus Prometheus?
Metrics answer aggregate operational questions quickly—rates, errors, latency distributions—while structured logs preserve request-level context such as request IDs and dependency outcomes. They serve different debugging layers and should be correlated rather than substituted for each other.

### Why not claim Cloud Run performance?
Because the measured “cloud-style” environment is still local Docker. The repository validates runtime compatibility and architecture, not cloud latency/cost. A real claim requires an actual cloud deployment, controlled load test and comparable environment.

### What breaks at 10x traffic?
I would expect database connection pressure, large result sets, downstream dependency saturation and synchronous request latency to appear before CPU-bound FastAPI logic. I would use existing metrics to verify that hypothesis, then address query bounds/indexes, pool sizing, dependency protection and horizontal scaling in that order.

### The customer wants this in one week. What do you cut?
Keep the highest-value workflow: containerized application, database reliability, health/observability, one migration target, and the top production failure modes. Defer cosmetic dashboards, secondary stores and broad cloud-service adoption until the core service has measurable SLOs and a rollback path.

## Code/evidence anchors

- `app/main.py` — API behavior, downstream timeout handling and operational metrics
- `app/schemas.py` — boundary validation
- `scripts/` — seeding/load/performance evidence
- `scenarios/` — reproducible failures
- `cloud/phase7/evidence/` — broken/fixed operational evidence
- `docs/troubleshooting-scoreboard.md` — incident summary
- `.github/workflows/ci.yml` — clean-checkout verification

## Claims boundary

Do not claim a live Google Cloud deployment, production-grade inventory concurrency, enterprise IAM or Internet-scale throughput. Claim reproducible migration/troubleshooting engineering, measured local performance, explicit failure evidence and a defensible production evolution path.
