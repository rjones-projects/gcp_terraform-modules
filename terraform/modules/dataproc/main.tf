module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_dataproc_cluster" "cluster" {
  # checkov:skip=CKV_GCP_103:Ensure Dataproc Clusters do not have public IPs
  # checkov:skip=CKV_GCP_91:Ensure Dataproc cluster is encrypted with Customer Supplied Encryption Keys (CSEK)

  for_each                      = local.dataproc_clusters
  name                          = each.value.name
  project                       = var.project_id
  region                        = var.region
  graceful_decommission_timeout = try(each.value.dataproc_config.graceful_decommission_timeout, null)

  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )

  dynamic "cluster_config" {
    for_each = try(each.value.dataproc_config.cluster_config, null) == null ? [] : [""]
    content {
      staging_bucket = try(each.value.dataproc_config.cluster_config.staging_bucket, null)
      temp_bucket    = try(each.value.dataproc_config.cluster_config.temp_bucket, null)
      dynamic "gce_cluster_config" {
        for_each = try(each.value.dataproc_config.cluster_config.gce_cluster_config, null) == null ? [] : [""]
        content {
          zone                   = try(each.value.dataproc_config.cluster_config.gce_cluster_config.zone, null)
          network                = try(each.value.dataproc_config.cluster_config.gce_cluster_config.network, null)
          subnetwork             = try(each.value.dataproc_config.cluster_config.gce_cluster_config.subnetwork, null)
          service_account        = try(each.value.dataproc_config.cluster_config.gce_cluster_config.service_account, null)
          service_account_scopes = try(each.value.dataproc_config.cluster_config.gce_cluster_config.service_account_scopes, [])
          tags                   = try(each.value.dataproc_config.cluster_config.gce_cluster_config.tags, [])
          //Default value to true
          internal_ip_only = true

          metadata = try(each.value.dataproc_config.cluster_config.gce_cluster_config.metadata, {})
          dynamic "reservation_affinity" {
            for_each = try(each.value.dataproc_config.cluster_config.gce_cluster_config.reservation_affinity, null) == null ? [] : [""]
            content {
              consume_reservation_type = try(each.value.dataproc_config.cluster_config.gce_cluster_config.reservation_affinity.consume_reservation_type, null)
              key                      = try(each.value.dataproc_config.cluster_config.gce_cluster_config.reservation_affinity.key, null)
              values                   = try(each.value.dataproc_config.cluster_config.gce_cluster_config.reservation_affinity.value, null)
            }
          }
          dynamic "node_group_affinity" {
            for_each = try(each.value.dataproc_config.cluster_config.gce_cluster_config.node_group_affinity, null) == null ? [] : [""]
            content {
              node_group_uri = try(each.value.dataproc_config.cluster_config.gce_cluster_config.node_group_uri, null)
            }
          }
          dynamic "shielded_instance_config" {
            for_each = try(each.value.dataproc_config.cluster_config.gce_cluster_config.shielded_instance_config, null) == null ? [] : [""]
            content {
              enable_secure_boot          = try(each.value.dataproc_config.cluster_config.gce_cluster_config.shielded_instance_config.enable_secure_boot, null)
              enable_vtpm                 = try(each.value.dataproc_config.cluster_config.gce_cluster_config.shielded_instance_config.enable_vtpm, null)
              enable_integrity_monitoring = try(each.value.dataproc_config.cluster_config.gce_cluster_config.shielded_instance_config.enable_integrity_monitoring, null)
            }
          }
          dynamic "confidential_instance_config" {
            for_each = try(each.value.dataproc_config.cluster_config.gce_cluster_config.confidential_instance_config, null) == null ? [] : [""]
            content {
              enable_confidential_compute = try(each.value.dataproc_config.cluster_config.gce_cluster_config.confidential_instance_config.enable_confidential_compute, null)
            }
          }
        }
      }
      dynamic "master_config" {
        for_each = try(each.value.dataproc_config.cluster_config.master_config, null) == null ? [] : [""]
        content {
          num_instances    = try(each.value.dataproc_config.cluster_config.master_config.num_instances, null)
          machine_type     = try(each.value.dataproc_config.cluster_config.master_config.machine_type, null)
          min_cpu_platform = try(each.value.dataproc_config.cluster_config.master_config.min_cpu_platform, null)
          image_uri        = try(each.value.dataproc_config.cluster_config.master_config.image_uri, null)
          dynamic "disk_config" {
            for_each = try(each.value.dataproc_config.cluster_config.master_config.disk_config, null) == null ? [] : [""]
            content {
              boot_disk_type    = try(each.value.dataproc_config.cluster_config.master_config.disk_config.boot_disk_type, null)
              boot_disk_size_gb = try(each.value.dataproc_config.cluster_config.master_config.disk_config.boot_disk_size_gb, null)
              num_local_ssds    = try(each.value.dataproc_config.cluster_config.master_config.disk_config.num_local_ssds, null)
            }
          }
          dynamic "accelerators" {
            for_each = try(each.value.dataproc_config.cluster_config.master_config.accelerators, null) == null ? [] : [""]
            content {
              accelerator_type  = try(each.value.dataproc_config.cluster_config.master_config.accelerators.accelerator_type, null)
              accelerator_count = try(each.value.dataproc_config.cluster_config.master_config.accelerators.accelerator_count, null)
            }
          }
        }
      }
      dynamic "worker_config" {
        for_each = try(each.value.dataproc_config.cluster_config.worker_config, null) == null ? [] : [""]
        content {
          num_instances    = try(each.value.dataproc_config.cluster_config.worker_config.num_instances, null)
          machine_type     = try(each.value.dataproc_config.cluster_config.worker_config.machine_type, null)
          min_cpu_platform = try(each.value.dataproc_config.cluster_config.worker_config.min_cpu_platform, null)
          dynamic "disk_config" {
            for_each = try(each.value.dataproc_config.cluster_config.worker_config.disk_config, null) == null ? [] : [""]
            content {
              boot_disk_type    = try(each.value.dataproc_config.cluster_config.worker_config.disk_config.boot_disk_type, null)
              boot_disk_size_gb = try(each.value.dataproc_config.cluster_config.worker_config.disk_config.boot_disk_size_gb, null)
              num_local_ssds    = try(each.value.dataproc_config.cluster_config.worker_config.disk_config.num_local_ssds, null)
            }
          }
          image_uri = try(each.value.dataproc_config.cluster_config.worker_config.image_uri, null)
          dynamic "accelerators" {
            for_each = try(each.value.dataproc_config.cluster_config.worker_config.accelerators, null) == null ? [] : [""]
            content {
              accelerator_type  = try(each.value.dataproc_config.cluster_config.worker_config.accelerators.accelerator_type, null)
              accelerator_count = try(each.value.dataproc_config.cluster_config.worker_config.accelerators.accelerator_count, null)
            }
          }
        }
      }
      dynamic "preemptible_worker_config" {
        for_each = try(each.value.dataproc_config.cluster_config.preemptible_worker_config, null) == null ? [] : [""]
        content {
          num_instances  = try(each.value.dataproc_config.cluster_config.preemptible_worker_config.num_instances, null)
          preemptibility = try(each.value.dataproc_config.cluster_config.preemptible_worker_config.preemptibility, null)
          dynamic "disk_config" {
            for_each = try(each.value.dataproc_config.cluster_config.preemptible_worker_config.disk_config, null) == null ? [] : [""]
            content {
              boot_disk_type    = try(each.value.dataproc_config.cluster_config.disk_config.boot_disk_type, null)
              boot_disk_size_gb = try(each.value.dataproc_config.cluster_config.disk_config.boot_disk_size_gb, null)
              num_local_ssds    = try(each.value.dataproc_config.cluster_config.disk_config.num_local_ssds, null)
            }
          }
        }
      }
      dynamic "software_config" {
        for_each = try(each.value.dataproc_config.cluster_config.software_config, null) == null ? [] : [""]
        content {
          image_version       = try(each.value.dataproc_config.cluster_config.software_config.image_version, null)
          override_properties = try(each.value.dataproc_config.cluster_config.software_config.override_properties, null)
          optional_components = try(each.value.dataproc_config.cluster_config.software_config.optional_components, null)
        }
      }
      dynamic "security_config" {
        for_each = try(each.value.dataproc_config.cluster_config.security_config, null) == null ? [] : [""]
        content {
          dynamic "kerberos_config" {
            for_each = try(try(each.value.dataproc_config.cluster_config.security_config.kerberos_config == null ? [] : [""], []), null)
            content {
              cross_realm_trust_admin_server        = try(each.value.dataproc_config.cluster_config.kerberos_config.cross_realm_trust_admin_server, null)
              cross_realm_trust_kdc                 = try(each.value.dataproc_config.cluster_config.kerberos_config.cross_realm_trust_kdc, null)
              cross_realm_trust_realm               = try(each.value.dataproc_config.cluster_config.kerberos_config.cross_realm_trust_realm, null)
              cross_realm_trust_shared_password_uri = try(each.value.dataproc_config.cluster_config.kerberos_config.cross_realm_trust_shared_password_uri, null)
              enable_kerberos                       = try(each.value.dataproc_config.cluster_config.kerberos_config.enable_kerberos, null)
              kdc_db_key_uri                        = try(each.value.dataproc_config.cluster_config.kerberos_config.kdc_db_key_uri, null)
              key_password_uri                      = try(each.value.dataproc_config.cluster_config.kerberos_config.key_password_uri, null)
              keystore_uri                          = try(each.value.dataproc_config.cluster_config.kerberos_config.keystore_uri, null)
              keystore_password_uri                 = try(each.value.dataproc_config.cluster_config.kerberos_config.keystore_password_uri, null)
              kms_key_uri                           = try(each.value.dataproc_config.cluster_config.kerberos_config.kms_key_uri, null)
              realm                                 = try(each.value.dataproc_config.cluster_config.kerberos_config.realm, null)
              root_principal_password_uri           = try(each.value.dataproc_config.cluster_config.kerberos_config.root_principal_password_uri, null)
              tgt_lifetime_hours                    = try(each.value.dataproc_config.cluster_config.kerberos_config.tgt_lifetime_hours, null)
              truststore_password_uri               = try(each.value.dataproc_config.cluster_config.kerberos_config.truststore_password_uri, null)
              truststore_uri                        = try(each.value.dataproc_config.cluster_config.kerberos_config.truststore_uri, null)
            }
          }
        }
      }
      dynamic "autoscaling_config" {
        for_each = try(each.value.dataproc_config.cluster_config.autoscaling_config, null) == null ? [] : [""]
        content {
          policy_uri = try(each.value.dataproc_config.cluster_config.autoscaling_config.policy_uri, null)
        }
      }
      dynamic "initialization_action" {
        for_each = try(each.value.dataproc_config.cluster_config.initialization_action, null) == null ? [] : [""]
        content {
          script      = try(each.value.dataproc_config.cluster_config.initialization_action.script, null)
          timeout_sec = try(each.value.dataproc_config.cluster_config.initialization_action.timeout_sec, null)
        }
      }
      dynamic "encryption_config" {
        for_each = try(try(each.value.dataproc_config.cluster_config.encryption_config.kms_key_name == null ? [] : [""], []), null)
        content {
          kms_key_name = try(each.value.dataproc_config.cluster_config.encryption_config.kms_key_name, null)
        }
      }
      dynamic "dataproc_metric_config" {
        for_each = try(each.value.dataproc_config.cluster_config.dataproc_metric_config, null) == null ? [] : [""]
        content {
          dynamic "metrics" {
            for_each = coalesce(try(each.value.dataproc_config.cluster_config.dataproc_metric_config.metrics, []), null)
            content {
              metric_source    = metrics.value.metric_source
              metric_overrides = metrics.value.metric_overrides
            }
          }
        }
      }
      dynamic "lifecycle_config" {
        for_each = try(each.value.dataproc_config.cluster_config.lifecycle_config, null) == null ? [] : [""]
        content {
          idle_delete_ttl  = try(each.value.dataproc_config.cluster_config.lifecycle_config.idle_delete_ttl, null)
          auto_delete_time = try(each.value.dataproc_config.cluster_config.lifecycle_config.auto_delete_time, null)
        }
      }
      dynamic "endpoint_config" {
        for_each = try(each.value.dataproc_config.cluster_config.endpoint_config, null) == null ? [] : [""]
        content {
          enable_http_port_access = try(each.value.dataproc_config.cluster_config.endpoint_config.enable_http_port_access, null)
        }
      }
      dynamic "metastore_config" {
        for_each = try(each.value.dataproc_config.cluster_config.metastore_config, null) == null ? [] : [""]
        content {
          dataproc_metastore_service = try(each.value.dataproc_config.cluster_config.metastore_config.dataproc_metastore_service, null)
        }
      }

    }
  }

  dynamic "virtual_cluster_config" {
    for_each = try(each.value.dataproc_config.virtual_cluster_config, null) == null ? [] : [""]
    content {
      dynamic "auxiliary_services_config" {
        for_each = try(each.value.dataproc_config.virtual_cluster_config.auxiliary_services_config, null) == null ? [] : [""]
        content {
          dynamic "metastore_config" {
            for_each = try(each.value.dataproc_config.virtual_cluster_config.auxiliary_services_config.metastore_config, null) == null ? [] : [""]
            content {
              dataproc_metastore_service = try(each.value.dataproc_config.virtual_cluster_config.auxiliary_services_config.metastore_config.dataproc_metastore_service, null)
            }
          }
          dynamic "spark_history_server_config" {
            for_each = try(each.value.dataproc_config.virtual_cluster_config.auxiliary_services_config.spark_history_server_config, null) == null ? [] : [""]
            content {
              dataproc_cluster = try(each.value.dataproc_config.virtual_cluster_config.auxiliary_services_config.spark_history_server_config.dataproc_cluster, null)
            }
          }
        }
      }
      dynamic "kubernetes_cluster_config" {
        for_each = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config, null) == null ? [] : [""]
        content {
          kubernetes_namespace = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.kubernetes_namespace, null)
          dynamic "kubernetes_software_config" {
            for_each = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.kubernetes_software_config, null) == null ? [] : [""]
            content {
              component_version = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.kubernetes_software_config.component_version, null)
              properties        = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.kubernetes_software_config.properties, null)
            }
          }
          dynamic "gke_cluster_config" {
            for_each = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config, null) == null ? [] : [""]
            content {
              gke_cluster_target = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.gke_cluster_target, null)
              dynamic "node_pool_target" {
                for_each = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target, null) == null ? [] : [""]
                content {
                  node_pool = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool, null)
                  roles     = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.roles, [])
                  dynamic "node_pool_config" {
                    for_each = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config, null) == null ? [] : [""]
                    content {
                      dynamic "autoscaling" {
                        for_each = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.autoscaling, null) == null ? [] : [""]
                        content {
                          min_node_count = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.autoscaling.min_node_count, null)
                          max_node_count = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.autoscaling.max_node_count, null)
                        }
                      }
                      dynamic "config" {
                        for_each = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.config, null) == null ? [] : [""]
                        content {
                          machine_type     = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.config.machine_type, null)
                          local_ssd_count  = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.config.local_ssd_count, null)
                          preemptible      = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.config.preemptible, null)
                          min_cpu_platform = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.config.min_cpu_platform, null)
                          spot             = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.config.spot, null)
                        }
                      }
                      locations = try(each.value.dataproc_config.virtual_cluster_config.kubernetes_cluster_config.gke_cluster_config.node_pool_target.node_pool_config.locations, [])
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      # Some scopes are assigned in addition to the one configured
      # https://cloud.google.com/dataproc/docs/concepts/configuring-clusters/service-accounts#dataproc_vm_access_scopes
      cluster_config[0].gce_cluster_config[0].service_account_scopes,
    ]
  }
}