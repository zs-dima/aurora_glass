import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// Kit widgets must survive Russian, which runs about 30% longer than English, and a text scale
/// of 2.0.
///
/// `takeException()` is half the assertion: a [Row] whose child is taller than its box reports
/// nothing, and the paragraph paints its remaining lines outside. So every paragraph is also
/// checked for the height it asked for.
void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
    home: Scaffold(
      body: Padding(padding: const .all(AppSpacing.lg), child: child),
    ),
  );

  Future<void> pumpNarrow(WidgetTester tester, Widget child, {double textScale = 1.0}) async {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = const Size(360, 640);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: host(child),
      ),
    );
  }

  /// Every laid-out paragraph under [scope] got at least the height it asked for.
  void expectNothingClipped(WidgetTester tester, Finder scope) {
    final texts = find.descendant(of: scope, matching: find.byType(Text));
    expect(texts, findsWidgets, reason: 'the finder matched no Text');
    for (final element in texts.evaluate()) {
      final box = element.renderObject! as RenderBox;
      final needed = box.getMaxIntrinsicHeight(box.size.width);
      expect(
        box.size.height,
        greaterThanOrEqualTo(needed),
        reason: 'a paragraph was given ${box.size.height}px but needs ${needed}px at width ${box.size.width}',
      );
    }
  }

  group('PrimaryPill', () {
    testWidgets('a long label wraps instead of overflowing', (tester) async {
      await pumpNarrow(
        tester,
        PrimaryPill(label: 'Сканировать QR-код', onPressed: () {}),
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
      expectNothingClipped(tester, find.byType(PrimaryPill));
    });

    testWidgets('a short label measures exactly the design height', (tester) async {
      await pumpNarrow(tester, PrimaryPill(label: 'Scan', onPressed: () {}));

      expect(tester.getSize(find.byType(PrimaryPill)).height, equals(AppTarget.primaryPill));
    });

    testWidgets('the shape stays a stadium when the label wraps', (tester) async {
      await pumpNarrow(tester, PrimaryPill(label: 'Сканировать QR-код', onPressed: () {}), textScale: 2.0);

      final decorated = tester.widgetList<DecoratedBox>(
        find.descendant(of: find.byType(PrimaryPill), matching: find.byType(DecoratedBox)),
      );
      final shapes = decorated.map((d) => d.decoration).whereType<ShapeDecoration>().map((d) => d.shape).toList();
      expect(shapes, isNotEmpty);
      expect(shapes.first, isA<StadiumBorder>());
    });
  });

  group('GhostPill', () {
    testWidgets('a long label wraps instead of being clipped', (tester) async {
      await pumpNarrow(tester, GhostPill(label: 'Пропустить и настроить позже', onPressed: () {}), textScale: 2.0);

      expect(tester.takeException(), isNull);
      expectNothingClipped(tester, find.byType(GhostPill));
    });

    testWidgets('a short label measures exactly the design height', (tester) async {
      await pumpNarrow(tester, GhostPill(label: 'Skip', onPressed: () {}));

      expect(tester.getSize(find.byType(GhostPill)).height, equals(AppTarget.ghostPill));
    });
  });

  group('StatusPill', () {
    testWidgets('a long status wraps instead of overflowing', (tester) async {
      await pumpNarrow(tester, const StatusPill(label: 'Ждём телефон у щитка…'), textScale: 2.0);

      expect(tester.takeException(), isNull);
    });

    testWidgets('a status word too wide for its row is capped, not broken in half', (tester) async {
      // One word has no space to wrap at, so it breaks between letters — and on a header row,
      // beside an arrow and a value, the second line pushes the row's height out.
      Future<double> pillHeight({int? maxLines}) async {
        await pumpNarrow(
          tester,
          // A bounded box, which is the only place `maxLines` can bite: unconstrained, the pill
          // lays out at its natural width and never reaches a second line at all.
          SizedBox(
            width: 120,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusPill(label: 'Подключено', maxLines: maxLines),
            ),
          ),
          textScale: 2.0,
        );
        return tester.getSize(find.byType(StatusPill)).height;
      }

      final broken = await pillHeight();
      final capped = await pillHeight(maxLines: 1);

      expect(tester.takeException(), isNull);
      expect(capped, lessThan(broken), reason: 'without the cap the word takes two lines');
    });
  });

  group('ListRow', () {
    testWidgets('a long trailing value wraps instead of overflowing', (tester) async {
      await pumpNarrow(
        tester,
        const ListRow(
          title: 'Питание',
          trailing: Text('От батареи', textAlign: .end),
        ),
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a long title and a long value coexist', (tester) async {
      await pumpNarrow(
        tester,
        const ListRow(
          title: 'Громкость сирены на этом телефоне',
          trailing: Text('Макс · сирена готова', textAlign: .end),
        ),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('a trailing control sits at the end of the row, not in the middle', (tester) async {
      await pumpNarrow(
        tester,
        ListRow(
          title: 'Send crash reports',
          subtitle: 'Anonymous diagnostics',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
      );

      final row = tester.getRect(find.byType(ListRow));
      final control = tester.getRect(find.byType(Switch));
      expect(row.right - control.right, lessThan(AppSpacing.md + AppSpacing.sm));
      expect(control.left, greaterThan(row.center.dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the title keeps the width a small trailing control does not need', (tester) async {
      await pumpNarrow(
        tester,
        ListRow(
          title: 'Отправлять отчёты о сбоях',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
        textScale: 1.3,
      );

      final title = tester.getRect(find.text('Отправлять отчёты о сбоях'));
      final row = tester.getRect(find.byType(ListRow));
      expect(title.width, greaterThan(row.width / 2));
      expectNothingClipped(tester, find.byType(ListRow));
    });

    testWidgets('a leading widget with no trailing keeps the text beside it', (tester) async {
      await pumpNarrow(tester, const ListRow(leading: Icon(Icons.bolt), title: 'Kitchen counter'));

      final icon = tester.getRect(find.byIcon(Icons.bolt));
      final title = tester.getRect(find.text('Kitchen counter'));
      expect(title.left - icon.right, closeTo(AppSpacing.sm, 1));
    });

    testWidgets('the chevron appears when there is no trailing widget', (tester) async {
      await pumpNarrow(tester, ListRow(title: 'Kitchen counter', onTap: () {}));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
