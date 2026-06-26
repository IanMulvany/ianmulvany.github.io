# ---------------------------------------------------------------------------
# secret-manager
# Implements "Secure Token Storage / Secret Manager" from the trust-boundaries
# column of the reference architecture. Creates Secret Manager secret SHELLS
# (no values in code or state) for the credentials the Airbyte source
# connectors and platform services need to authenticate to BMJ source systems.
#
# Values are populated out-of-band (console, gcloud, or a privileged
# break-glass pipeline) - NEVER committed or stored in Terraform state.
# ISO27001 - no secrets in code.
#
# CMEK: pass `secrets_kms_key` = kms dir's crypto_keys["secrets"] for CMEK at
# rest (default null = Google-managed; see kms dir).
# Access: grant SAs least-privilege accessor via `accessor_members` later.
# ---------------------------------------------------------------------------

module "secret" {
  source   = "../../modules/secret"
  for_each = toset(var.secrets)

  project_id        = var.project_id
  secret_id         = "src-${each.value}-credentials"
  replica_locations = var.replica_locations
  kms_key_name      = var.secrets_kms_key
  accessor_members  = var.accessor_members
  labels            = var.labels
}
