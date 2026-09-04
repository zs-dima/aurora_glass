# aurora_glass

[![CI](https://github.com/zs-dima/aurora_glass/actions/workflows/ci.yml/badge.svg)](https://github.com/zs-dima/aurora_glass/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

The Aurora Glass design system for Flutter: colour tokens, an adaptive layer, a theme and the kit
components built on them. It ships no palette. An app generates its own from the design workspace
and hands it in, so several apps share one kit without sharing a look.

## The idea

A scheme splits in two. Surfaces, the neutral ink ramp, the semantic tertiary/error families and
the gradient geometry are one design, shared, and arrive generated as `AppTokens`. The accent axis
is the app's own, and it is a parameter:

```dart
MaterialApp(
  theme: AppTheme.resolve(Brightness.light, WindowClass.compact, MyPalette.instance),
  darkTheme: AppTheme.resolve(Brightness.dark, WindowClass.compact, MyPalette.instance),
  themeAnimationDuration: Duration.zero,
  builder: (context, child) => WindowSizeScope(
    child: AppResponsiveTheme(palette: MyPalette.instance, child: child!),
  ),
);
```

`AppPalette` bundles a `Brand` pair (the gradients, glows and glass surfaces the components read
through `Brand.of(context)`) with an `AuroraScheme` pair (a `const` `ColorScheme` that takes the nine
accent roles and fills in the shared ones). There is no default and no fallback: a component that
finds no `Brand` in the theme throws rather than inventing colours.

Declare the palette `static const`. `AppTheme.resolve` memoizes on brightness, window class and
palette, so at most ten `ThemeData` objects exist per app and calling it on every build is intended.

## Generating a palette

Colour lives in the design workspace's `colors.json`, written by `make_light.py --emit-tokens`;
dark is the source of truth and light is derived from it by a substitution map. Two generators
read it, and both commit their output so CI and a fresh clone build without the workspace:

```sh
# in this repository: the shared half
dart run aurora_glass:gen_tokens --design-root <design>/tokens

# in an app: its own accent axis, chassis base and inner fills
dart run aurora_glass:gen_brand --design-root <design>/tokens
dart run aurora_glass:gen_brand --check      # fails when the committed file is stale
```

`gen_brand` reads the app's identity from a JSON spec:

```json
{
  "displayName": "My App",
  "tokens": {
    "designApp": "MA",
    "accentRoles": { "#FFC163": "pairStart", "#FF8E6E": "pairEnd" },
    "innerFills": { "rgba(26,18,32,0.92)": "gradientCardInner" }
  }
}
```

Both maps are keyed by the dark value on the artboards. The design file stores them as unordered
dark-to-light maps, so a role cannot be recovered from position; naming the dark value makes a
palette change fail in the generator instead of swapping two colours.

The five values a generator cannot carry, the two ambient glows, the glass fill and border and the
ink on the CTA gradient, are hand-written in the app; they live only in each board's CSS.
`example/lib/gallery_palette.dart` is the worked example.

## What is in the kit

- **Theme**: `AppTheme`, `AppPalette`, `Brand`, `AuroraScheme`, `AppDimens`, and the
  spacing/radius/target/motion scales in `tokens.dart`.
- **Adaptive**: `WindowClass` (Material 3 breakpoints, with `mapWithLowerFallback` so compact is
  the floor), `WindowSizeScope`, `AppResponsiveTheme`, `ListDetail`, `ContentPane`, and
  `UserTextScaler`, which composes an in-app text multiplier over the OS curve instead of
  flattening it.
- **Components**: `AppScaffold`, the button family, `GlassCard` and the other surfaces, `ListRow`,
  `ChecklistRow`, `CodeDigits`, `GaugeRing`, `LockedLabel`, `QrView`, `SelectionSheet`, status
  signals, and a dependency-free `Shimmer` for skeletons.
- **Icons**: one icon font. An app's own glyphs belong in its own family.

## The gallery

`example/` shows every component, every state, both themes, on every platform Flutter targets. It
is an app on this kit like any other: it generates its own palette from the design workspace and
passes it in. Run it with `flutter run` from `example/`.

## Install

```yaml
dependencies:
  aurora_glass:
    git:
      url: https://github.com/zs-dima/aurora_glass.git
      ref: v0.1.0
```

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

[MIT](LICENSE)
