// Several tests re-read the same expression after a re-pump, or assert the same thing for the
// box and the sliver form; that repetition is the property under test.
// ignore_for_file: use-existing-variable, avoid-duplicate-test-assertions
import 'dart:ui' as ui show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

void main() {
  Widget host({
    required Size size,
    Widget? detail,
    List<ui.DisplayFeature> features = const <ui.DisplayFeature>[],
  }) => MediaQuery(
    data: MediaQueryData(size: size, displayFeatures: features),
    child: MaterialApp(
      theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
      themeAnimationDuration: .zero,
      home: WindowSizeScope(
        child: AppResponsiveTheme(
          palette: TestPalette.instance,
          child: ListDetail(
            list: const SizedBox.expand(key: Key('list')),
            detail: detail,
          ),
        ),
      ),
    ),
  );

  double widthOf(WidgetTester tester, Key key) => tester.getSize(find.byKey(key)).width;

  /// Sets the real surface size as well as the MediaQuery, so the LayoutBuilder measures it.
  Future<void> pump(
    WidgetTester tester, {
    required Size size,
    Widget? detail,
    List<ui.DisplayFeature> features = const <ui.DisplayFeature>[],
  }) async {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(size: size, detail: detail, features: features));
    await tester.pumpAndSettle();
  }

  final listKey = find.byKey(const Key('list'));
  final detailKey = find.byKey(const Key('detail'));

  group('ListDetail', () {
    testWidgets('below expanded it is one pane, and the list keeps it', (tester) async {
      await pump(tester, size: const Size(400, 800));
      expect(listKey, findsOneWidget);
      expect(detailKey, findsNothing);

      await pump(
        tester,
        size: const Size(400, 800),
        detail: const SizedBox.expand(key: Key('detail')),
      );
      expect(widthOf(tester, const Key('list')), equals(400));
      expect(detailKey, findsNothing);
    });

    testWidgets('medium is still one pane', (tester) async {
      await pump(
        tester,
        size: const Size(700, 800),
        detail: const SizedBox.expand(key: Key('detail')),
      );
      expect(listKey, findsOneWidget);
      expect(detailKey, findsNothing);
    });

    testWidgets('the list survives the expanded boundary with its element', (tester) async {
      await pump(tester, size: const Size(400, 800));
      final before = tester.element(listKey);

      await pump(
        tester,
        size: const Size(1000, 800),
        detail: const SizedBox.expand(key: Key('detail')),
      );
      expect(tester.element(listKey), same(before), reason: 'its scroll position lives there');

      await pump(tester, size: const Size(400, 800));
      expect(tester.element(listKey), same(before), reason: 'and back again');
    });

    testWidgets('from expanded up both panes are on screen', (tester) async {
      await pump(
        tester,
        size: const Size(1000, 800),
        detail: const SizedBox.expand(key: Key('detail')),
      );
      expect(listKey, findsOneWidget);
      expect(detailKey, findsOneWidget);
      expect(widthOf(tester, const Key('list')), equals(440));
    });

    testWidgets('the list never takes more than half the window', (tester) async {
      await pump(
        tester,
        size: const Size(840, 800),
        detail: const SizedBox.expand(key: Key('detail')),
      );
      final listWidth = widthOf(tester, const Key('list'));
      expect(listWidth, lessThanOrEqualTo(840 / 2));
      expect(listWidth, lessThanOrEqualTo(widthOf(tester, const Key('detail'))));
    });

    testWidgets('a vertical hinge, not the default width, decides the split', (tester) async {
      await pump(
        tester,
        size: const Size(1000, 800),
        detail: const SizedBox.expand(key: Key('detail')),
        features: const <ui.DisplayFeature>[
          ui.DisplayFeature(
            bounds: Rect.fromLTRB(520, 0, 548, 800),
            type: ui.DisplayFeatureType.hinge,
            state: ui.DisplayFeatureState.postureFlat,
          ),
        ],
      );

      expect(widthOf(tester, const Key('list')), equals(520));
      expect(widthOf(tester, const Key('detail')), equals(1000 - 548));
      final listRight = tester.getTopRight(listKey).dx;
      final detailLeft = tester.getTopLeft(detailKey).dx;
      expect(listRight, lessThanOrEqualTo(520));
      expect(detailLeft, greaterThanOrEqualTo(548));
    });

    testWidgets('a cutout and a horizontal fold are both ignored', (tester) async {
      for (final feature in <ui.DisplayFeature>[
        const ui.DisplayFeature(
          bounds: Rect.fromLTRB(480, 0, 520, 40),
          type: ui.DisplayFeatureType.cutout,
          state: ui.DisplayFeatureState.unknown,
        ),
        const ui.DisplayFeature(
          bounds: Rect.fromLTRB(0, 390, 1000, 410),
          type: ui.DisplayFeatureType.fold,
          state: ui.DisplayFeatureState.postureFlat,
        ),
      ]) {
        await pump(
          tester,
          size: const Size(1000, 800),
          detail: const SizedBox.expand(key: Key('detail')),
          features: <ui.DisplayFeature>[feature],
        );
        expect(widthOf(tester, const Key('list')), equals(440), reason: '${feature.type.name} must not move the split');
      }
    });

    // Display features are in screen coordinates; inside a 600 dp column a hinge at x=520 would be
    // placed at the wrong local x.
    testWidgets('a hinge is refused, loudly, when the layout does not span the window', (tester) async {
      tester.view
        ..devicePixelRatio = 1.0
        ..physicalSize = const Size(1000, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1000, 800),
            displayFeatures: <ui.DisplayFeature>[
              ui.DisplayFeature(
                bounds: Rect.fromLTRB(520, 0, 548, 800),
                type: ui.DisplayFeatureType.hinge,
                state: ui.DisplayFeatureState.postureFlat,
              ),
            ],
          ),
          child: MaterialApp(
            theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
            themeAnimationDuration: .zero,
            home: const WindowSizeScope(
              child: AppResponsiveTheme(
                palette: TestPalette.instance,
                child: ContentPane(
                  child: ListDetail(
                    list: SizedBox.expand(key: Key('list')),
                    detail: SizedBox.expand(key: Key('detail')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final error = tester.takeException();
      expect(error, isAssertionError);
      expect(error.toString(), contains('600dp'), reason: 'the message must name the cause');
    });

    testWidgets('the chassis hands it the whole window, and then the hinge works', (tester) async {
      tester.view
        ..devicePixelRatio = 1.0
        ..physicalSize = const Size(1000, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1000, 800),
            displayFeatures: <ui.DisplayFeature>[
              ui.DisplayFeature(
                bounds: Rect.fromLTRB(520, 0, 548, 800),
                type: ui.DisplayFeatureType.hinge,
                state: ui.DisplayFeatureState.postureFlat,
              ),
            ],
          ),
          child: MaterialApp(
            theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
            themeAnimationDuration: .zero,
            home: const WindowSizeScope(
              child: AppResponsiveTheme(
                palette: TestPalette.instance,
                child: AppScaffold(
                  child: ListDetail(
                    list: SizedBox.expand(key: Key('list')),
                    detail: SizedBox.expand(key: Key('detail')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(listKey).width, equals(520));
      expect(tester.getTopLeft(detailKey).dx, greaterThanOrEqualTo(548));
    });
  });
}
