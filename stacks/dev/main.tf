# Dev Environment Stack
# Entry point for dev environment infrastructure (Azure)

# =============================================================================
# Foundation Layer
# =============================================================================

module "foundation" {
  source = "../../cloud/azure/foundation"

  environment  = var.environment
  project      = var.project
  region       = var.region
  network_cidr = var.network_cidr
  repository   = var.repository
  tags         = var.tags
}

# =============================================================================
# Network Layer
# =============================================================================

module "network" {
  source = "../../cloud/azure/network"

  environment         = var.environment
  project             = var.project
  region              = module.foundation.region
  resource_group_name = module.foundation.resource_group_name
  vnet_name           = module.foundation.vnet_name
  network_cidr        = var.network_cidr
}

# =============================================================================
# Platform Layer
# =============================================================================

module "platform" {
  source = "../../cloud/azure/platform"

  environment         = var.environment
  project             = var.project
  region              = module.foundation.region
  resource_group_name = module.foundation.resource_group_name
  vm_subnet_id        = module.network.vm_subnet_id
  bastion_subnet_id   = module.network.bastion_subnet_id
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  vm_size             = var.vm_size
}

# =============================================================================
# Outputs
# =============================================================================

output "resource_group_name" {
  value       = module.foundation.resource_group_name
  description = "Resource Group name"
}

output "vnet_id" {
  value       = module.foundation.vnet_id
  description = "VNet ID"
}

output "vm_public_ip" {
  value       = module.platform.vm_public_ip
  description = "VM public IP address"
}

output "vm_private_ip" {
  value       = module.platform.vm_private_ip
  description = "VM private IP address"
}

output "bastion_id" {
  value       = module.platform.bastion_id
  description = "Bastion host ID"
}

output "bastion_name" {
  value       = module.platform.bastion_name
  description = "Bastion host name"
}

output "environment" {
  value       = var.environment
  description = "Environment name"
}
