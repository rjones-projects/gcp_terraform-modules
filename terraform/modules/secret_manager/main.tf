resource "google_project_service" "secret_manager_api" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "this" {
  for_each    = local.secrets
  project     = var.project_id
  secret_id   = each.key
  labels      = each.value.labels
  expire_time = each.value.expire_time
  ttl         = each.value.ttl

  replication {
    dynamic "auto" {
      for_each = each.value.replication_automatic ? [1] : []
      content {
        dynamic "customer_managed_encryption" {
          for_each = each.value.kms_key_name != null ? [1] : []
          content {
            kms_key_name = each.value.kms_key_name
          }
        }
      }
    }

    dynamic "user_managed" {
      for_each = each.value.replication_automatic ? [] : [1]
      content {
        dynamic "replicas" {
          for_each = each.value.replicas
          content {
            location = replicas.value.location
            dynamic "customer_managed_encryption" {
              for_each = replicas.value.customer_managed_encryption != null ? [1] : []
              content {
                kms_key_name = replicas.value.customer_managed_encryption
              }
            }
          }
        }
      }
    }
  }

  dynamic "rotation" {
    for_each = each.value.rotation == null ? [] : [each.value.rotation]
    content {
      next_rotation_time = try(rotation.value.next_rotation_time, null)
      rotation_period    = try(rotation.value.rotation_period, null)
    }
  }

  dynamic "topics" {
    for_each = toset(each.value.topics)
    content {
      name = topics.value
    }
  }

  depends_on = [google_project_service.secret_manager_api]
}

resource "random_password" "generated" {
  for_each = {
    for secret_id, cfg in local.secrets : secret_id => cfg
    if cfg.generate_random_password
  }

  length           = each.value.random_password_length
  special          = each.value.random_password_special
  override_special = each.value.random_password_override_special
}

resource "google_secret_manager_secret_version" "this" {
  for_each    = local.version_payload
  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = each.value
}

resource "google_secret_manager_secret_iam_binding" "accessor_binding" {
  for_each = {
    for secret_id, cfg in local.secrets : secret_id => cfg
    if cfg.create_binding && length(cfg.members) > 0
  }

  project   = var.project_id
  secret_id = google_secret_manager_secret.this[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  members   = each.value.members
}

resource "google_secret_manager_secret_iam_member" "member" {
  for_each = local.iam_member_pairs

  project   = var.project_id
  secret_id = google_secret_manager_secret.this[each.value.secret_id].secret_id
  role      = each.value.role
  member    = each.value.member
}
