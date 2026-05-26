locals {

  datasets = [
    for spec in try(var.bigquery.spec, []) : {
      dataset_id                  = try(spec.dataset_name, spec.name)
      friendly_name               = try(spec.friendly_name, var.dataset_default.friendly_name)
      description                 = try(spec.description, var.dataset_default.description)
      location                    = try(spec.location, var.dataset_default.location)
      delete_contents_on_destroy  = try(spec.delete_contents_on_destroy, var.dataset_default.delete_contents_on_destroy)
      default_table_expiration_ms = try(spec.default_table_expiration_ms, var.dataset_default.default_table_expiration_ms)
      cmek_key_name               = try(spec.cmek_key_name, var.dataset_default.cmek_key_name)
      iam                         = try(spec.iam, var.dataset_default.iam)
      region                      = var.region
      finops_resource_type        = coalesce(try(spec.finops_resource_type, null), "bq_dataset")
      labels                      = try(spec.labels, {})

    }
  ]

  dataset_map = { for dataset in local.datasets : dataset.dataset_id => {
    dataset_id                  = dataset.dataset_id
    friendly_name               = dataset.friendly_name
    description                 = dataset.description
    location                    = dataset.location
    delete_contents_on_destroy  = dataset.delete_contents_on_destroy
    default_table_expiration_ms = dataset.default_table_expiration_ms
    cmek_key_name               = dataset.cmek_key_name
    iam                         = dataset.iam
    iam_owners                  = try(dataset.iam.owners, null)
    iam_writers                 = try(dataset.iam.writers, null)
    iam_readers                 = try(dataset.iam.readers, null)
    iam_users                   = try(dataset.iam.users, null)
    region                      = dataset.region
    finops_resource_type        = dataset.finops_resource_type
    labels                      = dataset.labels
  } }

  finops_specs = [
    for dataset in local.datasets : {
      resource_type = dataset.finops_resource_type
      name          = "${dataset.finops_resource_type}/${dataset.dataset_id}"
      resource_name = dataset.dataset_id
      input_labels  = dataset.labels
    }
  ]


}