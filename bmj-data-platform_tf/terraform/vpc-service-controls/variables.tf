variable "project_id" {
  description = "Data-platform project for this environment (bmj-data-dev|bmj-data-test|bmj-data-prod). Provider context only; perimeter membership uses project_number."
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
# Access Context Manager / VPC Service Controls inputs.
# These are ORG-LEVEL constructs; POC placeholders below must be replaced and a
# real apply requires org-level Access Context Manager admin (see header).
# ---------------------------------------------------------------------------

variable "org_id" {
  description = "BMJ GCP organisation ID (parent of the access policy)."
  type        = string
  default     = "REPLACE_WITH_ORG_ID" # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "access_policy_id" {
  description = "Existing Access Context Manager access policy ID (numeric) to attach the perimeter to. Using an existing policy avoids org-level create side-effects."
  type        = string
  default     = "REPLACE_WITH_ACCESS_POLICY_ID" # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "project_number" {
  description = "Numeric project NUMBER (not ID) of the data project protected by the perimeter."
  type        = string
  default     = "REPLACE_WITH_PROJECT_NUMBER" # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "allowed_ip_cidrs" {
  description = "BMJ corporate egress IP ranges (CIDR) permitted by the corp access level. Public internet is NOT allowed; do not use 0.0.0.0/0."
  type        = list(string)
  default     = ["REPLACE_WITH_BMJ_CORP_CIDR"] # POC placeholder — replace before apply. Do not deploy as-is.
}

variable "restricted_services" {
  description = "GCP services locked inside the perimeter (no data egress to projects outside it)."
  type        = list(string)
  default = [
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "composer.googleapis.com",
    "cloudkms.googleapis.com",
    "dataplex.googleapis.com",
  ]
}

variable "labels" {
  description = "Resource labels (kept for params-baseline consistency; ACM resources are not labelable)."
  type        = map(string)
  default     = {}
}
