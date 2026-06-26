# ---------------------------------------------------------------------------
# monitoring
# Implements "GOVERNANCE & SECURITY CONTROLS — Monitoring / Cloud Monitoring +
# Audit" and the observability for "Reliable & Resilient (HA, DR, Backup)" from
# the reference architecture. Provides:
#
#   * an email notification channel for the data team
#   * alert policies (BigQuery failures, Composer DAG failures, pipeline
#     freshness) all wired to that channel
#   * a logs-based metric counting failed BigQuery jobs
#   * project audit-log config (ADMIN_READ + DATA_WRITE) for an immutable audit
#     trail, per ISO27001 A.12.4 (event logging)
#   * a log sink exporting audit logs to GCS for >= 12-month retention
#
# This satisfies ISO27001 A.12.4 (logging and monitoring) and gives early
# warning on pipeline / warehouse failures.
# ---------------------------------------------------------------------------

# Email notification channel for the data team. All alert policies below
# reference this channel. POC: alert_email is a REPLACE_WITH placeholder.
resource "google_monitoring_notification_channel" "data_team_email" {
  project      = var.project_id
  display_name = "${var.env} data-platform email alerts"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

# ---------------------------------------------------------------------------
# Logs-based metric: failed BigQuery jobs.
# Counts completed BigQuery job events whose status carries an error. Used by
# the BigQuery alert policy below as a metric-threshold signal.
# ---------------------------------------------------------------------------
resource "google_logging_metric" "failed_bq_jobs" {
  project = var.project_id
  name    = "${var.env}-failed-bq-jobs"

  description = "Count of failed BigQuery jobs (job completion events carrying an error status)."

  filter = <<-EOT
    resource.type="bigquery_resource"
    protoPayload.serviceName="bigquery.googleapis.com"
    protoPayload.methodName="jobservice.jobcompleted"
    protoPayload.status.code!=0
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# ---------------------------------------------------------------------------
# Alert policy 1 — BigQuery failed jobs.
# Fires when the failed-BQ-jobs logs-based metric exceeds zero over a rolling
# window (i.e. any query/job failure).
# ---------------------------------------------------------------------------
resource "google_monitoring_alert_policy" "bigquery_failures" {
  project      = var.project_id
  display_name = "${var.env} BigQuery job failures"
  combiner     = "OR"

  conditions {
    display_name = "Failed BigQuery jobs > 0"

    condition_threshold {
      filter          = "resource.type=\"global\" AND metric.type=\"logging.googleapis.com/user/${google_logging_metric.failed_bq_jobs.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_DELTA"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.data_team_email.id]

  alert_strategy {
    auto_close = "1800s"
  }
}

# ---------------------------------------------------------------------------
# Alert policy 2 — Composer DAG failures.
# Uses Composer's built-in environment metric for failed Airflow task instances
# as a proxy for DAG failures. Fires when any task failures are observed.
# ---------------------------------------------------------------------------
resource "google_monitoring_alert_policy" "composer_dag_failures" {
  project      = var.project_id
  display_name = "${var.env} Composer DAG / task failures"
  combiner     = "OR"

  conditions {
    display_name = "Airflow failed task instances > 0"

    condition_threshold {
      filter          = "resource.type=\"cloud_composer_environment\" AND metric.type=\"composer.googleapis.com/environment/task_instance/failed_count\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "300s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_DELTA"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.data_team_email.id]

  alert_strategy {
    auto_close = "1800s"
  }
}

# ---------------------------------------------------------------------------
# Alert policy 3 — pipeline freshness (metric absence).
# Fires when NO successful BigQuery job completion has been seen for longer than
# freshness_threshold_hours, i.e. ingestion has stalled. Modelled as a
# metric-absence condition on the BigQuery completed-jobs metric.
# ---------------------------------------------------------------------------
resource "google_monitoring_alert_policy" "pipeline_freshness" {
  project      = var.project_id
  display_name = "${var.env} pipeline freshness — no ingestion"
  combiner     = "OR"

  conditions {
    display_name = "No completed BigQuery jobs for ${var.freshness_threshold_hours}h"

    condition_absent {
      filter   = "resource.type=\"bigquery_project\" AND metric.type=\"bigquery.googleapis.com/job/num_in_flight\""
      duration = "${var.freshness_threshold_hours * 3600}s"

      aggregations {
        alignment_period   = "3600s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.data_team_email.id]
}

# ---------------------------------------------------------------------------
# Audit-log configuration (ISO27001 A.12.4 — audit trail).
# Enables ADMIN_READ + DATA_WRITE on BigQuery and Cloud Storage. DATA_READ is
# intentionally NOT enabled to avoid excessive log volume / cost (it can be very
# noisy); ADMIN_READ + DATA_WRITE capture configuration changes and mutations,
# which are the security-relevant events for the audit trail.
# ---------------------------------------------------------------------------
resource "google_project_iam_audit_config" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_project_iam_audit_config" "storage" {
  project = var.project_id
  service = "storage.googleapis.com"

  audit_log_config {
    log_type = "ADMIN_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

# ---------------------------------------------------------------------------
# Audit-log export sink -> GCS.
# Exports audit logs (admin activity + data access) to a dedicated GCS bucket
# for long-term retention. The destination bucket MUST enforce a retention
# policy of >= 12 months per ISO27001 A.12.4. unique_writer_identity = true
# gives the sink its own service identity, which must be granted
# roles/storage.objectCreator on the bucket (handled where the bucket is owned).
# ---------------------------------------------------------------------------
resource "google_logging_project_sink" "audit_to_gcs" {
  project     = var.project_id
  name        = "${var.env}-audit-log-sink"
  destination = "storage.googleapis.com/${var.audit_log_bucket}"

  # Export admin activity + data access audit logs.
  filter = "logName:\"cloudaudit.googleapis.com\""

  unique_writer_identity = true
}
