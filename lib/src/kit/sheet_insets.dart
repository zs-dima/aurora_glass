import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The padding a modal bottom sheet applies to its own content, handed to the sheet's scroll
/// view rather than wrapped around it.
///
/// Wrapping the scrollable in `SafeArea > Padding` shrinks the viewport instead of the content:
/// the scrollbar stops short of the edge, and with the keyboard up there is less to scroll rather
/// than more.
///
/// The sum is right in both states: `padding` is `max(0, viewPadding - viewInsets)`, so once the
/// keyboard covers the gesture bar the gesture-bar term is already zero.
abstract final class SheetInsets {
  /// The insets for the sheet whose builder owns [context].
  ///
  /// Read from the sheet's context, not the caller's: a route below the sheet has different view
  /// insets.
  static EdgeInsets of(BuildContext context) => const .all(AppSpacing.md).copyWith(
    bottom: AppSpacing.md + MediaQuery.paddingOf(context).bottom + MediaQuery.viewInsetsOf(context).bottom,
  );
}
