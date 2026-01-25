# Makefile for Infrastructure Template
# Usage: make <target> [ENV=dev|stg|prd]

ENV ?= dev
STACK_DIR = stacks/$(ENV)

.PHONY: help init plan apply destroy fmt validate lint security-scan clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform (ENV=dev|stg|prd)
	@echo "Initializing $(ENV)..."
	cd $(STACK_DIR) && terraform init

plan: ## Run Terraform plan (ENV=dev|stg|prd)
	@echo "Planning $(ENV)..."
	cd $(STACK_DIR) && terraform plan

apply: ## Run Terraform apply (ENV=dev|stg|prd)
	@echo "Applying $(ENV)..."
	cd $(STACK_DIR) && terraform apply

destroy: ## Run Terraform destroy (ENV=dev|stg|prd) - USE WITH CAUTION
	@echo "WARNING: This will destroy $(ENV) environment!"
	@read -p "Type 'destroy-$(ENV)' to confirm: " confirm && [ "$$confirm" = "destroy-$(ENV)" ]
	cd $(STACK_DIR) && terraform destroy

fmt: ## Format all Terraform files
	terraform fmt -recursive

validate: ## Validate all stacks
	./scripts/validate-all.sh

lint: ## Run TFLint
	tflint --recursive

security-scan: ## Run security scans (tfsec + trivy)
	@echo "Running tfsec..."
	tfsec .
	@echo ""
	@echo "Running Trivy..."
	trivy config .

clean: ## Clean up temporary files
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.tfplan" -delete 2>/dev/null || true
	find . -type f -name "plan.txt" -delete 2>/dev/null || true

# Setup targets
setup-backend-aws: ## Setup AWS S3 backend
	./scripts/setup-backend-aws.sh

setup-backend-azure: ## Setup Azure Storage backend
	./scripts/setup-backend-azure.sh

setup-backend-gcp: ## Setup GCP Cloud Storage backend
	./scripts/setup-backend-gcp.sh

# Pre-commit
pre-commit-install: ## Install pre-commit hooks
	pre-commit install

pre-commit-run: ## Run pre-commit on all files
	pre-commit run --all-files

# Shortcuts
dev: ENV=dev
dev: plan

stg: ENV=stg
stg: plan

prd: ENV=prd
prd: plan
