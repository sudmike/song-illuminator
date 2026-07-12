output "service_url" {
  description = "URL of the beta Song Illuminator service."
  value       = google_cloud_run_v2_service.app.uri
}

output "service_account_email" {
  description = "Runtime identity used by the application."
  value       = google_service_account.app.email
}
