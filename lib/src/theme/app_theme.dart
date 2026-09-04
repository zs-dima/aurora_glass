import 'package:aurora_glass/src/adaptive/window_size.dart';
import 'package:aurora_glass/src/fonts/typography.dart';
import 'package:aurora_glass/src/theme/app_palette.dart';
import 'package:aurora_glass/src/theme/brand.dart';
import 'package:aurora_glass/src/theme/dimensions.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The [ThemeData] of an app: one per brightness, resolved for a [WindowClass] and an [AppPalette].
///
/// [resolve] is memoized on all three, so at most ten objects exist per palette and `Theme` keeps
/// its identity check. The window class is passed in rather than read from a [BuildContext]: the
/// root theme handed to `MaterialApp` stays one stable object, and `AppResponsiveTheme` swaps
/// between the memoized variants inside `MaterialApp.builder`.
abstract final class AppTheme {
  static final Map<(Brightness, WindowClass, AppPalette), ThemeData> _cache =
      <(Brightness, WindowClass, AppPalette), ThemeData>{};

  /// The theme for [brightness], [windowClass] and [palette]. Cached; call it on every build.
  ///
  /// Declare the palette `static const`: the cache is keyed by its identity. The cache survives
  /// hot reload, so hot restart after editing a token.
  static ThemeData resolve(Brightness brightness, WindowClass windowClass, AppPalette palette) =>
      _cache[(brightness, windowClass, palette)] ??= _build(brightness, windowClass, palette);

  static ThemeData _build(Brightness brightness, WindowClass windowClass, AppPalette palette) {
    final scheme = palette.schemeOf(brightness);
    final brand = palette.brandOf(brightness);
    final dimens = AppDimens.forClass(windowClass);

    return ThemeData(
      colorScheme: scheme,
      // No font family: the platform's system font, which covers Cyrillic.
      scaffoldBackgroundColor: brand.scaffoldBase,
      extensions: <ThemeExtension<Object?>>[brand, dimens],
      splashFactory: InkSparkle.splashFactory,
      // Standard density on every platform: compact density breaks the 44 px visual target.
      visualDensity: .standard,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: brand.cardFill,
        surfaceTintColor: Colors.transparent,
        shadowColor: scheme.shadow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppShape.card,
          side: BorderSide(color: brand.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll<Color>(scheme.outline),
        radius: AppRadius.small,
      ),
      inputDecorationTheme: _inputDecorationTheme(scheme, brand),
      // 44 px visual, 48 dp tap area.
      materialTapTargetSize: .padded,
      textTheme: AppTypography.textTheme(scheme),
    );
  }

  /// The one input decoration.
  ///
  /// [WidgetStateInputBorder] only: the state-named `focusedBorder` family takes precedence over
  /// it, so mixing the two produces a decoration that does not match its source.
  static InputDecorationTheme _inputDecorationTheme(ColorScheme scheme, Brand brand) {
    InputBorder border(Color color, {double width = 1}) => OutlineInputBorder(
      borderRadius: AppShape.row,
      borderSide: BorderSide(color: color, width: width, strokeAlign: BorderSide.strokeAlignInside),
    );

    return InputDecorationTheme(
      isCollapsed: false,
      isDense: false,
      filled: true,
      fillColor: brand.cardFill,
      floatingLabelAlignment: .start,
      floatingLabelBehavior: .always,
      contentPadding: const .symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      border: WidgetStateInputBorder.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return border(scheme.outlineVariant);
        if (states.contains(WidgetState.error)) return border(scheme.error, width: 2);
        if (states.contains(WidgetState.focused)) return border(brand.accentText, width: 2);
        if (states.contains(WidgetState.hovered)) return border(scheme.outline);
        return border(brand.cardBorder);
      }),
      labelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.error)
              ? scheme.error
              : states.contains(WidgetState.focused)
              ? brand.accentText
              : scheme.onSurfaceVariant,
        ),
      ),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
    );
  }
}
