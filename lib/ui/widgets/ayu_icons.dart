import 'package:flutter/material.dart';

/// Hand-drawn brand glyphs, palette-matched via ambient IconTheme color.
/// Lotus = calm mind, Leaf = everyday herbs, Drop = water.
enum _Glyph { lotus, leaf, drop }

class AyuGlyph extends StatelessWidget {
  const AyuGlyph.lotus({super.key, this.size = 24}) : _glyph = _Glyph.lotus;
  const AyuGlyph.leaf({super.key, this.size = 24}) : _glyph = _Glyph.leaf;
  const AyuGlyph.drop({super.key, this.size = 24}) : _glyph = _Glyph.drop;

  final _Glyph _glyph;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.primary;
    return CustomPaint(
      size: Size.square(size),
      painter: _BrandPainter(color, _glyph),
    );
  }
}

class _BrandPainter extends CustomPainter {
  _BrandPainter(this.color, this.glyph);
  final Color color;
  final _Glyph glyph;

  Paint get _p => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    switch (glyph) {
      case _Glyph.lotus:
        _lotus(canvas, size);
      case _Glyph.leaf:
        _leaf(canvas, size);
      case _Glyph.drop:
        _drop(canvas, size);
    }
  }

  void _lotus(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = _p..strokeWidth = w * 0.075;
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.5, h * 0.88)
          ..quadraticBezierTo(w * 0.5, h * 0.45, w * 0.5, h * 0.12)
          ..quadraticBezierTo(w * 0.5, h * 0.45, w * 0.5, h * 0.88),
        p);
    for (final s in [-1.0, 1.0]) {
      canvas.drawPath(
          Path()
            ..moveTo(w * 0.5, h * 0.88)
            ..quadraticBezierTo(
                w * (0.5 + s * 0.28), h * 0.62, w * (0.5 + s * 0.38), h * 0.34),
          p);
      canvas.drawPath(
          Path()
            ..moveTo(w * 0.5, h * 0.9)
            ..quadraticBezierTo(
                w * (0.5 + s * 0.42), h * 0.86, w * (0.5 + s * 0.46), h * 0.62),
          p);
    }
    canvas.drawArc(Rect.fromLTWH(w * 0.08, h * 0.72, w * 0.84, h * 0.3), 0.15,
        3.14 - 0.3, false, p);
  }

  void _leaf(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = _p..strokeWidth = w * 0.075;
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.5, h * 0.08)
          ..quadraticBezierTo(w * 0.95, h * 0.4, w * 0.5, h * 0.92)
          ..quadraticBezierTo(w * 0.05, h * 0.4, w * 0.5, h * 0.08),
        p);
    canvas.drawLine(Offset(w * 0.5, h * 0.14), Offset(w * 0.5, h * 0.86), p);
    final thin = _p..strokeWidth = w * 0.06;
    canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w * 0.72, h * 0.3), thin);
    canvas.drawLine(
        Offset(w * 0.5, h * 0.58), Offset(w * 0.28, h * 0.48), thin);
  }

  void _drop(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = _p..strokeWidth = w * 0.075;
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.5, h * 0.06)
          ..quadraticBezierTo(w * 0.88, h * 0.55, w * 0.5, h * 0.94)
          ..quadraticBezierTo(w * 0.12, h * 0.55, w * 0.5, h * 0.06),
        p);
  }

  @override
  bool shouldRepaint(covariant _BrandPainter old) =>
      old.color != color || old.glyph != glyph;
}
