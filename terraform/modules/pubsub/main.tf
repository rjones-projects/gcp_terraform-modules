module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

data "google_storage_project_service_account" "storage_sa" {
  count   = length(local.topic_notification_pubsub_publishers) > 0 ? 1 : 0
  project = var.project_id
}

resource "google_pubsub_schema" "schema" {
  for_each = local.schema_topics

  project    = var.project_id
  name       = "${each.key}-schema"
  type       = each.value.schema.schema_type
  definition = each.value.schema.definition
}

resource "google_pubsub_topic" "topic" {
  for_each = local.topic_map

  project                    = var.project_id
  name                       = each.key
  kms_key_name               = each.value.kms_key_name
  message_retention_duration = each.value.message_retention_duration
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.topic_name}"],
    {}
  )

  dynamic "message_storage_policy" {
    for_each = length(each.value.regions) > 0 ? [1] : []
    content {
      allowed_persistence_regions = each.value.regions
    }
  }

  dynamic "schema_settings" {
    for_each = each.value.schema == null ? [] : [1]
    content {
      schema   = google_pubsub_schema.schema[each.key].id
      encoding = try(each.value.schema.msg_encoding, "ENCODING_UNSPECIFIED")
    }
  }
}

resource "google_pubsub_topic_iam_member" "storage_notification_publisher" {
  for_each = local.topic_notification_pubsub_publishers

  project = var.project_id
  topic   = google_pubsub_topic.topic[each.key].name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.storage_sa[0].email_address}"
}

resource "google_storage_notification" "bucket_uploads" {
  for_each = local.topic_notification_map

  bucket             = each.value.bucket
  topic              = google_pubsub_topic.topic[each.value.topic_name].id
  payload_format     = each.value.payload_format
  event_types        = try(each.value.event_types, null)
  object_name_prefix = try(each.value.object_name_prefix, null)
  custom_attributes  = try(each.value.custom_attributes, null)

  depends_on = [
    google_pubsub_topic_iam_member.storage_notification_publisher
  ]
}

resource "google_pubsub_subscription" "subscription" {
  for_each = local.subscription_map

  project                      = var.project_id
  name                         = each.value.subscription_name
  topic                        = google_pubsub_topic.topic[each.value.topic_name].name
  ack_deadline_seconds         = each.value.ack_deadline_seconds
  message_retention_duration   = each.value.message_retention_duration
  retain_acked_messages        = each.value.retain_acked_messages
  filter                       = each.value.filter
  enable_message_ordering      = each.value.enable_message_ordering
  enable_exactly_once_delivery = each.value.enable_exactly_once_delivery
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.topic_name}/${each.value.subscription_name}"],
    try(module.finops_labels.labels["${each.value.topic_finops_resource_type}/${each.value.topic_name}"], {})
  )

  dynamic "bigquery_config" {
    for_each = each.value.bigquery == null ? [] : [1]
    content {
      table                 = each.value.bigquery.table
      use_table_schema      = try(each.value.bigquery.use_table_schema, false)
      use_topic_schema      = try(each.value.bigquery.use_topic_schema, false)
      write_metadata        = try(each.value.bigquery.write_metadata, false)
      drop_unknown_fields   = try(each.value.bigquery.drop_unknown_fields, false)
      service_account_email = try(each.value.bigquery.service_account_email, null)
    }
  }

  dynamic "cloud_storage_config" {
    for_each = each.value.cloud_storage == null ? [] : [1]
    content {
      bucket          = each.value.cloud_storage.bucket
      filename_prefix = try(each.value.cloud_storage.filename_prefix, null)
      filename_suffix = try(each.value.cloud_storage.filename_suffix, null)
      max_duration    = try(each.value.cloud_storage.max_duration, null)
      max_bytes       = try(each.value.cloud_storage.max_bytes, null)
      dynamic "avro_config" {
        for_each = try(each.value.cloud_storage.avro_config, null) == null ? [] : [1]
        content {
          write_metadata = try(each.value.cloud_storage.avro_config.write_metadata, false)
        }
      }
    }
  }

  dynamic "dead_letter_policy" {
    for_each = each.value.dead_letter_policy == null ? [] : [1]
    content {
      dead_letter_topic     = each.value.dead_letter_policy.topic
      max_delivery_attempts = try(each.value.dead_letter_policy.max_delivery_attempts, null)
    }
  }

  dynamic "expiration_policy" {
    for_each = each.value.expiration_policy_ttl == null ? [] : [1]
    content {
      ttl = each.value.expiration_policy_ttl
    }
  }

  dynamic "push_config" {
    for_each = each.value.push == null ? [] : [1]
    content {
      push_endpoint = each.value.push.endpoint
      attributes    = try(each.value.push.attributes, null)

      dynamic "no_wrapper" {
        for_each = try(each.value.push.no_wrapper, null) == null ? [] : [1]
        content {
          write_metadata = try(each.value.push.no_wrapper.write_metadata, false)
        }
      }

      dynamic "oidc_token" {
        for_each = try(each.value.push.oidc_token, null) == null ? [] : [1]
        content {
          service_account_email = each.value.push.oidc_token.service_account_email
          audience              = try(each.value.push.oidc_token.audience, null)
        }
      }
    }
  }

  dynamic "retry_policy" {
    for_each = each.value.retry_policy == null ? [] : [1]
    content {
      maximum_backoff = (
        try(each.value.retry_policy.maximum_backoff, null) != null
        ? "${each.value.retry_policy.maximum_backoff}s"
        : null
      )
      minimum_backoff = (
        try(each.value.retry_policy.minimum_backoff, null) != null
        ? "${each.value.retry_policy.minimum_backoff}s"
        : null
      )
    }
  }
}
