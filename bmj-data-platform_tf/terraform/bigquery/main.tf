# ---------------------------------------------------------------------------
# bigquery
# Implements the "ANALYTICS & DATA LAYER — BigQuery Datasets (ELT Modeled Data)"
# medallion warehouse from the reference architecture:
#   Raw/Bronze -> Silver -> Gold, plus Reference Data and the Dataplex-backed
#   "Metadata & Observe / Knowledge Catalog" working datasets.
#
# Layers (dataset_id : purpose):
#   raw        landing/raw ingested data from Airbyte (transient; table TTL)
#   bronze     lightly cleaned / typed
#   silver     conformed / joined / deduplicated
#   gold       curated, aggregated data marts (BI-facing)
#   reference  reference / lookup data (date dim, currency rates, postcodes, journal grid)
#   catalog    metadata / knowledge catalog working datasets (Dataplex)
#
# CMEK: pass `bigquery_kms_key` = kms dir's crypto_keys["bigquery"] for CMEK at
# rest (default null = Google-managed; see kms dir).
# Access: gold + reference are READER-readable by data_analysts_group; data
# engineers get WRITER on raw/bronze/silver/gold at the dataset level (broad
# project IAM is layered on in org-iam). Group emails are POC placeholders.
# ---------------------------------------------------------------------------

locals {
  # data engineers write across the working + curated layers.
  engineer_access = [
    {
      role           = "WRITER"
      group_by_email = var.data_engineers_group
    }
  ]

  # data analysts read only the BI-facing curated layers.
  analyst_access = [
    {
      role           = "READER"
      group_by_email = var.data_analysts_group
    }
  ]

  # One entry per medallion / reference / catalog dataset. `access` and the
  # per-dataset table expiration are tuned per layer.
  datasets = {
    raw = {
      friendly_name               = "Raw / Bronze landing (Airbyte)"
      description                 = "Landing / raw ingested data from Airbyte. Transient: tables self-expire."
      layer                       = "raw"
      default_table_expiration_ms = var.raw_table_expiration_ms
      access                      = local.engineer_access
    }
    bronze = {
      friendly_name               = "Bronze (cleaned / typed)"
      description                 = "Lightly cleaned and typed data derived from raw."
      layer                       = "bronze"
      default_table_expiration_ms = null
      access                      = local.engineer_access
    }
    silver = {
      friendly_name               = "Silver (conformed)"
      description                 = "Conformed, joined and deduplicated data."
      layer                       = "silver"
      default_table_expiration_ms = null
      access                      = local.engineer_access
    }
    gold = {
      friendly_name               = "Gold (curated data marts)"
      description                 = "Curated, aggregated BI-facing data marts."
      layer                       = "gold"
      default_table_expiration_ms = null
      # Engineers write, analysts read.
      access = concat(local.engineer_access, local.analyst_access)
    }
    reference = {
      friendly_name               = "Reference data"
      description                 = "Reference / lookup data: date dim, currency rates, postcodes, journal grid."
      layer                       = "reference"
      default_table_expiration_ms = null
      # Analysts read reference data (engineers manage it via project IAM).
      access = local.analyst_access
    }
    catalog = {
      friendly_name               = "Knowledge catalog (Dataplex)"
      description                 = "Metadata / knowledge catalog working datasets (Dataplex)."
      layer                       = "catalog"
      default_table_expiration_ms = null
      access                      = local.engineer_access
    }
  }
}

# One dataset per medallion layer, plus reference + catalog.
module "datasets" {
  source   = "../../modules/bigquery-dataset"
  for_each = local.datasets

  project_id    = var.project_id
  dataset_id    = each.key
  friendly_name = each.value.friendly_name
  description   = each.value.description
  location      = var.bq_location

  kms_key_name                = var.bigquery_kms_key
  default_table_expiration_ms = each.value.default_table_expiration_ms

  # Per-dataset "layer" label merged onto the standard BMJ labels.
  labels = merge(var.labels, { layer = each.value.layer })

  access = each.value.access
}

# ---------------------------------------------------------------------------
# Dataplex — "Metadata & Observe / Knowledge Catalog"
# A lake with a curated zone (gold/silver/reference) and a raw zone (raw/bronze),
# both with auto-discovery enabled so assets are catalogued. Toggleable.
# ---------------------------------------------------------------------------

resource "google_dataplex_lake" "this" {
  count = var.enable_dataplex ? 1 : 0

  project  = var.project_id
  name     = "${var.env}-bmj-data-lake"
  location = var.region

  display_name = "${var.env} BMJ Data Lake"
  description  = "Knowledge Catalog lake for the BMJ data platform (Dataplex)."
  labels       = var.labels
}

resource "google_dataplex_zone" "curated" {
  count = var.enable_dataplex ? 1 : 0

  project  = var.project_id
  lake     = google_dataplex_lake.this[0].name
  name     = "${var.env}-curated-zone"
  location = var.region

  type          = "CURATED"
  display_name  = "Curated zone"
  description   = "Curated / conformed layers (silver, gold, reference)."
  labels        = var.labels

  resource_spec {
    location_type = "SINGLE_REGION"
  }

  discovery_spec {
    enabled = true
  }
}

resource "google_dataplex_zone" "raw" {
  count = var.enable_dataplex ? 1 : 0

  project  = var.project_id
  lake     = google_dataplex_lake.this[0].name
  name     = "${var.env}-raw-zone"
  location = var.region

  type          = "RAW"
  display_name  = "Raw zone"
  description   = "Raw / lightly-processed layers (raw, bronze)."
  labels        = var.labels

  resource_spec {
    location_type = "SINGLE_REGION"
  }

  discovery_spec {
    enabled = true
  }
}
