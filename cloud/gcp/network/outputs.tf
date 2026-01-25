# GCP Network Module - Outputs

output "public_subnet_id" {
  value       = google_compute_subnetwork.public.id
  description = "Public subnet ID"
}

output "public_subnet_name" {
  value       = google_compute_subnetwork.public.name
  description = "Public subnet name"
}

output "private_subnet_id" {
  value       = google_compute_subnetwork.private.id
  description = "Private subnet ID"
}

output "private_subnet_name" {
  value       = google_compute_subnetwork.private.name
  description = "Private subnet name"
}

output "public_subnet_ids" {
  value       = [google_compute_subnetwork.public.id]
  description = "Public subnet IDs (standardized)"
}

output "private_subnet_ids" {
  value       = [google_compute_subnetwork.private.id]
  description = "Private subnet IDs (standardized)"
}

output "pods_ip_range_name" {
  value       = google_compute_subnetwork.private.secondary_ip_range[0].range_name
  description = "GKE pods IP range name"
}

output "services_ip_range_name" {
  value       = google_compute_subnetwork.private.secondary_ip_range[1].range_name
  description = "GKE services IP range name"
}

output "nat_ip" {
  value       = google_compute_router_nat.main.nat_ips
  description = "Cloud NAT IPs"
}
