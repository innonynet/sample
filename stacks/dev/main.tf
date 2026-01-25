# Dev Environment Stack
# Entry point for dev environment infrastructure

# =============================================================================
# Foundation Layer
# =============================================================================

module "foundation" {
  source = "../../cloud/aws/foundation"
  # For Azure: source = "../../cloud/azure/foundation"
  # For GCP:   source = "../../cloud/gcp/foundation"

  environment  = var.environment
  project      = var.project
  network_cidr = var.network_cidr
  repository   = var.repository
  tags         = var.tags
}

# =============================================================================
# Network Layer
# =============================================================================

module "network" {
  source = "../../cloud/aws/network"
  # For Azure: source = "../../cloud/azure/network"
  # For GCP:   source = "../../cloud/gcp/network"

  environment         = var.environment
  project             = var.project
  vpc_id              = module.foundation.vpc_id
  network_cidr        = var.network_cidr
  internet_gateway_id = module.foundation.internet_gateway_id
  availability_zones  = module.foundation.availability_zones

  # For Azure, use these instead:
  # region              = module.foundation.region
  # resource_group_name = module.foundation.resource_group_name
  # vnet_name           = module.foundation.vnet_name

  # For GCP, use these instead:
  # region      = module.foundation.region
  # vpc_name    = module.foundation.vpc_name
  # router_name = module.foundation.router_name
}

# =============================================================================
# Platform Layer (Optional - uncomment when ready)
# =============================================================================

# module "platform" {
#   source = "../../cloud/aws/platform"
#
#   environment        = var.environment
#   project            = var.project
#   vpc_id             = module.foundation.vpc_id
#   public_subnet_ids  = module.network.public_subnet_ids
#   private_subnet_ids = module.network.private_subnet_ids
#   kms_key_arn        = module.foundation.kms_key_arn
# }

# =============================================================================
# Outputs
# =============================================================================

output "vpc_id" {
  value       = module.foundation.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = module.foundation.vpc_cidr
  description = "VPC CIDR"
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.network.private_subnet_ids
  description = "Private subnet IDs"
}

output "environment" {
  value       = var.environment
  description = "Environment name"
}
