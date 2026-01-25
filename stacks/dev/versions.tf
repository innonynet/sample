terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Uncomment for Azure
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "~> 3.0"
    # }
    # Uncomment for GCP
    # google = {
    #   source  = "hashicorp/google"
    #   version = "~> 5.0"
    # }
  }
}
