output "backend_init_command" {
  description = "Run this command from the real Terraform stack folder to initialize the GCS backend."
  value       = <<EOT
terraform init \
  -backend-config="bucket=${google_storage_bucket.terraform_state.name}" \
  -backend-config="prefix=$(basename $(pwd))"
EOT
}

output "bucket_import_command" {
  description = "Run this command from the real Terraform stack folder to import the existing state bucket."
  value       = "terraform import google_storage_bucket.terraform_state ${google_storage_bucket.terraform_state.name}"
}

output "github_backend_bucket_variable_command" {
  description = "Run this command to store the Terraform state bucket name as a GitHub environment variable."
  value       = <<EOT
gh variable set TERRAFORM_STATE_BUCKET \
  --env <environment> \
  --body "${google_storage_bucket.terraform_state.name}"
EOT
}