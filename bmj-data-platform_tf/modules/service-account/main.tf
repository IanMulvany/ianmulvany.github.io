# ---------------------------------------------------------------------------
# Module: service-account
# Creates a least-privilege service account and binds a scoped set of project
# roles. No service-account KEYS are created here - workloads use Workload
# Identity / attached SAs, and human access uses Workforce Identity Federation
# (Entra ID). This satisfies ISO27001 A.9.2 (least privilege) and avoids
# long-lived static keys.
# ---------------------------------------------------------------------------

resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
}

# Project-level role grants (additive, one binding member per role).
resource "google_project_iam_member" "roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.this.email}"
}
