import 'dart:ui' as ui show DisplayFeature, DisplayFeatureType;

import 'package:aurora_glass/src/adaptive/window_size_scope.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/material.dart';

/// A list beside the thing selected in it.
///
/// Below `expanded` there is one pane: [list] takes the whole width and the caller navigates to
/// show a selection. From `expanded` up both are on screen at once.
///
/// The `Row` is always the same three children, list, gap and detail; the breakpoint changes
/// only their widths, so crossing it keeps the list's scroll offset and row state. [detail] is
/// built only when there is a pane to put it in.
///
/// A hinge or fold that splits the window vertically takes the split, so no control sits under it.
/// Display features are reported in screen coordinates, which match local ones only when this
/// layout spans the window horizontally; inside a narrower column the hinge is ignored, and debug
/// builds assert so the caller finds out.
class ListDetail extends StatelessWidget {
  /// Creates a [ListDetail].
  const ListDetail({
    required this.list,
    this.detail,
    this.listWidth = 440,
    super.key,
  });

  /// The first display feature that splits the window vertically, if any. A cutout is a hole in
  /// one pane, not a boundary between two.
  static ui.DisplayFeature? _verticalSeparator(List<ui.DisplayFeature> features) {
    for (final feature in features) {
      final isSeparator = feature.type == ui.DisplayFeatureType.hinge || feature.type == ui.DisplayFeatureType.fold;
      if (isSeparator && feature.bounds.height > feature.bounds.width) return feature;
    }
    return null;
  }

  /// The list pane. Always present.
  final Widget list;

  /// The detail pane, or null when nothing is selected. Shown from `expanded` up only.
  final Widget? detail;

  /// Width of the list pane at `expanded` and above, when no hinge decides it.
  final double listWidth;

  @override
  Widget build(BuildContext context) {
    final twoPane = WindowSizeScope.classOf(context).isExpandedOrLarger;
    final separator = twoPane ? _verticalSeparator(MediaQuery.displayFeaturesOf(context)) : null;
    final windowWidth = MediaQuery.widthOf(context);
    // Screen coordinates run left to right whatever the locale does; in RTL the list is on the
    // right, so the split is measured from the other edge.
    final rtl = Directionality.of(context) == .rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints.maxWidth.isFinite,
          'ListDetail needs a bounded width; it lays panes out against the window.',
        );

        final spansWindow = (constraints.maxWidth - windowWidth).abs() < precisionErrorTolerance;
        assert(
          separator == null || spansWindow,
          'ListDetail sees a hinge but is ${constraints.maxWidth}px wide inside a ${windowWidth}px '
          'window, so the hinge cannot be placed. Give it the full width: on a foldable that means '
          'not wrapping it in a ContentPane, which caps the column at 600dp.',
        );

        final hinge =
            separator != null &&
                spansWindow &&
                separator.bounds.left > 0 &&
                separator.bounds.right < constraints.maxWidth
            ? separator
            : null;

        final double paneWidth;
        final double gapWidth;
        if (!twoPane) {
          paneWidth = constraints.maxWidth;
          gapWidth = 0;
        } else if (hinge != null) {
          paneWidth = rtl ? constraints.maxWidth - hinge.bounds.right : hinge.bounds.left;
          gapWidth = hinge.bounds.width;
        } else {
          // Never more than half: at 840 a 440 px list leaves the detail smaller than its subject.
          paneWidth = listWidth.clamp(0.0, (constraints.maxWidth - AppSpacing.md) / 2);
          gapWidth = AppSpacing.md;
        }

        return Row(
          children: <Widget>[
            SizedBox(width: paneWidth, child: list),
            SizedBox(width: gapWidth),
            Expanded(child: twoPane ? (detail ?? const SizedBox.shrink()) : const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}
