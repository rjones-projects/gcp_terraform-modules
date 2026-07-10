# Changelog

All notable changes to this project will be documented in this file.

## [1.1.12] - 2026-07-08
### Updated
- Updated default value for export_custom_routes to true
### Fixed
- Fixed issue with auto-creation of subnets

## [1.1.11] - 2026-07-07
### Added
- Added support route for  LB Healthcheck and Pkg.dev Egress with private network bypassing squid proxy rules 

## [1.1.10] - 2026-06-23
### Fixed
- Fixed an issue wtih OPA policy where deny egress warning would trigger even if network module isn't in project config 

## [1.1.9] - 2026-06-22
### Added
- Added network OPA policy file
### Removed
- Removed ability to enable auto-creation of subnets

## [1.1.8] - 2026-05-20
### Added
- Added send_secondary_ip_range_if_empty flag to subnets

## [1.1.7] - 2026-05-19
### Fixed
- Fixed issue with subnet descriptions default value clashing with state merges

## [1.1.6] - 2026-05-18
### Fixed
- Checkov CKV_GCP_74: skip policy for configurable `enable_private_access` / legacy subnet adoption (inline + `.checkov.yml`).

## [1.1.5] - 2026-05-18
### Fixed
- Subnet adoption: set default `description` to `Terraform-managed.`, wire `enable_private_access` to `private_ip_google_access`, and use VPC `self_link` for `network` to avoid unnecessary subnet replacement after migration.
- PSC peering route config defaults (`export_custom_routes`, etc.) default to `false` to match legacy fabric state; override via `network.spec` or module variables.

## [1.1.4] - 2026-05-18
### Added
- Optional per-subnet `custom_subnet_name` in `network.spec[].subnets` (and `var.subnets`) to set the GCP subnetwork name directly. When omitted, the default `{common_resource_id}-subnet-{name}` naming is unchanged.

## [1.1.3] - 2026-02-27
### Updated
- Updated examples

## [1.1.2] - 2026-02-25
### Updated
- Updated test.yaml

## [1.1.1] - 2026-02-13
### Added
- change the reference from finops-labels to finops_labels

## [1.1.0] - 2026-02-12
### Added
- Integrated `finops_labels` policy module inside `network` to generate validated FinOps labels for networking resources.
- Extended `network` spec to accept `finops_resource_type` and `labels` (FinOps inputs).

## [1.0.1] - 2026-02-10
### Added
- Fixed region error.

## [1.0.0] - 2026-02-10
### Added
- Added example network module.