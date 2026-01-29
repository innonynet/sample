# Policy: VM SKU Restriction
# Restricts VM sizes to an allowed list

package terraform.azure

import data.allowed_skus

# Default allowed SKUs if data file is not available
default_allowed_vm_skus := [
    "Standard_B1s",
    "Standard_B1ms",
    "Standard_B2s",
    "Standard_B2ms",
    "Standard_D2s_v3",
    "Standard_D2s_v4",
    "Standard_D2s_v5",
    "Standard_D4s_v3",
    "Standard_D4s_v4",
    "Standard_D4s_v5"
]

# Get allowed SKUs from data or use defaults
get_allowed_vm_skus = skus {
    skus := allowed_skus.vm
} else = skus {
    skus := default_allowed_vm_skus
}

# Deny VMs with non-allowed SKUs
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_linux_virtual_machine"
    resource.change.actions[_] == "create"

    sku := resource.change.after.size
    allowed := get_allowed_vm_skus

    not sku_allowed(sku, allowed)

    msg := sprintf("VM SKU '%s' is not in the allowed list. Allowed SKUs: %v. Resource: %s", [sku, allowed, resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_windows_virtual_machine"
    resource.change.actions[_] == "create"

    sku := resource.change.after.size
    allowed := get_allowed_vm_skus

    not sku_allowed(sku, allowed)

    msg := sprintf("VM SKU '%s' is not in the allowed list. Allowed SKUs: %v. Resource: %s", [sku, allowed, resource.address])
}

# Helper function to check if SKU is in allowed list
sku_allowed(sku, allowed) {
    sku == allowed[_]
}
