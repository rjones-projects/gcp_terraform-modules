terraform {
  required_version = ">= 1.14.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.17.0, < 8.0.0" # tftest
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 7.17.0, < 8.0.0" # tftest
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}