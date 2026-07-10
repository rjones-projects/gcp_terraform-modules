variable "vpc_peering" {
  description = <<-EOT
    VPC peering configuration from project YAML. Each spec item creates one bidirectional
    peering pair (local -> peer, and optionally peer -> local).

    Example:
      vpc_peering:
        spec:
          - name: "runner-nonlive"
            local_network: "projects/alpha-etl/global/networks/alpha-etl-vpc"
            peer_network: "projects/vf-nwp-cntr-nonlive/global/networks/runner-vpc"
            peer_create_peering: false
            routes_config:
              local: { import: true, export: true }
  EOT
  type = object({
    spec = optional(list(any), [])
  })
  default = {
    spec = []
  }
  nullable = false
}

variable "vpc_peering_default" {
  description = "Default values merged into each vpc_peering spec item."
  type = object({
    prefix              = optional(string)
    peer_create_peering = bool
    stack_type          = optional(string)
    peering_names = optional(object({
      local = optional(string)
      peer  = optional(string)
    }))
    routes_config = object({
      local = object({
        export        = bool
        import        = bool
        public_export = optional(bool)
        public_import = optional(bool)
      })
      peer = object({
        export        = bool
        import        = bool
        public_export = optional(bool)
        public_import = optional(bool)
      })
    })
  })
  default = {
    prefix              = null
    peer_create_peering = true
    stack_type          = null
    peering_names       = {}
    routes_config = {
      local = {
        export        = true
        import        = true
        public_export = null
        public_import = null
      }
      peer = {
        export        = true
        import        = true
        public_export = null
        public_import = null
      }
    }
  }
  nullable = false
}
