# Changelog

All notable changes to this module will be documented in this file.

## [1.0.0] - 2026-05-18
### Added
- Initial Argo CD installation module via Helm release (argo-cd chart 9.5.14, Argo CD v3.4.x).
- Single-install design: deploys exactly one Argo CD instance per project, enforced via `argo_cd.spec` length validation (max 1 item, 0 = no-op).
- FinOps labels integration (labels applied to the managed namespace).
- Raw `helm_values` YAML pass-through for plain-text chart overrides.
- Required providers pinned to `helm >= 3.1.0, < 4.0.0` and `kubernetes >= 3.1.0, < 4.0.0` to align with the Plugin Framework rewrite.
- Examples and tests YAML compatible with `yaml_to_tfvars.py`.
