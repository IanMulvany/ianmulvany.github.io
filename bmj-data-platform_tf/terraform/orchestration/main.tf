# ---------------------------------------------------------------------------
# orchestration
# Implements the lightweight schedule/event glue from the orchestration layer of
# the reference architecture (the "Cloud Scheduler" + "Workflows" boxes). This
# is for cross-service coordination that does NOT belong in Composer DAGs -
# e.g. kicking off simple batch loads and coordinating Airbyte -> dbt -> publish
# for the simpler pipelines, where a full Airflow DAG would be overkill.
#
# Provisions:
#   - a Cloud Workflow that sequences: start Airbyte sync -> wait -> trigger dbt
#     Cloud Build -> notify
#   - a least-privilege Workflows service account (no SA keys)
#   - a params-driven set of Cloud Scheduler jobs that execute the workflow
#     (e.g. hourly incremental, nightly full)
# ---------------------------------------------------------------------------

# Least-privilege identity the workflow executes as.
module "workflows_sa" {
  source = "../../modules/service-account"

  project_id   = var.project_id
  account_id   = "${var.env}-workflows"
  display_name = "${var.env} Workflows orchestration SA"
  description  = "Identity for the ${var.env} cross-service orchestration workflow (least privilege)."

  project_roles = [
    "roles/workflows.invoker",
    "roles/cloudbuild.builds.editor",
    "roles/run.invoker",
    "roles/logging.logWriter",
    "roles/secretmanager.secretAccessor",
  ]
}

# The orchestration workflow. Inline YAML keeps the definition versioned with
# the infra. Each external call uses the workflow SA's OAuth identity.
resource "google_workflows_workflow" "ingest" {
  project         = var.project_id
  region          = var.region
  name            = "${var.env}-ingest-orchestration"
  description     = "Coordinates Airbyte sync -> dbt build -> notify for simple ${var.env} pipelines."
  service_account = module.workflows_sa.email

  user_env_vars = {
    AIRBYTE_SYNC_URL = var.airbyte_sync_url
    DBT_TRIGGER_URL  = var.dbt_trigger_url
    NOTIFY_URL       = var.notify_url
  }

  source_contents = <<-EOT
    main:
      params: [input]
      steps:
        - init:
            assign:
              - mode: $${default(map.get(input, "mode"), "incremental")}
        - start_airbyte_sync:
            call: http.post
            args:
              url: $${sys.get_env("AIRBYTE_SYNC_URL")}
              auth:
                type: OIDC
              body:
                mode: $${mode}
            result: sync_resp
        - wait_for_sync:
            call: sys.sleep
            args:
              seconds: 120
        - trigger_dbt_build:
            call: http.post
            args:
              url: $${sys.get_env("DBT_TRIGGER_URL")}
              auth:
                type: OAuth2
              body:
                mode: $${mode}
                upstream: $${sync_resp.body}
            result: dbt_resp
        - notify:
            call: http.post
            args:
              url: $${sys.get_env("NOTIFY_URL")}
              auth:
                type: OIDC
              body:
                status: "completed"
                mode: $${mode}
                dbt: $${dbt_resp.body}
            result: notify_resp
        - done:
            return: $${notify_resp.body}
  EOT

  labels = var.labels
}

# One Cloud Scheduler job per configured schedule. Each fires the workflow via
# the Workflows Executions API, authenticated as the workflow SA (OAuth token).
resource "google_cloud_scheduler_job" "triggers" {
  for_each = { for s in var.schedules : s.name => s }

  project   = var.project_id
  region    = var.region
  name      = "${var.env}-${each.value.name}"
  schedule  = each.value.cron
  time_zone = "Europe/London"

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.ingest.id}/executions"

    body = base64encode(jsonencode({
      argument = jsonencode({ mode = each.value.mode })
    }))

    headers = {
      "Content-Type" = "application/json"
    }

    oauth_token {
      service_account_email = module.workflows_sa.email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}
