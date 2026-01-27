# Stg Environment - Backend Configuration
# Using Terraform Cloud

terraform {
  cloud {
    organization = "your-org"

    workspaces {
      name = "infra-stg"
    }
  }
}
