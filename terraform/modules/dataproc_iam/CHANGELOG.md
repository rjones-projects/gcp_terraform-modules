# Changelog

All notable changes to this project will be documented in this file.

## [1.0.3] - 2026-02-27
### Updated
- Updated TF version to >= 1.14.0
- Updated test.yaml

## [1.0.2] - 2026-02-25
### Updated
- Updated TF version to >= 1.14.0
- Updated test.yaml

### Removed
- Removed unnecessary comments

## [1.0.1] - 2026-02-18
### Added
- Changed terraform version to have a value between 7.17.0 and 8.0.0
- Removed meta providers

## [1.0.0] - 2026-02-11
### Added
- Adjusted structure to utilise for_each for YAML compatibility
- Added dataproc_iam and dataproc_iam_default variables to make module compatible YAML structure
- Added locals.tf file to store all module locals
- Updated test folder with YAML compatible tests
- Changed examples to be YAML files, replacing TF files
- Updated README