# Prd Environment Stack
# Entry point for prd environment infrastructure
# NOTE: Production environment has additional safeguards

# =============================================================================
# Foundation Layer
# =============================================================================

module "foundation" {
  source = "../../cloud/aws/foundation"

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

  environment         = var.environment
  project             = var.project
  vpc_id              = module.foundation.vpc_id
  network_cidr        = var.network_cidr
  internet_gateway_id = module.foundation.internet_gateway_id
  availability_zones  = module.foundation.availability_zones
}

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
