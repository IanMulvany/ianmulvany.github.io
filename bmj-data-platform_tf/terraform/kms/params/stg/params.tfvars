# stg environment params for kms (stg maps to the TEST project per the architecture diagram)
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"
location   = "europe-west2"

# 90-day rotation (default). Override only with security sign-off.
rotation_period = "7776000s"

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
