# OPA Policy: Require Encryption
# Ensures all data at rest is encrypted

package terraform

import future.keywords.in

# Deny unencrypted S3 buckets
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not has_encryption_config(resource.address)
    msg := sprintf("S3 bucket %s must have encryption configured", [resource.address])
}

# Helper to check if bucket has encryption configuration
has_encryption_config(bucket_address) {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_server_side_encryption_configuration"
    contains(resource.address, bucket_address)
}

# Deny EBS volumes without encryption
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    not resource.change.after.encrypted
    msg := sprintf("EBS volume %s must be encrypted", [resource.address])
}

# Deny RDS without storage encryption
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    not resource.change.after.storage_encrypted
    msg := sprintf("RDS instance %s must have storage encryption", [resource.address])
}

# Deny Elasticache without encryption at rest
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_elasticache_replication_group"
    not resource.change.after.at_rest_encryption_enabled
    msg := sprintf("ElastiCache %s must have at-rest encryption", [resource.address])
}

# Deny Elasticache without encryption in transit
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_elasticache_replication_group"
    not resource.change.after.transit_encryption_enabled
    msg := sprintf("ElastiCache %s must have in-transit encryption", [resource.address])
}

# Azure: Deny unencrypted managed disks
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_managed_disk"
    resource.change.after.encryption_settings == null
    msg := sprintf("Managed disk %s must have encryption settings", [resource.address])
}

# GCP: Deny disks without CMEK
warn[msg] {
    resource := input.resource_changes[_]
    resource.type == "google_compute_disk"
    resource.change.after.disk_encryption_key == null
    msg := sprintf("Disk %s should use customer-managed encryption key", [resource.address])
}
