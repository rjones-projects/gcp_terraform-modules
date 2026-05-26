# Changelog

All notable changes to this project will be documented in this file.

## [1.0.4] - 2026-02-27
### Updated
- Updated examples

## [1.0.6] - 2026-03-30
### Fixed
- Render `workspace_compilation_overrides` only when at least one override value is set, preventing empty-block drift in Terraform plans.

## [1.0.5] - 2026-03-27
### Fixed
- Omit empty `workspace_compilation_overrides` inputs (default_database/schema_suffix/table_prefix) to reduce perpetual Terraform drift.

## [1.0.3] - 2026-02-25
### Updated
- Updated test.yaml

## [1.0.2] - 2026-02-17
### Added
- Updated if condition.

## [1.0.1] - 2026-02-16
### Added
- updated variable.

## [1.0.0] - 2026-02-06
### Added
- Added dataform-repository module.
