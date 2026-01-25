#!/bin/bash
# Setup Azure Storage Backend for Terraform State
# Usage: ./setup-backend-azure.sh [resource-group] [storage-account] [location]

set -euo pipefail

# Configuration
RESOURCE_GROUP="${1:-rg-terraform-state}"
STORAGE_ACCOUNT="${2:-stterraformstate$(openssl rand -hex 4)}"
LOCATION="${3:-japaneast}"
CONTAINER_NAME="tfstate"

echo "=== Setting up Terraform Backend (Azure) ==="
echo "Resource Group: $RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT"
echo "Location: $LOCATION"
echo "Container: $CONTAINER_NAME"
echo ""

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed"
    exit 1
fi

# Check Azure login
if ! az account show &> /dev/null; then
    echo "Error: Not logged in to Azure. Run 'az login' first."
    exit 1
fi

echo "1. Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

echo "2. Creating storage account..."
az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --https-only true \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --output none

echo "3. Creating blob container..."
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT" \
    --auth-mode login \
    --output none

echo "4. Enabling versioning..."
az storage account blob-service-properties update \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --enable-versioning true \
    --output none

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Add this to your backend.tf:"
echo ""
echo 'terraform {'
echo '  backend "azurerm" {'
echo "    resource_group_name  = \"$RESOURCE_GROUP\""
echo "    storage_account_name = \"$STORAGE_ACCOUNT\""
echo "    container_name       = \"$CONTAINER_NAME\""
echo '    key                  = "<env>/terraform.tfstate"'
echo '  }'
echo '}'
