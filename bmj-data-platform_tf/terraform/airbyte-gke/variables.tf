variable "project_id" {
  description = "Data-platform project that hosts the Airbyte GKE cluster (bmj-data-dev|bmj-data-test|bmj-data-prod)."
  type        = string
}

variable "region" {
  description = "Default region (europe-west2 / London) for the cluster and Artifact Registry."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live)."
  type        = string
}

variable "gke_subnet_name" {
  description = "Name of the GKE subnet provisioned by the networking dir."
  type        = string
  default     = null
}

variable "pods_range_name" {
  description = "Secondary range name for GKE pods (from networking dir)."
  type        = string
  default     = null
}

variable "services_range_name" {
  description = "Secondary range name for GKE services (from networking dir)."
  type        = string
  default     = null
}

variable "master_ipv4_cidr" {
  description = "RFC1918 /28 CIDR for the GKE control-plane (private endpoint peering range)."
  type        = string
  default     = "172.16.0.0/28"
}

variable "authorized_cidrs" {
  description = "Corporate CIDR ranges allowed to reach the (public) control-plane endpoint. Never 0.0.0.0/0."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "artifact_registry_kms_key" {
  description = "CMEK key for the Artifact Registry repo at rest (null = Google-managed)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution (GCP equivalent of AWS tags)."
  type        = map(string)
  default     = {}
}
