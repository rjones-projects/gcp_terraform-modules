variable "project_id" {
  type        = string
  description = "GCP Project ID."
}

variable "service_agent_iam" {
  description = "Service Agent IAM config. Expects a 'spec' list with 'service' and 'roles'."
  type        = any
  default     = null
}
