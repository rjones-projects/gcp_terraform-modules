module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_composer_environment" "composer_env" {
  for_each = local.composer_environments
  provider = google-beta

  project = var.project_id
  name    = each.value.name
  region  = var.region

  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )

  dynamic "storage_config" {
    for_each = each.value.storage_bucket != null ? ["storage_config"] : []
    content {
      bucket = each.value.storage_bucket
    }
  }

  config {

    enable_private_environment = each.value.use_private_environment # reusing the existing variable name from previous versions
    enable_private_builds_only = each.value.enable_private_builds_only

    environment_size = each.value.environment_size
    resilience_mode  = each.value.resilience_mode

    node_config {
      service_account             = each.value.composer_service_account
      tags                        = each.value.tags
      network                     = each.value.use_existing_network_attachment ? "projects/${each.value.network_project_id}/global/networks/${each.value.network}" : null
      subnetwork                  = each.value.use_existing_network_attachment ? "projects/${each.value.network_project_id}/regions/${each.value.subnetwork_region}/subnetworks/${each.value.subnetwork}" : null
      composer_network_attachment = each.value.use_existing_network_attachment ? null : "projects/${each.value.project_id}/regions/${each.value.region}/networkAttachments/${each.value.composer_network_attachment_name}"
    }

    dynamic "software_config" {
      for_each = [
        {
          airflow_config_overrides = each.value.airflow_config_overrides
          pypi_packages            = each.value.pypi_packages
          env_variables            = each.value.env_variables
          image_version            = each.value.image_version
          web_server_plugins_mode  = each.value.web_server_plugins_mode
      }]
      content {
        airflow_config_overrides = software_config.value["airflow_config_overrides"]
        pypi_packages            = software_config.value["pypi_packages"]
        env_variables            = software_config.value["env_variables"]
        image_version            = software_config.value["image_version"]
        web_server_plugins_mode  = software_config.value["web_server_plugins_mode"]
        dynamic "cloud_data_lineage_integration" {
          for_each = each.value.cloud_data_lineage_integration ? ["cloud_data_lineage_integration"] : []
          content {
            enabled = each.value.cloud_data_lineage_integration
          }
        }
      }
    }

    dynamic "maintenance_window" {
      for_each = (each.value.maintenance_end_time != null && each.value.maintenance_recurrence != null) ? [
        {
          start_time = each.value.maintenance_start_time
          end_time   = each.value.maintenance_end_time
          recurrence = each.value.maintenance_recurrence
      }] : []
      content {
        start_time = maintenance_window.value["start_time"]
        end_time   = maintenance_window.value["end_time"]
        recurrence = maintenance_window.value["recurrence"]
      }
    }

    workloads_config {

      dynamic "scheduler" {
        for_each = each.value.scheduler != null ? [each.value.scheduler] : []
        content {
          cpu        = scheduler.value["cpu"]
          memory_gb  = scheduler.value["memory_gb"]
          storage_gb = scheduler.value["storage_gb"]
          count      = scheduler.value["count"]
        }
      }

      dynamic "web_server" {
        for_each = each.value.web_server != null ? [each.value.web_server] : []
        content {
          cpu        = web_server.value["cpu"]
          memory_gb  = web_server.value["memory_gb"]
          storage_gb = web_server.value["storage_gb"]
        }
      }

      dynamic "worker" {
        for_each = each.value.worker != null ? [each.value.worker] : []
        content {
          cpu        = worker.value["cpu"]
          memory_gb  = worker.value["memory_gb"]
          storage_gb = worker.value["storage_gb"]
          min_count  = worker.value["min_count"]
          max_count  = worker.value["max_count"]
        }
      }

      dynamic "triggerer" {
        for_each = each.value.triggerer != null ? [each.value.triggerer] : []
        content {
          cpu       = triggerer.value["cpu"]
          memory_gb = triggerer.value["memory_gb"]
          count     = triggerer.value["count"]
        }
      }

      dynamic "dag_processor" {
        for_each = each.value.dag_processor != null ? [each.value.dag_processor] : []
        content {
          cpu        = dag_processor.value["cpu"]
          memory_gb  = dag_processor.value["memory_gb"]
          storage_gb = dag_processor.value["storage_gb"]
          count      = dag_processor.value["count"]
        }
      }

    }

    dynamic "recovery_config" {
      for_each = each.value.scheduled_snapshots_config != null ? ["recovery_config"] : []
      content {
        dynamic "scheduled_snapshots_config" {
          for_each = each.value.scheduled_snapshots_config != null ? [each.value.scheduled_snapshots_config] : []
          content {
            enabled                    = scheduled_snapshots_config.value["enabled"]
            snapshot_location          = scheduled_snapshots_config.value["snapshot_location"]
            snapshot_creation_schedule = scheduled_snapshots_config.value["snapshot_creation_schedule"]
            time_zone                  = scheduled_snapshots_config.value["time_zone"]
          }
        }
      }
    }

    dynamic "web_server_network_access_control" {
      for_each = each.value.web_server_network_access_control == null ? [] : ["web_server_network_access_control"]
      content {
        dynamic "allowed_ip_range" {
          for_each = { for x in each.value.web_server_network_access_control : x.allowed_ip_range => x }
          content {
            value       = allowed_ip_range.value["allowed_ip_range"]
            description = allowed_ip_range.value["description"]
          }
        }
      }
    }

    dynamic "encryption_config" {
      for_each = each.value.kms_key_name != null ? ["encryption_config"] : []
      content {
        kms_key_name = each.value.kms_key_name
      }
    }

    dynamic "data_retention_config" {
      for_each = each.value.task_logs_retention_storage_mode == null ? [] : ["data_retention_config"]
      content {
        task_logs_retention_config {
          storage_mode = each.value.task_logs_retention_storage_mode
        }
      }
    }
  }

  depends_on = [google_project_iam_member.composer_agent_service_account]

}