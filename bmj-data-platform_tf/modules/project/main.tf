# ---------------------------------------------------------------------------
# Module: project
# Creates a GCP project under a folder with a billing account, baseline APIs,
# and BMJ-standard labels. Mirrors the "isolated project per environment"
# pattern shown in the Reference GCP Platform Architecture (DEV / TEST / PROD).
# ---------------------------------------------------------------------------

resource "google_project" "this" {
  name            = var.display_name
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account

  # ISO27001 A.12.1.2 - no default network; networking is created explicitly
  # in the networking resource directory under least-privilege control.
  auto_create_network = false

  labels = var.labels
}

# Enable only the APIs the platform actually needs (least functionality).
resource "google_project_service" "enabled" {
  for_each = toset(var.activate_apis)

  project = google_project.this.project_id
  service = each.value

  # Keep services enabled even if removed from the list to avoid accidental
  # disruption; explicit teardown is a separate, reviewed action.
  disable_on_destroy         = false
  disable_dependent_services = false
}
