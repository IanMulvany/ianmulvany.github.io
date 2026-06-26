# live environment params for gcs-data-lake (object storage / data lake)
project_id      = "bmj-data-prod"
region          = "europe-west2"
env             = "live"
bucket_location = "EU"

# CMEK for the data-lake buckets at rest.
# POC placeholder — replace before apply. Do not deploy as-is.
# Wire to the kms dir's "gcs-data-lake" key, e.g. (via remote state):
#   gcs_kms_key = "projects/bmj-data-prod/locations/europe-west2/keyRings/live-bmj-data-keyring/cryptoKeys/gcs-data-lake"
gcs_kms_key = null

# Retention (days). Live keeps landing data longer; archive ~7 years.
landing_retention_days = 730
archive_retention_days = 2555

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "confidential"
}
