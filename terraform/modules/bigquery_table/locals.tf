locals {

  tables = [
    for spec in try(var.bigquery_table.spec, []) : {
      table_name           = try(spec.table_name, spec.name)
      dataset_id           = try(spec.dataset_id, var.table_default.dataset_id)
      description          = try(spec.description, var.table_default.description)
      schema               = try(spec.schema, var.table_default.schema)
      clustering           = try(spec.clustering, var.table_default.clustering)
      time_partitioning    = try(spec.time_partitioning, var.table_default.time_partitioning)
      deletion_protection  = try(spec.deletion_protection, var.table_default.deletion_protection)
      kms_key_name         = try(spec.kms_key_name, var.table_default.kms_key_name)
      finops_resource_type = coalesce(try(spec.finops_resource_type, null), "dataform_repository")
      labels               = try(spec.labels, {})
      region               = var.region

    }
  ]

  table_map = { for table in local.tables : table.table_name => table }

  finops_specs = [
    for table in local.tables : {
      resource_type = table.finops_resource_type
      name          = "${table.finops_resource_type}/${table.table_name}"
      resource_name = table.table_name
      input_labels  = table.labels
    }
  ]
}