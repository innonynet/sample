#!/bin/bash
# Create a new environment stack from template
# Usage: ./scripts/new-stack.sh <env_name> [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/templates/stack"

# Default values
PROJECT_NAME="demo"
REGION="japaneast"
NETWORK_CIDR="10.0.0.0/16"
VM_SIZE="Standard_D2s_v3"
TFC_ORG="your-org"
TFC_WORKSPACE_PREFIX="infra"

usage() {
    cat << EOF
Usage: $0 <env_name> [options]

Create a new Terraform stack for an environment.

Arguments:
  env_name              Environment name (e.g., dev, stg, prd, test)

Options:
  -p, --project         Project name (default: $PROJECT_NAME)
  -r, --region          Azure region (default: $REGION)
  -n, --network-cidr    Network CIDR (default: $NETWORK_CIDR)
  -v, --vm-size         VM size (default: $VM_SIZE)
  -o, --org             Terraform Cloud organization (default: $TFC_ORG)
  -w, --workspace       Workspace prefix (default: $TFC_WORKSPACE_PREFIX)
  -h, --help            Show this help message

Examples:
  $0 test
  $0 qa --project myproject --region westus2
  $0 sandbox -p demo -r japaneast -n "10.1.0.0/16"
EOF
    exit 0
}

# Parse arguments
if [ $# -lt 1 ]; then
    echo "Error: Environment name is required"
    usage
fi

ENV_NAME="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -n|--network-cidr)
            NETWORK_CIDR="$2"
            shift 2
            ;;
        -v|--vm-size)
            VM_SIZE="$2"
            shift 2
            ;;
        -o|--org)
            TFC_ORG="$2"
            shift 2
            ;;
        -w|--workspace)
            TFC_WORKSPACE_PREFIX="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate environment name
if [[ ! "$ENV_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "Error: Environment name must start with a letter and contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Check if stack already exists
STACK_DIR="$REPO_ROOT/stacks/$ENV_NAME"
if [ -d "$STACK_DIR" ]; then
    echo "Error: Stack '$ENV_NAME' already exists at $STACK_DIR"
    exit 1
fi

echo "=== Creating new stack: $ENV_NAME ==="
echo ""
echo "Configuration:"
echo "  Project:        $PROJECT_NAME"
echo "  Environment:    $ENV_NAME"
echo "  Region:         $REGION"
echo "  Network CIDR:   $NETWORK_CIDR"
echo "  VM Size:        $VM_SIZE"
echo "  TFC Org:        $TFC_ORG"
echo "  TFC Workspace:  $TFC_WORKSPACE_PREFIX-$ENV_NAME"
echo ""

# Create stack directory
mkdir -p "$STACK_DIR"

# Generate files from templates
echo "Generating Terraform files..."

# main.tf
sed -e "s/{{ cookiecutter.env }}/$ENV_NAME/g" \
    -e "s/{{ cookiecutter.env | capitalize }}/${ENV_NAME^}/g" \
    "$TEMPLATE_DIR/{{cookiecutter.env}}/main.tf.j2" > "$STACK_DIR/main.tf"

# variables.tf
sed -e "s/{{ cookiecutter.env }}/$ENV_NAME/g" \
    -e "s/{{ cookiecutter.env | capitalize }}/${ENV_NAME^}/g" \
    -e "s/{{ cookiecutter.project_name }}/$PROJECT_NAME/g" \
    -e "s/{{ cookiecutter.region }}/$REGION/g" \
    -e "s|{{ cookiecutter.network_cidr }}|$NETWORK_CIDR|g" \
    -e "s/{{ cookiecutter.vm_size }}/$VM_SIZE/g" \
    "$TEMPLATE_DIR/{{cookiecutter.env}}/variables.tf.j2" > "$STACK_DIR/variables.tf"

# backend.tf
sed -e "s/{{ cookiecutter.env }}/$ENV_NAME/g" \
    -e "s/{{ cookiecutter.env | capitalize }}/${ENV_NAME^}/g" \
    -e "s/{{ cookiecutter.terraform_cloud_org }}/$TFC_ORG/g" \
    -e "s/{{ cookiecutter.terraform_cloud_workspace_prefix }}/$TFC_WORKSPACE_PREFIX/g" \
    "$TEMPLATE_DIR/{{cookiecutter.env}}/backend.tf.j2" > "$STACK_DIR/backend.tf"

# providers.tf
sed -e "s/{{ cookiecutter.env }}/$ENV_NAME/g" \
    -e "s/{{ cookiecutter.env | capitalize }}/${ENV_NAME^}/g" \
    "$TEMPLATE_DIR/{{cookiecutter.env}}/providers.tf.j2" > "$STACK_DIR/providers.tf"

# versions.tf
sed -e "s/{{ cookiecutter.env }}/$ENV_NAME/g" \
    -e "s/{{ cookiecutter.env | capitalize }}/${ENV_NAME^}/g" \
    "$TEMPLATE_DIR/{{cookiecutter.env}}/versions.tf.j2" > "$STACK_DIR/versions.tf"

echo ""
echo "=== Stack created successfully ==="
echo ""
echo "Next steps:"
echo "  1. Update $STACK_DIR/backend.tf with your Terraform Cloud organization"
echo "  2. Create workspace '$TFC_WORKSPACE_PREFIX-$ENV_NAME' in Terraform Cloud"
echo "  3. Set required variables in Terraform Cloud:"
echo "     - ssh_public_key"
echo "     - oncall_email (if using observability)"
echo "  4. Run: cd $STACK_DIR && terraform init"
echo ""
