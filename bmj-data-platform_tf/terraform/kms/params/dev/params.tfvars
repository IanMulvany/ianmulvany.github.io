# dev environment params for kms
project_id = "bmj-data-dev"
region     = "europe-west2"
env        = "dev"
location   = "europe-west2"

# 90-day rotation (default). Override only with security sign-off.
rotation_period = "7776000s"

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
