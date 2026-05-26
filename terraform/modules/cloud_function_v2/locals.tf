locals {

  functions = [
    for spec in try(var.cloud_function_v2.spec, []) : {
      name                        = try(spec.function_name, spec.name)
      location                    = try(spec.location, var.function_default.location)
      prefix                      = try(spec.prefix, var.function_default.prefix)
      description                 = try(spec.description, var.function_default.description)
      kms_key                     = try(spec.kms_key, var.function_default.kms_key)
      build_environment_variables = try(spec.build_environment_variables, var.function_default.build_environment_variables)
      build_service_account       = try(spec.build_service_account, var.function_default.build_service_account)
      service_account_email       = try(spec.service_account_email, var.function_default.service_account_email)
      build_worker_pool           = try(spec.build_worker_pool, var.function_default.build_worker_pool)
      docker_repository_id        = try(spec.docker_repository_id, var.function_default.docker_repository_id)
      bucket_name                 = try(spec.bucket_name, var.function_default.bucket_name)
      bundle_path                 = try(spec.bundle_path, var.function_default.bundle_path)
      bundle_name                 = try(spec.bundle_name, var.function_default.bundle_name)
      environment_variables       = try(spec.environment_variables, var.function_default.environment_variables)
      ingress_settings            = try(spec.ingress_settings, var.function_default.ingress_settings)
      vpc_connector               = try(spec.vpc_connector, var.function_default.vpc_connector)
      direct_vpc_egress           = try(spec.direct_vpc_egress, var.function_default.direct_vpc_egress)
      secrets                     = try(spec.secrets, var.function_default.secrets)
      iam                         = try(spec.iam, var.function_default.iam) #"IAM bindings for topic in {ROLE => [MEMBERS]} format."
      function_config             = try(spec.function_config, var.function_default.function_config)
      trigger_config              = try(spec.trigger_config, var.function_default.trigger_config)
      finops_resource_type        = coalesce(try(spec.finops_resource_type, null), "cloud_function")
      labels                      = try(spec.labels, {})
    }
  ]

  function_map = { for function in local.functions : function.name => {
    name                        = function.name
    location                    = function.location
    prefix                      = function.prefix
    description                 = function.description
    kms_key                     = function.kms_key
    build_environment_variables = function.build_environment_variables
    build_service_account       = function.build_service_account
    service_account_email       = function.service_account_email
    build_worker_pool           = function.build_worker_pool
    docker_repository_id        = function.docker_repository_id
    bucket_name                 = function.bucket_name
    bundle_path                 = function.bundle_path
    bundle_type = (
      startswith(function.bundle_path, "gs://")
      ? "gcs"
      : (
        try(fileexists(pathexpand(function.bundle_path)), null) != null &&
        endswith(function.bundle_path, ".zip")
        ? "local-file"
        : "local-folder"
      )
    )
    bundle_name           = function.bundle_name
    environment_variables = function.environment_variables
    ingress_settings      = function.ingress_settings
    vpc_connector         = function.vpc_connector
    direct_vpc_egress     = function.direct_vpc_egress
    secrets               = function.secrets
    iam                   = function.iam
    function_config       = function.function_config
    trigger_config        = function.trigger_config
    finops_resource_type  = function.finops_resource_type
    labels                = function.labels
    }
  }

  finops_specs = [
    for function in local.functions : {
      resource_type = function.finops_resource_type
      name          = "${function.finops_resource_type}/${function.name}"
      resource_name = function.name
      input_labels  = function.labels
    }
  ]

}