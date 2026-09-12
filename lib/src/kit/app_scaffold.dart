import 'package:aurora_glass/src/adaptive/content_pane.dart';
import 'package:aurora_glass/src/kit/app_background.dart';
import 'package:flutter/material.dart';

/// The chassis every screen sits in: [AppBackground], and the screen on top of it.
///
/// The gradient and the glows are painted outside the [Scaffold], edge to edge and under the
/// status bar. The body gets the whole window, insets included: the screen applies the content
/// column itself, with [SliverContentPane] inside a `CustomScrollView`, [ContentPane] around static
/// content or [SliverContentFill] for a block that centres until it has to scroll.
class AppScaffold extends StatelessWidget {
  /// Creates an [AppScaffold].
  const AppScaffold({required this.child, this.appBar, super.key});

  /// Screen content, laid out against the full window.
  final Widget child;

  /// Optional top bar, rendered transparent over the gradient.
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      const Positioned.fill(child: AppBackground()),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: child,
      ),
    ],
  );
}
