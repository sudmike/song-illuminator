variable "gcp_project_id" {
  description = "The GCP project ID that will contain the Terraform state bucket and all files."
  type        = string
}

variable "gcp_runner_email" {
  description = "The GCP runner email that belongs to the runner service account that should have access."
  type        = string
}

variable "region" {
  description = "GCP region used for resources that require a location."
  type        = string
  default     = "europe-north1"
}
