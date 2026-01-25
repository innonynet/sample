# Azure Network Module - Variables

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

variable "vnet_name" {
  type        = string
  description = "VNet name"
}

variable "network_cidr" {
  type        = string
  description = "VNet address space"
}
