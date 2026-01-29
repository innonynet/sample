# Post-Mortem Template

## Incident Summary

| Field | Value |
|-------|-------|
| **Incident ID** | INC-XXXX |
| **Date** | YYYY-MM-DD |
| **Duration** | X hours Y minutes |
| **Severity** | P1/P2/P3/P4 |
| **Services Affected** | |
| **Customer Impact** | |
| **On-Call** | |

## Executive Summary

[2-3 sentence summary of what happened, impact, and resolution]

## Timeline

All times in JST (UTC+9)

| Time | Event |
|------|-------|
| HH:MM | Alert triggered |
| HH:MM | On-call acknowledged |
| HH:MM | Investigation started |
| HH:MM | Root cause identified |
| HH:MM | Mitigation applied |
| HH:MM | Service restored |
| HH:MM | Incident resolved |

## Root Cause Analysis

### What happened?

[Detailed technical description of what went wrong]

### Why did it happen?

[Use 5 Whys or similar technique]

1. Why? [First level cause]
2. Why? [Second level cause]
3. Why? [Third level cause]
4. Why? [Fourth level cause]
5. Why? [Root cause]

### Contributing Factors

- [ ] Configuration change
- [ ] Code deployment
- [ ] Infrastructure change
- [ ] Capacity/scaling issue
- [ ] External dependency
- [ ] Human error
- [ ] Monitoring gap
- [ ] Other: ___

## Impact Assessment

### User Impact

- Number of users affected:
- Duration of impact:
- User experience:

### Business Impact

- SLO impact:
- Error budget consumed:
- Financial impact (if applicable):

## Detection

- **How was it detected?** [Alert / User report / Monitoring]
- **Detection time**: X minutes after incident start
- **Was detection adequate?** [Yes / No - explain]

## Response

- **Time to acknowledge**: X minutes
- **Time to mitigate**: X minutes
- **Time to resolve**: X minutes
- **Was response adequate?** [Yes / No - explain]

## What Went Well

1.
2.
3.

## What Could Be Improved

1.
2.
3.

## Action Items

| # | Action | Owner | Due Date | Status |
|---|--------|-------|----------|--------|
| 1 | [Action description] | [Name] | YYYY-MM-DD | Open |
| 2 | | | | |
| 3 | | | | |

### Prevention Actions

Actions to prevent this from happening again:

### Detection Actions

Actions to detect this faster:

### Response Actions

Actions to respond better:

## Lessons Learned

[Key takeaways for the team]

## References

- Related incidents:
- Relevant documentation:
- Monitoring dashboards:

---

**Post-mortem completed by**: [Name]
**Date completed**: YYYY-MM-DD
**Reviewed by**: [Names]
