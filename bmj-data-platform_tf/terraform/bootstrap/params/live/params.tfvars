# live (PROD) environment params for bootstrap
project_id            = "bmj-data-mgmt"
region                = "europe-west2"
env                   = "live"
state_bucket_location = "EU"

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
}
