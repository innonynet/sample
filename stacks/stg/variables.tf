# Stg Environment - Variables

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "stg"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  description = "Azure region"
  default     = "japaneast"
}

variable "network_cidr" {
  type        = string
  description = "Network CIDR block"
  default     = "10.1.0.0/16"
}

variable "repository" {
  type        = string
  description = "Source repository"
  default     = "your-org/infra-template"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

# VM-related variables

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
