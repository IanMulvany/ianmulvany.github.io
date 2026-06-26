output "state_bucket" {
  description = "Name of the Terraform state bucket for this environment."
  value       = google_storage_bucket.tfstate.name
}
