# stg environment params for budgets (cost / carbon governance)
# Note: stg maps to the TEST project per the architecture diagram.
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

# Billing account the budget attaches to.
# POC placeholder — replace before apply. Do not deploy as-is.
billing_account = "REPLACE_WITH_BILLING_ACCOUNT_ID"

# Monthly budget amount (GBP).
budget_amount = 4000
currency_code = "GBP"
thresholds    = [0.5, 0.8, 0.9, 1.0]

# Route budget alerts to the monitoring dir's notification channel.
# POC placeholder — replace before apply. Do not deploy as-is.
# e.g. monitoring_notification_channels = ["projects/bmj-data-test/notificationChannels/REPLACE_WITH_CHANNEL_ID"]
monitoring_notification_channels = null

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
