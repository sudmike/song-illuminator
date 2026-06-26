terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.37.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.region
}
