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
  description = "Environment short name (dev|stg|live). Prefixes the consumer service-account IDs."
  type        = string
}

variable "gold_dataset_id" {
  description = "BigQuery dataset id for the curated GOLD layer that consumers read."
  type        = string
  default     = "gold"
}

variable "reference_dataset_id" {
  description = "BigQuery dataset id for the reference / lookup layer that consumers read."
  type        = string
  default     = "reference"
}

variable "enable_vertex" {
  description = <<-EOT
    Future Scope. When true, provisions a "<env>-vertex-pipeline" service
    account for Vertex AI ML workloads (roles/aiplatform.user +
    roles/bigquery.dataViewer). Gated off by default for the POC.
  EOT
  type        = bool
  default     = false
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution and governance."
  type        = map(string)
  default     = {}
}
