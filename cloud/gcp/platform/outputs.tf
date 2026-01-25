# GCP Platform Module - Outputs

# Uncomment when using GKE
# output "gke_cluster_name" {
#   value       = google_container_cluster.main.name
#   description = "GKE cluster name"
# }

# output "gke_cluster_endpoint" {
#   value       = google_container_cluster.main.endpoint
#   description = "GKE cluster endpoint"
# }

# output "gke_cluster_ca_certificate" {
#   value       = google_container_cluster.main.master_auth[0].cluster_ca_certificate
#   description = "GKE cluster CA certificate"
#   sensitive   = true
# }

# Uncomment when using Cloud SQL
# output "cloudsql_instance_name" {
#   value       = google_sql_database_instance.main.name
#   description = "Cloud SQL instance name"
# }

# output "cloudsql_connection_name" {
#   value       = google_sql_database_instance.main.connection_name
#   description = "Cloud SQL connection name"
# }
