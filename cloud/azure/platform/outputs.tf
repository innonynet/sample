# Azure Platform Module - Outputs

output "vm_private_ip" {
  value       = azurerm_network_interface.vm.private_ip_address
  description = "VM private IP address"
}

output "vm_id" {
  value       = azurerm_linux_virtual_machine.main.id
  description = "VM ID"
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.main.name
  description = "VM name"
}

output "vm_identity_principal_id" {
  value       = azurerm_linux_virtual_machine.main.identity[0].principal_id
  description = "VM managed identity principal ID"
}

output "bastion_id" {
  value       = azurerm_bastion_host.main.id
  description = "Bastion host ID"
}

output "bastion_name" {
  value       = azurerm_bastion_host.main.name
  description = "Bastion host name"
}

output "bastion_public_ip" {
  value       = azurerm_public_ip.bastion.ip_address
  description = "Bastion public IP address"
}
