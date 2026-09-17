# BULSA Backend and Authentication

## Decision

**Use an offline-first Flutter app. Add Firebase only when cloud backup or FCM is needed.**

The first playable game must work without an account, internet connection, backend, or payment details. Store the player profile and current game locally on the device. This keeps the prototype free, fast, private, and simple to build.

When players need to restore a profile on another phone, use **Firebase Authentication + Cloud Firestore** for optional sign-in and cloud sync. Use **Firebase Cloud Messaging (FCM)** later for remote notifications.

## Why Firebase

Firebase keeps authentication, Cloud Firestore, analytics/crash reporting, and FCM in one mobile-focused ecosystem. That means one project configuration, one set of Flutter packages, and fewer services to learn.

For BULSA’s early structured data, model the game as Firestore documents/subcollections rather than SQL tables. The current Spark free quota includes 1 GiB Firestore storage, 50,000 reads/day, 20,000 writes/day, 20,000 deletes/day, and 10 GiB/month outbound transfer. Firebase Authentication (except phone/SMS) and FCM are no-cost products. Firebase has no inactivity pause like Supabase Free.

The trade-off: Firestore charges by document operations at scale, so avoid wasteful real-time listeners and keep game data local while the player is playing. The app should still work offline first.

## Recommended architecture

```text
Flutter UI + game rules
        │
        ├── Local device storage (always available; source of play during a run)
        │      ├── profile
        │      ├── current run
        │      ├── ledger
        │      └── game settings
        │
        └── Firebase (optional cloud backup, cross-device restore, FCM)
               ├── Firebase Authentication
               ├── Cloud Firestore
               ├── Firebase Security Rules
               └── Firebase Cloud Messaging
```

### Local storage

- Use **Drift + SQLite** as BULSA's local game database. It is free, offline, and designed for related data such as profiles, pay schedules, runs, bills, and many ledger entries.
- Use `drift_flutter` to open the database on Flutter platforms. At the time of this decision, use `drift: ^2.35.0` and `drift_flutter: ^0.3.1` when Phase 1 begins; re-check compatible current versions before adding them.
- Use Drift/SQLite for **all** local persistence, including small settings such as onboarding completion, selected tab, and notification preference. This keeps storage implementation and migration behavior consistent.
- Never add or use `shared_preferences` in BULSA.
- Keep business rules in Dart, separate from both Flutter widgets and Firebase calls.
- Export/import can be a later user-controlled backup option.

## Authentication plan

### Phase 1: Guest by default

- Start immediately with a local profile; no sign-up wall.
- Display a gentle `Back up your progress` option only after the player has played enough to care.
- Never make an account a requirement for basic gameplay.

### Phase 2: Optional account link

Offer these providers in this order:

1. **Google Sign-In** on Android — familiar and low-friction for the target platform.
2. **Apple Sign-In** when the iOS version is publicly released.
3. **Email + password** as a fallback, with password reset handled by Firebase Authentication.

Do not use SMS/phone authentication in the free MVP; it can incur per-message costs and requires more abuse protection. Do not invent a custom password system.

Anonymous Firebase identities are possible, but not needed in the first version. A device-local guest profile is simpler. If anonymous Firebase Auth is added later, it must be linkable to Google/Apple/email before a user changes device, otherwise recovery is unreliable.

## Cloud Firestore structure

All player data lives beneath the authenticated user ID. Firestore Security Rules must only permit a signed-in user to read/write their own path: `users/{uid}/...`.

| Collection / document | Purpose | Example fields |
| --- | --- | --- |
| `users/{uid}` | Optional player/work profile | `displayName`, `jobTitle`, `employmentType` |
| `users/{uid}/paySchedules/{id}` | Regular cutoffs and payday policy | `dayRule`, `weekendPolicy`, `amount` |
| `users/{uid}/gameRuns/{runId}` | One saved pay-cycle run | `startDate`, `status`, `cash`, `savings` |
| `users/{uid}/gameRuns/{runId}/ledger/{entryId}` | Immutable in-game money history | `amount`, `category`, `occurredAt` |
| `users/{uid}/gameRuns/{runId}/choices/{choiceId}` | Decisions made during a run | `eventId`, `selectedChoiceId` |

Store only game/profile data. Do not collect real bank accounts, payment cards, CVVs, PINs, payslips, salary documents, or financial credentials.

## Sync behaviour

- The local database is usable offline and remains responsive during a game.
- Sync after a completed choice and when the app returns online; do not make the player wait for a network request.
- During MVP, use one active device as the supported assumption. If two devices edit the same run, show a clear conflict prompt rather than silently overwriting data.
- Save the game rules/version with every run so later game-balance changes do not corrupt old saves.

## Notifications: local first, FCM later

- Use **local notifications** for personal reminders such as a scheduled payday or a bill due tomorrow. They work while the player is offline and need no server.
- Use **FCM** for remote messages such as a new-season announcement, an optional campaign notification, or a cross-device sync prompt. FCM itself is no-cost.
- Do not put a Firebase server credential in the Flutter app. Sending FCM messages programmatically requires a trusted server environment. Until a secure server/budget exists, send campaign notifications manually through Firebase Console or keep notifications local.

## Security checklist

- Write and test Firebase Security Rules before any mobile app release.
- Keep Firebase server/service-account credentials out of Flutter code, Git, and app builds.
- Keep Firebase configuration in generated/build configuration, not hard-coded in widgets.
- Restrict Android OAuth credentials to BULSA’s package name and signing certificate when Google Sign-In is enabled.
- Add an in-app account deletion flow before public release if cloud accounts are offered.
- Do not claim that a free service is permanently free; review quotas before public launch.

## What not to build yet

- No Firebase project, credentials, dependency, or network calls in Phase 0–1.
- No real-time multiplayer, payment transfer, QR payments, bank integrations, or server-side game economy.
- No cloud sync until a complete local 7-day game run is working and tested.

## Sources

- [Firebase pricing](https://firebase.google.com/pricing)
- [Cloud Firestore free quota](https://firebase.google.com/docs/firestore/pricing)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Firebase anonymous authentication](https://firebase.google.com/docs/auth/flutter/anonymous-auth)
