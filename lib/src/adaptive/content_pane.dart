// The box pane, the sliver pane and the fill share one arithmetic and are read together.
// ignore_for_file: prefer-single-widget-per-file
import 'package:aurora_glass/src/theme/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The content column of a screen: side padding, and a ceiling on how wide it may get.
///
/// On a phone this is the side padding; from medium up the column caps at 600 dp and centres.
/// The column is a number, not a wrapper: [insetsFor] turns the two measurements into one
/// [EdgeInsets], applied by whoever owns the layout. This widget wraps static content;
/// [SliverContentPane] goes inside a scrollable, so the viewport keeps the window's width and the
/// scrollbar, the overscroll glow and bleeding rows reach the edge.
///
/// The tree shape never changes with the width, only the number does, so a resize, unfold or
/// rotation keeps every scroll offset, focus node and animation below.
class ContentPane extends StatelessWidget {
  /// Creates a [ContentPane].
  const ContentPane({required this.child, super.key});

  /// The column's insets at [availableWidth]: `(available - ceiling) / 2 + screenPadding`, floored
  /// at the padding. An unbounded width gets the padding alone.
  static EdgeInsets insetsFor(AppDimens dimens, double? availableWidth) {
    if (availableWidth == null || !availableWidth.isFinite)
      return EdgeInsets.symmetric(horizontal: dimens.screenPadding);

    final ceiling = dimens.contentMaxWidth;
    final centring = ceiling == null || !availableWidth.isFinite || availableWidth <= ceiling
        ? 0.0
        : (availableWidth - ceiling) / 2;
    return EdgeInsets.symmetric(horizontal: centring + dimens.screenPadding);
  }

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: _ContentInsets(dimens: AppDimens.of(context), child: child),
  );
}

/// The content column applied to a sliver, where a scrolling screen's insets belong.
///
/// A pinned [SliverAppBar] placed outside this stays full-bleed. A pane under one passes
/// `top: false`, or the status bar is counted twice.
///
/// The column is computed against the window's width. A scrollable in a narrower pane, such as
/// the list half of a `ListDetail`, passes [availableWidth].
class SliverContentPane extends StatelessWidget {
  /// Creates a [SliverContentPane].
  const SliverContentPane({
    required this.sliver,
    this.top = true,
    this.bottom = true,
    this.availableWidth,
    super.key,
  });

  /// The sliver to inset.
  final Widget sliver;

  /// Whether the safe area's top inset is applied here.
  final bool top;

  /// Whether the safe area's bottom inset is applied here.
  final bool bottom;

  /// The width to compute the column against; the window's when null.
  final double? availableWidth;

  @override
  Widget build(BuildContext context) => SliverSafeArea(
    top: top,
    bottom: bottom,
    sliver: SliverPadding(
      padding: ContentPane.insetsFor(AppDimens.of(context), availableWidth ?? MediaQuery.maybeWidthOf(context)),
      sliver: sliver,
    ),
  );
}

/// "Fill the viewport, then scroll", with the content column applied: one block of content,
/// centred when it fits and scrollable when it does not.
///
/// The insets go on the fill's box child, not around the fill as sliver padding.
/// [SliverFillRemaining] sizes itself to `viewport - precedingScrollExtent`, and a sliver's after
/// padding is not part of that extent, so a padded fill is taller than its viewport by the bottom
/// inset and every such screen scrolls by the height of the gesture bar.
class SliverContentFill extends StatelessWidget {
  /// Creates a [SliverContentFill].
  const SliverContentFill({required this.child, this.top = true, super.key});

  /// The content, which fills the viewport when it fits.
  final Widget child;

  /// Whether the safe area's top inset is applied here.
  final bool top;

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
    hasScrollBody: false,
    child: SafeArea(
      top: top,
      child: _ContentInsets(dimens: AppDimens.of(context), child: child),
    ),
  );
}

/// [RenderPadding] with the padding resolved from the width it is given.
class _ContentInsets extends SingleChildRenderObjectWidget {
  const _ContentInsets({required this.dimens, required super.child});

  final AppDimens dimens;

  @override
  _RenderContentInsets createRenderObject(BuildContext context) => .new(dimens: dimens);

  @override
  void updateRenderObject(BuildContext context, _RenderContentInsets renderObject) => renderObject.dimens = dimens;
}

/// A render object rather than a `LayoutBuilder`: a builder cannot answer an intrinsic query, and
/// `SliverFillRemaining(hasScrollBody: false)` measures its child with `getMaxIntrinsicHeight`.
class _RenderContentInsets extends RenderShiftedBox {
  // ignore: prefer_initializing_formals
  _RenderContentInsets({required AppDimens dimens}) : _dimens = dimens, super(null);

  AppDimens _dimens;

  /// The measurements the padding is resolved from.
  AppDimens get dimens => _dimens;

  set dimens(AppDimens value) {
    if (_dimens == value) return;
    _dimens = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) => _intrinsicWidth(child?.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) => _intrinsicWidth(child?.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) => child?.getMinIntrinsicHeight(_inner(width)) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) => child?.getMaxIntrinsicHeight(_inner(width)) ?? 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final insets = ContentPane.insetsFor(_dimens, constraints.maxWidth);
    final child = this.child;
    if (child == null) return constraints.constrain(Size(insets.horizontal, insets.vertical));
    final childSize = child.getDryLayout(constraints.deflate(insets));
    return constraints.constrain(
      Size(insets.horizontal + childSize.width, insets.vertical + childSize.height),
    );
  }

  @override
  void performLayout() {
    final insets = ContentPane.insetsFor(_dimens, constraints.maxWidth);
    final child = this.child;
    if (child == null) {
      size = constraints.constrain(Size(insets.horizontal, insets.vertical));
      return;
    }

    child.layout(constraints.deflate(insets), parentUsesSize: true);
    (child.parentData! as BoxParentData).offset = Offset(insets.left, insets.top);
    size = constraints.constrain(
      Size(insets.horizontal + child.size.width, insets.vertical + child.size.height),
    );
  }

  /// The child plus the padding; the ceiling only ever adds room, so it never enters an intrinsic width.
  double _intrinsicWidth(double? childWidth) => (childWidth ?? 0) + _dimens.screenPadding * 2;

  /// The width the child gets at [width].
  double _inner(double width) {
    if (!width.isFinite) return width;
    final insets = ContentPane.insetsFor(_dimens, width);
    return (width - insets.horizontal).clamp(0.0, width);
  }
}
