variable "gcp_project_id" {
  description = "Google Cloud project that hosts the beta application."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the application."
  type        = string
  default     = "europe-north1"
}

variable "image_uri" {
  description = "Immutable container image URI deployed to Cloud Run."
  type        = string
}

variable "allow_unauthenticated" {
  description = "Whether the beta web application is publicly reachable."
  type        = bool
  default     = true
}
