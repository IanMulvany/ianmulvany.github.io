output "pool_name" {
  description = "Workforce pool resource name."
  value       = module.wif.pool_name
}

output "provider_name" {
  description = "Workforce pool provider resource name."
  value       = module.wif.provider_name
}

output "principal_set_prefix" {
  description = "IAM principalSet prefix; append /group/<ENTRA_GROUP_ID> to grant roles to a federated Entra ID group."
  value       = module.wif.principal_set_prefix
}
