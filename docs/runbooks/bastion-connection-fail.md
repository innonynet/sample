# Runbook: Bastion Connection Failed

## Alert Details

- **Alert Name**: Bastion Connection Failures
- **Priority**: P2
- **Response Time**: 1 hour

## Symptoms

- Unable to connect to VM via Bastion
- Bastion connection timeouts
- "Connection failed" errors in Azure Portal

## Diagnosis Steps

### 1. Check Azure Service Health

1. Azure Portal > Service Health
2. Check for Azure Bastion incidents
3. Check for networking incidents in your region

### 2. Verify Bastion Status

1. Azure Portal > Bastion Host
2. Check provisioning state (should be "Succeeded")
3. Verify SKU is "Standard"

### 3. Verify Network Configuration

```bash
# Check Bastion Public IP
az network public-ip show \
  --name pip-<project>-<env>-bastion \
  --resource-group rg-<project>-<env> \
  --query ipAddress -o tsv

# Check NSG rules on AzureBastionSubnet
az network nsg rule list \
  --nsg-name nsg-<project>-<env>-bastion \
  --resource-group rg-<project>-<env> \
  -o table
```

### 4. Verify Target VM

```bash
# Check VM status
az vm show \
  --name vm-<project>-<env> \
  --resource-group rg-<project>-<env> \
  --query powerState -o tsv

# Check VM NSG allows Bastion
az network nsg rule list \
  --nsg-name nsg-<project>-<env>-vm \
  --resource-group rg-<project>-<env> \
  -o table
```

## Resolution Steps

### Issue: Bastion Not Running

```bash
# Redeploy Bastion (via Terraform)
cd stacks/<env>
terraform apply -target=module.platform.azurerm_bastion_host.main
```

### Issue: NSG Blocking Traffic

Verify these rules exist:

**AzureBastionSubnet NSG (Inbound)**:
- Allow 443 from Internet
- Allow 443 from GatewayManager

**AzureBastionSubnet NSG (Outbound)**:
- Allow 22, 3389 to VirtualNetwork
- Allow 443 to AzureCloud

**VM Subnet NSG (Inbound)**:
- Allow 22 (Linux) or 3389 (Windows) from AzureBastionSubnet

### Issue: VM Not Responding

```bash
# Restart VM
az vm restart \
  --name vm-<project>-<env> \
  --resource-group rg-<project>-<env>

# If restart fails, deallocate and start
az vm deallocate --name vm-<project>-<env> --resource-group rg-<project>-<env>
az vm start --name vm-<project>-<env> --resource-group rg-<project>-<env>
```

### Issue: SSH Key Problems (Linux)

1. Use Azure Portal > VM > Reset Password
2. Or use Run Command to add new SSH key

## Verification

1. Connect via Azure Portal > VM > Connect > Bastion
2. Verify SSH session opens
3. Run basic commands to confirm connectivity

## Alternative Access

If Bastion is down and urgent access needed:

1. **Serial Console**: Azure Portal > VM > Serial Console
2. **Run Command**: Azure Portal > VM > Run Command

## Post-Incident

- [ ] Update incident ticket
- [ ] Document root cause
- [ ] Review NSG rules
- [ ] Consider redundant Bastion setup for critical environments
