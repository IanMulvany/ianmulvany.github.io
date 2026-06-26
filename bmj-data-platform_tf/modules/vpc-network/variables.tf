variable "project_id" {
  description = "Project that owns the network."
  type        = string
}

variable "network_name" {
  description = "VPC network name."
  type        = string
}

variable "subnets" {
  description = "Subnets to create, each with optional GKE secondary ranges."
  type = list(object({
    name          = string
    region        = string
    ip_cidr_range = string
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = []
}

variable "enable_nat" {
  description = "Provision Cloud Router + Cloud NAT for controlled egress."
  type        = bool
  default     = true
}

variable "nat_region" {
  description = "Region for the Cloud Router / NAT."
  type        = string
}

variable "internal_cidrs" {
  description = "CIDR ranges considered internal (allowed to talk to each other)."
  type        = list(string)
  default     = []
}
