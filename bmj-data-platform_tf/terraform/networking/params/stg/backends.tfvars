# GCS remote state backend (stg) - BMJ convention:
#   bucket = bmj-data-{env}-tfstate   (created by the bootstrap dir)
#   prefix = {repo}/{resource-dir}    (cf. AWS state key {repo}/{dir}/terraform.tfstate)
bucket = "bmj-data-stg-tfstate"
prefix = "bmj-data-platform_tf/networking"
