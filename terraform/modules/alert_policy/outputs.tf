output "alert_policies" {
  description = "Map of created alert policy resources."
  value       = google_monitoring_alert_policy.google_custom_alerts
}

output "alert_policy_ids" {
  description = "Map of alert names to alert policy IDs."
  value = {
    for name, policy in google_monitoring_alert_policy.google_custom_alerts :
    name => policy.name
  }
}

output "log_metrics" {
  description = "Map of created log based metrics."
  value       = google_logging_metric.google_custom_metrics
}
