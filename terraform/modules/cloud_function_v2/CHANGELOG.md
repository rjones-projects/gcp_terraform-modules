# Changelog

All notable changes to this project will be documented in this file.

## [1.0.7] - 2026-06-10
### Changed
- Changed memory to allow greater range of potential values

## [1.0.6] - 2026-05-22
### Added
- HTTP trigger support: detect `trigger_config.http: true` and deploy without `event_trigger` (invoke via `service_config.uri` and `roles/run.invoker`)
- Optional `allow_unauthenticated` on `trigger_config` grants `allUsers` the Cloud Run invoker role when set

### Fixed
- Skip `event_trigger` for HTTP-triggered functions (Gen2 HTTP uses Cloud Run URL, not Eventarc)
- Skip additive `roles/run.invoker` member when `trigger_service_account_email` is unset

## [1.0.5] - 2026-03-20
### Fixed
- Fixed an issue with naming functions without a prefix

## [1.0.4] - 2026-03-16
### Added
- Updated TF code to remove requirement to have every value present in YAML
- Added extra test cases

### Updated
- Updated module name from cloud-function-v2 to cloud_function_v2 to match other modules
- Updated examples to reflect changes

## [1.0.3] - 2026-03-12
### Updated
- Updated event filters

## [1.0.2] - 2026-02-27
### Updated
- Updated examples

## [1.0.1] - 2026-02-25
### Updated
- Updated test.yaml

## [1.0.0] - 2026-02-18
### Added
- Added cloud-function-v2 module.
