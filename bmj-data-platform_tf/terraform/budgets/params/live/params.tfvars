# live environment params for budgets (cost / carbon governance)
project_id = "bmj-data-prod"
region     = "europe-west2"
env        = "live"

# Billing account the budget attaches to.
# POC placeholder — replace before apply. Do not deploy as-is.
billing_account = "REPLACE_WITH_BILLING_ACCOUNT_ID"

# Monthly budget amount (GBP). live carries the production workload.
budget_amount = 15000
currency_code = "GBP"
thresholds    = [0.5, 0.8, 0.9, 1.0]

# Route budget alerts to the monitoring dir's notification channel.
# POC placeholder — replace before apply. Do not deploy as-is.
# e.g. monitoring_notification_channels = ["projects/bmj-data-prod/notificationChannels/REPLACE_WITH_CHANNEL_ID"]
monitoring_notification_channels = null

labels = {
  costcentre  = "data-platform"
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
