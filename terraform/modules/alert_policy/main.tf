module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

# Fetch Notification Channels by Display Name to avoid hardcoding IDs
data "google_monitoring_notification_channel" "by_name" {
  for_each = toset([
    for nc in flatten([for alert in try(var.alert_policy.spec, []) : try(alert.notification_channels, [])]) :
    nc if !startswith(nc, "projects/")
  ])

  display_name = each.value
  project      = var.project_id
}

resource "google_project_service" "logging_api" {
  count              = length(local.alerts) > 0 ? 1 : 0
  project            = var.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "stackdriver_api" {
  count              = length(local.alerts) > 0 ? 1 : 0
  project            = var.project_id
  service            = "stackdriver.googleapis.com"
  disable_on_destroy = false
}

resource "google_logging_metric" "google_custom_metrics" {
  for_each = { for k, v in local.alerts : k => v if v.create_metric }

  project = var.project_id
  name    = each.value.metric_name
  filter  = each.value.custom_metric_filter

  metric_descriptor {
    metric_kind = each.value.custom_metric_kind
    value_type  = each.value.custom_metric_type
  }

  depends_on = [google_project_service.logging_api]
}

resource "google_monitoring_alert_policy" "google_custom_alerts" {
  for_each = local.alerts

  project               = var.project_id
  display_name          = each.value.alert_name
  combiner              = each.value.alert_combiner
  notification_channels = each.value.notification_channels

  user_labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.alert_name}"],
    {}
  )

  conditions {
    display_name = "${each.value.alert_name}-alert"
    condition_threshold {
      filter          = each.value.alert_filter
      duration        = each.value.alert_duration
      comparison      = each.value.alert_comparison
      threshold_value = each.value.alert_threshold

      aggregations {
        alignment_period     = each.value.alert_alignment != "" ? each.value.alert_alignment : null
        per_series_aligner   = each.value.alert_aligner != "" ? each.value.alert_aligner : null
        cross_series_reducer = each.value.alert_reducer != "" ? each.value.alert_reducer : null
        group_by_fields      = length(each.value.group_by_fields) > 0 ? each.value.group_by_fields : null
      }

      evaluation_missing_data = each.value.evaluation_missing_data != "" ? each.value.evaluation_missing_data : null

      trigger {
        percent = each.value.percent != "0" ? each.value.percent : null
        count   = each.value.trigger_count != "0" ? each.value.trigger_count : null
      }
    }
  }

  documentation {
    content = each.value.alert_doc
  }

  alert_strategy {
    auto_close = each.value.auto_close_duration
  }

  depends_on = [
    google_project_service.stackdriver_api,
    google_logging_metric.google_custom_metrics
  ]
}
