# GCS remote state backend (dev) - BMJ convention:
#   bucket = bmj-data-{env}-tfstate   (created by the bootstrap dir)
#   prefix = {repo}/{resource-dir}    (cf. AWS state key {repo}/{dir}/terraform.tfstate)
bucket = "bmj-data-dev-tfstate"
prefix = "bmj-data-platform_tf/orchestration"
