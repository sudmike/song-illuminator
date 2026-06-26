# Secret

resource "google_project_service" "secret_manager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}


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

resource "google_service_account" "github_runner" {
  account_id = "github-runner"
}

resource "google_service_account" "crema" {
  account_id = "github-runner-crema"
}

# Workers

resource "google_project_service" "cloud_run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_v2_worker_pool" "runner" {
  name     = "github-runner"
  location = var.region
  deletion_protection = false

  template {
    service_account = google_service_account.github_runner.email

    containers {
      image = "${var.github_runner_image_uri}/runner:latest"

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

# IAM for cloud run

resource "google_secret_manager_secret_iam_member" "workers_github_token_accessor" {
  secret_id = google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.github_runner.email}"
}

# CREMA configuration

data "google_project" "current" {}

resource "google_project_service" "parameter_manager" {
  service            = "parametermanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_parameter_manager_parameter" "crema_config" {
  parameter_id = "crema-config"
  format       = "YAML"

  depends_on = [google_project_service.parameter_manager]
}

resource "google_parameter_manager_parameter_version" "crema_config" {
  parameter            = google_parameter_manager_parameter.crema_config.id
  parameter_version_id = "v1"
  parameter_data = templatefile("${path.module}/crema-config.yaml.tftpl", {
    github_token_secret_id = google_secret_manager_secret.github_token.secret_id
    worker_pool_id         = google_cloud_run_v2_worker_pool.runner.id
    github_owner           = var.github_owner
    github_repo            = var.github_repo
  })
}

# IAM for CREMA

resource "google_secret_manager_secret_iam_member" "crema_github_token_accessor" {
  secret_id = google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.crema.email}"
}

resource "google_project_iam_member" "crema_parameter_viewer" {
  project = data.google_project.current.project_id
  role    = "roles/parametermanager.parameterViewer"
  member  = "serviceAccount:${google_service_account.crema.email}"
}

resource "google_project_iam_member" "crema_run_developer" {
  project = data.google_project.current.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.crema.email}"
}

resource "google_service_account_iam_member" "crema_runner_service_account_user" {
  service_account_id = google_service_account.github_runner.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.crema.email}"
}

# Cloud run scaler

resource "google_cloud_run_v2_service" "crema" {
  name     = "crema"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  deletion_protection = false

  template {
    service_account = google_service_account.crema.email

    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }

    containers {
      image          = "us-central1-docker.pkg.dev/cloud-run-oss-images/crema-v1/autoscaler:1.2"
      base_image_uri = "us-central1-docker.pkg.dev/serverless-runtimes/google-24/runtimes/java25"

      resources {
        cpu_idle = false
      }

      env {
        name  = "CREMA_CONFIG"
        value = google_parameter_manager_parameter_version.crema_config.name
      }
    }
  }

  depends_on = [
    google_project_service.cloud_run,
  ]
}