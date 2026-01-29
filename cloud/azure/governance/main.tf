# Azure Governance Module
# Creates Azure Policy definitions and assignments

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
# Data Sources
# =============================================================================

data "azurerm_subscription" "current" {}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }

  # Policy definition files
  policy_definitions = {
    deny_public_ip           = jsondecode(file("${path.module}/../../../policies/azure/definitions/deny-public-ip.json"))
    require_tags             = jsondecode(file("${path.module}/../../../policies/azure/definitions/require-tags.json"))
    allowed_vm_skus          = jsondecode(file("${path.module}/../../../policies/azure/definitions/allowed-vm-skus.json"))
    require_storage_encryption = jsondecode(file("${path.module}/../../../policies/azure/definitions/require-storage-encryption.json"))
  }
}

# =============================================================================
# Policy Definitions
# =============================================================================

resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip-${var.environment}"
  policy_type  = "Custom"
  mode         = local.policy_definitions.deny_public_ip.properties.mode
  display_name = local.policy_definitions.deny_public_ip.properties.displayName
  description  = local.policy_definitions.deny_public_ip.properties.description

  metadata    = jsonencode(local.policy_definitions.deny_public_ip.properties.metadata)
  parameters  = jsonencode(local.policy_definitions.deny_public_ip.properties.parameters)
  policy_rule = jsonencode(local.policy_definitions.deny_public_ip.properties.policyRule)
}

resource "azurerm_policy_definition" "require_tags" {
  name         = "require-tags-${var.environment}"
  policy_type  = "Custom"
  mode         = local.policy_definitions.require_tags.properties.mode
  display_name = local.policy_definitions.require_tags.properties.displayName
  description  = local.policy_definitions.require_tags.properties.description

  metadata    = jsonencode(local.policy_definitions.require_tags.properties.metadata)
  parameters  = jsonencode(local.policy_definitions.require_tags.properties.parameters)
  policy_rule = jsonencode(local.policy_definitions.require_tags.properties.policyRule)
}

resource "azurerm_policy_definition" "allowed_vm_skus" {
  name         = "allowed-vm-skus-${var.environment}"
  policy_type  = "Custom"
  mode         = local.policy_definitions.allowed_vm_skus.properties.mode
  display_name = local.policy_definitions.allowed_vm_skus.properties.displayName
  description  = local.policy_definitions.allowed_vm_skus.properties.description

  metadata    = jsonencode(local.policy_definitions.allowed_vm_skus.properties.metadata)
  parameters  = jsonencode(local.policy_definitions.allowed_vm_skus.properties.parameters)
  policy_rule = jsonencode(local.policy_definitions.allowed_vm_skus.properties.policyRule)
}

resource "azurerm_policy_definition" "require_storage_encryption" {
  name         = "require-storage-encryption-${var.environment}"
  policy_type  = "Custom"
  mode         = local.policy_definitions.require_storage_encryption.properties.mode
  display_name = local.policy_definitions.require_storage_encryption.properties.displayName
  description  = local.policy_definitions.require_storage_encryption.properties.description

  metadata    = jsonencode(local.policy_definitions.require_storage_encryption.properties.metadata)
  parameters  = jsonencode(local.policy_definitions.require_storage_encryption.properties.parameters)
  policy_rule = jsonencode(local.policy_definitions.require_storage_encryption.properties.policyRule)
}

# =============================================================================
# Policy Assignments (Resource Group Scope)
# =============================================================================

resource "azurerm_resource_group_policy_assignment" "deny_public_ip" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "deny-public-ip-assignment"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  description          = "Denies creation of Public IPs except for Bastion and NAT Gateway"

  parameters = jsonencode({
    effect = {
      value = var.policy_effect
    }
    allowedNamePatterns = {
      value = var.allowed_public_ip_patterns
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "require_tags" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "require-tags-assignment"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  description          = "Requires mandatory tags on all resources"

  parameters = jsonencode({
    effect = {
      value = var.policy_effect
    }
    tagName1 = {
      value = "Environment"
    }
    tagName2 = {
      value = "Project"
    }
    tagName3 = {
      value = "ManagedBy"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "allowed_vm_skus" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "allowed-vm-skus-assignment"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.allowed_vm_skus.id
  description          = "Restricts VM sizes to approved SKUs"

  parameters = jsonencode({
    effect = {
      value = var.policy_effect
    }
    allowedSkus = {
      value = var.allowed_vm_skus
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "require_storage_encryption" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "require-storage-encryption-assignment"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.require_storage_encryption.id
  description          = "Ensures storage accounts use secure configuration"

  parameters = jsonencode({
    effect = {
      value = var.policy_effect
    }
    minimumTlsVersion = {
      value = "TLS1_2"
    }
  })
}
