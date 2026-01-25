#!/bin/bash
# Import existing resources into Terraform state
# Usage: ./import-state.sh <environment> <resource_address> <resource_id>

set -euo pipefail

ENV="${1:-}"
RESOURCE_ADDRESS="${2:-}"
RESOURCE_ID="${3:-}"

if [ -z "$ENV" ] || [ -z "$RESOURCE_ADDRESS" ] || [ -z "$RESOURCE_ID" ]; then
    echo "Usage: ./import-state.sh <environment> <resource_address> <resource_id>"
    echo ""
    echo "Examples:"
    echo "  ./import-state.sh dev aws_vpc.main vpc-12345678"
    echo "  ./import-state.sh prd module.foundation.aws_vpc.main vpc-87654321"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
STACK_DIR="$ROOT_DIR/stacks/$ENV"

if [ ! -d "$STACK_DIR" ]; then
    echo "Error: Stack directory not found: $STACK_DIR"
    exit 1
fi

cd "$STACK_DIR"

echo "=== Importing Resource ==="
echo "Environment: $ENV"
echo "Address: $RESOURCE_ADDRESS"
echo "ID: $RESOURCE_ID"
echo ""

echo "Initializing Terraform..."
terraform init -input=false

echo ""
echo "Importing resource..."
terraform import "$RESOURCE_ADDRESS" "$RESOURCE_ID"

echo ""
echo "Verifying import..."
terraform state show "$RESOURCE_ADDRESS"

echo ""
echo "=== Import Complete ==="
echo ""
echo "Next steps:"
echo "1. Run 'terraform plan' to verify no changes"
echo "2. Update code if needed to match imported state"
