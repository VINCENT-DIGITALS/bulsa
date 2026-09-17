# BULSA Google Play submission handoff

This is the owner handoff for the **free, offline v1.0** release. It is not a
substitute for the release gates in [Release Readiness](RELEASE_READINESS.md).
Never replace a missing value below with a placeholder in the app, Play
Console, or privacy policy.

## Store copy ready to use

| Field | Draft |
| --- | --- |
| App name | BULSA |
| Recommended category | Games > Simulation |
| Short description | An offline game about making your fictional pay cycle last. |
| Audience | General audience; complete the Play content-rating questionnaire truthfully. |

### Full description

**BULSA** is a small offline budgeting-survival game inspired by everyday pay
cycles in the Philippines.

Set a payday schedule, decide what happens when it lands on a weekend, and
make one fictional everyday choice at a time. Protect your in-game cash, build
savings, cover fixed bills, and review every change in a clear ledger.

Your profile, schedule, game runs, and ledger stay on your device in this free
release. No account, subscription, bank connection, payment card, or real
financial information is needed to play.

## Owner-only inputs before a public submission

- Final, unique Android `applicationId`; it must also match the Firebase Android
  app configuration if Firebase Core remains in the build.
- Private upload keystore, backed up outside the repository, and a release-signed
  Android App Bundle.
- Verified Play Console developer identity and its required contact details.
- Public support contact email and/or URL, after the owner has a real domain or
  other verified destination.
- Hosted privacy-policy URL using the final policy text and a reachable public
  host.
- Play Console screenshots, feature graphic, final category/content rating,
  support contact, and Data safety answers.
- Closed-track test completion before production submission.

## Data and privacy review

The v1.0 product code stores gameplay/profile data in local Drift/SQLite. It
does not expose sign-in, cloud sync, FCM, analytics, crash reporting, billing,
or a support-ticket upload flow. Firebase Core is configured, so the release
owner must review the exact SDK version and final build when completing the
Data safety form; third-party SDK behaviour also counts as data collection.
Do not claim “no data collected” without that final review.

Google Play requires published apps—including closed/open testing tracks—to
complete Data safety information and provide a privacy-policy link. Firebase
also says the developer is responsible for the final disclosure. Read the
[Play Data safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-AE)
and [Firebase Android disclosure guidance](https://firebase.google.com/docs/android/play-data-disclosure)
immediately before submission.

## Build verification commands

```sh
flutter analyze
flutter test
flutter build appbundle --release
```

The release bundle must use the owner’s upload-key signing configuration. Do
not submit a debug-signed bundle.
