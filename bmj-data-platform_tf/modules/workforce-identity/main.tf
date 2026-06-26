# ---------------------------------------------------------------------------
# Module: workforce-identity
# Workforce Identity Federation pool + OIDC provider for Microsoft Entra ID
# (Azure Active Directory). This is how HUMAN users authenticate to GCP using
# their BMJ AD identity - no separate Google identities, no static keys.
# Group/role mapping is enforced via attribute mapping + IAM conditions so
# that access is least-privilege and fully auditable (ISO27001 A.9.2).
#
# NOTE: Workforce pools are an ORG-LEVEL resource. This module is applied once
# (in the management/identity project context) and referenced by environments.
# ---------------------------------------------------------------------------

resource "google_iam_workforce_pool" "this" {
  parent            = "organizations/${var.org_id}"
  location          = "global"
  workforce_pool_id = var.pool_id
  display_name      = var.display_name
  description       = var.description
  session_duration  = var.session_duration
  disabled          = false
}

resource "google_iam_workforce_pool_provider" "entra_id" {
  parent              = google_iam_workforce_pool.this.name
  location            = "global"
  workforce_pool_id   = google_iam_workforce_pool.this.workforce_pool_id
  provider_id         = var.provider_id
  display_name        = "BMJ Microsoft Entra ID (Active Directory)"
  description         = "OIDC federation with BMJ Entra ID tenant for human SSO."
  disabled            = false

  # Map Entra ID token claims to Google subject/attributes. Group membership
  # drives downstream IAM conditions (e.g. data analysts vs data engineers).
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "google.display_name"  = "assertion.email"
    "google.groups"        = "assertion.groups"
    "attribute.email"      = "assertion.email"
    "attribute.tenant"     = "assertion.tid"
  }

  # Only accept tokens from the BMJ Entra tenant (defence in depth).
  attribute_condition = "assertion.tid == '${var.entra_tenant_id}'"

  oidc {
    issuer_uri = "https://login.microsoftonline.com/${var.entra_tenant_id}/v2.0"
    client_id  = var.entra_client_id

    web_sso_config {
      response_type            = "CODE"
      assertion_claims_behavior = "MERGE_USER_INFO_OVER_ID_TOKEN_CLAIMS"
    }
  }
}
