# ---------------------------------------------------------------------------
# budgets
# Implements cost / carbon governance for the data platform (ISO14001 resource
# efficiency + the "creating expensive resources" guardrail from the reference
# architecture). Creates one billing budget per environment, scoped to that
# env's data project, with threshold alerts at 50/80/90/100% of the monthly
# amount. Alerts route to the monitoring dir's notification channel (POC: wire
# `monitoring_notification_channels` to that channel before apply).
# ---------------------------------------------------------------------------

module "budget" {
  source = "../../modules/budget"

  billing_account = var.billing_account
  display_name    = "${var.env}-bmj-data-platform-budget"
  project_ids     = [var.project_id]
  currency_code   = var.currency_code
  amount_units    = var.budget_amount
  thresholds      = var.thresholds

  # POC placeholder — wire to monitoring dir's notification_channel_id output.
  monitoring_notification_channels = var.monitoring_notification_channels
}
