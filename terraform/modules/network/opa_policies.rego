# terraform\modules\network\opa_policies.rego
package tf_policies.resources

import rego.v1

# Load resources being created or updated in plan
network_resources contains resource if {
	resource := input.resource_changes[_]
	resource.module_address == "module.network"
	resource.mode == "managed"
	resource.change.actions[_] in ["create", "update"]
}

# Warn for NAT Gateway being created
warn contains msg if {
    resource := network_resources[_]
    resource.type == "google_compute_router_nat"  
	"create" in resource.change.actions
    msg := "WARNING: A NAT Gateway is being created. Please confirm which subnets have access or disable if not required."
}

# Warn for unrestricted egress
deny_egress_active if {
	resource := network_resources[_]
	resource.name == "deny_all_egress"

	not "delete" in resource.change.actions
}

warn contains msg if {
	network_resources[_]
	not deny_egress_active
	msg := "WARNING: Unrestricted egress will be allowed. Please set deny_egress to true in network module configuration to resrtict egress."
}