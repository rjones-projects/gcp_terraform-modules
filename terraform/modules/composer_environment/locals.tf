locals {
  composer_environments = {
    for spec in try(var.composer_environment.spec, []) : try(spec.name, var.composer_environment_default.name) => {
      name                              = try(spec.name, var.composer_environment_default.name)
      labels                            = try(spec.labels, var.composer_environment_default.labels)
      finops_resource_type              = try(spec.finops_resource_type, "composer")
      tags                              = try(spec.tags, var.composer_environment_default.tags)
      network                           = try(spec.network, var.composer_environment_default.network)
      network_project_id                = try(spec.network_project_id, var.composer_environment_default.network_project_id) == null ? var.project_id : spec.network_project_id
      subnetwork                        = try(spec.subnetwork, var.composer_environment_default.subnetwork)
      subnetwork_region                 = try(spec.subnetwork_region, var.composer_environment_default.subnetwork_region) == null ? var.region : spec.subnetwork_region
      use_existing_network_attachment   = try(spec.use_existing_network_attachment, var.composer_environment_default.use_existing_network_attachment)
      composer_network_attachment_name  = try(spec.composer_network_attachment_name, var.composer_environment_default.composer_network_attachment_name)
      composer_service_account          = try(spec.composer_service_account, var.composer_environment_default.composer_service_account)
      airflow_config_overrides          = try(spec.airflow_config_overrides, var.composer_environment_default.airflow_config_overrides)
      env_variables                     = try(spec.env_variables, var.composer_environment_default.env_variables)
      image_version                     = try(spec.image_version, var.composer_environment_default.image_version)
      web_server_plugins_mode           = try(spec.web_server_plugins_mode, var.composer_environment_default.web_server_plugins_mode)
      pypi_packages                     = try(spec.pypi_packages, var.composer_environment_default.pypi_packages)
      use_private_environment           = try(spec.use_private_environment, var.composer_environment_default.use_private_environment)
      enable_private_builds_only        = try(spec.enable_private_builds_only, var.composer_environment_default.enable_private_builds_only)
      maintenance_start_time            = try(spec.maintenance_start_time, var.composer_environment_default.maintenance_start_time)
      maintenance_end_time              = try(spec.maintenance_end_time, var.composer_environment_default.maintenance_end_time)
      maintenance_recurrence            = try(spec.maintenance_recurrence, var.composer_environment_default.maintenance_recurrence)
      environment_size                  = try(spec.environment_size, var.composer_environment_default.environment_size)
      scheduler                         = try(spec.scheduler, var.composer_environment_default.scheduler)
      web_server                        = try(spec.web_server, var.composer_environment_default.web_server)
      worker                            = try(spec.worker, var.composer_environment_default.worker)
      triggerer                         = try(spec.triggerer, var.composer_environment_default.triggerer)
      dag_processor                     = try(spec.dag_processor, var.composer_environment_default.dag_processor)
      grant_sa_agent_permission         = try(spec.grant_sa_agent_permission, var.composer_environment_default.grant_sa_agent_permission)
      scheduled_snapshots_config        = try(spec.scheduled_snapshots_config, var.composer_environment_default.scheduled_snapshots_config)
      storage_bucket                    = try(spec.storage_bucket, var.composer_environment_default.storage_bucket)
      resilience_mode                   = try(spec.resilience_mode, var.composer_environment_default.resilience_mode)
      cloud_data_lineage_integration    = try(spec.cloud_data_lineage_integration, var.composer_environment_default.cloud_data_lineage_integration)
      web_server_network_access_control = try(spec.web_server_network_access_control, var.composer_environment_default.web_server_network_access_control)
      kms_key_name                      = try(spec.kms_key_name, var.composer_environment_default.kms_key_name)
      task_logs_retention_storage_mode  = try(spec.task_logs_retention_storage_mode, var.composer_environment_default.task_logs_retention_storage_mode)
    }
  }

  finops_specs = [
    for composer_environment in local.composer_environments : {
      resource_type = composer_environment.finops_resource_type
      name          = "${composer_environment.finops_resource_type}/${composer_environment.name}"
      resource_name = composer_environment.name
      input_labels  = composer_environment.labels
    }
  ]

  cloud_composer_sa = format("service-%s@cloudcomposer-accounts.iam.gserviceaccount.com", data.google_project.project.number)
}