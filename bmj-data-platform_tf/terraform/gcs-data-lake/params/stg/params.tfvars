# stg environment params for gcs-data-lake (stg maps to the TEST project per the architecture diagram)
project_id      = "bmj-data-test"
region          = "europe-west2"
env             = "stg"
bucket_location = "EU"

# CMEK for the data-lake buckets at rest.
# POC placeholder — replace before apply. Do not deploy as-is.
# Wire to the kms dir's "gcs-data-lake" key, e.g. (via remote state):
#   gcs_kms_key = "projects/bmj-data-test/locations/europe-west2/keyRings/stg-bmj-data-keyring/cryptoKeys/gcs-data-lake"
gcs_kms_key = null

# Retention (days).
landing_retention_days = 365
archive_retention_days = 2555

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
