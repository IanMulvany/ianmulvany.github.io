output "cluster_name" {
  description = "Name of the Airbyte GKE Autopilot cluster."
  value       = google_container_cluster.airbyte.name
}

output "cluster_endpoint" {
  description = "Control-plane endpoint for the Airbyte cluster."
  value       = google_container_cluster.airbyte.endpoint
  sensitive   = true
}

output "node_sa_email" {
  description = "Email of the least-privilege node service account."
  value       = module.node_sa.email
}

output "artifact_registry_repo" {
  description = "Full resource name of the Airbyte Artifact Registry repo."
  value       = google_artifact_registry_repository.airbyte.id
}
