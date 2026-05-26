module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

# ---------------------------------------------------------
# Random Suffix & Password
# ---------------------------------------------------------
resource "random_id" "suffix" {
  for_each = {
    for configuration in local.cloud_sql_configurations :
    configuration.name => configuration
    if configuration.random_instance_name == true
  }
  byte_length = 2 # Generates 4 hex characters
}

resource "random_password" "admin_password" {
  for_each = {
    for configuration in local.cloud_sql_configurations :
    configuration.name => configuration
    if strcontains(upper(configuration.database_version), "MYSQL")
  }
  length           = 16
  special          = true
  override_special = "_%@"
}

# ---------------------------------------------------------
# Secret Manager: Store Password
# ---------------------------------------------------------
resource "google_secret_manager_secret" "db_password" {
  for_each = {
    for configuration in local.cloud_sql_configurations :
    configuration.name => configuration
    if strcontains(upper(configuration.database_version), "MYSQL")
  }
  secret_id = "${each.value.random_instance_name ? "${each.value.name}-${random_id.suffix[each.value.name].hex}" : each.value.name}-admin-password"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  for_each = {
    for configuration in local.cloud_sql_configurations :
    configuration.name => configuration
    if strcontains(upper(configuration.database_version), "MYSQL")
  }
  secret      = google_secret_manager_secret.db_password[each.value.name].id
  secret_data = random_password.admin_password[each.value.name].result
}

# ---------------------------------------------------------
# Secret IAM Binding
# ---------------------------------------------------------
resource "google_secret_manager_secret_iam_binding" "secret_access" {
  for_each = {
    for configuration in local.cloud_sql_configurations :
    configuration.name => configuration
    if strcontains(upper(configuration.database_version), "MYSQL") && length(configuration.secret_access_members) > 0
  }
  project   = var.project_id
  secret_id = google_secret_manager_secret.db_password[each.value.name].secret_id
  role      = "roles/secretmanager.secretAccessor"
  members   = each.value.secret_access_members
}

# ---------------------------------------------------------
# Cloud SQL Instance
# ---------------------------------------------------------
resource "google_sql_database_instance" "master" {
  # checkov:skip=CKV_GCP_14:Ensure all Cloud SQL database instance have backup configuration enabled
  # checkov:skip=CKV_GCP_6:Ensure all Cloud SQL database instance requires all incoming connections to use SSL
  # checkov:skip=CKV_GCP_79:Ensure SQL database is using latest Major version
  for_each            = local.cloud_sql_configurations
  name                = each.value.random_instance_name ? "${each.value.name}-${random_id.suffix[each.value.name].hex}" : each.value.name
  project             = var.project_id
  region              = var.region
  database_version    = each.value.database_version
  deletion_protection = each.value.deletion_protection
  encryption_key_name = each.value.encryption_key_name

  settings {
    tier              = each.value.tier
    disk_size         = each.value.disk_size
    disk_type         = each.value.disk_type
    availability_type = each.value.availability_type

    user_labels = try(
      module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
      {}
    )

    dynamic "database_flags" {
      for_each = each.value.flags
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    backup_configuration {
      enabled                        = each.value.backup_configuration.enabled
      start_time                     = each.value.backup_configuration.start_time
      location                       = each.value.backup_configuration.location
      point_in_time_recovery_enabled = each.value.backup_configuration.point_in_time_recovery_enabled

      dynamic "backup_retention_settings" {
        for_each = each.value.backup_configuration.retained_backups != null ? [1] : []
        content {
          retained_backups = each.value.backup_configuration.retained_backups
          retention_unit   = each.value.backup_configuration.retention_unit
        }
      }
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = each.value.enable_private_service_access ? each.value.network_link : null
      enable_private_path_for_google_cloud_services = each.value.enable_private_path_for_google_cloud_services
      ssl_mode                                      = each.value.ssl_mode

      # PSC Configuration
      psc_config {
        psc_enabled               = each.value.psc_enabled
        allowed_consumer_projects = each.value.psc_allowed_consumer_projects
      }
    }
  }

  # Ignore changes to disk size as it can auto-grow
  lifecycle {
    ignore_changes = [settings[0].disk_size]
  }
}

# Databases
resource "google_sql_database" "default" {
  for_each = { for item in flatten([
    for instance_name, config in local.cloud_sql_configurations : [
      for db in config.databases : {
        key_name = "${instance_name}-${db}"
        instance = instance_name
        db_name  = db
      }
    ]
  ]) : item.key_name => item }
  name     = each.value.db_name
  project  = var.project_id
  instance = google_sql_database_instance.master[each.value.instance].name
}

# Admin User
resource "google_sql_user" "admin" {
  for_each = {
    for configuration in local.cloud_sql_configurations :
    configuration.name => configuration
    if strcontains(upper(configuration.database_version), "MYSQL")
  }
  name     = "admin"
  project  = var.project_id
  instance = google_sql_database_instance.master[each.value.name].name
  password = random_password.admin_password[each.value.name].result
  host     = "%" # Allow from any host (restricted by VPC/SSL)
}

# Read Replicas
resource "google_sql_database_instance" "replicas" {
  # checkov:skip=CKV_GCP_6:Ensure all Cloud SQL database instance requires all incoming connections to use SSL
  # checkov:skip=CKV_GCP_79:Ensure SQL database is using latest Major version
  for_each = { for item in flatten([
    for instance_name, config in local.cloud_sql_configurations : [
      for rr in config.read_replicas : {
        key_name     = "${instance_name}-${rr.name}"
        instance     = instance_name
        read_replica = rr
        parent       = config
      }
    ]
  ]) : item.key_name => item }
  name                 = "${each.value.instance}-${try(each.value.read_replica.name, null)}"
  project              = var.project_id
  region               = var.region
  database_version     = each.value.parent.database_version
  master_instance_name = google_sql_database_instance.master[each.value.instance].name
  deletion_protection  = each.value.parent.deletion_protection

  replica_configuration {
    failover_target = false
  }

  settings {
    tier      = coalesce(try(each.value.read_replica.tier, null), each.value.parent.tier)
    disk_size = coalesce(try(each.value.read_replica.disk_size, null), each.value.parent.disk_size)
    disk_type = coalesce(try(each.value.read_replica.disk_type, null), each.value.parent.disk_type)
    user_labels = try(
      module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
      {}
    )

    dynamic "database_flags" {
      for_each = try(each.value.read_replica.database_flags, each.value.parent.flags)
      content {
        name  = database_flags.key
        value = database_flags.value
      }
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = each.value.parent.enable_private_service_access ? each.value.parent.network_link : null
      enable_private_path_for_google_cloud_services = each.value.parent.enable_private_path_for_google_cloud_services
      ssl_mode                                      = each.value.parent.ssl_mode

      # PSC Configuration
      psc_config {
        psc_enabled               = each.value.parent.psc_enabled
        allowed_consumer_projects = each.value.parent.psc_allowed_consumer_projects
      }
    }
  }
}