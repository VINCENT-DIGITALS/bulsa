# BULSA Monetization and Customer Support

## Product promise

**BULSA’s complete core game is free.** Players never need to pay to play a pay cycle, manage a local profile, use the ledger, access core scenarios, or keep their local save.

The optional subscription is a voluntary **BULSA Supporter** plan. It funds the two services that have ongoing operating/support cost:

1. Online cloud backup and cross-device sync.
2. Priority customer support.

Do not sell power, better financial outcomes, locked essential gameplay, or access to a player’s own local data.

## Subscription entitlement

### Free player

- Full offline game and all core gameplay content.
- Local Drift/SQLite profile, settings, runs, and ledger.
- Local notifications for bills and payday reminders.
- Public help centre / FAQ and standard contact channel.

### BULSA Supporter (monthly or yearly)

- Firebase Authentication and encrypted-in-transit cloud backup/sync across signed-in devices.
- A clearly labeled priority support channel in the app.
- Faster target response time, stated honestly (for example, “we aim to reply within two business days”), never a guaranteed instant response.
- Supporter badge/profile acknowledgement, if desired; it must not affect gameplay.

The yearly plan is the same entitlement at a discount. Do not offer lifetime access to cloud sync or priority support: both require ongoing infrastructure and human time.

## Expiry and fairness rules

- Cancellation stops renewal, but Supporter benefits remain active until the paid billing period ends.
- When Supporter access ends, local gameplay and all local data remain available.
- Cloud sync pauses; never silently delete a player’s cloud data because a subscription expires.
- Before any future cloud-data retention limit, notify the player clearly and offer export/restore options. Do not set such a limit in the MVP.
- A restored subscription immediately re-enables cloud sync and priority support.

## Customer support feature

Build this after the core game is stable.

### In-app support screen

```text
HELP & SUPPORT

[ Help centre / FAQ ]
[ Report a problem ]
[ Contact support ]

Your plan: Free / BULSA Supporter
Standard support / Priority support
```

The public help, privacy, and contact destinations must come from a
backend-managed configuration when that backend exists. Do not hardcode a
placeholder email or URL. Until the owner supplies and verifies a real route,
show that support contact is not yet available; do not falsely present it as a
working channel.

### Support request fields

- Topic: Bug, account/cloud sync, billing, feedback, or other.
- Short subject and description.
- App version, device/OS, and optional screenshot only with the player’s consent.
- Never request PINs, payment-card numbers, passwords, Firebase credentials, or bank information.

### Routing

- Free requests use the standard queue.
- Active Supporter requests receive `priority` status and appear first in the support workflow.
- The support UI must not promise a response time that cannot be maintained.
- For MVP, a support request can open a prefilled email. Later, store tickets in a protected Firebase collection and use a private admin workflow—never expose all tickets to app users.

## How payment works on Android

1. The player taps **Become a Supporter**.
2. BULSA shows a transparent plan screen: monthly price, yearly price, renewal terms, and exactly what is included.
3. The app opens the official **Google Play Billing** purchase sheet.
4. The player pays with a payment method available in their own Google Play account; BULSA never sees or stores their card/payment details.
5. Google Play returns a purchase token. A trusted backend verifies it with Google Play, then grants the Supporter entitlement.
6. Firebase records only the verified entitlement, such as `isSupporter` and `supporterExpiresAt`; Flutter reads that status to enable cloud sync and priority support.
7. Google Play handles cancellation, renewal, and payment retry. The backend receives status changes and updates entitlement safely.

For Google Play-distributed Android apps, use Google Play Billing for this digital subscription. Do not place a GCash/bank-transfer/card-payment flow in the app for Supporter access.

## Implementation boundary

Do not add billing until all of these are true:

- The offline game is complete and tested.
- Firebase Auth and cloud sync are working for a test account.
- There is a real support route and a realistic support-response process.
- A secure backend can verify Google Play purchases and process subscription changes.
- The Play Console subscription products, cancellation flow, restoration flow, and transparent purchase screen have been tested with license testers.

## Sources

- [Google Play subscriptions](https://developer.android.com/google/play/billing/subscriptions)
- [Google Play one-time products](https://developer.android.com/google/play/billing/one-time-products)
- [Google Play payments policy](https://support.google.com/googleplay/android-developer/answer/10281818)
- [Play Billing backend guidance](https://developer.android.com/google/play/billing/backend)
