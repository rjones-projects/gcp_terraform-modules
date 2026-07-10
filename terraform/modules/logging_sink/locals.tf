locals {
  sinks = {
    for spec in try(var.logging_sink.spec, []) : try(spec.name, var.sink_default.name) => {
      name        = try(spec.name, var.sink_default.name)
      description = try(spec.description, var.sink_default.description)
      destination = try(spec.destination, var.sink_default.destination)
      dataset_id  = try(spec.dataset_id, var.sink_default.dataset_id)
      filter      = try(spec.filter, var.sink_default.filter)
    }
  }
}