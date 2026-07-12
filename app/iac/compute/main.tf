locals {
  required_services = toset([
    "artifactregistry.googleapis.com",
    "firestore.googleapis.com",
    "run.googleapis.com",
  ])
}

resource "google_project_service" "application" {
  for_each = local.required_services

  project            = var.gcp_project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "app" {
  project      = var.gcp_project_id
  account_id   = "song-illuminator-app"
  display_name = "Song Illuminator application"
}

resource "google_project_iam_member" "app_firestore" {
  project = var.gcp_project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.app.email}"
}

resource "google_firestore_database" "app" {
  project     = var.gcp_project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.application["firestore.googleapis.com"]]
}

resource "google_cloud_run_v2_service" "app" {
  project  = var.gcp_project_id
  name     = "song-illuminator"
  location = var.region

  deletion_protection = true
  ingress             = "INGRESS_TRAFFIC_ALL"

  scaling {
    min_instance_count = 1
    max_instance_count = 1
  }

  template {
    service_account = google_service_account.app.email

    containers {
      image = "${var.image_uri}/app:latest"

      resources {
        cpu_idle = false
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "APP_ENV"
        value = "production"
      }

      env {
        name  = "FIRESTORE_PROJECT_ID"
        value = var.gcp_project_id
      }

      startup_probe {
        initial_delay_seconds = 0
        timeout_seconds       = 2
        period_seconds        = 3
        failure_threshold     = 10

        http_get {
          path = "/healthz"
        }
      }

      liveness_probe {
        timeout_seconds   = 2
        period_seconds    = 30
        failure_threshold = 3

        http_get {
          path = "/healthz"
        }
      }
    }
  }

  depends_on = [
    google_firestore_database.app,
    google_project_service.application["run.googleapis.com"],
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count = var.allow_unauthenticated ? 1 : 0

  project  = google_cloud_run_v2_service.app.project
  location = google_cloud_run_v2_service.app.location
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
