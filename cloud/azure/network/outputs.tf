# Azure Network Module - Outputs

output "vm_subnet_id" {
  value       = azurerm_subnet.vm.id
  description = "VM subnet ID"
}

output "vm_subnet_cidr" {
  value       = local.vm_subnet_cidr
  description = "VM subnet CIDR"
}

output "bastion_subnet_id" {
  value       = azurerm_subnet.bastion.id
  description = "Bastion subnet ID"
}

output "bastion_subnet_cidr" {
  value       = local.bastion_subnet_cidr
  description = "Bastion subnet CIDR"
}

output "nat_gateway_id" {
  value       = azurerm_nat_gateway.main.id
  description = "NAT Gateway ID"
}

output "nat_public_ip" {
  value       = azurerm_public_ip.nat.ip_address
  description = "NAT Gateway public IP"
}

output "vm_nsg_id" {
  value       = azurerm_network_security_group.vm.id
  description = "VM NSG ID"
}
