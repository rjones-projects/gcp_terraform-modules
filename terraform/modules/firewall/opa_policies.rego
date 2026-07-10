# terraform\modules\network\opa_policies.rego
package tf_policies.resources

import rego.v1

# Load resources being created or updated in plan
firewall_resources contains resource if {
	resource := input.resource_changes[_]
	resource.module_address == "module.firewall"
	resource.mode == "managed"
	not "delete" in resource.change.actions
}

# Deny SSH not via IAP
deny contains msg if {
    resource := firewall_resources[_]
    resource.type == "google_compute_firewall"
	direction := object.get(resource.change.after, "direction", "INGRESS")
	lower(direction) == "ingress"
    check_protocols_ports(resource.change.after,"tcp","22")
	source_ranges := object.get(resource.change.after, "source_ranges", [])
	resource.change.after.source_ranges != ["35.235.240.0/20"]
    msg := "DENY: SSH is only permitted through IAP. Please set ingress_ssh_via_IAP flag to true in your network module and delete SSH firewall rule."
}

check_protocols_ports(after,protocol,port) if {
	protocols_ports := after.allow[_]
	lower(protocols_ports.protocol) == protocol
	port in protocols_ports.ports
}