# VM Availability SLO

## Service Level Indicator (SLI)

**Definition**: Percentage of time the VM is available and responding to health checks.

**Measurement**: Azure VM Availability Metric (`VmAvailabilityMetric`)

**Formula**:
```
Availability = (Total Minutes - Downtime Minutes) / Total Minutes * 100
```

## Service Level Objective (SLO)

| Environment | Target | Error Budget (monthly) |
|-------------|--------|----------------------|
| Production  | 99.9%  | 43.2 minutes |
| Staging     | 99.5%  | 216 minutes |
| Development | 99.0%  | 432 minutes |

## Measurement Window

- **Primary**: Monthly rolling window
- **Alerting**: 5-minute evaluation windows

## Exclusions

The following are excluded from SLO calculations:

1. Scheduled maintenance windows (announced 72+ hours in advance)
2. Azure platform-wide outages
3. Force majeure events

## Alert Thresholds

| Severity | Threshold | Action |
|----------|-----------|--------|
| Critical | < 99% (5 min window) | Page on-call |
| Warning  | < 99.5% (15 min window) | Email notification |

## Remediation

When SLO is at risk:

1. Check Azure Service Health
2. Review VM metrics (CPU, Memory, Disk)
3. Check NSG rules and network connectivity
4. Review recent deployments

## Reporting

Monthly SLO reports include:

- Total uptime percentage
- Number of incidents
- Error budget consumed
- Trend analysis
