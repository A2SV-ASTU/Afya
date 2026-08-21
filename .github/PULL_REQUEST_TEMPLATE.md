## What does this PR do?

## Which track(s) and PRD section(s) does this touch?

## How to test

## Checklist
- [ ] CI passes (lint, type check, tests)
- [ ] One job, one track — not combining web/mobile/backend unless it's the shared API contract
- [ ] If this touches `/checkins`, `/tags`, or crisis routing — a second person reviewed the routing logic specifically (PRD 7.5)
- [ ] If this touches signal-sharing or discussion endpoints — checked against PRD 7.4.2's never-shareable list
- [ ] If this touches crisis-pathway or resource-directory content — the "prototype, not clinically reviewed" disclaimer is still visible
- [ ] No secrets, `.env`, or keys in this diff