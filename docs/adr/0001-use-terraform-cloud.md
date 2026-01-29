# ADR 0001: Use Terraform Cloud for State Management and CI/CD

## Status

Accepted

## Context

We need to manage Terraform state securely and implement CI/CD for infrastructure changes. Options considered:

1. **Local state** - Simple but not team-friendly
2. **Azure Storage backend** - Requires separate setup, manual locking
3. **Terraform Cloud** - Managed state, built-in CI/CD, remote execution

## Decision

Use Terraform Cloud for:
- Remote state management
- Plan/Apply execution
- Team collaboration
- VCS integration

## Consequences

### Positive

- Centralized, versioned state
- Automatic state locking
- Built-in plan/apply workflow
- Team access control
- Audit history
- Free tier available

### Negative

- Dependency on external service
- Requires internet connectivity
- Learning curve for team
- API token management

### Mitigations

- Use VCS-driven workflow for redundancy
- Document local init process for emergencies
- Store API tokens securely in GitHub Secrets

## Implementation

1. Create Terraform Cloud organization
2. Create workspace per environment
3. Set Working Directory to `stacks/<env>`
4. Configure VCS connection
5. Set environment variables (ARM_*)

## References

- [Terraform Cloud Documentation](https://developer.hashicorp.com/terraform/cloud-docs)
