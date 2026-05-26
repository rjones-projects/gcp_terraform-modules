variable "secret_manager" {
  description = "Secret Manager module config with spec."
  type        = any
  default = {
    spec = []
  }
}

variable "project_id" {
  description = "Project id where secrets will be created."
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  description = "GCP region (accepted for compatibility with yaml_to_tfvars.py but not used by this module)."
  type        = string
  default     = null
}
