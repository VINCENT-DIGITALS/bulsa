# BULSA Owner Playtest Protocol

This protocol supplies the evidence required for Release Gate D. The product
owner chose owner-led validation in place of the former five-person external
test requirement. A complete re-test is required after each launch-blocking
usability fix.

## Build and setup

- Use the current Android debug or closed-test build.
- Ask each tester to play without instructions beyond: “Try to survive your
  next pay cycle.”
- Do not collect real financial details. Testers can use fictional names and
  amounts.

## Required tasks

1. Create an optional profile with one work tag.
2. Configure a 15th/month-end schedule and a weekend policy.
3. Start a run, identify the next payday and next fixed bill.
4. Make at least five event choices, including a savings action if available.
5. Reach a cycle outcome or debt-limit result.
6. Open the ledger and explain one change in cash.

## Questions to record

1. What does the next bill mean, and when will it affect cash?
2. What does the payday status mean?
3. Why did your cash change after your last choice?
4. Did any label, control, or screen make you stop or guess? Where?
5. Was survival possible through choices that felt understandable?

## Evidence record

Record only the findings needed to make the game clearer; do not store names
or private details.

| Test pass | Completed run | Explained cash/bill/payday | Blocker found | Follow-up issue |
| --- | --- | --- | --- | --- |
| Owner feedback — UI pass | Not yet re-tested | Not yet re-tested | Visual hierarchy, icon, action-row, and spacing consistency | Implement shared UI system and re-test complete journey |

Release Gate D remains open until the owner completes the post-fix journey and
any launch-blocking issue is fixed and retested.
