# Bootstrap uses a LOCAL backend on first run (it is the resource directory
# that CREATES the remote state buckets). After the state bucket exists you may
# migrate bootstrap state into it by uncommenting the gcs backend below and
# running `terraform init -migrate-state -backend-config=params/<env>/backends.tfvars`.

terraform {
  backend "local" {}

  # backend "gcs" {}
}
