# live environment params for networking
project_id = "bmj-data-prod"
region     = "europe-west2"
env        = "live"

# RFC1918 ranges for the live VPC. Primary subnets are /20; GKE pods is a /16 and
# services a /20 secondary range. Non-overlapping with dev/stg.
data_subnet_cidr  = "10.30.0.0/20"
gke_subnet_cidr   = "10.30.16.0/20"
gke_pods_cidr     = "10.80.0.0/16"
gke_services_cidr = "10.90.0.0/20"

# Internal east-west allow list = all of the above ranges.
internal_cidrs = [
  "10.30.0.0/20",
  "10.30.16.0/20",
  "10.80.0.0/16",
  "10.90.0.0/20",
]

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
