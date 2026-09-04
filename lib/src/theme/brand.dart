import 'package:aurora_glass/src/theme/tokens.g.dart';
import 'package:flutter/material.dart';

/// The per-app axis of the Aurora Glass design system: gradients, glows and glass surfaces.
///
/// The neutral and semantic scales live in the [ColorScheme] and are shared by every app on the
/// kit; everything here is one app's own. There is no default. An app generates its raw values
/// with `dart run aurora_glass:gen_brand`, composes a [Brand] per brightness, and hands them to
/// [AppTheme.resolve] inside an [AppPalette].
///
/// Five fields are hand-written in the app rather than generated: the two glows, the glass fill
/// and border, and [inkOnGradient] exist only in the artboards' CSS, not in the token contract.
@immutable
final class Brand extends ThemeExtension<Brand> {
  /// Creates a [Brand].
  const Brand({
    required this.pairStart,
    required this.pairEnd,
    required this.inkOnGradient,
    required this.baseStops,
    required this.accentText,
    required this.accentTextHover,
    required this.displayGradient,
    required this.glowPrimary,
    required this.glowSecondary,
    required this.cardFill,
    required this.cardBorder,
    required this.gradientCardInner,
    required this.scaffoldBase,
  });

  /// Start of the CTA gradient. Identical in both themes.
  final Color pairStart;

  /// End of the CTA gradient. Identical in both themes.
  final Color pairEnd;

  /// Label colour on top of a [cta] gradient. Identical in both themes.
  final Color inkOnGradient;

  /// The three stops of the 165° base gradient, in order.
  final List<Color> baseStops;

  /// The accent used as text, icon or stroke, never as a CTA fill.
  final Color accentText;

  /// Hover and pressed variant of [accentText].
  final Color accentTextHover;

  /// Gradient for text clipped to a gradient. Darkened on light.
  final List<Color> displayGradient;

  /// Upper ambient glow. Reduce Motion stops the animation, not the glow.
  final Color glowPrimary;

  /// Lower ambient glow.
  final Color glowSecondary;

  /// Glass card fill.
  final Color cardFill;

  /// Glass card hairline border.
  final Color cardBorder;

  /// Inner fill of a gradient-border card, the selected or hero treatment.
  final Color gradientCardInner;

  /// Flat base behind the gradient; also the splash background.
  final Color scaffoldBase;

  /// The CTA gradient. Identical in both themes.
  ///
  /// A getter, not a cached field: caching would cost `const Brand` and build three gradients per
  /// interpolated frame during a theme transition, to save an allocation that costs nothing.
  LinearGradient get cta => .new(colors: <Color>[pairStart, pairEnd]);

  /// The 165° base gradient of every screen; `AppScaffold` paints it.
  LinearGradient get base => .new(
    colors: baseStops,
    stops: AppTokens.baseGradientStops,
    // 165° clockwise from "up" in CSS, in Flutter's coordinate space.
    begin: const Alignment(-0.26, -1),
    end: const Alignment(0.26, 1),
  );

  /// Text clipped to [displayGradient].
  LinearGradient get display => .new(colors: displayGradient);

  @override
  Brand copyWith({
    Color? pairStart,
    Color? pairEnd,
    Color? inkOnGradient,
    List<Color>? baseStops,
    Color? accentText,
    Color? accentTextHover,
    List<Color>? displayGradient,
    Color? glowPrimary,
    Color? glowSecondary,
    Color? cardFill,
    Color? cardBorder,
    Color? gradientCardInner,
    Color? scaffoldBase,
  }) => .new(
    pairStart: pairStart ?? this.pairStart,
    pairEnd: pairEnd ?? this.pairEnd,
    inkOnGradient: inkOnGradient ?? this.inkOnGradient,
    baseStops: baseStops ?? this.baseStops,
    accentText: accentText ?? this.accentText,
    accentTextHover: accentTextHover ?? this.accentTextHover,
    displayGradient: displayGradient ?? this.displayGradient,
    glowPrimary: glowPrimary ?? this.glowPrimary,
    glowSecondary: glowSecondary ?? this.glowSecondary,
    cardFill: cardFill ?? this.cardFill,
    cardBorder: cardBorder ?? this.cardBorder,
    gradientCardInner: gradientCardInner ?? this.gradientCardInner,
    scaffoldBase: scaffoldBase ?? this.scaffoldBase,
  );

  @override
  Brand lerp(covariant Brand? other, double t) {
    if (other == null) return this;
    return Brand(
      pairStart: Color.lerp(pairStart, other.pairStart, t)!,
      pairEnd: Color.lerp(pairEnd, other.pairEnd, t)!,
      inkOnGradient: Color.lerp(inkOnGradient, other.inkOnGradient, t)!,
      baseStops: _lerpStops(baseStops, other.baseStops, t),
      accentText: Color.lerp(accentText, other.accentText, t)!,
      accentTextHover: Color.lerp(accentTextHover, other.accentTextHover, t)!,
      displayGradient: _lerpStops(displayGradient, other.displayGradient, t),
      glowPrimary: Color.lerp(glowPrimary, other.glowPrimary, t)!,
      glowSecondary: Color.lerp(glowSecondary, other.glowSecondary, t)!,
      cardFill: Color.lerp(cardFill, other.cardFill, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      gradientCardInner: Color.lerp(gradientCardInner, other.gradientCardInner, t)!,
      scaffoldBase: Color.lerp(scaffoldBase, other.scaffoldBase, t)!,
    );
  }

  /// The [Brand] of the closest [Theme] ancestor.
  ///
  /// Throws when the theme carries none: [AppTheme.resolve] installs it, and a fallback palette
  /// would render a missing one in the wrong colours instead of failing.
  static Brand of(BuildContext context) {
    final brand = Theme.of(context).extension<Brand>();
    if (brand != null) return brand;
    throw FlutterError(
      'No Brand found in the theme. '
      'Build the ThemeData with AppTheme.resolve(brightness, windowClass, palette), which installs it.',
    );
  }

  /// Interpolates two stop lists; lists of different length snap, as [ThemeData.lerp] does.
  static List<Color> _lerpStops(List<Color> a, List<Color> b, double t) {
    if (a.length != b.length) return t < 0.5 ? a : b;
    return <Color>[for (final (i, color) in a.indexed) Color.lerp(color, b[i], t)!];
  }
}
