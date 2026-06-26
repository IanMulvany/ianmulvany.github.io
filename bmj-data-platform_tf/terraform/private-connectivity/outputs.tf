output "psa_range_name" {
  description = "Name of the Private Service Access (VPC peering) reserved range."
  value       = google_compute_global_address.psa_range.name
}

output "psc_address" {
  description = "Internal IP of the Private Service Connect endpoint to Google APIs."
  value       = google_compute_global_address.psc_googleapis.address
}

output "dns_zone_name" {
  description = "Name of the private googleapis.com Cloud DNS managed zone."
  value       = google_dns_managed_zone.googleapis.name
}
