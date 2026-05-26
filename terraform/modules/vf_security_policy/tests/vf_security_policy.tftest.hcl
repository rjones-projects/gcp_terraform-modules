mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  vf_security_policy = {
    spec = [
      {
        name        = "test-waf-policy"
        description = "Test Cloud Armor WAF security policy"
        enable_waf  = true
        enable_layer7_ddos_defense = true
        enable_ssl_policy = true
        policy_type = "CLOUD_ARMOR"
        finops_resource_type = "networking"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      }
    ]
  }
}

run "plan_basic_security_policy" {
  command = plan

  assert {
    condition     = length(output.names) == 1
    error_message = "Expected 1 security policy"
  }
}
