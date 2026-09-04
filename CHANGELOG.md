# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
