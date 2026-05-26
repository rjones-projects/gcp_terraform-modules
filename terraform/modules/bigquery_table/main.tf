module "finops_labels" {
  source = "../finops_labels"
  finops_labels = {
    spec = local.finops_specs
  }
}


resource "google_bigquery_table" "tables" {
  # Flatten the map of tables for all datasets
  for_each = local.table_map

  project     = var.project_id
  table_id    = each.value.table_name
  dataset_id  = each.value.dataset_id
  description = each.value.description
  schema      = each.value.schema
  clustering  = each.value.clustering
  # checkov:skip=CKV_GCP_121: "Ensure BigQuery tables have deletion protection enabled"
  deletion_protection = each.value.deletion_protection
  encryption_configuration {
    kms_key_name = each.value.kms_key_name
  }
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.table_name}"],
    {}
  )
  dynamic "time_partitioning" {
    for_each = each.value.time_partitioning != null ? [each.value.time_partitioning] : []
    content {
      type          = time_partitioning.value.type
      field         = lookup(time_partitioning.value, "field", null)
      expiration_ms = lookup(time_partitioning.value, "expiration_ms", null)
    }
  }
}