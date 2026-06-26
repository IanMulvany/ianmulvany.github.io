variable "project_id" {
  description = "Data-platform project that owns the VPC (bmj-data-dev|bmj-data-test|bmj-data-prod)."
  type        = string
}

variable "region" {
  description = "Default region (europe-west2 / London). Also used for subnets and Cloud NAT."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live)."
  type        = string
}

variable "data_subnet_cidr" {
  description = "Primary RFC1918 CIDR for the data subnet (e.g. 10.10.0.0/20 dev)."
  type        = string
}

variable "gke_subnet_cidr" {
  description = "Primary RFC1918 CIDR for the GKE subnet where Airbyte runs (e.g. 10.10.16.0/20 dev)."
  type        = string
}

variable "gke_pods_cidr" {
  description = "Secondary range for GKE pods (e.g. 10.40.0.0/16 dev)."
  type        = string
}

variable "gke_services_cidr" {
  description = "Secondary range for GKE services (e.g. 10.50.0.0/20 dev)."
  type        = string
}

variable "internal_cidrs" {
  description = "CIDR ranges considered internal (allowed to talk to each other). Pass the subnet + secondary CIDRs."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution (GCP equivalent of AWS tags)."
  type        = map(string)
  default     = {}
}
