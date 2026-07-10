locals {
  key_iam = flatten([
    for ck, v in local.crypto_keys_unified : [
      for role, members in v.iam : {
        key     = ck
        role    = role
        members = members
      }
    ]
  ])
  key_iam_bindings = merge([
    for ck, v in local.crypto_keys_unified : {
      for binding_key, data in v.iam_bindings :
      (local.multi_keyring_mode ? "${ck}/${binding_key}" : binding_key) => {
        key       = ck
        role      = data.role
        members   = data.members
        condition = data.condition
      }
    }
  ]...)
  key_iam_bindings_additive = merge([
    for ck, v in local.crypto_keys_unified : {
      for binding_key, data in v.iam_bindings_additive :
      (local.multi_keyring_mode ? "${ck}/${binding_key}" : binding_key) => {
        key       = ck
        role      = data.role
        member    = data.member
        condition = data.condition
      }
    }
  ]...)
}

resource "google_kms_key_ring_iam_binding" "authoritative" {
  for_each    = local.keyring_iam_authoritative
  key_ring_id = local.keyring_by_key[each.value.keyring_key].id
  role        = each.value.role
  members     = each.value.members
}

resource "google_kms_key_ring_iam_binding" "bindings" {
  for_each    = local.keyring_iam_bindings
  key_ring_id = local.keyring_by_key[each.value.keyring_key].id
  role        = each.value.role
  members     = each.value.members
  dynamic "condition" {
    for_each = try(each.value.condition, null) == null ? [] : [""]
    content {
      expression  = try(each.value.condition.expression, null)
      title       = try(each.value.condition.title, null)
      description = try(each.value.condition.description, null)
    }
  }
}

resource "google_kms_key_ring_iam_member" "bindings" {
  for_each    = local.keyring_iam_bindings_additive
  key_ring_id = local.keyring_by_key[each.value.keyring_key].id
  role        = each.value.role
  member      = each.value.member
  dynamic "condition" {
    for_each = try(each.value.condition, null) == null ? [] : [""]
    content {
      expression  = try(each.value.condition.expression, null)
      title       = try(each.value.condition.title, null)
      description = try(each.value.condition.description, null)
    }
  }
}

resource "google_kms_crypto_key_iam_binding" "authoritative" {
  for_each = {
    for binding in local.key_iam :
    "${binding.key}.${binding.role}" => binding
  }
  role          = each.value.role
  crypto_key_id = google_kms_crypto_key.default[each.value.key].id
  members       = each.value.members
}

resource "google_kms_crypto_key_iam_binding" "bindings" {
  for_each      = local.key_iam_bindings
  role          = each.value.role
  crypto_key_id = google_kms_crypto_key.default[each.value.key].id
  members       = each.value.members
  dynamic "condition" {
    for_each = try(each.value.condition, null) == null ? [] : [""]
    content {
      expression  = try(each.value.condition.expression, null)
      title       = try(each.value.condition.title, null)
      description = try(each.value.condition.description, null)
    }
  }
}

resource "google_kms_crypto_key_iam_member" "members" {
  for_each      = local.key_iam_bindings_additive
  crypto_key_id = google_kms_crypto_key.default[each.value.key].id
  role          = each.value.role
  member        = each.value.member
  dynamic "condition" {
    for_each = try(each.value.condition, null) == null ? [] : [""]
    content {
      expression  = try(each.value.condition.expression, null)
      title       = try(each.value.condition.title, null)
      description = try(each.value.condition.description, null)
    }
  }
}
