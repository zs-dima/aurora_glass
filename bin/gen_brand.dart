import 'dart:convert';
import 'dart:io';

import '_gen/design_tokens.dart';

/// Generates an app's brand tokens: the half of the palette that is its own.
///
/// Runs in the consuming application:
///
/// ```
/// dart run aurora_glass:gen_brand --design-root ../design/tokens
/// dart run aurora_glass:gen_brand --check
/// ```
///
/// The app's identity comes from a JSON spec (`tool/fork/app.json` by default):
///
/// ```json
/// "tokens": {
///   "designApp": "BS",
///   "accentRoles": { "#FFC163": "pairStart", "#FF8E6E": "pairEnd" },
///   "innerFills": { "rgba(26,18,32,0.92)": "gradientCardInner" }
/// }
/// ```
///
/// `accentRoles` and `innerFills` are keyed by the dark value on the artboards: the design file
/// stores both as unordered dark-to-light maps, so a role cannot be recovered from position, and
/// a palette change fails here rather than swapping two colours.
void main(List<String> args) {
  var designRoot = '../design/tokens';
  var specPath = 'tool/fork/app.json';
  var outPath = 'lib/_core/theme/brand_tokens.g.dart';
  var check = false;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--check':
        check = true;

      case '--design-root':
        if (i + 1 >= args.length) fail('--design-root needs a path');
        designRoot = args[++i];

      case '--app-json':
        if (i + 1 >= args.length) fail('--app-json needs a path');
        specPath = args[++i];

      case '--out':
        if (i + 1 >= args.length) fail('--out needs a path');
        outPath = args[++i];

      case final unknown:
        fail(
          'unknown argument: $unknown\n'
          'usage: gen_brand.dart [--check] [--design-root <dir>] [--app-json <file>] [--out <file>]',
        );
    }
  }

  final tokens = DesignTokens.read(designRoot);
  emit(path: outPath, generated: _render(tokens, _AppIdentity.read(specPath)), check: check, source: tokens.path);
}

/// The consuming app's identity, read from its spec.
///
/// Hand-parsed with `dart:convert`, so it works inside a tree whose package resolution is broken.
final class _AppIdentity {
  const _AppIdentity({
    required this.displayName,
    required this.designApp,
    required this.accentRoles,
    required this.innerFills,
  });

  /// Reads the spec. A malformed or missing file is fatal.
  factory _AppIdentity.read(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      fail('$path not found. Run from the application root, or pass --app-json.');
    }

    final doc = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    final tokens = doc['tokens'];
    if (doc['displayName'] is! String || tokens is! Map<String, Object?>) {
      fail('$path is missing `displayName` or `tokens`');
    }
    final roles = tokens['accentRoles'];
    final fills = tokens['innerFills'];
    if (tokens['designApp'] is! String || roles is! Map<String, Object?>) {
      fail('$path is missing `tokens.designApp` or `tokens.accentRoles`');
    }
    if (fills is! Map<String, Object?>) {
      fail('$path is missing `tokens.innerFills`');
    }

    return _AppIdentity(
      displayName: doc['displayName']! as String,
      designApp: tokens['designApp']! as String,
      accentRoles: roles.cast<String, String>(),
      innerFills: fills.cast<String, String>(),
    );
  }

  /// Product name, for the generated header.
  final String displayName;

  /// The app's key in the design workspace's `apps` map.
  final String designApp;

  /// Accent roles, keyed by the dark hex on the artboards.
  final Map<String, String> accentRoles;

  /// Inner fills of the gradient-bordered surfaces the app draws, keyed by their dark value.
  final Map<String, String> innerFills;
}

String _render(DesignTokens tokens, _AppIdentity app) {
  final design = tokens.app(app.designApp);
  final accents = (design['accents']! as Map<String, Object?>).cast<String, String>();
  final inner = tokens.map('inner').cast<String, String>();

  for (final darkHex in app.accentRoles.keys) {
    if (!accents.containsKey(darkHex)) {
      fail(
        'accent $darkHex (${app.accentRoles[darkHex]}) is not in the "${app.designApp}" design tokens: '
        'the palette changed or the app spec is stale.',
      );
    }
  }
  for (final darkFill in app.innerFills.keys) {
    if (!inner.containsKey(darkFill)) {
      fail('inner fill $darkFill (${app.innerFills[darkFill]}) is not in the design tokens');
    }
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE - DO NOT EDIT BY HAND.')
    ..writeln('//')
    ..writeln("// Source: the design workspace's tokens/colors.json, written by")
    ..writeln('// `python make_light.py --emit-tokens`. Regenerate with')
    ..writeln('// `dart run aurora_glass:gen_brand`.')
    ..writeln('//')
    ..writeln('// ${tokens.contract}')
    ..writeln('//')
    ..writeln("// ${app.displayName}'s own half of the palette. The shared half is `AppTokens` in")
    ..writeln('// `package:aurora_glass`.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln("import 'package:flutter/painting.dart' show Color;")
    ..writeln()
    ..writeln('/// ${app.displayName} colour values, generated from the design workspace.')
    ..writeln('///')
    ..writeln("/// Read these through the app's `Brand` and `AuroraScheme`.")
    ..writeln('abstract final class BrandTokens {')
    ..writeln('  // --- ${app.displayName} accent axis ---');
  for (final entry in app.accentRoles.entries) {
    final role = entry.value;
    buffer
      ..writeln()
      ..writeln('  /// `${entry.key}` on dark.')
      ..writeln('  static const Color ${role}Dark = ${color(entry.key)};')
      ..writeln()
      ..writeln('  /// `${accents[entry.key]}` on light, derived from ${role}Dark by the token map.')
      ..writeln('  static const Color ${role}Light = ${color(accents[entry.key]!)};');
  }

  final baseDark = (design['baseStopsDark']! as List<Object?>).cast<String>();
  final baseLight = (design['baseStopsLight']! as List<Object?>).cast<String>();
  buffer
    ..writeln()
    ..writeln('  // --- Screen chassis ---')
    ..writeln()
    ..writeln('  /// The three stops of the ${tokens.doc['baseGradientAngleDeg']}° base gradient, in order.')
    ..writeln('  static const List<Color> baseStopsDark = <Color>[${baseDark.map(color).join(', ')}];')
    ..writeln()
    ..writeln('  /// The same three stops after the dark-to-light substitution.')
    ..writeln('  static const List<Color> baseStopsLight = <Color>[${baseLight.map(color).join(', ')}];')
    ..writeln()
    ..writeln('  /// Flat base behind the gradient; also the splash background.')
    ..writeln('  static const Color scaffoldBaseDark = ${color(design['body']! as String)};')
    ..writeln()
    ..writeln('  /// The same flat base on light.')
    ..writeln('  static const Color scaffoldBaseLight = ${color(design['bodyLight']! as String)};');

  for (final entry in app.innerFills.entries) {
    final role = entry.value;
    buffer
      ..writeln()
      ..writeln('  /// `${entry.key}` on dark.')
      ..writeln('  static const Color ${role}Dark = ${color(entry.key)};')
      ..writeln()
      ..writeln('  /// `${inner[entry.key]}` on light.')
      ..writeln('  static const Color ${role}Light = ${color(inner[entry.key]!)};');
  }

  buffer.writeln('}');
  return buffer.toString();
}
