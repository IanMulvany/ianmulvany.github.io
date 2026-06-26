variable "project_id" {
  description = "Data-platform project for this environment (bmj-data-dev|bmj-data-test|bmj-data-prod)."
  type        = string
}

variable "region" {
  description = "Default region (europe-west2 / London). Buckets use bucket_location instead."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live). Forms part of the globally-unique bucket names."
  type        = string
}

variable "bucket_location" {
  description = <<-EOT
    Location for all data-lake buckets. Defaults to the EU multi-region for
    BCP/DR resilience (data is geo-redundant across the EU). Use a single
    region (e.g. EUROPE-WEST2) only if data residency requires it.
  EOT
  type        = string
  default     = "EU"
}

variable "gcs_kms_key" {
  description = <<-EOT
    Optional CMEK key for the data-lake buckets at rest. Null = Google-managed.
    POC placeholder: wire this to the kms dir's "gcs-data-lake" crypto key
    (kms output crypto_keys["gcs-data-lake"]) before apply for CMEK at rest.
  EOT
  type        = string
  default     = null
}

variable "landing_retention_days" {
  description = "Age (days) after which landing objects are deleted, post NEARLINE/COLDLINE transitions."
  type        = number
  default     = 365
}

variable "archive_retention_days" {
  description = "Age (days) after which archived objects are deleted (long-term retention)."
  type        = number
  default     = 2555
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution and governance."
  type        = map(string)
  default     = {}
}
