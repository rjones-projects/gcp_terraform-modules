# Changelog

All notable changes to this project will be documented in this file.
## [1.1.2] - 2026-07-16
### Updated
- fixed iam_service_account bug


## [1.1.0] - 2026-06-05
### Updated
- Changed how project roles are assigned. Project ids can no longer be provided, project roles can only be granted in the YAML file's project, based on the project_id.
- Service account reuse is now a flag, to use an sa from another project set to true  

## [1.0.6] - 2026-05-21
### Fixed
- Fixed clash with multiple IAM bindings 

## [1.0.5] - 2026-05-21
### Fixed
- Fixed issue with IAM bindings 

## [1.0.4] - 2026-03-05
### Added
- Added IAM bindings, allows you to add users or SAs to impersonate the created sa 
- Added example showcasing new functionality

## [1.0.3] - 2026-02-24
### Added
- Updated example sa-reuse.yaml
- Removed unnecessary comments
- Updated versions

## [1.0.2] - 2026-02-17
### Added
- Added depends_on

## [1.0.1] - 2026-02-16
### Added
- Removed providers.tf file
- Updated TF versions

## [1.0.0] - 2026-02-06
### Added
- Adjusted structure to utilise for_each for YAML compatibility
- Added service_account and service_account_default variables to make module compatible YAML structure
- Added locals.tf file to store all module locals
- Adjusted locals to comply with new YAML structure
- Updated test folder with YAML compatible tests
- Changed examples to be YAML files, replacing TF files
- Updated README