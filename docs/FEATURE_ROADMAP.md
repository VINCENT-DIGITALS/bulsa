# BULSA Feature Roadmap

This is the delivery order and continuation log. Finish and verify a phase before starting the next one. The publish-ready definition is in [Release Readiness](RELEASE_READINESS.md); phase completion is not accepted unless its applicable release-gate evidence also exists.

## Launch plan

- **BULSA v1.0 Free Release:** Phases 0–5 plus every v1.0 release gate. It is the first publishable goal.
- **BULSA v1.1 Supporter Release:** Phase 3.5 and Phase 7 after v1.0 stability. It adds optional cloud sync and priority support only.

## Current status

**Active phase: v1.0 release hardening.** Phases 0–5 are implemented. The remaining work is the required first-time journey, help/privacy, accessibility, migration, and Android release-package evidence.

**Next exact task:** Run Android accessibility and visual QA at 1.3 font scale on both a small and a larger phone viewport, then close the remaining Gate C design/accessibility evidence. Help and privacy content is visible from Profile; a real verified contact destination and hosted privacy-policy URL remain release-owner inputs.

**Automated accessibility evidence:** A compact 360 × 640 logical-pixel widget pass at 1.3 text scale now opens each core tab without a Flutter exception. This protects against layout/runtime regressions, but does not replace the pending Android visual inspection for clipped essential content.

When work stops, update this file with: current phase, completed items, next exact task, and any blocker.

## Phase 0 — Foundation

Goal: create a stable Flutter app shell and shared design system.

- [x] Create Flutter project structure.
- [x] Add `BulsaColors`, radius tokens, and shared button/card theme configuration.
- [x] Apply `#F8F8F8` page background and the mandatory design system.
- [x] Create navigation placeholders: Today, Calendar, Ledger, Profile.
- [x] Verify the interface on a small mobile viewport at normal and 1.3 font scale.

**Verification evidence:** `flutter analyze`, widget tests, and Android debug APK build passed. The Android emulator showed the shell at normal and 1.3 font scale with no clipped essential content.

**Exit condition:** A polished static shell exists with no arbitrary colors/radii, and Release Gate C visual/accessibility checks have evidence.

## Phase 1 — First playable daily decision

Goal: prove the core choice loop in a short hard-coded run.

- [x] Add Drift/SQLite game state: day, cash, savings, and ledger.
- [x] Create one deterministic 7-day scenario.
- [x] Show one event card with 2–3 choices and immediate money update.
- [x] Add a visible ledger entry for every money change.
- [x] Show a completed-run result and restart option.

**Verification evidence:** Local-store unit tests cover creating/persisting a run, recording a choice, and completing Day 7. Android emulator verification showed Day 1 → Day 2 with cash changing from ₱5,000 to ₱4,880, retained after an app restart; the Ledger tab displayed the recorded −₱120 entry.

**Release-hardening evidence:** Widget tests now save an optional local profile, save Calendar policy/income settings, move cash to and from savings through the confirmation flow, play a configured two-day cycle through the visible Today choices, render its result screen, and reload the completed run and ledger. Store tests exercise legacy-schema upgrade, calendar settings, bills, savings transfers, payroll, failure, and ledger reconciliation. The UI audit also fixed every asynchronous `setState` defect found in onboarding, profile, Calendar, and Today money-saving flows.

**Exit condition:** A player can complete a 7-day run in under five minutes, understands why cash changed, and Gate A/B persistence/ledger checks pass.

## Phase 2 — Calendar and pay cycles

Goal: make the game reflect real-world cutoff patterns.

**Next exact task:** Create calendar/payday domain models and tests for month-end, February, and the 15th/month-end cutoff schedule before replacing the fixed 7-day dates in the UI.

- [x] Add selectable run start date.
- [x] Support payday on a day number and on the last calendar day of a month.
- [x] Handle 28–31-day months and leap years.
- [x] Add payday weekend policy: advance, delay, or keep date.
- [x] Show payday status: Expected, Early, Late, Received, Pending.
- [x] Support confirmed salary and recurring allowance.

**Verification evidence:** Unit tests cover February in common and leap years, Saturday advance, Sunday delay, next-payday calculation across a month boundary, start-date persistence, and final-day confirmed salary/allowance ledger credits. `flutter analyze`, all 11 tests, and Android debug APK builds passed. Android emulator checks confirmed the Calendar controls and adjusted-payday presentation.

**Exit condition:** A 15th/month-end pay cycle works correctly across month boundaries, with Gate B calendar tests for February and weekend policies. **Met.**

## Phase 3 — Profiles and variable income

Goal: personalize scenarios without requiring sensitive data.

- [x] Local-only optional profile: display name, avatar, job title, work tags, pay setup.
- [x] Add possible income: project incentive, freelance opportunity, one-time bonus.
- [x] Keep possible income out of confirmed budget forecasts.
- [x] Add profile-driven event weighting, such as remote work or commuter events.

**Verification evidence:** Local-store tests persist an app-developer profile and verify it does not alter confirmed payday income. Event-selection tests give the remote-work project-incentive event an additional deterministic slot and verify the incentive is a possible event, not a forecast. `flutter analyze`, all 14 tests, and Android debug APK builds passed. Android emulator validation confirmed the Profile screen's local-only privacy messaging and form layout.

**Exit condition:** A player can set up an app-developer profile and encounter a non-guaranteed project incentive. **Met.**

## Phase 3.5 — Optional cloud backup, account linking, and notifications

Goal: protect player progress without blocking offline play.

- [ ] Complete and test local Drift/SQLite persistence first.
- [ ] Create a Firebase project only when the local game loop is stable.
- [ ] Configure Firebase Authentication, Cloud Firestore, and tested user-owned Security Rules.
- [ ] Create `users/{uid}` documents with pay schedules, game runs, ledger, and choices as subcollections.
- [ ] Add optional Google Sign-In on Android and link local profile data to the account.
- [ ] Add offline-first sync and clear conflict handling.
- [ ] Add local notifications for bills and paydays; defer FCM campaigns until a secure sending environment exists.
- [ ] Add account deletion before public release.

**Exit condition:** A player can opt in, back up their game, restore it safely, and still play offline without an account. This is a v1.1 Supporter gate, not a v1.0 blocker.

## Phase 4 — Game depth and balance

Goal: make replaying interesting and fair.

- [x] Add 8–10 varied event cards.
- [x] Add fixed bills, savings withdrawal confirmation, and debt limit.
- [x] Use seedable random events for repeatable testing.
- [x] Tune win/lose scoring and a month/pay-cycle result screen.
- [x] Add one financial lesson per completed run.

**Verification evidence:** The deterministic pack contains ten event cards. Unit tests cover fixed-bill charges, savings movement, debt-limit failure, outcome scoring, seeded event sequences, and a full sound-choice route that survives a configured cycle while cash reconciles exactly with ledger entries. Android emulator checks verified the bill/savings layout and withdrawal safeguard. Run the full verification suite again after this milestone before treating the evidence as current.

**Exit condition:** Different choices produce meaningfully different outcomes without unavoidable losses, and Gate D product validation passes. **Met by product decision and developer evidence.**

**Owner validation decision:** The product owner supplied UI feedback, approved the resulting direction, and will review the final release candidate rather than provide staged re-test feedback. Developer automated and Android device checks are the Phase 4 evidence; no further owner feedback is a Phase 5 blocker.

## Phase 5 — Flame presentation

Goal: add game feel without changing core rules.

- [x] Add subtle Flame background/scene to the Today screen.
- [x] Add coin, payday, warning, and celebration effects.
- [x] Respect reduced-motion settings.
- [x] Keep all decision UI accessible Flutter widgets.

**Verification evidence:** Flame is embedded as a touch-transparent 96-pixel Today scene. It paints only approved BULSA colors and surfaces steady, payday-soon, celebration, and warning states. `MediaQuery.disableAnimationsOf` stops scene updates when reduced motion is requested, while all choices, forms, and dialogs remain Flutter widgets. `flutter analyze`, all 22 tests, Android debug APK build, and Android emulator visual QA passed.

**Exit condition:** Animation reinforces player feedback, never hides important information, and respects Gate C reduced-motion requirements. **Met.**

## Phase 6 — Post-v1.0 progression

Goal: add long-term motivation only after the core loop is proven.

- [ ] Additional scenarios and difficulty levels.
- [ ] Achievements, cosmetic themes, avatars, and fictional wallet/card skins.
- [ ] Goals and deeper budget categories.
- [ ] Local save/load, then optional cloud sync if explicitly desired.

**Not planned without a separate product/security decision:** real payments, bank connections, payment-card storage, money transfer, or real payment QR codes.

## Phase 7 — Optional Supporter subscription and support

Goal: fund cloud sync and support without paywalling the game.

- [ ] Build public help centre and standard contact route.
- [ ] Build a Supporter priority-support request path with honest response expectations.
- [ ] Complete Firebase Auth and verified cloud sync before selling Supporter access.
- [ ] Configure monthly and yearly Google Play subscription products and test with license testers.
- [ ] Build a secure backend for Play purchase verification, entitlement status, cancellation, refunds, and restoration.
- [ ] Keep all local game features/data free when the subscription expires.

**Exit condition:** A player can voluntarily subscribe through Google Play, restore a purchase, use cloud sync and priority support while active, and continue playing locally after cancellation. This must meet every v1.1 Supporter release gate.
