variable "project_id" {
  description = "GCP project ID."
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py; global load balancers are not region-scoped)."
  type        = string
  default     = null
}

variable "external_global_loadbalancer" {
  description = "External global load balancer configuration from project.yaml. Must contain a 'spec' list of load balancer definitions."
  type        = any
  default = {
    spec = []
  }
}
