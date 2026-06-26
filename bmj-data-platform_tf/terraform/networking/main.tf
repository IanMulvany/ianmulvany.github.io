# ---------------------------------------------------------------------------
# networking
# Private-by-design VPC for the BMJ data platform. Implements the "Private
# Network / RFC1918" and "Private Routing / Cloud Router / Cloud NAT / Private
# Google Access" items from the Connectivity & Trust Boundaries column of the
# reference architecture.
#
# One custom-mode VPC per environment with:
#   - a primary data subnet (RFC1918) for platform workloads
#   - a GKE subnet (RFC1918) with secondary ranges for pods + services; this is
#     where Airbyte runs (see airbyte-gke dir)
#   - Private Google Access on every subnet (reach Google APIs with no public IP)
#   - Cloud Router + Cloud NAT for controlled, logged egress
#   - default-deny ingress with an internal-only allow rule
#
# Hybrid (AWS<->GCP) and Private Service Connect endpoints are layered on top in
# the private-connectivity dir.
# ---------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc-network"

  project_id   = var.project_id
  network_name = "${var.env}-bmj-data-vpc"

  subnets = [
    {
      # Primary data subnet for platform workloads (BigQuery jobs, Composer,
      # dbt Cloud Build workers, etc.) in the default region.
      name          = "${var.env}-data-subnet"
      region        = var.region
      ip_cidr_range = var.data_subnet_cidr
    },
    {
      # GKE subnet where Airbyte runs, with VPC-native secondary ranges for
      # GKE pods and services.
      name          = "${var.env}-gke-subnet"
      region        = var.region
      ip_cidr_range = var.gke_subnet_cidr
      secondary_ranges = [
        {
          range_name    = "${var.env}-gke-pods"
          ip_cidr_range = var.gke_pods_cidr
        },
        {
          range_name    = "${var.env}-gke-services"
          ip_cidr_range = var.gke_services_cidr
        },
      ]
    },
  ]

  # Controlled, logged egress via Cloud Router + Cloud NAT (no external IPs on
  # workloads). NAT lives in the same region as the subnets.
  enable_nat = true
  nat_region = var.region

  # Internal-only east-west traffic between platform ranges.
  internal_cidrs = var.internal_cidrs
}
