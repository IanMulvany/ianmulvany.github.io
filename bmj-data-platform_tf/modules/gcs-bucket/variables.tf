variable "project_id" {
  description = "Project that owns the bucket."
  type        = string
}

variable "name" {
  description = "Globally unique bucket name."
  type        = string
}

variable "location" {
  description = "Bucket location (e.g. EUROPE-WEST2 or EU)."
  type        = string
}

variable "versioning" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "kms_key_name" {
  description = "Full CMEK key resource name. Null = Google-managed key."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for cost/carbon optimisation."
  type = list(object({
    action_type                = string
    storage_class              = optional(string)
    age                        = optional(number)
    days_since_noncurrent_time = optional(number)
    num_newer_versions         = optional(number)
    with_state                 = optional(string)
  }))
  default = []
}

variable "log_bucket" {
  description = "Bucket to receive access/storage logs (null = disabled)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution."
  type        = map(string)
  default     = {}
}
