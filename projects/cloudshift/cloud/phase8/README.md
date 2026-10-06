# Phase 8 — Portfolio Finalization

## 1. Repository hygiene

```bash
git status
```

Review anything untracked before committing.

Do not commit:

- `.env`
- credentials
- local emulator state
- Python caches
- OS files
- generated local data volumes

## 2. Validate documentation links

Open `README.md` in GitHub/VS Code preview and verify:

- Mermaid diagrams render
- evidence links work
- Phase 7 report exists
- no secret values appear
- no claims say Cloud Run/Cloud SQL were deployed live

## 3. Capture screenshots

Recommended screenshots:

1. Swagger `/docs`
2. Grafana CloudShift Operations dashboard
3. Firestore audit-events response
4. `EXPLAIN ANALYZE` before index
5. `EXPLAIN ANALYZE` after index
6. one structured JSON log
7. Phase 7 results/evidence directory

Store screenshots under:

```text
docs/screenshots/
```

## 4. Final verification

```bash
bash cloud/phase8/final-check.sh
```

## 5. Git checkpoint

```bash
git add .
git commit -m "Finalize CloudShift portfolio documentation"
git tag cloudshift-v1.0
```

## 6. Push

```bash
git push origin main
git push origin cloudshift-v1.0
```
