variable "project_id" {
  description = "Project used as the Terraform execution context (the mgmt/seed project)."
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

variable "org_id" {
  description = "BMJ GCP organisation ID."
  type        = string
}

variable "billing_account" {
  description = "Billing account ID to attach to the data-platform project."
  type        = string
}

variable "parent_folder_id" {
  description = "Parent folder under which the Data Platform folder is created (folders/NNN or organizations/NNN)."
  type        = string
}

variable "data_platform_folder_name" {
  description = "Display name for the Data Platform folder."
  type        = string
  default     = "Data Platform"
}

variable "data_project_id" {
  description = "Project ID for the data-platform project in THIS environment (e.g. bmj-data-dev)."
  type        = string
}

variable "data_project_display_name" {
  description = "Display name for the environment data project."
  type        = string
}

variable "activate_apis" {
  description = "APIs to enable on the data-platform project."
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerystorage.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "composer.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "dataplex.googleapis.com",
    "datacatalog.googleapis.com",
    "dlp.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudscheduler.googleapis.com",
    "workflows.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution."
  type        = map(string)
  default     = {}
}
