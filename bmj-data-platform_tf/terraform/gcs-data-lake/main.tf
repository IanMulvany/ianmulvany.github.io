# ---------------------------------------------------------------------------
# gcs-data-lake
# Implements "DATA LAKE STORAGE — Cloud Storage (GCS) Object Storage" from the
# reference architecture: the landing / staging object store that Airbyte writes
# to and that BigQuery external tables / load jobs read from. Provides lifecycle
# management, retention, and BCP/DR via the EU multi-region by default.
#
# Buckets (suffix : purpose):
#   landing      raw file landing from SFTP / API extracts (Airbyte). Tiered down
#                NEARLINE @30d -> COLDLINE @90d, deleted @ landing_retention_days.
#   staging      intermediate processing scratch; deleted @30d.
#   archive      long-term archive (e.g. Salesforce Old, Veterinary, Mobile App);
#                ARCHIVE storage class @30d, deleted @ archive_retention_days.
#   tmp          Dataproc/Composer-style temp space; deleted @7d.
#   access-logs  storage access-log sink for the data buckets (no logging on
#                itself, to avoid recursion).
#
# Security baseline (UBLA, public_access_prevention=enforced, versioning) is
# enforced inside the gcs-bucket module. CMEK via `gcs_kms_key` (default null =
# Google-managed; wire to kms dir's crypto_keys["gcs-data-lake"]).
# ---------------------------------------------------------------------------

locals {
  # Common bucket name prefix; suffix appended per bucket. Globally unique.
  name_prefix = "bmj-data-${var.env}"

  access_logs_name = "${local.name_prefix}-access-logs"

  # Data buckets (everything except the access-logs sink). The access-logs
  # bucket is declared separately because it must NOT log to itself.
  buckets = {
    landing = {
      suffix     = "landing"
      purpose    = "landing"
      versioning = true
      lifecycle_rules = [
        {
          action_type   = "SetStorageClass"
          storage_class = "NEARLINE"
          age           = 30
        },
        {
          action_type   = "SetStorageClass"
          storage_class = "COLDLINE"
          age           = 90
        },
        {
          action_type = "Delete"
          age         = var.landing_retention_days
        },
      ]
    }
    staging = {
      suffix     = "staging"
      purpose    = "staging"
      versioning = true
      lifecycle_rules = [
        {
          action_type = "Delete"
          age         = 30
        },
      ]
    }
    archive = {
      suffix     = "archive"
      purpose    = "archive"
      versioning = true
      lifecycle_rules = [
        {
          action_type   = "SetStorageClass"
          storage_class = "ARCHIVE"
          age           = 30
        },
        {
          action_type = "Delete"
          age         = var.archive_retention_days
        },
      ]
    }
    tmp = {
      suffix     = "tmp"
      purpose    = "temp"
      versioning = true
      lifecycle_rules = [
        {
          action_type = "Delete"
          age         = 7
        },
      ]
    }
  }
}

# Access-log sink bucket. Declared first so the data buckets can target it.
# No `log_bucket` on itself to avoid a logging recursion loop.
module "access_logs" {
  source = "../../modules/gcs-bucket"

  project_id   = var.project_id
  name         = local.access_logs_name
  location     = var.bucket_location
  versioning   = true
  kms_key_name = var.gcs_kms_key

  # Expire logs after a year to control storage cost/carbon.
  lifecycle_rules = [
    {
      action_type = "Delete"
      age         = 365
    },
  ]

  log_bucket = null
  labels     = merge(var.labels, { purpose = "access-logs" })
}

# Data-lake buckets (landing / staging / archive / tmp).
module "buckets" {
  source   = "../../modules/gcs-bucket"
  for_each = local.buckets

  project_id   = var.project_id
  name         = "${local.name_prefix}-${each.value.suffix}"
  location     = var.bucket_location
  versioning   = each.value.versioning
  kms_key_name = var.gcs_kms_key

  lifecycle_rules = each.value.lifecycle_rules

  # Ship access/storage logs to the dedicated sink bucket.
  log_bucket = module.access_logs.name

  labels = merge(var.labels, { purpose = each.value.purpose })
}
