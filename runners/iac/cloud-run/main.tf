# Secret

resource "google_secret_manager_secret" "github_token" {
  secret_id = "github-token"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github_token" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.github_token
}

# Service accounts

resource "google_service_account" "runner" {
  account_id = "github-runner"
}

resource "google_service_account" "crema" {
  account_id = "github-runner-crema"
}

# Cloud run workers

resource "google_cloud_run_v2_worker_pool" "runner" {
  name     = "github-runner"
  location = var.region

  template {
    service_account = google_service_account.runner.email

    containers {
      image = "${var.github_runner_image_uri}:latest"

      env {
        name = "GITHUB_TOKEN"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.github_token.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "GITHUB_OWNER"
        value = var.github_owner
      }
      env {
        name  = "GITHUB_REPO"
        value = var.github_repo
      }
    }
  }
}

# Cloud run scaler

resource "google_cloud_run_v2_service" "crema" {
  name     = "crema"
  location = var.region

  template {
    service_account = google_service_account.crema.email

    containers {
      image = "us-central1-docker.pkg.dev/cloud-run-oss-images/crema-v1/autoscaler:1.0"
    }
  }
}
