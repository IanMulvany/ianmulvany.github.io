output "email" {
  description = "Service account email."
  value       = google_service_account.this.email
}

output "name" {
  description = "Fully-qualified service account name."
  value       = google_service_account.this.name
}

output "member" {
  description = "IAM member string for this service account."
  value       = "serviceAccount:${google_service_account.this.email}"
}
