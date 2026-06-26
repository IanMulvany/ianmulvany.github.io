variable "project_id" {
  description = "Globally unique GCP project ID (e.g. bmj-data-dev)."
  type        = string
}

variable "display_name" {
  description = "Human-readable project display name."
  type        = string
}

variable "folder_id" {
  description = "Parent folder ID (folders/NNNN) this project belongs to."
  type        = string
}

variable "billing_account" {
  description = "Billing account ID to associate with the project."
  type        = string
}

variable "activate_apis" {
  description = "List of Google APIs to enable on the project."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Resource labels (GCP equivalent of AWS tags) for cost/carbon attribution."
  type        = map(string)
  default     = {}
}
