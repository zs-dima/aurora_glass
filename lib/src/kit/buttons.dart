// One file per kit category.
// ignore_for_file: prefer-single-widget-per-file
import 'package:aurora_glass/src/theme/brand.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// The primary call to action: the brand gradient, a glow and the gradient ink label, 58 px tall
/// and taller when the label wraps.
///
/// Press is a 120 ms scale to 0.97. Under Reduce Motion the button responds without moving.
class PrimaryPill extends StatefulWidget {
  /// Creates a [PrimaryPill].
  const PrimaryPill({required this.label, required this.onPressed, this.icon, this.expand = true, super.key});

  /// Button text. Never an icon alone: the label is what screen readers announce.
  final String label;

  /// `null` disables the button (38% opacity).
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether to fill the available width.
  final bool expand;

  @override
  State<PrimaryPill> createState() => _PrimaryPillState();
}

class _PrimaryPillState extends State<PrimaryPill> {
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    final enabled = widget.onPressed != null;
    final animate = AppMotion.ambientEnabled(context);
    final pressed = _pressed && animate;

    final button = AnimatedScale(
      scale: pressed ? AppMotion.pressScale : 1,
      duration: AppMotion.press,
      child: AnimatedContainer(
        duration: AppMotion.press,
        // A minimum, not a fixed height: a translated label at textScaler 2.0 needs three lines,
        // and a Row reports nothing for cross-axis overflow.
        constraints: const BoxConstraints(minHeight: AppTarget.primaryPill),
        decoration: ShapeDecoration(
          gradient: brand.cta,
          // A stadium stays a pill at any height. The side is always present with only its alpha
          // changing, so the label never shifts; it is the focus ring for keyboard users, since an
          // ink splash is invisible under a gradient.
          shape: AppShape.pill.copyWith(
            side: BorderSide(color: brand.inkOnGradient.withValues(alpha: _focused ? 1 : 0), width: 2),
          ),
          shadows: <BoxShadow>[
            BoxShadow(color: brand.pairStart.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Material(
          type: .transparency,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            onFocusChange: (v) => setState(() => _focused = v),
            customBorder: AppShape.pill,
            // `heightFactor: 1`: without a fixed height above it, a bare Center expands to the
            // tallest constraint it is offered.
            child: Center(
              heightFactor: 1,
              // Vertical padding only: it keeps a wrapped label off the ends, and horizontal padding
              // would change where every label wraps.
              child: Padding(
                padding: const .symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisSize: .min,
                  children: <Widget>[
                    if (widget.icon case final IconData icon) ...<Widget>[
                      Icon(icon, size: 20, color: brand.inkOnGradient),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: .center,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: brand.inkOnGradient, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // One tree shape in every state. Swapping wrappers when the button becomes pressable fails
    // `Widget.canUpdate`, resets the animations mid-tween and recreates the InkWell with its focus
    // node. Both wrappers are inert when enabled.
    return SizedBox(
      width: widget.expand ? .infinity : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.38,
        child: IgnorePointer(ignoring: !enabled, child: button),
      ),
    );
  }
}

/// The secondary action: 48 px, hairline border, no fill.
class GhostPill extends StatelessWidget {
  /// Creates a [GhostPill].
  const GhostPill({required this.label, required this.onPressed, this.expand = true, super.key});

  /// Button text.
  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  /// Whether to fill the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);
    // `minimumSize`, not a fixed box: a wrapped label grows the pill instead of painting outside it.
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: brand.cardBorder),
        shape: AppShape.pill,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        minimumSize: const Size(0, AppTarget.ghostPill),
      ),
      child: Text(label, textAlign: .center),
    );
    return SizedBox(width: expand ? .infinity : null, child: button);
  }
}

/// The tertiary action: 44 px visual, 48 dp tap area, accent-coloured label.
class TextAction extends StatelessWidget {
  /// Creates a [TextAction].
  const TextAction({required this.label, required this.onPressed, super.key});

  /// Button text.
  final String label;

  /// `null` disables the action.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: Brand.of(context).accentText,
      // The tap target, not the visual height: capping the box at 44 shrinks the semantics node.
      minimumSize: const Size(0, AppTarget.tap),
      padding: const .symmetric(horizontal: AppSpacing.sm),
    ),
    child: Text(label),
  );
}
