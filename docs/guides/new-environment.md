# Creating a New Environment

This guide walks through creating a new environment (stack) from scratch.

## Prerequisites

- Access to Terraform Cloud organization
- Azure Service Principal credentials
- SSH public key for VM access

## Steps

### 1. Generate Stack Files

Use the provided script to generate a new stack:

```bash
./scripts/new-stack.sh <env_name> [options]
```

**Example:**

```bash
# Create a test environment
./scripts/new-stack.sh test

# Create with custom options
./scripts/new-stack.sh sandbox \
  --project myproject \
  --region westus2 \
  --network-cidr "10.1.0.0/16" \
  --org my-tfc-org
```

### 2. Create Terraform Cloud Workspace

1. Log in to [Terraform Cloud](https://app.terraform.io)
2. Navigate to your organization
3. Create a new workspace:
   - Name: `infra-<env_name>`
   - Execution mode: Remote
   - VCS connection: Connect to your repository
   - Working directory: `stacks/<env_name>`

### 3. Configure Workspace Variables

**Environment Variables** (mark as sensitive where indicated):

| Variable | Value | Sensitive |
|----------|-------|-----------|
| ARM_CLIENT_ID | Service Principal Client ID | No |
| ARM_CLIENT_SECRET | Service Principal Secret | Yes |
| ARM_SUBSCRIPTION_ID | Azure Subscription ID | No |
| ARM_TENANT_ID | Azure Tenant ID | No |

**Terraform Variables**:

| Variable | Value | Required |
|----------|-------|----------|
| project | Project name | Yes |
| ssh_public_key | SSH public key content | Yes |
| oncall_email | Alert notification email | If using observability |

### 4. Update backend.tf

Edit `stacks/<env_name>/backend.tf` with your organization name:

```hcl
terraform {
  cloud {
    organization = "your-org-name"

    workspaces {
      name = "infra-<env_name>"
    }
  }
}
```

### 5. Initialize and Apply

**Option A: Via VCS (recommended)**

1. Commit and push your changes
2. Create a Pull Request
3. Review the Terraform plan
4. Merge to trigger apply

**Option B: Manual**

```bash
cd stacks/<env_name>
terraform init
terraform plan
terraform apply
```

### 6. Verify Deployment

1. Check Terraform Cloud run completed successfully
2. Verify resources in Azure Portal:
   - Resource Group created
   - VNet and subnets created
   - VM running
   - Bastion accessible

### 7. Test Connectivity

Connect to the VM via Bastion:

```bash
az network bastion ssh \
  --name bas-<project>-<env> \
  --resource-group rg-<project>-<env> \
  --target-resource-id $(az vm show -g rg-<project>-<env> -n vm-<project>-<env> --query id -o tsv) \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/id_rsa
```

## Troubleshooting

### Terraform Cloud workspace not found

Ensure the workspace name in `backend.tf` matches exactly the workspace created in Terraform Cloud.

### Authentication errors

Verify all ARM_* environment variables are set correctly in the workspace.

### SSH connection fails

1. Verify SSH public key format (should start with `ssh-rsa`)
2. Check NSG rules allow Bastion traffic
3. Verify VM is in running state

## Cleanup

To destroy an environment:

1. Run `terraform destroy` in Terraform Cloud
2. Or: `terraform destroy` locally
3. Delete the workspace in Terraform Cloud
4. Remove the stack directory: `rm -rf stacks/<env_name>`
