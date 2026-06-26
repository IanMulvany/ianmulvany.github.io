variable "project_id" {
  description = "Data-platform project for this environment (bmj-data-dev|bmj-data-test|bmj-data-prod). The budget is scoped to this project."
  type        = string
}

variable "region" {
  description = "Default region (europe-west2 / London). Budgets are global; kept for convention/parity."
  type        = string
  default     = "europe-west2"
}

variable "env" {
  description = "Environment short name (dev|stg|live). Prefixes the budget display name."
  type        = string
}

variable "billing_account" {
  description = <<-EOT
    Billing account id the budget attaches to.
    POC placeholder — replace before apply. Do not deploy as-is.
  EOT
  type        = string
  default     = "REPLACE_WITH_BILLING_ACCOUNT_ID"
}

variable "budget_amount" {
  description = "Monthly budget amount in whole currency units (params-driven per env)."
  type        = number
}

variable "currency_code" {
  description = "Budget currency code."
  type        = string
  default     = "GBP"
}

variable "thresholds" {
  description = "Threshold percentages (0-1) that trigger budget alerts."
  type        = list(number)
  default     = [0.5, 0.8, 0.9, 1.0]
}

variable "monitoring_notification_channels" {
  description = <<-EOT
    Monitoring notification channel ids for budget alerts (null = default IAM
    recipients). POC placeholder — wire to the monitoring dir's
    notification_channel_id output before apply.
  EOT
  type    = list(string)
  default = null
}

variable "labels" {
  description = "Resource labels for cost/carbon attribution and governance (budgets are not labelable; kept for params parity)."
  type        = map(string)
  default     = {}
}
