import 'dart:math' as math;

import 'package:aurora_glass/aurora_glass.dart';
import 'package:flutter/material.dart';

/// Every component, every state, both themes, including each data view's empty, loading and
/// error states.
class ShowcaseScreen extends StatefulWidget {
  /// Creates the showcase.
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = Brand.of(context);

    return AppScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverContentPane(
            sliver: SliverList.list(
              children: <Widget>[
                const SizedBox(height: AppSpacing.lg),
                Text('UI Kit', style: theme.textTheme.headlineSmall),
                Text(
                  'Aurora Glass, ${theme.brightness.name} theme',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),

                const _Section('Buttons'),
                PrimaryPill(label: 'PrimaryPill h58', onPressed: _disabled ? null : () {}),
                const SizedBox(height: AppSpacing.xs),
                GhostPill(label: 'GhostPill h48', onPressed: _disabled ? null : () {}),
                TextAction(label: 'TextAction h44 visual / 48dp tap', onPressed: _disabled ? null : () {}),
                SwitchListTile(
                  value: _disabled,
                  onChanged: (v) => setState(() => _disabled = v),
                  title: Text('Disabled state (38%)', style: theme.textTheme.bodyMedium),
                ),

                const _Section('Surfaces'),
                const GlassCard(child: Text('GlassCard: r24, 5.5% fill, hairline border')),
                const SizedBox(height: AppSpacing.xs),
                const GradientBorderCard(child: Text('GradientBorderCard: selected / hero')),
                const SizedBox(height: AppSpacing.xs),
                ListRow(title: 'ListRow', subtitle: 'r18, chevron when tappable', onTap: () {}),

                const _Section('Signals: colour is never alone'),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: <Widget>[
                    for (final tone in AppTone.values) StatusPill(label: tone.name, tone: tone),
                    const StatusPill(label: 'live', pulse: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final tone in AppTone.values)
                  Padding(
                    padding: const .only(bottom: 6),
                    child: InfoBanner(
                      message: 'InfoBanner: ${tone.name}',
                      tone: tone,
                      action: 'Details',
                      onAction: () {},
                    ),
                  ),

                const _Section('Headers: one row, at the back arrow height'),
                const ScreenHeader(label: 'Screen header', trailing: 'Aug 29', back: BackButton()),
                const ScreenHeader(
                  label: 'With a widget value',
                  trailingWidget: StatusPill(label: 'rec', tone: .alert, pulse: true, maxLines: 1),
                  back: BackButton(),
                ),
                const ScreenHeader(label: 'With an action', action: GaugeRing(size: 28), back: BackButton()),
                const ScreenHeader(back: BackButton()),
                const ScreenHeader(label: 'No way back — the band keeps its height'),

                const _Section('Data displays'),
                const ProgressBar(value: 0.28),
                const SizedBox(height: AppSpacing.xs),
                const ProgressBar(value: 0.82),
                const SizedBox(height: AppSpacing.xs),
                const ProgressBar(value: 0.82, emphasis: .featured, height: 9),
                const SizedBox(height: AppSpacing.sm),
                LevelBars(
                  // Generated rather than written out: a hand-typed trail of 25 levels is a list
                  // of repeated numbers, and what the part is for is a SHAPE.
                  values: <double>[for (var i = 0; i < 25; i++) (math.sin(i / 3) + 1) / 2 * (1 - i / 40)],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Row(
                  spacing: AppSpacing.xs,
                  children: <Widget>[
                    Expanded(
                      child: StatTile(label: 'Background', value: 'Quiet', tone: .ok),
                    ),
                    Expanded(
                      child: StatTile(label: 'Now', value: 'Recording', tone: .accent, live: true),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Row(
                  spacing: AppSpacing.xs,
                  children: <Widget>[
                    StatusDot(),
                    StatusDot(tone: .ok),
                    StatusDot(tone: .alert),
                    StatusDot(tone: .accent, pulse: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const GradientBorderCard(
                  radius: AppRadius.row,
                  glow: true,
                  child: Text('GradientBorderCard: the row radius, with the glow'),
                ),

                const _Section('Every data view: empty / loading / error'),
                const GlassCard(child: Center(child: Text('Empty: nothing here yet'))),
                const SizedBox(height: AppSpacing.xs),
                GlassCard(
                  child: SizedBox(
                    height: 44,
                    child: Shimmer(
                      highlight: brand.cardBorder,
                      background: brand.cardFill,
                      radius: AppRadius.small,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                InfoBanner(
                  message: 'Error: with a Details action',
                  tone: .alert,
                  action: 'Details',
                  onAction: () {},
                ),

                const _Section('Type scale'),
                Text('Headline medium', style: theme.textTheme.headlineMedium),
                Text('Title medium', style: theme.textTheme.titleMedium),
                Text('Body medium: the reading size', style: theme.textTheme.bodyMedium),
                Text('Body small 12.5: the floor for essentials', style: theme.textTheme.bodySmall),
                Text('1234567890 tabular figures', style: theme.textTheme.labelMedium),

                const _Section('Brand'),
                Row(
                  children: <Widget>[
                    _Swatch(color: brand.pairStart, label: 'pairStart'),
                    _Swatch(color: brand.pairEnd, label: 'pairEnd'),
                    _Swatch(color: brand.accentText, label: 'accentText'),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const .only(top: AppSpacing.lg, bottom: AppSpacing.xs),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 44,
          width: .infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, borderRadius: AppShape.row),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
