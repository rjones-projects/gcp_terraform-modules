resource "google_cloud_scheduler_job" "scheduler_job" {
  for_each         = local.cloud_schedulers
  project          = var.project_id
  region           = var.region
  name             = each.value.name
  description      = each.value.description
  schedule         = each.value.schedule
  time_zone        = each.value.time_zone
  attempt_deadline = each.value.attempt_deadline

  http_target {
    uri         = each.value.http_target.uri
    http_method = try(each.value.http_target.http_method, "POST")
    headers     = try(each.value.http_target.headers, {})
    body        = try(base64encode(each.value.http_target.body), null)

    dynamic "oidc_token" {
      for_each = try(each.value.http_target.auth_type, null) == "oidc" && try(each.value.http_target.service_account_email, null) != null ? [1] : []
      content {
        service_account_email = each.value.http_target.service_account_email
      }
    }

    dynamic "oauth_token" {
      for_each = try(each.value.http_target.auth_type, null) == "oauth" && try(each.value.http_target.service_account_email, null) != null ? [1] : []
      content {
        service_account_email = each.value.http_target.service_account_email
      }
    }
  }

  dynamic "retry_config" {
    for_each = each.value.retry_config != {} ? [""] : []
    content {
      retry_count          = try(each.value.retry_config.retry_count, 0)
      min_backoff_duration = try(each.value.retry_config.min_backoff_duration, "PT1S")
      max_backoff_duration = try(each.value.retry_config.max_backoff_duration, "PT10s")
      max_doublings        = try(each.value.retry_config.max_doublings, 10)
    }
  }
}