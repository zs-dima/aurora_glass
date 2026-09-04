import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:aurora_glass/src/theme/brand.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A moving highlight, for placeholders and loading states.
///
/// Painted by a fragment shader on its own layer; a solid fill when the shader is unavailable.
/// The sweep stops under Reduce Motion.
class Shimmer extends LeafRenderObjectWidget {
  /// Creates a [Shimmer].
  const Shimmer({
    this.highlight,
    this.background,
    this.speed = 1.0,
    this.size,
    this.radius,
    this.stripe,
    super.key,
  });

  /// The highlight colour. Null takes [Brand.cardBorder].
  final Color? highlight;

  /// The colour behind the highlight. Null takes [Brand.cardFill].
  final Color? background;

  /// Sweep speed; 1.0 is the default.
  final double speed;

  /// The size to paint, or null to fill the parent.
  final Size? size;

  /// Corner radius, or null for square corners.
  final Radius? radius;

  /// Width of the highlight stripe, best between 0.5 and 1.0.
  final double? stripe;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final brand = Brand.of(context);
    return ShimmerRenderObject(
      highlight: highlight ?? brand.cardBorder,
      background: background ?? brand.cardFill,
      speed: speed,
      size: size,
      radius: radius,
      stripe: stripe,
      animate: !MediaQuery.disableAnimationsOf(context),
    );
  }

  @override
  // `update()` carries every constructor parameter as a required named argument.
  // ignore: consistent-update-render-object
  void updateRenderObject(BuildContext context, covariant ShimmerRenderObject renderObject) {
    final brand = Brand.of(context);
    renderObject.update(
      highlight: highlight ?? brand.cardBorder,
      background: background ?? brand.cardFill,
      speed: speed,
      size: size,
      radius: radius,
      stripe: stripe,
      animate: !MediaQuery.disableAnimationsOf(context),
    );
  }
}

/// The render object behind [Shimmer].
class ShimmerRenderObject extends RenderBox with WidgetsBindingObserver {
  /// Creates a [ShimmerRenderObject].
  ShimmerRenderObject({
    required this._highlight,
    required Color background,
    required this._speed,
    required bool animate,
    required Size? size,
    required this._radius,
    required this._stripe,
  }) : _background = background,
       _preferredSize = size,
       _paint = Paint() {
    _paint
      ..color = background
      ..style = .fill
      ..blendMode = .srcOver
      ..filterQuality = .low
      ..isAntiAlias = true;
    // No ticker yet; this records the flag and attach() honours it.
    _setAnimate(animate);
  }

  Color _highlight;

  Color _background;

  double _speed;

  Radius? _radius;

  double? _stripe;

  final Paint _paint;

  Ticker? _animationTicker;

  Size _laidOutSize = .zero;

  /// Bit 0: the app is not resumed. Bit 1: detached. Bit 2: reduced motion.
  int _activeFlag = 0;

  Duration _elapsed = .zero;

  /// The requested size, or null to fill the parent; [_laidOutSize] is what layout chose.
  Size? _preferredSize;

  /// Repaints every frame, so whatever it sits inside must not repaint with it.
  @override
  bool get isRepaintBoundary => true;

  @override
  // ignore: match-getter-setter-field-names
  Size get size => _laidOutSize;

  @override
  set size(Size value) {
    final prev = hasSize ? size : null;
    if (prev == value) return;
    super.size = value;
    // ignore: match-getter-setter-field-names
    _laidOutSize = value;
  }

  /// Applies new widget parameters.
  void update({
    required Color highlight,
    required Color background,
    required double speed,
    required Size? size,
    required Radius? radius,
    required double? stripe,
    required bool animate,
  }) {
    _setAnimate(animate);
    if (size != _preferredSize) {
      markNeedsLayout();
    }
    _highlight = highlight;
    _background = background;
    _speed = speed;
    _preferredSize = size;
    _radius = radius;
    _stripe = stripe;
    _paint.color = background;
    markNeedsPaint();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    const lifecycleFlag = 1 << 0;
    state == .resumed ? _activeFlag &= ~lifecycleFlag : _activeFlag |= lifecycleFlag;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _activeFlag &= ~(1 << 1);
    WidgetsBinding.instance.addObserver(this);

    _ShimmerShaderManager.setShader(_paint);
    const reducedMotionFlag = 1 << 2;
    final ticker = _animationTicker = Ticker(_onTick);
    if (_activeFlag & reducedMotionFlag == 0) ticker.start();
  }

  @override
  @protected
  void detach() {
    super.detach();
    _activeFlag |= 1 << 1;
    // Nulled as well as disposed: `Ticker.start()` asserts on a disposed ticker, and
    // `_setAnimate` can run on a detached render object when Reduce Motion is toggled.
    _animationTicker?.dispose();
    _animationTicker = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => false;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) => switch (_preferredSize) {
    final Size s => constraints.constrain(s),
    _ => constraints.biggest,
  };

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  void performResize() {
    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final size = this.size;
    if (size.isEmpty) return;

    final canvas = context.canvas
      ..save()
      ..translate(offset.dx, offset.dy);

    if (_radius case final Radius radius when radius != .zero) {
      canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & size, _radius ?? .zero));
    } else {
      canvas.clipRect(Offset.zero & size);
    }

    if (_paint.shader case final ui.FragmentShader shader) {
      final seed = _elapsed.inMicroseconds * _speed / 200000;
      _paint.shader = shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, seed)
        ..setFloat(3, _highlight.r)
        ..setFloat(4, _highlight.g)
        ..setFloat(5, _highlight.b)
        ..setFloat(6, _highlight.a)
        ..setFloat(7, _background.r)
        ..setFloat(8, _background.g)
        ..setFloat(9, _background.b)
        ..setFloat(10, _background.a)
        ..setFloat(11, _stripe ?? 0.75);
      canvas.drawRect(Offset.zero & size, _paint);
    } else {
      canvas.drawRect(Offset.zero & size, _paint);
    }

    canvas.restore();
  }

  /// Reduced motion freezes the sweep and stops the ticker.
  void _setAnimate(bool animate) {
    const reducedMotionFlag = 1 << 2;
    if (animate) {
      _activeFlag &= ~reducedMotionFlag;
      final ticker = _animationTicker;
      if (ticker != null && !ticker.isActive) ticker.start();
    } else {
      _activeFlag |= reducedMotionFlag;
      _animationTicker?.stop();
    }
  }

  void _onTick(Duration elapsed) {
    _elapsed = elapsed;
    if (_activeFlag != 0) return;
    markNeedsPaint();
  }
}

abstract final class _ShimmerShaderManager {
  static final Future<ui.FragmentProgram?> _$loadfragmentProgramOnce = _$loadfragmentProgram();
  static ui.FragmentProgram? _$fragmentProgram;

  /// Installs the shimmer shader on [paint], now or once it has loaded.
  static void setShader(Paint paint) {
    if (_$fragmentProgram case final ui.FragmentProgram program) {
      paint
        ..shader = program.fragmentShader()
        ..blendMode = .src
        ..filterQuality = .low
        ..isAntiAlias = false;
    } else {
      _$loadfragmentProgramOnce.then((p) {
        if (p == null) return;
        paint
          ..shader = p.fragmentShader()
          ..blendMode = .src
          ..filterQuality = .low
          ..isAntiAlias = false;
      }).ignore();
    }
  }

  static Future<ui.FragmentProgram?> _$loadfragmentProgram() async {
    const asset = 'packages/aurora_glass/shaders/shimmer.frag';
    try {
      return _$fragmentProgram = await ui.FragmentProgram.fromAsset(asset).timeout(const Duration(seconds: 5));
      // ignore: avoid_catching_errors
    } on UnsupportedError {
      return null; // The HTML renderer and other platforms without shader support.
    } catch (e, s) {
      developer.log('Failed to load shader: $e', error: e, stackTrace: s, name: 'aurora_glass', level: 700);
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: s,
          library: 'aurora_glass',
          context: ErrorDescription('Failed to load shimmer shader'),
        ),
      );
      return null;
    }
  }
}
