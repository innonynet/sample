# AWS Network Module - Variables

variable "environment" {
  type        = string
  description = "Environment name (dev/stg/prd)"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "network_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "internet_gateway_id" {
  type        = string
  description = "Internet Gateway ID"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}
