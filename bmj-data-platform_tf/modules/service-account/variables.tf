variable "project_id" {
  description = "Project in which to create the service account."
  type        = string
}

variable "account_id" {
  description = "Service account ID (the part before @)."
  type        = string
}

variable "display_name" {
  description = "Display name."
  type        = string
}

variable "description" {
  description = "Purpose of the service account."
  type        = string
  default     = ""
}

variable "project_roles" {
  description = "Scoped project roles to grant. Keep to the minimum required."
  type        = list(string)
  default     = []
}
