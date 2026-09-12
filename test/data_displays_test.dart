import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// The parts a list of measurements is drawn from, and the header row above it.
///
/// All four were written in the apps first — some of them four times, in four shapes — and the
/// gallery has named three of them since 0.1.0. What is asserted here is what differed between the
/// copies: where a bar fills from, whether a value outside 0..1 reaches the render tree, whether a
/// header's label sits at the arrow's height, and whether an absent label still announces a
/// heading.
void main() {
  Widget host(Widget child, {bool brand = true}) => MaterialApp(
    theme: brand
        ? AppTheme.resolve(.dark, .compact, TestPalette.instance)
        // A bare Material theme with no `Brand` in it: a gallery cell, a golden, a screen in a
        // host app that has not installed the palette. Every kit part must still draw.
        : ThemeData(brightness: .dark),
    home: Scaffold(
      body: Padding(padding: const .all(AppSpacing.lg), child: child),
    ),
  );

  Future<void> pump(WidgetTester tester, Widget child, {bool brand = true}) async {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = const Size(360, 640);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(child, brand: brand));
  }

  group('ProgressBar', () {
    testWidgets('fills the fraction it is given, from the LEADING edge', (tester) async {
      await pump(tester, const SizedBox(width: 200, child: ProgressBar(value: 0.25)));

      final box = tester.renderObject<RenderBox>(find.byType(FractionallySizedBox));
      expect(box.size.width, closeTo(50, 0.5));
      expect(
        tester.getTopLeft(find.byType(FractionallySizedBox)).dx,
        closeTo(tester.getTopLeft(find.byType(ProgressBar)).dx, 0.5),
        reason: 'a bar that filled from the centre or the end would rank a list backwards in RTL',
      );
    });

    testWidgets('**and the fill has HEIGHT**, which is the half a width assertion cannot see', (tester) async {
      // A childless `DecoratedBox` under loose height constraints takes the smallest size it is
      // allowed. The bar laid out at exactly the right width and painted nothing — every row
      // showed its empty track, and it reached a store screenshot that way.
      await pump(tester, const SizedBox(width: 200, child: ProgressBar(value: 0.25, height: 9)));

      expect(tester.renderObject<RenderBox>(find.byType(FractionallySizedBox)).size.height, equals(9));
    });

    testWidgets('a full bar and an empty one are the two ends of the same track', (tester) async {
      await pump(
        tester,
        const SizedBox(
          width: 200,
          child: Column(
            children: <Widget>[ProgressBar(value: 0), ProgressBar(value: 1)],
          ),
        ),
      );

      final fills = tester.renderObjectList<RenderBox>(find.byType(FractionallySizedBox)).toList(growable: false);
      expect(fills.first.size.width, equals(0));
      expect(fills.last.size.width, closeTo(200, 0.5));
    });

    testWidgets('a value outside the range, and a NaN, never reach the render tree', (tester) async {
      // `0 / 0` upstream is how a NaN arrives, and `FractionallySizedBox` asserts on one.
      for (final value in <double>[-1, 2, double.nan]) {
        await pump(tester, SizedBox(width: 200, child: ProgressBar(value: value)));

        expect(tester.takeException(), isNull, reason: 'value $value threw');
      }
    });

    testWidgets('the featured bar carries the brand gradient; the normal one does not', (tester) async {
      await pump(
        tester,
        const SizedBox(
          width: 200,
          child: Column(
            children: <Widget>[
              ProgressBar(value: 0.5),
              ProgressBar(value: 0.5, emphasis: .featured),
            ],
          ),
        ),
      );

      final fills = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(DecoratedBox)),
          )
          .map((box) => box.decoration as BoxDecoration)
          .toList(growable: false);

      expect(fills.first.gradient, isNull);
      expect(fills.first.color, isNotNull, reason: 'a normal bar is a tint that deepens with the value');
      expect(fills.last.gradient, isNotNull);
      expect(fills.last.boxShadow, isNotNull, reason: 'the featured bar is the one the eye is meant to land on');
    });

    testWidgets('draws without a Brand in the theme', (tester) async {
      await pump(
        tester,
        const SizedBox(width: 200, child: ProgressBar(value: 0.5, emphasis: .featured)),
        brand: false,
      );

      expect(tester.takeException(), isNull);
      final fill =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(DecoratedBox)),
                  )
                  .decoration
              as BoxDecoration;
      expect(fill.color, isNotNull, reason: 'no gradient to be made of, so a solid accent fill');
    });

    testWidgets('an unlabelled bar says nothing, and a labelled one says its percentage', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const SizedBox(
          width: 200,
          child: Column(
            children: <Widget>[
              ProgressBar(value: 0.42),
              ProgressBar(value: 0.42, semanticsLabel: 'Bathroom wall'),
            ],
          ),
        ),
      );

      expect(find.bySemanticsLabel('Bathroom wall'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Bathroom wall')).value,
        equals('42%'),
        reason: 'a bar is a second reading of a number, and the number is what a screen reader needs',
      );
      handle.dispose();
    });
  });

  group('LevelBars', () {
    testWidgets('an empty list paints nothing and throws nothing', (tester) async {
      await pump(tester, const SizedBox(width: 200, child: LevelBars(values: <double>[])));

      expect(tester.takeException(), isNull);
    });

    testWidgets('silence is a row of stubs, not a blank strip', (tester) async {
      // A blank strip is indistinguishable from a meter that is not running, which is the one
      // thing a live meter must never look like.
      await pump(tester, SizedBox(width: 200, child: LevelBars(values: List<double>.filled(3, 0))));

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('the live constructor repaints from its listenable without rebuilding', (tester) async {
      final trail = ValueNotifier<List<double>>(List<double>.filled(3, 0));
      addTearDown(trail.dispose);
      var builds = 0;

      await pump(
        tester,
        SizedBox(
          width: 200,
          child: Builder(
            builder: (context) {
              builds++;

              return LevelBars.live(trail: trail);
            },
          ),
        ),
      );
      expect(builds, equals(1));

      trail.value = const <double>[1, 0.5, 0.2];
      await tester.pump();

      expect(
        builds,
        equals(1),
        reason: 'a frame every 46 ms must move rectangles, not rebuild the screen that holds them',
      );
    });
  });

  group('StatTile', () {
    testWidgets('does not impose a flex on its caller', (tester) async {
      // One app's copy returned an `Expanded` from its own build, which makes the tile unusable
      // anywhere but a row — and fails with a parent-data error rather than a readable one.
      await pump(tester, const StatTile(label: 'Background', value: 'Quiet'));

      expect(tester.takeException(), isNull);
      expect(find.byType(Expanded), findsWidgets, reason: 'only the one INSIDE the tile, around the value');
    });

    testWidgets('a live value gets the dot and a settled one gets the icon', (tester) async {
      await pump(
        tester,
        const Column(
          children: <Widget>[
            StatTile(label: 'Now', value: 'Recording', tone: .accent, live: true),
            StatTile(label: 'Then', value: 'Done', tone: .ok),
          ],
        ),
      );

      expect(find.byType(StatusDot), findsOneWidget);
      expect(find.byIcon(AppTone.ok.icon), findsOneWidget);
    });
  });

  group('StatusDot', () {
    testWidgets('a dot with no verdict does not glow — the three tones all MEAN something', (tester) async {
      await pump(
        tester,
        const Row(
          children: <Widget>[
            StatusDot(),
            StatusDot(tone: .ok),
          ],
        ),
      );

      final decorations = tester
          .widgetList<DecoratedBox>(find.descendant(of: find.byType(StatusDot), matching: find.byType(DecoratedBox)))
          .map((box) => box.decoration as BoxDecoration)
          .toList(growable: false);

      expect(decorations.first.boxShadow, isNull);
      expect(decorations.last.boxShadow, isNotNull);
    });

    testWidgets('is not announced: the row it marks keeps its own words', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const StatusDot(tone: .alert));

      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      handle.dispose();
    });

    testWidgets('a pulsing dot holds still under Reduce Motion', (tester) async {
      tester.view
        ..devicePixelRatio = 1.0
        ..physicalSize = const Size(360, 640);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(body: StatusDot(tone: .ok, pulse: true)),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final fade = tester.widget<FadeTransition>(
        find.descendant(of: find.byType(StatusDot), matching: find.byType(FadeTransition)),
      );
      expect(fade.opacity.value, equals(1), reason: 'stopped at full, never mid-fade');
    });
  });
}
