variable "project_id" {
  description = "GCP project ID."
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py and used as default for connectors)."
  type        = string
  default     = null
}

variable "vpc_connector" {
  description = "VPC Access Connector configuration object passed from YAML. Must contain a 'spec' field with a list of connector definitions."
  type        = any
  default = {
    spec = []
  }

  validation {
    condition = alltrue([
      for item in try(var.vpc_connector.spec, []) : (
        try(item.machine_type, null) == null ||
        contains(["f1-micro", "e2-micro", "e2-standard-4"], item.machine_type)
      )
    ])
    error_message = "vpc_connector.spec[*].machine_type must be one of: f1-micro, e2-micro, e2-standard-4."
  }
}

