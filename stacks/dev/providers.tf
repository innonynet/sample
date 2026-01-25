# Dev Environment - Provider Configuration

# =============================================================================
# AWS Provider
# =============================================================================

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    }
  }
}

# =============================================================================
# Azure Provider (uncomment if using Azure)
# =============================================================================

# provider "azurerm" {
#   features {
#     key_vault {
#       purge_soft_delete_on_destroy = var.environment != "prd"
#     }
#   }
# }

# =============================================================================
# GCP Provider (uncomment if using GCP)
# =============================================================================

# provider "google" {
#   project = var.gcp_project_id
#   region  = var.region
# }
