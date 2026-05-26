module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

data "google_kms_key_ring" "default" {
  count    = local.keyring_create ? 0 : 1
  project  = local.project_id
  name     = local.keyring_input.name
  location = local.keyring_location
}

resource "google_kms_key_ring" "default" {
  count    = local.keyring_create ? 1 : 0
  project  = local.project_id
  name     = local.keyring_input.name
  location = local.keyring_location

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "default" {
  # checkov:skip=CKV_GCP_43:Rotation period managed via variables or external policy

  for_each                   = local.keys
  key_ring                   = local.keyring.id
  name                       = each.key
  destroy_scheduled_duration = each.value.destroy_scheduled_duration
  rotation_period            = each.value.rotation_period
  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.key}"],
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
  count            = local.import_job != null ? 1 : 0
  key_ring         = local.keyring.id
  import_job_id    = local.import_job.id
  import_method    = local.import_job.import_method
  protection_level = local.import_job.protection_level
}
