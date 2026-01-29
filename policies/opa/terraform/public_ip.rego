# Policy: Public IP Restriction
# Denies creation of Public IPs except for Bastion and NAT Gateway

package terraform.azure

# Deny Public IP resources that are not for Bastion or NAT Gateway
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_public_ip"
    resource.change.actions[_] == "create"

    # Check if the resource name/address contains allowed patterns
    not is_allowed_public_ip(resource)

    msg := sprintf("Public IP creation is restricted. Only Bastion and NAT Gateway Public IPs are allowed: %s", [resource.address])
}

# Helper function to check if Public IP is allowed
is_allowed_public_ip(resource) {
    contains(lower(resource.address), "bastion")
}

is_allowed_public_ip(resource) {
    contains(lower(resource.address), "nat")
}

is_allowed_public_ip(resource) {
    contains(lower(resource.change.after.name), "bastion")
}

is_allowed_public_ip(resource) {
    contains(lower(resource.change.after.name), "nat")
}
