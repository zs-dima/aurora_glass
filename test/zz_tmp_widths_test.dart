import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

void main() {
  const kPhone = Size(360, 640);

  testWidgets('widths', (tester) async {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = kPhone;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: kPhone),
        child: MaterialApp(
          theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ScreenHeader(
                label: 'Where is louder',
                trailing: 'Aug 29',
                back: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
              ),
            ),
          ),
        ),
      ),
    );

    final header = tester.getSize(find.byType(ScreenHeader));
    final slot = tester.getSize(find.byType(LabelWithValue));
    final label = tester.renderObject<RenderParagraph>(find.text('WHERE IS LOUDER'));
    final value = tester.renderObject<RenderParagraph>(find.text('Aug 29'));
    // ignore: avoid_print
    print(
      'header=${header.width} slot=${slot.width} '
      'labelBox=${label.size.width} labelWants=${label.getMaxIntrinsicWidth(double.infinity)} '
      'cut=${label.didExceedMaxLines} '
      'valueBox=${value.size.width} valueWants=${value.getMaxIntrinsicWidth(double.infinity)}',
    );
  });
}
