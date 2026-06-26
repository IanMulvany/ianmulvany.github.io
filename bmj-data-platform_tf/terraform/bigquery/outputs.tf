output "dataset_ids" {
  description = "Map of logical layer -> created BigQuery dataset ID."
  value       = { for k, m in module.datasets : k => m.dataset_id }
}

output "dataplex_lake_id" {
  description = "Full resource name of the Dataplex lake (null when enable_dataplex = false)."
  value       = var.enable_dataplex ? google_dataplex_lake.this[0].id : null
}
