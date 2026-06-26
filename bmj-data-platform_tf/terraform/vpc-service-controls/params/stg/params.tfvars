# stg environment params for vpc-service-controls (stg maps to the TEST project
# per the architecture diagram).
# Access Context Manager is ORG-LEVEL; a real apply requires org-level ACM admin
# and an existing access policy.
# POC placeholder — replace before apply. Do not deploy as-is.
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

org_id           = "REPLACE_WITH_ORG_ID"           # POC placeholder — replace before apply. Do not deploy as-is.
access_policy_id = "REPLACE_WITH_ACCESS_POLICY_ID" # POC placeholder — replace before apply. Do not deploy as-is.
project_number   = "REPLACE_WITH_PROJECT_NUMBER"   # POC placeholder — replace before apply. Do not deploy as-is.

# BMJ corporate IP ranges permitted by the corp access level (no 0.0.0.0/0).
allowed_ip_cidrs = ["REPLACE_WITH_BMJ_CORP_CIDR"] # POC placeholder — replace before apply. Do not deploy as-is.

restricted_services = [
  "bigquery.googleapis.com",
  "storage.googleapis.com",
  "secretmanager.googleapis.com",
  "composer.googleapis.com",
  "cloudkms.googleapis.com",
  "dataplex.googleapis.com",
]

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
