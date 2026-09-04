// GENERATED FILE - DO NOT EDIT BY HAND.
//
// Source: the design workspace's tokens/colors.json, written by
// `python make_light.py --emit-tokens`. Regenerate with
// `dart run aurora_glass:gen_brand`.
//
// dark is the source of truth; light is derived from it by these maps
//
// Aurora Glass Gallery's own half of the palette. The shared half is `AppTokens` in
// `package:aurora_glass`.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/painting.dart' show Color;

/// Aurora Glass Gallery colour values, generated from the design workspace.
///
/// Read these through the app's `Brand` and `AuroraScheme`.
abstract final class BrandTokens {
  // --- Aurora Glass Gallery accent axis ---

  /// `#FFC163` on dark.
  static const Color pairStartDark = Color(0xFFFFC163);

  /// `#96610F` on light, derived from pairStartDark by the token map.
  static const Color pairStartLight = Color(0xFF96610F);

  /// `#FFD79A` on dark.
  static const Color accentHoverDark = Color(0xFFFFD79A);

  /// `#8A570C` on light, derived from accentHoverDark by the token map.
  static const Color accentHoverLight = Color(0xFF8A570C);

  /// `#FF8E6E` on dark.
  static const Color pairEndDark = Color(0xFFFF8E6E);

  /// `#B04A2B` on light, derived from pairEndDark by the token map.
  static const Color pairEndLight = Color(0xFFB04A2B);

  /// `#F0CFA0` on dark.
  static const Color sandTintDark = Color(0xFFF0CFA0);

  /// `#8A6320` on light, derived from sandTintDark by the token map.
  static const Color sandTintLight = Color(0xFF8A6320);

  // --- Screen chassis ---

  /// The three stops of the 165° base gradient, in order.
  static const List<Color> baseStopsDark = <Color>[Color(0xFF1A1226), Color(0xFF0B0817), Color(0xFF120A18)];

  /// The same three stops after the dark-to-light substitution.
  static const List<Color> baseStopsLight = <Color>[Color(0xFFFCF6EC), Color(0xFFF8F4EE), Color(0xFFF9F1EC)];

  /// Flat base behind the gradient; also the splash background.
  static const Color scaffoldBaseDark = Color(0xFF080614);

  /// The same flat base on light.
  static const Color scaffoldBaseLight = Color(0xFFF8F4EE);

  /// `rgba(26,18,32,0.92)` on dark.
  static const Color gradientCardInnerDark = Color(0xEB1A1220);

  /// `rgba(255,252,246,0.97)` on light.
  static const Color gradientCardInnerLight = Color(0xF7FFFCF6);

  /// `rgba(30,20,14,0.6)` on dark.
  static const Color selectedTileInnerDark = Color(0x991E140E);

  /// `rgba(255,251,244,0.96)` on light.
  static const Color selectedTileInnerLight = Color(0xF5FFFBF4);
}
