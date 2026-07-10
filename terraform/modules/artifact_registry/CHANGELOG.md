# Changelog

All notable changes to this project will be documented in this file.

## [1.0.6] - 2026-06-24
### Fixed
- Use `try()` for optional `remote` attributes (`public_repository`, `custom_repository`) so docker remote repos with only one upstream type plan successfully.

## [1.0.5] - 2026-05-18
### Added
- Fixed issue with IAM bindings

## [1.0.4] - 2026-02-25
### Added
- Updated test.yaml

## [1.0.3] - 2026-02-19
### Added
- Updated labels to use user-defined labels as FinOps labels not applicable.

## [1.0.2] - 2026-02-18
### Added
- Added correct terraform version to each file. 
- Renamed IAM resources to more appropriate names.
### Removed
- Removed unnecessary comments.

## [1.0.1] - 2026-02-12
### Added
- Added artifact registry module, testing to be done.