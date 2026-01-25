# GCP Platform Module
# Creates application platform: GKE, Cloud SQL, etc.
# This is a placeholder - extend based on your needs

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  common_labels = {
    environment = var.environment
    project     = var.project
    managed-by  = "terraform"
  }
}

# =============================================================================
# GKE Cluster (Optional - uncomment to use)
# =============================================================================

# resource "google_container_cluster" "main" {
#   name     = "${var.project}-${var.environment}-gke"
#   location = var.region
#
#   # We can't create a cluster with no node pool defined, but we want to only use
#   # separately managed node pools. So we create the smallest possible default
#   # node pool and immediately delete it.
#   remove_default_node_pool = true
#   initial_node_count       = 1
#
#   network    = var.vpc_name
#   subnetwork = var.private_subnet_name
#
#   ip_allocation_policy {
#     cluster_secondary_range_name  = var.pods_ip_range_name
#     services_secondary_range_name = var.services_ip_range_name
#   }
#
#   private_cluster_config {
#     enable_private_nodes    = true
#     enable_private_endpoint = false
#     master_ipv4_cidr_block  = "172.16.0.0/28"
#   }
#
#   workload_identity_config {
#     workload_pool = "${data.google_project.current.project_id}.svc.id.goog"
#   }
#
#   resource_labels = local.common_labels
# }

# resource "google_container_node_pool" "primary" {
#   name       = "${var.project}-${var.environment}-primary"
#   location   = var.region
#   cluster    = google_container_cluster.main.name
#   node_count = var.environment == "prd" ? 3 : 1
#
#   node_config {
#     preemptible  = var.environment != "prd"
#     machine_type = "e2-medium"
#
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#
#     labels = local.common_labels
#   }
# }

# =============================================================================
# Cloud SQL (Optional - uncomment to use)
# =============================================================================

# resource "google_sql_database_instance" "main" {
#   name             = "${var.project}-${var.environment}-db"
#   database_version = "POSTGRES_15"
#   region           = var.region
#
#   settings {
#     tier = var.environment == "prd" ? "db-custom-2-4096" : "db-f1-micro"
#
#     ip_configuration {
#       ipv4_enabled    = false
#       private_network = var.vpc_id
#     }
#
#     backup_configuration {
#       enabled            = true
#       binary_log_enabled = false
#       start_time         = "02:00"
#     }
#
#     user_labels = local.common_labels
#   }
#
#   deletion_protection = var.environment == "prd" ? true : false
# }
