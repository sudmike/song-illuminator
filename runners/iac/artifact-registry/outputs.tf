output "artifact_registry_repository_uri" {
  description = "The artifact registry repository uri."
  value       = google_artifact_registry_repository.github_runners.registry_uri
}

output "github_artifact_registry_host_variable_command" {
  description = "Run this command to store the Terraform artifact registry host as a GitHub environment variable."
  value       = <<EOT
gh variable set ARTIFACT_REGISTRY_HOST \
  --env <environment> \
  --body "${split("/", google_artifact_registry_repository.github_runners.registry_uri)[0]}"
EOT
}

output "github_artifact_registry_repository_uri_variable_command" {
  description = "Run this command to store the Terraform artifact registry repository uri as a GitHub environment variable."
  value       = <<EOT
gh variable set ARTIFACT_REGISTRY_REPOSITORY_URI \
  --env <environment> \
  --body "${google_artifact_registry_repository.github_runners.registry_uri}"
EOT
}
