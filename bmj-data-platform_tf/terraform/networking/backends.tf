# Remote state in GCS. The bucket/prefix are supplied per-environment via
# params/<env>/backends.tfvars (BMJ convention). GCS gives strong consistency
# and native locking, so no separate lock table is needed (cf. AWS DynamoDB).

terraform {
  backend "gcs" {}
}
