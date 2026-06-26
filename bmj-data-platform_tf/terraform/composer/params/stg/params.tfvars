# stg environment params for composer (maps to the TEST project).
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

data_subnet_name = "stg-data-subnet"

image_version = "composer-2.9.7-airflow-2.9.3"

env_variables = {
  BMJ_ENV               = "stg"
  AIRBYTE_API_HOST      = "REPLACE_WITH_AIRBYTE_HOST" # POC placeholder — replace before apply. Do not deploy as-is.
  DBT_CLOUDBUILD_REGION = "europe-west2"
}

pypi_packages = {
  "airbyte-api" = ""
}

# POC placeholder — replace before apply. Do not deploy as-is.
composer_kms_key = null

# Slightly larger than dev to mirror prod behaviour under test load.
scheduler = {
  cpu        = 1
  memory_gb  = 2
  storage_gb = 1
  count      = 1
}

web_server = {
  cpu        = 1
  memory_gb  = 2
  storage_gb = 1
}

worker = {
  cpu        = 1
  memory_gb  = 2
  storage_gb = 1
  min_count  = 1
  max_count  = 4
}

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
