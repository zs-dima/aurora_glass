import 'package:flutter/widgets.dart';

/// Composes an in-app text-scale setting with the platform's own text scaler.
///
/// The font size is multiplied by [factor] before the platform scaler sees it, which preserves a
/// non-linear platform curve (Android 14+), and [TextScaler.clamp] then bounds the result.
/// `TextScaler.linear(platform.scale(factor).clamp(…))` is wrong twice: [TextScaler.scale] takes
/// a font size, not a multiplier, and re-wrapping the result as linear discards the curve.
///
/// [operator ==] and [hashCode] matter: [MediaQueryData] compares its `textScaler`, and a scaler
/// without them notifies every dependent every frame.
@immutable
final class UserTextScaler extends TextScaler {
  /// Scales by [factor] on top of [platform].
  const UserTextScaler(this.platform, this.factor);

  /// The platform's own scaler, possibly non-linear.
  final TextScaler platform;

  // Abstract on TextScaler; delegated the way the SDK's own clamped scaler does.
  @override
  // ignore: deprecated_member_use, avoid-deprecated-usage
  double get textScaleFactor => platform.textScaleFactor * _factor;

  @override
  int get hashCode => Object.hash(platform, factor);

  /// The in-app setting. 1.0 leaves the platform scaler alone.
  ///
  /// A value that is not finite and positive is ignored; see [_factor].
  final double factor;

  /// [factor], or 1.0 when it cannot be honoured.
  ///
  /// The value is persisted, and corrupted storage must not crash the app: a negative, NaN or
  /// infinite factor would reach [TextScaler.scale] as a font size of the same shape.
  double get _factor => factor.isFinite && factor > 0 ? factor : 1.0;

  @override
  double scale(double fontSize) {
    assert(factor.isFinite && factor > 0, 'text scale factor must be finite and positive, got $factor');
    return platform.scale(fontSize * _factor);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserTextScaler && platform == other.platform && factor == other.factor;

  @override
  // ignore: avoid-default-tostring
  String toString() => '$platform x $factor';
}
