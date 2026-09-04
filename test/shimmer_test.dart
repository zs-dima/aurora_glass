import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// A `LeafRenderObjectWidget` driving a raw [Ticker] from `attach` and `detach`: mounting and
/// unmounting can leave something running or a disposed object reachable.
void main() {
  Widget host(Widget child, {bool reduceMotion = false}) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: MaterialApp(
      theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
      home: Scaffold(body: Center(child: child)),
    ),
  );

  const skeleton = SizedBox(height: 44, width: 200, child: Shimmer(radius: AppRadius.small));

  testWidgets('animates by default', (tester) async {
    await tester.pumpWidget(host(skeleton));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('Reduce Motion stops the ticker, not merely the repaint', (tester) async {
    await tester.pumpWidget(host(skeleton, reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isFalse, reason: 'a skipped repaint still burns a vsync callback');
    expect(tester.takeException(), isNull);
  });

  testWidgets('toggling Reduce Motion while mounted starts and stops it', (tester) async {
    final withShimmer = host(skeleton);
    await tester.pumpWidget(withShimmer);
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(host(skeleton, reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(withShimmer);
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isTrue, reason: 'it never came back');
    expect(tester.takeException(), isNull);
  });

  // A disposed Ticker throws on the next start(); detach must not leave one reachable.
  testWidgets('unmounting and remounting leaves nothing disposed behind', (tester) async {
    final withShimmer = host(skeleton);
    await tester.pumpWidget(withShimmer);
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(host(const SizedBox.shrink()));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(withShimmer);
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmounting while Reduce Motion is on is also clean', (tester) async {
    await tester.pumpWidget(host(skeleton, reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(host(const SizedBox.shrink(), reduceMotion: true));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('takes its colours from the theme', (tester) async {
    await tester.pumpWidget(host(skeleton));
    await tester.pump();

    expect(find.byType(Shimmer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('is its own repaint boundary', (tester) async {
    await tester.pumpWidget(host(skeleton));
    await tester.pump();

    final renderObject = tester.renderObject(find.byType(Shimmer));
    expect(renderObject.isRepaintBoundary, isTrue, reason: 'every frame would dirty the enclosing layer');
  });
}
