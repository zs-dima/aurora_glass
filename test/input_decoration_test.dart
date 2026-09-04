import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// The input decoration is written with [WidgetStateInputBorder]; the state-named `focusedBorder`
/// family takes precedence over it, so a decoration that mixes them behaves differently from how
/// it reads. These tests pin what the field paints.
// The decoration is under test; nothing types into the fields.
// ignore_for_file: avoid-missing-controller
void main() {
  Widget host(Widget child, Brightness brightness) => MaterialApp(
    theme: AppTheme.resolve(brightness, .compact, TestPalette.instance),
    home: Scaffold(body: Center(child: child)),
  );

  /// The border colour the field is painting.
  Color borderColour(WidgetTester tester) {
    final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
    final border = decorator.decoration.border;
    // `WidgetStateInputBorder` is both an InputBorder and a WidgetStateProperty<InputBorder>.
    // ignore: avoid-misused-test-matchers
    expect(border, isA<WidgetStateProperty<InputBorder>>(), reason: 'the theme border did not reach the field');
    // ignore: avoid-unrelated-type-casts
    final resolved = (border! as WidgetStateProperty<InputBorder>).resolve(
      decorator.decoration.enabled
          ? <WidgetState>{if (decorator.isFocused) WidgetState.focused}
          : <WidgetState>{WidgetState.disabled},
    );
    return resolved.borderSide.color;
  }

  for (final brightness in Brightness.values) {
    testWidgets('${brightness.name}: a field takes its border from the theme', (tester) async {
      await tester.pumpWidget(host(const TextField(), brightness));
      await tester.pump();

      final brand = brightness == .dark ? TestPalette.dark : TestPalette.light;
      expect(borderColour(tester), equals(brand.cardBorder));
    });

    testWidgets('${brightness.name}: focus moves the border to the brand accent', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(host(TextField(focusNode: focusNode), brightness));

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      final brand = brightness == .dark ? TestPalette.dark : TestPalette.light;
      expect(borderColour(tester), equals(brand.accentText));
    });

    testWidgets('${brightness.name}: a disabled field uses the muted outline', (tester) async {
      await tester.pumpWidget(host(const TextField(enabled: false), brightness));
      await tester.pump();

      final scheme = TestPalette.instance.schemeOf(brightness);
      expect(borderColour(tester), equals(scheme.outlineVariant));
    });

    testWidgets('${brightness.name}: the fill is the glass surface', (tester) async {
      await tester.pumpWidget(host(const TextField(), brightness));
      await tester.pump();

      final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
      final brand = brightness == .dark ? TestPalette.dark : TestPalette.light;
      expect(decorator.decoration.filled, isTrue);
      expect(decorator.decoration.fillColor, equals(brand.cardFill));
    });
  }

  testWidgets('the corner is on the shape scale', (tester) async {
    await tester.pumpWidget(host(const TextField(), .dark));
    await tester.pump();

    final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
    // ignore: avoid-unrelated-type-casts
    final border = (decorator.decoration.border! as WidgetStateProperty<InputBorder>).resolve(
      const <WidgetState>{},
    );
    expect(border, isA<OutlineInputBorder>());
    expect((border as OutlineInputBorder).borderRadius, equals(AppShape.row));
  });
}
