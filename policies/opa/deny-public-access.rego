# OPA Policy: Deny Public Access
# Prevents resources from being publicly accessible

package terraform

import future.keywords.in

# Deny S3 buckets without public access block
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    resource.change.after.block_public_acls == false
    msg := sprintf("S3 bucket %s must have block_public_acls enabled", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    resource.change.after.block_public_policy == false
    msg := sprintf("S3 bucket %s must have block_public_policy enabled", [resource.address])
}

# Deny security groups allowing SSH from anywhere
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group_rule"
    resource.change.after.type == "ingress"
    resource.change.after.from_port <= 22
    resource.change.after.to_port >= 22
    cidr := resource.change.after.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    msg := sprintf("Security group rule %s allows SSH from 0.0.0.0/0", [resource.address])
}

# Deny security groups allowing RDP from anywhere
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group_rule"
    resource.change.after.type == "ingress"
    resource.change.after.from_port <= 3389
    resource.change.after.to_port >= 3389
    cidr := resource.change.after.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    msg := sprintf("Security group rule %s allows RDP from 0.0.0.0/0", [resource.address])
}

# Deny unencrypted EBS volumes
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    resource.change.after.encrypted == false
    msg := sprintf("EBS volume %s must be encrypted", [resource.address])
}

# Deny unencrypted RDS instances
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    resource.change.after.storage_encrypted == false
    msg := sprintf("RDS instance %s must have storage encryption enabled", [resource.address])
}

# Deny RDS instances without deletion protection in production
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    contains(resource.address, "prd")
    resource.change.after.deletion_protection == false
    msg := sprintf("Production RDS instance %s must have deletion protection enabled", [resource.address])
}

# Deny public subnets with auto-assign public IP
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_subnet"
    resource.change.after.map_public_ip_on_launch == true
    msg := sprintf("Subnet %s should not auto-assign public IPs", [resource.address])
}

# Azure: Deny storage accounts with public blob access
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.after.allow_nested_items_to_be_public == true
    msg := sprintf("Storage account %s must not allow public blob access", [resource.address])
}

# GCP: Deny instances with external IPs
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "google_compute_instance"
    network_interface := resource.change.after.network_interface[_]
    count(network_interface.access_config) > 0
    msg := sprintf("Compute instance %s should not have external IP", [resource.address])
}
