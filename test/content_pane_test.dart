// Several tests re-read the same expression after a re-pump, or assert the same thing for the
// box and the sliver form; that repetition is the property under test.
// ignore_for_file: use-existing-variable, avoid-duplicate-test-assertions
import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// A child that remembers whether it was ever re-created.
class _Probe extends StatefulWidget {
  const _Probe({super.key});

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  static int _instances = 0;

  // ignore: prefer-widget-private-members
  late final int id = ++_instances;

  @override
  Widget build(BuildContext context) => const SizedBox(height: 40);
}

void main() {
  /// Mounts [child] at [size], with [padding] as the system inset.
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(360, 800),
    EdgeInsets padding = .zero,
  }) async {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size, padding: padding),
        child: MaterialApp(
          theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
          themeAnimationDuration: .zero,
          home: WindowSizeScope(
            child: AppResponsiveTheme(palette: TestPalette.instance, child: child),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the content column', () {
    testWidgets('is 312 wide at 360 and 552 from 600 up', (tester) async {
      const key = Key('content');

      await pump(tester, const ContentPane(child: SizedBox.expand(key: key)));
      expect(tester.getSize(find.byKey(key)).width, equals(312));

      await pump(
        tester,
        const ContentPane(child: SizedBox.expand(key: key)),
        size: const Size(1000, 800),
      );
      expect(tester.getSize(find.byKey(key)).width, equals(552));

      await pump(
        tester,
        const ContentPane(child: SizedBox.expand(key: key)),
        size: const Size(700, 800),
      );
      expect(tester.getSize(find.byKey(key)).width, equals(552), reason: 'capped, not proportional');
    });

    testWidgets('insets the rows and not the viewport', (tester) async {
      const row = Key('row');
      const scroll = CustomScrollView(
        slivers: <Widget>[
          SliverContentPane(
            sliver: SliverToBoxAdapter(child: SizedBox(height: 40, key: row)),
          ),
        ],
      );

      await pump(tester, scroll, size: const Size(1000, 800));
      expect(tester.getSize(find.byType(CustomScrollView)).width, equals(1000), reason: 'full bleed');
      expect(tester.getSize(find.byKey(row)).width, equals(552), reason: 'the row takes the column');
    });

    testWidgets('carries the safe area, in both forms', (tester) async {
      const key = Key('content');
      const inset = EdgeInsets.only(top: 24);

      await pump(
        tester,
        const ContentPane(child: SizedBox.expand(key: key)),
        padding: inset,
      );
      expect(tester.getTopLeft(find.byKey(key)).dy, equals(24));

      await pump(
        tester,
        const CustomScrollView(
          slivers: <Widget>[
            SliverContentPane(
              sliver: SliverToBoxAdapter(child: SizedBox(height: 40, key: key)),
            ),
          ],
        ),
        padding: inset,
      );
      expect(tester.getTopLeft(find.byKey(key)).dy, equals(24));
    });

    // Widget tests run with zero padding, so a fill that is taller than its viewport by the bottom
    // inset is invisible without one.
    testWidgets('a fill does not scroll on a phone with a gesture bar', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await pump(
        tester,
        CustomScrollView(
          controller: controller,
          slivers: const <Widget>[SliverContentFill(child: SizedBox.expand())],
        ),
        padding: const .only(top: 24, bottom: 48),
      );

      expect(controller.position.maxScrollExtent, isZero, reason: 'it fits, so there is nothing to scroll');
    });

    testWidgets('survives the intrinsic measurement a fill performs', (tester) async {
      await pump(
        tester,
        const CustomScrollView(
          slivers: <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: ContentPane(child: Text('measured', textDirection: .ltr)),
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the child State across the 600dp boundary', (tester) async {
      const probe = Key('probe');

      await pump(tester, const ContentPane(child: _Probe(key: probe)));
      final compact = tester.state<_ProbeState>(find.byKey(probe)).id;

      await pump(
        tester,
        const ContentPane(child: _Probe(key: probe)),
        size: const Size(1000, 800),
      );
      expect(
        tester.state<_ProbeState>(find.byKey(probe)).id,
        equals(compact),
        reason: 'a window resize must not rebuild the screen under it',
      );

      await pump(tester, const ContentPane(child: _Probe(key: probe)));
      expect(tester.state<_ProbeState>(find.byKey(probe)).id, equals(compact), reason: 'and back again');
    });
  });
}
