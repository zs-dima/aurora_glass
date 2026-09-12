import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// **The header that stays, and the three things that make it possible.**
///
/// It has to keep its own height at any text scale — which is why it is a [PinnedHeaderSliver] and
/// not a [SliverPersistentHeader], whose delegate must name a number before layout runs. It has to
/// HIDE what passes under it, which over this gradient no flat colour can do. And it must not cost
/// the pane below it a second status bar.
void main() {
  const phone = Size(360, 640);
  const padding = EdgeInsets.only(top: 24, bottom: 34);

  /// A row loud enough that a pixel tells you whether the header covered it.
  Widget loudRow(int index) => Container(
    key: ValueKey<int>(index),
    height: 80,
    color: const Color(0xFFFF0000),
  );

  Widget host(List<Widget> slivers, {double textScale = 1}) => MediaQuery(
    data: MediaQueryData(
      size: phone,
      padding: padding,
      viewPadding: padding,
      textScaler: TextScaler.linear(textScale),
    ),
    child: MaterialApp(
      theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
      home: RepaintBoundary(
        child: AppScaffold(child: CustomScrollView(slivers: slivers)),
      ),
    ),
  );

  Future<void> pump(WidgetTester tester, List<Widget> slivers, {double textScale = 1}) async {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = phone;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(slivers, textScale: textScale));
    await tester.pumpAndSettle();
  }

  Widget back() => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {});

  final header = find.byType(ScreenHeader);

  ScrollPosition positionOf(WidgetTester tester) => (tester.state(find.byType(Scrollable)) as ScrollableState).position;

  List<Widget> russianHeaderOverRows() => <Widget>[
    SliverScreenHeader(label: 'Где громче всего', trailing: '6 точек', back: back()),
    SliverList.list(children: <Widget>[for (var i = 0; i < 12; i++) loudRow(i)]),
  ];

  group('the band keeps its own height', () {
    testWidgets('**it grows with the text scale**, which a fixed extent could not', (tester) async {
      await pump(tester, russianHeaderOverRows());
      final atOne = tester.getSize(header).height;

      await pump(tester, russianHeaderOverRows(), textScale: 2);
      // Same expression, different world: the point of the test is that this number moved.
      // ignore: avoid-duplicate-initializers
      final atTwo = tester.getSize(header).height;

      expect(atOne, greaterThanOrEqualTo(AppTarget.tap));
      expect(
        atTwo,
        greaterThan(atOne),
        reason: 'the band is a minimum; a delegate would have had to name a number before layout',
      );
    });

    testWidgets('and the header stays put while the list moves under it', (tester) async {
      await pump(tester, <Widget>[
        SliverScreenHeader(label: 'Spots', back: back()),
        SliverList.list(children: <Widget>[for (var i = 0; i < 12; i++) loudRow(i)]),
      ]);

      final before = tester.getTopLeft(header);
      positionOf(tester).jumpTo(400);
      await tester.pump();

      // Read again after the jump on purpose — that it is still the same value is the assertion.
      // ignore: use-existing-variable
      expect(tester.getTopLeft(header), equals(before));
      expect(header, findsOneWidget);
    });
  });

  group('what passes under it is hidden', () {
    testWidgets('**a row scrolled under the band does not show through it**', (tester) async {
      await pump(tester, <Widget>[
        SliverScreenHeader(label: 'Spots', back: back()),
        SliverContentPane(
          top: false,
          sliver: SliverList.list(children: <Widget>[for (var i = 0; i < 12; i++) loudRow(i)]),
        ),
      ]);

      // Far enough that a row is definitely behind the band rather than below it.
      positionOf(tester).jumpTo(400);
      await tester.pump();

      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      late final ui.Image shot;
      late final ByteData bytes;
      await tester.runAsync(() async {
        shot = await boundary.toImage();
        bytes = (await shot.toByteData())!;
      });
      addTearDown(shot.dispose);

      int redAt(int x, int y) => bytes.getUint8((y * shot.width + x) * 4);
      int greenAt(int x, int y) => bytes.getUint8((y * shot.width + x) * 4 + 1);

      bool isRow(int x, int y) => redAt(x, y) > 200 && greenAt(x, y) < 60;

      // Inside the band, past the label, where only the page or the row can be showing. Sampled
      // inside the content column: the side padding is 24 dp and a row does not reach it.
      final band = tester.getRect(header);
      expect(
        isRow(300, band.center.dy.round()),
        isFalse,
        reason: 'the row is painting through the header',
      );
      // And the row really is there, immediately below the band — so the sample above means
      // something. Without this the test would pass over a screen with no rows at all.
      expect(
        isRow(180, band.bottom.round() + 10),
        isTrue,
        reason: 'the row should be visible immediately under the band',
      );
    });
  });

  group('the insets are owned once', () {
    testWidgets('**the pane under it does not count the status bar twice**', (tester) async {
      await pump(tester, <Widget>[
        SliverScreenHeader(label: 'Spots', back: back()),
        SliverContentPane(
          top: false,
          sliver: SliverList.list(children: <Widget>[for (var i = 0; i < 12; i++) loudRow(i)]),
        ),
      ]);

      final band = tester.getRect(header);
      final firstRowTop = tester.getTopLeft(find.byKey(const ValueKey<int>(0))).dy;

      expect(
        firstRowTop,
        closeTo(band.bottom, 1),
        reason: 'a pane passing top: true would push the first row down by another $padding',
      );
      expect(band.top, closeTo(padding.top, 1));
    });

    testWidgets('a content fill under it takes the rest of the viewport and does not scroll', (tester) async {
      await pump(tester, <Widget>[
        SliverScreenHeader(label: 'Spots', back: back()),
        const SliverContentFill(top: false, child: Center(child: Text('nothing here yet'))),
      ]);

      expect(
        positionOf(tester).maxScrollExtent,
        isZero,
        reason: 'a fill sized against the whole viewport instead of what the header left would scroll',
      );
    });
  });

  group('the background is the page itself', () {
    testWidgets('**AppBackground draws the same thing on its own as inside AppScaffold**', (tester) async {
      Future<ByteData> shoot(Widget child) async {
        tester.view
          ..devicePixelRatio = 1.0
          ..physicalSize = phone;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: phone),
            child: MaterialApp(
              theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
              home: RepaintBoundary(child: child),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
        late final ByteData bytes;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          bytes = (await image.toByteData())!;
          image.dispose();
        });
        return bytes;
      }

      final alone = await shoot(const AppBackground());
      final inScaffold = await shoot(const AppScaffold(child: SizedBox.expand()));

      expect(
        alone.buffer.asUint8List(),
        orderedEquals(inScaffold.buffer.asUint8List()),
        reason: 'the extraction must not have changed one pixel of the chassis',
      );
    });
  });
}
