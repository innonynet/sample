# On-Call Guide

## Overview

This guide provides essential information for on-call engineers responding to alerts.

## Before Your Shift

1. Verify access to:
   - Azure Portal
   - Terraform Cloud
   - GitHub repository
   - Email/notification channels

2. Review recent changes:
   - Check Terraform Cloud recent runs
   - Review merged PRs from last week
   - Check any open incidents

3. Ensure you have:
   - SSH keys configured
   - Azure CLI authenticated
   - VPN access (if required)

## During Your Shift

### Responding to Alerts

1. **Acknowledge** the alert within 5 minutes
2. **Assess** severity and impact
3. **Communicate** in incident channel
4. **Investigate** using runbooks
5. **Resolve** or **Escalate**
6. **Document** actions taken

### Severity Assessment

| Severity | Criteria | Response |
|----------|----------|----------|
| P1 | Service down, data at risk | Immediate response, consider escalation |
| P2 | Service degraded | Respond within 1 hour |
| P3 | Potential issue | Respond within 4 hours |
| P4 | Low priority | Next business day |

### Communication Template

```
**Alert**: [Alert Name]
**Severity**: P[1-4]
**Status**: Investigating / Mitigating / Resolved
**Impact**: [Description of user impact]
**Actions**: [What you're doing]
**ETA**: [If known]
```

## Key Resources

### Quick Links

- [Azure Portal](https://portal.azure.com)
- [Terraform Cloud](https://app.terraform.io)
- [Azure Service Health](https://status.azure.com)
- [GitHub Actions](https://github.com/<org>/<repo>/actions)

### Key Commands

```bash
# Azure login
az login

# Check VM status
az vm list -g rg-<project>-<env> -o table

# Connect via Bastion
az network bastion ssh \
  --name bas-<project>-<env> \
  --resource-group rg-<project>-<env> \
  --target-resource-id <vm-id> \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/id_rsa

# View activity log
az monitor activity-log list \
  --resource-group rg-<project>-<env> \
  --start-time $(date -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  -o table
```

## Escalation

If you need to escalate:

1. Follow [Escalation Matrix](escalation-matrix.md)
2. Page the next level with context
3. Join the incident bridge
4. Hand off cleanly with status update

## End of Shift

1. Document any ongoing issues
2. Update incident tickets
3. Brief incoming on-call
4. Ensure monitoring is working
