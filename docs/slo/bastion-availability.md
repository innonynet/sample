# Bastion Availability SLO

## Service Level Indicator (SLI)

**Definition**: Percentage of successful Bastion connection attempts.

**Measurement**: Bastion connection success rate from Azure Monitor logs

**Formula**:
```
Availability = Successful Connections / Total Connection Attempts * 100
```

## Service Level Objective (SLO)

| Environment | Target | Error Budget (monthly) |
|-------------|--------|----------------------|
| Production  | 99.5%  | 216 minutes |
| Staging     | 99.0%  | 432 minutes |
| Development | 98.0%  | 864 minutes |

## Measurement Window

- **Primary**: Monthly rolling window
- **Alerting**: 15-minute evaluation windows

## Exclusions

The following are excluded from SLO calculations:

1. User authentication failures (AAD issues)
2. Invalid VM targets (user error)
3. Scheduled maintenance windows
4. Azure platform-wide outages

## Alert Thresholds

| Severity | Threshold | Action |
|----------|-----------|--------|
| Critical | Connection failures > 5 in 15 min | Page on-call |
| Warning  | Connection failures > 2 in 15 min | Email notification |

## Remediation

When SLO is at risk:

1. Check Azure Bastion service health
2. Verify Bastion Public IP is accessible
3. Check AzureBastionSubnet NSG rules
4. Verify target VM is running
5. Check VM NSG allows Bastion traffic (port 22/3389 from Bastion subnet)

## Dependencies

Bastion availability depends on:

- Azure Bastion service availability
- Public IP allocation
- VNet connectivity
- Target VM availability
- NSG configuration

## Reporting

Monthly SLO reports include:

- Connection success rate
- Number of failed connections
- Error budget consumed
- Top failure reasons
