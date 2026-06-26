# stg environment params for airbyte-gke (maps to the TEST project).
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

gke_subnet_name     = "stg-gke-subnet"
pods_range_name     = "stg-gke-pods"
services_range_name = "stg-gke-services"

# Distinct /28 per env to avoid control-plane peering overlap.
master_ipv4_cidr = "172.16.0.16/28"

# POC placeholder — replace before apply. Do not deploy as-is. Never 0.0.0.0/0.
authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8" # REPLACE_WITH_BMJ_CORP_CIDR
    display_name = "bmj-corp-rfc1918"
  },
]

# POC placeholder — replace before apply. Do not deploy as-is.
artifact_registry_kms_key = null

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
