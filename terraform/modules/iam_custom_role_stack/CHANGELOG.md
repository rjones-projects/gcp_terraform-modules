# Changelog

All notable changes to this project will be documented in this file.

## [1.0.4] - 2026-04-13
### Fixed
- Exclude `iam.googleapis.com/workforcePoolProviderKeys.create` from merged permissions so project custom role creation succeeds when `roles/iam.admin` is expanded (GCP rejects this permission in project custom roles).

### Updated
- Regenerated `README.md` (terraform-docs) and bumped example/test module pins.

## [1.0.2] - 2026-04-10
### Updated
- Fixed issue with base permissions not applying
- Updated tests and examples

## [1.0.1] - 2026-04-07
### Updated
- Updated defaults to include default role set

## [1.0.0] - 2026-03-31
### Added
- Updated iam_custom_role_stack module from orchestrate to be YAML compatible
- Added README
- Added VERSION
- Added tests
- Added examples