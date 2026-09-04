import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// A marker, a title and one supporting line: a step in a list of steps.
///
/// Not wrapped in a surface; whether it sits in a [GlassCard] is the screen's decision.
class ChecklistRow extends StatelessWidget {
  /// Creates a [ChecklistRow].
  const ChecklistRow({required this.leading, required this.title, required this.body, super.key});

  /// The marker: a number, an icon, a check.
  final Widget leading;

  /// What this step is.
  final String title;

  /// The one line that explains it.
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: .start,
      spacing: AppSpacing.sm,
      children: <Widget>[
        leading,
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            spacing: 4,
            children: <Widget>[
              Text(title, style: theme.textTheme.titleMedium),
              Text(body, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
