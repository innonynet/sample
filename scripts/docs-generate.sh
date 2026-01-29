#!/bin/bash
# Generate documentation for Terraform modules using terraform-docs
# Usage: ./scripts/docs-generate.sh [module_path]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo "terraform-docs is not installed."
    echo ""
    echo "Install options:"
    echo "  macOS: brew install terraform-docs"
    echo "  Linux: https://terraform-docs.io/user-guide/installation/"
    echo ""
    exit 1
fi

# Generate documentation for a single module
generate_docs() {
    local module_path="$1"
    local readme_path="$module_path/README.md"

    echo "Generating docs for: $module_path"

    # Generate README.md
    terraform-docs markdown table \
        --output-file README.md \
        --output-mode inject \
        --show all \
        "$module_path" 2>/dev/null || \
    terraform-docs markdown table "$module_path" > "$readme_path"

    echo "  Created: $readme_path"
}

# Main logic
if [ $# -gt 0 ]; then
    # Generate for specific module
    MODULE_PATH="$1"
    if [ ! -d "$MODULE_PATH" ]; then
        echo "Error: Directory not found: $MODULE_PATH"
        exit 1
    fi
    generate_docs "$MODULE_PATH"
else
    # Generate for all modules
    echo "=== Generating documentation for all modules ==="
    echo ""

    # Cloud modules
    for module_dir in "$REPO_ROOT"/cloud/azure/*/; do
        if [ -d "$module_dir" ]; then
            generate_docs "$module_dir"
        fi
    done

    # Stacks
    for stack_dir in "$REPO_ROOT"/stacks/*/; do
        if [ -d "$stack_dir" ]; then
            generate_docs "$stack_dir"
        fi
    done

    echo ""
    echo "=== Documentation generation complete ==="
fi
