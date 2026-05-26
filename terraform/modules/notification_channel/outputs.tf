output "notification_channels" {
  description = "Map of created notification channel resources."
  value       = google_monitoring_notification_channel.notification_channel
}

output "notification_channel_ids" {
  description = "Map of channel keys to their fully qualified server-generated IDs (useful for referencing in alert policies)."
  value = {
    for k, v in google_monitoring_notification_channel.notification_channel :
    k => v.name
  }
}
