output "group_role_bindings" {
  description = "Persona group email -> list of project roles granted (echo of the bindings created)."
  value       = local.group_roles
}

output "binding_keys" {
  description = "Flat list of the (group|role) bindings actually created."
  value       = sort(tolist(local.group_role_bindings))
}
