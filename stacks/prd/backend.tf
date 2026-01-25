# Prd Environment - Backend Configuration

# terraform {
#   cloud {
#     organization = "your-org"
#     workspaces {
#       name = "infra-prd"
#     }
#   }
# }

# terraform {
#   backend "s3" {
#     bucket         = "your-org-terraform-state"
#     key            = "prd/terraform.tfstate"
#     region         = "ap-northeast-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
