import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WindowClass', () {
    test('classifies the M3 breakpoint boundaries', () {
      final isMedium = equals(WindowClass.medium);
      expect(WindowClass.ofWidth(0), equals(WindowClass.compact));
      expect(WindowClass.ofWidth(599), equals(WindowClass.compact));
      expect(WindowClass.ofWidth(600), isMedium);
      expect(WindowClass.ofWidth(839), isMedium);
      expect(WindowClass.ofWidth(840), equals(WindowClass.expanded));
      expect(WindowClass.ofWidth(1199), equals(WindowClass.expanded));
      expect(WindowClass.ofWidth(1200), equals(WindowClass.large));
      expect(WindowClass.ofWidth(1599), equals(WindowClass.large));
      expect(WindowClass.ofWidth(1600), equals(WindowClass.extraLarge));
    });

    // Split-screen and a dragged window edge both produce fractional widths.
    test('a fractional width lands on the class below the boundary', () {
      final isMedium = equals(WindowClass.medium);
      expect(WindowClass.ofWidth(599.9), equals(WindowClass.compact));
      expect(WindowClass.ofWidth(600.1), isMedium);
      expect(WindowClass.ofWidth(839.99), isMedium);
    });

    test('orLarger predicates are cumulative', () {
      expect(WindowClass.compact.isMediumOrLarger, isFalse);
      expect(WindowClass.medium.isMediumOrLarger, isTrue);
      expect(WindowClass.medium.isExpandedOrLarger, isFalse);
      expect(WindowClass.expanded.isExpandedOrLarger, isTrue);
      expect(WindowClass.expanded.isLargeOrLarger, isFalse);
      expect(WindowClass.large.isLargeOrLarger, isTrue);
      expect(WindowClass.extraLarge.isLargeOrLarger, isTrue);
    });

    // The predicates compare `index`, so the declaration order is the size order.
    test('the declaration order is the size order', () {
      expect(
        WindowClass.values,
        orderedEquals(<WindowClass>[
          WindowClass.compact,
          WindowClass.medium,
          WindowClass.expanded,
          WindowClass.large,
          WindowClass.extraLarge,
        ]),
      );
    });

    test('map is exhaustive over the size classes', () {
      String name(double width) => WindowClass.ofWidth(width).map(
        compact: () => 'compact',
        medium: () => 'medium',
        expanded: () => 'expanded',
        large: () => 'large',
        extraLarge: () => 'extraLarge',
      );
      expect(name(599), equals('compact'));
      expect(name(600), equals('medium'));
      expect(name(840), equals('expanded'));
      expect(name(1200), equals('large'));
      expect(name(1600), equals('extraLarge'));
    });

    test('maybeMap falls back to orElse for omitted handlers', () {
      expect(WindowClass.expanded.maybeMap(orElse: () => 'other', compact: () => 'compact'), equals('other'));
      expect(WindowClass.compact.maybeMap(orElse: () => 'other', compact: () => 'compact'), equals('compact'));
    });

    test('mapWithLowerFallback cascades down to the nearest smaller handler', () {
      String name(WindowClass windowClass) =>
          windowClass.mapWithLowerFallback(compact: () => 'compact', medium: () => 'medium');
      final medium = equals('medium');
      expect(name(.compact), equals('compact'));
      expect(name(.medium), medium);
      // No expanded, large or extraLarge handler: medium is the nearest smaller one.
      expect(name(.expanded), medium);
      expect(name(.large), medium);
      expect(name(.extraLarge), medium);
    });
  });

  group('WindowSizeScope', () {
    testWidgets('publishes the class of the current window', (tester) async {
      late WindowClass windowClass;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: WindowSizeScope(
            child: Builder(
              builder: (context) {
                windowClass = WindowSizeScope.classOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(windowClass, equals(WindowClass.expanded));
    });

    // Reading it without a scope must not throw: a screen pumped bare in a test, or a dialog on a
    // detached overlay, still has to classify.
    testWidgets('falls back to MediaQuery when no scope is mounted', (tester) async {
      late WindowClass windowClass;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              windowClass = WindowSizeScope.classOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(windowClass, equals(WindowClass.compact));
    });
  });
}
