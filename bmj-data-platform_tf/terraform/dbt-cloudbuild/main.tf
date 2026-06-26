# ---------------------------------------------------------------------------
# dbt-cloudbuild
# Implements "TRANSFORMATION LAYER — dbt + CI Runner / Cloud Build (Automated
# Testing & Deployments)" from the reference architecture. dbt runs the
# BigQuery transformations (bronze -> silver -> gold). Cloud Build is the CI
# runner that executes `dbt build` (which runs models AND tests), so every
# deployment is automatically tested.
#
# Provisions:
#   - a least-privilege dbt runner service account (no SA keys)
#   - an Artifact Registry repo for the dbt runner image
#   - a Cloud Build trigger wired to the dbt GitHub repo (push-triggered CI)
#   - a Pub/Sub topic + Cloud Scheduler job for the nightly batch dbt run
#
# Scheduling is modelled as Scheduler -> Pub/Sub topic; a Cloud Build trigger
# subscribed to that topic (or a small relay) kicks the build. This keeps the
# nightly trigger decoupled and auditable.
# ---------------------------------------------------------------------------

# Least-privilege identity Cloud Build uses to run dbt against BigQuery.
module "dbt_sa" {
  source = "../../modules/service-account"

  project_id   = var.project_id
  account_id   = "${var.env}-dbt-runner"
  display_name = "${var.env} dbt runner SA"
  description  = "Cloud Build identity that runs dbt build against BigQuery (least privilege)."

  project_roles = [
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectViewer",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
  ]
}

# Artifact Registry for the dbt runner image (dbt-core + bigquery adapter).
resource "google_artifact_registry_repository" "dbt" {
  project       = var.project_id
  location      = var.region
  repository_id = "${var.env}-dbt"
  description   = "dbt runner images for ${var.env}."
  format        = "DOCKER"

  kms_key_name = var.artifact_registry_kms_key

  labels = var.labels
}

# Push-triggered CI: runs `dbt build` from the repo's cloudbuild.dbt.yaml.
# Uses the dedicated dbt-runner SA. A user-specified SA requires the build to
# stream logs to a Cloud Logging / GCS bucket; we keep logs in Cloud Logging
# only (no public bucket) for a Checkov-clean POC.
resource "google_cloudbuild_trigger" "dbt_run" {
  count = var.enable_trigger ? 1 : 0

  project     = var.project_id
  location    = var.region
  name        = "${var.env}-dbt-run"
  description = "Runs dbt build (models + tests) on push to ${var.github_branch}."
  disabled    = false

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^${var.github_branch}$"
    }
  }

  filename        = var.dbt_build_filename
  service_account = module.dbt_sa.name

  # Run-as SA requires an explicit logging option.
  logging = "CLOUD_LOGGING_ONLY"
}

# Pub/Sub topic the nightly Scheduler job publishes to. A Cloud Build trigger
# (or relay) subscribed to this topic launches the batch dbt run.
resource "google_pubsub_topic" "dbt_trigger" {
  project = var.project_id
  name    = "${var.env}-dbt-trigger"

  # CMEK at rest (null = Google-managed).
  kms_key_name = var.pubsub_kms_key

  labels = var.labels
}

# Nightly batch run of dbt (in addition to push-triggered CI).
resource "google_cloud_scheduler_job" "dbt_nightly" {
  project   = var.project_id
  region    = var.region
  name      = "${var.env}-dbt-nightly"
  schedule  = var.schedule
  time_zone = "Europe/London"

  pubsub_target {
    topic_name = google_pubsub_topic.dbt_trigger.id
    data       = base64encode(jsonencode({ trigger = "nightly", env = var.env }))
  }
}
