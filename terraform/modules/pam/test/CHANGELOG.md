# Changelog

All notable changes to this module will be documented in this file.

## [1.1.2] - 2026-03-03
### Changed
- Confirmed test coverage for multiple entitlements per `pam.spec` and multiple role bindings per entitlement against the stabilized module implementation.

## [1.1.1] - 2026-03-03
### Changed
- Extended test configuration to cover multiple entitlements with multiple role bindings and align with the updated PAM module behavior.

## [1.1.0] - 2026-03-03
### Changed
- Updated test harness to configure two PAM entitlements in `pam.spec` and validate the multi-entitlement behavior.

## [1.0.0] - 2026-02-24
### Added
- Initial release of the `pam` module.
- Wraps Google Cloud Privileged Access Manager entitlement configuration using Vodafone NGDI module patterns.
- Supports configuration via `project.yaml` and `yaml_to_tfvars.py` under a `pam` key.
- Allows multiple entitlement requesters, multiple approvers, and multiple role bindings per entitlement.
- Provides example config in `examples/basic.yaml` and a simple Terraform test harness in `test/main.tf`.

