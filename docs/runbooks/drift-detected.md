# Runbook: Infrastructure Drift Detected

## Alert Details

- **Alert Name**: Infrastructure Drift Detected
- **Priority**: P3
- **Response Time**: 4 hours

## Symptoms

- GitHub Issue created by drift detection workflow
- Terraform plan shows changes not in code
- Resources modified outside of Terraform

## Diagnosis Steps

### 1. Review Drift Detection Report

1. Open the GitHub Issue created by drift detection
2. Review the workflow run logs
3. Identify which resources have drifted

### 2. Identify Change Source

```bash
# Check Azure Activity Log for the resource
az monitor activity-log list \
  --resource-group rg-<project>-<env> \
  --start-time $(date -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ) \
  --query "[?authorization.action != 'Microsoft.Resources/deployments/read'].{Time:eventTimestamp, User:caller, Action:authorization.action, Resource:resourceId}" \
  -o table
```

### 3. Compare with Terraform State

```bash
cd stacks/<env>
terraform init
terraform plan -no-color > drift_report.txt
```

## Classification

### Intentional Changes

Changes made knowingly but not updated in Terraform:
- Emergency fixes
- Troubleshooting modifications
- Manual scaling

**Action**: Update Terraform code to match

### Unintentional Changes

Changes made without proper process:
- Accidental portal modifications
- Unauthorized changes
- Azure auto-remediation

**Action**: Revert to Terraform state

### Expected Drift

Azure-managed values that naturally drift:
- Timestamps
- Auto-generated names
- Azure policy effects

**Action**: Add to ignore list or accept

## Resolution Steps

### Option 1: Update Terraform to Match Actual State

1. Update Terraform code to reflect desired state
2. Create PR with changes
3. Review and merge
4. Verify plan shows no changes

```bash
# Example: Update VM size in variables
vim stacks/<env>/variables.tf
git add .
git commit -m "Update VM size to match actual state"
git push
```

### Option 2: Revert to Terraform State

```bash
cd stacks/<env>
terraform apply
```

### Option 3: Import Unmanaged Resources

If new resources were created manually:

```bash
terraform import <resource_type>.<name> <azure_resource_id>
```

## Prevention

1. **Enforce IaC-only changes**: Use Azure Policy to deny manual changes
2. **RBAC**: Limit who can modify production resources
3. **Change management**: Require tickets for all changes
4. **More frequent drift checks**: Run on every commit

## Verification

1. Run Terraform plan - should show no changes
2. Close the drift detection GitHub Issue
3. Verify workflow passes on next scheduled run

## Post-Incident

- [ ] Close GitHub Issue with resolution notes
- [ ] Document what caused the drift
- [ ] Update process if manual change was required
- [ ] Review access controls if unauthorized
