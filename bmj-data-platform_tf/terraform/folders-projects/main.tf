# ---------------------------------------------------------------------------
# folders-projects
# The landing-zone resource hierarchy. Creates the "Data Platform" folder and,
# within it, the isolated per-environment project (DEV / TEST / PROD) shown in
# the reference architecture. Each environment runs this dir with its own
# params so each environment becomes its own project under the shared folder.
#
#   organisation
#   └── <parent_folder>            (e.g. "Engineering")
#       └── Data Platform          (this folder)
#           ├── bmj-data-dev       (env=dev)
#           ├── bmj-data-test      (env=stg)
#           └── bmj-data-prod      (env=live)
#
# Project isolation per environment is the primary security boundary and the
# unit of VPC Service Controls perimeters (see vpc-service-controls dir).
# ---------------------------------------------------------------------------

resource "google_folder" "data_platform" {
  display_name = var.data_platform_folder_name
  parent       = var.parent_folder_id

  lifecycle {
    # Folder is shared across environments; only created once. Re-applies in
    # other environments will import/no-op via the same display name + parent.
    ignore_changes = []
  }
}

module "data_project" {
  source = "../../modules/project"

  project_id      = var.data_project_id
  display_name    = var.data_project_display_name
  folder_id       = google_folder.data_platform.id
  billing_account = var.billing_account
  activate_apis   = var.activate_apis
  labels          = var.labels
}
