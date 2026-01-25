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
  description = "Cloud region"
  default     = "ap-northeast-1"
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
