output "project_id" {
  description = "The created project ID."
  value       = google_project.this.project_id
}

output "project_number" {
  description = "The created project number (used for IAM member bindings)."
  value       = google_project.this.number
}

output "enabled_apis" {
  description = "APIs enabled on the project."
  value       = [for s in google_project_service.enabled : s.service]
}
