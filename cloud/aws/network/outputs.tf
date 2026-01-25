# AWS Network Module - Outputs

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Private subnet IDs"
}

output "public_subnet_cidrs" {
  value       = aws_subnet.public[*].cidr_block
  description = "Public subnet CIDR blocks"
}

output "private_subnet_cidrs" {
  value       = aws_subnet.private[*].cidr_block
  description = "Private subnet CIDR blocks"
}

output "nat_gateway_ids" {
  value       = aws_nat_gateway.main[*].id
  description = "NAT Gateway IDs"
}

output "nat_gateway_public_ips" {
  value       = aws_eip.nat[*].public_ip
  description = "NAT Gateway public IPs"
}
