# ---------------------------------------------------------------------------
# bootstrap
# Creates the remote Terraform state bucket for an environment. This is the
# GCP equivalent of BMJ's AWS "bmj-{env}-tfstate" S3 bucket + "bmj-{env}-tf"
# DynamoDB lock table. GCS provides strong read-after-write consistency and
# native object-level locking, so a separate lock table is NOT required.
#
# Naming mirrors the BMJ convention:  bmj-data-{env}-tfstate
# ---------------------------------------------------------------------------

locals {
  state_bucket = "bmj-data-${var.env}-tfstate"
}

resource "google_storage_bucket" "tfstate" {
  project  = var.project_id
  name     = local.state_bucket
  location = var.state_bucket_location

  # State buckets must be hardened.
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  # Keep every version of state for recovery / audit (ISO27001 A.12.4).
  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 20
      with_state         = "ARCHIVED"
    }
  }

  labels = var.labels

  lifecycle {
    prevent_destroy = true
  }
}
