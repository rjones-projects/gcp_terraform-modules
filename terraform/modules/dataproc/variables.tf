variable "project_id" {
  description = "Project ID."
  type        = string
}

variable "region" {
  description = "Dataproc region."
  type        = string
}

variable "dataproc" {
  description = "Dataproc cluster configurations"
  type        = any
  default     = {}
}

variable "dataproc_cluster_default" {
  description = "A dataproc object to be merged into"
  type = object({
    name   = string
    labels = map(string)
    dataproc_config = optional(object({
      graceful_decommission_timeout = optional(string)
      cluster_config = optional(object({
        staging_bucket = optional(string)
        temp_bucket    = optional(string)
        gce_cluster_config = optional(object({
          zone                   = optional(string)
          network                = optional(string)
          subnetwork             = optional(string)
          service_account        = optional(string)
          service_account_scopes = optional(list(string))
          tags                   = optional(list(string), [])
          internal_ip_only       = optional(bool, true)
          metadata               = optional(map(string), {})
          reservation_affinity = optional(object({
            consume_reservation_type = string
            key                      = string
            values                   = string
          }))
          node_group_affinity = optional(object({
            node_group_uri = string
          }))
          shielded_instance_config = optional(object({
            enable_secure_boot          = bool
            enable_vtpm                 = bool
            enable_integrity_monitoring = bool
          }))
          confidential_instance_config = optional(object({
            enable_confidential_compute = bool
          }))
        }))
        master_config = optional(object({
          num_instances    = number
          machine_type     = optional(string)
          min_cpu_platform = optional(string)
          image_uri        = optional(string)
          disk_config = optional(object({
            boot_disk_type    = string
            boot_disk_size_gb = number
            num_local_ssds    = number
          }))
          accelerators = optional(object({
            accelerator_type  = string
            accelerator_count = number
          }))
        }))
        worker_config = optional(object({
          num_instances    = number
          machine_type     = string
          min_cpu_platform = string
          disk_config = optional(object({
            boot_disk_type    = string
            boot_disk_size_gb = number
            num_local_ssds    = number
          }))
          image_uri = string
          accelerators = optional(object({
            accelerator_type  = string
            accelerator_count = number
          }))
        }))
        preemptible_worker_config = optional(object({
          num_instances  = number
          preemptibility = string
          disk_config = optional(object({
            boot_disk_type    = string
            boot_disk_size_gb = number
            num_local_ssds    = number
          }))
        }))
        software_config = optional(object({
          image_version       = optional(string)
          override_properties = map(string)
          optional_components = optional(list(string))
        }))
        security_config = optional(object({
          kerberos_config = object({
            cross_realm_trust_admin_server        = optional(string)
            cross_realm_trust_kdc                 = optional(string)
            cross_realm_trust_realm               = optional(string)
            cross_realm_trust_shared_password_uri = optional(string)
            enable_kerberos                       = optional(string)
            kdc_db_key_uri                        = optional(string)
            key_password_uri                      = optional(string)
            keystore_uri                          = optional(string)
            keystore_password_uri                 = optional(string)
            kms_key_uri                           = string
            realm                                 = optional(string)
            root_principal_password_uri           = string
            tgt_lifetime_hours                    = optional(string)
            truststore_password_uri               = optional(string)
            truststore_uri                        = optional(string)
          })
        }))
        autoscaling_config = optional(object({
          policy_uri = string
        }))
        initialization_action = optional(object({
          script      = string
          timeout_sec = optional(string)
        }))
        encryption_config = optional(object({
          kms_key_name = string
        }))
        lifecycle_config = optional(object({
          idle_delete_ttl  = optional(string)
          auto_delete_time = optional(string)
        }))
        endpoint_config = optional(object({
          enable_http_port_access = string
        }))
        dataproc_metric_config = optional(object({
          metrics = list(object({
            metric_source    = string
            metric_overrides = optional(list(string))
          }))
        }))
        metastore_config = optional(object({
          dataproc_metastore_service = string
        }))
      }))
      virtual_cluster_config = optional(object({
        staging_bucket = optional(string)
        auxiliary_services_config = optional(object({
          metastore_config = optional(object({
            dataproc_metastore_service = string
          }))
          spark_history_server_config = optional(object({
            dataproc_cluster = string
          }))
        }))
        kubernetes_cluster_config = object({
          kubernetes_namespace = optional(string)
          kubernetes_software_config = object({
            component_version = map(string)
            properties        = optional(map(string))
          })
          gke_cluster_config = object({
            gke_cluster_target = optional(string)
            node_pool_target = optional(object({
              node_pool = string
              roles     = list(string)
              node_pool_config = optional(object({
                autoscaling = optional(object({
                  min_node_count = optional(number)
                  max_node_count = optional(number)
                }))
                config = object({
                  machine_type     = optional(string)
                  preemptible      = optional(bool)
                  local_ssd_count  = optional(number)
                  min_cpu_platform = optional(string)
                  spot             = optional(bool)
                })
                locations = optional(list(string))
              }))
            }))
          })
        })
      }))
    }))
  })
  default = {
    name            = null
    labels          = {}
    dataproc_config = {}
  }


}