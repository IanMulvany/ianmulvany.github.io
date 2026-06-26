# ---------------------------------------------------------------------------
# Module: vpc-network
# Private-by-design VPC for the data platform. Implements the "Connectivity &
# Trust Boundaries" column of the reference architecture:
#  - custom-mode VPC (no auto subnets)
#  - Private Google Access on every subnet (reach Google APIs without egress)
#  - Cloud Router + Cloud NAT for controlled, logged egress
#  - secondary ranges for GKE (pods/services) where Airbyte runs
#  - default-deny ingress; only explicitly allowed flows are opened
# ---------------------------------------------------------------------------

resource "google_compute_network" "this" {
  project                         = var.project_id
  name                            = var.network_name
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "subnets" {
  for_each = { for s in var.subnets : s.name => s }

  project       = var.project_id
  name          = each.value.name
  region        = each.value.region
  network       = google_compute_network.this.id
  ip_cidr_range = each.value.ip_cidr_range

  # Private Google Access: VMs/pods reach Google APIs (BigQuery, GCS, Secret
  # Manager) over Google's internal network, no public IPs required.
  private_ip_google_access = true

  # VPC flow logs for audit (ISO27001 A.12.4 event logging).
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

# Controlled egress: Cloud Router + Cloud NAT (no external IPs on workloads).
resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  project = var.project_id
  name    = "${var.network_name}-router"
  region  = var.nat_region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat ? 1 : 0
  project                            = var.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router[0].name
  region                             = var.nat_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

# Default-deny ingress (zero trust). Specific allows are layered on top.
resource "google_compute_firewall" "deny_all_ingress" {
  project       = var.project_id
  name          = "${var.network_name}-deny-all-ingress"
  network       = google_compute_network.this.name
  direction     = "INGRESS"
  priority      = 65534
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow internal traffic between platform subnets only.
resource "google_compute_firewall" "allow_internal" {
  project       = var.project_id
  name          = "${var.network_name}-allow-internal"
  network       = google_compute_network.this.name
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = var.internal_cidrs

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
