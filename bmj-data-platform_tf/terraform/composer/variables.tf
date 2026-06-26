variable "project_id" {
  description = "Data-platform project that hosts Cloud Composer (bmj-data-dev|bmj-data-test|bmj-data-prod)."
  type        = string
}

variable "region" {
  description = "Default region (europe-west2 / London) for the Composer environment."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live)."
  type        = string
}

variable "data_subnet_name" {
  description = "Name of the data subnet (from the networking dir) Composer runs in."
  type        = string
  default     = null
}

variable "image_version" {
  description = "Cloud Composer image version (Composer 2 / Airflow 2)."
  type        = string
  default     = "composer-2.9.7-airflow-2.9.3"
}

variable "composer_kms_key" {
  description = "CMEK key for the Composer environment at rest (null = Google-managed)."
  type        = string
  default     = null
}

variable "env_variables" {
  description = "Airflow environment variables exposed to DAGs."
  type        = map(string)
  default     = {}
}

variable "pypi_packages" {
  description = "Extra PyPI packages installed into the Composer environment (name -> version constraint)."
  type        = map(string)
  default     = {}
}

variable "scheduler" {
  description = "Scheduler workload sizing (right-sized per env for ISO14001)."
  type = object({
    cpu        = number
    memory_gb  = number
    storage_gb = number
    count      = number
  })
}

variable "web_server" {
  description = "Web server workload sizing."
  type = object({
    cpu        = number
    memory_gb  = number
    storage_gb = number
  })
}

variable "worker" {
  description = "Worker workload sizing + autoscaling bounds."
  type = object({
    cpu        = number
    memory_gb  = number
    storage_gb = number
    min_count  = number
    max_count  = number
  })
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution (GCP equivalent of AWS tags)."
  type        = map(string)
  default     = {}
}
