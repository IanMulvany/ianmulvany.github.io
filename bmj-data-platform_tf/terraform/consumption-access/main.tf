# ---------------------------------------------------------------------------
# consumption-access
# Implements the "CONSUMPTION" column of the reference architecture: least-
# privilege ACCESS for the systems that consume the curated GOLD BigQuery
# layer. It provisions the connecting identities and dataset-level grants only
# (NOT the consumer applications themselves):
#
#   Tableau              Dashboards & Analytics      -> ${var.env}-tableau-reader
#   Hum                  Business Reporting/Insights -> ${var.env}-hum-reader
#   Third-Party Apps     Operational Apps/Portals/APIs -> ${var.env}-thirdparty-api
#   ML Workloads (Vertex AI)  Future Scope           -> ${var.env}-vertex-pipeline (gated)
#
# Each consumer gets a dedicated service account (no static keys; Tableau/Hum
# auth via Secret Manager — see the secret-manager dir's "tableau-connection"
# secret) with the minimum BigQuery roles: dataViewer (read metadata/run reads)
# and jobUser (run query jobs). On top of project-level dataViewer/jobUser, we
# additionally bind each consumer as READER at the DATASET level on `gold` and
# `reference`, so access is scoped to the BI-facing layers (least privilege,
# ISO27001 A.9.2). The bigquery dir owns the datasets; here we only add member
# bindings.
# ---------------------------------------------------------------------------

locals {
  # BigQuery roles every connecting consumer needs: read data + run query jobs.
  consumer_bq_roles = [
    "roles/bigquery.dataViewer",
    "roles/bigquery.jobUser",
  ]

  # Consumers that connect to BigQuery gold/reference. Keyed by logical name.
  consumers = {
    tableau = {
      account_id   = "${var.env}-tableau-reader"
      display_name = "${var.env} Tableau gold reader"
      description  = "Tableau (Dashboards & Analytics) read access to BigQuery gold/reference."
    }
    hum = {
      account_id   = "${var.env}-hum-reader"
      display_name = "${var.env} Hum gold reader"
      description  = "Hum (Business Reporting & Insights) read access to BigQuery gold/reference."
    }
    thirdparty = {
      account_id   = "${var.env}-thirdparty-api"
      display_name = "${var.env} third-party API reader"
      description  = "Third-party operational apps / portals / APIs read access to BigQuery gold/reference."
    }
  }

  # Datasets the consumers may read, scoped to the BI-facing layers.
  reader_datasets = toset([var.gold_dataset_id, var.reference_dataset_id])
}

# Dedicated least-privilege service account per consumer. project_roles grants
# dataViewer + jobUser at the project level; dataset-level READER bindings below
# further constrain effective read scope to gold/reference.
module "consumers" {
  source   = "../../modules/service-account"
  for_each = local.consumers

  project_id    = var.project_id
  account_id    = each.value.account_id
  display_name  = each.value.display_name
  description   = each.value.description
  project_roles = local.consumer_bq_roles
}

# Dataset-level READER on gold + reference for each consumer (one binding per
# consumer x dataset). This is the primary access mechanism; the bigquery dir
# created the datasets, we only add member bindings here.
resource "google_bigquery_dataset_iam_member" "consumer_reader" {
  for_each = {
    for pair in setproduct(keys(local.consumers), local.reader_datasets) :
    "${pair[0]}-${pair[1]}" => {
      consumer = pair[0]
      dataset  = pair[1]
    }
  }

  project    = var.project_id
  dataset_id = each.value.dataset
  role       = "roles/bigquery.dataViewer"
  member     = module.consumers[each.value.consumer].member
}

# ---------------------------------------------------------------------------
# Vertex AI ML Workloads — FUTURE SCOPE
# Gated behind `enable_vertex` (default false). When enabled, creates a
# dedicated pipeline SA for Vertex AI training/serving that reads features from
# the gold layer. Kept off for the POC to avoid provisioning ML infrastructure
# before it is required.
# ---------------------------------------------------------------------------
module "vertex_pipeline" {
  source   = "../../modules/service-account"
  for_each = var.enable_vertex ? { vertex = true } : {}

  project_id   = var.project_id
  account_id   = "${var.env}-vertex-pipeline"
  display_name = "${var.env} Vertex AI pipeline (future scope)"
  description  = "Vertex AI ML workloads pipeline SA. Future scope — reads BigQuery gold for features."
  project_roles = [
    "roles/aiplatform.user",
    "roles/bigquery.dataViewer",
  ]
}

# Dataset-level READER on gold + reference for the Vertex pipeline SA (future
# scope; only created when enable_vertex = true).
resource "google_bigquery_dataset_iam_member" "vertex_reader" {
  for_each = var.enable_vertex ? local.reader_datasets : toset([])

  project    = var.project_id
  dataset_id = each.value
  role       = "roles/bigquery.dataViewer"
  member     = module.vertex_pipeline["vertex"].member
}
