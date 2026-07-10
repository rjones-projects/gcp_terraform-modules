resource "google_logging_project_sink" "logging_sink" {
  for_each = local.sinks

  name        = each.value.name
  description = each.value.description
  filter      = each.value.filter

  destination = coalesce(
    each.value.destination,
    each.value.dataset_id != null ? "bigquery.googleapis.com/projects/${var.project_id}/datasets/${each.value.dataset_id}" : null
  )

  unique_writer_identity = true
}

# IAM binding for sink writer identity to BigQuery datasets
resource "google_bigquery_dataset_iam_binding" "sink_binding" {
  for_each = {
    for k, v in local.sinks : k => v
    if v.dataset_id != null || can(regex("bigquery", coalesce(v.destination, "")))
  }

  dataset_id = coalesce(
    each.value.dataset_id,
    can(regex("datasets/([^/]+)", coalesce(each.value.destination, ""))) ? regex("datasets/([^/]+)", each.value.destination)[0] : null
  )

  role    = "roles/bigquery.dataEditor"
  members = [google_logging_project_sink.logging_sink[each.key].writer_identity]

  depends_on = [google_logging_project_sink.logging_sink]
}