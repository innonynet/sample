# Azure Governance Module - Variables

variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd)"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "resource_group_id" {
  type        = string
  description = "Resource Group ID for policy assignments"
}

variable "enable_policy_assignments" {
  type        = bool
  description = "Enable policy assignments (set to false for policy definition only)"
  default     = true
}

variable "policy_effect" {
  type        = string
  description = "Policy effect (Audit, Deny, or Disabled)"
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.policy_effect)
    error_message = "Policy effect must be Audit, Deny, or Disabled."
  }
}

variable "allowed_public_ip_patterns" {
  type        = list(string)
  description = "Allowed name patterns for Public IPs"
  default     = ["*bastion*", "*nat*"]
}

variable "allowed_vm_skus" {
  type        = list(string)
  description = "List of allowed VM SKUs"
  default = [
    "Standard_B1s",
    "Standard_B1ms",
    "Standard_B2s",
    "Standard_B2ms",
    "Standard_D2s_v3",
    "Standard_D2s_v4",
    "Standard_D2s_v5",
    "Standard_D4s_v3",
    "Standard_D4s_v4",
    "Standard_D4s_v5",
    "Standard_D8s_v3",
    "Standard_D8s_v4",
    "Standard_D8s_v5"
  ]
}
