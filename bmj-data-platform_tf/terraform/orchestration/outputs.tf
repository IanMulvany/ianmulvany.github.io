output "workflow_id" {
  description = "Full resource ID of the ingest orchestration workflow."
  value       = google_workflows_workflow.ingest.id
}

output "workflow_sa_email" {
  description = "Email of the least-privilege Workflows service account."
  value       = module.workflows_sa.email
}

output "scheduler_jobs" {
  description = "Map of schedule name -> Cloud Scheduler job name."
  value       = { for k, j in google_cloud_scheduler_job.triggers : k => j.name }
}
