# ---------------------------------------------------------------------------
# kms
# Implements "Cloud KMS (Enc. at Rest)" from the governance cross-cutting layer
# of the reference architecture. Provisions a single per-environment key ring
# and a set of CMEK crypto keys, one per data domain so the blast radius of a
# key compromise / rotation is contained to that domain.
# ISO27001 A.10.1.2 (key management & rotation).
#
# Keys (90-day rotation):
#   bigquery      -> CMEK for BigQuery datasets         (consumed by: bigquery dir)
#   gcs-data-lake -> CMEK for the data-lake buckets     (consumed by: gcs-data-lake dir)
#   composer      -> CMEK for Cloud Composer env/state  (consumed by: composer dir)
#   secrets       -> CMEK for Secret Manager payloads   (consumed by: secret-manager dir)
#   pubsub        -> CMEK for Pub/Sub topics            (consumed by: ingestion/orchestration)
#
# Downstream dirs reference these keys via this dir's `crypto_keys` output
# (key name -> full resource ID), surfaced through remote state.
# ---------------------------------------------------------------------------

module "keyring" {
  source = "../../modules/kms-keyring"

  project_id    = var.project_id
  key_ring_name = "${var.env}-bmj-data-keyring"
  location      = var.location

  # One key per data domain to contain blast radius. Rotation defaults to the
  # ring-wide 90-day default below (each key may override if ever needed).
  keys = [
    { name = "bigquery" },
    { name = "gcs-data-lake" },
    { name = "composer" },
    { name = "secrets" },
    { name = "pubsub" },
  ]

  default_rotation_period = var.rotation_period
  labels                  = var.labels
}
