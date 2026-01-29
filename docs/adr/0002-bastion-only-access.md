# ADR 0002: Azure Bastion for VM Management Access

## Status

Accepted

## Context

VMs need management access (SSH/RDP). Options considered:

1. **Public IP with NSG rules** - Simple but exposes attack surface
2. **VPN Gateway** - Secure but complex and costly
3. **Azure Bastion** - Managed jump host service

## Decision

Use Azure Bastion as the only method for VM management access:
- No public IPs on VMs
- SSH/RDP ports not exposed to internet
- All management via Azure Portal or `az network bastion ssh`

## Consequences

### Positive

- No direct internet exposure of management ports
- Managed service (no VM to maintain)
- Azure AD authentication integration
- Session logging available
- Native tunneling support (Standard SKU)

### Negative

- Cost (~$140/month for Standard SKU)
- Requires /27 or larger subnet
- Slightly more complex connection process
- Depends on Azure Bastion service availability

### Mitigations

- Use Serial Console as emergency backup
- Consider Basic SKU for non-critical environments
- Document connection procedures

## Implementation

1. Create AzureBastionSubnet (/27 minimum)
2. Deploy Standard SKU Bastion
3. Configure NSG for Bastion subnet
4. Document connection procedures
5. Block 22/3389 from Internet in VM NSG

## Security Requirements

### AzureBastionSubnet NSG Rules

Inbound:
- Allow 443 from Internet (for browser connections)
- Allow 443 from GatewayManager

Outbound:
- Allow 22, 3389 to VirtualNetwork
- Allow 443 to AzureCloud

### VM Subnet NSG Rules

Inbound:
- Allow 22 (Linux) or 3389 (Windows) from AzureBastionSubnet ONLY
- Deny 22, 3389 from Internet

## References

- [Azure Bastion Documentation](https://docs.microsoft.com/azure/bastion/)
- [Azure Bastion FAQ](https://docs.microsoft.com/azure/bastion/bastion-faq)
