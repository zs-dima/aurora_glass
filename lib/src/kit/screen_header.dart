// The header and the label-value pair are one part: the pair exists because the header needed it,
// and a card that carries the same pair imports both together.
// ignore_for_file: prefer-single-widget-per-file
import 'package:aurora_glass/src/kit/signals.dart';
import 'package:aurora_glass/src/kit/surfaces.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The visible way back, for the [ScreenHeader.back] slot and for a screen that has no header.
///
/// The system gesture keeps working — this exists because on gesture-nav Android and on iOS there
/// is no visible chrome at all, and a screen with no on-screen way back reads as a dead end.
///
/// **[onPressed] is required and there is no default**, which is the whole reason this is a kit
/// part rather than a copy in each app: the icon, its RTL mirroring and the tooltip are the same
/// everywhere, and HOW an app pops is the one thing that is not. Material's own [BackButton] pops
/// the Navigator directly, which is wrong for any app that navigates by a state object.
class AppBackButton extends StatelessWidget {
  /// Creates an [AppBackButton].
  const AppBackButton({required this.onPressed, this.tooltip, super.key});

  /// What "back" means in this app.
  final VoidCallback onPressed;

  /// Overrides the platform's own word for it. Null takes [MaterialLocalizations], which is
  /// localized without an ARB row of its own.
  final String? tooltip;

  @override
  Widget build(BuildContext context) => IconButton(
    // Auto-mirrored for RTL by the icon registry.
    icon: const Icon(Icons.arrow_back),
    tooltip: tooltip ?? MaterialLocalizations.of(context).backButtonTooltip,
    onPressed: onPressed,
  );
}

/// The one line at the top of a screen: the way back, what the screen is, and one value.
///
/// **Four apps of the line wrote this, in two incompatible shapes, and each had a bug the others
/// did not.** BreakerSonar took widget slots, a `back` flag and a capped trailing cell;
/// DoctorNoise, LeakSonar and PipeGuard took strings and stacked the value under the label past
/// 1.3×. PipeGuard's alone marked the label as a heading and guarded against an empty one;
/// LeakSonar's alone had `crossAxisAlignment: .start`, which put a 14 px overline against a 48 px
/// icon and left the label floating ~17 px above the arrow on every screenshot the store shipped.
/// This is all four, merged (2026-09-12): PipeGuard's slots and semantics, BreakerSonar's [back]
/// and band height, and the alignment fixed once.
///
/// The slots yield differently on purpose:
///
/// - [label] is the overline. It ellipsizes, because a translation is the thing that can shrink.
/// - [trailing] / [trailingWidget] is the value that belongs to the screen as a whole rather than
///   to any section of it — a date, a count, a status pill. It is capped at
///   [AppTarget.trailingMax] and drops UNDER the label past the one-row scale instead of squeezing
///   the label to nothing.
/// - [action] is a control that must keep its size at every scale, such as a progress ring. It
///   never stacks, so pass only something narrow and bounded.
///
/// **A gutter arrow is not offered.** An arrow inset into a screen's side padding is drawable, and
/// then untappable in the inset half: an ancestor's `hitTest` checks `size.contains` before it
/// descends, so a child painted outside the parent's box takes no pointer. Only a bar that owns
/// its own insets can do it, and this is a row inside the content column.
class ScreenHeader extends StatelessWidget {
  /// Creates a [ScreenHeader].
  const ScreenHeader({this.label, this.trailing, this.trailingWidget, this.action, this.back, super.key})
    : assert(trailing == null || trailingWidget == null, 'A header carries one value, as text or as a widget'),
      _headline = null;

  /// The arrow beside a screen's HEADLINE rather than its overline.
  ///
  /// For the screens whose title is the first thing said rather than a label over something else —
  /// a paywall whose gradient headline is already the screen's name, where an overline beside it
  /// would say the same thing twice.
  const ScreenHeader.headline({required Widget child, this.back, super.key})
    : _headline = child,
      label = null,
      trailing = null,
      trailingWidget = null,
      action = null;

  /// The overline, upper-cased by [SectionLabel] as everywhere else.
  ///
  /// Null — or empty — renders the value alone, and no heading node at all: an empty
  /// `SectionLabel` is still a heading a screen reader announces, saying nothing.
  final String? label;

  /// Optional right-hand value, already localized.
  final String? trailing;

  /// Optional right-hand widget — a [StatusPill], a chip. Mutually exclusive with [trailing].
  ///
  /// Laid out [Flexible] under the same cap as [trailing]: a pill's own `maxLines` only bites
  /// under a bounded width, so an unbounded slot would let it lay out at its natural size and
  /// overflow the row instead of ellipsizing.
  final Widget? trailingWidget;

  /// Optional fixed-size control at the end of the row, which never stacks under the label.
  final Widget? action;

  /// The way back. Null draws no arrow and keeps the band, so screens do not shift against each
  /// other — and so a flow that must not be left by a single tap can omit it deliberately.
  final Widget? back;

  final Widget? _headline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headline = _headline;
    final back = this.back;

    if (headline != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppTarget.tap),
        child: Row(
          spacing: AppSpacing.xs,
          crossAxisAlignment: .start,
          children: <Widget>[
            ?back,
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTarget.tap),
                child: Align(alignment: AlignmentDirectional.centerStart, heightFactor: 1, child: headline),
              ),
            ),
          ],
        ),
      );
    }

    final trailing = this.trailing;
    final base = theme.textTheme.labelSmall;
    final value =
        trailingWidget ??
        (trailing == null
            ? null
            // [SectionLabel]'s metrics, one role dimmer and a shade lighter, so the two read as one
            // optical line. Not upper-cased: a date is not a label, and "JAN 14" reads as shouting
            // where "Jan 14" reads as a fact.
            : Text(
                trailing,
                maxLines: 1,
                softWrap: false,
                overflow: .ellipsis,
                textAlign: .end,
                style: base?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: .w600,
                  letterSpacing: (base.fontSize ?? 12) * 0.14,
                ),
              ));

    return ConstrainedBox(
      // The arrow is a 48 dp target; a header without one keeps the same band.
      constraints: const BoxConstraints(minHeight: AppTarget.tap),
      child: Row(
        spacing: AppSpacing.xs,
        // **Centre, and this is the fix.** The row holds a 48 px icon button whose glyph sits at
        // y≈24 and a ~14 px overline whose line sits at y≈7, so `.start` aligns their TOPS and
        // leaves the label hanging seventeen pixels above the arrow it belongs to.
        crossAxisAlignment: .center,
        children: <Widget>[
          ?back,
          Expanded(
            child: LabelWithValue(label: label, value: value),
          ),
          // A constant slot, so a control that arrives with the screen's first result does not
          // re-index the row.
          ?action,
        ],
      ),
    );
  }
}

/// An overline with a value beside it — and beneath it instead, once the two stop fitting.
///
/// **The rule lives here because two kinds of place need it**: a screen header, and a card that
/// carries the same pair. The arrow is a fixed 48, a date or a chip is a fixed width at a given
/// text size, and a translated label is not — so there is always a row where the two no longer
/// share a line, and no amount of ellipsis saves it, because the thing that does not fit is not
/// the thing that can shrink.
///
/// **"Once they stop fitting" is a layout question, so the layout answers it.** It used to be
/// guessed from the text scaler, which knows nothing about either width: on a 360 pt phone, with
/// the value at its old 160 px cap, the label was handed exactly 88 px — the leftover after the
/// arrow and two gaps — at EVERY scale up to the threshold, however long the translation was, and
/// then 256 px one hundredth of a scale step later. A [Wrap] asks the only question that decides
/// it — do these two, at these widths, in this language, fit this row — and it asks it of the
/// widths actually on screen.
class LabelWithValue extends StatelessWidget {
  /// Creates a [LabelWithValue].
  const LabelWithValue({this.label, this.value, super.key});

  /// The overline, upper-cased by [SectionLabel] as everywhere else.
  final String? label;

  /// The value that belongs beside it — a date, a count, a chip — already styled and localized.
  final Widget? value;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    final label = this.label;
    final text = label != null && label.isNotEmpty ? label : null;
    // Nothing to say beside the arrow — a centred body whose words belong in the middle of the
    // screen. An empty [SectionLabel] here would be a heading node announcing nothing, which a
    // screen reader reads out as a heading all the same. And a header that is its VALUE alone
    // starts the row rather than being pushed to the far edge by an empty label.
    if (text == null && value == null) return const SizedBox.shrink();
    if (text == null)
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: _Capped(child: value!),
      );
    if (value == null) return _Heading(text);

    // **The rule IS a wrap, so it is one.** Beside while both fit, beneath once they stop —
    // decided by the widths actually on screen, which is the only thing that can answer it: the
    // label is a translation and the value is a date or a pill, and whether the two fit is a fact
    // about this row in this language, not about the text scale.
    //
    // [WrapAlignment.spaceBetween] is what keeps the value at the far edge while the pair share a
    // line, and puts the label at the start once they do not — a run of one has nothing to space.
    return Wrap(
      alignment: .spaceBetween,
      // A date or a pill against the overline reads as one optical line.
      crossAxisAlignment: .center,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[_Heading(text), value],
    );
  }
}

/// The overline, marked as this screen's heading so a screen reader can jump to it.
///
/// Heading semantics are the one thing an `AppBar` would have given for free, and the reason they
/// are worth writing by hand: a screen whose title is not a heading is a screen a rotor cannot
/// navigate to.
class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(header: true, child: SectionLabel(text, maxLines: 1));
}

/// The cap on a value that has no label beside it.
///
/// **This is the last place that needs one.** The cap used to guard the shared row — a value that
/// grew past it squeezed the label out — but a [Wrap] moves the value to its own line instead of
/// squeezing anything, so capping it there only made a status pill wrap to three lines and pushed
/// the screen under it 35 px past the bottom at 2.0× in Russian (2026-09-12). A value standing
/// alone has no label to protect and nothing to wrap to, so it keeps the bound.
class _Capped extends StatelessWidget {
  const _Capped({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: AppTarget.trailingMax),
    child: child,
  );
}
