variable "project_id" {
  description = "Data-platform project for this environment (bmj-data-dev|bmj-data-test|bmj-data-prod)."
  type        = string
}

variable "region" {
  description = "Default region (europe-west2 / London). Used for Dataplex lake/zone location."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live)."
  type        = string
}

variable "bq_location" {
  description = "BigQuery dataset location for all medallion datasets (e.g. europe-west2)."
  type        = string
  default     = "europe-west2"
}

variable "bigquery_kms_key" {
  description = <<-EOT
    Optional CMEK key for BigQuery datasets at rest. Null = Google-managed.
    POC placeholder: wire this to the kms dir's "bigquery" crypto key
    (kms output crypto_keys["bigquery"]) before apply for CMEK at rest.
  EOT
  type        = string
  default     = null
}

variable "raw_table_expiration_ms" {
  description = <<-EOT
    Default table expiration (ms) for the transient raw/landing dataset, so
    Airbyte-landed tables self-expire. Null = never. dev keeps this short
    (e.g. 90 days); live keeps raw longer for replay/lineage.
  EOT
  type        = number
  default     = null
}

variable "data_engineers_group" {
  description = <<-EOT
    Google Group email for data engineers. Granted WRITER on raw/bronze/silver/gold
    at the dataset level (broad project IAM is layered on top in org-iam).
    POC placeholder — replace with the real group email before apply.
  EOT
  type        = string
  default     = "REPLACE_WITH_DATA_ENGINEERS_GROUP_EMAIL"
}

variable "data_analysts_group" {
  description = <<-EOT
    Google Group email for data analysts / BI consumers. Granted READER on the
    BI-facing gold and reference datasets only (least privilege).
    POC placeholder — replace with the real group email before apply.
  EOT
  type        = string
  default     = "REPLACE_WITH_DATA_ANALYSTS_GROUP_EMAIL"
}

variable "enable_dataplex" {
  description = "Toggle the Dataplex lake + zones (Knowledge Catalog / Metadata & Observe layer)."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution and governance."
  type        = map(string)
  default     = {}
}
