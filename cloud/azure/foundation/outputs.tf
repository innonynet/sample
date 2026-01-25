# Azure Foundation Module - Outputs
# Standardized interface across all cloud providers

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource Group name"
}

output "resource_group_id" {
  value       = azurerm_resource_group.main.id
  description = "Resource Group ID"
}

output "vpc_id" {
  value       = azurerm_virtual_network.main.id
  description = "VNet ID (standardized as vpc_id)"
}

output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "VNet ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.main.name
  description = "VNet name"
}

output "vpc_cidr" {
  value       = azurerm_virtual_network.main.address_space[0]
  description = "VNet address space (standardized as vpc_cidr)"
}

output "key_vault_id" {
  value       = azurerm_key_vault.main.id
  description = "Key Vault ID"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.main.vault_uri
  description = "Key Vault URI"
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.main.id
  description = "Log Analytics Workspace ID"
}

output "region" {
  value       = azurerm_resource_group.main.location
  description = "Azure region"
}

output "common_tags" {
  value       = local.common_tags
  description = "Common tags applied to all resources"
}
