# Changelog

All notable changes to this project will be documented in this file.

## [1.0.3] - 2026-03-02
### Removed
- Removed unnecessary files 

## [1.0.2] - 2026-02-27
### Updated
- Updated examples

## [1.0.1] - 2026-02-25
### Updated
- Updated test.yaml

## [1.0.0] - 2026-02-20
### Added
- Initial release of the `external_global_address` module.
- Manage Google Cloud external global IP addresses via `google_compute_global_address`.
- Support creating multiple addresses in one go via `spec` list in project.yaml.
- Optional fields per address: `name`, `address`, `description`, `labels`, `ip_version`.
- Integrated `finops_labels` policy module to generate validated FinOps labels for networking resources.
- Extended `external_global_address` spec to accept `finops_resource_type` and `labels` (FinOps inputs).
- Examples: `examples/basic.yaml`, `examples/multiple.yaml`.
- Test fixture: `test/external-global-address-multiple.yaml` and `test/main.tf`.
