# Runbook: VM Disk Full

## Alert Details

- **Alert Name**: VM Disk Critical/Warning
- **Priority**: P1 (Critical), P2 (Warning)
- **Response Time**: 15 minutes (Critical), 1 hour (Warning)

## Symptoms

- Disk usage exceeds threshold (Warning: 85%, Critical: 95%)
- Applications failing to write
- Logs not being written
- Database errors

## Diagnosis Steps

### 1. Connect to VM

```bash
az network bastion ssh \
  --name bas-<project>-<env> \
  --resource-group rg-<project>-<env> \
  --target-resource-id <vm-id> \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/id_rsa
```

### 2. Check Disk Usage

```bash
# Overall disk usage
df -h

# Check specific mount points
df -h /
df -h /var
df -h /home

# Find large directories
sudo du -sh /* 2>/dev/null | sort -hr | head -10

# Find large files
sudo find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
```

### 3. Check Common Culprits

```bash
# Log files
sudo du -sh /var/log/*

# Temporary files
sudo du -sh /tmp/*

# Package cache
sudo du -sh /var/cache/apt/archives/

# Old kernels
dpkg --list | grep linux-image
```

## Resolution Steps

### Option 1: Clear Logs

```bash
# Clear old journal logs (keep last 7 days)
sudo journalctl --vacuum-time=7d

# Truncate large log files (keeps file, clears content)
sudo truncate -s 0 /var/log/syslog

# Remove old rotated logs
sudo rm -f /var/log/*.gz
```

### Option 2: Clear Package Cache

```bash
# Clean apt cache
sudo apt-get clean
sudo apt-get autoremove
```

### Option 3: Remove Old Files

```bash
# Find and remove files older than 30 days in /tmp
sudo find /tmp -type f -mtime +30 -delete

# Remove old cores
sudo rm -f /var/crash/*
```

### Option 4: Expand Disk (requires planning)

1. Resize disk in Azure Portal or Terraform
2. Apply Terraform changes
3. Extend partition:

```bash
# Extend partition (example for /dev/sda1)
sudo growpart /dev/sda 1
sudo resize2fs /dev/sda1
```

## Verification

1. Confirm disk usage below 80%
```bash
df -h
```
2. Test application write operations
3. Verify logs are being written

## Prevention

- Set up log rotation
- Configure alerts at 70% threshold
- Regular capacity planning reviews
- Consider separate data disks for applications

## Post-Incident

- [ ] Update incident ticket
- [ ] Document what consumed space
- [ ] Review log retention policy
- [ ] Schedule disk expansion if needed
