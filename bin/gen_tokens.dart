import '_gen/design_tokens.dart';

/// Generates `lib/src/theme/tokens.g.dart`: the half of the palette every app shares.
///
/// The neutral text ramp, the semantic colours and the base gradient's stop positions. An app's
/// own accent axis is generated into the app by `gen_brand.dart`.
///
/// Colour only: the design workspace's token file carries nothing else. Spacing, radii, targets
/// and motion are hand-written constants in `tokens.dart`.
///
/// ```
/// dart run aurora_glass:gen_tokens
/// dart run aurora_glass:gen_tokens --check
/// dart run aurora_glass:gen_tokens --design-root ../../../app/design/tokens
/// ```
void main(List<String> args) {
  var designRoot = '../../../app/design/tokens';
  var check = false;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--check':
        check = true;

      case '--design-root':
        if (i + 1 >= args.length) fail('--design-root needs a path');
        designRoot = args[++i];

      case final unknown:
        fail(
          'unknown argument: $unknown\n'
          'usage: gen_tokens.dart [--check] [--design-root <dir>]',
        );
    }
  }
  final tokens = DesignTokens.read(designRoot);
  emit(
    path: 'lib/src/theme/tokens.g.dart',
    generated: _render(tokens),
    check: check,
    source: tokens.path,
  );
}

/// The ramp's roles in the order the design file lists them, lightest ink first. The design map
/// carries no names, so position is the binding; a ramp of another length fails below.
const _kNeutralNames = <String>['ink', 'inkStrong', 'inkSoft', 'secondary', 'deEmphasis', 'muted'];

String _render(DesignTokens tokens) {
  final neutral = tokens.map('neutralText').cast<String, String>();
  final semantic = tokens.map('semantic');
  if (neutral.length != _kNeutralNames.length) {
    fail('the neutral ramp has ${neutral.length} entries; this generator names ${_kNeutralNames.length}.');
  }
  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE - DO NOT EDIT BY HAND.')
    ..writeln('//')
    ..writeln("// Source: the design workspace's tokens/colors.json, written by")
    ..writeln('// `python make_light.py --emit-tokens`. Regenerate with')
    ..writeln('// `dart run aurora_glass:gen_tokens`.')
    ..writeln('//')
    ..writeln('// ${tokens.contract}')
    ..writeln('//')
    ..writeln('// Shared values only. An app\'s accent axis, chassis base and inner fills are')
    ..writeln('// generated into the app by `dart run aurora_glass:gen_brand`.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln("import 'package:flutter/painting.dart' show Color;")
    ..writeln()
    ..writeln('/// Colour values generated from the design workspace.')
    ..writeln('///')
    ..writeln('/// Read these through [AuroraScheme] rather than directly.')
    ..writeln('abstract final class AppTokens {')
    ..writeln('  // --- Neutral text ramp ---');
  var index = 0;
  for (final entry in neutral.entries) {
    // ignore: move-variable-outside-iteration
    final name = _kNeutralNames[index++];
    buffer
      ..writeln()
      ..writeln('  /// `${entry.key}` on dark.')
      ..writeln('  static const Color ${name}Dark = ${color(entry.key)};')
      ..writeln()
      ..writeln('  /// `${entry.value}` on light.')
      ..writeln('  static const Color ${name}Light = ${color(entry.value)};');
  }
  buffer
    ..writeln()
    ..writeln('  // --- Semantic colours ---')
    ..writeln('  //')
    ..writeln('  // Text and fill darken differently: a fill sits behind white ink, so it stays')
    ..writeln('  // brighter than the same colour used as text.');
  for (final entry in semantic.entries) {
    final value = (entry.value! as Map<String, Object?>).cast<String, String>();
    final name = entry.key;
    buffer
      ..writeln()
      ..writeln('  /// `$name` as ink or stroke, on dark.')
      ..writeln('  static const Color ${name}Dark = ${color(value['dark']!)};')
      ..writeln()
      ..writeln('  /// `$name` as ink or stroke, on light.')
      ..writeln('  static const Color ${name}TextLight = ${color(value['lightText']!)};')
      ..writeln()
      ..writeln('  /// `$name` as a fill, on light.')
      ..writeln('  static const Color ${name}FillLight = ${color(value['lightFill']!)};');
  }
  final stops = tokens.list('baseGradientStopsPercent').map((p) => ((p! as num) / 100).toString()).join(', ');
  buffer
    ..writeln()
    ..writeln('  // --- Chassis geometry; the colours of the stops are per app ---')
    ..writeln()
    ..writeln('  /// Stop positions of the ${tokens.doc['baseGradientAngleDeg']}° base gradient, as fractions.')
    ..writeln('  static const List<double> baseGradientStops = <double>[$stops];')
    ..writeln('}');
  return buffer.toString();
}
