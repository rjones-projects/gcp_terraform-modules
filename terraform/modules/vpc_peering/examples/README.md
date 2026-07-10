# vpc_peering examples

| File | Description |
|------|-------------|
| `basic.yaml` | Same-project peering between local NGDI VPC and an existing second VPC. |
| `cross-project-runner.yaml` | Platform ETL to `vf-nwp-cntr-nonlive` runner VPC (remote peering often managed by NWP). |
| `multiple-peerings.yaml` | Two peerings in one `vpc_peering.spec` list. |

Peering names must be ≤ 63 characters unless `peering_names.local` / `peering_names.peer` are set.

**Multiple peerings:** You can list many entries under one `vpc_peering` block. If they share the same `local_network`, serialize applies (`-parallelism=1`) or use separate `vpc_peering` module blocks with YAML `depends_on`. See [Fabric multiple peerings](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/modules/net-vpc-peering#multiple-peerings).
