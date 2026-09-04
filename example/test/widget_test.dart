import 'package:aurora_glass/aurora_glass.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the gallery boots on the chassis and renders every section', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pump();

    expect(find.byType(AppScaffold), findsOneWidget);
    expect(find.text('UI Kit'), findsWidgets);
    expect(find.text('BUTTONS'), findsOneWidget);
    // The design-law triad is in the gallery: the ListView builds lazily, so scroll it into view
    // rather than asserting against an unbuilt viewport.
    await tester.scrollUntilVisible(find.text('EVERY DATA VIEW: EMPTY / LOADING / ERROR'), 300);
    expect(find.text('EVERY DATA VIEW: EMPTY / LOADING / ERROR'), findsOneWidget);
  });
}
