# Dev Environment - Backend Configuration
# Choose ONE of the following options:

# =============================================================================
# Option 1: Terraform Cloud
# =============================================================================

# terraform {
#   cloud {
#     organization = "your-org"
#     workspaces {
#       name = "infra-dev"
#     }
#   }
# }

# =============================================================================
# Option 2: AWS S3 Backend
# =============================================================================

# terraform {
#   backend "s3" {
#     bucket         = "your-org-terraform-state"
#     key            = "dev/terraform.tfstate"
#     region         = "ap-northeast-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

# =============================================================================
# Option 3: Azure Storage Backend
# =============================================================================

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "stterraformstate"
#     container_name       = "tfstate"
#     key                  = "dev/terraform.tfstate"
#   }
# }

# =============================================================================
# Option 4: GCP Cloud Storage Backend
# =============================================================================

# terraform {
#   backend "gcs" {
#     bucket = "your-org-terraform-state"
#     prefix = "dev"
#   }
# }

# =============================================================================
# Option 5: Local Backend (for initial testing only)
# =============================================================================

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
