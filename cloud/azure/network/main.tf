# Azure Network Module
# Creates subnets (VM, Bastion), NAT Gateway, NSGs

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

  # Subnet CIDR calculations
  # network_cidr: 10.0.0.0/16
  # vm_subnet:      10.0.1.0/24 (cidrsubnet /16 + 8 bits = /24, index 1)
  # bastion_subnet: 10.0.2.0/27 (cidrsubnet /16 + 11 bits = /27, index 64)
  vm_subnet_cidr      = cidrsubnet(var.network_cidr, 8, 1)   # /24
  bastion_subnet_cidr = cidrsubnet(var.network_cidr, 11, 64) # /27
}

# =============================================================================
# Subnets
# =============================================================================

# VM Subnet
resource "azurerm_subnet" "vm" {
  name                 = "snet-${var.project}-${var.environment}-vm"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.vm_subnet_cidr]
}

# AzureBastionSubnet (name must be exactly "AzureBastionSubnet")
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.bastion_subnet_cidr]
}

# =============================================================================
# NAT Gateway (for VM outbound internet access)
# =============================================================================

resource "azurerm_public_ip" "nat" {
  name                = "pip-${var.project}-${var.environment}-nat"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "azurerm_nat_gateway" "main" {
  name                    = "nat-${var.project}-${var.environment}"
  location                = var.region
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10

  tags = local.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "vm" {
  subnet_id      = azurerm_subnet.vm.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

# =============================================================================
# Network Security Groups
# =============================================================================

# NSG for VM subnet
resource "azurerm_network_security_group" "vm" {
  name                = "nsg-${var.project}-${var.environment}-vm"
  location            = var.region
  resource_group_name = var.resource_group_name

  # Allow SSH from Bastion subnet only
  security_rule {
    name                       = "AllowSSHFromBastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.bastion_subnet_cidr
    destination_address_prefix = "*"
  }

  # Deny SSH from Internet (explicit deny for clarity)
  security_rule {
    name                       = "DenySSHFromInternet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Deny RDP from Internet
  security_rule {
    name                       = "DenyRDPFromInternet"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.vm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}
