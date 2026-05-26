output "disk_self_links" {
  description = "A map of disk self links by disk name"
  value       = { for disk in google_compute_disk.compute_disk : disk.name => disk.self_link }
}

output "disk_names" {
  description = "A list of disk names"
  value       = [for disk in google_compute_disk.compute_disk : disk.name]
}