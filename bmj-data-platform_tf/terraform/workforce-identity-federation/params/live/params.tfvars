# live environment params for workforce-identity-federation.
# This is the canonical apply for the workforce pool: the pool/provider are
# ORG-LEVEL and in production this dir is applied ONCE against the org using
# THESE live params.
# POC placeholder — replace before apply. Do not deploy as-is.
project_id = "bmj-data-prod"
region     = "europe-west2"
env        = "live"

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
  environment = "live"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
