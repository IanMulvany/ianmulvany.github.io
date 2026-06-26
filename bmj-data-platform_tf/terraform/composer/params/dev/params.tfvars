# dev environment params for composer (orchestration layer).
project_id = "bmj-data-dev"
region     = "europe-west2"
env        = "dev"

data_subnet_name = "dev-data-subnet"

image_version = "composer-2.9.7-airflow-2.9.3"

# Airflow env vars surfaced to DAGs (point at the other layers).
env_variables = {
  BMJ_ENV               = "dev"
  AIRBYTE_API_HOST      = "REPLACE_WITH_AIRBYTE_HOST" # POC placeholder — replace before apply. Do not deploy as-is.
  DBT_CLOUDBUILD_REGION = "europe-west2"
}

# Providers/clients the DAGs import.
pypi_packages = {
  "airbyte-api" = ""
}

# CMEK (null = Google-managed).
# POC placeholder — replace before apply. Do not deploy as-is.
composer_kms_key = null

# Right-sized small footprint for dev (ISO14001).
scheduler = {
  cpu        = 0.5
  memory_gb  = 2
  storage_gb = 1
  count      = 1
}

web_server = {
  cpu        = 0.5
  memory_gb  = 2
  storage_gb = 1
}

worker = {
  cpu        = 0.5
  memory_gb  = 2
  storage_gb = 1
  min_count  = 1
  max_count  = 3
}

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
