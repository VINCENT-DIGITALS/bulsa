# BULSA Feature Roadmap

This is the delivery order and continuation log. Finish and verify a phase before starting the next one.

## Current status

**Active phase: Phase 0 — Foundation.** The Flutter app shell and shared theme tokens are in place; gameplay implementation has not started yet.

When work stops, update this file with: current phase, completed items, next exact task, and any blocker.

## Phase 0 — Foundation

Goal: create a stable Flutter app shell and shared design system.

- [x] Create Flutter project structure.
- [x] Add `BulsaColors`, radius tokens, and shared button/card theme configuration.
- [x] Apply `#F8F8F8` page background and the mandatory design system.
- [x] Create navigation placeholders: Today, Calendar, Ledger, Profile.
- [ ] Verify the interface on a small mobile viewport.

**Next exact task:** Add shared typography and reusable page/button/card components, then verify the shell on an Android emulator.

**Exit condition:** A polished static shell exists with no arbitrary colors or radii.

## Phase 1 — First playable daily decision

Goal: prove the core choice loop in a short hard-coded run.

- [ ] Add Drift/SQLite game state: date, cash, savings, next bill, ledger, and app settings.
- [ ] Create one 7-day scenario with fixed dates.
- [ ] Show one event card with 2–3 choices and immediate money update.
- [ ] Add a ledger entry for every money change.
- [ ] Show a simple completed-run result.

**Exit condition:** A player can complete a 7-day run in under five minutes and understands why cash changed.

## Phase 2 — Calendar and pay cycles

Goal: make the game reflect real-world cutoff patterns.

- [ ] Add selectable run start date.
- [ ] Support payday on a day number and on the last calendar day of a month.
- [ ] Handle 28–31-day months and leap years.
- [ ] Add payday weekend/holiday policy: advance, delay, or keep date.
- [ ] Show payday status: Expected, Early, Late, Received, Pending.
- [ ] Support confirmed salary and recurring allowance.

**Exit condition:** A 15th/month-end pay cycle works correctly across month boundaries.

## Phase 3 — Profiles and variable income

Goal: personalize scenarios without requiring sensitive data.

- [ ] Local-only optional profile: display name, avatar, job title, work tags, pay setup.
- [ ] Add possible income: project incentive, freelance opportunity, one-time bonus.
- [ ] Keep possible income out of confirmed budget forecasts.
- [ ] Add profile-driven event weighting, such as remote work or commuter events.

**Exit condition:** A player can set up an app-developer profile and encounter a non-guaranteed project incentive.

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

**Exit condition:** A player can opt in, back up their game, restore it safely, and still play offline without an account.

## Phase 4 — Game depth and balance

Goal: make replaying interesting and fair.

- [ ] Add 8–10 varied event cards.
- [ ] Add fixed bills, savings withdrawal confirmation, and debt limit.
- [ ] Use seedable random events for repeatable testing.
- [ ] Tune win/lose scoring and a month/pay-cycle result screen.
- [ ] Add one financial lesson per completed run.

**Exit condition:** Different choices produce meaningfully different outcomes without unavoidable losses.

## Phase 5 — Flame presentation

Goal: add game feel without changing core rules.

- [ ] Add subtle Flame background/scene to the Today screen.
- [ ] Add coin, payday, warning, and celebration effects.
- [ ] Respect reduced-motion settings.
- [ ] Keep all decision UI accessible Flutter widgets.

**Exit condition:** Animation reinforces player feedback and never hides important information.

## Phase 6 — Post-MVP progression

Goal: add long-term motivation only after the core loop is proven.

- [ ] Additional scenarios and difficulty levels.
- [ ] Achievements, cosmetic themes, avatars, and fictional wallet/card skins.
- [ ] Goals and deeper budget categories.
- [ ] Local save/load, then optional cloud sync if explicitly desired.

**Not planned without a separate product/security decision:** real payments, bank connections, payment-card storage, money transfer, or real payment QR codes.
