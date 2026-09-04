import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// WCAG 2.x contrast ratio: (L_lighter + 0.05) / (L_darker + 0.05).
double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// WCAG AA for normal text.
const _kAaNormalText = 4.5;

/// Ratchet: pairs known to fail. The test fails on new failures and on entries that start
/// passing. Empty; the muted tone (`outline`) never carries information and is not a text pair.
const _kKnownFailures = <String>{};

void main() {
  // Only the shared roles. The accent half of a scheme differs in every app, so its contrast is
  // each app's own test over its own palette; the fixture here only gets a scheme built.
  group('WCAG contrast of the shared roles (AA normal text, ratchet)', () {
    for (final brightness in Brightness.values) {
      test('${brightness.name} scheme foreground/background pairs', () {
        final scheme = TestPalette.instance.schemeOf(brightness);
        final name = brightness.name;
        final pairs = <String, (Color, Color)>{
          'tertiary/onTertiary': (scheme.tertiary, scheme.onTertiary),
          'tertiaryContainer/onTertiaryContainer': (scheme.tertiaryContainer, scheme.onTertiaryContainer),
          'error/onError': (scheme.error, scheme.onError),
          'errorContainer/onErrorContainer': (scheme.errorContainer, scheme.onErrorContainer),
          'surface/onSurface': (scheme.surface, scheme.onSurface),
          'surface/onSurfaceVariant': (scheme.surface, scheme.onSurfaceVariant),
          'inverseSurface/onInverseSurface': (scheme.inverseSurface, scheme.onInverseSurface),
        };

        final failures = <String>{
          for (final MapEntry(key: pair, value: (background, foreground)) in pairs.entries)
            if (_contrastRatio(background, foreground) < _kAaNormalText) '$name $pair',
        };

        final knownForBrightness = _kKnownFailures.where((entry) => entry.startsWith(name)).toSet();
        expect(
          failures,
          equals(knownForBrightness),
          reason:
              'New entries are a contrast regression; missing entries now pass, remove them from '
              '_kKnownFailures. Ratios: '
              '${pairs.entries.map((e) => '${e.key}=${_contrastRatio(e.value.$1, e.value.$2).toStringAsFixed(2)}').join(', ')}',
        );
      });
    }
  });
}
