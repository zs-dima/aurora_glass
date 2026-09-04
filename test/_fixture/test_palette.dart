// A shared fixture, imported by the suites; its declarations are meant to be visible.
// ignore_for_file: avoid-top-level-members-in-tests
import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';

/// A palette for the kit's own tests.
///
/// A synthetic teal/violet axis that belongs to no app, so it cannot be mistaken for a default.
/// The values only need to be distinguishable: every assertion over this palette is about plumbing,
/// never about a colour being the right colour.
abstract final class TestPalette {
  /// The fixture palette.
  static const AppPalette instance = AppPalette(
    darkBrand: dark,
    lightBrand: light,
    darkScheme: darkScheme,
    lightScheme: lightScheme,
  );

  /// The fixture brand on dark.
  static const Brand dark = Brand(
    pairStart: Color(0xFF2ED3C6),
    pairEnd: Color(0xFF8A7BFF),
    inkOnGradient: Color(0xFF07201E),
    baseStops: <Color>[Color(0xFF07201E), Color(0xFF0B1020), Color(0xFF120A18)],
    accentText: Color(0xFF2ED3C6),
    accentTextHover: Color(0xFF7FE8DF),
    displayGradient: <Color>[Color(0xFF2ED3C6), Color(0xFF8A7BFF)],
    glowPrimary: Color(0x2E2ED3C6),
    glowSecondary: Color(0x1A8A7BFF),
    cardFill: Color(0x0EFFFFFF),
    cardBorder: Color(0x1FFFFFFF),
    gradientCardInner: Color(0xEB121A22),
    scaffoldBase: Color(0xFF060B12),
  );

  /// The fixture brand on light. Every field differs from [dark].
  static const Brand light = Brand(
    pairStart: Color(0xFF2ED3C6),
    pairEnd: Color(0xFF8A7BFF),
    inkOnGradient: Color(0xFF07201E),
    baseStops: <Color>[Color(0xFFF2FBFA), Color(0xFFF6F5FF), Color(0xFFFAF7FF)],
    accentText: Color(0xFF0E6F68),
    accentTextHover: Color(0xFF0A544F),
    displayGradient: <Color>[Color(0xFF0E6F68), Color(0xFF4B3BC4)],
    glowPrimary: Color(0x292ED3C6),
    glowSecondary: Color(0x1A8A7BFF),
    cardFill: Color(0xFFFFFFFF),
    cardBorder: Color(0x1A17122B),
    gradientCardInner: Color(0xF7FCFEFE),
    scaffoldBase: Color(0xFFF4F8F8),
  );

  /// The fixture scheme on dark.
  static const ColorScheme darkScheme = AuroraScheme.dark(
    primary: Color(0xFF2ED3C6),
    onPrimary: Color(0xFF07201E),
    primaryContainer: Color(0xFF1B3A38),
    onPrimaryContainer: Color(0xFF7FE8DF),
    secondary: Color(0xFF8A7BFF),
    onSecondary: Color(0xFF0E0A24),
    secondaryContainer: Color(0xFF272044),
    onSecondaryContainer: Color(0xFFF3F0FB),
    inversePrimary: Color(0xFF0E6F68),
  );

  /// The fixture scheme on light.
  static const ColorScheme lightScheme = AuroraScheme.light(
    primary: Color(0xFF0E6F68),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDDF4F2),
    onPrimaryContainer: Color(0xFF07201E),
    secondary: Color(0xFF4B3BC4),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE6E2FF),
    onSecondaryContainer: Color(0xFF0E0A24),
    inversePrimary: Color(0xFF2ED3C6),
  );
}
