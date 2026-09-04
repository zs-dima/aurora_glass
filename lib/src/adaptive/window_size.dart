/// The Material 3 window size class.
///
/// Breakpoints (https://m3.material.io/foundations/layout/applying-layout/window-size-classes):
/// compact < 600, medium 600-839, expanded 840-1199, large 1200-1599, extraLarge ≥ 1600.
///
/// Layout branches on this, never on a device type, an orientation or a platform: a window is
/// resized, split, folded and put in picture-in-picture. Read it from `WindowSizeScope.classOf`,
/// which notifies only when the class changes. For a measurement use `MediaQuery.sizeOf`, or
/// `LayoutBuilder` when the parent's space is what matters.
enum WindowClass {
  /// Width < 600: phones.
  compact,

  /// 600 ≤ width < 840: tablets in portrait, unfolded foldables.
  medium,

  /// 840 ≤ width < 1200: tablets in landscape, small desktop windows.
  expanded,

  /// 1200 ≤ width < 1600: desktops.
  large,

  /// Width ≥ 1600: wide desktops.
  extraLarge;

  /// Classifies a window [width] in logical pixels.
  static WindowClass ofWidth(double width) => switch (width) {
    < 600 => compact,
    < 840 => medium,
    < 1200 => expanded,
    < 1600 => large,
    _ => extraLarge,
  };

  /// Width ≥ 600.
  bool get isMediumOrLarger => index >= medium.index;

  /// Width ≥ 840: where a list-detail layout shows two panes.
  bool get isExpandedOrLarger => index >= expanded.index;

  /// Width ≥ 1200.
  bool get isLargeOrLarger => index >= large.index;

  /// Exhaustively maps this size class.
  T map<T>({
    required T Function() compact,
    required T Function() medium,
    required T Function() expanded,
    required T Function() large,
    required T Function() extraLarge,
  }) => switch (this) {
    .compact => compact(),
    .medium => medium(),
    .expanded => expanded(),
    .large => large(),
    .extraLarge => extraLarge(),
  };

  /// Maps this size class, or returns [orElse] when its handler is omitted.
  T maybeMap<T>({
    required T Function() orElse,
    T Function()? compact,
    T Function()? medium,
    T Function()? expanded,
    T Function()? large,
    T Function()? extraLarge,
  }) => map(
    compact: compact ?? orElse,
    medium: medium ?? orElse,
    expanded: expanded ?? orElse,
    large: large ?? orElse,
    extraLarge: extraLarge ?? orElse,
  );

  /// Maps this size class, cascading down to the nearest smaller handler given; [compact] is
  /// the floor. On an `expanded` window with only `compact` and `medium` given, `medium` wins.
  T mapWithLowerFallback<T>({
    required T Function() compact,
    T Function()? medium,
    T Function()? expanded,
    T Function()? large,
    T Function()? extraLarge,
  }) => map(
    compact: compact,
    medium: medium ?? compact,
    expanded: expanded ?? medium ?? compact,
    large: large ?? expanded ?? medium ?? compact,
    extraLarge: extraLarge ?? large ?? expanded ?? medium ?? compact,
  );
}
