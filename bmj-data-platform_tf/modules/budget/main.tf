# ---------------------------------------------------------------------------
# Module: budget
# A billing budget scoped to one or more projects with threshold alerts.
# Supports cost attribution and the "creating expensive resources" guardrail
# by surfacing spend early. Aligns with ISO14001 resource-efficiency intent.
# ---------------------------------------------------------------------------

resource "google_billing_budget" "this" {
  billing_account = var.billing_account
  display_name    = var.display_name

  budget_filter {
    projects               = [for p in var.project_ids : "projects/${p}"]
    calendar_period        = "MONTH"
    credit_types_treatment = "INCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      currency_code = var.currency_code
      units         = tostring(var.amount_units)
    }
  }

  dynamic "threshold_rules" {
    for_each = var.thresholds
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }

  dynamic "all_updates_rule" {
    for_each = var.monitoring_notification_channels == null ? [] : [1]
    content {
      monitoring_notification_channels = var.monitoring_notification_channels
      disable_default_iam_recipients   = false
    }
  }
}
