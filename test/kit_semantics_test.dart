import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// The kit's accessibility rules: at least 44 px visual and 48 dp tap target, AA text contrast,
/// and colour never as the only signal.
void main() {
  Widget host(Widget child, {Brightness brightness = .dark}) => MaterialApp(
    theme: AppTheme.resolve(brightness, .compact, TestPalette.instance),
    home: Scaffold(
      // A solid ground so the contrast guideline has something to sample.
      backgroundColor: TestPalette.instance.schemeOf(brightness).surface,
      body: Center(
        child: Padding(padding: const .all(16), child: child),
      ),
    ),
  );

  testWidgets('a toned ListRow carries the tone in its colour and an icon', (tester) async {
    await tester.pumpWidget(host(const ListRow(title: 'Delete', tone: .alert)));

    final title = tester.widget<Text>(find.text('Delete'));
    final scheme = Theme.of(tester.element(find.text('Delete'))).colorScheme;
    expect(title.style?.color, equals(scheme.error));
    expect(find.byIcon(AppTone.alert.icon), findsOneWidget);
  });

  testWidgets('an untoned ListRow is unchanged', (tester) async {
    await tester.pumpWidget(host(const ListRow(title: 'Language')));

    expect(find.byIcon(AppTone.alert.icon), findsNothing);
  });

  for (final brightness in Brightness.values) {
    final name = brightness.name;

    testWidgets('$name PrimaryPill meets contrast and tap-target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          PrimaryPill(label: 'Start', onPressed: () {}),
          brightness: brightness,
        ),
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('$name GhostPill and TextAction meet tap-target guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: .min,
            children: <Widget>[
              GhostPill(label: 'Skip', onPressed: () {}),
              TextAction(label: 'Restore purchases', onPressed: () {}),
            ],
          ),
          brightness: brightness,
        ),
      );

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('$name ListRow keeps a 48dp tap target', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          ListRow(title: 'Kitchen', subtitle: 'Row 12', onTap: () {}),
          brightness: brightness,
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });
  }

  testWidgets('StatusPill never signals with colour alone', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(const StatusPill(label: 'Listening', tone: .ok)));

    expect(find.bySemanticsLabel('Listening'), findsOneWidget);
    expect(find.byIcon(AppTone.ok.icon), findsOneWidget);
    handle.dispose();
  });

  testWidgets('InfoBanner carries an icon and an accessible action', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(InfoBanner(message: 'Connection lost, retrying', tone: .alert, action: 'Retry', onAction: () {})),
    );

    expect(find.byIcon(AppTone.alert.icon), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('ambient pulse is suppressed under Reduce Motion', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: host(const StatusPill(label: 'Armed', pulse: true)),
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });
}
