mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_id = "test-project-id"

  external_global_loadbalancer = {
    spec = [
      {
        name     = "test-http-lb"
        address  = "test-global-ip"
        protocol = "HTTP"
        backend_config = {
          instance_group = "projects/test-project-id/zones/europe-west2-a/instanceGroups/test-group"
          balancing_mode = "UTILIZATION"
          max_utilization = 0.8
        }
        finops_resource_type = "networking"
        labels = {
          vf_ngdi_environment = "alpha"
          vf_ngdi_shared      = "true"
        }
      }
    ]
  }
}

run "plan_basic_loadbalancer" {
  command = plan

  assert {
    condition     = length(output.loadbalancers) == 1
    error_message = "Expected 1 load balancer"
  }
}
