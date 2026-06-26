# ---------------------------------------------------------------------------
# airbyte-gke
# Implements "INGESTION LAYER — Airbyte on GKE (Scalable Connectors)" from the
# reference architecture. Airbyte (open source) is the EL tool that extracts
# from the BMJ source systems (SFTP/API/DB) and lands data in the GCS landing
# bucket / BigQuery raw datasets.
#
# This dir provisions ONLY the platform Airbyte runs on:
#   - a private GKE Autopilot cluster on the networking dir's GKE subnet
#     (VPC-native, Workload Identity, private nodes)
#   - a least-privilege node service account
#   - an Artifact Registry repo for any custom connector images
#
# Airbyte ITSELF (the Helm release / Kubernetes objects) is NOT deployed by
# Terraform. Following the BMJ GitOps pattern, the Airbyte app is deployed onto
# this cluster via Helm through GitOps (ArgoCD / Flux) from the platform's
# _eks-equivalent GitOps repo. Terraform provisions the platform; the GitOps
# controller reconciles the application. This keeps app lifecycle out of the
# Terraform state and gives auditable, PR-driven app deploys (ISO27001).
# ---------------------------------------------------------------------------

# Look up the VPC and GKE subnet created by the networking dir so we do not
# duplicate network state here.
data "google_compute_network" "vpc" {
  project = var.project_id
  name    = "${var.env}-bmj-data-vpc"
}

data "google_compute_subnetwork" "gke" {
  project = var.project_id
  region  = var.region
  name    = coalesce(var.gke_subnet_name, "${var.env}-gke-subnet")
}

locals {
  pods_range_name     = coalesce(var.pods_range_name, "${var.env}-gke-pods")
  services_range_name = coalesce(var.services_range_name, "${var.env}-gke-services")
}

# Least-privilege node service account for the Airbyte cluster. No SA keys.
module "node_sa" {
  source = "../../modules/service-account"

  project_id   = var.project_id
  account_id   = "${var.env}-airbyte-gke"
  display_name = "${var.env} Airbyte GKE node SA"
  description  = "Node identity for the ${var.env} Airbyte Autopilot cluster (least privilege)."

  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
    "roles/storage.objectAdmin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/secretmanager.secretAccessor",
  ]
}

# Private GKE Autopilot cluster. Autopilot enforces a hardened, Google-managed
# node posture and right-sizes capacity (ISO14001) - you pay for running pods.
resource "google_container_cluster" "airbyte" {
  project  = var.project_id
  name     = "${var.env}-bmj-airbyte"
  location = var.region

  enable_autopilot = true
  release_channel {
    channel = "REGULAR"
  }

  # Reference the networking dir's VPC + GKE subnet (VPC-native cluster).
  network    = data.google_compute_network.vpc.self_link
  subnetwork = data.google_compute_subnetwork.gke.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_range_name
    services_secondary_range_name = local.services_range_name
  }

  # Private nodes (no public IPs). Endpoint kept public but locked down to the
  # corporate authorized networks below (POC) - flip enable_private_endpoint to
  # true once private connectivity to the control plane is in place.
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_cidrs
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # Workload Identity is enabled by default on Autopilot; reference it so app
  # pods (Airbyte) federate to GCP SAs without static keys (ISO27001).
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Autopilot manages the node SA via the default node pool; pin our dedicated
  # least-privilege SA for nodes.
  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = module.node_sa.email
    }
  }

  deletion_protection = true

  resource_labels = var.labels
}

# Artifact Registry for any custom Airbyte connector images we build.
resource "google_artifact_registry_repository" "airbyte" {
  project       = var.project_id
  location      = var.region
  repository_id = "${var.env}-airbyte"
  description   = "Custom Airbyte connector images for ${var.env}."
  format        = "DOCKER"

  # CMEK at rest (null = Google-managed).
  kms_key_name = var.artifact_registry_kms_key

  labels = var.labels
}
