output "notification_channel_id" {
  description = "Resource id of the data-team email notification channel (wire into the budgets dir)."
  value       = google_monitoring_notification_channel.data_team_email.id
}

output "alert_policy_names" {
  description = "Resource names of the provisioned alert policies."
  value = [
    google_monitoring_alert_policy.bigquery_failures.name,
    google_monitoring_alert_policy.composer_dag_failures.name,
    google_monitoring_alert_policy.pipeline_freshness.name,
  ]
}

output "log_sink_writer_identity" {
  description = "Writer identity of the audit-log sink. Grant it storage.objectCreator on the audit bucket."
  value       = google_logging_project_sink.audit_to_gcs.writer_identity
}
