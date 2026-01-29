# Policy: Mandatory Tags
# Enforces required tags on all resources

package terraform.azure

import data.required_tags

# Default required tags if data file is not available
default_required_tags := ["Environment", "Project", "ManagedBy"]

# Get required tags from data or use defaults
get_required_tags = tags {
    tags := required_tags.tags
} else = tags {
    tags := default_required_tags
}

# Resource types that should have tags
taggable_resources := [
    "azurerm_resource_group",
    "azurerm_virtual_network",
    "azurerm_subnet",
    "azurerm_network_security_group",
    "azurerm_public_ip",
    "azurerm_network_interface",
    "azurerm_linux_virtual_machine",
    "azurerm_windows_virtual_machine",
    "azurerm_bastion_host",
    "azurerm_key_vault",
    "azurerm_storage_account",
    "azurerm_log_analytics_workspace",
    "azurerm_nat_gateway"
]

# Deny resources missing required tags
deny[msg] {
    resource := input.resource_changes[_]
    resource.change.actions[_] == "create"

    # Check if resource type is taggable
    resource.type == taggable_resources[_]

    # Get required tags
    required := get_required_tags[_]

    # Check if tag is missing
    not has_tag(resource, required)

    msg := sprintf("Missing required tag '%s' on resource: %s", [required, resource.address])
}

# Helper function to check if resource has a tag
has_tag(resource, tag_name) {
    resource.change.after.tags[tag_name]
}
