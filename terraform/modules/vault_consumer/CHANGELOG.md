# Changelog

All notable changes to this project will be documented in this file.

## [1.0.3] - 2026-06-23

### Added

- Added support for "beta" environment as alias for nonlive Vault instance

### Fixed

- Fixed invalid index error when using environment = "beta"

## [1.0.2] - 2026-06-23

### Changed

- Removed `null_resource` with `local-exec` provisioner (anti-pattern)
- DNS peering export now via output commands (manual step)
- Added `dns_peering_export_commands` output for users to execute manually
- Updated README with DNS peering export documentation

## [1.0.1] - 2026-06-23

### Added

- Added top-level `project_id` and `region` variables for simpler module usage
- Module now supports both simple and complex usage patterns

### Changed

- Updated locals.tf to handle module argument input with or without spec array
- Updated README with examples for both simple and multi-environment usage

## [1.0.0] - 2026-06-22

### Added

- Initial release of vault_consumer module following NGDI pattern
- Support for multiple Vault environments (live/nonlive) via environment configuration lookup
- Private DNS managed zone creation for Vault endpoints
- DNS A record registration with configurable TTL
- Egress firewall rule with optional logging for Vault IP whitelist
- Custom IAM role (vault_gcp_auth) with Vault GCP auth permissions
- Service account IAM role binding to Vault service account
- Optional DNS peering export via gcloud CLI
- Support for multi-project deployments via spec array
- Comprehensive outputs for all created resources
