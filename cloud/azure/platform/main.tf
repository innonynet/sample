# Azure Platform Module
# Creates application platform: AKS, Azure SQL, etc.
# This is a placeholder - extend based on your needs

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# AKS Cluster (Optional - uncomment to use)
# =============================================================================

# resource "azurerm_kubernetes_cluster" "main" {
#   name                = "aks-${var.project}-${var.environment}"
#   location            = var.region
#   resource_group_name = var.resource_group_name
#   dns_prefix          = "${var.project}-${var.environment}"
#
#   default_node_pool {
#     name           = "default"
#     node_count     = var.environment == "prd" ? 3 : 1
#     vm_size        = "Standard_D2_v2"
#     vnet_subnet_id = var.private_subnet_id
#   }
#
#   identity {
#     type = "SystemAssigned"
#   }
#
#   network_profile {
#     network_plugin = "azure"
#     network_policy = "azure"
#   }
#
#   tags = local.common_tags
# }

# =============================================================================
# Azure SQL (Optional - uncomment to use)
# =============================================================================

# resource "azurerm_mssql_server" "main" {
#   name                         = "sql-${var.project}-${var.environment}"
#   resource_group_name          = var.resource_group_name
#   location                     = var.region
#   version                      = "12.0"
#   administrator_login          = "sqladmin"
#   administrator_login_password = var.sql_admin_password
#
#   minimum_tls_version = "1.2"
#
#   tags = local.common_tags
# }
