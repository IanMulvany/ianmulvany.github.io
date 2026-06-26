# live environment params for secret-manager
project_id = "bmj-data-prod"
region     = "europe-west2"
env        = "live"

# Data residency: keep payloads in London only.
replica_locations = ["europe-west2"]

# CMEK for secret payloads.
# POC placeholder — replace before apply. Do not deploy as-is.
# Wire to the kms dir's "secrets" key, e.g. (via remote state):
#   secrets_kms_key = "projects/bmj-data-prod/locations/europe-west2/keyRings/live-bmj-data-keyring/cryptoKeys/secrets"
secrets_kms_key = null

# Service accounts granted secretAccessor on the secrets (least privilege).
# Populate once the Airbyte / dbt / Tableau SAs exist.
accessor_members = []

# `secrets` uses the module default list (Airbyte sources + platform services).

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "confidential"
}
