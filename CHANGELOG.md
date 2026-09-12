# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **`LabelWithValue` stopped guessing whether a label and its value fit, and asks the layout.** It
  stacked them past a text scale of 1.3 — a threshold that knows the scale and nothing about the
  label's translated length, the value's width or the phone's. Below it the label was squeezed to
  whatever the value left and ellipsised; above it a pair that fitted a tablet was stacked anyway.
  It is a `Wrap` now: beside while both fit, beneath once they do not, decided by the widths
  actually on screen. The 160 px cap stays only where there is no label to protect and no line to
  drop to — a value standing alone.

  **Layout tests that assert which line the pair lands on need a real font.** `flutter_test` draws
  every glyph as a square of the font size, about 1.7× wider than the face that ships, so a pair
  that sits side by side on a 360 pt phone stacks under the test font. What holds in every font is
  that the label keeps its words and nothing overflows; the sharing question is asked here, where
  the font is known.

## [0.1.3] - 2026-09-12

### Fixed

- A one-line `ScreenHeader.headline` sat at the top of the 48 dp band instead of on the arrow's
  centre line. It is centred within the band now, and a headline that outgrows it still wraps
  beside the arrow rather than dragging it down the screen.
- A value stacked under its label was held to the trailing slot's 160 px cap, where it has the
  whole width — a status pill wrapped to three lines and pushed the screen under it 35 px past the
  bottom at 2.0× in Russian.

## [0.1.2] - 2026-09-12

**The parts four apps of the line each wrote for themselves.** A component that lives in four repos
drifts in four directions: of the four `ScreenHeader`s, one marked its label as a heading, one
guarded against an empty label, one capped its trailing slot, and one aligned the row on its
children's TOPS — which put a 14 px overline seventeen pixels above the 48 px arrow beside it, and
shipped that way in a store listing's screenshots.

### Added

- `ScreenHeader` and `LabelWithValue`: the way back, what the screen is, and one value, on ONE row
  at the arrow's height. Slots for a text value, a widget value (bounded, so a `StatusPill`'s
  `maxLines` can bite), and a fixed-size action that never stacks. `ScreenHeader.headline` for a
  screen whose title is the first thing said. The label carries `Semantics(header: true)` — the one
  thing an `AppBar` would have given for free — and an absent or empty label announces nothing
  rather than an empty heading. The app passes its own `back` widget: how an app pops is the app's
  business, and `back: null` keeps the band without an arrow.
- `AppBackButton`: the arrow, its RTL mirroring and its `MaterialLocalizations` tooltip, with
  `onPressed` required and no default — the icon is the same in every app and HOW an app pops is
  the one thing that is not. It was byte-identical in four repos.
- `ProgressBar`: a horizontal bar for a 0..1 value, `normal` or `featured`. A comparison rather
  than an indicator — bars in a list share an origin and a scale, so the ranking reads before any
  number does. Clamps its value (a NaN from a `0 / 0` upstream draws empty rather than asserting),
  fills from the leading edge, and reads its defaults from `ProgressIndicatorThemeData`.
- `LevelBars`, with two constructors: a snapshot for a gallery or a golden, and `LevelBars.live`,
  which repaints from a `ValueListenable` without rebuilding anything — the only shape that works
  for an audio meter at ~22 frames a second.
- `StatTile`: a label and the value that changes under it, with a tone icon or a live dot. The
  caller owns the flex.
- `StatusDot`: the pill's dot, on its own, for a row that needs a second reading of what it already
  says. Excluded from semantics; a null tone is the absence of a verdict and does not glow.
- `AppTheme.paper`: a light theme for a subtree inside a dark app — a document preview. Keeps the
  ambient font, which a bare `resolve` drops. Wrap the subtree in a `Material` so `DefaultTextStyle`
  is re-derived, or the text stays dark on white paper.
- `GradientBorderCard` takes `radius` and `glow`: the same card at row scale, and the one element a
  screen is about.

### Changed

- `StatusPill` takes `maxLines`: a status word has no space to break at, so a pill sharing a header
  row used to wrap mid-word. Callers on such a row pass 1, as they already do for `SectionLabel`.
  The pill's private dot is now `StatusDot`.

### Fixed

- `InfoBanner`'s action was a bare `TextButton` beside an `Expanded` message: unconstrained next to
  flexible, so at 2.0× in a long language the button kept its natural width, the message shrank to
  nothing, and the row overflowed anyway. It drops under the message past the same 1.3× scale
  `LabelWithValue` uses. One app had grown a private wrapper widget purely to avoid this banner.

## [0.1.1] - 2026-09-11

Released as a tag without this entry; recorded here with 0.1.2.

- `SectionLabel` takes `maxLines`: a label that shares a row with a back arrow and a trailing value
  must not wrap.

## [0.1.0] - 2026-09-04

First release.

- `AppTheme`, `AppPalette`, `Brand` and `AuroraScheme`: an app's colours are a `const` value it
  hands to the kit, so several apps share one design system without sharing a look.
- Adaptive layer: `WindowClass`, `WindowSizeScope`, `AppResponsiveTheme`, `ListDetail`,
  `ContentPane` and `UserTextScaler`.
- Kit components: `AppScaffold`, the button family, the glass surfaces, `ListRow`, `ChecklistRow`,
  `CodeDigits`, `GaugeRing`, `LockedLabel`, `QrView`, `SelectionSheet`, status signals and
  `Shimmer`.
- `dart run aurora_glass:gen_tokens` generates the shared half of the palette into this package;
  `dart run aurora_glass:gen_brand` generates an app's own half into the app, from a JSON spec.
- `example/` is the gallery: every component, every state, both themes. It generates its own
  palette, which also keeps `gen_brand` tested.
