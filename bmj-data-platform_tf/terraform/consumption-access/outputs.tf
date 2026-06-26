output "consumer_sa_emails" {
  description = "Map of logical consumer -> service account email (incl. Vertex pipeline when enabled)."
  value = merge(
    { for k, m in module.consumers : k => m.email },
    { for k, m in module.vertex_pipeline : "vertex" => m.email },
  )
}
