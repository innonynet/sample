# Runbook: VM High CPU

## Alert Details

- **Alert Name**: VM CPU Critical/Warning
- **Priority**: P2
- **Response Time**: 1 hour

## Symptoms

- VM CPU utilization exceeds threshold (Warning: 80%, Critical: 95%)
- Application slowness reported
- SSH connections timing out

## Diagnosis Steps

### 1. Verify Alert

```bash
# Connect via Bastion
az network bastion ssh \
  --name bas-<project>-<env> \
  --resource-group rg-<project>-<env> \
  --target-resource-id <vm-id> \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/id_rsa
```

### 2. Check System Load

```bash
# On the VM
top -bn1 | head -20

# Check load average
uptime

# List processes by CPU
ps aux --sort=-%cpu | head -10
```

### 3. Check Azure Metrics

1. Azure Portal > VM > Metrics
2. Add metric: Percentage CPU
3. Check time range matching alert

### 4. Review Recent Changes

- Check recent deployments
- Review cron jobs/scheduled tasks
- Check for backup processes

## Resolution Steps

### Option 1: Identify and Stop Runaway Process

```bash
# Kill process by PID
sudo kill -9 <pid>

# Kill process by name
sudo pkill -f <process-name>
```

### Option 2: Scale Up VM

1. Stop VM (if acceptable downtime)
2. Change VM size in Terraform
3. Apply changes via Terraform Cloud
4. Start VM

### Option 3: Add CPU Limits (if containerized)

Update container resource limits in application configuration.

## Verification

1. Confirm CPU has returned to normal levels
2. Test application functionality
3. Monitor for 15 minutes

## Post-Incident

- [ ] Update incident ticket
- [ ] Document root cause
- [ ] Consider alerting threshold adjustment
- [ ] Schedule capacity review if recurring
