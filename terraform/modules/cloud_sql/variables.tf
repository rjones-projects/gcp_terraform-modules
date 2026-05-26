variable "project_id" {
  description = "The ID of the project in which the resource belongs"
  type        = string
}

variable "region" {
  description = "The region the instance will sit in"
  type        = string
}

variable "cloud_sql" {
  description = "Cloud SQL configurations"
  type        = any
  default     = {}
}

variable "cloud_sql_default" {
  description = "A cloud SQL object to be merged into"
  type = object({
    name                = string
    database_version    = string
    deletion_protection = bool
    encryption_key_name = string
    tier                = string
    disk_size           = number
    disk_type           = string
    availability_type   = string
    labels              = map(string)
    flags               = map(string)
    backup_configuration = object({
      enabled                        = bool
      start_time                     = optional(string)
      location                       = optional(string)
      point_in_time_recovery_enabled = optional(bool)
      transaction_log_retention_days = optional(number)
      retained_backups               = optional(number)
      retention_unit                 = optional(string)
    })
    enable_private_service_access                 = bool
    network_link                                  = string
    enable_private_path_for_google_cloud_services = bool
    ssl_mode                                      = string
    psc_enabled                                   = bool
    psc_allowed_consumer_projects                 = list(string)
    databases                                     = list(string)
    read_replicas = list(object({
      name                = string
      tier                = string
      zone                = string
      disk_type           = string
      disk_size           = number
      labels              = map(string)
      database_flags      = map(string)
      ip_configuration    = map(string)
      encryption_key_name = string
    }))
    random_instance_name  = bool
    secret_access_members = list(string)
  })
  default = {
    name                = ""
    database_version    = "MYSQL_8_0"
    deletion_protection = true
    encryption_key_name = null
    tier                = "db-f1-micro"
    disk_size           = 10
    disk_type           = "PD_SSD"
    availability_type   = "ZONAL"
    labels              = {}
    flags               = {}
    backup_configuration = {
      enabled                        = false
      start_time                     = "03:00"
      location                       = null
      point_in_time_recovery_enabled = false
      transaction_log_retention_days = null
      retained_backups               = null
      retention_unit                 = null
    }
    enable_private_service_access                 = true
    network_link                                  = null
    enable_private_path_for_google_cloud_services = false
    ssl_mode                                      = "ENCRYPTED_ONLY"
    psc_enabled                                   = false
    psc_allowed_consumer_projects                 = []
    databases                                     = []
    read_replicas                                 = []
    random_instance_name                          = true
    secret_access_members                         = []
  }
}