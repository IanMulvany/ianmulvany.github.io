output "composer_env_name" {
  description = "Name of the Cloud Composer environment."
  value       = google_composer_environment.orchestrator.name
}

output "airflow_uri" {
  description = "Airflow web UI URI."
  value       = google_composer_environment.orchestrator.config[0].airflow_uri
}

output "composer_sa_email" {
  description = "Email of the least-privilege Composer worker service account."
  value       = module.composer_sa.email
}

output "dag_gcs_prefix" {
  description = "GCS prefix where DAGs are uploaded for this environment."
  value       = google_composer_environment.orchestrator.config[0].dag_gcs_prefix
}
