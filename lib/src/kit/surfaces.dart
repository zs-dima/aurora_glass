// One file per kit category.
// ignore_for_file: prefer-single-widget-per-file
import 'package:aurora_glass/src/kit/signals.dart';
import 'package:aurora_glass/src/theme/brand.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The main surface: glass fill, hairline border, r24, deep shadow.
class GlassCard extends StatelessWidget {
  /// Creates a [GlassCard].
  const GlassCard({required this.child, this.padding = const EdgeInsets.all(AppSpacing.md), this.onTap, super.key});

  /// Card content.
  final Widget child;

  /// Inner padding. Nested corners follow `inner = outer - padding`.
  final EdgeInsetsGeometry padding;

  /// Makes the whole card tappable, with the Material state layers.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: brand.cardFill,
        borderRadius: AppShape.card,
        border: .all(color: brand.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Theme.of(context).colorScheme.shadow, blurRadius: 50, offset: const Offset(0, 20)),
        ],
      ),
      child: Material(
        type: .transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppShape.card,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The selected or hero treatment: a 2 px gradient border around a near-opaque inner fill.
class GradientBorderCard extends StatelessWidget {
  /// Creates a [GradientBorderCard].
  const GradientBorderCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.radius = AppRadius.card,
    this.glow = false,
    super.key,
  });

  /// Card content.
  final Widget child;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Makes the whole card tappable.
  final VoidCallback? onTap;

  /// The outer corner. The inner one follows the nesting rule, `inner = outer − border`.
  ///
  /// A card is the default, and a ROW is the other case this shape is used for: one item in a list
  /// drawn with the gradient border to say it is the one that matters. A 24 pt corner on a 56 pt
  /// row reads as a lozenge, not as a row.
  final Radius radius;

  /// Whether the card casts the brand glow.
  ///
  /// Off by default, which is every card that has ever used this: a screen full of glowing cards
  /// has no focal point. On for the ONE element a screen is about.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    // The border is 2 px on every side, so the inner radius is 2 less — nested corners never share
    // a radius, or the border reads as thicker at the corners than along the edges.
    final inner = BorderRadius.all(.circular(radius.x - 2));

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: brand.cta,
        borderRadius: .all(radius),
        boxShadow: glow ? <BoxShadow>[BoxShadow(color: brand.pairStart.withValues(alpha: 0.2), blurRadius: 36)] : null,
      ),
      child: Padding(
        padding: const .all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(color: brand.gradientCardInner, borderRadius: inner),
          child: Material(
            type: .transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: inner,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// A dense list row: the row radius, a subtle fill, an optional leading widget and a trailing
/// slot that defaults to a chevron when the row is tappable.
class ListRow extends StatelessWidget {
  /// Creates a [ListRow].
  const ListRow({
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.tone,
    super.key,
  });

  /// Primary text.
  final String title;

  /// Replaces the rendered [title] while keeping its slot, for a decorated first line. [title]
  /// stays required as the row's identity.
  final Widget? titleWidget;

  /// Optional secondary text.
  final String? subtitle;

  /// Optional leading widget: a status dot, a number, an icon.
  final Widget? leading;

  /// Optional trailing widget; a chevron when [onTap] is set and nothing is given.
  final Widget? trailing;

  /// Row tap handler.
  final VoidCallback? onTap;

  /// Whether a detail pane is showing this row. Marked on the row itself, as Material's
  /// list-detail layouts do.
  final bool selected;

  /// Paints the row in the tone's colour with the tone's icon, for a destructive option or the
  /// like. Ignored when [leading] or [titleWidget] is given.
  final AppTone? tone;

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    final theme = Theme.of(context);
    final toneColor = tone?.on(theme.colorScheme);
    final leadingWidget = leading ?? (tone == null ? null : Icon(tone!.icon, color: toneColor));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? Color.alphaBlend(brand.accentText.withValues(alpha: 0.1), brand.cardFill) : brand.cardFill,
        borderRadius: AppShape.row,
        border: .all(color: selected ? brand.accentText : brand.cardBorder),
      ),
      child: Material(
        type: .transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppShape.row,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTarget.visual),
            child: Padding(
              padding: const .symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  // Three constant slots, so the body is always the second child and
                  // `Widget.canUpdate` keeps it when a leading widget appears.
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: leadingWidget == null ? 0 : AppSpacing.sm),
                    child: leadingWidget ?? const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      mainAxisSize: .min,
                      children: <Widget>[
                        titleWidget ?? Text(title, style: theme.textTheme.titleMedium?.copyWith(color: toneColor)),
                        if (subtitle case final String s) Text(s, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  // A constant cap, not a Flexible: a control hugs the edge at its own size, the body
                  // keeps the rest, a long value wraps. A trailing Text should pass
                  // `textAlign: TextAlign.end`.
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppTarget.trailingMax),
                    child:
                        trailing ??
                        (onTap == null
                            ? const SizedBox.shrink()
                            : Icon(Icons.chevron_right, color: theme.colorScheme.outline)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The overline above a group of content: 12/w700, capitals, +14% tracking.
class SectionLabel extends StatelessWidget {
  /// Creates a [SectionLabel].
  const SectionLabel(this.text, {this.maxLines, super.key});

  /// Label text; rendered upper-case with Unicode default casing.
  final String text;

  /// Cap on rendered lines; the label ellipsizes past it. Null lets it wrap freely, as before.
  ///
  /// A section label normally owns its line and should wrap — a translation that needs two lines
  /// gets two. It is when the label SHARES a row that wrapping is wrong: on a header line beside a
  /// back arrow and a trailing value, a second line pushes the row's height out and reads as a
  /// mistake rather than as a translation. Callers in that position pass 1.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.labelSmall;
    return Text(
      text.toUpperCase(),
      maxLines: maxLines,
      overflow: maxLines == null ? null : .ellipsis,
      style: base?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: .w700,
        // Derived here rather than baked into `labelSmall`, which Material also hands to Badge,
        // ListTile, NavigationBar and both pickers.
        letterSpacing: (base.fontSize ?? 12) * 0.14,
      ),
    );
  }
}
