variable "project_id" {
  description = "Project ID."
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "dataflow_flex_template" {
  description = "Dataflow Flex Template object"
  type        = any
}

variable "dataflow_flex_template_default" {
  description = "Default settings for Dataflow jobs to merge into"
  type = object({
    region               = string
    network              = string
    subnetwork           = string
    labels               = map(string)
    parameters           = map(string)
    finops_resource_type = string
    ip_configuration     = string
  })
  default = {
    region               = null
    network              = null
    subnetwork           = null
    labels               = {}
    parameters           = {}
    finops_resource_type = "dataflow"
    ip_configuration     = "WORKER_IP_PRIVATE"
  }
}
