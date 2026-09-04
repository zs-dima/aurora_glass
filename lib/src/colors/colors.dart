import 'package:aurora_glass/src/theme/tokens.g.dart';
import 'package:flutter/material.dart';

/// An Aurora Glass [ColorScheme].
///
/// Surfaces, the neutral ink ramp and the semantic tertiary/error families are the same in every
/// app on this kit and are filled in here. The nine accent-tinted roles are the app's own and are
/// passed in, so the whole scheme stays a compile-time constant:
///
/// ```dart
/// static const ColorScheme dark = AuroraScheme.dark(
///   primary: BrandTokens.pairStartDark,
///   ...
/// );
/// ```
///
/// [ColorScheme.==] compares `runtimeType`, so a scheme produced by [copyWith] is never equal to
/// the constant it came from even with identical values. Nothing in the kit copies a scheme.
final class AuroraScheme extends ColorScheme {
  /// The light scheme, derived from [AuroraScheme.dark] by the design's token map.
  ///
  /// The light accents are darkened at the design source so accent-as-text clears AA; a solid
  /// `primary` fill is therefore dark and takes white ink. The CTA gradient does not use this role.
  const AuroraScheme.light({
    required super.primary,
    required super.onPrimary,
    required super.primaryContainer,
    required super.onPrimaryContainer,
    required super.secondary,
    required super.onSecondary,
    required super.secondaryContainer,
    required super.onSecondaryContainer,
    required super.inversePrimary,
  }) : super(
         brightness: .light,
         tertiary: AppTokens.okTextLight,
         onTertiary: const Color(0xFFFFFFFF),
         tertiaryContainer: AppTokens.okFillLight,
         onTertiaryContainer: const Color(0xFF06231A),
         error: AppTokens.alertTextLight,
         onError: const Color(0xFFFFFFFF),
         errorContainer: AppTokens.alertFillLight,
         onErrorContainer: const Color(0xFF1E1206),
         surface: const Color(0xFFF8F4EE),
         onSurface: AppTokens.inkLight,
         onSurfaceVariant: AppTokens.secondaryLight,
         surfaceContainerLowest: const Color(0xFFFCF6EC),
         surfaceContainerLow: const Color(0xFFF9F1EC),
         surfaceContainer: const Color(0xFFFFFFFF),
         surfaceContainerHigh: const Color(0xFFFFFFFF),
         surfaceContainerHighest: const Color(0xFFFFFFFF),
         outline: AppTokens.mutedLight,
         outlineVariant: const Color(0x1A17122B),
         shadow: const Color(0x1417122B),
         scrim: const Color(0x5217122B),
         inverseSurface: const Color(0xFF17122B),
         onInverseSurface: const Color(0xFFF3F0FB),
       );

  /// The dark scheme, the design's source of truth.
  const AuroraScheme.dark({
    required super.primary,
    required super.onPrimary,
    required super.primaryContainer,
    required super.onPrimaryContainer,
    required super.secondary,
    required super.onSecondary,
    required super.secondaryContainer,
    required super.onSecondaryContainer,
    required super.inversePrimary,
  }) : super(
         brightness: .dark,
         tertiary: AppTokens.okDark,
         onTertiary: const Color(0xFF06231A),
         tertiaryContainer: AppTokens.okFillLight,
         onTertiaryContainer: const Color(0xFF06231A),
         error: AppTokens.alertDark,
         onError: const Color(0xFF2E0C06),
         errorContainer: AppTokens.alertFillLight,
         onErrorContainer: const Color(0xFF1E1206),
         surface: const Color(0xFF0B0817),
         onSurface: AppTokens.inkDark,
         onSurfaceVariant: AppTokens.secondaryDark,
         surfaceContainerLowest: const Color(0xFF080614),
         surfaceContainerLow: const Color(0xFF120A18),
         surfaceContainer: const Color(0xFF1A1226),
         surfaceContainerHigh: const Color(0xFF1F1730),
         surfaceContainerHighest: const Color(0xFF251C39),
         outline: AppTokens.mutedDark,
         outlineVariant: const Color(0x1FFFFFFF),
         shadow: const Color(0x8C000000),
         scrim: const Color(0x52000000),
         inverseSurface: const Color(0xFFF3F0FB),
         onInverseSurface: const Color(0xFF17122B),
       );
}
