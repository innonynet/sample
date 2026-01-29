# Azure Observability Module - Variables

variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd)"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "vm_id" {
  type        = string
  description = "VM resource ID for alerts"
  default     = ""
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID"
  default     = ""
}

variable "oncall_email" {
  type        = string
  description = "On-call email address for alert notifications"
}

variable "enable_alerts" {
  type        = bool
  description = "Enable alert rules (typically disabled for dev)"
  default     = true
}

# =============================================================================
# Alert Thresholds
# =============================================================================

variable "cpu_threshold_critical" {
  type        = number
  description = "CPU percentage threshold for critical alerts"
  default     = 95
}

variable "cpu_threshold_warning" {
  type        = number
  description = "CPU percentage threshold for warning alerts"
  default     = 80
}

variable "memory_threshold_critical" {
  type        = number
  description = "Memory percentage threshold for critical alerts"
  default     = 95
}

variable "memory_threshold_warning" {
  type        = number
  description = "Memory percentage threshold for warning alerts"
  default     = 85
}

variable "disk_threshold_critical" {
  type        = number
  description = "Disk percentage threshold for critical alerts"
  default     = 95
}

variable "disk_threshold_warning" {
  type        = number
  description = "Disk percentage threshold for warning alerts"
  default     = 85
}
