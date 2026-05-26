
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "project_services" {
  description = "Project services config with specs"
  type        = any
  default     = ""
}

variable "service_default" {
  description = "A service object to be merged into"
  type = object({
    service_list = list(string)
    service_config = object({
      disable_on_destroy         = bool
      disable_dependent_services = bool
    })

  })

  default = {
    service_list = [
      "compute.googleapis.com"
    ]

    service_config = {
      disable_on_destroy         = false
      disable_dependent_services = false
    }
  }
}

/* labels aren't used yet for the module
variable "labels" {
  description = "Resource labels"
  type = object({
    org       = string
    app       = string
    iac       = string
    component = string
    env       = string
  })
  default = {
    org       = "vf"
    app       = "ngdi"
    iac       = "terraform"
    component = "backend"
    env       = "dev"
  }
}
*/


