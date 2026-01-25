# GCP Foundation Module - Outputs
# Standardized interface across all cloud providers

output "vpc_id" {
  value       = google_compute_network.main.id
  description = "VPC Network ID"
}

output "vpc_name" {
  value       = google_compute_network.main.name
  description = "VPC Network name"
}

output "vpc_self_link" {
  value       = google_compute_network.main.self_link
  description = "VPC Network self link"
}

output "vpc_cidr" {
  value       = var.network_cidr
  description = "VPC CIDR (input value, subnets use this for calculation)"
}

output "kms_key_id" {
  value       = google_kms_crypto_key.main.id
  description = "KMS Crypto Key ID"
}

output "kms_key_ring_id" {
  value       = google_kms_key_ring.main.id
  description = "KMS Key Ring ID"
}

output "router_id" {
  value       = google_compute_router.main.id
  description = "Cloud Router ID"
}

output "router_name" {
  value       = google_compute_router.main.name
  description = "Cloud Router name"
}

output "project_id" {
  value       = data.google_project.current.project_id
  description = "GCP Project ID"
}

output "project_number" {
  value       = data.google_project.current.number
  description = "GCP Project number"
}

output "region" {
  value       = var.region
  description = "GCP region"
}

output "common_labels" {
  value       = local.common_labels
  description = "Common labels applied to all resources"
}
