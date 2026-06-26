# live environment params for composer (production).
project_id = "bmj-data-prod"
region     = "europe-west2"
env        = "live"

data_subnet_name = "live-data-subnet"

image_version = "composer-2.9.7-airflow-2.9.3"

env_variables = {
  BMJ_ENV               = "live"
  AIRBYTE_API_HOST      = "REPLACE_WITH_AIRBYTE_HOST" # POC placeholder — replace before apply. Do not deploy as-is.
  DBT_CLOUDBUILD_REGION = "europe-west2"
}

pypi_packages = {
  "airbyte-api" = ""
}

# POC placeholder — replace before apply. Do not deploy as-is.
composer_kms_key = null

# Production sizing with headroom for autoscaling.
scheduler = {
  cpu        = 2
  memory_gb  = 4
  storage_gb = 2
  count      = 2
}

web_server = {
  cpu        = 2
  memory_gb  = 4
  storage_gb = 2
}

worker = {
  cpu        = 2
  memory_gb  = 4
  storage_gb = 2
  min_count  = 2
  max_count  = 8
}

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "confidential"
}
