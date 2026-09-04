import 'dart:math' as math;

import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// A sweeping ring that can hold a [child] at its centre.
///
/// For progress with no percentage to report; the [child] names the step. The sweep stops under
/// Reduce Motion, see [AppMotion.ambientEnabled].
class GaugeRing extends StatefulWidget {
  /// Creates a [GaugeRing].
  const GaugeRing({
    this.size = 64,
    this.child,
    super.key,
  });

  /// Side length in logical pixels.
  final double size;

  /// What sits at the centre of the ring.
  final Widget? child;

  @override
  State<GaugeRing> createState() => _GaugeRingState();
}

class _GaugeRingState extends State<GaugeRing> with SingleTickerProviderStateMixin {
  late final AnimationController _sweepController;
  late final Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _curvedAnimation = CurvedAnimation(
      parent: _sweepController,
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Held still rather than hidden: the ring still says "working".
    if (AppMotion.ambientEnabled(context)) {
      if (!_sweepController.isAnimating) _sweepController.repeat();
    } else if (_sweepController.isAnimating) {
      _sweepController.stop();
    }
    return Center(
      child: SizedBox.square(
        dimension: widget.size,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _GaugeRingPainter(
              animation: _curvedAnimation,
              color: theme.progressIndicatorTheme.color ?? theme.colorScheme.primary,
            ),
            child: Center(
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugeRingPainter extends CustomPainter {
  _GaugeRingPainter({required Animation<double> animation, required Color color})
    : _animation = animation,
      _arcPaint = Paint()
        ..strokeCap = .round
        ..style = .stroke
        ..color = color,
      super(repaint: animation);

  final Animation<double> _animation;

  final Paint _arcPaint;

  @override
  void paint(Canvas canvas, Size size) {
    _arcPaint.strokeWidth = size.shortestSide / 8;
    final progress = _animation.value;
    final rect = Rect.fromCircle(
      center: size.center(.zero),
      radius: size.shortestSide / 2 - _arcPaint.strokeWidth / 2,
    );
    final rotate = math.pow(progress, 2) * math.pi * 2;
    final sweep = math.sin(progress * math.pi) * 3 + math.pi * 0.25;

    canvas.drawArc(rect, rotate, sweep, false, _arcPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugeRingPainter oldDelegate) => _animation.value != oldDelegate._animation.value;

  @override
  bool shouldRebuildSemantics(covariant _GaugeRingPainter oldDelegate) => false;
}
