output "budget_name" {
  description = "The budget resource name."
  value       = google_billing_budget.this.name
}
