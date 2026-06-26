variable "project_id" {
  description = "Data-platform project for this environment (bmj-data-dev|bmj-data-test|bmj-data-prod)."
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

variable "secrets" {
  description = <<-EOT
    Logical source/platform systems that require stored credentials. One secret
    SHELL named "src-<system>-credentials" is created per entry (values are
    populated out-of-band, never in Terraform). Covers the Airbyte source
    connectors plus platform service credentials.
  EOT
  type        = list(string)
  default = [
    # --- Airbyte source-system connector credentials ---------------------
    "salesforce",
    "navision",
    "bma-azure-crm",
    "adestra",
    "crossref",
    "dimensions",
    "web-of-science",
    "scholarone",
    "highwire",
    "ringgold",
    "ror",
    "rightslink",
    "madgex",
    "onexam",
    "kria",
    "nhs-job-board",
    "health-education-england",
    "siq",
    "google-analytics",
    "pardot",
    # --- Platform service credentials ------------------------------------
    "airbyte-admin",
    "dbt-service-token",
    "tableau-connection",
  ]
}

variable "replica_locations" {
  description = "User-managed replication locations (data residency control)."
  type        = list(string)
  default     = ["europe-west2"]
}

variable "secrets_kms_key" {
  description = <<-EOT
    Optional CMEK key for secret payloads. Null = Google-managed encryption.
    POC placeholder: wire this to the kms dir's "secrets" crypto key
    (kms output crypto_keys["secrets"]) before apply for CMEK at rest.
  EOT
  type        = string
  default     = null
}

variable "accessor_members" {
  description = "IAM members (e.g. serviceAccount:...) granted secretAccessor on ALL secrets. Default empty; grant SAs least-privilege access later."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution and governance."
  type        = map(string)
  default     = {}
}
