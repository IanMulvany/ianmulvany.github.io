# ---------------------------------------------------------------------------
# vpc-service-controls
# Implements "VPC Service Controls / Allowlists" from the trust-boundaries
# column of the reference architecture. A VPC-SC service perimeter is drawn
# around the data project so that BigQuery, GCS, Secret Manager (and the rest of
# the restricted services) CANNOT be exfiltrated to any project outside the
# perimeter, even by an otherwise-authorised identity.
#
# This is the enforcement of "Private by Design / Zero Trust": services are
# reachable only from inside the perimeter and only from BMJ corporate IP ranges
# (via the corp access level). It directly supports ISO27001 data protection
# (A.8 / A.13) by removing the data-exfiltration path.
#
# ORG-LEVEL NOTE: Access Context Manager (access policies, perimeters, access
# levels) is an organisation-scoped capability. A real apply requires org-level
# Access Context Manager admin (roles/accesscontextmanager.policyAdmin) and an
# existing access policy. POC placeholders below must be replaced before apply.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Access policy.
# For the POC we attach to an EXISTING access policy via var.access_policy_id so
# applying this dir does not create org-wide side effects. To create one
# instead (org-level admin required), uncomment the resource below and reference
# google_access_context_manager_access_policy.this.name as the parent.
#
#   resource "google_access_context_manager_access_policy" "this" {
#     parent = "organizations/${var.org_id}"
#     title  = "BMJ Data Platform Access Policy"
#   }
# ---------------------------------------------------------------------------

# Corporate access level: only traffic originating from BMJ corporate IP ranges
# satisfies this level. Used by the perimeter to gate ingress (zero trust:
# default-deny, explicit corp allowlist).
resource "google_access_context_manager_access_level" "corp" {
  parent = "accessPolicies/${var.access_policy_id}"
  name   = "accessPolicies/${var.access_policy_id}/accessLevels/${var.env}_corp_access"
  title  = "${var.env} BMJ corporate access"

  basic {
    conditions {
      ip_subnetworks = var.allowed_ip_cidrs
    }
  }
}

# Service perimeter around the data project. Restricted services can only be
# reached from inside the perimeter; the corp access level is attached so
# in-perimeter callers must also come from BMJ corporate IP ranges.
resource "google_access_context_manager_service_perimeter" "data" {
  parent = "accessPolicies/${var.access_policy_id}"
  name   = "accessPolicies/${var.access_policy_id}/servicePerimeters/${var.env}_bmj_data_perimeter"
  title  = "${var.env}_bmj_data_perimeter"

  status {
    resources           = ["projects/${var.project_number}"]
    restricted_services = var.restricted_services

    # Attach the corp access level so in-perimeter access additionally requires
    # a request from a BMJ corporate IP range.
    access_levels = [
      google_access_context_manager_access_level.corp.name,
    ]

    # Lock VPC-originated traffic down to the restricted services only.
    vpc_accessible_services {
      enable_restriction = true
      allowed_services   = ["RESTRICTED-SERVICES"]
    }
  }
}
