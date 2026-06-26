output "key_ring_id" {
  description = "Key ring ID."
  value       = google_kms_key_ring.this.id
}

output "crypto_keys" {
  description = "Map of key name to full key resource ID (for CMEK references)."
  value       = { for k, v in google_kms_crypto_key.keys : k => v.id }
}
