# BULSA Working Rules

Read these files before changing the product:

1. [Product overview](#%20BULSA%20🇵🇭.md) — concept, gameplay, finance boundaries.
2. [Design system](docs/DESIGN_SYSTEM.md) — mandatory visual tokens and UI rules.
3. [Feature roadmap](docs/FEATURE_ROADMAP.md) — current phase, scope, and continuation point.
4. [Backend and authentication](docs/BACKEND_AND_AUTH.md) — offline-first storage, Firebase cloud sync/FCM, and security rules.

## Non-negotiable rules

- Use the connected GitHub repository as the project source of truth. Create focused branches when useful, commit completed work with clear messages, and push changes so work can resume from GitHub.
- Follow `docs/DESIGN_SYSTEM.md` exactly. Do not introduce unapproved colors or arbitrary border radii.
- Build only the active roadmap phase unless the user explicitly changes scope.
- Preserve the distinction between confirmed and possible income.
- Treat all money, cards, transactions, and QR concepts as fictional game systems. Never request or store banking credentials, payment-card details, PINs, CVVs, or real payment access.
- Prefer Flutter for interface and state. Add Flame only for game presentation and interactions that improve player feel.
- Keep the app mobile-first, clear, and accessible.
- Do not add backend packages, credentials, network calls, or authentication screens before the roadmap reaches the backend/auth phase.
- Use Drift/SQLite for **all** local persistence, including settings. Never add or use `shared_preferences`.
