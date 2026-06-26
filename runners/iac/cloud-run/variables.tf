variable "gcp_project_id" {
  description = "The GCP project ID that will contain the Terraform state bucket and all files."
  type        = string
}

variable "region" {
  description = "GCP region used for resources that require a location."
  type        = string
  default     = "europe-north1"
}

variable "github_runner_image_uri" {
  type        = string
  description = "URI of artifact registry repository repository to use for the github runner."
}

variable "github_token" {
  description = "GitHub personal access token used by the GitHub runner. This value is stored in Terraform state."
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "Github owner of the repository."
  type        = string
}

variable "github_repo" {
  description = "Github repository."
  type        = string
}