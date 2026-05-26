locals {
  cloud_schedulers = {
    for spec in try(var.cloud_scheduler.spec, []) : try(spec.name, var.cloud_scheduler_default.name) => {
      name             = try(spec.name, var.cloud_scheduler_default.name)
      description      = try(spec.description, var.cloud_scheduler_default.description)
      schedule         = try(spec.schedule, var.cloud_scheduler_default.schedule)
      time_zone        = try(spec.time_zone, var.cloud_scheduler_default.time_zone)
      attempt_deadline = try(spec.attempt_deadline, var.cloud_scheduler_default.attempt_deadline)
      http_target      = try(spec.http_target, var.cloud_scheduler_default.http_target)
      retry_config     = try(spec.retry_config, var.cloud_scheduler_default.retry_config)
    }
  }
}