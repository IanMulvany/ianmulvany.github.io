# ---------------------------------------------------------------------------
# private-connectivity
# The hybrid connectivity boundary for the BMJ data platform. Implements the
# "AWS to GCP Private Connectivity (Dedicated/Partner Interconnect)" item plus
# the Private Service Connect / Private Google Access endpoints and DNS for
# googleapis.com from the Connectivity & Trust Boundaries column of the
# reference architecture.
#
# Real Dedicated/Partner Interconnect requires physical cross-connect
# provisioning (LOA-CFA, colo, VLAN attachments) that cannot be fully expressed
# in this POC. We model the GCP-side private-access surface that the
# interconnect would carry traffic to:
#
#   1. Private Service Access (PSA) reserved range + a service networking
#      connection — the peering used by managed services (e.g. Cloud SQL,
#      managed Composer) to reach the VPC privately.
#   2. A Private Service Connect (PSC) endpoint for Google APIs ("all-apis"),
#      giving workloads private access to Google APIs over the VPC.
#   3. A Cloud DNS private zone for googleapis.com pinned to the
#      private.googleapis.com VIPs (199.36.153.8-11), the standard Private
#      Google Access DNS so all *.googleapis.com resolves to private addresses.
#
# NOTE: the actual Interconnect / VLAN attachments (google_compute_interconnect,
# google_compute_interconnect_attachment) are intentionally NOT created here —
# they depend on physical provisioning and partner details that are
# REPLACE_WITH placeholders at POC stage. Do not deploy as-is.
# ---------------------------------------------------------------------------

# VPC lookup by name. In production the network would more likely be wired from
# the networking dir via terraform_remote_state; for the POC we resolve it by
# name so nothing has to be hardcoded. Defaults to "${var.env}-bmj-data-vpc".
data "google_compute_network" "vpc" {
  project = var.project_id
  name    = var.network_name != "" ? var.network_name : "${var.env}-bmj-data-vpc"
}

# ---------------------------------------------------------------------------
# 1. Private Service Access (service networking peering range)
# ---------------------------------------------------------------------------

# Reserved address block handed to Google for managed-service peering. purpose
# VPC_PEERING + prefix_length lets Google carve allocations out of this block.
resource "google_compute_global_address" "psa_range" {
  project       = var.project_id
  name          = "${var.env}-psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.psa_range_address
  prefix_length = var.psa_prefix_length
  network       = data.google_compute_network.vpc.id

  labels = var.labels
}

# The peering connection itself, for servicenetworking.googleapis.com.
resource "google_service_networking_connection" "psa" {
  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range.name]
}

# ---------------------------------------------------------------------------
# 2. Private Service Connect endpoint for Google APIs (all-apis)
# ---------------------------------------------------------------------------

# Single internal global address used as the PSC endpoint. purpose is ignored
# for a plain internal global address used by a forwarding rule.
resource "google_compute_global_address" "psc_googleapis" {
  project      = var.project_id
  name         = "${var.env}-psc-googleapis"
  address_type = "INTERNAL"
  address      = var.psc_address
  network      = data.google_compute_network.vpc.id

  labels = var.labels
}

# Forwarding rule targeting the "all-apis" Google bundle. load_balancing_scheme
# must be empty ("") for a PSC-to-Google-API endpoint.
resource "google_compute_global_forwarding_rule" "psc_googleapis" {
  project               = var.project_id
  name                  = "${var.env}-psc-googleapis-fr"
  target                = "all-apis"
  network               = data.google_compute_network.vpc.id
  ip_address            = google_compute_global_address.psc_googleapis.id
  load_balancing_scheme = ""

  labels = var.labels
}

# ---------------------------------------------------------------------------
# 3. Private Google Access DNS (googleapis.com private zone)
# ---------------------------------------------------------------------------

# Private managed zone for googleapis.com, visible only inside the VPC.
resource "google_dns_managed_zone" "googleapis" {
  project     = var.project_id
  name        = "${var.env}-googleapis"
  dns_name    = "googleapis.com."
  description = "Private zone pinning *.googleapis.com to Private Google Access VIPs."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.vpc.id
    }
  }

  labels = var.labels
}

# A record for private.googleapis.com -> the standard Private Google Access VIPs.
resource "google_dns_record_set" "private_googleapis" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.googleapis.name
  name         = "private.googleapis.com."
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

# CNAME so every *.googleapis.com name resolves to private.googleapis.com,
# routing all Google API traffic over Private Google Access / the VPC.
resource "google_dns_record_set" "wildcard_googleapis" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.googleapis.name
  name         = "*.googleapis.com."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["private.googleapis.com."]
}
