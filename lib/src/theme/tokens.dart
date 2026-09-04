import 'package:flutter/material.dart';

/// The spacing scale: a 4 dp grid at ×2/3/4/6/8.
///
/// Compile-time constants, not adaptive: layout branches structure on a breakpoint, never
/// padding, and [ThemeData.visualDensity] already answers "roomier or tighter for this input".
abstract final class AppSpacing {
  /// Between a label and the thing it labels.
  static const double xs = 8;

  /// Between rows of a list.
  static const double sm = 12;

  /// Inside a card.
  static const double md = 16;

  /// Between sections.
  static const double lg = 24;

  /// Around a hero element.
  static const double xl = 32;
}

/// Corner radii, named for the surface they belong to rather than the value they hold.
///
/// Nested corners follow `inner = outer − padding`; nested elements never share a radius.
abstract final class AppRadius {
  /// The smallest rounded thing: a skeleton placeholder, a scrollbar thumb.
  static const Radius small = Radius.circular(16);

  /// A dense list row, an inline banner.
  static const Radius row = Radius.circular(18);

  /// A stat tile, a settings group.
  static const Radius tile = Radius.circular(20);

  /// The glass card, the main surface.
  static const Radius card = Radius.circular(24);
}

/// The corner treatments, ready for a decoration or a border.
///
/// Separate from [AppRadius] because [pill] is a [StadiumBorder], which has no radius.
abstract final class AppShape {
  /// A dense list row, an inline banner.
  static const BorderRadius row = BorderRadius.all(AppRadius.row);

  /// A stat tile, a settings group.
  static const BorderRadius tile = BorderRadius.all(AppRadius.tile);

  /// The glass card, the main surface.
  static const BorderRadius card = BorderRadius.all(AppRadius.card);

  /// Every pill-shaped control: the primary CTA, the ghost button, a chip.
  static const StadiumBorder pill = StadiumBorder();
}

/// Hit targets: at least 44 px visual, 48 dp Material tap area.
abstract final class AppTarget {
  /// The floor for anything interactive, and the iOS minimum.
  static const double visual = 44;

  /// The Material tap area, reached with `MaterialTapTargetSize.padded`.
  static const double tap = 48;

  /// A field used one-handed at arm's length.
  static const double field = 56;

  /// The primary CTA, Material Expressive size M.
  static const double primaryPill = 58;

  /// The secondary, outlined CTA.
  static const double ghostPill = 48;

  /// A bare text action.
  static const double textAction = 44;

  /// The widest a list row's trailing slot may grow; a value wraps beyond this.
  ///
  /// A constant rather than a share of the row: a share needs the row's width and a second layout
  /// pass per row.
  static const double trailingMax = 160;
}

/// Motion. Flutter has no Material Expressive springs yet; these are the documented fallbacks.
///
/// Reduce Motion stops ambient animation and scale, leaving a 150 ms crossfade; see
/// [ambientEnabled].
abstract final class AppMotion {
  /// A press: scale to [pressScale] and back.
  static const Duration press = Duration(milliseconds: 120);

  /// A state layer, a colour change.
  static const Duration fast = Duration(milliseconds: 200);

  /// A card, a sheet, a list reveal.
  static const Duration standard = Duration(milliseconds: 300);

  /// A full-screen transition.
  static const Duration slow = Duration(milliseconds: 450);

  /// All that survives Reduce Motion.
  static const Duration reducedCrossfade = Duration(milliseconds: 150);

  /// The brand curve; it overshoots, unlike `Easing.emphasizedDecelerate`.
  static const Curve standardCurve = Curves.easeOutBack;

  /// How far a pressed control shrinks.
  static const double pressScale = 0.97;

  /// False when the platform asks for reduced motion; ambient loops must not run then.
  static bool ambientEnabled(BuildContext context) => !MediaQuery.disableAnimationsOf(context);
}

/// Geometry of the two radial glows the chassis paints behind every screen.
///
/// Exactly two per screen. The colours are per app and live in `Brand`; only the geometry is
/// shared.
abstract final class AppGlow {
  /// Diameter of the upper-trailing glow.
  static const double primarySize = 430;

  /// Distance the upper glow hangs above the top edge.
  static const double primaryTop = -150;

  /// Distance the upper glow hangs past the trailing edge.
  static const double primaryTrailing = -110;

  /// Diameter of the lower-leading glow.
  static const double secondarySize = 400;

  /// Distance the lower glow hangs below the bottom edge.
  static const double secondaryBottom = -170;

  /// Distance the lower glow hangs past the leading edge.
  static const double secondaryLeading = -130;

  /// Where the radial fade reaches zero.
  static const double fadeStop = 0.7;
}
