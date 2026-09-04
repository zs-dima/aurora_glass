import 'package:aurora_glass/src/theme/brand.dart';
import 'package:flutter/material.dart';

/// Everything one app contributes to an Aurora Glass theme: its [Brand] and its [ColorScheme],
/// in both brightnesses.
///
/// The one parameter [AppTheme.resolve] takes. Declare it `static const`: the theme cache is keyed
/// by palette identity, and a palette built on every build would be a new key every time.
///
/// The kit ships no palette. An app generates its raw values with `dart run aurora_glass:gen_brand`
/// and composes them here; the gallery's `example/lib/gallery_palette.dart` shows the whole shape.
@immutable
final class AppPalette {
  /// Creates an [AppPalette].
  const AppPalette({
    required this.darkBrand,
    required this.lightBrand,
    required this.darkScheme,
    required this.lightScheme,
  });

  /// The brand axis on dark, the design's source of truth.
  final Brand darkBrand;

  /// The brand axis on light, derived from [darkBrand] by the design's token map.
  final Brand lightBrand;

  /// The dark [ColorScheme], normally an [AuroraScheme.dark].
  final ColorScheme darkScheme;

  /// The light [ColorScheme], normally an [AuroraScheme.light].
  final ColorScheme lightScheme;

  @override
  int get hashCode => Object.hash(darkBrand, lightBrand, darkScheme, lightScheme);

  /// The [Brand] for [brightness].
  Brand brandOf(Brightness brightness) => brightness == .dark ? darkBrand : lightBrand;

  /// The [ColorScheme] for [brightness].
  ColorScheme schemeOf(Brightness brightness) => brightness == .dark ? darkScheme : lightScheme;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppPalette &&
          darkBrand == other.darkBrand &&
          lightBrand == other.lightBrand &&
          darkScheme == other.darkScheme &&
          lightScheme == other.lightScheme;
}
