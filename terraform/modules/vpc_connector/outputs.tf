output "connectors" {
  description = "Created VPC Access Connector resources."
  value       = google_vpc_access_connector.connector
}

output "connector_ids" {
  description = "Map of connector name => full resource id."
  value = {
    for name, connector in google_vpc_access_connector.connector :
    name => connector.id
  }
}

