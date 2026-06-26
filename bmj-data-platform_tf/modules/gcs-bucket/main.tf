# ---------------------------------------------------------------------------
# Module: gcs-bucket
# Hardened Google Cloud Storage bucket. Defaults satisfy Checkov GCP policies:
#  - uniform bucket-level access (CKV_GCP_29)
#  - public access prevention enforced (CKV_GCP_114)
#  - versioning enabled (CKV_GCP_78)
#  - CMEK encryption at rest (CKV_GCP_6 / ISO27001 A.10.1.2)
#  - access & storage logging optional
# Used for the GCS data lake (object storage) layer of the platform.
# ---------------------------------------------------------------------------

resource "google_storage_bucket" "this" {
  project  = var.project_id
  name     = var.name
  location = var.location

  # Security baseline.
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = var.versioning
  }

  # CMEK encryption at rest.
  dynamic "encryption" {
    for_each = var.kms_key_name == null ? [] : [1]
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  # Lifecycle management (ISO14001 - storage efficiency / right-sizing).
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action_type
        storage_class = lookup(lifecycle_rule.value, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value, "age", null)
        days_since_noncurrent_time = lookup(lifecycle_rule.value, "days_since_noncurrent_time", null)
        num_newer_versions    = lookup(lifecycle_rule.value, "num_newer_versions", null)
        with_state            = lookup(lifecycle_rule.value, "with_state", null)
      }
    }
  }

  dynamic "logging" {
    for_each = var.log_bucket == null ? [] : [1]
    content {
      log_bucket = var.log_bucket
    }
  }

  labels = var.labels
}
