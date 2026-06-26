variable "project_id" {
  description = "Data-platform project that hosts the dbt runner + Cloud Build (bmj-data-dev|bmj-data-test|bmj-data-prod)."
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

variable "github_owner" {
  description = "GitHub org/owner that holds the dbt project repo."
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name for the dbt project."
  type        = string
}

variable "github_branch" {
  description = "Branch regex that triggers a dbt build on push."
  type        = string
  default     = "main"
}

variable "dbt_build_filename" {
  description = "Cloud Build config filename in the repo that runs dbt build."
  type        = string
  default     = "cloudbuild.dbt.yaml"
}

variable "enable_trigger" {
  description = "Whether to create the Cloud Build trigger (allows toggling per env)."
  type        = bool
  default     = true
}

variable "schedule" {
  description = "Cron schedule for the nightly dbt run (Cloud Scheduler)."
  type        = string
  default     = "0 5 * * *"
}

variable "artifact_registry_kms_key" {
  description = "CMEK key for the dbt Artifact Registry repo at rest (null = Google-managed)."
  type        = string
  default     = null
}

variable "pubsub_kms_key" {
  description = "CMEK key for the dbt-trigger Pub/Sub topic at rest (null = Google-managed)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution (GCP equivalent of AWS tags)."
  type        = map(string)
  default     = {}
}
