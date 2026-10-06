# Hassan Ali Rajab

### AI & Technology Consulting · Enterprise GenAI · Applied ML

I build and analyze AI systems through the full enterprise lens:

**business problem → use-case decision → architecture → evaluation → governance → implementation**

My background spans networking engineering, cybersecurity, cloud/DevOps and machine learning. I am currently pursuing an **MSc in Machine Learning & Computational Intelligence at the University of Bahrain**, with a research focus in Quantum Machine Learning.

The common thread across my work is simple: **the model is only one part of the system.** I focus on access control, data flows, grounding, failure modes, APIs, deployment, observability, human approval and measurable value around it.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-0A66C2?style=for-the-badge&logo=linkedin)](https://lnkd.in/p/dKNnbPtN)

---

## Flagship case — NEXUS Enterprise AI

### The problem
How can an enterprise use generative AI for internal knowledge and workflows **without weakening authorization, evidence quality, auditability or human authority?**

### The recommendation
**Governed read-only RAG → department copilot → approval-gated actions**

### Architecture
```text
identity
  → server-side entitlements
  → retrieval-time ACLs
  → hybrid retrieval
  → reranking
  → evidence sufficiency
  → grounded answer + citations / abstention
  → audit

separate action plane:
request → allowlist/schema → human approval → guarded execution → audit
```

### Verified evidence
Pinned NEXUS CI reference run:
- **14/14** backend/security tests passed
- **8-case** strict controlled RAG evaluation
- **1.000** retrieval hit@k
- **1.000** citation rate
- **1.000** citation-to-source integrity
- **1.000** grounding-decision accuracy
- **1.000** language-match rate
- **1.000** grounded keyword coverage

These are controlled fictional-corpus results, not production guarantees.

**[Open NEXUS →](https://github.com/hasan-rajab/Gulf-Policy-Assistant)**

---

## Selected systems

| Project | Business / operating problem | Architecture & evidence |
|---|---|---|
| **[NEXUS](https://github.com/hasan-rajab/Gulf-Policy-Assistant)** | trusted enterprise GenAI knowledge and controlled automation | governed bilingual RAG, retrieval-time ACLs, approval gates, audit, 22 automated validation checks in pinned reference run |
| **[NexusMind](https://github.com/hasan-rajab/NexusMind)** | governed agentic workflows in Microsoft environments | Foundry, Azure OpenAI, Azure AI Search, bounded tools/memory; governance/API tests across Python 3.10 and 3.12 |
| **[SentinelIQ](https://github.com/hasan-rajab/SentinelIQ)** | help security analysts prioritize and explain anomalous telemetry | Kafka, XGBoost, autoencoders, BERT, MITRE ATT&CK, PostgreSQL, Prometheus; inference-integrity CI |
| **[CloudShift](https://github.com/hasan-rajab/hasan-rajab/tree/main/projects/cloudshift)** | diagnose database, API and cloud-migration risks in a fictional order platform | FastAPI/PostgreSQL, Firestore emulator, seven recorded troubleshooting scenarios; [raw SQL plans and reproduction guide](projects/cloudshift/docs/CV_EVIDENCE.md) |
| **[ForgeML + Falcon](https://github.com/hasan-rajab/tabulaai)** | move ML from experiments to governed real-time decisions | model registry, canary/rollback, Kafka decisioning, champion/challenger, delayed feedback; lifecycle + decisioning regression tests |
| **[Infobip Solution Engineering Demo](https://github.com/hasan-rajab/infobip-solution-engineering-demo)** | safe customer-messaging automation and escalation | webhook parsing, deduplication, approved FAQ routing, outbound WhatsApp API; verified HTTP 200 + delivered trial message |
| **[SecureBERT Threat Lab](https://github.com/hasan-rajab/ML-Threat-Detector)** | semantic threat analysis beyond signatures | SecureBERT, session embeddings, DBSCAN, MITRE context, analyst dashboard |

---

## Consulting capabilities

### AI strategy and discovery
- use-case framing and prioritization
- business value vs feasibility vs risk
- KPI and pilot design
- build / buy / integrate thinking

### Enterprise GenAI
- RAG and hybrid retrieval
- embeddings, reranking and grounding
- agents and tool use
- evaluation, abstention and human escalation
- approval-gated workflows

### AI governance and security
- RBAC / IAM / least privilege
- retrieval authorization
- auditability
- prompt-injection and data-leakage thinking
- explainability and model-integrity controls

### Cloud and delivery
- REST APIs and microservices
- Docker and Kubernetes fundamentals
- Terraform
- CI/CD
- Kafka
- Azure, AWS and OCI foundations

### Applied ML
- anomaly detection
- classification
- NLP / BERT
- autoencoders
- XGBoost
- SHAP / feature attribution
- precision/recall and threshold trade-offs

---

## Education

**MSc — Machine Learning & Computational Intelligence**  
University of Bahrain · 2025–2027 expected  
Research focus: Quantum Machine Learning

**BSc — Networking Engineering**  
University of Bahrain · 2021–2025

---

## Certifications and technical development

- CompTIA **Security+**
- AWS **Certified Cloud Practitioner**
- Microsoft **Azure Fundamentals**
- OCI DevOps Professional — course preparation / exam study

---

## Current direction

I am focused on early-career opportunities across the GCC where AI has to work inside real organizational constraints:

- AI Consulting
- Enterprise GenAI
- AI / ML Engineering
- Solution / Forward-Deployed Engineering
- AI Governance & Technology Transformation

I am especially interested in teams that need someone who can move between **business framing, technical architecture, implementation and governance** rather than treating those as separate conversations.

---

## Claims philosophy

I separate:
- **repository-backed results** from assumptions;
- **synthetic benchmarks** from production performance;
- **reference architectures** from live enterprise deployments;
- **business-case illustrations** from realized client ROI.

That distinction is intentional. Strong AI work should be technically defensible and commercially useful at the same time.
