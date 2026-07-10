# terraform\modules\network\opa_policies.rego
package tf_policies.resources

import rego.v1

# Load gcs module resources being created or updated in plan
gcs_resources contains resource if {
    resource := input.resource_changes[_]
	resource.module_address == "module.gcs"
	resource.mode == "managed"
	not "delete" in resource.change.action
}

# Deny any storage bucket created without a CMEK key.
deny contains msg if {
    resource := gcs_resources[_]
    resource.type == "google_storage_bucket"
    not has_cmek(resource.change.after)
    msg := sprintf(
        "DENY: Bucket '%s' has no CMEK key. Set kms_key_name in the bucket spec (encryption.default_kms_key_name is required).",
        [resource.address],
    )
}

# true only
has_cmek(after) if {
    enc := after.encryption[_]
    enc.default_kms_key_name != null
    enc.default_kms_key_name != ""
}