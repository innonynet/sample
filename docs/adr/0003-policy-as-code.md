# ADR 0003: Policy as Code with OPA/Conftest and Azure Policy

## Status

Accepted

## Context

We need to enforce security and compliance policies on infrastructure:
- Prevent non-compliant resources from being deployed
- Ensure consistent tagging
- Restrict allowed VM SKUs
- Enforce encryption standards

Options considered:

1. **Manual review only** - Error-prone, doesn't scale
2. **Terraform Sentinel** - Requires Terraform Cloud Plus ($$$)
3. **OPA/Conftest** - Open source, flexible, CI-integrated
4. **Azure Policy** - Native Azure, runtime enforcement

## Decision

Use a layered approach:

1. **OPA/Conftest in CI** - Pre-deployment policy checks on Terraform plans
2. **Azure Policy** - Runtime enforcement and compliance reporting

## Consequences

### Positive

- Shift-left security (catch issues before deployment)
- Open source tooling (no additional licensing)
- Runtime protection via Azure Policy
- Compliance dashboard in Azure Portal
- Audit trail for policy violations

### Negative

- Two systems to maintain (OPA policies + Azure Policy)
- Learning curve for Rego language
- Policy synchronization overhead

### Mitigations

- Start with audit mode, gradually move to deny
- Keep policies DRY between OPA and Azure Policy
- Document policy rationale

## Implementation

### OPA/Conftest Policies

Located in `policies/opa/terraform/`:
- `public_ip.rego` - Restrict public IPs
- `mandatory_tags.rego` - Enforce required tags
- `vm_sku.rego` - Restrict VM sizes
- `storage_encryption.rego` - Enforce storage security

### Azure Policy Definitions

Located in `policies/azure/definitions/`:
- `deny-public-ip.json`
- `require-tags.json`
- `allowed-vm-skus.json`
- `require-storage-encryption.json`

### Deployment

1. CI runs `conftest test` on `terraform plan` output
2. Azure Policy definitions deployed via `governance` module
3. Policies assigned at resource group level
4. Start with `Audit` effect, move to `Deny` after validation

## Policy Enforcement Levels

| Policy | OPA (CI) | Azure Policy | Effect |
|--------|----------|--------------|--------|
| Public IP restriction | Yes | Yes | Deny |
| Required tags | Yes | Yes | Audit → Deny |
| VM SKU restriction | Yes | Yes | Audit |
| Storage encryption | Yes | Yes | Deny |

## References

- [OPA Documentation](https://www.openpolicyagent.org/docs/)
- [Conftest](https://www.conftest.dev/)
- [Azure Policy](https://docs.microsoft.com/azure/governance/policy/)
