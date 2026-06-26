variable "project_id" {
  description = "Data-platform project for this environment (bmj-data-dev|bmj-data-test|bmj-data-prod). Used for provider context and project-level federated group bindings."
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

# ---------------------------------------------------------------------------
# Workforce Identity Federation (Microsoft Entra ID -> GCP human SSO).
# This is an ORG-LEVEL resource. POC placeholders below must be replaced.
# ---------------------------------------------------------------------------

variable "org_id" {
  description = "BMJ GCP organisation ID (workforce pools are org-scoped)."
  type        = string
  default     = "REPLACE_WITH_ORG_ID" # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "pool_id" {
  description = "Workforce pool ID."
  type        = string
  default     = "bmj-entra-id"
}

variable "provider_id" {
  description = "Workforce pool provider ID."
  type        = string
  default     = "entra-oidc"
}

variable "entra_tenant_id" {
  description = "Microsoft Entra ID (Azure AD) tenant ID for the BMJ tenant."
  type        = string
  default     = "REPLACE_WITH_ENTRA_TENANT_ID" # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "entra_client_id" {
  description = "OIDC application (client) ID registered in Entra ID for GCP SSO."
  type        = string
  default     = "REPLACE_WITH_ENTRA_CLIENT_ID" # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "session_duration" {
  description = "Federated session duration (e.g. 3600s)."
  type        = string
  default     = "3600s"
}

variable "group_role_grants" {
  description = <<-EOT
    Optional list of role grants for federated Entra ID groups. Each object maps
    an Entra ID group object ID to a GCP role at the given level.
      entra_group_id : the Entra ID group OBJECT ID (GUID) surfaced via the
                       attribute.groups claim, NOT the group email.
      role           : the GCP role to grant (e.g. roles/bigquery.dataViewer).
      level          : "project" (binds on var.project_id) or "org" (binds on
                       var.org_id). Defaults to "project".
    Defaults to [] so the POC creates the pool/provider without side-effect IAM.
  EOT
  type = list(object({
    entra_group_id = string
    role           = string
    level          = optional(string, "project")
  }))
  default = []
}

variable "labels" {
  description = "Resource labels (kept for params-baseline consistency; workforce pool resources are not labelable)."
  type        = map(string)
  default     = {}
}
