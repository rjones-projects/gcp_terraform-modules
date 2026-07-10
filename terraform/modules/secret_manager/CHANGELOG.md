# Changelog

All notable changes to this project will be documented in this file.

## [1.0.5] - 2026-06-15
### Fixed
- Read `data.google_project` only when IAM bindings are configured, so CI module tests without IAM do not require Cloud Resource Manager API access.
- Remove IAM from `test/test.yaml`; IAM behaviour remains covered by `examples/iam-and-rotation.yaml`.

## [1.0.4] - 2026-06-12
### Fixed
- Use project number (not project ID) on `google_secret_manager_secret_iam_*` resources to prevent perpetual destroy/recreate drift in Terraform state.

## [1.0.3] - 2026-02-27
### Added
- fixed secret_id

## [1.0.2] - 2026-02-27
### Added
- Added test.yaml

## [1.0.1] - 2026-02-27
### Updated
- Updated examples

## [1.0.0] - 2026-02-13
### Added
- Added `secret_manager` module with support for creating multiple secrets from `secret_manager.spec`.
- Added optional random password generation, secret version creation, and IAM bindings.
- Added module documentation, examples, and test scaffold.
