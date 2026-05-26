locals {
  secrets = {
    for item in try(var.secret_manager.spec, []) : tostring(item.secret_id) => {
      secret_id             = tostring(item.secret_id)
      labels                = { for k, v in try(item.labels, {}) : tostring(k) => tostring(v) }
      expire_time           = try(item.expire_time, null)
      ttl                   = try(item.ttl, null)
      replication_automatic = try(item.replication_automatic, true)
      kms_key_name          = try(item.kms_key_name, null)
      replicas = [
        for replica in try(item.replicas, []) : {
          location                    = tostring(replica.location)
          customer_managed_encryption = try(replica.customer_managed_encryption, null)
        }
      ]
      rotation = try(item.rotation, null) == null ? null : {
        next_rotation_time = try(item.rotation.next_rotation_time, null)
        rotation_period    = try(item.rotation.rotation_period, null)
      }
      topics                           = [for t in try(item.topics, []) : tostring(t)]
      generate_random_password         = try(item.generate_random_password, false)
      random_password_length           = try(item.random_password_length, 32)
      random_password_special          = try(item.random_password_special, true)
      random_password_override_special = try(item.random_password_override_special, "_%@")
      secret_data                      = try(item.secret_data, null)
      create_binding                   = try(item.create_binding, false)
      members                          = [for m in try(item.members, []) : tostring(m)]
      iam_bindings                     = { for role, members in try(item.iam_bindings, {}) : tostring(role) => [for member in tolist(members) : tostring(member)] }
    }
    if tostring(item.secret_id) != ""
  }

  version_payload = {
    for secret_id, cfg in local.secrets :
    secret_id => (cfg.generate_random_password ? random_password.generated[secret_id].result : cfg.secret_data)
    if cfg.generate_random_password || cfg.secret_data != null
  }

  iam_member_pairs = {
    for pair in flatten([
      for secret_id, cfg in local.secrets : [
        for role, members in cfg.iam_bindings : [
          for member in members : {
            key       = "${secret_id}::${role}::${member}"
            secret_id = secret_id
            role      = role
            member    = member
          }
        ]
      ]
    ]) : pair.key => pair
  }
}
