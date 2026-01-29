# Azure Governance Module - Outputs

output "policy_definition_ids" {
  value = {
    deny_public_ip           = azurerm_policy_definition.deny_public_ip.id
    require_tags             = azurerm_policy_definition.require_tags.id
    allowed_vm_skus          = azurerm_policy_definition.allowed_vm_skus.id
    require_storage_encryption = azurerm_policy_definition.require_storage_encryption.id
  }
  description = "Map of policy definition IDs"
}

output "policy_assignment_ids" {
  value = var.enable_policy_assignments ? {
    deny_public_ip           = azurerm_resource_group_policy_assignment.deny_public_ip[0].id
    require_tags             = azurerm_resource_group_policy_assignment.require_tags[0].id
    allowed_vm_skus          = azurerm_resource_group_policy_assignment.allowed_vm_skus[0].id
    require_storage_encryption = azurerm_resource_group_policy_assignment.require_storage_encryption[0].id
  } : {}
  description = "Map of policy assignment IDs"
}
