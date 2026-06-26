variable "project_id" {
  description = "Seed/management project that will own the Terraform state buckets."
  type        = string
}

variable "region" {
  description = "GCP region. BMJ data-platform default is europe-west2 (London)."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live). Used to name the state bucket."
  type        = string
}

variable "state_bucket_location" {
  description = "Location for the GCS state bucket (multi-region EU or europe-west2)."
  type        = string
  default     = "EU"
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution."
  type        = map(string)
  default     = {}
}
