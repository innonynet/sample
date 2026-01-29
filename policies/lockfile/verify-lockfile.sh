#!/bin/bash
# Lockfile Verification Script
# Verifies .terraform.lock.hcl integrity across all stacks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Terraform Lockfile Verification ==="
echo ""

FAILED=0
CHECKED=0

# Find all stack directories
for stack_dir in "$REPO_ROOT"/stacks/*/; do
    stack_name=$(basename "$stack_dir")
    echo "Checking stack: $stack_name"

    cd "$stack_dir"

    # Check if lockfile exists
    if [ ! -f ".terraform.lock.hcl" ]; then
        echo "  WARNING: No lockfile found"
        echo ""
        continue
    fi

    CHECKED=$((CHECKED + 1))

    # Check lockfile has expected providers
    if ! grep -q "provider" .terraform.lock.hcl; then
        echo "  ERROR: Lockfile appears to be empty or invalid"
        FAILED=1
        continue
    fi

    # Verify provider hashes are present
    if ! grep -q "h1:" .terraform.lock.hcl; then
        echo "  WARNING: No h1 hashes found in lockfile"
        echo "  Consider running: terraform providers lock -platform=linux_amd64 -platform=darwin_amd64"
    fi

    # Check for zh (zip hash) which provides additional verification
    if grep -q "zh:" .terraform.lock.hcl; then
        echo "  Lockfile contains zh (zip) hashes"
    fi

    # Count providers
    provider_count=$(grep -c "provider \"" .terraform.lock.hcl || true)
    echo "  Providers locked: $provider_count"

    # Extract and display provider versions
    echo "  Provider versions:"
    while IFS= read -r line; do
        if [[ $line =~ provider.*\"(.*)\" ]]; then
            PROVIDER="${BASH_REMATCH[1]}"
        fi
        if [[ $line =~ version.*=.*\"(.*)\" ]]; then
            VERSION="${BASH_REMATCH[1]}"
            if [ -n "$PROVIDER" ] && [ -n "$VERSION" ]; then
                echo "    - $PROVIDER: $VERSION"
                PROVIDER=""
                VERSION=""
            fi
        fi
    done < .terraform.lock.hcl

    echo "  Lockfile OK"
    echo ""

    cd - > /dev/null
done

echo "=== Summary ==="
echo "Stacks checked: $CHECKED"

if [ $FAILED -gt 0 ]; then
    echo "Status: FAILED"
    exit 1
else
    echo "Status: PASSED"
    exit 0
fi
