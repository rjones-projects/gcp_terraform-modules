# Notification Channel Module

This module simplifies the creation of Google Cloud Monitoring Notification Channels from a centralized YAML `spec` configuration via `yaml_to_tfvars.py`.

It integrates with the `finops_labels` policy module to generate validated FinOps labels, placing them in `user_labels` to ensure they don't conflict with the channel configuration `labels` (which define the actual email address).

## Usage with `project.yaml`

```yaml
notification_channel:
  source: "../modules/notification_channel"
  depends_on:
    - finops_labels
  spec:
    - name: "cloud-analytics-team"
      display_name: "Cloud Analytics Support"
      email_address: "cloud-analytics-team@vodafone.com"
      finops_resource_type: "notification_channel"
      labels:
        vf_ngdi_environment: "alpha"
        vf_ngdi_shared: "true"
        
    - name: "neds-support"
      email_address: "neds-support@vodafone.com"
      labels:
        vf_ngdi_environment: "alpha"