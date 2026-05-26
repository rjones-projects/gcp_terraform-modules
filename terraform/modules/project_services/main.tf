resource "google_project_service" "service" {

  for_each = {
    for individual in flatten([
      for service_key, service_val in local.service_map : [
        for service_list_val in service_val.service_list : {
          service_name   = service_key
          service        = service_list_val
          service_config = service_val.service_config
        }
      ]
    ]) : "${individual.service_name}.${individual.service}" => individual
  }

  project                    = var.project_id
  service                    = each.value.service
  disable_on_destroy         = each.value.service_config.disable_on_destroy
  disable_dependent_services = each.value.service_config.disable_dependent_services
}

# Inject a 60-second delay to allow GCP to fully propagate the enabled APIs
resource "time_sleep" "wait_for_apis" {
  create_duration = "60s"

  # The triggers block ensures the delay runs whenever the list of APIs changes
  triggers = {
    services_list = join(",", keys(google_project_service.service))
  }

  # This timer will ONLY start after all API enablement calls return successfully
  depends_on = [google_project_service.service]
}
