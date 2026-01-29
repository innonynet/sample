# Operational Runbooks

This directory contains operational runbooks for common scenarios.

## Quick Reference

| Alert | Runbook | Priority |
|-------|---------|----------|
| VM CPU High | [vm-high-cpu.md](vm-high-cpu.md) | P2 |
| VM Disk Full | [vm-disk-full.md](vm-disk-full.md) | P1 |
| Bastion Connection Failed | [bastion-connection-fail.md](bastion-connection-fail.md) | P2 |
| Infrastructure Drift | [drift-detected.md](drift-detected.md) | P3 |

## Priority Levels

| Priority | Response Time | Description |
|----------|--------------|-------------|
| P1 | 15 minutes | Service down, data at risk |
| P2 | 1 hour | Service degraded |
| P3 | 4 hours | Potential issue, no immediate impact |
| P4 | 1 business day | Low priority, scheduled work |

## General Troubleshooting Steps

1. **Check Azure Service Health**
   - [Azure Status](https://status.azure.com/)
   - Azure Portal > Service Health

2. **Review Recent Changes**
   - Check Terraform Cloud runs
   - Review GitHub commits/PRs
   - Check Azure Activity Log

3. **Gather Diagnostics**
   - Azure Monitor metrics
   - Log Analytics queries
   - VM boot diagnostics

4. **Escalation Path**
   - See [Escalation Matrix](../incident-response/escalation-matrix.md)
