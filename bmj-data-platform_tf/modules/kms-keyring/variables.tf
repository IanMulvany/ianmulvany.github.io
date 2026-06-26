variable "project_id" {
  description = "Project that owns the key ring."
  type        = string
}

variable "key_ring_name" {
  description = "Key ring name."
  type        = string
}

variable "location" {
  description = "KMS location (e.g. europe-west2). Should match data location."
  type        = string
}

variable "keys" {
  description = "Crypto keys to create in the ring."
  type = list(object({
    name             = string
    rotation_period  = optional(string)
    protection_level = optional(string)
  }))
  default = []
}

variable "default_rotation_period" {
  description = "Default key rotation period (seconds suffix s). 90 days."
  type        = string
  default     = "7776000s"
}

variable "labels" {
  description = "Resource labels."
  type        = map(string)
  default     = {}
}
