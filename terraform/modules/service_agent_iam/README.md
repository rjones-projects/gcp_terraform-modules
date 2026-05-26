# Service Agent IAM module

This module manages **Google-managed Service Accounts (Service Agents)** and their IAM bindings for a single Google Cloud project. It is designed to be driven from `project_config.yaml` using `yaml_to_tfvars.py`.

It utilizes `google_project_service_identity` to ensure the agent is safely provisioned before attempting to attach roles, avoiding "User not found" race conditions.

## YAML-driven usage

Declare a `service_agent_iam` block and pass a `spec` list. Each entry requires a `service` URL and a list of `roles`.

```yaml
service_agent_iam:
  source:
    version: v1.0.0
  depends_on: []
  spec:
    - service: "storage.googleapis.com"
      roles:
        - "roles/pubsub.publisher"