# Azure Foundation Module
# Creates base infrastructure: Resource Group, VNet, Key Vault

# =============================================================================
# Data Sources
# =============================================================================

data "azurerm_client_config" "current" {}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
    Repository  = var.repository
  }

  location_short = {
    "japaneast"     = "jpe"
    "japanwest"     = "jpw"
    "eastus"        = "eus"
    "westus"        = "wus"
    "westeurope"    = "weu"
    "northeurope"   = "neu"
    "southeastasia" = "sea"
  }
}

# =============================================================================
# Resource Group
# =============================================================================

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.region

  tags = local.common_tags
}

# =============================================================================
# Virtual Network
# =============================================================================

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.network_cidr]

  tags = local.common_tags
}

# =============================================================================
# Key Vault
# =============================================================================

resource "azurerm_key_vault" "main" {
  name                = "kv-${var.project}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = var.environment == "prd" ? 90 : 7
  purge_protection_enabled   = var.environment == "prd" ? true : false

  enabled_for_disk_encryption = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = local.common_tags
}

# =============================================================================
# Log Analytics Workspace
# =============================================================================

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prd" ? 365 : 30

  tags = local.common_tags
}
