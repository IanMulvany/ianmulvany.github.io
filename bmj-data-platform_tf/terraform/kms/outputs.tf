# These outputs are consumed (via remote state) by the bigquery, gcs-data-lake,
# composer and secret-manager dirs to wire CMEK on their resources.

output "key_ring_id" {
  description = "Full resource ID of the environment key ring."
  value       = module.keyring.key_ring_id
}

output "crypto_keys" {
  description = "Map of crypto key name -> full key resource ID (CMEK references for downstream dirs)."
  value       = module.keyring.crypto_keys
}
