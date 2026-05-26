output "instance_name" {
  description = "List of bastion host instance names."
  value = [
    for vm in local.bastion_vms : vm.name
  ]
}

output "instance_self_link" {
  description = "Map of self-links from the bastion host instances."
  value = {
    for vm in google_compute_instance.bastion : vm.name => vm.self_link
  }
}