# NGDI FinOps Labels (spec‑based wrapper)

**Policy‑driven label validator for Google Cloud resources, integrated with `yaml_to_tfvars.py`.**  
This module wraps the core NGDI policy from `ngdi-finops_labels` and exposes a **spec‑driven** interface that:

- takes a list of resources to validate (`spec`),
- applies **defaults per resource type**,
- **sanitizes** and **validates** labels, and
- returns **per‑resource maps** of final labels and validation status.

It is designed to be used from `project.yaml` / `example*.yaml` together with `yaml_to_tfvars.py`.

---

## Features

- **Single source of truth** for NGDI label rules (vendored from ORCHESTRATE `ngdi-finops_labels`).
- **Spec‑driven**: validate many resources in a single call (project, buckets, datasets, KMS, networking, …).
- **Type‑aware** defaults & validation (required/optional/not‑applicable, allowed values per type).
- **Sanitization**: keys/values lower‑cased, unsafe chars replaced with `-`.
- **Structured outputs** per spec key: labels, violations, missing required, validity.

---

## Inputs

This module is called from the generated `deploy/main.tf` like:

```hcl
module "finops_labels" {
  source        = "../modules/finops_labels"
  project_id    = var.project_id
  region        = var.region
  finops_labels = var.finops_labels
}
```

### Variables

| Name            | Type   | Description                                                  |
|-----------------|--------|--------------------------------------------------------------|
| `project_id`    | string | GCP project ID (for consistency with other modules).        |
| `region`        | string | GCP region (for consistency with other modules).            |
| `finops_labels` | any    | Top‑level config from YAML, expected to contain `spec`.     |

### Spec items

In `project.yaml` (or another YAML config), you define the resources to validate:

```yaml
finops_labels:
  source: "..//modules/finops_labels"
  depends_on: []
  spec:
    - name: "project/default"
      resource_type: "project"
      resource_name: null
      input_labels:
        vf_ngdi_environment: "alpha"
        vf_ngdi_owner: "platform@example.com"
        vf_ngdi_shared: "false"
        vf_ngdi_goal: "foundation"
    - name: "network/main-vpc"
      resource_type: "networking"
      resource_name: "main-vpc"
      input_labels:
        vf_ngdi_environment: "alpha"
        vf_ngdi_shared: "true"
        vf_ngdi_goal: "networking"
```

Each `spec` item supports:

| Attribute        | Type   | Required | Description                                                                                     |
|------------------|--------|----------|-------------------------------------------------------------------------------------------------|
| `name`           | string | No       | Key for outputs. If omitted, defaults to `item-{index}`.                                       |
| `resource_type`  | string | Yes      | Logical class: `project`, `gcs_bucket`, `bq_dataset`, `composer`, `dataproc_cluster`, `dataproc_job`, `cloud_function`, `pubsub`, `kms`, `compute`, `networking`, … |
| `resource_name`  | string | No       | Logical/physical name; auto‑stamped into `vf_ngdi_resource_name` when applicable.              |
| `input_labels`   | map    | No       | Caller‑provided labels to merge on top of defaults.                                            |

---

## Outputs

For each `spec.name`, the module exposes:

| Output             | Type               | Description                                                              |
|--------------------|--------------------|--------------------------------------------------------------------------|
| `labels`           | `map(map(string))` | `labels[name]` = final, sanitized labels for that spec item.            |
| `violations`       | `map(map(string))` | Per label key error text for invalid values.                             |
| `missing_required` | `map(list(string))` | Required label keys that are missing/empty for each spec item.       |
| `is_valid`         | `map(bool)`        | `true` if no violations or missing required labels for that spec item.  |
| `error_report`     | `map(any)`         | Structured validation details (currently mirrors `violations`).         |

Example (in `terraform console`):

```hcl
module.finops_labels.labels["network/main-vpc"]
module.finops_labels.is_valid["network/main-vpc"]
```

---

## Using with `yaml_to_tfvars.py`

From the `terraform/` directory:

```bash
python3 yaml_to_tfvars.py project.yaml deploy/terraform.tfvars.json
```

This generates `deploy/main.tf` containing both:

```hcl
module "finops_labels" { ... }

module "network" {
  source     = "../modules/network"
  project_id = var.project_id
  region     = var.region
  network    = var.network
  depends_on = [module.finops_labels]

  # Auto‑wired when `finops_labels:` is present in project.yaml
  labels = {
    for k in ["network/main-vpc"] :
    k => module.finops_labels.labels[k]
  }
}
```

Inside `modules/network`, you then consume `var.labels` and optionally merge with any labels from the spec:

```hcl
variable "labels" {
  description = "FinOps labels map keyed by spec name (e.g. \"network/main-vpc\")."
  type        = map(map(string))
  default     = {}
}

locals {
  labels_from_spec   = try(local.network.labels, {})
  labels_from_finops = try(var.labels["network/main-vpc"], {})
  labels             = merge(labels_from_spec, labels_from_finops)
}

resource "google_compute_address" "nat_external_ip" {
  # ...
  labels = local.labels
}
```

You can follow the same pattern in other modules (`kms`, `firewall`, etc.) by:

1. Adding `finops_labels:` at module level in YAML,
2. Letting `yaml_to_tfvars.py` wire `labels = { ... }` in `deploy/main.tf`,
3. Reading from `var.labels["<spec-name>"]` in the module and applying to supported resources.

---

## Relationship to ORCHESTRATE module

The core policy logic (defaults, required/optional rules, allowed values) is vendored from  
`DNE-PE-NGDI-ORCHESTRATE/modules/ngdi-finops_labels` into `local.policy` in this module.

This wrapper:

- provides a **multi‑resource spec interface** suitable for `yaml_to_tfvars.py`, and
- surfaces **aggregate outputs** for other modules to consume.

To evolve the FinOps standard, change only the policy in `locals.tf` (the `local.policy` block);  
callers stay unchanged.
