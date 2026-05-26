module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_storage_bucket" "bucket" {
  project = var.project_id

  for_each      = local.bucket_map
  name          = each.value.bucket_name
  storage_class = each.value.storage_class
  location      = each.value.location
  # checkov:skip=CKV_GCP_29:Ensure that Cloud Storage buckets have uniform bucket-level access enabled
  uniform_bucket_level_access = each.value.uniform_bucket_level_access
  public_access_prevention    = "enforced"

  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.bucket_name}"],
    {}
  )

  # checkov:skip=CKV_GCP_78:Ensure Cloud storage has versioning enabled
  versioning {
    enabled = each.value.versioning_enabled
  }

  dynamic "encryption" {
    for_each = each.value.kms_key_name != null ? [1] : []
    content {
      default_kms_key_name = each.value.kms_key_name
    }
  }

  dynamic "lifecycle_rule" {
    for_each = (
      each.value.lifecycle_rules != null ? {
        for idx, rule in each.value.lifecycle_rules : idx => jsonencode(rule)
      } : {}
    )
    content {
      action {
        type          = lookup(jsondecode(lifecycle_rule.value).action, "type", null)
        storage_class = lookup(jsondecode(lifecycle_rule.value).action, "storage_class", null)
      }
      condition {
        age                   = lookup(jsondecode(lifecycle_rule.value).condition, "age", null)
        created_before        = lookup(jsondecode(lifecycle_rule.value).condition, "created_before", null)
        with_state            = lookup(jsondecode(lifecycle_rule.value).condition, "with_state", null)
        matches_storage_class = lookup(jsondecode(lifecycle_rule.value).condition, "matches_storage_class", null)
        num_newer_versions    = lookup(jsondecode(lifecycle_rule.value).condition, "num_newer_versions", null)
      }
    }
  }

  # VF 
  dynamic "retention_policy" {
    for_each = each.value.retention_policy != null ? tolist([each.value.retention_policy]) : []
    content {
      is_locked        = try(each.value.retention_policy.is_locked, false)
      retention_period = each.value.retention_policy.retention_period
    }
  }

  # logging 
  dynamic "logging" {
    for_each = each.value.logging != null ? tolist([each.value.logging]) : []
    content {
      log_bucket        = each.value.logging.log_bucket
      log_object_prefix = try(each.value.logging.log_object_prefix, null)
    }
  }

  # autoclass
  autoclass {
    enabled = each.value.autoclass
  }



}


resource "google_storage_bucket_object" "objects_to_upload" {

  for_each       = { for obj in local.objects_map : obj.combined_key => obj }
  bucket         = each.value.object_bucket_id
  name           = each.value.object_name
  source         = each.value.object_source
  detect_md5hash = each.value.object_hash
  depends_on     = [google_storage_bucket.bucket]
}

# iam bindings for individual bucket set in accesses
resource "google_storage_bucket_iam_binding" "accesses_iam_bindings" {
  for_each   = local.accesses_iam_bindings
  bucket     = each.value.bucket_id
  role       = each.value.role
  members    = each.value.members
  depends_on = [google_storage_bucket.bucket]
}

# iam binding for all buckets (authoratative)
resource "google_storage_bucket_iam_binding" "iam_bindings" {
  for_each = local.iam_bindings_map
  bucket   = each.value.bucket_id
  role     = each.value.role
  members  = each.value.members
  dynamic "condition" {
    for_each = each.value.condition == null ? [] : each.value.condition
    content {
      expression  = condition.value.expression
      title       = condition.value.title
      description = condition.value.description
    }
  }
  depends_on = [google_storage_bucket.bucket]
}

# iam binding for all buckets (additive)
resource "google_storage_bucket_iam_member" "iam_bindings_additive" {
  for_each = local.iam_bindings_additive_map
  bucket   = each.value.bucket_id
  role     = each.value.role
  member   = each.value.member
  dynamic "condition" {
    for_each = each.value.condition == null ? [] : each.value.condition
    content {
      expression  = condition.value.expression
      title       = condition.value.title
      description = condition.value.description
    }
  }
  depends_on = [google_storage_bucket.bucket]
}
