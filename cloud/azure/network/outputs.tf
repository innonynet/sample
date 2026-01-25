# Azure Network Module - Outputs

output "public_subnet_id" {
  value       = azurerm_subnet.public.id
  description = "Public subnet ID"
}

output "private_subnet_id" {
  value       = azurerm_subnet.private.id
  description = "Private subnet ID"
}

output "database_subnet_id" {
  value       = azurerm_subnet.database.id
  description = "Database subnet ID"
}

output "public_subnet_ids" {
  value       = [azurerm_subnet.public.id]
  description = "Public subnet IDs (standardized)"
}

output "private_subnet_ids" {
  value       = [azurerm_subnet.private.id]
  description = "Private subnet IDs (standardized)"
}

output "nat_gateway_id" {
  value       = azurerm_nat_gateway.main.id
  description = "NAT Gateway ID"
}

output "nat_public_ip" {
  value       = azurerm_public_ip.nat.ip_address
  description = "NAT Gateway public IP"
}

output "public_nsg_id" {
  value       = azurerm_network_security_group.public.id
  description = "Public NSG ID"
}

output "private_nsg_id" {
  value       = azurerm_network_security_group.private.id
  description = "Private NSG ID"
}
