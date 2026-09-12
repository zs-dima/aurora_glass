import 'package:aurora_glass/src/theme/brand.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The page itself: the 165° base gradient and exactly two radial glows, edge to edge.
///
/// [AppScaffold] paints it behind every screen. It is a widget of its own because a SECOND thing
/// needs it — a pinned header has to hide the rows passing under it, and over this background no
/// flat colour can. Measured on a shipped render at 390×844: across the band a header occupies the
/// page runs `#0d142e` at the leading edge, `#2e2b5c` two thirds across and `#171a3a` at the
/// trailing edge — a 46-level swing — and steps another ~13 levels at the band's lower edge. The
/// cause is [AppGlow.primaryTop] of -150 against [AppGlow.primarySize] of 430, which puts the upper
/// glow's CENTRE at y≈65, inside the band. A header painted in any single colour shows a seam
/// there; a header that paints THIS, clipped to its own height and anchored to the window, is
/// indistinguishable from the page it covers. See `SliverScreenHeader`.
///
/// The glows do not move; any animation of them must honour [AppMotion.ambientEnabled].
class AppBackground extends StatelessWidget {
  /// Creates an [AppBackground].
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);

    // Expanded rather than sized by its children: the glows are all positioned, so a bare Stack
    // under loose constraints — which is what a clipped slice hands it — would collapse to nothing.
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: brand.base),
        child: Stack(
          children: <Widget>[
            PositionedDirectional(
              top: AppGlow.primaryTop,
              end: AppGlow.primaryTrailing,
              child: _Glow(color: brand.glowPrimary, size: AppGlow.primarySize),
            ),
            PositionedDirectional(
              bottom: AppGlow.secondaryBottom,
              start: AppGlow.secondaryLeading,
              child: _Glow(color: brand.glowSecondary, size: AppGlow.secondarySize),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    // A full-screen radial gradient is expensive to rasterise and everything animates on top of it.
    child: RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: .circle,
            gradient: RadialGradient(
              colors: <Color>[color, color.withValues(alpha: 0)],
              stops: const <double>[0, AppGlow.fadeStop],
            ),
          ),
        ),
      ),
    ),
  );
}
