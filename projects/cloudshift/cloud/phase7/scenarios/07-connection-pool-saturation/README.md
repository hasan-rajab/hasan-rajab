# Scenario 07 — Connection Pool Saturation
Expected signals: broken state yields controlled 503s, db_pool_timeout JSON logs and rising 5xx metrics; fixed state returns to zero failures under the same workload.
