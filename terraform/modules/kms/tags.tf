resource "google_tags_location_tag_binding" "binding" {
  for_each  = local.tag_bindings
  parent    = "//cloudkms.googleapis.com/${local.keyring.id}"
  tag_value = each.value
  location  = local.keyring_location
}
