# stg environment params for consumption-access (CONSUMPTION column access)
# Note: stg maps to the TEST project per the architecture diagram.
project_id = "bmj-data-test"
region     = "europe-west2"
env        = "stg"

# BigQuery datasets the consumers (Tableau / Hum / third-party) may read.
gold_dataset_id      = "gold"
reference_dataset_id = "reference"

# Vertex AI ML workloads are FUTURE SCOPE — keep gated off for the POC.
enable_vertex = false

labels = {
  costcentre  = "data-platform"
  environment = "stg"
  managedby   = "terraform"
  gitrepo     = "bmj-data-platform_tf"
  owner       = "data-engineering"
  dataclass   = "internal"
}
