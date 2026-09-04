import 'dart:ui' show lerpDouble;

import 'package:aurora_glass/src/adaptive/window_size.dart';
import 'package:flutter/material.dart';

/// The measurements that change with the size of the window.
///
/// Everything that does not, such as the spacing and radius scales, hit targets and motion, is a
/// compile-time constant in `tokens.dart`. Registered in [ThemeData.extensions] and resolved per
/// [WindowClass] by `AppResponsiveTheme`, so values interpolate through [lerp] when the class
/// changes.
@immutable
final class AppDimens extends ThemeExtension<AppDimens> {
  static const AppDimens _compact = AppDimens(screenPadding: 24);

  /// Creates an [AppDimens].
  const AppDimens({required this.screenPadding, this.contentMaxWidth});

  /// The measurements for [windowClass]: the content column is capped at 600 dp from medium up.
  factory AppDimens.forClass(WindowClass windowClass) => windowClass.mapWithLowerFallback(
    compact: () => _compact,
    medium: () => const AppDimens(screenPadding: 24, contentMaxWidth: 600),
  );

  /// Side padding of a screen, in logical pixels.
  final double screenPadding;

  /// Maximum width of the content column, or null for unconstrained.
  ///
  /// Null rather than [double.infinity]: interpolating through infinity yields NaN, which reaches
  /// the render tree and throws. [lerp] snaps this field instead.
  final double? contentMaxWidth;

  @override
  int get hashCode => Object.hash(screenPadding, contentMaxWidth);

  /// The [AppDimens] of the closest [Theme] ancestor, or the compact defaults.
  static AppDimens of(BuildContext context) => Theme.of(context).extension<AppDimens>() ?? _compact;

  @override
  AppDimens copyWith({double? screenPadding, double? contentMaxWidth}) => .new(
    screenPadding: screenPadding ?? this.screenPadding,
    contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
  );

  @override
  AppDimens lerp(covariant AppDimens? other, double t) {
    if (other == null) return this;
    return AppDimens(
      screenPadding: lerpDouble(screenPadding, other.screenPadding, t)!,
      contentMaxWidth: t < 0.5 ? contentMaxWidth : other.contentMaxWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppDimens && screenPadding == other.screenPadding && contentMaxWidth == other.contentMaxWidth;

  @override
  String toString() => 'AppDimens(screenPadding: $screenPadding, contentMaxWidth: $contentMaxWidth)';
}
