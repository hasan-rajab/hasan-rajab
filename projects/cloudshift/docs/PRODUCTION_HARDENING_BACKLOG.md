# Production Hardening Backlog

This file records known gaps that are intentionally not disguised as completed production capabilities.

## P0 — inventory concurrency

The current local order flow validates stock and decrements inventory in the request transaction, but it does not claim globally safe inventory reservation under concurrent writers.

Production hardening should:

1. lock all affected product rows in deterministic product-ID order with PostgreSQL `SELECT ... FOR UPDATE`, or use an atomic conditional reservation/update strategy;
2. make reservation/checkout semantics explicit;
3. add concurrent tests proving stock cannot go negative or oversell;
4. define retry behavior for serialization/deadlock failures;
5. separate reservation expiry/release from order creation if the business workflow requires it.

## P1 — diagnostic endpoints

Failure-injection/diagnostic routes exist for the lab. A real deployment should place them behind an explicit non-production feature flag and authenticated operator boundary, or remove them from the production image entirely.

## P1 — authentication/authorization

The lab focuses on migration and reliability rather than end-user identity. A production service needs enterprise identity, least-privilege service credentials, authorization rules for business operations, and secret-manager integration.

## P1 — pagination and response bounds

The customer-order endpoint can return a large history. Add cursor/keyset pagination, explicit maximum page size and load tests around realistic access patterns.

## P2 — resilience policy

Add circuit-breaking/bulkhead behavior and carefully bounded retries only for safe transient dependency failures. Define SLOs and alert thresholds before tuning infrastructure blindly.
