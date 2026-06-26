# dev environment params for folders-projects
# NOTE: org_id / billing_account / parent_folder_id are PLACEHOLDERS for the POC.
# Replace with real BMJ org values before any apply. (Do not deploy as-is.)
project_id                = "bmj-data-mgmt"
region                    = "europe-west2"
env                       = "dev"
org_id                    = "REPLACE_WITH_BMJ_ORG_ID"
billing_account           = "REPLACE_WITH_BILLING_ACCOUNT_ID"
parent_folder_id          = "folders/REPLACE_WITH_PARENT_FOLDER_ID"
data_platform_folder_name = "Data Platform"
data_project_id           = "bmj-data-dev"
data_project_display_name = "BMJ Data Platform - Dev"

labels = {
  costcentre  = "data-platform"
  environment = "dev"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
