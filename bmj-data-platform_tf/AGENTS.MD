# BMJ Data Platform (_tf) — Agent Configuration

> This repository follows BMJ organisation-wide standards.
> See: https://github.com/BMJ-Ltd/arg-agentic-configuration/blob/main/AGENTS.MD

## Quick Context

GCP landing zone and data-platform infrastructure-as-code for the BMJ Data
Roadmap. This is a **Pattern 3 (`_tf`) shared-resources repo** translated to
**Google Cloud**: it provisions the medallion data warehouse (BigQuery), the
GCS data lake, ingestion (Airbyte on GKE), transformation (dbt + Cloud Build),
orchestration (Cloud Composer / Workflows), security guardrails (KMS, Secret
Manager, VPC Service Controls, Workforce Identity Federation against Entra ID),
and the consumption access layer (Tableau / Hum / third-party / Vertex AI).

The platform is **GCP**, while most existing BMJ infra is AWS. The translation
decisions (state backend, accounts→projects, OIDC, tags→labels) are recorded in
[`docs/DECISIONS.md`](docs/DECISIONS.md).

## Key Files

- `terraform/<resource-dir>/` — one directory per GCP resource/capability type
  (BMJ Pattern 3 convention). Each has `providers.tf`, `backends.tf`,
  `variables.tf`, `main.tf`, `outputs.tf`, and `params/{dev,stg,live}/`.
- `modules/` — reusable building blocks (project, bigquery-dataset, gcs-bucket,
  service-account, vpc-network, kms-keyring, secret, workforce-identity, budget).
- `.github/workflows/` — Pattern 3 GitOps (`plan`, `dev`, `live`, `dispatch`).
- `config/source_systems.yaml` — the 30+ BMJ source systems and their ingestion
  metadata (drives Airbyte connector planning).
- `explorer/index.html` — interactive architecture + IaC explorer.

## Local Development

```bash
# Validate a single resource dir (DEV) — PLAN ONLY, never apply locally.
gcloud auth application-default login            # human SSO via Entra ID
cd terraform/<dir>
terraform init -backend-config=params/dev/backends.tfvars
terraform plan -var-file=params/dev/params.tfvars
checkov -d .                                     # security gate
terraform fmt -recursive ../..
```

## Deployment

GitOps only — **do not `terraform apply` locally** (BMJ execution discipline):
1. Branch from `main`, make changes, `terraform fmt` + `checkov`.
2. Open PR → `plan-infrastructure` posts the plan; Checkov + Superlinter gate.
3. Merge to `main` → `dev-infrastructure` applies to DEV.
4. STG (TEST) applies via `dispatch-run-infrastructure` (manual).
5. Publish a GitHub Release → `live-infrastructure` applies to LIVE (PROD).

When you add a new resource directory, add it to the `SERVICES` map in **all**
workflow files and to the `dispatch` choice list.

## Repo-Specific Guardrails

- **Do not deploy as-is.** `params.tfvars` contain `REPLACE_WITH_*` placeholders
  for org ID, billing account, Entra tenant/client IDs, group emails, and CIDRs.
- No service-account keys; humans use Workforce Identity Federation, workloads
  use Workload Identity / attached SAs.
- No secret values in code — Secret Manager shells only.
- CMEK on BigQuery, GCS, Composer, Pub/Sub, Secret Manager.
- `stg` params map to the **TEST** project (`bmj-data-test`), per the
  reference architecture's DEV / TEST / PROD projects.
