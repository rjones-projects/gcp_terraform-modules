variable "project_id" {
  description = "The ID of the project where OS Login will be enabled."
  type        = string
}

variable "os_login" {
  description = "os login configurations"
  type        = any
  default     = {}
}

variable "os_login_default" {
  description = "A os login object to be merged into"
  type = object({
    enable_os_login = bool
  })
  default = {
    enable_os_login = true
  }
}