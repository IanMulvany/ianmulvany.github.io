# ---------------------------------------------------------------------------
# Module: secret
# Secret Manager secret shell (no value in code). Implements "Secure Token
# Storage / Secret Manager" from the trust-boundaries column. Connector
# credentials (Airbyte sources), service tokens, etc. live here - NEVER in
# Terraform state or git. Values are populated out-of-band (console, CLI, or
# a privileged break-glass pipeline). ISO27001 - no secrets in code.
# ---------------------------------------------------------------------------

resource "google_secret_manager_secret" "this" {
  project   = var.project_id
  secret_id = var.secret_id

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = var.replica_locations
        content {
          location = replicas.value
          dynamic "customer_managed_encryption" {
            for_each = var.kms_key_name == null ? [] : [1]
            content {
              kms_key_name = var.kms_key_name
            }
          }
        }
      }
    }
  }

  labels = var.labels
}

# Grant accessor role to the workloads that need this secret (least privilege).
resource "google_secret_manager_secret_iam_member" "accessors" {
  for_each = toset(var.accessor_members)

  project   = var.project_id
  secret_id = google_secret_manager_secret.this.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}
