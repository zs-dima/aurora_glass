import 'package:aurora_glass/src/theme/brand.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// A QR code, painted here over the pure-Dart `package:qr` encoder: rounded modules on a card,
/// so the code belongs on the chassis.
///
/// The modules are painted at full opacity on an opaque light ground in both themes. A camera
/// needs a hard light/dark boundary; a code tinted to the palette does not scan.
class QrView extends StatefulWidget {
  /// Creates a [QrView].
  const QrView({required this.data, required this.semanticsLabel, this.size = 220, super.key});

  /// What the code encodes.
  final String data;

  /// What a screen reader is told instead of the code, localized by the caller.
  ///
  /// This is the whole accessible surface of the widget. Say what the code is and what to do
  /// instead; a screen that shows a QR code also shows a typed alternative.
  final String semanticsLabel;

  /// Side length in logical pixels.
  final double size;

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  /// Encoded once per [QrView.data], not per build.
  late QrImage _image;

  static QrImage _encode(String data) => .new(
    QrCode.fromData(
      data: data,
      // About 15% of the code may be obscured and still decode; a code held at arm's length under
      // a hallway light earns the extra modules.
      errorCorrectLevel: QrErrorCorrectLevel.M,
    ),
  );

  @override
  void initState() {
    super.initState();
    _image = _encode(widget.data);
  }

  @override
  void didUpdateWidget(covariant QrView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _image = _encode(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    final brand = Brand.of(context);

    return Semantics(
      label: widget.semanticsLabel,
      image: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Opaque and light regardless of theme: a scanning target, not a surface.
          color: const Color(0xFFF7F5FF),
          borderRadius: AppShape.card,
          border: .all(color: brand.cardBorder),
        ),
        child: Padding(
          padding: const .all(AppSpacing.md),
          // Its own layer: a few thousand rounded rects must not repaint with a pulsing dot next to
          // them.
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _QrPainter(_image),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter(this._image);

  final QrImage _image;

  @override
  void paint(Canvas canvas, Size size) {
    final count = _image.moduleCount;
    final module = size.width / count;
    final paint = Paint()..color = const Color(0xFF120A18);
    // A hair of overlap: exactly adjacent rects at fractional sizes leave seams a camera reads as
    // noise.
    final radius = Radius.circular(module * 0.3);

    for (var y = 0; y < count; y++) {
      for (var x = 0; x < count; x++) {
        if (!_image.isDark(y, x)) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x * module, y * module, module + 0.5, module + 0.5),
            radius,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => !identical(oldDelegate._image, _image);
}
