import 'package:aurora_glass/aurora_glass.dart';
import 'package:example/gallery_palette.dart';
import 'package:example/showcase_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// The gallery host: both themes, switchable in place.
class ExampleApp extends StatefulWidget {
  /// Creates the gallery.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = .system;

  void _toggle() => setState(
    () => _mode = switch (_mode) {
      // From system, jump to the opposite of what is shown, so the first tap visibly changes.
      .system => WidgetsBinding.instance.platformDispatcher.platformBrightness == .dark ? .light : .dark,
      .light => .dark,
      .dark => .light,
    },
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'UI Kit',
    themeMode: _mode,
    theme: AppTheme.resolve(.light, .compact, GalleryPalette.instance),
    darkTheme: AppTheme.resolve(.dark, .compact, GalleryPalette.instance),
    builder: (context, child) => WindowSizeScope(child: child ?? const SizedBox.shrink()),
    home: Stack(
      children: <Widget>[
        const ShowcaseScreen(),
        SafeArea(
          child: Align(
            alignment: .topRight,
            child: Padding(
              padding: const .all(AppSpacing.sm),
              child: IconButton(
                icon: const Icon(Icons.brightness_6_outlined),
                tooltip: 'Toggle theme',
                onPressed: _toggle,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
