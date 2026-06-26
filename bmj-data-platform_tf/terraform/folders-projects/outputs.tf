output "data_platform_folder_id" {
  description = "ID of the Data Platform folder."
  value       = google_folder.data_platform.id
}

output "data_project_id" {
  description = "The environment data-platform project ID."
  value       = module.data_project.project_id
}

output "data_project_number" {
  description = "The environment data-platform project number."
  value       = module.data_project.project_number
}
