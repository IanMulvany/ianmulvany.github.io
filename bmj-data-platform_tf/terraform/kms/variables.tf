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
  description = "Environment short name (dev|stg|live)."
  type        = string
}

variable "location" {
  description = "KMS key ring location. Kept separate from region so multi-region/regional choices are explicit; should match the data location."
  type        = string
  default     = "europe-west2"
}

variable "rotation_period" {
  description = "Default crypto key rotation period (seconds, with 's' suffix). 90 days = 7776000s."
  type        = string
  default     = "7776000s"
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution and governance."
  type        = map(string)
  default     = {}
}
