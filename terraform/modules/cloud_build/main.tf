resource "google_cloudbuildv2_connection" "connection" {
  count       = local.cloud_build_object.connection_create ? 1 : 0
  location    = try(local.cloud_build_object.location, var.region)
  project     = var.project_id
  name        = local.cloud_build_object.name
  annotations = local.cloud_build_object.annotations
  disabled    = local.cloud_build_object.disabled

  dynamic "github_config" {
    for_each = try(local.cloud_build_object.connection_config.github == null ? [] : [""], [])
    content {
      app_installation_id = try(local.cloud_build_object.connection_config.github.app_installation_id, null)
      authorizer_credential {
        oauth_token_secret_version = try(local.cloud_build_object.connection_config.github.authorizer_credential_secret_version, null)
      }
    }
  }

  dynamic "github_enterprise_config" {
    for_each = try(local.cloud_build_object.connection_config.github_enterprise == null ? [] : [""], [])
    content {
      host_uri                      = try(local.cloud_build_object.connection_config.github_enterprise.host_uri, null)
      app_id                        = try(local.cloud_build_object.connection_config.github_enterprise.app_id, null)
      app_slug                      = try(local.cloud_build_object.connection_config.github_enterprise.app_slug, null)
      app_installation_id           = try(local.cloud_build_object.connection_config.github_enterprise.app_installation_id, null)
      private_key_secret_version    = try(local.cloud_build_object.connection_config.github_enterprise.private_key_secret_version, null)
      webhook_secret_secret_version = try(local.cloud_build_object.connection_config.github_enterprise.webhook_secret_secret_version, null)
      ssl_ca                        = try(local.cloud_build_object.connection_config.github_enterprise.ssl_ca, null)
      dynamic "service_directory_config" {
        for_each = try(local.cloud_build_object.connection_config.github_enterprise.service, [])
        content {
          service = try(local.cloud_build_object.connection_config.github_enterprise.service, null)
        }
      }
    }
  }
}

resource "google_cloudbuildv2_repository" "repositories" {
  for_each          = local.cloud_build_object.repositories
  name              = each.key
  project           = var.project_id
  location          = local.cloud_build_object.location
  parent_connection = local.cloud_build_object.name
  remote_uri        = each.value.remote_uri
  annotations       = try(each.value.annotations, {})
}

resource "google_cloudbuild_trigger" "triggers" {
  for_each    = try(local.triggers, {})
  location    = local.cloud_build_object.location
  name        = each.key
  project     = var.project_id
  description = try(each.value.description, null)
  disabled    = try(each.value.disabled, false)
  repository_event_config {
    repository = google_cloudbuildv2_repository.repositories[each.value.repository_name].id
    dynamic "push" {
      for_each = try(each.value.push, null) == null ? [] : [""]
      content {
        branch       = try(each.value.push.branch, null)
        invert_regex = try(each.value.push.invert_regex, null)
        tag          = try(each.value.push.tag, null)
      }
    }
    dynamic "pull_request" {
      for_each = try(each.value.pull_request, null) == null ? [] : [""]
      content {
        branch          = try(each.value.pull_request.branch, null)
        invert_regex    = try(each.value.pull_request.invert_regex, null)
        comment_control = try(each.value.pull_request.comment_control, null)
      }
    }
  }
  include_build_logs = try(each.value.include_build_logs, null)
  tags               = try(each.value.tags, null)
  substitutions      = try(each.value.substitutions, null)
  service_account    = try(each.value.service_account, null)
  filename           = try(each.value.filename, null)
}
