variable "kms" {
  type        = any
  description = "KMS module config with spec."
  default     = null
}

variable "iam" {
  description = "Keyring IAM bindings in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
  nullable    = false
}

variable "iam_bindings" {
  description = "Authoritative IAM bindings in {KEY => {role = ROLE, members = [], condition = {}}}. Keys are arbitrary."
  type = map(object({
    members = list(string)
    role    = string
    condition = optional(object({
      expression  = string
      title       = string
      description = optional(string)
    }))
  }))
  nullable = false
  default  = {}
}

variable "iam_bindings_additive" {
  description = "Keyring individual additive IAM bindings. Keys are arbitrary."
  type = map(object({
    member = string
    role   = string
    condition = optional(object({
      expression  = string
      title       = string
      description = optional(string)
    }))
  }))
  nullable = false
  default  = {}
}

variable "import_job" {
  description = "Keyring import job attributes."
  type = object({
    id               = string
    import_method    = string
    protection_level = string
  })
  default = null
}

variable "keyring" {
  description = "Keyring attributes."
  type = object({
    location = string
    name     = string
  })
  default  = null
  nullable = true
}

variable "keyring_create" {
  description = "Set to false to manage keys and IAM bindings in an existing keyring."
  type        = bool
  default     = true
}

variable "keys" {
  description = "Key names and base attributes. Set attributes to null if not needed."
  type = map(object({
    destroy_scheduled_duration    = optional(string, null)
    rotation_period               = optional(string, null)
    labels                        = optional(map(string), {})
    finops_resource_type          = optional(string, null)
    purpose                       = optional(string, "ENCRYPT_DECRYPT")
    skip_initial_version_creation = optional(bool, false)
    version_template = optional(object({
      algorithm        = string
      protection_level = optional(string, "SOFTWARE")
    }), null)
    iam = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      members = list(string)
      role    = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }), null)
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }), null)
    })), {})
  }))
  default  = {}
  nullable = false
  validation {
    condition = alltrue([
      for k, v in var.keys : contains([
        "CRYPTO_KEY_PURPOSE_UNSPECIFIED", "ENCRYPT_DECRYPT", "ASYMMETRIC_SIGN",
        "ASYMMETRIC_DECRYPT", "RAW_ENCRYPT_DECRYPT", "MAC"
        ], v.purpose
      )
    ])
    error_message = "Invalid key purpose."
  }
  validation {
    condition = alltrue([
      for k, v in var.keys : contains([
        "SOFTWARE", "HSM", "HSM_SINGLE_TENANT", "EXTERNAL", "EXTERNAL_VPC"
      ], try(v.version_template.protection_level, "SOFTWARE"))
    ])
    error_message = "Invalid version template protection level."
  }
  validation {
    condition = alltrue([
      for k, v in var.keys : (
        try(v.version_template.algorithm, null) == null ||
        contains([
          # Symmetric
          "GOOGLE_SYMMETRIC_ENCRYPTION", "AES_128_GCM", "AES_256_GCM",
          "AES_128_CBC", "AES_256_CBC", "AES_128_CTR", "AES_256_CTR",
          "EXTERNAL_SYMMETRIC_ENCRYPTION",
          # RSA sign - PSS
          "RSA_SIGN_PSS_2048_SHA256", "RSA_SIGN_PSS_3072_SHA256",
          "RSA_SIGN_PSS_4096_SHA256", "RSA_SIGN_PSS_4096_SHA512",
          # RSA sign - PKCS1
          "RSA_SIGN_PKCS1_2048_SHA256", "RSA_SIGN_PKCS1_3072_SHA256",
          "RSA_SIGN_PKCS1_4096_SHA256", "RSA_SIGN_PKCS1_4096_SHA512",
          # RSA sign - raw PKCS1
          "RSA_SIGN_RAW_PKCS1_2048", "RSA_SIGN_RAW_PKCS1_3072", "RSA_SIGN_RAW_PKCS1_4096",
          # RSA decrypt - OAEP
          "RSA_DECRYPT_OAEP_2048_SHA256", "RSA_DECRYPT_OAEP_3072_SHA256",
          "RSA_DECRYPT_OAEP_4096_SHA256", "RSA_DECRYPT_OAEP_4096_SHA512",
          "RSA_DECRYPT_OAEP_2048_SHA1", "RSA_DECRYPT_OAEP_3072_SHA1", "RSA_DECRYPT_OAEP_4096_SHA1",
          # Elliptic curve sign
          "EC_SIGN_P256_SHA256", "EC_SIGN_P384_SHA384", "EC_SIGN_SECP256K1_SHA256", "EC_SIGN_ED25519",
          # HMAC
          "HMAC_SHA1", "HMAC_SHA224", "HMAC_SHA256", "HMAC_SHA384", "HMAC_SHA512",
          # Key encapsulation
          "ML_KEM_768", "ML_KEM_1024", "KEM_XWING",
          # Post-quantum sign
          "PQ_SIGN_ML_DSA_44", "PQ_SIGN_ML_DSA_65", "PQ_SIGN_ML_DSA_87",
          "PQ_SIGN_SLH_DSA_SHA2_128S", "PQ_SIGN_HASH_SLH_DSA_SHA2_128S_SHA256",
          "PQ_SIGN_ML_DSA_44_EXTERNAL_MU", "PQ_SIGN_ML_DSA_65_EXTERNAL_MU", "PQ_SIGN_ML_DSA_87_EXTERNAL_MU",
        ], v.version_template.algorithm)
      )
    ])
    error_message = "Invalid version_template.algorithm. See https://cloud.google.com/kms/docs/algorithms for the current list (Google adds algorithms over time; update this list if a new one is rejected)."
  }
}

variable "project_id" {
  description = "Project id where the keyring will be created."
  type        = string
}

variable "region" {
  description = "Default region used when keyring location is not provided."
  type        = string
  default     = "europe-west2"
}

variable "tag_bindings" {
  description = "Tag bindings for this keyring, in key => tag value id format."
  type        = map(string)
  nullable    = false
  default     = {}
}
