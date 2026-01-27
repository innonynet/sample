# Dev Environment - Backend Configuration
# Using Terraform Cloud

terraform {
  cloud {
    organization = "Innospot"

    workspaces {
      name = "infra-dev"
    }
  }
}
