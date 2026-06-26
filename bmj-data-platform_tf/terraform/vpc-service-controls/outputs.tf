output "perimeter_name" {
  description = "Service perimeter resource name."
  value       = google_access_context_manager_service_perimeter.data.name
}

output "access_level_name" {
  description = "Corporate access level resource name."
  value       = google_access_context_manager_access_level.corp.name
}
