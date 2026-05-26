module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_cloudfunctions2_function" "function" {
  # checkov:skip=CKV_GCP_124:Ensure GCP Cloud Function is not configured with overly permissive Ingress setting
  for_each     = local.function_map
  provider     = google-beta
  project      = var.project_id
  depends_on   = [module.finops_labels]
  location     = each.value.location
  name         = "${each.value.prefix}-${each.value.name}"
  description  = each.value.description
  kms_key_name = each.value.kms_key == null ? null : each.value.kms_key
  build_config {
    service_account       = each.value.build_service_account
    worker_pool           = each.value.build_worker_pool
    runtime               = try(each.value.function_config.runtime, "python310")
    entry_point           = try(each.value.function_config.entry_point, "main")
    environment_variables = each.value.build_environment_variables
    docker_repository     = each.value.docker_repository_id
    source {
      storage_source {
        bucket = each.value.bucket_name
        object = (
          each.value.bundle_type == "gcs"
          ? replace(each.value.bundle_path, "/^gs:\\/\\/[^\\/]+\\//", "")
          : each.value.bundle_name
        )
      }
    }
  }
  dynamic "event_trigger" {
    for_each = each.value.trigger_config == null ? [] : [""]

    content {
      event_type   = try(each.value.trigger_config.event_type, null)
      pubsub_topic = try(each.value.trigger_config.pubsub_topic, null)
      trigger_region = (
        try(each.value.trigger_config.region, null) == null
        ? var.region
        : each.value.trigger_config.region
      )
      dynamic "event_filters" {
        for_each = try(each.value.trigger_config.event_filters, null) == null ? [] : each.value.trigger_config.event_filters
        iterator = event_filter
        content {
          attribute = event_filter.value.attribute
          value     = event_filter.value.value
          operator  = try(event_filter.value.operator, null)
        }
      }
      service_account_email = each.value.trigger_config.trigger_service_account_email
      retry_policy          = try(each.value.trigger_config.retry_policy, "RETRY_POLICY_DO_NOT_RETRY")
    }
  }
  service_config {
    all_traffic_on_latest_revision = true
    available_cpu                  = try(each.value.function_config.cpu, "0.166")
    available_memory               = "${try(each.value.function_config.memory_mb, 256)}M"
    binary_authorization_policy    = try(each.value.function_config.binary_authorization_policy, null)
    environment_variables          = each.value.environment_variables
    ingress_settings               = each.value.ingress_settings
    max_instance_count             = try(each.value.function_config.instance_count, 1)
    min_instance_count             = 0
    service_account_email          = each.value.service_account_email
    timeout_seconds                = try(each.value.function_config.timeout_seconds, 180)
    vpc_connector                  = each.value.vpc_connector.name
    vpc_connector_egress_settings  = each.value.vpc_connector.egress_settings
    direct_vpc_egress              = try(each.value.direct_vpc_egress.mode, null)

    dynamic "direct_vpc_network_interface" {
      for_each = each.value.direct_vpc_egress == null ? [] : [""]
      content {
        network    = each.value.direct_vpc_egress.network
        subnetwork = each.value.direct_vpc_egress.subnetwork
        tags       = try(each.value.direct_vpc_egress.tags, [])
      }
    }

    dynamic "secret_environment_variables" {
      for_each = { for k, v in each.value.secrets : k => v if !v.is_volume }
      iterator = secret
      content {
        key        = secret.key
        project_id = var.project_id
        secret     = secret.value.secret
        version    = try(secret.value.versions[0], "latest")
      }
    }

    dynamic "secret_volumes" {
      for_each = { for k, v in each.value.secrets : k => v if v.is_volume }
      iterator = secret
      content {
        mount_path = secret.key
        project_id = var.project_id
        secret     = secret.value.secret
        dynamic "versions" {
          for_each = secret.value.versions
          iterator = version
          content {
            path    = split(":", version.value)[1]
            version = split(":", version.value)[0]
          }
        }
      }
    }
  }
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )
}

resource "google_cloudfunctions2_function_iam_binding" "binding" {
  for_each = {
    for item in flatten([
      for f_key, f_val in local.function_map : [
        for iam_key, iam_val in try(f_val.iam, {}) : {
          f_key    = f_key
          iam_key  = iam_key
          iam_val  = iam_val
          location = f_val.location
        }
      ]
    ]) : "${item.f_key}.${item.iam_key}" => item if item.iam_key != "roles/run.invoker"
  }
  project        = var.project_id
  depends_on     = [google_cloudfunctions2_function.function]
  location       = each.value.location
  cloud_function = google_cloudfunctions2_function.function[each.value.f_key].name
  role           = each.value.iam_key
  members = distinct(concat(
    [for group in lookup(each.value.iam_val, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.iam_val, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.iam_val, "special_groups", []) : sp],
  [for user in lookup(each.value.iam_val, "users", []) : "user:${user}"]))
  lifecycle {
    replace_triggered_by = [google_cloudfunctions2_function.function]
  }
}


resource "google_cloud_run_service_iam_binding" "invoker" {
  # cloud run resources are needed for invoker role to the underlying service

  for_each = { for k, v in local.function_map : k => { location = v.location
    invoker_data = lookup(try(v.iam, {}), "roles/run.invoker", null)
    }
    if lookup(try(v.iam, {}), "roles/run.invoker", null) != null
  }
  project    = var.project_id
  depends_on = [google_cloudfunctions2_function.function]
  location   = each.value.location
  service    = google_cloudfunctions2_function.function[each.key].name
  role       = "roles/run.invoker"
  members = distinct(concat(
    [for group in lookup(each.value.invoker_data, "groups", []) : "group:${group}"],
    [for sa in lookup(each.value.invoker_data, "service_accounts", []) : "serviceAccount:${sa}"],
    [for sp in lookup(each.value.invoker_data, "special_groups", []) : sp],
    [for user in lookup(each.value.invoker_data, "users", []) : "user:${user}"]
  ))
  lifecycle {
    replace_triggered_by = [google_cloudfunctions2_function.function]
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  # if authoritative invoker role is not present and we create trigger sa
  # use additive binding to grant it the role

  for_each = local.function_map


  project    = var.project_id
  depends_on = [google_cloudfunctions2_function.function]
  location   = each.value.location
  service    = google_cloudfunctions2_function.function[each.key].name
  role       = "roles/run.invoker"
  member     = "serviceAccount:${each.value.trigger_config.trigger_service_account_email}"
  lifecycle {
    replace_triggered_by = [google_cloudfunctions2_function.function]
  }
}
