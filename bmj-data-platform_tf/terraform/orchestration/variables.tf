variable "project_id" {
  description = "Data-platform project that hosts the Workflows + Scheduler glue (bmj-data-dev|bmj-data-test|bmj-data-prod)."
  type        = string
}

variable "region" {
  description = "Default region (europe-west2 / London)."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live)."
  type        = string
}

variable "airbyte_sync_url" {
  description = "HTTPS endpoint the workflow calls to start an Airbyte sync."
  type        = string
  default     = "REPLACE_WITH_AIRBYTE_SYNC_URL"
}

variable "dbt_trigger_url" {
  description = "HTTPS endpoint the workflow calls to trigger the dbt Cloud Build run."
  type        = string
  default     = "REPLACE_WITH_DBT_TRIGGER_URL"
}

variable "notify_url" {
  description = "HTTPS endpoint the workflow calls to send a completion notification."
  type        = string
  default     = "REPLACE_WITH_NOTIFY_URL"
}

variable "schedules" {
  description = "Cron schedules that trigger the workflow (name + cron expression)."
  type = list(object({
    name = string
    cron = string
    mode = string
  }))
  default = [
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
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution (GCP equivalent of AWS tags)."
  type        = map(string)
  default     = {}
}
