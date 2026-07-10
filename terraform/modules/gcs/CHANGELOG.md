# Changelog

All notable changes to this project will be documented in this file.

## [1.1.10] - 2026-06-23
### Added
- gcs CMEK OPA rule now evaluates all bucket plan actions except delete, so existing buckets without a CMEK key are flagged

## [1.1.9] - 2026-06-23
### Added
- Added OPA policy enforcing CMEK on GCS buckets: denies any 'google_storage_bucket' created or updated without 'kms_key_name'

## [1.1.8] - 2026-06-03
### Fixed
- Fixed an issue with public_access_prevention 

## [1.1.7] - 2026-06-02
### Added
- Added option for public_access_prevention, this can either be inherited or enforced

## [1.1.6] - 2026-05-11
### Updated
- Fixed issue with IAM bindings when there were multiple bindings for one bucket
- Updated examples
- Expanded tests

## [1.1.5] - 2026-02-27
### Updated
- Updated examples

## [1.1.4] - 2026-02-25
### Updated
- Updated test.yaml

## [1.1.3] - 2026-02-19
### Updated
- updated terraform version to 7.17 and higher in versions.tf

## [1.1.2] - 2026-02-17
### Removed
- removed provider.tf file as empty
### Updated
- updated terraform version to 7.18 and higher in versions.tf

## [1.1.1] - 2026-02-13
### Added
- change the reference from finops-labels to finops_labels

## [1.1.0] - 2026-02-13
### Added
- Integrated `finops_labels` module for GCS bucket labels and updated `locals.tf`/`main.tf` to consume only FinOps-derived labels.
- Updated GCS examples, tests, and `USEME.md` to show FinOps configuration (`finops-lables` block, `finops_resource_type`, and FinOps label keys).
- Documented FinOps usage in `README.md`.

## [1.0.1] - 2026-02-12
### Added
- Added gcs module, testing to be done.