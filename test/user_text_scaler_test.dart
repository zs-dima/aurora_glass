import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A non-linear platform scaler, the way Android 14+ behaves: small text grows more than large.
final class _NonLinearScaler extends TextScaler {
  const _NonLinearScaler();

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => 1.6;

  @override
  int get hashCode => 0;

  @override
  double scale(double fontSize) => fontSize <= 20 ? fontSize * 1.6 : fontSize * 1.1;

  @override
  bool operator ==(Object other) => other is _NonLinearScaler;
}

void main() {
  group('UserTextScaler', () {
    test('leaves the platform scaler alone at factor 1', () {
      const scaler = UserTextScaler(_NonLinearScaler(), 1);
      expect(scaler.scale(14), equals(const _NonLinearScaler().scale(14)));
      expect(scaler.scale(57), equals(const _NonLinearScaler().scale(57)));
    });

    test('does not flatten a non-linear platform curve', () {
      const scaler = UserTextScaler(_NonLinearScaler(), 1);
      final ratio = scaler.scale(57) / scaler.scale(14);
      expect(ratio, isNot(closeTo(57 / 14, 0.001)));
    });

    test('multiplies the font size, not the platform factor', () {
      const scaler = UserTextScaler(_NonLinearScaler(), 2);
      // 14 * 2 = 28 is past the curve's knee, so the large branch applies.
      expect(scaler.scale(14), closeTo(28 * 1.1, 0.0001));
    });

    test('clamp bounds the result and keeps the curve below the ceiling', () {
      const scaler = UserTextScaler(_NonLinearScaler(), 1);
      final clamped = scaler.clamp(minScaleFactor: 0.5, maxScaleFactor: 1.2);
      expect(clamped.scale(14), closeTo(14 * 1.2, 0.0001));
      expect(clamped.scale(57), closeTo(57 * 1.1, 0.0001));
    });

    test('a corrupt factor is refused in debug', () {
      expect(() => const UserTextScaler(.noScaling, -1).scale(14), throwsAssertionError);
      expect(() => const UserTextScaler(.noScaling, .nan).scale(14), throwsAssertionError);
    });

    test('a corrupt factor still produces a usable size in release', () {
      // `textScaleFactor` takes the same guard without the assert.
      // ignore: deprecated_member_use
      expect(const UserTextScaler(TextScaler.linear(2), -1).textScaleFactor, equals(2));
      // ignore: deprecated_member_use
      expect(const UserTextScaler(TextScaler.linear(2), .nan).textScaleFactor, equals(2));
    });

    test('equal scalers compare equal, so MediaQueryData does not churn', () {
      const a = UserTextScaler(_NonLinearScaler(), 1.25);
      const b = UserTextScaler(_NonLinearScaler(), 1.25);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(const MediaQueryData(textScaler: a), equals(const MediaQueryData(textScaler: b)));
      expect(a, isNot(const UserTextScaler(_NonLinearScaler(), 1.5)));
    });
  });
}
