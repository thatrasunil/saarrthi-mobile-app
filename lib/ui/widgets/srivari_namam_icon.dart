import 'package:flutter/material.dart';

class SrivariNamamIcon extends StatelessWidget {
  final double size;
  final Color whiteColor;
  final Color redColor;

  const SrivariNamamIcon({
    super.key,
    this.size = 24.0,
    this.whiteColor = const Color(0xFFE2E8F0),
    this.redColor = const Color(0xFFDC2626),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.75, size),
      painter: _NamamPainter(whiteColor: whiteColor, redColor: redColor),
    );
  }
}

class _NamamPainter extends CustomPainter {
  final Color whiteColor;
  final Color redColor;

  _NamamPainter({required this.whiteColor, required this.redColor});

  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = whiteColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.12).clamp(1.5, 3.0)
      ..strokeCap = StrokeCap.round;

    final redPaint = Paint()
      ..color = redColor
      ..style = PaintingStyle.fill;

    // White 'U' shaped Namam (Thiruman)
    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.08);
    path.lineTo(size.width * 0.15, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.98,
      size.width * 0.85,
      size.height * 0.65,
    );
    path.lineTo(size.width * 0.85, size.height * 0.08);
    canvas.drawPath(path, whitePaint);

    // Red center line / sacred Tilak (Srichurnam)
    final tilakPath = Path();
    tilakPath.moveTo(size.width * 0.44, size.height * 0.15);
    tilakPath.lineTo(size.width * 0.56, size.height * 0.15);
    tilakPath.lineTo(size.width * 0.53, size.height * 0.78);
    tilakPath.lineTo(size.width * 0.47, size.height * 0.78);
    tilakPath.close();
    canvas.drawPath(tilakPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant _NamamPainter oldDelegate) {
    return oldDelegate.whiteColor != whiteColor || oldDelegate.redColor != redColor;
  }
}
