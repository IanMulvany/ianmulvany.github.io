# Architecture & Implementation Decision Log

This log records the decisions taken while turning the **Reference GCP Platform
Architecture** (and the Reference Data Architecture blueprint) into deployable
Terraform, accelerating the BMJ Data Roadmap from POC toward delivery.

The brief was: *"When you have a question, make your own decision and log it with
your rationale."* Each decision below is something that was genuinely ambiguous
or under-specified in the inputs; obvious choices are not logged.

Status key: ✅ Decided · ⚠️ Decided with caveats / needs confirmation before apply

| ID | Decision | Status |
|----|----------|--------|
| D-001 | Repo shape: single Pattern 3 `_tf` repo, resource-type directories | ✅ |
| D-002 | Cloud target is GCP; BMJ AWS standards are *mirrored*, not copied | ✅ |
| D-003 | Environment model: dev / stg(=TEST) / live(=PROD) isolated projects | ✅ |
| D-004 | Terraform state in GCS (no DynamoDB-equivalent lock table) | ✅ |
| D-005 | Region default `europe-west2` (London) | ✅ |
| D-006 | Tags → GCP labels (lowercase keys) | ✅ |
| D-007 | Human identity via Workforce Identity Federation (Entra ID/AD) | ✅ |
| D-008 | Workload identity: no SA keys; Workload Identity + attached SAs | ✅ |
| D-009 | GitOps via BMJ reusable workflows, assuming a GCP-capable variant | ⚠️ |
| D-010 | Checkov is a hard gate; no repo-wide skips | ✅ |
| D-011 | Medallion layering: raw→bronze→silver→gold + reference + catalog | ✅ |
| D-012 | Airbyte on **GKE Autopilot**, app deployed by GitOps not Terraform | ✅ |
| D-013 | dbt runs via **Cloud Build**; dbt project lives in a separate repo | ✅ |
| D-014 | Orchestration: Cloud Composer (primary) + Workflows/Scheduler (glue) | ✅ |
| D-015 | CMEK everywhere; per-domain keys to contain blast radius | ✅ |
| D-016 | VPC Service Controls perimeter around the data project | ⚠️ |
| D-017 | Secrets are Secret Manager *shells*; values populated out-of-band | ✅ |
| D-018 | Data residency: EU multi-region storage, europe-west2 compute | ✅ |
| D-019 | Vertex AI / ML kept behind an `enable_vertex` flag (future scope) | ✅ |
| D-020 | All org-specific values are `REPLACE_WITH_*` placeholders; no deploy | ✅ |
| D-021 | Source-system catalogue generated from the provided CSV | ✅ |

---

## D-001 — One Pattern 3 `_tf` repository, resource-type directories
**Context.** BMJ defines three repo patterns. The platform is shared
infrastructure consumed by many downstream services (Tableau, Hum, third-party
apps), which is the textbook trigger for **Pattern 3** (`PREFIX_tf`).
**Decision.** Single repo `bmj-data-platform_tf`, with `terraform/<dir>/` where
each `<dir>` is a GCP resource/capability type (`bigquery`, `gcs-data-lake`,
`kms`, `networking`, …) — mirroring BMJ's rule that `_tf` directories are named
for resource types, not business names.
**Rationale.** Discoverability, independent plan/apply per directory via the
`SERVICES` changed-service matrix, and direct alignment with the ARG template
`arg-example_tf`.
**Alternative rejected.** Per-environment repos or a Terragrunt mono-tree —
both diverge from the BMJ template and the changed-service workflow.

## D-002 — GCP target; AWS standards mirrored, not copied
**Context.** The BMJ ARG standards are heavily AWS-centric (EKS, ECR, S3+DynamoDB
state, `aws_*` resources). The target architecture is **GCP**.
**Decision.** Preserve every BMJ *convention* (repo layout, file names,
`params/<env>/{backends,params}.tfvars`, PascalCase intent for tags→labels,
GitOps execution discipline, Checkov/Superlinter gates, OPSQ pre-provisioning
mindset) and translate the *implementation* to GCP-native resources.
**Rationale.** Maximises consistency with the rest of BMJ engineering while
honouring the actual platform choice in the diagram.
**Action for ARG.** This GCP translation should be ratified by the Architecture
Review Group and folded back into org standards (a `terraform-gcp` skill).

## D-003 — Environments: dev / stg / live, where **stg = TEST**, **live = PROD**
**Context.** BMJ uses dev/stg/live. The GCP diagram shows **DEV / TEST / PROD**
isolated projects.
**Decision.** Keep BMJ's `dev|stg|live` triplet for tooling/state/workflow
compatibility, and map `stg → bmj-data-test` (the diagram's TEST project),
`live → bmj-data-prod`, `dev → bmj-data-dev`. Each environment is its **own GCP
project** under a shared "Data Platform" folder.
**Rationale.** Project-per-environment is the strongest GCP isolation boundary
and the natural unit for VPC-SC perimeters and IAM. The label/comment make the
stg=TEST mapping explicit to avoid confusion.

## D-004 — Terraform state in GCS, no separate lock table
**Context.** BMJ AWS uses `bmj-{env}-tfstate` (S3) + `bmj-{env}-tf` (DynamoDB
lock).
**Decision.** Use GCS buckets `bmj-data-{env}-tfstate` with `prefix =
bmj-data-platform_tf/<dir>` (mirrors the AWS state-key pattern). No lock table:
the GCS backend provides native locking and strong consistency.
**Rationale.** GCS object generations give atomic locking, so the DynamoDB
analogue is unnecessary. The `bootstrap` directory creates these buckets first
(local backend), exactly as an AWS bootstrap would.

## D-005 — Region default `europe-west2` (London)
**Context.** BMJ AWS default is `eu-west-1` (Ireland). Data is UK/EU
(member data, NHS job boards, HEE) with residency expectations.
**Decision.** Default `europe-west2` (London) for compute, `EU` multi-region for
storage/BCP-DR. Overridable per `params.tfvars`.
**Rationale.** Lowest latency to UK consumers and clean UK/EU data residency.
**Caveat.** If BMJ's existing GCP footprint standardises on `europe-west1`
(Belgium) instead, change the default in one place (`variables.tf` defaults +
params). Logged for confirmation.

## D-006 — Tags become GCP labels with lowercase keys
**Context.** BMJ mandates **PascalCase** tag keys on AWS (`GitRepo`,
`CostCentre`). GCP **labels disallow uppercase**.
**Decision.** Carry the same tag *taxonomy* as labels with lowercase keys:
`gitrepo`, `costcentre`, `managedby`, `environment`, `owner`, `dataclass`.
**Rationale.** Same cost/carbon attribution intent (ISO14001), constrained by
the GCP label charset. Equivalence is documented so reporting can join across
clouds.

## D-007 — Human SSO via Workforce Identity Federation against Entra ID
**Context.** The brief requires access "managed via Active Directory". BMJ AD is
Microsoft **Entra ID** (Azure AD).
**Decision.** Workforce Identity Federation pool + OIDC provider trusting the
BMJ Entra tenant; Entra group membership (`assertion.groups`) drives GCP IAM via
`principalSet` conditions. No Google-native user accounts, no SA keys.
**Rationale.** Single source of truth for identity, automatic
joiner/mover/leaver handling, full auditability (ISO27001 A.9.2).
**Caveat.** Requires an Entra app registration + group claim configuration on
the Microsoft side; tenant/client IDs are placeholders here.

## D-008 — No service-account keys
**Decision.** Workloads use Workload Identity (GKE/Composer) or attached service
accounts; CI authenticates via GitHub OIDC → Workload Identity Federation. The
`service-account` module deliberately exposes **no** key resource.
**Rationale.** Eliminates the single highest-risk long-lived credential class
(ISO27001). Aligns with BMJ's "no secrets in code".

## D-009 — GitOps via BMJ reusable workflows (GCP variant assumed) ⚠️
**Context.** BMJ's reusable workflows (`BMJ-Ltd/github-actions-terraform`) are
written for AWS OIDC.
**Decision.** Keep the identical Pattern 3 workflow *shape* (changed-service
matrix, `@main` refs, `arc-runner-set`, plan-on-PR / dev-on-merge /
live-on-release / dispatch-for-stg) and pass a `CLOUD: gcp` input plus
`id-token: write` for Workload Identity Federation.
**Rationale.** Preserves the org's GitOps muscle memory and review gates.
**Action.** The shared workflow needs a GCP authentication path (or a sibling
`github-actions-terraform-gcp`). Raise an OPSQ/PLAT ticket. Until then these
workflows will not run green — they are the target contract, not yet wired.

## D-010 — Checkov is a hard gate, no repo-wide skips
**Decision.** `soft-fail: false`; the modules bake in the controls Checkov
checks (UBLA, public-access-prevention, versioning, CMEK, flow logs, no
`0.0.0.0/0` ingress). Any future skip must be an inline
`#checkov:skip=<ID>:<justification>` reviewed by ARG, not a blanket exclusion.
**Rationale.** Matches BMJ quality-gate policy (no high/critical findings).

## D-011 — Medallion layering with explicit reference & catalog datasets
**Context.** The diagram shows Raw/Bronze → Silver → Gold plus "Reference Data"
and a "Knowledge Catalog (Dataplex)".
**Decision.** Six BigQuery datasets: `raw`, `bronze`, `silver`, `gold`,
`reference`, `catalog`; plus a Dataplex lake with RAW and CURATED zones. `raw`
carries a default table expiry (transient landing); gold/reference are the only
consumer-readable layers.
**Rationale.** Clean lineage, least-privilege consumption, and the catalog/
Dataplex surface for the "Metadata & Observe" requirement.

## D-012 — Airbyte on GKE Autopilot; app via GitOps
**Context.** Diagram: "Airbyte on GKE (Scalable Connectors)".
**Decision.** Terraform provisions a **private GKE Autopilot** cluster, node SA,
and Artifact Registry. Airbyte itself is **not** Terraform-managed — it is
deployed onto the cluster by GitOps (ArgoCD/Flux + Helm), matching BMJ's
"Terraform provisions, GitOps deploys" split.
**Rationale.** Autopilot right-sizes nodes (ISO14001) and reduces ops load for
the India-based Platform Team. Keeping the app in GitOps avoids Terraform owning
fast-moving Helm state.

## D-013 — dbt via Cloud Build; dbt project in a separate repo
**Decision.** This repo provisions the dbt runner SA, Artifact Registry, a Cloud
Build trigger (`cloudbuild.dbt.yaml`), a nightly Cloud Scheduler + Pub/Sub
trigger. The actual dbt models live in `bmj-data-platform-dbt` (not created
here).
**Rationale.** Separation of infrastructure from transformation logic; the dbt
repo can iterate independently with its own tests.

## D-014 — Composer primary, Workflows/Scheduler for glue
**Decision.** Cloud Composer (Airflow) orchestrates the end-to-end pipeline;
Cloud Workflows + Scheduler handle lightweight cross-service triggers that don't
warrant a DAG. Both shown in the diagram's orchestration layer.
**Rationale.** Composer for complex dependency graphs and backfills; Workflows
for cheap event glue (cost/carbon efficient).

## D-015 — CMEK with per-domain keys
**Decision.** One KMS key ring per environment with separate keys for
`bigquery`, `gcs-data-lake`, `composer`, `secrets`, `pubsub` (90-day rotation).
**Rationale.** Encryption at rest (ISO27001 A.10.1.2) with blast-radius
isolation — compromising/rotating one domain's key doesn't touch the others.

## D-016 — VPC Service Controls perimeter ⚠️
**Decision.** A service perimeter around each environment's data project,
restricting BigQuery/GCS/Secret Manager/KMS/Composer/Dataplex to in-perimeter
access, with a corporate-IP access level.
**Rationale.** Prevents data exfiltration to projects outside the perimeter —
the enforcement behind "Private by Design / Zero Trust".
**Caveat.** Access Context Manager is **org-level**; applying it needs org admin
and an existing access policy. Project number and policy ID are placeholders.

## D-017 — Secret Manager shells only
**Decision.** Create secret *containers* (with CMEK + EU replication + accessor
IAM) for every source-system credential and platform token, but **no values**.
Values are added out-of-band (console/CLI/break-glass), never in git or state.
**Rationale.** "No secrets in code"; keeps Terraform state free of sensitive
material.

## D-018 — Data residency: EU storage, London compute
**Decision.** GCS buckets and BigQuery datasets in EU/`europe-west2`; Secret
Manager replicated to `europe-west2`.
**Rationale.** UK/EU data (member, NHS, HEE) stays in-region for residency and
latency.

## D-019 — ML/Vertex AI behind a feature flag
**Decision.** The consumption layer's Vertex AI access (an `enable_vertex`
toggle, default **false**) is provisioned only when explicitly enabled, matching
the diagram's "ML Workloads (Future Scope)".
**Rationale.** Don't provision (or pay for) ML infrastructure before it's needed.

## D-020 — Placeholders everywhere; nothing deploys as-is
**Decision.** Org ID, billing account, parent folder, Entra tenant/client IDs,
AD group emails, corporate CIDRs, project numbers, audit-log bucket → all
`REPLACE_WITH_*` with a "POC placeholder — replace before apply" comment.
**Rationale.** The brief said **do not deploy anything**. The repo is a
ready-to-wire blueprint; a human must supply real values and run the standard
PR→plan→review flow.

## D-021 — Source-system catalogue generated from the CSV
**Decision.** `config/source_systems.{yaml,json}` is generated from
`Source_Systems_Warehouse - Source Systems.csv` (33 systems) and enriched with a
suggested Airbyte connector and the matching Secret Manager secret id. It drives
the Secret Manager shells and the interactive explorer.
**Rationale.** Single source of truth for ingestion planning; keeps the Airbyte
connector list and secret shells in lockstep with the documented sources.

---

### Open items to confirm before first apply
1. Real BMJ GCP org ID, billing account, and parent folder (D-020).
2. Entra tenant ID + GCP app registration / group claims (D-007).
3. Confirm region default `europe-west2` vs an existing GCP standard (D-005).
4. GCP-capable variant of `BMJ-Ltd/github-actions-terraform` (D-009).
5. Org-level Access Context Manager policy for VPC-SC (D-016).
6. AD group → role mapping sign-off by BISO (Marie Ashworth) (D-007/org-iam).
