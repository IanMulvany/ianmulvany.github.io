variable "project_id" {
  description = "Data-platform project that owns the VPC (bmj-data-dev|bmj-data-test|bmj-data-prod)."
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

variable "network_name" {
  description = "Name of the VPC to attach private connectivity to. Looked up via a data source so no self_link needs hardcoding."
  type        = string
  default     = ""
}

# In production the VPC self_link / id would be wired from the networking dir via
# terraform_remote_state (or a data source). For the POC we look the VPC up by
# name with a google_compute_network data source (see main.tf), and these vars
# remain available as REPLACE_WITH placeholders if a direct wiring is preferred.
variable "network_self_link" {
  description = "Optional explicit VPC self link. Leave as placeholder to use the data-source lookup by name."
  type        = string
  default     = "REPLACE_WITH_NETWORK_SELF_LINK" # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "network_id" {
  description = "Optional explicit VPC id. Leave as placeholder to use the data-source lookup by name."
  type        = string
  default     = "REPLACE_WITH_NETWORK_ID" # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "psa_range_address" {
  description = "Start address for the Private Service Access (VPC peering) range, e.g. 10.100.0.0."
  type        = string
}

variable "psa_prefix_length" {
  description = "Prefix length for the Private Service Access range (a /20 gives service networking room to allocate)."
  type        = number
  default     = 20
}

variable "psc_address" {
  description = "Internal global IP for the Private Service Connect endpoint to Google APIs (all-apis), e.g. 10.100.16.0."
  type        = string
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution (GCP equivalent of AWS tags)."
  type        = map(string)
  default     = {}
}
