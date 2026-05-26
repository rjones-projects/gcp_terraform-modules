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
- Initial release of the `external_global_loadbalancer` module.
- Manage Google Cloud external global HTTP/HTTPS Application Load Balancers via `google_compute_global_forwarding_rule`, `google_compute_backend_service`, `google_compute_url_map`, and related resources.
- Support creating multiple load balancers in one go via `spec` list in project.yaml.
- Support HTTP and HTTPS protocols.
- Support classic and non-classic (EXTERNAL_MANAGED) load balancers.
- Integrated `finops_labels` policy module to generate validated FinOps labels for networking resources.
- Extended `external_global_loadbalancer` spec to accept `finops_resource_type` and `labels` (FinOps inputs).
- Integration with `external_global_address` module outputs for address references by name.
- Support for health checks (HTTP, HTTPS, TCP).
- Support for backend services with instance groups.
- Support for URL maps with host rules and path matchers.
- Examples: `examples/basic.yaml`, `examples/multiple.yaml`.
- Test fixture: `test/external-global-loadbalancer-basic.yaml` and `test/main.tf`.
