# live environment params for monitoring (Cloud Monitoring + audit trail)
project_id = "bmj-data-prod"
region     = "europe-west2"
env        = "live"

# Data-team notification channel email.
# POC placeholder — replace before apply. Do not deploy as-is.
alert_email = "REPLACE_WITH_DATA_TEAM_EMAIL"

# Destination GCS bucket for the audit-log sink. Must enforce >= 12-month
# retention per ISO27001 A.12.4.
# POC placeholder — replace before apply. Do not deploy as-is.
audit_log_bucket = "REPLACE_WITH_AUDIT_LOG_BUCKET"

# Hours of no ingestion before the freshness alert fires.
freshness_threshold_hours = 26

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
