variable "project_id" {
  description = "Project id where SSL Policy will be created."
  type        = string
}

variable "ssl_policy" {
  description = "SSL Policy configuration object passed from YAML. Must contain a 'spec' field with a list of policy definitions"
  type        = any
}

variable "ssl_policy_default" {
  description = "A SSL Policy object to be merged into"
  type = object({
    name        = string
    profile     = string
    tls_version = string
  })
  default = {
    name        = "strict-ssl-policy"
    profile     = "RESTRICTED"
    tls_version = "TLS_1_2"
  }
}