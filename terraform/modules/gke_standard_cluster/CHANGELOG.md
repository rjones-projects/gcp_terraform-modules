# Changelog

All notable changes to this project will be documented in this file.

## [1.2.3] - 2026-06-25
### Added
- Optional `enable_k8s_tokens_via_dns` and `enable_k8s_certs_via_dns` (bool, default `false`) on cluster spec. When `enable_dns_endpoint = true`, these map to `dns_endpoint_config` so clients (e.g. `gke-gcloud-auth-plugin` in CI) can obtain tokens and the cluster CA via the DNS endpoint.

### Fixed
- When `enable_dns_endpoint = true`, emit all `dns_endpoint_config` fields explicitly (`allow_external_traffic`, `enable_k8s_tokens_via_dns`, `enable_k8s_certs_via_dns`) so provider `>= 7.29.0` includes them in API updates.

## [1.2.2] - 2026-06-23
### Added
- ignore version on primary_node_pool

## [1.2.1] - 2026-06-22
### Updated
- Raised minimum `google` / `google-beta` provider to `>= 7.29.0`. Versions below 7.29.0 silently drop `control_plane_endpoints_config.dns_endpoint_config.allow_external_traffic = false` on update, so private DNS endpoints (`enable_dns_endpoint = true`, `dns_endpoint_allow_external_traffic = false`) never get enabled. See hashicorp/terraform-provider-google#26126.

## [1.2.0] - 2026-06-22
### Added
- Optional `enable_dns_endpoint` (bool, default `false`) on cluster spec. When `true`, emits `control_plane_endpoints_config.dns_endpoint_config`, exposing the API server over a Google-managed DNS name resolved via the Google APIs path and gated by IAM (`container.clusters.connect`). This lets clients in other VPCs/projects (e.g. a cross-project Argo CD control plane) reach a private control plane without IP allow-lists or VPC peering.
- Optional `dns_endpoint_allow_external_traffic` (bool, default `false`). Left `false`, the DNS endpoint is reachable only from within Google Cloud (Private Google Access) and never from the public internet, keeping the cluster private. Only relevant when `enable_dns_endpoint = true`.
- New `dns_endpoints` output exposing the per-cluster DNS endpoint (empty string when not enabled) for use as the Argo CD cluster server URL.

## [1.1.0] - 2026-06-10
### Added
- Enable the GKE Secret Manager add-on (`secret_manager_config`) by default via `enable_secret_manager_addon`.
- Enable Secret Manager to Kubernetes Secret synchronization (`secret_sync_config`) by default, with optional rotation settings.

## [1.0.4] - 2026-06-03
### Added
- Optional `master_authorized_networks` list on cluster spec to allow multiple authorized CIDR blocks (for example CI runner NAT and source subnets) while keeping `management_zone_cidr_range` as the single-CIDR fallback.

## [1.0.3] - 2026-03-27
### Updated
- Updated labels

## [1.0.2] - 2026-03-25
### Updated
- Fixed variable error in tests and examples

## [1.0.1] - 2026-03-23
### Added
- updated gke_standard_cluster module from orchestrate to be YAML compatible

## [1.0.0] - 2026-03-06
### Added
- updated gke_standard_cluster module from orchestrate to be YAML compatible
- Added README
- Added VERSION
- Added tests
- Added examples