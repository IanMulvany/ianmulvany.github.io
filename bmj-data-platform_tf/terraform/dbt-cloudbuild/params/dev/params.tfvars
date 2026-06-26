# dev environment params for dbt-cloudbuild (transformation layer).
project_id = "bmj-data-dev"
region     = "europe-west2"
env        = "dev"

# GitHub repo holding the dbt project.
# POC placeholder — replace before apply. Do not deploy as-is.
github_owner  = "bmjpublishing" # REPLACE_WITH_GITHUB_OWNER
github_repo   = "bmj-data-dbt"  # REPLACE_WITH_GITHUB_REPO
github_branch = "main"

dbt_build_filename = "cloudbuild.dbt.yaml"
enable_trigger     = true

# Nightly dbt build at 05:00 Europe/London.
schedule = "0 5 * * *"

# CMEK (null = Google-managed).
# POC placeholder — replace before apply. Do not deploy as-is.
artifact_registry_kms_key = null
pubsub_kms_key            = null

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
