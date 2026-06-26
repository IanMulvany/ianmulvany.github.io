output "pool_name" {
  description = "Workforce pool resource name."
  value       = google_iam_workforce_pool.this.name
}

output "pool_id" {
  description = "Workforce pool ID."
  value       = google_iam_workforce_pool.this.workforce_pool_id
}

output "provider_name" {
  description = "Workforce pool provider resource name."
  value       = google_iam_workforce_pool_provider.entra_id.name
}

output "principal_set_prefix" {
  description = "IAM principalSet prefix for granting roles to federated identities."
  value       = "principalSet://iam.googleapis.com/locations/global/workforcePools/${google_iam_workforce_pool.this.workforce_pool_id}"
}
