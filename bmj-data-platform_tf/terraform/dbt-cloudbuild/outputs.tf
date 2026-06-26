output "dbt_sa_email" {
  description = "Email of the least-privilege dbt runner service account."
  value       = module.dbt_sa.email
}

output "trigger_id" {
  description = "ID of the dbt Cloud Build trigger (null when disabled)."
  value       = var.enable_trigger ? google_cloudbuild_trigger.dbt_run[0].id : null
}

output "scheduler_job_name" {
  description = "Name of the nightly dbt Cloud Scheduler job."
  value       = google_cloud_scheduler_job.dbt_nightly.name
}

output "pubsub_topic" {
  description = "Full resource name of the dbt-trigger Pub/Sub topic."
  value       = google_pubsub_topic.dbt_trigger.id
}
