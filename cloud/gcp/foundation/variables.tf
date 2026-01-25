# GCP Foundation Module - Variables
# Standardized interface across all cloud providers

variable "environment" {
  type        = string
  description = "Environment name (dev/stg/prd)"
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd."
  }
}

variable "project" {
  type        = string
  description = "Project name (used for naming, not GCP project)"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project))
    error_message = "Project name must be lowercase alphanumeric with hyphens, 2-21 characters."
  }
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "asia-northeast1"
}

variable "network_cidr" {
  type        = string
  description = "VPC primary CIDR (used for subnet calculation)"
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.network_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "repository" {
  type        = string
  description = "Source repository for labeling"
  default     = "your-org/infra-template"
}

variable "labels" {
  type        = map(string)
  description = "Additional labels to apply to all resources"
  default     = {}
}
