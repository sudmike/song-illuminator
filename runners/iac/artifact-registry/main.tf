resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "github_runners" {
  location      = var.region
  repository_id = "github-runner"
  description   = "Docker images for GitHub runners"
  format        = "DOCKER"

  depends_on = [
    google_project_service.artifactregistry
  ]
}
