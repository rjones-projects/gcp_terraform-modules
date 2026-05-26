# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-03-19
### Added
- Added FinOps labels integration for KMS keys via `finops_labels`.
- Added support for per-key `finops_resource_type` (with module-level default).

### Changed
- KMS project and region now resolve directly from declared `project_id` and `region`.

### Removed
- Removed `context` feature from the KMS module (IAM/tag remapping and IAM condition templating).

## [1.0.3] - 2026-02-27
### Updated
- Updated examples

## [1.0.2] - 2026-02-25
### Updated
- Updated test.yaml

## [1.0.1] - 2026-02-25
### Added
- Removed unnecessary comments
- Removed google meta providers in versions.tf

## [1.0.0] - 2026-02-10
### Added
- Added kms module.
