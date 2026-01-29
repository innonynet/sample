# Escalation Matrix

## Overview

This document defines the escalation path for incidents.

## Escalation Levels

### Level 1: On-Call Engineer

**Responsibilities**:
- First response to all alerts
- Initial triage and assessment
- Follow runbooks for known issues
- Escalate if unable to resolve within SLA

**Contact**: On-call rotation (see schedule)

### Level 2: Senior Engineer / Team Lead

**Responsibilities**:
- Complex troubleshooting
- Architecture decisions
- Coordinate with other teams
- Approve emergency changes

**Escalate when**:
- Issue beyond L1 capability
- Requires code changes
- Multiple systems affected
- P1 not resolved in 30 minutes

**Contact**: [Define contact method]

### Level 3: Management / Vendor Support

**Responsibilities**:
- Business decisions
- External communication
- Vendor escalation
- Resource allocation

**Escalate when**:
- Extended outage (>1 hour for P1)
- Customer-facing impact
- Security incident
- Need vendor support

**Contact**: [Define contact method]

## Escalation Triggers

| Situation | Escalate To | Timeline |
|-----------|-------------|----------|
| P1 not resolved | L2 | 30 minutes |
| P1 extended outage | L3 | 1 hour |
| P2 not resolved | L2 | 2 hours |
| Security incident | L3 | Immediately |
| Data breach suspected | L3 + Security | Immediately |
| Customer complaint | L2 + L3 | 1 hour |

## Communication During Escalation

### Handoff Template

```
**Incident**: [ID/Name]
**Current Status**: [Status]
**Timeline**:
- [Time]: Alert triggered
- [Time]: Investigation started
- [Time]: [Actions taken]

**Findings**:
- [What you've discovered]

**Attempted Resolutions**:
- [What you've tried]

**Hypothesis**:
- [Your best guess at root cause]

**Recommended Next Steps**:
- [Suggestions]
```

## Vendor Escalation

### Azure Support

**When to escalate**:
- Azure service issues
- Platform-level problems
- Need Microsoft assistance

**How to escalate**:
1. Azure Portal > Help + Support
2. Create support request
3. Select appropriate severity
4. Provide diagnostic info

### Terraform Cloud Support

**When to escalate**:
- Terraform Cloud service issues
- State locking problems
- Plan/Apply failures

**How to escalate**:
1. support.hashicorp.com
2. Include workspace details
3. Attach relevant logs

## After Escalation

1. Stay available for questions
2. Continue monitoring
3. Update incident timeline
4. Support the escalation team
