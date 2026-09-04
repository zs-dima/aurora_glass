// GENERATED FILE - DO NOT EDIT BY HAND.
//
// Source: the design workspace's tokens/colors.json, written by
// `python make_light.py --emit-tokens`. Regenerate with
// `dart run aurora_glass:gen_tokens`.
//
// dark is the source of truth; light is derived from it by these maps
//
// Shared values only. An app's accent axis, chassis base and inner fills are
// generated into the app by `dart run aurora_glass:gen_brand`.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/painting.dart' show Color;

/// Colour values generated from the design workspace.
///
/// Read these through [AuroraScheme] rather than directly.
abstract final class AppTokens {
  // --- Neutral text ramp ---

  /// `#F3F0FB` on dark.
  static const Color inkDark = Color(0xFFF3F0FB);

  /// `#17122B` on light.
  static const Color inkLight = Color(0xFF17122B);

  /// `#E6E1F5` on dark.
  static const Color inkStrongDark = Color(0xFFE6E1F5);

  /// `#2A2440` on light.
  static const Color inkStrongLight = Color(0xFF2A2440);

  /// `#CFC8E6` on dark.
  static const Color inkSoftDark = Color(0xFFCFC8E6);

  /// `#3A3552` on light.
  static const Color inkSoftLight = Color(0xFF3A3552);

  /// `#A79FC2` on dark.
  static const Color secondaryDark = Color(0xFFA79FC2);

  /// `#5D5776` on light.
  static const Color secondaryLight = Color(0xFF5D5776);

  /// `#9A93B8` on dark.
  static const Color deEmphasisDark = Color(0xFF9A93B8);

  /// `#6D6786` on light.
  static const Color deEmphasisLight = Color(0xFF6D6786);

  /// `#6E678A` on dark.
  static const Color mutedDark = Color(0xFF6E678A);

  /// `#8A84A0` on light.
  static const Color mutedLight = Color(0xFF8A84A0);

  // --- Semantic colours ---
  //
  // Text and fill darken differently: a fill sits behind white ink, so it stays
  // brighter than the same colour used as text.

  /// `ok` as ink or stroke, on dark.
  static const Color okDark = Color(0xFF3EE6B0);

  /// `ok` as ink or stroke, on light.
  static const Color okTextLight = Color(0xFF0C7A59);

  /// `ok` as a fill, on light.
  static const Color okFillLight = Color(0xFF14A87A);

  /// `alert` as ink or stroke, on dark.
  static const Color alertDark = Color(0xFFFF8E7A);

  /// `alert` as ink or stroke, on light.
  static const Color alertTextLight = Color(0xFFB23F27);

  /// `alert` as a fill, on light.
  static const Color alertFillLight = Color(0xFFE8654C);

  // --- Chassis geometry; the colours of the stops are per app ---

  /// Stop positions of the 165° base gradient, as fractions.
  static const List<double> baseGradientStops = <double>[0.0, 0.46, 1.0];
}
