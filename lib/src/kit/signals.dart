// One file per kit category.
// ignore_for_file: prefer-single-widget-per-file
import 'package:aurora_glass/src/kit/data_displays.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// Semantic tone. Colour is never the only signal: every [StatusPill] and [InfoBanner] carries an
/// icon and text as well.
enum AppTone {
  /// Success, confirmed.
  ok,

  /// Warning, risk.
  alert,

  /// Neutral but notable, drawn in the brand accent.
  accent;

  /// Foreground colour for this tone.
  Color on(ColorScheme scheme) => switch (this) {
    ok => scheme.tertiary,
    alert => scheme.error,
    accent => scheme.primary,
  };

  /// The icon that carries the meaning when colour cannot.
  IconData get icon => switch (this) {
    ok => Icons.check_circle_outline,
    alert => Icons.warning_amber_rounded,
    accent => Icons.bolt_outlined,
  };
}

/// A compact status chip: 30 px minimum, 10% tint, 35% border, capitals.
///
/// The optional [pulse] dot is ambient motion and stops under Reduce Motion.
class StatusPill extends StatelessWidget {
  /// Creates a [StatusPill].
  const StatusPill({
    required this.label,
    this.tone = AppTone.accent,
    this.pulse = false,
    this.maxLines,
    super.key,
  });

  /// Chip text, rendered upper-case.
  final String label;

  /// Semantic tone.
  final AppTone tone;

  /// Whether to show the live dot.
  final bool pulse;

  /// Cap on rendered lines; the label ellipsizes past it. Null lets it wrap freely, as before.
  ///
  /// A status word has no space to wrap at, so a pill that outgrows its row breaks MID-WORD.
  /// That is only visible where the pill shares a row — on a header line beside a back arrow and a
  /// trailing value — and there the second line pushes the row's height out. Callers in that
  /// position pass 1, as they do for [SectionLabel].
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tone.on(theme.colorScheme);
    final labelStyle = theme.textTheme.labelSmall;
    return Semantics(
      // Announce the human-cased label once instead of the upper-cased visual string.
      container: true,
      excludeSemantics: true,
      label: label,
      child: Container(
        // A minimum: a capitalised status in Russian at 2x type wraps to two lines.
        constraints: const BoxConstraints(minHeight: 30),
        padding: const .symmetric(horizontal: AppSpacing.sm, vertical: 4),
        // A stadium stays a pill at any height.
        decoration: ShapeDecoration(
          color: color.withValues(alpha: 0.1),
          shape: AppShape.pill.copyWith(side: BorderSide(color: color.withValues(alpha: 0.35))),
        ),
        child: Row(
          mainAxisSize: .min,
          children: <Widget>[
            if (pulse) ...<Widget>[
              StatusDot(tone: tone, size: 8, pulse: true, glow: false),
              const SizedBox(width: 6),
            ] else ...<Widget>[
              Icon(tone.icon, size: 14, color: color),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: maxLines,
                overflow: maxLines == null ? null : .ellipsis,
                style: labelStyle?.copyWith(
                  color: color,
                  fontWeight: .w700,
                  // The same +14% tracking as the section label.
                  letterSpacing: (labelStyle.fontSize ?? 12) * 0.14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dot on an icon: something is here, nothing more.
///
/// A dot rather than a count. The number still has to reach a screen reader, so the caller puts
/// it in the button's tooltip and semantic label.
class IconBadge extends StatelessWidget {
  /// Creates an [IconBadge].
  const IconBadge({required this.child, this.visible = true, this.tone = AppTone.alert, super.key});

  /// The icon the dot sits on.
  final Widget child;

  /// Whether to draw the dot.
  final bool visible;

  /// Semantic tone of the dot.
  final AppTone tone;

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: visible,
    smallSize: 8,
    backgroundColor: tone.on(Theme.of(context).colorScheme),
    child: child,
  );
}

/// An inline banner for a state the user must see without a modal getting in the way.
class InfoBanner extends StatelessWidget {
  /// Creates an [InfoBanner].
  const InfoBanner({required this.message, this.tone = AppTone.accent, this.action, this.onAction, super.key});

  /// Banner copy.
  final String message;

  /// Semantic tone.
  final AppTone tone;

  /// Optional action label.
  final String? action;

  /// Action handler.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = tone.on(scheme);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: AppShape.row,
        border: .all(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: AppSpacing.sm, vertical: 3),
        child: Row(
          crossAxisAlignment: .center,
          spacing: AppSpacing.sm,
          children: <Widget>[
            // const SizedBox(width: AppSpacing.sm),
            Padding(
              padding: const .only(bottom: AppSpacing.sm, top: AppSpacing.sm),
              child: Icon(tone.icon, size: 20, color: color),
            ),
            // **The action drops UNDER the message instead of squeezing it.** It was a bare
            // `TextButton` beside an `Expanded`: an unconstrained child next to a flexible one, so
            // at 2.0× in a long language the button kept its natural width, the message shrank to
            // nothing, and the row overflowed anyway — one app grew a private wrapper widget for the
            // sole purpose of avoiding this banner (2026-09-12).
            //
            // The choice is made on the SCALER and not by measuring, the same rule and the same
            // threshold [LabelWithValue] uses: cheap, deterministic, and it cannot depend on which
            // language happened to be on screen when somebody looked.
            Expanded(
              child: switch ((action, MediaQuery.textScalerOf(context).scale(1) > _kBannerOneRowScale)) {
                (null, _) => Text(message, style: Theme.of(context).textTheme.bodyMedium),
                (final String label, true) => Column(
                  crossAxisAlignment: .start,
                  children: <Widget>[
                    Text(message, style: Theme.of(context).textTheme.bodyMedium),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _BannerAction(label: label, color: color, onPressed: onAction),
                    ),
                  ],
                ),
                (final String label, false) => Row(
                  children: <Widget>[
                    Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
                    _BannerAction(label: label, color: color, onPressed: onAction),
                  ],
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// An [InfoBanner]'s action, which is a [TextButton] with the banner's tone and a real tap target.
class _BannerAction extends StatelessWidget {
  const _BannerAction({required this.label, required this.color, required this.onPressed});

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: color,
      // tapTargetSize: .shrinkWrap,
      minimumSize: const Size(0, AppTarget.tap),
      padding: const .symmetric(horizontal: AppSpacing.sm),
    ),
    child: Text(label, maxLines: 2, textAlign: .center),
  );
}

/// The largest text scale a banner's message and its action still fit on one row at.
///
/// The same 1.3 [LabelWithValue] uses, measured the same way: at 2.0× on a 320 dp phone a Russian
/// message beside an action wants about 55 px more than the row has.
const double _kBannerOneRowScale = 1.3;
