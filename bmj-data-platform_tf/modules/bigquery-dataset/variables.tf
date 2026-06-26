variable "project_id" {
  description = "Project that owns the dataset."
  type        = string
}

variable "dataset_id" {
  description = "Dataset ID (letters, numbers, underscores)."
  type        = string
}

variable "friendly_name" {
  description = "Human-readable dataset name."
  type        = string
  default     = null
}

variable "description" {
  description = "Dataset description."
  type        = string
  default     = ""
}

variable "location" {
  description = "BigQuery dataset location (e.g. europe-west2)."
  type        = string
}

variable "kms_key_name" {
  description = "Full CMEK key resource name for encryption at rest. Null = Google-managed key."
  type        = string
  default     = null
}

variable "default_table_expiration_ms" {
  description = "Default table expiration in ms (null = never). Used to keep raw/landing transient."
  type        = number
  default     = null
}

variable "default_partition_expiration_ms" {
  description = "Default partition expiration in ms (null = never)."
  type        = number
  default     = null
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution."
  type        = map(string)
  default     = {}
}

variable "access" {
  description = "List of least-privilege access grants for the dataset."
  type = list(object({
    role           = string
    user_by_email  = optional(string)
    group_by_email = optional(string)
    special_group  = optional(string)
  }))
  default = []
}
