# ---------------------------------------------------------------------------
# workforce-identity-federation
# Implements human SSO via Microsoft Entra ID (Azure Active Directory) -> GCP
# using Workforce Identity Federation, from the reference architecture
# identity/trust-boundaries column. BMJ staff authenticate with their existing
# Entra ID identity (no separate Google identities, no static service-account
# keys) and Entra ID group membership drives least-privilege GCP access,
# keeping access fully auditable (ISO27001 A.9.2 - user access management).
#
# This is an ORG-LEVEL resource: a workforce pool + OIDC provider live at the
# organisation, not per project. Per-env params are kept only for consistency
# with the rest of the repo. In PRODUCTION this dir is typically applied ONCE
# against the org using the live params; the dev/stg params exist so the
# pipeline shape matches every other dir.
# ---------------------------------------------------------------------------

module "wif" {
  source = "../../modules/workforce-identity"

  org_id           = var.org_id
  pool_id          = var.pool_id
  display_name     = "BMJ Workforce Pool (Entra ID)"
  description      = "Human SSO via BMJ Microsoft Entra ID (Azure AD)."
  session_duration = var.session_duration
  provider_id      = var.provider_id
  entra_tenant_id  = var.entra_tenant_id
  entra_client_id  = var.entra_client_id
}

# ---------------------------------------------------------------------------
# Federated group -> role bindings.
#
# Members of a federated identity are addressed via the principalSet prefix
# exported by the module. To grant a role to an entire Entra ID group, append
# "/group/<ENTRA_GROUP_ID>" (the group OBJECT ID surfaced via attribute.groups):
#
#   principalSet://iam.googleapis.com/locations/global/workforcePools/<pool>/group/<ENTRA_GROUP_ID>
#
# Example (commented) bindings — uncomment and replace the GUIDs, or drive them
# entirely from var.group_role_grants in params.tfvars:
#
#   resource "google_project_iam_member" "example_analysts" {
#     project = var.project_id
#     role    = "roles/bigquery.dataViewer"
#     member  = "${module.wif.principal_set_prefix}/group/REPLACE_WITH_ENTRA_ANALYSTS_GROUP_ID"
#   }
#
#   resource "google_organization_iam_member" "example_admins_org" {
#     org_id = var.org_id
#     role   = "roles/viewer"
#     member = "${module.wif.principal_set_prefix}/group/REPLACE_WITH_ENTRA_ADMINS_GROUP_ID"
#   }
# ---------------------------------------------------------------------------

locals {
  # Split the param-driven grants by binding level so each level uses its own
  # resource type. Key is "<group>|<role>" to guarantee a unique for_each key.
  project_grants = {
    for g in var.group_role_grants : "${g.entra_group_id}|${g.role}" => g
    if g.level == "project"
  }

  org_grants = {
    for g in var.group_role_grants : "${g.entra_group_id}|${g.role}" => g
    if g.level == "org"
  }
}

resource "google_project_iam_member" "federated_group" {
  for_each = local.project_grants

  project = var.project_id
  role    = each.value.role
  member  = "${module.wif.principal_set_prefix}/group/${each.value.entra_group_id}"
}

resource "google_organization_iam_member" "federated_group" {
  for_each = local.org_grants

  org_id = var.org_id
  role   = each.value.role
  member = "${module.wif.principal_set_prefix}/group/${each.value.entra_group_id}"
}
