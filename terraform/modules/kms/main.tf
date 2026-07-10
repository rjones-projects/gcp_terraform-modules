module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

data "google_kms_key_ring" "default" {
  count = (
    !local.multi_keyring_mode
    && local.single_keyring_spec != null
    && !local.single_keyring_spec.keyring_create
  ) ? 1 : 0

  project  = local.project_id
  name     = local.keyring_input.name
  location = local.keyring_location
}

resource "google_kms_key_ring" "default" {
  count = (
    !local.multi_keyring_mode
    && local.single_keyring_spec != null
    && local.single_keyring_spec.keyring_create
  ) ? 1 : 0

  project  = local.project_id
  name     = local.keyring_input.name
  location = local.keyring_location

  lifecycle {
    prevent_destroy = true
  }
}

data "google_kms_key_ring" "keyrings" {
  for_each = {
    for keyring_key, keyring_spec in local.keyring_specs :
    keyring_key => keyring_spec
    if local.multi_keyring_mode && !keyring_spec.keyring_create
  }

  project  = local.project_id
  name     = each.value.name
  location = each.value.location
}

resource "google_kms_key_ring" "keyrings" {
  for_each = {
    for keyring_key, keyring_spec in local.keyring_specs :
    keyring_key => keyring_spec
    if local.multi_keyring_mode && keyring_spec.keyring_create
  }

  project  = local.project_id
  name     = each.value.name
  location = each.value.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "default" {
  # checkov:skip=CKV_GCP_43:Rotation period managed via variables or external policy

  for_each                   = local.crypto_keys_unified
  key_ring                   = local.keyring_by_key[each.value.keyring_key].id
  name                       = each.value.key_name
  destroy_scheduled_duration = each.value.destroy_scheduled_duration
  rotation_period            = each.value.rotation_period
  labels = try(
    module.finops_labels.labels[each.value.finops_label_key],
    {}
  )
  purpose                       = each.value.purpose
  skip_initial_version_creation = each.value.skip_initial_version_creation

  dynamic "version_template" {
    for_each = each.value.version_template == null ? [] : [""]
    content {
      algorithm        = each.value.version_template.algorithm
      protection_level = each.value.version_template.protection_level
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_key_ring_import_job" "default" {
  count = (
    !local.multi_keyring_mode
    && local.import_job != null
  ) ? 1 : 0

  key_ring         = local.keyring.id
  import_job_id    = local.import_job.id
  import_method    = local.import_job.import_method
  protection_level = local.import_job.protection_level
}

resource "google_kms_key_ring_import_job" "keyrings" {
  for_each = local.multi_keyring_mode ? local.import_jobs : {}

  key_ring         = local.keyring_by_key[each.key].id
  import_job_id    = each.value.id
  import_method    = each.value.import_method
  protection_level = each.value.protection_level
}
