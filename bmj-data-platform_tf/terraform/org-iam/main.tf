# ---------------------------------------------------------------------------
# org-iam
# Implements the IAM role groups mapped to BMJ Active Directory / Entra ID
# groups from the reference architecture (least privilege, ISO27001 A.9.2 -
# user access management). Grants PROJECT-level roles to AD groups on the
# per-environment data project.
#
# The groups are federated from BMJ Entra ID via Workforce Identity Federation
# (see the workforce-identity-federation dir); user membership is administered
# in Entra ID, NOT in Terraform. Here we only bind GCP roles to the
# "group:<email>" identity, so access is driven entirely by AD group membership.
#
# Persona -> role mapping (deliberately scoped, no roles/owner anywhere):
#   data_platform_admins -> editor + projectIamAdmin   (owner avoided on purpose)
#   data_engineers       -> bigquery dataEditor/jobUser, composer.user,
#                           storage.objectAdmin, secretmanager.secretAccessor
#   data_analysts        -> bigquery dataViewer/jobUser (read-only analytics)
#   data_viewers         -> bigquery dataViewer
#   platform_ops         -> monitoring.editor, logging.viewer, cloudkms.viewer
# ---------------------------------------------------------------------------

locals {
  # Persona group email -> list of project roles (least privilege).
  group_roles = {
    (var.data_platform_admins) = [
      # roles/owner is intentionally AVOIDED (too broad); grant editor plus the
      # specific IAM-admin capability admins actually need.
      "roles/editor",
      "roles/resourcemanager.projectIamAdmin",
    ]
    (var.data_engineers) = [
      "roles/bigquery.dataEditor",
      "roles/bigquery.jobUser",
      "roles/composer.user",
      "roles/storage.objectAdmin",
      "roles/secretmanager.secretAccessor",
    ]
    (var.data_analysts) = [
      "roles/bigquery.dataViewer",
      "roles/bigquery.jobUser",
    ]
    (var.data_viewers) = [
      "roles/bigquery.dataViewer",
    ]
    (var.platform_ops) = [
      "roles/monitoring.editor",
      "roles/logging.viewer",
      "roles/cloudkms.viewer",
    ]
  }

  # Flatten {group => [roles]} into a set of "email|role" binding keys so each
  # (group, role) pair becomes one google_project_iam_member resource.
  group_role_bindings = toset(flatten([
    for group, roles in local.group_roles : [
      for role in roles : "${group}|${role}"
    ]
  ]))
}

resource "google_project_iam_member" "persona_bindings" {
  for_each = local.group_role_bindings

  project = var.project_id
  role    = split("|", each.value)[1]
  member  = "group:${split("|", each.value)[0]}"
}
