# GCP Network Module
# Creates subnets, Cloud NAT, firewall rules

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
# Subnets
# =============================================================================

resource "google_compute_subnetwork" "public" {
  name          = "${var.project}-${var.environment}-public"
  ip_cidr_range = cidrsubnet(var.network_cidr, 4, 0)
  region        = var.region
  network       = var.vpc_name

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "private" {
  name          = "${var.project}-${var.environment}-private"
  ip_cidr_range = cidrsubnet(var.network_cidr, 4, 4)
  region        = var.region
  network       = var.vpc_name

  private_ip_google_access = true

  # Secondary ranges for GKE
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = cidrsubnet(var.network_cidr, 4, 8)
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = cidrsubnet(var.network_cidr, 4, 12)
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# =============================================================================
# Cloud NAT
# =============================================================================

resource "google_compute_router_nat" "main" {
  name                               = "${var.project}-${var.environment}-nat"
  router                             = var.router_name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# =============================================================================
# Firewall Rules
# =============================================================================

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project}-${var.environment}-allow-internal"
  network = var.vpc_name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.network_cidr]
}

resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.project}-${var.environment}-allow-health-check"
  network = var.vpc_name

  allow {
    protocol = "tcp"
  }

  # Google health check ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
}

resource "google_compute_firewall" "deny_all_ingress" {
  name     = "${var.project}-${var.environment}-deny-all-ingress"
  network  = var.vpc_name
  priority = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}
