import 'package:aurora_glass/src/kit/surfaces.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// A short code shown one character per card: a pairing code, an OTP, a room number.
///
/// One semantics node, not one per card, so a screen reader announces the code as the caller's
/// [semanticsLabel] rather than as stray characters. The gutters tighten before anything clips,
/// and `FittedBox` is the backstop for what tightening cannot absorb.
class CodeDigits extends StatelessWidget {
  /// Creates a [CodeDigits].
  const CodeDigits({required this.code, required this.semanticsLabel, this.style, super.key});

  /// The characters to show, one card each.
  final String code;

  /// What assistive technology hears in place of the cards. Space the characters out ("5 0 5 2")
  /// so they are read one by one; the sentence around them is the caller's.
  final String semanticsLabel;

  /// Style for each character; defaults to `displaySmall`.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticsLabel,
    excludeSemantics: true,
    child: FittedBox(
      fit: .scaleDown,
      child: Row(
        mainAxisAlignment: .center,
        children: <Widget>[
          for (final character in code.split(''))
            Padding(
              padding: const .symmetric(horizontal: 4),
              child: GlassCard(
                padding: const .all(AppSpacing.sm),
                child: Text(character, style: style ?? Theme.of(context).textTheme.displaySmall),
              ),
            ),
        ],
      ),
    ),
  );
}
