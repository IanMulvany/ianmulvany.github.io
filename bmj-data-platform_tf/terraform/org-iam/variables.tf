variable "project_id" {
  description = "Data-platform project for this environment (bmj-data-dev|bmj-data-test|bmj-data-prod). IAM bindings are granted at this project's level."
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
# Persona group emails (BMJ Entra ID / Active Directory security groups).
# These are federated into GCP via Workforce Identity Federation (see the
# workforce-identity-federation dir); members are managed in Entra ID, NOT here.
# POC placeholder — replace before apply. Do not deploy as-is.
# ---------------------------------------------------------------------------

variable "data_platform_admins" {
  description = "Entra ID group for data-platform administrators (broadest persona; owner intentionally NOT granted)."
  type        = string
  default     = "REPLACE_WITH_DATA_PLATFORM_ADMINS_GROUP@bmj.com"
}

variable "data_engineers" {
  description = "Entra ID group for data engineers (build & operate pipelines/datasets)."
  type        = string
  default     = "REPLACE_WITH_DATA_ENGINEERS_GROUP@bmj.com"
}

variable "data_analysts" {
  description = "Entra ID group for data analysts (read + run queries)."
  type        = string
  default     = "REPLACE_WITH_DATA_ANALYSTS_GROUP@bmj.com"
}

variable "data_viewers" {
  description = "Entra ID group for data viewers (read-only)."
  type        = string
  default     = "REPLACE_WITH_DATA_VIEWERS_GROUP@bmj.com"
}

variable "platform_ops" {
  description = "Entra ID group for platform operations (observability + KMS visibility)."
  type        = string
  default     = "REPLACE_WITH_PLATFORM_OPS_GROUP@bmj.com"
}

variable "labels" {
  description = "Resource labels (unused by IAM members but kept for params-baseline consistency)."
  type        = map(string)
  default     = {}
}
