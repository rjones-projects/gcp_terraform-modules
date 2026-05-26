variable "vpc_connector_create" {
  description = "VPC connector network configuration. Must be provided if new VPC connector is being created."
  type = object({
    ip_cidr_range = optional(string)
    machine_type  = optional(string)
    name          = optional(string)
    network       = optional(string)
    instances = optional(object({
      max = optional(number)
      min = optional(number)
      }), {}
    )
    throughput = optional(object({
      max = optional(number)
      min = optional(number)
      }), {}
    )
    subnet = optional(object({
      name       = optional(string)
      project_id = optional(string)
    }), {})
  })
  default = null
  validation {
    condition = (
      var.vpc_connector_create == null ||
      try(var.vpc_connector_create.instances, null) != null ||
      try(var.vpc_connector_create.throughput, null) != null
    )
    error_message = "VPC connector must specify either instances or throughput."
  }
}
