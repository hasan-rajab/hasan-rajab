# Troubleshooting Scoreboard

## Case 01 — Bad Environment Variable

**Customer symptom:** API unavailable after configuration change.

**Evidence**

- API container exits
- PostgreSQL remains healthy
- logs report nonexistent database
- deployed `DB_NAME` differs from actual DB

**Root cause:** incorrect database name.

**Skill signal:** configuration analysis, Linux/Docker, database connectivity.

---

## Case 02 — API Timeout

**Customer symptom:** shipping quote requests fail while core API remains healthy.

**Evidence**

```text
Shipping direct response ≈ 4 seconds
CloudShift timeout budget = 1 second
CloudShift response = HTTP 504
```

**Root cause:** downstream dependency latency exceeded timeout budget.

**Skill signal:** latency isolation, dependency troubleshooting, HTTP 504.

---

## Case 03 — Incorrect HTTP Status

**Customer symptom:** client reports missing resources as successful requests.

**Broken behavior**

```text
HTTP 200
{"error":"Order not found"}
```

**Correct behavior**

```text
HTTP 404
```

**Skill signal:** REST semantics, monitoring correctness, regression testing.

---

## Case 04 — Container Configuration

**Customer symptom:** container process is running but service is unreachable.

**Evidence**

- internal `127.0.0.1` request succeeds
- external request fails
- process binds only to loopback

**Root cause:** incorrect listening interface.

**Skill signal:** containers, networking, runtime contracts.

---

## Case 05 — Database Bottleneck

**Customer symptom:** customer order history slows as records grow.

**Before**

```text
Seq Scan on orders
75,002 unrelated rows discarded
Execution: 25.068 ms
```

**After**

```text
Index Scan
Execution: 13.933 ms
```

**Remediation**

```sql
CREATE INDEX idx_orders_customer_created_at
ON orders (customer_id, created_at DESC);
```

**Skill signal:** PostgreSQL, indexing, query plans, performance engineering.

---

## Case 06 — API Authentication Failure

**Customer symptom:** shipping integration fails after credential change.

**Evidence**

- upstream `401`
- CloudShift controlled dependency failure
- wrong Bearer token
- structured auth-failure logs

**Root cause:** invalid API token.

**Skill signal:** HTTP auth, headers, API integration.

---

## Case 07 — Connection Pool Saturation

**Customer symptom:** traffic spike produces database-backed HTTP 503 responses.

**Evidence**

- high concurrency
- very small connection pool
- pool acquisition timeout
- 5xx metrics increase

**Remediation**

- increase controlled connection capacity
- validate under identical workload
- return to zero failures

**Skill signal:** concurrency, DB capacity, load testing, scaling design.

---

# Overall Troubleshooting Method

```text
Define symptom
    ↓
Reproduce
    ↓
Observe health
    ↓
Collect logs/metrics
    ↓
Separate application from dependency
    ↓
Form hypothesis
    ↓
Test hypothesis
    ↓
Identify root cause
    ↓
Apply smallest corrective action
    ↓
Re-run same verification
    ↓
Document prevention
```
