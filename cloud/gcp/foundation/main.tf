# GCP Foundation Module
# Creates base infrastructure: VPC, KMS, etc.

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
# Data Sources
# =============================================================================

data "google_project" "current" {}
data "google_client_config" "current" {}

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
# VPC Network
# =============================================================================

resource "google_compute_network" "main" {
  name                    = "${var.project}-${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# =============================================================================
# KMS Key Ring and Key
# =============================================================================

resource "google_kms_key_ring" "main" {
  name     = "${var.project}-${var.environment}-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "main" {
  name            = "${var.project}-${var.environment}-key"
  key_ring        = google_kms_key_ring.main.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

# =============================================================================
# Cloud Router (for NAT)
# =============================================================================

resource "google_compute_router" "main" {
  name    = "${var.project}-${var.environment}-router"
  region  = var.region
  network = google_compute_network.main.id

  bgp {
    asn = 64514
  }
}

# =============================================================================
# Logging Sink
# =============================================================================

resource "google_logging_project_sink" "main" {
  name        = "${var.project}-${var.environment}-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  filter      = "resource.type=\"gce_instance\" OR resource.type=\"gke_cluster\""

  unique_writer_identity = true
}

resource "google_storage_bucket" "logs" {
  name          = "${var.project}-${var.environment}-logs-${data.google_project.current.number}"
  location      = var.region
  force_destroy = var.environment != "prd"

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = var.environment == "prd" ? 365 : 30
    }
    action {
      type = "Delete"
    }
  }

  labels = local.common_labels
}

resource "google_storage_bucket_iam_member" "logs_writer" {
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.main.writer_identity
}
