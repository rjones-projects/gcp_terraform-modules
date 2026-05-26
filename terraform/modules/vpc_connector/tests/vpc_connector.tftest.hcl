mock_provider "google" {}

variables {
  project_id = "test-project-id"
  region     = "europe-west2"

  vpc_connector = {
    spec = [
      {
        name            = "test-vpc-connector"
        region          = "europe-west2"
        subnet_name     = "test-serverless-subnet"
        subnet_project_id = "test-project-id"
        min_instances   = 2
        max_instances   = 10
        machine_type    = "e2-micro"
      }
    ]
  }
}

run "plan_basic_connector" {
  command = plan

  assert {
    condition     = length(output.connectors) == 1
    error_message = "Expected 1 VPC connector"
  }
}
