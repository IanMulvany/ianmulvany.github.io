# dev environment params for orchestration (Workflows + Scheduler glue).
project_id = "bmj-data-dev"
region     = "europe-west2"
env        = "dev"

# Endpoints the workflow calls. Wire to the Airbyte API on GKE, the dbt Cloud
# Build trigger, and a notification sink (Slack/Chat/PubSub relay).
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
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
