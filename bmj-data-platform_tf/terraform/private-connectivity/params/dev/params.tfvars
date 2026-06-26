# dev environment params for private-connectivity
project_id = "bmj-data-dev"
region     = "europe-west2"
env        = "dev"

# VPC is resolved by name via a data source; default name is "${env}-bmj-data-vpc".
# Leave network_name empty to use that default (set it here only to override).
network_name = "dev-bmj-data-vpc"

# Private Service Access (VPC peering) reserved range. /20 carved from a block
# that does not overlap the dev VPC subnets (10.10.* / 10.40.* / 10.50.*).
psa_range_address = "10.100.0.0"
psa_prefix_length = 20

# Private Service Connect endpoint IP for Google APIs (all-apis).
psc_address = "10.100.16.0"

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
