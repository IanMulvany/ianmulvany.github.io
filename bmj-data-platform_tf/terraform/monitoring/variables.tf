variable "project_id" {
  description = "Data-platform project for this environment (bmj-data-dev|bmj-data-test|bmj-data-prod)."
  type        = string
}

variable "region" {
  description = "Default region (europe-west2 / London)."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live). Prefixes alert policy / metric display names."
  type        = string
}

variable "alert_email" {
  description = <<-EOT
    Email address for the data-team notification channel that receives alerts.
    POC placeholder — replace before apply. Do not deploy as-is.
  EOT
  type        = string
  default     = "REPLACE_WITH_DATA_TEAM_EMAIL"
}

variable "audit_log_bucket" {
  description = <<-EOT
    GCS bucket name (no gs:// prefix) that the audit-log sink exports to for
    long-term retention. Must already exist with a retention policy of >= 12
    months per ISO27001 A.12.4. POC placeholder — replace before apply.
  EOT
  type        = string
  default     = "REPLACE_WITH_AUDIT_LOG_BUCKET"
}

variable "freshness_threshold_hours" {
  description = <<-EOT
    Hours of no successful ingestion after which the pipeline-freshness alert
    fires (metric-absence). Default 26h covers a daily pipeline plus slack.
  EOT
  type        = number
  default     = 26
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution and governance (applied to the log sink metric labels where supported)."
  type        = map(string)
  default     = {}
}
