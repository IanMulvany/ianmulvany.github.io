# stg environment params for bigquery (stg maps to the TEST project per the architecture diagram)
project_id  = "bmj-data-test"
region      = "europe-west2"
env         = "stg"
bq_location = "europe-west2"

# CMEK for BigQuery datasets at rest.
# POC placeholder — replace before apply. Do not deploy as-is.
# Wire to the kms dir's "bigquery" key, e.g. (via remote state):
#   bigquery_kms_key = "projects/bmj-data-test/locations/europe-west2/keyRings/stg-bmj-data-keyring/cryptoKeys/bigquery"
bigquery_kms_key = null

# Raw/landing tables self-expire after 180 days in stg. 180d = 15552000000 ms.
raw_table_expiration_ms = 15552000000

# Dataset-level group grants (least privilege).
# POC placeholders — replace with the real Google Group emails before apply. Do not deploy as-is.
data_engineers_group = "REPLACE_WITH_DATA_ENGINEERS_GROUP_EMAIL"
data_analysts_group  = "REPLACE_WITH_DATA_ANALYSTS_GROUP_EMAIL"

# Dataplex Knowledge Catalog (lake + curated/raw zones).
enable_dataplex = true

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
