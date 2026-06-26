# dev environment params for bootstrap
project_id            = "bmj-data-mgmt"
region                = "europe-west2"
env                   = "dev"
state_bucket_location = "EU"

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
}
