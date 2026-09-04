import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

void main() {
  group('AppDimens', () {
    test('caps the content column from medium up', () {
      expect(AppDimens.forClass(.compact).contentMaxWidth, isNull);
      expect(AppDimens.forClass(.medium).contentMaxWidth, equals(600));
    });

    test('large and extra-large fall back to expanded', () {
      expect(AppDimens.forClass(.large), equals(AppDimens.forClass(.expanded)));
      expect(AppDimens.forClass(.extraLarge), equals(AppDimens.forClass(.expanded)));
    });

    // Interpolating through infinity gives NaN, which reaches the render tree and throws.
    test('lerp across the compact/medium boundary never yields NaN or infinity', () {
      final compact = AppDimens.forClass(.compact);
      final medium = AppDimens.forClass(.medium);
      const stops = <double>[0, 0.1, 0.25, 0.49, 0.5, 0.51, 0.75, 0.9, 1];

      for (final t in stops) {
        for (final pair in <List<AppDimens>>[
          <AppDimens>[compact, medium],
          <AppDimens>[medium, compact],
        ]) {
          final d = pair.first.lerp(pair.last, t);
          expect(d.screenPadding.isFinite, isTrue, reason: 'screenPadding at t=$t');
          final width = d.contentMaxWidth;
          expect(width == null || width.isFinite, isTrue, reason: 'contentMaxWidth at t=$t was $width');
        }
      }
    });

    test('carries only what the window changes', () {
      const dimens = AppDimens(screenPadding: 24, contentMaxWidth: 600);
      expect(dimens.toString(), equals('AppDimens(screenPadding: 24.0, contentMaxWidth: 600.0)'));
    });
  });

  group('AppTheme', () {
    test('resolve is memoized', () {
      final a = AppTheme.resolve(.dark, .compact, TestPalette.instance);
      // ignore: avoid-duplicate-initializers
      final b = AppTheme.resolve(.dark, .compact, TestPalette.instance);
      expect(identical(a, b), isTrue);
    });

    test('carries the palette it was handed, not the framework default', () {
      final dark = AppTheme.resolve(.dark, .compact, TestPalette.instance);
      final light = AppTheme.resolve(.light, .compact, TestPalette.instance);
      expect(dark.colorScheme.primary, equals(TestPalette.darkScheme.primary));
      expect(light.colorScheme.primary, equals(TestPalette.lightScheme.primary));
      expect(dark.colorScheme.primary, isNot(const Color(0xFF1565C0)));
      expect(light.colorScheme.primary, isNot(const Color(0xFF1565C0)));
    });

    test('a second palette builds a second theme, and the cache keeps them apart', () {
      const swapped = AppPalette(
        darkBrand: TestPalette.dark,
        lightBrand: TestPalette.light,
        darkScheme: TestPalette.lightScheme,
        lightScheme: TestPalette.darkScheme,
      );

      final mine = AppTheme.resolve(.dark, .compact, TestPalette.instance);
      final theirs = AppTheme.resolve(.dark, .compact, swapped);

      expect(theirs.colorScheme.primary, equals(TestPalette.lightScheme.primary));
      expect(identical(mine, theirs), isFalse);
    });

    test('registers Brand and AppDimens as extensions', () {
      final theme = AppTheme.resolve(.dark, .medium, TestPalette.instance);
      expect(theme.extension<Brand>(), equals(TestPalette.dark));
      expect(theme.extension<AppDimens>()?.contentMaxWidth, equals(600));
    });

    test('keeps the type ladder plain: no component tracking on labelSmall', () {
      final theme = AppTheme.resolve(.dark, .compact, TestPalette.instance);
      // Badge, ListTile, NavigationBar and both pickers read this role.
      expect(theme.textTheme.labelSmall?.letterSpacing, isNull);
      expect(theme.textTheme.bodySmall?.fontSize, equals(12.5));
    });

    test('never names a font family', () {
      final theme = AppTheme.resolve(.dark, .compact, TestPalette.instance);
      final styles = <TextStyle?>[
        theme.textTheme.displayLarge,
        theme.textTheme.headlineMedium,
        theme.textTheme.bodyMedium,
        theme.textTheme.labelSmall,
      ];
      for (final style in styles) {
        // `TextStyle(fontFamily: null, package: 'x')` interpolates to the literal 'packages/x/null'.
        expect(style?.fontFamily ?? '', isNot(startsWith('packages/')));
      }
    });
  });

  group('AppResponsiveTheme', () {
    Widget host({required Size size, required void Function(AppDimens dimens) onDimens}) => MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        theme: AppTheme.resolve(.light, .compact, TestPalette.instance),
        darkTheme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
        themeAnimationDuration: .zero,
        home: WindowSizeScope(
          child: AppResponsiveTheme(
            palette: TestPalette.instance,
            child: Builder(
              builder: (context) {
                onDimens(AppDimens.of(context));
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    testWidgets('resolves AppDimens for the current window class', (tester) async {
      late AppDimens dimens;
      await tester.pumpWidget(host(size: const Size(360, 800), onDimens: (d) => dimens = d));
      // ignore: prefer-moving-to-variable
      await tester.pumpAndSettle();
      expect(dimens.contentMaxWidth, isNull, reason: '360 is compact');

      await tester.pumpWidget(host(size: const Size(700, 800), onDimens: (d) => dimens = d));
      // ignore: prefer-moving-to-variable
      await tester.pumpAndSettle();
      expect(dimens.contentMaxWidth, equals(600), reason: '700 is medium');
    });

    testWidgets('crossing 600 animates without producing a non-finite width', (tester) async {
      final seen = <double?>[];
      await tester.pumpWidget(host(size: const Size(599, 800), onDimens: (d) => seen.add(d.contentMaxWidth)));
      await tester.pumpWidget(host(size: const Size(601, 800), onDimens: (d) => seen.add(d.contentMaxWidth)));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(seen, isNotEmpty);
      for (final width in seen) {
        expect(width == null || width.isFinite, isTrue, reason: 'saw $width mid-animation');
      }
      expect(tester.takeException(), isNull);
    });

    // MaterialApp's own AnimatedTheme is set to zero, so ours is the only one in the tree.
    testWidgets('a light/dark switch settles exactly on the target', (tester) async {
      late ThemeData seen;
      var frames = 0;

      Widget tree(ThemeMode mode) => MediaQuery(
        data: const MediaQueryData(size: Size(360, 800)),
        child: MaterialApp(
          theme: AppTheme.resolve(.light, .compact, TestPalette.instance),
          darkTheme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
          themeMode: mode,
          themeAnimationDuration: .zero,
          home: WindowSizeScope(
            child: AppResponsiveTheme(
              palette: TestPalette.instance,
              child: Builder(
                builder: (context) {
                  seen = Theme.of(context);
                  frames++;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(tree(.light));
      // ignore: prefer-moving-to-variable
      await tester.pumpAndSettle();
      expect(seen.colorScheme.primary, equals(TestPalette.lightScheme.primary));

      frames = 0;
      await tester.pumpWidget(tree(.dark));
      // ignore: prefer-moving-to-variable
      await tester.pumpAndSettle();

      expect(seen.colorScheme.primary, equals(TestPalette.darkScheme.primary));
      // A 200 ms transition at 60 fps.
      expect(frames, lessThan(40), reason: 'the theme transition rebuilt $frames times');
      expect(frames, greaterThan(1), reason: 'it did not animate at all');
    });

    // The probe instance is created once, so a rebuild can only come from an inherited notification.
    testWidgets('does not notify dependents while the class does not change', (tester) async {
      var builds = 0;
      final probe = Builder(
        builder: (context) {
          AppDimens.of(context);
          builds++;
          return const SizedBox.shrink();
        },
      );

      Widget tree(double width) => MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: MaterialApp(
          theme: AppTheme.resolve(.light, .compact, TestPalette.instance),
          themeAnimationDuration: .zero,
          home: WindowSizeScope(
            child: AppResponsiveTheme(palette: TestPalette.instance, child: probe),
          ),
        ),
      );

      await tester.pumpWidget(tree(360));
      // ignore: prefer-moving-to-variable
      await tester.pumpAndSettle();
      final afterFirst = builds;

      for (final width in <double>[380, 420, 500, 599]) {
        await tester.pumpWidget(tree(width));
        await tester.pump();
      }
      expect(builds, equals(afterFirst), reason: 'four resizes inside compact notified the dependent');

      await tester.pumpWidget(tree(700));
      // ignore: prefer-moving-to-variable
      await tester.pumpAndSettle();
      expect(builds, greaterThan(afterFirst), reason: 'crossing into medium must notify');
    });
  });
}
