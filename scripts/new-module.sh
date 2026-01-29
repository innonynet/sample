#!/bin/bash
# Create a new Terraform module from template
# Usage: ./scripts/new-module.sh <module_name> [provider]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    cat << EOF
Usage: $0 <module_name> [provider]

Create a new Terraform module with standard structure.

Arguments:
  module_name     Name of the module (e.g., storage, database)
  provider        Cloud provider (default: azure)

Options:
  -h, --help      Show this help message

Examples:
  $0 storage
  $0 database azure
  $0 cdn
EOF
    exit 0
}

# Parse arguments
if [ $# -lt 1 ]; then
    echo "Error: Module name is required"
    usage
fi

MODULE_NAME="$1"
PROVIDER="${2:-azure}"

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
fi

# Validate module name
if [[ ! "$MODULE_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "Error: Module name must start with a letter and contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Check if module already exists
MODULE_DIR="$REPO_ROOT/cloud/$PROVIDER/$MODULE_NAME"
if [ -d "$MODULE_DIR" ]; then
    echo "Error: Module '$MODULE_NAME' already exists at $MODULE_DIR"
    exit 1
fi

echo "=== Creating new module: $MODULE_NAME ==="
echo ""
echo "Provider: $PROVIDER"
echo "Location: $MODULE_DIR"
echo ""

# Create module directory
mkdir -p "$MODULE_DIR"

# Generate main.tf
cat > "$MODULE_DIR/main.tf" << 'EOF'
# Azure MODULE_NAME_PLACEHOLDER Module
# Description: TODO - Add module description

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
# Resources
# =============================================================================

# TODO: Add resources here
EOF

sed -i "s/MODULE_NAME_PLACEHOLDER/${MODULE_NAME^}/g" "$MODULE_DIR/main.tf"

# Generate variables.tf
cat > "$MODULE_DIR/variables.tf" << 'EOF'
# Azure MODULE_NAME_PLACEHOLDER Module - Variables

variable "environment" {
  type        = string
  description = "Environment name (dev, stg, prd)"
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

# TODO: Add module-specific variables here
EOF

sed -i "s/MODULE_NAME_PLACEHOLDER/${MODULE_NAME^}/g" "$MODULE_DIR/variables.tf"

# Generate outputs.tf
cat > "$MODULE_DIR/outputs.tf" << 'EOF'
# Azure MODULE_NAME_PLACEHOLDER Module - Outputs

# TODO: Add outputs here

# Example:
# output "resource_id" {
#   value       = azurerm_resource.main.id
#   description = "Resource ID"
# }
EOF

sed -i "s/MODULE_NAME_PLACEHOLDER/${MODULE_NAME^}/g" "$MODULE_DIR/outputs.tf"

echo ""
echo "=== Module created successfully ==="
echo ""
echo "Created files:"
echo "  - $MODULE_DIR/main.tf"
echo "  - $MODULE_DIR/variables.tf"
echo "  - $MODULE_DIR/outputs.tf"
echo ""
echo "Next steps:"
echo "  1. Add resources to main.tf"
echo "  2. Define variables in variables.tf"
echo "  3. Define outputs in outputs.tf"
echo "  4. Add module to stack (stacks/<env>/main.tf)"
echo "  5. Run: ./scripts/docs-generate.sh"
echo ""
