#!/bin/bash
# Setup GCP Cloud Storage Backend for Terraform State
# Usage: ./setup-backend-gcp.sh [bucket-name] [project-id] [location]

set -euo pipefail

# Configuration
PROJECT_ID="${2:-$(gcloud config get-value project)}"
BUCKET_NAME="${1:-${PROJECT_ID}-terraform-state}"
LOCATION="${3:-asia-northeast1}"

echo "=== Setting up Terraform Backend (GCP) ==="
echo "Project: $PROJECT_ID"
echo "Bucket: $BUCKET_NAME"
echo "Location: $LOCATION"
echo ""

# Check gcloud CLI
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed"
    exit 1
fi

# Check gcloud auth
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 &> /dev/null; then
    echo "Error: Not authenticated. Run 'gcloud auth login' first."
    exit 1
fi

echo "1. Creating Cloud Storage bucket..."
if gsutil ls -b "gs://$BUCKET_NAME" &>/dev/null; then
    echo "   Bucket already exists"
else
    gsutil mb -p "$PROJECT_ID" -l "$LOCATION" -b on "gs://$BUCKET_NAME"
fi

echo "2. Enabling versioning..."
gsutil versioning set on "gs://$BUCKET_NAME"

echo "3. Setting uniform bucket-level access..."
gsutil uniformbucketlevelaccess set on "gs://$BUCKET_NAME"

echo "4. Setting lifecycle policy (optional)..."
cat > /tmp/lifecycle.json << 'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "numNewerVersions": 10,
          "isLive": false
        }
      }
    ]
  }
}
EOF

gsutil lifecycle set /tmp/lifecycle.json "gs://$BUCKET_NAME"
rm /tmp/lifecycle.json

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Add this to your backend.tf:"
echo ""
echo 'terraform {'
echo '  backend "gcs" {'
echo "    bucket = \"$BUCKET_NAME\""
echo '    prefix = "<env>"'
echo '  }'
echo '}'
