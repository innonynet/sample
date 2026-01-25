# AWS Foundation Module - Outputs
# Standardized interface across all cloud providers

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main.id
  description = "Internet Gateway ID"
}

output "kms_key_id" {
  value       = aws_kms_key.main.id
  description = "KMS Key ID"
}

output "kms_key_arn" {
  value       = aws_kms_key.main.arn
  description = "KMS Key ARN"
}

output "availability_zones" {
  value       = local.azs
  description = "Available AZs"
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID"
}

output "region" {
  value       = data.aws_region.current.name
  description = "AWS Region"
}

output "common_tags" {
  value       = local.common_tags
  description = "Common tags applied to all resources"
}
