# stg environment params for org-iam (stg maps to the TEST project per the architecture diagram)
# Group emails are BMJ Entra ID / AD security groups, federated via Workforce
# Identity Federation (see workforce-identity-federation dir).
# POC placeholder — replace before apply. Do not deploy as-is.
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

data_platform_admins = "REPLACE_WITH_DATA_PLATFORM_ADMINS_GROUP@bmj.com"
data_engineers       = "REPLACE_WITH_DATA_ENGINEERS_GROUP@bmj.com"
data_analysts        = "REPLACE_WITH_DATA_ANALYSTS_GROUP@bmj.com"
data_viewers         = "REPLACE_WITH_DATA_VIEWERS_GROUP@bmj.com"
platform_ops         = "REPLACE_WITH_PLATFORM_OPS_GROUP@bmj.com"

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
