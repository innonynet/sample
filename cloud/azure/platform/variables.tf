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

variable "vm_subnet_id" {
  type        = string
  description = "VM subnet ID"
}

variable "bastion_subnet_id" {
  type        = string
  description = "Bastion subnet ID"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VM"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM authentication"
}

variable "vm_size" {
  type        = string
  description = "VM size"
  default     = "Standard_B2s"
}

variable "allowed_inbound_cidrs" {
  type        = list(string)
  description = "CIDRs allowed for inbound traffic (e.g., for HTTP/HTTPS)"
  default     = []
}
