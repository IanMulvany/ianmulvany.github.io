# BMJ Data Platform — GCP Landing Zone & Data Platform (`_tf`)

Infrastructure-as-Code for the **BMJ Data Roadmap** target architecture on
Google Cloud. This repository takes the *Reference GCP Platform Architecture*
and the *Reference Data Architecture blueprint* and turns them into deployable,
BMJ-standards-compliant Terraform — accelerating the move **from POC to
delivery**.

> ⚠️ **This is a blueprint, not a live deployment.** Every org-specific value
> (org ID, billing account, Entra tenant, AD groups, CIDRs) is a
> `REPLACE_WITH_*` placeholder. **Nothing here deploys as-is** — by design.
> See [`docs/DECISIONS.md`](docs/DECISIONS.md).

🔎 **Explore it interactively:** open [`explorer/index.html`](explorer/index.html)
in a browser — a self-contained, offline app (no server needed) with eight
views:
- **Architecture** — the four-layer reference diagram (cards).
- **Diagram** — the architecture and GitOps flow rendered as **Mermaid**
  (`explorer/diagrams/*.mmd`), with zoom/pan and a view-source toggle.
  **Every component is clickable** — clicking a node jumps straight to the
  Terraform (or workflow/config) that provisions it, opened in the Files tab.
- **Terraform** — every resource directory and module, click for detail.
- **Files** — a tree navigator + syntax-highlighted viewer for **every**
  `.tf`, `.tfvars`, workflow, config and doc in the repo (with Copy).
- **Source systems**, **Data flow**, **Security & compliance**, **Decisions**.

Mermaid is vendored locally at `explorer/vendor/mermaid.min.js` so the diagram
renders under `file://` with no network. The diagram sources live in
`explorer/diagrams/` and are also browsable from the Files tab.

---

## 1. What this provisions

```
SOURCES ─▶ CONNECTIVITY & TRUST ─▶ GCP DATA PLATFORM ─▶ CONSUMPTION
(33 systems)  (private network,      (DEV / TEST / PROD     (Tableau, Hum,
              VPC-SC, Entra SSO)      isolated projects)     3rd-party, Vertex)
```

| Architecture layer | Implemented by (`terraform/<dir>`) | Key GCP services |
|--------------------|-------------------------------------|------------------|
| Landing zone / resource hierarchy | `folders-projects` | Folders, Projects, API enablement |
| Identity & access (AD/Entra SSO) | `workforce-identity-federation`, `org-iam` | Workforce Identity Federation, IAM |
| Connectivity & trust boundary | `networking`, `private-connectivity` | VPC, Cloud NAT, Private Google Access, PSC, Private Service Access, Cloud DNS |
| Data-protection guardrails | `kms`, `secret-manager`, `vpc-service-controls` | Cloud KMS (CMEK), Secret Manager, VPC Service Controls |
| Ingestion (EL) | `airbyte-gke` | GKE Autopilot, Artifact Registry |
| Storage — data lake | `gcs-data-lake` | GCS (landing/staging/archive/tmp/logs) |
| Warehouse — medallion | `bigquery` | BigQuery (raw→bronze→silver→gold + reference + catalog), Dataplex |
| Transformation (T) | `dbt-cloudbuild` | dbt on Cloud Build, Pub/Sub, Cloud Scheduler |
| Orchestration | `composer`, `orchestration` | Cloud Composer (Airflow), Cloud Workflows, Scheduler |
| Consumption access | `consumption-access` | Least-priv SAs for Tableau/Hum/3rd-party/Vertex |
| Observability & cost | `monitoring`, `budgets` | Cloud Monitoring, Logging, audit sinks, Billing Budgets |
| State bootstrap | `bootstrap` | GCS state buckets (`bmj-data-{env}-tfstate`) |

---

## 2. Repository layout

```
bmj-data-platform_tf/
├── terraform/                 # one directory per GCP resource/capability type
│   └── <dir>/
│       ├── providers.tf       # google ~> 6.0, region default europe-west2
│       ├── backends.tf        # GCS remote state
│       ├── variables.tf
│       ├── main.tf
│       ├── outputs.tf
│       └── params/
│           ├── dev/{backends,params}.tfvars
│           ├── stg/{backends,params}.tfvars   # stg == the TEST project
│           └── live/{backends,params}.tfvars
├── modules/                   # reusable building blocks
│   ├── project/  bigquery-dataset/  gcs-bucket/  service-account/
│   ├── vpc-network/  kms-keyring/  secret/  workforce-identity/  budget/
├── .github/
│   ├── workflows/             # Pattern 3 GitOps: plan / dev / live / dispatch + lint + checkov
│   └── dependabot.yml         # SHA-pinned actions + terraform deps
├── config/
│   └── source_systems.{yaml,json}   # 33 BMJ sources → Airbyte + Secret Manager
├── docs/DECISIONS.md          # the decision log (21 logged decisions)
├── explorer/index.html        # interactive architecture + IaC explorer
├── cloudbuild.dbt.yaml        # dbt Cloud Build runner contract
├── AGENTS.MD  CODEOWNERS  .checkov.yaml  .gitignore
└── README.md
```

Directory names are **GCP resource/capability types**, never business names —
the BMJ Pattern 3 (`_tf`) convention, so infrastructure is visible from the
tree at a glance.

---

## 3. Environments & projects

| BMJ env | GCP project (placeholder) | Diagram tier | State bucket |
|---------|---------------------------|--------------|--------------|
| `dev`   | `bmj-data-dev`            | DEV          | `bmj-data-dev-tfstate` |
| `stg`   | `bmj-data-test`           | **TEST**     | `bmj-data-stg-tfstate` |
| `live`  | `bmj-data-prod`           | PROD         | `bmj-data-live-tfstate` |
| (seed)  | `bmj-data-mgmt`           | management   | hosts the three state buckets |

State key convention mirrors BMJ AWS: bucket `bmj-data-{env}-tfstate`,
`prefix = bmj-data-platform_tf/<dir>` (cf. AWS `{repo}/{dir}/terraform.tfstate`).

---

## 4. Security & compliance (ISO27001 / ISO14001)

| Control | How it's met |
|---------|--------------|
| Encryption at rest (A.10.1.2) | CMEK on BigQuery, GCS, Composer, Pub/Sub, Secret Manager; per-domain keys; 90-day rotation |
| Encryption in transit (A.10.1) | Private Google Access + TLS; no public data endpoints |
| Least privilege (A.9.2) | Scoped service accounts, dataset-level grants, AD-group→role mapping, no `roles/owner` for admins |
| No static credentials | Workforce Identity Federation (humans) + Workload Identity (workloads); **no SA keys** |
| No secrets in code | Secret Manager *shells*; values populated out-of-band |
| Network isolation | Private VPC, default-deny ingress, Cloud NAT egress only, **VPC Service Controls** perimeter |
| Audit trails (A.12.4) | VPC flow logs, NAT logs, audit-log sink (≥12-month retention), data-access audit config |
| Change management (A.12.1.2) | PR → plan → review → merge; Checkov + Superlinter gates; CODEOWNERS |
| Resource efficiency (ISO14001) | GKE Autopilot, right-sized Composer, GCS lifecycle tiering, billing budgets, labels for cost/carbon attribution |

Checkov runs as a **hard gate** (`soft-fail: false`) — the modules bake in the
controls it checks (UBLA, public-access-prevention, versioning, CMEK, flow logs,
no `0.0.0.0/0`).

---

## 5. How to use it (first-time bring-up)

> Requires real org values first — see "Before you apply" below.

```bash
# 0. Authenticate as a human via Entra ID SSO (once WIF is wired)
gcloud auth application-default login

# 1. Bootstrap state buckets per environment (LOCAL backend, run once)
cd terraform/bootstrap
terraform init
terraform apply -var-file=params/dev/params.tfvars     # repeat for stg, live

# 2. For every other directory: init against the GCS backend, plan, review
cd ../folders-projects
terraform init  -backend-config=params/dev/backends.tfvars
terraform plan  -var-file=params/dev/params.tfvars
checkov -d .                                            # security gate

# Recommended apply order (dependencies flow downward):
#   bootstrap → folders-projects → org-iam → networking → private-connectivity
#   → kms → secret-manager → vpc-service-controls → gcs-data-lake → bigquery
#   → airbyte-gke → dbt-cloudbuild → composer → orchestration
#   → consumption-access → monitoring → budgets
#   (workforce-identity-federation is org-level, applied once from live)
```

**In practice you don't apply locally.** Push a branch, open a PR, and let the
GitOps workflows plan it (BMJ execution discipline — see §6).

---

## 6. GitOps deployment flow

| Trigger | Workflow | Effect |
|---------|----------|--------|
| Open / update a PR | `plan-infrastructure` | Checkov + plan for every changed dir × env (plan-only) |
| Merge to `main` | `dev-infrastructure` | Apply changed dirs to **dev** |
| Manual dispatch | `dispatch-run-infrastructure` | Apply any dir to any env (used for **stg/TEST** and initial bring-up) |
| Publish a Release | `live-infrastructure` | Apply changed dirs to **live/PROD** |
| Any push / PR | `lint`, `checkov` | Superlinter + standalone Checkov |

The `SERVICES` map in each workflow is the source of truth for which directories
exist and which environments they target. **When you add a resource directory,
add it to every `SERVICES` map and the dispatch choice list.**

> The reusable workflows reference `BMJ-Ltd/github-actions-terraform@main` with a
> `CLOUD: gcp` input. That GCP authentication path needs to exist in the shared
> workflow (Workload Identity Federation) before these run green — see
> DECISIONS.md **D-009**. Raise an OPSQ/PLAT ticket.

---

## 7. Source systems & ingestion

`config/source_systems.{yaml,json}` is generated from the supplied CSV — **33
source systems** (10 SFTP, 11 API, 9 database, 3 other). Each entry carries the
hosting model, data format, volumes, refresh cadence, load type, a **suggested
Airbyte connector**, and the matching **Secret Manager secret id**. The
`secret-manager` directory creates a credential shell per system from this list.

Notable scale/》shape:
- Largest: **LRS** (~2 TB, ~20% of the warehouse), **SiQ** (~1 TB, monthly).
- ~half incremental, ~half full loads; daily windows from 10 min to 3 hrs.
- Several archive-only sources (Salesforce Old, Veterinary, Mobile App) → the
  `archive` GCS bucket + cold storage class.

---

## 8. Before you apply (checklist)

- [ ] Replace `REPLACE_WITH_*` in every `params/*/params.tfvars` (org id,
      billing account, parent folder, Entra tenant/client, group emails, CIDRs,
      project numbers, audit bucket).
- [ ] Confirm region default (`europe-west2`) vs any existing GCP standard.
- [ ] Stand up the Entra ID app registration + group claims for WIF.
- [ ] Provide a GCP-capable variant of the BMJ Terraform reusable workflow.
- [ ] Provision an org-level Access Context Manager policy (for VPC-SC).
- [ ] BISO sign-off on the AD-group → IAM-role mapping (`org-iam`).
- [ ] Run `terraform fmt -recursive`, `terraform validate`, `checkov -d .`.

---

## 9. Related BMJ standards

- Org agent standards: `BMJ-Ltd/arg-agentic-configuration`
- `_tf` template: `BMJ-Ltd/arg-example_tf`
- Reusable Terraform workflows: `BMJ-Ltd/github-actions-terraform`
- Quality gates: `BMJ-Ltd/github-actions-superlinter`, `BMJ-Ltd/code-standards`
- ARG: #architecture-review-group · Alex Hooper (chair) · Marie Ashworth (BISO)

---

*Generated as a POC accelerator for the BMJ Data Roadmap. Decisions and
rationale: [`docs/DECISIONS.md`](docs/DECISIONS.md).*
