# stg environment params for dbt-cloudbuild (maps to the TEST project).
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

# POC placeholder — replace before apply. Do not deploy as-is.
github_owner  = "bmjpublishing" # REPLACE_WITH_GITHUB_OWNER
github_repo   = "bmj-data-dbt"  # REPLACE_WITH_GITHUB_REPO
github_branch = "main"

dbt_build_filename = "cloudbuild.dbt.yaml"
enable_trigger     = true

schedule = "0 5 * * *"

# POC placeholder — replace before apply. Do not deploy as-is.
artifact_registry_kms_key = null
pubsub_kms_key            = null

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
