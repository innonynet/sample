# Service Level Objectives (SLOs)

This directory contains SLO definitions for the Azure VM + Bastion infrastructure.

## Overview

| Service | SLI | SLO Target | Measurement Window |
|---------|-----|------------|-------------------|
| VM Availability | Uptime percentage | 99.9% | Monthly |
| Bastion Availability | Connection success rate | 99.5% | Monthly |

## SLO Documents

- [VM Availability SLO](vm-availability.md)
- [Bastion Availability SLO](bastion-availability.md)

## Error Budget Policy

When an SLO is breached or error budget is exhausted:

1. **< 50% Error Budget Remaining**: Review and prioritize reliability work
2. **< 25% Error Budget Remaining**: Freeze feature deployments, focus on stability
3. **0% Error Budget**: Full incident response, post-mortem required

## Measurement

SLOs are measured using Azure Monitor metrics and Log Analytics queries.
Monthly reports are generated on the first business day of each month.
