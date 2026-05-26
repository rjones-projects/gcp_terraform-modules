#!/usr/bin/env python3
"""
Convert a YAML config file to Terraform tfvars.json and generate deploy files.
"""

import json
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML required. Install with: pip install PyYAML")
    sys.exit(1)

# Base URL for the modules repository (kept for reference, though source is now overridden locally)
MODULE_REPO_BASE = "git::https://github.com/VFGROUP-NSE-DNOSS/DNE-PE-NGDI-TERRAFORM-MODULES.git"

def load_yaml(path: Path) -> dict:
    """Load and parse YAML file."""
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f)


def write_tfvars_json(data: dict, path: Path) -> None:
    """Write data as Terraform tfvars JSON, excluding internal config keys."""
    # Create a shallow copy to avoid modifying the original data used elsewhere
    output_data = data.copy()
    
    # Remove keys that are used for config but aren't Terraform variables
    output_data.pop("terraform", None)
    
    with open(path, "w", encoding="utf-8") as f:
        json.dump(output_data, f, indent=2, sort_keys=False)


def _module_keys(data: dict) -> list[str]:
    keys: list[str] = []
    for key, value in data.items():
        if isinstance(value, dict) and "source" in value:
            keys.append(key)
    return keys


def _write_file(path: Path, content: str) -> None:
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def _is_empty_spec(module_cfg: dict) -> bool:
    spec = module_cfg.get("spec")
    return spec is None or spec == "" or spec == [] or spec == {}


def _generate_variables_tf(data: dict, module_keys: list[str]) -> str:
    lines: list[str] = []
    lines.append('variable "project_id" {')
    lines.append("  type = string")
    lines.append("}")
    lines.append("")
    lines.append('variable "region" {')
    lines.append("  type = string")
    lines.append('  default = "europe-west1"') 
    lines.append("}")
    if "env" in data:
        lines.append("")
        lines.append('variable "env" {')
        lines.append("  type = string")
        lines.append("}")
    for key in module_keys:
        lines.append("")
        lines.append(f'variable "{key}" {{')
        lines.append("  type = any")
        lines.append("}")
    return "\n".join(lines)


def _generate_providers_tf() -> str:
    return "\n".join(
        [
            'provider "google" {',
            "  project = var.project_id",
            "  region  = var.region",
            "}",
            "",
            'provider "google-beta" {',
            "  project = var.project_id",
            "  region  = var.region",
            "}",
        ]
    )


def _generate_versions_tf(required_version: str, provider_version: str, project_id: str) -> str:
    """
    Generates versions.tf. 
    Backend configuration has been removed as requested.
    """
    
    return "\n".join(
        [
            "terraform {",
            # Backend block removed
            "",
            f'  required_version = "{required_version}"',
            "  required_providers {",
            "    google = {",
            '      source  = "hashicorp/google"',
            f'      version = "{provider_version}"',
            "    }",
            "    google-beta = {",
            '      source  = "hashicorp/google-beta"',
            f'      version = "{provider_version}"',
            "    }",
            "  }",
            "}",
        ]
    )


def _generate_main_tf(data: dict, module_keys: list[str]) -> str:
    lines: list[str] = []
    for key in module_keys:
        module_cfg = data[key]
        
        # NOTE: Source logic modified to use fixed relative path as requested
        # We ignore the source/version defined in YAML for the source string construction
        source = f"../../../terraform/modules/{key}"

        lines.append(f'module "{key}" {{')
        lines.append(f'  source     = "{source}"')
        
        # Always pass project_id
        if key not in ["iam_custom_role_stack"]:
            lines.append("  project_id = var.project_id")
        
        # Pass region to all modules EXCEPT project_services, iam_service_account, vpc_tags, AND dashboard_bq
        if key not in ["project_services", "iam_service_account", "vpc_tags", "dashboard_bq", "dashboard_composer", "dashboard_gcs", "dashboard_dataproc", "dns", "project_iam", "gke_standard_cluster", "bastion_vm", "vf_security_policy", "service_agent_iam", "compute_instance", "os_login", "compute_disk", "gke_autopilot_cluster", "iam_custom_role_stack"]:
            lines.append("  region     = var.region")

        # Pass the module configuration object if the spec is not empty
        if not _is_empty_spec(module_cfg):
             lines.append(f"  {key}        = var.{key}")

        depends_on = module_cfg.get("depends_on")
        if depends_on is not None:
            if isinstance(depends_on, list):
                refs = ", ".join([f"module.{name}" for name in depends_on])
                lines.append(f"  depends_on = [{refs}]")
            elif isinstance(depends_on, str) and depends_on != "":
                lines.append(f"  depends_on = [module.{depends_on}]")
            else:
                lines.append("  depends_on = []")
        
        lines.append("}")
        lines.append("")
    return "\n".join(lines).rstrip()


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: yaml_to_tfvars.py <input_yaml> [output_json]")
        sys.exit(1)

    input_path = Path(sys.argv[1])
    
    if len(sys.argv) > 2:
        output_path = Path(sys.argv[2])
    else:
        output_path = Path(__file__).parent / "deploy" / "terraform.tfvars.json"

    if not input_path.exists():
        print(f"Error: Input file not found: {input_path}")
        sys.exit(1)

    data = load_yaml(input_path)

    deploy_dir = output_path.parent
    deploy_dir.mkdir(parents=True, exist_ok=True)

    write_tfvars_json(data, output_path)

    # Extract required vars
    terraform_cfg = data.get("terraform", {})
    required_version = terraform_cfg.get("required_version")
    providers_cfg = terraform_cfg.get("providers", {})
    provider_version = providers_cfg.get("google")
    project_id = data.get("project_id")
    
    if not all([required_version, provider_version, project_id]):
        print("Error: 'project_id', 'terraform.required_version' and 'terraform.providers.google' are required.")
        sys.exit(1)

    module_keys = _module_keys(data)
    
    _write_file(deploy_dir / "main.tf", _generate_main_tf(data, module_keys))
    _write_file(deploy_dir / "providers.tf", _generate_providers_tf())
    _write_file(deploy_dir / "variables.tf", _generate_variables_tf(data, module_keys))
    
    # Pass project_id to generate versions.tf (though backend is now removed)
    _write_file(deploy_dir / "versions.tf", _generate_versions_tf(required_version, provider_version, project_id))

    print(f"✅ Successfully generated Terraform files in: {deploy_dir}")


if __name__ == "__main__":
    main()