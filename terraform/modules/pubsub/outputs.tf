output "topic_ids" {
  description = "Map of fully qualified topic IDs keyed by topic name."
  value = {
    for k, topic in google_pubsub_topic.topic : k => topic.id
  }
}

output "topic_names" {
  description = "List of created topic names."
  value       = [for topic in google_pubsub_topic.topic : topic.name]
}

output "subscription_ids" {
  description = "Map of fully qualified subscription IDs keyed by topic/subscription key."
  value = {
    for k, sub in google_pubsub_subscription.subscription : k => sub.id
  }
}

output "schema_ids" {
  description = "Map of created schema IDs keyed by topic name."
  value = {
    for k, schema in google_pubsub_schema.schema : k => schema.id
  }
}

output "bucket_notification_ids" {
  description = "Map of created Cloud Storage notification IDs keyed by topic/index."
  value = {
    for k, notification in google_storage_notification.bucket_uploads : k => notification.id
  }
}
