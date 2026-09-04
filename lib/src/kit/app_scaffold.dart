import 'package:aurora_glass/src/adaptive/content_pane.dart';
import 'package:aurora_glass/src/theme/brand.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The chassis every screen sits in: the 165° base gradient plus exactly two radial glows.
///
/// The gradient and the glows are painted outside the [Scaffold], edge to edge and under the
/// status bar. The body gets the whole window, insets included: the screen applies the content
/// column itself, with [SliverContentPane] inside a `CustomScrollView`, [ContentPane] around static
/// content or [SliverContentFill] for a block that centres until it has to scroll.
///
/// The glows do not move; any animation of them must honour [AppMotion.ambientEnabled].
class AppScaffold extends StatelessWidget {
  /// Creates an [AppScaffold].
  const AppScaffold({required this.child, this.appBar, super.key});

  /// Screen content, laid out against the full window.
  final Widget child;

  /// Optional top bar, rendered transparent over the gradient.
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);

    return DecoratedBox(
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
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: child,
          ),
        ],
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
