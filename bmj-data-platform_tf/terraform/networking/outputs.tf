output "network_id" {
  description = "VPC network ID."
  value       = module.vpc.network_id
}

output "network_name" {
  description = "VPC network name."
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "VPC network self link (consumed by the private-connectivity dir)."
  value       = module.vpc.self_link
}

output "subnet_self_links" {
  description = "Map of subnet name to self link."
  value       = module.vpc.subnets
}
