import 'package:aurora_glass/src/adaptive/window_size_scope.dart';
import 'package:aurora_glass/src/theme/app_palette.dart';
import 'package:aurora_glass/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Applies the window-class-dependent half of the theme, and animates the change.
///
/// Sits inside `MaterialApp.builder`, above the [Navigator], so routes, dialogs and sheets
/// inherit it. The root [ThemeData] handed to `MaterialApp` stays one stable object; sizes
/// interpolate because [ThemeData.lerp] lerps every registered [ThemeExtension].
///
/// Set `MaterialApp.themeAnimationDuration` to [Duration.zero]: MaterialApp wraps the tree in an
/// [AnimatedTheme] of its own, and two of them chase each other on a light/dark switch.
class AppResponsiveTheme extends StatelessWidget {
  /// Creates an [AppResponsiveTheme].
  const AppResponsiveTheme({required this.palette, required this.child, super.key});

  /// The same [AppPalette] handed to `MaterialApp.theme`.
  ///
  /// Passed rather than read from the ambient theme: a built [ThemeData] cannot be taken apart
  /// into the palette it came from.
  final AppPalette palette;

  /// The subtree the resolved theme applies to.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // MaterialApp has already picked the brightness from themeMode and platformBrightness.
    final brightness = Theme.of(context).brightness;
    final windowClass = WindowSizeScope.classOf(context);
    return AnimatedTheme(
      data: AppTheme.resolve(brightness, windowClass, palette),
      duration: MediaQuery.disableAnimationsOf(context) ? .zero : Durations.short4,
      curve: Easing.standard,
      child: child,
    );
  }
}
