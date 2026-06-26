output "dataset_id" {
  description = "The dataset ID."
  value       = google_bigquery_dataset.this.dataset_id
}

output "self_link" {
  description = "The dataset self link."
  value       = google_bigquery_dataset.this.self_link
}
