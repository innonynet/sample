# Tagging Module
# Provides consistent tagging/labeling across resources

variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stg/prd)"
}

variable "owner" {
  type        = string
  description = "Team or person responsible"
  default     = "platform-team"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing"
  default     = ""
}

variable "repository" {
  type        = string
  description = "Source repository"
  default     = ""
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to merge"
  default     = {}
}

locals {
  # Base tags (always applied)
  base_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
  }

  # Optional tags (only if provided)
  optional_tags = merge(
    var.cost_center != "" ? { CostCenter = var.cost_center } : {},
    var.repository != "" ? { Repository = var.repository } : {}
  )

  # All tags combined
  all_tags = merge(local.base_tags, local.optional_tags, var.additional_tags)

  # GCP-compatible labels (lowercase, limited charset)
  gcp_labels = {
    for k, v in local.all_tags :
    lower(replace(k, "/[^a-z0-9_-]/", "_")) => lower(replace(v, "/[^a-z0-9_-]/", "_"))
  }
}

output "tags" {
  value       = local.all_tags
  description = "Tags for AWS/Azure resources"
}

output "labels" {
  value       = local.gcp_labels
  description = "Labels for GCP resources"
}

output "base_tags" {
  value       = local.base_tags
  description = "Minimal required tags"
}
