/// Shared machinery of the two token generators.
///
/// Under `bin/_gen/` rather than `lib/`: `dart:io` must not be reachable from
/// `package:aurora_glass`, and pub advertises only `bin/*.dart` as executables.
library;

import 'dart:convert';
import 'dart:io';

/// Prints [message] and exits with status 2. Every generator failure is fatal: a fallback would
/// emit one app's palette under another app's name.
Never fail(String message) {
  stderr.writeln(message);
  exit(2);
}

/// The design workspace's `colors.json`, as written by `make_light.py --emit-tokens`.
final class DesignTokens {
  const DesignTokens(this.doc, this.path);

  /// Reads `<root>/colors.json`.
  factory DesignTokens.read(String designRoot) {
    final source = File('$designRoot/colors.json');
    if (!source.existsSync()) {
      fail(
        'design tokens not found at ${source.path}\n'
        'Run `python make_light.py --emit-tokens` in the design workspace, or pass --design-root.',
      );
    }
    return DesignTokens(jsonDecode(source.readAsStringSync()) as Map<String, Object?>, source.path);
  }

  /// The parsed document.
  final Map<String, Object?> doc;

  /// Where it was read from, for headers and messages.
  final String path;

  /// The dark-to-light contract line the design workspace states about itself.
  String get contract => doc[r'$contract']! as String;

  /// A required top-level map.
  Map<String, Object?> map(String key) {
    final value = doc[key];
    if (value is! Map<String, Object?>) fail('the design tokens carry no "$key" map');
    return value;
  }

  /// A required top-level list.
  List<Object?> list(String key) {
    final value = doc[key];
    if (value is! List<Object?>) fail('the design tokens carry no "$key" list');
    return value;
  }

  /// The `apps` entry for [key].
  Map<String, Object?> app(String key) {
    final entry = map('apps')[key];
    if (entry is! Map<String, Object?>) fail('the design tokens carry no "$key" app entry');
    return entry;
  }
}

/// Renders `#RRGGBB` or `rgba(r,g,b,a)` as a Dart `Color` literal.
String color(String value) {
  final hex = RegExp(r'^#([0-9A-Fa-f]{6})$').firstMatch(value);
  if (hex != null) return 'Color(0xFF${hex.group(1)!.toUpperCase()})';

  final rgba = RegExp(r'^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([0-9.]+)\s*\)$').firstMatch(value);
  if (rgba != null) {
    final a = (double.parse(rgba.group(4)!) * 255).round().clamp(0, 255);
    final channels = <int>[a, int.parse(rgba.group(1)!), int.parse(rgba.group(2)!), int.parse(rgba.group(3)!)];
    return 'Color(0x${channels.map((c) => c.toRadixString(16).padLeft(2, '0').toUpperCase()).join()})';
  }

  fail('cannot render "$value" as a Color: expected #RRGGBB or rgba(r,g,b,a)');
}

/// Writes [generated] to [path], or with [check] compares and exits 1 when the file is stale.
///
/// The output is committed, so CI and a fresh clone build without the design workspace.
void emit({required String path, required String generated, required bool check, required String source}) {
  final target = File(path);
  if (check) {
    final current = target.existsSync() ? target.readAsStringSync().replaceAll('\r\n', '\n') : '';
    if (current == generated) {
      stdout.writeln('$path is up to date with $source');
      return;
    }
    stderr.writeln('$path is stale against $source. Regenerate it and commit the result.');
    exit(1);
  }
  target.parent.createSync(recursive: true);
  target.writeAsStringSync(generated);
  stdout.writeln('wrote $path from $source');
}
