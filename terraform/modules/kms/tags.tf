resource "google_tags_location_tag_binding" "binding" {
  for_each = local.multi_keyring_mode ? local.tag_bindings_unified : {
    for tag_key, tag_value in local.tag_bindings :
    tag_key => {
      keyring_key = local.single_keyring_key
      location    = local.keyring_location
      tag_value   = tag_value
    }
  }

  parent    = "//cloudkms.googleapis.com/${local.keyring_by_key[each.value.keyring_key].id}"
  tag_value = each.value.tag_value
  location  = each.value.location
}
