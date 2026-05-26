variable "project_id" {
  description = "The project ID to deploy the security policy"
  type        = string
}

variable "vf_security_policy" {
  description = "VF security policy configurations"
  type        = any
  default     = {}
}

variable "vf_security_policy_default" {
  description = "A VF security policy object to be merged into"
  type = object({
    name                         = string
    description                  = string
    type                         = string
    enable_layer_7_ddos_defense  = bool
    layer_7_ddos_rule_visibility = string
    default_rule_action          = string
    enable_waf                   = bool
    waf_components = list(object({
      expression  = string
      description = string
    }))
    enable_custom_rules = bool
    custom_waf_components = list(object({
      action      = string
      expression  = string
      description = string
    }))
    authorised_networks = list(object({
      cidr_ranges = list(string)
      description = string
    }))
    additional_networks = list(object({
      cidr_ranges = list(string)
      description = string
    }))
    custom_rules = list(object({
      priority      = number
      action        = string
      description   = optional(string)
      preview       = optional(bool, false)
      expression    = optional(string, "")
      src_ip_ranges = optional(list(string), ["*"])
    }))
    enable_ssl_policy = bool
    ssl_policy_name   = string
  })
  default = {
    name                         = null
    description                  = "Cloud Armor security policy"
    type                         = "CLOUD_ARMOR"
    enable_layer_7_ddos_defense  = false
    layer_7_ddos_rule_visibility = "STANDARD"
    default_rule_action          = "deny(404)"
    enable_waf                   = false
    waf_components = [
      {
        description = "SQL injection",
        expression  = "sqli-stable",
      },
      {
        description = "Cross-site scripting",
        expression  = "xss-stable",
      },
      {
        description = "Local file inclusion",
        expression  = "lfi-stable",
      },
      {
        description = "Remote file inclusion",
        expression  = "rfi-stable",
      },
      {
        description = "Remote code execution",
        expression  = "rce-stable",
      },
      {
        description = "Method enforcement",
        expression  = "methodenforcement-stable",
      },
      {
        description = "Scanner detection",
        expression  = "scannerdetection-stable",
      },
      {
        description = "Protocol attack",
        expression  = "protocolattack-stable",
      },
      {
        description = "PHP injection attack",
        expression  = "php-stable",
      },
      {
        description = "Session fixation attack",
        expression  = "sessionfixation-stable",
      },
      {
        description = "Apache Log4J CVE-2021-44228 vulnerability",
        expression  = "cve-canary",
      },
    ]
    enable_custom_rules   = false
    custom_waf_components = []
    authorised_networks = [
      {
        description = "GDC",
        cidr_ranges = ["200.10.10.10/32", "195.233.26.86/32", "195.233.250.6/32"],
      },
      {
        description = "Portugal offices",
        cidr_ranges = ["212.18.162.33/32", "213.30.78.168/30", "213.30.78.172/32"],
      },
      {
        description = "UK offices",
        cidr_ranges = ["195.233.26.80/28", "85.205.122.128/28", "185.69.146.224/29", "185.69.146.240/29", "85.115.52.0/24", "85.115.53.0/24", "85.115.54.0/24", "195.89.11.0/25", "194.62.232.0/24"]

      },
      {
        description = "India offices 1",
        cidr_ranges = ["121.200.57.84/32", "121.200.57.13/32", "121.200.57.14/32", "121.200.57.85/32"],
      },
      {
        description = "Spain offices",
        cidr_ranges = ["212.166.209.18/32", "62.87.30.66/32"],
      },
      {
        description = "Italy offices",
        cidr_ranges = ["195.232.147.116/30", "195.232.147.120/31"],
      },
      {
        description = "Hungary offices CRQ000030213407",
        cidr_ranges = ["80.244.96.53/32"],
      },
      {
        description = "Romania offices CRQ000030265158 1",
        cidr_ranges = ["46.97.128.35/32", "81.12.134.18/32", "81.12.134.70/32", "81.12.134.71/32", "81.12.134.72/32"],
      },
      {
        description = "Ireland offices CRQ000030284048",
        cidr_ranges = ["213.233.159.69/32"],
      },

      {
        description = "Office Proxies of VOIS Egypt",
        cidr_ranges = ["62.68.247.20/32", "102.221.68.0/22", "102.221.70.4/32"],
      },
      {
        description = "Allow Greece Offices",
        cidr_ranges = ["213.249.56.36/32"]
      }
    ]
    additional_networks = []
    custom_rules        = []
    enable_ssl_policy   = true
    ssl_policy_name     = "strict-ssl-policy"
  }
}