# Security Checklist

Use this checklist when reviewing Terraform changes or deploying new infrastructure.

## Network Security

- [ ] **No public IPs on VMs** - VMs should only have private IPs
- [ ] **Bastion for management access** - No direct SSH/RDP from internet
- [ ] **NSG rules reviewed** - Principle of least privilege applied
- [ ] **Outbound traffic controlled** - NAT Gateway or Azure Firewall used
- [ ] **Service endpoints configured** - For PaaS services where applicable

## Identity & Access

- [ ] **Managed identities used** - Avoid storing credentials in code
- [ ] **RBAC configured** - Least privilege access
- [ ] **No hardcoded secrets** - Use Key Vault or TFC variables
- [ ] **Service Principal scoped** - Not subscription-wide if possible

## Data Protection

- [ ] **Encryption at rest** - Azure default or CMK
- [ ] **Encryption in transit** - TLS 1.2 minimum
- [ ] **Key Vault for secrets** - Never in code or state
- [ ] **Backup configured** - For critical data

## Storage Security

- [ ] **HTTPS only** - `https_traffic_only_enabled = true`
- [ ] **TLS 1.2 minimum** - `min_tls_version = "TLS1_2"`
- [ ] **No public blob access** - `allow_nested_items_to_be_public = false`
- [ ] **Network rules configured** - Restrict to VNet where possible

## Compute Security

- [ ] **SSH key authentication** - No password auth for Linux
- [ ] **Latest OS images** - Use supported versions
- [ ] **Disk encryption** - Azure disk encryption enabled
- [ ] **Auto-update configured** - Or documented patching strategy

## Monitoring & Logging

- [ ] **Diagnostic logs enabled** - For security events
- [ ] **Log Analytics configured** - Centralized logging
- [ ] **Alerts configured** - For security-relevant events
- [ ] **Activity log retention** - Meet compliance requirements

## Compliance

- [ ] **Required tags present** - Environment, Project, ManagedBy
- [ ] **Policy check passed** - OPA/Conftest policies
- [ ] **Trivy scan passed** - No HIGH/CRITICAL findings
- [ ] **TFLint passed** - No errors

## Terraform Security

- [ ] **Lockfile committed** - `.terraform.lock.hcl` present
- [ ] **State in Terraform Cloud** - Not local
- [ ] **Sensitive variables marked** - In TFC
- [ ] **No sensitive outputs** - Or marked sensitive

## Pre-Deployment Checklist

Before applying to production:

1. [ ] PR reviewed by at least one team member
2. [ ] Security scan workflow passed
3. [ ] Policy check workflow passed
4. [ ] Plan reviewed (no unexpected destroys)
5. [ ] Change documented (ticket/PR description)
6. [ ] Rollback plan documented
7. [ ] Monitoring in place

## Post-Deployment Checklist

After applying changes:

1. [ ] Verify resources created correctly
2. [ ] Test connectivity
3. [ ] Check for security warnings in Portal
4. [ ] Verify monitoring/alerts working
5. [ ] Update documentation if needed

## Common Issues

### Policy Violations

If policy check fails:

1. Review the specific violation message
2. Check if it's a legitimate exception
3. If exception needed, document in PR
4. Otherwise, fix the violation

### Security Scan Findings

If Trivy finds issues:

1. Check if finding is valid for your use case
2. Add to `.trivyignore` with justification if false positive
3. Fix the issue if valid
4. Re-run scan to verify

### Access Issues

If connectivity fails:

1. Check NSG rules
2. Verify subnet associations
3. Check Bastion configuration
4. Review Azure Firewall rules (if applicable)
