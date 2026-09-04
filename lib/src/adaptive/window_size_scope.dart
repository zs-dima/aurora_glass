import 'package:aurora_glass/src/adaptive/window_size.dart';
import 'package:flutter/widgets.dart';

/// Publishes the current [WindowClass] to descendants.
///
/// The class, not the [Size]: dependents rebuild when the class changes, not on every pixel of
/// a window drag. Anything that needs the exact width reads [MediaQuery.sizeOf] or uses
/// `LayoutBuilder`.
class WindowSizeScope extends StatelessWidget {
  /// Creates a [WindowSizeScope].
  const WindowSizeScope({required this.child, super.key});

  /// The window class from the nearest scope, falling back to [MediaQuery.widthOf].
  static WindowClass classOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InheritedWindowClass>()?.windowClass ??
      WindowClass.ofWidth(MediaQuery.widthOf(context));

  /// The subtree that can look the window class up.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _InheritedWindowClass(windowClass: WindowClass.ofWidth(MediaQuery.widthOf(context)), child: child);
}

class _InheritedWindowClass extends InheritedWidget {
  const _InheritedWindowClass({required this.windowClass, required super.child});

  final WindowClass windowClass;

  @override
  bool updateShouldNotify(_InheritedWindowClass oldWidget) => windowClass != oldWidget.windowClass;
}
