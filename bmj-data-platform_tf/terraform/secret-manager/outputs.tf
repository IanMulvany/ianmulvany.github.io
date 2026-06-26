output "secret_ids" {
  description = "Map of secret_id -> fully-qualified secret name for every secret shell created."
  value       = { for k, m in module.secret : m.secret_id => m.name }
}
