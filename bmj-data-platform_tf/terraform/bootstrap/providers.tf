# Provider configuration for the bootstrap resource directory.
# Bootstrap is special: it creates the GCS state buckets that every OTHER
# resource directory uses as its backend. It is run ONCE per environment with
# a LOCAL backend, then (optionally) migrated. See README "First-time setup".

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
