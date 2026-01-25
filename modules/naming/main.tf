# Naming Module
# Provides consistent naming across resources

variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stg/prd)"
}

variable "region" {
  type        = string
  description = "Cloud region"
  default     = ""
}

variable "component" {
  type        = string
  description = "Component name"
  default     = ""
}

locals {
  # Region short codes
  region_short = {
    # AWS
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-southeast-1" = "apse1"
    "us-east-1"      = "use1"
    "us-west-2"      = "usw2"
    "eu-west-1"      = "euw1"
    # Azure
    "japaneast"     = "jpe"
    "japanwest"     = "jpw"
    "eastus"        = "eus"
    "westeurope"    = "weu"
    # GCP
    "asia-northeast1" = "ane1"
    "asia-northeast2" = "ane2"
    "us-central1"     = "usc1"
    "europe-west1"    = "euw1"
  }

  region_code = var.region != "" ? lookup(local.region_short, var.region, substr(replace(var.region, "-", ""), 0, 6)) : ""

  # Base name without component
  base_name = var.region != "" ? "${var.project}-${var.environment}-${local.region_code}" : "${var.project}-${var.environment}"

  # Full name with optional component
  full_name = var.component != "" ? "${local.base_name}-${var.component}" : local.base_name
}

output "base_name" {
  value       = local.base_name
  description = "Base resource name"
}

output "full_name" {
  value       = local.full_name
  description = "Full resource name with component"
}

output "region_code" {
  value       = local.region_code
  description = "Short region code"
}

# Resource-specific naming
output "vpc_name" {
  value = "${local.base_name}-vpc"
}

output "subnet_name" {
  value = "${local.base_name}-subnet"
}

output "security_group_name" {
  value = "${local.base_name}-sg"
}

output "iam_role_name" {
  value = "${local.base_name}-role"
}

output "s3_bucket_prefix" {
  value = lower(replace("${var.project}-${var.environment}", "_", "-"))
}
