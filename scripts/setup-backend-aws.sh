#!/bin/bash
# Setup AWS S3 Backend for Terraform State
# Usage: ./setup-backend-aws.sh [bucket-name] [region]

set -euo pipefail

# Configuration
BUCKET_NAME="${1:-your-org-terraform-state}"
REGION="${2:-ap-northeast-1}"
DYNAMODB_TABLE="terraform-locks"
KMS_ALIAS="alias/terraform-state"

echo "=== Setting up Terraform Backend ==="
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo ""

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS credentials not configured"
    exit 1
fi

echo "1. Creating S3 bucket..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "   Bucket already exists"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION"
    echo "   Bucket created"
fi

echo "2. Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

echo "3. Enabling encryption..."
# Create KMS key if it doesn't exist
KMS_KEY_ID=$(aws kms describe-key --key-id "$KMS_ALIAS" --query 'KeyMetadata.KeyId' --output text 2>/dev/null || echo "")

if [ -z "$KMS_KEY_ID" ]; then
    echo "   Creating KMS key..."
    KMS_KEY_ID=$(aws kms create-key \
        --description "Terraform state encryption key" \
        --query 'KeyMetadata.KeyId' \
        --output text)

    aws kms create-alias \
        --alias-name "$KMS_ALIAS" \
        --target-key-id "$KMS_KEY_ID"
fi

aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "aws:kms",
                "KMSMasterKeyID": "'"$KMS_ALIAS"'"
            },
            "BucketKeyEnabled": true
        }]
    }'

echo "4. Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'

echo "5. Creating DynamoDB table for locking..."
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" &>/dev/null; then
    echo "   Table already exists"
else
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$REGION"

    echo "   Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Add this to your backend.tf:"
echo ""
echo 'terraform {'
echo '  backend "s3" {'
echo "    bucket         = \"$BUCKET_NAME\""
echo '    key            = "<env>/terraform.tfstate"'
echo "    region         = \"$REGION\""
echo '    encrypt        = true'
echo "    dynamodb_table = \"$DYNAMODB_TABLE\""
echo '  }'
echo '}'
