# GCP Platform Module - Variables

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
  description = "GCP region"
}

variable "vpc_id" {
  type        = string
  description = "VPC Network ID"
}

variable "vpc_name" {
  type        = string
  description = "VPC Network name"
}

variable "private_subnet_name" {
  type        = string
  description = "Private subnet name"
}

variable "pods_ip_range_name" {
  type        = string
  description = "GKE pods IP range name"
  default     = "pods"
}

variable "services_ip_range_name" {
  type        = string
  description = "GKE services IP range name"
  default     = "services"
}

variable "kms_key_id" {
  type        = string
  description = "KMS Key ID for encryption"
}
