# Changelog

All notable changes to this project will be documented in this file.

### Changed

- Updated README with notification direction guidance (GCS->Pub/Sub vs Pub/Sub->GCS), supported event types, and notification fields.

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
