# ---------------------------------------------------------------------------
# Module: kms-keyring
# A Cloud KMS key ring plus a set of CMEK crypto keys with rotation. Provides
# the "Cloud KMS (Enc. at Rest)" control from the governance cross-cutting
# layer. Keys are referenced by BigQuery, GCS, Composer, etc. for CMEK.
# ISO27001 A.10.1.2 (key management, rotation).
# ---------------------------------------------------------------------------

resource "google_kms_key_ring" "this" {
  project  = var.project_id
  name     = var.key_ring_name
  location = var.location
}

resource "google_kms_crypto_key" "keys" {
  for_each = { for k in var.keys : k.name => k }

  name            = each.value.name
  key_ring        = google_kms_key_ring.this.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = lookup(each.value, "rotation_period", var.default_rotation_period)

  # Protect keys from accidental destruction.
  lifecycle {
    prevent_destroy = true
  }

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = lookup(each.value, "protection_level", "SOFTWARE")
  }

  labels = var.labels
}
