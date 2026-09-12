// One file per kit category.
// ignore_for_file: prefer-single-widget-per-file
import 'package:aurora_glass/src/kit/signals.dart';
import 'package:aurora_glass/src/theme/brand.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/foundation.dart' show ValueListenable, listEquals;
import 'package:flutter/material.dart';

/// How much of the surface a [ProgressBar] is allowed to claim.
enum ProgressBarEmphasis {
  /// One row among many: a tinted fill that deepens with the value.
  normal,

  /// The one row that matters: the brand gradient, with the glow under it.
  featured,
}

/// A horizontal bar for a value between 0 and 1.
///
/// **A comparison, not an indicator.** Material's `LinearProgressIndicator` says "something is
/// happening"; this says "this one is bigger than that one", which is what a list of measurements
/// needs — the bars share an origin and a scale, so the ranking is readable before a single number
/// is. The gallery has named this part since 0.1.0 and four apps drew their own.
///
/// M3's stop-dot idiom is deliberately absent: a dot at the end of the track reads as a data point
/// on a chart bar, which is the one thing this must not look like.
class ProgressBar extends StatelessWidget {
  /// Creates a [ProgressBar].
  const ProgressBar({
    required this.value,
    this.emphasis = ProgressBarEmphasis.normal,
    this.height = 8,
    this.semanticsLabel,
    super.key,
  });

  /// The fraction filled, clamped to 0..1. A NaN — which a `0 / 0` upstream produces — draws empty.
  final double value;

  /// How loudly this bar is drawn.
  final ProgressBarEmphasis emphasis;

  /// Track thickness in logical pixels.
  final double height;

  /// What a screen reader says, or null where the row around it already says it.
  ///
  /// Null excludes the bar entirely rather than leaving an unlabelled node: a bar is a second
  /// reading of a number that is almost always written beside it.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<Brand>();
    final indicator = theme.progressIndicatorTheme;
    final fraction = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final accent = indicator.color ?? brand?.accentText ?? theme.colorScheme.primary;

    final bar = ClipRRect(
      borderRadius: .circular(height / 2),
      child: SizedBox(
        height: height,
        child: ColoredBox(
          color: indicator.linearTrackColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.07),
          child: Align(
            // Directional, so the bar fills from the leading edge in Arabic as well as in English.
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: fraction,
              // **`heightFactor`, or the fill is invisible.** A childless `DecoratedBox` under
              // loose height constraints takes the SMALLEST size it is allowed — zero — so the bar
              // laid out at the right width and painted nothing, and every row showed its empty
              // track. It shipped in a store screenshot that way (2026-09-12).
              heightFactor: 1,
              child: DecoratedBox(
                decoration: switch (emphasis) {
                  // The fill deepens with the value, so a row's weight reads before its width does.
                  .normal => BoxDecoration(color: accent.withValues(alpha: fraction * 0.3 + 0.4)),
                  // Without a `Brand` — a bare mount, a golden — the gradient and its glow have no
                  // colours to be made of, and a solid accent fill is the honest degradation.
                  .featured => BoxDecoration(
                    color: brand == null ? accent : null,
                    gradient: brand?.cta,
                    boxShadow: brand == null
                        ? null
                        // Clipped to the track by the `ClipRRect` above: the glow belongs to the
                        // filled part, not to the row.
                        : <BoxShadow>[BoxShadow(color: brand.pairStart.withValues(alpha: 0.7), blurRadius: 14)],
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );

    return semanticsLabel == null
        ? ExcludeSemantics(child: bar)
        : Semantics(
            label: semanticsLabel,
            value: '${(fraction * 100).round()}%',
            child: ExcludeSemantics(child: bar),
          );
  }
}

/// A row of vertical bars: a signal over time, or a spectrum at one moment.
///
/// Two constructors, and the difference is who owns the clock. The default takes a snapshot and
/// rebuilds with its parent — for a gallery, a golden, a still figure. [LevelBars.live] takes a
/// [ValueListenable] and repaints from it without rebuilding anything, which is the only shape
/// that works for an audio meter: a frame arrives every ~46 ms, and rebuilding a screen's widget
/// tree that often to move 25 rectangles is how a meter costs more than the capture behind it.
/// The same split [GaugeRing] makes.
class LevelBars extends StatelessWidget {
  /// Creates a [LevelBars] over a fixed list of values, each 0..1.
  const LevelBars({
    required List<double> values,
    this.height = 52,
    this.minFraction = 0.08,
    this.semanticsLabel,
    super.key,
    // Named for the caller and held privately: the two constructors store different things, and
    // an initialising formal cannot rename.
    // ignore: prefer_initializing_formals
  }) : _values = values,
       _trail = null;

  /// Creates a [LevelBars] that repaints from [trail] without rebuilding.
  const LevelBars.live({
    required ValueListenable<List<double>> trail,
    this.height = 52,
    this.minFraction = 0.08,
    this.semanticsLabel,
    super.key,
    // ignore: prefer_initializing_formals — the name is public and the field is private
  }) : _trail = trail,
       _values = null;

  /// Overall height in logical pixels; the tallest bar fills it.
  final double height;

  /// How tall a zero reads. Silence is a row of stubs rather than a blank strip, because a blank
  /// strip is indistinguishable from a meter that is not running.
  final double minFraction;

  /// What a screen reader says, or null to exclude the bars entirely.
  final String? semanticsLabel;

  final List<double>? _values;
  final ValueListenable<List<double>>? _trail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<Brand>();
    final trail = _trail;

    final bars = RepaintBoundary(
      child: CustomPaint(
        size: Size.fromHeight(height),
        painter: _LevelBarsPainter(
          values: _values ?? const <double>[],
          trail: trail,
          minFraction: minFraction,
          gradient: brand?.cta,
          fallback: theme.colorScheme.primary,
        ),
        child: SizedBox(height: height, width: .infinity),
      ),
    );

    return semanticsLabel == null
        ? ExcludeSemantics(child: bars)
        : Semantics(label: semanticsLabel, excludeSemantics: true, child: bars);
  }
}

class _LevelBarsPainter extends CustomPainter {
  _LevelBarsPainter({
    required this.values,
    required this.trail,
    required this.minFraction,
    required this.gradient,
    required this.fallback,
  }) : super(repaint: trail);

  final List<double> values;
  final ValueListenable<List<double>>? trail;
  final double minFraction;

  /// The brand gradient, or null on a mount with no `Brand` in its theme.
  final Gradient? gradient;

  /// What the bars are painted in when there is no gradient.
  final Color fallback;

  @override
  void paint(Canvas canvas, Size size) {
    final levels = trail?.value ?? values;
    if (levels.isEmpty || size.width <= 0) return;
    final pitch = size.width / levels.length;
    // Seven twelfths of the pitch: the bar and the gap it sits in, as the artboards draw them.
    final width = pitch * 7 / 12;
    final radius = Radius.circular(width / 2 > 3 ? 3 : width / 2);
    final gradient = this.gradient;
    final paint = gradient == null
        ? (Paint()..color = fallback)
        : (Paint()..shader = gradient.createShader(Offset.zero & size));

    for (final (index, raw) in levels.indexed) {
      final level = raw.isNaN ? 0.0 : raw.clamp(0.0, 1.0);
      final barHeight = size.height * (minFraction + (1 - minFraction) * level);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(index * pitch + (pitch - width) / 2, size.height - barHeight, width, barHeight),
          radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LevelBarsPainter oldDelegate) =>
      !listEquals(oldDelegate.values, values) ||
      oldDelegate.trail != trail ||
      oldDelegate.minFraction != minFraction ||
      oldDelegate.gradient != gradient ||
      oldDelegate.fallback != fallback;
}

/// One fact in a tile: what it is, and what it says right now.
///
/// The alternative is a list row, whose `tone` colours the TITLE — backwards here, because the
/// title is the constant and the value is the thing that changes, so "Charging" could never be
/// green and "On battery" could never be red. Colour is not the only signal either: a live value
/// carries a pulsing dot, a settled one carries its tone's icon.
///
/// **The caller owns the flex.** A tile that returned an `Expanded` from its own `build` — as one
/// app's copy did — cannot be placed anywhere but a row, and puts an incomprehensible parent-data
/// error in front of whoever tries.
class StatTile extends StatelessWidget {
  /// Creates a [StatTile].
  const StatTile({required this.label, required this.value, this.tone, this.live = false, super.key});

  /// What this tile is about. Constant.
  final String label;

  /// What it says now.
  final String value;

  /// The value's tone, or null where the value is neither good nor bad.
  final AppTone? tone;

  /// Whether the value is happening right now — a pulsing dot instead of the tone's icon.
  final bool live;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<Brand>();
    final semantic = tone;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: brand?.cardFill ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppShape.tile,
        border: .all(color: brand?.cardBorder ?? theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          spacing: 2,
          children: <Widget>[
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Row(
              crossAxisAlignment: .center,
              children: <Widget>[
                // Slots, not collection-ifs: a value going live must not re-create the row.
                Visibility(
                  visible: live && semantic != null,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 6, end: 6),
                    child: StatusDot(tone: semantic ?? .accent, size: 8, pulse: true),
                  ),
                ),
                Visibility(
                  visible: !live && semantic != null,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 2, end: 4),
                    child: Icon(semantic?.icon, size: 14, color: semantic?.on(theme.colorScheme)),
                  ),
                ),
                // No line cap: a wrapped translation is readable, an ellipsised one is not.
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(color: semantic?.on(theme.colorScheme)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A small tinted circle: a second reading of something the words already say.
///
/// A list of rows that all look alike — same shape, same date, a sentence that differs in its
/// middle — reads as a pattern once each row carries a dot. **Colour is never the only signal**:
/// every such row keeps its sentence, and this is excluded from semantics, so a screen reader gets
/// the words rather than "green".
///
/// A null [tone] is the deliberate absence of a verdict — a skipped night, a row nobody confirmed.
/// It draws in the outline colour and does not glow: the three tones all MEAN something, and
/// "nothing to say about this one" is not one of them.
class StatusDot extends StatefulWidget {
  /// Creates a [StatusDot].
  const StatusDot({this.tone, this.size = 9, this.pulse = false, this.glow = true, super.key});

  /// What this row ended as, or null for a row with no verdict.
  final AppTone? tone;

  /// Diameter, in logical pixels.
  final double size;

  /// Whether this dot is live. A still dot still marks the row.
  final bool pulse;

  /// Whether to draw the halo. Off inside a [StatusPill], whose border already frames the dot —
  /// a glow there would bloom against the tint rather than against the screen.
  final bool glow;

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  bool get _animate => widget.pulse && AppMotion.ambientEnabled(context);

  void _sync() {
    if (_animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!_animate && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce Motion can be toggled while the app is open.
    _sync();
  }

  @override
  void didUpdateWidget(covariant StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.tone?.on(scheme) ?? scheme.onSurfaceVariant;

    return RepaintBoundary(
      // Its own layer: the ticker runs for as long as the row is on screen.
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _animate
              ? _controller.drive(Tween<double>(begin: 0.35, end: 1))
              : const AlwaysStoppedAnimation<double>(1),
          child: SizedBox.square(
            // A fixed box, so a row's body starts at the same x whatever the dot says.
            dimension: widget.size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: .circle,
                boxShadow: widget.tone == null || !widget.glow
                    ? null
                    // The halo, which is what makes a 9 px dot legible on a dark ground.
                    : <BoxShadow>[BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 10)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
