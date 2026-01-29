# Policy: Storage Encryption
# Enforces secure configuration for storage accounts

package terraform.azure

# Deny storage accounts without HTTPS-only traffic
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] == "create"

    # Check if https_traffic_only_enabled is explicitly set to false
    resource.change.after.https_traffic_only_enabled == false

    msg := sprintf("Storage account must have HTTPS-only traffic enabled: %s", [resource.address])
}

# Deny storage accounts without TLS 1.2 minimum
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] == "create"

    # Check TLS version
    tls_version := resource.change.after.min_tls_version
    not is_valid_tls_version(tls_version)

    msg := sprintf("Storage account must use TLS 1.2 or higher. Current: %s. Resource: %s", [tls_version, resource.address])
}

# Deny storage accounts with public blob access enabled
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] == "create"

    # Check if public access is allowed
    resource.change.after.allow_nested_items_to_be_public == true

    msg := sprintf("Storage account must not allow public blob access: %s", [resource.address])
}

# Deny storage accounts without infrastructure encryption
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.actions[_] == "create"

    # Infrastructure encryption is recommended for sensitive data
    resource.change.after.infrastructure_encryption_enabled == false

    msg := sprintf("Storage account should have infrastructure encryption enabled for enhanced security: %s", [resource.address])
}

# Helper function to validate TLS version
is_valid_tls_version(version) {
    version == "TLS1_2"
}

is_valid_tls_version(version) {
    version == "TLS1_3"
}
