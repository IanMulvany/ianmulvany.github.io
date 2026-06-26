# live environment params for private-connectivity
project_id = "bmj-data-prod"
region     = "europe-west2"
env        = "live"

# VPC is resolved by name via a data source; default name is "${env}-bmj-data-vpc".
network_name = "live-bmj-data-vpc"

# Private Service Access (VPC peering) reserved range. /20 non-overlapping with
# the live VPC subnets (10.30.* / 10.80.* / 10.90.*) and the dev/stg ranges.
psa_range_address = "10.120.0.0"
psa_prefix_length = 20

# Private Service Connect endpoint IP for Google APIs (all-apis).
psc_address = "10.120.16.0"

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
