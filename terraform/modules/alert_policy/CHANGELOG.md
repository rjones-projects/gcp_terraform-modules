# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-03-02
### Added
- Rebuilt `alert_policy` to be compliant with the `yaml_to_tfvars.py` standard structure.
- Introduced loop iteration via `spec` for multi-alert configurations.
- Handled backwards compatibility for existing log metrics and direct alert creation logic.
- Integrated `finops_labels` module for dynamic cost tagging.