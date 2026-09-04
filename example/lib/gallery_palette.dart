import 'package:aurora_glass/aurora_glass.dart';
import 'package:example/gallery_tokens.g.dart';
import 'package:flutter/material.dart';

/// The gallery's palette, composed the way every app on this kit composes one.
///
/// [BrandTokens] is generated from the design workspace by `aurora_glass:gen_brand`; the glows,
/// the glass fill and border, and the container fills are hand-written because the design's
/// machine-readable contract does not carry them.
abstract final class GalleryPalette {
  /// The gallery palette.
  static const AppPalette instance = AppPalette(
    darkBrand: _dark,
    lightBrand: _light,
    darkScheme: _darkScheme,
    lightScheme: _lightScheme,
  );

  static const Brand _dark = Brand(
    pairStart: BrandTokens.pairStartDark,
    pairEnd: BrandTokens.pairEndDark,
    inkOnGradient: Color(0xFF1E1206),
    baseStops: BrandTokens.baseStopsDark,
    accentText: BrandTokens.pairStartDark,
    accentTextHover: BrandTokens.accentHoverDark,
    displayGradient: <Color>[BrandTokens.pairStartDark, BrandTokens.pairEndDark],
    glowPrimary: Color(0x2EFFC163),
    glowSecondary: Color(0x1AFF8E6E),
    cardFill: Color(0x0EFFFFFF),
    cardBorder: Color(0x1FFFFFFF),
    gradientCardInner: BrandTokens.gradientCardInnerDark,
    scaffoldBase: BrandTokens.scaffoldBaseDark,
  );

  // The CTA gradient is identical in both themes; only gradient-clipped text darkens on light.
  static const Brand _light = Brand(
    pairStart: BrandTokens.pairStartDark,
    pairEnd: BrandTokens.pairEndDark,
    inkOnGradient: Color(0xFF1E1206),
    baseStops: BrandTokens.baseStopsLight,
    accentText: BrandTokens.pairStartLight,
    accentTextHover: BrandTokens.accentHoverLight,
    displayGradient: <Color>[BrandTokens.pairStartLight, BrandTokens.pairEndLight],
    glowPrimary: Color(0x29FFC163),
    glowSecondary: Color(0x1AFF8E6E),
    cardFill: Color(0xFFFFFFFF),
    cardBorder: Color(0x1A17122B),
    gradientCardInner: BrandTokens.gradientCardInnerLight,
    scaffoldBase: BrandTokens.scaffoldBaseLight,
  );

  static const ColorScheme _darkScheme = AuroraScheme.dark(
    primary: BrandTokens.pairStartDark,
    onPrimary: Color(0xFF1E1206),
    // 18% amber over the dark surface.
    primaryContainer: Color(0xFF372925),
    onPrimaryContainer: BrandTokens.accentHoverDark,
    secondary: BrandTokens.pairEndDark,
    onSecondary: Color(0xFF1E1206),
    secondaryContainer: Color(0xFF372027),
    onSecondaryContainer: AppTokens.inkDark,
    inversePrimary: BrandTokens.pairStartLight,
  );

  static const ColorScheme _lightScheme = AuroraScheme.light(
    primary: BrandTokens.pairStartLight,
    onPrimary: Color(0xFFFFFFFF),
    // 18% amber over white; a scheme role must be opaque.
    primaryContainer: Color(0xFFFFF4E3),
    onPrimaryContainer: Color(0xFF1E1206),
    secondary: BrandTokens.pairEndLight,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFEBE5),
    onSecondaryContainer: Color(0xFF1E1206),
    inversePrimary: BrandTokens.pairStartDark,
  );
}
