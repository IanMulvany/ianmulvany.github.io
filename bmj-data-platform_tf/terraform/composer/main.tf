# ---------------------------------------------------------------------------
# composer
# Implements "ORCHESTRATION LAYER — Cloud Composer (Airflow)" from the reference
# architecture. Composer orchestrates the end-to-end BMJ pipeline: trigger
# Airbyte syncs (on the airbyte-gke cluster), then run dbt (via dbt-cloudbuild),
# then publish to the gold datasets / downstream consumers.
#
# Provisions:
#   - a least-privilege Composer service account (no SA keys)
#   - a private Cloud Composer 2 environment on the networking dir's data subnet,
#     right-sized per env (ISO14001) and CMEK-encrypted (POC placeholder)
# ---------------------------------------------------------------------------

# Look up the VPC + data subnet from the networking dir.
data "google_compute_network" "vpc" {
  project = var.project_id
  name    = "${var.env}-bmj-data-vpc"
}

data "google_compute_subnetwork" "data" {
  project = var.project_id
  region  = var.region
  name    = coalesce(var.data_subnet_name, "${var.env}-data-subnet")
}

# Least-privilege identity Composer workers run as. container.developer lets
# Airflow tasks trigger Airbyte syncs on the GKE cluster.
module "composer_sa" {
  source = "../../modules/service-account"

  project_id   = var.project_id
  account_id   = "${var.env}-composer"
  display_name = "${var.env} Composer worker SA"
  description  = "Cloud Composer / Airflow worker identity for ${var.env} (least privilege)."

  project_roles = [
    "roles/composer.worker",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectAdmin",
    "roles/secretmanager.secretAccessor",
    "roles/container.developer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

resource "google_composer_environment" "orchestrator" {
  project = var.project_id
  name    = "${var.env}-bmj-orchestrator"
  region  = var.region

  labels = var.labels

  config {
    software_config {
      image_version = var.image_version
      env_variables = var.env_variables
      pypi_packages = var.pypi_packages
    }

    node_config {
      network         = data.google_compute_network.vpc.id
      subnetwork      = data.google_compute_subnetwork.data.id
      service_account = module.composer_sa.email
    }

    # Private environment: control plane reachable only over private endpoint.
    private_environment_config {
      enable_private_endpoint = true
    }

    # Right-sized workloads per env (ISO14001 - avoid over-provisioning).
    workloads_config {
      scheduler {
        cpu        = var.scheduler.cpu
        memory_gb  = var.scheduler.memory_gb
        storage_gb = var.scheduler.storage_gb
        count      = var.scheduler.count
      }
      web_server {
        cpu        = var.web_server.cpu
        memory_gb  = var.web_server.memory_gb
        storage_gb = var.web_server.storage_gb
      }
      worker {
        cpu        = var.worker.cpu
        memory_gb  = var.worker.memory_gb
        storage_gb = var.worker.storage_gb
        min_count  = var.worker.min_count
        max_count  = var.worker.max_count
      }
    }

    # CMEK at rest (POC placeholder; null = Google-managed, so the block is
    # omitted entirely when no key is supplied).
    dynamic "encryption_config" {
      for_each = var.composer_kms_key == null ? [] : [var.composer_kms_key]
      content {
        kms_key_name = encryption_config.value
      }
    }
  }
}
