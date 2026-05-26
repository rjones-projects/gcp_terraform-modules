resource "google_cloud_run_v2_service" "service" {
  count                = local.type == "SERVICE" && var.managed_revision ? 1 : 0
  provider             = google-beta
  project              = local.project_id
  location             = local.location
  name                 = local.name
  ingress              = var.service_config.ingress
  invoker_iam_disabled = var.service_config.invoker_iam_disabled
  labels               = var.labels
  launch_stage         = var.launch_stage
  custom_audiences     = var.service_config.custom_audiences
  deletion_protection  = var.deletion_protection
  iap_enabled          = var.service_config.iap_config != null

  template {
    labels         = var.revision.labels
    encryption_key = var.encryption_key
    revision       = local.revision_name
    execution_environment = (
      var.service_config.gen2_execution_environment
      ? "EXECUTION_ENVIRONMENT_GEN2" : "EXECUTION_ENVIRONMENT_GEN1"
    )
    gpu_zonal_redundancy_disabled    = var.revision.gpu_zonal_redundancy_disabled
    max_instance_request_concurrency = var.service_config.max_concurrency
    dynamic "node_selector" {
      for_each = var.revision.node_selector == null ? [] : [""]
      content {
        accelerator = var.revision.node_selector.accelerator
      }
    }
    dynamic "scaling" {
      for_each = var.service_config.scaling == null ? [] : [""]
      content {
        max_instance_count = var.service_config.scaling.max_instance_count
        min_instance_count = var.service_config.scaling.min_instance_count
      }
    }
    dynamic "vpc_access" {
      for_each = local.connector == null ? [] : [""]
      content {
        connector = local.connector
        egress    = try(var.revision.vpc_access.egress, null)
      }
    }
    dynamic "vpc_access" {
      for_each = var.revision.vpc_access.subnet == null && var.revision.vpc_access.network == null ? [] : [""]
      content {
        egress = var.revision.vpc_access.egress
        network_interfaces {
          subnetwork = var.revision.vpc_access.subnet == null ? null : lookup(
            local.ctx.subnets, var.revision.vpc_access.subnet,
            var.revision.vpc_access.subnet
          )
          network = var.revision.vpc_access.network == null ? null : lookup(
            local.ctx.networks, var.revision.vpc_access.network,
            var.revision.vpc_access.network
          )
          tags = var.revision.vpc_access.tags
        }
      }
    }
    timeout         = var.service_config.timeout
    service_account = local.service_account_email
    dynamic "containers" {
      for_each = local.containers
      content {
        name       = containers.key
        image      = containers.value.image
        depends_on = try(containers.value.depends_on, null)
        command    = try(containers.value.command, null)
        args       = try(containers.value.args, null)
        dynamic "env" {
          for_each = coalesce(try(containers.value.env, tomap({})), tomap({}))
          content {
            name  = env.key
            value = env.value
          }
        }
        dynamic "env" {
          for_each = coalesce(try(containers.value.env_from_key, tomap({})), tomap({}))
          content {
            name = env.key
            value_source {
              secret_key_ref {
                secret  = env.value.secret
                version = env.value.version
              }
            }
          }
        }
        dynamic "resources" {
          for_each = try(containers.value.resources, null) == null ? [] : [""]
          content {
            limits            = containers.value.resources.limits
            cpu_idle          = containers.value.resources.cpu_idle
            startup_cpu_boost = containers.value.resources.startup_cpu_boost
          }
        }
        dynamic "ports" {
          for_each = coalesce(try(containers.value.ports, tomap({})), tomap({}))
          content {
            container_port = ports.value.container_port
            name           = ports.value.name
          }
        }
        dynamic "volume_mounts" {
          for_each = { for k, v in coalesce(try(containers.value.volume_mounts, tomap({})), tomap({})) : k => v if k != "cloudsql" }
          content {
            name       = volume_mounts.key
            mount_path = volume_mounts.value
          }
        }
        # CloudSQL is the last mount in the list returned by API
        dynamic "volume_mounts" {
          for_each = { for k, v in coalesce(try(containers.value.volume_mounts, tomap({})), tomap({})) : k => v if k == "cloudsql" }
          content {
            name       = volume_mounts.key
            mount_path = volume_mounts.value
          }
        }
        dynamic "liveness_probe" {
          for_each = try(containers.value.liveness_probe, null) == null ? [] : [""]
          content {
            initial_delay_seconds = containers.value.liveness_probe.initial_delay_seconds
            timeout_seconds       = containers.value.liveness_probe.timeout_seconds
            period_seconds        = containers.value.liveness_probe.period_seconds
            failure_threshold     = containers.value.liveness_probe.failure_threshold
            dynamic "http_get" {
              for_each = try(containers.value.liveness_probe.http_get, null) == null ? [] : [""]
              content {
                path = containers.value.liveness_probe.http_get.path
                port = containers.value.liveness_probe.http_get.port
                dynamic "http_headers" {
                  for_each = coalesce(try(containers.value.liveness_probe.http_get.http_headers, tomap({})), tomap({}))
                  content {
                    name  = http_headers.key
                    value = http_headers.value
                  }
                }
              }
            }
            dynamic "grpc" {
              for_each = try(containers.value.liveness_probe.grpc, null) == null ? [] : [""]
              content {
                port    = containers.value.liveness_probe.grpc.port
                service = containers.value.liveness_probe.grpc.service
              }
            }
          }
        }
        dynamic "startup_probe" {
          for_each = try(containers.value.startup_probe, null) == null ? [] : [""]
          content {
            initial_delay_seconds = containers.value.startup_probe.initial_delay_seconds
            timeout_seconds       = containers.value.startup_probe.timeout_seconds
            period_seconds        = containers.value.startup_probe.period_seconds
            failure_threshold     = containers.value.startup_probe.failure_threshold
            dynamic "http_get" {
              for_each = try(containers.value.startup_probe.http_get, null) == null ? [] : [""]
              content {
                path = containers.value.startup_probe.http_get.path
                port = containers.value.startup_probe.http_get.port
                dynamic "http_headers" {
                  for_each = coalesce(try(containers.value.startup_probe.http_get.http_headers, tomap({})), tomap({}))
                  content {
                    name  = http_headers.key
                    value = http_headers.value
                  }
                }
              }
            }
            dynamic "tcp_socket" {
              for_each = try(containers.value.startup_probe.tcp_socket, null) == null ? [] : [""]
              content {
                port = containers.value.startup_probe.tcp_socket.port
              }
            }
            dynamic "grpc" {
              for_each = try(containers.value.startup_probe.grpc, null) == null ? [] : [""]
              content {
                port    = containers.value.startup_probe.grpc.port
                service = containers.value.startup_probe.grpc.service
              }
            }
          }
        }
      }
    }
    dynamic "volumes" {
      for_each = { for k, v in var.volumes : k => v if v.cloud_sql_instances == null }
      content {
        name = volumes.key
        dynamic "secret" {
          for_each = volumes.value.secret == null ? [] : [""]
          content {
            secret       = volumes.value.secret.name
            default_mode = volumes.value.secret.default_mode
            dynamic "items" {
              for_each = volumes.value.secret.path == null ? [] : [""]
              content {
                path    = volumes.value.secret.path
                version = volumes.value.secret.version
                mode    = volumes.value.secret.mode
              }
            }
          }
        }

        dynamic "empty_dir" {
          for_each = volumes.value.empty_dir_size == null ? [] : [""]
          content {
            medium     = "MEMORY"
            size_limit = volumes.value.empty_dir_size
          }
        }
        dynamic "gcs" {
          for_each = volumes.value.gcs == null ? [] : [""]
          content {
            bucket    = volumes.value.gcs.bucket
            read_only = volumes.value.gcs.is_read_only
          }
        }
        dynamic "nfs" {
          for_each = volumes.value.nfs == null ? [] : [""]
          content {
            server    = volumes.value.nfs.server
            path      = volumes.value.nfs.path
            read_only = volumes.value.nfs.is_read_only
          }
        }
      }
    }
    # CloudSQL is the last volume in the list returned by API
    dynamic "volumes" {
      for_each = { for k, v in var.volumes : k => v if v.cloud_sql_instances != null }
      content {
        name = volumes.key
        dynamic "cloud_sql_instance" {
          for_each = length(coalesce(volumes.value.cloud_sql_instances, [])) == 0 ? [] : [""]
          content {
            instances = volumes.value.cloud_sql_instances
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version,
      template[0].annotations["run.googleapis.com/operation-id"],
    ]
  }
}
