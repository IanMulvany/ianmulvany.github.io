# stg environment params for workforce-identity-federation (stg maps to the
# TEST project per the architecture diagram).
# NOTE: workforce pools are ORG-LEVEL; in production this dir is typically
# applied ONCE against the org using the live params. dev/stg params are kept
# only for pipeline consistency.
# POC placeholder — replace before apply. Do not deploy as-is.
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

org_id          = "REPLACE_WITH_ORG_ID"          # POC placeholder — replace before apply. Do not deploy as-is.
entra_tenant_id = "REPLACE_WITH_ENTRA_TENANT_ID" # POC placeholder — replace before apply. Do not deploy as-is.
entra_client_id = "REPLACE_WITH_ENTRA_CLIENT_ID" # POC placeholder — replace before apply. Do not deploy as-is.

pool_id          = "bmj-entra-id"
provider_id      = "entra-oidc"
session_duration = "3600s"

# Federated Entra ID group -> GCP role grants. Empty for the POC; populate with
# the Entra group OBJECT IDs (GUIDs) once known.
group_role_grants = []

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
