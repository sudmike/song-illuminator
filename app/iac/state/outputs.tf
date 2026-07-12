output "state_bucket_name" {
  description = "The Terraform state bucket name."
  value       = google_storage_bucket.terraform_state.name
}

