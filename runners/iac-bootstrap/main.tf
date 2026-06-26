resource "google_project_service" "storage" {
  service = "storage.googleapis.com"

  disable_on_destroy = false
}

resource "google_storage_bucket" "terraform_state" {
  name                        = "${var.gcp_project_id}-state"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }

    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.storage]
}
