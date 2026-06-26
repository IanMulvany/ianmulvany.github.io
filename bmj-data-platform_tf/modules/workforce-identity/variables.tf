variable "org_id" {
  description = "BMJ GCP organisation ID."
  type        = string
}

variable "pool_id" {
  description = "Workforce pool ID (e.g. bmj-entra-id)."
  type        = string
}

variable "display_name" {
  description = "Pool display name."
  type        = string
  default     = "BMJ Workforce Pool"
}

variable "description" {
  description = "Pool description."
  type        = string
  default     = "Human SSO via BMJ Entra ID."
}

variable "session_duration" {
  description = "Federated session duration (e.g. 3600s)."
  type        = string
  default     = "3600s"
}

variable "provider_id" {
  description = "Provider ID (e.g. entra-oidc)."
  type        = string
  default     = "entra-oidc"
}

variable "entra_tenant_id" {
  description = "Microsoft Entra ID (Azure AD) tenant ID."
  type        = string
}

variable "entra_client_id" {
  description = "OIDC application (client) ID registered in Entra ID for GCP."
  type        = string
}
