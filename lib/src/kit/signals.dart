// One file per kit category.
// ignore_for_file: prefer-single-widget-per-file
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
  const StatusPill({required this.label, this.tone = AppTone.accent, this.pulse = false, super.key});

  /// Chip text, rendered upper-case.
  final String label;

  /// Semantic tone.
  final AppTone tone;

  /// Whether to show the live dot.
  final bool pulse;

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
              _Dot(color: color, animate: AppMotion.ambientEnabled(context)),
              const SizedBox(width: 6),
            ] else ...<Widget>[
              Icon(tone.icon, size: 14, color: color),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
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

class _Dot extends StatefulWidget {
  const _Dot({required this.color, required this.animate});

  final Color color;
  final bool animate;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _Dot oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reduce Motion can be toggled while the app is open.
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    // Its own layer: the ticker runs while the pill is on screen, inside a card with a 50 px shadow.
    child: FadeTransition(
      opacity: widget.animate ? _controller.drive(Tween<double>(begin: 0.35, end: 1)) : const AlwaysStoppedAnimation(1),
      child: SizedBox.square(
        dimension: 8,
        child: DecoratedBox(
          decoration: BoxDecoration(color: widget.color, shape: .circle),
        ),
      ),
    ),
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
    return Container(
      padding: const .all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: AppShape.row,
        border: .all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: <Widget>[
          Icon(tone.icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
          if (action case final String label)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: color, minimumSize: const Size(0, AppTarget.tap)),
              child: Text(label),
            ),
        ],
      ),
    );
  }
}
