output "network_id" {
  description = "VPC network ID."
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "VPC network name."
  value       = google_compute_network.this.name
}

output "self_link" {
  description = "VPC network self link."
  value       = google_compute_network.this.self_link
}

output "subnets" {
  description = "Map of subnet name to self link."
  value       = { for k, s in google_compute_subnetwork.subnets : k => s.self_link }
}
