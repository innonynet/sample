# Creating a New Module

This guide explains how to create and integrate a new Terraform module.

## Module Structure

Each module follows this structure:

```
cloud/azure/<module_name>/
  ├── main.tf          # Resources
  ├── variables.tf     # Input variables
  ├── outputs.tf       # Output values
  └── README.md        # Documentation (auto-generated)
```

## Steps

### 1. Generate Module Structure

Use the provided script:

```bash
./scripts/new-module.sh <module_name>
```

**Example:**

```bash
./scripts/new-module.sh storage
```

This creates:
- `cloud/azure/storage/main.tf`
- `cloud/azure/storage/variables.tf`
- `cloud/azure/storage/outputs.tf`

### 2. Implement the Module

**main.tf:**

```hcl
# Azure Storage Module

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

resource "azurerm_storage_account" "main" {
  name                     = "st${var.project}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_tier             = var.account_tier
  account_replication_type = var.replication_type

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  tags = local.common_tags
}
```

**variables.tf:**

```hcl
variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "region" {
  type        = string
  description = "Azure region"
}

variable "account_tier" {
  type        = string
  description = "Storage account tier"
  default     = "Standard"
}

variable "replication_type" {
  type        = string
  description = "Storage replication type"
  default     = "LRS"
}
```

**outputs.tf:**

```hcl
output "storage_account_id" {
  value       = azurerm_storage_account.main.id
  description = "Storage account ID"
}

output "storage_account_name" {
  value       = azurerm_storage_account.main.name
  description = "Storage account name"
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.main.primary_blob_endpoint
  description = "Primary blob endpoint"
}
```

### 3. Add to Stack

Edit `stacks/<env>/main.tf`:

```hcl
module "storage" {
  source = "../../cloud/azure/storage"

  environment         = var.environment
  project             = var.project
  region              = module.foundation.region
  resource_group_name = module.foundation.resource_group_name
  account_tier        = "Standard"
  replication_type    = "LRS"
}
```

### 4. Generate Documentation

```bash
./scripts/docs-generate.sh cloud/azure/storage
```

Or push to trigger the docs workflow.

### 5. Test the Module

1. Run `terraform init` in the stack
2. Run `terraform plan` to verify
3. Create a PR for review
4. Apply after approval

## Best Practices

### Naming Conventions

- Module directory: lowercase, hyphen-separated
- Resource names: include project and environment
- Variables: descriptive, with defaults where sensible

### Common Tags

Always include common tags on resources:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}
```

### Security

- Enable encryption by default
- Restrict network access
- Use managed identities where possible
- Follow the principle of least privilege

### Version Constraints

Specify provider version constraints:

```hcl
terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
```

## Policy Compliance

Ensure your module complies with organization policies:

- [ ] Required tags applied
- [ ] Encryption enabled
- [ ] Network restrictions configured
- [ ] No public IPs (unless approved)
- [ ] Approved SKUs used

Run policy check locally:

```bash
cd stacks/<env>
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json --policy ../../policies/opa/terraform
```
