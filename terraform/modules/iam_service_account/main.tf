resource "google_service_account" "service_account" {
  for_each = {
    for k, v in local.service_accounts : k => v
    if v.service_account_reuse == false
  }
  project      = each.value.project_id
  account_id   = "${try(each.value.prefix, null) == null ? "" : "${each.value.prefix}-"}${each.value.name}"
  display_name = each.value.display_name
  description  = each.value.description
}

resource "google_tags_tag_binding" "binding" {
  for_each = {
    for pair in local.tag_bindings_pair :
    "${pair.sa_name}-${pair.tag_key}" => pair
    if pair.reuse == null
  }
  parent    = "//iam.googleapis.com/projects/${coalesce(var.project_number, var.project_id)}/serviceAccounts/${google_service_account.service_account[each.value.sa_name].unique_id}"
  tag_value = each.value.tag_value
}
