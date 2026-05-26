# GCP Alerting Module

This module simplifies the creation of multiple Google Cloud Platform (GCP) Alert Policies and optional Log-based Metrics from a centralized YAML `spec` configuration via `yaml_to_tfvars.py`.

It integrates with the `finops_labels` policy module to generate validated FinOps labels for alerting resources.

## Features
- Create standard GCP Metric-based alerts.
- Optional creation of log-based metrics seamlessly tied to alerts (enabled via `create_metric: true`).
- Supports aggregations, duration mapping, and notification routing out-of-the-box.
- Support creating multiple alerts in one go via `spec` list in `project.yaml`.

## Usage with `project.yaml`

```yaml
alert_policy:
  source: "../modules/alert_policy"
  depends_on:
    - finops_labels
  spec:
    # 1. Standard GCP Monitoring Metric-based Alert
    - alert_name: "P3_SQL_High_CPU_Usage"
      alert_filter: 'resource.type = "cloudsql_database" AND metric.type = "[cloudsql.googleapis.com/database/cpu/utilization](https://cloudsql.googleapis.com/database/cpu/utilization)"'
      alert_combiner: "OR"
      alert_duration: "0s"
      alert_threshold: "0.9"
      alert_alignment: "300s"
      custom_metric_kind: "GAUGE"
      alert_comparison: "COMPARISON_GT"
      alert_aligner: "ALIGN_MEAN"
      trigger_count: "1"
      alert_doc: "Cloud SQL CPU utilization threshold has breached."
      notification_channels: 
        - "projects/my-project/notificationChannels/16990596901635594246"

    # 2. Log-based metric and alert
    - alert_name: "P3_K8s_Pod_failed_liveness"
      create_metric: true
      metric_name: "pod-metric"
      custom_metric_filter: 'resource.type = "k8s_pod" jsonPayload.message =~ "connection refused"'
      custom_metric_kind: "DELTA"
      custom_metric_type: "INT64"
      alert_filter: 'resource.type = "k8s_pod" AND metric.type="[logging.googleapis.com/user/pod-metric](https://logging.googleapis.com/user/pod-metric)"'
      alert_combiner: "OR"
      alert_threshold: "10"
      alert_alignment: "600s"
      alert_comparison: "COMPARISON_GT"
      alert_aligner: "ALIGN_COUNT"
      alert_reducer: "REDUCE_COUNT"
      alert_doc: "A pod has failed liveness check"
      percent: "100"
      alert_duration: "120s"
      group_by_fields: 
        - "resource.label.pod_name"
      evaluation_missing_data: "EVALUATION_MISSING_DATA_INACTIVE"