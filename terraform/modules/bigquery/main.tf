
module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_bigquery_dataset" "main" {

  for_each = local.dataset_map

  project                     = var.project_id
  dataset_id                  = each.key
  friendly_name               = each.value.friendly_name
  description                 = each.value.description
  location                    = each.value.location
  delete_contents_on_destroy  = each.value.delete_contents_on_destroy
  default_table_expiration_ms = each.value.default_table_expiration_ms
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.dataset_id}"],
    {}
  )

  dynamic "default_encryption_configuration" {
    for_each = each.value.cmek_key_name != null ? [each.value.cmek_key_name] : []
    content {
      kms_key_name = default_encryption_configuration.value
    }
  }

}

resource "google_bigquery_dataset_iam_binding" "owners" {
  for_each = { for k, v in local.dataset_map : k => v if lookup(v, "iam_owners", null) != null }

  dataset_id = google_bigquery_dataset.main[each.key].dataset_id
  role       = "roles/bigquery.dataOwner"
  members = distinct(concat(
    [for group in lookup(each.value.iam_owners, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.iam_owners, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.iam_owners, "special_groups", []) : sp],
    [for user in lookup(each.value.iam_owners, "users", []) : "user:${user}"]
  ))
}

resource "google_bigquery_dataset_iam_binding" "writers" {
  for_each = { for k, v in local.dataset_map : k => v if lookup(v, "iam_writers", null) != null }

  dataset_id = google_bigquery_dataset.main[each.key].dataset_id
  role       = "roles/bigquery.dataEditor"
  members = distinct(concat(
    [for group in lookup(each.value.iam_writers, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.iam_writers, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.iam_writers, "special_groups", []) : sp],
    [for user in lookup(each.value.iam_writers, "users", []) : "user:${user}"]
  ))
}

resource "google_bigquery_dataset_iam_binding" "readers" {
  for_each = { for k, v in local.dataset_map : k => v if lookup(v, "iam_readers", null) != null }

  dataset_id = google_bigquery_dataset.main[each.key].dataset_id
  role       = "roles/bigquery.dataViewer"
  members = distinct(concat(
    [for group in lookup(each.value.iam_readers, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.iam_readers, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.iam_readers, "special_groups", []) : sp],
    [for user in lookup(each.value.iam_readers, "users", []) : "user:${user}"]
  ))
}


resource "google_bigquery_dataset_iam_binding" "users" {
  for_each = { for k, v in local.dataset_map : k => v if lookup(v, "iam_users", null) != null }

  dataset_id = google_bigquery_dataset.main[each.key].dataset_id
  role       = "roles/bigquery.user"
  members = distinct(concat(
    [for group in lookup(each.value.iam_users, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.iam_users, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.iam_users, "special_groups", []) : sp],
    [for user in lookup(each.value.iam_users, "users", []) : "user:${user}"]
  ))
}