# Changelog

All notable changes to this project will be documented in this file.

## [1.0.7] - 2026-06-23

### Fixed

- Fixed issue where IAM member resources attempted to modify topics/subscriptions with `ignore_creation = true`, resulting in 404 errors during apply
- Added filter to `topic_iam_binding_pairs` to skip IAM bindings for non-created topics
- Added filter to `topic_notification_pubsub_publishers` to skip publisher permissions for non-created topics

## [1.0.6] - 2026-06-10
### Added
- Added custom IAM bindings for pubsub topics

## [1.0.5] - 2026-05-15
### Added
- Fixed additional issue with IAM bindings

## [1.0.4] - 2026-05-14
### Added
- Added prefix to notifications
- Fixed issue with IAM bindings

## [1.0.3] - 2026-05-13
### Added
- Added flag that allows use of existing topics

## [1.0.2] - 2026-02-27
### Updated
- Updated examples

## [1.0.1] - 2026-02-25
### Updated
- Updated test.yaml

## [1.0.0] - 2026-02-16

### Added in 1.0.0

- Added a new `pubsub` module with YAML `spec` support for creating multiple topics and subscriptions.
- Integrated `finops_labels` so both topics and subscriptions get validated, normalized NGDI labels.
- Added YAML examples and tests for single-topic and multi-topic/module usage patterns.
