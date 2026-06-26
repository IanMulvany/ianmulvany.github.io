# dev environment params for airbyte-gke (Airbyte ingestion on GKE Autopilot)
project_id = "bmj-data-dev"
region     = "europe-west2"
env        = "dev"

# GKE subnet + secondary ranges from the networking dir. Defaults derive from
# env, listed here for clarity.
gke_subnet_name     = "dev-gke-subnet"
pods_range_name     = "dev-gke-pods"
services_range_name = "dev-gke-services"

# Private control-plane peering range (/28, RFC1918, must not overlap subnets).
master_ipv4_cidr = "172.16.0.0/28"

# Corporate ranges allowed to reach the control-plane endpoint.
# POC placeholder — replace before apply. Do not deploy as-is. Never 0.0.0.0/0.
authorized_cidrs = [
  {
    cidr_block   = "10.0.0.0/8" # REPLACE_WITH_BMJ_CORP_CIDR
    display_name = "bmj-corp-rfc1918"
  },
]

# CMEK for the Artifact Registry repo at rest.
# POC placeholder — replace before apply. Do not deploy as-is.
# Wire to the kms dir, e.g.:
#   artifact_registry_kms_key = "projects/bmj-data-dev/locations/europe-west2/keyRings/dev-bmj-data-keyring/cryptoKeys/artifact-registry"
artifact_registry_kms_key = null

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
