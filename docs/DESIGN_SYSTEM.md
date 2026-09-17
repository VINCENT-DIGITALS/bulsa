# BULSA Design System

This is the visual source of truth for BULSA. Follow it for every new screen, widget, overlay, and Flame presentation.

## Brand direction

**Quiet, warm, and trustworthy.** BULSA should feel like a helpful personal game companion—not a bank portal, a neon arcade game, or a crowded financial dashboard.

## Native logo and splash

The native BULSA mark is a dark wallet with a warm primary inner panel and a
light coin detail. It is defined once as the Android vector
`@drawable/bulsa_logo_mark`, then reused for the launcher and splash screen.
The native splash uses `background` (`#F8F8F8`) with the centered mark on every
supported Android version. Do not introduce a separate logo palette, gradient,
or one-off splash background.

## Core color tokens

| Token | Hex | Use |
| --- | --- | --- |
| `primary` | `#C59D62` | Primary actions, selected state, progress, rewards |
| `background` | `#F8F8F8` | App/page background |
| `lightGray` | `#E8E8E8` | Borders, inactive controls, muted surfaces |
| `black` | `#2F2F32` | Primary text, icons, high-contrast UI |

Use these colors by default. Any additional semantic color (success, warning, danger) must be defined here before it is used in the product.

### Color usage rules

- Use `background` as the main screen canvas.
- Use white surfaces sparingly for cards, modals, and event content; separate them with `lightGray` borders rather than heavy shadows.
- Reserve `primary` for the most important action on a screen and for positive progress. Do not make every button gold.
- Use `black` for readable text; do not replace important text with light gray.
- Do not use gradients, random brand colors, or pure black/white substitutes unless this document is updated first.

## Radius scale

Radius communicates component type. Never choose a one-off radius value.

| Component | Token | Radius |
| --- | --- | --- |
| Small tags, chips, compact status indicators | `radiusSmall` | `8` |
| Buttons, input fields, small action cards | `radiusControl` | `12` |
| Standard containers, event cards, money summary cards | `radiusContainer` | `16` |
| Modals, bottom sheets, large dialogs | `radiusModal` | `24` |
| Circular avatars / icon buttons only | `radiusCircle` | `999` |

Examples: every primary button uses `radiusControl`; every event card uses `radiusContainer`; every modal uses `radiusModal`. A modal must not use the card radius simply because both are rounded rectangles.

## Spacing and layout

Use an 8-point spacing rhythm: `4, 8, 12, 16, 24, 32`.

- Screen horizontal padding: `16`.
- Normal gap between related controls: `8` or `12`.
- Gap between sections: `24`.
- Minimum touch target: `48 × 48` logical pixels.
- Buttons should normally fill the available width on mobile decision screens.

### Semantic spacing tokens

The numeric scale stays small and deliberate. Use the semantic names in the
Flutter theme rather than choosing values per screen.

| Use | Token | Value |
| --- | --- | --- |
| Screen sides | `screenHorizontal` | `16` |
| Screen top | `screenTop` | `24` |
| Screen bottom | `screenBottom` | `32` |
| Header to first content section | `headerToContent` | `24` |
| Between independent sections | `section` | `24` |
| Standard card content | `card` | `16` |
| Prominent event/result card content | `prominentCard` | `24` |
| Adjacent actions | `actionGap` | `8` |

### Page hierarchy

Every main tab starts with the same vertical header: a 48 × 48 outlined icon
tile, screen title, then one short description. Content begins 24 pixels below
that header. Informational cards use an icon tile, title, and description in
that order. This gives screens a predictable scanning path without making the
app feel like a dense finance dashboard.

### Action layout

- One primary action occupies a full row.
- Two related actions share one row with equal widths and an 8-pixel gap.
- More than two actions must be split into separate rows or presented as
  decision choices; never squeeze three actions into one row.
- Use the shared `BulsaPrimaryButton`, `BulsaSecondaryButton`, and
  `BulsaButtonRow` widgets. Buttons are 52 pixels high, exceeding the
  48-pixel minimum touch target.

### Elevation, selection, and navigation

- Use the shared `BulsaShadows.card` and `BulsaShadows.navigation` tokens;
  never add a one-off shadow to a screen.
- Cards stay white with a light border and restrained shadow. The shadow gives
  hierarchy, not decoration.
- Selection lists use the shared modal bottom sheet, with a drag handle and a
  24-pixel exposed-top radius. Do not use a compact dropdown menu for form
  choices on mobile.
- The bottom navigation is a calm persistent surface with an outlined top
  separation/shadow, 72-pixel height, readable labels, and the primary selected
  indicator.

### Semantic spacing tokens

The numeric scale stays small and deliberate. Use the semantic names in the
Flutter theme rather than choosing values per screen.

| Use | Token | Value |
| --- | --- | --- |
| Screen sides | `screenHorizontal` | `16` |
| Screen top | `screenTop` | `24` |
| Screen bottom | `screenBottom` | `32` |
| Header to first content section | `headerToContent` | `24` |
| Between independent sections | `section` | `24` |
| Standard card content | `card` | `16` |
| Prominent event/result card content | `prominentCard` | `24` |
| Adjacent actions | `actionGap` | `8` |

### Page hierarchy

Every main tab starts with the same vertical header: a 48 × 48 outlined icon
tile, screen title, then one short description. Content begins 24 pixels below
that header. Informational cards use an icon tile, title, and description in
that order. This gives screens a predictable scanning path without making the
app feel like a dense finance dashboard.

### Action layout

- One primary action occupies a full row.
- Two related actions share one row with equal widths and an 8-pixel gap.
- More than two actions must be split into separate rows or presented as
  decision choices; never squeeze three actions into one row.
- Use the shared `BulsaPrimaryButton`, `BulsaSecondaryButton`, and
  `BulsaButtonRow` widgets. Buttons are 52 pixels high, exceeding the
  48-pixel minimum touch target.

## Typography and hierarchy

- Use one readable sans-serif family supplied by Flutter/Material until a brand typeface is deliberately selected.
- Use `black` for headings and essential figures.
- Use clear labels before values: `AVAILABLE CASH`, then `₱4,280`.
- Do not rely on color alone for payday status, warnings, or money changes; include text and an icon where useful.

## Component rules

### Primary button

- Background: `primary`; text/icon: `black`.
- Radius: `radiusControl` (`12`).
- Use one primary action per view when possible.

### Secondary button

- Transparent or white background with `lightGray` border.
- Text/icon: `black`.
- Radius: `radiusControl` (`12`).

### Event card / container

- White surface, subtle `lightGray` border.
- Radius: `radiusContainer` (`16`).
- The situation title, short explanation, and choices must be readable without scrolling where practical.

### Modal / bottom sheet

- White surface over a dimmed scrim.
- Radius: `radiusModal` (`24`) on exposed top corners.
- Use for confirmations that affect money, such as withdrawing savings or accepting debt.

### Money and status

- Never show a financial effect only through animation. Also display a signed amount and a ledger label, for example `−₱120 · Food`.
- Keep confirmed income and possible income visually labeled as different states.

## Flutter implementation seed

```dart
abstract final class BulsaColors {
  static const primary = Color(0xFFC59D62);
  static const background = Color(0xFFF8F8F8);
  static const lightGray = Color(0xFFE8E8E8);
  static const black = Color(0xFF2F2F32);
}

abstract final class BulsaRadius {
  static const small = Radius.circular(8);
  static const control = Radius.circular(12);
  static const container = Radius.circular(16);
  static const modal = Radius.circular(24);
}
```

Create a single `theme/` implementation from these tokens before building screens. Widgets must import the shared tokens rather than declaring hex colors or `BorderRadius.circular(...)` values locally.
