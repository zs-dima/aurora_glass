import 'dart:io';

import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// The seam between the design workspace and this repository.
///
/// `tokens.g.dart` is generated and committed, so CI and a fresh clone build without the design
/// workspace. The drift checks run only when the workspace is reachable and skip otherwise.
///
/// Nothing here is about an app's accent axis: that is generated into the app and tested there.
void main() {
  group('generated colour tokens', () {
    test('scheme roles the design contract defines read from the generated tokens', () {
      final light = TestPalette.instance.schemeOf(.light);
      final dark = TestPalette.instance.schemeOf(.dark);

      expect(light.onSurface, equals(AppTokens.inkLight));
      expect(dark.onSurface, equals(AppTokens.inkDark));
      expect(light.onSurfaceVariant, equals(AppTokens.secondaryLight));
      expect(dark.onSurfaceVariant, equals(AppTokens.secondaryDark));
      expect(light.outline, equals(AppTokens.mutedLight));
      expect(dark.outline, equals(AppTokens.mutedDark));
    });

    test('the semantic families read from the generated tokens', () {
      final light = TestPalette.instance.schemeOf(.light);
      final dark = TestPalette.instance.schemeOf(.dark);

      expect(light.tertiary, equals(AppTokens.okTextLight));
      expect(dark.tertiary, equals(AppTokens.okDark));
      expect(light.error, equals(AppTokens.alertTextLight));
      expect(dark.error, equals(AppTokens.alertDark));
      // Text and fill darken differently and must not be bound to each other.
      expect(light.errorContainer, equals(AppTokens.alertFillLight));
      expect(light.error, isNot(equals(light.errorContainer)));
    });

    test('the base gradient carries a stop position per colour', () {
      expect(AppTokens.baseGradientStops, hasLength(TestPalette.dark.baseStops.length));
      expect(AppTokens.baseGradientStops.first, equals(0.0));
      expect(AppTokens.baseGradientStops.last, equals(1.0));
    });
  });

  group('design workspace drift', () {
    const designFromPackage = '../../../app/design/tokens';
    const designFromExample = '../../../../app/design/tokens';

    /// Runs a generator in `--check` mode, or skips when the design workspace is out of reach.
    Future<void> expectUpToDate(
      String executable,
      String designRoot, {
      String workingDirectory = '.',
      List<String> extra = const <String>[],
    }) async {
      final design = Directory('$workingDirectory/$designRoot');
      if (!design.existsSync()) {
        markTestSkipped('design workspace not reachable at ${design.path}; the generated files are committed');
        return;
      }
      final result = await Process.run(
        'dart',
        <String>['run', executable, '--check', '--design-root', designRoot, ...extra],
        workingDirectory: workingDirectory,
        runInShell: true,
      );
      expect(
        result.exitCode,
        equals(0),
        reason: 'the generated file is stale. Regenerate it and commit.\n${result.stdout}${result.stderr}',
      );
    }

    // The assertion is inside `expectUpToDate`.
    // ignore: missing-test-assertion
    test(
      'the committed tokens.g.dart is up to date with the design workspace',
      () async {
        await expectUpToDate('bin/gen_tokens.dart', designFromPackage);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    // The gallery generates its own palette from the same source, and this is the only place
    // `gen_brand` runs inside the repository.
    // ignore: missing-test-assertion
    test(
      'the gallery palette is up to date with the design workspace',
      () async {
        await expectUpToDate(
          'aurora_glass:gen_brand',
          designFromExample,
          workingDirectory: 'example',
          extra: const <String>['--app-json', 'tool/gallery.json', '--out', 'lib/gallery_tokens.g.dart'],
        );
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
