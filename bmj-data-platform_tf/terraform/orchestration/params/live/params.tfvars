# live environment params for orchestration (production).
project_id = "bmj-data-prod"
region     = "europe-west2"
env        = "live"

# POC placeholder — replace before apply. Do not deploy as-is.
airbyte_sync_url = "REPLACE_WITH_AIRBYTE_SYNC_URL"
dbt_trigger_url  = "REPLACE_WITH_DBT_TRIGGER_URL"
notify_url       = "REPLACE_WITH_NOTIFY_URL"

schedules = [
  {
    name = "hourly-incremental"
    cron = "0 * * * *"
    mode = "incremental"
  },
  {
    name = "nightly-full"
    cron = "0 2 * * *"
    mode = "full"
  },
]

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "confidential"
}
