output "secret_id" {
  description = "Secret ID."
  value       = google_secret_manager_secret.this.secret_id
}

output "name" {
  description = "Fully-qualified secret name."
  value       = google_secret_manager_secret.this.name
}
