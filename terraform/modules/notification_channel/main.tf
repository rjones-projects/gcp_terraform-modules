module "finops_labels" {
  source = "../finops_labels"

  finops_labels = {
    spec = local.finops_specs
  }
}

resource "google_monitoring_notification_channel" "notification_channel" {
  for_each = local.channels

  project      = var.project_id
  display_name = each.value.display_name
  type         = each.value.type

  # Channel configuration labels (e.g., email_address)
  labels = each.value.type == "email" ? {
    email_address = each.value.email_address
  } : {}

  # FinOps and business labels
  user_labels = try(
    module.finops_labels.labels["${each.value.finops_resource_type}/${each.value.name}"],
    {}
  )

  lifecycle {
    create_before_destroy = true
  }
}
