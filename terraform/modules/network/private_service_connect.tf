resource "google_project_service" "enable_service_networking_api" {
  for_each           = local.enable_private_service_connect ? toset(["psc"]) : toset([])
  project            = local.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_global_address" "psc_ip_range" {
  for_each      = local.enable_private_service_connect ? toset(["psc"]) : toset([])
  provider      = google-beta
  project       = local.project_id
  name          = local.global_address_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", local.psc_ip_range)[0]
  prefix_length = split("/", local.psc_ip_range)[1]
  network       = google_compute_network.vpc_network.id
  labels        = local.labels
  depends_on    = [google_compute_subnetwork.subnets]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  for_each = local.enable_private_service_connect ? toset(["psc"]) : toset([])
  provider = google-beta
  network  = google_compute_network.vpc_network.id
  service  = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [one(values(google_compute_global_address.psc_ip_range)).name]
  depends_on              = [google_project_service.enable_service_networking_api]
}

resource "google_compute_network_peering_routes_config" "peering_primary_routes" {
  for_each = local.enable_private_service_connect ? toset(["psc"]) : toset([])
  project  = local.project_id
  peering  = "servicenetworking-googleapis-com"
  network  = google_compute_network.vpc_network.name

  # exporting custom routes is required to allow peered networks to use Transparent Squid.
  # enabled for cloud_build_worker_pool
  export_custom_routes = true
  import_custom_routes = false

  depends_on = [google_service_networking_connection.private_vpc_connection]
}


 