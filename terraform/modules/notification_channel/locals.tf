locals {
  channels = {
    for spec in try(var.notification_channel.spec, []) : try(spec.name, spec.email_address) => {
      name                 = try(spec.name, spec.email_address)
      display_name         = try(spec.display_name, "Notification channel for ${spec.email_address}")
      type                 = try(spec.type, var.notification_channel_default.type)
      email_address        = try(spec.email_address, var.notification_channel_default.email_address)
      finops_resource_type = coalesce(try(spec.finops_resource_type, null), var.notification_channel_default.finops_resource_type)
      labels               = try(spec.labels, var.notification_channel_default.labels)
    }
  }

  finops_specs = [
    for channel in local.channels : {
      resource_type = channel.finops_resource_type
      name          = "${channel.finops_resource_type}/${channel.name}"
      resource_name = channel.name
      input_labels  = channel.labels
    }
  ]
}
