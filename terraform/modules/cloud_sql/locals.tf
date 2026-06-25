locals {
  cloud_sql_configurations = {
    for spec in try(var.cloud_sql.spec, []) : try(spec.name, var.cloud_sql_default.name) => {
      name                 = try(spec.name, var.cloud_sql_default.name)
      database_version     = try(spec.database_version, var.cloud_sql_default.database_version)
      deletion_protection  = try(spec.deletion_protection, var.cloud_sql_default.deletion_protection)
      encryption_key_name  = try(spec.encryption_key_name, var.cloud_sql_default.encryption_key_name)
      tier                 = try(spec.tier, var.cloud_sql_default.tier)
      disk_size            = try(spec.disk_size, var.cloud_sql_default.disk_size)
      disk_type            = try(spec.disk_type, var.cloud_sql_default.disk_type)
      availability_type    = try(spec.availability_type, var.cloud_sql_default.availability_type)
      finops_resource_type = coalesce(try(spec.finops_resource_type, null), "compute")
      labels               = try(spec.labels, var.cloud_sql_default.labels)
      flags                = try(spec.flags, var.cloud_sql_default.flags)
      backup_configuration = {
        enabled                        = try(spec.backup_configuration.enabled, var.cloud_sql_default.backup_configuration.enabled)
        start_time                     = try(spec.backup_configuration.start_time, var.cloud_sql_default.backup_configuration.start_time)
        location                       = try(spec.backup_configuration.location, var.cloud_sql_default.backup_configuration.location)
        point_in_time_recovery_enabled = try(spec.backup_configuration.point_in_time_recovery_enabled, var.cloud_sql_default.backup_configuration.point_in_time_recovery_enabled)
        transaction_log_retention_days = try(spec.backup_configuration.transaction_log_retention_days, var.cloud_sql_default.backup_configuration.transaction_log_retention_days)
        retained_backups               = try(spec.backup_configuration.retained_backups, var.cloud_sql_default.backup_configuration.retained_backups)
        retention_unit                 = try(spec.backup_configuration.retention_unit, var.cloud_sql_default.backup_configuration.retention_unit)
      }
      enable_private_service_access                 = try(spec.enable_private_service_access, var.cloud_sql_default.enable_private_service_access)
      network_link                                  = try(spec.network_link, var.cloud_sql_default.network_link)
      enable_private_path_for_google_cloud_services = try(spec.enable_private_path_for_google_cloud_services, var.cloud_sql_default.enable_private_path_for_google_cloud_services)
      ssl_mode                                      = try(spec.ssl_mode, var.cloud_sql_default.ssl_mode)
      psc_enabled                                   = try(spec.psc_enabled, var.cloud_sql_default.psc_enabled)
      psc_allowed_consumer_projects                 = try(spec.psc_allowed_consumer_projects, var.cloud_sql_default.psc_allowed_consumer_projects)
      databases                                     = try(spec.databases, var.cloud_sql_default.databases)
      read_replicas                                 = try(spec.read_replicas, var.cloud_sql_default.read_replicas)
      random_instance_name                          = try(spec.random_instance_name, var.cloud_sql_default.random_instance_name)
      secret_access_members                         = try(spec.secret_access_members, var.cloud_sql_default.secret_access_members)
    }
  }

  finops_specs = [
    for cloud_sql_configuration in local.cloud_sql_configurations : {
      resource_type = cloud_sql_configuration.finops_resource_type
      name          = "${cloud_sql_configuration.finops_resource_type}/${cloud_sql_configuration.name}"
      resource_name = cloud_sql_configuration.name
      input_labels  = cloud_sql_configuration.labels
    }
  ]

  Password="securePassword123!"
}