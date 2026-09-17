# BULSA App Architecture

## Purpose

Keep the offline game easy to change without mixing game rules, persistence,
and visual layout. This is a lightweight, feature-first interpretation of
Flutter's recommended separation between UI and data layers.

## Current structure

```text
lib/
├── main.dart                  # App composition and tab shell only
├── theme/                     # Design tokens and Material theme
├── widgets/                   # Reusable layout, cards, and action controls
├── screens/                   # Feature views: Today, Calendar, Ledger, Profile
└── game/
    ├── models/                # Immutable game domain data
    ├── presentation/          # Optional, touch-transparent Flame effects
    ├── rules/                 # Pure, testable calendar/event/result rules
    └── data/                  # Drift/SQLite persistence and scenario data
```

## Boundaries

- **Widgets and screens** render UI, perform layout, and forward user intent.
  They must not contain money calculations, calendar rules, SQL, or hard-coded
  visual tokens.
- **`game/rules`** contains deterministic domain logic. It has no Flutter or
  database dependency and receives unit tests for every money/calendar rule.
- **`LocalGameStore`** is the local data boundary. It owns Drift/SQLite schema,
  migrations, transactions, and persistence. `shared_preferences` is never
  used.
- **Theme and widgets** are the only place to define shared presentation
  tokens, cards, page headers, and button layouts.
- **Flame presentation** is decorative only. It reads an already-derived UI
  state, respects reduced motion, uses shared color tokens, and never owns
  choices, forms, dialogs, money, or accessibility-critical text.
- **Public support configuration** will be read through a repository and cached
  in Drift/SQLite when the backend phase starts. Views must not embed contact
  emails or public URLs as string literals.

## Next evolution, only when complexity needs it

As a screen gains multiple loading/error/mutation states, introduce a
feature-local view model and repository interface:

```text
screen (view) → view model → repository → LocalGameStore / future cloud service
```

Do not add view models merely as boilerplate. Add them when they remove real
screen logic or allow a feature to be tested independently. Game rules stay in
the domain layer regardless of whether a view model exists.

## UI consistency rule

New screens must compose `BulsaPage`, `BulsaInfoCard`, and shared action
widgets before introducing a new local layout component. If a new pattern is
truly reusable, create it in `lib/widgets/`, document it in
`DESIGN_SYSTEM.md`, and add a widget test.
