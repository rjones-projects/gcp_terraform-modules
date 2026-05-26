variable "project_id" {
  description = "Project ID where Cloud Composer Environment is created."
  type        = string
}

variable "region" {
  description = "Region where the Cloud Composer Environment is created."
  type        = string
}

variable "composer_environment" {
  description = "Composer environment configurations"
  type        = any
  default     = {}
}

variable "composer_environment_default" {
  description = "A composer environment to be merged into"
  type = object({
    name                             = string
    labels                           = map(string)
    tags                             = set(string)
    network                          = string
    network_project_id               = string
    subnetwork                       = string
    subnetwork_region                = string
    use_existing_network_attachment  = bool
    composer_network_attachment_name = string
    composer_service_account         = string
    airflow_config_overrides         = map(string)
    env_variables                    = map(string)
    image_version                    = string
    web_server_plugins_mode          = string
    pypi_packages                    = map(string)
    use_private_environment          = bool
    enable_private_builds_only       = bool
    maintenance_start_time           = string
    maintenance_end_time             = string
    maintenance_recurrence           = string
    environment_size                 = string
    scheduler = object({
      cpu        = string
      memory_gb  = number
      storage_gb = number
      count      = number
    })
    web_server = object({
      cpu        = string
      memory_gb  = number
      storage_gb = number
    })
    worker = object({
      cpu        = string
      memory_gb  = number
      storage_gb = number
      min_count  = number
      max_count  = number
    })
    triggerer = object({
      cpu       = string
      memory_gb = number
      count     = number
    })
    dag_processor = object({
      cpu        = string
      memory_gb  = number
      storage_gb = number
      count      = number
    })
    grant_sa_agent_permission = bool
    scheduled_snapshots_config = object({
      enabled                    = optional(bool)
      snapshot_location          = optional(string)
      snapshot_creation_schedule = optional(string)
      time_zone                  = optional(string)
    })
    storage_bucket                 = string
    resilience_mode                = string
    cloud_data_lineage_integration = bool
    web_server_network_access_control = list(object({
      allowed_ip_range = string
      description      = string
    }))
    kms_key_name                     = string
    task_logs_retention_storage_mode = string
  })
  default = {
    name                             = null
    labels                           = {}
    tags                             = []
    network                          = null
    network_project_id               = null
    subnetwork                       = null
    subnetwork_region                = null
    use_existing_network_attachment  = true
    composer_network_attachment_name = null
    composer_service_account         = null
    airflow_config_overrides         = {}
    env_variables                    = {}
    image_version                    = "composer-3-airflow-2.10.2-build.7"
    web_server_plugins_mode          = "ENABLED"
    pypi_packages                    = {}
    use_private_environment          = true
    enable_private_builds_only       = true
    maintenance_start_time           = "05:00"
    maintenance_end_time             = null
    maintenance_recurrence           = null
    environment_size                 = "ENVIRONMENT_SIZE_MEDIUM"
    scheduler = {
      cpu        = 0.5
      memory_gb  = 1
      storage_gb = 1
      count      = 1
    }
    web_server = {
      cpu        = 0.5
      memory_gb  = 2
      storage_gb = 1
    }
    worker = {
      cpu        = 0.5
      memory_gb  = 1
      storage_gb = 1
      min_count  = 2
      max_count  = 3
    }
    triggerer = {
      cpu       = 1
      memory_gb = 1
      count     = 1
    }
    dag_processor = {
      cpu        = 0.5
      memory_gb  = 1
      storage_gb = 1
      count      = 1
    }
    grant_sa_agent_permission         = true
    scheduled_snapshots_config        = null
    storage_bucket                    = null
    resilience_mode                   = null
    cloud_data_lineage_integration    = false
    web_server_network_access_control = null
    kms_key_name                      = null
    task_logs_retention_storage_mode  = null
  }
}