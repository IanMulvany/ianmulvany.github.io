variable "billing_account" {
  description = "Billing account ID the budget is attached to."
  type        = string
}

variable "display_name" {
  description = "Budget display name."
  type        = string
}

variable "project_ids" {
  description = "Projects in scope for this budget."
  type        = list(string)
}

variable "currency_code" {
  description = "Currency code (e.g. GBP)."
  type        = string
  default     = "GBP"
}

variable "amount_units" {
  description = "Budget amount in whole currency units."
  type        = number
}

variable "thresholds" {
  description = "Threshold percentages (0-1) that trigger alerts."
  type        = list(number)
  default     = [0.5, 0.8, 1.0]
}

variable "monitoring_notification_channels" {
  description = "Monitoring notification channel IDs for budget alerts (null = default IAM recipients)."
  type        = list(string)
  default     = null
}
