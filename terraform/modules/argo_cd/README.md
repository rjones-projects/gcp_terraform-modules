# Argo CD (spec-based wrapper, single install)

**Install and manage a single [Argo CD](https://argo-cd.readthedocs.io/) instance on GKE (Autopilot or Standard) using the official Argo CD Helm chart, integrated with the project-config / `yaml_to_tfvars.py` pattern.**

This module:

- deploys exactly **one** Argo CD installation per project (enforced via variable validation),
- pins to the `argo-cd` Helm chart (default `9.5.14`, Argo CD v3.4.x),
- accepts plain-text Helm `values` from YAML — no SOPS/KMS dependency,
- manages the Argo CD namespace explicitly so FinOps labels can be applied,
- integrates with the central `finops_labels` module.

If `argo_cd.spec` is empty or omitted the module is a no-op (`enabled = false`); declaring more than one `spec` item fails validation.

It is consumed by the orchestrator-generated `deploy/main.tf` like any other NGDI module:

```hcl
module "argo_cd" {
  source     = "../../../terraform/modules/argo_cd"
  project_id = var.project_id
  region     = var.region
  argo_cd    = var.argo_cd
  depends_on = [module.gke_autopilot_cluster]
}
```

## Provider wiring

The Argo CD module declares `helm` and `kubernetes` providers in `required_providers` but **does not configure them**, per the repo rules.

`yaml_to_tfvars.py` has been extended to detect `argo_cd:` in a project YAML and emit the following at root level when present:

- a `data "google_client_config"` block,
- a configured `helm` provider that authenticates against the GKE cluster created by `module.gke_autopilot_cluster`,
- a configured `kubernetes` provider with the same auth.

This requires the project YAML to declare `argo_cd.cluster_name` and `argo_cd.cluster_location` at the module level (NOT inside `spec`) so the orchestrator can index the GKE cluster's outputs.

## Inputs

| Name              | Type   | Required | Description                                                                 |
|-------------------|--------|:--------:|-----------------------------------------------------------------------------|
| `project_id`      | string | yes      | GCP project that hosts the GKE cluster.                                     |
| `region`          | string | no       | Accepted for orchestrator compatibility; not used by this module.           |
| `argo_cd`         | any    | no       | Module config from YAML (see structure below).                              |
| `argo_cd_default` | object | no       | Defaults merged into every `spec` item.                                     |

### YAML structure

```yaml
argo_cd:
  source:
    version: v1.0.0
  depends_on:
    - gke_autopilot_cluster

  # Cluster reference (consumed by the orchestrator to wire helm/kubernetes providers).
  cluster_name: "acd-cluster"
  cluster_location: "europe-west3"

  spec:
    - name: "argocd"
      namespace: "argocd"
      chart_version: "9.5.14"
      create_namespace: true
      atomic: false
      cleanup_on_fail: false
      wait: true
      timeout: 600

      helm_values: |
        global:
          domain: argocd.pltfrm-beta-acd.example.com
        configs:
          params:
            server.insecure: false
        server:
          ingress:
            enabled: true
            ingressClassName: gce-internal

      finops_resource_type: "compute"
      labels:
        vf_ngdi_environment: "beta"
        vf_ngdi_shared: "true"
        vf_ngdi_domain: "pltfrm"
```

The single `spec` item supports:

| Attribute              | Type    | Required | Default                                | Description                                                  |
|------------------------|---------|:--------:|----------------------------------------|--------------------------------------------------------------|
| `name`                 | string  | no       | `"argocd"`                             | Helm release name.                                           |
| `namespace`            | string  | no       | `"argocd"`                             | Target Kubernetes namespace.                                 |
| `chart_version`        | string  | no       | `"9.5.14"`                             | argo-cd Helm chart version.                                  |
| `chart_repository`     | string  | no       | `https://argoproj.github.io/argo-helm` | Override only for internal mirrors.                          |
| `create_namespace`     | bool    | no       | `true`                                 | Create the namespace via `kubernetes_namespace_v1`.          |
| `atomic`               | bool    | no       | `false`                                | Helm `--atomic` behavior.                                    |
| `cleanup_on_fail`      | bool    | no       | `false`                                | Helm `--cleanup-on-fail` behavior.                           |
| `wait`                 | bool    | no       | `true`                                 | Block apply until release reports ready.                     |
| `timeout`              | number  | no       | `600`                                  | Helm timeout in seconds (must be `(0, 3600]`).               |
| `helm_values`          | string  | no       | `""`                                   | Raw YAML overrides passed to the chart, plain text.          |
| `finops_resource_type` | string  | no       | `"compute"`                            | FinOps resource type (see `finops_labels`).                  |
| `labels`               | map     | no       | `{}`                                   | Labels validated by `finops_labels` and applied to namespace.|

## Outputs

| Name            | Description                                                                |
|-----------------|----------------------------------------------------------------------------|
| `enabled`       | `true` when a release is managed, `false` when `spec` is empty.            |
| `release_name`  | Helm release name (or `null` when disabled).                               |
| `namespace`     | Kubernetes namespace where Argo CD is installed (or `null` when disabled). |
| `chart_version` | Installed argo-cd Helm chart version (or `null` when disabled).            |
| `app_version`   | Resolved Argo CD application version (or `null` when disabled).            |
| `labels`        | FinOps-validated namespace labels (`{}` when disabled).                    |

## Notes / improvements over the snappy reference

- **No SOPS/helm-secrets stack**: per request, this module accepts plain-text values only. If secret material is required (e.g. admin password override, OIDC client secret), use `secret_manager` + an out-of-band `kubernetes_secret_v1` or — preferred — wire Argo CD to External Secrets Operator or Workload Identity.
- **GKE Autopilot–friendly**: no node affinities are baked in. Resource requests/limits can still be set via `helm_values` if you tune for Autopilot constraints.
- **Single-install by design**: one Argo CD per project enforced via validation. To run a separate Argo CD elsewhere, create a second project-config YAML.
- **Namespace lifecycle decoupled from Helm**: the namespace is managed by `kubernetes_namespace_v1` so FinOps labels can be applied and audited.
