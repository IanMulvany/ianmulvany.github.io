# dev environment params for networking
project_id = "bmj-data-dev"
region     = "europe-west2"
env        = "dev"

# RFC1918 ranges for the dev VPC. Primary subnets are /20; GKE pods is a /16 and
# services a /20 secondary range.
data_subnet_cidr  = "10.10.0.0/20"
gke_subnet_cidr   = "10.10.16.0/20"
gke_pods_cidr     = "10.40.0.0/16"
gke_services_cidr = "10.50.0.0/20"

# Internal east-west allow list = all of the above ranges.
internal_cidrs = [
  "10.10.0.0/20",
  "10.10.16.0/20",
  "10.40.0.0/16",
  "10.50.0.0/20",
]

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
