# dev environment params for bigquery (medallion warehouse + Dataplex catalog)
project_id  = "bmj-data-dev"
region      = "europe-west2"
env         = "dev"
bq_location = "europe-west2"

# CMEK for BigQuery datasets at rest.
# POC placeholder — replace before apply. Do not deploy as-is.
# Wire to the kms dir's "bigquery" key, e.g. (via remote state):
#   bigquery_kms_key = "projects/bmj-data-dev/locations/europe-west2/keyRings/dev-bmj-data-keyring/cryptoKeys/bigquery"
bigquery_kms_key = null

# Raw/landing tables self-expire after 90 days in dev (transient). 90d = 7776000000 ms.
raw_table_expiration_ms = 7776000000

# Dataset-level group grants (least privilege).
# POC placeholders — replace with the real Google Group emails before apply. Do not deploy as-is.
data_engineers_group = "REPLACE_WITH_DATA_ENGINEERS_GROUP_EMAIL"
data_analysts_group  = "REPLACE_WITH_DATA_ANALYSTS_GROUP_EMAIL"

# Dataplex Knowledge Catalog (lake + curated/raw zones).
enable_dataplex = true

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
