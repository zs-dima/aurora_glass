import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixture/test_palette.dart';

/// **The row every deeper screen starts with, and the two things four copies of it got wrong.**
///
/// The alignment: a 48 px icon button beside a ~14 px overline, aligned on their TOPS, leaves the
/// label floating about seventeen pixels above the arrow it belongs to. That is what every
/// LeakSonar store screenshot shipped, and it is one enum value.
///
/// The heading: only one of the four apps marked the label as a heading, and only one guarded
/// against an EMPTY one — which the other rendered as a heading node announcing nothing at all.
void main() {
  /// The narrowest phone the kit targets.
  const kPhone = Size(360, 640);

  Widget host(Widget child, {double textScale = 1}) => MediaQuery(
    data: MediaQueryData(size: kPhone, textScaler: TextScaler.linear(textScale)),
    child: MaterialApp(
      theme: AppTheme.resolve(.dark, .compact, TestPalette.instance),
      home: Scaffold(
        body: Padding(padding: const .all(AppSpacing.lg), child: child),
      ),
    ),
  );

  Future<void> pump(WidgetTester tester, Widget child, {double textScale = 1}) async {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = kPhone;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(child, textScale: textScale));
  }

  Widget back() => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {});

  group("one row, at the arrow's height", () {
    testWidgets("**the label sits on the arrow's centre line**, not above it", (tester) async {
      await pump(tester, ScreenHeader(label: 'Step 2 of 3', back: back()));

      expect(
        tester.getCenter(find.byType(Text)).dy,
        closeTo(tester.getCenter(find.byType(IconButton)).dy, 1),
        reason:
            'with `crossAxisAlignment: .start` these differ by about 17 px — a 48 px button against '
            'a 14 px line — and that is the misalignment on every screenshot',
      );
    });

    testWidgets('a trailing value sits on the same line as both', (tester) async {
      await pump(tester, ScreenHeader(label: 'Hunt', trailing: 'Aug 29', back: back()));

      final label = tester.getCenter(find.text('HUNT')).dy;
      final value = tester.getCenter(find.text('Aug 29')).dy;
      expect(value, closeTo(label, 1));
      expect(label, closeTo(tester.getCenter(find.byType(IconButton)).dy, 1));
    });

    testWidgets('**a short value takes the room it needs and no more**', (tester) async {
      // A `Flexible` around the value defaulted to flex 1, the same as the label's `Expanded`, so
      // the two split the free space evenly: a six-character value took half the row and a label
      // that fits twice over came out ellipsised.
      await pump(tester, ScreenHeader(label: 'Hunt', trailing: '5 spots', back: back()));

      // **The property, not a width.** Every measured width here is an artefact of the test's
      // square-glyph font, so what is asserted is the layout rule: the value is as wide as its own
      // words and sits at the far edge, and the label starts at the near one. Under the bug the
      // value took half the free space whatever its own words needed.
      final header = tester.getRect(find.byType(ScreenHeader));
      final value = tester.getRect(find.text('5 spots'));
      final label = tester.getRect(find.text('HUNT'));

      expect(value.right, closeTo(header.right, 1), reason: 'the value belongs at the end of the row');
      expect(
        label.left,
        closeTo(header.left + AppTarget.tap + AppSpacing.xs, 1),
        reason: 'and the label at the start of what the arrow left',
      );
      expect(
        value.width,
        lessThan(header.width / 3),
        reason: 'seven characters, not a third of the row — which is what an even split handed it',
      );
    });

    testWidgets("the band is the arrow's tap target, with or without an arrow", (tester) async {
      Future<double> bandHeight(Widget header) async {
        await pump(tester, header);

        return tester.getSize(find.byType(ScreenHeader)).height;
      }

      expect(await bandHeight(ScreenHeader(label: 'Settings', back: back())), closeTo(AppTarget.tap, 1));
      expect(
        await bandHeight(const ScreenHeader(label: 'Settings')),
        equals(AppTarget.tap),
        reason: 'screens must not shift against each other',
      );
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('a long label ellipsizes rather than wrapping the row open', (tester) async {
      await pump(
        tester,
        ScreenHeader(label: 'Где слышно громче всего — шаг два из трёх', trailing: '6 точек', back: back()),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      final label = tester.widget<Text>(find.textContaining('ГДЕ СЛЫШНО'));
      expect(label.maxLines, equals(1));
      expect(label.overflow, equals(TextOverflow.ellipsis));
    });
  });

  group('what the row says to a screen reader', () {
    testWidgets("the label is this screen's heading", (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, ScreenHeader(label: 'Report', back: back()));

      expect(
        find.ancestor(of: find.text('REPORT'), matching: _headings),
        findsOneWidget,
        reason: 'the one thing an AppBar would have given for free; a rotor needs it to jump here',
      );
      handle.dispose();
    });

    testWidgets('**an absent label announces nothing** rather than an empty heading', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, ScreenHeader(back: back()));

      expect(find.byType(SectionLabel), findsNothing);
      expect(
        _headings,
        findsNothing,
        reason: 'an empty SectionLabel is still a heading a screen reader stops on and reads out as nothing',
      );
      handle.dispose();
    });

    testWidgets('an empty string is the same as none — a caller passing one is not punished', (tester) async {
      await pump(tester, ScreenHeader(label: '', back: back()));

      expect(find.byType(SectionLabel), findsNothing);
    });
  });

  group('the trailing slot', () {
    testWidgets('**a pill that no longer fits beside the label drops below it**, uncapped', (tester) async {
      // The cap used to be the slot's contract: it stopped a value squeezing the label out of the
      // row they shared. Nothing squeezes anything now — a value that does not fit takes its own
      // line — and capping it there only made a pill wrap to three lines and push the screen under
      // it 35 px past the bottom in Russian (2026-09-12).
      await pump(
        tester,
        ScreenHeader(
          label: 'Сохранено три точки',
          trailingWidget: const StatusPill(label: 'Запись идёт прямо сейчас', tone: .alert),
          back: back(),
        ),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getCenter(find.byType(StatusPill)).dy,
        greaterThan(tester.getCenter(find.text('СОХРАНЕНО ТРИ ТОЧКИ')).dy),
      );
      expect(
        tester.getSize(find.byType(StatusPill)).width,
        greaterThan(AppTarget.trailingMax),
        reason: 'on its own line the value is given the width it has rather than a row cap',
      );
    });

    testWidgets('a value with no label to share with is capped all the same', (tester) async {
      // The one slot that still needs the cap: there is no label to protect and no line to drop
      // to, so an unbounded pill would lay out at its natural width and overflow the row.
      await pump(
        tester,
        ScreenHeader(
          trailingWidget: const StatusPill(label: 'Запись идёт прямо сейчас', tone: .alert, maxLines: 1),
          back: back(),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(StatusPill)).width, lessThanOrEqualTo(AppTarget.trailingMax));
    });

    testWidgets('once it no longer fits, the value drops UNDER the label, not into it', (tester) async {
      await pump(tester, ScreenHeader(label: 'Hunt', trailing: 'Aug 29', back: back()), textScale: 2);

      expect(tester.getCenter(find.text('Aug 29')).dy, greaterThan(tester.getCenter(find.text('HUNT')).dy));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an action never stacks: it keeps its size at every scale', (tester) async {
      await pump(
        tester,
        ScreenHeader(label: 'Checklist', action: const GaugeRing(size: 28), back: back()),
        textScale: 2,
      );

      expect(tester.getSize(find.byType(GaugeRing)).width, equals(28));
      expect(tester.takeException(), isNull);
    });
  });

  /// **The headline form's two halves are one rule, so they are tested as a pair.** The slot is
  /// floored at the band's height: a title that fits has room to be centred in, and one that has
  /// wrapped has none, which leaves it at the top where the row's `.start` meets it. Neither case
  /// is a branch in the widget, so a test that only covered one would not notice the other break.
  group('the headline against the arrow', () {
    testWidgets("**one line sits on the arrow's centre line**, not above it", (tester) async {
      // The headline form kept `crossAxisAlignment: .start` after the overline form was fixed, so a
      // ~28 px title's TOP met a 48 px button whose glyph sits at y≈24, and the title came out
      // roughly ten pixels high of the arrow on every screen whose name is the first thing said.
      await pump(tester, ScreenHeader.headline(back: back(), child: const Text('Settings')));

      expect(tester.getSize(find.byType(ScreenHeader)).height, equals(AppTarget.tap));
      expect(
        tester.getCenter(find.text('Settings')).dy,
        closeTo(tester.getCenter(find.byType(Icon)).dy, 1),
        reason: "the band is the arrow's 48 dp target and a one-line title has to sit in the middle of it",
      );
    });

    testWidgets('one that outgrows the band wraps beside the arrow instead of dragging it down', (tester) async {
      await pump(
        tester,
        ScreenHeader.headline(
          back: back(),
          child: const Text('Разблокируйте отчёт для сантехника прямо сейчас'),
        ),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(ScreenHeader)).height,
        greaterThan(AppTarget.tap),
        reason: 'the case under test is a headline the band cannot hold',
      );
      expect(
        tester.getTopLeft(find.byType(Text)).dy,
        closeTo(tester.getTopLeft(find.byType(IconButton)).dy, 1),
        reason: 'no room left to centre in, so the words start at the arrow and grow downward past it',
      );
    });
  });
}

/// Every widget that declares itself this screen's heading.
final Finder _headings = find.byWidgetPredicate(
  (widget) => widget is Semantics && (widget.properties.header ?? false),
  description: 'a heading',
);
