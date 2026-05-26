locals {
  jobs = {
    for job in try(var.dataflow_flex_template.spec, []) : job.name => {
      name                  = job.name
      region                = try(job.region, var.dataflow_flex_template_default.region, var.region)
      template_gcs_path     = job.template_gcs_path
      service_account_email = try(job.service_account_email, null)
      network               = try(job.network, var.dataflow_flex_template_default.network)
      subnetwork            = try(job.subnetwork, var.dataflow_flex_template_default.subnetwork)
      labels                = try(job.labels, var.dataflow_flex_template_default.labels)
      parameters            = try(job.parameters, var.dataflow_flex_template_default.parameters)
      finops_resource_type  = try(job.finops_resource_type, var.dataflow_flex_template_default.finops_resource_type)
      ip_configuration      = try(job.ip_configuration, var.dataflow_flex_template_default.ip_configuration) # <-- ADD THIS
    }
  }

  # Build the spec list to pass to the finops_labels submodule
  finops_specs = [
    for job in local.jobs : {
      resource_type = job.finops_resource_type
      name          = "${job.finops_resource_type}/${job.name}"
      resource_name = job.name
      input_labels  = job.labels
    }
  ]
}
