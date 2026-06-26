# stg environment params for networking (stg maps to the TEST project)
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

# RFC1918 ranges for the stg VPC. Primary subnets are /20; GKE pods is a /16 and
# services a /20 secondary range. Non-overlapping with dev/live.
data_subnet_cidr  = "10.20.0.0/20"
gke_subnet_cidr   = "10.20.16.0/20"
gke_pods_cidr     = "10.60.0.0/16"
gke_services_cidr = "10.70.0.0/20"

# Internal east-west allow list = all of the above ranges.
internal_cidrs = [
  "10.20.0.0/20",
  "10.20.16.0/20",
  "10.60.0.0/16",
  "10.70.0.0/20",
]

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
