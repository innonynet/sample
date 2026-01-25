# Azure Platform Module - Variables

variable "environment" {
  type        = string
  description = "Environment name (dev/stg/prd)"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet ID"
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault ID"
}
