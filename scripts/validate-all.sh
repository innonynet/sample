#!/bin/bash
# Validate all Terraform stacks
# Usage: ./validate-all.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Validating All Stacks ==="
echo ""

FAILED=0

for env in dev stg prd; do
    STACK_DIR="$ROOT_DIR/stacks/$env"

    if [ -d "$STACK_DIR" ]; then
        echo "--- Validating $env ---"
        cd "$STACK_DIR"

        echo "  Formatting..."
        if ! terraform fmt -check -recursive; then
            echo "  ❌ Format check failed"
            FAILED=1
        fi

        echo "  Initializing..."
        if ! terraform init -backend=false -input=false > /dev/null 2>&1; then
            echo "  ❌ Init failed"
            FAILED=1
            continue
        fi

        echo "  Validating..."
        if terraform validate; then
            echo "  ✅ $env validation passed"
        else
            echo "  ❌ $env validation failed"
            FAILED=1
        fi

        echo ""
    fi
done

echo ""
if [ $FAILED -eq 0 ]; then
    echo "=== All validations passed ✅ ==="
    exit 0
else
    echo "=== Some validations failed ❌ ==="
    exit 1
fi
