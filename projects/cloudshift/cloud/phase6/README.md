# Phase 6 — Firestore + Observability

This is the zero-cost local implementation of CloudShift's NoSQL and observability layer.

## Components

- Firestore local emulator — audit/event documents
- PostgreSQL — transactional data
- structured JSON application logs
- Prometheus — metric collection
- Grafana — operations dashboard

## 1. Firestore preflight

```bash
bash cloud/phase6/00-firestore-preflight.sh
```

The Firestore emulator requires the gcloud CLI and Java 21+. The preflight also installs/updates the `cloud-firestore-emulator` gcloud component.

## 2. Start Firestore

```bash
bash cloud/phase6/01-start-firestore.sh
```

The emulator runs on:

```text
localhost:8085
```

It is intentionally local-only test infrastructure.

## 3. Start Phase 6 stack

```bash
bash cloud/phase6/02-start-stack.sh
```

Services:

```text
Frontend    http://localhost:3000
API         http://localhost:8080
Shipping    http://localhost:9000
Prometheus  http://localhost:9090
Grafana     http://localhost:3001
Firestore   localhost:8085
```

Grafana development login:

```text
admin / cloudshift
```

## 4. Seed PostgreSQL

```bash
bash cloud/phase6/03-seed.sh
```

## 5. Generate telemetry

```bash
bash cloud/phase6/04-generate-observability-data.sh
```

This creates:

- normal API traffic
- controlled 404s
- new orders
- Firestore `ORDER_CREATED` audit events
- shipping dependency calls

## 6. Verify

```bash
bash cloud/phase6/05-verify.sh
```

Then open Grafana:

```text
http://localhost:3001
```

Open:

```text
Dashboards → CloudShift → CloudShift Operations
```

## 7. Inspect Firestore events

```bash
curl "http://localhost:8080/audit-events?limit=20"
```

For one order:

```bash
curl "http://localhost:8080/orders/1/audit-events"
```

## 8. Inspect structured logs

```bash
docker logs cloudshift-p6-api --tail=50
```

Each application log line is JSON.

## Cleanup

```bash
bash cloud/phase6/cleanup.sh
```

## Important limitation

The Firestore emulator is for local testing and its data is not persistent across emulator restarts. A live Firestore deployment can also require indexes that the emulator does not enforce.
