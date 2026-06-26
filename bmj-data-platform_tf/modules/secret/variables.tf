variable "project_id" {
  description = "Project that owns the secret."
  type        = string
}

variable "secret_id" {
  description = "Secret ID."
  type        = string
}

variable "replica_locations" {
  description = "User-managed replication locations (data residency control)."
  type        = list(string)
  default     = ["europe-west2"]
}

variable "kms_key_name" {
  description = "Optional CMEK key for the secret payload. Null = Google-managed."
  type        = string
  default     = null
}

variable "accessor_members" {
  description = "IAM members granted secretAccessor (e.g. serviceAccount:...)."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Resource labels."
  type        = map(string)
  default     = {}
}
