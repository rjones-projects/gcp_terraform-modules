locals {

  buckets = [
    for item in var.gcs.spec : {
      bucket_name                 = coalesce(item.bucket_name, item.name)
      location                    = coalesce(item.location, var.region)
      storage_class               = item.storage_class
      uniform_bucket_level_access = item.uniform_bucket_level_access
      kms_key_name                = item.kms_key_name
      finops_resource_type        = item.finops_resource_type
      labels                      = item.labels
      versioning_enabled          = coalesce(item.versioning_enabled, item.versioning, true)
      accesses = length(item.accesses) > 0 ? item.accesses : [
        for role, members in item.iam : {
          role    = role
          members = members
        }
      ]
      retention_policy         = item.retention_policy
      logging                  = item.logging
      lifecycle_rules          = item.lifecycle_rules
      autoclass                = length(item.lifecycle_rules) > 0 ? false : item.autoclass
      iam_bindings             = item.iam_bindings
      iam_bindings_additive    = item.iam_bindings_additive
      objects_to_upload        = item.objects_to_upload
      public_access_prevention = item.public_access_prevention
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
        for k, v in b_val.iam_bindings : {
          unique_key = "${b_val.bucket_name}-${k}-${v.role}"
          bucket_id  = b_val.bucket_name
          role       = v.role
          members    = v.members
          condition  = try(v.condition, [])
        }
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
        for k, v in b_val.iam_bindings_additive : {
          unique_key = "${b_val.bucket_name}-${k}-${v.role}"
          bucket_id  = b_val.bucket_name
          role       = v.role
          member     = v.member
          condition  = try(v.condition, [])
        }
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

