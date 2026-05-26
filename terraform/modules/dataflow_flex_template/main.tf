module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_dataflow_flex_template_job" "jobs" {
  for_each = local.jobs

  provider                = google-beta
  project                 = var.project_id
  region                  = each.value.region
  name                    = each.value.name
  container_spec_gcs_path = each.value.template_gcs_path
  service_account_email   = each.value.service_account_email

  parameters = each.value.parameters

  labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )

  network = each.value.network

  subnetwork = each.value.subnetwork != null ? (
    length(regexall("/", each.value.subnetwork)) > 0 ?
    each.value.subnetwork :
    "regions/${each.value.region}/subnetworks/${each.value.subnetwork}"
  ) : null

  ip_configuration = each.value.ip_configuration
}
