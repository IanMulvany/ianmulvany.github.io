# live environment params for bigquery (medallion warehouse + Dataplex catalog)
project_id  = "bmj-data-prod"
region      = "europe-west2"
env         = "live"
bq_location = "europe-west2"

# CMEK for BigQuery datasets at rest.
# POC placeholder — replace before apply. Do not deploy as-is.
# Wire to the kms dir's "bigquery" key, e.g. (via remote state):
#   bigquery_kms_key = "projects/bmj-data-prod/locations/europe-west2/keyRings/live-bmj-data-keyring/cryptoKeys/bigquery"
bigquery_kms_key = null

# Live keeps raw indefinitely for replay / lineage (no table TTL); retention is
# managed deliberately by data engineering rather than auto-expiry.
raw_table_expiration_ms = null

# Dataset-level group grants (least privilege).
# POC placeholders — replace with the real Google Group emails before apply. Do not deploy as-is.
data_engineers_group = "REPLACE_WITH_DATA_ENGINEERS_GROUP_EMAIL"
data_analysts_group  = "REPLACE_WITH_DATA_ANALYSTS_GROUP_EMAIL"

# Dataplex Knowledge Catalog (lake + curated/raw zones).
enable_dataplex = true

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "confidential"
}
