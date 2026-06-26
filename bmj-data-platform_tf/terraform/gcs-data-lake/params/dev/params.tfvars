# dev environment params for gcs-data-lake (object storage / data lake)
project_id      = "bmj-data-dev"
region          = "europe-west2"
env             = "dev"
bucket_location = "EU"

# CMEK for the data-lake buckets at rest.
# POC placeholder — replace before apply. Do not deploy as-is.
# Wire to the kms dir's "gcs-data-lake" key, e.g. (via remote state):
#   gcs_kms_key = "projects/bmj-data-dev/locations/europe-west2/keyRings/dev-bmj-data-keyring/cryptoKeys/gcs-data-lake"
gcs_kms_key = null

# Retention (days). dev is shorter to control cost.
landing_retention_days = 365
archive_retention_days = 2555

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
