# Changelog

All notable changes to this module will be documented in this file.

## [1.1.3] - 2026-03-17
### Added
- Default role bindings for the `data-engineer` entitlement when `role_bindings` are omitted from `pam.spec`.
- Test configuration example `data-engineer` entitlement in `test/test.yaml` that relies on the module defaults instead of specifying roles explicitly.

## [1.1.2] - 2026-03-03
### Changed
- Clarified and stabilized support for multiple entitlements per `pam.spec`, with locals inlined into the module for simpler consumption.

## [1.1.1] - 2026-03-03
### Fixed
- Deduplicated PAM service agent IAM bindings for shared parents and simplified locals, resolving duplicate key errors during `terraform plan`.

## [1.1.0] - 2026-03-03
### Changed
- Updated the PAM module to support multiple entitlements per module instance by iterating over all `pam.spec` entries.
- Refactored locals and outputs to expose a map of entitlements keyed by `entitlement_id`.
- Updated examples and test configuration to demonstrate multi-entitlement usage.

## [1.0.2] - 2026-02-27
### Updated
- Updated examples

## [1.0.1] - 2026-02-25
### Updated
- Updated test.yaml

## [1.0.0] - 2026-02-24
### Added
- Initial release of the `pam` module.
- Wraps Google Cloud Privileged Access Manager entitlement configuration using Vodafone NGDI module patterns.
- Supports configuration via `project.yaml` and `yaml_to_tfvars.py` under a `pam` key.
- Allows multiple entitlement requesters, multiple approvers, and multiple role bindings per entitlement.
- Provides example config in `examples/basic.yaml` and a simple Terraform test harness in `test/main.tf`.

