# GCS remote state backend (live) - BMJ convention:
#   bucket = bmj-data-{env}-tfstate   (created by the bootstrap dir)
#   prefix = {repo}/{resource-dir}    (cf. AWS state key {repo}/{dir}/terraform.tfstate)
bucket = "bmj-data-live-tfstate"
prefix = "bmj-data-platform_tf/org-iam"
