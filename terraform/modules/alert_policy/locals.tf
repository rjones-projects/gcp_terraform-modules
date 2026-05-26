locals {
  alerts = {
    for spec in try(var.alert_policy.spec, []) : try(spec.alert_name, spec.name) => {
      alert_name              = try(spec.alert_name, spec.name)
      metric_name             = try(spec.metric_name, var.alert_policy_default.metric_name)
      custom_metric_filter    = try(spec.custom_metric_filter, var.alert_policy_default.custom_metric_filter)
      create_metric           = try(spec.create_metric, var.alert_policy_default.create_metric)
      custom_metric_kind      = try(spec.custom_metric_kind, var.alert_policy_default.custom_metric_kind)
      custom_metric_type      = try(spec.custom_metric_type, var.alert_policy_default.custom_metric_type)
      alert_filter            = try(spec.alert_filter, var.alert_policy_default.alert_filter)
      alert_combiner          = try(spec.alert_combiner, var.alert_policy_default.alert_combiner)
      alert_duration          = try(spec.alert_duration, var.alert_policy_default.alert_duration)
      alert_threshold         = try(spec.alert_threshold, var.alert_policy_default.alert_threshold)
      alert_alignment         = try(spec.alert_alignment, var.alert_policy_default.alert_alignment)
      alert_comparison        = try(spec.alert_comparison, var.alert_policy_default.alert_comparison)
      alert_aligner           = try(spec.alert_aligner, var.alert_policy_default.alert_aligner)
      alert_doc               = try(spec.alert_doc, var.alert_policy_default.alert_doc)
      alert_reducer           = try(spec.alert_reducer, var.alert_policy_default.alert_reducer)
      group_by_fields         = try(spec.group_by_fields, var.alert_policy_default.group_by_fields)
      percent                 = try(spec.percent, var.alert_policy_default.percent)
      trigger_count           = try(spec.trigger_count, var.alert_policy_default.trigger_count)
      evaluation_missing_data = try(spec.evaluation_missing_data, var.alert_policy_default.evaluation_missing_data)
      notification_channels = [
        for nc in try(spec.notification_channels, var.alert_policy_default.notification_channels) :
        startswith(nc, "projects/") ? nc : try(data.google_monitoring_notification_channel.by_name[nc].name, nc)
      ]
      auto_close_duration  = try(spec.auto_close_duration, var.alert_policy_default.auto_close_duration)
      finops_resource_type = coalesce(try(spec.finops_resource_type, null), "alert_policy")
      labels               = try(spec.labels, {})
    }
  }

  finops_specs = [
    for alert in local.alerts : {
      resource_type = alert.finops_resource_type
      name          = "${alert.finops_resource_type}/${alert.alert_name}"
      resource_name = alert.alert_name
      input_labels  = alert.labels
    }
  ]
}
