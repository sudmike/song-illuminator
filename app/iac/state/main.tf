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

data "google_service_account" "github_runner" {
  account_id = var.gcp_runner_email
}

resource "google_project_iam_member" "github_runner_owner" {
  project = var.gcp_project_id
  role    = "roles/owner"
  member  = "serviceAccount:${data.google_service_account.github_runner.email}"
}

resource "google_storage_bucket_iam_member" "github_runner_state" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${data.google_service_account.github_runner.email}"
}
