# Azure Platform Module
# Creates VM, Bastion, Public IPs, NIC

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# Public IP for VM
# =============================================================================

resource "azurerm_public_ip" "vm" {
  name                = "pip-${var.project}-${var.environment}-vm"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

# =============================================================================
# Public IP for Bastion
# =============================================================================

resource "azurerm_public_ip" "bastion" {
  name                = "pip-${var.project}-${var.environment}-bastion"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

# =============================================================================
# Network Interface for VM
# =============================================================================

resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.project}-${var.environment}-vm"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }

  tags = local.common_tags
}

# =============================================================================
# Linux Virtual Machine
# =============================================================================

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-${var.project}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.region
  size                = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk-${var.project}-${var.environment}-vm"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# =============================================================================
# Azure Bastion
# =============================================================================

resource "azurerm_bastion_host" "main" {
  name                = "bas-${var.project}-${var.environment}"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  copy_paste_enabled     = true
  file_copy_enabled      = true
  tunneling_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = false

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = local.common_tags
}
