output "id" {
  description = "Fully qualified keyring id when exactly one keyring is managed; null when multiple keyrings are configured."
  value       = local.single_keyring_key != null ? local.keyring.id : null
  depends_on = [
    google_kms_key_ring_iam_binding.authoritative,
    google_kms_key_ring_iam_binding.bindings,
    google_kms_key_ring_iam_member.bindings,
    google_kms_crypto_key_iam_binding.authoritative,
    google_kms_crypto_key_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members
  ]
}

output "import_job" {
  description = "Keyring import job resources for single-keyring mode."
  value       = google_kms_key_ring_import_job.default
  depends_on = [
    google_kms_key_ring_iam_binding.authoritative,
    google_kms_key_ring_iam_binding.bindings,
    google_kms_key_ring_iam_member.bindings,
    google_kms_crypto_key_iam_binding.authoritative,
    google_kms_crypto_key_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members
  ]
}

output "import_jobs" {
  description = "Keyring import job resources keyed by location/name."
  value = merge(
    google_kms_key_ring_import_job.keyrings,
    length(google_kms_key_ring_import_job.default) > 0 ? {
      (local.single_keyring_key) = google_kms_key_ring_import_job.default[0]
    } : {}
  )
}

output "key_ids" {
  description = "Fully qualified key ids keyed by crypto key for_each key."
  value = {
    for name, resource in google_kms_crypto_key.default :
    name => resource.id
  }
  depends_on = [
    google_kms_crypto_key_iam_binding.authoritative,
    google_kms_crypto_key_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members
  ]
}

output "keyring" {
  description = "Keyring resource when exactly one keyring is managed; null when multiple keyrings are configured."
  value       = local.keyring
  depends_on = [
    google_kms_key_ring_iam_binding.authoritative,
    google_kms_key_ring_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members,
    google_kms_crypto_key_iam_binding.authoritative,
    google_kms_crypto_key_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members,
  ]
}

output "keyrings" {
  description = "Keyring resources keyed by location/name."
  value       = local.keyring_by_key
  depends_on = [
    google_kms_key_ring_iam_binding.authoritative,
    google_kms_key_ring_iam_binding.bindings,
    google_kms_key_ring_iam_member.bindings,
    google_kms_crypto_key_iam_binding.authoritative,
    google_kms_crypto_key_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members
  ]
}

output "keys" {
  description = "Key resources keyed by crypto key for_each key."
  value       = google_kms_crypto_key.default
  depends_on = [
    google_kms_key_ring_iam_binding.authoritative,
    google_kms_key_ring_iam_binding.bindings,
    google_kms_key_ring_iam_member.bindings,
    google_kms_crypto_key_iam_binding.authoritative,
    google_kms_crypto_key_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members
  ]
}

output "location" {
  description = "Keyring location when exactly one keyring is managed; null when multiple keyrings are configured."
  value       = local.single_keyring_key != null ? local.keyring.location : null
  depends_on = [
    google_kms_key_ring_iam_binding.authoritative,
    google_kms_key_ring_iam_binding.bindings,
    google_kms_key_ring_iam_member.bindings,
    google_kms_crypto_key_iam_binding.authoritative,
    google_kms_crypto_key_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members
  ]
}

output "name" {
  description = "Keyring name when exactly one keyring is managed; null when multiple keyrings are configured."
  value       = local.single_keyring_key != null ? local.keyring.name : null
  depends_on = [
    google_kms_key_ring_iam_binding.authoritative,
    google_kms_key_ring_iam_binding.bindings,
    google_kms_key_ring_iam_member.bindings,
    google_kms_crypto_key_iam_binding.authoritative,
    google_kms_crypto_key_iam_binding.bindings,
    google_kms_crypto_key_iam_member.members
  ]
}
