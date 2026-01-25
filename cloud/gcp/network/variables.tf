# GCP Network Module - Variables

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

variable "vpc_name" {
  type        = string
  description = "VPC Network name"
}

variable "network_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "router_name" {
  type        = string
  description = "Cloud Router name"
}
