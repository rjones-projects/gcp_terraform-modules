# vpc_peering

Creates [VPC Network Peering](https://cloud.google.com/vpc/docs/vpc-peering) between two VPCs. Each YAML `spec` item manages:

- one peering from `local_network` → `peer_network`
- optionally one peering from `peer_network` → `local_network` when `peer_create_peering` is `true`

Implementation follows [cloud-foundation-fabric `net-vpc-peering`](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-vpc-peering).

## YAML spec

```yaml
vpc_peering:
  source:
    version: v1.0.0
  depends_on:
    - network
  spec:
    - name: "runner-nonlive"
      prefix: "ngdi"
      local_network: "projects/my-etl/global/networks/my-etl-vpc"
      peer_network: "projects/vf-nwp-cntr-nonlive/global/networks/runner-vpc"
      peer_create_peering: false
      routes_config:
        local: { import: true, export: true }
        peer:  { import: true, export: true }
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | yes | Unique key for this peering in the module |
| `local_network` | yes | Network self link to peer from |
| `peer_network` | yes | Remote network self link |
| `prefix` | no | Prefix for auto-generated peering names |
| `peer_create_peering` | no | Create return peering on peer VPC (default `true`) |
| `peering_names` | no | Override `local` / `peer` peering resource names (max 63 chars) |
| `routes_config` | no | Import/export flags for local and peer sides |
| `stack_type` | no | `IPV4_ONLY` or `IPV4_IPV6` |
Use with `gke_standard_cluster` `master_authorized_networks` for API allowlists; this module provides L3 connectivity only.

## Multiple peerings in one project

Yes. Add several items under `vpc_peering.spec` (each needs a unique `name`). One module creates all of them in a single Terraform apply.

| Scenario | Guidance |
|----------|----------|
| Different `local_network` per spec item | Safe in one apply (parallel local peerings on different VPCs). |
| Same `local_network`, multiple `peer_network` values | GCP allows only **one peering operation at a time** on that VPC. Use `terraform apply -parallelism=1`, two applies, or two `vpc_peering` YAML blocks with `depends_on` between modules. |
| Cross-project return peering | Set `peer_create_peering: false` when the remote project owns the reverse peering. |

See `examples/multiple-peerings.yaml`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.17.0, < 8.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network_peering.local_network_peering](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.peer_network_peering](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID (accepted for compatibility with yaml\_to\_tfvars.py; peering uses network self links). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region (accepted for compatibility with yaml\_to\_tfvars.py but not used by this module). | `string` | `null` | no |
| <a name="input_vpc_peering"></a> [vpc\_peering](#input\_vpc\_peering) | VPC peering configuration from project YAML. Each spec item creates one bidirectional<br/>peering pair (local -> peer, and optionally peer -> local).<br/><br/>Example:<br/>  vpc\_peering:<br/>    spec:<br/>      - name: "runner-nonlive"<br/>        local\_network: "projects/alpha-etl/global/networks/alpha-etl-vpc"<br/>        peer\_network: "projects/vf-nwp-cntr-nonlive/global/networks/runner-vpc"<br/>        peer\_create\_peering: false<br/>        routes\_config:<br/>          local: { import: true, export: true } | <pre>object({<br/>    spec = optional(list(any), [])<br/>  })</pre> | <pre>{<br/>  "spec": []<br/>}</pre> | no |
| <a name="input_vpc_peering_default"></a> [vpc\_peering\_default](#input\_vpc\_peering\_default) | Default values merged into each vpc\_peering spec item. | <pre>object({<br/>    prefix              = optional(string)<br/>    peer_create_peering = bool<br/>    stack_type          = optional(string)<br/>    peering_names = optional(object({<br/>      local = optional(string)<br/>      peer  = optional(string)<br/>    }))<br/>    routes_config = object({<br/>      local = object({<br/>        export        = bool<br/>        import        = bool<br/>        public_export = optional(bool)<br/>        public_import = optional(bool)<br/>      })<br/>      peer = object({<br/>        export        = bool<br/>        import        = bool<br/>        public_export = optional(bool)<br/>        public_import = optional(bool)<br/>      })<br/>    })<br/>  })</pre> | <pre>{<br/>  "peer_create_peering": true,<br/>  "peering_names": {},<br/>  "prefix": null,<br/>  "routes_config": {<br/>    "local": {<br/>      "export": true,<br/>      "import": true,<br/>      "public_export": null,<br/>      "public_import": null<br/>    },<br/>    "peer": {<br/>      "export": true,<br/>      "import": true,<br/>      "public_export": null,<br/>      "public_import": null<br/>    }<br/>  },<br/>  "stack_type": null<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_local_network_peering_names"></a> [local\_network\_peering\_names](#output\_local\_network\_peering\_names) | Map of local peering resource names keyed by spec name. |
| <a name="output_local_network_peerings"></a> [local\_network\_peerings](#output\_local\_network\_peerings) | Map of local-side network peering resources keyed by spec name. |
| <a name="output_peer_network_peering_names"></a> [peer\_network\_peering\_names](#output\_peer\_network\_peering\_names) | Map of peer peering resource names keyed by spec name. |
| <a name="output_peer_network_peerings"></a> [peer\_network\_peerings](#output\_peer\_network\_peerings) | Map of peer-side network peering resources keyed by spec name (only when peer\_create\_peering is true). |
<!-- END_TF_DOCS -->
