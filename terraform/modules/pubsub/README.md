# Pub/Sub Module

Creates Pub/Sub topics and subscriptions from YAML `spec` input, with FinOps labels automatically validated and applied through `finops_labels`.

## What this module manages

- Multiple Pub/Sub topics (`google_pubsub_topic`)
- Optional topic schemas (`google_pubsub_schema`)
- Multiple subscriptions per topic (`google_pubsub_subscription`)
- GCS to Pub/Sub notifications (`google_storage_notification`)
- FinOps labels for both topics and subscriptions

## How to use in `project.yaml`

Declare `finops_labels` and `pubsub`, then pass one or more topic entries in `pubsub.spec`.

```yaml
finops_labels:
  source: "../modules/finops_labels"
  depends_on: []
  spec: []

pubsub:
  source: "../modules/pubsub"
  depends_on:
    - finops_labels
  spec:
    - topic_name: "orders-events"
      finops_resource_type: "pubsub"
      message_retention_duration: "604800s"
      labels:
        vf_ngdi_environment: "alpha"
        vf_ngdi_data_layer: "bronze"
        vf_ngdi_shared: "true"
      notifications:
        - bucket: "your-project-id-terraform-state"
          event_types:
            - "OBJECT_FINALIZE"
          payload_format: "JSON_API_V1"
      subscriptions:
        - name: "orders-events-pull"
          ack_deadline_seconds: 20
          labels:
            vf_ngdi_environment: "alpha"
            vf_ngdi_data_layer: "bronze"
            vf_ngdi_shared: "true"
```

## Input model (`pubsub.spec`)

### Topic fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `topic_name` | string | yes | Topic name. `name` is also accepted as fallback. |
| `kms_key_name` | string | no | CMEK for topic encryption. |
| `message_retention_duration` | string | no | Pub/Sub duration format, e.g. `604800s`. |
| `regions` | list(string) | no | Used for `message_storage_policy.allowed_persistence_regions`. |
| `schema` | object | no | `{ schema_type, definition, msg_encoding? }`. |
| `finops_resource_type` | string | no | Defaults to `pubsub`. |
| `labels` | map(string) | no | FinOps input labels for topic. |
| `notifications` | list(object) | no | Cloud Storage notification configs for this topic. |
| `subscriptions` | list(object) | no | Subscription entries for this topic. |

### Subscription fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `name` | string | yes | Subscription name. |
| `ack_deadline_seconds` | number | no | Pull ack deadline. |
| `message_retention_duration` | string | no | Subscription retention window. |
| `retain_acked_messages` | bool | no | Defaults to `false`. |
| `filter` | string | no | Pub/Sub filter expression. |
| `enable_message_ordering` | bool | no | Defaults to `false`. |
| `enable_exactly_once_delivery` | bool | no | Defaults to `false`. |
| `expiration_policy_ttl` | string | no | Expiration TTL. |
| `bigquery` | object | no | `table`, `use_table_schema`, `use_topic_schema`, `write_metadata`, `drop_unknown_fields`, `service_account_email`. |
| `cloud_storage` | object | no | `bucket`, optional file options, optional `avro_config.write_metadata`. |
| `dead_letter_policy` | object | no | `topic`, optional `max_delivery_attempts`. |
| `push` | object | no | `endpoint`, optional `attributes`, optional `no_wrapper`, optional `oidc_token`. |
| `retry_policy` | object | no | `minimum_backoff`, `maximum_backoff` (seconds). |
| `finops_resource_type` | string | no | Defaults to `pubsub`. |
| `labels` | map(string) | no | If omitted, inherits topic labels. |

### Notification fields

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `bucket` | string | yes | Source GCS bucket name. |
| `event_types` | list(string) | no | Supported: `OBJECT_FINALIZE`, `OBJECT_METADATA_UPDATE`, `OBJECT_DELETE`, `OBJECT_ARCHIVE`. |
| `payload_format` | string | no | Defaults to `JSON_API_V1`. |
| `object_name_prefix` | string | no | Filter by object prefix. |
| `custom_attributes` | map(string) | no | Optional extra attributes. |

## Notification direction

- `notifications` in topic spec configures **GCS -> Pub/Sub** events.
- `subscriptions[].cloud_storage` configures **Pub/Sub -> GCS** delivery.
- These are separate features and can be used independently.

## FinOps requirements

Module behavior:

- Generates FinOps spec entries for each topic and subscription.
- Applies labels from `module.finops_labels.labels[...]`.
- Auto-populates `vf_ngdi_resource_name` from resource name through policy.

For `resource_type: pubsub`, provide these labels to satisfy policy:

- `vf_ngdi_environment` (`alpha`, `beta`, `zeta-nl`, `zeta-live`)
- `vf_ngdi_data_layer` (`bronze`, `silver`, `gold`)
- `vf_ngdi_shared` (`true`, `false`)

Policy defaults include:

- `vf_ngdi_domain = mob`
- `vf_cost_item = ngdi`

## Outputs

- `topic_ids`: map of topic IDs by topic name
- `topic_names`: list of topic names
- `subscription_ids`: map of subscription IDs by `topic/subscription` key
- `schema_ids`: map of schema IDs by topic name
- `bucket_notification_ids`: map of GCS notification IDs by `topic/index` key

## Examples and tests

- Examples:
  - `examples/basic.yaml`
  - `examples/notification.yaml`
  - `examples/multiple_topics.yaml`
- Test sample:
  - `tests/pubsub-basic.yaml`
