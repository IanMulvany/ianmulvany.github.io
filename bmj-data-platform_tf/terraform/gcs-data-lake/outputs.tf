output "bucket_names" {
  description = "Map of logical bucket -> created GCS bucket name (incl. the access-logs sink)."
  value = merge(
    { for k, m in module.buckets : k => m.name },
    { access-logs = module.access_logs.name },
  )
}
