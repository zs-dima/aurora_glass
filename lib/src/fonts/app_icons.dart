import 'package:flutter/widgets.dart';

/// The kit's icon font. An app's own glyphs belong in a family of its own.
@staticIconProvider
abstract final class AppIcons {
  static const _kFontFamily = 'icons';
  static const String _kFontPkg = 'aurora_glass';

  /// Apple logo.
  static const IconData apple = IconData(0xF0D5, fontFamily: _kFontFamily, fontPackage: _kFontPkg);

  /// Windows logo.
  static const IconData windows = IconData(0x1014F, fontFamily: _kFontFamily, fontPackage: _kFontPkg);

  /// Windows logo, outlined.
  static const IconData windowsOutline = IconData(0xF33B, fontFamily: _kFontFamily, fontPackage: _kFontPkg);

  /// Google logo.
  static const IconData google = IconData(0xF653, fontFamily: _kFontFamily, fontPackage: _kFontPkg);

  /// Sun.
  static const IconData sun = IconData(0xF03D, fontFamily: _kFontFamily, fontPackage: _kFontPkg);

  const AppIcons._();
}
