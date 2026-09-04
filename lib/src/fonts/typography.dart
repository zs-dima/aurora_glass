import 'package:flutter/material.dart';

/// Readouts (counts, timers, "12/24") must not jitter as digits change.
const kTabularFigures = <FontFeature>[FontFeature.tabularFigures()];

/// The type ladder.
///
/// System font only: `fontFamily` is left unset so Flutter resolves the platform default. Never
/// pass `package:` here either; `TextStyle(fontFamily: null, package: 'x')` produces the literal
/// family name `packages/x/null`.
///
/// The roles stay a plain Material 3 ladder with no component-specific tracking and no baked
/// colours: `labelSmall` alone is read by `Badge`, `ListTile`, `NavigationBar` and both pickers,
/// so a component that needs a bespoke style derives it in its own build.
abstract final class AppTypography {
  /// The [TextTheme] for [scheme].
  static TextTheme textTheme(ColorScheme scheme) => const .new(
    displayLarge: TextStyle(fontSize: 57, fontWeight: .w700, height: 1, fontFeatures: kTabularFigures),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: .w700,
      height: 1,
      fontFeatures: kTabularFigures,
    ),
    displaySmall: TextStyle(fontSize: 36, fontWeight: .w700, height: 1, fontFeatures: kTabularFigures),
    headlineLarge: TextStyle(fontSize: 31, fontWeight: .w800, height: 1.12, letterSpacing: -0.62),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: .w800, height: 1.12, letterSpacing: -0.56),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: .w800, height: 1.16),
    titleLarge: TextStyle(fontSize: 20, fontWeight: .w700),
    titleMedium: TextStyle(fontSize: 16, fontWeight: .w700),
    titleSmall: TextStyle(fontSize: 14, fontWeight: .w700),
    bodyLarge: TextStyle(fontSize: 15, fontWeight: .w400, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: .w400, height: 1.5),
    // 12.5 px is the floor for anything essential.
    bodySmall: TextStyle(fontSize: 12.5, height: 1.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: .w700),
    labelMedium: TextStyle(fontSize: 13, fontWeight: .w500, fontFeatures: kTabularFigures),
    labelSmall: TextStyle(fontSize: 12, fontWeight: .w500),
  ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
}
