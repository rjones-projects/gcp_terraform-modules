resource "google_artifact_registry_repository" "registry" {
  provider               = google-beta
  project                = var.project_id
  for_each               = local.registry_map
  location               = try(each.value.location, var.region)
  description            = each.value.description
  format                 = upper(each.value.format_string)
  repository_id          = each.value.name
  mode                   = "${upper(each.value.mode_string)}_REPOSITORY"
  kms_key_name           = each.value.encryption_key
  cleanup_policy_dry_run = each.value.cleanup_policy_dry_run
  labels                 = each.value.labels

  vulnerability_scanning_config {
    enablement_config = (
      each.value.enable_vulnerability_scanning == true
      ? "INHERITED"
      : each.value.enable_vulnerability_scanning == false ? "DISABLED" : null
    )
  }

  dynamic "cleanup_policies" {
    for_each = each.value.cleanup_policies
    content {
      id     = cleanup_policies.key
      action = cleanup_policies.value.action
      dynamic "condition" {
        for_each = (lookup(cleanup_policies.value, "condition", null) != null) ? [""] : []
        content {
          tag_state             = lookup(cleanup_policies.value.condition, "tag_state", null)
          tag_prefixes          = lookup(cleanup_policies.value.condition, "tag_prefixes", null)
          version_name_prefixes = lookup(cleanup_policies.value.condition, "version_name_prefixes", null)
          package_name_prefixes = lookup(cleanup_policies.value.condition, "package_name_prefixes", null)
          newer_than            = lookup(cleanup_policies.value.condition, "newer_than", null)
          older_than            = lookup(cleanup_policies.value.condition, "older_than", null)
        }
      }

      dynamic "most_recent_versions" {
        for_each = (lookup(cleanup_policies.value, "most_recent_versions", null) != null) ? [""] : []
        content {
          package_name_prefixes = lookup(cleanup_policies.value.most_recent_versions, "package_name_prefixes", null)
          keep_count            = lookup(cleanup_policies.value.most_recent_versions, "keep_count", null)
        }
      }
    }
  }

  dynamic "docker_config" {
    for_each = (
      each.value.format_string == "docker" && try(each.value.format_obj.standard.immutable_tags, null) != null
      ? [""] : []
    )
    content {
      immutable_tags = each.value.format_obj.standard.immutable_tags
    }
  }

  dynamic "maven_config" {
    for_each = each.value.format_string == "maven" ? [""] : []
    content {
      allow_snapshot_overwrites = try(each.value.format_obj.standard.allow_snapshot_overwrites, null)
      version_policy            = try(each.value.format_obj.standard.version_policy, null)
    }
  }

  dynamic "remote_repository_config" {
    for_each = each.value.mode_string == "remote" ? [""] : []
    content {
      disable_upstream_validation = each.value.format_obj.remote.disable_upstream_validation
      dynamic "upstream_credentials" {
        for_each = each.value.format_obj.remote.upstream_credentials != null ? [""] : []
        content {
          username_password_credentials {
            username                = each.value.format_obj.remote.upstream_credentials.username
            password_secret_version = each.value.format_obj.remote.upstream_credentials.password_secret_version
          }
        }
      }
      dynamic "apt_repository" {
        for_each = each.value.format_string == "apt" ? [""] : []
        content {
          public_repository {
            repository_base = split(" ", each.value.format_obj.remote.public_repository)[0]
            repository_path = split(" ", each.value.format_obj.remote.public_repository)[1]
          }
        }
      }
      dynamic "common_repository" {
        for_each = (
          each.value.format_string == "docker" && try(each.value.format_obj.remote.common_repository, null) != null
          ? [""] : []
        )
        content {
          uri = each.value.format_obj.remote.common_repository
        }
      }
      dynamic "docker_repository" {
        for_each = (
          each.value.format_string == "docker" && try(each.value.format_obj.remote.common_repository, null) == null
          ? [""] : []
        )
        content {
          public_repository = each.value.format_obj.remote.public_repository
          dynamic "custom_repository" {
            for_each = each.value.format_obj.remote.custom_repository != null ? [""] : []
            content {
              uri = each.value.format_obj.remote.custom_repository
            }
          }
        }
      }
      dynamic "maven_repository" {
        for_each = each.value.format_string == "maven" ? [""] : []
        content {
          public_repository = each.value.format_obj.remote.public_repository
          dynamic "custom_repository" {
            for_each = each.value.format_obj.remote.custom_repository != null ? [""] : []
            content {
              uri = each.value.format_obj.remote.custom_repository
            }
          }
        }
      }
      dynamic "npm_repository" {
        for_each = each.value.format_string == "npm" ? [""] : []
        content {
          public_repository = each.value.format_obj.remote.public_repository
          dynamic "custom_repository" {
            for_each = each.value.format_obj.remote.custom_repository != null ? [""] : []
            content {
              uri = each.value.format_obj.remote.custom_repository
            }
          }
        }
      }
      dynamic "python_repository" {
        for_each = each.value.format_string == "python" ? [""] : []
        content {
          public_repository = each.value.format_obj.remote.public_repository
          dynamic "custom_repository" {
            for_each = each.value.format_obj.remote.custom_repository != null ? [""] : []
            content {
              uri = each.value.format_obj.remote.custom_repository
            }
          }
        }
      }
      dynamic "yum_repository" {
        for_each = each.value.format_string == "yum" ? [""] : []
        content {
          public_repository {
            repository_base = split(" ", each.value.format_obj.remote.public_repository)[0]
            repository_path = split(" ", each.value.format_obj.remote.public_repository)[1]
          }
        }
      }
    }
  }

  dynamic "virtual_repository_config" {
    for_each = each.value.mode_string == "virtual" ? [""] : []
    content {
      dynamic "upstream_policies" {
        for_each = each.value.format_obj.virtual
        content {
          id         = upstream_policies.key
          repository = upstream_policies.value.repository
          priority   = upstream_policies.value.priority
        }
      }
    }
  }


  lifecycle {
    precondition {
      condition = each.value.mode_string != "remote" || contains(
        ["apt", "docker", "maven", "npm", "python", "yum"], each.value.format_string
      )
      error_message = "Invalid format for remote repository."
    }
  }
}
