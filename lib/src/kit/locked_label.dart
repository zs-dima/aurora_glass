import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A paywalled label: readable as a shape, not as words.
///
/// Blur rather than redaction bars, so the user sees that their text is there. The real text is
/// excluded from semantics: assistive technology hears [semanticsLabel] instead.
class LockedLabel extends StatelessWidget {
  /// Creates a [LockedLabel].
  const LockedLabel({required this.text, required this.semanticsLabel, this.style, super.key});

  /// The last style handed out, and what it was made from. Every locked row on a screen shares
  /// the same base style and colour, so one entry serves them all.
  static (TextStyle, Color, TextStyle)? _cache;

  /// [base] with its colour moved into a blurred foreground paint.
  ///
  /// Memoised because `TextStyle` compares `foreground` by identity: a fresh `Paint` per build
  /// makes every rebuilt style unequal to the last and re-shapes every locked row on every frame.
  static TextStyle _blurred(TextStyle base, Color color) {
    final cached = _cache;
    if (cached != null && cached.$1 == base && cached.$2 == color) return cached.$3;
    final style = _build(base, color);
    _cache = (base, color, style);
    return style;
  }

  /// Rebuilt field by field: `copyWith` cannot clear `color`, and a style may not carry both
  /// `color` and `foreground`.
  static TextStyle _build(TextStyle base, Color color) => .new(
    inherit: base.inherit,
    fontSize: base.fontSize,
    fontWeight: base.fontWeight,
    fontStyle: base.fontStyle,
    letterSpacing: base.letterSpacing,
    wordSpacing: base.wordSpacing,
    height: base.height,
    fontFamily: base.fontFamily,
    fontFamilyFallback: base.fontFamilyFallback,
    fontFeatures: base.fontFeatures,
    fontVariations: base.fontVariations,
    foreground: ui.Paint()
      ..color = color
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
  );

  /// The label being withheld.
  final String text;

  /// What assistive technology hears instead of [text], typically the name of the thing being
  /// sold. Localized by the caller.
  final String semanticsLabel;

  /// Style of the underlying text; defaults to the list row's title style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.titleMedium ?? const TextStyle();
    final color = base.color ?? DefaultTextStyle.of(context).style.color ?? theme.colorScheme.onSurface;
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        // Keeps the blur from bleeding over neighbouring rows.
        child: ClipRect(
          child: Text(
            text,
            maxLines: 1,
            overflow: .clip,
            // A glyph mask filter, not an `ImageFiltered` layer, which would rasterise every row
            // into its own texture on every scroll frame.
            style: _blurred(base, color),
          ),
        ),
      ),
    );
  }
}
