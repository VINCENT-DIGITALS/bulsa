# BULSA Release Readiness

## Primary delivery goal: BULSA v1.0 Free Release

Deliver a polished, offline-first Android game to Google Play where a new player can create a local profile, configure a real calendar/pay cycle, play through a complete pay cycle, make meaningful financial choices, review the ledger/result, and safely resume later—without an account, payment, or internet connection.

**v1.0 is publish-ready only when every release gate below is checked.** Completing a feature list alone is not enough.

## Scope boundary

### Required for v1.0 launch

- Consistent mobile UI using the approved design system.
- Drift/SQLite persistence for all local player data and settings.
- Optional local profile and configurable pay schedule.
- Calendar that correctly handles 28–31-day months, leap years, and the selected weekend-payday policy.
- Complete playable pay cycle: payday, bills, daily choices/events, ledger, savings, result, and restart.
- At least 10 balanced event cards and a clear outcome/end screen.
- Basic local help/FAQ and a visible privacy/contact route.
- Android release build that meets Google Play target API requirements.

### Explicitly not required for v1.0 launch

- Firebase Authentication, Cloud Firestore sync, FCM, or account deletion.
- Supporter subscription, billing, or priority-support ticket queue.
- iOS release, multiplayer, real payments, real cards, QR payments, or bank integration.

These are a **v1.1 Supporter release**, not a reason to delay the free game. Firebase Core may remain configured, but no online service may be advertised until its own release gate passes.

## v1.0 release gates

### Gate A — Complete player journey

- [x] A first-time player can understand the purpose and start a run without guidance from the developer. A local three-step onboarding screen explains the cycle, choices, and ledger, then directs the player to Calendar setup; clean-install Android visual QA passed.
- [ ] The player can create/edit a local profile and pay schedule.
- [ ] The game shows current date, cash, savings, next bill, next payday, and payday status.
- [ ] Each choice creates exactly one understandable financial/ledger outcome.
- [ ] The run can be closed/reopened without losing progress.
- [ ] The player can finish a complete cycle and see an understandable result plus restart option.

### Gate B — Correctness and persistence

- [ ] Automated unit tests cover money updates, bills, savings withdrawals, scoring, and ledger entries.
- [ ] Automated calendar tests cover February in leap/non-leap years, month-end, 15th/month-end cutoffs, and weekend advance/delay/keep rules.
- [ ] Automated Drift migration/persistence tests cover save, restart, and existing-data upgrades.
- [ ] Seeded event tests prove that the same seed produces the same event sequence.
- [ ] No known issue can create or lose in-game money without a ledger entry.

### Gate C — Design, accessibility, and quality

- [ ] Every screen uses only the approved colors, spacing, and radius tokens.
- [ ] Buttons and interactive items meet the 48 × 48 logical-pixel minimum target.
- [ ] Important status is communicated with text/icon, not color alone.
- [ ] Text is readable at Android font scale 1.3 without clipped essential content.
- [ ] The app works in portrait on a small Android phone and a larger Android phone.
- [ ] Reduced motion does not hide any outcome or prevent gameplay.
- [ ] No open blocker/critical bug; no known crash in the core player journey.

### Gate D — Product validation

- [x] Product-owner UI feedback was triaged into the shared header, card, spacing, and action system. The owner will review the final release candidate rather than provide staged feedback.
- [x] Android device checks confirm the current-date, cash, savings, next-bill, and payday information remain visible after the UI update.
- [x] The starting scenario has deterministic balance coverage: a sound-choice route completes a configured cycle and reconciles cash exactly with the ledger.
- [x] Developer checks cover core player-journey interactions; final owner approval is deferred to the release candidate review by product decision.

### Gate E — Google Play release package

- [ ] Unique final Android application ID is confirmed before production release.
- [ ] `targetSdk` meets the Google Play requirement at submission time; re-check immediately before upload.
- [ ] Version name/code are set for the release.
- [ ] Signed Android App Bundle (`.aab`), not only a debug APK, is built and installed/tested.
- [ ] Release keystore is privately backed up and never committed to Git.
- [ ] App icon, feature graphic, screenshots, short description, full description, category, contact email, and content rating are ready.
- [ ] Privacy policy is published and accurately describes local storage, Firebase Core configuration, and any data collection.
- [ ] Google Play Data safety form accurately matches the final app behaviour.
- [ ] Closed test track passes before production submission.

## v1.1 Supporter release goal

Only begin after v1.0 is stable in testing or published.

Goal: let a willing player pay through Google Play for cloud sync and a priority-support queue, while all core game play remains free and offline-capable.

Additional non-negotiable gates:

- [ ] Firebase Auth, Firestore Security Rules, account deletion, and cloud restore are tested with separate user accounts.
- [ ] Subscription purchase, cancellation, expiration, refund, restore, and entitlement verification are tested with Play license testers.
- [ ] Secure purchase-verification backend and subscription-change handling are live before accepting real payments.
- [ ] Supporter expiry pauses cloud sync but never blocks local play or removes local data.
- [ ] Priority support has an actual owner, queue, and honest response target.

## Release decision

The release decision is binary:

```text
All applicable v1.0 gates checked + release build verified = READY TO SUBMIT
Any unchecked v1.0 gate                              = NOT READY TO SUBMIT
```

Update this file at every milestone. The current active work must name the one remaining gate item it is trying to close.
