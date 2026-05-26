locals {

  buckets = [
    for item in try(var.gcs.spec, []) : {
      bucket_name                 = try(item.bucket_name, item.name)
      location                    = try(item.location, var.region)
      storage_class               = try(item.storage_class, var.bucket_default.storage_class)
      uniform_bucket_level_access = try(item.uniform_bucket_level_access, var.bucket_default.uniform_bucket_level_access)
      kms_key_name                = try(item.kms_key_name, var.bucket_default.kms_key_name)
      finops_resource_type        = coalesce(try(item.finops_resource_type, null), "gcs_bucket")
      labels                      = try(item.labels, {})
      versioning_enabled          = try(item.versioning_enabled, item.versioning, var.bucket_default.versioning_enabled)
      accesses = length(try(item.accesses, var.bucket_default.accesses)) > 0 ? item.accesses : [
        for role, members in try(item.iam, {}) : {
          role    = role
          members = members
        }
      ]
      retention_policy      = try(item.retention_policy, var.bucket_default.retention_policy)
      logging               = try(item.logging, var.bucket_default.logging)
      lifecycle_rules       = try(item.lifecycle_rules, var.bucket_default.lifecycle_rules)
      autoclass             = length(try(item.lifecycle_rules, [])) > 0 ? false : try(item.autoclass, var.bucket_default.autoclass)
      iam_bindings          = try(item.iam_bindings, var.bucket_default.iam_bindings)
      iam_bindings_additive = try(item.iam_bindings_additive, var.bucket_default.iam_bindings_additive)
      objects_to_upload     = try(item.objects_to_upload, var.bucket_default.objects_to_upload)

    }
  ]

  bucket_map = { for bucket in local.buckets : bucket.bucket_name => bucket }

  finops_specs = [
    for bucket in local.buckets : {
      resource_type = bucket.finops_resource_type
      name          = "${bucket.finops_resource_type}/${bucket.bucket_name}"
      resource_name = bucket.bucket_name
      input_labels  = bucket.labels
    }
  ]

  # Group IAM bindings by bucket and role for creating IAM resources bucket_iam_bindings
  accesses_iam_bindings = {
    for binding in flatten([
      for bucket in local.buckets : [
        for role_access in bucket.accesses : {
          key       = "${bucket.bucket_name}-${role_access.role}"
          bucket_id = bucket.bucket_name
          role      = role_access.role
          members   = role_access.members
        }
      ]
      ]) : binding.key => {
      bucket_id = binding.bucket_id
      role      = binding.role
      members   = binding.members
    }
  }

  iam_bindings_map = {
    for entry in flatten([
      for b_key, b_val in local.buckets : [
        for iam_val in b_val.iam_bindings : [
          for k, v in iam_val : {
            # for memb in v.members : {
            unique_key = "${b_val.bucket_name}-${k}-${v.role}"
            bucket_id  = b_val.bucket_name
            role       = v.role
            members    = v.members
            condition  = try(v.condition, [])
            # } 
          }
        ]
      ]
      ]) : entry.unique_key => {
      bucket_id = entry.bucket_id
      role      = entry.role
      members   = entry.members
      condition = entry.condition
    }
  }

  iam_bindings_additive_map = {
    for entry in flatten([
      for b_key, b_val in local.buckets : [
        for iam_val in b_val.iam_bindings_additive : [
          for k, v in iam_val : {
            unique_key = "${b_val.bucket_name}-${k}-${v.role}"
            bucket_id  = b_val.bucket_name
            role       = v.role
            member     = v.member
            condition  = try(v.condition, [])
          }
        ]
      ]
      ]) : entry.unique_key => {
      bucket_id = entry.bucket_id
      role      = entry.role
      member    = entry.member
      condition = entry.condition
    }
  }


  # map of objects to upload and buckets 
  objects_map = flatten([
    for b in local.bucket_map : [
      for object in b.objects_to_upload : [
        for k, v in object : {
          combined_key     = "${b.bucket_name}-${k}-${v.name}"
          object_bucket_id = b.bucket_name
          object_name      = v.name
          object_source    = try(v.source, "")
          object_hash      = try(v.detect_md5hash, "")
        }
      ]
    ]
  ])
}

