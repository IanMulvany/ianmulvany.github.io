# stg environment params for private-connectivity (stg maps to the TEST project)
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

# VPC is resolved by name via a data source; default name is "${env}-bmj-data-vpc".
network_name = "stg-bmj-data-vpc"

# Private Service Access (VPC peering) reserved range. /20 non-overlapping with
# the stg VPC subnets (10.20.* / 10.60.* / 10.70.*) and the dev/live ranges.
psa_range_address = "10.110.0.0"
psa_prefix_length = 20

# Private Service Connect endpoint IP for Google APIs (all-apis).
psc_address = "10.110.16.0"

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
