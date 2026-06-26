# ---------------------------------------------------------------------------
# Module: bigquery-dataset
# A single BigQuery dataset with CMEK encryption at rest (ISO27001 A.10.1.2),
# BMJ labels, optional table-expiration, and least-privilege access grants.
# Used to build the medallion layers: raw/bronze -> silver -> gold, plus
# reference data and the (Dataplex) catalog datasets.
# ---------------------------------------------------------------------------

resource "google_bigquery_dataset" "this" {
  project       = var.project_id
  dataset_id    = var.dataset_id
  friendly_name = var.friendly_name
  description   = var.description
  location      = var.location

  # Encryption at rest with a customer-managed key (CMEK).
  dynamic "default_encryption_configuration" {
    for_each = var.kms_key_name == null ? [] : [1]
    content {
      kms_key_name = var.kms_key_name
    }
  }

  # Optional default expiration for transient layers (e.g. raw landing).
  default_table_expiration_ms     = var.default_table_expiration_ms
  default_partition_expiration_ms = var.default_partition_expiration_ms

  delete_contents_on_destroy = false

  labels = var.labels

  # Least-privilege dataset access. Each entry grants a role to one member.
  dynamic "access" {
    for_each = var.access
    content {
      role           = access.value.role
      user_by_email  = lookup(access.value, "user_by_email", null)
      group_by_email = lookup(access.value, "group_by_email", null)
      special_group  = lookup(access.value, "special_group", null)
    }
  }
}
